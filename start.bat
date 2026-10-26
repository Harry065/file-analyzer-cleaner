@echo off
title Intelligent File Analyzer & Cleanup Assistant
echo =======================================================
echo   Intelligent File Analyzer & Cleanup Assistant
echo =======================================================
echo.
echo Starting local backend server...
cd /d "%~dp0"

start http://127.0.0.1:3847
npm start
pause
