# -------- Build (Node 22.12) --------
FROM node:22.12.0-alpine AS build
WORKDIR /app

# Instala deps (incluye devDeps)
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# Copia el resto
COPY . .

# Memoria extra para Angular
ENV NODE_OPTIONS=--max_old_space_size=2048

# Info útil + build con captura de log
RUN node -v && npm -v && npx ng version && ls -la && test -f angular.json && cat angular.json | head -n 30
RUN (npm run build -- --configuration=production --verbose 2>&1 | tee /tmp/build.log) \
 || (echo "---- BUILD FAILED (últimas 200 líneas) ----" && tail -n 200 /tmp/build.log && exit 1)

# -------- Serve estático --------
FROM node:22.12.0-alpine
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist /app/dist
ENV PORT=8080
EXPOSE 8080
CMD ["serve","-s","dist/frontend/browser","-l","$PORT"]