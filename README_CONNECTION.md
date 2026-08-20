# XITFORGE - backend connection

The app is configured to validate Keys against:

`http://10.0.0.19:8080/api/validate`

The iPhone and PC must be on the same LAN. The Windows backend must listen on `0.0.0.0:8080` and allow inbound TCP 8080 in Windows Firewall.

The app uses the existing XITFORGE Key UI and the working full-screen layout. The original app engine is not modified by this change.
