# PowerShell script to start vendor app (OneDrive fix)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Vendor App (OneDrive Fix)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] Stopping all Flutter/Chrome processes..." -ForegroundColor Yellow
Get-Process -Name dart -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[2/4] Cleaning build directories manually..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path ".dart_tool\build") {
    Remove-Item -Path ".dart_tool\build" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "[3/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "[4/4] Starting app on Chrome..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  App is starting..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
flutter run -d chrome
