# ---- build ----
FROM node:20 AS build
WORKDIR /app

# copiar solo los manifests del frontend (ya estamos en frontend/)
COPY package*.json ./

# instalar dependencias
RUN npm install --legacy-peer-deps --no-audit --fund=false

# copiar el resto del frontend
COPY . .

# construir angular
RUN npm run build --prod

# ---- run ----
FROM node:20
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist/frontend ./dist/frontend

ENV PORT=8080
EXPOSE 8080
CMD ["serve", "-s", "dist/frontend", "-l", "8080"]
