Write-Host "========================================" -ForegroundColor Green
Write-Host "🚀 Starting FX Screener with NGROK" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

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

# Function to wait for service to be ready
function Wait-ForService {
    param([string]$Url, [int]$MaxWait = 30)
    $waited = 0
    while ($waited -lt $MaxWait) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                return $true
            }
        }
        catch {
            Start-Sleep -Seconds 2
            $waited += 2
        }
    }
    return $false
}

# Step 1: Activate virtual environment
Write-Host "📦 Activating virtual environment..." -ForegroundColor Yellow
& '.venv\Scripts\Activate.ps1'

# Step 2: Start Excel API server
Write-Host "🔧 Starting Excel API server..." -ForegroundColor Yellow
if (Test-Port 5001) {
    Write-Host "   ⚠️  Port 5001 is already in use. Stopping existing process..." -ForegroundColor Yellow
    Get-Process | Where-Object {$_.ProcessName -eq "python"} | Stop-Process -Force
    Start-Sleep -Seconds 2
}

Start-Process powershell -ArgumentList "-Command", "cd '$PWD'; .venv\Scripts\Activate.ps1; python excel_server.py" -WindowStyle Minimized

# Wait for Excel server to start
Write-Host "   ⏳ Waiting for Excel server to start..." -ForegroundColor Yellow
if (Wait-ForService "http://127.0.0.1:5001/health" 15) {
    Write-Host "   ✅ Excel server is running!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Excel server failed to start!" -ForegroundColor Red
    exit 1
}

# Step 3: Start ngrok tunnels
Write-Host "🌐 Starting ngrok tunnels..." -ForegroundColor Yellow
if (Get-Process -Name "ngrok" -ErrorAction SilentlyContinue) {
    Write-Host "   ⚠️  Stopping existing ngrok process..." -ForegroundColor Yellow
    Stop-Process -Name "ngrok" -Force
    Start-Sleep -Seconds 2
}

Start-Process powershell -ArgumentList "-Command", "cd '$PWD'; ngrok start --all --config=ngrok.yml" -WindowStyle Minimized

# Wait for ngrok to start
Write-Host "   ⏳ Waiting for ngrok tunnels to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Get tunnel URLs
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:4040/api/tunnels" -UseBasicParsing
    $json = $response.Content | ConvertFrom-Json
    $streamlitUrl = ($json.tunnels | Where-Object {$_.name -eq "streamlit"}).public_url
    $apiUrl = ($json.tunnels | Where-Object {$_.name -eq "api"}).public_url
    
    Write-Host "   ✅ Ngrok tunnels are active!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to get ngrok tunnel URLs!" -ForegroundColor Red
    exit 1
}

# Step 4: Start Streamlit app
Write-Host "📊 Starting Streamlit app..." -ForegroundColor Yellow
if (Test-Port 8501) {
    Write-Host "   ⚠️  Port 8501 is already in use. Stopping existing process..." -ForegroundColor Yellow
    Get-Process | Where-Object {$_.ProcessName -eq "python"} | Stop-Process -Force
    Start-Sleep -Seconds 2
}

Start-Process powershell -ArgumentList "-Command", "cd '$PWD'; .venv\Scripts\Activate.ps1; streamlit run app.py --server.port 8501" -WindowStyle Normal

# Wait for Streamlit to start
Write-Host "   ⏳ Waiting for Streamlit to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Final status
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 FX SCREENER IS READY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 PUBLIC URLs:" -ForegroundColor Cyan
Write-Host "   📊 Streamlit App: $streamlitUrl" -ForegroundColor White
Write-Host "   🔧 API Server: $apiUrl" -ForegroundColor White
Write-Host ""
Write-Host "📋 API ENDPOINTS:" -ForegroundColor Cyan
Write-Host "   ❤️  Health Check: $apiUrl/health" -ForegroundColor White
Write-Host "   📈 FX Data: $apiUrl/api/fx" -ForegroundColor White
Write-Host ""
Write-Host "💡 TIP: Add 'ngrok-skip-browser-warning: true' header to skip ngrok warnings" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
