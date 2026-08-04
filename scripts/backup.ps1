$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"

$backupPath = ".\backup\full"

if (!(Test-Path $backupPath)) {
    New-Item -ItemType Directory -Force $backupPath
}

$archivo = "$backupPath\servidor_$fecha.zip"


Write-Host "Deteniendo contenedores..."

docker compose stop


Write-Host "Creando backup..."

Compress-Archive `
-Path `
docker-compose.yml,
.env,
pagina,
infraestructura/nginx,
infraestructura/mariadb,
infraestructura/mosquitto,
herramientas,
scripts `
-DestinationPath $archivo `
-Force


Write-Host "Backup creado:"
Write-Host $archivo


Write-Host "Iniciando contenedores..."

docker compose start


Write-Host "Eliminando backups mayores a 30 dias..."

Get-ChildItem $backupPath |
Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-30)
} |
Remove-Item -Force


Write-Host "Proceso terminado correctamente"