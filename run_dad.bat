@echo off
chcp 65001 >nul
title Support Family - Dad App (Pixel_Dad)
cd /d "%~dp0"

echo [1/2] Khoi dong Android Emulator thu 2 (Pixel_Dad)...
start "" "D:\Application\android-sdk\emulator\emulator.exe" -avd Pixel_Dad -no-snapshot-load -gpu swiftshader_indirect

echo Dang cho Pixel_Dad boot xong...
"D:\Application\android-sdk\platform-tools\adb.exe" -s emulator-5556 wait-for-device

:waitboot
for /f "delims=" %%i in ('"D:\Application\android-sdk\platform-tools\adb.exe" -s emulator-5556 shell getprop sys.boot_completed 2^>nul') do set BOOT=%%i
if not "%BOOT%"=="1" (
  timeout /t 2 >nul
  goto waitboot
)

echo Dat vi tri GPS cho Bo tai Da Nang (gan Be Na)...
"D:\Application\android-sdk\platform-tools\adb.exe" -s emulator-5556 emu geo fix 108.2150 16.0600 >nul 2>&1

echo.
echo [2/2] Chay app Flutter cho Bo Hoang...
echo.
echo   r = Hot reload
echo   R = Hot restart
echo   q = Thoat
echo.
flutter run -d emulator-5556
pause
