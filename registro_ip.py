from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

from flask import Flask, jsonify, request
from flask_cors import CORS

APP = Flask(__name__)
CORS(APP)

DB_FILE = Path("/data/usuarios.json")
RESET_HOURS = 24
ADMIN_TOKEN = "jasonxit_admin_local_123456789"


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def parse_iso(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except Exception:
        return None


def load_db() -> dict[str, Any]:
    if not DB_FILE.exists():
        return {}

    text = DB_FILE.read_text(encoding="utf-8").strip()
    if not text:
        return {}

    try:
        data = json.loads(text)
        if isinstance(data, dict):
            return data
    except Exception:
        pass

    return {}


def save_db(data: dict[str, Any]) -> None:
    DB_FILE.write_text(
        json.dumps(data, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )


def format_remaining_delta(delta: timedelta) -> str:
    total = int(delta.total_seconds())
    if total <= 0:
        return "0M"

    days = total // 86400
    hours = (total % 86400) // 3600
    minutes = (total % 3600) // 60
    seconds = total % 60

    parts: list[str] = []
    if days:
        parts.append(f"{days}D")
    if hours:
        parts.append(f"{hours}H")
    if minutes:
        parts.append(f"{minutes}M")
    if seconds or not parts:
        parts.append(f"{seconds}S")

    return " ".join(parts)


def format_key_time(rec: dict[str, Any]) -> str:
    plan = str(rec.get("plan", "")).lower()
    if plan == "permanent":
        return "PERMANENTE"

    expires_at = parse_iso(rec.get("expires_at"))
    if not expires_at:
        return "SIN ACTIVAR"

    delta = expires_at - now_utc()
    if delta.total_seconds() <= 0:
        return "VENCIDA"

    return format_remaining_delta(delta)


def find_user_by_key(key_value: str, data: dict[str, Any]) -> tuple[str | None, dict[str, Any] | None]:
    for username, rec in data.items():
        if isinstance(rec, dict) and rec.get("password") == key_value:
            return username, rec
    return None, None


def ensure_ip_fields(rec: dict[str, Any]) -> None:
    rec.setdefault("bound_ip", None)
    rec.setdefault("bound_at", None)
    rec.setdefault("last_ip_reset_at", None)


def key_is_usable(rec: dict[str, Any]) -> tuple[bool, str]:
    if not rec.get("active", True):
        return False, "Key desactivada"

    status = str(rec.get("status", "")).lower()
    if status == "paused":
        return False, "Key pausada"
    if status == "expired":
        return False, "Key vencida"

    plan = str(rec.get("plan", "")).lower()
    if plan != "permanent":
        expires_at = parse_iso(rec.get("expires_at"))
        if expires_at and now_utc() >= expires_at:
            return False, "Key vencida"

    return True, "OK"


def get_request_ip() -> str:
    forwarded = request.headers.get("X-Forwarded-For", "").strip()
    if forwarded:
        return forwarded.split(",")[0].strip()

    real_ip = request.headers.get("X-Real-IP", "").strip()
    if real_ip:
        return real_ip

    return request.remote_addr or "unknown"


def is_admin(req) -> bool:
    token = req.headers.get("X-Admin-Token", "").strip()
    return token == ADMIN_TOKEN


@APP.post("/api/registrar-ip")
def registrar_ip():
    data = load_db()
    payload = request.get_json(silent=True) or {}

    key_value = str(payload.get("key", "")).strip()
    ip_value = str(payload.get("ip", "")).strip() or get_request_ip()

    if not key_value:
        return jsonify({"ok": False, "message": "Debes introducir una key."}), 400

    username, rec = find_user_by_key(key_value, data)
    if not rec or not username:
        return jsonify({"ok": False, "message": "La key no es valida."}), 404

    ensure_ip_fields(rec)

    usable, msg = key_is_usable(rec)
    if not usable:
        return jsonify({"ok": False, "message": msg}), 403

    bound_ip = rec.get("bound_ip")

    if not bound_ip:
        rec["bound_ip"] = ip_value
        rec["bound_at"] = iso(now_utc())
        data[username] = rec
        save_db(data)
        return jsonify({
            "ok": True,
            "message": f"IP registrada correctamente: {ip_value}",
            "username": username,
            "time_left": format_key_time(rec),
            "bound_ip": rec["bound_ip"],
        })

    if bound_ip == ip_value:
        return jsonify({
            "ok": True,
            "message": "Esta key ya esta registrada con tu IP actual.",
            "username": username,
            "time_left": format_key_time(rec),
            "bound_ip": rec["bound_ip"],
        })

    return jsonify({
        "ok": False,
        "message": "Esta key ya esta vinculada a otra IP. Usa Reset IP si necesitas cambiarla.",
        "username": username,
        "time_left": format_key_time(rec),
        "bound_ip": rec["bound_ip"],
    }), 409


@APP.post("/api/reset-ip")
def reset_ip():
    data = load_db()
    payload = request.get_json(silent=True) or {}

    key_value = str(payload.get("key", "")).strip()
    new_ip = str(payload.get("ip", "")).strip() or get_request_ip()

    if not key_value:
        return jsonify({"ok": False, "message": "Debes introducir una key."}), 400

    username, rec = find_user_by_key(key_value, data)
    if not rec or not username:
        return jsonify({"ok": False, "message": "La key no es valida."}), 404

    ensure_ip_fields(rec)

    usable, msg = key_is_usable(rec)
    if not usable:
        return jsonify({"ok": False, "message": msg}), 403

    last_reset = parse_iso(rec.get("last_ip_reset_at"))
    now = now_utc()

    if last_reset:
        next_allowed = last_reset + timedelta(hours=RESET_HOURS)
        if now < next_allowed:
            remaining = next_allowed - now
            return jsonify({
                "ok": False,
                "message": f"No puedes cambiar la IP todavia. Intentalo de nuevo en {format_remaining_delta(remaining)}.",
                "time_left": format_key_time(rec),
                "bound_ip": rec.get("bound_ip"),
            }), 429

    rec["bound_ip"] = new_ip
    rec["bound_at"] = iso(now)
    rec["last_ip_reset_at"] = iso(now)
    data[username] = rec
    save_db(data)

    return jsonify({
        "ok": True,
        "message": f"IP actualizada correctamente: {new_ip}",
        "username": username,
        "time_left": format_key_time(rec),
        "bound_ip": rec["bound_ip"],
    })


@APP.post("/api/admin/upsert-user")
def admin_upsert_user():
    if not is_admin(request):
        return jsonify({"ok": False, "message": "No autorizado"}), 401

    data = load_db()
    payload = request.get_json(silent=True) or {}

    username = str(payload.get("username", "")).strip()
    record = payload.get("record")

    if not username or not isinstance(record, dict):
        return jsonify({"ok": False, "message": "Datos invalidos"}), 400

    data[username] = record
    save_db(data)

    return jsonify({"ok": True, "message": "Usuario sincronizado"})


@APP.post("/api/admin/delete-user")
def admin_delete_user():
    if not is_admin(request):
        return jsonify({"ok": False, "message": "No autorizado"}), 401

    data = load_db()
    payload = request.get_json(silent=True) or {}

    username = str(payload.get("username", "")).strip()
    if not username:
        return jsonify({"ok": False, "message": "Username requerido"}), 400

    if username in data:
        del data[username]
        save_db(data)

    return jsonify({"ok": True, "message": "Usuario borrado"})


@APP.get("/api/ping")
def ping():
    return jsonify({"ok": True, "message": "Backend activo"})
    
@APP.get("/api/admin/export-users")
def admin_export_users():
    if not is_admin(request):
        return jsonify({"ok": False, "message": "No autorizado"}), 401

    data = load_db()
    return jsonify({"ok": True, "users": data})

if __name__ == "__main__":
    APP.run(host="0.0.0.0", port=5050, debug=False)
