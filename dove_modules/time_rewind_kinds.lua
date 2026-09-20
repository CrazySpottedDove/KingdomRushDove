-- chunkname: @./dove_modules/time_rewind_kinds.lua
-- 本体的回溯决定登记表：一处放齐 apply / valid / label 与按自然键找回目标的查找。
-- 键一律用游戏自己的存档身份（塔 = tower.holder_id；英雄/可点物件 = 模板名 + 唯一性），
-- 不要用 entity.id —— 它按创建顺序发号，重演一遍就会错位。
-- game_gui 只负责「什么时候记」：time_rewind.decision(RK.xxx, ...)。
local time_rewind = require("dove_modules.time_rewind")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local V = require("lib.klua.vector")
local P = require("path_db")
local GR = require("grid_db")
local LU = require("level_utils")
local U = require("utils")

require("i18n")

-- ── 回溯决定：目标键与查找 ──────────────────────────────────────────
-- 决定的目标键一律用「游戏自己存档/恢复时用的身份」。塔用 tower.holder_id（关卡作者标的塔位），
-- 不能用 entity.id：它是 entity_db.last_id 单调计数器，按创建顺序发号，重演一遍就会错位。
-- 必须声明在所有登记闭包之前：闭包体运行时才查名，声明在后的会静默解析成全局 nil。
local function tower_by_holder_id(store, holder_id)
	if holder_id == nil then
		return nil
	end

	for _, e in pairs(store.towers) do
		if e.tower.holder_id == holder_id then
			return e
		end
	end
end

-- 可调集单位的解析：先用 template_name 锁定同一种单位。
-- 只有唯一一个时直接用它（不必比对坐标）；有多个同类时，才按"记录那一刻的坐标"取最近的，
-- 并要求落在 RALLY_MATCH_RADIUS 内 —— 多个才需要半径筛选，最近者超距就当作没找到。
local RALLY_MATCH_RADIUS = 80

local function resolve_rally_unit(store, template_name, x, y)
	local found, count = nil, 0
	local best, best_d2 = nil, RALLY_MATCH_RADIUS * RALLY_MATCH_RADIUS

	for _, e in pairs(store.entities) do
		if e.template_name == template_name and e.nav_rally and not e.health.dead and (e.hero or e.controable) then
			count = count + 1
			found = e

			local dx, dy = e.pos.x - x, e.pos.y - y
			local d2 = dx * dx + dy * dy

			if d2 <= best_d2 then
				best, best_d2 = e, d2
			end
		end
	end

	if count == 1 then
		return found, count
	end

	return best, count
end

-- 点「可点的世界物件」（羊、特殊可点敌人…）。这类点击真正改变世界，但目标本身是随机世界结果，
-- 所以键用 template_name 且要求同型**恰好一个**：不唯一就静默跳过，绝不把点击下到别的物件上。
local function clickable_by_template(store, template_name)
	local found, count = nil, 0

	for _, e in pairs(store.entities_with_ui) do
		if e.template_name == template_name and e.ui.can_click and not (e.tower or e.hero or e.controable) then
			count = count + 1
			found = e
		end
	end

	return found, count
end

-- 扝塔/交换：`tw_change_mode`（已接）让塔的 ghost 脚本把 swap_entity 指向携带的 ghost 并进
-- SWAP_TOWER，玩家再点目标时本体插一个 controller_tower_swap 去执行交换。重演里携带状态由
-- change_mode 的决定复现，所以这里只记目标键（holder_id），apply 直接读重演世界的 swap_entity。
local KIND_TOWER_SWAP = time_rewind.register("tower_swap", {
	apply = function(game, holder_id)
		local carried = game.game_gui.swap_entity
		local target = tower_by_holder_id(game.simulation.store, holder_id)

		if not carried or not target then
			return
		end

		game.game_gui:deselect_entity()

		local controller = E:create_entity("controller_tower_swap")

		controller.tower_1 = carried
		controller.tower_2 = target

		game.simulation:insert_entity(controller)
	end,
	valid = function(game, holder_id)
		return game.game_gui.swap_entity ~= nil and tower_by_holder_id(game.simulation.store, holder_id) ~= nil
	end
})
-- 一键随机建塔（F8 热键与暂停菜单按钮都调它）：把每个塔位的随机塔型一次性解析出来、
-- 记成一条决定，再照单建。随机塔属于世界结果，重演必须复现同一批，不能重摇一遍。
local KIND_RANDOM_TOWERS = time_rewind.register("random_towers", {
	apply = function(game, resolved)
		game.game_gui:build_random_towers(resolved)
	end
})
-- 提前召唤：send_next_wave 是「现在就来下一波」，force_next_wave 是「清掉当前波直接跳」。
-- 只登记玩家侧入口（热键/按钮）；boss 脚本里那些 store.force_next_wave = true 是世界结果，不该进日志。
local KIND_NEXT_WAVE = time_rewind.register("next_wave", {
	apply = function(game)
		game.simulation.store.send_next_wave = true
	end
})
local KIND_FORCE_WAVE = time_rewind.register("force_next_wave", {
	apply = function(game)
		game.simulation.store.force_next_wave = true
	end
})
-- 调试作弊入口（F6 加钱 / F7 加命，暂停菜单里也有同样两个按钮）：它们同样改世界，
-- 不记的话回溯一遍就丢了。记的是增量；金币/生命本身仍按重演世界自己的数值走。
local KIND_CHEAT_GOLD = time_rewind.register("cheat_gold", {
	apply = function(game, amount)
		game.simulation.store.player_gold = game.simulation.store.player_gold + amount
	end
})
local KIND_CHEAT_LIVES = time_rewind.register("cheat_lives", {
	apply = function(game, amount)
		game.simulation.store.lives = game.simulation.store.lives + amount
	end
})
-- ── 回溯决定：点选一个位置（兵营集结点 / 攻击方式定点 / 自由动作 / 修理都走这里）──
-- 进模式那一下不记（那是 UI 状态），真正提交是这里；arg 也一起记，因为它是进模式时选的，
-- 重演世界不一定还有这个状态。
local KIND_USER_POINT = time_rewind.register("tower_user_point", {
	apply = function(game, holder_id, x, y, arg)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.user_selection.in_progress = false
			t.user_selection.arg = arg
			t.user_selection.new_pos = V.v(x, y)
		end
	end,
	valid = function(game, holder_id)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		return t ~= nil and t.user_selection ~= nil
	end
})
-- ── 回溯决定：释放技能 / 调遣英雄 ────────────────────────────────────
-- 玩家技能只有 power_1 / power_2（本体只有 Power1Button/Power2Button；GUI_MODE_POWER_3 是
-- 留下的死分支，本项目没有第三个按钮），记「第几个 + 落点」，valid 就是该按钮在当前关卡存在。
-- 调遣英雄的键用 selected_hero_to_summon（本体存的就是 item.name 这个字符串），不是 entity.id。
local KIND_POWER_FIRE = time_rewind.register("power_fire", {
	apply = function(game, which, x, y)
		local gui = game.game_gui
		local button = gui["power_" .. which]

		if button then
			button:fire(x, y)
		end
	end,
	valid = function(game, which)
		local gui = game.game_gui

		return gui["power_" .. which] ~= nil
	end,
	label = function(which, x, y)
		return string.format("%s %d @ %.0f,%.0f", _("INGAME_UI_TIME_REWIND_ARG_POWER"), which, x, y)
	end
})
local KIND_SUMMON_HERO = time_rewind.register("summon_hero", {
	apply = function(game, hero_name, x, y)
		LU.insert_hero(game.simulation.store, hero_name, V.v(x, y))
	end
})
-- 兵营集结点：本体可能把玩家点的位置夹到该方向上最远的合法点上，所以记「解析后的落点」。
-- valid 重做玩家点选时的同一套前提判定（椭圆范围 + 地形），前提不成立就静默跳过。
local KIND_BARRACK_RALLY = time_rewind.register("barrack_rally", {
	apply = function(game, holder_id, x, y)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t and t.barrack then
			t.barrack.rally_pos = V.v(x, y)
			t.barrack.rally_new = true
		end
	end,
	valid = function(game, holder_id, x, y)
		local t = tower_by_holder_id(game.simulation.store, holder_id)
		local b = t and t.barrack

		if not b then
			return false
		end

		local center = V.v(t.pos.x + t.tower.range_offset.x, t.pos.y + t.tower.range_offset.y)

		return U.is_inside_ellipse(V.v(x, y), center, b.rally_range) and (b.rally_anywhere or P:valid_node_nearby(x, y, nil, NF_RALLY) and GR:cell_is_only(x, y, b.rally_terrains))
	end
})
-- 英雄 / 可控单位调遣：记「单位当时的坐标 + 落点」，重演时按坐标就近找回同一个单位
-- （多个同型援军也能区分开）。落点前提与玩家点选时同一套判定。
local KIND_UNIT_RALLY = time_rewind.register("unit_rally", {
	apply = function(game, template_name, unit_x, unit_y, x, y)
		local e = resolve_rally_unit(game.simulation.store, template_name, unit_x, unit_y)

		if not e then
			return
		end

		if not e.nav_grid.ignore_waypoints then
			e.nav_grid.waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(x, y), e.nav_grid.valid_terrains)
		end

		e.nav_rally.new = true
		e.nav_rally.pos = V.v(x, y)
		e.nav_rally.center = V.v(x, y)
	end,
	valid = function(game, template_name, unit_x, unit_y, x, y)
		local e = resolve_rally_unit(game.simulation.store, template_name, unit_x, unit_y)

		return e ~= nil and (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(x, y, nil, NF_RALLY)) and GR:cell_is_only(x, y, e.nav_grid.valid_terrains_dest)
	end
})
-- 集体调遣：本体是两组互斥的可调集单位（援军 = controable_other，其余 = 非 controable_other），
-- 两个热键各选一组，所以决定也分两种。只记落点；当时选了哪些属于 UI 状态，不进日志。
-- 单位绕点击点摆成一圈，顺序由遍历顺序决定。
local function rally_units(game, x, y, want_other)
	local store = game.simulation.store
	local units = {}
	local n = 0

	for _, e in pairs(store.soldiers) do
		if e.controable and not e.health.dead and (e.controable_other and true or false) == want_other then
			n = n + 1
			units[n] = e
		end
	end

	for idx = 1, n do
		local e = units[idx]
		local rally_pos = V.v(x + 15 * math.cos(idx * 2 * math.pi / n), y + 15 * math.sin(idx * 2 * math.pi / n))

		if GR:cell_is_only(rally_pos.x, rally_pos.y, e.nav_grid.valid_terrains_dest) then
			local waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, rally_pos, e.nav_grid.valid_terrains)

			if waypoints then
				e.nav_grid.waypoints = waypoints
				e.nav_rally.new = true
				e.nav_rally.pos = rally_pos
				e.nav_rally.center = rally_pos
			end
		end
	end
end

local function register_group_rally(name, want_other)
	return time_rewind.register(name, {
		apply = function(game, x, y)
			rally_units(game, x, y, want_other)
		end,
		valid = function(game, x, y)
			return P:valid_node_nearby(x, y, nil, NF_RALLY)
		end,
		label = function(x, y, flag)
			return string.format("%s @ %.0f,%.0f", flag == 1 and _("INGAME_UI_TIME_REWIND_ARG_RALLY_REINF") or _("INGAME_UI_TIME_REWIND_ARG_RALLY_UNITS"), x, y)
		end
	})
end

local KIND_UNITS_RALLY = register_group_rally("units_rally", false)
local KIND_REINFORCE_RALLY = register_group_rally("reinforce_rally", true)

-- 点可点的世界物件：apply 只把 ui.clicked 置回去，剩下交给原来那个脚本（羊被打掉之类）。
local KIND_WORLD_CLICK = time_rewind.register("world_click", {
	apply = function(game, template_name)
		local e = clickable_by_template(game.simulation.store, template_name)

		if e then
			e.ui.clicked = true
		end
	end,
	valid = function(game, template_name)
		local _, count = clickable_by_template(game.simulation.store, template_name)

		return count == 1
	end
})
-- ── 回溯决定：塔的升级 / 解封 ────────────────────────────────────────
-- 记录的是「解析完的升级目标」而不是 item.action_arg：随机塔（tower_random_*）的实际结果
-- 是点击那一刻摇出来的，只记 action_arg 会在重演时重新摇一次、变成另一座塔 —— 这正是
-- 「回溯前后部分防御塔变了」的主因之一。
local KIND_TOWER_UPGRADE = time_rewind.register("tower_upgrade", {
	apply = function(game, holder_id, upgrade_to)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.tower.upgrade_to = upgrade_to
			signal.emit("tower-built")
		end
	end,
	valid = function(game, holder_id)
		return tower_by_holder_id(game.simulation.store, holder_id) ~= nil
	end
})
local KIND_TOWER_SELL = time_rewind.register("tower_sell", {
	apply = function(game, holder_id)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.tower.sell = true
		end
	end,
	valid = function(game, holder_id)
		return tower_by_holder_id(game.simulation.store, holder_id) ~= nil
	end
})
-- 技能/强化升级：本体在这里直接扣钱，所以价钱进日志，重演按记录的价钱扣（金币余额允许和原来不同）
local KIND_POWER_UPGRADE = time_rewind.register("tower_power_upgrade", {
	apply = function(game, holder_id, power_name, level, spent)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		local power = t.powers[power_name]

		power.level = level
		power.changed = true

		local store = game.simulation.store

		store.player_gold = store.player_gold - spent
		t.tower.spent = t.tower.spent + spent

		signal.emit("tower-power-upgraded", t, power)
	end,
	valid = function(game, holder_id, power_name, level)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		return t ~= nil and t.powers ~= nil and t.powers[power_name] ~= nil and t.powers[power_name].level < level
	end
})
local KIND_BARRACK_UNIT = time_rewind.register("barrack_buy_soldier", {
	apply = function(game, holder_id, unit)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.barrack.unit_bought = unit
		end
	end,
	valid = function(game, holder_id)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		return t ~= nil and t.barrack ~= nil
	end
})
-- 兵营的集结点/攻击方式：只有 ignore_point 那条是当场提交，其余是进模式等玩家点位置（那一下单独记）
local KIND_BARRACK_ATTACK = time_rewind.register("barrack_buy_attack", {
	apply = function(game, holder_id, arg)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.user_selection.arg = arg
		end
	end,
	valid = function(game, holder_id)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		return t ~= nil and t.user_selection ~= nil
	end
})
local KIND_TOWER_MODE = time_rewind.register("tower_change_mode", {
	apply = function(game, holder_id, arg, current_mode)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		if t then
			t.change_mode = true
			t.tower_upgrade_persistent_data.current_mode = current_mode

			local us = t.user_selection

			if us then
				us.in_progress = true
				us.arg = arg
				us.new_pos = nil
			end

			if not t.user_selection_func or t.user_selection_func(t, game.simulation.store) then
			-- block empty
			end
		end
	end,
	valid = function(game, holder_id)
		local t = tower_by_holder_id(game.simulation.store, holder_id)

		return t ~= nil and t.tower_upgrade_persistent_data ~= nil
	end
})

-- 名字 -> 决定 id：调用点用 RK.<名字>，热路径上只是一个数字
local RK = {
	barrack_buy_attack = KIND_BARRACK_ATTACK,
	barrack_buy_soldier = KIND_BARRACK_UNIT,
	barrack_rally = KIND_BARRACK_RALLY,
	cheat_gold = KIND_CHEAT_GOLD,
	cheat_lives = KIND_CHEAT_LIVES,
	force_next_wave = KIND_FORCE_WAVE,
	next_wave = KIND_NEXT_WAVE,
	power_fire = KIND_POWER_FIRE,
	random_towers = KIND_RANDOM_TOWERS,
	reinforce_rally = KIND_REINFORCE_RALLY,
	summon_hero = KIND_SUMMON_HERO,
	tower_change_mode = KIND_TOWER_MODE,
	tower_power_upgrade = KIND_POWER_UPGRADE,
	tower_sell = KIND_TOWER_SELL,
	tower_swap = KIND_TOWER_SWAP,
	tower_upgrade = KIND_TOWER_UPGRADE,
	tower_user_point = KIND_USER_POINT,
	unit_rally = KIND_UNIT_RALLY,
	units_rally = KIND_UNITS_RALLY,
	world_click = KIND_WORLD_CLICK
}

return RK
