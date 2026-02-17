Write-Host "========================================" -ForegroundColor Red
Write-Host "Stopping Todo App Servers" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue

if ($nodeProcesses) {
    Write-Host "Found $($nodeProcesses.Count) Node.js process(es)" -ForegroundColor Yellow
    Write-Host "Stopping..." -ForegroundColor Red
    $nodeProcesses | Stop-Process -Force
    Start-Sleep -Seconds 1
    Write-Host "All servers stopped!" -ForegroundColor Green
} else {
    Write-Host "No Node.js processes running" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To start servers, run: .\start-dev.ps1" -ForegroundColor Gray
Write-Host ""
