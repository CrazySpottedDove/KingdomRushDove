#!/bin/bash
set -e

WINDOWS_DIR="$1"
LAST_SYNC_FILE=".last_sync_commit"

echo -e "\033[1;36m=== sync changed files since last sync to: $WINDOWS_DIR ===\033[0m"

if [ -f "$LAST_SYNC_FILE" ]; then
    last_commit=$(cat "$LAST_SYNC_FILE")
    # 直接用命令替换，避免多行变量丢失
    {
        git diff --name-only "$last_commit" HEAD
        git diff --name-only
        git diff --name-only --cached
        git ls-files --others --exclude-standard
    } | sort | uniq | grep -v '^$' > .sync_file_list
    if [ -s .sync_file_list ]; then
        echo "将要同步的文件:"
        cat .sync_file_list
        cat .sync_file_list | xargs -I{} cp --parents "{}" "$WINDOWS_DIR"
    else
        echo "无文件需要同步。"
    fi
else
    echo "首次同步，复制所有文件"
    git ls-files > .sync_file_list
    git ls-files --others --exclude-standard >> .sync_file_list
    sort .sync_file_list | uniq > .sync_file_list.tmp && mv .sync_file_list.tmp .sync_file_list
    echo "将要同步的文件:"
    cat .sync_file_list
    cat .sync_file_list | xargs -I{} cp --parents "{}" "$WINDOWS_DIR"
fi

git rev-parse HEAD > "$LAST_SYNC_FILE"