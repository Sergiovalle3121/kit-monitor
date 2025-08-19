# Etapa 1: Build de Angular
FROM node:18 AS build
WORKDIR /app

COPY frontend/package*.json ./frontend/
WORKDIR /app/frontend
RUN npm install --legacy-peer-deps --no-audit --fund=false

COPY frontend/ ./ 
RUN npm run build -- --configuration production

# Etapa 2: Nginx para servir estáticos
FROM nginx:alpine
COPY --from=build /app/frontend/dist/frontend /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
COPY nginx.conf /etc/nginx/conf.d/default.conf
