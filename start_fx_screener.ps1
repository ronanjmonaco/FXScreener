Write-Host "========================================" -ForegroundColor Green
Write-Host "Starting FX Screener..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Start Excel API server
Write-Host "Starting Excel API server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-Command", "& '.venv\Scripts\Activate.ps1'; python excel_server.py" -WindowStyle Normal

# Wait for server to start
Write-Host "Waiting 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Start Cloudflare tunnel with CORRECT syntax
Write-Host "Starting Cloudflare tunnel..." -ForegroundColor Yellow
Start-Process cmd -ArgumentList "/k", ".\cloudflared.exe tunnel run argyfx-tunnel --config tunnel-config.yml" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "FX Screener is starting!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. Excel API server - Starting..." -ForegroundColor Cyan
Write-Host "2. Cloudflare tunnel - Starting..." -ForegroundColor Cyan
Write-Host "3. Streamlit app - Already running!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Streamlit URL: https://fx-screener-mep-ccl.streamlit.app" -ForegroundColor White
Write-Host "Your API URL: https://argyfx.com" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
