Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Todo App Servers" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for existing processes
$port3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
$port3001 = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue

if ($port3000 -or $port3001) {
    Write-Host "Warning: Ports may already be in use" -ForegroundColor Yellow
    if ($port3000) { Write-Host "  Port 3000 (Frontend) is busy" -ForegroundColor Yellow }
    if ($port3001) { Write-Host "  Port 3001 (Backend) is busy" -ForegroundColor Yellow }
    Write-Host ""
}

# Start Backend
Write-Host "Starting Backend Server..." -ForegroundColor Green
$BackendPath = Join-Path $PSScriptRoot "backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BackendPath'; Write-Host 'Backend Server' -ForegroundColor Cyan; npm start"

Start-Sleep -Seconds 3

# Start Frontend
Write-Host "Starting Frontend Server..." -ForegroundColor Green
$FrontendPath = Join-Path $PSScriptRoot "frontend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$FrontendPath'; Write-Host 'Frontend Server' -ForegroundColor Cyan; npm start"

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Servers Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Backend:  http://localhost:3001" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opening browser..." -ForegroundColor Gray
Start-Sleep -Seconds 2
Start-Process "http://localhost:3000"
Write-Host ""
Write-Host "To stop servers, run: .\stop-dev.ps1" -ForegroundColor Gray
Write-Host ""
