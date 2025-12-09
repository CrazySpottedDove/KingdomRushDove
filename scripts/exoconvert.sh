#!/bin/bash
# 输入路径：第一个参数
INPUT_PATH="$1"

# 遍历输入路径下的所有文件
find "$INPUT_PATH" -type f | while read -r FILE; do
    # 获取文件扩展名
    EXT="${FILE##*.}"
    # 检查文件扩展名是否为 .lua
    if [[ "$EXT" == "lua" ]]; then
        luajit ./scripts/exo_v1tov3.lua "$FILE" "$FILE"
    fi
done
echo "Conversion completed."
