@echo off
title Emergency App Launcher
echo ========================================================
echo       EMERGENCY APP - ONE-CLICK PC LAUNCHER
echo ========================================================
echo.

set ADB="C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set EMULATOR="C:\Users\HP\AppData\Local\Android\Sdk\emulator\emulator.exe"
set APK="C:\Users\HP\Desktop\EmergencyApp.apk"

echo [1/4] Checking if Emulator is already running...
%ADB% devices | findstr /R "emulator-[0-9]*" >nul
if %errorlevel% neq 0 (
    echo [1/4] Starting Android Emulator (EmergencyApp_x64)...
    start "" %EMULATOR% -avd EmergencyApp_x64
    echo [2/4] Waiting for emulator to start...
    %ADB% wait-for-device
    echo [2/4] Waiting for system to boot completely...
    timeout /t 10 /nobreak >nul
) else (
    echo [1/4] Emulator is already running!
)

echo.
echo [3/4] Installing latest Emergency App APK...
%ADB% install -r %APK%

echo.
echo [4/4] Launching Emergency App...
%ADB% shell monkey -p com.atinity.public_emergency_app -c android.intent.category.LAUNCHER 1

echo.
echo ========================================================
echo   SUCCESS! Emergency App is now running on your PC.
echo ========================================================
echo.
pause
