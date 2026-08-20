local M = {}
function M.register(sys)
	sys.tower = {}
	sys.tower.name = "tower"

	local E = require("entity_db")
	local signal = require("lib.hump.signal")
	local km = require("lib.klua.macros")
	local V = require("lib.klua.vector")
	local S = require("sound_db")
	local U = require("utils")
	local UP = require("kr1.upgrades")

	function sys.tower:init(store)
		store.towers = {}
		require("lib.klua.table")
		self.mage_tower_map = table.to_map(UP.mage_towers)
	end

	function sys.tower:on_insert_unconditional(entity, store)
		if entity.tower then
			-- tower index
			store.towers[entity.id] = entity

			-- mage_brilliance
			local mage_bullet_names = UP.mage_tower_bolts
			local mage_tower_map = self.mage_tower_map
			local u = UP:get_upgrade("mage_brilliance")

			if u and mage_tower_map[entity.template_name] then
				local existing_towers = table.filter(store.towers, function(_, e)
					return mage_tower_map[e.template_name]
				end)
				local dps = E:get_template("mod_ray_arcane").dps
				local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
				local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
				local dps_infernal_mage = E:get_template("mod_lava_infernal_mage").dps
				local dps_wicked_sister = E:get_template("mod_wicked_sister_poison").dps

				local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

				for _, bn in ipairs(mage_bullet_names) do
					local b = E:get_template(bn).bullet

					if not b._orig_damage_min then
						b._orig_damage_min = b.damage_min
						b._orig_damage_max = b.damage_max
					end

					b.damage_min = b._orig_damage_min * f
					b.damage_max = b._orig_damage_max * f
				end

				if not dps._orig_damage_min then
					dps._orig_damage_min = dps.damage_min
					dps._orig_damage_max = dps.damage_max
				end

				dps.damage_min = dps._orig_damage_min * f
				dps.damage_max = dps._orig_damage_max * f

				if not bullet_ray_high_elven._orig_damage_min then
					bullet_ray_high_elven._orig_damage_min = bullet_ray_high_elven.damage_min
					bullet_ray_high_elven._orig_damage_max = bullet_ray_high_elven.damage_max
				end

				bullet_ray_high_elven.damage_min = bullet_ray_high_elven._orig_damage_min * f
				bullet_ray_high_elven.damage_max = bullet_ray_high_elven._orig_damage_max * f

				if not modifier_pixie._orig_damage_min then
					modifier_pixie._orig_damage_min = modifier_pixie.damage_min
					modifier_pixie._orig_damage_max = modifier_pixie.damage_max
				end

				modifier_pixie.damage_min = modifier_pixie._orig_damage_min * f
				modifier_pixie.damage_max = modifier_pixie._orig_damage_max * f

				local arcane5_disintegrate = E:get_template("tower_arcane_wizard_ray_disintegrate_mod")

				if not arcane5_disintegrate._origin_damage_config then
					arcane5_disintegrate._origin_damage_config = {}
					arcane5_disintegrate._origin_damage_config[1] = arcane5_disintegrate.boss_damage_config[1]
					arcane5_disintegrate._origin_damage_config[2] = arcane5_disintegrate.boss_damage_config[2]
					arcane5_disintegrate._origin_damage_config[3] = arcane5_disintegrate.boss_damage_config[3]
				end

				for i = 1, 3 do
					arcane5_disintegrate.boss_damage_config[i] = arcane5_disintegrate._origin_damage_config[i] * f
				end

				if not dps_infernal_mage._orig_damage_min then
					dps_infernal_mage._orig_damage_min = dps_infernal_mage.damage_min
					dps_infernal_mage._orig_damage_max = dps_infernal_mage.damage_max
				end

				dps_infernal_mage.damage_min = dps_infernal_mage._orig_damage_min * f
				dps_infernal_mage.damage_max = dps_infernal_mage._orig_damage_max * f

				if not dps_wicked_sister._orig_damage_min then
					dps_wicked_sister._orig_damage_min = dps_wicked_sister.damage_min
					dps_wicked_sister._orig_damage_max = dps_wicked_sister.damage_max
				end

				dps_wicked_sister.damage_min = dps_wicked_sister._orig_damage_min * f
				dps_wicked_sister.damage_max = dps_wicked_sister._orig_damage_max * f
			end
		end
	end

	function sys.tower:on_remove_unconditional(entity, store)
		if entity.tower then
			local mage_bullet_names = UP.mage_tower_bolts
			local mage_tower_map = self.mage_tower_map
			local u = UP:get_upgrade("mage_brilliance")

			if entity.tower and u and mage_tower_map[entity.template_name] then
				local existing_towers = table.filter(store.towers, function(_, e)
					return mage_tower_map[e.template_name]
				end)
				local dps = E:get_template("mod_ray_arcane").dps
				local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
				local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
				local dps_infernal_mage = E:get_template("mod_lava_infernal_mage").dps
				local dps_wicked_sister = E:get_template("mod_wicked_sister_poison").dps
				local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

				for _, bn in ipairs(mage_bullet_names) do
					local b = E:get_template(bn).bullet

					b.damage_min = b._orig_damage_min * f
					b.damage_max = b._orig_damage_max * f
				end

				dps.damage_min = dps._orig_damage_min * f
				dps.damage_max = dps._orig_damage_max * f
				bullet_ray_high_elven.damage_min = bullet_ray_high_elven._orig_damage_min * f
				bullet_ray_high_elven.damage_max = bullet_ray_high_elven._orig_damage_max * f
				modifier_pixie.damage_min = modifier_pixie._orig_damage_min * f
				modifier_pixie.damage_max = modifier_pixie._orig_damage_max * f

				local arcane5_disintegrate = E:get_template("tower_arcane_wizard_ray_disintegrate_mod")

				for i = 1, 3 do
					arcane5_disintegrate.boss_damage_config[i] = arcane5_disintegrate._origin_damage_config[i] * f
				end

				dps_infernal_mage.damage_min = dps_infernal_mage._orig_damage_min * f
				dps_infernal_mage.damage_max = dps_infernal_mage._orig_damage_max * f
				dps_wicked_sister.damage_min = dps_wicked_sister._orig_damage_min * f
				dps_wicked_sister.damage_max = dps_wicked_sister._orig_damage_max * f
			end

			-- tower index
			store.towers[entity.id] = nil
		end
	end

	function sys.tower:on_update(dt, ts, store)
		-- tower upgrade/sell
		for _, e in pairs(store.towers) do
			if e.tower.sell or e.tower.destroy then
				if e.tower.sell then
					local refund = store.wave_group_number == 0 and e.tower.spent or km.round(e.tower.refund_factor * e.tower.spent)

					store.player_gold = store.player_gold + refund
				end

				if e.tower.sell then
					if e._applied_mods then
						for _, mod in pairs(e._applied_mods) do
							simulation:queue_remove_entity(mod)
						end
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

				-- if e.tower.terrain_style then
				-- 	th.tower.terrain_style = e.tower.terrain_style
				-- 	th.render.sprites[1].name = string.format(th.render.sprites[1].name, e.tower.terrain_style)
				-- end

				if th.ui and e.ui then
					th.ui.nav_mesh_id = e.ui.nav_mesh_id
				end

				simulation:queue_insert_entity(th)
				simulation:queue_remove_entity(e)
				signal.emit("tower-removed", e, th)

				if e.tower.sell then
					local dust = E:create_entity("fx_tower_sell_dust")

					dust.pos.x, dust.pos.y = th.pos.x, th.pos.y + 35
					dust.render.sprites[1].ts = ts

					simulation:queue_insert_entity(dust)

					if e.sound_events and e.sound_events.sell then
						S:queue(e.sound_events.sell, e.sound_events.sell_args)
					end
				end
			elseif e.tower.upgrade_to then
				if e._applied_mods then
					for _, mod in pairs(e._applied_mods) do
						simulation:queue_remove_entity(mod)
					end
				end

				local ne = E:create_entity(e.tower.upgrade_to)

				ne.pos = V.vclone(e.pos)
				ne.tower.holder_id = e.tower.holder_id
				ne.tower.flip_x = e.tower.flip_x

				if e.tower.default_rally_pos then
					ne.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
				end

				-- if e.tower.terrain_style then
				-- 	ne.tower.terrain_style = e.tower.terrain_style
				-- 	ne.render.sprites[1].name = string.format(ne.render.sprites[1].name, e.tower.terrain_style)
				-- end
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

								ns.info.i18n_key = s.info.i18n_key
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

								ns.soldier.tower_soldier_idx = i
								ne.barrack.soldiers[i] = ns

								simulation:queue_insert_entity(ns)
							end

							s.health.dead = true

							simulation:queue_remove_entity(s)
						end
					end
				elseif ne.barrack then
					ne.barrack.rally_pos = V.vclone(ne.tower.default_rally_pos)
				end

				if ne.tower.type ~= "build_animation" and not ne.tower.hide_dust then
					local dust = E:create_entity("fx_tower_buy_dust")

					dust.pos.x, dust.pos.y = ne.pos.x, ne.pos.y + 10
					dust.render.sprites[1].ts = ts

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
		end
	end
end

return M
