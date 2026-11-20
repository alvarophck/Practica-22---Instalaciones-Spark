$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # descargas mucho mas rapidas en PowerShell 5.1
$dl = "C:\SparkLocal\tmp"

# --- Java 17 (Temurin, zip portable) ---
Write-Host "Descargando Java 17..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse" -OutFile "$dl\jdk17.zip"
Expand-Archive -Path "$dl\jdk17.zip" -DestinationPath "$dl\jdk_extract" -Force
$sub = Get-ChildItem "$dl\jdk_extract" -Directory | Select-Object -First 1
Copy-Item "$($sub.FullName)\*" -Destination "C:\SparkLocal\jdk-17" -Recurse -Force
Remove-Item "$dl\jdk_extract","$dl\jdk17.zip" -Recurse -Force
if (-not (Test-Path "C:\SparkLocal\jdk-17\bin\java.exe")) { throw "No se encuentra java.exe" }

# --- Spark 4.1.4 ---
Write-Host "Descargando Spark 4.1.4 (unos 450 MB)..." -ForegroundColor Cyan
$tgz = "$dl\spark-4.1.4-bin-hadoop3.tgz"
try { Invoke-WebRequest -Uri "https://downloads.apache.org/spark/spark-4.1.4/spark-4.1.4-bin-hadoop3.tgz" -OutFile $tgz }
catch { Invoke-WebRequest -Uri "https://archive.apache.org/dist/spark/spark-4.1.4/spark-4.1.4-bin-hadoop3.tgz" -OutFile $tgz }
tar -xzf $tgz -C "C:\SparkLocal\spark" --strip-components=1
Remove-Item $tgz -Force
if (-not (Test-Path "C:\SparkLocal\spark\bin\spark-shell.cmd")) { throw "No se encuentra spark-shell.cmd" }

# --- winutils + hadoop.dll ---
Write-Host "Descargando winutils y hadoop.dll..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/cdarlint/winutils/raw/master/hadoop-3.3.6/bin/winutils.exe" -OutFile "C:\SparkLocal\hadoop\bin\winutils.exe"
Invoke-WebRequest -Uri "https://github.com/cdarlint/winutils/raw/master/hadoop-3.3.6/bin/hadoop.dll" -OutFile "C:\SparkLocal\hadoop\bin\hadoop.dll"
Unblock-File -Path "C:\SparkLocal\hadoop\bin\winutils.exe", "C:\SparkLocal\hadoop\bin\hadoop.dll"
Copy-Item "C:\SparkLocal\hadoop\bin\hadoop.dll" -Destination "C:\SparkLocal\jdk-17\bin\hadoop.dll" -Force

Write-Host "Java 17, Spark 4.1.4 y winutils instalados." -ForegroundColor Green
& "C:\SparkLocal\jdk-17\bin\java.exe" -version
