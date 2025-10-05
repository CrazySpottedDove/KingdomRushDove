#!/bin/bash

# 资源目录
WINDOWS_DIR="$1"

# 上一次执行 sync 时的 git commit head
LAST_SYNC_COMMIT_FILE="makefiles/.last_sync_commit_file"
SYNC_LIST_FILE="makefiles/.sync_file_list"
TMP_SYNC_LIST_FILE="makefiles/.tmp_sync_file_list"
echo -e "\033[1;36m=== sync changed files since last sync to: $WINDOWS_DIR ===\033[0m"

# 当前的 git commit head
current_commit=$(git rev-parse HEAD)

if [ -f "$LAST_SYNC_COMMIT_FILE" ]; then
    # 获取上一次执行 sync 时的 git commit head
    last_commit=$(cat "$LAST_SYNC_COMMIT_FILE")

    # 找出自上次同步 commit 以来有变动的文件（包括已修改、已暂存、未跟踪的文件）
    {
        git diff --name-only "$last_commit" HEAD
        git diff --name-only
        git diff --name-only --cached
        git ls-files --others --exclude-standard
    } | sort | uniq | grep -v '^$' > $TMP_SYNC_LIST_FILE

    # 如果当前的 git commit head 和上一次执行 sync 时的 git commit head 相同，则只对 SYNC_LIST_FILE 进行追加，不进行简单覆盖
    if [ "$last_commit" = "$current_commit" ]; then
        echo "当前 commit 未变化，仅追加新增文件到同步列表"
        if [ -f "$SYNC_LIST_FILE" ]; then
            grep -Fxv -f "$SYNC_LIST_FILE" $TMP_SYNC_LIST_FILE >> "$SYNC_LIST_FILE"
            sort -u "$SYNC_LIST_FILE" -o "$SYNC_LIST_FILE.tmp"
            mv "$SYNC_LIST_FILE.tmp" "$SYNC_LIST_FILE"
        else
            mv $TMP_SYNC_LIST_FILE "$SYNC_LIST_FILE"
        fi
    else
    # 如果不同，则本次将原有 SYNC_LIST_FILE 中的记录和本次变动的文件都同步，然后用本次记录覆盖原有 SYNC_LIST_FILE
        cat "$SYNC_LIST_FILE" | xargs -I{} cp --parents "{}" "$WINDOWS_DIR"
        mv $TMP_SYNC_LIST_FILE "$SYNC_LIST_FILE"
    fi
else
    echo "首次同步，复制所有文件"
    git ls-files > $SYNC_LIST_FILE
    git ls-files --others --exclude-standard >> $SYNC_LIST_FILE
    sort $SYNC_LIST_FILE | uniq > $TMP_SYNC_LIST_FILE && mv $TMP_SYNC_LIST_FILE $SYNC_LIST_FILE
fi
echo "将要同步的文件:"
cat $SYNC_LIST_FILE
cat "$SYNC_LIST_FILE" | xargs -I{} cp --parents "{}" "$WINDOWS_DIR"
git rev-parse HEAD > "$LAST_SYNC_COMMIT_FILE"