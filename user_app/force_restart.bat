@echo off
echo ========================================
echo FORCE RESTART - User App
echo ========================================
echo.

echo Step 1: Killing ALL Flutter/Dart/Chrome processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
taskkill /F /IM chromedriver.exe 2>nul
echo Waiting for processes to terminate...
timeout /t 3 >nul

echo.
echo Step 2: Removing build directory manually...
if exist "build" (
    echo Attempting to remove build folder...
    rmdir /s /q build 2>nul
    if exist "build" (
        echo Build folder still exists, trying harder...
        rd /s /q build 2>nul
        timeout /t 2 >nul
    )
)

if exist ".dart_tool" (
    echo Removing .dart_tool folder...
    rmdir /s /q .dart_tool 2>nul
)

echo.
echo Step 3: Running flutter clean...
flutter clean

echo.
echo Step 4: Getting dependencies...
flutter pub get

echo.
echo Step 5: Starting app on Chrome...
echo.
echo NOTE: 
echo - Images for Doctor, Nurse, Ambulance, Lab Test should now be visible
echo - Nurse section navigation should work
echo - All service navigations should work
echo.
flutter run -d chrome

pause
