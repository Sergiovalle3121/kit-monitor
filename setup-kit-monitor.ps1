<#  setup-kit-monitor.ps1
    Ejecuta este script desde la raíz del repo (la carpeta que contiene /backend y /frontend).
    Hace TODO: CORS, /api, proxy en frontend, Dockerfiles, env examples, etc.

    --- CONFIG EDITABLE ---
#>
$FrontendDomain   = "https://your-frontend.up.railway.app"  # dominio público final del FRONTEND en Railway
$BackendPublicUrl = "https://your-backend.up.railway.app"   # dominio público del BACKEND en Railway (para proxy del server.js)
$SharedKey        = "change-me-strong-key"                  # debe ser igual en frontend y backend

# --- No edites de aquí hacia abajo ---
$ErrorActionPreference = "Stop"

function Ensure-Dir($p){
  if(-not (Test-Path $p)){ New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

function Write-Text($path,$content){
  Ensure-Dir (Split-Path $path -Parent)
  if(Test-Path $path){ Copy-Item $path "$($path).bak" -Force }
  Set-Content -Path $path -Value $content -Encoding UTF8
}

function Replace-Regex($path,$pattern,$replace){
  if(-not (Test-Path $path)){ return }
  $txt = Get-Content $path -Raw
  $new = [regex]::Replace($txt,$pattern,$replace)
  if($new -ne $txt){
    Copy-Item $path "$($path).bak" -Force
    Set-Content $path $new -Encoding UTF8
  }
}

function Add-NpmDep($packageJsonPath,$name,$version){
  $pkg = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

  if(-not $pkg.dependencies){
    $pkg | Add-Member -NotePropertyName dependencies -NotePropertyValue ([pscustomobject]@{})
  }

  # Convertir dependencies a hashtable (soporta claves con guiones)
  $depsHash = @{}
  foreach($p in $pkg.dependencies.PSObject.Properties){
    $depsHash[$p.Name] = $p.Value
  }

  $depsHash[$name] = $version
  $pkg.dependencies = [pscustomobject]$depsHash
  ($pkg | ConvertTo-Json -Depth 100) | Set-Content $packageJsonPath -Encoding UTF8
}

$root     = (Get-Location).Path
$backend  = Join-Path $root "backend"
$frontend = Join-Path $root "frontend"

if(-not (Test-Path $backend) -or -not (Test-Path $frontend)){
  throw "No encuentro carpetas 'backend' y 'frontend' aquí: $root"
}

# ---------------------------
# BACKEND (NestJS)
# ---------------------------

# main.ts con /api, CORS por ALLOWED_ORIGIN, helmet/compression y llave compartida
$backendMain = @"
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import compression from 'compression';
import { Request, Response, NextFunction } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });

  app.use(helmet());
  app.use(compression());

  // API bajo /api
  app.setGlobalPrefix('api');

  const env = process.env.NODE_ENV || 'development';
  const allowedOrigin = process.env.ALLOWED_ORIGIN || (env === 'production'
    ? '$FrontendDomain'
    : 'http://localhost:8080');

  app.enableCors({
    origin: [allowedOrigin],
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type','Authorization','x-frontend-key'],
  });

  // En prod, exigir header compartido desde el proxy del frontend
  const sharedKey = process.env.FRONTEND_SHARED_KEY;
  if (env === 'production' && sharedKey) {
    app.use((req: Request, res: Response, next: NextFunction) => {
      if (req.path === '/api/health') return next(); // health abierto
      const got = req.header('x-frontend-key');
      if (got !== sharedKey) return res.status(403).json({ error: 'Forbidden' });
      return next();
    });
  }

  const port = parseInt(process.env.PORT ?? '3000', 10);
  await app.listen(port, '0.0.0.0');
  console.log(`API listening on :${port} (NODE_ENV=${env}) allowedOrigin=${allowedOrigin}`);
}
bootstrap();
"@
Write-Text (Join-Path $backend "src\main.ts") $backendMain

# HealthController mínimo si no existe
$healthCtrlPath = Join-Path $backend "src\health\health.controller.ts"
if(-not (Test-Path $healthCtrlPath)){
  Write-Text $healthCtrlPath @"
import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('health')
  health() {
    return { status: 'ok', time: new Date().toISOString() };
  }
}
"@
}

# Asegurar app.module importa el HealthController (si existe app.module.ts)
$appModulePath = Join-Path $backend "src\app.module.ts"
if(Test-Path $appModulePath){
  $appTxt = Get-Content $appModulePath -Raw
  if($appTxt -notmatch "HealthController"){
    # Inyecta en la lista de controllers
    $appTxt = $appTxt -replace "(@Module\(\{\s*imports:\s*\[[^\]]*\],\s*controllers:\s*\[)","`$1HealthController, "
    # Añade import si no existe
    if($appTxt -notmatch 'from\s+\./health/health\.controller'){
      $appTxt = "import { HealthController } from './health/health.controller';`r`n" + $appTxt
    }
    Set-Content $appModulePath $appTxt -Encoding UTF8
  }
}

# Backend Dockerfile
Write-Text (Join-Path $backend "Dockerfile") @"
# ---- Build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- Run ----
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
EXPOSE 3000
CMD ["node","dist/main.js"]
"@

# Backend .env.example
Write-Text (Join-Path $backend ".env.example") @"
# Backend environment
NODE_ENV=production
PORT=3000
ALLOWED_ORIGIN=$FrontendDomain
FRONTEND_SHARED_KEY=$SharedKey

# Railway Postgres (reemplaza host/credenciales con los de Railway)
DATABASE_URL=postgresql://postgres:password@host:5432/railway?sslmode=require

# Dev (opcional):
# DB_HOST=localhost
# DB_PORT=5432
# DB_USERNAME=postgres
# DB_PASSWORD=postgres
# DB_DATABASE=kitmonitor
# SYNCHRONIZE=false
"@

# Asegurar scripts package.json mínimos
$bpkgPath = Join-Path $backend "package.json"
if(Test-Path $bpkgPath){
  $bpkg = Get-Content $bpkgPath -Raw | ConvertFrom-Json
  if(-not $bpkg.scripts) { $bpkg | Add-Member -NotePropertyName scripts -NotePropertyValue (@{}) }
  $bpkg.scripts.build = "nest build"
  if(-not $bpkg.scripts."start:prod"){ $bpkg.scripts | Add-Member -Name "start:prod" -Value "node dist/main.js" -MemberType NoteProperty }
  ($bpkg | ConvertTo-Json -Depth 100) | Set-Content $bpkgPath -Encoding UTF8
}

# ---------------------------
# FRONTEND (Angular + Node/Express server.js)
# ---------------------------

# environment.prod.ts => apiBaseUrl '/api'
$envProdPath = Join-Path $frontend "src\environments\environment.prod.ts"
if(Test-Path $envProdPath){
  Replace-Regex $envProdPath 'apiBaseUrl\s*:\s*[''"][^''"]+[''"]' "apiBaseUrl: '/api'"
  $txt = Get-Content $envProdPath -Raw
  if($txt -notmatch "apiBaseUrl"){
    $txt = $txt -replace "\}\s*;?\s*$", ", apiBaseUrl: '/api' };"
    Set-Content $envProdPath $txt -Encoding UTF8
  }
}else{
  Write-Text $envProdPath "export const environment = { production: true, apiBaseUrl: '/api' };"
}

# server.js -> añade proxy /api → BACKEND_URL + header x-frontend-key
$serverJs = Join-Path $frontend "server.js"
if(Test-Path $serverJs){
  $srv = Get-Content $serverJs -Raw
}else{
  $srv = @"
const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const candidates = [
  path.join(__dirname, 'dist', 'frontend', 'browser'),
  path.join(__dirname, 'dist', 'kit-monitor', 'browser')
];
const distPath = candidates.find(p => fs.existsSync(p)) || candidates[0];
app.use(express.static(distPath));
app.get('*', (_req, res) => res.sendFile(path.join(distPath, 'index.html')));
const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => console.log(`Frontend listening on :${port} -> ${distPath}`));
"@
}

if($srv -notmatch "http-proxy-middleware"){
  $proxyBlock = @"
const { createProxyMiddleware } = require('http-proxy-middleware');
const backendTarget = process.env.BACKEND_URL || '$BackendPublicUrl';
const sharedKey = process.env.FRONTEND_SHARED_KEY || '$SharedKey';

if (backendTarget) {
  app.use('/api', createProxyMiddleware({
    target: backendTarget,
    changeOrigin: true,
    pathRewrite: {'^/api': '/api'},
    onProxyReq: (proxyReq) => {
      if (sharedKey) proxyReq.setHeader('x-frontend-key', sharedKey);
    }
  }));
}
"@
  $srv = $srv -replace "app.use\(express\.static\(distPath\)\);\s*", "app.use(express.static(distPath));`r`n$proxyBlock`r`n"
}
Write-Text $serverJs $srv

# Añadir dependencia http-proxy-middleware al frontend
$fpkgPath = Join-Path $frontend "package.json"
if(Test-Path $fpkgPath){ Add-NpmDep $fpkgPath "http-proxy-middleware" "^3.0.0" }

# Frontend Dockerfile
Write-Text (Join-Path $frontend "Dockerfile") @"
# ---- Build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- Run ----
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/server.js ./server.js
ENV PORT=8080
EXPOSE 8080
CMD ["node","server.js"]
"@

# Frontend .env.example
Write-Text (Join-Path $frontend ".env.example") @"
# Frontend runtime (Railway)
PORT=8080
BACKEND_URL=$BackendPublicUrl
FRONTEND_SHARED_KEY=$SharedKey
"@

# ---------------------------
# README de despliegue
# ---------------------------
Write-Text (Join-Path $root "README-DEPLOY.md") @"
# kit-monitor — Despliegue Railway

## Servicios
- **Backend (NestJS)** carpeta \`backend\`. Health: \`/api/health\`.
- **Frontend (Angular+Node)** carpeta \`frontend\`. Sirve SPA y **proxy** \`/api\` → backend.
- **PostgreSQL** de Railway.

## Variables de Entorno
### Backend
- NODE_ENV=production
- PORT (asignado por Railway)
- ALLOWED_ORIGIN=$FrontendDomain
- FRONTEND_SHARED_KEY=$SharedKey
- DATABASE_URL (de Postgres Railway, con \`sslmode=require\`)

### Frontend
- PORT (asignado por Railway)
- BACKEND_URL=$BackendPublicUrl
- FRONTEND_SHARED_KEY=$SharedKey

## Check
- \`GET https://<frontend>/api/health\` → 200 (via proxy).
- Rutas SPA OK; sin CORS.
"@

Write-Host "`n✅ Cambios aplicados. Revisa backups *.bak si quieres comparar."
Write-Host "Opcional en local:"
Write-Host "  cd backend  && npm ci && npm run build"
Write-Host "  cd ../frontend && npm ci && npm run build"
Write-Host "`nLuego haz commit & push a GitHub; crea 2 servicios en Railway usando los Dockerfiles."
