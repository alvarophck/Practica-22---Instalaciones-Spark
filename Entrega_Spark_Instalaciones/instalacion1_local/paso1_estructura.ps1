New-Item -ItemType Directory -Force -Path `
  "C:\SparkLocal\jdk-17", "C:\SparkLocal\spark", "C:\SparkLocal\hadoop\bin", `
  "C:\SparkLocal\tmp", "C:\SparkLocal\tools\cache\coursier", "C:\SparkLocal\tools\cache\ivy2", `
  "C:\SparkLocal\workspace\.vscode", "C:\SparkLocal\workspace\notebooks"
Write-Host "Estructura creada en C:\SparkLocal" -ForegroundColor Green
