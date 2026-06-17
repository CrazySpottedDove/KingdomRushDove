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
    --exclude='https.so' \
    --exclude='all/librender_sort.so' \
    --exclude='*.aluac' \
    --exclude='mods/local/' \
    --exclude='.plugins/' \
    --exclude='config.json' \
    --exclude='.deepseek/' \
    --exclude='.opencode' \
    ./ "$DEST_DIR/"

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
ICON_FILE="$STAGE_DIR/$TOPDIR/game.ico"
[ -f "$ICON_FILE" ] || ICON_FILE="$STAGE_DIR/$TOPDIR/love.ico"
ICON_NSIS="${TOPDIR}/$(basename "$ICON_FILE")"

# Generate NSIS script
NSI_FILE="$STAGE_DIR/installer.nsi"
cat > "$NSI_FILE" << NSISEOL
!include "MUI2.nsh"

Name "王国保卫战 Dove 版"
OutFile "..\\$(basename "$INSTALLER_FILE")"
InstallDir "\$PROGRAMFILES64\\王国保卫战Dove版"
InstallDirRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "UninstallString"
RequestExecutionLevel admin

SetCompressor zlib

!define MUI_ABORTWARNING
!define MUI_ICON "${ICON_NSIS}"
!define MUI_UNICON "${ICON_NSIS}"
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

  CreateDirectory "\$SMPROGRAMS\\王国保卫战 Dove 版"
  nsExec::Exec \`powershell -ExecutionPolicy Bypass -Command "\$\$ws=New-Object -ComObject WScript.Shell;\$\$s=\$\$ws.CreateShortcut('\$DESKTOP\\王国保卫战 Dove 版.lnk');\$\$s.TargetPath='\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe';\$\$s.WorkingDirectory='\$INSTDIR\\KingdomRushDove';\$\$s.Save();\$\$s=\$\$ws.CreateShortcut('\$SMPROGRAMS\\王国保卫战 Dove 版\\王国保卫战 Dove 版.lnk');\$\$s.TargetPath='\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe';\$\$s.WorkingDirectory='\$INSTDIR\\KingdomRushDove';\$\$s.Save()"\`

  WriteUninstaller "\$INSTDIR\\uninstall.exe"

  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "DisplayName" "王国保卫战 Dove 版"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "UninstallString" "\$INSTDIR\\uninstall.exe"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "DisplayIcon" "\$INSTDIR\\KingdomRushDove\\KingdomRushDove版启动器.exe"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "Publisher" "Dove"
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "NoModify" 1
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "\$DESKTOP\\王国保卫战 Dove 版.lnk"
  RMDir /r "\$SMPROGRAMS\\王国保卫战 Dove 版"
  RMDir /r "\$INSTDIR"
  DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\王国保卫战Dove版"
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

if [ "$QUICK_MODE" = "1" ]; then
    scp -P 60001 "$INSTALLER_FILE" dove@10.112.99.5:/srv/files/王国保卫战Dove版-Windows端/
else
    scp -P 60001 "$INSTALLER_FILE" dove@krdovedownload6.crazyspotteddove.top:/srv/files/王国保卫战Dove版-Windows端/
fi
