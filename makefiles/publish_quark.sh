#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="${VERSION_FILE:-./version.lua}"
KUAKE_BIN="${KUAKE_BIN:-kuake}"
KUAKE_CONFIG="${KUAKE_CONFIG:-config.json}"
KEEP_LATEST="${KEEP_LATEST:-8}"
MAX_UPLOAD_PARALLEL="${MAX_UPLOAD_PARALLEL:-8}"

QUARK_DIR_ANDROID="${QUARK_DIR_ANDROID:-/王国保卫战Dove版/安卓端}"
QUARK_DIR_WINDOWS="${QUARK_DIR_WINDOWS:-/王国保卫战Dove版/Windows端}"
QUARK_DIR_LINUX="${QUARK_DIR_LINUX:-/王国保卫战Dove版/Linux端}"

if ! command -v "$KUAKE_BIN" >/dev/null 2>&1; then
    echo "ERROR: kuake not found: $KUAKE_BIN" >&2
    exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 not found" >&2
    exit 1
fi

if [[ "$KEEP_LATEST" =~ ^[0-9]+$ ]]; then
    :
else
    echo "ERROR: KEEP_LATEST must be an integer, got: $KEEP_LATEST" >&2
    exit 1
fi

if [ -f "$KUAKE_CONFIG" ]; then
    KUAKE_ARGS=(-c "$KUAKE_CONFIG")
else
    KUAKE_ARGS=()
fi

run_kuake() {
    "$KUAKE_BIN" "${KUAKE_ARGS[@]}" "$@"
}

run_kuake_json() {
    local out err status tmp_out tmp_err
    tmp_out="$(mktemp)"
    tmp_err="$(mktemp)"
    status=0
    if ! run_kuake "$@" >"$tmp_out" 2>"$tmp_err"; then
        status=$?
    fi
    out="$(cat "$tmp_out")"
    err="$(cat "$tmp_err")"
    rm -f "$tmp_out" "$tmp_err"

    if [ "$status" -ne 0 ]; then
        if [ -n "$out" ]; then
            printf "%s\n" "$out" >&2
        elif [ -n "$err" ]; then
            printf "%s\n" "$err" >&2
        fi
        return "$status"
    fi

    python3 - "$out" <<'PY'
import json, sys
raw = sys.argv[1]
try:
    data = json.loads(raw)
except Exception:
    if raw:
        sys.stderr.write(raw + "\n")
    sys.exit(1)
if data.get("success") is True:
    sys.stdout.write(raw)
    sys.exit(0)
if raw:
    sys.stderr.write(raw + "\n")
sys.exit(1)
PY
}

ensure_remote_dir() {
    local remote_dir="$1"
    if run_kuake_json info "$remote_dir" >/dev/null; then
        return 0
    fi
    local parent name
    parent="$(dirname "$remote_dir")"
    name="$(basename "$remote_dir")"
    if [ "$parent" = "." ]; then
        parent="/"
    fi
    if [ "$parent" != "/" ]; then
        ensure_remote_dir "$parent"
    fi
    if ! run_kuake_json create "$name" "$parent" >/dev/null; then
        local ok=0
        for _ in 1 2 3; do
            if run_kuake_json info "$remote_dir" >/dev/null; then
                ok=1
                break
            fi
            sleep 1
        done
        if [ "$ok" != "1" ]; then
            echo "ERROR: failed to create remote dir: $remote_dir" >&2
            exit 1
        fi
    fi
}

remote_file_size() {
    local remote_path="$1"
    local json
    if ! json="$(run_kuake_json info "$remote_path")"; then
        return 1
    fi
    python3 - "$json" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
obj = d.get("data", {}) if isinstance(d, dict) else {}
candidates = [obj, obj.get("file", {}), obj.get("entry", {}), obj.get("item", {}), obj.get("metadata", {})]
for it in candidates:
    if not isinstance(it, dict):
        continue
    for k in ("size", "file_size", "fsize"):
        v = it.get(k)
        if isinstance(v, (int, float)):
            print(int(v))
            sys.exit(0)
        if isinstance(v, str) and v.isdigit():
            print(int(v))
            sys.exit(0)
sys.exit(1)
PY
}

upload_if_needed() {
    local local_file="$1"
    local remote_dir="$2"
    local base remote_path local_size remote_size
    if [ ! -f "$local_file" ]; then
        echo "WARN: local file missing, skip: $local_file" >&2
        return 0
    fi
    ensure_remote_dir "$remote_dir"
    base="$(basename "$local_file")"
    remote_path="${remote_dir%/}/$base"
    local_size="$(stat -c '%s' "$local_file")"
    if remote_size="$(remote_file_size "$remote_path" 2>/dev/null)"; then
        if [ "$remote_size" = "$local_size" ]; then
            echo "[SKIP] already exists: $remote_path"
            return 0
        fi
        echo "[REPLACE] size changed: $remote_path ($remote_size -> $local_size)"
        run_kuake_json delete "$remote_path" >/dev/null || true
    fi
    echo "[UPLOAD] $local_file -> $remote_path"
    run_kuake_json upload "$local_file" "$remote_path" --max_upload_parallel "$MAX_UPLOAD_PARALLEL" >/dev/null
}

cleanup_remote_versions() {
    local remote_dir="$1"
    local regex="$2"
    local keep="$3"
    if ! run_kuake list "$remote_dir" --stream 2>/dev/null | python3 - "$keep" "$regex" <<'PY' | while IFS= read -r path; do
import json, os, re, sys
keep = int(sys.argv[1])
pattern = re.compile(sys.argv[2])
items = []
def parse_ver(v):
    try:
        return tuple(int(x) for x in v.split("."))
    except Exception:
        return (0,)
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        o = json.loads(line)
    except Exception:
        continue
    if not isinstance(o, dict):
        continue
    if o.get("dir") is True or o.get("is_dir") is True or o.get("is_folder") is True:
        continue
    p = o.get("path")
    if not isinstance(p, str):
        continue
    name = os.path.basename(p)
    m = pattern.match(name)
    if not m:
        continue
    ver = parse_ver(m.group(1))
    items.append((ver, p))
items.sort(key=lambda x: x[0], reverse=True)
for _, p in items[keep:]:
    print(p)
PY
        [ -n "$path" ] || continue
        echo "[CLEAN] delete old remote version: $path"
        run_kuake_json delete "$path" >/dev/null || true
    done; then
        return 0
    fi
    return 0
}

run_cleanup() {
    cleanup_remote_versions "$QUARK_DIR_ANDROID" '^KingdomRushDove-Android(?:-HD)?-Cycle2-v([0-9]+(?:\.[0-9]+)*)\.(?:apk|zip)$' "$KEEP_LATEST"
    cleanup_remote_versions "$QUARK_DIR_WINDOWS" '^KingdomRushDove-Windows-Cycle2-v([0-9]+(?:\.[0-9]+)*)\.zip$' "$KEEP_LATEST"
    cleanup_remote_versions "$QUARK_DIR_LINUX" '^KingdomRushDove-Linux-Cycle2-v([0-9]+(?:\.[0-9]+)*)\.zip$' "$KEEP_LATEST"
}

MODE="${1:-all}"
if [ "$#" -gt 0 ]; then
    shift
fi

case "$MODE" in
    upload-one)
        if [ "$#" -ne 2 ]; then
            echo "Usage: $0 upload-one <local_file> <remote_dir>" >&2
            exit 1
        fi
        upload_if_needed "$1" "$2"
        ;;
    cleanup-only)
        run_cleanup
        ;;
    all)
        if [ -f "$VERSION_FILE" ]; then
            current_id="$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")"
        else
            current_id=""
        fi
        if [ -z "$current_id" ]; then
            echo "ERROR: cannot read version id from $VERSION_FILE" >&2
            exit 1
        fi

        mkdir -p ".versions"
        android_apk=".versions/KingdomRushDove-Android-Cycle2-v${current_id}.apk"
        android_hd_apk=".versions/KingdomRushDove-Android-HD-Cycle2-v${current_id}.apk"
        windows_zip=".versions/KingdomRushDove-Windows-Cycle2-v${current_id}.zip"
        linux_zip=".versions/KingdomRushDove-Linux-Cycle2-v${current_id}.zip"

        upload_if_needed "$android_apk" "$QUARK_DIR_ANDROID"
        upload_if_needed "$android_hd_apk" "$QUARK_DIR_ANDROID"
        upload_if_needed "$windows_zip" "$QUARK_DIR_WINDOWS"
        upload_if_needed "$linux_zip" "$QUARK_DIR_LINUX"
        run_cleanup
        echo "Publish to Quark finished."
        ;;
    *)
        echo "ERROR: unknown mode: $MODE" >&2
        echo "Usage: $0 [all|upload-one <local_file> <remote_dir>|cleanup-only]" >&2
        exit 1
        ;;
esac
