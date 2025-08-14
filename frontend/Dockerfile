# --------- Build (Node 22.12) ----------
FROM node:22.12.0-alpine AS build
WORKDIR /app

# 1) Instalar dependencias (incluye devDeps)
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# 2) Copiar el resto del código
COPY . .

# 3) Build con diagnóstico/verbose
RUN node -v && npm -v && npx ng version
RUN npm run build -- --configuration=production --verbose

# --------- Servir estático ----------
FROM node:22.12.0-alpine
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist /app/dist
ENV PORT=8080
EXPOSE 8080
CMD ["serve","-s","dist/frontend/browser","-l","$PORT"]
