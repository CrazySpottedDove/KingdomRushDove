#!/usr/bin/env bash
set -euo pipefail

# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
    echo "ERROR: zip not found" >&2
    exit 1
fi
if ! command -v rsync >/dev/null 2>&1; then
    echo "ERROR: rsync not found" >&2
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

# 检查 astcenc 是否可用
if ! command -v astcenc >/dev/null 2>&1; then
    echo "ERROR: astcenc not found, required for Android build" >&2
    exit 1
fi

# 安卓包音频压缩（只影响打包产物，不改动仓库源资源）
AUDIO_COMPRESS_MODE="${AUDIO_COMPRESS_MODE:-1}"
if [ "$AUDIO_COMPRESS_MODE" = "1" ]; then
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "ERROR: ffmpeg not found, required for AUDIO_COMPRESS_MODE=1" >&2
        exit 1
    fi
    if ! command -v ffprobe >/dev/null 2>&1; then
        echo "ERROR: ffprobe not found, required for AUDIO_COMPRESS_MODE=1" >&2
        exit 1
    fi
fi

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

# 并行任务数（可通过环境变量 JOBS 调整）
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}

DDS_ASSETS_DIR="./_assets/kr1-desktop/images/fullhd"
mkdir -p ".versions"

# 把 .versions 转化成绝对目录
VERSION_DIR="$(cd .versions && pwd)"

HD_MODE=0
QUICK_MODE=0
NO_UPLOAD_MODE=0
for arg in "$@"; do
    case "$arg" in
        hd) HD_MODE=1 ;;
        quick) QUICK_MODE=1 ;;
        no-upload) NO_UPLOAD_MODE=1 ;; # 保持原有 no-upload 逻辑
    esac
done

if [ "$HD_MODE" -eq 1 ]; then
    ARCHIVE_DIR=".versions/王国保卫战Dove版-v${current_id}-安卓手机端-高清版.zip"
    OUTPUT_FINAL=$VERSION_DIR/王国保卫战Dove版-v${current_id}-安卓手机端-高清版.apk
    CACHE_DIR=".versions/.android_image_cache_hd"
    CACHE_KEY="resize=100%|strip=1|astc=1|tool=$IM_CMD"
    AUDIO_CACHE_DIR=".versions/.android_audio_cache_hd"
else
    ARCHIVE_DIR=".versions/王国保卫战Dove版-v${current_id}-安卓手机端.zip"
    OUTPUT_FINAL=$VERSION_DIR/王国保卫战Dove版-v${current_id}-安卓手机端.apk
    CACHE_DIR=".versions/.android_image_cache"
    CACHE_KEY="resize=50%|strip=1|astc=1|tool=$IM_CMD"
    AUDIO_CACHE_DIR=".versions/.android_audio_cache"
fi

AUDIO_Q_SFX="${AUDIO_Q_SFX:-3}"
AUDIO_Q_BGM="${AUDIO_Q_BGM:-5}"
AUDIO_BGM_MIN_DURATION="${AUDIO_BGM_MIN_DURATION:-25}"
AUDIO_SFX_SKIP_KBPS="${AUDIO_SFX_SKIP_KBPS:-96}"
AUDIO_BGM_SKIP_KBPS="${AUDIO_BGM_SKIP_KBPS:-144}"
AUDIO_CACHE_KEY="cache_dir=$AUDIO_CACHE_DIR|q_sfx=$AUDIO_Q_SFX|q_bgm=$AUDIO_Q_BGM|bgm_min_duration=$AUDIO_BGM_MIN_DURATION|sfx_skip_kbps=$AUDIO_SFX_SKIP_KBPS|bgm_skip_kbps=$AUDIO_BGM_SKIP_KBPS"

CACHE_KEY_FILE="$CACHE_DIR/.cache_key"
LOVE_FILE="../Application/love-android/app/src/embed/assets/game.love"
LOVE_ANDROID="../Application/love-android"
OUTPUT_RAW="app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release.apk"
LOVE_FINGERPRINT_FILE=".versions/.love_input_fingerprint"

mkdir -p "$CACHE_DIR"
if [ ! -f "$CACHE_KEY_FILE" ] || [ "$(cat "$CACHE_KEY_FILE" 2>/dev/null || true)" != "$CACHE_KEY" ]; then
    echo "Cache key changed, rebuilding image cache..."
    rm -rf "$CACHE_DIR"
    mkdir -p "$CACHE_DIR"
    printf "%s" "$CACHE_KEY" > "$CACHE_KEY_FILE"
fi

# .love 输入指纹（增量跳过打包）
calc_love_fingerprint() {
    {
        echo "cache_key=$CACHE_KEY"
        echo "audio_compress=$AUDIO_COMPRESS_MODE|$AUDIO_CACHE_KEY"
        # .love 直接打包的源文件（排除项需与 zip 保持一致）
        find . \
            -path "./.git" -prune -o \
            -path "./.versions" -prune -o \
            -path "./tmp" -prune -o \
            -path "./docs" -prune -o \
            -path "./.plugins" -prune -o \
            -path "./mods/local" -prune -o \
            -path "./.deepseek" -prune -o \
            -type f ! -name "*.dds" ! -name "*.exe" \
            ! -name "client.log" ! -name "client" \
            ! -name "https.dll" ! -name "https.so" \
            ! -name "run.bat" ! -name "launch.bat" \
            ! -name "存档位置.lnk" ! -name "dlfmt" \
            ! -name ".dlfmt_cache.json" ! -name "update.lua" \
            ! -name ".gdb_history" \
            -print0 \
        | sort -z \
        | xargs -0 stat -c 'SRC|%n|%s|%Y'

        # dds 源文件（用于驱动 png 产物变化）
        find "$DDS_ASSETS_DIR" -type f -name "*.dds" -print0 2>/dev/null \
        | sort -z \
        | xargs -0 stat -c 'DDS|%n|%s|%Y' 2>/dev/null || true
    } | sha256sum | awk '{print $1}'
}

new_fingerprint="$(calc_love_fingerprint)"
old_fingerprint="$(cat "$LOVE_FINGERPRINT_FILE" 2>/dev/null || true)"

rebuild_love=1
if [ -f "$LOVE_FILE" ] && [ -n "$old_fingerprint" ] && [ "$new_fingerprint" = "$old_fingerprint" ]; then
    rebuild_love=0
    echo ".love inputs unchanged, skipping .love rebuild."
fi

# 收集待处理 DDS 列表（相对于工作目录）
# mapfile -d '' dds_files < <(find "$DDS_ASSETS_DIR" -type f -name "*.dds" -print0 || printf '')
mapfile -d '' dds_files < <(find "$DDS_ASSETS_DIR" -type f -name "*.dds" -print0 || printf '')

# 更可靠地计算数量
dds_count=${#dds_files[@]}

if [ "$rebuild_love" -eq 1 ]; then
    # 生成 Android 专用渲染排序库，避免与 Linux 同名库混用
    # bash makefiles/build_render_sort_android.sh

    pack_tmp_root=$(mktemp -d)
    trap 'rm -rf "$pack_tmp_root"' EXIT
    stage_dir="$pack_tmp_root/stage"
    mkdir -p "$stage_dir"

    echo "Staging package files -> $stage_dir"

    EXCLUDES=(
        "*.dds"
        ".versions/*"
        "tmp/*"
        "*.exe"
        ".git/*"
        "KingdomRushDoveUpdater"
        "client.log"
        "client"
        "https.dll"
        "https.so"
        "run.bat"
        "launch.bat"
        "存档位置.lnk"
        "dlfmt"
        ".dlfmt_cache.json"
        "update.lua"
        ".gdb_history"
        "docs/*"
        ".plugins/*"
        "all/librender_sort.so"
        "all/librender_sort.dll"
        "love_env/*"
        ".vscode/*"
        "mods/local/*"
        "Makefile"
        "makefiles/*"
        "scripts/*"
        "dlfmt_task.json"
        "README.md"
        "KingdomRushDove版启动器.exe"
        "current_version_commit_hash.txt"
        ".gitignore"
        "游玩必读说明，务必阅读.url"
        "_assets/assets_index.lua"
        "_assets/tmp_download/*"
        "lldebugger.lua"
        "kr1/data/waveconfigs/*"
        "config.json"
        "kr1/data/game_animations.lua"
        "_assets/kr1-desktop/images/fullhd/*.lua"
        "_assets/kr1-desktop/images/fullhd/*.luac"
        "_assets/kr1-desktop/images/fullhd/*.png"
        "precompile/tests/*"
        ".deepseek/*"
        ".opencode/*"
    )
    if [ "$AUDIO_COMPRESS_MODE" = "1" ]; then
        # 音频将由压缩步骤单独写入 staging，避免先拷贝原始 ogg。
        EXCLUDES+=("_assets/kr1-desktop/sounds/files/*.ogg")
    fi
    RSYNC_EXCLUDES=()
    for pattern in "${EXCLUDES[@]}"; do
        RSYNC_EXCLUDES+=("--exclude=$pattern")
    done
    rsync -a --delete "${RSYNC_EXCLUDES[@]}" ./ "$stage_dir"/

    # 分析图像大小，生成缩放映射
    echo "Analyzing image sizes from Lua definitions..."
    RESIZE_MAP_FILE=".versions/.resize_map.txt"
    if ! lua makefiles/analyze_image_sizes.lua; then
        echo "WARNING: Failed to analyze image sizes, using heuristic method"
    fi

    if [ "$dds_count" -eq 0 ]; then
        echo "No DDS files found in $DDS_ASSETS_DIR."
    else
        echo "Processing $dds_count DDS files with $JOBS jobs (incremental cache enabled)..."

        export IM_CMD stage_dir CACHE_DIR RESIZE_MAP_FILE HD_MODE

        # 并行增量处理 DDS -> ASTC
        # 命中缓存：直接拷贝缓存结果；未命中：转换后写入缓存并拷贝
        printf "%s\0" "${dds_files[@]}" | xargs -0 -P "$JOBS" -I {} bash -c '
            should_resize() {
                if [ "$HD_MODE" = "1" ]; then
                    return 1 # 不缩放
                fi
                local filename="$1"
                # 从 resize_map 读取（只用文件名匹配，不含路径）
                local result=$(grep "^${filename}.dds=" "$RESIZE_MAP_FILE" 2>/dev/null | cut -d= -f2)
                [ "$result" = "1" ]
            }

            src="$1"
            rel="${src#./}"
            base_name="${rel%.dds}"
            base_name_only="$(basename "$base_name")"

            cache_file="$CACHE_DIR/${base_name}.astc"
            dest="$stage_dir/${base_name}.astc"

            mkdir -p "$(dirname "$dest")"
            mkdir -p "$(dirname "$cache_file")"

            if [ -f "$cache_file" ] && [ "$cache_file" -nt "$src" ]; then
                cp -f "$cache_file" "$dest"
            else
                temp_png="/tmp/temp_${RANDOM}.png"

                if should_resize "$base_name_only"; then
                    "$IM_CMD" "$src" -resize 50% -strip "png:$temp_png" 2>/dev/null
                else
                    "$IM_CMD" "$src" -strip "png:$temp_png" 2>/dev/null
                fi

                astcenc -cs "$temp_png" "$cache_file" 8x8 -thorough -silent 2>/dev/null
                rm -f "$temp_png"
                cp -f "$cache_file" "$dest"
            fi
        ' _ {}

        # 处理 PNG 文件（直接转 ASTC）
        png_files_count=$(find "$DDS_ASSETS_DIR" -type f -name "*.png" 2>/dev/null | wc -l || echo 0)
        if [ "$png_files_count" -gt 0 ]; then
            echo "Processing $png_files_count PNG files for ASTC conversion..."
            find "$DDS_ASSETS_DIR" -type f -name "*.png" -print0 | xargs -0 -P "$JOBS" -I {} bash -c '
                src="$1"
                rel="${src#./}"
                base_name="${rel%.png}"

                cache_file="$CACHE_DIR/${base_name}.astc"
                dest="$stage_dir/${base_name}.astc"

                mkdir -p "$(dirname "$dest")"
                mkdir -p "$(dirname "$cache_file")"

                if [ -f "$cache_file" ] && [ "$cache_file" -nt "$src" ]; then
                    cp -f "$cache_file" "$dest"
                else
                    astcenc -cs "$src" "$cache_file" 8x8 -thorough -silent 2>/dev/null
                    cp -f "$cache_file" "$dest"
                fi
            ' _ {}
        fi

        dds_stage_root="$stage_dir/${DDS_ASSETS_DIR#./}"
        processed=$(find "$dds_stage_root" -type f -name "*.astc" 2>/dev/null | wc -l || echo 0)
        astc_count="$processed"
        printf "[IMAGE] %d/%d processed (ASTC: %d, PNG: %d).\n" "$processed" "$dds_count" "$astc_count" "$((processed - astc_count))"
    fi

    # 压缩字体文件
    echo "Minifying fonts for Android..."
    if bash makefiles/minify_font.sh; then
        echo "Replacing fonts in staging with minified versions..."
        mkdir -p "$stage_dir/_assets/all-desktop/fonts"
        cp tmp/msyh_minify.ttc "$stage_dir/_assets/all-desktop/fonts/msyh.ttc"
        cp tmp/msyhbd_minify.ttc "$stage_dir/_assets/all-desktop/fonts/msyhbd.ttc"
        cp tmp/JIMOJW_minify.ttf "$stage_dir/_assets/all-desktop/fonts/JIMOJW.ttf"
    else
        echo "WARNING: Font minification failed, using original fonts"
    fi

    if [ "$AUDIO_COMPRESS_MODE" = "1" ]; then
        echo "Optimizing OGG audio for Android package..."
        audio_tmpdir="$pack_tmp_root/audio"
        mkdir -p "$audio_tmpdir"
        AUDIO_CACHE_DIR="$AUDIO_CACHE_DIR" \
        AUDIO_Q_SFX="$AUDIO_Q_SFX" \
        AUDIO_Q_BGM="$AUDIO_Q_BGM" \
        AUDIO_BGM_MIN_DURATION="$AUDIO_BGM_MIN_DURATION" \
        AUDIO_SFX_SKIP_KBPS="$AUDIO_SFX_SKIP_KBPS" \
        AUDIO_BGM_SKIP_KBPS="$AUDIO_BGM_SKIP_KBPS" \
        bash makefiles/process_android_audio.sh "$audio_tmpdir" "./_assets/kr1-desktop/sounds/files"
        mkdir -p "$stage_dir/_assets/kr1-desktop/sounds/files"
        rsync -a "$audio_tmpdir/_assets/kr1-desktop/sounds/files/" "$stage_dir/_assets/kr1-desktop/sounds/files/"
    else
        echo "Skipping Android audio optimization (AUDIO_COMPRESS_MODE=0)."
    fi

    echo "Creating final archive -> $ARCHIVE_DIR"
    rm -f "$ARCHIVE_DIR"
    # 仅打包文件，避免把 staging 里的空目录写入 zip。
    (
        cd "$stage_dir"
        find . -type f | LC_ALL=C sort | zip -X "$OLDPWD/$ARCHIVE_DIR" -@ -q
    )

    # 生成 .love 文件（复制以保留 zip 备份）
    mv "$ARCHIVE_DIR" "$LOVE_FILE"
    printf "%s" "$new_fingerprint" > "$LOVE_FINGERPRINT_FILE"
    echo "Packed -> $LOVE_FILE"
else
    echo "Reusing existing .love -> $LOVE_FILE"
fi

cd $LOVE_ANDROID

./gradlew assembleEmbedNoRecordRelease

mv "$OUTPUT_RAW" "$OUTPUT_FINAL"

if [ "$NO_UPLOAD_MODE" = "1" ]; then
    echo "Build complete, skipping upload as per argument."
    exit 0
fi

# 如果传入了参数 quick，则使用内网 scp 传输
if [ "$QUICK_MODE" = "1" ]; then
    scp -P 60001 "$OUTPUT_FINAL" dove@10.112.99.5:/srv/files/王国保卫战Dove版-安卓端/
else
    scp -P 60001 "$OUTPUT_FINAL" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-安卓端/
fi
