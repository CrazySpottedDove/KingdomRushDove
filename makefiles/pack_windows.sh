#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="./version.lua"
PACKAGE_BRANCH="${PACKAGE_BRANCH:-master}"
PACKAGE_TAG="${PACKAGE_TAG:-}"
case "$PACKAGE_BRANCH" in
    master|dev) ;;
    *) echo "ERROR: PACKAGE_BRANCH 只能是 master 或 dev" >&2; exit 1 ;;
esac
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
ARCHIVE_DIR=".versions/王国保卫战Dove版-v${current_id}${PACKAGE_TAG}-Windows电脑端.zip"
TOPDIR="$(basename "$ARCHIVE_DIR" .zip)"  # love_env 改名为这个

QUICK_MODE=0
NO_UPLOAD_MODE=0
for arg in "$@"; do
    case "$arg" in
        quick) QUICK_MODE=1 ;;
        no-upload) NO_UPLOAD_MODE=1 ;;
    esac
done

# 打包新版本前，删除 .versions 下旧版本的 Windows 包，保留当前版本
source makefiles/cleanup_old_versions.sh
cleanup_old_packages "$current_id" ".versions/王国保卫战Dove版-v*Windows电脑端*.zip"

# 依赖检查
if ! command -v 7z >/dev/null 2>&1; then
    echo "ERROR: 7z not found" >&2
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

# 复制项目根目录到 DEST_DIR（自动从 .gitignore 生成排除列表）
source makefiles/_excludes.sh
GITIGNORE_ALLOW=(
    "_assets/all-desktop/cursors"
    "_assets/all-desktop/fonts"
    "_assets/kr1-desktop/icons"
    "_assets/kr1-desktop/images/fullhd/*.png"
    "_assets/kr1-desktop/images/fullhd/*.dds"
    "_assets/kr1-desktop/sounds/files"
    "_assets/kr1-desktop/strings/de.lua"
    "_assets/kr1-desktop/strings/en.lua"
    "_assets/kr1-desktop/strings/es.lua"
    "_assets/kr1-desktop/strings/fr.lua"
    "_assets/kr1-desktop/strings/it.lua"
    "_assets/kr1-desktop/strings/ja.lua"
    "_assets/kr1-desktop/strings/ko.lua"
    "_assets/kr1-desktop/strings/pt.lua"
    "_assets/kr1-desktop/strings/ru.lua"
    "_assets/kr1-desktop/strings/zh-Hant.lua"
    "KingdomRushDove版启动器*"
)
MANUAL_EXCLUDES=(
    "https.so"
    "all/librender_sort.so"
)
EXCLUDE_ARGS=()
while IFS= read -r arg; do
    EXCLUDE_ARGS+=("$arg")
done < <(gitignore_excludes)
rsync -a "${EXCLUDE_ARGS[@]}" ./ "$DEST_DIR/"

# 构建标签必须写在发布产物里，而不是被 master 投影带回 dev 源码
COMMIT_HASH="$(git rev-parse --verify --quiet "$PACKAGE_BRANCH")"
if [ -z "$COMMIT_HASH" ]; then
    echo "ERROR: 本地没有 $PACKAGE_BRANCH 分支，无法写入 current_version_commit_hash.txt" >&2
    exit 1
fi
printf '%s\n' "$COMMIT_HASH" > "$DEST_DIR/current_version_commit_hash.txt"
cat > "$DEST_DIR/build_info.lua" <<EOF
return {
    branch = "$PACKAGE_BRANCH"
}
EOF
if [ "$PACKAGE_BRANCH" = "dev" ]; then
    echo "WARN: dev 包记录的是本地 dev commit；请确认该 commit 已推送到服务器 dev" >&2
fi

echo "Creating archive -> $ARCHIVE_DIR"
(
    cd "$STAGE_DIR"
    # 打包改名后的目录 TOPDIR，这样解压后顶层就是 KingdomRushDove-Windows-v9.1.6
    7z a -tzip -mx9 -mmt=on "../$(basename "$ARCHIVE_DIR")" "$TOPDIR" >/dev/null
)

# 移回到 .versions 下的最终 zip（cd 子shell里已写到 .versions）
# 确保归档位于 ARCHIVE_DIR（相对路径已经正确）
# 清理临时目录
rm -rf "$STAGE_DIR"

echo "Packed -> $ARCHIVE_DIR"

if [ "$NO_UPLOAD_MODE" = "1" ]; then
    echo "Build complete, skipping upload as per argument."
    exit 0
fi

# 如果传入了参数 quick，则使用内网 scp 传输
# if [ "$QUICK_MODE" = "1" ]; then
#     scp -P 60001 "$ARCHIVE_DIR" dove@10.112.99.5:/srv/files/王国保卫战Dove版-Windows端/
# else
#     scp -P 60001 "$ARCHIVE_DIR" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-Windows端/
# fi
