local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function ice_spike_update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.sprite_idx == 1 then
		this.render.sprites[1].anchor.y = this.spike_1_anchor_y
		this.render.sprites[2].anchor.y = this.spike_1_anchor_y
	end

	if this.delay then
		U.y_wait_unconditional(store, this.delay)
	end

	this.render.sprites[1].hidden = false

	local start_ts = store.tick_ts

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start(this, "start", nil, store.tick_ts, false, 1)
	U.y_wait_unconditional(store, b.hit_time)

	this.render.sprites[2].hidden = false

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = E.assign_damage(b.damage_type, math.random(b.damage_min, b.damage_max), this.id, target.id)

			queue_damage(store, d)
		end
	end

	U.y_wait_unconditional(store, 1)
	S:queue(this.sound_events.ice_break)
	U.y_wait_unconditional(store, b.duration - (store.tick_ts - start_ts))
	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	for i = 1, 2 do
		local bt = E:get_template(this.ranged.attacks[i].bullet)

		bt.bullet.damage_min = ls.ranged_damage_min[hl]
		bt.bullet.damage_max = ls.ranged_damage_max[hl]
	end

	upgrade_skill(this, "chill", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max_range = s.max_range[s.level]
		a.count = s.count[s.level]

		local b = E:get_template(a.bullet)

		b.aura.level = s.level

		local m = E:get_template("mod_elora_chill")

		m.slow.factor = s.slow_factor[s.level]
	end)
	upgrade_skill(this, "ice_storm", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.count = s.count[s.level]
		a.max_range = s.max_range[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local fe = this.render.sprites[2]
	local ps = E:create_entity(this.run_particles_name)

	ps.particle_system.track_id = this.id
	ps.particle_system.emit = false

	simulation:queue_insert_entity(ps)
	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	fe.hidden = true

	while true do
		ps.particle_system.emit = false

		if h.dead then
			fe.hidden = true

			SU.y_hero_death_and_respawn(store, this)
		end

		fe.hidden = false

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				ps.particle_system.emit = true

				if SU.y_hero_new_rally(store, this) then
					goto label_61_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.ice_storm

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.cast_time, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.4
					else
						local s_pi, _, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x
						local start_ts = store.tick_ts

						U.animation_start_default(this, "iceStorm", flip, store.tick_ts)
						S:queue(a.sound)

						if SU.y_soldier_wait(store, this, a.cast_time) then
							goto label_61_0
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -2 or 2

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + a.nodes_offset or ni)

						for i = 1, skill.count[skill.level] do
							local b = E:create_entity(a.bullet)

							b.pos = P:node_pos(pi, spi, ni)
							b.spike_idx = math.random(1, 2)
							b.render.sprites[1].prefix = b.render.sprites[1].prefix .. b.spike_idx
							b.render.sprites[1].flip_x = not flip
							b.render.sprites[2].name = b.render.sprites[2].name .. b.spike_idx
							b.delay = delay
							b.bullet.source_id = this.id
							b.bullet.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(b)

							delay = delay + U.frandom(0.05, 0.1)
							ni = ni + n_step
							spi = km.zmod(spi + 1, 3)
						end

						SU.y_hero_animation_wait(this)

						goto label_61_0
					end
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.chill

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.cast_time, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.4
					else
						local s_pi, _, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x
						local start_ts = store.tick_ts

						U.animation_start_default(this, "chill", flip, store.tick_ts)
						S:queue(a.sound)

						if SU.y_soldier_wait(store, this, a.cast_time) then
							goto label_61_0
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -a.step or a.step

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + a.nodes_offset or ni)

						for i = 1, skill.count[skill.level] do
							local b = E:create_entity(a.bullet)

							b.pos = P:node_pos(pi, spi, ni)
							b.render.sprites[1].prefix = b.render.sprites[1].prefix .. math.random(1, 3)
							b.render.sprites[1].flip_x = not flip
							b.delay = delay

							simulation:queue_insert_entity(b)

							delay = delay + 0.05
							ni = ni + n_step
							spi = km.zmod(spi + 1, 3)
						end

						SU.y_hero_animation_wait(this)

						goto label_61_0
					end
				end
			end

			if this.soldier.target_id then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_61_0
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				goto label_61_0
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
				goto label_61_0
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_61_0
			end

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_61_0::

		coroutine.yield()
	end
end

local tt

tt = RT("ps_elora_run")
AC(tt, "pos", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_elora_run"

tt = RT("fx_bolt_elora_hit", "fx")
tt.render.sprites[1].prefix = "fx_bolt_elora"
tt.render.sprites[1].name = "hit"

tt = RT("hero_elora", "hero")
AC(tt, "melee", "ranged", "timed_attacks")
tt.hero.level_stats.armor = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5}
tt.hero.level_stats.hp_max = {270, 290, 310, 330, 350, 370, 390, 410, 430, 450}
tt.hero.level_stats.melee_damage_max = {2, 4, 6, 8, 11, 13, 16, 18, 20, 23}
tt.hero.level_stats.melee_damage_min = {1, 2, 4, 6, 7, 9, 10, 12, 14, 15}
tt.hero.level_stats.ranged_damage_max = {41, 47, 54, 61, 68, 74, 81, 88, 95, 101}
tt.hero.level_stats.ranged_damage_min = {18, 20, 23, 25, 27, 29, 32, 34, 36, 38}
tt.hero.skills.chill = CC("hero_skill")
tt.hero.skills.chill.slow_factor = {0.4, 0.3, 0.2}
tt.hero.skills.chill.max_range = {153.6, 166.4, 179.2}
tt.hero.skills.chill.count = {6, 8, 10}
tt.hero.skills.chill.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.chill.xp_gain = {125, 250, 375}
tt.hero.skills.ice_storm = CC("hero_skill")
tt.hero.skills.ice_storm.count = {3, 5, 8}
tt.hero.skills.ice_storm.damage_max = {40, 50, 60}
tt.hero.skills.ice_storm.damage_min = {20, 20, 30}
tt.hero.skills.ice_storm.max_range = {154, 167, 180}
tt.hero.skills.ice_storm.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.ice_storm.xp_gain = {100, 200, 300}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0008"
tt.info.portrait = "info_portraits_heroes_0008"
tt.main_script.update = hero_update
tt.motion.max_speed = 3.5 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.17)
tt.render.sprites[1].prefix = "hero_elora"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_elora_frostEffect"
tt.render.sprites[2].anchor = vec_2(0.5, 0.1)
tt.render.sprites[2].hidden = true
tt.render.sprites[2].ignore_start = true
tt.run_particles_name = "ps_elora_run"
tt.soldier.melee_slot_offset = vec_2(12, 0)
tt.sound_events.change_rally_point = "HeroFrostTaunt"
tt.sound_events.death = "HeroFrostDeath"
tt.sound_events.hero_room_select = "HeroFrostTauntSelect"
tt.sound_events.insert = "HeroFrostTauntIntro"
tt.sound_events.respawn = "HeroFrostTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.range = 45
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = fts(40)
tt.ranged.attacks[1].bullet = "bolt_elora_freeze"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(18, 36)}
tt.ranged.attacks[1].chance = 0.27
tt.ranged.attacks[1].min_range = 23.04
tt.ranged.attacks[1].max_range = 166.4
tt.ranged.attacks[1].shoot_time = fts(19)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].vis_bans = bor(F_BOSS)
tt.ranged.attacks[1].xp_gain_factor = 2
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bolt_elora_slow"
tt.ranged.attacks[2].chance = 1
tt.ranged.attacks[2].vis_bans = 0
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "iceStorm"
tt.timed_attacks.list[1].bullet = "elora_ice_spike"
tt.timed_attacks.list[1].cast_time = fts(24)
tt.timed_attacks.list[1].cooldown = 10 + fts(30)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].nodes_offset = 4
tt.timed_attacks.list[1].sound = "HeroFrostIceRainSummon"
tt.timed_attacks.list[1].vis_bans = F_FRIEND
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].xp_from_skill = "ice_storm"
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].animation = "chill"
tt.timed_attacks.list[2].bullet = "aura_chill_elora"
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].cooldown = 8 + fts(20)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].sound = "HeroFrostGroundFreeze"
tt.timed_attacks.list[2].step = 3
tt.timed_attacks.list[2].nodes_offset = 6
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[2].vis_flags = F_RANGED
tt.timed_attacks.list[2].xp_from_skill = "chill"

tt = RT("bolt_elora_freeze", "bolt")
tt.render.sprites[1].prefix = "bolt_elora"
tt.bullet.hit_fx = "fx_bolt_elora_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.mod = "mod_elora_bolt_freeze"
tt.bullet.damage_min = 14
tt.bullet.damage_max = 41
tt.bullet.xp_gain_factor = 2

tt = RT("bolt_elora_slow", "bolt_elora_freeze")
tt.bullet.mod = "mod_elora_bolt_slow"

tt = RT("mod_elora_bolt_freeze", "mod_freeze")
AC(tt, "render")
tt.modifier.duration = 2
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.custom_offsets = {
	flying = vec_2(-5, 32)
}
tt.custom_suffixes = {
	flying = "_air"
}
tt.custom_animations = {"start", "end"}

tt = RT("mod_elora_bolt_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.45

tt = RT("aura_chill_elora", "aura")
AC(tt, "render", "tween")
tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.mod = "mod_elora_chill"
tt.aura.radius = 44.800000000000004
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_chill_elora.update
tt.render.sprites[1].prefix = "decal_elora_chill_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.2, 0}}

tt = RT("mod_elora_chill", "mod_slow")
tt.modifier.duration = fts(11)
tt.slow.factor = 0.8

tt = RT("elora_ice_spike", "bullet")
tt.main_script.update = ice_spike_update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 51.2
tt.bullet.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.hit_time = 0.1
tt.bullet.duration = 2
tt.spike_1_anchor_y = 0.16
tt.render.sprites[1].prefix = "elora_ice_spike_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = 0.2
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_frost_spikes_decal"
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.delayed_insert = "HeroFrostIceRainDrop"
tt.sound_events.ice_break = "HeroFrostIceRainBreak"

