MAKE_FILE_DIR:=makefiles
WINDOWS_DIR:=$(shell cat $(MAKE_FILE_DIR)/.windows_kr_dove_dir)
LOVE:=$(shell cat $(MAKE_FILE_DIR)/.love_dir)
WINDOWS_DIR_WIN:=$(shell wslpath -w "$(WINDOWS_DIR)")
LAST_SYNC_FILE := $(MAKE_FILE_DIR)/.last_sync_commit
MAIN_VERSION_COMMIT_HASH_FILE := $(MAKE_FILE_DIR)/.main_version_commit_hash
CURRENT_ID=$(shell awk -F'"' '/version\.id[ ]*=/ {print $$2}' "./version.lua" | head -n 1)
.PHONY: all debug package repackage sync branch master index upload download main_version_jump

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

sync:
	@bash $(MAKE_FILE_DIR)/sync.sh "$(WINDOWS_DIR)"
debug: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" debug

monitor: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" monitor

package:
	@bash $(MAKE_FILE_DIR)/package.sh
	git add .
# 	git commit -m "LAST VERSION: $(CURRENT_ID)"

branch:
	@bash $(MAKE_FILE_DIR)/branch.sh

master:
	@bash $(MAKE_FILE_DIR)/master.sh

index:
	@lua scripts/gen_assets_index.lua

upload:
	@lua scripts/upload_assets.lua

download:
	@lua scripts/download_assets.lua

main_version_jump: sync
	git rev-parse HEAD > $(MAIN_VERSION_COMMIT_HASH_FILE)


