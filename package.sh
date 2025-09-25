#!/bin/bash
VERSION_FILE="./version.lua"

# 读取当前 id
current_id=$(awk -F'"' '/version\.id[ ]*=/ {print $2}' "$VERSION_FILE" | head -n 1)

if [[ ! $current_id =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "version.id 格式错误，当前值：$current_id"
    exit 1
fi

IFS='.' read -r major minor patch <<<"$current_id"

# patch自增并进位
patch=$((patch + 1))
if [ "$patch" -ge 10 ]; then
    patch=0
    minor=$((minor + 1))
    if [ "$minor" -ge 10 ]; then
        minor=0
        major=$((major + 1))
    fi
fi
new_id="$major.$minor.$patch"

# 压缩包名用新 id
mkdir -p ./.versions
OUTPUT_ZIP="./.versions/Kingdom Rush_${current_id}.zip"

if [ -f "../Kingdom Rush.zip" ]; then
    echo "已存在 Kingdom Rush.zip，正在删除..."
    rm "../Kingdom Rush.zip"
fi

echo "打包至: $OUTPUT_ZIP"

if [ $# -eq 0 ]; then
    # find . -name "*.lua" -type f ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" | zip "$OUTPUT_ZIP" -@
    find . -name "*.lua" -type f ! -path "./_assets/kr1-desktop/strings/*" | zip "$OUTPUT_ZIP" -@
else
    find . -name "*.lua" -type f ! -path "./_assets/kr1-desktop/strings/*" ! -path "./lib/*" | zip "$OUTPUT_ZIP" -@
fi

# zip "$OUTPUT_ZIP" "./必读说明.md"
zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/strings/zh-Hans.lua"
zip "$OUTPUT_ZIP" "./存档位置.lnk"
zip "$OUTPUT_ZIP" "./游玩必读说明，务必阅读.url"

# tmp usage
zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/go_towers_necromancer-1.dds"

# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/go_towers_dark_elf-1.dds"
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/go_towers_tricannon-1.dds"
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/gui_common-5.png"
# # 记录 commit hash 文件
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/criket_random_eff_mod.png"
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/cricet_random_eff.png"
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/go_stage90_bg-1.png"
# zip "$OUTPUT_ZIP" "./_assets/kr1-desktop/images/fullhd/go_stages_flag-1.png"

COMMIT_FILE="last_build_commit.txt"
LOG_FILE="update_log.txt"

# 获取当前最新 commit hash
current_commit=$(git rev-parse HEAD)

# 获取上次打包的 commit hash（如果没有，取最早一次提交）
if [ -f "$COMMIT_FILE" ]; then
    last_commit=$(cat "$COMMIT_FILE")
else
    last_commit=$(git rev-list --max-parents=0 HEAD)
fi

# 生成更新日志
echo "------------------------------" >> "$LOG_FILE"
echo "版本 $current_id 更新内容：" >> "$LOG_FILE"
git log --pretty=format:"%h %ad %an %s" --date=short "$last_commit..$current_commit" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 更新 commit hash
echo "$current_commit" > "$COMMIT_FILE"

# 把日志文件打包进压缩包
zip "$OUTPUT_ZIP" "$LOG_FILE"

# 更新 version.lua
sed -i "s/version\.id = \".*\"/version.id = \"$new_id\"/" "$VERSION_FILE"