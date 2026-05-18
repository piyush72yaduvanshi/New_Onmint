# Force Restart Script for User App
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FORCE RESTART - User App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill all processes
Write-Host "Step 1: Killing ALL Flutter/Dart/Chrome processes..." -ForegroundColor Yellow
Get-Process -Name dart -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name flutter -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name chromedriver -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "Waiting for processes to terminate..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Step 2: Remove build directories with force
Write-Host ""
Write-Host "Step 2: Removing build directories..." -ForegroundColor Yellow

if (Test-Path "build") {
    Write-Host "Removing build folder..." -ForegroundColor Gray
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    
    if (Test-Path "build") {
        Write-Host "Build folder still exists, trying with takeown..." -ForegroundColor Gray
        takeown /f build /r /d y 2>$null
        icacls build /grant administrators:F /t 2>$null
        Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path ".dart_tool") {
    Write-Host "Removing .dart_tool folder..." -ForegroundColor Gray
    Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
}

# Step 3: Flutter clean
Write-Host ""
Write-Host "Step 3: Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Step 4: Get dependencies
Write-Host ""
Write-Host "Step 4: Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Step 5: Run app
Write-Host ""
Write-Host "Step 5: Starting app on Chrome..." -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTE:" -ForegroundColor Green
Write-Host "- Images for Doctor, Nurse, Ambulance, Lab Test should now be visible" -ForegroundColor Green
Write-Host "- Nurse section navigation should work" -ForegroundColor Green
Write-Host "- All service navigations should work" -ForegroundColor Green
Write-Host ""

flutter run -d chrome

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
