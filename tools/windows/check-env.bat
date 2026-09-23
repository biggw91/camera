@echo off
REM Phase 1 - Development environment check (read-only, installs nothing)
REM ExecutionPolicy Bypass applies to this run only; PC settings are not changed.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-env.ps1"
echo.
pause
