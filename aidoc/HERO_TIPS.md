# 英雄移植经验手册

> 本文档总结从 Kingdom Rush FL（kr3/kr5）向 KingdomRushDove（kr1）移植英雄的注意事项与常见错误。
> 每次移植新英雄前请先阅读本文档。

---

## 一、数值调整规则（kr5 英雄）

从 kr5（FL/Alliance）移植的英雄，在 `kr1/data/balance.lua` 中需做以下调整：

| 项目 | 系数 | 适用范围 |
|---|---|---|
| 生命值（`hp_max`/`hp`） | ×1.3（向下取整） | 英雄本体及所有衍生单位 |
| 技能经验获取（`xp_gain`） | ×8 | 所有技能 |
| 终极技冷却（`ultimate.cooldown`） | ×0.8 | 终极技 |

---

## 二、heroes.lua 模板移植要点

### 2.1 基础模板

- kr5 使用 `"hero5"` 基础模板（含 `relic_slot`、`tombstone` 等字段），kr1 不存在 `"hero5"`，必须改为 `"hero"`。

### 2.2 技能必须有 `xp_level_steps`

每个技能（含 ultimate）都必须声明 `xp_level_steps`，否则 `upgrade_skill` 无法正常工作。典型写法（参照同级数英雄如 `hero_muyrn`）：

```lua
-- hr_order 1
tt.hero.skills.skill_a.xp_level_steps = { [2] = 1, [5] = 2, [8] = 3 }
-- hr_order 2
tt.hero.skills.skill_b.xp_level_steps = { [3] = 1, [6] = 2, [9] = 3 }
-- hr_order 3
tt.hero.skills.skill_c.xp_level_steps = { [1] = 1, [4] = 2, [7] = 3 }
-- hr_order 4
tt.hero.skills.skill_d.xp_level_steps = { [2] = 1, [5] = 2, [8] = 3 }
-- ultimate (4级)
tt.hero.skills.ultimate.xp_level_steps = { [1] = 1, [4] = 2, [7] = 3, [10] = 4 }
```

### 2.3 终极技组件

所有有终极技的英雄模板中，**必须**在 `tt.tween` 之类的字段之后显式添加：

```lua
tt.ultimate = { ts = 0, cooldown = b.ultimate.cooldown[1] }
```

### 2.4 英雄头像字段

`heroes.lua` 中有两个独立的头像字段，不能混用：

| 字段 | 用途 | 格式示例 |
|---|---|---|
| `tt.info.hero_portrait` | 英雄殿堂选择 UI | `"kr5_hero_portraits_0015"` |
| `tt.info.portrait` | 游戏内信息面板 | `"kr5_info_portraits_heroes_0015"` |

### 2.5 `get_info` 函数

不要在脚本中自定义 `scripts.hero_xxx.get_info`，统一使用：

```lua
tt.info.fn = scripts.hero_basic.get_info
```

### 2.6 tween 组件规范

**kr1 的 `tween_prop.sprite_id` 只接受单个整数，不接受数组！**

FL/kr5 中有 `sprite_id = {2, 3}` 的写法（对多个精灵同时应用 tween），kr1 会在 `systems.lua:on_insert` 处崩溃（`attempt to index local 'sprite' (a nil value)`）。

正确做法：每个精灵单独创建一个 `tween_prop`：

```lua
-- 错误（FL写法）：
tt.tween.props[2].sprite_id = { 2, 3 }

-- 正确（kr1写法）：
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
-- ...
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].sprite_id = 3
-- ...
```

拆分后，脚本中所有对这些 props 的引用（`disabled`、`ts`）也要同步更新。

---

## 三、hero_scripts.lua 脚本移植要点

### 3.1 `level_up` 函数

kr1 不使用 FL 的 `if initial and s.level > 0` 模式，必须改为：

```lua
function scripts.hero_xxx.level_up(this, store, initial)
    level_up_basic(this)
    upgrade_skill(this, "skill_a", function(this, s) ... end)
    upgrade_skill(this, "skill_b", function(this, s) ... end)
    -- ...
end
```

- `level_up_basic(this)` 自动处理 `hp_max`、`armor`、`magic_armor`、`regen`（不从 balance 读 `regen`，由 `hp_max × GS.soldier_regen_factor` 计算）。
- `upgrade_skill(this, name, fn)` 从 `s.xp_level_steps[this.hero.level]` 读取升级阶段。

### 3.2 终极技释放逻辑

dove 版所有英雄的终极技均为**手动释放**，在 `scripts.xxx.update` 中需要：

```lua
if ready_to_use_skill(this.ultimate, store) then
	if not this.ultimate_active then
		local ue = E:create_entity(this.hero.skills.ultimate.controller_name)
		queue_insert(store, ue)
		this.ultimate.ts = store.tick_ts
		SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
	else
		this.ultimate.ts = this.ultimate.ts + 1 -- 已激活时跳过冷却
	end
end
```

### 3.3 FL 专有代码必须删除

以下 FL/kr5 特有代码在 dove 中**不存在**，移植时必须删除或替换：

| FL 代码 | 处理方式 |
|---|---|
| `store.selected_team` | 直接删除 |
| `signal.emit("lock-user-power")` / `"unlock-user-power"` | 直接删除 |
| `SU.y_hero_death_and_respawn_kr5(...)` | 改为 `SU.y_hero_death_and_respawn(...)` |
| `SU.alliance_merciless_upgrade` / `SU.alliance_corageous_upgrade` | 直接删除 |
| `SU.heroes_visual_learning_upgrade` / `SU.heroes_lone_wolves_upgrade` | 直接删除 |
| `KR_GAME == "kr5" and X or Y` | 直接替换为 `Y`（dove 的 `KR_GAME` 永远是 `"kr1"`） |

> **注意**：删除前先确认所在函数的上下文，避免误删必要逻辑。`SU.y_hero_wait` 和 `SU.y_hero_animation_wait` 在 dove 中**存在**（`all/script_utils.lua:4634-4635` 的别名），不要删除。

### 3.4 动画名称

dove 使用 `"levelup"` 而不是 `"lvlup"`：

```lua
-- 错误：
U.y_animation_play_group(this, "hero_xxx_hero_lvlup", ...)
-- 正确：
U.y_animation_play_group(this, "levelup", nil, store.tick_ts, 1, this.render.sprites[1].group)
```

动画名称需通过动画文件（`_assets/` 目录下的 `.exo` 文件）确认正确名称。

### 3.5 衍生修饰符对目标的安全访问

当一个 modifier 脚本可能被应用到多种目标（如有不同 `tween.props` 数量的基础版和强化版士兵）时，访问 `props[N]` 前必须先检查：

```lua
if #target.tween.props > 1 then
	target.tween.props[2].disabled = false
	-- ...
end
```

---

## 四、士兵头像

**移植 kr5 英雄召唤的士兵时，头像字段不能使用 FL 格式！**

| 错误（FL 格式，不存在） | 正确（dove 格式） |
|---|---|
| `"gui_bottom_info_image_soldiers_0050"` | `"kr5_info_portraits_soldiers_XXXX"` |

- 错误的头像 key 会直接导致游戏**启动时崩溃**（`Image xxx not found in database`）。
- 在 `kr1/game_templates.lua` 搜索 `kr5_info_portraits_soldiers_` 找已有的有效值。
- 若没有对应士兵的专属头像，优先找**视觉相同或相似单位**使用的头像（如 `soldier_arborean_barrack` 与树灵召唤兵共用 `kr5_info_portraits_soldiers_0032`）。

---

## 五、英雄殿堂（Hero Room）

每个新英雄需要在以下**四处**补充内容：

### 5.1 `kr1-desktop/data/map_data.lua`

在 `hero_data` 列表中添加英雄条目：

```lua
{
    from_kr = 5,
    portrait = 15,   -- 对应大图编号
    thumb = 15,
    name = "hero_dragon_arb",
    available_level = 116,
    starting_level = 1,
    icon = 15,
    stats = {8, 4, 7, 5}
}
```

### 5.2 `kr1-desktop/data/kui_templates/hero_room_view.lua`

在英雄大图列表（`portrait_hero_wukong` 之后）添加英雄大图项：

```lua
{
    id = "portrait_hero_dragon_arb",
    hidden = true,
    class = "KView",
    children = {{
        class = "KImageView",
        image_name = "kr5_portrait_notxt_0015"   -- 大图资源 key
    }, {
        id = "name_img",
        image_name = "hero_room_portraits_name_0000",
        class = "KImageView"
    }},
    pos = hero_portraits_pos,
    scale = hero_portraits_scale
},
```

- 大图资源 key 格式为 `kr5_portrait_notxt_XXXX`，可用编号参见 `_assets/kr1-desktop/images/fullhd/hero_room.lua`。
- 缺少此项会导致英雄殿堂中无法正常显示大图。

### 5.3 `_assets/kr1-desktop/strings/zh-Hans.lua`

需要添加两个 i18n key（key 格式 = `{info.i18n_key}_DESCRIPTION` 和 `_SPECIAL`）：

```lua
HERO_DRAGON_ARB_DESCRIPTION = "英雄简介文本……",
HERO_DRAGON_ARB_SPECIAL = "技能A，技能B，技能C，技能D，技能E",
```

- `_DESCRIPTION`：显示在英雄殿堂下方的简介区域。
- `_SPECIAL`：显示技能名称列表。
- 注意：文件中已有的 `HERO_XXX_DESC` 是 FL 格式的旧 key，**不是** dove 所用的 key。

### 5.4 `_assets/kr1-desktop/strings/hero_room_special.lua`

在文件末尾（`return H` 之前）添加技能说明块，使用 `set_hero` + `blc = balance.hero_xxx.skill_name` 的模式，根据代码执行逻辑给出准确描述。注意：

- 该文件中 `balance` 已是 `balance.heroes`，直接用 `balance.hero_xxx` 访问。
- `tail(name)` = `table.tail(blc[name])`，取最高等级值。
- `health[]`、`d[]`、`cooldown`、`duration`、`factor`、`count` 等变量为文件共享变量，直接赋值即可。
- 描述要反映代码的实际执行逻辑，参数数值从 balance 中动态获取。

---

## 六、快速检查清单

移植完成后，逐项核对：

- [ ] `hero5` → `hero` 基础模板
- [ ] 所有技能含 `xp_level_steps`
- [ ] `tt.ultimate = { ts=0, cooldown=... }` 已添加
- [ ] `level_up` 使用 `level_up_basic` + `upgrade_skill` 模式
- [ ] `update` 中有 `ready_to_use_skill(this.ultimate, store)` 块
- [ ] 已删除所有 FL 专有代码（`selected_team`、`lock/unlock-user-power`、`kr5` 函数等）
- [ ] 动画名称使用 `"levelup"` 而非 `"lvlup"`
- [ ] `tween_prop.sprite_id` 均为单个整数
- [ ] 修饰符访问目标 `tween.props[N]` 前有 `#props > N-1` 的安全检查
- [ ] 士兵头像使用 `kr5_info_portraits_soldiers_XXXX` 格式
- [ ] `info.hero_portrait` 和 `info.portrait` 填写正确（两个不同字段）
- [ ] `map_data.lua` 已添加英雄条目
- [ ] `hero_room_view.lua` 已添加大图项
- [ ] `zh-Hans.lua` 已添加 `_DESCRIPTION` 和 `_SPECIAL`
- [ ] `hero_room_special.lua` 已添加技能描述块
- [ ] balance 数值已应用 kr5→kr1 调整系数

---

*最后更新：2026-03-05（移植 hero_dragon_arb 后总结）*
