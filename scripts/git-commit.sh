#!/bin/bash
# Wrapper around git commit: records the commit in changelog_data.lua
# inside the same commit, avoiding extra "update changelog" commits.
#
# Usage: scripts/git-commit.sh -m "message" [other git commit args]
#
# How it works:
#   1. Runs git commit normally
#   2. On success, regenerates changelog from updated git history
#      (now includes this commit's message)
#   3. Stages the changelog and amends it into the same commit

set -e
cd "$(git rev-parse --show-toplevel)" || exit 1

CHANGELOG_FILE="dove_modules/data/changelog_data.lua"

# Step 1: git commit
git commit "$@"
COMMIT_EXIT=$?

if [ $COMMIT_EXIT -ne 0 ]; then
	exit $COMMIT_EXIT
fi

# Step 2: regenerate changelog from actual history (now with this commit)
luajit scripts/gen_changelog.lua
git add "$CHANGELOG_FILE"

# Step 3: squash into the same commit
git commit --amend --no-edit

echo "Changelog updated and squashed into the commit."
