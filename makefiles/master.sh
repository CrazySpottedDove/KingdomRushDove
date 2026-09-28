#!/bin/bash
# 将开发分支投影为 master：master 只保留“编译产物”，剔除仅源码文件
# （源码清单由 makefiles/gen_release_source_paths.sh 生成）。
#
# 采用 git read-tree 快照而非 merge：因为 merge 会把开发分支的源码重新带回 master，
# 且下次合并会产生大量 delete/modify 冲突。master 因此不与开发分支共享合并历史，
# 只保留线性快照提交，保证服务端的 git pull 仍是 fast-forward。
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

echo "源分支: $SOURCE_BRANCH"

# 1) 同步并推送源分支
git checkout "$SOURCE_BRANCH"
git push origin "$SOURCE_BRANCH"

# 2) 生成仅源码清单（以已提交的源分支为准）
bash makefiles/gen_release_source_paths.sh "$SOURCE_BRANCH" > "$MANIFEST"
echo "仅源码文件数: $(wc -l < "$MANIFEST")"

# 3) 生成 master 投影快照
git checkout master

# 让工作区与索引精确等于源分支的树（同时处理新增、修改与删除）
git read-tree -u --reset "$SOURCE_BRANCH"

# 从索引与工作区移除仅源码文件
# 此时索引已精确等于源分支的树，只需删除源码后直接 commit，
# 不要使用 git add -A，以免把工作区里未跟踪/未忽略的文件误加入 master。
if [ -s "$MANIFEST" ]; then
	# -f 必需：源码相对上一次 master 快照可能是“新增但已暂存”的状态
	git rm -r -q -f --ignore-unmatch --pathspec-from-file="$MANIFEST"
fi

if git diff --cached --quiet; then
	echo "master 相对源分支无变化，跳过提交。"
else
	VERSION_ID="$(sed -n 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' version.lua | head -1)"
	git commit -m "release: ${VERSION_ID:-snapshot}"
	echo "master 已更新为投影快照（仅编译产物）。"
fi
