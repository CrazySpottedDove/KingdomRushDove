#!/bin/bash
VERSION_FILE="./version.lua"
BASE_COMMIT=$(cat "makefiles/.main_version_commit_hash")

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

git diff --name-status "$BASE_COMMIT" HEAD | awk '$1 != "D" {print $2}' > changed_files.txt

# 用 zip 打包
zip "$OUTPUT_ZIP" -@ < changed_files.txt

rm changed_files.txt

# 更新 version.lua
sed -i "s/version\.id = \".*\"/version.id = \"$new_id\"/" "$VERSION_FILE"