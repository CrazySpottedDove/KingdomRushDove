# 开发者手册

## 如何搭建开发环境

### windows 环境

至 love2d 的 github 仓库下载 love 11.5.zip，解压缩。然后，将本项目放在 love.exe 的同级目录下即可。启动时，在本项目目录中使用 `..\love.exe .`。

### linux 环境

使用你的包管理器下载 love，如：

```sh
sudo pacman -S love
```

然后在项目目录下使用

```sh
love .
```

启动。

请确保开启了 GPU 加速，否则游戏运行速度将非常缓慢。

### linux 下开发代码，但是应用放在 windows 中

可以使用 Makefile 提供的命令。

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

### 上传美术资源

在项目目录下运行

```cmd
.\client.exe --upload-assets
```

或

```sh
./client --upload-assets
```

### 下载美术资源

在项目目录下运行

```cmd
.\client.exe --sync-assets
```

或

```sh
./client --sync-assets
```

## 服务器仓库

本项目托管于仓库：

```sh
# git remote -v
server  ssh://dove@10.112.99.5:60001/srv/git/KingdomRushDove.git (fetch)
server  ssh://dove@10.112.99.5:60001/srv/git/KingdomRushDove.git (push)
```

### 格式化

本项目使用专有 vscode 插件 `dlfmt` 格式化。在提交更改前，请右键 `dlfmt_task.json`，选择使用 `dlfmt: 运行 JSON 任务`，以保证整个项目格式一致，且压缩了必要的数据资源。