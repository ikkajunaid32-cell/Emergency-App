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
if %errorlevel% equ 0 goto check_boot

echo [1/4] Starting Android Emulator: EmergencyApp_x64...
start "" "%EMULATOR%" -avd EmergencyApp_x64

:check_boot
echo [2/4] Waiting for emulator to connect...
"%ADB%" wait-for-device

echo [2/4] Waiting for Android system to boot completely...
:wait_boot
for /f "tokens=*" %%a in ('"%ADB%" shell getprop sys.boot_completed 2^>nul') do set "BOOT=%%a"
if not "%BOOT%"=="1" (
    ping -n 3 127.0.0.1 >nul
    goto wait_boot
)
echo [2/4] Android is fully booted!

:wait_pm
"%ADB%" shell pm path android >nul 2>&1
if %errorlevel% neq 0 (
    ping -n 3 127.0.0.1 >nul
    goto wait_pm
)

echo.
echo [3/4] Installing latest Emergency App APK...
"%ADB%" install -r -d "%APK%"

echo.
echo [4/4] Launching Emergency App...
"%ADB%" shell monkey -p com.atinity.public_emergency_app -c android.intent.category.LAUNCHER 1

echo.
echo ========================================================
echo   SUCCESS! Emergency App is now running on your PC.
echo ========================================================
echo.
pause
