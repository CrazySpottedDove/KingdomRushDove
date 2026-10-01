#!/usr/bin/env bash
# 生成“仅源码”文件清单：这些 .lua 在运行时加载的是同名编译产物，
# 因此发布分支（master）与发行包中不需要它们。
#
# 判断规则：在指定 ref 中，某个 .lua 存在同名编译产物（.luac / .aluac / .exo3 / .bin）时，
# 视为仅源码。必须以 ref（已提交内容）为准，避免把未跟踪/未提交的产物误当成已发布产物。
# 例：
#   _assets/kr1-desktop/images/fullhd/achievements.lua   (有 .luac/.aluac)
#   kr1/data/game_animations.lua                         (有 .bin)
#   kr1/data/exoskeletons/fooDef.lua                     (有 .exo3)
#
# 用法：gen_release_source_paths.sh [ref]   (默认 HEAD)
# 输出：相对仓库根目录的路径，每行一个（稳定顺序）。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REF="${1:-HEAD}"

tree="$(git ls-tree -r --name-only "$REF")"

# 已提交的 .lua（排序去重）
tracked_lua="$(printf '%s\n' "$tree" | grep '\.lua$' | sort -u || true)"

# 由已提交的编译产物反推出的候选源码（排序去重）
candidates="$(printf '%s\n' "$tree" \
	| grep -E '\.(luac|aluac|exo3|bin)$' \
	| sed -E 's/\.(luac|aluac|exo3|bin)$/.lua/' \
	| sort -u || true)"

# 取交集：既是已提交源码、又有已提交编译产物
if [ -n "$candidates" ]; then
	printf '%s\n' "$tracked_lua" | grep -Fx -f <(printf '%s\n' "$candidates") || true
fi
