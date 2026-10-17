local M = {}

M.id = "thunder_zapper"
M.i18n = "POWER_THUNDER_ZAPPER"
M.control = "power_thunder_zapper_control"
M.button_icon = "in_game_icon_power_thunder_zapper"
M.pointer_icon = "pointer_power_thunder_zapper"
M.portrait = "power_portraits_big_thunder_zapper"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 255, 255, 255},
	shaders = {"p_outline", "p_glow"},
	shader_margin = 16
}
M.required_textures = {"go_power_thunder_zapper"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_thunder_zapper"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"teslaguy_lvl1Def", "teslaguy_lvl2Def", "teslaguy_lvl3Def", "animations_areadmgDef", "animations_skyrayDef", "animations_modifierDef", "animations_decalDef"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bit = require("bit")
	local bor = bit.bor
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local GR = require("grid_db")
	local P = require("path_db")
	local UP = require("kr1.upgrades")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function queue_damage(store, damage)
		store.damage_queue[#store.damage_queue + 1] = damage
	end

	local function find_most_populated_path(enemies)
		if not enemies or #enemies == 0 then
			return nil
		end

		local paths_count = {}
		local found_paths = {}

		for _, enemy in pairs(enemies) do
			if not table.contains(found_paths, enemy.nav_path.pi) then
				table.insert(found_paths, enemy.nav_path.pi)
				table.insert(paths_count, {enemy.nav_path.pi, 1})
			else
				for _, entry in ipairs(paths_count) do
					if entry[1] == enemy.nav_path.pi then
						entry[2] = entry[2] + 1
						break
					end
				end
			end
		end

		table.sort(paths_count, function(a, b)
			return a[2] > b[2]
		end)

		return paths_count
	end

	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	E:add_comps(tt, "sound_events")
	tt.main_script.insert = function(this, store)
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)[1]
		local pi, _, ni = unpack(nearest)

		this.pos.x, this.pos.y = P:node_pos(pi, 1, ni).x, P:node_pos(pi, 1, ni).y

		local soldier = E:create_entity(this.tz_template)

		soldier.pos.x, soldier.pos.y = this.pos.x, this.pos.y
		soldier.nav_rally.center.x, soldier.nav_rally.center.y = this.pos.x, this.pos.y
		soldier.nav_rally.pos.x, soldier.nav_rally.pos.y = this.pos.x, this.pos.y

		simulation:queue_insert_entity(soldier)

		local ray = E:create_entity(this.ray_decal)

		ray.pos.x, ray.pos.y = this.pos.x, this.pos.y
		ray.render.sprites[1].ts = store.tick_ts
		ray.aura = this.summon_aura

		simulation:queue_insert_entity(ray)

		return false
	end
	tt.main_script.update = nil
	tt.user_selection.can_select_point_fn = function(this, x, y, store)
		return GR:cell_is(x, y, bor(TERRAIN_LAND, TERRAIN_ICE)) and not GR:cell_is(x, y, bor(TERRAIN_NOWALK)) and P:valid_node_nearby(x, y, nil, NF_RALLY)
	end
	tt.cooldown = 50
	tt.tz_template = "soldier_thunder_zapper"
	tt.ray_decal = "decal_power_thunder_zapper_ray"
	tt.summon_aura = "aura_power_thunder_zapper_summon"
	tt.sound_events.insert = "PowersThunderZapperBaseCast"

	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("soldier_thunder_zapper", "soldier_militia")
	E:add_comps(tt, "timed_attacks")

	tt.ui.click_rect = r(0, 0, 0, 0)
	tt.main_script.insert = scripts.soldier_reinforcement.insert
	tt.main_script.update = function(this, store)
		local ra = not this.timed_attacks.list[1].disabled and this.timed_attacks.list[1] or nil

		if ra then
			ra.ts = store.tick_ts - ra.cooldown
		end

		local la = not this.timed_attacks.list[2].disabled and this.timed_attacks.list[2] or nil

		this.ts = store.tick_ts
		this.render.sprites[1].ts = store.tick_ts

		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true
		this.aura = E:create_entity(this.damage_aura)
		this.aura.pos = this.pos

		simulation:queue_insert_entity(this.aura)

		local range_decal = E:create_entity(this.decal_damage_range)

		range_decal.pos = this.pos
		range_decal.render.sprites[1].ts = store.tick_ts
		this.decal_damage_range_entity = range_decal

		simulation:queue_insert_entity(range_decal)

		local distance = 0
		local path_ni = 1
		local path_spi = 1
		local path_pi = 1
		local available_paths = {}

		for k in pairs(P.paths) do
			table.insert(available_paths, k)
		end

		if store.level.ignore_walk_backwards_paths then
			available_paths = table.filter(available_paths, function(_, pi)
				return not table.contains(store.level.ignore_walk_backwards_paths, pi)
			end)
		end

		available_paths = table.filter(available_paths, function(_, pi)
			return P:is_path_active(pi)
		end)

		local enemies = U.find_enemies_in_range(store, this.pos, 0, this.spawn_detection_range, 0, 0)
		local enemy_paths = find_most_populated_path(enemies)

		if enemy_paths then
			for _, entry in ipairs(enemy_paths) do
				if table.contains(available_paths, entry[1]) then
					available_paths = {entry[1]}

					break
				end
			end
		end

		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

		if #nearest > 0 then
			for _, node in ipairs(nearest) do
				if GR:find_waypoints(this.pos, nil, P:node_pos(node[1], node[2], node[3]), bor(TERRAIN_LAND, TERRAIN_ICE)) ~= nil then
					path_pi, path_spi, path_ni = node[1], node[2], node[3]

					break
				end
			end
		end

		this.nav_rally.pos.x, this.nav_rally.pos.y = P:node_pos(path_pi, path_spi, path_ni - 3).x, P:node_pos(path_pi, path_spi, path_ni - 3).y

		U.y_animation_play(this, "in", this.pos.x > this.nav_rally.pos.x, store.tick_ts, 1, 1)

		while true do
			if this.duration and store.tick_ts - this.ts > this.duration or path_ni <= P:get_start_node(path_pi) then
				S:queue(this.sound_out)
				U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
				simulation:queue_remove_entity(this)

				return
			end

			local node_pos = this.nav_rally.pos
			distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

			if distance < 25 * 25 then
				path_ni = path_ni - 3
				this.nav_rally.pos.x, this.nav_rally.pos.y = P:node_pos(path_pi, path_spi, path_ni).x, P:node_pos(path_pi, path_spi, path_ni).y
			end

			if ra and store.tick_ts - ra.ts >= ra.cooldown then
				local targets = U.find_enemies_in_range(store, this.pos, 0, ra.range, 0, 0)

				if not targets or #targets == 0 or #targets < ra.min_targets then
					ra.ts = ra.ts + fts(2)
				else
					table.sort(targets, function(e1, e2)
						return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
					end)

					local flip = targets[1].pos.x < this.pos.x and 1 or -1

					this.unit.hit_offset.x = this.unit.hit_offset.x * flip

					local bullet = E:create_entity(ra.bullet)

					bullet.pos.x, bullet.pos.y = this.pos.x, this.pos.y
					bullet.bullet.from.x, bullet.bullet.from.y = bullet.pos.x, bullet.pos.y
					bullet.bullet.to.x, bullet.bullet.to.y = targets[1].pos.x + targets[1].unit.hit_offset.x, targets[1].pos.y + targets[1].unit.hit_offset.y
					bullet.bullet.target_id = targets[1].id
					bullet.bullet.source_id = this.id

					simulation:queue_insert_entity(bullet)

					ra.ts = store.tick_ts
				end
			end

			if la and store.tick_ts - la.ts >= la.cooldown then
				local decal = E:create_entity(la.decal)

				decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
				decal.aura = la.aura
				decal.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(decal)

				la.ts = store.tick_ts
			end

			SU.soldier_go_back_step(store, this)

			coroutine.yield()
		end
	end
	tt.main_script.remove = function(this, store)
		if this.aura then
			simulation:queue_remove_entity(this.aura)
		end

		if this.decal_damage_range_entity then
			this.decal_damage_range_entity.remove = true
		end

		return true
	end
	tt.motion.max_speed = 60
	tt.duration = 10
	tt.unit.hit_offset.x, tt.unit.hit_offset.y = 5, 35
	tt.unit.level = 0
	tt.unit.size = UNIT_SIZE_MEDIUM
	tt.render.sprites[1].prefix = "teslaguy_lvl1Def"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.vis.bans = bor(F_ALL)
	tt.vis.flags = 0
	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.portrait = "kr6_info_portraits_soldiers_0045"
	tt.info.i18n_key = "POWER_THUNDER_ZAPPER"
	tt.info.damage_icon = "d_true"
	tt.damage_aura = "aura_power_thunder_zapper"
	tt.decal_damage_range = "decal_power_thunder_zapper_area_range"
	tt.timed_attacks.list[1] = E:clone_c("custom_attack")
	tt.timed_attacks.list[1].bullet = "bullet_power_thunder_zapper_ray_l3"
	tt.timed_attacks.list[1].range = 100
	tt.timed_attacks.list[1].cooldown = 2
	tt.timed_attacks.list[1].disabled = true
	tt.timed_attacks.list[1].min_targets = 1
	tt.timed_attacks.list[2] = E:clone_c("custom_attack")
	tt.timed_attacks.list[2].cooldown = 3
	tt.timed_attacks.list[2].decal = "decal_power_thunder_zapper_ray"
	tt.timed_attacks.list[2].aura = "aura_power_thunder_zapper_l6"
	tt.timed_attacks.list[2].disabled = true
	tt.sound_events.insert = "PowersThunderZapperSummonTaunt"
	tt.spawn_detection_range = 80
	tt.sound_out = "PowersThunderZapperOut"

	tt = E:register_t_tmp("bullet_power_thunder_zapper_ray_l3", "bullet")
	tt.bullet.hit_time = fts(1)
	tt.bullet.damage_type = DAMAGE_TRUE
	tt.bullet.pop = {"pop_zap"}
	tt.bullet.pop_chance = 0.5
	tt.bullet.pop_conds = DR_KILL
	tt.bounces = nil
	tt.bounces_lvl = {
		[0] = 2,
		3,
		4,
		5
	}
	tt.bounce_range = 100
	tt.bounce_vis_flags = F_RANGED
	tt.bounce_vis_bans = 0
	tt.bounce_damage_min = 25
	tt.bounce_damage_max = 35
	tt.bounce_damage_factor = 1
	tt.bounce_damage_factor_min = 1
	tt.bounce_damage_factor_inc = 0
	tt.bounce_delay = fts(2)
	tt.bounce_scale_y = 1
	tt.bounce_scale_y_factor = 0.88
	tt.excluded_templates = {"enemy_spectral_knight"}
	tt.image_width = 100
	tt.seen_targets = {}
	tt.render.sprites[1].anchor = v(0, 0.5)
	tt.render.sprites[1].name = "ray_tesla"
	tt.render.sprites[1].loop = false
	tt.render.sprites[1].z = Z_BULLETS
	tt.sound_events.insert = "PowersThunderZapperRicochetCast"
	tt.main_script.update = function(this, store)
		local b = this.bullet
		local s = this.render.sprites[1]
		local target = store.entities[b.target_id]
		local source = store.entities[b.source_id]
		local dest = b.to
		local l_src, l_dst = V.vclone(this.pos), V.vclone(b.to)

		s.scale = v(1, 1)

		local function update_sprite()
			if target and target.motion then
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end

			if source and source.motion then
				this.pos.x, this.pos.y = source.pos.x, source.pos.y

				if source.unit and source.unit.hit_offset then
					this.pos.x, this.pos.y = this.pos.x + source.unit.hit_offset.x, this.pos.y + source.unit.hit_offset.y
				end
			end

			local dsrc = math.max(math.abs(this.pos.x - l_src.x), math.abs(this.pos.y - l_src.y))
			local ddst = math.max(math.abs(dest.x - l_dst.x), math.abs(dest.y - l_dst.y))

			if dsrc > b.max_track_distance or ddst > b.max_track_distance then
				s.hidden = true
				target = nil

				return false
			end

			l_src.x, l_src.y = this.pos.x, this.pos.y
			l_dst.x, l_dst.y = dest.x, dest.y

			s.r = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)
			s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
			s.scale.y = 0.4 + math.min(0.6, math.max(0, s.scale.x * 0.6))
			s.scale.y = s.scale.y * this.bounce_scale_y

			return true
		end

		if target then
			s.ts = store.tick_ts

			if not update_sprite() then
			elseif not this.excluded_templates or not table.contains(this.excluded_templates, target.template_name) then
				local d = E:create_entity("damage")

				d.source_id = b.source_id
				d.target_id = target.id
				local bounce_factor = (not this.bounces or UP:get_upgrade("engineer_efficiency")) and 1 or this.bounce_damage_factor

				d.value = math.floor(math.random(this.bounce_damage_min, this.bounce_damage_max) * bounce_factor)
				d.damage_type = b.damage_type
				d.pop = b.pop
				d.pop_conds = b.pop_conds

				queue_damage(store, d)

				local hfx = E:create_entity("fx_power_thunder_zapper_hit")

				hfx.render.sprites[1].ts = store.tick_ts
				hfx.pos.x = target.pos.x + (target.unit.hit_offset and target.unit.hit_offset.x or 0)
				hfx.pos.y = target.pos.y + (target.unit.hit_offset and target.unit.hit_offset.y or 0)

				simulation:queue_insert_entity(hfx)

				table.insert(this.seen_targets, target.id)

				if not this.bounces then
					this.bounces = this.bounces_lvl[b.level]
				end

				if this.bounces > 0 then
					U.y_wait(store, this.bounce_delay)

					local bounce_target = U.find_nearest_enemy(store, target.pos, 0, this.bounce_range, this.bounce_vis_flags, this.bounce_vis_bans, function(e)
						return not table.contains(this.seen_targets, e.id)
					end)

					if bounce_target then
						local next_ray = E:create_entity(this.template_name)

						next_ray.pos = V.vclone(dest)
						next_ray.bullet.to = V.vclone(bounce_target.pos)
						next_ray.bullet.target_id = bounce_target.id
						next_ray.bullet.source_id = target.id
						next_ray.bounces = this.bounces - 1
						next_ray.bounce_scale_y = next_ray.bounce_scale_y * next_ray.bounce_scale_y_factor
						next_ray.seen_targets = this.seen_targets
						next_ray.bounce_damage_factor = math.max(this.bounce_damage_factor + this.bounce_damage_factor_inc, this.bounce_damage_factor_min)

						simulation:queue_insert_entity(next_ray)
					end
				end

				while not U.animation_finished(this) do
					if target then
						update_sprite()
					end

					coroutine.yield()
				end
			end
		end

		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp("aura_power_thunder_zapper", "aura")
	tt.aura.vis_bans = bor(F_FRIEND, F_FLYING, F_HERO)
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.cycle_time = 0.25
	tt.aura.duration = 1e99
	tt.aura.damage_min = 6
	tt.aura.damage_max = 10
	tt.aura.damage_type = DAMAGE_TRUE
	tt.aura.radius = 80
	tt.aura.mods = {}
	tt.main_script.update = scripts.aura_apply_damage.update

	tt = E:register_t_tmp("aura_power_thunder_zapper_summon", "aura")
	tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.cycle_time = 0
	tt.aura.cycles = 1
	tt.aura.duration = 1e99
	tt.aura.damage_min = 30
	tt.aura.damage_max = 42
	tt.aura.damage_type = DAMAGE_TRUE
	tt.aura.radius = 110
	tt.aura.mods = {}
	tt.main_script.update = scripts.aura_apply_damage.update

	tt = E:register_t_tmp("aura_power_thunder_zapper_l6", "aura")
	tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
	tt.aura.vis_flags = bor(F_AREA)
	tt.aura.cycle_time = 0
	tt.aura.cycles = 1
	tt.aura.duration = 1e99
	tt.aura.damage_min = 80
	tt.aura.damage_max = 125
	tt.aura.damage_type = DAMAGE_TRUE
	tt.aura.radius = 120
	tt.aura.mods = {}
	tt.main_script.update = scripts.aura_apply_damage.update

	tt = E:register_t_tmp("decal_power_thunder_zapper_area_damage", "decal_timed")
	tt.render.sprites[1].prefix = "animations_areadmgDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t_tmp("decal_power_thunder_zapper_ray", "decal_scripted")
	E:add_comps(tt, "sound_events")

	tt.render.sprites[1].prefix = "animations_skyrayDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = v(2, 2)
	tt.render.sprites[1].r = 3 * math.pi / 2
	tt.render.sprites[1].offset = v(0, 150)
	tt.render.sprites[1].loop = false
	tt.main_script.update = function(this, store)
		if this.aura then
			local aura = E:create_entity(this.aura)

			aura.pos.x, aura.pos.y = this.pos.x, this.pos.y

			simulation:queue_insert_entity(aura)
		end

		local area = E:create_entity(this.decal_damage)

		area.pos.x, area.pos.y = this.pos.x, this.pos.y
		area.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(area)
		U.y_animation_wait(this, 1, 1)
		simulation:queue_remove_entity(this)
	end
	tt.decal_damage = "decal_power_thunder_zapper_area_damage"
	tt.sound_events.insert = "PowersThunderZapperLightningStrikeCast"

	tt = E:register_t_tmp("decal_power_thunder_zapper_area_range", "decal_scripted")
	tt.render.sprites[1].prefix = "animations_decalDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = vv(0.8)
	tt.anim_in = "in"
	tt.anim_loop = "run"
	tt.anim_out = "out"
	tt.main_script.update = function(this, store)
		U.y_animation_play(this, this.anim_in, nil, store.tick_ts, 1, 1)
		U.animation_start(this, this.anim_loop, nil, store.tick_ts, true, 1)

		while not this.remove do
			coroutine.yield()
		end

		U.y_animation_play(this, this.anim_out, nil, store.tick_ts, 1, 1)
		simulation:queue_remove_entity(this)
	end

	tt = E:register_t_tmp("fx_power_thunder_zapper_hit", "fx")
	tt.render.sprites[1].prefix = "animations_modifierDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_BULLETS

	tt = E:register_t_tmp("mod_power_thunder_zapper_slow", "mod_slow")
	tt.slow.factor = 0.75
	tt.modifier.duration = 1
	tt.modifier.vis_flags = bor(F_MOD)
	tt.main_script.insert = scripts.mod_slow.insert

	tt = E:register_t_tmp("mod_power_thunder_zapper_stun", "mod_stun")
	tt.modifier.duration = 3
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.modifier.vis_bans = bor(F_BOSS)
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local soldier = E:get_template("soldier_thunder_zapper")
	local damage_aura = E:get_template("aura_power_thunder_zapper")
	local summon_aura = E:get_template("aura_power_thunder_zapper_summon")
	local strike_aura = E:get_template("aura_power_thunder_zapper_l6")
	local ray = E:get_template("bullet_power_thunder_zapper_ray_l3")

	ctrl.cooldown = 50
	soldier.duration = 10
	soldier.render.sprites[1].prefix = "teslaguy_lvl1Def"
	soldier.unit.hit_offset.x, soldier.unit.hit_offset.y = 5, 35
	soldier.timed_attacks.list[1].disabled = true
	soldier.timed_attacks.list[2].disabled = true

	damage_aura.aura.damage_min = 5.5
	damage_aura.aura.damage_max = 8
	damage_aura.aura.radius = 80
	damage_aura.aura.mods = {}

	summon_aura.aura.damage_min = 30
	summon_aura.aura.damage_max = 42
	summon_aura.aura.radius = 110
	summon_aura.aura.mods = {}

	strike_aura.aura.damage_min = 80
	strike_aura.aura.damage_max = 120
	strike_aura.aura.radius = 120
	strike_aura.aura.mods = {}

	ray.bounce_damage_min = 25
	ray.bounce_damage_max = 35

	if level >= 2 then
		local function scale_damage(aura, factor)
			aura.aura.damage_min = aura.aura.damage_min * factor
			aura.aura.damage_max = aura.aura.damage_max * factor
		end

		scale_damage(damage_aura, 1.5)
		scale_damage(strike_aura, 1.25)

		soldier.duration = 10 * 1.2
	end

	if level >= 3 then
		soldier.timed_attacks.list[1].disabled = false
		soldier.render.sprites[1].prefix = "teslaguy_lvl2Def"
	end

	if level >= 4 then
		ctrl.cooldown = 50 - 7.5

		damage_aura.aura.mods = {"mod_power_thunder_zapper_slow"}
		summon_aura.aura.mods = {"mod_power_thunder_zapper_slow"}
		strike_aura.aura.mods = {"mod_power_thunder_zapper_slow"}
	end

	if level >= 5 then
		damage_aura.aura.radius = damage_aura.aura.radius * 1.25
		summon_aura.aura.radius = summon_aura.aura.radius * 1.25
		strike_aura.aura.radius = strike_aura.aura.radius * 1.25

		summon_aura.aura.mods = {"mod_power_thunder_zapper_slow", "mod_power_thunder_zapper_stun"}
	end

	if level >= 6 then
		soldier.render.sprites[1].prefix = "teslaguy_lvl3Def"
		soldier.unit.hit_offset.x, soldier.unit.hit_offset.y = 2, 55
		soldier.timed_attacks.list[2].disabled = false
	end
end

return M
