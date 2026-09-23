@echo off
REM Phase 3 - Create MySQL database and app account, then write .env
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-db.ps1"
echo.
pause
