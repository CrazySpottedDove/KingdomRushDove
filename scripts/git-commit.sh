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
cd "$(git rev-parse --show-toplevel)" || exit 1

# Step 0: format code
echo "Running dlfmt..."
dlfmt --json-task ./dlfmt_task.json

# Step 1: stage all changes (including formatting)
git add -A

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

# Step 4: stage updated changelog files
git add dove_modules/data/changelog_data.lua
git add dove_modules/data/changelog/

# Step 5: squash into the same commit
git commit --amend --no-edit

echo "Changelog updated and squashed into the commit."
