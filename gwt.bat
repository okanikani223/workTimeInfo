@echo off
setlocal
set current=%~dp0
@powershell -NoProfile -ExecutionPolicy Unrestricted %current%workTimeInfo.ps1 %1
endlocal