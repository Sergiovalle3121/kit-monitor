# --------- Build (Node 22.12) ----------
FROM node:22.12.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --------- Serve estático ----------
FROM node:22.12.0-alpine
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist /app/dist
ENV PORT=8080
EXPOSE 8080
# Detecta la carpeta correcta de Angular 20 (browser) o la clásica
CMD ["sh","-c","if [ -d dist/frontend/browser ]; then serve -s dist/frontend/browser -l $PORT; \
else if [ -d dist/frontend ]; then serve -s dist/frontend -l $PORT; else serve -s dist -l $PORT; fi; fi"]
