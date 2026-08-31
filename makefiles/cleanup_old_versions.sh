#!/usr/bin/env bash
# 打包新版本前，删除 .versions 下旧版本的同平台包（保留当前版本正在生成的产物）。
#
# 用法:
#   source makefiles/cleanup_old_versions.sh
#   cleanup_old_packages "$current_id" ".versions/王国保卫战Dove版-v*Windows电脑端.zip"
#
# 说明:
#   - 每个 pattern 对应一个平台的产物命名模式，只清理该平台的旧版本包
#   - 文件名中包含 "-v<当前版本>-" 的文件会被保留（可能是本次打包刚生成的当前版本包）
#   - 没有匹配到文件时静默跳过

cleanup_old_packages() {
    local current_id="$1"
    shift
    local keep_marker="-v${current_id}-"
    local pattern f
    for pattern in "$@"; do
        # 通配符在 for 中展开；无匹配时 $f 是字面 pattern，由 [ -e ] 兜底跳过
        for f in $pattern; do
            [ -e "$f" ] || continue
            if [[ "$f" == *"$keep_marker"* ]]; then
                echo "保留当前版本包: $f"
            else
                echo "删除旧版本包: $f"
                rm -f "$f"
            fi
        done
    done
}
