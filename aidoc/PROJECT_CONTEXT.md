# KingdomRushDove 项目全局上下文

> 本文档为跨会话共享记忆文档，综合整理项目架构、核心系统、开发规范及已有 mod 信息。
> 更新时间：2026-03-05

---

## 一、项目概述

**KingdomRushDove**（王国保卫战 dove 版）是基于 [LÖVE2D](https://love2d.org/)（`love 11.5`）框架开发的王国保卫战改版游戏，使用 **Lua** 编写全部游戏逻辑。

- **版本标识**：`kr1-desktop-5.6.12`，`id = "9.7.1"`
- **游戏标识**：`KR_GAME = "kr1"`，`KR_TARGET = "desktop"`，`KR_PLATFORM = "win32"`
- **文件系统 identity**：`"kingdom_rush"`（存档目录名）
- **服务器仓库**：`ssh://dove@10.112.99.5:60001/srv/git/KingdomRushDove.git`（本地私有服务器，非 GitHub）

---

## 二、目录结构

```
KingdomRushDove/
├── main.lua                  # 程序入口，LÖVE 回调注册，加载流程控制
├── main_globals.lua          # 全局常量：KR_GAME / KR_TARGET / KR_PLATFORM
├── conf.lua                  # LÖVE 配置（禁用 physics / joystick）
├── version.lua               # 版本信息
├── args.lua                  # 调试启动参数
├── all/                      # 所有游戏版本共用的核心代码
│   ├── constants.lua         # 全局常量（伤害类型、Z层级、FPS、尺寸等）
│   ├── simulation.lua        # ECS 调度核心
│   ├── systems.lua           # 所有 ECS 系统定义（4000+ 行）
│   ├── entity_db.lua         # 实体模板数据库（E）
│   ├── components.lua        # 组件定义（health/pos/render 等）
│   ├── templates.lua         # 实体模板注册（敌人/子弹/特效等）
│   ├── game.lua              # 游戏主对象（game），管理关卡生命周期
│   ├── director.lua          # 场景导演（director），管理屏幕切换
│   ├── game_gui.lua          / 游戏内 HUD（desktop 版在 all-desktop/）
│   ├── wave_db.lua           # 波次数据库
│   ├── path_db.lua           # 路径数据库（寻路）
│   ├── grid_db.lua           # 格子数据库（塔放置）
│   ├── animation_db.lua      # 动画数据库
│   ├── sound_db.lua          # 音效数据库
│   ├── seek.lua              # 索敌逻辑（空间哈希 + 路径）
│   ├── spatial_index.lua     # 空间索引（哈希格，FFI优化）
│   ├── render_utils.lua      # 渲染工具
│   ├── exoskeleton.lua       # 骨骼动画系统（EXO，.exo3/.exo/.lua 格式）
│   ├── storage.lua           # 存档系统
│   ├── difficulty.lua        # 难度系统
│   ├── upgrades.lua          # 游戏升级系统
│   ├── utils.lua             # 通用工具（U）
│   ├── script_utils.lua      # 脚本工具（SU）
│   ├── level_utils.lua       # 关卡工具（LU）
│   ├── i18n.lua              # 国际化
│   ├── render_sort.c         # 渲染排序 C 源码（FFI 编译成 .so/.dll）
│   ├── librender_sort.so     # Linux 渲染排序库
│   └── librender_sort.dll    # Windows 渲染排序库
├── all-desktop/              # 桌面端专用覆盖代码
│   ├── game_gui.lua          # 桌面版游戏内 HUD
│   ├── screen_map.lua        # 地图选关屏幕
│   ├── screen_settings.lua   # 设置屏幕
│   ├── screen_slots.lua      # 存档槽位屏幕
│   └── screen_loading.lua    # 加载屏幕
├── kr1/                      # kr1 版本专用逻辑
│   ├── game_settings.lua     # 塔/英雄分类列表（GS）
│   ├── game_templates.lua    # kr1 实体模板
│   ├── enemies.lua           # 敌人定义
│   ├── boss.lua / hero_boss.lua # Boss 定义
│   ├── heroes.lua            # 英雄定义
│   ├── archer_towers.lua     # 弓箭塔定义
│   ├── mage_towers.lua       # 法师塔定义
│   ├── engineer_towers.lua   # 工程师塔定义
│   ├── barrack_towers.lua    # 兵营定义
│   ├── tower_scripts.lua     # 塔脚本
│   ├── hero_scripts.lua      # 英雄脚本
│   ├── boss_scripts.lua      # Boss 脚本
│   ├── game_scripts.lua      # 游戏脚本（协程逻辑）
│   ├── upgrades.lua          # 升级数据
│   └── data/                 # 关卡/波次/动画/平衡数据
│       ├── levels/           # 关卡 lua 文件
│       ├── waves/            # 波次 lua 文件
│       ├── balance.lua       # 数值平衡
│       └── exoskeletons/     # 骨骼动画数据
├── _assets/                  # 资源索引（不含实际图片/音频）
│   └── assets_index.lua      # 资源路径索引
├── mods/                     # Mod 系统
│   ├── mod_main.lua          # Mod 系统入口
│   ├── mod_hook.lua          # 系统级资源覆盖钩子
│   ├── mod_globals.lua       # 全局变量注入
│   ├── mod_main_config.lua   # Mod 系统默认配置模板
│   ├── all/                  # Mod 公共工具（hook_utils / mod_db / mod_utils）
│   ├── mod_template/         # Mod 开发模板（示例）
│   └── local/                # 用户安装的 mod（不纳入版控）
│       ├── mod_main_config.lua  # 本地配置（enabled=true 启用 mod 系统）
│       ├── damage_numbers/   # 已有 mod：伤害数字显示
│       └── enhanced_vesper/  # 已有 mod：增强维斯珀英雄
├── dove_modules/             # dove 版特有功能模块
│   ├── perf/                 # 性能计数器（perf.lua / perf_ui.lua）
│   ├── updater/              # 自动更新管理器
│   ├── gui/                  # 自定义 GUI（boss_health_bar / mod_manager_view）
│   └── notice/               # 公告（must_read / author_words）
├── lib/                      # 第三方/通用库
│   ├── klua/                 # Lua 工具库（log, table, vector, macros...）
│   ├── klove/                # LÖVE 专用库（image_db, font_db, shader_db...）
│   ├── hump/                 # HUMP 库（vector-light, signal）
│   └── ...                   # json, serpent, middleclass 等
├── patches/                  # 补丁文件（default.lua 等）
├── scripts/                  # 开发辅助脚本（gen_assets_index.lua 等）
├── makefiles/                # Makefile 辅助文件
├── client / client.exe       # 资源同步客户端（需联系作者获取）
└── aidoc/                    # AI 文档（本目录）
```

---

## 三、启动流程

```
love.run()
  → load(arg)
      → 挂载资源（fused 模式下挂载 .dat 文件）
      → storage:load_settings() → main.params
      → MU.basic_init() / parse_args / default_params
      → main:set_locale(locale)
      → loader:load()   ← 顺序加载以下 4 个阶段
          1. "settings"        → screen_settings 设置屏幕
          2. "must_read"       → dove_modules.notice.must_read 必读公告
          3. "update_manager"  → dove_modules.updater.update_manager 更新检查
          4. "director"        → director:init() + mod_main:init(director)
  → love.update(dt) → main.handler:update(dt)
  → love.draw()     → main.handler:draw()
```

`main.handler` 是当前活跃的场景对象，随阶段切换而替换。

**Mod 系统在 `director:init()` 之后、`mod_main:after_init()` 中完成注册**，保证核心系统先初始化。

---

## 四、核心架构：ECS（实体-组件-系统）

### 4.1 三大核心对象

| 对象 | 类型 | 说明 |
|------|------|------|
| `E` (`entity_db`) | 全局单例 | 模板/组件注册中心；`E:register_c(name)` 注册组件，`E:register_t(name)` 注册模板，`E:create_entity(name)` 实例化 |
| `simulation` | 全局单例 | ECS 调度器，驱动所有系统，管理实体生命周期 |
| `game` | 全局对象 | 游戏主对象，持有 `store`、`camera`、`game_scale`，管理关卡渲染 |

### 4.2 store — 游戏数据中心

`game.store` 是贯穿整个游戏的数据中心，由 `simulation` 持有和驱动：

| 字段 | 说明 |
|------|------|
| `store.entities` | id → entity，所有活跃实体 |
| `store.enemies` / `store.soldiers` / `store.towers` | 分类快速索引 |
| `store.modifiers` / `store.auras` | 修饰器/光环索引 |
| `store.particle_systems` | 粒子系统索引 |
| `store.entities_with_render/tween/timed/lights/ui` | 按组件类型的快速索引 |
| `store.damage_queue` | 待结算伤害队列（通过 `queue_damage(store, d)` 写入） |
| `store.damages_applied` | 当帧已结算伤害列表（每帧由 sys.health 更新） |
| `store.render_frames` | 排序后的可渲染帧列表（由 sys.render 维护，渲染层消费） |
| `store.tick_ts` | 游戏累计时间（秒），暂停时不增长 |
| `store.paused` / `store.step` | 暂停/单步模式 |
| `store.speed_factor` | 游戏速度倍数 |
| `store.level_name` / `store.level_idx` | 当前关卡名/序号 |
| `store.pending_inserts` / `store.pending_removals` | 实体插入/移除队列 |
| `store.entity_count` | 当前活跃实体数 |
| `store.game_gui` | game_gui 引用（允许 store 层影响 HUD） |
| `store.last_hooks` | `on_insert/on_remove` 扩展点，供 mod 注入自定义逻辑 |
| `store.ephemeral` | 临时数据，重启时清空 |

### 4.3 simulation 调度流程

```
simulation:do_tick(dt)
  1. tick_ts += dt
  2. 批量处理 pending_inserts（倒序，避免当帧递归）
     → on_queue → on_insert（任意返回 false → 取消插入）
  3. 批量处理 pending_removals
     → on_dequeue → on_remove（任意返回 false → 取消移除）
  4. 依次调用所有系统 on_update(dt, tick_ts, store)
```

### 4.4 系统执行顺序（`game.simulation_systems`）

```lua
"level", "wave_spawn", "wave_spawn_tsv", "mod_lifecycle",
"main_script", "events", "timed", "tween", "endless_patch",
"health",           -- ★ 伤害结算核心
"count_groups", "hero_xp_tracking", "pops",
"goal_line", "tower_upgrade", "game_upgrades",
"texts", "particle_system",
"render",           -- ★ 渲染帧维护与排序
"sound_events", "seen_tracker", "spatial_index",
"last_hook",        -- ★ 最后钩子，维护各分类索引
"lights", "assets_checker", "wave_generator"
```

---

## 五、关键系统详解

### sys.health — 伤害结算

伤害数据结构（`damage` 对象 `d`）：
```lua
d.target_id       -- 目标实体 id
d.source_id       -- 来源实体 id
d.damage_type     -- 伤害类型位标志（DAMAGE_* 常量）
d.value           -- 原始伤害值
d.damage_applied  -- 实际伤害（结算后）
d.damage_result   -- 结果位标志（DR_DAMAGE/DR_KILL/DR_ARMOR/DR_MAGICAL_ARMOR）
d.pop             -- 命中特效实体名列表
d.xp_gain_factor  -- 英雄经验增益系数
d.hooks           -- table of function(entity, damage, protection)，额外伤害结算逻辑
```

### sys.render — 渲染帧排序

排序键优先级：`z` → `sort_y`（越大越后绘制）→ `_draw_order`

Z 层级常量：
```
Z_BACKGROUND=1000, Z_TOWER_BASES=1300, Z_DECALS=1400,
Z_GUI_DECALS=2000, Z_OBJECTS=3000, Z_BULLET_PARTICLES=3200,
Z_EFFECTS=3300, Z_BULLETS=3400, Z_SCREEN_FIXED=3900, Z_GUI=4000
```

非 Android 平台使用 FFI C 归并排序（`librender_sort.so/.dll`）。

### sys.last_hook — 分类索引维护

最后一个 on_insert/on_remove 处理器，维护所有分类快速索引。  
提供 `store.last_hooks.on_insert/on_remove` 扩展点供外部（mod）追加逻辑。

### sys.spatial_index — 空间索引

使用空间哈希（格子大小 `SPATIAL_HASH_CELL_SIZE=50`），配合 `seek.lua` 实现高效范围索敌。FFI 优化（`id_array` C 结构体），Android 上降级为 Lua 实现。

### seek.lua — 索敌

专用索敌模块，只允许 `utils.lua` 调用，不允许其它模块直接调用。

### exoskeleton.lua — 骨骼动画（EXO）

支持 `.exo3`、`.exo`、`.lua` 格式的骨骼动画，数据存于 `kr1/data/exoskeletons/`。

---

## 六、渲染架构要点

- **render 系统**只拥有 sprites，frames 功能全部合并进 sprites，避免每帧大量拷贝开销（dove 版性能优化）。
- 绘制时坐标变换（摄像机）：`rox = -(camera.x * zoom - screen_w * 0.5)`，`gs = game_scale * zoom`。
- Y 轴约定：世界坐标 Y 向上为正，屏幕绘制时做 `REF_H - world_y` 翻转。
- `REF_W=1024, REF_H=768`，游戏参考分辨率。
- `world_offset` 存在时需加到 `rox/roy`。

---

## 七、Mod 系统

### 7.1 架构

```
mods/
├── mod_main.lua          # 入口：扫描/加载/初始化所有启用 mod
├── mod_hook.lua          # 系统级资源覆盖（图集/音效/关卡/波次）
├── mod_globals.lua       # 全局变量注入（simulation/game/E/U/signal 等）
├── mod_main_config.lua   # 默认配置模板
├── all/
│   ├── hook_utils.lua    # HOOK/UNHOOK/CALL_ORIGINAL
│   ├── mod_db.lua        # Mod 数据库（扫描/排序）
│   └── mod_utils.lua     # 路径工具
└── local/                # 用户安装的 mod（不纳入版控）
```

### 7.2 加载顺序

```
mod_main:init(director)
  → mod_db:init()          # 扫描 mods/local/，按 priority 排序
  → director:init(params)  # 核心游戏初始化
  → mod_main:after_init()
      → 正序为每个 mod 添加 require 路径
      → 倒序 require 每个 mod（得到 hook 表）
      → 正序调用 hook:init(mod_data)（高优先级覆盖低优先级）
      → mod_hook:after_init()（注册资源覆盖钩子）
```

### 7.3 hook_utils — 钩子机制

```lua
HOOK(obj, fn_name, handler, priority?)
-- 调用链：handler1(next1,...) → handler2(next2,...) → ... → original(...)
-- handler 签名：function(next, self_or_first_arg, ...)
UNHOOK(obj, fn_name, handler)
CALL_ORIGINAL(obj, fn_name, ...)
```

### 7.4 config.lua 结构

```lua
return {
    name = "mod名称",
    version = "1.0",
    game_version = {"kr1"},
    enabled = true,
    priority = 0,   -- 越小越先初始化（高优先级）
}
```

### 7.5 mod 主文件结构

```lua
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()

function hook:init(mod_data)
    HOOK(some_object, "method_name", self.some_object.method_name)
end

function hook.some_object.method_name(next, self, ...)
    next(self, ...)   -- 调用原始/下一个钩子
    -- 自定义逻辑
end

return hook
```

### 7.6 mod 内全局可用对象（由 mod_globals.lua 注入）

| 全局变量 | 说明 |
|---------|------|
| `simulation` | ECS 调度器 |
| `game` | 游戏主对象（含 `store`, `camera`, `game_scale`, `draw_game`） |
| `E` | 实体数据库 |
| `V` / `V.v(x,y)` | 向量工具 |
| `signal` | 事件信号系统（lib.hump.signal） |
| `SH` | Shader 数据库 |
| `UPGR` | 升级数据 |
| `storage` | 存档系统 |
| `SU` | 脚本工具 |
| `U` | 通用工具 |
| `RT/AC/CC/T` | 模板注册/添加组件/克隆组件/获取模板 |
| `queue_insert/queue_remove/queue_damage` | 实体/伤害队列操作 |
| `fts(v)` | 帧转秒（`v / FPS`，`FPS=30`） |
| `d2r(d)` | 角度转弧度 |
| `IS_KR5` | 是否为 kr5 版本 |
| `IS_LOVE_11` | 是否为 LÖVE 11+ |
| `DAMAGE_*` / `DR_*` | 伤害类型/结果常量（来自 constants.lua） |

### 7.7 系统级资源覆盖（mod_hook）

mod 只需在对应目录放置文件即可触发：

| 钩子目标 | mod 文件位置 | 效果 |
|---------|------------|------|
| `I.load_atlas` / `queue_load_atlas` | `mod/_assets/images/<name>.lua` | 覆盖图集 |
| `S.init` | `mod/_assets/sounds/settings.lua` | 覆盖音效配置 |
| `S.load_group` | `mod/_assets/sounds/files/` | 覆盖音效文件 |
| `LU.load_level` | `mod/data/levels/` | 覆盖关卡数据 |
| `P.load` | `mod/data/waves/` | 覆盖波次路径 |

---

## 八、已有 Mod

### damage_numbers（伤害数字显示）

- 路径：`mods/local/damage_numbers/`
- 技术：Hook `simulation.do_tick`（每帧末读 `store.damages_applied`）+ Hook `game.draw_game`（叠加浮动文字）
- 实现亮点：FFI `DNum` 结构体池（300槽环形写入），避免 GC；颜色按 `DAMAGE_*` 类型映射；字号/速度按伤害占 HP 比例分级
- 坐标约定：屏幕-Y 空间（`y = REF_H - world_y`），vy < 0 = 向上

### enhanced_vesper（增强维斯珀英雄）

- 路径：`mods/local/enhanced_vesper/`
- 技术：Hook `E.load`，加载后 require 自定义 scripts/templates 文件
- 特点：通过 `config_skills.lua` 暴露可配置技能参数

---

## 九、伤害类型常量（DAMAGE_*）

```lua
DAMAGE_TRUE=1, DAMAGE_PHYSICAL=2, DAMAGE_MAGICAL=4,
DAMAGE_EXPLOSION=8, DAMAGE_ELECTRICAL=16, DAMAGE_MAGICAL_EXPLOSION=32,
DAMAGE_SHOT=64, DAMAGE_RUDE=128, DAMAGE_STAB=256, DAMAGE_MIXED=512,
DAMAGE_ARMOR=1024, DAMAGE_MAGICAL_ARMOR=2048,
DAMAGE_INSTAKILL=4096, DAMAGE_DISINTEGRATE=8192,
DAMAGE_EAT=16384, DAMAGE_HOST=32768,
DAMAGE_POISON=65536, DAMAGE_AGAINST_ARMOR=131072, DAMAGE_AGAINST_MAGIC_ARMOR=262144,
DAMAGE_NO_KILL=8388608, DAMAGE_NO_SPAWNS=16777216, DAMAGE_NO_DODGE=33554432,
DAMAGE_NO_LIFESTEAL=67108864, DAMAGE_NO_SHIELD_HIT=134217728,
DAMAGE_ONE_SHIELD_HIT=268435456, DAMAGE_IGNORE_SHIELD=536870912,
DAMAGE_FX_NOT_EXPLODE=1073741824, DAMAGE_FX_EXPLODE=2147483648
-- 组合
DAMAGE_MAGICAL_GROUP = DAMAGE_MAGICAL + DAMAGE_MAGICAL_EXPLOSION + DAMAGE_AGAINST_MAGIC_ARMOR
DAMAGE_PHYSICAL_GROUP = DAMAGE_PHYSICAL + DAMAGE_EXPLOSION + DAMAGE_SHOT + DAMAGE_RUDE + DAMAGE_STAB + DAMAGE_ELECTRICAL + DAMAGE_AGAINST_ARMOR
-- 结果标志
DR_NONE=0, DR_DAMAGE=1, DR_KILL=2, DR_ARMOR=4, DR_MAGICAL_ARMOR=8
```

---

## 十、开发规范与禁忌

- **禁止**直接修改 `enemy.can_do_magic`
- **禁止**直接修改 `tween` 的 `sprite_id`
- **禁止**将 `damage` 作为 component（damage 是事件数据，不是组件）
- **禁止**在 `tween_prop.keys` 中用 `key[3]` 指定插值方法，只能通过 `tween_prop.interp` 指定
- **禁止**直接修改 `sprite` 的 `draw_order`，必须调用 `U.change_sprite_draw_order()`
- **建议**只运行一次的 `tween` 将 `run_once` 赋为 `true`
- UI `colors.tint` 使用**归一化参数**（0~1）
- KView 中的 `alpha` 是归一化的
- scripts 的 require 关系：`scripts → hero_scripts → tower_scripts → boss_scripts`（链式，保证插件跳转功能正常）

---

## 十一、路径解析机制

`main.lua` 注册了自定义 `package.searcher`，按以下根目录顺序查找模块：

```lua
"",          -- 当前目录
"src",
"lib",
"all",
"all-desktop",   -- all-{KR_TARGET}
"kr1",           -- KR_GAME
"kr1-desktop",   -- {KR_GAME}-{KR_TARGET}
"_assets",
"_assets/all-desktop",
"_assets/kr1-desktop",
"mods",
"mods/all",
"mods/local"
```

因此 `require("game")` 会在这些路径中依次查找 `game.lua`，`require("data.xxx")` 会在每个根目录下查找 `data/xxx.lua`。

---

## 十二、存档系统

- 存档文件：`slot_1.lua` / `slot_2.lua` / `slot_3.lua`（LÖVE filesystem identity 目录下）
- 设置文件：`settings.lua`
- 关键字段：`levels`（关卡通关状态）、`upgrades`（升级列表）、`heroes`（英雄数据）、`gems`、`bag`
- 每次进入对局时通过 `storage:load_slot()` 加载，系统初始化时 `UP:set_levels(slot.upgrades)` 应用

---

## 十三、性能工具

`dove_modules/perf/perf.lua` 提供性能计数器：

```lua
perf.start("draw")  -- 开始计时
perf.stop("draw")   -- 结束计时
perf.reset()        -- 每帧重置
```

`perf_ui.lua` 在屏幕上叠加绘制各项耗时数据（每帧 `updated = true` 时同步）。

---

## 十四、资源系统

- 美术资源（图集/音效）**不纳入版控**，通过 `client.exe --sync-assets` 同步
- 资源索引由 `lua ./scripts/gen_assets_index.lua` 生成，输出到 `_assets/assets_index.lua`
- 打包发布时资源存于 `all-desktop.dat` / `kr1-desktop.dat`（fused 模式挂载）
- 图集数据库：`lib/klove/image_db.lua`（`I`），字体数据库：`lib/klove/font_db.lua`（`F`）

---

## 十五、格式化规范

使用专有 VSCode 插件 `dlfmt` 格式化（配置见 `dlfmt_task.json`）。  
提交前必须右键 `dlfmt_task.json` 运行 JSON 任务，确保格式一致且必要数据资源已压缩。

---

## 十六、关联文档（aidoc/）

| 文件 | 内容 |
|------|------|
| `simulation_understanding.md` | simulation.lua 详解（ECS 调度、实体生命周期、store 字段） |
| `systems_understanding.md` | systems.lua 详解（各系统钩子、伤害结算、渲染排序） |
| `mods_understanding.md` | mods/ 目录详解（加载流程、hook 机制、mod 开发步骤） |
| `PROJECT_CONTEXT.md` | **本文件**（全局概览，跨会话共享记忆） |
