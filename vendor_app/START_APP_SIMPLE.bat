@echo off
echo ========================================
echo   Starting Vendor App - SIMPLE VERSION
echo   (Ambulance Bookings Only)
echo ========================================

echo [1/4] Stopping all Flutter/Chrome processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM chrome.exe 2>nul

echo [2/4] Cleaning build directories manually...
if exist "build" rmdir /s /q "build" 2>nul
if exist ".dart_tool\build" rmdir /s /q ".dart_tool\build" 2>nul

echo [3/4] Getting dependencies...
call flutter pub get

echo [4/4] Starting app on Chrome (Simple Version)...
echo ========================================
echo   App is starting...
echo   Note: Pharmacist screens disabled
echo   Focus: Ambulance bookings only
echo ========================================
call flutter run -d chrome -t lib/main_simple.dart

pause
