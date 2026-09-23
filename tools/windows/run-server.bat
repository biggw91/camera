@echo off
REM Start thermal-event-server (Ctrl+C to stop)
REM First run downloads Maven and libraries automatically (internet required).
cd /d "%~dp0..\..\thermal-event-server"
call mvnw.cmd spring-boot:run
pause
