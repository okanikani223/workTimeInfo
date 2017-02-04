@echo off
setlocal
echo %0
set current=%~dp0
@powershell -NoProfile -ExecutionPolicy Unrestricted %current%workTimeInfo.ps1
endlocal