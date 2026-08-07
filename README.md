# 开发者手册

## 如何搭建开发环境

### windows 环境

至 love2d 的 github 仓库下载 love 11.5.zip，解压缩。然后，将本项目放在 love.exe
的同级目录下即可。启动时，在本项目目录中使用 `..\love.exe .`。

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

确保 `git` 和 `gh` 已添加到环境变量。确保 `lua` 或 `luajit`
已添加到环境变量。（下面的内容，使用 `lua` 和使用 `luajit` 同理）。

### 注册本地美术资源路径

首先，在 `makefiles` 目录下创建
`.assets_path.txt`，在里面写上你本地美术资源目录。如，我在 `wsl`
下开发，但是美术资源放在 windows 中，那么我的 `.assets_path.txt` 的内容就可能是

```txt
/mnt/d/Local-App/Kingdom_Rush_dove/Kingdom Rush/_assets
```

### 更新美术资源索引

在项目目录下运行

```sh
lua ./scripts/gen_assets_index.lua
```

来更新美术资源索引。这个命令会在 `_assets` 下生成/更新美术资源索引
`assets_index.lua`。

### 上传美术资源

安全起见，client 需联系作者获得。

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

## 格式化

本项目使用专有 vscode 插件 `dlfmt` 格式化。在提交更改前，请右键
`dlfmt_task.json`，选择使用
`dlfmt: 运行 JSON 任务`，以保证整个项目格式一致，且压缩了必要的数据资源。

## 文本输入（textinput / IME）规范

背景：`love.keypressed` 在用户的系统输入法处于非英文（如中文拼音）状态时，字母键会被 IME
组词拦截，导致按键事件不触发。为让游戏快捷键在任意输入法下可用，游戏默认关闭系统文本输入，
仅在真正需要输入文本时临时开启。

机制：

- `main.lua` 启动时调用 `love.keyboard.setTextInput(false)`，全局默认关闭。
- `KWindow:set_responder(view)` 是唯一的开关点：传入的 view 带有 `on_textinput` 方法时自动
  `setTextInput(true)`，否则（包括传 nil 归还输入权）自动 `setTextInput(false)`。
- `KWindow:destroy()` 会归还输入权并强制关闭文本输入，避免 IME 残留。

规则：

- 新增任何需要键盘输入的控件（文本、数字、枚举等），都必须实现 `on_textinput(t)` 方法，并
  通过 `KWindow:set_responder(self)` 注册为响应者；输入结束后调用
  `KWindow:set_responder()`（传 nil）归还输入权。禁止直接调用 `love.keyboard.setTextInput`
  或直接给 `window.responder` 赋值，否则会被自动开关逻辑漏掉。
- 自定义虚拟键盘（不需要系统 IME，如 `NumericKeyboardView`）必须在 initialize 中设置
  `self.is_virtual_keyboard = true`，这样即使实现 `on_textinput` 也不会弹系统输入法。
- 离开页面/界面时必须归还输入权：窗口被 `destroy()` 会自动处理；持久化窗口（不销毁）则须在
  退出路径中显式调用 `window:set_responder()`（参考 `atlas_manager:leave()`）。
- 目前所有 `on_textinput` 均通过 `set_responder` 转交，覆盖的控件清单：
  `KENum/KEEnum/KEProp`（游戏编辑器属性）、`EditableItem`（可编辑面板）、atlas_manager 的
  `name_input` 与 `inp`、`NumericKeyboardView`（虚拟键盘，不启用 IME）。

## 规则

- 任何直接修改 `enemy.can_do_magic` 的行为都是危险的。
- 任何直接修改 `tween` 的 `sprite_id` 的行为都是危险的。
- 不允许将 `damage` 作为 component。
- 不允许在 `tween_prop.keys` 中使用 `key[3]` 指定插值方法，每个 `tween_prop`
  只能有一个插值方法，并通过 `tween_prop.interp` 指定。
- 建议将只运行一次的 `tween` 的 `run_once` 赋为 `true`。
- 不允许直接修改 `sprite` 的 `draw_order`。如需修改，必须调用
  `U.change_sprite_draw_order()`。
- UI 中的 `colors.tint` 使用归一化参数。
- KView 中的 `alpha` 是归一化的。
- 为了性能考虑，dove 版中，render 只拥有 sprites，frames
  的功能全部都合并了进去，以避免每帧大量的拷贝开销。
- scripts 的 require
  关系：scripts->endless_scripts->hero_scripts->tower_scripts->boss_scripts，这是为了满足插件的正常跳转功能，并不是随便设计成这样的。endless_scripts
  在同一张 `scripts`
  表上扩展无尽模式相关脚本；之后如果还要拆分逻辑，也需要这样链式插入。
- 为了提高加载效率，游戏在运行时只加载 `game_animations.luac`。如果对
  `game_animations.lua` 进行了修改，请使用 `make compile_animations` 编译它。
- 同理，图集定义文件也需经过 `make compile_atlas` 编译，才能正常被使用。
- `main_script` 的 queue 和 dequeue 方法被禁用，统一在 insert, remove 中实现。
- 运行时（实体已在 store 中时）修改 health_bar 的 offset，需调用
  `U.change_health_bar_offset_run_time(health_bar, offset_y)` 方法。修改
  z，需调用 `U.change_health_bar_z_run_time(health_bar, z)`。修改 sort_y_offset,
  需调用 `U.change_health_bar_sort_y_offset_run_time(health_bar, sort_y_offset)`
- 对于 sprite 的 pos，如要修改其值，不应当直接为他赋一个新的 pos，而应该改动它的
  pos（赋值和克隆的区别，克隆会导致原有的引用关系失效，导致一系列优化问题）。
- 对于一个 arrow，我们期待它的 payload 是一个 string? 类型的量。我们不希望在运行时直接通过赋值给某个 bullet，使它获得 payload。你可以为这种情况专门写一个脚本来实现类似的效果。如果是对实体数据库中所有同类 arrow 都生效的，则可以添加 payload，并对它的 update 脚本执行重新编译。
- 不要在运行时把 hit_decal 置 nil，而是使用类似于 `decal_timed_empty` 的空 decal 替换他。
- 不要在运行时给 aura 赋 `track_source`，应直接在模板定义中确定。