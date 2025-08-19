# ===== Stage 1: Build Angular =====
FROM node:18-alpine AS build
WORKDIR /app

# Instalar deps SOLO del frontend
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm ci

# Copiar código del frontend y construir
COPY frontend ./frontend
RUN cd frontend && npx ng build --configuration production

# ===== Stage 2: Run Nginx =====
FROM nginx:alpine

# Config SPA Angular
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar artefacto generado (dist/frontend)
COPY --from=build /app/frontend/dist/frontend /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
