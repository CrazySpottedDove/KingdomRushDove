-- 防御塔升级 / 出售 / 摧毁的对外接口。
-- 原实现由 all/systems/tower.lua 的 on_update 每帧轮询 tower.sell / tower.destroy / tower.upgrade_to 标志，
-- 现改为在事件发生处直接调用本模块，系统不再需要每帧检测。
local tower_utils = {}

local E = require("entity_db")
local km = require("lib.klua.macros")
local V = require("lib.klua.vector")
local S = require("sound_db")
local U = require("utils")
local signal = require("lib.hump.signal")

--- 恢复被防御塔占用的塔位（卖出 / 摧毁共用）
---@param store table game.store
---@param e table 塔实体
---@return table 塔位实体
local function restore_tower_holder(store, e)
	if e._applied_mods then
		for _, mod in pairs(e._applied_mods) do
			simulation:queue_remove_entity(mod)
		end
	end

	local th = E:create_entity(e.tower.terrain_style)

	th.pos = V.vclone(e.pos)
	th.tower.holder_id = e.tower.holder_id
	th.tower.flip_x = e.tower.flip_x

	U.set_terrain_style(th, e.tower.terrain_style)

	if e.tower.default_rally_pos then
		th.tower.default_rally_pos = e.tower.default_rally_pos
	end

	if th.ui and e.ui then
		th.ui.nav_mesh_id = e.ui.nav_mesh_id
	end

	simulation:queue_insert_entity(th)
	simulation:queue_remove_entity(e)
	signal.emit("tower-removed", e, th)

	return th
end

--- 卖出防御塔：返还金币，生成卖出特效与音效，并恢复塔位
---@param store table game.store
---@param e table 塔实体
function tower_utils.sell_tower(store, e)
	local refund = store.wave_group_number == 0 and e.tower.spent or km.round(e.tower.refund_factor * e.tower.spent)

	store.player_gold = store.player_gold + refund

	local th = restore_tower_holder(store, e)

	local dust = E:create_entity("fx_tower_sell_dust")

	dust.pos.x, dust.pos.y = th.pos.x, th.pos.y + 35
	dust.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(dust)

	if e.sound_events and e.sound_events.sell then
		S:queue(e.sound_events.sell, e.sound_events.sell_args)
	end
end

--- 摧毁防御塔：不返还金币，仅恢复塔位
---@param store table game.store
---@param e table 塔实体
function tower_utils.destroy_tower(store, e)
	restore_tower_holder(store, e)
end

--- 升级 / 解封防御塔为 upgrade_to 指定的模板
---@param store table game.store
---@param e table 塔实体
---@param upgrade_to string 目标模板名
function tower_utils.upgrade_tower(store, e, upgrade_to)
	if e._applied_mods then
		for _, mod in pairs(e._applied_mods) do
			simulation:queue_remove_entity(mod)
		end
	end

	local ne = E:create_entity(upgrade_to)

	ne.pos = V.vclone(e.pos)
	ne.tower.holder_id = e.tower.holder_id
	ne.tower.flip_x = e.tower.flip_x

	if e.tower.default_rally_pos then
		ne.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
	end

	if e.tower.terrain_style then
		U.set_terrain_style(ne, e.tower.terrain_style)
	end

	if ne.ui and e.ui then
		ne.ui.nav_mesh_id = e.ui.nav_mesh_id
	end

	simulation:queue_insert_entity(ne)
	simulation:queue_remove_entity(e)
	signal.emit("tower-upgraded", ne, e)

	local price = ne.tower.price

	if ne.tower.type == "build_animation" then
		local bt = E:get_template(ne.build_name)

		price = bt.tower.price
	elseif e.tower.type == "build_animation" then
		price = 0
	elseif e.tower_holder and e.tower_holder.unblock_price > 0 then
		price = e.tower_holder.unblock_price
	end

	if e.tower.upgrade_price_multiplier then
		price = math.ceil(price * e.tower.upgrade_price_multiplier)
		price = math.floor(price / 10) * 10
	end

	store.player_gold = store.player_gold - price

	if not e.tower_holder or not e.tower_holder.blocked then
		ne.tower.spent = e.tower.spent + price
	end

	if e.tower and e.tower.type == "engineer" and ne.tower.type == "engineer" then
		if ne.ranged_attack then
			ne.ranged_attack.ts = e.ranged_attack.ts
		elseif ne.area_attack then
			ne.area_attack.ts = e.ranged_attack.ts
		end
	elseif e.barrack and ne.barrack and not ne.barrack.banned then
		ne.barrack.rally_pos = V.vclone(e.barrack.rally_pos)
		store._dominant_entity = ne
		for i, s in ipairs(e.barrack.soldiers) do
			if s.health.dead then
			-- block empty
			else
				if i > ne.barrack.max_soldiers then
					U.unblock_target(store, s)
				else
					local soldier_type = ne.barrack.soldier_type

					if ne.barrack.soldier_types then
						soldier_type = ne.barrack.soldier_types[i]
					end

					local ns = E:create_entity(soldier_type)

					ns.soldier.tower_id = ne.id
					ns.pos = V.vclone(s.pos)
					ns.motion.dest = V.vclone(s.motion.dest)
					ns.motion.arrived = s.motion.arrived
					ns.render.sprites[1].flip_x = s.render.sprites[1].flip_x
					ns.render.sprites[1].flip_y = s.render.sprites[1].flip_y
					ns.render.sprites[1].name = s.render.sprites[1].name
					ns.render.sprites[1].loop = s.render.sprites[1].loop
					ns.render.sprites[1].ts = s.render.sprites[1].ts
					ns.render.sprites[1].runs = s.render.sprites[1].runs

					if ne.mercenary then
						ns.nav_rally.pos = V.vclone(s.nav_rally.pos)
						ns.nav_rally.center = V.vclone(s.nav_rally.center)
						ns.nav_rally.new = s.nav_rally.new
					else
						ns.nav_rally.pos, ns.nav_rally.center = U.rally_formation_position(i, ne.barrack, ne.barrack.max_soldiers)
						ns.nav_rally.new = true
					end

					if ns.melee and s.melee then
						for i, a in ipairs(ns.melee.attacks) do
							if s.melee.attacks[i] then
								a.ts = s.melee.attacks[i].ts
							end
						end

						U.replace_blocker(store, s, ns)
					end

					require("script_utils").soldier_inherit_tower_buff_factor(ns, ne, store.tick_ts)

					ns.soldier.tower_soldier_idx = i
					ne.barrack.soldiers[i] = ns

					simulation:queue_insert_entity(ns)
				end

				s.health.dead = true

				simulation:queue_remove_entity(s)
			end
		end
		store._dominant_entity = nil
	elseif ne.barrack then
		ne.barrack.rally_pos = V.vclone(ne.tower.default_rally_pos)
	end

	if ne.tower.type ~= "build_animation" and not ne.tower.hide_dust then
		local dust = E:create_entity("fx_tower_buy_dust")

		dust.pos.x, dust.pos.y = ne.pos.x, ne.pos.y + 10
		dust.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(dust)
	end

	if e.tower_upgrade_persistent_data and ne.tower_upgrade_persistent_data then
		for k, v in pairs(e.tower_upgrade_persistent_data) do
			if not ne.tower_upgrade_persistent_data[k] then
				ne.tower_upgrade_persistent_data[k] = v
			end
		end

		for _, f in pairs(ne.tower_upgrade_persistent_data.upgrade_functions) do
			f(ne, store)
		end
	end
end

return tower_utils
