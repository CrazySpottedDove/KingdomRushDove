local M = {}

M.name = "sheepmorph"
M.i18n = "POWER_SHEEPMORPH"
M.control = "power_sheepmorph_control"
M.button_icon = "in_game_icon_power_sheepmorph"
M.pointer_icon = "pointer_power_sheepmorph"
M.portrait = "power_portraits_big_sheepmorph"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {255, 244, 196, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.26, 0.20, 0.03, 1}
	}, {
		thickness = 2,
		glow_color = {0.98, 0.86, 0.36, 0.75}
	}},
	shader_margin = 16
}
M.resources = {
	game = {
		required_textures = {"go_power_sheepmorph"},
		plugin_required_textures = {},
		required_sounds = {"spell_sheepmorph"},
		plugin_required_sounds = {},
		required_exoskeletons = {"sheepmorph_unit_sheep_bigDef", "sheepmorph_unit_sheep_ninjaDef", "sheepmorph_unit_sheep_smallDef", "sheepmorph_unit_sheep_voladorDef", "sheepmorph_unit_super_sheepDef"},
		plugin_required_exoskeletons = {}
	}
}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local vv = V.vv
	local r = V.r
	local bit = require("bit")
	local band = bit.band
	local bor = bit.bor
	local km = require("lib.klua.macros")
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local GS = require("kr1.game_settings")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function queue_damage(store, d)
		store.damage_queue[#store.damage_queue + 1] = d
	end

	local function find_targets(store, mod, pos, radius)
		return U.find_enemies_in_range(store, pos, 0, radius, mod.modifier.vis_flags, mod.modifier.vis_bans, function(e)
			return e.motion and not e._sheepmorph_swapped and not e.health.ignore_damage
		end)
	end

	local function insert_mod(store, mod_t, target, source_id)
		local m = E:create_entity(mod_t)

		m.modifier.target_id = target.id
		m.modifier.source_id = source_id

		simulation:queue_insert_entity(m)

		return m
	end

	local function insert_fx(store, name, pos, follow)
		local fx = E:create_entity(name)

		fx.pos = V.vclone(pos)
		fx.render.sprites[1].ts = store.tick_ts
		fx._follow_id = follow and follow.id

		simulation:queue_insert_entity(fx)

		return fx
	end

	local function base_pos(e)
		return v(e.pos.x, e.pos.y + (e.flight_height or 0))
	end

	local function pay_gold(store, e)
		local factor = GS.difficulty_enemy_gold_factor and GS.difficulty_enemy_gold_factor[store.level_difficulty] or 1
		local gold = km.round(e.enemy.gold * factor)

		e.enemy.gold = 0

		if gold > 0 then
			store.player_gold = store.player_gold + gold

			signal.emit("got-enemy-gold", e, gold)
		end
	end

	local function release_count_group(store, e)
		local c = e.count_group

		if not c or not c.in_limbo then
			return
		end

		c.in_limbo = nil

		local g = store.count_groups

		if c.type == COUNT_GROUP_CONCURRENT and g[c.type][c.name] then
			g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)

			signal.emit("count-group-changed", e, g[c.type][c.name], -1)
		end
	end

	local function explode(this, store, bans)
		local enemies = U.find_enemies_in_range(store, this.pos, 0, this.damage_radius, F_AREA, bans)

		for _, e in pairs(enemies or {}) do
			local d = E:create_entity("damage")

			d.damage_type = this.damage_type
			d.value = math.random(this.damage_min, this.damage_max)
			d.source_id = this.id
			d.target_id = e.id

			queue_damage(store, d)
		end

		insert_fx(store, this.hit_fx, this.pos)
		insert_fx(store, this.hit_decal, this.pos)
		S:queue(this.sound_hit)
	end

	local function insert_trail(store, this, h)
		local ps = E:create_entity(this.trail_ps)

		ps.particle_system.track_id = this.id
		ps.particle_system.track_offset = v(0, h)

		simulation:queue_insert_entity(ps)

		return ps
	end

	local function spawn_barbarian(this, store, target)
		if band(target.health.immune_to, DAMAGE_EAT) ~= 0 then
			return false
		end

		local alive = table.filter(store.entities, function(_, e)
			return e.template_name == this.barbarian_t and not e.health.dead
		end)

		if #alive >= this.barbarian_max_alive then
			table.sort(alive, function(e1, e2)
				return (e1.reinforcement.ts or store.tick_ts) < (e2.reinforcement.ts or store.tick_ts)
			end)

			for i = 1, #alive - this.barbarian_max_alive + 1 do
				alive[i].reinforcement.duration = 0
			end
		end

		local d = E:create_entity("damage")

		d.damage_type = bor(DAMAGE_EAT, DAMAGE_NO_LIFESTEAL)
		d.source_id = this.id
		d.target_id = target.id

		queue_damage(store, d)

		local e = E:create_entity(this.barbarian_t)

		e.pos = V.vclone(target.pos)
		e.nav_rally.center = V.vclone(target.pos)
		e.nav_rally.pos = V.vclone(target.pos)

		simulation:queue_insert_entity(e)
		insert_fx(store, this.barbarian_fx, e.pos, e)

		return true
	end

	local function restore(this, store, target, sheep)
		target._sheepmorph_swapped = nil

		for i, s in ipairs(target.render.sprites) do
			s.hidden = this._sprites_hidden[i]
		end

		target.main_script.runs = 1

		if target.ui then
			target.ui.can_click = this._ui_can_click
		end

		target.pos = V.vclone(sheep.pos)

		if sheep.enemy then
			target.nav_path = sheep.nav_path
		else
			target.nav_path.pi, target.nav_path.spi = sheep.nav_path.pi, sheep.nav_path.spi
			target.nav_path.ni = math.max(1, sheep.nav_path.ni)
		end

		local n = target.nav_path
		local nodes = P.paths[n.pi][n.spi]
		local best, best_d2 = n.ni, 9e+99

		for i = math.max(1, n.ni - 20), math.min(#nodes, n.ni + 20) do
			local d2 = V.dist2(nodes[i].x, nodes[i].y, target.pos.x, target.pos.y)

			if d2 < best_d2 then
				best, best_d2 = i, d2
			end
		end

		n.ni = best

		local restored_max = math.min(target.health.hp_max, this._target_hp or target.health.hp_max)

		target.health.hp = km.clamp(1, restored_max, target.health.hp_max * sheep.health.hp / sheep.health.hp_max)

		simulation:queue_insert_entity(target)

		sheep.trigger_deselect = true

		SU.remove_modifiers(store, sheep)

		if sheep.soldier then
			U.unblock_target(store, sheep)
		end

		if store.entities[sheep.id] then
			simulation:queue_remove_entity(sheep)
		end

		insert_fx(store, this.transform_fx, base_pos(target), target)
		S:queue(this.sound_transform_out)
	end

	local function spread_curse(store, mod, pos, fx_pos, source_id)
		if math.random() >= mod.contagion_chance then
			return
		end

		pos = V.vclone(pos)

		insert_fx(store, mod.death_fx, fx_pos)
		U.y_wait(store, mod.contagion_delay)

		local targets = find_targets(store, mod, pos, mod.contagion_radius)

		if targets then
			table.sort(targets, function(e1, e2)
				return V.dist(e1.pos.x, e1.pos.y, pos.x, pos.y) < V.dist(e2.pos.x, e2.pos.y, pos.x, pos.y)
			end)

			for i = 1, math.min(#targets, mod.contagion_max_targets) do
				insert_mod(store, mod.template_name, targets[i], source_id)
			end
		end
	end

	local function y_launch(this, store)
		local s = this.render.sprites[1]

		this.ui.can_click = false

		S:queue(this.sound_launch, this.sound_launch_args)

		if this.launch_animation then
			s.flip_x = not s.flip_x

			U.y_animation_play(this, this.launch_animation, nil, store.tick_ts, 1)
		end

		U.sprites_hide(this, nil, nil, true)

		local b = E:create_entity(this.launch_t)

		b.pos = V.vclone(this.pos)
		b._path_pi, b._path_ni = this.nav_path.pi, this.nav_path.ni
		b._start_h = this.launch_height
		b._contagion_mod_t = this._sheepmorph_contagion_mod_t

		simulation:queue_insert_entity(b)

		this.health.delete_now = true
	end

	local tt

	tt = E:register_t(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		return true
	end
	tt.main_script.update = function(this, store)
		local targets = find_targets(store, E:get_template(this.mod_t), this.pos, this.radius) or {}

		table.sort(targets, function(e1, e2)
			return e1.health.hp_max > e2.health.hp_max
		end)

		local count = math.min(#targets, this.max_targets)
		local barbarian_idx

		if this.barbarian_t then
			local candidates = {}

			for i = 1, count do
				if not U.flag_has(targets[i].vis.flags, F_MINIBOSS) then
					table.insert(candidates, i)
				end
			end

			barbarian_idx = #candidates > 0 and table.random(candidates)
		end

		for i = 1, count do
			if i ~= barbarian_idx or not spawn_barbarian(this, store, targets[i]) then
				local m = insert_mod(store, this.mod_t, targets[i], this.id)

				if this.ninja_t and not U.flag_has(targets[i].vis.flags, F_FLYING) then
					m.ninja_t = this.ninja_t
				end
			end
		end

		insert_fx(store, this.cast_fx, this.pos)
		S:queue(this.sound_cast)
		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = scripts.user_power_3.can_select_point
	tt.cooldown = 50
	tt.radius = 80
	tt.max_targets = 4
	tt.mod_t = "mod_power_sheepmorph"
	tt.barbarian_t = nil
	tt.barbarian_max_alive = 3
	tt.barbarian_fx = "fx_power_sheepmorph_spawn_in"
	tt.cast_fx = "fx_power_sheepmorph_click_no_creeps"
	tt.sound_cast = "PowersSheepmorphCast"
	tt.ninja_t = nil

	E:set_template("user_power_3", tt)

	tt = E:register_t("mod_power_sheepmorph", "modifier")
	tt.modifier.duration = 6
	tt.modifier.type = MOD_TYPE_POLYMORPH
	tt.modifier.vis_flags = bor(F_MOD, F_POLYMORPH)
	tt.modifier.vis_bans = bor(F_BOSS, F_POLYMORPH)
	tt.miniboss_duration_factor = 0.5
	tt.hp_factor = 0.6
	tt.speed_factor = 0.6
	tt.sheep_t = "enemy_power_sheepmorph_sheep"
	tt.sheep_flying_t = "enemy_power_sheepmorph_sheep_flying"
	tt.ninja_t = nil
	tt.transform_fx = "fx_power_sheepmorph_spawn_in"
	tt.sound_transform = "PowersSheepmorphTransform"
	tt.sound_transform_out = "PowersSheepmorphTransformOut"
	tt.contagion = false
	tt.contagion_chance = 0.35
	tt.contagion_radius = 70
	tt.contagion_max_targets = 1
	tt.contagion_delay = fts(7)
	tt.death_fx = "fx_power_sheepmorph_spread_curse"
	tt.main_script.insert = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if not target or target.health.dead or target._sheepmorph_swapped or not target.nav_path then
			return false
		end

		local speed = target.motion.max_speed
		local _, mods = U.has_modifier_types(store, target, MOD_TYPE_FAST, MOD_TYPE_SLOW)

		for _, m in pairs(mods) do
			local f = m.fast and m.fast.factor or m.slow and m.slow.factor

			if f and f > 0 then
				speed = speed / f
			end
		end

		this._sprites_hidden = {}

		for i, s in ipairs(target.render.sprites) do
			this._sprites_hidden[i] = s.hidden
			s.hidden = true
		end

		this._ui_can_click = target.ui and target.ui.can_click

		SU.remove_modifiers(store, target)
		SU.remove_auras(store, target)
		simulation:queue_remove_entity(target)
		U.unblock_all(store, target)

		if target.ui then
			target.ui.can_click = false
		end

		target.main_script.co = nil
		target.main_script.runs = 0

		if target.count_group then
			target.count_group.in_limbo = true
		end

		target.trigger_deselect = true
		target._sheepmorph_swapped = true
		this._target = target
		this._target_hp = target.health.hp

		if U.flag_has(target.vis.flags, F_MINIBOSS) then
			this.modifier.duration = this.modifier.duration * this.miniboss_duration_factor
		end

		local flying = U.flag_has(target.vis.flags, F_FLYING)
		local sheep

		if this.ninja_t and not flying and P:is_node_valid(target.nav_path.pi, target.nav_path.ni, NF_NO_BACKWARDS) then
			sheep = E:create_entity(this.ninja_t)
			sheep.nav_path.pi, sheep.nav_path.spi, sheep.nav_path.ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
		else
			sheep = E:create_entity(flying and this.sheep_flying_t or this.sheep_t)
			sheep.nav_path = target.nav_path
			sheep.enemy.gold = target.enemy.gold
			sheep.enemy.lives_cost = target.enemy.lives_cost
			U.update_max_speed(sheep, speed * this.speed_factor)
		end

		sheep.pos = V.vclone(target.pos)
		sheep.health.hp_max = math.max(1, math.floor(target.health.hp_max * this.hp_factor))
		sheep.health.hp = math.max(1, math.floor(target.health.hp * this.hp_factor))
		sheep.health.patched = target.health.patched

		if sheep.soldier then
			sheep.nav_rally.pos:copy(sheep.pos)
			sheep.nav_rally.center:copy(sheep.pos)
		end

		if this.contagion then
			sheep._sheepmorph_contagion_mod_t = this.template_name
		end

		simulation:queue_insert_entity(sheep)

		this._sheep = sheep

		insert_fx(store, this.transform_fx, base_pos(target), sheep)
		S:queue(this.sound_transform)

		return true
	end
	tt.main_script.update = function(this, store)
		local m = this.modifier
		local sheep = this._sheep

		m.ts = store.tick_ts
		local insert_wait = 0

		while true do
			this.pos.x, this.pos.y = sheep.pos.x, sheep.pos.y

			if sheep.health.dead then
				if not sheep.enemy then
					pay_gold(store, this._target)
				end

				if this.contagion and not sheep.launch_t then
					spread_curse(store, this, sheep.pos, base_pos(sheep), this.id)
				end

				break
			end

			if store.entities[sheep.id] then
				sheep._sheepmorph_inserted = true
			elseif sheep._sheepmorph_inserted then
				break
			else
				-- mod 先插入、羊后插入；插入队列要到下一 tick 才处理，不能在第一帧就判定羊消失
				insert_wait = insert_wait + 1

				if insert_wait > 2 then
					break
				end
			end

			if sheep.pending_removal then
				break
			end

			if store.tick_ts - m.ts > m.duration or sheep._sheepmorph_path_end then
				break
			end

			coroutine.yield()
		end

		simulation:queue_remove_entity(this)
	end
	tt.main_script.remove = function(this, store)
		local target, sheep = this._target, this._sheep

		if not target or not sheep then
			return true
		end

		local in_game = store.entities[sheep.id] and not sheep.pending_removal

		if not sheep.health.dead and (in_game or not sheep._sheepmorph_inserted) then
			restore(this, store, target, sheep)
		else
			release_count_group(store, target)
		end

		return true
	end

	local function register_sheep(name, base)
		local tt = E:register_t(name, base or "enemy")

		if not base then
			E:add_comps(tt, "tween")
		end

		tt.enemy.gold = 0
		tt.health.hp_max = 100
		tt.health.hp = 100
		tt.health.armor = 0
		tt.health.magic_armor = 0
		tt.health_bar.offset = v(0, 28)
		tt.info.i18n_key = "ENEMY_SHEEP"
		tt.info.portrait = "kr6_info_portraits_soldiers_0028"
		tt.main_script.insert = scripts.enemy_basic.insert
		tt.main_script.update = function(this, store)
			local bombs, bomb_ts = 0, store.tick_ts
			local bomb_wait = this.bomb_cooldown and this.bomb_cooldown + U.frandom(0, this.bomb_random_delay)

			local function bomb_due()
				return this.bomb_t and bombs < this.bomb_max and store.tick_ts - bomb_ts >= bomb_wait
			end

			local function interrupt(store, this)
				return this.ui.clicked or bomb_due()
			end

			while true do
				if this.health.dead then
					if this.launch_t then
						y_launch(this, store)

						return
					end

					SU.y_enemy_death(store, this)

					return
				end

				if bomb_due() then
					bombs = bombs + 1
					bomb_ts = store.tick_ts
					bomb_wait = this.bomb_cooldown + U.frandom(0, this.bomb_random_delay)

					local b = E:create_entity(this.bomb_t)

					b.pos = V.vclone(this.pos)
					b._path_pi, b._path_spi, b._path_ni = this.nav_path.pi, this.nav_path.spi, this.nav_path.ni
					b._start_h = this.unit.hit_offset.y

					simulation:queue_insert_entity(b)
				end

				if this.ui.clicked then
					this.ui.clicked = nil
					this.tween.ts = store.tick_ts
					this.tween.disabled = false
				end

				if this.unit.is_stunned then
					U.animation_start(this, "idle", nil, store.tick_ts, true)
					coroutine.yield()
				else
					SU.y_enemy_walk_until_blocked(store, this, true, interrupt)
				end
			end
		end
		tt.render.sprites[1].prefix = "sheepmorph_unit_sheep_smallDef"
		tt.render.sprites[1].name = "idle"
		tt.render.sprites[1].exo = true
		tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
		tt.sound_events.death = "PowersSheepmorphDeath"
		tt.tween.disabled = true
		tt.tween.remove = false
		tt.tween.run_once = true
		tt.tween.props[1].name = "scale"
		tt.tween.props[1].interp = "step"
		tt.tween.props[1].keys = {{0, vv(1)}, {fts(2), v(1.054, 0.87)}, {fts(4), v(0.934, 1.074)}, {fts(6), vv(1)}}
		tt.ui.click_rect = r(-15, 0, 30, 25)
		tt.unit.can_explode = false
		tt.unit.fade_time_after_death = nil
		tt.unit.can_disintegrate = false
		tt.unit.hide_after_death = true
		tt.unit.show_blood_pool = false
		tt.unit.hit_offset = v(0, 10)
		tt.unit.head_offset = v(0, 16)
		tt.unit.mod_offset = v(0, 10)
		tt.unit.size = UNIT_SIZE_SMALL
		tt.vis.flags = bor(F_ENEMY)
		tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT, F_POLYMORPH)
		tt.sheepmorph_sheep = true

		return tt
	end

	register_sheep("enemy_power_sheepmorph_sheep")

	tt = register_sheep("enemy_power_sheepmorph_sheep_flying", "enemy_power_sheepmorph_sheep")
	tt.flight_height = 40
	tt.health_bar.offset = v(0, 80)
	tt.info.portrait = "kr6_info_portraits_soldiers_0029"
	tt.render.sprites[1].prefix = "sheepmorph_unit_sheep_voladorDef"
	tt.render.sprites[1].offset = v(0, 40)
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "decal_flying_shadow"
	tt.render.sprites[2].z = Z_DECALS
	tt.render.sprites[2].scale = vv(0.6)
	tt.ui.click_rect = r(-17, 35, 34, 40)
	tt.unit.hit_offset = v(0, 52)
	tt.unit.head_offset = v(0, 60)
	tt.unit.mod_offset = v(0, 52)
	tt.vis.flags = bor(F_ENEMY, F_FLYING)

	tt = register_sheep("enemy_power_sheepmorph_supersheep", "enemy_power_sheepmorph_sheep")
	tt.health_bar.offset = v(0, 38)
	tt.info.i18n_key = "POWER_SHEEPMORPH_BOMB_SHEEP"
	tt.render.sprites[1].prefix = "sheepmorph_unit_super_sheepDef"
	tt.ui.click_rect = r(-15, 0, 30, 32)
	tt.launch_t = "bullet_power_sheepmorph_supersheep"
	tt.launch_animation = "fly_in"
	tt.sound_launch = "PowersSheepmorphSupersheepFly"
	tt.sound_launch_args = {
		delay = fts(16)
	}
	tt.launch_height = 40
	tt.bomb_t = nil
	tt.bomb_cooldown = 1.5
	tt.bomb_random_delay = 0.6
	tt.bomb_max = 6

	tt = register_sheep("enemy_power_sheepmorph_supersheep_flying", "enemy_power_sheepmorph_sheep_flying")
	tt.flight_height = 40
	tt.health_bar.offset = v(0, 80)
	tt.info.i18n_key = "POWER_SHEEPMORPH_BOMB_SHEEP"
	tt.info.portrait = "kr6_info_portraits_soldiers_0029"
	tt.render.sprites[1].prefix = "sheepmorph_unit_sheep_voladorDef"
	tt.render.sprites[1].offset = v(0, 40)
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "decal_flying_shadow"
	tt.render.sprites[2].z = Z_DECALS
	tt.render.sprites[2].scale = vv(0.6)
	tt.ui.click_rect = r(-17, 35, 34, 40)
	tt.unit.hit_offset = v(0, 52)
	tt.unit.head_offset = v(0, 60)
	tt.unit.mod_offset = v(0, 52)
	tt.vis.flags = bor(F_ENEMY, F_FLYING)
	tt.launch_t = "bullet_power_sheepmorph_supersheep"
	tt.launch_height = 52
	tt.sound_launch = "PowersSheepmorphSupersheepFly"
	tt.bomb_t = nil
	tt.bomb_cooldown = 1.5
	tt.bomb_random_delay = 0.6
	tt.bomb_max = 6

	tt = E:register_t("soldier_power_sheepmorph_ninja", "soldier_militia")
	E:add_comps(tt, "nav_path")
	tt.health.armor = 0
	tt.health.hp_max = 100
	tt.health.hp = 100
	tt.health.dead_lifetime = 3
	tt.health_bar.offset = v(0, 32)
	tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
	tt.idle_flip.chance = 0
	tt.info.fn = scripts.soldier_reinforcement.get_info
	tt.info.i18n_key = "POWER_SHEEPMORPH_NINJA_SHEEP"
	tt.info.random_name_format = nil
	tt.info.portrait = "kr6_info_portraits_soldiers_0028"
	tt.main_script.insert = function(this, store)
		this.melee.order = U.attack_order(this.melee.attacks)

		return true
	end
	tt.main_script.update = function(this, store)
		local brk, sta
		local next_pos = V.vclone(this.pos)

		this.render.sprites[1].ts = store.tick_ts

		if this.innate_orf_mod then
			local m = E:create_entity(this.innate_orf_mod)
			local d = math.max(1, math.ceil(this.health.hp_max * m.hp_percent_per_second))

			m.dps.damage_min, m.dps.damage_max = d, d
			m.modifier.target_id = this.id
			m.modifier.source_id = this.id

			simulation:queue_insert_entity(m)
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true)
		U.y_wait(store, this.spawn_wait, function()
			return this.health.dead
		end)

		while true do
			if this.health.dead then
				SU.remove_modifiers(store, this)
				SU.y_soldier_death(store, this)
				simulation:queue_remove_entity(this)

				return
			end

			this.nav_rally.pos:copy(this.pos)
			this.nav_rally.center:copy(this.pos)

			if this.unit.is_stunned then
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			else
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if not (brk or sta ~= A_NO_TARGET) then
					U.set_destination(this, next_pos)

					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

					U.animation_start(this, an, af, store.tick_ts, true)
					U.walk(this, store.tick_length)
					coroutine.yield()

					next_pos = P:next_entity_node(this, store.tick_length)

					if not next_pos then
						this._sheepmorph_path_end = true
						next_pos = V.vclone(this.pos)
					end
				end
			end

			coroutine.yield()
		end
	end
	tt.melee.range = 60
	tt.melee.attacks[1].animation = "attack"
	tt.melee.attacks[1].cooldown = 1
	tt.melee.attacks[1].damage_min = 14
	tt.melee.attacks[1].damage_max = 22
	tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
	tt.melee.attacks[1].hit_time = fts(11)
	tt.melee.attacks[1].shared_cooldown = true
	tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
	tt.melee.attacks[1].vis_flags = F_BLOCK
	tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
	tt.melee.attacks[2].animation = "attack_2"
	tt.melee.attacks[2].chance = 0.5
	tt.motion.max_speed = 70
	tt.nav_path.dir = -1
	tt.regen.health = 0
	tt.render.sprites[1].prefix = "sheepmorph_unit_sheep_ninjaDef"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.soldier.melee_slot_offset = v(8, 0)
	tt.sound_events.death = "PowersSheepmorphDeath"
	tt.ui.click_rect = r(-15, 0, 30, 30)
	tt.unit.hit_offset = v(0, 12)
	tt.unit.head_offset = v(0, 20)
	tt.unit.mod_offset = v(0, 12)
	tt.unit.size = UNIT_SIZE_SMALL
	tt.unit.hide_after_death = true
	tt.vis.flags = bor(F_BLOCK, F_FRIEND)
	tt.vis.bans = bor(F_SKELETON, F_LYCAN, F_EAT, F_NET, F_POLYMORPH)
	tt.innate_orf_mod = nil
	tt.spawn_wait = fts(14)

	tt = E:register_t("mod_power_sheepmorph_innate_orf", "modifier")
	E:add_comps(tt, "dps", "render")
	tt.modifier.duration = 1e+99
	tt.hp_percent_per_second = 0.06
	tt.dps.damage_every = 1
	tt.dps.damage_type = DAMAGE_TRUE
	tt.dps.kill = true
	tt.main_script.insert = scripts.mod_dps.insert
	tt.main_script.update = scripts.mod_dps.update
	tt.modifier.use_mod_offset = false
	tt.render.sprites[1].prefix = "power_sheepmorph_ninja_poison"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].draw_order = 2
	tt.render.sprites[1].loop = true

	tt = E:register_t("bullet_power_sheepmorph_supersheep", "decal_scripted")
	tt.render.sprites[1].prefix = "power_sheepmorph_supersheep_bullet"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].z = Z_BULLETS
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "decal_flying_shadow"
	tt.render.sprites[2].z = Z_DECALS
	tt.main_script.update = function(this, store)
		local s, shadow = this.render.sprites[1], this.render.sprites[2]
		local origin = V.vclone(this.pos)

		local function find_target()
			local found = U.find_enemies_in_paths(store.enemies, origin, math.floor(this.min_target_distance / P.average_node_dist), math.ceil(this.max_target_distance / P.average_node_dist), nil, F_AREA, 0, true, function(e)
				local d = V.dist(e.pos.x, e.pos.y, origin.x, origin.y)

				return d >= this.min_target_distance and d <= this.max_target_distance
			end)

			return found and found[1].enemy
		end

		local back_nodes = math.floor(0.5 * (this.min_target_distance + this.max_target_distance) / P.average_node_dist)
		local back_pos = P:node_pos(this._path_pi, 1, math.max(1, this._path_ni - back_nodes))
		local target, from, from_h, dest, dest_h, duration, arc, t0

		local function aim(h)
			target = find_target()
			dest = target and target.pos or back_pos
			dest_h = target and target.unit.hit_offset.y or 0
			from, from_h, t0 = V.vclone(this.pos), h, store.tick_ts

			local dist = V.dist(from.x, from.y, dest.x, dest.y)

			duration = math.max(this.min_flight_time, dist / this.speed)
			arc = km.clamp(this.arc_height_min, this.arc_height_max, dist * this.arc_height_factor)
		end

		local function height(p)
			return from_h + (dest_h - from_h) * p + 4 * arc * p * (1 - p)
		end

		aim(this._start_h or 0)
		U.animation_start(this, "loop", nil, store.tick_ts, true)

		local h = from_h
		local trail = insert_trail(store, this, h)

		while true do
			if target and (target.health.dead or not store.entities[target.id]) then
				aim(h)
			end

			local p = math.min(1, (store.tick_ts - t0) / duration)
			local x, y = from.x + (dest.x - from.x) * p, from.y + (dest.y - from.y) * p
			local nh = height(p)
			local vx, vy = x - this.pos.x, y + nh - (this.pos.y + h)

			if vx ~= 0 or vy ~= 0 then
				s.flip_x = vx < 0
				s.r = s.flip_x and math.atan2(-vy, -vx) or math.atan2(vy, vx)
			end

			this.pos.x, this.pos.y, h = x, y, nh
			s.offset.y = h
			trail.particle_system.track_offset.y = h

			local k = this.shadow_scale * (1 - 0.5 * km.clamp(0, 1, h / this.arc_height_max))

			shadow.scale = vv(k, k)

			if p >= 1 then
				break
			end

			coroutine.yield()
		end

		explode(this, store, 0)

		if this._contagion_mod_t then
			U.sprites_hide(this, nil, nil, true)

			trail.particle_system.emit = false

			spread_curse(store, E:get_template(this._contagion_mod_t), this.pos, this.pos, this.id)
		end

		simulation:queue_remove_entity(this)
	end
	tt.speed = 175
	tt.min_flight_time = 0.9
	tt.arc_height_min = 30
	tt.arc_height_factor = 0.8
	tt.arc_height_max = 220
	tt.shadow_scale = 0.6
	tt.trail_ps = "ps_power_sheepmorph_supersheep_trail"
	tt.min_target_distance = 90
	tt.max_target_distance = 270
	tt.damage_min = 80
	tt.damage_max = 120
	tt.damage_radius = 50
	tt.damage_type = DAMAGE_EXPLOSION
	tt.hit_fx = "fx_power_sheepmorph_supersheep_explosion"
	tt.hit_decal = "decal_power_sheepmorph_supersheep"
	tt.sound_hit = "PowersSheepmorphSupersheepExplosion"

	tt = E:register_t("bullet_power_sheepmorph_bomb", "decal_scripted")
	tt.render.sprites[1].prefix = "power_sheepmorph_bomb_bullet"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[2] = E:clone_c("sprite")
	tt.render.sprites[2].animated = false
	tt.render.sprites[2].name = "sheepmorph_asst_shadow"
	tt.render.sprites[2].scale = vv(0.6)
	tt.render.sprites[2].z = Z_DECALS
	tt.render.sprites[2].hidden = true
	tt.main_script.update = function(this, store)
		local s = this.render.sprites[1]

		S:queue(this.sound_spawn)

		local back_nodes = math.floor(this.drop_distance / P.average_node_dist)
		local dest = P:node_pos(this._path_pi, this._path_spi, math.max(1, this._path_ni - back_nodes))
		local from, from_h, t0 = V.vclone(this.pos), this._start_h or 0, store.tick_ts
		local spin = (dest.x < from.x and 1 or -1) * this.spin

		U.animation_start(this, "loop", nil, store.tick_ts, true)

		while true do
			local p = math.min(1, (store.tick_ts - t0) / this.drop_time)

			this.pos.x, this.pos.y = from.x + (dest.x - from.x) * p, from.y + (dest.y - from.y) * p
			s.offset.y = from_h + (this.rest_height - from_h) * p + 4 * this.drop_height * p * (1 - p)
			s.r = spin * p

			if p >= 1 then
				break
			end

			coroutine.yield()
		end

		this.render.sprites[2].hidden = false

		local function trigger(e)
			return not e.sheepmorph_sheep
		end

		local ts = store.tick_ts

		while store.tick_ts - ts < this.duration and not U.find_enemies_in_range(store, this.pos, 0, this.trigger_radius, F_AREA, F_FLYING, trigger) do
			coroutine.yield()
		end

		explode(this, store, F_FLYING)
		simulation:queue_remove_entity(this)
	end
	tt.drop_distance = 10
	tt.drop_time = fts(9)
	tt.drop_height = 8
	tt.rest_height = 8
	tt.spin = d2r(20)
	tt.trigger_radius = 30
	tt.duration = 7
	tt.damage_min = 80
	tt.damage_max = 110
	tt.damage_radius = 40
	tt.damage_type = DAMAGE_EXPLOSION
	tt.hit_fx = "fx_power_sheepmorph_bomb_explosion"
	tt.hit_decal = "decal_power_sheepmorph_bomb"
	tt.sound_spawn = "PowersSheepmorphBombsheepBombSpawn"
	tt.sound_hit = "PowersSheepmorphBombExplosion"

	tt = E:register_t("soldier_power_sheepmorph_barbarian", "soldier_militia")
	E:add_comps(tt, "reinforcement", "nav_grid", "tween")
	tt.controable = true
	tt.cooldown = nil
	tt.health.armor = 0
	tt.health.magic_armor = 0
	tt.health.hp_max = 300
	tt.health.hp = 300
	tt.health_bar.offset = v(0, 48)
	tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
	tt.info.portrait = "kr6_info_portraits_soldiers_0028"
	tt.info.i18n_key = "POWER_SHEEPMORPH_BARBARIAN_SHEEP"
	tt.info.random_name_format = nil
	tt.main_script.insert = function(this, store)
		this.tween.props[1].ts = store.tick_ts

		return scripts.soldier_reinforcement.insert(this, store)
	end
	tt.main_script.update = scripts.soldier_reinforcement.update
	tt.melee.attacks[1].animation = "attack_1"
	tt.melee.attacks[1].cooldown = 1.2
	tt.melee.attacks[1].damage_min = 24
	tt.melee.attacks[1].damage_max = 36
	tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
	tt.melee.attacks[1].hit_fx = nil
	tt.melee.attacks[1].hit_time = fts(13)
	tt.melee.attacks[1].hit_offset = v(25, 10)
	tt.melee.attacks[1].shared_cooldown = true
	tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
	tt.melee.attacks[2].animation = "attack_2"
	tt.melee.attacks[2].chance = 0.5
	tt.melee.range = 70
	tt.motion.max_speed = 75
	tt.regen.cooldown = 1
	tt.reinforcement.duration = 35
	tt.reinforcement.fade = false
	tt.render.sprites[1].prefix = "sheepmorph_unit_sheep_bigDef"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = {}
	tt.render.sprites[1].angles.walk = {"walk"}
	tt.soldier.melee_slot_offset = v(5, 0)
	tt.sound_events.insert = "PowersSheepmorphTransform"
	tt.sound_events.change_rally_point = "PowersSheepmorphTransform"
	tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
	tt.tween.props[1].name = "alpha"
	tt.tween.remove = false
	tt.tween.run_once = true
	tt.ui.click_rect = r(-18, -2, 36, 46)
	tt.unit.hit_offset = v(0, 18)
	tt.unit.mod_offset = v(0, 18)
	tt.unit.size = UNIT_SIZE_MEDIUM
	tt.portrait_idxs = nil

	tt = E:register_t("fx_power_sheepmorph_spawn_in", "fx")
	E:add_comps(tt, "main_script")
	tt.main_script.update = function(this, store)
		while true do
			local e = this._follow_id and store.entities[this._follow_id]

			if e then
				this.pos.x, this.pos.y = e.pos.x, e.pos.y + (e.flight_height or 0)
			end

			coroutine.yield()
		end
	end
	tt.render.sprites[1].prefix = "power_sheepmorph_spawn_in_fx"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("fx_power_sheepmorph_click_no_creeps", "fx")
	tt.render.sprites[1].prefix = "power_sheepmorph_click_no_creeps"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t("fx_power_sheepmorph_spread_curse", "fx")
	tt.render.sprites[1].prefix = "power_sheepmorph_spread_curse_fx"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("fx_power_sheepmorph_supersheep_explosion", "fx")
	tt.render.sprites[1].prefix = "power_sheepmorph_supersheep_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("decal_power_sheepmorph_supersheep", "decal_sequence")
	tt.render.sprites[1].prefix = "power_sheepmorph_supersheep_decal"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].z = Z_DECALS
	tt.sequence.steps = {"in", fts(27), "out"}

	tt = E:register_t("fx_power_sheepmorph_bomb_explosion", "fx")
	tt.render.sprites[1].prefix = "power_sheepmorph_bomb_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("decal_power_sheepmorph_bomb", "decal_sequence")
	tt.render.sprites[1].prefix = "power_sheepmorph_bomb_decal"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].z = Z_DECALS
	tt.sequence.steps = {"in", fts(27), "out"}

	tt = E:register_t("ps_power_sheepmorph_supersheep_trail", "particle_system")
	tt.particle_system.name = "power_sheepmorph_supersheep_trail_run"
	tt.particle_system.animated = true
	tt.particle_system.loop = false
	tt.particle_system.z = Z_BULLET_PARTICLES
	tt.particle_system.animation_fps = 30
	tt.particle_system.emission_rate = 15
	tt.particle_system.particle_lifetime = {fts(16), fts(16)}
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local mod = E:get_template("mod_power_sheepmorph")
	local ninja = E:get_template("soldier_power_sheepmorph_ninja")
	local supersheep = E:get_template("enemy_power_sheepmorph_supersheep")
	local supersheep_flying = E:get_template("enemy_power_sheepmorph_supersheep_flying")

	ctrl.cooldown = 50
	ctrl.radius = 80
	ctrl.max_targets = 4
	ctrl.barbarian_t = nil
	ctrl.ninja_t = nil
	mod.modifier.duration = 6
	mod.hp_factor = 0.6
	mod.speed_factor = 0.6
	mod.sheep_t = "enemy_power_sheepmorph_sheep"
	mod.sheep_flying_t = "enemy_power_sheepmorph_sheep_flying"
	mod.ninja_t = nil
	mod.contagion = false
	ninja.innate_orf_mod = nil
	supersheep.bomb_t = nil
	supersheep_flying.bomb_t = nil

	if level >= 2 then
		mod.modifier.duration = 8
		ctrl.max_targets = 6
	end

	if level >= 3 then
		mod.contagion = true
	end

	if level >= 4 then
		ctrl.ninja_t = "soldier_power_sheepmorph_ninja"
		mod.ninja_t = "soldier_power_sheepmorph_ninja"
		mod.sheep_t = "enemy_power_sheepmorph_supersheep"
		mod.sheep_flying_t = "enemy_power_sheepmorph_supersheep_flying"
		mod.speed_factor = 1.2
		mod.hp_factor = 0.6 * 0.67
	end

	if level >= 5 then
		ninja.innate_orf_mod = "mod_power_sheepmorph_innate_orf"
		supersheep.bomb_t = "bullet_power_sheepmorph_bomb"
		supersheep_flying.bomb_t = "bullet_power_sheepmorph_bomb"
	end

	if level >= 6 then
		ctrl.barbarian_t = "soldier_power_sheepmorph_barbarian"
	end
end

return M
