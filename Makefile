WINDOWS_DIR:=$(shell cat ./.windows_kr_dove_dir)
LOVE:=$(shell cat ./.love_dir)
WINDOWS_DIR_WIN:=$(shell wslpath -w "$(WINDOWS_DIR)")
LAST_SYNC_FILE := .last_sync_commit

.PHONY: all debug package repackage sync

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
	@bash ./sync.sh "$(WINDOWS_DIR)"
debug: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" debug

monitor: _examine_dir_map sync
	$(LOVE) "$(WINDOWS_DIR_WIN)" monitor

package:
	bash ./package.sh