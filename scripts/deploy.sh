#!/bin/bash

# Script de Linux equivalente a deploy.ps1

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo -e "\e[31mERROR: ProjectName requerido.\e[0m"
    exit 1
fi

# Obtenemos la ruta absoluta de la carpeta 'deploy' basándonos en dónde está este script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_PATH="$DIR/deploy"

case "$PROJECT_NAME" in
    "FreezerGuard")
        bash "$DEPLOY_PATH/FreezerGuard.sh"
        ;;
    "OtraPagina")
        bash "$DEPLOY_PATH/OtraPagina.sh"
        ;;
    *)
        echo -e "\e[31mERROR: No existe un deployment configurado para '$PROJECT_NAME'.\e[0m"
        exit 1
        ;;
esac
