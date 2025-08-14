# -------- Build (Node 22.12) --------
FROM node:22.12.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
ENV NODE_OPTIONS=--max_old_space_size=2048
RUN npm run build -- --configuration=production

# -------- Serve estático --------
FROM node:22.12.0-alpine
WORKDIR /app
RUN npm i -g serve
COPY --from=build /app/dist /app/dist
# No fijamos PORT aquí; Railway lo inyecta
EXPOSE 8080
CMD ["sh","-lc","p=${PORT:-8080}; \
for d in dist/frontend/browser dist/frontend dist; do \
  if [ -d \"$d\" ]; then echo \"Serving $d on tcp://0.0.0.0:$p\"; \
  exec serve -s \"$d\" --listen tcp://0.0.0.0:$p; fi; \
done; echo 'ERROR: no dist folder'; find dist -maxdepth 2 -type d -print; exit 1"]