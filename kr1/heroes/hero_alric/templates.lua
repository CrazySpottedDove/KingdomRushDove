local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local km = require("lib.klua.macros")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_regen = HU.update_regen
local update_hp = HU.update_hp

local function soldier_sand_warrior_get_info(this)
	local t = scripts.soldier_barrack.get_info(this)

	t.respawn = nil

	return t
end

local function soldier_sand_warrior_insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.health.hp_max = this.health.hp_max + this.health.hp_inc * this.unit.level

	local node_offset = math.random(3, 6)

	this.nav_path.ni = this.nav_path.ni + node_offset
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not this.pos then
		return false
	end

	return true
end

local function soldier_sand_warrior_update(this, store)
	local attack = this.melee.attacks[1]
	local target
	local expired = false
	local next_pos = V.vclone(this.pos)
	local brk, sta, nearest

	this.lifespan.ts = store.tick_ts

	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	while true do
		if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
			this.health.hp = 0

			if not U.flag_has(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_DISINTEGRATE)) then
				local s = E:create_entity("decal_alric_soul_ball")

				s.target_id = this.owner_id
				s.source_id = this.id
				s.source_hp = this.health.hp_max

				simulation:queue_insert_entity(s)
			end

			SU.y_soldier_death(store, this)
			simulation:queue_remove_entity(this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		else
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

				if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
					this.nav_path.ni = nearest[1][3]
				end

				U.y_animation_play(this, "start_walk", nil, store.tick_ts, 1)

				while next_pos and not target and not this.health.dead and not expired and not this.unit.is_stunned do
					U.set_destination(this, next_pos)

					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

					U.animation_start_default(this, an, af, store.tick_ts, true)
					U.walk_off__accel__unsnapped(this, store.tick_length)
					coroutine.yield()

					target = U.find_foremost_enemy_in_range_filter_off(this.pos, this.melee.range, false, attack.vis_flags, attack.vis_bans)
					expired = store.tick_ts - this.lifespan.ts > this.lifespan.duration
					next_pos = P:next_entity_node(this, store.tick_length)

					if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) then
						next_pos = nil
					end
				end

				target = nil

				if expired or this.health.dead or not next_pos then
					this.health.hp = 0

					U.y_animation_play(this, "death_travel", nil, store.tick_ts, 1)
					simulation:queue_remove_entity(this)
				end
			end
		end

		coroutine.yield()
	end
end

-- 阿尔里奇
local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	upgrade_skill(this, "swordsmanship", function(this, s)
		this.swordsmanship_extra = s.extra_damage[s.level]
	end)
	upgrade_skill(this, "spikedarmor", function(this, s)
		this.health.spiked_armor = this.health.spiked_armor + s.values[s.level]
	end)
	upgrade_skill(this, "toughness", function(this, s)
		this.toughness_hp_extra = s.hp_max[s.level]
	end)
	upgrade_skill(this, "flurry", function(this, s)
		this.melee.attacks[3].disabled = nil
		this.melee.attacks[3].cooldown = s.cooldown[s.level]
		this.melee.attacks[3].loops = s.loops[s.level]
	end)
	upgrade_skill(this, "sandwarriors", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template(this.timed_attacks.list[1].entity)

		e.lifespan.duration = s.lifespan[s.level]
	end)

	for i = 1, 3 do
		this.melee.attacks[i].damage_min = ls.melee_damage_min[hl] + this.swordsmanship_extra
		this.melee.attacks[i].damage_max = ls.melee_damage_max[hl] + this.swordsmanship_extra
	end

	this.health.hp_max = this.health.hp_max + this.toughness_hp_extra

	update_regen(this)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local swa = this.timed_attacks.list[1]
	local sws = this.hero.skills.sandwarriors
	local brk, sta

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_289_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(swa, store, this.unit.cooldown_factor) then
				local target_info = U.find_enemies_in_paths(store.enemies, this.pos, 0, swa.range_nodes, nil, swa.vis_flags, swa.vis_bans, true)

				if target_info then
					local origin = target_info[1].origin
					local start_ts = store.tick_ts

					S:queue(swa.sound)
					U.animation_start_default(this, swa.animation, nil, store.tick_ts, false)

					while store.tick_ts - start_ts < swa.spawn_time do
						if this.nav_rally.new then
							goto label_289_0
						end

						if this.health.dead then
							goto label_289_0
						end

						if this.unit.is_stunned then
							goto label_289_0
						end

						coroutine.yield()
					end

					swa.ts = start_ts

					SU.hero_gain_xp_from_skill(this, sws)

					for i = 1, sws.count[sws.level] do
						local spawn = E:create_entity(swa.entity)

						spawn.nav_path.pi = origin[1]
						spawn.nav_path.spi = km.zmod(i, 3)
						spawn.nav_path.ni = origin[3]
						spawn.unit.level = sws.level
						spawn.owner_id = this.id

						simulation:queue_insert_entity(spawn)
					end

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_289_0
						end

						if this.health.dead then
							goto label_289_0
						end

						if this.unit.is_stunned then
							goto label_289_0
						end

						coroutine.yield()
					end
				else
					swa.ts = store.tick_ts + 0.2
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_289_0::

		coroutine.yield()
	end
end

-- 博林-地雷
-- 迪纳斯-火球
-- 兽王-恢复
local tt

tt = RT("hero_alric", "hero")

AC(tt, "melee", "timed_attacks", "transfer")

tt.hero.level_stats.armor = {0.38, 0.41, 0.44, 0.47, 0.5, 0.53, 0.56, 0.59, 0.62, 0.65}
tt.hero.level_stats.hp_max = {260, 275, 290, 305, 320, 335, 350, 365, 380, 395}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 18, 20, 22, 24, 26, 28, 30}
tt.hero.level_stats.melee_damage_min = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
tt.hero.skills.flurry = CC("hero_skill")
tt.hero.skills.flurry.cooldown = {6, 6, 6}
tt.hero.skills.flurry.loops = {2, 3, 4}
tt.hero.skills.flurry.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.flurry.xp_gain = {45, 70, 95}
tt.hero.skills.sandwarriors = CC("hero_skill")
tt.hero.skills.sandwarriors.count = {2, 3, 4}
tt.hero.skills.sandwarriors.lifespan = {7, 8, 9}
tt.hero.skills.sandwarriors.xp_gain = {50, 75, 100}
tt.hero.skills.sandwarriors.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.spikedarmor = CC("hero_skill")
tt.hero.skills.spikedarmor.values = {0.2, 0.2, 0.2}
tt.hero.skills.spikedarmor.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.swordsmanship = CC("hero_skill")
tt.hero.skills.swordsmanship.extra_damage = {6, 12, 18}
tt.hero.skills.swordsmanship.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.toughness = CC("hero_skill")
tt.hero.skills.toughness.hp_max = {90, 180, 270}
tt.hero.skills.toughness.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 35.9)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0001"
tt.info.portrait = "kr2_info_portraits_heroes_0001"
tt.main_script.update = hero_update
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].xp_gain_factor = 5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {"flurry_start", "flurry_loop", "flurry_end"}
tt.melee.attacks[3].cooldown = 6
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_times = {fts(4), fts(9)}
tt.melee.attacks[3].interrupt_loop_on_dead_target = true
tt.melee.attacks[3].loopable = true
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].sound_loop = "HeroAlricFlurry"
tt.melee.attacks[3].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].xp_from_skill = "flurry"
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.cooldown = 1
tt.melee.range = 80
tt.motion.max_speed = 90
tt.transfer.extra_speed = 60
tt.transfer.min_distance = 90
tt.transfer.sound_loop = "HeroAlricSandwarrior"
tt.transfer.animations = {"sand_travel_start", "sand_travel_loop", "sand_travel_end"}
tt.transfer.scale = vec_1(1.2)
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = 0.09
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_alric"
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[1].color = {255, 255, 255}
tt.soldier.melee_slot_offset.x = 5
tt.sound_events.change_rally_point = "HeroAlricTaunt"
tt.sound_events.death = "HeroAlricDeath"
tt.sound_events.respawn = "HeroAlricTauntIntro"
tt.sound_events.insert = "HeroAlricTauntIntro"
tt.sound_events.hero_room_select = "HeroAlricTauntSelect"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "sandwarrior"
tt.timed_attacks.list[1].cooldown = 10
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_sand_warrior"
tt.timed_attacks.list[1].range_nodes = 40
tt.timed_attacks.list[1].spawn_time = fts(10)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.timed_attacks.list[1].sound = "HeroAlricSandwarrior"
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.swordsmanship_extra = 0
tt.toughness_hp_extra = 0
tt.toughness_regen_extra = 0
tt = RT("soldier_sand_warrior", "unit")

AC(tt, "soldier", "motion", "nav_path", "main_script", "vis", "info", "lifespan", "melee", "sound_events")

tt.info.portrait = "kr2_info_portraits_soldiers_0015"
tt.health.hp_inc = 40
tt.health.hp_max = 20
tt.health_bar.offset = vec_2(0, 31.8)
tt.info.fn = soldier_sand_warrior_get_info
tt.lifespan.duration = nil
tt.main_script.insert = soldier_sand_warrior_insert
tt.main_script.update = soldier_sand_warrior_update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(4)
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.range = 64
tt.motion.max_speed = 60
tt.nav_path.dir = -1
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_sand_warrior"
tt.soldier.melee_slot_offset.x = 5
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 14.8)
tt.vis.bans = bor(F_POISON, F_CANNIBALIZE, F_LYCAN, F_SKELETON)
tt.vis.flags = F_FRIEND
tt = RT("decal_alric_soul_ball", "decal_regson_heal_ball")
tt.render.sprites[1].color = {255, 122, 0}
tt.hp_factor = 0.1
tt.fx_spawn = "fx_alric_soul_ball_spawn"
tt.fx_receive = "fx_alric_receive_soul"
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
tt.render.sprites[2].scale = vec_1(0.9)
tt.side_effect = function(hero, store)
	local cool_next = hero.melee.attacks[3].cooldown * hero.unit.cooldown_factor - (hero.melee.attacks[3].ts - store.tick_ts)

	if cool_next > 0 then
		hero.melee.attacks[3].ts = hero.melee.attacks[3].ts - cool_next * 0.1
	end
end
tt = RT("fx_alric_soul_ball_spawn", "fx_regson_heal_ball_spawn")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
tt = RT("fx_alric_receive_soul", "fx_regson_heal")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
