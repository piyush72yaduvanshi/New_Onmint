# Flutter App Starter with OneDrive Fix
# This script handles the OneDrive file locking issue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Flutter App (OneDrive Fix)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill all processes
Write-Host "[1/4] Stopping all Flutter/Chrome processes..." -ForegroundColor Yellow
Get-Process dart,flutter,chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Clean build directory
Write-Host "[2/4] Cleaning build directory..." -ForegroundColor Yellow
if (Test-Path "build\flutter_assets") {
    Remove-Item -Path "build\flutter_assets" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "build\web") {
    Remove-Item -Path "build\web" -Recurse -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 1

# Step 3: Get dependencies
Write-Host "[3/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Step 4: Start app
Write-Host "[4/4] Starting app on Chrome..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  App is starting..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

flutter run -d chrome

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
