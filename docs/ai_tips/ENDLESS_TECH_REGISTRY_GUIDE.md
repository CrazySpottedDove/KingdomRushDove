# Endless Tech Registry Guide

本文说明无尽科技系统的新结构与新增流程，供后续开发直接参考。

## 1. 当前结构

- 核心入口：`kr1/endless_utils.lua`
  - `EU.patch_upgrades(endless)`：开局/读档后应用模板级效果
  - `EU.patch_upgrade_in_game(key, store, endless)`：局内升级时应用运行时效果
  - 两个入口都会优先调用 `TechRegistry`
- 注册中心：`kr1/endless/tech_registry.lua`
  - `register(def)`
  - `apply_template(id, level, endless, ctx)`
  - `apply_runtime(id, level, store, endless, ctx)`
- 科技处理器目录：`kr1/endless/tech_handlers/`
  - `global.lua`
  - `friend_core.lua`
  - `archer.lua`
  - `mage.lua`
  - `rain.lua`
  - `barrack.lua`
  - `engineer.lua`

## 2. 单个科技定义规范

每个科技建议按以下结构注册：

```lua
registry.register({
	id = "tech_id",
	group = "group_name",
	apply_template = function(level, endless)
		-- 可选：模板/初始化阶段逻辑
	end,
	apply_runtime = function(level, store, endless)
		-- 可选：局内升级时逻辑
	end,
})
```

说明：
- `id` 必须与 `kr1/data/endless.lua` 中 `upgrade_max_levels` 的 key 一致。
- `apply_template` 和 `apply_runtime` 可只实现一个，但至少要有一个。
- 共享数值请从 `ctx.friend_buff` 或 `ctx.EL` 读取，不要在 handler 中硬编码重复常量。

## 3. 新增科技步骤

1. 在 `kr1/data/endless.lua` 增加配置：
   - `upgrade_max_levels.tech_id`
   - （如需要）`force_upgrade_max_levels.tech_id`
   - （如需要）`gold_extra_upgrade` 列表
   - 文本映射：`key_label_map.tech_id`、`key_desc_map.tech_id`
2. 选择或新增 handler 文件（按体系分组）。
3. 在 handler 中 `registry.register({...})` 注册该科技。
4. 若是新增 handler 文件，在 `kr1/endless_utils.lua` 的 `ensure_tech_registry()` 中接入 `register(...)`。
5. 启动游戏验证：
   - 可抽到该科技
   - 升级后生效
   - 读档后效果保持一致

## 4. 设计约定

- 优先保持“数据驱动 + 小函数”：
  - 大逻辑拆为 `patch_xxx()` 私有函数
  - `register()` 只做装配
- 避免跨 handler 互相调用，减少耦合。
- 一次只迁移/新增一组科技，便于回归。
- 若涉及对现存实体即时修正，必须放在 `apply_runtime`。

## 5. 回归测试清单（最小）

- 开局初始化：`EU.patch_upgrades` 后无报错
- 局内升级：`EU.patch_upgrade_in_game` 后无报错
- 至少验证一次读档恢复
- 对应派系关键表现正确（伤害、冷却、范围、特效）

## 6. 调试开关（可选）

- 配置文件：`kr1/data/endless.lua`
- `debug_print_registered_techs`：打印已注册科技列表
- `debug_check_registry_coverage`：检查 `upgrade_max_levels` 是否全部有 handler（缺失会报错日志）
- `debug_trace_upgrades`：打印升级应用路径与未处理 key（仅首次）
- `debug_trace_tower_skills`：打印塔专属技能触发日志（塔名、技能ID、目标数、下次冷却）

## 7. 运行时保护（已接入）

- `EU.patch_upgrade_in_game` 对非法 key 做保护：
  - 若 `endless.upgrade_levels[key]` 不存在，忽略并记录错误日志
  - 若 `upgrade_max_levels[key]` 缺失配置，忽略并记录错误日志
- 目的：避免模组或配置异常导致局内升级流程崩溃。

- `EU.patch_upgrades` 对历史/异常存档中的非法 key 做保护：
  - 跳过无 `upgrade_max_levels` 配置的 key
  - 在本次应用结束后汇总一次被跳过的 key 列表

