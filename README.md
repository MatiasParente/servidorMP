# ServidorMP

Infraestructura personal basada en Docker para alojar servicios web, automatizaciones e IoT.

## Objetivo

Este proyecto implementa un servidor modular utilizando contenedores Docker,
permitiendo desplegar aplicaciones, bases de datos, automatizaciones y servicios
de comunicación.

## Tecnologías principales

- Docker Compose
- Nginx Proxy Manager
- MariaDB
- n8n
- Node-RED
- MQTT Mosquitto
- phpMyAdmin
- Tailscale

## Arquitectura

El sistema está dividido en dos redes:

- **proxy**: Servicios accesibles mediante HTTPS.
- **internal**: Comunicación interna entre servicios.

## Servicios

| Servicio | Función |
|---|---|
| Nginx Proxy Manager | Reverse proxy y certificados SSL |
| n8n | Automatizaciones |
| Node-RED | Flujos IoT |
| Mosquitto | Broker MQTT |
| MariaDB | Base de datos |
| phpMyAdmin | Administración BD |

## Acceso

El servidor utiliza **Tailscale** para acceso privado seguro desde cualquier dispositivo.

## Despliegue rápido

1. **Configurar .env**

   ```bash
   cp .env.example .env
   # Editar variables
   ```

2. **Levantar servicios**

   ```bash
   docker compose up -d
   ```

3. **Configurar Tailscale**

   ```bash
   docker exec -it vps_tailscale tailscale up
   ```

4. **Configurar Nginx Proxy Manager**

   Acceder a `http://TAILNET_DOMAIN:81` y configurar:
   - Domain: `TAILNET_DOMAIN`
   - Forward Host: `homepage`
   - Forward Port: `80`

## Backup

Ejecutar script:

```powershell
.\scripts\backup.ps1
```

## Estructura

- `docker-compose.yml`: Configuración principal
- `infraestructura/`: Infraestructura base
- `herramientas/`: Aplicaciones desplegadas
- `pagina/`: Página de inicio
- `scripts/`: Scripts de administración
- `backups/`: Backups full

---

## 2. Instalación y Configuración del Servidor

### 2.1. Requisitos Previos

Antes de comenzar con el despliegue en el servidor (en un entorno Linux), es necesario contar con las siguientes herramientas instaladas:

- **Git**: Para clonar los repositorios del servidor y de los proyectos.
- **Docker y Docker Compose**: Motor de contenedores para la infraestructura.
- **Tailscale**: Altamente recomendado (y necesario si se desea acceder a la red interna para modificar configuraciones de Node-RED o la base de datos de forma segura).

---

### 2.2. Descarga de Repositorios y Respaldos

**1. Descargar el servidor:**

Cloná el repositorio principal del servidor en el equipo de destino:

```bash
git clone https://github.com/MatiasParente/servidorMP
cd servidorMP
```

**2. Descargar FreezerGuard:**

Cloná el repositorio de FreezerGuard y ubicalo directamente dentro de la carpeta `proyectos/` del servidor:

```bash
git clone https://github.com/MatiasParente/FreezerGuard proyectos/FreezerGuard
```

**3. Restaurar datos anteriores *(Opcional)*:**

Si necesitás migrar datos de un servidor anterior, descargá el archivo de respaldo (`backup`) correspondiente y colocalo en la carpeta `backups/` para su posterior ejecución.

---

### 2.3. Configuración de Variables de Entorno (`.env`)

Creá el archivo `.env` a partir de la plantilla de ejemplo:

```bash
cp .env.example .env
```

Luego editá el archivo `.env` configurando los parámetros según tu entorno:

| Sección | Variable | Descripción |
|---|---|---|
| **General** | `TZ` | Zona horaria (ej: `America/Argentina/Buenos_Aires`) |
| | `TAILNET_DOMAIN` | Dominio de Tailscale |
| | `APP_ENV` | Entorno (`production` / `development`) |
| | `SERVER_NAME` | Nombre identificatorio del servidor |
| **MariaDB** | `MYSQL_ROOT_PASSWORD` | Contraseña del usuario root |
| | `MYSQL_DATABASE` | Nombre de la base de datos |
| | `MYSQL_USER` | Usuario de la base de datos |
| | `MYSQL_PASSWORD` | Contraseña del usuario |
| **n8n** | `N8N_ENCRYPTION_KEY` | Clave de encriptación de credenciales |
| | `WEBHOOK_SECRET` | Secreto para webhooks |
| **Docker** | `COMPOSE_PROJECT_NAME` | Nombre del proyecto en Docker Compose |
| **MQTT** | `MQTT_USER` | Usuario del broker MQTT |
| | `MQTT_PASSWORD` | Contraseña del broker MQTT |

---

### 2.4. Despliegue de Contenedores

**1. Construir la imagen de FreezerGuard:**

Desde la **raíz del repositorio** (`servidorMP/`), generá la imagen Docker específica para FreezerGuard:

```bash
docker build -t freezerguard:local -f docker/freezerguard/Dockerfile ./proyectos
```

**2. Levantar los servicios:**

Iniciá toda la infraestructura en segundo plano:

```bash
docker compose up -d
```

---

### 2.5. Configuración de Red y Acceso

**1. Configurar Tailscale:**

Conectá el nodo del servidor a tu red privada ejecutando:

```bash
docker exec -it vps_tailscale tailscale up
```

Esto te permitirá gestionar de forma segura servicios internos como Node-RED o bases de datos.

**2. Configurar Nginx Proxy Manager:**

Accedé al panel de administración en:

```
http://TAILNET_DOMAIN:81
```

Configurá el proxy reverso apuntando al servicio principal para habilitar el acceso mediante HTTPS:

- **Domain**: `TAILNET_DOMAIN`
- **Forward Host**: `homepage`
- **Forward Port**: `80`

## Si todo funciona correctamente intenta acceder a la aplicacion web a travez del link:

### [https://tip-proymf26.tipyenaccion.net/](https://tip-proymf26.tipyenaccion.net/)