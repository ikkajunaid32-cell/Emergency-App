@echo off
title Emergency App Launcher
echo ========================================================
echo       EMERGENCY APP - ONE-CLICK PC LAUNCHER
echo ========================================================
echo.

set "ADB=C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set "EMULATOR=C:\Users\HP\AppData\Local\Android\Sdk\emulator\emulator.exe"
set "APK=C:\Users\HP\Desktop\EmergencyApp.apk"

echo [1/4] Checking Android Emulator status...
"%ADB%" devices | findstr "emulator-" >nul
if %errorlevel% equ 0 (
    echo [1/4] Emulator is already running!
    goto install_app
)

echo [1/4] Starting Android Emulator: EmergencyApp_x64...
start "" "%EMULATOR%" -avd EmergencyApp_x64

echo [2/4] Waiting for emulator to connect...
"%ADB%" wait-for-device

echo [2/4] Waiting for Android system to boot...
ping -n 12 127.0.0.1 >nul

:install_app
echo.
echo [3/4] Installing latest Emergency App APK...
"%ADB%" install -r "%APK%"

echo.
echo [4/4] Launching Emergency App...
"%ADB%" shell monkey -p com.atinity.public_emergency_app -c android.intent.category.LAUNCHER 1

echo.
echo ========================================================
echo   SUCCESS! Emergency App is now running on your PC.
echo ========================================================
echo.
pause
