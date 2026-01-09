#!/bin/bash

# 资源目录
WINDOWS_DIR="$1"
TMP_1="makefiles/.tmp_1"
TMP_2="makefiles/.tmp_2"
echo -e "\033[1;36m=== sync files to: $WINDOWS_DIR ===\033[0m"
git ls-files > $TMP_1
git ls-files --others --exclude-standard >> $TMP_1
sort $TMP_1 | uniq > $TMP_2 && mv $TMP_2 $TMP_1
cat $TMP_1 | xargs -I{} cp --parents "{}" "$WINDOWS_DIR"
