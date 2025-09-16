# FX Screener - Fixed Domain Startup Script
# This script starts all services with your fixed argyfx.com domain

Write-Host "=== STARTING FX SCREENER WITH FIXED DOMAIN ===" -ForegroundColor Cyan
Write-Host "Domain: https://argyfx.com" -ForegroundColor Green
Write-Host ""

# Step 1: Start Excel Server
Write-Host "STEP 1: Starting Excel Server..." -ForegroundColor Yellow
Start-Process -FilePath "python" -ArgumentList "excel_server.py" -WindowStyle Hidden
Start-Sleep -Seconds 3

# Step 2: Start Streamlit App
Write-Host "STEP 2: Starting Streamlit App..." -ForegroundColor Yellow
Start-Process -FilePath ".venv\Scripts\Activate.ps1" -ArgumentList "; streamlit run app.py --server.port 8501 --server.headless true" -WindowStyle Hidden
Start-Sleep -Seconds 3

# Step 3: Start Cloudflare Tunnel (Fixed Domain)
Write-Host "STEP 3: Starting Cloudflare Tunnel (argyfx.com)..." -ForegroundColor Yellow
Start-Process -FilePath ".\cloudflared.exe" -ArgumentList "tunnel run --config tunnel-config.yml" -WindowStyle Hidden
Start-Sleep -Seconds 5

# Step 4: Test connections
Write-Host "STEP 4: Testing connections..." -ForegroundColor Yellow

# Test Excel Server
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001/api/fx?ci_mode=ci" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Excel Server: OK" -ForegroundColor Green
} catch {
    Write-Host "✗ Excel Server: FAILED" -ForegroundColor Red
}

# Test Streamlit
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8501" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Streamlit App: OK" -ForegroundColor Green
} catch {
    Write-Host "✗ Streamlit App: FAILED" -ForegroundColor Red
}

# Test Fixed Domain
try {
    $response = Invoke-WebRequest -Uri "https://argyfx.com/api/fx?ci_mode=ci" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Fixed Domain (argyfx.com): OK" -ForegroundColor Green
} catch {
    Write-Host "✗ Fixed Domain (argyfx.com): FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== FX SCREENER IS READY ===" -ForegroundColor Green
Write-Host "Local Streamlit: http://localhost:8501" -ForegroundColor Cyan
Write-Host "Fixed Domain: https://argyfx.com" -ForegroundColor Cyan
Write-Host "API Endpoint: https://argyfx.com/api/fx" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to stop all services..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop all services
Write-Host "Stopping services..." -ForegroundColor Yellow
taskkill /F /IM python.exe 2>$null
taskkill /F /IM cloudflared.exe 2>$null
Write-Host "All services stopped." -ForegroundColor Green
