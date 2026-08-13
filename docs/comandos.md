# Iniciar

docker compose up -d


# Detener

docker compose down


# Logs

docker logs nombre_contenedor


# Reiniciar

docker restart nombre


# Actualizar imágenes

docker compose pull
docker compose up -d


# Limpiar imágenes viejas

docker image prune

# Crear Backup (de toda la infraestructura y proyectos)

.\scripts\backup.ps1

# Ejecutar Deploy

.\scripts\deploy.ps1