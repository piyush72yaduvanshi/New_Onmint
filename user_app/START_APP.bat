@echo off
echo ========================================
echo   Starting Flutter App (OneDrive Fix)
echo ========================================
echo.

REM Kill all processes
echo [1/4] Stopping all Flutter/Chrome processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
timeout /t 2 /nobreak >nul

REM Clean build directory manually (OneDrive safe)
echo [2/4] Cleaning build directory...
if exist "build\flutter_assets" (
    rmdir /s /q "build\flutter_assets" 2>nul
)
if exist "build\web" (
    rmdir /s /q "build\web" 2>nul
)
timeout /t 1 /nobreak >nul

REM Get dependencies
echo [3/4] Getting dependencies...
call flutter pub get
echo.

REM Start app
echo [4/4] Starting app on Chrome...
echo.
echo ========================================
echo   App is starting...
echo ========================================
echo.
call flutter run -d chrome

pause
