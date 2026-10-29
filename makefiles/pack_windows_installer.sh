#!/usr/bin/bash
set -euo pipefail

VERSION_FILE="./version.lua"
PACKAGE_BRANCH="${PACKAGE_BRANCH:-master}"
PACKAGE_TAG="${PACKAGE_TAG:-}"
case "$PACKAGE_BRANCH" in
    master|dev) ;;
    *) echo "ERROR: PACKAGE_BRANCH 只能是 master 或 dev" >&2; exit 1 ;;
esac
if [ "$PACKAGE_BRANCH" = "dev" ]; then
    NAME_SUFFIX=" Dev"
else
    NAME_SUFFIX=""
fi
if [ -n "${VERSION_FILE:-}" ] && [ -f "$VERSION_FILE" ]; then
    current_id=$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")
    current_id=${current_id:-$(date +%s)}
else
    current_id=$(date +%s)
fi

echo "Current version id: $current_id"

mkdir -p ".versions"
INSTALLER_FILE=".versions/王国保卫战Dove版-v${current_id}${PACKAGE_TAG}-Windows电脑端-安装程序.exe"
TOPDIR="王国保卫战Dove版-Windows电脑端-v${current_id}${PACKAGE_TAG}"
GAME_7Z="game-v${current_id}${PACKAGE_TAG}.7z"
INSTALL_DIR_NAME="王国保卫战Dove版${PACKAGE_TAG}"
SHORTCUT_NAME="王国保卫战 Dove 版${NAME_SUFFIX}"
REG_KEY="Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版${PACKAGE_TAG}"

QUICK_MODE=0
NO_UPLOAD_MODE=0
for arg in "$@"; do
    case "$arg" in
        quick) QUICK_MODE=1 ;;
        no-upload) NO_UPLOAD_MODE=1 ;;
    esac
done

# 打包新版本前，删除 .versions 下旧版本的 Windows 安装程序，保留当前版本
source makefiles/cleanup_old_versions.sh
cleanup_old_packages "$current_id" ".versions/王国保卫战Dove版-v*Windows电脑端-安装程序.exe"

if ! command -v makensis >/dev/null 2>&1; then
    echo "ERROR: makensis not found, please install NSIS first" >&2
    exit 1
fi
if ! command -v rsync >/dev/null 2>&1; then
    echo "ERROR: rsync not found" >&2
    exit 1
fi
if ! command -v 7z >/dev/null 2>&1; then
    echo "ERROR: 7z not found, please install 7zip first" >&2
    exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl not found" >&2
    exit 1
fi
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    echo "ERROR: ImageMagick (magick/convert) not found" >&2
    exit 1
fi

STAGE_DIR=".versions/_pack_tmp_${current_id}"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

if [ ! -d "./love_env" ]; then
    echo "ERROR: ./love_env not found" >&2
    exit 1
fi

if cp -a ./love_env "$STAGE_DIR/$TOPDIR" 2>/dev/null; then
    :
else
    cp -r ./love_env "$STAGE_DIR/$TOPDIR"
fi

DEST_DIR="$STAGE_DIR/$TOPDIR/KingdomRushDove"
mkdir -p "$DEST_DIR"

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

COMMIT_HASH="$(git rev-parse --verify --quiet "$PACKAGE_BRANCH")"
if [ -z "$COMMIT_HASH" ]; then
    echo "ERROR: 本地没有 $PACKAGE_BRANCH 分支，无法写入 current_version_commit_hash.txt" >&2
    exit 1
fi
printf '%s\n' "$COMMIT_HASH" > "$DEST_DIR/current_version_commit_hash.txt"
cat > "$DEST_DIR/build_info.lua" <<EOF
return {
    branch = "$PACKAGE_BRANCH",
}
EOF
if [ "$PACKAGE_BRANCH" = "dev" ]; then
    echo "WARN: dev 安装包记录的是本地 dev commit；请确认该 commit 已推送到服务器 dev" >&2
fi

# Download Windows 7za.exe if not cached
SZ7ZA_EXE=".versions/7za.exe"
if [ ! -f "$SZ7ZA_EXE" ]; then
    echo "Downloading 7za.exe (Windows extractor)..."
    curl -sL -o /tmp/7z_extra.7z "https://www.7-zip.org/a/7z2601-extra.7z"
    mkdir -p /tmp/7z_extra_tmp
    rm -rf /tmp/7z_extra_tmp/*
    7z x /tmp/7z_extra.7z -o/tmp/7z_extra_tmp -y "x64/7za.exe" >/dev/null
    mv /tmp/7z_extra_tmp/x64/7za.exe "$SZ7ZA_EXE"
    rm -rf /tmp/7z_extra.7z /tmp/7z_extra_tmp
    echo "7za.exe cached to $SZ7ZA_EXE"
fi

# Create 7z archive (multi-threaded LZMA2, fast mode)
echo "Creating game archive with 7z (multi-threaded)..."
GAME_7Z_ABS="$(cd "$STAGE_DIR" && pwd)/$GAME_7Z"
(
    cd "$STAGE_DIR/$TOPDIR"
    7z a -mx5 -mmt=on -t7z "$GAME_7Z_ABS" . >/dev/null
)
SZ7Z_SIZE=$(du -h "$GAME_7Z_ABS" | cut -f1)
echo "Archive created: $GAME_7Z_ABS ($SZ7Z_SIZE)"

# Copy 7za.exe to stage dir for NSIS packaging
cp "$SZ7ZA_EXE" "$STAGE_DIR/7za.exe"

# Determine icon path
ICON_SRC="./_assets/kr1-desktop/icons/krdove.png"
ICON_FILE=""
if [ -f "$ICON_SRC" ]; then
    ICON_FILE="$STAGE_DIR/$TOPDIR/krdove.ico"
    if command -v magick >/dev/null 2>&1; then
        magick "$ICON_SRC" -define icon:auto-resize=256,128,64,48,32,16 "$ICON_FILE"
    else
        convert "$ICON_SRC" -define icon:auto-resize=256,128,64,48,32,16 "$ICON_FILE"
    fi
elif [ -f "$STAGE_DIR/$TOPDIR/game.ico" ]; then
    ICON_FILE="$STAGE_DIR/$TOPDIR/game.ico"
elif [ -f "$STAGE_DIR/$TOPDIR/love.ico" ]; then
    ICON_FILE="$STAGE_DIR/$TOPDIR/love.ico"
else
    echo "ERROR: no installer icon source found" >&2
    exit 1
fi
ICON_NSIS="${TOPDIR}/$(basename "$ICON_FILE")"

# Generate NSIS script
NSI_FILE="$STAGE_DIR/installer.nsi"
cat > "$NSI_FILE" << NSISEOL
!include "MUI2.nsh"

Name "王国保卫战 Dove 版"
OutFile "..\\$(basename "$INSTALLER_FILE")"
InstallDir "\$LOCALAPPDATA\\${INSTALL_DIR_NAME}"
InstallDirRegKey HKCU "${REG_KEY}" "UninstallString"
RequestExecutionLevel user

SetCompressor zlib

!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "你确定要退出安装吗？"
!define MUI_ICON "${ICON_NSIS}"
!define MUI_UNICON "${ICON_NSIS}"
!define MUI_WELCOMEPAGE_TITLE "欢迎安装 ${SHORTCUT_NAME}"
!define MUI_WELCOMEPAGE_TEXT "本安装向导将引导您完成安装过程。$\r$\n$\r$\n点击「下一步」继续。$\r$\n$\r$\n注意：本游戏为免费改版，一切售卖本游戏的行为均属侵权。"
!define MUI_FINISHPAGE_TITLE "安装完成"
!define MUI_FINISHPAGE_TEXT "${SHORTCUT_NAME} 已成功安装！$\r$\n$\r$\n点击「完成」退出安装向导。"

!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "安装进行中"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "请稍候，正在复制文件..."

Caption "${SHORTCUT_NAME} 安装程序"
VIProductVersion "${current_id}"
VIAddVersionKey "ProductName" "${SHORTCUT_NAME}"
VIAddVersionKey "FileDescription" "${SHORTCUT_NAME} 安装程序"
VIAddVersionKey "FileVersion" "${current_id}"
VIAddVersionKey "LegalCopyright" "Modified version based on Kingdom Rush, Copyright Ironhide Game Studio. KingdomRushDove mod by CrazySpottedDove."
BrandingText "https://github.com/CrazySpottedDove/KingdomRushDove"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"

Section "Install"
  SetOutPath "\$INSTDIR"
  File "$GAME_7Z"
  File "7za.exe"

  DetailPrint "正在解压游戏文件，请耐心等待..."
  nsExec::Exec '"\$INSTDIR\\7za.exe" x "\$INSTDIR\\$GAME_7Z" -o"\$INSTDIR" -y -bso0 -bsp0'
  Pop \$0

  Delete "\$INSTDIR\\$GAME_7Z"
  Delete "\$INSTDIR\\7za.exe"

  SetOutPath "\$INSTDIR\\KingdomRushDove"
  CreateDirectory "\$SMPROGRAMS\\${SHORTCUT_NAME}"
  DetailPrint "正在创建桌面快捷方式..."
  CreateShortCut "\$DESKTOP\\${SHORTCUT_NAME}.lnk" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"
  DetailPrint "正在创建开始菜单快捷方式..."
  CreateShortCut "\$SMPROGRAMS\\${SHORTCUT_NAME}\\${SHORTCUT_NAME}.lnk" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"

  WriteUninstaller "\$INSTDIR\\uninstall.exe"

  WriteRegStr HKCU "${REG_KEY}" "DisplayName" "${SHORTCUT_NAME}"
  WriteRegStr HKCU "${REG_KEY}" "UninstallString" "\$INSTDIR\\uninstall.exe"
  WriteRegStr HKCU "${REG_KEY}" "DisplayIcon" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"
  WriteRegStr HKCU "${REG_KEY}" "Publisher" "Dove"
  WriteRegDWORD HKCU "${REG_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${REG_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "\$DESKTOP\\${SHORTCUT_NAME}.lnk"
  RMDir /r "\$SMPROGRAMS\\${SHORTCUT_NAME}"
  RMDir /r "\$INSTDIR"
  DeleteRegKey HKCU "${REG_KEY}"
SectionEnd
NSISEOL

echo "Compiling installer..."
(cd "$STAGE_DIR" && makensis installer.nsi)

if [ -f "$INSTALLER_FILE" ]; then
    INSTALLER_SIZE=$(du -h "$INSTALLER_FILE" | cut -f1)
    echo "Installer created -> $INSTALLER_FILE ($INSTALLER_SIZE)"
else
    echo "ERROR: Installer not created" >&2
    exit 1
fi

# Cleanup
rm -rf "$STAGE_DIR"

if [ "$NO_UPLOAD_MODE" = "1" ]; then
    echo "Build complete, skipping upload as per argument."
    exit 0
fi

# if [ "$QUICK_MODE" = "1" ]; then
#     scp -P 60001 "$INSTALLER_FILE" dove@10.112.99.5:/srv/files/王国保卫战Dove版-Windows端/
# else
#     scp -P 60001 "$INSTALLER_FILE" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-Windows端/
# fi
