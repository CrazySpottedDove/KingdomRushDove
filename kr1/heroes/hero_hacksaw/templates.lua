local bit = require("bit")
local E = require("entity_db")
local km = require("lib.klua.macros")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "sawblade", function(this, s)
		local a = this.ranged.attacks[1]

		a.disabled = nil

		local b = E:get_template(a.bullet)

		b.bounces_max = s.bounces[s.level]
	end)
	upgrade_skill(this, "timber", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
	end)

	update_hp(this)
end

local function hero_side_effect(this, store, damage, target)
	local fx = E:create_entity("fx_coin_jump")

	fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	if target.health_bar then
		fx.render.sprites[1].offset.y = target.health_bar.offset.y
	end

	target.enemy.gold = target.enemy.gold * 2
	target.health.hp = 0

	simulation:queue_insert_entity(fx)
end

local function hero_update(this, store)
	local h = this.health
	local brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	while true do
		if h.dead then
			S:queue(this.sound_events.death2)
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_64_0
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

		::label_64_0::

		coroutine.yield()
	end
end

local function sawblade_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target, ps
	local bounce_count = 0

	U.animation_start_default(this, "flying", nil, store.tick_ts, true)

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_193_0::

	local mdist2 = mspeed * mspeed * store.tick_length * store.tick_length

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > mdist2 do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	end

	if b.hit_blood_fx and target and target.unit.blood_color ~= BLOOD_NONE then
		local sfx = E:create_entity(b.hit_blood_fx)

		sfx.pos:copy(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		if sfx.use_blood_color and target.unit.blood_color then
			sfx.render.sprites[1].name = target.unit.blood_color
			sfx.render.sprites[1].r = this.render.sprites[1].r
		end

		simulation:queue_insert_entity(sfx)
	end

	if bounce_count < this.bounces_max then
		local target = U.find_random_enemy(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return v ~= target
		end)

		if target then
			S:queue(this.sound_events.bounce)

			bounce_count = bounce_count + 1
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			b.target_id = target.id

			goto label_193_0
		end
	end

	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_hacksaw", "hero")
AC(tt, "melee", "ranged")
tt.hero.level_stats.armor = {0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 0.71, 0.74, 0.77, 0.8}
tt.hero.level_stats.hp_max = {420, 440, 460, 480, 500, 520, 540, 560, 580, 600}
tt.hero.level_stats.melee_damage_max = {27, 30, 33, 36, 39, 42, 45, 48, 51, 54}
tt.hero.level_stats.melee_damage_min = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
tt.hero.skills.timber = CC("hero_skill")
tt.hero.skills.timber.cooldown = {28.5 + fts(35), 24.5 + fts(35), 20.5 + fts(35)}
tt.hero.skills.timber.xp_level_steps = {
	[10] = 3,
	[4] = 1,
	[7] = 2
}
tt.hero.skills.timber.xp_gain = {50, 100, 150}
tt.hero.skills.sawblade = CC("hero_skill")
tt.hero.skills.sawblade.bounces = {3, 5, 7, 9, 11}
tt.hero.skills.sawblade.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4,
	[10] = 5
}
tt.hero.skills.sawblade.xp_gain = {50, 70, 90, 110, 130}
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 58)
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(150)
tt.info.hero_portrait = "hero_portraits_0010"
tt.info.portrait = "info_portraits_heroes_0010"
tt.main_script.update = hero_update
tt.motion.max_speed = 2.8 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.13636363636363635)
tt.render.sprites[1].prefix = "hero_hacksaw"
tt.soldier.melee_slot_offset = vec_2(13, 0)
tt.sound_events.change_rally_point = "HeroHacksawTaunt"
tt.sound_events.death = "BombExplosionSound"
tt.sound_events.death2 = "HeroHacksawDeath"
tt.sound_events.hero_room_select = "HeroHacksawTauntSelect"
tt.sound_events.insert = "HeroHacksawTauntIntro"
tt.sound_events.respawn = "HeroHacksawTauntIntro"
tt.unit.hit_offset = vec_2(0, 38)
tt.unit.mod_offset = vec_2(0, 25)
tt.unit.pop_offset = vec_2(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.range = 65
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.6
tt.melee.attacks[1].side_effect = function(this, store, damage, target)
	SU.armor_dec(target, 0.05)

	this.ranged.attacks[1].ts = this.ranged.attacks[1].ts - (target.health.armor) * 0.5
end
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "timber"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].pop = {"pop_splat"}
tt.melee.attacks[2].pop_chance = 1
tt.melee.attacks[2].sound = "HeroHacksawDrill"
tt.melee.attacks[2].sound_args = {
	delay = fts(7)
}
tt.melee.attacks[2].damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_DODGE)
tt.melee.attacks[2].xp_from_skill = "timber"
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL)
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.melee.attacks[2].side_effect = hero_side_effect
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "sawblade"
tt.ranged.attacks[1].bullet = "hacksaw_sawblade"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 21)}
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].sound_shoot = "HeroHacksawShoot"
tt.ranged.attacks[1].cooldown = 6.5 + fts(32)
tt.ranged.attacks[1].xp_from_skill = "sawblade"

tt = RT("hacksaw_sawblade", "bullet")
tt.main_script.update = sawblade_update
tt.bullet.particles_name = "ps_hacksaw_sawblade"
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.damage_min = 45
tt.bullet.damage_max = 60
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_hacksaw_sawblade_hit"
tt.bounce_range = 160
tt.render.sprites[1].prefix = "hacksaw_sawblade"
tt.sound_events.insert = "HeroAlienDiscoThrow"
tt.sound_events.bounce = "HeroAlienDiscoBounce"

tt = RT("ps_hacksaw_sawblade")
AC(tt, "pos", "particle_system")
tt.particle_system.alphas = {255, 200, 0, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "ps_hacksaw_sawblade"
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.scales_y = {1.5, 0.5}

tt = RT("fx_hacksaw_sawblade_hit", "fx")
tt.render.sprites[1].prefix = "fx_hacksaw_sawblade"
tt.render.sprites[1].name = "hit"
