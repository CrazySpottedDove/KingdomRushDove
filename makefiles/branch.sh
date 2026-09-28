#!/bin/bash
# master 现在是“只含编译产物”的投影分支，不再作为开发基线与开发分支合并
# （把 master 合并进开发分支会误删源码）。因此这里只把开发分支与远程同步。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

branch_name="$(cat makefiles/.branch 2>/dev/null || true)"
if [ -z "$branch_name" ] || ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
	branch_name="dev"
fi

git fetch origin "$branch_name"

if git show-ref --verify --quiet "refs/heads/$branch_name"; then
	git checkout "$branch_name"
else
	git checkout -b "$branch_name" --track "origin/$branch_name"
fi

git pull --ff-only origin "$branch_name"
