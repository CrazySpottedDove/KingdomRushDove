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

mkdir -p ".versions"
ARCHIVE_DIR=".versions/KingdomRushDove-Android-v${current_id}.zip"
LOVE_FILE=".versions/KingdomRushDove-Android-v${current_id}.love"

# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
    echo "ERROR: zip not found" >&2
    exit 1
fi

# 选择 ImageMagick 命令：优先 magick，再用 convert
if command -v magick >/dev/null 2>&1; then
    IM_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
    IM_CMD="convert"
else
    echo "ERROR: ImageMagick (magick/convert) not found" >&2
    exit 1
fi

# 并行任务数（可通过环境变量 JOBS 调整）
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}

echo "Creating base archive (excluding PNGs) -> $ARCHIVE_DIR"
# 先打包项目中除 png 和 .versions 的文件（避免把 archive 自己打进去）
zip -r "$ARCHIVE_DIR" . -x "*.dds" -x ".versions/*" -x "tmp/*" -x "*.exe" -x ".git/*" -x "KingdomRushDoveUpdater" -x "client.log" -x "client" -x "https.dll" -x "https.so" -x "run.bat" -x "launch.bat" -x "存档位置.lnk" -x "dlfmt" -x ".dlfmt_cache.json" -x "update.lua" -x ".gdb_history" -x "aidoc/*" -x ".plugins/*" -x "mods/local/*" -q

# 创建临时目录用于放置缩放后的 png，保留相对路径
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT
DDS_ASSETS_DIR="./_assets/kr1-desktop/images/fullhd"

# 收集待处理 DDS 列表（相对于工作目录）
mapfile -d '' dds_files < <(find $DDS_ASSETS_DIR -type f -name "*.dds" -print0 || printf '')

# 更可靠地计算数量
dds_count=${#dds_files[@]}

if [ "$dds_count" -eq 0 ]; then
    echo "No DDS files found in $DDS_ASSETS_DIR."
else
    echo "Processing $dds_count DDS files with $JOBS jobs (ImageMagick: $IM_CMD)..."

    export IM_CMD tempdir

    # 并行处理 DDS -> PNG（缩小一半）
    printf "%s\0" "${dds_files[@]}" | xargs -0 -P "$JOBS" -I {} bash -c '
        src="{}"
        rel="${src#./}"
        dest="$tempdir/${rel%.dds}.png"
        mkdir -p "$(dirname "$dest")"
        # 用 ImageMagick 转换并缩小一半
        "$IM_CMD" "$src" -resize 50% -strip "$dest"
    '

    processed=$(find "$tempdir" -type f -name "*.png" 2>/dev/null | wc -l || echo 0)
    printf "[PNG] %d/%d processed.\n" "$processed" "$dds_count"
fi

# 把处理好的 PNG 按相对路径追加到已有 zip 中
if [ -d "$tempdir" ] && [ "$(find "$tempdir" -type f | wc -l)" -gt 0 ]; then
    echo "Appending processed PNGs to archive..."
    pushd "$tempdir" >/dev/null
    zip -r "$OLDPWD/$ARCHIVE_DIR" . -q
    popd >/dev/null
else
    echo "No processed PNGs to append."
fi

# 生成 .love 文件（复制以保留 zip 备份）
mv "$ARCHIVE_DIR" "$LOVE_FILE"

echo "Packed -> $LOVE_FILE"

# 如果传入了参数 quick，则使用内网 scp 传输
if [ "${1:-}" = "quick" ]; then
    scp -P 60001 "$LOVE_FILE" dove@10.112.99.5:/srv/files/王国保卫战Dove版-安卓端/
else
    scp -P 60001 "$LOVE_FILE" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-安卓端/
fi