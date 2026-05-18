@echo off
echo ========================================
echo Restarting User App with Clean Build
echo ========================================
echo.

echo Step 1: Stopping all Flutter processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
timeout /t 2 >nul

echo.
echo Step 2: Cleaning build artifacts...
flutter clean

echo.
echo Step 3: Getting dependencies...
flutter pub get

echo.
echo Step 4: Running app on Chrome...
echo.
echo NOTE: The app will now start on Chrome.
echo Images for Doctor, Nurse, Ambulance, and Lab Test should now be visible.
echo.
flutter run -d chrome

pause
