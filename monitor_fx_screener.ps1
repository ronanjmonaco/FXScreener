# FX Screener Monitoring Script
# This script monitors the health of all services and can auto-restart them

param(
    [switch]$AutoRestart,
    [int]$CheckInterval = 30
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "FX Screener Health Monitor" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

if ($AutoRestart) {
    Write-Host "Auto-restart mode: ENABLED" -ForegroundColor Yellow
} else {
    Write-Host "Auto-restart mode: DISABLED" -ForegroundColor Yellow
}

Write-Host "Check interval: $CheckInterval seconds" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host ""

# Set working directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

function Test-Service {
    param([string]$Name, [string]$Url, [int]$Port)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        return @{
            Status = "OK"
            Code = $response.StatusCode
            Message = "✅ $Name is healthy (Status: $($response.StatusCode))"
        }
    }
    catch {
        return @{
            Status = "ERROR"
            Code = 0
            Message = "❌ $Name is down: $($_.Exception.Message)"
        }
    }
}

function Restart-Service {
    param([string]$ServiceName, [string]$Command)
    
    Write-Host "🔄 Restarting $ServiceName..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-Command", "cd '$scriptPath'; $Command" -WindowStyle Normal
    Start-Sleep -Seconds 5
}

$services = @(
    @{ Name = "Excel API"; Url = "http://127.0.0.1:5001/api/fx"; Port = 5001; Command = ".venv\Scripts\python.exe excel_server.py" },
    @{ Name = "Streamlit"; Url = "http://127.0.0.1:8501"; Port = 8501; Command = ".venv\Scripts\streamlit.exe run app.py --server.port 8501 --server.headless true" },
    @{ Name = "External API"; Url = "https://argyfx.com/api/fx"; Port = 0; Command = ".\cloudflared.exe tunnel run argyfx-tunnel --config tunnel-config.yml" },
    @{ Name = "External Site"; Url = "https://argyfx.com"; Port = 0; Command = ".\cloudflared.exe tunnel run argyfx-tunnel --config tunnel-config.yml" }
)

while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] Checking services..." -ForegroundColor Cyan
    
    $allHealthy = $true
    
    foreach ($service in $services) {
        $result = Test-Service -Name $service.Name -Url $service.Url -Port $service.Port
        
        if ($result.Status -eq "OK") {
            Write-Host "  $($result.Message)" -ForegroundColor Green
        } else {
            Write-Host "  $($result.Message)" -ForegroundColor Red
            $allHealthy = $false
            
            if ($AutoRestart -and $service.Command) {
                Restart-Service -ServiceName $service.Name -Command $service.Command
            }
        }
    }
    
    if ($allHealthy) {
        Write-Host "  🎉 All services are healthy!" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Some services need attention" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Start-Sleep -Seconds $CheckInterval
}
