# DevOps Final Project

## Descripción del Proyecto

Este proyecto es una aplicación web que consta de un frontend y un backend. El frontend está construido con Vite y React, mientras que el backend está construido con Flask. La aplicación se despliega en Azure App Service utilizando imágenes de Docker almacenadas en Azure Container Registry (ACR).

## Arquitectura del Proyecto

La arquitectura del proyecto se compone de los siguientes componentes:

1. **Frontend**: Una aplicación React construida con Vite.
2. **Backend**: Una API REST construida con Flask.
3. **Azure Container Registry (ACR)**: Almacena las imágenes de Docker para el frontend y el backend.
4. **Azure App Service**: Despliega las aplicaciones frontend y backend utilizando las imágenes de Docker almacenadas en ACR.

### Diagrama de Arquitectura

```plaintext
+-------------------+       +-------------------+
|                   |       |                   |
|   Azure App       |       |   Azure App       |
|   Service         |       |   Service         |
|   (Frontend)      |       |   (Backend)       |
|                   |       |                   |
+---------+---------+       +---------+---------+
          |                           |
          |                           |
          |                           |
+---------v---------+       +---------v---------+
|                   |       |                   |
|   Azure Container |       |   Azure Container |
|   Registry (ACR)  |       |   Registry (ACR)  |
|   (Frontend)      |       |   (Backend)       |
|                   |       |                   |
+-------------------+       +-------------------+
```

## Estructura del Proyecto

```plaintext
/Users/jmisael27/DevOps_Final_Project/
├── avatares-devops/
│   ├── web/
│   │   ├── vite.config.js
│   │   ├── package.json
│   │   ├── package-lock.json (si existe)
│   │   └── ... (otros archivos y carpetas del frontend)
│   ├── api/
│   │   ├── requirements.txt
│   │   ├── app.py
│   │   └── ... (otros archivos y carpetas del backend)
│   └── devops/
│       └── docker/
│           ├── Dockerfile-Frontend
│           ├── Dockerfile-Backend
│           └── ... (otros archivos y carpetas de DevOps)
└── ... (otros archivos y carpetas del proyecto)
```

## Despliegue en Azure

### Prerrequisitos

1. Tener una cuenta de Azure.
2. Tener instalado Azure CLI.
3. Tener instalado Terraform.

### Nota para Usuarios de Mac M1

La construcción de imágenes de Docker en Mac M1 no es compatible directamente. Debes utilizar `docker buildx` para construir las imágenes.

### Pasos para Desplegar

1. **Iniciar sesión en Azure**

   ```sh
   az login
   ```

2. **Construir las Imágenes de Docker**

   Navega a la carpeta `devops/docker` y construye las imágenes del frontend y backend.

   ```sh
   cd /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/docker

   # Construir la imagen del backend
   docker buildx build --platform linux/amd64 -t backend-avatares:latest -f Dockerfile-Backend .

   # Construir la imagen del frontend
   docker buildx build --platform linux/amd64 -t frontend-avatares:latest -f Dockerfile-Frontend .
   ```

3. **Subir las Imágenes a Azure Container Registry (ACR)**

   ```sh
   # Iniciar sesión en ACR
   az acr login --name avatarescr

   # Subir la imagen del backend
   docker tag backend-avatares:latest avatarescr.azurecr.io/backend-avatares:latest
   docker push avatarescr.azurecr.io/backend-avatares:latest

   # Subir la imagen del frontend
   docker tag frontend-avatares:latest avatarescr.azurecr.io/frontend-avatares:latest
   docker push avatarescr.azurecr.io/frontend-avatares:latest
   ```

4. **Desplegar la Infraestructura con Terraform**

   Navega a la carpeta `devops/terraform` y despliega la infraestructura en Azure.

   ```sh
   cd /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/terraform

   # Inicializar Terraform
   terraform init

   # Planificar la Implementación
   terraform plan

   # Aplicar la Implementación
   terraform apply
   ```

## Configuración de Vite

### /Users/jmisael27/DevOps_Final_Project/avatares-devops/web/vite.config.js

```javascript
// filepath: /Users/jmisael27/DevOps_Final_Project/avatares-devops/web/vite.config.js
import { defineConfig } from 'vite'
import reactRefresh from '@vitejs/plugin-react-refresh'

export default defineConfig({
  logLevel: 'info',
  plugins: [reactRefresh()],
  server: {
    host: process.env.VITE_HOST || '0.0.0.0',
    port: process.env.VITE_PORT || 5173,
    hmr: {
      clientPort: process.env.VITE_CLIENT_PORT || null
    },
    proxy: {
      '^/api': {
        target: process.env.VITE_BACKEND_URL || 'http://backend-service:5000',
        changeOrigin: true
      }
    }
  }
})
```

## Dockerfiles

### /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/docker/Dockerfile-Frontend

```dockerfile
// filepath: /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/docker/Dockerfile-Frontend
# Usa una imagen base ligera de Node.js
FROM node:18-alpine

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos necesarios desde la carpeta web
COPY ../../web/package*.json ./

# Instala las dependencias
RUN npm install

# Copia el código fuente al contenedor desde la carpeta web
COPY ../../web .

# Expone el puerto 5173 para el frontend
EXPOSE 5173

# Comando para iniciar el servidor de desarrollo
CMD ["npm", "run", "dev", "--", "--host"]
```

### /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/docker/Dockerfile-Backend

```dockerfile
// filepath: /Users/jmisael27/DevOps_Final_Project/avatares-devops/devops/docker/Dockerfile-Backend
# Usa una imagen base oficial de Python
FROM python:3.10-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos necesarios
COPY ../../api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ../../api .

# Establece las variables de entorno
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Expone el puerto del backend
EXPOSE 5000

# Comando para ejecutar la aplicación
CMD ["flask", "run", "--host=0.0.0.0"]
```

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o un pull request para discutir cualquier cambio que te gustaría realizar.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
