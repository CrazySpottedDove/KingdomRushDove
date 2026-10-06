#!/bin/bash
# VERSION_FILE="./version.lua"
# # BASE_COMMIT=$(cat "makefiles/.main_version_commit_hash")

# # 读取当前 id
# if [ -n "${VERSION_FILE:-}" ] && [ -f "$VERSION_FILE" ]; then
#     # 仅匹配行首的 `id = "..."`，避免匹配到 bundle_id
#     current_id=$(awk -F'"' '/^[[:space:]]*id[[:space:]]*=/ {print $2; exit}' "$VERSION_FILE")
#     current_id=${current_id:-$(date +%s)}
# else
#     current_id=$(date +%s)
# fi

# if [[ ! $current_id =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#     echo "version.id 格式错误，当前值：$current_id"
#     exit 1
# fi

# IFS='.' read -r major minor patch <<<"$current_id"

# # patch自增并进位
# patch=$((patch + 1))
# if [ "$patch" -ge 10 ]; then
#     patch=0
#     minor=$((minor + 1))
#     if [ "$minor" -ge 10 ]; then
#         minor=0
#         major=$((major + 1))
#     fi
# fi
# new_id="$major.$minor.$patch"

# # # 压缩包名用新 id
# # mkdir -p ./.versions
# # BASE_DIR="$(pwd)"
# # OUTPUT_ZIP="$(pwd)/.versions/Kingdom Rush_${current_id}.zip"

# # if [ -f "../Kingdom Rush.zip" ]; then
# #     echo "已存在 Kingdom Rush.zip，正在删除..."
# #     rm "../Kingdom Rush.zip"
# # fi

# # echo "打包至: $OUTPUT_ZIP"

# # git diff --name-status "$BASE_COMMIT" HEAD | awk '$1 != "D" {print $2}' > changed_files.txt

# # # 用 zip 打包
# # zip "$OUTPUT_ZIP" -@ < changed_files.txt

# # rm changed_files.txt

# # 更新 version.lua
# sed -i "s/version\.id = \".*\"/version.id = \"$new_id\"/" "$VERSION_FILE"

# cd "$(cat makefiles/.windows_kr_dove_dir)"
# zip "$OUTPUT_ZIP" -@  < "$BASE_DIR/makefiles/.tmp_files"
# cd - >/dev/null

# 更新器服务端（git_services.rs: /commits）以 master 为基准：
#   rev_range = "<client_hash>..<git rev-parse master>"，diff 也用 <client_hash> <master>。
# 因此客户端记录的必须是 master 上的提交，不能是 dev（master 是独立投影分支，dev 不是其祖先，
# 否则 <dev_hash>..master 会等于整个 master 历史，导致每次全新安装都误报"有更新"）。
if master_hash="$(git rev-parse --verify --quiet master)"; then
    printf '%s\n' "$master_hash" > ./current_version_commit_hash.txt
else
    echo "WARN: 本地没有 master 分支，回退记录 HEAD；请先执行 make package 生成 master 投影" >&2
    git rev-parse HEAD > ./current_version_commit_hash.txt
fi