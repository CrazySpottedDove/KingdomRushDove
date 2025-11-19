#!/bin/bash
#!/usr/bin/env bash
set -euo pipefail
VERSION_FILE="./version.lua"
# 可通过 VERSION_FILE 环境变量指定版本文件（可选）
# VERSION_FILE=${VERSION_FILE:-}
if [ -n "$VERSION_FILE" ] && [ -f "$VERSION_FILE" ]; then
    current_id=$(awk -F'"' '/version\.id[ ]*=/ {print $2; exit}' "$VERSION_FILE")
    current_id=${current_id:-$(date +%s)}
else
    current_id=$(date +%s)
fi

mkdir -p ".versions"
ARCHIVE_DIR=".versions/KingdomRushDove-Windows-v${current_id}.zip"

# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
    echo "ERROR: zip not found" >&2
    exit 1
fi

echo "Creating archive-> $ARCHIVE_DIR"
# 先打包项目中除 png 和 .versions 的文件（避免把 archive 自己打进去）
zip -r "$ARCHIVE_DIR" . -x ".versions/*" -x "tmp/*" -x ".git/*" -x "KingdomRushDoveUpdater" -x "client.log" -x "update.lua" -q

# echo "Packed -> $ARCHIVE_DIR"
# echo "Also copied to -> $LOVE_FILE"
# scp -P 60001 "$LOVE_FILE" root@10.112.99.5:/srv/files/王国保卫战Dove版-Windows端/