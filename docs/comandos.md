# Iniciar

docker compose up -d


# Detener

docker compose down

# Encender

docker compose start

# Apagar

docker compose stop

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

# Ejecutar Deploy Manual
.\scripts\deploy.ps1

# Ejecutar el "Runner" de Deploy (Para actualización automática 24/7)
## En Windows:
.\scripts\deploy-runner.ps1

## En Linux (Oracle Cloud):
sudo systemctl enable deploy-runner.service
sudo systemctl start deploy-runner.service
sudo systemctl status deploy-runner.service