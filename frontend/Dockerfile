# --- build ---
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

# --- run (serve SPA) ---
FROM node:20-alpine
WORKDIR /app
RUN npm i -g http-server
# copia solo el build
COPY --from=build /app/dist/frontend ./dist/frontend

# Railway te pasa $PORT; usa 8080 por defecto local
ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "http-server dist/frontend -p ${PORT:-8080}"]
