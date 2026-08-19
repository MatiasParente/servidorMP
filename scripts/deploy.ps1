param (
    [Parameter(Mandatory = $true)]
    [string]$ProjectName
)

$DeployPath = "D:\Contenedores Dockern\servidorMP\scripts\deploy"

switch ($ProjectName) {

    "FreezerGuard" {
        & "$DeployPath\FreezerGuard.ps1"
    }

    "OtraPagina" {
        & "$DeployPath\OtraPagina.ps1"
    }

    default {
        Write-Host "ERROR: No existe un deployment configurado para '$ProjectName'." -ForegroundColor Red
        exit 1
    }
}