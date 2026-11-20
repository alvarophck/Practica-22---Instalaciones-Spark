$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Set-Location C:\SparkLocal\workspace
. .\activar_entorno.ps1

# 6.1 Coursier portable
Invoke-WebRequest -Uri "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-win32.zip" -OutFile "C:\SparkLocal\tools\cs.zip"
Expand-Archive -Path "C:\SparkLocal\tools\cs.zip" -DestinationPath "C:\SparkLocal\tools" -Force
Rename-Item -Path "C:\SparkLocal\tools\cs-x86_64-pc-win32.exe" -NewName "cs.exe" -Force
Unblock-File -Path "C:\SparkLocal\tools\cs.exe"
Remove-Item "C:\SparkLocal\tools\cs.zip"

# 6.2 Kernel Almond 0.15.0 para Scala 2.13.18
cs launch almond:0.15.0 --scala 2.13.18 -- `
  --install `
  --force `
  --id scala-213-spark `
  --display-name "Scala 2.13.18 (Spark Aislado)" `
  --jupyter-path "C:\SparkLocal\workspace\.venv\share\jupyter\kernels"

# 6.3 Variables y flags de Java 17 en el kernel de Scala
$scalaKernelPath = "C:\SparkLocal\workspace\.venv\share\jupyter\kernels\scala-213-spark\kernel.json"
$scalaKernel = Get-Content $scalaKernelPath -Raw | ConvertFrom-Json
if ($scalaKernel.argv[0] -eq "java") { $scalaKernel.argv[0] = "C:\SparkLocal\jdk-17\bin\java.exe" }

$java17Opts = @(
    "-Djava.library.path=C:\SparkLocal\hadoop\bin",
    "--add-opens=java.base/java.lang=ALL-UNNAMED",
    "--add-opens=java.base/java.lang.invoke=ALL-UNNAMED",
    "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED",
    "--add-opens=java.base/java.io=ALL-UNNAMED",
    "--add-opens=java.base/java.net=ALL-UNNAMED",
    "--add-opens=java.base/java.nio=ALL-UNNAMED",
    "--add-opens=java.base/java.util=ALL-UNNAMED",
    "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED",
    "--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED",
    "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED",
    "--add-opens=java.base/sun.nio.cs=ALL-UNNAMED",
    "--add-opens=java.base/sun.security.action=ALL-UNNAMED",
    "--add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
) -join " "

$scalaEnv = [ordered]@{
    JAVA_HOME        = "C:\SparkLocal\jdk-17"
    HADOOP_HOME      = "C:\SparkLocal\hadoop"
    SPARK_LOCAL_DIRS = "C:\SparkLocal\tmp"
    COURSIER_CACHE   = "C:\SparkLocal\tools\cache\coursier"
    JDK_JAVA_OPTIONS = $java17Opts
}
$scalaKernel | Add-Member -MemberType NoteProperty -Name "env" -Value $scalaEnv -Force
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($scalaKernelPath, ($scalaKernel | ConvertTo-Json -Depth 5), $utf8NoBom)
Write-Host "Kernel Scala 2.13.18 listo." -ForegroundColor Green
jupyter kernelspec list
