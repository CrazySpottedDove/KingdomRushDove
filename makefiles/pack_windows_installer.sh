#!/usr/bin/bash
set -euo pipefail

VERSION_FILE="./version.lua"
if [ -n "${VERSION_FILE:-}" ] && [ -f "$VERSION_FILE" ]; then
    current_id=$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")
    current_id=${current_id:-$(date +%s)}
else
    current_id=$(date +%s)
fi

echo "Current version id: $current_id"

mkdir -p ".versions"
INSTALLER_FILE=".versions/王国保卫战Dove版-v${current_id}-Windows电脑端-安装程序.exe"
TOPDIR="王国保卫战Dove版-Windows电脑端-v${current_id}"
GAME_7Z="game-v${current_id}.7z"

QUICK_MODE=0
NO_UPLOAD_MODE=0
for arg in "$@"; do
    case "$arg" in
        quick) QUICK_MODE=1 ;;
        no-upload) NO_UPLOAD_MODE=1 ;;
    esac
done

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
InstallDir "\$LOCALAPPDATA\\王国保卫战Dove版"
InstallDirRegKey HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "UninstallString"
RequestExecutionLevel user

SetCompressor zlib

!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "你确定要退出安装吗？"
!define MUI_ICON "${ICON_NSIS}"
!define MUI_UNICON "${ICON_NSIS}"
!define MUI_WELCOMEPAGE_TITLE "欢迎安装 王国保卫战 Dove 版"
!define MUI_WELCOMEPAGE_TEXT "本安装向导将引导您完成安装过程。$\r$\n$\r$\n点击「下一步」继续。$\r$\n$\r$\n注意：本游戏为免费改版，一切售卖本游戏的行为均属侵权。"
!define MUI_FINISHPAGE_TITLE "安装完成"
!define MUI_FINISHPAGE_TEXT "王国保卫战 Dove 版已成功安装！$\r$\n$\r$\n点击「完成」退出安装向导。"

!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "安装进行中"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "请稍候，正在复制文件..."

Caption "王国保卫战 Dove 版 安装程序"
VIProductVersion "${current_id}"
VIAddVersionKey "ProductName" "王国保卫战 Dove 版"
VIAddVersionKey "FileDescription" "王国保卫战 Dove 版 安装程序"
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
  CreateDirectory "\$SMPROGRAMS\\王国保卫战 Dove 版"
  DetailPrint "正在创建桌面快捷方式..."
  CreateShortCut "\$DESKTOP\\王国保卫战 Dove 版.lnk" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"
  DetailPrint "正在创建开始菜单快捷方式..."
  CreateShortCut "\$SMPROGRAMS\\王国保卫战 Dove 版\\王国保卫战 Dove 版.lnk" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"

  WriteUninstaller "\$INSTDIR\\uninstall.exe"

  WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "DisplayName" "王国保卫战 Dove 版"
  WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "UninstallString" "\$INSTDIR\\uninstall.exe"
  WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "DisplayIcon" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"
  WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "Publisher" "Dove"
  WriteRegDWORD HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "NoModify" 1
  WriteRegDWORD HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "\$DESKTOP\\王国保卫战 Dove 版.lnk"
  RMDir /r "\$SMPROGRAMS\\王国保卫战 Dove 版"
  RMDir /r "\$INSTDIR"
  DeleteRegKey HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版"
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
