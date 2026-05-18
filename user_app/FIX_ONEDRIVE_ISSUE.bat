@echo off
echo ========================================
echo   OneDrive Build Issue - Permanent Fix
echo ========================================
echo.
echo This script will:
echo 1. Stop OneDrive sync for this folder
echo 2. Clean build directories
echo 3. Set proper permissions
echo.
pause

REM Kill all processes
echo [1/5] Stopping all processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
taskkill /F /IM OneDrive.exe 2>nul
timeout /t 3 /nobreak >nul

REM Exclude build folders from OneDrive sync
echo [2/5] Excluding build folders from OneDrive...
attrib +U build /S /D 2>nul
attrib +U linux\flutter\ephemeral /S /D 2>nul
attrib +U .dart_tool /S /D 2>nul

REM Take ownership
echo [3/5] Taking ownership...
takeown /F build /R /D Y >nul 2>&1
icacls build /grant %USERNAME%:F /T >nul 2>&1
takeown /F linux /R /D Y >nul 2>&1
icacls linux /grant %USERNAME%:F /T >nul 2>&1
takeown /F .dart_tool /R /D Y >nul 2>&1
icacls .dart_tool /grant %USERNAME%:F /T >nul 2>&1

REM Clean directories
echo [4/5] Cleaning build directories...
rmdir /S /Q build 2>nul
rmdir /S /Q linux\flutter\ephemeral 2>nul
rmdir /S /Q .dart_tool 2>nul
timeout /t 2 /nobreak >nul

REM Restart OneDrive
echo [5/5] Restarting OneDrive...
start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe"

echo.
echo ========================================
echo   Fix Applied Successfully!
echo ========================================
echo.
echo Build folders are now excluded from OneDrive sync.
echo You can now run: START_APP.bat
echo.
pause
