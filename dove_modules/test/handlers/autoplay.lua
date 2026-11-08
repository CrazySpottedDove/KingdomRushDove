-- autoplay：由命令脚本驱动的无人值守跑关逻辑。
-- 不再自己做 game 初始化，关卡统一通过 open_level 走 director，这样测到的是真实加载路径。
local V = require("lib.klua.vector")
local LU = require("level_utils")
local E = require("entity_db")
local P = require("path_db")
local U = require("utils")
local S = require("sound_db")
local signal = require("lib.hump.signal")
local util = require("dove_modules.test.util")
local autoplay = {}
local TOWER_ROTATION = {"tower_ranger", "tower_sorcerer", "tower_barbarian", "tower_bfg", "tower_musketeer", "tower_arcane_wizard", "tower_tesla", "tower_paladin"}
local CLICK_INTERVAL = 0.5

local function ensure_state(harness)
	if harness.autoplay then
		return harness.autoplay
	end

	harness.autoplay = {
		auto_click = false,
		send_next_wave = true,
		force_boss = true,
		next_click_ts = 0,
		spell_id = nil,
		stats = {
			towers_built = 0,
			auto_clicks = 0,
			auto_hires = 0,
			spell_casts = 0
		}
	}

	return harness.autoplay
end

local function tower_name_at(rotation, idx, single)
	if single then
		return single
	end

	return rotation[((idx - 1) % #rotation) + 1]
end

--- 在指定塔位造塔。返回新建实体。
local function build_tower_at(harness, holder, name, level)
	local t = E:create_entity(name)

	if not t then
		error("tower template missing: " .. tostring(name))
	end

	t.pos = V.vclone(holder.pos)
	t.tower.spent = 100000

	if level then
		t.tower.level = level
	end

	t.tower.holder_id = holder.tower.holder_id

	if holder.tower.default_rally_pos then
		t.tower.default_rally_pos = V.vclone(holder.tower.default_rally_pos)

		if t.barrack then
			t.barrack.rally_pos = V.vclone(holder.tower.default_rally_pos)
		end
	end

	if t.ui and holder.ui then
		t.ui.nav_mesh_id = holder.ui.nav_mesh_id
	end

	if holder.tower.terrain_style then
		U.set_terrain_style(t, holder.tower.terrain_style)
	end

	simulation:queue_insert_entity(t)
	simulation:queue_remove_entity(holder)

	harness.autoplay.stats.towers_built = harness.autoplay.stats.towers_built + 1

	return t
end

function autoplay.build_all_towers(harness, args)
	local game = util.require_game(harness)
	local store = game.store

	ensure_state(harness)

	local rotation = args.rotation or TOWER_ROTATION
	local level = tonumber(args.level)
	local single = args.tower
	local built = 0

	for _, holder_id in ipairs(util.tower_holder_ids(store)) do
		if not util.find_tower_by_holder(store, holder_id) then
			local holder = util.find_holder(store, holder_id)

			if holder then
				build_tower_at(harness, holder, tower_name_at(rotation, built + 1, single), level)

				built = built + 1
			end
		end
	end

	return {
		built = built,
		towers = harness.autoplay.stats.towers_built
	}
end

function autoplay.build_tower(harness, args)
	local store = util.require_game(harness).store

	if not args.holder_id then
		error("build_tower requires holder_id")
	end

	local holder = util.find_holder(store, args.holder_id)

	if not holder then
		error("tower holder not found: " .. tostring(args.holder_id))
	end

	ensure_state(harness)

	local name = args.tower or TOWER_ROTATION[1]

	build_tower_at(harness, holder, name, tonumber(args.level))

	return {
		holder_id = args.holder_id,
		tower = name
	}
end

--- 把实体所在的世界坐标换算成窗口坐标，模拟一次真实鼠标左键点击。
local function simulate_click_at(harness, e)
	local game = util.require_game(harness)
	local game_gui = game.game_gui

	if not game_gui or not game_gui.window or not e.pos then
		return
	end

	local wx, wy = e.pos.x, e.pos.y
	local rect = e.ui and e.ui.click_rect

	if rect then
		wx = e.pos.x + rect.pos.x + rect.size.x * 0.5
		wy = e.pos.y + rect.pos.y + rect.size.y * 0.5
	end

	local ux, uy = game_gui:g2u(V.v(wx, wy))
	local origin = game_gui.window.origin
	local scale = game_gui.window.scale
	local sx = origin.x + ux * scale.x
	local sy = origin.y + uy * scale.y

	game_gui:mousepressed(sx, sy, 1)
	game_gui:mousereleased(sx, sy, 1)
end

--- 强制推进 boss 阶段：按 phases_health_thresholds 把 boss 血量逐档压低。
function autoplay.force_boss_phases(harness)
	local game = util.require_game(harness)

	for _, e in pairs(game.store.entities) do
		if e.health and not e.health.dead and not e.pending_removal and e.phases_health_thresholds and e.health.hp_max > 0 then
			local hp_max = e.health.hp_max

			for _, t in ipairs(e.phases_health_thresholds) do
				if e.health.hp >= hp_max * t then
					e.health.hp = hp_max * t - 1

					break
				end
			end
		end
	end
end

--- 模拟玩家点击带 ui 的世界物件与特殊塔，并校验特殊塔菜单数据。
function autoplay.run_clicks(harness)
	local game = util.require_game(harness)
	local store = game.store
	local state = ensure_state(harness)
	local ts = store.tick_ts

	if ts < state.next_click_ts then
		return
	end

	state.next_click_ts = ts + CLICK_INTERVAL

	for _, e in pairs(store.entities_with_ui) do
		if e.ui and e.ui.can_click and not e.pending_removal and not e.enemy and not e.hero and not e.soldier and not e.tower then
			simulate_click_at(harness, e)

			state.stats.auto_clicks = state.stats.auto_clicks + 1
		end
	end

	for _, e in pairs(store.entities) do
		if e.tower and e.user_selection and e.ui and e.ui.can_click and not e.pending_removal and not e.tower.blocked and (e.tower_action or e.soldier_t) then
			if not e._autoplay_menu_checked then
				e._autoplay_menu_checked = true

				local tmd = require("kr1.data.tower_menus_data")
				local menus = tmd[e.tower.type]
				local list = menus and (menus[e.tower.level or 1] or menus[1])

				if not list then
					error("special tower menu missing/empty in tower_menus_data: " .. tostring(e.tower.type))
				end

				for _, item in pairs(list) do
					local action = item.action
					local bad

					if action == "tw_repair" then
						if not e.repair then
							bad = "needs entity.repair (cost/active)"
						end
					elseif action == "tw_buy_soldier" then
						local nt = E:get_template(item.action_arg)

						if not (nt and nt.unit and nt.unit.price) then
							bad = "bad action_arg " .. tostring(item.action_arg)
						end
					elseif action == "tw_buy_attack" then
						if not (e.attacks and e.attacks.list and e.attacks.list[item.action_arg]) then
							bad = "bad action_arg " .. tostring(item.action_arg)
						end
					elseif action == "tw_point" or action == "tw_free_action" then
						if not e.user_selection then
							bad = action .. " needs entity.user_selection"
						end
					elseif action == "tw_custom_no_close" or action == "tw_custom_close" then
						if not (e.tower_action and e.tower_action.cost) then
							bad = action .. " needs entity.tower_action (cost/active)"
						end
					elseif action == "tw_upgrade" then
						if not E:get_template(item.action_arg) then
							bad = "missing template " .. tostring(item.action_arg)
						end
					elseif action == "upgrade_power" then
						if not (e.powers and e.powers[item.action_arg]) then
							bad = "bad action_arg " .. tostring(item.action_arg)
						end
					elseif action == "tw_change_mode" then
						if not e.tower_upgrade_persistent_data then
							bad = "needs tower_upgrade_persistent_data"
						end
					end

					if bad then
						error(string.format("tower menu item invalid (%s/%s): %s", tostring(e.tower.type), tostring(action), bad))
					end
				end
			end

			simulate_click_at(harness, e)

			state.stats.auto_clicks = state.stats.auto_clicks + 1

			if e.tower_action and not e.tower_action.active then
				e.user_selection.in_progress = true
				state.stats.auto_hires = state.stats.auto_hires + 1
			end
		end
	end
end

--- 在当前场景释放 power3 法术。
function autoplay.cast_spell(harness, args)
	local game = util.require_game(harness)
	local store = game.store
	local state = ensure_state(harness)
	local spell_id = (args and args.id) or state.spell_id
	local spell_level = args and args.level or state.spell_level

	if not spell_id then
		error("cast_spell requires spell id")
	end

	local up = E:get_template("user_power_3")

	if not up or not up.cooldown or up.template_name == "user_power_3" then
		error("spell template user_power_3 is not ready")
	end

	if not args and state.last_spell_ts and store.tick_ts - state.last_spell_ts < up.cooldown then
		return {
			skipped = "cooldown"
		}
	end

	local pos

	if args and args.x and args.y then
		pos = {
			x = tonumber(args.x),
			y = tonumber(args.y)
		}
	else
		for _, t in pairs(store.towers or {}) do
			if t.pos then
				pos = t.pos

				break
			end
		end
	end

	if not pos then
		local nearest = P:nearest_nodes(REF_W * 0.5, REF_H * 0.5)

		if nearest and nearest[1] then
			local pi, spi, ni = unpack(nearest[1])

			pos = P:node_pos(pi, spi, ni)
		end
	end

	if not pos then
		error("cannot resolve spell position")
	end

	local fn = up.user_selection and up.user_selection.can_select_point_fn

	if fn and not fn(up, pos.x, pos.y, store) then
		pos = P:node_pos(1, 1, math.min(10, #P.paths[1][1]))
	end

	local e = E:create_entity("user_power_3")

	e.pos.x, e.pos.y = pos.x, pos.y

	simulation:queue_insert_entity(e)
	signal.emit("power-used", 3)

	state.last_spell_ts = store.tick_ts
	state.stats.spell_casts = state.stats.spell_casts + 1

	return {
		spell = spell_id,
		level = spell_level,
		x = pos.x,
		y = pos.y,
		casts = state.stats.spell_casts
	}
end

function autoplay.autoplay_start(harness, args)
	local game = util.require_game(harness)
	local state = ensure_state(harness)
	local stats = state.stats

	state.auto_click = args.auto_click ~= false
	state.send_next_wave = args.send_next_wave ~= false
	state.force_boss = args.force_boss ~= false
	state.spell_id = args.spell
	state.spell_level = args.spell_level
	state.next_click_ts = 0
	game.store.lives = tonumber(args.lives) or 99999
	game.store.paused = false

	-- 关卡实体（塔位等）在 game-start 之后还会继续插入；先空推几帧再铺塔，
	-- 否则会像旧 autoplay 一样漏掉整张图的塔位。
	local warmup_ticks = tonumber(args.warmup_ticks) or 10

	for _ = 1, warmup_ticks do
		harness:step_once()
	end

	if stats.game_started_ts == nil then
		stats.game_started_ts = game.store.tick_ts
	end

	local built = 0

	if args.build_towers ~= false then
		local result = autoplay.build_all_towers(harness, args)

		built = result.built
	end

	return {
		started = true,
		build_towers = args.build_towers ~= false,
		auto_click = state.auto_click,
		send_next_wave = state.send_next_wave,
		force_boss = state.force_boss,
		spell = state.spell_id,
		built = built,
		lives = game.store.lives
	}
end

function autoplay.autoplay_stop(harness)
	local state = ensure_state(harness)

	state.auto_click = false
	state.send_next_wave = false
	state.force_boss = false

	return {
		stopped = true
	}
end

function autoplay.set_auto_click(harness, args)
	local state = ensure_state(harness)

	state.auto_click = args.enabled ~= false

	return {
		auto_click = state.auto_click
	}
end

function autoplay.set_force_boss(harness, args)
	local state = ensure_state(harness)

	state.force_boss = args.enabled ~= false

	return {
		force_boss = state.force_boss
	}
end

--- 固定步长推进一帧游戏内逻辑。不用 game:update，避免 adaptive_fps 改写固定 tick。
function autoplay.step_game(harness)
	local game = util.require_game(harness)
	local store = game.store
	local state = ensure_state(harness)

	store.paused = false

	if state.send_next_wave and store.next_wave_group_ready and not store.send_next_wave and not LU.has_alive_enemies(store) then
		store.send_next_wave = true
	end

	if state.auto_click then
		autoplay.run_clicks(harness)
	end

	if state.force_boss then
		autoplay.force_boss_phases(harness)
	end

	if state.spell_id then
		local ok, err = pcall(autoplay.cast_spell, harness)

		if not ok then
			error(err)
		end
	end

	game.simulation:update(TICK_LENGTH)
	game.simulation:render_update(TICK_LENGTH)
	S:update(TICK_LENGTH)

	if game.game_gui then
		game.game_gui:update(TICK_LENGTH)
	end

	local stats = state.stats

	stats.total_ts = store.tick_ts
	stats.wave_group_number = store.wave_group_number
	stats.wave_group_total = store.wave_group_total
	stats.lives = store.lives

	if store.game_outcome then
		stats.victory = store.game_outcome.victory
	end
end

function autoplay.report(harness)
	local state = ensure_state(harness)
	local snap = harness:snapshot()

	return {
		stats = state.stats,
		state = snap,
		log_errors = harness.log_errors
	}
end

return autoplay
