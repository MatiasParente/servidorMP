# Iniciar

docker compose up -d

# Iniciar con rebuild

docker compose up -d --build

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

# Reiniciar con composer un contenedor en especifico

docker compose restart homepage

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

# Crear imagen para los conetendores de freezerguard
docker build -t freezerguard:local -f docker/freezerguard/Dockerfile ./proyectos

# ⚠️ IMPORTANTE: Al recrear FreezerGuard, SIEMPRE reiniciar también freezerguard-nginx
docker compose up -d --force-recreate freezerguard freezerguard-nginx

# ============================================================
# SETUP INICIAL DEL SERVIDOR (solo una vez)
# ============================================================

# Instalar el servicio deploy-runner (sin esto, los push de GitHub no se despliegan)
sudo cp ~/servidorMP/infraestructura/deploy-runner.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable deploy-runner
sudo systemctl start deploy-runner

# ============================================================
# TROUBLESHOOTING
# ============================================================

# Si FreezerGuard da 502 después de recrear contenedores:
docker restart vps_freezerguard_nginx

# Si el deploy no funciona (los push no se aplican):
sudo systemctl status deploy-runner
# Si está muerto:
sudo systemctl restart deploy-runner

# Ver órdenes de deploy pendientes:
ls -la ~/servidorMP/deploy-queue/

# Ver logs del deploy runner:
sudo journalctl -u deploy-runner --tail=50
