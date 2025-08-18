# kit-monitor â€” Despliegue Railway

## Servicios
- **Backend (NestJS)** carpeta \ackend\. Health: \/api/health\.
- **Frontend (Angular+Node)** carpeta \rontend\. Sirve SPA y **proxy** \/api\ â†’ backend.
- **PostgreSQL** de Railway.

## Variables de Entorno
### Backend
- NODE_ENV=production
- PORT (asignado por Railway)
- ALLOWED_ORIGIN=https://your-frontend.up.railway.app
- FRONTEND_SHARED_KEY=change-me-strong-key
- DATABASE_URL (de Postgres Railway, con \sslmode=require\)

### Frontend
- PORT (asignado por Railway)
- BACKEND_URL=https://your-backend.up.railway.app
- FRONTEND_SHARED_KEY=change-me-strong-key

## Check
- \GET https://<frontend>/api/health\ â†’ 200 (via proxy).
- Rutas SPA OK; sin CORS.
