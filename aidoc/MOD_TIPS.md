# mods/ 目录理解文档

> 目录：`mods/`
> 作用：游戏模组（Mod）系统，允许在不修改核心代码的前提下扩展/覆盖游戏逻辑、资源、实体模板。

---

## 一、目录结构

```
mods/
├── mod_main.lua          # Mod 系统入口，负责扫描/加载/初始化所有启用的 mod
├── mod_hook.lua          # 系统级钩子（图片/声音/关卡数据覆盖）
├── mod_globals.lua       # 全局变量和辅助函数（暴露到全局命名空间）
├── mod_main_config.lua   # Mod 系统默认配置（总开关、路径白名单等）
├── mod_template/         # Mod 模板（示例）
│   ├── config.lua
│   ├── mod_template.lua
│   ├── mod_template_scripts.lua
│   └── mod_template_templates.lua
├── all/                  # Mod 公共工具模块（所有 mod 可 require）
│   ├── hook_utils.lua    # 钩子工具（HOOK/UNHOOK/CALL_ORIGINAL）
│   ├── mod_db.lua        # Mod 数据库（扫描/排序/管理已启用 mod）
│   └── mod_utils.lua     # 路径工具（获取子目录、添加 require 路径）
└── local/                # 用户实际安装的 mod（不纳入版本控制）
    └── <mod_name>/
        ├── config.lua    # 必须：mod 元数据
        └── <mod_name>.lua # 必须：mod 主入口，返回 hook 表
```

---

## 二、Mod 加载流程

```
game 启动
  → mod_main:init(director)
      → mod_db:init()         # 扫描 mods/local/ 下所有已启用且版本兼容的 mod
      → director:init(params) # 核心游戏初始化（在 mod 路径注册前先初始化钩子基础设施）
      → mod_main:after_init()
          → 正序为每个 mod 添加 require 路径
          → 倒序 require 每个 mod（得到 hook 表）
          → 正序调用 hook:init(mod_data)（高优先级覆盖低优先级）
          → mod_hook:after_init()（注册系统级资源覆盖钩子）
```

---

## 三、config.lua 结构

```lua
return {
    name = "mod名称",
    version = "1.0",
    entry = "入口文件名称（无.lua后缀）"
    game_version = {"kr1", "kr2"},  -- 支持的游戏版本
    desc = "描述",
    url = "链接",
    by = "作者",
    enabled = true,   -- false 则不加载
    priority = 0,     -- 数字越小越先初始化（高优先级覆盖低优先级）
}
```

---

## 四、Mod 主文件结构

Mod 主文件（`<mod_name>.lua`）需返回一个 **hook 表**，该表必须实现 `init(mod_data)` 方法：

```lua
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()   -- 创建带 auto_table_mt 的 hook 实例

function hook:init(mod_data)
    self.mod_data = mod_data
    -- 在这里注册所有钩子
    HOOK(SomeObject, "some_method", self.SomeObject.some_method)
end

-- 钩子函数签名：function(next_fn, self_or_first_arg, ...)
function hook.SomeObject.some_method(next, self, ...)
    next(self, ...)   -- 调用原始函数（可在前/后/替换）
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

## 六、mod_hook.lua — 系统级资源覆盖

这些钩子由框架自动注册，mod 只需在对应目录放文件即可触发：

| 钩子 | 触发条件 | 作用 |
|------|---------|------|
| `I.load_atlas` | `mod/_assets/images/<name>.lua` 存在 | 覆盖图集资源 |
| `I.queue_load_atlas` | 同上 | 队列加载时覆盖图集 |
| `S.init` | `mod/_assets/sounds/settings.lua` 等存在 | 覆盖音效配置 |
| `S.load_group` | `mod/_assets/sounds/files/` 存在 | 覆盖音效文件 |
| `LU.load_level` | `mod/data/levels/` 存在 | 覆盖关卡数据 |
| `P.load` | `mod/data/waves/` 存在 | 覆盖波次路径数据 |

---

## 七、mod_main_config.lua — 总控配置

```lua
return {
    enabled = true,           -- 总开关，false 时禁用整个 mod 系统
    not_mod_path = {"mod_template", "all"},  -- 不视为 mod 的目录
    ignored_path = {"_assets"},  -- 扫描子目录时忽略的名称
    ppref = "",               -- require 前缀（一般为空）
    check_paths = {...}       -- 检查每个 mod 是否含有这些路径（用于 check_paths 功能）
}
```

**注意**：`mods/local/mod_main_config.lua` 是用户本地配置（不在版本控制中），首次运行时自动从模板复制。**要启用 mod 系统，必须将 `enabled` 设为 `true`。**

---

## 八、开发新 mod 的步骤

1. 在 `mods/local/` 下创建目录 `<mod_name>/`。
2. 创建 `config.lua`（填写元数据，`enabled = true`）。
3. 创建 `<mod_name>.lua`（实现 `hook:init`，注册 HOOK）。
4. 确认 `mods/local/mod_main_config.lua` 中 `enabled = true`。
5. 启动游戏，mod 自动加载。

---

## 九、mod 内可访问的全局对象（由 mod_globals.lua 注入）

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

## 十、已有 mod 参考

### enhanced_vesper（厉害的维斯珀）
- 路径：`mods/local/enhanced_vesper/`
- 技术：Hook `E.load`，在加载后 `require` 自定义 scripts/templates 文件
- 特点：通过 `config_skills.lua` 暴露可配置参数

### damage_numbers（伤害数字显示）
- 路径：`mods/local/damage_numbers/`
- 技术：Hook `simulation.do_tick`（读取伤害）+ Hook `game.draw_game`（叠加绘制）
- 特点：纯运行时 Hook，无需资源文件，支持所有游戏版本
- 注意：伤害类型判断直接使用全局常量 `DAMAGE_*` / `DR_*`，不硬编码数值；这些常量由 `all/constants.lua` 在游戏启动时注册为全局变量，mod 初始化时已可用
