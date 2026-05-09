--[[
precompile/tests/harness.lua
============================
预编译测试框架 — 统一的存根、编译、基准测试工具。

用法：
    local H = require("precompile.tests.harness")
    H.stub_all()    -- 一次性设置所有存根
    -- ... 加载 scripts, entity_db, 编译器等 ...

    -- 运行 benchmark
    H.benchmark("test_name", {
        compile = function(entity)
            -- 返回 compiled_insert, compiled_update
        end,
        make_entities = function(count)
            -- 返回实体列表
        end,
        setup_store = function(store)
            -- 向 store 添加士兵/目标等
        end,
    })

特性：
  - 自适迭代：自动增加实体数量，保证每次测试运行足够久以降低噪声
  - 统计分析：多次轮次的均值、标准差、最小值、最大值
  - 统一结果输出
--]]

local M = {}

-- ===================== 常量 =====================
F_ENEMY = 2048
F_FRIEND = 1024
F_MOD = 4
F_RANGED = 2
F_BLOCK = 1
F_FLYING = 128
F_BOSS = 32
F_HERO = 16
F_MOCKING = 64
F_BURN = 16384
F_POISON = 1048576
F_AREA = 8
F_NONE = 0
F_ALL = 4294967295

TERRAIN_NONE = 0
TERRAIN_LAND = 1
TERRAIN_WATER = 2

DAMAGE_PHYSICAL = 2
DAMAGE_TRUE = 1
DAMAGE_MAGICAL = 4
DAMAGE_ALL_TYPES = 16777215

MOD_TYPE_SLOW = "slow"
MOD_TYPE_POISON = "poison"
MOD_TYPE_FREEZE = "freeze"
MOD_TYPE_BLEED = "bleed"
MOD_TYPE_STUN = "stun"

M.F_ENEMY = F_ENEMY
M.F_FRIEND = F_FRIEND
M.F_MOD = F_MOD
M.F_RANGED = F_RANGED
M.F_BLOCK = F_BLOCK
M.TERRAIN_LAND = TERRAIN_LAND
M.TERRAIN_WATER = TERRAIN_WATER
-- 独立 deepclone（不依赖 table.deepclone，避免初始化顺序问题）
function M.deepclone(t)
	if type(t) ~= "table" then
		return t
	end
	local c = {}
	for k, v in pairs(t) do
		c[k] = M.deepclone(v)
	end
	return c
end

-- ===================== 1. love2d 存根 =====================
function M.stub_love()
	if _G.love then -- 只存根一次
		return
	end
	_G.love = {}
	love.filesystem = {
		getInfo = function()
			return nil
		end,
		loadWithPreference = function()
			return nil, "stub"
		end
	}
	love.graphics = {
		newImage = function()
			return {}
		end,
		newQuad = function()
			return {}
		end
	}
	love.audio = {
		newSource = function()
			return {}
		end
	}
	love.mouse = {
		getX = function()
			return 0
		end,
		getY = function()
			return 0
		end
	}
	love.window = {
		getWidth = function()
			return 1024
		end,
		getHeight = function()
			return 768
		end
	}
end

-- ===================== 2. 全局常量 =====================
function M.stub_globals()
	_G.FPS = 30
	_G.IS_ANDROID = false
	_G.LLDEBUGGER = nil
	_G.TICK_LENGTH = 1 / 30
	_G.NULL = "__NULL__"
	_G.INT_32_MAX = 2147483647
	_G.FLOAT_MAX = 3.402823466e+308

	-- 一些预编译模板引用的全局函数
	_G.yield = coroutine.yield
	_G.fts = function(v)
		return v / 30
	end
	_G.tpos = function(e)
		return e.pos
	end
end

-- ===================== 3. 核心模块存根 =====================
function M.stub_core_modules()
	-- 注意：不能通过检查 package.loaded["bit"] 来判断是否已初始化，
	-- 因为 LuaJIT 的内置 bit 库在 require 前可能已经在 package.loaded 中。
	-- 用 initialized 标志（在 ensure_initialized 中管理）。

	-- bit — 用 LuaJIT 内置或纯 Lua 回退
	local ok, bit_mod = pcall(require, "bit")
	if ok then
		package.loaded["bit"] = bit_mod
	else
		bit_mod = {
			band = function(a, b)
				local res, bitval = 0, 1
				while a > 0 or b > 0 do
					if a % 2 == 1 and b % 2 == 1 then
						res = res + bitval
					end
					a, b = math.floor(a / 2), math.floor(b / 2)
					bitval = bitval * 2
				end
				return res
			end,
			bor = function(a, b)
				local res, bitval = 0, 1
				while a > 0 or b > 0 do
					if a % 2 == 1 or b % 2 == 1 then
						res = res + bitval
					end
					a, b = math.floor(a / 2), math.floor(b / 2)
					bitval = bitval * 2
				end
				return res
			end,
			bnot = function(a)
				return 4294967295 - a
			end,
			bxor = function(a, b)
				local res, bitval = 0, 1
				while a > 0 or b > 0 do
					if (a % 2) ~= (b % 2) then
						res = res + bitval
					end
					a, b = math.floor(a / 2), math.floor(b / 2)
					bitval = bitval * 2
				end
				return res
			end,
			lshift = function(a, b)
				return a * (2 ^ b)
			end,
			rshift = function(a, b)
				return math.floor(a / (2 ^ b))
			end
		}
		package.loaded["bit"] = bit_mod
	end

	-- 扩展全局 table（与原版 lib/klua/table.lua 一致）
	if not table.deepclone then
		function table.keys(t)
			local kk = {}
			for k in pairs(t) do
				kk[#kk + 1] = k
			end
			return kk
		end
		function table.keyforobject(t, o)
			for k, v in pairs(t) do
				if v == o then
					return k
				end
			end
			return nil
		end
		function table.contains(t, o)
			return table.keyforobject(t, o) ~= nil
		end
		function table.arraycontains(t, o)
			for i = 1, #t do
				if t[i] == o then
					return true
				end
			end
			return false
		end
		function table.indexforobject(t, o)
			for i, v in ipairs(t) do
				if v == o then
					return i
				end
			end
			return nil
		end
		function table.clone(t)
			local c = {}
			for k, v in pairs(t) do
				c[k] = v
			end
			return c
		end
		function table.deepclone(t)
			if type(t) ~= "table" then
				return t
			end
			local c = {}
			for k, v in pairs(t) do
				c[k] = table.deepclone(v)
			end
			return c
		end
		function table.merge(t1, t2, new)
			local m = new and table.clone(t1) or t1
			for k, v in pairs(t2) do
				m[k] = v
			end
			return m
		end
	end
	package.loaded["lib.klua.table"] = true

	-- 其他 core modules
	local core_stubs = {
		["lib.klua.macros"] = {
			clamp = function(min, max, v)
				return math.max(min, math.min(max, v))
			end
		},
		["lib.hump.signal"] = {
			emit = function()
			end,
			register = function()
			end
		},
		["lib.hump.vector-light"] = {},
		["lib.klua.log"] = {
			new = function(name)
				return {
					debug = function()
					end,
					info = function()
					end,
					warn = function()
					end,
					error = function()
					end
				}
			end
		},
		["dove_modules.perf.perf"] = {
			start = function()
			end,
			stop = function()
			end,
			tmp_start = function()
			end,
			tmp_stop = function()
			end
		},
		["i18n"] = setmetatable({}, {
			__call = function(_, s)
				return s
			end
		}),
		["kr1.game_settings"] = {
			difficulty_enemy_speed_factor = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1
			}
		},
		["kr1.upgrades"] = {},
		["achievements"] = {},
		["level_utils"] = {},
		["all.constants"] = true
	}
	for name, mod in pairs(core_stubs) do
		if not package.loaded[name] then
			package.loaded[name] = mod
		end
	end

	-- vector — 简化版（不用 ffi）
	if not package.loaded["lib.klua.vector"] then
		local function vec2(x, y)
			return {
				x = x or 0,
				y = y or 0
			}
		end
		package.loaded["lib.klua.vector"] = {
			v = vec2,
			vec2 = vec2,
			vclone = function(v)
				return {
					x = v.x,
					y = v.y
				}
			end,
			dist = function(a, b)
				return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
			end,
			len = function(x, y)
				return math.sqrt(x * x + y * y)
			end
		}
	end

	-- sound_db, grid_db, path_db
	if not package.loaded["sound_db"] then
		package.loaded["sound_db"] = {
			queue = function()
			end,
			stop_all = function()
			end
		}
	end
	if not package.loaded["grid_db"] then
		package.loaded["grid_db"] = {
			cell_type = function()
				return TERRAIN_LAND
			end,
			get_coords = function()
				return 1, 1
			end
		}
	end
	if not package.loaded["path_db"] then
		package.loaded["path_db"] = {
			path_end_margin = 10,
			next_entity_node = function(self, entity, tick_length)
				local ni = entity.nav_path.ni or 1
				return {
					x = ni * 30,
					y = 0
				}, true
			end,
			is_node_valid = function()
				return true
			end,
			node_pos = function(self, pi, spi, ni)
				return {
					x = (ni or 1) * 30,
					y = 0
				}
			end,
			node_pos_ref = function(self, pi, spi, ni)
				return {
					x = (ni or 1) * 30,
					y = 0
				}
			end
		}
	end

	-- 导出常用引用
	_G.band = package.loaded["bit"].band
	_G.bor = package.loaded["bit"].bor
	_G.bnot = package.loaded["bit"].bnot
	_G.V = package.loaded["lib.klua.vector"]
end

-- ===================== 4. entity_db 存根 =====================
-- 提供最小化的 entity_db，支持组件注册和实体创建
local function make_entity_db()
	local E = {
		last_id = 1,
		entities = {},
		components = {},
		loaded = true
	}

	function E:create_entity(name)
		local tpl = self.entities[name]
		if not tpl then
			error("entity_db: template not found: " .. tostring(name))
		end
		local out = table.deepclone(tpl)
		out.id = self.last_id
		self.last_id = self.last_id + 1
		return out
	end

	function E:register_t(name, base)
		local t = base and table.deepclone(self.entities[base]) or {}
		t.template_name = name
		self.entities[name] = t
		return t
	end

	function E:register_c(name, base)
		local c = base and table.deepclone(self.components[base]) or {}
		self.components[name] = c
		return c
	end

	function E:clone_c(name)
		return table.deepclone(self.components[name])
	end

	function E:add_comps(entity, ...)
		for _, comp_name in ipairs({...}) do
			local comp = self.components[comp_name]
			if comp then
				entity[comp_name] = table.deepclone(comp)
			end
		end
	end

	function E:get_template(name)
		return self.entities[name]
	end

	return E
end

-- 用给定的 entity_db 注册基础组件和模板
function M.register_base_components(E)
	-- sprite
	local sprite = E:register_c("sprite")
	sprite.name = ""
	sprite.prefix = ""
	sprite.ts = 0
	sprite.offset = {
		x = 0,
		y = 0
	}
	sprite.hidden = nil
	sprite.z = 0
	sprite.loop = true
	sprite.angles = {}
	sprite.anchor = {
		x = 0.5,
		y = 0.5
	}

	local render = E:register_c("render")
	render.sprites = {}
	render.sprites[1] = E:clone_c("sprite")
	local pos = E:register_c("pos")
	pos.x = 0
	pos.y = 0
	local health = E:register_c("health")
	health.hp = 100
	health.hp_max = 100
	health.dead = false
	health.immune_to = 0
	local unit = E:register_c("unit")
	unit.level = 1
	unit.is_stunned = false
	unit.cooldown_factor = 1
	unit.blood_color = "red"
	local motion = E:register_c("motion")
	motion.dest = {
		x = 200,
		y = 0
	}
	motion.arrived = false
	motion.real_speed = 3
	motion.speed = {
		x = 0,
		y = 0
	}
	motion.max_speed = 3
	local nav_path = E:register_c("nav_path")
	nav_path.pi = 0
	nav_path.spi = 1
	nav_path.ni = 1
	nav_path.nodes = {}
	local heading = E:register_c("heading")
	heading.angle = 0
	local vis = E:register_c("vis")
	vis.flags = F_ENEMY
	vis.bans = 0
	local enemy = E:register_c("enemy")
	enemy.blockers = {}
	enemy.max_blockers = 1
	enemy.gold = 10
	enemy.gold_bag = 10
	enemy.lives_cost = 1
	local main_script = E:register_c("main_script")
	main_script.insert = nil
	main_script.update = nil
	main_script.remove = nil
	main_script.runs = 1
	main_script.co = nil
	local info = E:register_c("info")
	local sound_events = E:register_c("sound_events")
	sound_events.new_node = nil
	sound_events.new_node_args = nil
	local health_bar = E:register_c("health_bar")
	health_bar.hidden = nil

	local melee_attack = E:register_c("melee_attack")
	melee_attack.type = "melee"
	melee_attack.animation = "attack"
	melee_attack.cooldown = 30
	melee_attack.damage_min = 5
	melee_attack.damage_max = 10
	melee_attack.damage_type = DAMAGE_PHYSICAL
	melee_attack.hit_time = 10
	melee_attack.chance = 1
	melee_attack.vis_flags = 0
	melee_attack.vis_bans = 0
	melee_attack.ts = 0
	melee_attack.disabled = nil
	melee_attack.dodge_time = 4

	local melee = E:register_c("melee")
	melee.attacks = {}
	melee.attacks[1] = E:clone_c("melee_attack")
	melee.order = {1}
	melee.cooldown = nil
	melee.range = nil
	melee.arrived_slot_animation = "idle"

	local bullet_attack = E:register_c("bullet_attack")
	bullet_attack.type = "bullet"
	bullet_attack.cooldown = 30
	bullet_attack.damage_min = 5
	bullet_attack.damage_max = 10
	bullet_attack.damage_type = DAMAGE_PHYSICAL
	bullet_attack.min_range = 0
	bullet_attack.max_range = 200
	bullet_attack.vis_flags = F_RANGED
	bullet_attack.vis_bans = 0
	bullet_attack.ts = 0
	bullet_attack.disabled = nil

	local ranged = E:register_c("ranged")
	ranged.attacks = {}
	ranged.attacks[1] = E:clone_c("bullet_attack")
	ranged.order = {1}
	ranged.cooldown = nil
	ranged.range_while_blocking = nil

	local aura = E:register_c("aura")
	aura.mod = nil
	aura.mods = nil
	aura.duration = -1
	aura.cycle_time = 1
	aura.radius = 100
	aura.level = 1
	aura.damage_factor = 1
	aura.targets_per_cycle = nil
	aura.max_count = nil
	aura.cycles = nil
	aura.apply_delay = nil
	aura.apply_duration = nil
	aura.track_source = nil
	aura.track_dead = nil
	aura.source_id = nil
	aura.source_vis_flags = nil
	aura.requires_alive_source = nil
	aura.vis_flags = 0
	aura.vis_bans = 0
	aura.hide_source_fx = nil
	aura.allowed_templates = nil
	aura.excluded_templates = nil
	aura.filter_source = nil
	aura.cast_resets_sprite_id = nil
	aura.duration_inc = nil
	aura.ts = 0

	local modifier = E:register_c("modifier")
	modifier.type = nil
	modifier.level = 1
	modifier.target_id = nil
	modifier.source_id = nil
	modifier.damage_factor = 1

	-- 基础模板
	local unit_tpl = E:register_t("unit")
	E:add_comps(unit_tpl, "pos", "health", "unit", "motion", "nav_path", "heading", "vis", "render", "main_script", "info", "sound_events", "health_bar")
	unit_tpl.render.sprites[1].name = "idle"

	local enemy_tpl = E:register_t("enemy", "unit")
	E:add_comps(enemy_tpl, "enemy")
	enemy_tpl.vis.flags = F_ENEMY

	local aura_tpl = E:register_t("aura")
	E:add_comps(aura_tpl, "aura", "pos", "render", "main_script", "sound_events")
end

-- 设置全局 _G 引用（interface.lua 的 env 需要这些）
function M.set_globals(E, simulation_stub)
	_G.km = require("lib.klua.macros")
	_G.signal = require("lib.hump.signal")
	_G.AC = require("achievements")
	_G.GR = require("grid_db")
	_G.GS = require("kr1.game_settings")
	_G.P = require("path_db")
	_G.S = require("sound_db")
	_G.SU = require("script_utils") -- 将被设置
	_G.U = require("utils") -- 将被设置
	_G.LU = require("level_utils")
	_G.UP = require("kr1.upgrades")
	_G.V = require("lib.klua.vector")
	_G.E = E
	_G.band = package.loaded["bit"].band
	_G.bor = package.loaded["bit"].bor
	_G.bnot = package.loaded["bit"].bnot
	_G.is_file = function()
		return false
	end
	_G.queue_insert = function(store, e)
		if simulation_stub then
			simulation_stub:queue_insert_entity(e)
		end
	end
	_G.queue_remove = function(store, e)
		if simulation_stub then
			simulation_stub:queue_remove_entity(e)
		end
	end
end

-- 创建 simulation 存根
function M.make_simulation()
	return {
		store = nil,
		queue_insert_entity = function(self, e)
			if self.store then
				self.store.pending_inserts = self.store.pending_inserts or {}
				table.insert(self.store.pending_inserts, e)
			end
		end,
		queue_remove_entity = function(self, e)
			if self.store then
				self.store.pending_removals = self.store.pending_removals or {}
				table.insert(self.store.pending_removals, e)
			end
		end
	}
end

-- 创建 utils 存根
function M.make_utils()
	local U = {}
	local atan2, cos, sin = math.atan2, math.cos, math.sin

	function U.set_destination(e, pos)
		e.motion.dest.x, e.motion.dest.y = pos.x, pos.y
		e.motion.arrived = false
	end
	function U.set_heading(e, dest)
		e.heading.angle = atan2(dest.y - e.pos.y, dest.x - e.pos.x)
	end
	function U.walk_off__accel__unsnapped(e, dt)
		if e.motion.arrived then
			return true
		end
		local m, pos = e.motion, e.pos
		local vx, vy = m.dest.x - pos.x, m.dest.y - pos.y
		local step = m.real_speed * dt
		if vx * vx + vy * vy <= step * step then
			pos.x, pos.y = m.dest.x, m.dest.y
			m.speed.x, m.speed.y = 0, 0
			m.arrived = true
			return true
		end
		local v_angle = atan2(vy, vx)
		if e.heading then
			e.heading.angle = v_angle
		end
		local sx, sy = step * cos(v_angle), step * sin(v_angle)
		pos.x, pos.y = pos.x + sx, pos.y + sy
		m.speed.x, m.speed.y = sx / dt, sy / dt
		m.arrived = false
		return false
	end
	function U.animation_start()
	end
	function U.animation_name_facing_point(e, group)
		return group, nil
	end
	function U.y_animation_play()
	end
	function U.animation_finished()
		return true
	end
	function U.is_inside_ellipse(p, center, radius, aspect)
		aspect = aspect or 0.7
		return ((p.x - center.x) ^ 2 + ((p.y - center.y) / aspect) ^ 2) <= radius * radius
	end
	function U.cleanup_blockers(store, blocked)
		local blockers = blocked.enemy.blockers
		if not blockers then
			return
		end
		for i = #blockers, 1, -1 do
			if not store.entities[blockers[i]] then
				table.remove(blockers, i)
			end
		end
	end
	function U.find_nearest_soldier(entities, origin, min_range, max_range)
		local best, best_dist
		for _, soldier in pairs(entities) do
			if not soldier.health.dead then
				local d = math.sqrt((soldier.pos.x - origin.x) ^ 2 + (soldier.pos.y - origin.y) ^ 2)
				if d >= (min_range or 0) and d <= (max_range or 999999) then
					if not best_dist or d < best_dist then
						best, best_dist = soldier, d
					end
				end
			end
		end
		return best
	end
	function U.find_enemies_in_range_filter_on(origin, radius, flags, bans, filter_func)
		local store = _G._bench_store
		if not store then
			return {}
		end
		local result = {}
		for _, e in pairs(store.enemies) do
			if e and not e.health.dead and U.is_inside_ellipse(e.pos, origin, radius) then
				if not filter_func or filter_func(e) then
					result[#result + 1] = e
				end
			end
		end
		return result
	end
	function U.find_enemies_in_range_filter_off(origin, radius, flags, bans)
		return U.find_enemies_in_range_filter_on(origin, radius, flags, bans, nil)
	end
	function U.attack_order(attacks)
		local order = {}
		for i = 1, #attacks do
			order[i] = i
		end
		return order
	end
	return U
end

-- 创建 script_utils 存根
function M.make_script_utils(U)
	local SU = {}
	local P = require("path_db")

	function SU.y_enemy_walk_step(store, this, animation_name)
		animation_name = animation_name or "walk"
		local next, new = P:next_entity_node(this, store.tick_length)
		if not next then
			coroutine.yield()
			return false
		end
		U.set_destination(this, next)
		U.animation_start(this, animation_name, nil, store.tick_ts, true)
		U.walk_off__accel__unsnapped(this, store.tick_length)
		coroutine.yield()
		this.motion.speed.x, this.motion.speed.y = 0, 0
		return true
	end

	function SU.y_enemy_death(store, this)
		this.health.dead = true
	end

	function SU.y_enemy_stun(store, this)
		U.animation_start(this, "idle", nil, store.tick_ts, true)
		coroutine.yield()
	end

	function SU.y_wait_for_blocker()
		return true
	end

	function SU.can_melee_blocker(store, this, blocker)
		return not this.health.dead and not this.unit.is_stunned and blocker and not blocker.health.dead
	end

	function SU.y_enemy_melee_attacks(store, this, target)
		for _, i in ipairs(this.melee.order) do
			local ma = this.melee.attacks[i]
			if store.tick_ts - ma.ts > ma.cooldown then
				ma.ts = store.tick_ts
				if target.health and not target.health.dead then
					target.health.hp = target.health.hp - ma.damage_min
					if target.health.hp <= 0 then
						target.health.dead = true
					end
				end
				return true
			end
		end
		coroutine.yield()
		return true
	end

	function SU.can_range_soldier(store, this, soldier)
		if not this.ranged then
			return false
		end
		for _, ar in ipairs(this.ranged.attacks) do
			if store.tick_ts - ar.ts > ar.cooldown and not this.health.dead and not this.unit.is_stunned and not soldier.health.dead and U.is_inside_ellipse(soldier.pos, this.pos, ar.max_range) then
				return true
			end
		end
		return false
	end

	function SU.y_enemy_range_attacks(store, this, target)
		if not this.ranged then
			return true
		end
		for _, i in ipairs(this.ranged.order) do
			local ar = this.ranged.attacks[i]
			if store.tick_ts - ar.ts > ar.cooldown then
				ar.ts = store.tick_ts
				if target.health and not target.health.dead then
					target.health.hp = target.health.hp - ar.damage_min
					if target.health.hp <= 0 then
						target.health.dead = true
					end
				end
				return true
			end
		end
		coroutine.yield()
		return true
	end

	-- 原始 enemy_mixed.update 调用的专用行走函数
	function SU.y_enemy_walk_until_blocked_off__ignore_soldiers__func(store, this)
		local ranged, blocker
		while not blocker and not ranged do
			if this.unit.is_stunned then
				return false
			end
			if this.health.dead then
				return false
			end
			if P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
				if this.ranged and this.enemy and this.enemy.can_do_magic then
					for i = 1, #this.ranged.attacks do
						local a = this.ranged.attacks[i]
						if not a.disabled and (a.hold_advance or store.tick_ts - a.ts > a.cooldown) then
							ranged = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
							if ranged then
								break
							end
						end
					end
				end
				if #this.enemy.blockers > 0 then
					U.cleanup_blockers(store, this)
					blocker = store.entities[this.enemy.blockers[1]]
				end
			end
			if not blocker and not ranged then
				SU.y_enemy_walk_step(store, this)
			else
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end
		end
		return true, blocker, ranged
	end

	function SU.show_blood_pool()
	end
	return SU
end

-- ===================== 5. 实体克隆工具 =====================
function M.clone_entity_for_test(e)
	local c = M.deepclone(e)
	c.id = e.id
	c.main_script = M.deepclone(e.main_script)
	c.main_script.co = nil
	c.main_script.runs = 1
	return c
end

-- ===================== 6. 目标/士兵创建 =====================
function M.create_target_entity(E, id, x, y, flags, bans, hp)
	local t = E:create_entity("unit")
	t.id = id
	t.pos.x = x or 0
	t.pos.y = y or 0
	t.vis.flags = flags or F_NONE
	t.vis.bans = bans or 0
	t.health.hp = hp or 200
	t.health.hp_max = hp or 200
	t.health.dead = false
	return t
end

function M.create_soldiers(E, count, start_x, start_y)
	local soldiers = {}
	for i = 1, count do
		local s = M.create_target_entity(E, 20000 + i, start_x + (i - 1) * 40, start_y or 50, F_BLOCK, 0, 100)
		s.unit = {
			is_stunned = false,
			cooldown_factor = 1,
			level = 1
		}
		s.template_name = "soldier_" .. i
		soldiers[i] = s
	end
	return soldiers
end

-- ===================== 7. Store 管理 =====================
function M.create_store()
	local store = {
		tick_length = 1 / 30,
		tick_ts = 0,
		ts = 0,
		entities = {},
		enemies = {},
		soldiers = {},
		auras = {},
		modifiers = {},
		towers = {},
		entities_with_main_script_on_update = {},
		entities_with_main_script_on_update_index = {},
		entities_with_main_script_on_update_count = 0,
		pending_inserts = {},
		pending_removals = {}
	}
	_G._bench_store = store
	return store
end

function M.store_add_entity(store, e)
	store.entities[e.id] = e
	if e.enemy then
		store.enemies[e.id] = e
	end
	if e.unit and (e.vis.flags or 0) ~= F_ENEMY then
		store.soldiers[e.id] = e
	end
	if e.aura then
		store.auras[e.id] = e
	end
	if e.modifier then
		store.modifiers[e.id] = e
	end
	if e.main_script and e.main_script.update then
		local idx = store.entities_with_main_script_on_update_count + 1
		store.entities_with_main_script_on_update[idx] = e
		store.entities_with_main_script_on_update_index[e.id] = idx
		store.entities_with_main_script_on_update_count = idx
	end
end

-- ===================== 8. 模拟运行 =====================
function M.run_main_script_frame(store)
	for i = 1, store.entities_with_main_script_on_update_count do
		local e = store.entities_with_main_script_on_update[i]
		local s = e.main_script
		if not s.co and s.runs ~= 0 then
			s.runs = s.runs - 1
			s.co = coroutine.create(s.update)
		end
		if s.co then
			local ok, err = coroutine.resume(s.co, e, store)
			if coroutine.status(s.co) == "dead" or (not ok and err ~= nil) then
				if not ok and err ~= nil then
					error("Error running " .. (e.template_name or "?") .. " coro: " .. tostring(err))
				end
				s.co = nil
			end
		end
	end
end

function M.run_simulation_frame(store)
	store.tick_ts = store.tick_ts + (1 / 30)
	for i = 1, #store.pending_inserts do
		M.store_add_entity(store, store.pending_inserts[i])
	end
	store.pending_inserts = {}
	for i = 1, #store.pending_removals do
		local e = store.pending_removals[i]
		store.entities[e.id] = nil
		store.enemies[e.id] = nil
		store.soldiers[e.id] = nil
		store.auras[e.id] = nil
	end
	store.pending_removals = {}
	M.run_main_script_frame(store)
end

-- ===================== 9. 稳定 Benchmark =====================
local MIN_DURATION = 0.15 -- 最少运行 150ms，保证信噪比
local WARMUP_FRAMES = 100

-- 自适应 benchmark：自动找到合适的实体数量，使每轮运行达到 MIN_DURATION
-- run_fn(count, is_compiled) → void（运行完整的模拟过程）
function M.benchmark_stable(name, run_fn, compile_fn, opts)
	opts = opts or {}
	local rounds = opts.rounds or 7
	local min_dur = opts.min_duration or MIN_DURATION
	local max_entities = opts.max_entities or 200

	-- 校准阶段：找合适的实体数量
	local calibration_count = 10

	-- 快速测量单次运行时间（少次预热，一次测量）
	local function quick_measure(count)
		-- 一次预热
		run_fn(count, false)
		-- 一次测量（对比原始和编译各一次）
		local t0 = os.clock()
		run_fn(count, false)
		local orig_dt = os.clock() - t0
		t0 = os.clock()
		run_fn(count, true)
		local comp_dt = os.clock() - t0
		return orig_dt, comp_dt
	end

	-- 找到合适的实体数量
	local count = calibration_count
	local orig_per_run, comp_per_run
	for attempt = 1, 6 do -- 最多 6 次校准尝试
		orig_per_run, comp_per_run = quick_measure(count)
		local worst = math.max(orig_per_run, comp_per_run)
		if worst >= min_dur then
			break
		end
		if count >= max_entities then
			break
		end
		-- 估算需要的数量
		local ratio = min_dur / math.max(worst, 1e-9)
		count = math.min(max_entities, math.ceil(count * ratio * 1.5))
	end
	if count > max_entities then
		count = max_entities
	end

	-- 正式测试
	local orig_times, comp_times = {}, {}
	for round = 1, rounds do
		-- 预热
		run_fn(count, false)
		run_fn(count, true)

		-- 原始版本
		collectgarbage("collect")
		local t0 = os.clock()
		run_fn(count, false)
		local orig_dt = os.clock() - t0
		table.insert(orig_times, orig_dt)

		-- 编译版本
		collectgarbage("collect")
		t0 = os.clock()
		run_fn(count, true)
		local comp_dt = os.clock() - t0
		table.insert(comp_times, comp_dt)
	end

	return {
		name = name,
		entity_count = count,
		rounds = rounds,
		orig = orig_times,
		comp = comp_times
	}
end

-- ===================== 10. 统计分析 =====================
function M.mean(arr)
	local s = 0
	for i = 1, #arr do
		s = s + arr[i]
	end
	return s / #arr
end

function M.min(arr)
	local m = arr[1]
	for i = 2, #arr do
		if arr[i] < m then
			m = arr[i]
		end
	end
	return m
end

function M.max(arr)
	local m = arr[1]
	for i = 2, #arr do
		if arr[i] > m then
			m = arr[i]
		end
	end
	return m
end

function M.stddev(arr, mean)
	local m = mean or M.mean(arr)
	local s = 0
	for i = 1, #arr do
		s = s + (arr[i] - m) ^ 2
	end
	return math.sqrt(s / #arr)
end

function M.format_time(seconds)
	if seconds >= 1 then
		return string.format("%.3f s", seconds)
	end
	if seconds >= 0.001 then
		return string.format("%.2f ms", seconds * 1000)
	end
	return string.format("%.1f μs", seconds * 1000000)
end

function M.fmt_pct_change(old, new)
	return (new - old) / old * 100
end

-- ===================== 11. 结果输出 =====================
function M.print_result(r)
	local o_mean = M.mean(r.orig)
	local c_mean = M.mean(r.comp)
	local o_std = M.stddev(r.orig, o_mean)
	local c_std = M.stddev(r.comp, c_mean)
	local o_min = M.min(r.orig)
	local c_min = M.min(r.comp)
	local pct = (c_mean - o_mean) / o_mean * 100

	print(string.rep("─", 65))
	print("  " .. r.name)
	print(string.rep("─", 65))
	print(string.format("  实体数: %s | 轮次: %d", tostring(r.entity_count or "auto"), r.rounds))
	print("")
	print(string.format("  %-20s  %14s  %14s  %8s", "", "平均", "标准差", "最佳"))
	print(string.format("  %-20s  %14s  %14s  %8s", string.rep("─", 20), string.rep("─", 14), string.rep("─", 14), string.rep("─", 8)))
	print(string.format("  %-20s  %14s  %14s  %8s", "原始 (未编译)", M.format_time(o_mean), M.format_time(o_std), M.format_time(o_min)))
	print(string.format("  %-20s  %14s  %14s  %8s", "已编译", M.format_time(c_mean), M.format_time(c_std), M.format_time(c_min)))

	local arrow = pct < 0 and "🚀" or "⚠"
	print("")
	print(string.format("  性能变化: %+.2f%%  %s", -pct, (-pct) > 5 and "✓ 编译版本更快" or "~ 噪声范围内"))
	print("")
end

-- 简洁的汇总
function M.print_summary(all_results)
	print("")
	print(string.rep("=", 65))
	print("  汇  总")
	print(string.rep("=", 65))
	print("")
	local total_orig, total_comp = 0, 0
	for _, r in ipairs(all_results) do
		local o = M.mean(r.orig)
		local c = M.mean(r.comp)
		local pct = (c - o) / o * 100
		local tag = (-pct) > 5 and "✓" or "~"
		print(string.format("  %-30s %+8.2f%%  %s", r.name, -pct, tag))
		total_orig = total_orig + o
		total_comp = total_comp + c
	end
	local total_pct = (total_comp - total_orig) / total_orig * 100
	print(string.format("  %s", string.rep("-", 45)))
	print(string.format("  %-30s %+8.2f%%", "总计", -total_pct))
	print("")
end

-- ===================== 一次性初始化 =====================
local initialized = false
function M.ensure_initialized()
	if initialized then
		return
	end
	M.stub_love()
	M.stub_globals()
	M.stub_core_modules()
	initialized = true
end

return M
