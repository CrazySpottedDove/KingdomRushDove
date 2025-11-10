@REM 运行 ..\love.exe .
@echo off
setlocal enabledelayedexpansion
set "love_path=..\love.exe"
if not exist "%love_path%" (
    echo Love executable not found at %love_path%.
    exit /b 1
)
set "current_dir=%cd%"
cd /d "%~dp0"
if exist "%love_path%" (
    echo Running Love executable...
    "%love_path%" .
) else (
    echo Love executable not found at %love_path%.
    exit /b 1
)