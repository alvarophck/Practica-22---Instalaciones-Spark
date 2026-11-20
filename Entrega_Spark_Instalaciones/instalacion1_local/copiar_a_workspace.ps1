# Ejecutar desde la carpeta instalacion1_local (donde esta este fichero)
$o = $PSScriptRoot
Copy-Item "$o\activar_entorno.ps1" "C:\SparkLocal\workspace\" -Force
Copy-Item "$o\.vscode\settings.json" "C:\SparkLocal\workspace\.vscode\" -Force
Copy-Item "$o\notebooks\*.ipynb" "C:\SparkLocal\workspace\notebooks\" -Force
Write-Host "Ficheros copiados a C:\SparkLocal\workspace" -ForegroundColor Green
