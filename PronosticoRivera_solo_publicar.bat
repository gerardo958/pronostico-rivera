@echo off
REM ============================================================
REM  PronosticoRivera - Solo publicar
REM  Publica en GitHub Pages lo que ya esta calculado.
REM  (No recalcula indices.)
REM ============================================================

set PY="C:\Program Files\QGIS 4.0.2\apps\Python312\python.exe"
set DIR=C:\Users\G A\AppData\Roaming\PronosticoRivera

cd /d "%DIR%"

echo.
echo ============================================================
echo   Publicando en GitHub Pages...
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
