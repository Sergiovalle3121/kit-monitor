# -------- Build (Node 22.12) --------
FROM node:22.12.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
ENV NODE_OPTIONS=--max_old_space_size=2048
RUN npm run build -- --configuration=production

# -------- Serve estático con http-server --------
FROM node:22.12.0-alpine
WORKDIR /app
RUN npm i -g http-server
COPY --from=build /app/dist /app/dist
EXPOSE 8080
CMD ["sh","-lc","p=${PORT:-8080}; \
for d in dist/frontend/browser dist/frontend dist; do \
  if [ -d \"$d\" ]; then echo \"Serving $d on 0.0.0.0:$p\"; exec http-server \"$d\" -p $p -a 0.0.0.0 --cors -c-1; fi; \
done; echo 'ERROR: no dist folder'; find dist -maxdepth 2 -type d -print; exit 1"]
