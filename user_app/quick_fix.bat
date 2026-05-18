@echo off
echo Killing processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
timeout /t 3 >nul

echo Removing build folder...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul

echo Cleaning...
flutter clean

echo Getting dependencies...
flutter pub get

echo Starting app...
flutter run -d chrome
