$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"

$backupPath = ".\backup\full"

if (!(Test-Path $backupPath)) {
    New-Item -ItemType Directory -Force $backupPath
}

$archivo = "$backupPath\servidor_$fecha.zip"


Write-Host "Deteniendo contenedores..."

docker compose stop


$tempPath = ".\backup\temp_staging"
if (Test-Path $tempPath) { Remove-Item -Recurse -Force $tempPath }
New-Item -ItemType Directory -Force $tempPath | Out-Null

Write-Host "Copiando archivos temporalmente (excluyendo node_modules y vendor)..."
Copy-Item ".env" -Destination $tempPath
New-Item -ItemType Directory -Force "$tempPath\infraestructura" | Out-Null
Copy-Item "infraestructura\deploy-runner.service" -Destination "$tempPath\infraestructura\" -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force "$tempPath\proyectos\FreezerGuard" | Out-Null
Copy-Item "proyectos\FreezerGuard\.env" -Destination "$tempPath\proyectos\FreezerGuard\" -ErrorAction SilentlyContinue

$carpetas = @("pagina", "infraestructura\nginx", "infraestructura\mariadb", "infraestructura\mosquitto", "herramientas", "scripts", "docs", "proyectos", "deploy-service", "deploy-queue")
foreach ($carpeta in $carpetas) {
    if (Test-Path ".\$carpeta") {
        robocopy ".\$carpeta" "$tempPath\$carpeta" /E /XD node_modules vendor FreezerGuard /R:0 /W:0 /NJH /NJS /NDL /NC /NS | Out-Null
    }
}

Write-Host "Comprimiendo archivo ZIP..."
Compress-Archive -Path "$tempPath\*" -DestinationPath $archivo -Force

Write-Host "Limpiando archivos temporales..."
Remove-Item -Recurse -Force $tempPath


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