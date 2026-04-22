@echo off
title DroidX26 Launcher

:: Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

:: Run the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%DroidX26.ps1"

:: Optional: keep window open after execution
pause