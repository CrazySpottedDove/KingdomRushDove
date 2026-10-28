local bit = require("bit")
local E = require("entity_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local update_regen = HU.update_regen
local queue_damage = U.queue_damage

local function giant_boulder_insert(this, store)
	if not scripts.bomb.insert(this, store) then
		return false
	end

	local b = this.bullet
	local target = store.entities[b.target_id]

	if not target then
		return false
	end

	if target.unit and target.unit.hit_offset then
		b.hit_fx_sort_y_offset = -1 - target.unit.hit_offset.y

		if target.unit.hit_offset.y > 23 then
			-- b.hit_decal = nil
			b.hit_decal = "decal_timed_empty"
		end
	end

	return true
end

local function mod_giant_massivedamage_insert(this, store)
	local m = this.modifier
	local source = store.entities[m.source_id]
	local target = store.entities[m.target_id]

	if not source or not target or target.health.dead then
		return false
	end

	this.pos = V.vclone(target.pos)

	local s = this.render.sprites[1]

	s.name = s.name .. "_" .. s.size_names[target.unit.size]
	s.anchor.y = s.size_anchors_y[target.unit.size]
	s.flip_x = source.render.sprites[1].flip_x
	s.ts = store.tick_ts

	local d = E.assign_damage(DAMAGE_TRUE, source.unit.damage_factor * (math.random(this.damage_min, this.damage_max) + source.unit.damage_buff), this.id, target.id)
	local predicted_damage = d.value * target.health.damage_factor

	if math.random() < this.instakill_chance then
		if (band(target.vis.flags, F_BOSS) ~= 0) or target.health.hp - predicted_damage > this.instakill_min_hp then
			d.value = d.value * 2
		else
			d.damage_type = DAMAGE_INSTAKILL
		end
	end

	queue_damage(store, d)

	return true
end

local function aura_giant_bastion_update(this, store)
	local hero = store.entities[this.aura.source_id]

	this.pos = hero.pos

	local enabled = false
	local added_damage = 0
	local last_tick = store.tick_ts
	local s = this.render.sprites[1]

	local function add_damage(value)
		if added_damage + value >= 0 then
			added_damage = added_damage + value

			SU.damage_inc(hero, value)
		end
	end

	while true do
		local rally_pos = hero.nav_rally.pos

		if enabled then
			if hero.health.dead then
				enabled = false

				add_damage(-added_damage)

				added_damage = 0
			elseif V.dist2(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) > this.max_distance * this.max_distance and store.tick_ts - last_tick > this.tick_time then
				add_damage(-this.damage_per_tick)

				last_tick = store.tick_ts
			elseif added_damage < this.max_damage and store.tick_ts - last_tick > this.tick_time then
				add_damage(this.damage_per_tick)

				last_tick = store.tick_ts
			end
		elseif not hero.health.dead and V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) < this.max_distance then
			enabled = true
			added_damage = 0
			last_tick = store.tick_ts
		end

		s.hidden = added_damage == 0

		local new_scale

		new_scale = added_damage >= this.max_damage and 1 or added_damage > 0 and 0.5 or 0

		if new_scale ~= s.scale.x then
			s.ts = store.tick_ts
			s.scale.x, s.scale.y = new_scale, new_scale
		end

		coroutine.yield()
	end
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "boulderthrow", function(this, s)
		this.ranged.attacks[1].disabled = nil

		local b = E:get_template(this.ranged.attacks[1].bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "stomp", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.damage = s.damage[s.level]
		a.loops = s.loops[s.level]

		local stun = E:get_template("mod_giant_stun")

		stun.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "bastion", function(this, s)
		local a = E:get_template(this.auras.list[1].name)

		a.damage_per_tick = s.damage_per_tick[s.level]
		a.max_damage = s.max_damage[s.level]

		local aura_baston_key = table.find(store.auras, function(k, v)
			return v.template_name == this.auras.list[1].name
		end)

		if aura_baston_key then
			local aura_baston = store.entities[aura_baston_key]

			aura_baston.damage_per_tick = s.damage_per_tick[s.level]
			aura_baston.max_damage = s.max_damage[s.level]
		end
	end)
	upgrade_skill(this, "hardrock", function(this, s)
		this.hardrock_extra_hp = s.extra_hp[s.level]
		this.health.damage_block = s.damage_block[s.level]
	end)

	this.health.hp_max = this.health.hp_max + this.hardrock_extra_hp

	update_regen(this)
	upgrade_skill(this, "massivedamage", function(this, s)
		this.melee.attacks[2].disabled = nil

		local mod = E:get_template(this.melee.attacks[2].mod)

		mod.instakill_chance = s.chance[s.level]
		mod.instakill_min_hp = this.health.hp_max / s.health_factor
		mod.damage_min = ls.melee_damage_min[hl] + s.extra_damage[s.level]
		mod.damage_max = ls.melee_damage_max[hl] + s.extra_damage[s.level]
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function do_stomp(attack, targets)
		if not targets then
			return
		end

		for _, t in ipairs(targets) do
			local d = E.assign_damage(attack.damage_type, (attack.damage + this.unit.damage_buff) * this.unit.damage_factor, this.id, t.id)

			queue_damage(store, d)

			local m = E:create_entity("mod_giant_slow")

			m.modifier.source_id = this
			m.modifier.target_id = t.id

			simulation:queue_insert_entity(m)
		end

		local stun_targets = table.filter(targets, function(k, v)
			return v.vis and band(v.vis.bans, attack.stun_vis_flags) == 0 and band(v.vis.flags, attack.stun_vis_bans) == 0
		end)

		if #stun_targets > 0 and math.random() < attack.stun_chance then
			local t = table.random(stun_targets)
			local m = E:create_entity("mod_giant_stun")

			m.modifier.source_id = this
			m.modifier.target_id = t.id

			simulation:queue_insert_entity(m)
		end
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_HOST, DAMAGE_EAT)) == 0 then
				this.unit.hide_after_death = true

				local remains = E:create_entity("giant_death_remains")

				remains.pos.x, remains.pos.y = this.pos.x, this.pos.y
				remains.render.sprites[1].ts = store.tick_ts
				remains.render.sprites[2].ts = store.tick_ts

				simulation:queue_insert_entity(remains)
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_306_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.stomp

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
				-- block empty
				else
					local targets_hp = table.map(targets, function(k, v)
						return v.health and v.health.hp or 0
					end)
					local _, max_target_hp = table.maxv(targets_hp)

					if #targets < a.trigger_min_enemies and max_target_hp < a.trigger_min_hp then
						a.ts = a.ts + 0.13333333333333333
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.loops do
							if this.health.dead or this.nav_rally.new then
								break
							end

							local flip_sign = this.render.sprites[1].flip_x and -1 or 1
							local start_ts = store.tick_ts
							local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.damage_flags, a.damage_bans)

							S:queue("HeroGiantStomp")
							U.animation_start_default(this, "stomp", nil, store.tick_ts, false)

							while store.tick_ts - start_ts < a.hit_times[1] do
								coroutine.yield()
							end

							do_stomp(a, targets)

							local fx = E:create_entity("giant_stomp_decal")

							fx.pos = V.v(this.pos.x - 20 * flip_sign, this.pos.y - 2)
							fx.render.sprites[1].ts = store.tick_ts

							simulation:queue_insert_entity(fx)

							while store.tick_ts - start_ts < a.hit_times[2] do
								coroutine.yield()
							end

							do_stomp(a, targets)

							local fx = E:create_entity("giant_stomp_decal")

							fx.pos = V.v(this.pos.x + 19 * flip_sign, this.pos.y + 5)
							fx.render.sprites[1].ts = store.tick_ts

							simulation:queue_insert_entity(fx)
							U.y_animation_wait_default(this)
						end

						goto label_306_0
					end
				end
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

		::label_306_0::

		coroutine.yield()
	end
end

local function hero_on_damage(this, store, damage)
	damage.value = math.max(0, damage.value - this.health.damage_block)

	return true
end

local tt

tt = RT("hero_giant", "hero")

AC(tt, "auras", "melee", "ranged", "timed_attacks")

tt.hero.level_stats.hp_max = {330, 360, 390, 420, 450, 480, 510, 540, 570, 600}
tt.hero.level_stats.armor = {0.24, 0.27, 0.30, 0.34, 0.37, 0.40, 0.44, 0.47, 0.50, 0.55}
tt.hero.level_stats.melee_damage_min = {10, 12, 14, 15, 17, 18, 20, 21, 23, 24}
tt.hero.level_stats.melee_damage_max = {16, 18, 20, 23, 25, 27, 30, 32, 34, 37}
tt.hero.skills.boulderthrow = CC("hero_skill")
tt.hero.skills.boulderthrow.damage_min = {20, 40, 60}
tt.hero.skills.boulderthrow.damage_max = {40, 60, 100}
tt.hero.skills.boulderthrow.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.boulderthrow.xp_gain_factor = 60
tt.hero.skills.stomp = CC("hero_skill")
tt.hero.skills.stomp.damage = {10, 15, 20}
tt.hero.skills.stomp.loops = {2, 3, 4}
tt.hero.skills.stomp.stun_duration = {2, 3, 4}
tt.hero.skills.stomp.xp_gain_factor = 80
tt.hero.skills.stomp.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.bastion = CC("hero_skill")
tt.hero.skills.bastion.damage_per_tick = {1.5, 2, 2.5, 3}
tt.hero.skills.bastion.max_damage = {15, 20, 25, 30}
tt.hero.skills.bastion.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.massivedamage = CC("hero_skill")
tt.hero.skills.massivedamage.chance = {0.2, 0.45, 0.7}
tt.hero.skills.massivedamage.extra_damage = {60, 120, 180}
tt.hero.skills.massivedamage.health_factor = 2.5
tt.hero.skills.massivedamage.xp_gain_factor = 90
tt.hero.skills.massivedamage.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.hardrock = CC("hero_skill")
tt.hero.skills.hardrock.extra_hp = {150, 300, 450}
tt.hero.skills.hardrock.damage_block = {9, 12, 15}
tt.hero.skills.hardrock.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_giant_bastion"
tt.health.armor = tt.hero.level_stats.armor[1]
tt.health.dead_lifetime = 15
tt.health.hp_max = tt.hero.level_stats.hp_max[1]
tt.health_bar.offset = vec_2(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.on_damage = hero_on_damage
tt.health.damage_block = 0
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0008"
tt.info.portrait = "kr2_info_portraits_heroes_0008"
-- tt.main_script.insert = scripts.hero_giant.insert
tt.main_script.update = hero_update
tt.motion.max_speed = 55
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.19117647058823528
tt.render.sprites[1].prefix = "hero_giant"
tt.soldier.melee_slot_offset.x = 18
tt.sound_events.change_rally_point = "HeroGiantTaunt"
tt.sound_events.death = "HeroGiantDeath"
tt.sound_events.respawn = "HeroGiantTauntIntro"
tt.sound_events.insert = "HeroGiantTauntIntro"
tt.sound_events.hero_room_select = "HeroGiantTauntSelect"
tt.ui.click_rect = r(-25, 0, 50, 45)
tt.unit.marker_offset = vec_2(0, 0.28)
tt.unit.mod_offset = vec_2(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.blood_color = BLOOD_GRAY
tt.vis.bans = bor(tt.vis.bans, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_MOCKING)
tt.melee.range = 70
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].cooldown = 1.3
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3.2
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].animation = "massive"
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].cooldown = 9.6
tt.melee.attacks[2].mod = "mod_giant_massivedamage"
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].xp_from_skill = "massivedamage"
tt.melee.attacks[2].sound = "HeroGiantMassiveDamage"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "giant_boulder"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 77)}
tt.ranged.attacks[1].cooldown = 10.4
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(20)
tt.ranged.attacks[1].sound = "HeroGiantBoulder"
tt.ranged.attacks[1].node_prediction = fts(40)
tt.ranged.attacks[1].xp_from_skill = "boulderthrow"
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "stomp"
tt.timed_attacks.list[1].cooldown = 12.6
tt.timed_attacks.list[1].damage_radius = 150
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_times = {fts(4), fts(12)}
tt.timed_attacks.list[1].max_range = 76.8
tt.timed_attacks.list[1].stun_chance = 0.5
tt.timed_attacks.list[1].trigger_min_enemies = 2
tt.timed_attacks.list[1].trigger_min_hp = 100
tt.timed_attacks.list[1].stun_vis_flags = F_STUN
tt.timed_attacks.list[1].stun_vis_bans = bor(F_CLIFF, F_BOSS, F_FLYING)
tt.hardrock_extra_hp = 0
tt = RT("giant_death_remains", "decal_tween")
tt.render.sprites[1].name = "hero_giant_death_remains"
tt.render.sprites[1].anchor.y = 0.19117647058823528
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_giant_death_rocks"
tt.render.sprites[2].anchor.y = 0.19117647058823528
tt.render.sprites[2].time_offset = -fts(12)
tt.tween.props[1].keys = {{0, 0}, {fts(12), 0}, {fts(26), 255}, {fts(45), 255}, {fts(60), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {fts(12), 0}, {fts(13), 255}, {fts(25), 0}, {fts(27), 0}}
tt.tween.props[2].sprite_id = 2
tt = RT("aura_giant_bastion", "aura")

AC(tt, "render", "tween")

tt.aura.duration = -1
tt.aura.track_source = true
tt.main_script.update = aura_giant_bastion_update
tt.render.sprites[1].name = "giant_bastion_decal"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].scale = vec_2(0, 0)
tt.render.sprites[1].anchor.y = 0.19117647058823528
tt.max_distance = 80
tt.tick_time = 2.5
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = RT("mod_giant_massivedamage", "modifier")

AC(tt, "render", "tween")

tt.damage_type = DAMAGE_TRUE
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "giant_ice"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].size_anchors_y = {0.19, 0.22, 0.22}
tt.tween.props[1].keys = {{0, 255}, {fts(12), 255}, {fts(12) + 0.25, 0}}
tt.main_script.insert = mod_giant_massivedamage_insert
tt = RT("mod_giant_slow", "mod_slow")
tt.modifier.duration = 1
tt = RT("mod_giant_stun", "mod_stun")
tt.modifier.duration = nil
tt = RT("giant_stomp_decal", "decal_timed")
tt.render.sprites[1].name = "giant_stomp_stones"
tt = RT("giant_boulder", "bomb")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 86.4
tt.bullet.flight_time = fts(20)
tt.bullet.g = -1.5 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_giant_boulder_explosion"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx_water = "fx_explosion_water"
tt.bullet.use_hit_offset = true
tt.sound_events.hit = "HeroGiantExplosionRock"
tt.sound_events.hit_water = "RTWaterExplosion"
tt.sound_events.insert = nil
tt.render.sprites[1].name = "hero_giant_proy_0001"
tt.main_script.insert = giant_boulder_insert
tt = RT("fx_giant_boulder_explosion", "fx")
tt.render.sprites[1].name = "giant_boulder_explosion"
tt.render.sprites[1].z = Z_OBJECTS
