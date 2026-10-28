local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this, store)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "ring", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "giant", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.scale = s.scale[s.level]
	end)
	upgrade_skill(this, "dwarfsoldier", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local brk, sta
	local ring = this.melee.attacks[2]

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local pow_dwarf = this.hero.skills.dwarfsoldier
	local a

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_467_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				if U.find_first_enemy_in_range_filter_off(this.pos, 120, F_BLOCK, bor(F_FLYING, F_CLIFF, F_WATER)) ~= nil then
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 1
					else
						U.animation_start_default(this, a.animation, nil, store.tick_ts)
						S:queue(a.sound)
						SU.hero_gain_xp_from_skill(this, a)

						a.ts = store.tick_ts

						local pi, _, ni = unpack(nodes[1])

						for i = 1, a.count do
							local new_soldier = E:create_entity(a.entity)
							local e_spi, e_ni = math.random(1, 3), ni
							local no = math.random(2, 4) * U.random_sign()

							if P:is_node_valid(pi, e_ni + no) then
								e_ni = e_ni + no
							end

							new_soldier.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
							new_soldier.nav_rally.pos = V.vclone(new_soldier.nav_rally.center)
							new_soldier.pos = V.vclone(new_soldier.nav_rally.center)
							new_soldier.owner = this

							for k, p in pairs(new_soldier.powers) do
								p.level = math.min(pow_dwarf.level, E:get_template("tower_barrack_dwarf").powers[k].max_level)
							end

							simulation:queue_insert_entity(new_soldier)
						end
					end

					SU.y_hero_animation_wait(this)

					goto label_467_0
				else
					a.ts = a.ts + 1
				end
			end

			a = this.timed_attacks.list[1]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_off(this.pos, ring.damage_radius * a.scale, a.vis_flags, a.vis_bans)
				local bigger_begin_time = store.tick_ts

				if targets and #targets >= a.min_count then
					if targets[1].pos.x < this.pos.x then
						this.render.sprites[1].flip_x = true
					else
						this.render.sprites[1].flip_x = false
					end

					a.ts = store.tick_ts
					this.health.ignore_damage = true
					this.health_bar.hidden = true

					U.animation_start_default(this, a.animations[1], nil, store.tick_ts, true)
					U.heal(this, this.health.hp_max * a.scale * 0.1)

					while store.tick_ts - bigger_begin_time < a.scale_time do
						local rate = (store.tick_ts - bigger_begin_time) / a.scale_time
						local current_scale = 1 + (a.scale - 1) * rate

						this.render.sprites[1].scale.x = current_scale
						this.render.sprites[1].scale.y = current_scale
						this.render.sprites[1].alpha = 255 - 127 * rate

						coroutine.yield()
					end

					this.render.sprites[1].scale.x = a.scale
					this.render.sprites[1].scale.y = a.scale
					this.render.sprites[1].alpha = 128

					U.animation_start_default(this, a.animations[2], nil, store.tick_ts, false)
					S:queue(a.sound)
					U.y_animation_wait_default(this)
					SU.hero_gain_xp_from_skill(this, this.hero.skills.giant)

					local hit_pos = V.vclone(this.pos)

					if this.render.sprites[1].flip_x then
						hit_pos.x = hit_pos.x - ring.hit_offset.x * a.scale
					else
						hit_pos.x = hit_pos.x + ring.hit_offset.x * a.scale
					end

					targets = U.find_enemies_in_range_filter_off(hit_pos, ring.damage_radius * a.scale, a.vis_flags, a.vis_bans)

					if targets then
						for _, target in ipairs(targets) do
							local d = SU.create_attack_damage(ring, target.id, this)

							d.value = d.value * a.scale

							queue_damage(store, d)

							local fx = E:create_entity(ring.hit_fx)

							fx.pos:copy(hit_pos)

							fx.render.sprites[1].ts = store.tick_ts
							fx.render.sprites[1].scale.x = a.scale
							fx.render.sprites[1].scale.y = a.scale

							simulation:queue_insert_entity(fx)

							local decal = E:create_entity(ring.hit_decal)

							decal.pos:copy(hit_pos)

							decal.render.sprites[1].ts = store.tick_ts
							decal.render.sprites[1].scale.x = a.scale * decal.render.sprites[1].scale.x
							decal.render.sprites[1].scale.y = a.scale * decal.render.sprites[1].scale.y

							simulation:queue_insert_entity(decal)

							local mod = E:create_entity(a.mod)

							if band(target.vis.flags, mod.modifier.vis_bans) == 0 and band(target.vis.bans, mod.modifier.vis_flags) == 0 then
								mod.modifier.source_id = this.id
								mod.modifier.target_id = target.id
								mod.modifier.duration = mod.modifier.duration * a.scale

								simulation:queue_insert_entity(mod)
							end
						end
					end

					SU.y_hero_animation_wait(this)
					U.animation_start_default(this, a.animations[3], nil, store.tick_ts, true)

					local smaller_begin_time = store.tick_ts

					while store.tick_ts - smaller_begin_time < a.scale_time do
						local rate = (store.tick_ts - smaller_begin_time) / a.scale_time
						local current_scale = a.scale - (a.scale - 1) * rate

						this.render.sprites[1].scale.x = current_scale
						this.render.sprites[1].scale.y = current_scale
						this.render.sprites[1].alpha = 128 + 127 * rate

						coroutine.yield()
					end

					this.render.sprites[1].scale.x = 1
					this.render.sprites[1].scale.y = 1
					this.render.sprites[1].alpha = 255
					this.health.ignore_damage = false
					this.health_bar.hidden = false
				else
					a.ts = a.ts + 1
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_467_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_467_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_dwarf", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.43, 0.46, 0.49, 0.52, 0.55, 0.58, 0.61, 0.64, 0.67, 0.7}
tt.hero.level_stats.hp_max = {285, 300, 315, 330, 345, 360, 375, 390, 405, 420}
tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 18, 20, 22, 24, 26, 28, 30}
tt.hero.skills.ring = CC("hero_skill")
tt.hero.skills.ring.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ring.damage_min = {60, 80, 100, 120}
tt.hero.skills.ring.damage_max = {80, 100, 120, 140}
tt.hero.skills.giant = CC("hero_skill")
tt.hero.skills.giant.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.giant.scale = {1.5, 2, 2.5}
tt.hero.skills.giant.xp_gain_factor = 150
tt.hero.skills.dwarfsoldier = CC("hero_skill")
tt.hero.skills.dwarfsoldier.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.dwarfsoldier.xp_gain_factor = 100
tt.health.armor = 0.43
tt.health.dead_lifetime = 15
tt.health.hp_max = 420
tt.health_bar.offset = vec_2(0, 37.78)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(60)
tt.hero.fn_level_up = hero_level_up
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0017"
tt.info.portrait = "kr2_info_portraits_heroes_0017"
tt.main_script.update = hero_update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 6
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].cooldown = 8
tt.melee.attacks[2].damage_max = 120
tt.melee.attacks[2].damage_min = 60
tt.melee.attacks[2].damage_radius = 60
tt.melee.attacks[2].damage_type = bor(DAMAGE_TRUE, DAMAGE_FX_EXPLODE)
tt.melee.attacks[2].xp_gain_factor = 1.5
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = "fx_dwarf_area_quake"
tt.melee.attacks[2].hit_fx = "fx_dwarf_area_ring"
tt.melee.attacks[2].hit_offset = vec_2(29, 0)
tt.melee.attacks[2].hit_time = fts(29)
tt.melee.range = 80
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"giant_start", "attack2", "giant_end"}
tt.timed_attacks.list[1].scale_time = fts(10)
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].scale = 1.5
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].vis_flags = F_AREA
tt.timed_attacks.list[1].vis_bans = F_FLYING
tt.timed_attacks.list[1].sound = "HeroReinforcementJump"
tt.timed_attacks.list[1].mod = "mod_dwarf_champion_stun"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "levelup"
tt.timed_attacks.list[2].cooldown = 14
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "soldier_dwarf_reinforcement"
tt.timed_attacks.list[2].sound = "DwarfTaunt"
tt.timed_attacks.list[2].count = 1
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.13
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_dwarf"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].scale = vec_1(1)
tt.soldier.melee_slot_offset.x = 10
tt.sound_events.change_rally_point = "DwarfHeroTaunt"
tt.sound_events.death = "DwarfHeroTauntDeath"
tt.sound_events.respawn = "DwarfHeroTauntIntro"
tt.sound_events.hero_room_select = "DwarfHeroTauntSelect"
tt.unit.marker_offset = vec_2(0, -2)
tt.unit.mod_offset = vec_2(0, 9.78)
tt = RT("soldier_dwarf_reinforcement", "soldier_dwarf")

AC(tt, "reinforcement", "tween", "nav_grid")

tt.controable = true
tt.controable_other = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.disabled = true
tt.reinforcement.duration = 12
tt = RT("fx_dwarf_area_quake", "decal_timed")
tt.render.sprites[1].name = "fx_dwarf_area_quake"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].offset.y = 2
tt.render.sprites[1].scale = vec_2(0.8, 0.8)
tt.render.sprites[1].alpha = 166
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset.y = -22
tt = RT("fx_dwarf_area_ring", "decal_timed")
tt.render.sprites[1].name = "fx_dwarf_area_ring"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].scale = vec_1(1)
tt = RT("mod_dwarf_champion_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
