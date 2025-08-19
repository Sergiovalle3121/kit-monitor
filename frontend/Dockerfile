# Imagen base ligera de Node
FROM node:20-alpine

# Definir directorio de trabajo
WORKDIR /app

# Copiar dependencias
COPY package*.json ./

# Instalar dependencias (ignora conflictos de peer deps)
RUN npm install --legacy-peer-deps --no-audit --fund=false

# Copiar todo el código del frontend
COPY . .

# Construir la aplicación Angular
RUN npm run build

# Exponer el puerto de Angular (normalmente 4200 o 80, depende de cómo sirvas)
EXPOSE 4200

# Comando de inicio
CMD ["npm", "start"]
