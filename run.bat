@echo off
chcp 65001 >nul
setlocal

:main
if not exist "client.exe" (
    echo 错误: 未找到 client.exe
    exit /b 1
)

if "%1"=="" (
    call :show_help
    exit /b 0
)

if "%1"=="index" (
    call :index
) else if "%1"=="upload" (
    call :upload
) else if "%1"=="download" (
    call :download
) else if "%1"=="help" (
    call :show_help
) else if "%1"=="idx" (
    call :index
) else if "%1"=="up" (
    call :upload
) else if "%1"=="down" (
    call :download
) else (
    echo 错误: 未知命令 '%1'
    call :show_help
    exit /b 1
)

exit /b 0

:index
echo 生成资源索引...
if exist "scripts/gen_assets_index.lua" (
    %LUA_EXEC% "scripts/gen_assets_index.lua"
) else (
    echo 错误: 未找到 gen_assets_index.lua
    exit /b 1
)
exit /b 0

:upload
echo 上传资源...
"client.exe" --upload-assets
exit /b 0

:download
echo 下载资源...
"client.exe" --sync-assets
exit /b 0

:show_help
echo.
echo 可用命令:
echo   run index    -idx     - 生成资源索引
echo   run upload   -up      - 上传资源
echo   run download -down   - 下载资源
echo   run help       - 显示此帮助
echo.
exit /b 0