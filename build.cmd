@echo OFF

SET COMMAND_TO_EXECUTE="psake -buildFile .\default.ps1"

rem echo Build command is "%COMMAND_TO_EXECUTE%"

C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe  -Version "2.0" -NoProfile -ExecutionPolicy unrestricted -Command "& {. %COMMAND_TO_EXECUTE%}"