#!/bin/bash
# Wrapper around git commit: formats code, records commit in changelog,
# and squashes everything into one commit.
#
# Usage: scripts/git-commit.sh -m "message"
#        make commit msg="feat: 新增某某功能"
#
# Changelog is updated incrementally (one entry appended to the per-version
# file) instead of a full git history scan, keeping it fast.

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# 提交前检查版本任务。放在 commit 之前，避免“提交成功后才发现任务到期”的无效拦截。
if ! luajit ./scripts/check_version_tasks.lua; then
	echo "ERROR: 存在到期的版本任务，已阻止提交。设置 VERSION_TASKS_WARN_ONLY=1 可仅提醒。" >&2
	exit 1
fi

# Step 2: git commit (capture exit without set -e killing us)
set +e
git commit "$@"
COMMIT_EXIT=$?
set -e

if [ $COMMIT_EXIT -ne 0 ]; then
	exit $COMMIT_EXIT
fi

# Step 3: fast incremental changelog append (reads last commit info)
luajit scripts/append_changelog.lua

echo "Running dlfmt..."
dlfmt --json-task ./dlfmt_task.json

# Step 4: stage updated changelog files
git add dove_modules/data/changelog_data.lua
git add dove_modules/data/changelog/

# Step 5: squash into the same commit
git commit --amend --no-edit

echo "Changelog updated and squashed into the commit."
