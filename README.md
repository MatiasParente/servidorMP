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

- proxy:
  Servicios accesibles mediante HTTPS.

- internal:
  Comunicación interna entre servicios.

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

## Despliegue

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

   Acceder a `https://TAILNET_DOMAIN` y configurar:
   - Domain: `TAILNET_DOMAIN`
   - Forward Host: `homepage:80`

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