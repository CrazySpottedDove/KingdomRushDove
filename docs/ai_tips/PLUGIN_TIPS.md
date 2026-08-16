# plugin/ 目录理解文档

> 目录：`plugin/`
> 作用：游戏插件（Plugin）系统，允许在不修改核心代码的前提下扩展/覆盖游戏逻辑、资源、实体模板。

---

## 一、目录结构

```
plugin/
├── plugin_main.lua          # Plugin 系统入口，负责扫描/加载/初始化所有启用的 plugin
├── plugin_globals.lua       # 全局变量和辅助函数（暴露到全局命名空间）
├── plugin_main_config.lua   # Plugin 系统默认配置（总开关、路径白名单等）
├── plugin_template/         # Plugin 模板（示例）
│   ├── config.lua
│   ├── plugin_template.lua
│   ├── plugin_template_scripts.lua
│   └── plugin_template_templates.lua
├── all/                  # Plugin 公共工具模块（所有 plugin 可 require）
│   ├── hook_utils.lua    # 钩子工具（HOOK/UNHOOK/CALL_ORIGINAL）
│   ├── plugin_db.lua        # Plugin 数据库（扫描/排序/管理已启用 plugin）
│   └── plugin_utils.lua     # 路径工具（获取子目录、添加 require 路径）
└── local/                # 用户实际安装的 plugin（不纳入版本控制）
    └── <plugin_name>/
        ├── config.lua    # 必须：plugin 元数据
        └── <plugin_name>.lua # 必须：plugin 主入口，返回 hook 表
```

---

## 二、Plugin 加载流程

```
game 启动
  → plugin_main:init(director)
      → plugin_db:init()         # 扫描 plugins/ 下所有已启用且版本兼容的 plugin
      → director:init(params) # 核心游戏初始化（在 plugin 路径注册前先初始化钩子基础设施）
      → plugin_main:after_init()
          → 正序为每个 plugin 添加 require 路径
          → 倒序 require 每个 plugin（得到 hook 表）
          → 正序调用 hook:init(plugin_data)（高优先级覆盖低优先级）
```

---

## 三、config.lua 结构

```lua
return {
    name = "plugin名称",
    version = "1.0",
    entry = "入口文件名称（无.lua后缀）"
    desc = "描述",
    url = "链接",
    by = "作者",
    enabled = true,   -- false 则不加载
    priority = 0,     -- 数字越小越先初始化（高优先级覆盖低优先级）
}
```

---

## 四、Plugin 主文件结构

Plugin 主文件（`<plugin_name>.lua`）需返回一个 **hook 表**，该表必须实现 `init(plugin_data)` 方法：

```lua
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new() -- 创建带 auto_table_mt 的 hook 实例

function hook:init(plugin_data)
	self.plugin_data = plugin_data
	-- 在这里注册所有钩子
	HOOK(SomeObject, "some_method", self.SomeObject.some_method)
end

-- 钩子函数签名：function(next_fn, self_or_first_arg, ...)
function hook.SomeObject.some_method(next, self, ...)
	next(self, ...) -- 调用原始函数（可在前/后/替换）
	-- 自定义逻辑
end

return hook
```

---

## 五、hook_utils 工具

### HOOK(obj, fn_name, handler, priority?)

为 `obj[fn_name]` 注册一个钩子处理器。
- `obj`: 目标对象（如 `E`, `simulation`, `game`）
- `fn_name`: 方法名字符串（如 `"load"`, `"do_tick"`）
- `handler`: 钩子函数，签名为 `function(next, ...)`，`next` 是下一个钩子或原始函数
- `priority`: 可选，越小越先执行（默认 0）

**调用链：** `handler1(next1, ...) → next1 = handler2(next2, ...) → ... → original(...)`

### UNHOOK(obj, fn_name, handler)

移除特定钩子处理器。

### CALL_ORIGINAL(obj, fn_name, ...)

绕过所有钩子，直接调用原始函数。

---

## 七、plugin_main_config.lua — 总控配置

```lua
return {
	enabled = true, -- 总开关，false 时禁用整个 plugin 系统
}
```

**注意**：`plugins/plugin_main_config.lua` 是用户本地配置（不在版本控制中），首次运行时自动从模板复制。**要启用 plugin 系统，必须将 `enabled` 设为 `true`。**

---

## 八、开发新 plugin 的步骤

1. 在 `plugins/` 下创建目录 `<plugin_name>/`。
2. 创建 `config.lua`（填写元数据，`enabled = true`）。
3. 创建 `<plugin_name>.lua`（实现 `hook:init`，注册 HOOK）。
4. 确认 `plugins/plugin_main_config.lua` 中 `enabled = true`。
5. 启动游戏，plugin 自动加载。

---

## 九、plugin 内可访问的全局对象（由 plugin_globals.lua 注入）

| 全局变量 | 说明 |
|---------|------|
| `simulation` | ECS 调度器 |
| `game` | 游戏主对象（含 `store`, `camera`, `game_scale`, `draw_game` 等） |
| `E` | 实体数据库（`entity_db`） |
| `V` / `V.v(x,y)` | 向量工具 |
| `signal` | 事件信号系统 |
| `SH` | Shader 数据库 |
| `UPGR` | 升级数据 |
| `storage` | 存档系统 |
| `SU` | 脚本工具（`script_utils`） |
| `U` | 通用工具（`utils`） |
| `RT/AC/CC/T` | 模板注册/添加组件/克隆组件/获取模板 |
| `queue_insert/queue_remove/queue_damage` | 实体/伤害队列操作 |
| `fts(v)` | 帧转秒（`v / FPS`） |
| `d2r(d)` | 角度转弧度 |
| `IS_KR5` | 是否为 kr5 版本 |
| `IS_LOVE_11` | 是否为 LÖVE 11+ |

---

## 十、已有 plugin 参考

### enhanced_vesper（厉害的维斯珀）

- 路径：`plugins/enhanced_vesper/`
- 技术：Hook `E.load`，在加载后 `require` 自定义 scripts/templates 文件
- 特点：通过 `config_skills.lua` 暴露可配置参数

### damage_numbers（伤害数字显示）

- 路径：`plugins/damage_numbers/`
- 技术：Hook `simulation.do_tick`（读取伤害）+ Hook `game.draw_game`（叠加绘制）
- 特点：纯运行时 Hook，无需资源文件，支持所有游戏版本
- 注意：伤害类型判断直接使用全局常量 `DAMAGE_*` / `DR_*`，不硬编码数值；这些常量由 `all/constants.lua` 在游戏启动时注册为全局变量，plugin 初始化时已可用
