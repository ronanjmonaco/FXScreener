@echo off
echo ========================================
echo Starting FX Screener...
echo ========================================

cd /d "C:\Users\rmonaco\Desktop\FXScreener"

echo Starting Excel API server...
start "FX API Server" cmd /k ".venv\Scripts\activate && python excel_server.py"

echo Waiting 3 seconds...
timeout /t 3 /nobreak > nul

echo Starting Cloudflare tunnel...
start "Cloudflare Tunnel" cmd /k ".\cloudflared.exe tunnel run --config tunnel-config.yml"

echo.
echo ========================================
echo FX Screener is starting!
echo ========================================
echo.
echo 1. Excel API server - Starting...
echo 2. Cloudflare tunnel - Starting...
echo 3. Streamlit app - Already running!
echo.
echo Your Streamlit URL: https://your-app-name.streamlit.app
echo Your API URL: https://argyfx.com
echo.
echo Press any key to continue...
pause



