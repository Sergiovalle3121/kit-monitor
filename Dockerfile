# -------- Build stage --------
FROM node:20-alpine AS build
WORKDIR /app

# Instala deps del frontend
COPY frontend/package*.json ./frontend/
RUN npm ci --prefix frontend

# Copia código y construye Angular
COPY frontend ./frontend
RUN npm run --prefix frontend build

# -------- Runtime stage --------
FROM node:20-alpine AS runner
WORKDIR /app

# Copia el server y el dist
COPY frontend/server.js ./server.js
COPY --from=build /app/frontend/dist/frontend ./dist/frontend

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "server.js"]
