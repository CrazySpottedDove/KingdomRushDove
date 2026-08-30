-- chunkname: @./all/entity_db.lua
local log = require("lib.klua.log"):new("entity_db")

require("lib.klua.table")
local perf = require("dove_modules.perf.perf")

local copy = table.deepclone

local function quickcopy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = copy(v)
	end
	return out
end

local entity_db = {
	last_id = 1,
	entities = {},
	components = {},
	components_cloner = {},
	loaded = false
}

function entity_db:Load()
	self.last_id = 1
	self.loaded = true

	if not self.entities_backup then
		self:load()
		self:precompile()
		self.entities_backup = quickcopy(self.entities)
	else
		-- 已有实体数据库备份时，直接拷贝即可。components 约定为只读数据，无需重复拷贝。
		self.entities = quickcopy(self.entities_backup)
	end
end

--- 实体数据库的首次初始化，实际的初始化逻辑，只负责将组件和实体模板从文件加载到内存中。
--- 插件应当 HOOK 该函数，来实现自己定义的组件和实体模板的加载（不要在这个HOOK中做其他事情！）。
--- 通过将 precompile 步骤和 load 步骤分离，允许了在 load HOOK 中注册的实体也享受到编译效果，从而避免错误地继承一个已被编译的脚本的问题。
function entity_db:load()
	require("components")

	local compiler = require("precompile.interface")
	self.components_cloner = compiler:compile_component_cloners(self.components)

	require("templates")
	require("game_templates")

	-- clear up
	package.loaded["components"] = nil
	package.loaded["templates"] = nil
	package.loaded["game_templates"] = nil
	package.loaded["foundamental_towers"] = nil
	package.loaded["mage_towers"] = nil
	package.loaded["archer_towers"] = nil
	package.loaded["engineer_towers"] = nil
	package.loaded["barrack_towers"] = nil
	package.loaded["heroes"] = nil
	package.loaded["enemies"] = nil
	package.loaded["boss"] = nil
	package.loaded["hero_boss"] = nil

-- self:test_attacks()
-- self:report_status()
-- self:test_tween()
end

--- 在 DI:patch_templates() 后调用，负责进行一些预计算工作，减少运行时检查开销
function entity_db:precompute()
end

--- 在第一次初始化 entity_db 时调用，对 entity_db 里的实体运行逻辑进行类似编译的操作，减少运行时的动态分支，以提高脚本执行性能
function entity_db:precompile()
	local compiler = require("precompile.interface")
	perf.tmp_start("precompile")
	for _, e in pairs(self.entities) do
		compiler:compile(e)
	end
	perf.tmp_stop("precompile")
-- profiling report (可注释掉以关闭)
-- local CU = require("precompile.compile_utils")
-- CU.profile_report()
end

-- --- 返回一个实体数据库的影子副本，通过元表可访问所有的entity_db的成员和方法，但是自身也拥有独立的entities和components。
-- --- 通过影子副本进行 E:register_t()，可以以 entity_db 已注册的模板作为父模板，并注册到独立的 entities 列表中。
-- function entity_db:shadow()
-- 	-- 1. 影子自己的实体表：读缺失键时回退到原 entity_db.entities
-- 	local shadow_entities = setmetatable({}, {
-- 		__index = self.entities
-- 	})

-- 	-- 2. 影子自己的组件表：读缺失键时回退到原 entity_db.components
-- 	local shadow_components = setmetatable({}, {
-- 		__index = self.components
-- 	})

-- 	-- 3. 影子自己的克隆器表：读缺失键时回退到原 entity_db.components_cloner
-- 	local shadow_cloners = setmetatable({}, {
-- 		__index = self.components_cloner
-- 	})

-- 	-- 影子本体
-- 	local shadow = {
-- 		entities = shadow_entities,
-- 		components = shadow_components,
-- 		components_cloner = shadow_cloners,
-- 		last_id = 1,
-- 		loaded = true -- 影子默认已“加载”，避免调用 Load()
-- 	}

-- 	-- 影子本体的元表：方法（如 register_t）回退到原 entity_db
-- 	setmetatable(shadow, {
-- 		__index = self
-- 	})

-- 	return shadow
-- end

-- --- 将影子数据库中注册的模板合并进实体数据库中
-- ---@param shadowed_entity_db any
-- function entity_db:merge_shadow(shadowed_entity_db)
-- 	local compiler = require("precompile.interface")
-- 	local incremental_components_cloner = require("precompile.interface"):compile_component_cloners(shadowed_entity_db.components)
-- 	for name, component in pairs(shadowed_entity_db.components) do
-- 		self.components[name] = component
-- 	end
-- 	for name, cloner in pairs(incremental_components_cloner) do
-- 		self.components_cloner[name] = cloner
-- 	end
-- 	for name, entity in pairs(shadowed_entity_db.entities) do
-- 		compiler:compile(entity)
-- 		self.entities[name] = entity
-- 	end
-- 	if self.entities_backup then
-- 		for name, entity in pairs(shadowed_entity_db.entities) do
-- 			self.entities_backup[name] = entity
-- 		end
-- 	end
-- end

--- 确认 entity_db 已加载
--- @return boolean (true: 执行加载逻辑；false: 已加载)
function entity_db:ensure_loaded()
	if not self.loaded then
		self:Load()
		return true
	end
	return false
end

function entity_db:test_tween()
	for name, e in pairs(self.entities) do
		if e.tween then
			for _, prop in pairs(e.tween.props) do
				for _, key in pairs(prop.keys) do
					if key[3] then
						log.error("template %s has tween with ease function in [keys], which is not supported in entity_db:test_tween()", name)
					end

					if key[2] == nil then
						log.error("template %s has tween with key missing value", name)
					end
				end

				if not e.render.sprites[prop.sprite_id] then
					log.error("template %s has tween with invalid sprite_id %s", name, tostring(prop.sprite_id))
				end
			end
		end
	end
end

function entity_db:test_attacks()
	for name, e in pairs(self.entities) do
		if e.tower then
			if not e.attacks or not e.attacks.list then
				print("template " .. name .. " has tower component but no attacks defined")
			end
		end
	end
end

function entity_db:report_status()
	local template_count = 0

	for _ in pairs(self.entities) do
		template_count = template_count + 1
	end

	local component_count = 0

	for _ in pairs(self.components) do
		component_count = component_count + 1
	end

	print("entity_db status: " .. template_count .. " templates, " .. component_count .. " components")
end

-- 性能与内存测试函数
function entity_db:test()
	-- 记录初始内存
	collectgarbage("collect")

	local mem_before = collectgarbage("count") -- 单位：KB
	local t0 = os.clock()

	self:load()

	local t1 = os.clock()
	-- 统计模板数量
	local template_count = 0

	if self.entities then
		for _ in pairs(self.entities) do
			template_count = template_count + 1
		end
	end

	local component_count = 0

	if self.components then
		for _ in pairs(self.components) do
			component_count = component_count + 1
		end
	end

	-- 记录load后内存
	collectgarbage("collect")

	local mem_after = collectgarbage("count") -- 单位：KB

	print("entity_db:load() 用时: " .. string.format("%.4f", t1 - t0) .. " 秒")
	print("entity_db:load() 前内存: " .. string.format("%.2f", mem_before) .. " KB")
	print("entity_db:load() 后内存: " .. string.format("%.2f", mem_after) .. " KB")
	print("entity_db:load() 增加内存: " .. string.format("%.2f", mem_after - mem_before) .. " KB")
	print("模板数量: " .. template_count)
	print("组件数量: " .. component_count)

	-- 可选：测试批量创建实体的性能和内存
	local create_count = 1000
	local t2 = os.clock()
	local tmp_entities = {}

	for k in pairs(self.entities) do
		for i = 1, create_count do
			tmp_entities[#tmp_entities + 1] = self:create_entity(k)
		end

		break -- 只测一个模板
	end

	local t3 = os.clock()

	collectgarbage("collect")

	local mem_entities = collectgarbage("count")

	print("批量创建 " .. create_count .. " 个实体用时: " .. string.format("%.4f", t3 - t2) .. " 秒")
	print("批量创建后内存: " .. string.format("%.2f", mem_entities) .. " KB")
	print("批量创建增加内存: " .. string.format("%.2f", mem_entities - mem_after) .. " KB")
end

function entity_db:register_t(name, base)
	-- 仅在开发时启用它，发行时关闭
	-- if self.entities[name] then
	-- 	log.error("template %s already exists", name)

	-- 	return self.entities[name]
	-- end

	local t = base and quickcopy(self.entities[base]) or {}

	t.template_name = name
	self.entities[name] = t

	return t
end

function entity_db:register_c(name, base)
	-- if self.components[name] then
	-- 	log.error("component %s already exists", name)

	-- 	return
	-- end

	local c = base and copy(self.components[base]) or {}

	self.components[name] = c

	return c
end

--- 在 entity_db 中注册一个 ffi 类型的组件，无返回值，所有默认值需提前在 ffi 结构体中准备好
---@param name string 组件名称
---@param ffi_data userdata ffi 组件数据，必须是一个已经准备好默认值的 ffi 结构体实例
function entity_db:register_c_ffi(name, ffi_data)
	self.components[name] = ffi_data
end

function entity_db:clone_c(name)
	-- if not self.components[name] then
	-- 	log.error("component %s does not exist", name)

	-- 	return
	-- end

	local cloner = self.components_cloner[name]
	if cloner then
		return cloner(self.components[name])
	end

	return copy(self.components[name])
end

function entity_db:add_comps(entity, ...)
	for _, v in ipairs({...}) do
		-- DEBUG USE
		-- if entity[v] then
		-- 	log.error("entity %s already has component %s", entity.template_name, v)
		-- end

		-- RELEASE VER
		local cloner = self.components_cloner[v]
		if cloner then
			entity[v] = cloner(self.components[v])
		else
			entity[v] = copy(self.components[v])
		end
	end
end

--- 只接收字符串模板名，创建对应实体
---@param t string 模板名
function entity_db:create_entity(t)
	local tpl = self.entities[t]
	-- DEBUG USE
	-- if not tpl then
	-- 	log.error("template %s not found", t)

	-- 	return nil
	-- end

	local out = quickcopy(tpl)

	out.id = self.last_id
	self.last_id = self.last_id + 1
	return out
end

--- 这是一个面向伤害的特殊优化函数，因为调用 table.deepclone 在创建伤害时的效率是直接给一个伤害表的 1 / 10。
--- 注意和 templates.lua 中的 damage 模板同步定义。
function entity_db.create_damage()
	return {
		damage_type = DAMAGE_TRUE,
		value = 0,
		reduce_armor = 0,
		reduce_magic_armor = 0,
		damage_result = 0,
		hooks = {}
	}
end

--- 更直接的伤害创建函数，避免多次赋值。
---@param damage_type number
---@param value number
---@param source_id number
---@param target_id number
function entity_db.assign_damage(damage_type, value, source_id, target_id)
	return {
		damage_type = damage_type,
		value = value,
		reduce_armor = 0,
		reduce_magic_armor = 0,
		damage_result = 0,
		hooks = {},
		target_id = target_id,
		source_id = source_id
	}
end

function entity_db:clone_entity(e)
	local out = quickcopy(e)

	out.id = self.last_id
	self.last_id = self.last_id + 1

	return out
end

--- 获取对应实体模板
---@param t string 模板名
function entity_db:get_template(t)
	-- 开发时才启用，发布时关闭。
	-- if not self.entities[t] then
	-- log.error("template %s not found", t)
	-- end

	return self.entities[t]
end

-- 该方法不允许在 entity_db 的 load 阶段使用，必须在 entity_db 已经加载后，再额外设置模板，否则可能导致引用了作为备份的表，导致意外的结果。
function entity_db:set_template(name, t)
	self.entities[name] = t
end

function entity_db:filter(entities, ...)
	local result = {}

	for id, e in pairs(entities) do
		for _, n in pairs({...}) do
			if not e[n] then
				goto label_12_0
			end
		end

		table.insert(result, e)

		::label_12_0::
	end

	return result
end

function entity_db:filter_iter(entities, c1, c2, c3)
	local function next_entity(t, i)
		local k, v = i, nil

		while true do
			::label_14_0::

			k, v = next(t, k)

			if not k then
				return nil
			end

			if c1 and not v[c1] then
				goto label_14_0
			end

			if c2 and not v[c2] then
				goto label_14_0
			end

			if c3 and not v[c3] then
				goto label_14_0
			end

			return k, v
		end
	end

	return next_entity, entities, nil
end

function entity_db:filter_templates(...)
	return self:filter(self.entities, ...)
end

function entity_db:search_entity(p)
	local results = {}
	local pattern = string.lower(p)

	for k, e in pairs(self.entities) do
		if string.match(string.lower(k), pattern) then
			table.insert(results, k)
		end
	end

	-- 按匹配分数排序：前缀匹配 > 包含匹配
	table.sort(results, function(a, b)
		local la, lb = string.lower(a), string.lower(b)
		local pa = string.find(la, pattern, 1, true) == 1 and 0 or 1
		local pb = string.find(lb, pattern, 1, true) == 1 and 0 or 1
		if pa ~= pb then
			return pa < pb
		end
		return #a < #b
	end)

	return results
end

-- 在 difficulty:patch_templates() 后调用！
function entity_db:patch_config(config)
	if not config.enabled then
		return
	end

	-- 动态添加模板, 避免模板数量膨胀. 正常游玩, 并不太会开 build_random_towers.
	local GS = require("kr1.game_settings")
	if config.build_random_towers then
		local scripts = require("game_scripts")
		local tt = self:register_t("tower_random_advanced_archer", "tower")
		tt.tower.price = 0
		tt.info.fn = scripts.tower_random.get_info
		tt.desc_key = "TOWER_RANDOM_ADVANCED_ARCHER_DESCRIPTION"
		for i = 4, #GS.archer_towers do
			tt.tower.price = tt.tower.price + self:get_template(GS.archer_towers[i]).tower.price
		end
		tt.tower.price = math.floor(tt.tower.price / (#GS.archer_towers - 3))

		tt = self:register_t("tower_random_advanced_mage", "tower")
		tt.tower.price = 0
		tt.info.fn = scripts.tower_random.get_info
		for i = 4, #GS.mage_towers do
			tt.tower.price = tt.tower.price + self:get_template(GS.mage_towers[i]).tower.price
		end
		tt.desc_key = "TOWER_RANDOM_ADVANCED_MAGE_DESCRIPTION"
		tt.tower.price = math.floor(tt.tower.price / (#GS.mage_towers - 3))

		tt = self:register_t("tower_random_advanced_engineer", "tower")
		tt.tower.price = 0
		tt.info.fn = scripts.tower_random.get_info
		for i = 4, #GS.engineer_towers do
			tt.tower.price = tt.tower.price + self:get_template(GS.engineer_towers[i]).tower.price
		end
		tt.desc_key = "TOWER_RANDOM_ADVANCED_ENGINEER_DESCRIPTION"
		tt.tower.price = math.floor(tt.tower.price / (#GS.engineer_towers - 3))

		tt = self:register_t("tower_random_advanced_barrack", "tower")
		tt.tower.price = 0
		tt.info.fn = scripts.tower_random.get_info
		for i = 4, #GS.barrack_towers do
			tt.tower.price = tt.tower.price + self:get_template(GS.barrack_towers[i]).tower.price
		end
		tt.desc_key = "TOWER_RANDOM_ADVANCED_BARRACK_DESCRIPTION"
		tt.tower.price = math.floor(tt.tower.price / (#GS.barrack_towers - 3))
	end

	-- 如果所有倍率都是 1，就直接跳过，避免不必要的循环和乘法运算，提升性能。
	if config.enemy_damage_multiplier == 1 and config.enemy_health_multiplier == 1 and config.enemy_gold_multiplier == 1 and config.enemy_health_damage_multiplier == 1 and config.enemy_speed_multiplier == 1 and config.tower_cooldown_divider == 1 and config.tower_damage_multiplier == 1 and config.tower_range_multiplier == 1 and config.extra_soldiers == 0 then
		return
	end

	local barrack_towers = GS.barrack_towers
	local SU = require("script_utils")
	for _, t in pairs(self.entities) do
		if t.enemy then
			if t.health.hp_max then
				t.health.hp_max = t.health.hp_max * config.enemy_health_multiplier
			end

			if t.enemy.gold then
				t.enemy.gold = math.ceil(t.enemy.gold * config.enemy_gold_multiplier)
			end

			if t.unit.damage_factor then
				t.unit.damage_factor = t.unit.damage_factor * config.enemy_damage_multiplier
			end

			if t.health.damage_factor then
				t.health.damage_factor = t.health.damage_factor * config.enemy_health_damage_multiplier
			end

			if t.motion.max_speed then
				t.motion.max_speed = t.motion.max_speed * config.enemy_speed_multiplier
			end
		end
		if t.tower then
			t.tower.cooldown_factor_divider = config.tower_cooldown_divider * t.tower.cooldown_factor_divider
			t.tower.cooldown_factor = 1.0 / t.tower.cooldown_factor_divider
			SU.change_fps(0, t, t.tower.cooldown_factor_divider)
			t.tower.damage_factor = t.tower.damage_factor * config.tower_damage_multiplier
			if t.attacks then
				t.attacks.range = t.attacks.range * config.tower_range_multiplier
			end
			if t.template_name ~= "tower_baby_ashbite" and t.template_name ~= "tower_pandas_lvl4" and table.arraycontains(barrack_towers, t.template_name) then
				t.barrack.max_soldiers = t.barrack.max_soldiers + config.extra_soldiers
			end
		end
	end

end

return entity_db
