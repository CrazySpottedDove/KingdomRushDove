# 开发者手册

## 美术资源的同步

### 注册本地美术资源路径

首先，在 `makefiles` 目录下创建 `.assets_path.txt`，在里面写上你本地美术资源目录。如，我在 `wsl` 下开发，但是美术资源放在 windows 中，那么我的 `.assets_path.txt` 的内容就可能是

```txt
/mnt/d/Local-App/Kingdom_Rush_dove/Kingdom Rush/_assets
```

### 更新美术资源索引

在项目目录下运行

```sh
lua ./scripts/gen_assets_index.lua
```

来更新美术资源索引。这个命令会在 `_assets` 下生成/更新美术资源索引 `assets_index.lua`。

### 上传美术资源

在项目目录下运行

```sh
lua ./scripts/upload_assets.lua
```

来上传美术资源。这个命令会比较本地的 `assets_index.lua` 和远程仓库的 `assets_index.lua`，来识别两者到底有什么差别。然后，这个命令会把需要上传的本地美术资源上传到 github release 中。

需要注意的是，如果远程仓库的 `assets_index.lua` 信息和远程仓库中实际拥有的美术资源情况不一致，可能导致一些问题。因此，在执行完 `gen_assets_index.lua` 后，请务必保证成功上传全部美术资源后，再将改变进行 commit。

### 下载美术资源

在项目目录下运行

```sh
lua ./scripts/download_assets.lua
```

来下载美术资源。这个命令会根据本地的 `assets_index.lua` 来确定需要下载哪些美术资源，然后从远程仓库下载到 `.assets_path.txt` 中指定的美术资源目录中。