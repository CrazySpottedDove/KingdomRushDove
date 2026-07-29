#!/usr/bin/env bash
# 从 .gitignore 自动生成 rsync --exclude 参数
#
# 用法:
#   source makefiles/_excludes.sh
#   GITIGNORE_ALLOW=("pattern1" "pattern2")
#   MANUAL_EXCLUDES=("extra1" "extra2")
#   EXCLUDE_ARGS=()
#   while IFS= read -r arg; do
#       EXCLUDE_ARGS+=("$arg")
#   done < <(gitignore_excludes)
#   rsync -a "${EXCLUDE_ARGS[@]}" ./ "$DEST_DIR/"
#
# 原理：
#   - 读取 .gitignore 每一行，转为 --exclude 参数
#   - 在 GITIGNORE_ALLOW 中的条目会被跳过（它们在 .gitignore 中但需要打包进游戏）
#   - MANUAL_EXCLUDES 中的条目是 .gitignore 之外但要排除的（手写维护）

gitignore_excludes() {
    [ ! -f .gitignore ] && return
    while IFS= read -r line; do
        case "$line" in
            '' | '#'*) continue ;;
        esac
        case "$line" in
            '!'*) continue ;;
        esac
        local skip=0
        for allow in "${GITIGNORE_ALLOW[@]}"; do
            if [ "$line" = "$allow" ]; then
                skip=1
                break
            fi
        done
        if [ "$skip" = "1" ]; then
            continue
        fi
        echo "--exclude=$line"
    done < .gitignore
    echo "--exclude=.git/"
    for ex in "${MANUAL_EXCLUDES[@]}"; do
        echo "--exclude=$ex"
    done
}
