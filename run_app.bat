@echo off
title Brainy Basket - Smart Grocery Monitoring
echo ========================================================
echo   Starting Brainy Basket (AI & IoT Smart Grocery App)
echo ========================================================
echo.
python "%~dp0run.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Trying py launcher...
    py -3 "%~dp0run.py"
)
pause
