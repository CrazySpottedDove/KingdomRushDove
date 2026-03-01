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
ARCHIVE_DIR=".versions/KingdomRushDove-Windows-v${current_id}.zip"
TOPDIR="$(basename "$ARCHIVE_DIR" .zip)"  # love_env 改名为这个
# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
    echo "ERROR: zip not found" >&2
    exit 1
fi

# 临时打包目录（舞台目录）
STAGE_DIR=".versions/_pack_tmp_${current_id}"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 复制 love_env 到舞台根目录
if [ ! -d "./love_env" ]; then
    echo "ERROR: ./love_env not found" >&2
    exit 1
fi

# 将 love_env 复制并改名为 TOPDIR
if cp -a ./love_env "$STAGE_DIR/$TOPDIR" 2>/dev/null; then
    :
else
    cp -r ./love_env "$STAGE_DIR/$TOPDIR"
fi

# 将项目内容复制到 love_env/KingdomRushDove 目录
DEST_DIR="$STAGE_DIR/$TOPDIR/KingdomRushDove"
mkdir -p "$DEST_DIR"

# 需要排除的顶层路径/文件
EXCLUDES=(
    ".versions"
    ".git"
    "tmp"
    "love_env"
    "KingdomRushDoveUpdater"
    "client.log"
    "update.lua"
    "dlfmt"
    ".dlfmt_cache.json"
    "client"
    "client.exe"
    ".gdb_history"
    "https.so"
    "all/librender_sort.so"
    "mods/local"
)

should_exclude() {
    local name="$1"
    for ex in "${EXCLUDES[@]}"; do
        if [[ "$name" == "$ex" ]] || [[ "$name" == "$ex/"* ]]; then
            return 0
        fi
    done
    return 1
}

# 复制项目根目录下的文件与文件夹到 DEST_DIR（应用排除）
shopt -s dotglob nullglob
for entry in * .*; do
    # 跳过当前/父目录伪项
    [ "$entry" = "." ] && continue
    [ "$entry" = ".." ] && continue
    # 确保存在
    [ -e "$entry" ] || continue
    # 应用排除规则
    if should_exclude "$entry"; then
        continue
    fi
    # 复制
    if cp -a "$entry" "$DEST_DIR/" 2>/dev/null; then
        :
    else
        cp -r "$entry" "$DEST_DIR/"
    fi
done
shopt -u dotglob nullglob

echo "Creating archive -> $ARCHIVE_DIR"
(
    cd "$STAGE_DIR"
    # 打包改名后的目录 TOPDIR，这样解压后顶层就是 KingdomRushDove-Windows-v9.1.6
    zip -r "../$(basename "$ARCHIVE_DIR")" "$TOPDIR" -q
)

# 移回到 .versions 下的最终 zip（cd 子shell里已写到 .versions）
# 确保归档位于 ARCHIVE_DIR（相对路径已经正确）
# 清理临时目录
rm -rf "$STAGE_DIR"

echo "Packed -> $ARCHIVE_DIR"

# 如果传入了参数 quick，则使用内网 scp 传输
if [ "${1:-}" = "quick" ]; then
    scp -P 60001 "$ARCHIVE_DIR" dove@10.112.99.5:/srv/files/王国保卫战Dove版-Windows端/
else
    scp -P 60001 "$ARCHIVE_DIR" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-Windows端/
fi
