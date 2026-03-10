#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="./version.lua"
# 可通过 VERSION_FILE 环境变量指定版本文件（可选）
# VERSION_FILE=${VERSION_FILE:-}

if [ -n "${VERSION_FILE:-}" ] && [ -f "$VERSION_FILE" ]; then
    # 仅匹配行首的 `id = "..."`，避免匹配到 bundle_id
    current_id=$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")
    current_id=${current_id:-$(date +%s)}
else
    current_id=$(date +%s)
fi

echo "Current version id: $current_id"

mkdir -p ".versions"
ARCHIVE_DIR=".versions/KingdomRushDove-Linux-v${current_id}.zip"
TOPDIR="$(basename "$ARCHIVE_DIR" .zip)"  # love_env 改名为这个
# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
    echo "ERROR: zip not found" >&2
    exit 1
fi
if ! command -v rsync >/dev/null 2>&1; then
    echo "ERROR: rsync not found" >&2
    exit 1
fi

# 临时打包目录（舞台目录）
STAGE_DIR=".versions/_pack_tmp_${current_id}"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 将项目内容复制到 love_env/KingdomRushDove 目录
DEST_DIR="$STAGE_DIR/$TOPDIR/KingdomRushDove"
mkdir -p "$DEST_DIR"

# 复制项目根目录到 DEST_DIR（应用排除）
rsync -a \
    --exclude='.versions/' \
    --exclude='.git/' \
    --exclude='tmp/' \
    --exclude='love_env/' \
    --exclude='KingdomRushDoveUpdater' \
    --exclude='client.log' \
    --exclude='update.lua' \
    --exclude='dlfmt' \
    --exclude='.dlfmt_cache.json' \
    --exclude='client' \
    --exclude='client.exe' \
    --exclude='.gdb_history' \
    --exclude='https.dll' \
    --exclude='KingdomRushDove版启动器.exe' \
    --exclude='run.bat' \
    --exclude='launch.bat' \
    --exclude='存档位置.lnk' \
    --exclude='all/librender_sort.dll' \
    --exclude='mods/local/' \
    --exclude='.plugins/' \
    ./ "$DEST_DIR/"

echo "Creating archive -> $ARCHIVE_DIR"
(
    cd "$STAGE_DIR"
    zip -r "../$(basename "$ARCHIVE_DIR")" "$TOPDIR" -q
)

# 移回到 .versions 下的最终 zip（cd 子shell里已写到 .versions）
# 确保归档位于 ARCHIVE_DIR（相对路径已经正确）
# 清理临时目录
rm -rf "$STAGE_DIR"

echo "Packed -> $ARCHIVE_DIR"

# 如果传入了参数 quick，则使用内网 scp 传输
if [ "${1:-}" = "quick" ]; then
    scp -P 60001 "$ARCHIVE_DIR" dove@10.112.99.5:/srv/files/王国保卫战Dove版-Linux端/
else
    scp -P 60001 "$ARCHIVE_DIR" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-Linux端/
fi