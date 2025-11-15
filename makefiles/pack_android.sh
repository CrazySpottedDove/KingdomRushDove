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

PNGQUANT_CMD=""
if command -v pngquant >/dev/null 2>&1; then
    PNGQUANT_CMD="pngquant"
fi

# 并行任务数（可通过环境变量 JOBS 调整）
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}

echo "Creating base archive (excluding PNGs) -> $ARCHIVE_DIR"
# 先打包项目中除 png 和 .versions 的文件（避免把 archive 自己打进去）
zip -r "$ARCHIVE_DIR" . -x "*.png" -x ".versions/*" -x "tmp/*" -x "*.exe" -x ".git/*" -x "KingdomRushDoveUpdater" -q

# 创建临时目录用于放置缩放后的 png，保留相对路径
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT

# 收集待处理 PNG 列表（相对于工作目录）
mapfile -d '' png_files < <(find ./_assets -type f -name "*.png" -print0 || printf '')

# 更可靠地计算数量（避免复杂的参数替换导致的兼容性问题）
png_count=$(find ./_assets -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
png_count=${png_count:-0}

if [ "$png_count" -eq 0 ]; then
    echo "No PNG files found in ./_assets"
else
    echo "Processing $png_count PNG files with $JOBS jobs (ImageMagick: $IM_CMD)..."

    # 导出环境变量，供子 shell 使用
    export IM_CMD PNGQUANT_CMD tempdir

    # 使用 xargs 并行处理，每个任务在独立 shell 中完成
    printf "%s\0" "${png_files[@]}" | xargs -0 -P "$JOBS" -I {} bash -c '
        src="{}"
        # 去掉前导 ./ （若存在）
        rel="${src#./}"
        dest="$tempdir/$rel"
        mkdir -p "$(dirname "$dest")"
        # 使用 ImageMagick 缩小并 strip 元数据
        "$IM_CMD" "$src" -resize 50% -strip "$dest"
    '

    # 实时进度监控（直到临时目录的 png 数量达到总数或超时）
    processed=0
    start_ts=$(date +%s)
    while :; do
        processed=$(find "$tempdir" -type f -name "*.png" 2>/dev/null | wc -l || echo 0)
        printf "\r[PNG] %d/%d processed..." "$processed" "$png_count"
        if [ "$processed" -ge "$png_count" ]; then
            break
        fi
        # 超时保护：如果超过 30 分钟则退出循环（避免死等）
        now_ts=$(date +%s)
        if [ $((now_ts - start_ts)) -gt 1800 ]; then
            echo
            echo "Warning: PNG processing timeout" >&2
            break
        fi
        sleep 0.5
    done
    echo

    # 确认所有文件已生成
    processed=$(find "$tempdir" -type f -name "*.png" 2>/dev/null | wc -l || echo 0)
    printf "[PNG] %d/%d processed.\n" "$processed" "$png_count"
fi

# 把处理好的图片按相对路径追加到已有 zip 中（若 tempdir 有内容）
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

# echo "Packed -> $ARCHIVE_DIR"
# echo "Also copied to -> $LOVE_FILE"