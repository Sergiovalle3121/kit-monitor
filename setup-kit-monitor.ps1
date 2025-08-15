# setup-kit-monitor.ps1
# Ejecutar desde la raíz del repo: kit-monitor/
# Requiere: PowerShell 5+ y Node/npm instalados.

Set-StrictMode -Version Latest
Continue = 'Stop'

function Ensure-Folder() { if (-not (Test-Path )) { New-Item -ItemType Directory -Force -Path  | Out-Null } }

# Verifica estructura
if (-not (Test-Path ".\backend"))  { throw "No se encontró carpeta .\backend. Ejecuta este script desde la raíz del proyecto (kit-monitor)." }
if (-not (Test-Path ".\frontend")) { throw "No se encontró carpeta .\frontend. Ejecuta este script desde la raíz del proyecto (kit-monitor)." }

Write-Host "==> Configurando BACKEND (NestJS)..." -ForegroundColor Cyan

# -------------------------
# BACKEND: main.ts
# -------------------------
 = ".\backend\src"
Ensure-Folder 
 = Join-Path  "main.ts"

@'
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });

  app.enableCors({
    origin: [
      'https://mindful-presence-production-1bd7.up.railway.app',
    ],
    credentials: true,
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type','Authorization'],
  });

  const port = parseInt(process.env.PORT ?? '3000', 10);
  await app.listen(port, '0.0.0.0');
  console.log(API listening on :);
}
bootstrap();
'@ | Set-Content -NoNewline -Encoding UTF8 

# -------------------------
# BACKEND: Health Controller
# -------------------------
 = Join-Path  "health"
Ensure-Folder 
 = Join-Path  "health.controller.ts"

@'
import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('health')
  health() {
    return { status: 'ok', time: new Date().toISOString() };
  }
}
'@ | Set-Content -NoNewline -Encoding UTF8 

# -------------------------
# BACKEND: app.module.ts -> inyectar HealthController
# -------------------------
 = Join-Path  "app.module.ts"
if (Test-Path ) {
   = Get-Content -Raw 

  if ( -notmatch 'HealthController') {
    # Agrega import
    if ( -match "import\s+\{\s*Module\s*\}\s+from\s+'@nestjs/common';") {
       =  -replace "(import\s+\{\s*Module\s*\}\s+from\s+'@nestjs/common';\s*)", "$1
import { HealthController } from './health/health.controller';
"
    } elseif ( -match "^import\s") {
       =  -replace "^(import[^\r\n]*[\r\n]+)", "$1import { HealthController } from './health/health.controller';
"
    } else {
       = "import { HealthController } from './health/health.controller';
" + 
    }

    # Inserta en metadata @Module
    if ( -match "@Module\(\{\s*[^)]*\}\)\s*export\s+class\s+AppModule") {
      if ( -match "controllers\s*:\s*\[([^\]]*)\]") {
        # Ya hay controllers: agrega HealthController si no existe
         =  -replace "(controllers\s*:\s*\[)([^\]]*)\]", { 
          param()
           = .Groups[2].Value
          if ( -notmatch "HealthController") {
            return .Groups[1].Value + .Trim() + (if (.Trim() -eq '') { "HealthController" } else { ", HealthController" }) + "]"
          } else {
            return .Value
          }
        }
      } else {
        # No hay controllers: inserta controllers: [HealthController],
         =  -replace "(@Module\(\{\s*)", "$1controllers: [HealthController],
  "
      }
    } else {
      Write-Warning "No se detectó el decorador @Module en app.module.ts; revisa manualmente controllers: [HealthController]."
    }

     | Set-Content -Encoding UTF8 
  }
} else {
  Write-Warning "No existe backend/src/app.module.ts. Crea tu AppModule y registra HealthController en controllers."
}

# -------------------------
# BACKEND: package.json -> scripts y engines
# -------------------------
 = ".\backend\package.json"
if (Test-Path ) {
   = Get-Content -Raw  | ConvertFrom-Json
} else {
   = [pscustomobject]@{ name="kit-monitor-backend"; version="1.0.0"; private=True }
}
if (-not .scripts) {  | Add-Member -Name scripts -MemberType NoteProperty -Value (@{}) }
.scripts.build       = "nest build"
.scripts.start       = "nest start"
.scripts."start:prod"= "node dist/main.js"
.scripts.postinstall = "npm run build"

if (-not .engines) {  | Add-Member -Name engines -MemberType NoteProperty -Value (@{}) }
.engines.node = ">=18"

( | ConvertTo-Json -Depth 20) | Set-Content -Encoding UTF8 

Write-Host "==> Configurando FRONTEND (Angular)..." -ForegroundColor Cyan

# -------------------------
# FRONTEND: server.js (sirve dist con fallback)
# -------------------------
 = ".\frontend"
 = Join-Path  "server.js"

@'
const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

// Intento autodetectar carpeta dist:
const candidates = [
  path.join(__dirname, 'dist', 'frontend', 'browser'),
  path.join(__dirname, 'dist', 'kit-monitor', 'browser')
];
const distPath = candidates.find(p => fs.existsSync(p)) || candidates[0];

app.use(express.static(distPath));

app.get('*', (_req, res) => {
  res.sendFile(path.join(distPath, 'index.html'));
});

const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => console.log(Frontend listening on : -> ));
'@ | Set-Content -NoNewline -Encoding UTF8 

# -------------------------
# FRONTEND: package.json -> scripts, engines, deps (express)
# -------------------------
 = ".\frontend\package.json"
if (Test-Path ) {
   = Get-Content -Raw  | ConvertFrom-Json
} else {
   = [pscustomobject]@{ name="kit-monitor-frontend"; version="1.0.0"; private=True }
}

if (-not .scripts) {  | Add-Member -Name scripts -MemberType NoteProperty -Value (@{}) }
.scripts.build       = "ng build --configuration production"
.scripts.start       = "node server.js"
.scripts.postinstall = "npm run build"

if (-not .engines) {  | Add-Member -Name engines -MemberType NoteProperty -Value (@{}) }
.engines.node = ">=18"

if (-not .dependencies) {  | Add-Member -Name dependencies -MemberType NoteProperty -Value (@{}) }
if (-not .dependencies.express) { .dependencies.express = "^4.19.2" }

( | ConvertTo-Json -Depth 20) | Set-Content -Encoding UTF8 

# -------------------------
# FRONTEND: environments
# -------------------------
 = ".\frontend\src\environments"
Ensure-Folder 

@'
export const environment = {
  production: false,
  apiBase: 'http://localhost:3000'
};
'@ | Set-Content -NoNewline -Encoding UTF8 (Join-Path  "environment.ts")

@'
export const environment = {
  production: true,
  apiBase: 'https://kit-monitor-production.up.railway.app'
};
'@ | Set-Content -NoNewline -Encoding UTF8 (Join-Path  "environment.prod.ts")

# -------------------------
# FRONTEND: interceptor
# -------------------------
 = ".\frontend\src\app\core"
Ensure-Folder 
 = Join-Path  "api.interceptor.ts"
@'
import { Injectable } from '@angular/core';
import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable()
export class ApiBaseInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (req.url.startsWith('/')) {
      const apiReq = req.clone({ url: environment.apiBase + req.url });
      return next.handle(apiReq);
    }
    return next.handle(req);
  }
}
'@ | Set-Content -NoNewline -Encoding UTF8 

# -------------------------
# FRONTEND: registrar interceptor (mejor esfuerzo)
# - Si existe AppModule => agrega HttpClientModule y provider
# - Si no, intenta standalone en main.ts (provideHttpClient)
# -------------------------
 = ".\frontend\src\app\app.module.ts"
      = ".\frontend\src\main.ts"

function Add-Provider-To-AppModule {
  param([string])
   = Get-Content -Raw 

  if ( -notmatch "HttpClientModule") {
     =  -replace "(@NgModule\(\{)", "import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
"
  } elseif ( -notmatch "HTTP_INTERCEPTORS") {
     =  -replace "import\s+\{\s*HttpClientModule\s*\}\s+from\s+'@angular/common/http';", "import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';"
  }

  if ( -notmatch "ApiBaseInterceptor") {
     =  -replace "(@NgModule\(\{)", "import { ApiBaseInterceptor } from './core/api.interceptor';
"
  }

  # Agrega HttpClientModule en imports:
  if ( -match "imports\s*:\s*\[([^\]]*)\]") {
     =  -replace "(imports\s*:\s*\[)([^\]]*)\]", { 
      param()
       = .Groups[2].Value
      if ( -notmatch "HttpClientModule") {
        return .Groups[1].Value + .Trim() + (if (.Trim() -eq '') { "HttpClientModule" } else { ", HttpClientModule" }) + "]"
      } else { .Value }
    }
  }

  # Agrega provider del interceptor:
  if ( -match "providers\s*:\s*\[([^\]]*)\]") {
     =  -replace "(providers\s*:\s*\[)([^\]]*)\]", {
      param()
       = .Groups[2].Value
      if ( -notmatch "HTTP_INTERCEPTORS") {
         = "{ provide: HTTP_INTERCEPTORS, useClass: ApiBaseInterceptor, multi: true }"
        return .Groups[1].Value + .Trim() + (if (.Trim() -eq '') {  } else { ", " }) + "]"
      } else { .Value }
    }
  } else {
    # No había providers: crear sección
     =  -replace "(@NgModule\(\{\s*)", "$1providers: [{ provide: HTTP_INTERCEPTORS, useClass: ApiBaseInterceptor, multi: true }],
  "
  }

   | Set-Content -Encoding UTF8 
}

function Add-Interceptor-Standalone {
  param([string])
   = Get-Content -Raw 

  if ( -notmatch "provideHttpClient") {
    if ( -match "from\s+'@angular/common';") {
       =  -replace "from\s+'@angular/common';", "from '@angular/common';
import { provideHttpClient, withInterceptors } from '@angular/common/http';"
    } else {
       = "import { provideHttpClient, withInterceptors } from '@angular/common/http';
" + 
    }
  } elseif ( -notmatch "withInterceptors") {
     =  -replace "provideHttpClient", "provideHttpClient, withInterceptors"
  }

  if ( -notmatch "ApiBaseInterceptor") {
     =  -replace "from\s+'@angular/core';", "from '@angular/core';
import { ApiBaseInterceptor } from './app/core/api.interceptor';"
  }

  if ( -match "bootstrapApplication\([^\)]*,\s*\{\s*providers\s*:\s*\[([^\]]*)\]") {
     =  -replace "(bootstrapApplication\([^\)]*,\s*\{\s*providers\s*:\s*\[)([^\]]*)\]", {
      param()
       = .Groups[2].Value
      if ( -notmatch "provideHttpClient") {
        return .Groups[1].Value + .Trim() + (if (.Trim() -eq '') { "provideHttpClient(withInterceptors([(req, next) => new ApiBaseInterceptor().intercept(req, next)]))" } else { ", provideHttpClient(withInterceptors([(req, next) => new ApiBaseInterceptor().intercept(req, next)]))" }) + "]"
      } elseif ( -notmatch "withInterceptors") {
        return .Groups[1].Value + .Trim() + ", withInterceptors([(req, next) => new ApiBaseInterceptor().intercept(req, next)])]"
      } else {
        return .Value
      }
    }
  } elseif ( -match "bootstrapApplication\(") {
     =  -replace "bootstrapApplication\(\s*([^\s,]+)\s*\)", "bootstrapApplication(, { providers: [ provideHttpClient(withInterceptors([(req, next) => new ApiBaseInterceptor().intercept(req, next)])) ] })"
  }

   | Set-Content -Encoding UTF8 
}

if (Test-Path ) {
  try { Add-Provider-To-AppModule -file ; Write-Host "Interceptor registrado en AppModule." -ForegroundColor Green } catch { Write-Warning "No se pudo editar app.module.ts automáticamente. Revisa providers e imports." }
} elseif (Test-Path ) {
  try { Add-Interceptor-Standalone -file ; Write-Host "Interceptor registrado en main.ts (standalone)." -ForegroundColor Green } catch { Write-Warning "No se pudo editar main.ts automáticamente. Registra provideHttpClient(withInterceptors(...))." }
} else {
  Write-Warning "No se encontró ni app.module.ts ni main.ts para registrar el interceptor."
}

# -------------------------
# (Opcional) npm install locales para verificar que todo compila
# -------------------------
Write-Host "==> Instalando dependencias mínimas..." -ForegroundColor Cyan
try {
  pushd .\backend
  if (Test-Path package.json) { npm install | Out-Null } else { Write-Warning "backend/package.json no existe; omito npm install en backend." }
  popd

  pushd .\frontend
  if (Test-Path package.json) {
    npm install express --save | Out-Null
    npm install | Out-Null
  } else { Write-Warning "frontend/package.json no existe; omito npm install en frontend." }
  popd
} catch {
  Write-Warning "npm install tuvo advertencias/errores. Puedes correrlo manualmente después."
}

Write-Host "
✅ Listo. Revisa:" -ForegroundColor Cyan
Write-Host "1) BACKEND local: cd backend; npm run start (o build + start:prod). Endpoint de salud: http://localhost:3000/health"
Write-Host "2) FRONTEND local: cd frontend; npm run build; npm start (sirve dist en http://localhost:8080)"
Write-Host "
Para Railway configura por servicio:" -ForegroundColor Yellow
Write-Host "- Backend -> Root Directory: backend | Start Command: npm run start:prod | NODE_ENV=production"
Write-Host "- Frontend -> Root Directory: frontend | Start Command: npm start       | NODE_ENV=production"
Write-Host "
En producción valida:" -ForegroundColor Yellow
Write-Host "- https://kit-monitor-production.up.railway.app/health  (debe responder JSON)"
Write-Host "- https://mindful-presence-production-1bd7.up.railway.app/  (debe cargar la SPA)"
