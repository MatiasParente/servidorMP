#!/bin/bash

# Este script es el equivalente a deploy-runner.ps1 para Linux (Oracle Cloud).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$DIR")"
QUEUE_PATH="$PROJECT_ROOT/deploy-queue"
DEPLOY_SCRIPT="$DIR/deploy.sh"

echo -e "\e[36mDeploy Runner iniciado.\e[0m"
echo -e "\e[90mEsperando ordenes en: $QUEUE_PATH\e[0m"

while true; do
    for file in "$QUEUE_PATH"/*.json; do
        if [ -f "$file" ]; then
            # Parseamos el JSON de forma sencilla
            PROJECT=$(grep '"project"' "$file" | awk -F '"' '{print $4}')
            ID=$(grep '"id"' "$file" | awk -F '"' '{print $4}')
            CREATED_AT=$(grep '"created_at"' "$file" | awk -F '"' '{print $4}')

            echo -e "\e[33m========================================\e[0m"
            echo -e "\e[33mOrden recibida\e[0m"
            echo -e "\e[90mID:       $ID\e[0m"
            echo -e "\e[90mProyecto: $PROJECT\e[0m"
            echo -e "\e[90mFecha:    $CREATED_AT\e[0m"
            echo -e "\e[33m========================================\e[0m"

            bash "$DEPLOY_SCRIPT" "$PROJECT"

            if [ $? -eq 0 ]; then
                echo -e "\e[32mDeploy completado correctamente.\e[0m"
                rm -f "$file"
            else
                echo -e "\e[31mEl deploy fallo.\e[0m"
            fi
        fi
    done

    sleep 2
done
