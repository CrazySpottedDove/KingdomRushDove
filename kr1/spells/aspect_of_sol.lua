local M = {}

M.id = "aspect_of_sol"
M.i18n = "POWER_ASPECT_OF_SOL"
M.control = "power_aspect_of_sol_control"
M.button_icon = "in_game_icon_power_aspect_of_sol"
M.pointer_icon = "pointer_power_aspect_of_sol"
M.portrait = "power_portraits_big_aspect_of_sol"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 206, 122, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.34, 0.14, 0.03, 1}
	}, {
		thickness = 2,
		glow_color = {0.95, 0.56, 0.16, 0.75}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_aspect_of_sol"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_aspect_of_sol"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"hero_gerald_inspire_courage_buff_decalDef"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	-- 惰性加载：只有本局选中该法术时才 require / 定义脚本
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bit = require("bit")
	local band = bit.band
	local bor = bit.bor
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function queue_damage(store, damage)
		store.damage_queue[#store.damage_queue + 1] = damage
	end

	-- 索罗化身士兵脚本（移植自 kr6 scripts.soldier_aspect_of_sol）
	-- 召唤冲击光环：造成一次伤害并给范围内目标上 mod（4 级为眩晕，6 级追加伤害）
	local tt

	-- 控制实体：点击地面 -> 在合法节点召唤索罗化身
	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local e = E:create_entity("soldier_aspect_of_sol")

		e.pos = v(this.pos.x, this.pos.y)
		e.nav_rally.center = v(this.pos.x, this.pos.y)
		e.nav_rally.pos = V.vclone(e.pos)
		e.id_enemy = this.id_enemy

		simulation:queue_insert_entity(e)

		return true
	end
	tt.main_script.update = function(this, store)
		coroutine.yield()
		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = function(this, x, y, store)
		this.id_enemy = nil

		local valid_pos = GR:cell_is(x, y, bor(TERRAIN_LAND, TERRAIN_ICE)) and not GR:cell_is(x, y, bor(TERRAIN_NOWALK)) and P:valid_node_nearby(x, y, nil, NF_RALLY)

		if not valid_pos then
			return false
		end

		local enemies = U.find_enemies_in_range(store, v(x, y), 0, this.summon_target_radius, 0, this.vis_bans)

		if not enemies then
			return true
		end

		local max_hp_enemy = 0

		for _, enemy in ipairs(enemies) do
			if max_hp_enemy < enemy.health.hp then
				max_hp_enemy = enemy.health.hp
				this.id_enemy = enemy.id
			end
		end

		return true
	end
	tt.cooldown = 60
	tt.summon_target_radius = 50
	tt.vis_bans = bor(F_BLOCK, F_FLYING)

	E:set_template("user_power_3", tt)

	-- 索罗化身本体
	tt = E:register_t_tmp("soldier_aspect_of_sol", "soldier_militia")

	E:add_comps(tt, "reinforcement", "timed_attacks", "nav_grid")

	tt.controable = true
	tt.health.hp_max = 750
	tt.health.armor = 0.5
	tt.health.magic_armor = 0
	tt.health_bar.offset = v(0, 60)
	tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.portrait = "kr6_info_portraits_soldiers_0045"
	tt.info.i18n_key = "POWER_ASPECT_OF_SOL"
	tt.main_script.insert = function(this, store)
		this.original_attack_min = this.melee.attacks[1].damage_min
		this.original_attack_max = this.melee.attacks[1].damage_max
		this.original_special_attack_min = this.melee.attacks[2].damage_min
		this.original_special_attack_max = this.melee.attacks[2].damage_max
		this.ts = store.tick_ts

		if this.spawn_with_beam then
			S:queue(this.sound_entrance_lvl3)
		else
			S:queue(this.sound_entrance_lvl1)
		end

		this.melee.order = U.attack_order(this.melee.attacks)

		return true
	end
	tt.main_script.update = function(this, store)
		this.reinforcement.ts = store.tick_ts

		local enemy = this.id_enemy and store.entities[this.id_enemy] or nil
		local number_of_attacks = 0
		local a1 = this.melee.attacks[1]
		local a2 = this.melee.attacks[2]
		local sa = this.timed_attacks.list[1]

		a1.ts = store.tick_ts - a1.cooldown
		sa.ts = store.tick_ts - sa.cooldown

		local brk, stam

		local function y_warcry()
			if sa.disabled then
				return
			end

			local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, sa.min_range, sa.max_range, sa.vis_flags, sa.vis_bans)

			if soldiers and #soldiers > 0 then
				for _, v in pairs(soldiers) do
					local mod = E:create_entity(sa.mod_dmg_inc)

					mod.modifier.source_id = this.id
					mod.modifier.target_id = v.id

					simulation:queue_insert_entity(mod)

					mod = E:create_entity(sa.mod_armor_inc)
					mod.modifier.source_id = this.id
					mod.modifier.target_id = v.id

					simulation:queue_insert_entity(mod)
				end
			end

			if sa.mod_slow then
				local enemies = U.find_enemies_in_range(store, this.pos, sa.min_range, sa.max_range, sa.vis_flags, sa.vis_bans)

				if enemies and #enemies > 0 then
					for _, v in pairs(enemies) do
						local mod = E:create_entity(sa.mod_slow)

						mod.modifier.source_id = this.id
						mod.modifier.target_id = v.id

						simulation:queue_insert_entity(mod)
					end
				end
			end

			S:queue(sa.sound)
			U.y_animation_play(this, sa.animation, nil, store.tick_ts, 1, 1)
		end

		if this.spawn_with_beam then
			local beam = E:create_entity(this.decal_beam)

			beam.pos = V.vclone(this.pos)
			beam.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(beam)
			S:queue(this.sound_entrance_lvl3)
			U.y_wait(store, this.beam_delay)
		end

		U.animation_start(this, "summon", nil, store.tick_ts, false, 1)

		this.render.sprites[1].hidden = false
		this.render.sprites[1].z = Z_OBJECTS

		U.y_wait(store, this.crack_delay)

		local crack = E:create_entity(this.decal_crack)

		crack.pos = V.vclone(this.pos)
		crack.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(crack)

		local smoke = E:create_entity(this.decal_smoke)

		smoke.pos = V.vclone(this.pos)
		smoke.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(smoke)

		if enemy then
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = enemy.id
			d.damage_type = this.on_select_enemy.damage_type

			if band(enemy.vis.flags, F_BOSS) ~= 0 then
				d.value = this.on_select_enemy.max_boss_damage
			elseif band(enemy.vis.flags, F_MINIBOSS) ~= 0 then
				d.value = this.on_select_enemy.max_miniboss_damage
			else
				d.value = this.on_select_enemy.damage
			end

			queue_damage(store, d)
		end

		if this.spawn_aura then
			local aura = E:create_entity(this.spawn_aura)

			aura.boss_damage_cap = this.on_summon.boss_damage_cap
			aura.miniboss_damage_cap = this.on_summon.miniboss_damage_cap
			aura.pos = V.vclone(this.pos)

			simulation:queue_insert_entity(aura)
		end

		while not U.animation_finished(this, 1) do
			coroutine.yield()
		end

		U.animation_start(this, "idle", nil, store.tick_ts, false, 1)

		while true do
			if this.health.dead or this.reinforcement.duration and store.tick_ts - this.ts > this.reinforcement.duration then
				U.unblock_target(store, this)

				this.ui.can_click = false

				if game.game_gui and game.game_gui.selected_entity and game.game_gui.selected_entity.id == this.id then
					signal.emit("hide-bottom-info")
				end

				local beam = E:create_entity(this.decal_beam)

				beam.pos = V.vclone(this.pos)
				beam.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(beam)

				local smoke = E:create_entity(this.decal_crack)

				smoke.pos = V.vclone(this.pos)
				smoke.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(smoke)

				smoke = E:create_entity(this.decal_smoke)
				smoke.pos = V.vclone(this.pos)
				smoke.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(smoke)
				S:queue(this.sound_out)
				U.y_animation_play(this, "leave", nil, store.tick_ts, 1, 1)
				SU.remove_modifiers(store, this)
				simulation:queue_remove_entity(this)

				return
			end

			if this.unit.is_stunned then
				SU.soldier_idle(store, this)
			else
				if enemy and enemy.health.dead then
					y_warcry()

					enemy = nil
				end

				if not this.l5b_disabled and store.tick_ts - sa.ts > sa.cooldown then
					y_warcry()

					sa.ts = store.tick_ts
				end

				while this.nav_rally.new do
					if SU.y_hero_new_rally(store, this) then
						break
					end
				end

				local target = store.entities[this.soldier.target_id]

				if target then
					if band(target.vis.flags, F_BOSS) ~= 0 then
						this.melee.attacks[1].damage_min = this.original_attack_min * this.melee.attacks[1].boss_damage_cap
						this.melee.attacks[1].damage_max = this.original_attack_max * this.melee.attacks[1].boss_damage_cap
						this.melee.attacks[2].damage_min = this.original_special_attack_min * this.melee.attacks[2].boss_damage_cap
						this.melee.attacks[2].damage_max = this.original_special_attack_max * this.melee.attacks[2].boss_damage_cap
					elseif band(target.vis.flags, F_MINIBOSS) ~= 0 then
						this.melee.attacks[1].damage_min = this.original_attack_min * this.melee.attacks[1].miniboss_damage_cap
						this.melee.attacks[1].damage_max = this.original_attack_max * this.melee.attacks[1].miniboss_damage_cap
						this.melee.attacks[2].damage_min = this.original_special_attack_min * this.melee.attacks[2].miniboss_damage_cap
						this.melee.attacks[2].damage_max = this.original_special_attack_max * this.melee.attacks[2].miniboss_damage_cap
					else
						this.melee.attacks[1].damage_min = this.original_attack_min
						this.melee.attacks[1].damage_max = this.original_attack_max
						this.melee.attacks[2].damage_min = this.original_special_attack_min
						this.melee.attacks[2].damage_max = this.original_special_attack_max
					end
				end

				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk then
				-- block empty
				else
					if stam == A_DONE then
						number_of_attacks = number_of_attacks + 1

						if a2.has_upgrade and number_of_attacks % 3 == 0 then
							a2.disabled = false
							a1.disabled = true
						else
							a2.disabled = true
							a1.disabled = false
						end
					end

					if brk or stam ~= A_NO_TARGET then
					-- block empty
					elseif SU.soldier_go_back_step(store, this) then
					-- block empty
					else
						SU.soldier_idle(store, this)
					end
				end
			end

			coroutine.yield()
		end
	end
	tt.melee.attacks[1] = E:clone_c("melee_attack")
	tt.melee.attacks[1].cooldown = 1.5
	tt.melee.attacks[1].damage_min = 42
	tt.melee.attacks[1].damage_max = 64
	tt.melee.attacks[1].damage_type = DAMAGE_TRUE
	tt.melee.attacks[1].boss_damage_cap = 0.5
	tt.melee.attacks[1].miniboss_damage_cap = 1
	tt.melee.attacks[1].animation = "attack_1"
	tt.melee.attacks[1].hit_time = fts(23)
	tt.melee.attacks[1].hit_fx = "fx_soldier_aspect_of_sol_basic_hit"
	tt.melee.attacks[1].sound_hit = "PowersAspectOfSolBasicAttackCast"
	tt.melee.attacks[1].hit_offset = v(50, -20)
	tt.melee.attacks[1].disabled = false
	tt.melee.attacks[2] = E:clone_c("melee_attack")
	tt.melee.attacks[2].damage_min = 98
	tt.melee.attacks[2].damage_max = 146
	tt.melee.attacks[2].damage_type = DAMAGE_TRUE
	tt.melee.attacks[2].boss_damage_cap = 0.5
	tt.melee.attacks[2].miniboss_damage_cap = 1
	tt.melee.attacks[2].animation = "attack_dmg"
	tt.melee.attacks[2].hit_time = fts(24)
	tt.melee.attacks[2].hit_fx = "fx_soldier_aspect_of_sol_special_hit"
	tt.melee.attacks[2].hit_offset = v(45, 10)
	tt.melee.attacks[2].disabled = true
	tt.melee.attacks[2].has_upgrade = false
	tt.melee.attacks[2].cooldown = 0
	tt.melee.attacks[2].sound = "PowersAspectOfSolChargedAttack"
	tt.timed_attacks.list[1] = E:clone_c("custom_attack")
	tt.timed_attacks.list[1].animation = "warcry"
	tt.timed_attacks.list[1].disabled = true
	tt.timed_attacks.list[1].cooldown = 30
	tt.timed_attacks.list[1].sound = "PowersAspectOfSolWarcryCast"
	tt.timed_attacks.list[1].min_range = 0
	tt.timed_attacks.list[1].max_range = 100
	tt.timed_attacks.list[1].vis_bans = 0
	tt.timed_attacks.list[1].vis_flags = 0
	tt.timed_attacks.list[1].mod_dmg_inc = "mod_power_aspect_of_sol_warcry_dmg_inc"
	tt.timed_attacks.list[1].mod_armor_inc = "mod_power_aspect_of_sol_warcry_armor_inc"
	tt.melee.range = 72
	tt.motion.max_speed = 40
	tt.reinforcement.duration = 18
	tt.render.sprites[1].prefix = "aspectofsol_lvl_1"
	tt.render.sprites[1].name = "summon"
	tt.render.sprites[1].scale = vv(0.9)
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.render.sprites[1].hidden = true
	tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
	tt.soldier.melee_slot_offset = v(25, 0)
	tt.sound_entrance_lvl1 = "PowersAspectOfSolEntrance"
	tt.sound_entrance_lvl3 = "PowersAspectOfSolEpicEntranceCast"
	tt.sound_out = "PowersAspectOfSolEpicEntranceOut"
	tt.unit.hit_offset = v(0, 5)
	tt.unit.mod_offset = v(0, 14)
	tt.unit.level = 0
	tt.unit.size = UNIT_SIZE_MEDIUM
	tt.vis.bans = bor(F_LYCAN, F_EAT, F_NET, F_POISON, F_DISINTEGRATED)
	tt.vis.flags = bor(F_BLOCK, F_FRIEND)
	tt.decal_beam = "decal_power_aspect_of_sol_beam"
	tt.decal_smoke = "decal_power_aspect_of_sol_smoke"
	tt.decal_crack = "decal_power_aspect_of_sol_crack"
	tt.spawn_with_beam = false
	tt.beam_delay = fts(6)
	tt.crack_delay = fts(4)
	tt.l5b_disabled = true
	tt.spawn_aura = nil
	tt.on_summon = {
		stun_duration = 2,
		radius = 100,
		damage_type = DAMAGE_TRUE,
		boss_damage_cap = 0.5,
		miniboss_damage_cap = 0.5
	}
	tt.on_select_enemy = {
		damage = 300,
		damage_type = DAMAGE_TRUE,
		max_boss_damage = 300,
		max_miniboss_damage = 300
	}
	tt.sound_events.insert = "PowersAspectOfSolSummonTaunt"
	tt.sound_events.change_rally_point = "PowersAspectOfSolMoveTaunt"
	tt.ui.click_rect = r(-25, -2, 50, 50)
	tt = E:register_t_tmp("decal_power_aspect_of_sol_beam", "decal_timed")
	tt.render.sprites[1].prefix = "aspectofsol_beam"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt = E:register_t_tmp("decal_power_aspect_of_sol_smoke", "decal_timed")
	tt.render.sprites[1].prefix = "aspectofsol_humo_land"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
	tt.render.sprites[1].offset = v(5, -5)
	tt = E:register_t_tmp("decal_power_aspect_of_sol_crack", "decal_timed")
	tt.render.sprites[1].prefix = "aspectofsol_decal"
	tt.render.sprites[1].name = "crack"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS
	tt = E:register_t_tmp("fx_soldier_aspect_of_sol_basic_hit", "fx")
	tt.render.sprites[1].prefix = "aspectofsol_hit"
	tt.render.sprites[1].name = "run"
	tt = E:register_t_tmp("fx_soldier_aspect_of_sol_special_hit", "fx")
	tt.render.sprites[1].prefix = "aspectofsol_hit_fuerte"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].scale = v(2, 2)

	tt = E:register_t_tmp("mod_power_aspect_of_sol_warcry_dmg_inc", "modifier")
	E:add_comps(tt, "render")
	tt.modifier.duration = 5
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.use_mod_offset = false
	tt.inflicted_damage_factor = 1.3
	tt.main_script.insert = scripts.mod_damage_factors.insert
	tt.main_script.remove = scripts.mod_damage_factors.remove
	tt.main_script.update = scripts.mod_track_target.update
	tt.render.sprites[1].prefix = "hero_gerald_inspire_courage_buff_decalDef"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t_tmp("mod_power_aspect_of_sol_warcry_armor_inc", "modifier")
	E:add_comps(tt, "armor_buff")
	tt.modifier.duration = 5
	tt.modifier.vis_flags = bor(F_MOD)
	tt.modifier.vis_bans = 0
	tt.armor_buff.both = true
	tt.armor_buff.max_factor = 0.3
	tt.main_script.insert = scripts.mod_armor_buff.insert
	tt.main_script.update = scripts.mod_armor_buff.update
	tt.main_script.remove = scripts.mod_armor_buff.remove
	tt = E:register_t_tmp("mod_power_aspect_of_sol_warcry_slow", "mod_slow")
	tt.slow.factor = 0.5
	tt.modifier.duration = 6
	tt.modifier.vis_flags = bor(F_MOD)
	tt = E:register_t_tmp("mod_power_aspect_of_sol_stun", "mod_stun")
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.duration = 2
	tt.modifier.use_mod_offset = false
	tt.modifier.animation_phases = false
	tt = E:register_t_tmp("aura_power_aspect_of_sol_summon", "aura")
	tt.aura.radius = 100
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
	tt.aura.cycles = 1
	tt.aura.cycle_time = 0
	tt.aura.duration = 1e99
	tt.aura.damage_min = 0
	tt.aura.damage_max = 0
	tt.aura.damage_type = DAMAGE_TRUE
	tt.main_script.update = function(this, store)
		local targets = table.filter(store.enemies, function(_, v)
			return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name))
		end)

		for _, target in pairs(targets) do
			if (this.aura.damage_min or 0) > 0 then
				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = target.id

				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				if band(target.vis.flags, F_BOSS) ~= 0 then
					dmin = dmin * this.boss_damage_cap
					dmax = dmax * this.boss_damage_cap
				elseif band(target.vis.flags, F_MINIBOSS) ~= 0 then
					dmin = dmin * this.miniboss_damage_cap
					dmax = dmax * this.miniboss_damage_cap
				end

				d.value = math.random(dmin, dmax)
				d.damage_type = this.aura.damage_type
				d.track_damage = this.aura.track_damage

				queue_damage(store, d)
			end

			if this.aura.mod then
				local m = E:create_entity(this.aura.mod)

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				simulation:queue_insert_entity(m)
			end
		end

		simulation:queue_remove_entity(this)
	end
end

-- 法术的科技生效接口：1..6 级线性映射自 KR6 的升级卡
function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local soldier = E:get_template("soldier_aspect_of_sol")
	local warcry_dmg = E:get_template("mod_power_aspect_of_sol_warcry_dmg_inc")
	local summon_aura = E:get_template("aura_power_aspect_of_sol_summon")

	-- l2：持续时间 +34%，伤害 +30%
	if level >= 2 then
		soldier.reinforcement.duration = 18 * 1.34
		soldier.melee.attacks[1].damage_min = 42 * 1.3
		soldier.melee.attacks[1].damage_max = 64 * 1.3
		soldier.melee.attacks[2].damage_min = 98 * 1.3
		soldier.melee.attacks[2].damage_max = 146 * 1.3
	end

	-- l3：解锁战吼；换 2 阶形象
	if level >= 3 then
		soldier.timed_attacks.list[1].disabled = false
		soldier.render.sprites[1].prefix = "aspectofsol_lvl_2"
		soldier.info.portrait = "kr6_info_portraits_soldiers_0046"
	end

	-- l4：战吼持续翻倍；召唤时眩晕周围敌人
	if level >= 4 then
		warcry_dmg.modifier.duration = 5 * 2
		soldier.spawn_aura = "aura_power_aspect_of_sol_summon"
		summon_aura.aura.mod = "mod_power_aspect_of_sol_stun"
	end

	-- l5：每三次攻击触发裁决猛击；战吼附带减速
	if level >= 5 then
		soldier.melee.attacks[2].has_upgrade = true
		soldier.timed_attacks.list[1].mod_slow = "mod_power_aspect_of_sol_warcry_slow"
		soldier.l5b_disabled = false
	end

	-- l6：光柱降临；召唤伤害；3 阶形象
	if level >= 6 then
		soldier.spawn_with_beam = true
		soldier.render.sprites[1].prefix = "aspectofsol_lvl_3"
		soldier.info.portrait = "kr6_info_portraits_soldiers_0047"
		summon_aura.aura.vis_bans = F_FRIEND
		summon_aura.aura.damage_min = 120
		summon_aura.aura.damage_max = 200
	else
		summon_aura.aura.damage_max = 0
		summon_aura.aura.damage_min = 0
	end

	ctrl.cooldown = 60
end

return M
