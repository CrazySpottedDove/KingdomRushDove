#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:?Usage: process_android_audio.sh <out_dir> [source_sound_dir]}"
SRC_DIR="${2:-./_assets/kr1-desktop/sounds/files}"

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ERROR: ffmpeg not found" >&2
    exit 1
fi
if ! command -v ffprobe >/dev/null 2>&1; then
    echo "ERROR: ffprobe not found" >&2
    exit 1
fi

JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
CACHE_DIR="${AUDIO_CACHE_DIR:-.versions/.android_audio_cache}"
Q_SFX="${AUDIO_Q_SFX:-3}"
Q_BGM="${AUDIO_Q_BGM:-5}"
BGM_MIN_DURATION="${AUDIO_BGM_MIN_DURATION:-25}"
SFX_SKIP_KBPS="${AUDIO_SFX_SKIP_KBPS:-96}"
BGM_SKIP_KBPS="${AUDIO_BGM_SKIP_KBPS:-144}"

CACHE_KEY="q_sfx=${Q_SFX}|q_bgm=${Q_BGM}|bgm_min_duration=${BGM_MIN_DURATION}|sfx_skip_kbps=${SFX_SKIP_KBPS}|bgm_skip_kbps=${BGM_SKIP_KBPS}"
CACHE_KEY_FILE="$CACHE_DIR/.cache_key"
if [ ! -f "$CACHE_KEY_FILE" ] || [ "$(cat "$CACHE_KEY_FILE" 2>/dev/null || true)" != "$CACHE_KEY" ]; then
    rm -rf "$CACHE_DIR"
    mkdir -p "$CACHE_DIR"
    printf "%s" "$CACHE_KEY" > "$CACHE_KEY_FILE"
fi

mkdir -p "$OUT_DIR"

mapfile -d '' ogg_files < <(find "$SRC_DIR" -type f -name "*.ogg" -print0 2>/dev/null || printf '')
ogg_count=${#ogg_files[@]}

if [ "$ogg_count" -eq 0 ]; then
    echo "[AUDIO] No .ogg files found in $SRC_DIR."
    exit 0
fi

echo "[AUDIO] Processing $ogg_count ogg files with $JOBS jobs..."

export OUT_DIR SRC_DIR CACHE_DIR Q_SFX Q_BGM BGM_MIN_DURATION SFX_SKIP_KBPS BGM_SKIP_KBPS

printf "%s\0" "${ogg_files[@]}" | xargs -0 -P "$JOBS" -I {} bash -c '
    src="$1"
    rel="${src#"$SRC_DIR"/}"
    cache_file="$CACHE_DIR/$rel"
    cache_dir="$(dirname "$cache_file")"
    out_file="$OUT_DIR/_assets/kr1-desktop/sounds/files/$rel"
    out_dir="$(dirname "$out_file")"

    mkdir -p "$cache_dir" "$out_dir"

    if [ -f "$cache_file" ] && [ "$cache_file" -nt "$src" ]; then
        cp -f "$cache_file" "$out_file"
        exit 0
    fi

    duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)"
    bitrate="$(ffprobe -v error -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)"

    q="$Q_SFX"
    skip_kbps="$SFX_SKIP_KBPS"
    if awk "BEGIN {exit !($duration+0 >= $BGM_MIN_DURATION+0)}"; then
        q="$Q_BGM"
        skip_kbps="$BGM_SKIP_KBPS"
    fi

    should_reencode=1
    if [ -n "$bitrate" ] && [ "$bitrate" != "N/A" ]; then
        kbps="$(awk "BEGIN {printf \"%.0f\", ($bitrate+0)/1000}")"
        if [ "$kbps" -le "$skip_kbps" ]; then
            should_reencode=0
        fi
    fi

    if [ "$should_reencode" -eq 1 ]; then
        tmp="${cache_file}.tmp.$$"
        ffmpeg -y -v error -i "$src" -map_metadata -1 -vn -c:a libvorbis -q:a "$q" -f ogg "$tmp"
        mv -f "$tmp" "$cache_file"
    else
        cp -f "$src" "$cache_file"
    fi

    cp -f "$cache_file" "$out_file"
' _ {}

processed_count=$(find "$OUT_DIR/_assets/kr1-desktop/sounds/files" -type f -name "*.ogg" 2>/dev/null | wc -l || echo 0)
echo "[AUDIO] Prepared $processed_count files for Android package."
