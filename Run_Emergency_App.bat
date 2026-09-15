@echo off
title Emergency App Launcher
echo ========================================================
echo Starting Android Emulator and Emergency App GUI...
echo ========================================================

start "" "C:\Users\HP\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd EmergencyApp_x64

echo Waiting for emulator to load...
"C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe" wait-for-device

echo Launching Emergency App...
timeout /t 5 /nobreak >nul
"C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe" shell monkey -p com.atinity.public_emergency_app -c android.intent.category.LAUNCHER 1

echo App launched successfully!
