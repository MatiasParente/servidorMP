param (
    [string]$ProjectPath = "D:\Contenedores Dockern\servidorMP\proyectos\FreezerGuard"
)

Write-Host "Iniciando despliegue de FreezerGuard..." -ForegroundColor Cyan

Set-Location -Path $ProjectPath

Write-Host "Descargando últimos cambios de Git..." -ForegroundColor Yellow
git pull origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: git pull falló." -ForegroundColor Red
    exit 1
}

Write-Host "Instalando dependencias de PHP..." -ForegroundColor Yellow
docker exec vps_freezerguard composer install --no-interaction --prefer-dist --optimize-autoloader

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: composer install falló." -ForegroundColor Red
    exit 1
}

Write-Host "Ejecutando migraciones..." -ForegroundColor Yellow
docker exec vps_freezerguard php artisan migrate --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: las migraciones fallaron." -ForegroundColor Red
    exit 1
}

Write-Host "Instalando dependencias de Node..." -ForegroundColor Yellow
docker exec vps_freezerguard npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: npm install falló." -ForegroundColor Red
    exit 1
}

Write-Host "Compilando Vite..." -ForegroundColor Yellow
docker exec vps_freezerguard npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: npm run build falló." -ForegroundColor Red
    exit 1
}

Write-Host "Limpiando cachés de Laravel..." -ForegroundColor Yellow
docker exec vps_freezerguard php artisan optimize:clear

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: optimize:clear falló." -ForegroundColor Red
    exit 1
}

Write-Host "¡FreezerGuard desplegado correctamente!" -ForegroundColor Green