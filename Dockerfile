# ===== Stage 1: Build =====
FROM node:18-alpine AS build
WORKDIR /app

# Copia solo lo mínimo para cachear deps
COPY package*.json ./
RUN npm ci

# Copia el resto del código y construye
COPY . .
# Si usas un subfolder "frontend", ajusta el WORKDIR o el comando:
# WORKDIR /app
# RUN npx ng build --configuration production
RUN npx ng build --configuration production

# ===== Stage 2: Nginx =====
FROM nginx:alpine

# Config Nginx para Angular (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia el artefacto de Angular al root de Nginx
# OJO: usa el nombre exacto de la carpeta que salió en tu build: dist/frontend
COPY --from=build /app/dist/frontend /usr/share/nginx/html

# (Opcional) Si usas variables por archivo env.js, cópialo también
# COPY env.js /usr/share/nginx/html/assets/env.js

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
