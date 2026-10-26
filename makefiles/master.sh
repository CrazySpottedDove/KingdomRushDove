#!/bin/bash
# 将开发分支投影为 master：master 只保留“编译产物”，剔除仅源码文件
# （源码清单由 makefiles/gen_release_source_paths.sh 生成）。
#
# 采用 git read-tree 快照而非 merge：因为 merge 会把开发分支的源码重新带回 master，
# 且下次合并会产生大量 delete/modify 冲突。master 因此不与开发分支共享合并历史，
# 只保留线性快照提交，保证服务端的 git pull 仍是 fast-forward。
#
# 提交信息对齐：打包时把“上次已投影的开发提交”之后的每条开发提交各自投影成
# master 上的一条提交，提交信息/作者/作者日期与开发分支完全一致；只有源码改动
# 的提交会生成树相同的空提交，保证信息不丢。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# 安全闸：read-tree -u --reset 会丢弃工作区改动，必须先提交
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
	echo "错误: 工作区有未提交的改动。请先 make add && make commit 再执行。" >&2
	exit 1
fi

# 源分支：优先环境变量，其次 makefiles/.branch，最后回退 dev
SOURCE_BRANCH="${SOURCE_BRANCH:-$(cat makefiles/.branch 2>/dev/null || true)}"
if [ -z "$SOURCE_BRANCH" ] || ! git show-ref --verify --quiet "refs/heads/$SOURCE_BRANCH"; then
	SOURCE_BRANCH="dev"
fi

MANIFEST="makefiles/.release_source_paths"
MANIFEST_TMP="$(mktemp)"
TMP_INDEX="$(mktemp)"
trap 'rm -f "$MANIFEST_TMP" "$TMP_INDEX"' EXIT
rm -f "$TMP_INDEX"

# master 投影额外排除的开发文档（不属于“仅源码”清单）
MASTER_EXCLUDE_FILES=()

echo "源分支: $SOURCE_BRANCH"

# 1) 同步并推送源分支
git checkout "$SOURCE_BRANCH"
git push origin "$SOURCE_BRANCH"

# 某个提交投影到 master 后的 tree id（临时索引，只读，不碰工作区）
# 用法: projection_tree <提交> <仅源码清单>
projection_tree() {
	local ref="$1" manifest="$2"

	rm -f "$TMP_INDEX"
	GIT_INDEX_FILE="$TMP_INDEX" git read-tree "$ref"

	if [ -s "$manifest" ]; then
		GIT_INDEX_FILE="$TMP_INDEX" git rm --cached -r -q -f --ignore-unmatch --pathspec-from-file="$manifest"
	fi

	for extra in "${MASTER_EXCLUDE_FILES[@]}"; do
		GIT_INDEX_FILE="$TMP_INDEX" git rm --cached -q -f --ignore-unmatch -- "$extra"
	done

	GIT_INDEX_FILE="$TMP_INDEX" git write-tree
}

# 找到 master HEAD 对应的源分支提交
#   1) master 与源分支仍共享历史时，master HEAD 本身就是源分支提交；
#   2) 否则按“提交信息 + 作者日期 + 投影树”匹配；
#   3) 兜底：从源分支 HEAD 往回找第一个投影树等于 master HEAD 树的提交。
resolve_base_commit() {
	local master_subject master_date master_tree commit subject date checked

	if git merge-base --is-ancestor master "$SOURCE_BRANCH"; then
		git rev-parse master

		return 0
	fi

	master_subject="$(git log -1 --format=%s master)"
	master_date="$(git log -1 --format=%aI master)"
	master_tree="$(git rev-parse master^{tree})"

	while IFS=$'\t' read -r commit subject date; do
		if [ "$subject" = "$master_subject" ] && [ "$date" = "$master_date" ]; then
			bash makefiles/gen_release_source_paths.sh "$commit" > "$MANIFEST_TMP"

			if [ "$(projection_tree "$commit" "$MANIFEST_TMP")" = "$master_tree" ]; then
				printf '%s\n' "$commit"

				return 0
			fi
		fi
	done < <(git log --format=$'%H\t%s\t%aI' "$SOURCE_BRANCH")

	# 作者日期被改过等情况：只按“提交信息 + 投影树”匹配
	while IFS=$'\t' read -r commit subject; do
		if [ "$subject" = "$master_subject" ]; then
			bash makefiles/gen_release_source_paths.sh "$commit" > "$MANIFEST_TMP"

			if [ "$(projection_tree "$commit" "$MANIFEST_TMP")" = "$master_tree" ]; then
				printf '%s\n' "$commit"

				return 0
			fi
		fi
	done < <(git log --format=$'%H\t%s' "$SOURCE_BRANCH")

	# 兜底：从源分支 HEAD 往回找第一个投影树等于 master HEAD 树的提交
	checked=0

	while IFS= read -r commit; do
		checked=$((checked + 1))

		if [ "$checked" -gt 300 ]; then
			break
		fi

		bash makefiles/gen_release_source_paths.sh "$commit" > "$MANIFEST_TMP"

		if [ "$(projection_tree "$commit" "$MANIFEST_TMP")" = "$master_tree" ]; then
			printf '%s\n' "$commit"

			return 0
		fi
	done < <(git log --format='%H' "$SOURCE_BRANCH")

	return 1
}

if ! git show-ref --verify --quiet refs/heads/master; then
	echo "错误: 本地没有 master 分支。请先同步远端 master（如 git checkout -b master origin/master）再打包。" >&2
	exit 1
fi

git checkout master

if ! BASE_COMMIT="$(resolve_base_commit)"; then
	echo "错误: 无法确定 master HEAD 对应的源分支提交。" >&2
	echo "      master HEAD: $(git log -1 --format='%h %s' master)" >&2
	exit 1
fi

echo "上次已投影的开发提交: $(git log -1 --format='%h %s' "$BASE_COMMIT")"

# 2) 逐条投影新的开发提交
bash makefiles/gen_release_source_paths.sh "$BASE_COMMIT" > "$MANIFEST_TMP"

REPLAY_LIST=""

# 极端情况：master 仍直接跟着 dev（树里还有源码），base 本身也要投影一次
if [ "$(projection_tree "$BASE_COMMIT" "$MANIFEST_TMP")" != "$(git rev-parse master^{tree})" ]; then
	REPLAY_LIST="$BASE_COMMIT"$'\n'
fi

REPLAY_LIST+="$(git rev-list --reverse --topo-order "$BASE_COMMIT..$SOURCE_BRANCH")"

REPLAY_COUNT=0

while IFS= read -r commit; do
	[ -n "$commit" ] || continue

	# 该提交自己的仅源码清单（编译产物在不同提交上可能不同）
	bash makefiles/gen_release_source_paths.sh "$commit" > "$MANIFEST_TMP"

	# 让工作区与索引精确等于该提交的树（同时处理新增、修改与删除）
	git read-tree -u --reset "$commit"

	# 从索引与工作区移除仅源码文件（-f 必需：源码相对上一次快照可能是“新增但已暂存”）
	if [ -s "$MANIFEST_TMP" ]; then
		git rm -r -q -f --ignore-unmatch --pathspec-from-file="$MANIFEST_TMP"
	fi

	for extra in "${MASTER_EXCLUDE_FILES[@]}"; do
		git rm -q -f --ignore-unmatch -- "$extra"
	done

	AUTHOR="$(git log -1 --format='%an <%ae>' "$commit")"
	DATE="$(git log -1 --format=%aI "$commit")"

	# --allow-empty: 只有源码改动的提交投影后树不变，仍需保留提交信息
	git log -1 --format=%B "$commit" | git commit -q --allow-empty --allow-empty-message --cleanup=verbatim --author="$AUTHOR" --date="$DATE" -F -

	REPLAY_COUNT=$((REPLAY_COUNT + 1))
done <<< "$REPLAY_LIST"

# 3) 记录最终仅源码清单（打包排除规则用，见 makefiles/_excludes.sh）
bash makefiles/gen_release_source_paths.sh "$SOURCE_BRANCH" > "$MANIFEST"

if [ "$REPLAY_COUNT" -eq 0 ]; then
	echo "master 已与 $SOURCE_BRANCH 对齐，无需新增提交。"
else
	echo "master 已追加 $REPLAY_COUNT 条投影提交（提交信息/作者/日期与 $SOURCE_BRANCH 一致）。"
fi
