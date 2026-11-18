local M = {}

M.name = "regeneration_circle"
M.i18n = "POWER_REGENERATION_CIRCLE"
M.control = "power_regeneration_circle_control"
M.button_icon = "in_game_icon_power_regeneration_circle"
M.pointer_icon = "pointer_power_regeneration_circle"
M.portrait = "power_portraits_big_regeneration_circle"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {177, 236, 150, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.07, 0.22, 0.05, 1}
	}, {
		thickness = 2,
		glow_color = {0.52, 0.95, 0.38, 0.75}
	}},
	shader_margin = 16
}
M.resources = {
	game = {
		required_textures = {"go_power_regeneration_circle"},
		plugin_required_textures = {},
		required_sounds = {"spell_regeneration_circle"},
		plugin_required_sounds = {},
		required_exoskeletons = {"regeneration_circle_druid_decal_lvl3_hitDef", "regeneration_circle_druid_heal_hitfxDef", "regeneration_circle_druid_healing_decalDef", "regeneration_circle_druid_leaves_fxDef", "regeneration_circle_druid_lvl1Def", "regeneration_circle_druid_lvl2Def", "regeneration_circle_druid_lvl3Def", "regeneration_circle_druid_skill_5a_buffDef", "regeneration_circle_heal_fxDef"},
		plugin_required_exoskeletons = {}
	}
}

function M.register_templates(E)
	local V = require("lib.klua.vector")
	local v = V.v
	local r = V.r
	local bit = require("bit")
	local bor = bit.bor
	local km = require("lib.klua.macros")
	local U = require("utils")
	local S = require("sound_db")
	local SU = require("script_utils")
	local P = require("path_db")
	local signal = require("lib.hump.signal")
	local scripts = require("game_scripts")

	require("lib.klua.table")

	local function fts(x)
		return x / FPS
	end

	local function reduce_soldier_cooldowns(soldier, factor)
		for _, list in pairs({soldier.timed_attacks and soldier.timed_attacks.list, soldier.melee and soldier.melee.attacks, soldier.ranged and soldier.ranged.attacks}) do
			if list then
				for _, a in ipairs(list) do
					if a.ts and a.cooldown then
						a.ts = a.ts - a.cooldown * factor
					end
				end
			end
		end
	end

	local tt

	tt = E:register_t(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local e = E:create_entity(this.circle_t)

		e.pos = v(this.pos.x, this.pos.y)

		simulation:queue_insert_entity(e)
		S:queue(this.sound_cast)

		return true
	end
	tt.main_script.update = function(this, store)
		coroutine.yield()
		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = scripts.user_power_3.can_select_point
	tt.cooldown = 24
	tt.circle_t = "decal_power_regeneration_circle"
	tt.sound_cast = "PowersRegenerationCircleCast"

	E:set_template("user_power_3", tt)

	tt = E:register_t("decal_power_regeneration_circle", "decal_scripted")
	tt.render.sprites[1].prefix = "regeneration_circle_druid_healing_decalDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.main_script.update = function(this, store)
		local druid = E:create_entity(this.druid_t)

		druid.pos = V.vclone(this.pos)
		druid._circle_id = this.id
		druid._circle_pos = V.vclone(this.pos)
		druid._circle_radius = this.radius

		if druid.nav_rally then
			druid.nav_rally.center = V.vclone(this.pos)
			druid.nav_rally.pos = V.vclone(this.pos)
			druid.melee.range = this.radius
		end

		simulation:queue_insert_entity(druid)

		local slots = {}

		local function allies_inside(include_druid)
			return U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.radius, 0, 0, function(e)
				return include_druid or e.id ~= druid.id
			end) or {}
		end

		local function insert_mod(name, target)
			local m = E:create_entity(name)

			m.modifier.source_id = this.id
			m.modifier.target_id = target.id

			simulation:queue_insert_entity(m)

			return m
		end

		local function hero_heal_factor(target)
			return this.l4a_active and target.hero and this.hero_heal_factor or 1
		end

		U.y_animation_play(this, "in", nil, store.tick_ts, 1)
		U.animation_start(this, "idle", nil, store.tick_ts, true)

		if this.l5a_active then
			for _, s in pairs(store.soldiers) do
				reduce_soldier_cooldowns(s, this.cooldown_reduction)
			end
		end

		if this.l5b_active then
			for _, s in pairs(allies_inside(true)) do
				insert_mod(this.mod_invulnerability, s)
			end
		end

		local start_ts = store.tick_ts
		local cycle_ts = start_ts - this.cycle_time
		local flashing = false

		while store.tick_ts - start_ts < this.duration do
			if this._druid_hit then
				this._druid_hit = nil

				for _, s in pairs(allies_inside(true)) do
					insert_mod(this.mod_druid_hit, s)
				end

				U.animation_start(this, "lvl3_hit", nil, store.tick_ts, false)

				flashing = true
			end

			if flashing and U.animation_finished(this) then
				U.animation_start(this, "idle", nil, store.tick_ts, true)

				flashing = false
			end

			if store.tick_ts - cycle_ts >= this.cycle_time then
				cycle_ts = store.tick_ts

				local allies = allies_inside(true)
				local kept = {}

				for _, id in ipairs(slots) do
					local e = store.entities[id]

					if e and not e.health.dead and e.health.hp < e.health.hp_max and U.is_inside_ellipse(e.pos, this.pos, this.radius) then
						table.insert(kept, id)
					end
				end

				slots = kept

				if #slots < this.max_targets then
					local candidates = {}

					for _, e in pairs(allies) do
						if e.health.hp < e.health.hp_max and not table.contains(slots, e.id) then
							table.insert(candidates, e)
						end
					end

					table.sort(candidates, function(e1, e2)
						return e1.health.hp / e1.health.hp_max < e2.health.hp / e2.health.hp_max
					end)

					for i = 1, math.min(#candidates, this.max_targets - #slots) do
						table.insert(slots, candidates[i].id)
					end
				end

				for _, id in ipairs(slots) do
					local e = store.entities[id]
					local m = insert_mod(this.mod_heal, e)
					local f = hero_heal_factor(e)

					m.hps.heal_min, m.hps.heal_max = m.hps.heal_min * f, m.hps.heal_max * f
				end

				if this.l4b_active then
					for _, e in pairs(U.find_enemies_in_range(store, this.pos, 0, this.radius, 0, 0) or {}) do
						insert_mod(this.mod_slow, e)
					end
				end
			end

			coroutine.yield()
		end

		this._ended = true

		local out_ts = store.tick_ts

		U.animation_start(this, "out", nil, store.tick_ts, false)

		while not U.animation_finished(this) do
			this.render.sprites[1].alpha = 255 * km.clamp(0, 1, 1 - (store.tick_ts - out_ts) / this.out_fade_time)

			coroutine.yield()
		end

		simulation:queue_remove_entity(this)
	end
	tt.duration = 10
	tt.radius = 90
	tt.cycle_time = 0.25
	tt.max_targets = 5
	tt.out_fade_time = fts(13)
	tt.druid_t = "decal_power_regeneration_circle_druid_lvl1"
	tt.mod_heal = "mod_power_regeneration_circle_heal"
	tt.mod_druid_hit = "mod_power_regeneration_circle_druid_hit_heal"
	tt.l4a_active = false
	tt.hero_heal_factor = 1.5
	tt.l4b_active = false
	tt.mod_slow = "mod_power_regeneration_circle_slow"
	tt.l5a_active = false
	tt.cooldown_reduction = 0.2
	tt.l5b_active = false
	tt.mod_invulnerability = "mod_power_regeneration_circle_invulnerability"

	tt = E:register_t("decal_power_regeneration_circle_leaves", "decal_scripted")
	tt.render.sprites[1].prefix = "regeneration_circle_druid_leaves_fxDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = 1
	tt.main_script.update = function(this, store)
		U.y_animation_play(this, "in", nil, store.tick_ts, 1)
		U.animation_start(this, "loop", nil, store.tick_ts, true)

		while not this._stop do
			coroutine.yield()
		end

		U.y_animation_play(this, "out", nil, store.tick_ts, 1)
		simulation:queue_remove_entity(this)
	end

	tt = E:register_t("decal_power_regeneration_circle_druid_lvl1", "decal_scripted")
	tt.render.sprites[1].prefix = "regeneration_circle_druid_lvl1Def"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.main_script.update = function(this, store)
		U.y_animation_play(this, "in", nil, store.tick_ts, 1)

		local leaves = E:create_entity(this.leaves_t)

		leaves.pos = V.vclone(this.pos)
		simulation:queue_insert_entity(leaves)

		U.y_animation_play(this, "in_healing", nil, store.tick_ts, 1)
		U.y_animation_play(this, "loop_healing", nil, store.tick_ts, this.cast_loops)

		leaves._stop = true

		U.y_animation_play(this, this.animation_out_healing, nil, store.tick_ts, 1)
		U.y_animation_play(this, "death", nil, store.tick_ts, 1)
		simulation:queue_remove_entity(this)
	end
	tt.cast_loops = 1
	tt.leaves_t = "decal_power_regeneration_circle_leaves"
	tt.animation_out_healing = "out_healing"

	local function register_druid(name, base)
		local tt = E:register_t(name, base or "soldier_militia")

		if not base then
			E:add_comps(tt, "nav_grid", "reinforcement")
		end

		tt.reinforcement.fade = false
		tt.controable = true
		tt.controable_other = true
		tt.circle_margin = 8
		tt.health.hp_max = 200
		tt.health.hp = 200
		tt.health.armor = 0
		tt.health.magic_armor = 0
		tt.health.dead_lifetime = 2
		tt.health_bar.offset = v(0, 52)
		tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
		tt.idle_flip.chance = 0
		tt.info.fn = scripts.soldier_reinforcement.get_info
		tt.info.i18n_key = "POWER_REGENERATION_CIRCLE_SOLDIER"
		tt.info.random_name_format = nil
		tt.info.portrait = "kr6_info_portraits_soldiers_0070"
		tt.main_script.insert = function(this, store)
			this.melee.order = U.attack_order(this.melee.attacks)

			return true
		end
		tt.main_script.update = function(this, store)
			local brk, sta
			local vis_bans = this.vis.bans

			U.bans_add(this.vis, F_ALL)

			U.y_animation_play(this, "in", nil, store.tick_ts, 1)

			if this.cast_loops > 0 then
				local leaves = E:create_entity(this.leaves_t)

				leaves.pos = V.vclone(this.pos)
				simulation:queue_insert_entity(leaves)

				U.y_animation_play(this, "in_healing", nil, store.tick_ts, 1)
				U.y_animation_play(this, "loop_healing", nil, store.tick_ts, this.cast_loops)

				leaves._stop = true

				U.y_animation_play(this, this.animation_out_healing, nil, store.tick_ts, 1)
			end

			U.bans_remove(this.vis, F_ALL)
			U.bans_add(this.vis, vis_bans)

			U.animation_start(this, "idle", nil, store.tick_ts, true)

			while true do
				local circle = store.entities[this._circle_id]
				local ended = not circle or circle._ended

				if this.health.dead or ended then
					U.flags_add(this.vis, F_FRIEND)
					U.unblock_target(store, this)

					this.health.hp = 0

					U.y_animation_play(this, "death", nil, store.tick_ts, 1)
					simulation:queue_remove_entity(this)

					return
				end

				if this.unit.is_stunned then
					SU.soldier_idle(store, this)
				else
					while this.nav_rally.new do
						local rr = this.nav_rally
						local c = this._circle_pos
						local max_r = this._circle_radius - this.circle_margin
						local dx, dy = rr.center.x - c.x, rr.center.y - c.y
						local d = math.sqrt(dx * dx + (dy / 0.7) ^ 2)

						if max_r < d then
							dx, dy = dx * max_r / d, dy * max_r / d
						end

						rr.pos = v(c.x + dx, c.y + dy)
						rr.center = V.vclone(rr.pos)

						if SU.y_soldier_new_rally(store, this) then
							break
						end
					end

					this.nav_rally.center = this._circle_pos
					brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

					if not this.nav_rally.new then
						this.nav_rally.center = V.vclone(this.nav_rally.pos)
					end

					if not (brk or sta ~= A_NO_TARGET) and not SU.soldier_go_back_step(store, this) then
						SU.soldier_idle(store, this)
					end
				end

				coroutine.yield()
			end
		end
		tt.main_script.remove = nil
		tt.melee.attacks[1].animation = "attack"
		tt.melee.attacks[1].cooldown = 1.5
		tt.melee.attacks[1].damage_min = 18
		tt.melee.attacks[1].damage_max = 28
		tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
		tt.melee.attacks[1].hit_time = fts(12)
		tt.melee.attacks[1].hit_offset = v(35, 0)
		tt.melee.range = 90
		tt.motion.max_speed = 50
		tt.regen.health = 0
		tt.render.sprites[1] = E:clone_c("sprite")
		tt.render.sprites[1].prefix = "regeneration_circle_druid_lvl2Def"
		tt.render.sprites[1].name = "idle"
		tt.render.sprites[1].exo = true
		tt.render.sprites[1].angles = {}
		tt.render.sprites[1].angles.walk = {"walk"}
		tt.soldier.melee_slot_offset = v(20, 0)
		tt.ui.click_rect = r(-20, -5, 40, 50)
		tt.unit.hit_offset = v(0, 18)
		tt.unit.mod_offset = v(0, 20)
		tt.unit.size = UNIT_SIZE_MEDIUM
		tt.unit.fade_time_after_death = nil
		tt.vis.flags = bor(F_BLOCK, F_FRIEND)
		tt.vis.bans = bor(F_LYCAN, F_EAT, F_NET, F_DISINTEGRATED)
		tt.cast_loops = 1
		tt.leaves_t = "decal_power_regeneration_circle_leaves"
		tt.animation_out_healing = "out"

		return tt
	end

	register_druid("soldier_power_regeneration_circle_druid_lvl2")

	local archdruid = register_druid("soldier_power_regeneration_circle_druid_lvl3", "soldier_power_regeneration_circle_druid_lvl2")
	archdruid.health.hp_max = 400
	archdruid.health.hp = 400
	archdruid.melee.attacks[1].cooldown = 1.5
	archdruid.melee.attacks[1].damage_min = 36
	archdruid.melee.attacks[1].damage_max = 56
	archdruid.melee.attacks[1].damage_type = DAMAGE_MAGICAL
	archdruid.melee.attacks[1].hit_time = fts(16)
	archdruid.melee.attacks[1].hit_aura = "aura_power_regeneration_circle_druid_hit"
	archdruid.melee.attacks[1].hit_decal = "fx_power_regeneration_circle_druid_hit_ring"
	archdruid.melee.attacks[1].sound = nil
	archdruid.melee.attacks[1].sound_hit = "PowersRegenerationCircleDruidHit"
	archdruid.render.sprites[1].prefix = "regeneration_circle_druid_lvl3Def"
	archdruid.info.portrait = "kr6_info_portraits_soldiers_0071"
	archdruid.cast_loops = 0

	tt = E:register_t("aura_power_regeneration_circle_druid_hit", "aura")
	tt.main_script.insert = function(this, store)
		local druid = store.entities[this.aura.source_id]
		local circle = druid and store.entities[druid._circle_id]

		if circle and not circle._ended then
			circle._druid_hit = true
		end

		return false
	end

	tt = E:register_t("mod_power_regeneration_circle_heal", "modifier")
	E:add_comps(tt, "hps", "render")
	tt.hps.heal_every = 0.25
	tt.hps.heal_min = 4
	tt.hps.heal_max = 4
	tt.main_script.insert = scripts.mod_hps.insert
	tt.main_script.update = scripts.mod_hps.update
	tt.modifier.duration = 0.5
	tt.modifier.resets_same = true
	tt.render.sprites[1].prefix = "regeneration_circle_heal_fxDef"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t("mod_power_regeneration_circle_druid_hit_heal", "modifier")
	E:add_comps(tt, "render")
	tt.heal_hp = 35
	tt.main_script.insert = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if not target or not target.health or target.health.dead then
			return false
		end

		local h = target.health
		local hp_start = h.hp

		h.hp = km.clamp(0, h.hp_max, h.hp + this.heal_hp)

		signal.emit("entity-healed", this, target, h.hp - hp_start)

		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end

		return true
	end
	tt.main_script.update = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if target then
			this.pos = target.pos
		end

		U.y_animation_play(this, nil, nil, store.tick_ts, 1)
		simulation:queue_remove_entity(this)
	end
	tt.modifier.allows_duplicates = true
	tt.modifier.use_mod_offset = false
	tt.render.sprites[1].prefix = "regeneration_circle_druid_heal_hitfxDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].loop = false
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -1

	tt = E:register_t("mod_power_regeneration_circle_slow", "mod_slow")
	tt.slow.factor = 0.75
	tt.modifier.duration = 0.5

	tt = E:register_t("mod_power_regeneration_circle_invulnerability", "modifier")
	E:add_comps(tt, "render")
	tt.modifier.duration = 3
	tt.main_script.insert = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if not target or not target.health or target.health.dead then
			return false
		end

		target.health.ignore_damage = true
		this._active = true
		this.render.sprites[1].ts = store.tick_ts

		return true
	end
	tt.main_script.update = function(this, store)
		local m = this.modifier

		m.ts = store.tick_ts

		local target = store.entities[m.target_id]

		if not target then
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = target.pos

		local s = this.render.sprites[1]

		while store.tick_ts - m.ts < m.duration do
			target = store.entities[m.target_id]

			if not target or target.health.dead then
				simulation:queue_remove_entity(this)

				return
			end

			if target.unit and target.unit.mod_offset then
				local flip_sign = target.render and target.render.sprites[1].flip_x and -1 or 1

				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
			end

			coroutine.yield()
		end

		simulation:queue_remove_entity(this)
	end
	tt.main_script.remove = function(this, store)
		local target = store.entities[this.modifier.target_id]

		if this._active and target and target.health then
			target.health.ignore_damage = false
		end

		this._active = false

		return true
	end
	tt.render.sprites[1].prefix = "regeneration_circle_druid_skill_5a_buffDef"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t("fx_power_regeneration_circle_druid_hit_ring", "fx")
	tt.render.sprites[1].prefix = "regeneration_circle_druid_decal_lvl3_hitDef"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
end

function M.apply(level)
	local E = require("entity_db")
	local ctrl = E:get_template(M.control)
	local circle = E:get_template("decal_power_regeneration_circle")
	local heal = E:get_template("mod_power_regeneration_circle_heal")
	local slow = E:get_template("mod_power_regeneration_circle_slow")
	local invulnerability = E:get_template("mod_power_regeneration_circle_invulnerability")

	ctrl.cooldown = 24
	circle.duration = 10
	circle.radius = 90
	circle.cycle_time = 0.25
	circle.max_targets = 5
	circle.druid_t = "decal_power_regeneration_circle_druid_lvl1"
	circle.l4a_active = false
	circle.l4b_active = false
	circle.l5a_active = false
	circle.l5b_active = false
	heal.hps.heal_every = 0.25
	heal.hps.heal_min = 4
	heal.hps.heal_max = 4
	slow.slow.factor = 0.75
	slow.modifier.duration = 0.5
	invulnerability.modifier.duration = 3

	if level >= 2 then
		heal.hps.heal_min = 5.5
		heal.hps.heal_max = 5.5
		circle.max_targets = 10
	end

	if level >= 3 then
		circle.druid_t = "soldier_power_regeneration_circle_druid_lvl2"
	end

	if level >= 4 then
		circle.l4a_active = true
		circle.l4b_active = true
	end

	if level >= 5 then
		circle.l5a_active = true
		circle.l5b_active = true
	end

	if level >= 6 then
		circle.druid_t = "soldier_power_regeneration_circle_druid_lvl3"
	end
end

return M
