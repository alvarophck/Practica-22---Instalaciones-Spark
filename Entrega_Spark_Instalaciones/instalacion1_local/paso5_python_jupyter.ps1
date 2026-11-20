$ErrorActionPreference = "Stop"
Set-Location C:\SparkLocal\workspace
. .\activar_entorno.ps1

if (-not (Test-Path ".\.venv\Scripts\python.exe")) {
    # py -3.12 garantiza la version correcta aunque haya otras instaladas
    py -3.12 -m venv .venv
}
. .\activar_entorno.ps1
python --version            # debe decir Python 3.12.x

python -m pip install --upgrade pip
pip install pyspark==4.1.4 jupyterlab ipykernel
python -m ipykernel install --sys-prefix --name pyspark-414 --display-name "PySpark 4.1.4 (Python 3.12)"

# Inyectar variables en el kernel de PySpark
$pyKernelPath = "C:\SparkLocal\workspace\.venv\share\jupyter\kernels\pyspark-414\kernel.json"
$pyKernel = Get-Content $pyKernelPath -Raw | ConvertFrom-Json
$pyEnv = [ordered]@{
    JAVA_HOME             = "C:\SparkLocal\jdk-17"
    SPARK_HOME            = "C:\SparkLocal\spark"
    HADOOP_HOME           = "C:\SparkLocal\hadoop"
    SPARK_LOCAL_DIRS      = "C:\SparkLocal\tmp"
    PYSPARK_PYTHON        = "C:\SparkLocal\workspace\.venv\Scripts\python.exe"
    PYSPARK_DRIVER_PYTHON = "C:\SparkLocal\workspace\.venv\Scripts\python.exe"
}
$pyKernel | Add-Member -MemberType NoteProperty -Name "env" -Value $pyEnv -Force
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($pyKernelPath, ($pyKernel | ConvertTo-Json -Depth 5), $utf8NoBom)
Write-Host "Kernel PySpark 4.1.4 listo." -ForegroundColor Green
