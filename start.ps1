Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  Intelligent File Analyzer & Cleanup Assistant        " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching desktop web dashboard at http://127.0.0.1:3847 ..." -ForegroundColor Green

Set-Location $PSScriptRoot
Start-Process "http://127.0.0.1:3847"
npm start
