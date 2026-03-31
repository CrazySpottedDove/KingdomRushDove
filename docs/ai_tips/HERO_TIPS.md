# 英雄移植经验手册

> 本文档总结从 Kingdom Rush FL（kr3/kr5）向 KingdomRushDove（kr1）移植英雄的注意事项与常见错误。
> 每次移植新英雄前请先阅读本文档。

---

## 一、数值调整规则（kr5 英雄）

从 kr5（FL/Alliance）移植的英雄，在 `kr1/data/balance.lua` 中需做以下调整：

| 项目 | 系数 | 适用范围 |
|---|---|---|
| 生命值（`hp_max`/`hp`） | ×1.3（向下取整） | 英雄本体及所有衍生单位（士兵、召唤物等子表中的 `hp_max`） |
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

dove 版所有英雄的终极技均为**自动释放**（当冷却完成且有敌人时自动触发）。FL 源码中没有这段逻辑，**必须手动添加**，插在 `SU.hero_level_up` 检查之后，第一个技能判断之前：

```lua
if ready_to_use_skill(this.ultimate, store) then
	local target = U.find_foremost_enemy_in_range_filter_off(this.pos, 200, 0, F_AREA, 0)

	if target and target.pos then
		local e = E:create_entity(this.hero.skills.ultimate.controller_name)

		e.level = this.hero.skills.ultimate.level
		e.pos = V.vclone(target.pos)

		queue_insert(store, e)

		this.ultimate.ts = store.tick_ts

		SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
	else
		this.ultimate.ts = this.ultimate.ts + 1
	end
end
```

- 范围 200 是通用值；如果英雄技能范围明显更大/更小可以调整
- `e.pos` 设置为目标敌人位置，让 controller 在敌人附近找路径节点
- 没有敌人时 `ts + 1` 表示等待，不消耗冷却

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

## 六、批量移植常见运行时错误（2026-03-06 总结）

### 6.1 FX 模板未定义

**错误**：`entity_db.error create_entity() - template fx_xxx not found`

**原因**：FL 中某些 FX 模板是在文件前半段（全局 FX 区）定义的，而不在英雄模板附近。移植时只复制了英雄主模板部分，遗漏了这些 FX 定义。

**修复**：在英雄模板块之前，显式用 `RT(name, base)` 注册所有被英雄引用的 FX。示例：

```lua
tt = RT("fx_hero_builder_melee_attack_hit", "fx")
tt.render.sprites[1].name = "hero_obdul_basic_attack_hit"

tt = RT("fx_hero_builder_overtime_work_raise", "fx")
tt.render.sprites[1].name = "hero_obdul_skill_5_soldier_spawn_decal"
tt.render.sprites[1].z = Z_DECALS
```

**排查方法**：搜索英雄模板中所有 `.hit_fx`、`.spawn_fx`、`.fx`、`.aura`、`.bullet` 字段，确保每个被引用的模板名称都有对应的 `RT(...)` 定义。

### 6.2 直接修改 `motion.max_speed` 会被 dove 运动系统忽略

**错误**：英雄速度未生效，或速度修改没有同步到 `real_speed`。

**原因**：dove 的 `U.real_max_speed()` 综合了 `max_speed + buff * factor`，直接赋值 `this.motion.max_speed = x` 不会更新 `real_speed`。

**正确 API**（全部在 `all/utils.lua` 中定义）：

| 场景 | 调用方式 |
|---|---|
| 重置到指定值 | `U.update_max_speed(entity, value)` |
| 技能/状态导致的永久加速 | `U.speed_inc_self(entity, amount)` |
| 技能/状态导致的永久减速 | `U.speed_dec_self(entity, amount)` |
| 乘以系数 | `U.speed_mul_self(entity, factor)` |
| 除以系数 | `U.speed_div_self(entity, factor)` |
| 外部 buff 加速（临时） | `U.speed_inc(entity, amount)` |
| 外部 buff 减速（临时） | `U.speed_dec(entity, amount)` |

**注意**：`speed_inc_self` 和 `speed_dec_self` 对称使用，需要在效果结束时调用对应的 dec/inc 来还原，不能用 `original_speed` 变量暂存再恢复，因为多次叠加后直接赋原值会破坏其他效果。

### 6.3 FL 专有函数导致崩溃

以下函数在 dove 中不存在，必须删除或替换：

| FL 调用 | dove 处理方式 |
|---|---|
| `y_hero_melee_block_and_attacks(store, this)` | 改为 `SU.y_soldier_melee_block_and_attacks(store, this)` |
| `y_hero_ranged_attacks(store, this)` | 改为 `SU.y_soldier_ranged_attacks(store, this)` |
| `SU.heroes_visual_learning_upgrade(store, this)` | 删除（dove 不需要） |
| `SU.heroes_lone_wolves_upgrade(store, this)` | 删除（dove 不需要） |
| `SU.y_hero_death_and_respawn_kr5(...)` | 改为 `SU.y_hero_death_and_respawn(...)` |

### 6.4 声音资源缺失

**错误**：英雄嘲讽、死亡、出场音效无声。

**原因**：FL 的语音条目（Taunt/TauntIntro/TauntSelect/Death）存放在 `5_sounds.lua` 或 `kr4_sounds.lua` 等单独文件中，而 SFX 条目在 `sounds.lua` 中，容易遗漏语音部分。

**修复**：移植时必须同时检查 FL 的 `5_sounds.lua`，将所有 `HeroXxxTaunt`、`HeroXxxTauntIntro`、`HeroXxxTauntSelect`、`HeroXxxDeath` 条目添加到 dove 的 `_assets/kr1-desktop/sounds/sounds.lua`。

### 6.5 FL 专有基础模板 `bombKR5` 不存在于 dove

**错误**：`entity_db.error create_entity() - template bombKR5 not found`

**原因**：FL 中定义了 `bombKR5`（继承自 `bomb`，添加了 `damage_decay_random = false`、自定义 `hit_decal`、自定义脚本等），但 dove 已将这些内容合并进 `bomb` 基础模板，不再单独存在 `bombKR5`。

**修复**：将所有 `RT("xxx", "bombKR5")` 改为 `RT("xxx", "bomb")`，并手动补上 `bombKR5` 相对于 `bomb` 额外设置的字段（主要是 `tt.bullet.damage_decay_random = false`）：

```lua
-- 错误写法（FL 风格）
tt = RT("bullet_hero_mecha_tar_bomb", "bombKR5")

-- 正确写法（dove）
tt = RT("bullet_hero_mecha_tar_bomb", "bomb")
tt.bullet.damage_decay_random = false
```

**注意**：dove 的 `bomb` 基础模板已包含 `damage_type = DAMAGE_EXPLOSION`、`hit_decal = "decal_bomb_crater"`、`main_script = scripts.bomb.*`，无需重复声明这些字段（除非要覆盖）。

### 6.6 map_data.lua 必须同时添加着色器（shader）

**错误**：英雄名称文字颜色显示为默认白色，无法体现英雄主色调。

**原因**：英雄名称文字颜色由 `kr1-desktop/data/map_data.lua` 中 `hero_shaders` 表的 `shader_args` 控制，移植时只添加了 `hero_data` 条目，遗漏了 `hero_shaders` 条目。

**修复**：在 `hero_shaders` 表（紧接在 `hero_data` 之前）中添加对应条目，颜色值参照 FL 的 `kr3-desktop/data/map_data.lua`。典型格式：

```lua
hero_xxx = {
    shader_args = {{
        margin = 0 * rs,
        p1 = p11, p2 = p12,
        c1 = fc(0, 0, 0, 255),
        c2 = fc(R, G, B, 255),  -- 主色调（亮）
        c3 = fc(R, G, B, 255)   -- 主色调（暗）
    }, {
        thickness = 2.5 * rs,
        outline_color = fc(R, G, B, 255)
    }, {
        thickness = 1 * rs,
        glow_color = fc(R, G, B, 255)
    }, {}}
},
```

---

## 七、今日移植常见漏洞（2026-03-06 总结）

### 7.1 balance 衍生单位 hp_max 遗漏调整

**错误**：英雄本体 `hp_max` 已应用 ×1.3，但英雄技能召唤的士兵/单位的 `hp_max` 仍是 FL 原值。

**原因**：balance.lua 中一个英雄 block 可能有多个 `hp_max` 数组，脚本/手动调整时只改了顶层的英雄本体 `hp_max`，忽略了子表（如 `skill.soldier.hp_max`）。

**实例**：
- `hero_bird` 的鸟巢单位 `hp_max = {200, 400, 600}` → 应调整为 `{260, 520, 780}`
- `hero_lava` 的熔岩分身 `hp_max = {75, 100, 125}` → 应调整为 `{97, 130, 162}`

**规则**：balance block 内**所有 `hp_max` 数组**（不论嵌套深度）均须 ×1.3 floor。

### 7.2 FL 同盟升级函数（alliance upgrade）必须删除

**错误**：`attempt to call field 'alliance_merciless_upgrade' (a nil value)`

**原因**：FL 中存在 `SU.alliance_merciless_upgrade(store, this)` 和 `SU.alliance_corageous_upgrade(store, this)`（同盟系统专属），dove 不存在这两个函数。

**修复**：直接删除这两行，不需要任何替代逻辑。已在 §3.3 表格中列出。

### 7.3 终极技自动释放逻辑必须手动添加

**错误**：英雄终极技永远不触发。

**原因**：FL 的英雄终极技是通过玩家点击（`can_fire_fn`）触发的，`update` 函数中没有自动检测冷却并释放的逻辑。dove 中所有英雄均为**自动释放**，但 FL 源码中无此代码，移植时容易遗漏。

**修复**：参见 §3.2 的标准模板，必须在 `SU.hero_level_up` 检查之后手动插入 `ready_to_use_skill(this.ultimate, store)` 块。这对每一个移植的英雄都是必须步骤。

### 7.5 `level_up` 必须显式更新基础近战伤害

**错误**：英雄近战伤害随等级提升不变化。

**原因**：拥有 `melee` 组件的英雄，其 `level_stats.melee_damage_min/max` 数组在 `heroes.lua` 模板中已正确映射，但 `level_up` 函数内若**未显式赋值**给 `this.melee.attacks[1].damage_min/max`，伤害值将永远停留在模板初始值，不随英雄等级成长。FL 的 level_up 有时也遗漏这一赋值，需在移植时主动补充。

**规则**：只要英雄模板通过 `E:add_comps(tt, "melee", ...)` 添加了 melee 组件，`level_up` 中必须包含：

```lua
this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
```

紧跟在 `local hl, ls = level_up_basic(this)` 之后，在所有 `upgrade_skill(...)` 之前。

**受影响**：`hero_lava`（移植时 FL 源码中遗漏此赋值）。纯远程英雄（如 `hero_bird`、`hero_mecha`）无 melee 组件，无需此步骤。

---

### 7.4 `SU.create_attack_damage` 接口差异

**错误**：`attempt to index local 'this' (a number value)` in `all/script_utils.lua`

**原因**：FL 和 dove 的 `create_attack_damage` 签名不同：

| 版本 | 签名 |
|---|---|
| FL | `SU.create_attack_damage(a, target.id, this.id)` — 第三参数传 ID（数字） |
| dove | `SU.create_attack_damage(a, target_id, this)` — 第三参数传实体本身 |

dove 内部用 `this.id` 取 source ID、用 `this.unit.damage_factor` 计算伤害，因此必须传入实体对象而非 ID。

**修复**：所有 `SU.create_attack_damage(...)` 调用中，第三个参数从 `this.id` 改为 `this`：

```lua
-- 错误（FL 写法）：
local d = SU.create_attack_damage(a, target.id, this.id)

-- 正确（dove 写法）：
local d = SU.create_attack_damage(a, target.id, this)
```

---

## 八、快速检查清单

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
- [ ] 英雄模板中所有引用的 FX/PS 名称都有对应的 `RT(...)` 定义
- [ ] 所有 `motion.max_speed` 修改使用 `U.update_max_speed` / `U.speed_inc_self` 等 API
- [ ] 语音条目（Taunt/Death 等）已添加到 `sounds.lua`
- [ ] `map_data.lua` 同时添加了 `hero_data` 条目 **和** `hero_shaders` 条目
- [ ] `hero_room_view.lua` 已添加大图项
- [ ] `zh-Hans.lua` 已添加 `_DESCRIPTION` 和 `_SPECIAL`
- [ ] `hero_room_special.lua` 已添加技能描述块
- [ ] balance 数值已应用 kr5→kr1 调整系数（**包括衍生单位的 `hp_max`**）
- [ ] `update` 函数中已手动添加 `ready_to_use_skill(this.ultimate, store)` 自动释放块（FL 无此逻辑）
- [ ] 已删除所有 `SU.alliance_merciless_upgrade` / `SU.alliance_corageous_upgrade` 调用
- [ ] 所有 `SU.create_attack_damage(...)` 第三参数为实体 `this`（不是 `this.id`）
- [ ] 有 melee 组件的英雄，`level_up` 中已在 `level_up_basic` 后显式赋值 `this.melee.attacks[1].damage_min/max`

---

*最后更新：2026-03-06（移植 hero_builder/robot/bird/lava/spider/mecha 后总结，补充终极技自动释放、同盟函数、衍生单位 hp 调整等教训）*
