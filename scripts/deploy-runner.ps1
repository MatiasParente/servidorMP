$ProjectRoot = Split-Path $PSScriptRoot -Parent
$QueuePath = Join-Path $ProjectRoot "deploy-queue"
$DeployScript = Join-Path $PSScriptRoot "deploy.ps1"

Write-Host "Deploy Runner iniciado." -ForegroundColor Cyan
Write-Host "Esperando órdenes en: $QueuePath" -ForegroundColor Gray

while ($true) {

    $files = Get-ChildItem -Path $QueuePath -Filter "*.json" -File

    foreach ($file in $files) {

        try {

            $request = Get-Content $file.FullName -Raw | ConvertFrom-Json

            Write-Host ""
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host "Orden recibida" -ForegroundColor Yellow
            Write-Host "ID:       $($request.id)" -ForegroundColor Gray
            Write-Host "Proyecto: $($request.project)" -ForegroundColor Gray
            Write-Host "Fecha:    $($request.created_at)" -ForegroundColor Gray
            Write-Host "========================================" -ForegroundColor Yellow

            & $DeployScript -ProjectName $request.project

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Deploy completado correctamente." -ForegroundColor Green
                Remove-Item $file.FullName -Force
            }
            else {
                Write-Host "El deploy falló." -ForegroundColor Red
            }

        }
        catch {

            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Start-Sleep -Seconds 2
}