# -------- Build (Node 22.12) --------
FROM node:22.12.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
ENV NODE_OPTIONS=--max_old_space_size=2048
RUN npm run build -- --configuration=production

# -------- Runtime: Node static server --------
FROM node:22.12.0-alpine
WORKDIR /app
COPY --from=build /app/dist /app/dist

# servidor estático sin dependencias
RUN printf '%s\n' \
'import { createServer } from "http";' \
'import fs from "fs";' \
'import { readFile, stat } from "fs/promises";' \
'import path from "path";' \
'import { fileURLToPath } from "url";' \
'const __dirname = path.dirname(fileURLToPath(import.meta.url));' \
'const candidates = ["dist/frontend/browser","dist/frontend","dist"];' \
'let base=""; for (const d of candidates){ const p=path.join(__dirname,d); if (fs.existsSync(p)){ base=p; break; } }' \
'if (!base){ console.error("ERROR: no dist folder"); process.exit(1); }' \
'const port = parseInt(process.env.PORT||"8080",10);' \
'const server = createServer(async (req,res)=>{ try {' \
'  let reqPath = decodeURIComponent((req.url||"/").split("?")[0]);' \
'  if (reqPath === "/" || reqPath === "") reqPath = "/index.html";' \
'  let filePath = path.join(base, reqPath);' \
'  if (!filePath.startsWith(base)){ res.statusCode=403; return res.end("Forbidden"); }' \
'  try { await stat(filePath); } catch { filePath = path.join(base, "index.html"); }' \
'  const ext = path.extname(filePath).toLowerCase();' \
'  const types={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".ico":"image/x-icon",".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".svg":"image/svg+xml",".webp":"image/webp"};' \
'  res.setHeader("Content-Type", types[ext]||"application/octet-stream");' \
'  res.end(await readFile(filePath));' \
'} catch(e){ res.statusCode=500; res.end(String(e)); }});' \
'server.listen(port,"0.0.0.0",()=>console.log(`Static server on http://0.0.0.0:${port} (base=${base})`));' \
> server.mjs

EXPOSE 8080
CMD ["node","server.mjs"]
