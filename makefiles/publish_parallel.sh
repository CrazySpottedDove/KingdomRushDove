#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION_FILE="${VERSION_FILE:-./version.lua}"
JOBS="${JOBS:-8}"
SCP_PORT="${SCP_PORT:-60001}"
SCP_USER="${SCP_USER:-dove}"
SCP_HOST_PUBLIC="${SCP_HOST_PUBLIC:-krdovedownload6.crazyspotteddove.top}"
SCP_HOST_LAN="${SCP_HOST_LAN:-10.112.99.5}"
PUBLISH_QUICK="${PUBLISH_QUICK:-1}"

SERVER_DIR_ANDROID="${SERVER_DIR_ANDROID:-/srv/files/王国保卫战Dove版-安卓端/}"
SERVER_DIR_WINDOWS="${SERVER_DIR_WINDOWS:-/srv/files/王国保卫战Dove版-Windows端/}"
SERVER_DIR_LINUX="${SERVER_DIR_LINUX:-/srv/files/王国保卫战Dove版-Linux端/}"

QUARK_DIR_ANDROID="${QUARK_DIR_ANDROID:-/王国保卫战Dove版/安卓端（HD即高清的意思，适合配置较好的手机使用）}"
QUARK_DIR_WINDOWS="${QUARK_DIR_WINDOWS:-/王国保卫战Dove版/Windows端}"
QUARK_DIR_LINUX="${QUARK_DIR_LINUX:-/王国保卫战Dove版/Linux端}"
ENABLE_QUARK_UPLOAD="${ENABLE_QUARK_UPLOAD:-0}"
LOCAL_KEEP_LATEST="${LOCAL_KEEP_LATEST:-8}"
MODE="${1:-all}"
QUARK_LOCK_FILE="${QUARK_LOCK_FILE:-.versions/.quark_upload.lock}"

if [ "$PUBLISH_QUICK" = "1" ]; then
    SCP_HOST="$SCP_HOST_LAN"
else
    SCP_HOST="$SCP_HOST_PUBLIC"
fi

if [ "$ENABLE_QUARK_UPLOAD" != "1" ]; then
    echo "[INFO] quark upload disabled (ENABLE_QUARK_UPLOAD=$ENABLE_QUARK_UPLOAD)"
fi

if [ ! -f "$VERSION_FILE" ]; then
    echo "ERROR: version file not found: $VERSION_FILE" >&2
    exit 1
fi

current_id="$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")"
if [ -z "$current_id" ]; then
    echo "ERROR: cannot read version id from $VERSION_FILE" >&2
    exit 1
fi

LOG_DIR=".versions/.publish_logs"
mkdir -p "$LOG_DIR"

declare -a upload_pids=()
declare -a upload_names=()
declare -a upload_logs=()

start_upload_pair() {
    local local_file="$1"
    local server_dir="$2"
    local quark_dir="$3"
    local job_name="$4"
    local log_file="$LOG_DIR/${current_id}_${job_name}.log"

    if [ ! -f "$local_file" ]; then
        echo "ERROR: package not found: $local_file" >&2
        exit 1
    fi

    (
        set -uo pipefail
        local scp_status=0
        local quark_status=0
        local quark_pid=0

        scp -q -P "$SCP_PORT" "$local_file" "${SCP_USER}@${SCP_HOST}:${server_dir}" &
        local scp_pid=$!

        if [ "$ENABLE_QUARK_UPLOAD" = "1" ]; then
            (
                flock -x 9
                QUARK_DIR_ANDROID="$QUARK_DIR_ANDROID" \
                QUARK_DIR_WINDOWS="$QUARK_DIR_WINDOWS" \
                QUARK_DIR_LINUX="$QUARK_DIR_LINUX" \
                bash makefiles/publish_quark.sh upload-one "$local_file" "$quark_dir"
            ) 9>"$QUARK_LOCK_FILE" &
            quark_pid=$!
        fi

        wait "$scp_pid" || scp_status=$?
        if [ "$quark_pid" -ne 0 ]; then
            wait "$quark_pid" || quark_status=$?
        fi

        if [ "$scp_status" -ne 0 ] || [ "$quark_status" -ne 0 ]; then
            echo "[PAIR-ERR] $job_name scp=$scp_status quark=$quark_status" >&2
            exit 1
        fi
    ) >"$log_file" 2>&1 &

    upload_pids+=("$!")
    upload_names+=("$job_name")
    upload_logs+=("$log_file")
}

cleanup_local_group() {
    local keep="$1"
    shift
    local files=("$@")
    local sorted=()
    local remove_count=0

    if [ "${#files[@]}" -le "$keep" ]; then
        return 0
    fi

    mapfile -t sorted < <(printf "%s\n" "${files[@]}" | sort -V)
    remove_count=$((${#sorted[@]} - keep))

    for ((i = 0; i < remove_count; i++)); do
        rm -f "${sorted[$i]}"
        echo "[CLEAN-LOCAL] removed ${sorted[$i]}"
    done
}

cleanup_local_versions() {
    shopt -s nullglob
    local android=(.versions/KingdomRushDove-Android-Cycle2-v*.apk)
    local android_hd=(.versions/KingdomRushDove-Android-HD-Cycle2-v*.apk)
    local windows=(.versions/KingdomRushDove-Windows-Cycle2-v*.zip)
    local linux=(.versions/KingdomRushDove-Linux-Cycle2-v*.zip)
    local logs=("$LOG_DIR"/*.log)
    shopt -u nullglob

    cleanup_local_group "$LOCAL_KEEP_LATEST" "${android[@]}"
    cleanup_local_group "$LOCAL_KEEP_LATEST" "${android_hd[@]}"
    cleanup_local_group "$LOCAL_KEEP_LATEST" "${windows[@]}"
    cleanup_local_group "$LOCAL_KEEP_LATEST" "${linux[@]}"
    cleanup_local_group "$LOCAL_KEEP_LATEST" "${logs[@]}"
}

start_all_uploads() {
    start_upload_pair ".versions/KingdomRushDove-Android-Cycle2-v${current_id}.apk" "$SERVER_DIR_ANDROID" "$QUARK_DIR_ANDROID" "android"
    start_upload_pair ".versions/KingdomRushDove-Android-HD-Cycle2-v${current_id}.apk" "$SERVER_DIR_ANDROID" "$QUARK_DIR_ANDROID" "android_hd"
    start_upload_pair ".versions/KingdomRushDove-Windows-Cycle2-v${current_id}.zip" "$SERVER_DIR_WINDOWS" "$QUARK_DIR_WINDOWS" "windows"
    start_upload_pair ".versions/KingdomRushDove-Linux-Cycle2-v${current_id}.zip" "$SERVER_DIR_LINUX" "$QUARK_DIR_LINUX" "linux"
}

run_upload_phase() {
    echo "[STEP] waiting uploads"
    failed_upload=0
    for i in "${!upload_pids[@]}"; do
        if wait "${upload_pids[$i]}"; then
            echo "[OK] upload ${upload_names[$i]}"
        else
            echo "[FAIL] upload ${upload_names[$i]} (log: ${upload_logs[$i]})" >&2
            tail -n 20 "${upload_logs[$i]}" >&2 || true
            failed_upload=1
        fi
    done
}

if [ "$MODE" = "upload-only" ]; then
    start_all_uploads
else
    echo "[STEP] package branch sync"
    bash makefiles/package.sh

    echo "[STEP] build android"
    JOBS="$JOBS" bash makefiles/pack_android.sh no-upload
    start_upload_pair ".versions/KingdomRushDove-Android-Cycle2-v${current_id}.apk" "$SERVER_DIR_ANDROID" "$QUARK_DIR_ANDROID" "android"

    echo "[STEP] build android hd"
    JOBS="$JOBS" bash makefiles/pack_android.sh hd no-upload
    start_upload_pair ".versions/KingdomRushDove-Android-HD-Cycle2-v${current_id}.apk" "$SERVER_DIR_ANDROID" "$QUARK_DIR_ANDROID" "android_hd"

    echo "[STEP] build windows"
    bash makefiles/pack_windows.sh no-upload
    start_upload_pair ".versions/KingdomRushDove-Windows-Cycle2-v${current_id}.zip" "$SERVER_DIR_WINDOWS" "$QUARK_DIR_WINDOWS" "windows"

    echo "[STEP] build linux"
    bash makefiles/pack_linux.sh no-upload
    start_upload_pair ".versions/KingdomRushDove-Linux-Cycle2-v${current_id}.zip" "$SERVER_DIR_LINUX" "$QUARK_DIR_LINUX" "linux"
fi

run_upload_phase

if [ "$failed_upload" = "0" ] && [ "$ENABLE_QUARK_UPLOAD" = "1" ]; then
    echo "[STEP] quark cleanup"
    QUARK_DIR_ANDROID="$QUARK_DIR_ANDROID" \
    QUARK_DIR_WINDOWS="$QUARK_DIR_WINDOWS" \
    QUARK_DIR_LINUX="$QUARK_DIR_LINUX" \
    bash makefiles/publish_quark.sh cleanup-only
else
    echo "[STEP] skip quark cleanup" >&2
fi

echo "[STEP] local cleanup"
cleanup_local_versions

if [ "$failed_upload" = "0" ]; then
    echo "Parallel publish finished."
else
    exit 1
fi
