# ---- build ----
FROM node:20 AS build
WORKDIR /app

# Paquetes para node-gyp (por si alguna lib lo requiere)
RUN apt-get update && apt-get install -y python3 make g++ git && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# usa lock + ignora peer deps + menos ruido
RUN npm ci --legacy-peer-deps --no-audit --fund=false

COPY . .
RUN npm run build

# ---- run (serve SPA) ----
FROM node:20
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist/frontend ./dist/frontend

ENV PORT=8080
EXPOSE 8080
CMD ["serve", "-s", "dist/frontend", "-l", "${PORT}"]
