local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function decal_torment_sword_update(this, store)
	local sword_name = table.random(this.sword_names)

	this.render.sprites[1].prefix = sword_name
	this.render.sprites[1].hidden = true

	U.y_wait_unconditional(store, this.delay)

	this.render.sprites[1].hidden = false

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.y_wait_unconditional(store, this.duration)
	U.y_animation_play(this, "out", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

local function aura_rage_update(this, store)
	local hero = store.entities[this.aura.source_id]

	this.pos = hero.pos

	local s = this.render.sprites[1]

	while true do
		local scale = 0
		local rate = hero.health.hp / hero.health.hp_max

		if rate < 0.2 then
			scale = 1
		elseif rate < 0.4 then
			scale = 0.7
		elseif rate < 0.6 then
			scale = 0.4
		elseif rate < 0.8 then
			scale = 0.1
		end

		if hero.health.dead then
			scale = 0
		end

		if scale ~= s.scale.x then
			s.ts = store.tick_ts
			s.scale.x, s.scale.y = scale, scale
		end

		s.hidden = scale == 0

		coroutine.yield()
	end
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	local e = E:create_entity("aura_oni_rage")

	e.aura.source_id = this.id

	simulation:queue_insert_entity(e)

	return true
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "death_strike", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.chance = s.chance[s.level]
		a = this.melee.attacks[3]
		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
	end)
	upgrade_skill(this, "torment", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage_min = s.min_damage[s.level]
		a.damage_max = s.max_damage[s.level]
	end)
	upgrade_skill(this, "rage", function(this, s)
		this.rage_max = s.rage_max[s.level]
		this.unyield_max = s.unyield_max[s.level]
	end)
	update_hp(this)
end

local function hero_on_damage(this, store, damage)
	if this.timed_attacks.list[1].ts then
		this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 1
	end

	if this.melee.attacks[2].ts then
		this.melee.attacks[2].ts = this.melee.attacks[2].ts - 0.5
	end

	if this.melee.attacks[3].ts then
		this.melee.attacks[3].ts = this.melee.attacks[3].ts - 0.5
	end

	if this.melee.attacks[1].ts then
		this.melee.attacks[1].ts = this.melee.attacks[1].ts - 0.5
	end

	return true
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function spawn_swords(count, center, radius, angle, delay)
		for i = 1, count do
			local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
			local e = E:create_entity("decal_oni_torment_sword")

			e.pos.x, e.pos.y = p.x, p.y
			e.delay = delay

			simulation:queue_insert_entity(e)
		end
	end

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		local rate = (this.health.hp_max - this.health.hp) / this.health.hp_max
		local rage = rate * this.rage_max

		this.unit.damage_buff = this.unit.damage_buff - this.rage + rage
		this.rage = rage

		local unyield = rate * this.unyield_max

		SU.insert_received_damage_factor_buff(this, unyield - this.unyield)

		this.unyield = unyield

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_83_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.torment

			if not a.disabled and store.tick_ts - a.ts > a.cooldown then
				local triggers = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not triggers or #triggers < a.min_count then
					a.ts = a.ts + 0.13333333333333333
				else
					local start_ts = store.tick_ts
					local af = triggers[1].pos.x < this.pos.x

					U.animation_start_default(this, a.animation, af, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
						goto label_83_0
					end

					S:queue(a.sound_hit)

					a.ts = start_ts

					local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans)

					if not targets then
						a.ts = a.ts + 0.13333333333333333
					else
						SU.hero_gain_xp_from_skill(this, skill)

						local hit_center = V.vclone(this.pos)

						for _, s in ipairs(a.torment_swords) do
							local d, r, c = unpack(s)

							spawn_swords(c, hit_center, r, math.random(0, 2) * math.pi, d)
						end

						U.y_wait_unconditional(store, a.damage_delay)

						for _, target in ipairs(targets) do
							local d = SU.create_attack_damage(a, target.id, this)

							if target.is_demon then
								d.value = d.value * 1.6
							end

							queue_damage(store, d)
						end

						SU.y_hero_animation_wait(this)

						goto label_83_0
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if sta == A_IN_COOLDOWN then
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			end

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_83_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_oni", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.32, 0.35, 0.38, 0.41, 0.45, 0.48, 0.51, 0.54, 0.57, 0.6}
tt.hero.level_stats.hp_max = {425, 450, 475, 500, 525, 550, 575, 600, 625, 650}
tt.hero.level_stats.melee_damage_max = {22, 23, 25, 27, 28, 30, 32, 34, 36, 38}
tt.hero.level_stats.melee_damage_min = {9, 9, 10, 10, 11, 22, 12, 13, 13, 14}
tt.hero.skills.rage = CC("hero_skill")
tt.hero.skills.rage.rage_max = {49, 61, 73, 81}
tt.hero.skills.rage.unyield_max = {0.35, 0.4, 0.45, 0.5}
tt.hero.skills.rage.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.death_strike = CC("hero_skill")
tt.hero.skills.death_strike.chance = {0.1, 0.15, 0.2}
tt.hero.skills.death_strike.damage = {180, 260, 340}
tt.hero.skills.death_strike.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.death_strike.xp_gain = {100, 150, 200}
tt.hero.skills.torment = CC("hero_skill")
tt.hero.skills.torment.min_damage = {50, 80, 110}
tt.hero.skills.torment.max_damage = {80, 110, 140}
tt.hero.skills.torment.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.torment.xp_gain = {100, 150, 200}
tt.health.dead_lifetime = 15
tt.health.on_damage = hero_on_damage
tt.health_bar.offset = vec_2(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.hero_portrait = "hero_portraits_0011"
tt.info.portrait = "info_portraits_heroes_0011"
tt.melee.range = 65
tt.main_script.update = hero_update
tt.main_script.insert = hero_insert
tt.motion.max_speed = 3.2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "hero_oni"
tt.render.sprites[1].anchor = vec_2(0.5, 0.14285714285714285)
tt.soldier.melee_slot_offset = vec_2(8, 0)
tt.sound_events.change_rally_point = "HeroSamuraiTaunt"
tt.sound_events.death = "HeroSamuraiDeath"
tt.sound_events.hero_room_select = "HeroSamuraiTauntSelect"
tt.sound_events.insert = "HeroSamuraiTauntIntro"
tt.sound_events.respawn = "HeroSamuraiTauntIntro"
tt.unit.hit_offset = vec_2(0, 21)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.pop_offset = vec_2(0, 10)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_times = {fts(7), fts(15)}
tt.melee.attacks[1].xp_gain_factor = 2.4
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].animations = {nil, "attack"}
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "deathStrike"
tt.melee.attacks[2].chance = 0.15
tt.melee.attacks[2].cooldown = 9 + fts(48)
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_min = 180
tt.melee.attacks[2].damage_max = 180
tt.melee.attacks[2].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_INSTAKILL)
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].pop = {"pop_splat"}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroSamuraiDeathStrike"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].xp_from_skill = "death_strike"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].chance = 1
tt.melee.attacks[3].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.melee.attacks[3].pop = {"pop_sok", "pop_pow"}
tt.melee.attacks[3].pop_chance = 0.1
tt.melee.attacks[3].vis_flags = F_RANGED
tt.melee.attacks[3].vis_bans = 0
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "torment"
tt.timed_attacks.list[1].cooldown = 18 + fts(68)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].damage_min = 50
tt.timed_attacks.list[1].damage_max = 80
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_NO_DODGE, DAMAGE_TRUE)
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].max_range = 120
tt.timed_attacks.list[1].damage_radius = 120
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].damage_delay = 0.15
tt.timed_attacks.list[1].sound_hit = "HeroSamuraiTorment"
tt.timed_attacks.list[1].torment_swords = {{0.01, 20, 8}, {0.2, 37.5, 8}, {0.3, 55, 8}}
tt.rage = 0
tt.rage_max = 0
tt.unyield = 0
tt.unyield_max = 0
tt = RT("aura_oni_rage", "aura")

AC(tt, "render", "tween")

tt.aura.duration = -1
tt.aura.track_source = true
tt.main_script.update = aura_rage_update
tt.render.sprites[1].name = "giant_bastion_decal"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].scale = vec_2(0, 0)
tt.render.sprites[1].anchor.y = 0.19117647058823528
tt.render.sprites[1].color = {255, 100, 100}
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = RT("decal_oni_torment_sword", "decal_scripted")
tt.render.sprites[1].prefix = "decal_oni_torment_sword_1"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.main_script.update = decal_torment_sword_update
tt.duration = 0.5
tt.delay = 0.01
tt.sword_names = {"decal_oni_torment_sword_1", "decal_oni_torment_sword_2", "decal_oni_torment_sword_3", "decal_oni_torment_sword_1"}
