# SEEK_TIPS.md — 索敌模块使用规范

## 一、概述

`all/seek.lua` 是游戏的高效索敌模块，内部使用空间哈希（`spatial_index`）加速范围查询。
所有索敌调用都应通过 `utils.lua` 暴露的接口（前缀 `U.`）来完成，**禁止其他模块直接 `require("seek")`**。

---

## 二、接口命名规律

所有 seek 接口遵循统一命名格式：

```
U.find_<TYPE>_<RANGE_MODE>_<FILTER_MODE>(origin, [min_range,] max_range, [pred,] flags, bans [, filter_fn])
```

| 维度 | 可选值 |
|------|--------|
| TYPE | `enemies` / `foremost_enemy` / `first_enemy` / `biggest_enemy` / `foremost_enemy_with_max_coverage` / `foremost_enemy_with_flying_preference` |
| RANGE_MODE | `in_range`（min=0）/ `between_range`（min>0）|
| FILTER_MODE | `filter_off`（无过滤函数）/ `filter_on`（有过滤函数）|

---

## 三、替换老旧写法

### 3.1 `U.find_enemies_in_range(store, origin, min, max, flags, bans[, filter])`

这是旧版包装函数，内部含 2 层 if 分支。**已弃用，应直接调用对应的 seek 接口。**

| 旧调用形式 | 替换为 |
|-----------|--------|
| `U.find_enemies_in_range(store, origin, 0, max, flags, bans)` | `U.find_enemies_in_range_filter_off(origin, max, flags, bans)` |
| `U.find_enemies_in_range(store, origin, 0, max, flags, bans, fn)` | `U.find_enemies_in_range_filter_on(origin, max, flags, bans, fn)` |
| `U.find_enemies_in_range(store, origin, min, max, flags, bans)` | `U.find_enemies_between_range_filter_off(origin, min, max, flags, bans)` |
| `U.find_enemies_in_range(store, origin, min, max, flags, bans, fn)` | `U.find_enemies_between_range_filter_on(origin, min, max, flags, bans, fn)` |

注意：
- `store` 参数被完全丢弃（seek 模块通过 `simulation` 直接持有 `id_arrays`/`entities`）
- 用 `_filter_off` 比 `_filter_on` 更快，如无过滤条件应优先用前者

### 3.2 `U.find_foremost_enemy(store, origin, min, max, pred, flags, bans[, filter[, min_override_flags]])`

旧版同样含分支，且有第 9 个参数 `min_override_flags` 从未被 seek 层使用，**调用时静默丢弃**。

| 旧调用形式 | 替换为 |
|-----------|--------|
| `U.find_foremost_enemy(store, origin, 0, max, pred, flags, bans)` | `U.find_foremost_enemy_in_range_filter_off(origin, max, pred, flags, bans)` |
| `U.find_foremost_enemy(store, origin, 0, max, pred, flags, bans, fn)` | `U.find_foremost_enemy_in_range_filter_on(origin, max, pred, flags, bans, fn)` |
| `U.find_foremost_enemy(store, origin, min, max, pred, flags, bans)` | `U.find_foremost_enemy_between_range_filter_off(origin, min, max, pred, flags, bans)` |
| `U.find_foremost_enemy(store, origin, min, max, pred, flags, bans, fn)` | `U.find_foremost_enemy_between_range_filter_on(origin, min, max, pred, flags, bans, fn)` |

---

## 四、处理 filter 可能为 nil 的情况

当 filter 来自表字段（如 `a.filter_fn`、`attack.filter_fn`），其值在运行时可能为 `nil`，  
**不能直接传给 `_filter_on`**，需显式判断：

```lua
-- 正确写法
if a.filter_fn then
	target = U.find_foremost_enemy_in_range_filter_on(origin, max, pred, flags, bans, a.filter_fn)
else
	target = U.find_foremost_enemy_in_range_filter_off(origin, max, pred, flags, bans)
end

-- 错误写法（旧包装器能容忍 nil，新接口不行）
target = U.find_foremost_enemy_in_range_filter_on(origin, max, pred, flags, bans, a.filter_fn)
```

---

## 五、其他常用接口

| 函数 | 说明 |
|------|------|
| `U.find_first_enemy_in_range_filter_off(origin, max, flags, bans)` | 找到第一个满足条件的敌人（比 find_enemies 开销更小，只找一个） |
| `U.find_first_enemy_in_range_filter_on(origin, max, flags, bans, fn)` | 同上，带过滤 |
| `U.find_biggest_enemy_in_range_filter_off(origin, max, flags, bans)` | 找血量最多的敌人 |
| `U.detect_foremost_enemy_in_range_filter_off(origin, max, flags, bans)` | 仅检测最前敌人（不返回预测位置，开销更小） |
| `U.find_enemies_in_range_filter_override(origin, max, override_fn)` | 完全自定义过滤逻辑（用于 necromancer 类不依赖 flags/bans 的特殊场景） |

---

## 六、2026-03 批量重构记录

本次重构使用 Python 脚本对以下文件进行了批量替换：

| 文件 | 变更数 | 跳过数（unsafe filter）|
|------|--------|------------------------|
| `kr1/game_scripts.lua` | 106 | 0 |
| `kr1/hero_scripts.lua` | 177+2（手动） | 2→手动展开 |
| `kr1/hero_boss.lua` | 2 | 0 |
| `kr1/tower_scripts.lua` | 8 | 0 |
| `kr1/boss_scripts.lua` | 5+1（手动） | 1→手动展开 |
| `all/scripts.lua` | 4 | 2（注释行，保留） |
| `all/script_utils.lua` | 4 | 0 |
| `kr1/endless_utils.lua` | 2 | 0 |
| `all/utils.lua` | 1（手动） | — |

**手动处理说明**：凡 filter 为表字段（`a.filter_fn`、`attack.filter_fn`）的调用，自动脚本标记为 unsafe 跳过，改为手动添加 `if filter_fn then ... else ... end` 分支展开。
