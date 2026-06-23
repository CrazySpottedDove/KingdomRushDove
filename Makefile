MAKE_FILE_DIR:=makefiles
WINDOWS_DIR:=$(shell cat $(MAKE_FILE_DIR)/.windows_kr_dove_dir)
LOVE:=$(shell cat $(MAKE_FILE_DIR)/.love_dir)
WINDOWS_DIR_WIN:=$(shell wslpath -w "$(WINDOWS_DIR)")
MAIN_VERSION_COMMIT_HASH_FILE := $(MAKE_FILE_DIR)/.main_version_commit_hash
CURRENT_ID=$(shell awk -F'"' '/version\.id[ ]*=/ {print $$2}' "./version.lua" | head -n 1)
.PHONY: all debug package repackage sync branch master index upload download main_version_jump assets_check gen_waves android windows publish publish_retry

all: _examine_dir_map sync
	cd "$(WINDOWS_DIR)" && $(LOVE) "$(WINDOWS_DIR_WIN)"

_examine_dir_map:
	@if [ ! -d "$(WINDOWS_DIR)" ]; then \
		echo "错误: 目录 $(WINDOWS_DIR) 不存在，请创建该目录或修改 .windows_kr_dove_dir 文件中的路径。"; \
		exit 1; \
	fi
	@if [ ! -f "$(LOVE)" ]; then \
		echo "错误: LOVE 可执行文件 $(LOVE) 不存在，请检查 .love_dir 文件中的路径。"; \
		exit 1; \
	fi

changelog:
	@luajit scripts/gen_changelog.lua

# sync 目标只在开发者游戏放在 windows 上，但是代码开发在 linux 上时作为同步代码资源脚本来使用
sync:
	@bash $(MAKE_FILE_DIR)/sync.sh "$(WINDOWS_DIR)"

sync-full:
	@bash $(MAKE_FILE_DIR)/sync-full.sh "$(WINDOWS_DIR)"

debug: _examine_dir_map sync
	cd "$(WINDOWS_DIR)" && $(LOVE) "$(WINDOWS_DIR_WIN)" debug

assets_check: _examine_dir_map sync
	cd "$(WINDOWS_DIR)" && $(LOVE) "$(WINDOWS_DIR_WIN)" assets

gen_waves: _examine_dir_map sync
	cd "$(WINDOWS_DIR)" && $(LOVE) "$(WINDOWS_DIR_WIN)" waves

# 用于发布小的版本更新，使得更新器端可以在 master 分支上检查到最新更新
package:
# 	@bash $(MAKE_FILE_DIR)/package.sh
# 	git add .
# 	git commit -m "UPDATE VERSION COMMIT HASH"
	git checkout master
	git merge dev
	git push server master
	git push origin master
# 	git push gitee master
	git checkout dev

branch:
	@bash $(MAKE_FILE_DIR)/branch.sh

master:
	@bash $(MAKE_FILE_DIR)/master.sh

# 建立美术资源索引，在上传前必须使用
index:
	@luajit scripts/gen_assets_index.lua

# 上传修改的美术资源(Deprecated)
upload:
	@lua scripts/upload_assets.lua

# 拉取最新的资源文件到本地(Deprecated)
download:
	@lua scripts/download_assets.lua

# deprecated
# main_version_jump: sync
# 	git rev-parse HEAD > $(MAIN_VERSION_COMMIT_HASH_FILE)

android:
	@bash $(MAKE_FILE_DIR)/package.sh
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh hd

windows:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_windows.sh

linux:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_linux.sh

windows_quick:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_windows.sh quick

installer:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_windows_installer.sh

installer_quick:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_windows_installer.sh quick

installer_build:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_windows_installer.sh no-upload

android_quick:
	@bash $(MAKE_FILE_DIR)/package.sh
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh quick
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh hd quick

linux_quick:
	@bash $(MAKE_FILE_DIR)/package.sh
	bash $(MAKE_FILE_DIR)/pack_linux.sh quick

publish:
	JOBS=8 bash $(MAKE_FILE_DIR)/publish_parallel.sh

publish_retry:
	JOBS=8 bash $(MAKE_FILE_DIR)/publish_parallel.sh upload-only

android_build:
# 	@bash $(MAKE_FILE_DIR)/package.sh
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh no-upload

android_hd_build:
# 	@bash $(MAKE_FILE_DIR)/package.sh
	JOBS=8 bash $(MAKE_FILE_DIR)/pack_android.sh hd no-upload

push:
	git push origin dev
	git push server dev

format:
	dlfmt --json-task ./dlfmt_task.json

add:
	dlfmt --json-task ./dlfmt_task.json
	git add .

compile_animations:
	luajit ./scripts/compile_game_animations.lua

compile_atlas:
	luajit ./scripts/compile_image_atlas.lua

compile: compile_animations compile_atlas