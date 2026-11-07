# Generation 包实现计划

## 目标

让本体世代和插件世代使用同一套资源模型：

- generation 自己声明地图、关卡、模板组、资源
- 插件可以从自己的目录加载关卡文件
- 本体关卡按 generation 包组织，表现上等同于“预内置的关卡插件”
- 美术、音乐、字体等共享资源仍由本体集中管理
- 不破坏 custom map 插件地图机制

## 命名约定

### 运行时关卡 key

`store.level_name` 继续作为全局唯一的逻辑 key，例如：

```text
level_kr1_001
level_mygen_001
```

原因是 `wave_db`、`grid_db`、`path_db`、日志和调试工具都可能把它当唯一标识。

### 物理文件

generation 包内可以使用局部文件名：

```text
kr1/generations/kr1/data/levels/level_001.lua
kr1/generations/kr1/data/levels/level_001_data.lua
kr1/generations/kr1/data/waves/level_001_waves_campaign.tsv
kr1/generations/kr1/templates/level_001_templates.lua
```

物理文件由 `gen.resource_root` 定位，不再要求文件名里出现 `kr1`。

也就是说：

- 文件内容/文件名：可以局部化
- 运行时唯一 key：保持全局唯一

### 模板组

`required_templates` 强制写完整模块路径，不提供前缀机制。

本体：

```lua
required_templates = {
    "kr1.template_groups.level_kr1_001_templates",
}
```

插件：

```lua
required_templates = {
    "MyMap.templates.level_001_templates",
}
```

加载时直接：

```lua
require(required_templates[i])
```

插件地图可以引用不同目录下的模板文件，只需要写完整模块路径。

## Generation 描述符

```lua
{
    name = "mygen",
    order = 70,
    label_key = "MAP_UI_GEN_MYGEN",

    kind = "standard",

    resource_root = "plugins/MyGen",

    map = require("MyGen.map"),

    levels = {
        count = 10,
        ranges = {{1, 10}},
        main_campaign_last = 10,
    },

    upgrades = {
        default_line = "1",
    },

    resources = {
        map = {...},
    },
}
```

### 科技线

科技线与 generation 无关：

- 科技线仍是全局 registry
- 每个 generation 只独立保存 `list_id` 和升级等级
- 不按 generation 过滤科技线
- 不再使用 `gen.upgrades.lines`

## 资源加载

新增 generation 资源根：

```lua
gen.resource_root = "plugins/MyGen"
```

搜索顺序：

```text
EDITOR_PATH
gen.resource_root
CUSTOM_MAP_ROOT（仅 custom map）
KR_PATH_GAME
```

涉及：

- `all/level_utils.lua`
- `all/grid_db.lua`
- `all/path_db.lua`
- `all/wave_db.lua`
- `all/scripts.lua` / `kr1/game_scripts.lua` 的 `load_file`

`custom map` 的 `CUSTOM_MAP_ROOT` 行为保持不变。

## 地图数据归属

每个 generation 自己提供地图数据模块：

```text
kr1/generations/kr1/data/map_points.lua
kr1/generations/kr1/data/map_animations.lua
kr1/generations/kr1/data/map_decos.lua
kr1/generations/kr1/data/level_data.lua
```

插件：

```text
plugins/MyGen/data/map_points.lua
plugins/MyGen/data/map_animations.lua
plugins/MyGen/data/map_decos.lua
plugins/MyGen/data/level_data.lua
```

地图背景、音乐、缩略图、战斗/准备音乐等描述字段仍由 generation 的 `init.lua` 通过 `common.standard` 声明。

`gen.map` 负责：

- 背景
- 地图动画
- 地图装饰
- 地图点位/旗帜
- level select 数据
- 缩略图 key
- 战斗/准备音乐

`MapView`、`LevelSelectView` 不再依赖全局 `map_data`。

## 存档布局

每个 slot 一个文件夹，每个 generation 一个文件：

```text
saves/
  slot_1/
    meta.lua
    kr1.lua
    kr2.lua
    kr3.lua
    kr5.lua
    kr6.lua
    custom.lua
    mygen.lua
```

`meta.lua`：

- `schema_version`
- `last_generation`
- `last_victory`
- `difficulty`
- `heroes`
- `spell_power_id`

`<gen>.lua`：

- `levels`
- `upgrades = {list_id, levels}`

插件移除后保留 generation 文件；插件重新出现时自动恢复。`last_generation` 失效时回退到 `kr1`。

## 实施阶段

### 阶段 A：资源根与模板命名空间

- [x] descriptor 增加 `resource_root`
- [x] `required_templates` 强制完整模块路径
- [x] `LU/GR/P/W` 支持 generation 资源根
- [x] `load_file` 使用当前 generation 资源根
- [x] custom map 继续使用 `CUSTOM_MAP_ROOT`

### 阶段 B：地图数据 generation 化

- [x] 拆出 `kr1/generations/<gen>/data/map_points.lua`
- [x] 拆出 `kr1/generations/<gen>/data/map_animations.lua`
- [x] 拆出 `kr1/generations/<gen>/data/map_decos.lua`
- [x] 拆出 `kr1/generations/<gen>/data/level_data.lua`
- [x] `MapView` 只读 `gen.map`
- [x] `screen_map.level_data` 改为 `gen.map.level_data`
- [x] 缩略图、音乐从 `gen.map` 读取

### 阶段 C：本体关卡包化

- [x] 关卡文件移入 `kr1/generations/<gen>/data/levels/`
- [x] 波次移入对应 generation 的 `data/waves/`
- [x] 关卡模板组移入对应 generation 的 `templates/`
- [x] 本体文件使用局部文件名
- [x] 本体共享美术/音乐保持集中管理

### 阶段 D：存档分片

- [ ] `slot_<n>/meta.lua`
- [ ] `slot_<n>/<gen>.lua`
- [ ] 旧 `slot_n.lua` 自动迁移并备份
- [ ] 插件移除后保留 generation 文件
- [ ] 总星数按已注册 generation 聚合

### 阶段 E：插件生命周期与工具

- [ ] generation 卸载时资源清理
- [ ] 插件重新启用时重新注册
- [ ] generation 包校验
- [ ] 最小插件 generation 示例
- [ ] 文档和资源引用检查

## 兼容性红线

- `custom map` 机制继续可用，但旧地图若引用旧模板组名需要自行改成新引用方式
- `CUSTOM_MAP_ROOT` 的编辑器、波次、grid、paths、`load_file` 行为不变
- 旧 v1 存档必须迁移到新结构
- 插件移除后旧存档数据不能删除
