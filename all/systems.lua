-- chunkname: @./all/systems.lua
MISSED_SS = {}
local log = require("lib.klua.log"):new("systems")
local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local perf = require("dove_modules.perf.perf")
local SystemsIndex = require("systems.index")
local IS_ANDROID = love.system.getOS() == "Android"
require("lib.klua.table")
require("lib.klua.dump")

local EU = require("endless_utils")
local A = require("animation_db")
local AC = require("achievements")
local DI = require("difficulty")
local I = require("lib.klove.image_db")
local SH = require("klove.shader_db")
local E = require("entity_db")
local P = require("path_db")
local F = require("lib.klove.font_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local S = require("sound_db")
local UP = require("kr1.upgrades")
local W = require("wave_db")
local U = require("utils")
local SU = require("script_utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local storage = require("all.storage")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local random = math.random
local ceil = math.ceil
local floor = math.floor
local sin = math.sin
local cos = math.cos
local PI = math.pi

require("all.constants")

local ffi = require("ffi")
local EXO = require("all.exoskeleton")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function fts(v)
	return v / FPS
end

local sys = {}

sys.level = {}
sys.level.name = "level"

function sys.level:init(store)
	perf.clear()
	local slot = storage:load_slot(nil, true)

	UP:set_levels(slot.upgrades)
	UP:set_list_id(slot.upgrade_list_id)
	DI:set_level(store.level_difficulty)
	GR:load(store.level_name)
	P:load(store.level_name, store.visible_coords)

	if store.config.reverse_path then
		P:reverse_all_paths()
	end

	E:load()
	DI:patch_templates()
	E:patch_config(store.config)
	W:load(store.level_name, store.level_mode, store.level_mode_override == GAME_MODE_ENDLESS)

	if store.criket and store.criket.on then
		W:patch_waves(store.criket)
	end

	if store.config.random_creeps then
		W:randomize_creeps()
	end

	A:load()
	EXO:load()

	store.selected_hero = slot.heroes.selected

	if store.level.init then
		store.level:init(store)
	end

	UP:patch_templates(store.level.max_upgrade_level or GS.max_upgrade_level)

	if store.level.data then
		store.level.locations = {}

		LU.insert_entities(store, store.level.data.entities_list)
		LU.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)
	end

	if store.level.load then
		store.level:load(store)
	end

	store.level.co = nil
	store.level.run_complete = nil
	store.player_gold = ceil(W:initial_gold() * store.config.gold_multiplier)

	-- 英雄经验乘数
	store.hero_xp_multiplier = GS.hero_xp_gain_per_difficulty_mode[store.level_difficulty] * store.config.hero_xp_gain_multiplier

	if store.level_idx <= 9 then
		store.hero_xp_multiplier = 0.1 * store.level_idx * store.hero_xp_multiplier
	elseif store.level_idx <= 35 and store.level_idx > 26 then
		store.hero_xp_multiplier = 0.1 * (store.level_idx - 26) * store.hero_xp_multiplier
	elseif store.level_idx <= 57 and store.level_idx > 48 then
		store.hero_xp_multiplier = 0.1 * (store.level_idx - 48) * store.hero_xp_multiplier
	elseif store.level_idx <= 109 and store.level_idx > 100 then
		store.hero_xp_multiplier = 0.1 * (store.level_idx - 100) * store.hero_xp_multiplier
	end

	if store.criket and store.criket.on then
		store.player_gold = store.criket.cash
	end

	if slot.locked_towers then
		for _, tower in pairs(slot.locked_towers) do
			if not table.find(store.level.locked_towers, tower) then
				table.insert(store.level.locked_towers, tower)
			end
		end
	end

	for _, unlock_tower in pairs(store.level.unlock_towers) do
		table.removeobject(store.level.locked_towers, unlock_tower)
	end

	if store.config.ban_random_towers then
		local locked_towers = store.level.locked_towers
		for i = 4, #GS.archer_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.archer_towers[i]
			end
		end
		for i = 4, #GS.mage_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.mage_towers[i]
			end
		end
		for i = 4, #GS.engineer_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.engineer_towers[i]
			end
		end
		for i = 4, #GS.barrack_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.barrack_towers[i]
			end
		end
	end

	if store.criket and store.criket.on then
		store.lives = 0
	elseif store.level_mode == GAME_MODE_CAMPAIGN then
		store.lives = 20
	elseif store.level_mode == GAME_MODE_HEROIC then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_IRON then
		store.lives = 1
	end

	if store.level_mode_override == GAME_MODE_ENDLESS then
		store.lives = 20
		store.player_gold = store.player_gold + W.endless.extra_cash
		store.endless = W.endless

		local endless_data = store.endless

		if endless_data.upgrade_levels then
			EU.patch_upgrades(endless_data)
		end

		if endless_data.player_gold then
			store.player_gold = endless_data.player_gold
		end

		if endless_data.lives then
			store.lives = endless_data.lives
		end

		if endless_data.wave_group_number then
			store.wave_group_number = endless_data.wave_group_number
		end

		if endless_data.towers then
			for _, tower_data in ipairs(endless_data.towers) do
				local tower = E:create_entity(tower_data.template_name)

				tower.pos = V.v(tower_data.pos.x, tower_data.pos.y)
				tower.tower.level = tower_data.tower_level
				tower.tower.spent = tower_data.spent
				tower.tower.holder_id = tower_data.holder_id

				for _, e in pairs(store.pending_inserts) do
					if e.tower and e.tower.holder_id == tower.tower.holder_id then
						if e.template_name == tower.template_name then
							-- 说明是同一座塔，移除待插入的旧数据
							goto continue
						end

						tower.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)

						if tower.ui and e.ui then
							tower.ui.nav_mesh_id = e.ui.nav_mesh_id
						end

						queue_remove(store, e)
					end
				end

				tower.tower.flip_x = tower_data.flip_x

				if tower_data.terrain_style then
					U.set_terrain_style(tower, tower_data.terrain_style)
				end

				-- 恢复技能等级
				if tower_data.powers and tower.powers then
					for power_name, power_data in pairs(tower_data.powers) do
						if tower.powers[power_name] then
							tower.powers[power_name].level = power_data.level
							tower.powers[power_name].changed = true
						end
					end
				end

				-- 恢复集结点
				if tower_data.rally_pos and tower.barrack then
					tower.barrack.rally_pos = V.v(tower_data.rally_pos.x, tower_data.rally_pos.y)

					if tower.mercenary then
						for i = 1, tower_data.soldier_count do
							tower.barrack.soldiers[i] = E:create_entity(tower.barrack.soldier_type)
							tower.barrack.soldiers[i].health.dead = true
							tower.barrack.soldiers[i].id = -1
						end
					end
				end

				queue_insert(store, tower)

				::continue::
			end
		end
	end

	store.player_score = 0
	store.game_outcome = nil
	store.main_hero = nil
end

function sys.level:on_update(dt, ts, store)
	perf.start("level")

	if not store.level.update then
		store.level.run_complete = true
	else
		if not store.level.co and not store.level.run_complete then
			store.level.co = coroutine.create(store.level.update)
		end

		if store.level.co then
			local success, error = coroutine.resume(store.level.co, store.level, store)

			if coroutine.status(store.level.co) == "dead" or error ~= nil then
				if error ~= nil then
					log.error("Error running level coro: %s", debug.traceback(store.level.co, error))
				end

				store.level.co = nil
				store.level.run_complete = true
			end
		end
	end

	if not store._common_notifications then
		local slot = storage:load_slot()

		store._common_notifications = true

		if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
			signal.emit("wave-notification", "view", "TIP_UPGRADES")
		elseif store.level_mode_override == GAME_MODE_ENDLESS then
			signal.emit("wave-notification", "view", "TIP_SURVIVAL")
		elseif store.selected_hero and #store.selected_hero ~= 0 and not U.is_seen(store, "TIP_HEROES") then
			signal.emit("wave-notification", "icon", "TIP_HEROES")
		elseif store.level_mode == GAME_MODE_CAMPAIGN and store.level_idx >= 13 and U.count_stars(slot) < 50 and not U.is_seen(store, "TIP_ELITE") then
			signal.emit("wave-notification", "view", "TIP_ELITE")
		end
	end

	if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
		LU.insert_hero(store)
	end

	if not store.game_outcome then
		if store.lives < 1 and (not store.criket or not store.criket.on) then
			log.info("++++ DEFEAT ++++")

			store.game_outcome = {
				victory = false,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}
			store.paused = true
			store.defeat_count = (store.defeat_count or 0) + 1

			local slot = storage:load_slot()

			slot.last_victory = nil

			signal.emit("game-defeat", store)
			signal.emit("game-defeat-after", store)
			storage:save_slot(slot, nil, true)
		elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
			if store.criket and store.criket.on then
				local stars = 3

				if store.lives < -10 then
					stars = 1
				elseif store.lives < -5 then
					stars = 2
				end

				store.criket.time_cost = store.tick_ts - store.criket.start_time
				store.game_outcome = {
					victory = true,
					lives_left = store.lives,
					stars = stars,
					level_idx = store.level_idx,
					level_mode = store.level_mode,
					level_difficulty = store.level_difficulty
				}

				signal.emit("game-victory", store)
				signal.emit("game-victory-after", store)

				return
			end

			log.info("++++ VICTORY ++++")

			local stars = 1

			if store.level_mode == GAME_MODE_CAMPAIGN then
				if store.lives >= 18 then
					stars = 3
				elseif store.lives >= 6 then
					stars = 2
				end
			end

			store.game_outcome = {
				victory = true,
				lives_left = store.lives,
				stars = stars,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}

			local slot = storage:load_slot()

			slot.last_victory = {
				level_idx = store.level_idx,
				level_difficulty = store.level_difficulty,
				level_mode = store.level_mode,
				stars = stars,
				unlock_towers = store.level.unlock_towers
			}

			signal.emit("game-victory", store)
			signal.emit("game-victory-after", store)
			storage:save_slot(slot, nil, true)
		end
	end
	perf.stop("level")
end

sys.tween = {}
sys.tween.name = "tween"

--- LERP FUNCTIONS BEGIN
local function lerp_boolean_multiply(a, b, t, s, key)
	s[key] = a[2] and s[key]
end

local function lerp_boolean(a, b, t, s, key)
	s[key] = a[2]
end

local function lerp_number_step_multiply(a, b, t, s, key)
	s[key] = a[2] * s[key]
end

local function lerp_number_step(a, b, t, s, key)
	s[key] = a[2]
end

local function lerp_number_linear_multiply(a, b, t, s, key)
	s[key] = a == b and (a[2] * s[key]) or ((a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1])) * s[key])
end

local function lerp_number_linear(a, b, t, s, key)
	s[key] = a == b and a[2] or (a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1]))
end

local function lerp_number_quad_multiply(a, b, t, s, key)
	if a == b then
		s[key] = a[2] * s[key]

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])

	s[key] = (a[2] + (b[2] - a[2]) * tt * tt) * s[key]
end

local function lerp_number_quad(a, b, t, s, key)
	if a == b then
		s[key] = a[2]

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])

	s[key] = a[2] + (b[2] - a[2]) * tt * tt
end

local function lerp_number_sine_multiply(a, b, t, s, key)
	s[key] = a == b and (a[2] * s[key]) or (a + (b - a) * (0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))) * s[key])
end

local function lerp_number_sine(a, b, t, s, key)
	s[key] = a == b and a[2] or (a[2] + (b[2] - a[2]) * (0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))))
end

local function lerp_table_step(a, b, t, s, key)
	s[key].x = a[2].x
	s[key].y = a[2].y
end

local function lerp_table_step_multiply(a, b, t, s, key)
	s[key].x = a[2].x * s[key].x
	s[key].y = a[2].y * s[key].y
end

local function lerp_table_linear(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * tt
	s[key].y = av.y + (bv.y - av.y) * tt
end

local function lerp_table_linear_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * tt) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * tt) * s[key].y
end

local function lerp_table_quad(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * tt * tt
	s[key].y = av.y + (bv.y - av.y) * tt * tt
end

local function lerp_table_quad_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local tt = (t - a[1]) / (b[1] - a[1])
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * tt * tt) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * tt * tt) * s[key].y
end

local function lerp_table_sine_multiply(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x * s[key].x
		s[key].y = a[2].y * s[key].y

		return
	end

	local ft = 0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))
	local av = a[2]
	local bv = b[2]

	s[key].x = (av.x + (bv.x - av.x) * ft) * s[key].x
	s[key].y = (av.y + (bv.y - av.y) * ft) * s[key].y
end

local function lerp_table_sine(a, b, t, s, key)
	if a == b then
		s[key].x = a[2].x
		s[key].y = a[2].y

		return
	end

	local ft = 0.5 * (1 - cos((t - a[1]) / (b[1] - a[1]) * PI))
	local av = a[2]
	local bv = b[2]

	s[key].x = av.x + (bv.x - av.x) * ft
	s[key].y = av.y + (bv.y - av.y) * ft
end
--- LERP FUNCTIONS END

function sys.tween:on_insert(entity, store)
	if entity.tween then
		for _, p in pairs(entity.tween.props) do
			for _, n in pairs(p.keys) do
				for i = 1, 2 do
					if type(n[i]) == "string" then
						local nf = loadstring("return " .. n[i])
						local env = {}

						env.this = entity
						env.store = store
						env.math = math
						env.U = U
						env.V = V

						setfenv(nf, env)

						n[i] = nf()
					end
				end
			end

			-- 为了避免每次更新都动态查找合适的插值函数，我们应该在 insert 的时候就确定下来。插值函数的赋值单元为 tween_prop。
			do
				local sprite = entity.render.sprites[p.sprite_id]
				local key_type

				if #p.keys == 0 then
					if sprite[p.name] then
						key_type = type(sprite[p.name])
					else
						error(entity.template_name .. " tween_prop " .. p.name .. " has no keys and sprite has no such property")
					end
				else
					key_type = type(p.keys[1][2])
				end

				local interp_type = p.interp or "linear"
				local multiply = p.multiply

				-- 初始化
				if not sprite[p.name] then
					if key_type == "table" then
						sprite[p.name] = V.vclone(p.keys[1][2])
					else
						sprite[p.name] = p.keys[1][2]
					end
				end

				-- 选择插值函数
				if key_type == "boolean" then
					p.interp_fn = multiply and lerp_boolean_multiply or lerp_boolean

					goto continue
				end

				if key_type == "number" then
					if interp_type == "linear" then
						p.interp_fn = multiply and lerp_number_linear_multiply or lerp_number_linear
					elseif interp_type == "sine" then
						p.interp_fn = multiply and lerp_number_sine_multiply or lerp_number_sine
					elseif interp_type == "step" then
						p.interp_fn = multiply and lerp_number_step_multiply or lerp_number_step
					elseif interp_type == "quad" then
						p.interp_fn = multiply and lerp_number_quad_multiply or lerp_number_quad
					end
				elseif key_type == "table" then
					if interp_type == "linear" then
						p.interp_fn = multiply and lerp_table_linear_multiply or lerp_table_linear
					elseif interp_type == "sine" then
						p.interp_fn = multiply and lerp_table_sine_multiply or lerp_table_sine
					elseif interp_type == "step" then
						p.interp_fn = multiply and lerp_table_step_multiply or lerp_table_step
					elseif interp_type == "quad" then
						p.interp_fn = multiply and lerp_table_quad_multiply or lerp_table_quad
					end
				end
			end

			::continue::
		end

		if entity.tween.random_ts then
			entity.tween.ts = U.frandom(-1 * entity.tween.random_ts, 0)
		end
	end

	return true
end

function sys.tween:on_update(dt, ts, store)
	perf.start("tween_system")
	local entities = store.entities_with_tween

	for _, e in pairs(entities) do
		if e.tween.disabled then
		-- block empty
		else
			local finished = true
			local sprites = e.render.sprites
			local tween = e.tween

			for _, tween_prop in pairs(tween.props) do
				if tween_prop.disabled then
				-- block empty
				else
					local s = sprites[tween_prop.sprite_id]
					local keys = tween_prop.keys
					local ka = keys[1]
					local kb = keys[#keys]
					local start_time = ka[1]
					local end_time = kb[1]
					local duration = end_time - start_time
					local time = ts - (tween_prop.ts or tween.ts or s.ts)

					if tween_prop.time_offset then
						time = time + tween_prop.time_offset
					end

					if tween_prop.loop then
						time = time % duration
					end

					if tween.reverse and not tween_prop.ignore_reverse then
						time = duration - time
					end

					time = time < start_time and start_time or (time > end_time and end_time or time)

					for i = 2, #keys do
						local ki = keys[i]

						if time <= ki[1] then
							kb = ki
							ka = time == ki[1] and ki or keys[i - 1]

							break
						end
					end

					-- 直接通过 interp_fn 来进行插值计算和赋值，避免创建中间变量与小表的频繁创建，降低 gc 压力
					-- debug usage: 检查铁皮错误的运行时搞事情
					-- if not tween_prop.interp_fn then
					--     log.error("entity %s tween_prop %s has no interp_fn", e.template_name, tween_prop.name)
					-- end
					tween_prop.interp_fn(ka, kb, time, s, tween_prop.name)

					finished = finished and (tween_prop.loop or ka == kb)
				end
			end

			if finished then
				if tween.remove then
					queue_remove(store, e)
				end

				if tween.run_once then
					tween.disabled = true
				end
			end
		end
	end
	perf.stop("tween_system")
end

sys.particle_system = {}
sys.particle_system.name = "particle_system"

ffi.cdef[[
    typedef struct {
        float pos_x;
        float pos_y;
        float r;
        float speed_x;
        float speed_y;
        float spin;
        float scale_x;
        float scale_y;
        float ts;
        float last_ts;
        float lifetime;
        int name_idx;
    } particle_t;
]]

sys.render = {}
sys.render.name = "render"

ffi.cdef[[
typedef struct {
    double sort_y;
    double pos_x;
    int z;
    int draw_order;
    int lua_index;
} RenderFrameFFI;
void ffi_sort(RenderFrameFFI* arr, RenderFrameFFI* tmp, int n);
]]

local lib_render_sort
local libname

if IS_ANDROID then
	-- 在安卓端需要在 jniLib 中提供一个名为 librender_sort_android.so 的库，包含 ffi_sort 函数的实现
	libname = "librender_sort_android.so"
else
	if jit and jit.os == "Windows" then
		libname = "all/librender_sort.dll"
	else
		libname = "all/librender_sort.so"
	end
end

local ok, lib = pcall(ffi.load, libname)

if ok and lib then
	lib_render_sort = lib
else
	-- fallback: 归并排序，直接用 FFI 数组和 tmp
	local function cmp(a, b)
		if a.z ~= b.z then
			return a.z < b.z
		end

		if a.sort_y ~= b.sort_y then
			return a.sort_y > b.sort_y
		end

		if a.draw_order ~= b.draw_order then
			return a.draw_order < b.draw_order
		end

		if a.pos_x ~= b.pos_x then
			return a.pos_x < b.pos_x
		end

		return false
	end

	local function merge(arr, tmp, left, mid, right)
		for i = left, right do
			tmp[i] = arr[i]
		end

		local i, j, k = left, mid + 1, left

		while i <= mid and j <= right do
			if not cmp(tmp[j], tmp[i]) then
				arr[k] = tmp[i]
				i = i + 1
			else
				arr[k] = tmp[j]
				j = j + 1
			end

			k = k + 1
		end

		while i <= mid do
			arr[k] = tmp[i]
			i = i + 1
			k = k + 1
		end

		while j <= right do
			arr[k] = tmp[j]
			j = j + 1
			k = k + 1
		end
	end

	local function merge_sort(arr, tmp, left, right)
		if left < right then
			local mid = math.floor((left + right) / 2)

			merge_sort(arr, tmp, left, mid)
			merge_sort(arr, tmp, mid + 1, right)
			merge(arr, tmp, left, mid, right)
		end
	end

	lib_render_sort = {
		ffi_sort = function(arr, tmp, n)
			merge_sort(arr, tmp, 0, n - 1)
		end
	}
end

function sys.render:init(store)
	store.render_frames = {}
	store.render_frames_ffi = ffi.new("RenderFrameFFI[16384]")
	store.render_frames_ffi_tmp = ffi.new("RenderFrameFFI[16384]")

	local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))

	self._hb_ss = {
		ref_scale = 1,
		quad = hb_quad,
		trim = {0, 0, 0, 0},
		size = {1, 1}
	}
	self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
	self._hb_colors = HEALTH_BAR_COLORS
end

function sys.render:on_insert(entity, store)
	local render_frames = store.render_frames

	if entity.render then
		for i = 1, #entity.render.sprites do
			local s = entity.render.sprites[i]

			s.marked_to_remove = false
			s._draw_order = 100000 * (s.draw_order or i) + entity.id

			if s.random_ts then
				s.ts = U.frandom(-1 * s.random_ts, 0)
			end

			if not s.pos then
				s.pos = {
					x = entity.pos.x,
					y = entity.pos.y
				}
				s._track_e = true
			end

			if s.shader then
				s._shader = SH:get(s.shader)
			end

			if not s.z then
				s.z = Z_OBJECTS
			end

			render_frames[#render_frames + 1] = s
		end
	end

	if entity.health_bar and store.config and store.config.show_health_bar then
		local hb = entity.health_bar
		local hbsize = self._hb_sizes[hb.type]
		local fb = {
			flip_x = false,
			pos = {
				x = 0,
				y = 0
			},
			r = 0,
			alpha = 255,
			anchor = {
				x = 0,
				y = 0
			},
			offset = {
				x = hb.offset.x,
				y = hb.offset.y
			},
			_draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id,
			z = Z_OBJECTS,
			sort_y_offset = hb.sort_y_offset,
			ss = self._hb_ss,
			color = hb.colors and hb.colors.bg or self._hb_colors.bg,
			bar_width = hbsize.x,
			scale = {
				x = hbsize.x,
				y = hbsize.y
			}
		}

		fb.offset.x = fb.offset.x - hbsize.x * fb.ss.ref_scale * 0.5

		local ff = {
			flip_x = false,
			pos = {
				x = 0,
				y = 0
			},
			r = 0,
			alpha = 255,
			anchor = {
				x = 0,
				y = 0
			},
			offset = {
				x = hb.offset.x,
				y = hb.offset.y
			},
			_draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id,
			z = Z_OBJECTS,
			sort_y_offset = hb.sort_y_offset,
			ss = self._hb_ss,
			color = hb.colors and hb.colors.fg or self._hb_colors.fg,
			bar_width = hbsize.x,
			scale = {
				x = hbsize.x,
				y = hbsize.y
			}
		}

		ff.offset.x = ff.offset.x - hbsize.x * ff.ss.ref_scale * 0.5

		for i = #hb.frames, 1, -1 do
			hb.frames[i].marked_to_remove = true
		end

		hb.frames[1] = fb
		hb.frames[2] = ff
		render_frames[#render_frames + 1] = fb
		render_frames[#render_frames + 1] = ff

		if hb.black_bar_hp then
			local fk = {
				flip_x = false,
				pos = {
					x = 0,
					y = 0
				},
				r = 0,
				alpha = 255,
				anchor = {
					x = 0,
					y = 0
				},
				offset = {
					x = hb.offset.x - hbsize.x * 0.5,
					y = hb.offset.y
				},
				_draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id,
				z = Z_OBJECTS,
				sort_y_offset = hb.sort_y_offset,
				ss = self._hb_ss,
				color = hb.colors and hb.colors.black or self._hb_colors.black,
				bar_width = hbsize.x,
				scale = {
					x = hbsize.x,
					y = hbsize.y
				}
			}

			hb.frames[3] = fk
			render_frames[#render_frames + 1] = fk
		end
	end

	return true
end

function sys.render:on_remove(entity, store)
	if entity.render then
		for i = #entity.render.sprites, 1, -1 do
			local s = entity.render.sprites[i]

			s.marked_to_remove = true
		-- 这里不可以置 nil，以防其它地方使用 sprite 时发生错误
		-- entity.render.sprites[i] = nil
		end
	end

	if store.config and store.config.show_health_bar and entity.health_bar then
		for i = #entity.health_bar.frames, 1, -1 do
			local f = entity.health_bar.frames[i]

			f.marked_to_remove = true
			entity.health_bar.frames[i] = nil
		end
	end

	return true
end

function sys.render:on_update(dt, ts, store)
	perf.start("render")
	local d = store
	local entities = d.entities_with_render
	local show_health_bar = store.config and store.config.show_health_bar

	for _, e in pairs(entities) do
		local sprites = e.render.sprites

		for i = 1, #sprites do
			local s = sprites[i]

			if s.ts > ts then
				s.hidden = true
				s._hidden_for_ts = true
			elseif s._hidden_for_ts then
				s.hidden = false
				s._hidden_for_ts = false
			end

			local last_runs = s.runs
			local fn

			if s.animation then
				A:generate_frames(s.animation)

				fn, s.runs, s.frame_idx = A:fni(s.animation, ts - s.ts + s.time_offset, s.loop, s.fps)
			elseif s.animated then
				fn, s.runs, s.frame_idx = A:fn(s.prefix and (s.prefix .. "_" .. s.name) or s.name, ts - s.ts + s.time_offset, s.loop, s.fps)
				s.frame_name = fn
			else
				s.runs = 0
				s.frame_idx = 1
				fn = s.name
			end

			if s.exo then
				local exo_frame = EXO:f(fn)

				if exo_frame then
					s.exo_frame = exo_frame

					-- local exo = exo_frame.exo

					-- s.exo = exo
					local exo = EXO:get_exo_by_frame(exo_frame)

					if s.exo_hide_prefix then
						for _, p in ipairs(exo_frame) do
							if p[1] == 1 then
								local pname = exo.parts[p[2]][1]

								p.hidden = false

								for _, prefix in ipairs(s.exo_hide_prefix) do
									if string.find(pname, prefix, 1, true) then
										p.hidden = true

										break
									end
								end
							end
						end
					end
				else
					-- fallback
					s.exo_frame = {}
				end
			else
				s.sync_flag = last_runs ~= s.runs
				s.ss = I:s(fn)

			-- 仅在开发时启用，用于检查美术资源
			-- if s.ss == nil then
			-- 	if s.animation and not MISSED_SS[s.animation] then
			-- 		log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
			-- 		log.error("Animation name: %s", s.animation)
			-- 		MISSED_SS[s.animation] = true
			-- 	elseif s.animated and not MISSED_SS[(s.prefix or "nil") .. "_" .. s.name] then
			-- 		log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
			-- 		log.error("Animated prefix: %s", s.prefix)
			-- 		log.error("Animated name: %s", s.name)
			-- 		MISSED_SS[(s.prefix or "nil") .. "_" .. s.name] = true
			-- 	elseif not MISSED_SS[s.name] then
			-- 		log.error("Failed to get sprite for entity %s, frame id: %d", e.template_name or e.id, i)
			-- 		log.error("Static sprite name: %s", s.name)
			-- 		MISSED_SS[s.name] = true
			-- 	end
			-- end
			end

			if s._track_e then
				s.pos.x, s.pos.y = e.pos.x, e.pos.y
			end

			if s.hide_after_runs and s.runs >= s.hide_after_runs then
				s.hidden = true
			end
		end

		if e.health_bar and show_health_bar then
			local hb = e.health_bar
			local fb = hb.frames[1]
			local ff = hb.frames[2]
			local fk = hb.black_bar_hp and hb.frames[3] or nil

			if hb.hidden or e.health.hp == e.health.hp_max then
				fb.hidden = true
				ff.hidden = true

				if fk then
					fk.hidden = true
				end
			else
				-- draw_order 属性在 insert 时即计算，我们要求后续永远不要出现操作 draw_order 的行为
				fb.hidden = false
				ff.hidden = false
				fb.pos.x, fb.pos.y = floor(e.pos.x), ceil(e.pos.y)
				ff.pos.x, ff.pos.y = fb.pos.x, fb.pos.y
				fb.offset.x, fb.offset.y = hb.offset.x - fb.bar_width * fb.ss.ref_scale * 0.5, hb.offset.y
				ff.offset.x, ff.offset.y = hb.offset.x - ff.bar_width * ff.ss.ref_scale * 0.5, hb.offset.y
				fb.z = hb.z or Z_OBJECTS
				ff.z = fb.z
				fb.sort_y_offset = hb.sort_y_offset
				ff.sort_y_offset = hb.sort_y_offset

				if fk then
					fk.hidden = false
					fk.pos.x, fk.pos.y = floor(e.pos.x), floor(e.pos.y)
					fk.offset.x, fk.offset.y = hb.offset.x - fk.bar_width * fk.ss.ref_scale * 0.5, hb.offset.y
					fk.z = hb.z or Z_OBJECTS
					fk.sort_y_offset = hb.sort_y_offset
					ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
					fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
				else
					if e.health.hp > e.health.hp_max then
						ff.scale.x = ff.bar_width
						ff.color = self._hb_colors.fg2
					else
						ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
						ff.color = self._hb_colors.fg
					end
				end
			end
		end
	end

	-- FFI同步
	local render_frames = store.render_frames
	local render_frames_ffi = store.render_frames_ffi
	local n = 0

	for i = 1, #render_frames do
		local f = render_frames[i]

		if not f.marked_to_remove then
			local ffi_f = render_frames_ffi[n]

			ffi_f.z = f.z
			ffi_f.sort_y = f.sort_y or (f.sort_y_offset or 0) + f.pos.y
			ffi_f.draw_order = f._draw_order
			ffi_f.pos_x = f.pos.x
			ffi_f.lua_index = i
			n = n + 1
		end
	end

	lib_render_sort.ffi_sort(render_frames_ffi, store.render_frames_ffi_tmp, n)

	local new_frames = {}

	local i = 0
	while i < n do
		local ffi_f = render_frames_ffi[i]
		i = i + 1
		new_frames[i] = render_frames[ffi_f.lua_index]
	end

	store.render_frames = new_frames
	perf.stop("render")
end

SystemsIndex.register_extracted(sys, {
	log = log,
	perf = perf,
	km = km,
	signal = signal,
	E = E,
	UP = UP,
	U = U,
	SU = SU,
	LU = LU,
	P = P,
	W = W,
	GS = GS,
	DI = DI,
	S = S,
	V = V,
	F = F,
	I = I,
	ASSETS_CHECK_ENABLED = ASSETS_CHECK_ENABLED,
	storage = storage,
	fts = fts,
	ceil = ceil,
	random = random,
	PI = PI,
	band = band,
	bor = bor,
	queue_insert = queue_insert,
	queue_remove = queue_remove,
	floor = floor
	,
	ffi = ffi,
	cos = cos,
	sin = sin,
	A = A
})

return sys
