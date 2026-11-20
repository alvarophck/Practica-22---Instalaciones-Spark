# Script de entorno aislado para Apache Spark 4.1.4 (sin modificar Windows)
$env:SPARK_LOCAL_ROOT = "C:\SparkLocal"
$env:JAVA_HOME        = "$env:SPARK_LOCAL_ROOT\jdk-17"
$env:SPARK_HOME       = "$env:SPARK_LOCAL_ROOT\spark"
$env:HADOOP_HOME      = "$env:SPARK_LOCAL_ROOT\hadoop"
$env:SPARK_LOCAL_DIRS = "$env:SPARK_LOCAL_ROOT\tmp"
$env:COURSIER_CACHE   = "$env:SPARK_LOCAL_ROOT\tools\cache\coursier"

# Anadir binarios locales solo al PATH de esta sesion de terminal
$env:PATH = "$env:JAVA_HOME\bin;$env:SPARK_HOME\bin;$env:HADOOP_HOME\bin;$env:SPARK_LOCAL_ROOT\tools;$env:PATH"

# Activar el entorno virtual de Python 3.12 si ya existe
if (Test-Path "$env:SPARK_LOCAL_ROOT\workspace\.venv\Scripts\Activate.ps1") {
    & "$env:SPARK_LOCAL_ROOT\workspace\.venv\Scripts\Activate.ps1"
    $env:PYSPARK_PYTHON = "$env:SPARK_LOCAL_ROOT\workspace\.venv\Scripts\python.exe"
    $env:PYSPARK_DRIVER_PYTHON = $env:PYSPARK_PYTHON
}

Write-Host "Entorno Spark 4.1.4 (Java 17 + Python 3.12) activado." -ForegroundColor Green
java -version
