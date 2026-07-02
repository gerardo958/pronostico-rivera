@echo off
REM ============================================================
REM  PronosticoRivera - Ciclo completo
REM  Calcula los indices y publica el sitio en GitHub Pages.
REM  Doble clic para ejecutar, o correr desde consola.
REM ============================================================

set PY="C:\Program Files\QGIS 4.0.2\apps\Python312\python.exe"
set DIR=C:\Users\G A\AppData\Roaming\PronosticoRivera

cd /d "%DIR%"

echo.
echo ============================================================
echo   PASO 1 de 2 - Calculando indices climaticos...
echo ============================================================
%PY% calcular_indices.py
if errorlevel 1 (
    echo.
    echo [ERROR] Fallo el calculo de indices. Se detiene aqui.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   PASO 2 de 2 - Publicando en GitHub Pages...
echo ============================================================
%PY% deploy_pronostico.py
if errorlevel 1 (
    echo.
    echo [ERROR] Fallo la publicacion.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   LISTO. Sitio: https://gerardo958.github.io/pronostico-rivera/
echo ============================================================
pause
