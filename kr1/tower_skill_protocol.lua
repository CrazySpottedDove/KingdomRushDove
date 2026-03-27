local E = require("entity_db")
local V = require("lib.klua.vector")
local log = require("lib.klua.log"):new("tower_skill")
local EL = require("kr1.data.endless")

local SkillData = require("kr1.data.tower_skills_endless")

local TowerSkill = {}

local function tpos(tower)
	-- 塔有 range_offset 时用偏移后的坐标；没有就直接用实体坐标。
	-- 这样选敌范围和原塔攻击判定更一致，不会出现“明明在圈里却打不到”。
	local p = tower.pos
	if tower.tower and tower.tower.range_offset then
		return V.v(p.x + tower.tower.range_offset.x, p.y + tower.tower.range_offset.y)
	end
	return p
end

local function pick_targets(list, max_targets)
	-- 先按候选顺序截断，数值可控，后续调平衡只改配置里的 max_targets 即可。
	if not list or #list == 0 then
		return {}
	end
	if not max_targets or max_targets <= 0 or #list <= max_targets then
		return list
	end
	local out = {}
	for i = 1, max_targets do
		out[i] = list[i]
	end
	return out
end

local function select_targets(cfg, tower, store)
	local pos = tpos(tower)
	local target_cfg = cfg.target or {}

	if target_cfg.type == "enemies_in_range" then
		local enemies = store.enemies
		local out = {}
		local r2 = (target_cfg.range or 0) * (target_cfg.range or 0)

		for _, e in pairs(enemies) do
			if e and e.pos and e.health and not e.health.dead then
				local dx = e.pos.x - pos.x
				local dy = e.pos.y - pos.y
				if dx * dx + dy * dy <= r2 then
					out[#out + 1] = e
				end
			end
		end
		return out
	end

	if target_cfg.type == "soldiers_in_range" then
		local soldiers = store.soldiers
		local out = {}
		local r2 = (target_cfg.range or 0) * (target_cfg.range or 0)

		for _, s in pairs(soldiers) do
			if s and s.pos and s.health and not s.health.dead then
				local dx = s.pos.x - pos.x
				local dy = s.pos.y - pos.y
				if dx * dx + dy * dy <= r2 then
					out[#out + 1] = s
				end
			end
		end
		return out
	end

	return {}
end

local function execute_effect(cfg, tower, store, targets)
	local effect = cfg.effect or {}
	local max_targets = effect.max_targets
	targets = pick_targets(targets, max_targets)
	local applied_count = #targets

	if effect.type == "heal_percent" then
		-- 治疗走直接改血量，避免走 damage_queue 带来的额外分支开销。
		for _, t in pairs(targets) do
			if t.health and t.health.hp_max then
				local add = math.floor(t.health.hp_max * (effect.percent or 0))
				t.health.hp = math.min(t.health.hp_max, t.health.hp + add)
			end
		end
		return applied_count
	end

	if effect.type == "damage" then
		-- 伤害统一走 damage 实体，复用现有 health/pops 链路，兼容现有 mod。
		for _, t in pairs(targets) do
			if t.health and not t.health.dead then
				local dmg = E:create_entity("damage")
				local min_dmg = effect.damage_min or 0
				local max_dmg = effect.damage_max or min_dmg
				dmg.value = math.random(min_dmg, max_dmg)
				dmg.target_id = t.id
				dmg.source_id = tower.id
				dmg.damage_type = effect.damage_type or DAMAGE_TRUE
				dmg.pop = effect.pop
				dmg.pop_conds = effect.pop_conds or DR_DAMAGE
				store.damage_queue[#store.damage_queue + 1] = dmg
			end
		end
	end

	return applied_count
end

local function tick_skill(skill_cfg, tower, store, state)
	local key = skill_cfg.id
	local now = store.tick_ts
	local next_ts = state[key] or 0

	if now < next_ts then
		return
	end

	local targets = select_targets(skill_cfg, tower, store)
	if #targets == 0 then
		-- 没目标就不推进冷却：避免“空放技能”导致实战体感发虚。
		return
	end

	local applied_count = execute_effect(skill_cfg, tower, store, targets) or 0
	state[key] = now + (skill_cfg.cooldown or 10)

	if EL.debug_trace_tower_skills then
		log.error(
			"trigger tower_skill tower=%s skill=%s targets=%s next_cd=%.2f",
			tostring(tower.template_name),
			tostring(key),
			tostring(applied_count),
			state[key] - now
		)
	end
end

function TowerSkill.tick_tower(tower, store)
	local cfgs = SkillData.skills_by_tower[tower.template_name]
	if not cfgs then
		-- 未配置技能的塔直接跳过，便于分批接入。
		return
	end

	store._tower_skill_state = store._tower_skill_state or {}
	local tower_state = store._tower_skill_state[tower.id]
	if not tower_state then
		tower_state = {}
		store._tower_skill_state[tower.id] = tower_state
	end

	for i = 1, #cfgs do
		tick_skill(cfgs[i], tower, store, tower_state)
	end
end

function TowerSkill.tick_all(store)
	local towers = store.towers
	local has_list_towers = towers and next(towers) ~= nil

	if not has_list_towers then
		-- 有些场景分组表可能为空，这里走实体扫描兜底，保证技能系统不断档。
		-- 这是兼容复杂关卡/特殊脚本的兜底分支，不建议删除。
		towers = {}
		local entities = store.entities or {}
		for _, e in pairs(entities) do
			if e and e.tower then
				towers[#towers + 1] = e
			end
		end
	end

	if EL.debug_trace_tower_skills then
		store._tower_skill_dbg_next_ts = store._tower_skill_dbg_next_ts or 0
		if store.tick_ts >= store._tower_skill_dbg_next_ts then
			local total_towers = 0
			local skill_towers = 0
			for _, tower in pairs(towers) do
				if tower and tower.tower then
					total_towers = total_towers + 1
					if SkillData.skills_by_tower[tower.template_name] then
						skill_towers = skill_towers + 1
					end
				end
			end
			store._tower_skill_dbg_next_ts = store.tick_ts + 5
			-- 心跳每 5 秒输出一次，用于确认系统在运行。
			log.error(
				"tower_skill heartbeat total_towers=%s skill_towers=%s source=%s",
				tostring(total_towers),
				tostring(skill_towers),
				has_list_towers and "store.towers" or "fallback_scan"
			)
		end
	end

	for _, tower in pairs(towers) do
		if tower and tower.tower then
			-- 不判断 health：部分塔模板没有 health 组件。
			TowerSkill.tick_tower(tower, store)
		end
	end
end

return TowerSkill
