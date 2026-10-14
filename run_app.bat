@echo off
chcp 65001 >nul
title Support Family - Run App
cd /d "%~dp0"

echo [1/3] Khoi dong Backend (cua so moi)...
start "Support Family Backend" cmd /k "cd /d %~dp0BE && npm run dev"

echo [2/3] Khoi dong Android Emulator...
"D:\Application\android-sdk\platform-tools\adb.exe" kill-server >nul 2>&1
"D:\Application\android-sdk\platform-tools\adb.exe" start-server >nul 2>&1
start "" "D:\Application\android-sdk\emulator\emulator.exe" -avd Pixel_6_API_36 -no-snapshot-load -gpu swiftshader_indirect

echo Dang cho emulator boot xong...
"D:\Application\android-sdk\platform-tools\adb.exe" wait-for-device
:waitboot
for /f "delims=" %%i in ('"D:\Application\android-sdk\platform-tools\adb.exe" shell getprop sys.boot_completed 2^>nul') do set BOOT=%%i
if not "%BOOT%"=="1" (
  timeout /t 2 >nul
  goto waitboot
)

echo Dat vi tri GPS gia lap ve Da Nang...
"D:\Application\android-sdk\platform-tools\adb.exe" emu geo fix 108.2022 16.0544 >nul 2>&1

echo [3/3] Chay app Flutter...
echo.
echo   r = Hot reload (sau khi sua code)
echo   R = Hot restart
echo   q = Thoat
echo.
flutter run -d emulator-5554
pause
