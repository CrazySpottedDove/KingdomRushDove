local bit = require("bit")
local E = require("entity_db")
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
local v = V.v

local function ray_thor_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = b.to

	s.scale = v(1, 1)

	local function update_sprite()
		if target and target.motion then
			dest.x, dest.y = target.pos.x, target.pos.y

			if target.unit and target.unit.hit_offset then
				dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		s.scale.y = 0.4 + km.clamp(0, 0.6, s.scale.x * 0.6)
		s.scale.y = s.scale.y * this.bounce_scale_y
	end

	if target then
		s.ts = store.tick_ts

		update_sprite()

		local mod = E:create_entity(b.mod)

		mod.modifier.source_id = b.source_id
		mod.modifier.target_id = target.id

		simulation:queue_insert_entity(mod)

		while not U.animation_finished_default(this) do
			update_sprite()
			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function chain_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local source = store.entities[m.source_id]
	local cl = this.chainlightning

	if target and target.health and not target.health.dead then
		local d = E.assign_damage(cl.damage_type, cl.damage, m.source_id, m.target_id)

		queue_damage(store, d)

		local mod = E:create_entity(cl.mod)

		mod.modifier.ts = store.tick_ts
		mod.modifier.source_id = m.source_id
		mod.modifier.target_id = target.id

		simulation:queue_insert_entity(mod)
	end

	U.y_wait_unconditional(store, cl.chain_delay)

	local chain_pos = V.vclone(source.pos)
	local af = source.render.sprites[1].flip_x

	chain_pos.x = chain_pos.x + cl.offset.x * (af and -1 or 1)
	chain_pos.y = chain_pos.y + cl.offset.y

	local targets = U.find_enemies_between_range_filter_off(chain_pos, cl.min_range, cl.max_range, cl.vis_flags or 0, cl.vis_bans or 0)

	if targets then
		for i = 1, cl.count do
			local num = math.random(1, #targets)
			local t = targets[num]
			local dest = V.vclone(t.pos)
			local b = E:create_entity(cl.bullet)

			b.pos:copy(chain_pos)
			b.bullet.from:copy(b.pos)

			b.bullet.to = dest
			b.bullet.target_id = t.id
			b.bullet.source_id = m.source_id
			b.bullet.level = m.level

			simulation:queue_insert_entity(b)
		end
	end

	simulation:queue_remove_entity(this)
end

local function thunderclap_update(this, store)
	local tc = this.thunderclap
	local m = this.modifier
	local target = store.entities[m.target_id]
	local mods = {tc.mod_stun, tc.mod_fx}

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = V.vclone(target.pos)

	if target.health and not target.health.dead then
		local d = E.assign_damage(tc.damage_type, tc.damage, m.source_id, m.target_id)

		queue_damage(store, d)

		local mod = E:create_entity(tc.mod_stun)

		mod.modifier.ts = store.tick_ts
		mod.modifier.source_id = m.source_id
		mod.modifier.target_id = m.target_id

		simulation:queue_insert_entity(mod)
	end

	S:queue(tc.sound)
	U.y_wait_unconditional(store, tc.explosion_delay)

	local targets = U.find_enemies_in_range_filter_on(target.pos, tc.max_range, tc.vis_flags or 0, tc.vis_bans or 0, function(e)
		return e.id ~= m.target_id and e.health and not e.health.dead
	end)

	if targets then
		for _, t in ipairs(targets) do
			local d = E.assign_damage(tc.secondary_damage_type, tc.secondary_damage, m.source_id, t.id)

			queue_damage(store, d)

			for _, tm in ipairs(mods) do
				local mod = E:create_entity(tm)

				mod.modifier.ts = store.tick_ts
				mod.modifier.source_id = m.source_id

				if tm == tc.mod_stun then
					mod.modifier.duration = U.frandom(tc.stun_duration_min, tc.stun_duration_max)
				end

				mod.modifier.target_id = t.id
				mod.modifier.level = m.level

				simulation:queue_insert_entity(mod)
			end
		end
	end

	local fx = E:create_entity(tc.fx)

	fx.pos:copy(this.pos)

	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
	U.y_wait_unconditional(store, fts(24))
	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.cooldown = ls.melee_cooldown[hl]
	this.lightning_heal = ls.lightning_heal[hl]
	this.melee.attacks[1].cooldown = ls.melee_cooldown[hl]
	this.melee.attacks[2].cooldown = ls.melee_cooldown[hl]

	upgrade_skill(this, "chainlightning", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.level = s.level
		a.chance = s.chance[s.level]

		local mod = E:get_template(a.mod)

		mod.chainlightning.count = s.count[s.level]
		mod.chainlightning.damage = s.damage_max[s.level]
	end)
	upgrade_skill(this, "thunderclap", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil
		a.level = s.level

		local b = E:get_template(a.bullet)
		local mod = E:get_template(b.bullet.mod)

		mod.thunderclap.damage = s.damage_max[s.level]
		mod.thunderclap.secondary_damage = s.secondary_damage_max[s.level]
		mod.thunderclap.stun_duration_max = s.stun_duration[s.level]
		mod.thunderclap.max_range = s.max_range[s.level]
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

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
					goto label_87_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_ranged_attacks(store, this)

			if brk then
			-- block empty
			else
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
		end

		::label_87_0::

		coroutine.yield()
	end
end

local tt

tt = RT("ray_hero_thor", "ray_tesla")
tt.bullet.mod = "mod_ray_hero_thor"
tt.render.sprites[1].name = "ray_hero_thor"
tt.main_script.update = ray_thor_update
tt = RT("fx_hero_thor_thunderclap_disipate", "fx")
tt.render.sprites[1].name = "fx_hero_thor_thunderclap_disipate"
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt = RT("hero_thor", "hero")

AC(tt, "melee", "ranged")

tt.hero.level_stats.armor = {0.43, 0.46, 0.49, 0.52, 0.55, 0.58, 0.61, 0.64, 0.67, 0.7}
tt.hero.level_stats.hp_max = {380, 410, 440, 470, 500, 530, 560, 590, 620, 650}
tt.hero.level_stats.melee_damage_max = {31, 34, 36, 39, 42, 44, 47, 49, 52, 55}
tt.hero.level_stats.melee_damage_min = {25, 27, 29, 32, 34, 36, 38, 40, 42, 44}
tt.hero.level_stats.melee_cooldown = {1, 0.98, 0.96, 0.94, 0.92, 0.9, 0.88, 0.86, 0.84, 0.82}
tt.hero.level_stats.lightning_heal = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40}
tt.hero.skills.chainlightning = CC("hero_skill")
tt.hero.skills.chainlightning.count = {5, 7, 9}
tt.hero.skills.chainlightning.damage_max = {40, 50, 60}
tt.hero.skills.chainlightning.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.chainlightning.xp_gain = {50, 100, 150}
tt.hero.skills.chainlightning.chance = {0.28, 0.32, 0.36}
tt.hero.skills.thunderclap = CC("hero_skill")
tt.hero.skills.thunderclap.damage_max = {60, 80, 120}
tt.hero.skills.thunderclap.secondary_damage_max = {50, 70, 90}
tt.hero.skills.thunderclap.max_range = {70, 77, 84}
tt.hero.skills.thunderclap.stun_duration = {3, 4, 6}
tt.hero.skills.thunderclap.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.thunderclap.xp_gain = {50, 100, 150}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.hero_portrait = "hero_portraits_0012"
tt.info.portrait = "info_portraits_heroes_0012"
tt.main_script.update = hero_update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].prefix = "hero_thor"
tt.soldier.melee_slot_offset = vec_2(13, 0)
tt.sound_events.change_rally_point = "HeroThorTaunt"
tt.sound_events.death = "HeroThorDeath"
tt.sound_events.hero_room_select = "HeroThorTauntSelect"
tt.sound_events.insert = "HeroThorTauntIntro"
tt.sound_events.respawn = "HeroThorTauntIntro"
tt.unit.hit_offset = vec_2(0, 22)
tt.unit.mod_offset = vec_2(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "chain"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].cooldown = 1
tt.melee.attacks[2].damage_type = DAMAGE_NO_DODGE
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(16)
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound = "HeroThorElectricAttack"
tt.melee.attacks[2].mod = "mod_hero_thor_chainlightning"
tt.melee.attacks[2].xp_from_skill = "chainlightning"
tt.melee.attacks[2].side_effect = function(this, store, damage, target)
	this.ranged.attacks[1].ts = this.ranged.attacks[1].ts - 1
end
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "thunderclap"
tt.ranged.attacks[1].bullet = "hammer_hero_thor"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 10)}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].cooldown = 9.5 + fts(28)
tt.ranged.attacks[1].max_range = 250
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].sound_shoot = "HeroThorHammer"
tt.ranged.attacks[1].xp_from_skill = "thunderclap"
tt.lightning_heal = 20
tt = RT("hammer_hero_thor", "bolt")
tt.bullet.min_speed = 300
tt.bullet.max_speed = 900
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_hero_thor_thunderclap"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "hammer_hero_thor"
tt.sound_events.insert = nil
tt = RT("mod_ray_hero_thor", "mod_ray_tesla")
tt.modifier.duration = fts(16)
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_type = DAMAGE_ELECTRICAL
tt = RT("mod_hero_thor_chainlightning", "modifier")
tt.chainlightning = {
	bullet = "ray_hero_thor",
	count = 2,
	damage = 40,
	offset = vec_2(25, -1),
	damage_type = DAMAGE_ELECTRICAL,
	chain_delay = fts(2),
	max_range = 110,
	min_range = 40,
	mod = "mod_tesla_overcharge"
}
tt.main_script.update = chain_update
tt = RT("mod_hero_thor_thunderclap", "modifier")

AC(tt, "render")

tt.thunderclap = {
	damage = 60,
	offset = vec_2(0, 10),
	damage_type = DAMAGE_ELECTRICAL,
	explosion_delay = fts(3),
	secondary_damage = 50,
	secondary_damage_type = DAMAGE_ELECTRICAL,
	radius = 70,
	stun_duration_max = 3,
	stun_duration_min = 2,
	mod_stun = "mod_hero_thor_stun",
	mod_fx = "mod_tesla_overcharge",
	fx = "fx_hero_thor_thunderclap_disipate",
	sound = "HeroThorThunder"
}
tt.main_script.update = thunderclap_update
tt.main_script.insert = scripts.mod_track_target.insert
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt.render.sprites[1].name = "mod_hero_thor_thunderclap"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mod_hero_thor_thunderclap_explosion"
tt = RT("mod_hero_thor_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
