WINDOWS_DIR:=$(shell cat ./.windows_kr_dove_dir)

.PHONY: examine_windows_dir  sync

examine_windows_dir:
# 	如果 WINDOWS_DIR 目录不存在，提示用户创建
	@if [ ! -d "$(WINDOWS_DIR)" ]; then \
		echo "错误: 目录 $(WINDOWS_DIR) 不存在，请创建该目录或修改 .windows_kr_dove_dir 文件中的路径。"; \
		exit 1; \
	fi
sync:
    @echo "同步变动的 lua 文件到 $(WINDOWS_DIR)"
    @git status --porcelain | grep '\.lua$$' | awk '{print $$2}' | xargs -I{} cp --parents {} $(WINDOWS_DIR)