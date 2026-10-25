@echo off
echo ==================================================
echo    Roblox1: Style a Snack - GitHub Sync
echo ==================================================
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\sync-github.ps1" %*
pause
