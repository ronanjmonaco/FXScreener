@echo off
echo ========================================
echo Starting FX Screener (Improved Version)
echo ========================================
echo.

cd /d "C:\Users\rmonaco\Desktop\FXScreener"

echo Starting improved startup script...
powershell -ExecutionPolicy Bypass -File "start_fx_screener_improved.ps1"

echo.
echo ========================================
echo FX Screener startup completed!
echo ========================================
pause