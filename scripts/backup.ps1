$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"


$backupPath = ".\backup\full"

if (!(Test-Path $backupPath)) {
    New-Item -ItemType Directory -Force $backupPath
}


$archivo = "$backupPath\servidor_$fecha.zip"


Compress-Archive `
-Path `
docker-compose.yml,
.env,
pagina,
infraestructura/nginx,
infraestructura/mariadb,
infraestructura/mosquitto/config,
infraestructura/mosquitto/data,
herramientas `
-DestinationPath $archivo



# eliminar backups mayores a 30 días

Get-ChildItem $backupPath |
Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-30)
} |
Remove-Item -Force