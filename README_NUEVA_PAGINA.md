# Guía: Cómo agregar una nueva página al servidor

Tu servidor está orquestado con **Docker** y **Nginx Proxy Manager**. Gracias a esta estructura, agregar una nueva aplicación web o página es muy fácil.

Sigue estos pasos para agregar cualquier proyecto nuevo:

## Paso 1: Agregar el contenedor al `docker-compose.yml`

Abre tu archivo principal `docker-compose.yml` (en la raíz de `servidorMP`). Ve al final del archivo, antes de las secciones de `networks:` y `volumes:`, y agrega el bloque de tu nueva aplicación.

Por ejemplo, si vas a agregar un nuevo proyecto en HTML o un nuevo Laravel, debes crearle un servicio. Si es solo un sitio estático (HTML/CSS):
```yaml
  mi_nueva_pagina:
    image: nginx:alpine
    container_name: vps_mi_nueva_pagina
    restart: unless-stopped
    volumes:
      - ./proyectos/MiNuevaPagina:/usr/share/nginx/html:ro
    networks:
      - proxy
    expose:
      - "80"
```
*(Nota: Es vital que tenga la network `proxy` y exponga el puerto `80` para que Nginx Proxy Manager lo pueda ver).*

## Paso 2: Levantar el nuevo contenedor

Abre tu terminal en la carpeta `servidorMP` y ejecuta:
```bash
docker compose up -d
```
Esto encenderá tu nueva página sin apagar el resto de las aplicaciones (n8n, FreezerGuard, etc.).

## Paso 3: Configurar Nginx Proxy Manager

Tu nueva página ya está corriendo internamente, pero el mundo exterior no la ve. Tienes que decirle a Nginx Proxy Manager cómo llegar a ella.

1. Entra a la interfaz de Nginx Proxy Manager (por el puerto 81).
2. Ve a **Hosts > Proxy Hosts**.
3. Si vas a usar un **nuevo dominio/subdominio** (ej: `minuevapagina.ts.net`), créale un Proxy Host apuntando a:
   - **Forward Hostname / IP:** `vps_mi_nueva_pagina` (El nombre de tu contenedor)
   - **Forward Port:** `80`
4. Si lo vas a poner en una **subcarpeta** del dominio principal (ej: `servidor.tailbe2913.ts.net/mipagina/`):
   - Edita el Proxy Host de `servidor.tailbe2913.ts.net`.
   - Ve a la pestaña **Custom locations** y agrega `/mipagina/`.
   - Forward Hostname: `vps_mi_nueva_pagina` y Puerto: `80`.
   - **IMPORTANTE:** Recuerda siempre ir a la "tuerca" (Opciones Avanzadas) de esa location y agregar `proxy_set_header X-Forwarded-Prefix /mipagina;` si el proyecto (como Laravel) necesita saber en qué carpeta está instalado.

¡Y listo! Con esos 3 pasos, puedes alojar infinitas páginas en el servidor.

## Paso 4: Automatizar el Deploy (GitHub Webhooks)

Si quieres que tu nueva página o proyecto se actualice automáticamente cada vez que haces un push a GitHub, sigue estos 3 pasos:

1. **Registrar el repositorio en el servicio de deploy:**
   Abre el archivo `deploy-service/server.js`. Busca la línea que dice `const projects = {` y agrega tu nuevo repositorio mapeado a un nombre de proyecto.
   Ejemplo:
   ```javascript
   const projects = {
       'MatiasParente/FreezerGuard': 'FreezerGuard',
       'MatiasParente/MiNuevaPaginaRepo': 'MiNuevaPagina' // <--- Agrega esto
   };
   ```

2. **Crear el script de deploy:**
   Crea un archivo llamado `MiNuevaPagina.ps1` y otro `MiNuevaPagina.sh` dentro de la carpeta `scripts/deploy/`. Ahí debes escribir los comandos que actualizan tu código. Ejemplo básico:
   ```bash
   cd "D:\Contenedores Dockern\servidorMP\proyectos\MiNuevaPagina" # o la ruta en Linux
   git pull origin main
   ```

3. **Registrar el script en el switch:**
   Abre el archivo `scripts/deploy.ps1` (y su versión `.sh`) y agrega un nuevo caso al `switch` para que reconozca tu proyecto y llame a tu script:
   ```powershell
       "MiNuevaPagina" {
           & "$DeployPath\MiNuevaPagina.ps1"
       }
   ```

**Cómo probarlo:** Ve a GitHub > Configuración de tu repositorio > Webhooks. Crea uno apuntando a `https://smee.io/Vxu7SLbrAl7xvld` (application/json) y pon tu contraseña secreta del `.env`. Haz un push y verás en tu servidor cómo `deploy-runner` recibe la orden y la ejecuta al instante.