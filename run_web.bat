@echo off
chcp 65001 >nul
title Support Family - Caregiver Web
cd /d "%~dp0"

echo ==============================================
echo    Support Family - Web Nguoi cham soc
echo ==============================================

if not exist "BE\node_modules" (
  echo [1/4] Cai dat thu vien Backend...
  pushd BE && call npm install && popd
)
if not exist "caregiver_web\node_modules" (
  echo [2/4] Cai dat thu vien Web...
  pushd caregiver_web && call npm install && popd
)

echo [3/4] Khoi dong Backend (http://localhost:3000)...
start "SupportFamily Backend" cmd /k "cd /d %~dp0BE && npm run dev"

echo [4/4] Khoi dong Web (http://localhost:8081)...
start "SupportFamily Caregiver Web" cmd /k "cd /d %~dp0caregiver_web && npm run dev"

timeout /t 12 /nobreak >nul
start "" http://localhost:8081
echo Da mo trinh duyet. Dong cac cua so terminal de dung server.
