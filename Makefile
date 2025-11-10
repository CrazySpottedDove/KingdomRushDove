MAKE_FILE_DIR:=makefiles
WINDOWS_DIR:=$(shell cat $(MAKE_FILE_DIR)/.windows_kr_dove_dir)
LOVE:=$(shell cat $(MAKE_FILE_DIR)/.love_dir)
WINDOWS_DIR_WIN:=$(shell wslpath -w "$(WINDOWS_DIR)")
MAIN_VERSION_COMMIT_HASH_FILE := $(MAKE_FILE_DIR)/.main_version_commit_hash
CURRENT_ID=$(shell awk -F'"' '/version\.id[ ]*=/ {print $$2}' "./version.lua" | head -n 1)
.PHONY: all debug package repackage sync branch master index upload download main_version_jump assets_check gen_waves pack

all: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)"

_examine_dir_map:
	@if [ ! -d "$(WINDOWS_DIR)" ]; then \
		echo "错误: 目录 $(WINDOWS_DIR) 不存在，请创建该目录或修改 .windows_kr_dove_dir 文件中的路径。"; \
		exit 1; \
	fi
	@if [ ! -f "$(LOVE)" ]; then \
		echo "错误: LOVE 可执行文件 $(LOVE) 不存在，请检查 .love_dir 文件中的路径。"; \
		exit 1; \
	fi

# sync 目标只在开发者游戏放在 windows 上，但是代码开发在 linux 上时作为同步代码资源脚本来使用
sync:
	@bash $(MAKE_FILE_DIR)/sync.sh "$(WINDOWS_DIR)"

debug: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" debug

assets_check: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" assets

monitor: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" monitor

gen_waves: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" waves

# 用于发布小的版本更新，使得更新器端可以在 master 分支上检查到最新更新
package:
	@bash $(MAKE_FILE_DIR)/package.sh
	git add .
	git commit -m "LAST VERSION: $(CURRENT_ID)"
	git checkout master
	git merge dev
	git push origin master
	git push gitee master
	git checkout dev

branch:
	@bash $(MAKE_FILE_DIR)/branch.sh

master:
	@bash $(MAKE_FILE_DIR)/master.sh

# 建立美术资源索引，在上传前必须使用
index:
	@lua scripts/gen_assets_index.lua

# 上传修改的美术资源
upload:
	@lua scripts/upload_assets.lua

# 拉取最新的资源文件到本地
download:
	@lua scripts/download_assets.lua

# deprecated
main_version_jump: sync
	git rev-parse HEAD > $(MAIN_VERSION_COMMIT_HASH_FILE)


