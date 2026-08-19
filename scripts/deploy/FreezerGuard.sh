#!/bin/bash

# Obtenemos el directorio raiz basado en donde esta este script (scripts/deploy)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$(dirname "$(dirname "$DIR")")/proyectos/FreezerGuard"

echo -e "\e[36mIniciando despliegue de FreezerGuard...\e[0m"

cd "$PROJECT_PATH" || { echo -e "\e[31mERROR: No se encontro la ruta $PROJECT_PATH\e[0m"; exit 1; }

echo -e "\e[33mDescargando ultimos cambios de Git...\e[0m"
git pull origin main

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: git pull fallo.\e[0m"
    exit 1
fi

echo -e "\e[33mInstalando dependencias de PHP...\e[0m"
docker exec vps_freezerguard composer install --no-interaction --prefer-dist --optimize-autoloader

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: composer install fallo.\e[0m"
    exit 1
fi

echo -e "\e[33mEjecutando migraciones...\e[0m"
docker exec vps_freezerguard php artisan migrate --force

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: las migraciones fallaron.\e[0m"
    exit 1
fi

echo -e "\e[33mInstalando dependencias de Node...\e[0m"
docker exec vps_freezerguard npm install

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: npm install fallo.\e[0m"
    exit 1
fi

echo -e "\e[33mCompilando Vite...\e[0m"
docker exec vps_freezerguard npm run build

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: npm run build fallo.\e[0m"
    exit 1
fi

echo -e "\e[33mLimpiando caches de Laravel...\e[0m"
docker exec vps_freezerguard php artisan optimize:clear

if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: optimize:clear fallo.\e[0m"
    exit 1
fi

echo -e "\e[32m!FreezerGuard desplegado correctamente!\e[0m"
