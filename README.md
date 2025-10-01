# 开发者手册

## 美术资源的同步

### 预备工具

确保 `git` 和 `gh` 已添加到环境变量。确保 `lua` 或 `luajit` 已添加到环境变量。（下面的内容，使用 `lua` 和使用 `luajit` 同理）。

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

- 请注意！`gen_assets_index.lua` 只是遍历了 `_assets` 目录，并为其中所有的美术资源生成索引。所以，使用它时，有两个要点：
    - 发现其它协作者推送的更新包含对 `assets_index.lua` 的修改时，请运行 `download_assets.lua`，以保证您的本地美术资源和远程一致。
    - 当您需要修改美术资源并提交时，请在本地删除不再需要的美术资源，然后运行本脚本，然后将 `assets_index.lua` 更新推送到远程。

### 上传美术资源

在项目目录下运行

```sh
lua ./scripts/upload_assets.lua
```

来上传美术资源。这个命令会比较本地的 `assets_index.lua` 和远程仓库的 **master** 分支的 `assets_index.lua`，来识别两者到底有什么差别。然后，这个命令会把需要上传的本地美术资源上传到 github release 中。

需要注意的是，如果远程仓库的 `assets_index.lua` 信息和远程仓库中实际拥有的美术资源情况不一致，可能导致一些问题。因此，在执行完 `gen_assets_index.lua` 后，请务必保证成功上传全部美术资源后，再将改变进行 commit。

### 下载美术资源

在项目目录下运行

```sh
lua ./scripts/download_assets.lua
```

来下载美术资源。这个命令会根据本地的 `assets_index.lua` 来确定需要下载哪些美术资源，然后从远程仓库下载到 `.assets_path.txt` 中指定的美术资源目录中。

一个典型的项目部署方式是，首先 `git clone` 获取项目代码和 `assets_index.lua`，然后再通过 `download_assets.lua` 获得美术资源。

对于本地依然存在，但是在本地的 `assets_index.lua` 中已经消失或不匹配的文件，`download_assets.lua` 会将它们移动到美术资源目录同级的 `_trashed_assets` 目录下，以起删除作用。

### 典型案例

#### 发现其他开发者修改了 `assets_index.lua`，且本地没有美术资源改动

运行 `lua ./scripts/download_assets.lua`，确保本地美术资源和 `assets_index.lua` 状态一致。

#### 本地修改了美术资源，将要提交

在 git 提交代码更改之前，首先运行 `lua ./scripts/gen_assets_index.lua`，以生成最新的 `assets_index.lua`。

然后，运行 `lua ./scripts/upload_assets.lua`，将新的或修改后的美术资源上传到远程仓库。

最后，git 提交代码，使得远程仓库的 `assets_index.lua` 是最新的，和当前游戏需要的美术资源相匹配。

#### 发现其他开发者修改了 `assets_index.lua`，且本地有美术资源改动

首先，合并其它开发者的提交，首先运行 `lua ./scripts/download_assets.lua`，确保本地美术资源和 `assets_index.lua` 状态一致。

然后，您会发现，含有冲突的美术资源会被移动的和美术资源目录同级的 `_trashed_assets` 目录下。您可以将您希望保留的美术资源重新复制回资源目录。

接着，参考**本地修改了美术资源，需要提交**。