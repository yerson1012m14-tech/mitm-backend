# Conexión XITFORGE ↔ backend

`KeyViewController.m` ahora envía `POST /api/validate` con:

- `key`
- `device_id` basado en `identifierForVendor`
- `app_version`

## Antes de compilar

Cambia `XITFORGE_SERVER_URL` en `MiApp/KeyViewController.m` por la IP del PC que ejecuta el backend, por ejemplo:

`http://192.168.1.50:8080`

El PC debe permitir conexiones entrantes al puerto 8080 en el firewall de Windows.

Para producción, cambia esa URL por un endpoint HTTPS público del backend.

La app no contiene el token de administrador.
