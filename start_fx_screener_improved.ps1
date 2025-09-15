# Improved FX Screener Startup Script
# This script handles all the PowerShell issues we encountered

Write-Host "========================================" -ForegroundColor Green
Write-Host "Starting FX Screener (Improved Version)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Set working directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Working directory: $scriptPath" -ForegroundColor Cyan

# Function to check if port is in use
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("127.0.0.1", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Function to wait for service to start
function Wait-ForService {
    param([int]$Port, [string]$ServiceName, [int]$TimeoutSeconds = 30)
    
    Write-Host "Waiting for $ServiceName to start on port $Port..." -ForegroundColor Yellow
    $elapsed = 0
    
    while ($elapsed -lt $TimeoutSeconds) {
        if (Test-Port $Port) {
            Write-Host "$ServiceName is running on port $Port" -ForegroundColor Green
            return $true
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "$ServiceName failed to start within $TimeoutSeconds seconds" -ForegroundColor Red
    return $false
}

# Start Excel API Server
Write-Host "Starting Excel API server..." -ForegroundColor Yellow
if (Test-Port 5001) {
    Write-Host "Port 5001 is already in use. Checking if Excel API is running..." -ForegroundColor Yellow
} else {
    Start-Process powershell -ArgumentList "-Command", "cd '$scriptPath'; .venv\Scripts\python.exe excel_server.py" -WindowStyle Normal
    if (-not (Wait-ForService 5001 "Excel API Server" 15)) {
        Write-Host "Failed to start Excel API Server" -ForegroundColor Red
        exit 1
    }
}

# Start Streamlit
Write-Host "Starting Streamlit..." -ForegroundColor Yellow
if (Test-Port 8501) {
    Write-Host "Port 8501 is already in use. Checking if Streamlit is running..." -ForegroundColor Yellow
} else {
    Start-Process powershell -ArgumentList "-Command", "cd '$scriptPath'; .venv\Scripts\streamlit.exe run app.py --server.port 8501 --server.headless true" -WindowStyle Normal
    if (-not (Wait-ForService 8501 "Streamlit" 20)) {
        Write-Host "Failed to start Streamlit" -ForegroundColor Red
        exit 1
    }
}

# Wait a moment for services to stabilize
Write-Host "Waiting for services to stabilize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start Cloudflare Tunnel
Write-Host "Starting Cloudflare tunnel..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-Command", "cd '$scriptPath'; .\cloudflared.exe tunnel run argyfx-tunnel --config tunnel-config.yml" -WindowStyle Normal

# Wait for tunnel to connect
Write-Host "Waiting for tunnel to connect..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test connections
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Testing Connections..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Test local services
try {
    $localAPI = (Invoke-WebRequest -Uri "http://127.0.0.1:5001/api/fx" -UseBasicParsing -TimeoutSec 10).StatusCode
    Write-Host "✅ Local API (port 5001): Status $localAPI" -ForegroundColor Green
} catch {
    Write-Host "❌ Local API (port 5001): Failed" -ForegroundColor Red
}

try {
    $localStreamlit = (Invoke-WebRequest -Uri "http://127.0.0.1:8501" -UseBasicParsing -TimeoutSec 10).StatusCode
    Write-Host "✅ Local Streamlit (port 8501): Status $localStreamlit" -ForegroundColor Green
} catch {
    Write-Host "❌ Local Streamlit (port 8501): Failed" -ForegroundColor Red
}

# Test external services
try {
    $externalAPI = (Invoke-WebRequest -Uri "https://argyfx.com/api/fx" -UseBasicParsing -TimeoutSec 15).StatusCode
    Write-Host "✅ External API (argyfx.com/api/fx): Status $externalAPI" -ForegroundColor Green
} catch {
    Write-Host "❌ External API (argyfx.com/api/fx): Failed" -ForegroundColor Red
}

try {
    $externalSite = (Invoke-WebRequest -Uri "https://argyfx.com" -UseBasicParsing -TimeoutSec 15).StatusCode
    Write-Host "✅ External Site (argyfx.com): Status $externalSite" -ForegroundColor Green
} catch {
    Write-Host "❌ External Site (argyfx.com): Failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "FX Screener Startup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your URLs:" -ForegroundColor White
Write-Host "   • Local Streamlit: http://127.0.0.1:8501" -ForegroundColor Cyan
Write-Host "   • Local API: http://127.0.0.1:5001/api/fx" -ForegroundColor Cyan
Write-Host "   • External Site: https://argyfx.com" -ForegroundColor Cyan
Write-Host "   • External API: https://argyfx.com/api/fx" -ForegroundColor Cyan
Write-Host "   • Streamlit Cloud: https://fx-screener-mep-ccl.streamlit.app" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
