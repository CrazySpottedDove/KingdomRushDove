#!/usr/bin/env bash
# 用新的 -test 命令脚本跑一局 autoplay。
#
# 用法：
#   scripts/test/autoplay.sh <关卡号> [选项] [-- 其它 love 参数]
#
# 选项：
#   --mode N             1 campaign / 2 heroic / 3 iron
#   --difficulty N       难度
#   --no-towers          不铺塔
#   --no-clicks          不自动点击世界物件/特殊塔
#   --no-next-wave       不自动发下一波
#   --no-force-boss      不强推 boss 阶段
#   --spell ID           自动释放 power3 法术
#   --spell-level N      法术等级（开局前设置）
#   --max-seconds N      模拟时间上限，默认 1800
#   --script-out PATH    保留生成的 JSONL 脚本到指定路径
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LEVEL="${1:-}"
shift || true

if [[ -z "$LEVEL" ]]; then
	echo "usage: $0 <level> [options] [-- love args]" >&2
	exit 2
fi

MODE=1
DIFF=1
BUILD_TOWERS=true
AUTO_CLICK=true
NEXT_WAVE=true
FORCE_BOSS=true
SPELL=""
SPELL_LEVEL=""
MAX_SECONDS=1800
SCRIPT_OUT=""
EXTRA=()

while [[ $# -gt 0 ]]; do
	case "$1" in
		--mode) MODE="$2"; shift 2 ;;
		--difficulty|--diff) DIFF="$2"; shift 2 ;;
		--no-towers) BUILD_TOWERS=false; shift ;;
		--no-clicks) AUTO_CLICK=false; shift ;;
		--no-next-wave) NEXT_WAVE=false; shift ;;
		--no-force-boss) FORCE_BOSS=false; shift ;;
		--spell) SPELL="$2"; shift 2 ;;
		--spell-level) SPELL_LEVEL="$2"; shift 2 ;;
		--max-seconds) MAX_SECONDS="$2"; shift 2 ;;
		--script-out) SCRIPT_OUT="$2"; shift 2 ;;
		--) shift; EXTRA=("$@"); break ;;
		*) EXTRA+=("$1"); shift ;;
	esac
done

TMP_SCRIPT="$(mktemp "${TMPDIR:-/tmp}/krd-autoplay-XXXXXX.jsonl")"
cleanup() {
	rm -f "$TMP_SCRIPT"
}
trap cleanup EXIT

CONFIG_ARGS="\"difficulty\":$DIFF"
if [[ -n "$SPELL" ]]; then
	CONFIG_ARGS="$CONFIG_ARGS,\"spell\":\"$SPELL\""
fi
if [[ -n "$SPELL_LEVEL" ]]; then
	CONFIG_ARGS="$CONFIG_ARGS,\"spell_level\":$SPELL_LEVEL"
fi

START_ARGS="\"build_towers\":$BUILD_TOWERS,\"auto_click\":$AUTO_CLICK,\"send_next_wave\":$NEXT_WAVE,\"force_boss\":$FORCE_BOSS"
if [[ -n "$SPELL" ]]; then
	START_ARGS="$START_ARGS,\"spell\":\"$SPELL\""
fi
if [[ -n "$SPELL_LEVEL" ]]; then
	START_ARGS="$START_ARGS,\"spell_level\":$SPELL_LEVEL"
fi

{
	echo "{\"id\":0,\"cmd\":\"plugins_load_all\"}"
	echo "{\"id\":1,\"cmd\":\"configure\",\"args\":{$CONFIG_ARGS}}"
	echo "{\"id\":2,\"cmd\":\"open_level\",\"args\":{\"level\":$LEVEL,\"mode\":$MODE,\"difficulty\":$DIFF}}"
	echo "{\"id\":3,\"cmd\":\"run_until\",\"args\":{\"condition\":\"game_start\",\"load_timeout_ms\":60000,\"max_ticks\":400000}}"
	echo "{\"id\":4,\"cmd\":\"autoplay_start\",\"args\":{$START_ARGS}}"
	echo "{\"id\":5,\"cmd\":\"run_until\",\"args\":{\"condition\":\"level_outcome\",\"max_sim_seconds\":$MAX_SECONDS}}"
	echo "{\"id\":6,\"cmd\":\"report\"}"
	echo "{\"id\":7,\"cmd\":\"quit\",\"args\":{\"code\":0}}"
} > "$TMP_SCRIPT"

if [[ -n "$SCRIPT_OUT" ]]; then
	cp "$TMP_SCRIPT" "$SCRIPT_OUT"
fi

cd "$ROOT"
exec "${LOVE:-love}" . -test "$TMP_SCRIPT" ${EXTRA[@]+"${EXTRA[@]}"}
