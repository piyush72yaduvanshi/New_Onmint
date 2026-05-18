@echo off
echo Cleaning build directories...

REM Kill all Flutter/Dart/Chrome processes
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul

timeout /t 2 /nobreak >nul

REM Remove build directories
if exist "build" (
    attrib -r -s -h "build\*.*" /s /d
    rmdir /s /q "build" 2>nul
)

if exist ".dart_tool" (
    attrib -r -s -h ".dart_tool\*.*" /s /d
    rmdir /s /q ".dart_tool" 2>nul
)

echo Starting Flutter app...
flutter run -d chrome --web-renderer html

pause
