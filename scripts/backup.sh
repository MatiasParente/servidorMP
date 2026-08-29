#!/bin/bash

# Este script es el equivalente a backup.ps1 para Linux (Oracle Cloud).
# Para ejecutarlo manual: ./scripts/backup.sh

FECHA=$(date +"%Y-%m-%d_%H-%M")
BACKUP_PATH="./backup/full"

mkdir -p "$BACKUP_PATH"

ARCHIVO="$BACKUP_PATH/servidor_$FECHA.tar.gz"

echo "Deteniendo contenedores..."
docker compose stop

TEMP_PATH="./backup/temp_staging"
rm -rf "$TEMP_PATH"
mkdir -p "$TEMP_PATH"

echo "Copiando archivos temporalmente (excluyendo node_modules y vendor)..."
cp .env "$TEMP_PATH/" 2>/dev/null
mkdir -p "$TEMP_PATH/proyectos/FreezerGuard"
cp proyectos/FreezerGuard/.env "$TEMP_PATH/proyectos/FreezerGuard/" 2>/dev/null

CARPETAS=("pagina" "infraestructura/nginx" "infraestructura/mariadb" "infraestructura/mosquitto" "herramientas" "scripts" "docs" "proyectos" "deploy-service" "deploy-queue")

for CARPETA in "${CARPETAS[@]}"; do
    if [ -d "./$CARPETA" ]; then
        mkdir -p "$TEMP_PATH/$CARPETA"
        # Usamos rsync para copiar excluyendo carpetas pesadas y FreezerGuard
        rsync -a --exclude 'node_modules' --exclude 'vendor' --exclude 'FreezerGuard' "./$CARPETA/" "$TEMP_PATH/$CARPETA/"
    fi
done

echo "Comprimiendo archivo TAR.GZ..."
tar -czf "$ARCHIVO" -C "$TEMP_PATH" .

echo "Limpiando archivos temporales..."
rm -rf "$TEMP_PATH"

echo "Backup creado:"
echo "$ARCHIVO"

echo "Iniciando contenedores..."
docker compose start

echo "Eliminando backups mayores a 30 dias..."
find "$BACKUP_PATH" -type f -name "*.tar.gz" -mtime +30 -exec rm -f {} \;

echo "Proceso terminado correctamente"
