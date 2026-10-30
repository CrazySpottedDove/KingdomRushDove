local bit = require("bit")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local function mod_zefira_talent_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	SU.update_armor(target)
	SU.update_magic_armor(target)

	SU.armor_dec(target, target.health.raw_armor * this.armor_factor)
	SU.magic_armor_dec(target, target.health.raw_magic_armor * this.magic_armor_factor)
	signal.emit("mod-applied", this, target)

	if target.unit.size == UNIT_SIZE_MEDIUM or target.unit.size == UNIT_SIZE_LARGE then
		this.render.sprites[1].prefix = "hero_zefira_talent_mod_bigDef"
		this.render.sprites[2].prefix = "hero_zefira_talent_decal_bigDef"
	end

	for i = 1, #this.render.sprites do
		this.render.sprites[i].ts = store.tick_ts
	end

	return true
end

local function mod_zefira_talent_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			simulation:queue_remove_entity(this)

			return
		end

		if m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		coroutine.yield()
	end
end

local function mod_zefira_talent_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_inc(target, target.health.raw_armor * this.armor_factor)
		SU.magic_armor_inc(target, target.health.raw_magic_armor * this.magic_armor_factor)
	end

	return true
end

local function aura_zefira_skill_b_insert(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		return false
	end

	SU.armor_inc(source, this.aura.armor_inc)
	SU.magic_armor_inc(source, this.aura.magic_armor_inc)

	this.aura.ts = store.tick_ts
	this.pos = source.pos

	return true
end

local function aura_zefira_skill_b_update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = source.pos

	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	local last_hit_ts = 0

	while true do
		source = store.entities[this.aura.source_id]

		if not source or source.health.dead or store.tick_ts - this.aura.ts >= this.aura.duration then
			break
		end

		this.pos = source.pos

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = target.id
					d.damage_type = this.aura.damage_type
					d.value = math.random(this.aura.damage_min, this.aura.damage_max)

					queue_damage(store, d)

					local fx = E:create_entity(this.aura.hit_fx)

					fx.pos = V.vclone(target.pos)
					fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)

					if this.aura.slow_mod then
						local mod = E:create_entity(this.aura.slow_mod)

						mod.modifier.target_id = target.id
						mod.modifier.source_id = this.id

						simulation:queue_insert_entity(mod)
					end
				end
			end
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end

local function aura_zefira_skill_b_remove(this, store)
	local source = store.entities[this.aura.source_id]

	if source then
		SU.armor_dec(source, this.aura.armor_inc)
		SU.magic_armor_dec(source, this.aura.magic_armor_inc)
	end

	return true
end

local function mod_zefira_blink_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	U.y_animation_play(this, "in", nil, store.tick_ts, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			U.y_animation_play(this, "out", nil, store.tick_ts, 1)
			simulation:queue_remove_entity(this)

			return
		end

		this.pos = target.pos

		coroutine.yield()
	end
end

local function decal_zefira_ultimate_spear_update(this, store)
	U.animation_start(this, "in", nil, store.tick_ts, false)

	local enemies = U.find_enemies_in_range(store, this.pos, 0, this.damage_radius, this.vis_flags, this.vis_bans)

	if enemies then
		for _, enemy in ipairs(enemies) do
			local d = E:create_entity("damage")

			d.damage_type = this.damage_type
			d.value = math.random(this.damage_min, this.damage_max)
			d.source_id = this.id
			d.target_id = enemy.id

			queue_damage(store, d)
		end
	end

	local decal = E:create_entity(this.decal_t)

	decal.pos = V.vclone(this.pos)
	decal.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(decal)
	U.y_animation_wait(this)
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	U.y_wait_unconditional(store, fts(30))

	local enemies = U.find_enemies_in_range(store, this.pos, 0, this.damage_radius, this.vis_flags, this.vis_bans)

	if enemies then
		for _, enemy in ipairs(enemies) do
			local d = E:create_entity("damage")

			d.damage_type = this.damage_type
			d.value = math.random(this.damage_min, this.damage_max)
			d.source_id = this.id
			d.target_id = enemy.id

			queue_damage(store, d)
		end
	end
	U.y_animation_play(this, "out", nil, store.tick_ts, 1)

	this.render.sprites[1].hidden = true

	simulation:queue_remove_entity(this)
end

local function zefira_crit_damage(this, store, attack, target)
	local base = math.random(attack.damage_min, attack.damage_max)
	local s = this.hero.skills.talent_2

	if s.level > 0 and math.random() < s.crit_chance then
		return base * 2
	end

	return base
end

local function zefira_blink_side_effect(this, store)
	local s = this.hero.skills.skill_c

	if s.level > 0 and ready_to_use_skill(s, store, this.unit.cooldown_factor) then
		s.ts = store.tick_ts

		SU.hero_gain_xp_from_skill(this, s)
		S:queue("HeroZefiraAstralBlinkOutCast")

		local mod = E:create_entity(this.teleport.mod)

		mod.modifier.target_id = this.id
		mod.modifier.source_id = this.id
		mod.modifier.duration = s.duration[s.level]
		mod.inflicted_damage_factor = s.damage_factor[s.level]

		simulation:queue_insert_entity(mod)
	end
end

local function hero_zefira_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	local hero = this

	bt.bullet.damage_hooks = {function(entity, damage, protection)
		local s = hero.hero.skills.talent_2

		if s.level > 0 and math.random() < s.crit_chance then
			damage.value = damage.value * 2
		end
	end}

	upgrade_skill(this, "skill_a", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		this.hero.skills.skill_b.disabled = nil
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		this.teleport.disabled = false
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[1].disabled = nil
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		this.hero.skills.talent_1.ts = store.tick_ts
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.hero.skills.talent_2.ts = store.tick_ts
	end)
	update_hp(this)
end

local function hero_zefira_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local skill_b = skills.skill_b
	local skill_c = skills.skill_c
	local talent_1 = skills.talent_1
	local ultimate = this.timed_attacks.list[1]
	local brk, sta
	local cdf = this.unit.cooldown_factor or 1

	U.y_animation_play(this, "level_up", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	this.melee.attacks[1].ts = store.tick_ts - this.melee.attacks[1].cooldown * cdf
	skill_b.ts = store.tick_ts - skill_b.cooldown * cdf
	skill_c.ts = store.tick_ts - skill_c.cooldown * cdf
	ultimate.ts = store.tick_ts - ultimate.cooldown * cdf

	if talent_1.level > 0 and not this.hero.talent_1_aura then
		local aura = E:create_entity(talent_1.aura)

		aura.pos = V.vclone(this.pos)
		aura.aura.source_id = this.id

		simulation:queue_insert_entity(aura)

		this.hero.talent_1_aura = aura.id
	end

	local function spawn_spear(pi, spi, ni, flip)
		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local spear = E:create_entity(ultimate.spear_t)

		spear.pos = V.vclone(pos)
		spear.render.sprites[1].flip_x = flip

		simulation:queue_insert_entity(spear)
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					break
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "level_up", nil, store.tick_ts, 1)
			end

			if skill_b.level > 0 and ready_to_use_skill(skill_b, store, cdf) and this.soldier.target_id and this.motion.arrived then
				local target = store.entities[this.soldier.target_id]

				if target and not target.health.dead then
					skill_b.ts = store.tick_ts

					S:queue("HeroZefiraShieldingBladesCast")
					SU.hero_gain_xp_from_skill(this, skill_b)

					local aura = E:create_entity(skill_b.aura)

					aura.pos = V.vclone(this.pos)
					aura.aura.source_id = this.id
					aura.aura.target_id = this.id
					aura.aura.level = skill_b.level
					aura.aura.duration = skill_b.duration[skill_b.level]

					simulation:queue_insert_entity(aura)
				end
			end

			if ready_to_use_skill(ultimate, store, cdf) then
				local a = ultimate
				local enemies = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
				local targets = {}

				if enemies then
					for _, enemy in ipairs(enemies) do
						local pi = enemy.nav_path.pi

						if P:is_path_active(pi) and not (store.level.ignore_walk_backwards_paths and table.contains(store.level.ignore_walk_backwards_paths, pi)) then
							local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {pi})

							if nearest[1] and nearest[1][3] < enemy.nav_path.ni then
								targets[#targets + 1] = enemy
							end
						end
					end
				end

				if #targets >= a.min_targets then
					local start_ts = store.tick_ts
					local flip = targets[1].pos.x < this.pos.x

					S:queue(a.sound)
					S:queue(a.sound_taunt)

					U.animation_start(this, a.animation, flip, store.tick_ts, false)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto continue
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, ultimate)

					local path = targets[1].nav_path.pi
					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path})

					if nearest[1] then
						local pi, _, ni = unpack(nearest[1])
						local initial_offset = 1

						ni = ni - initial_offset

						local count = a.spears_count / 3
						local nodes_between_spears = 2

						for i = 1, count do
							local ni_aux = ni - i * nodes_between_spears

							if P:is_node_valid(pi, ni_aux) then
								spawn_spear(pi, 1, ni_aux, flip)
								U.y_wait_unconditional(store, fts(1))
							end

							ni_aux = ni - i * (nodes_between_spears + 1)

							if P:is_node_valid(pi, ni_aux) then
								spawn_spear(pi, 2, ni_aux, flip)
								U.y_wait_unconditional(store, fts(1))
								spawn_spear(pi, 3, ni_aux, flip)
								U.y_wait_unconditional(store, fts(1))
							end
						end
					end

					if SU.y_hero_animation_wait(this) then
						goto continue
					end
					U.animation_start(this, "idle", nil, store.tick_ts, true)
				else
					a.ts = a.ts + fts(10)
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::continue::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_zefira", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "teleport", "transfer")
tt.hero.level_stats.armor = {0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.19, 0.2}
tt.hero.level_stats.hp_max = {160, 170, 180, 190, 200, 210, 220, 230, 240, 250}
tt.hero.level_stats.melee_damage_min = {8, 9, 9, 10, 11, 12, 13, 14, 15, 16}
tt.hero.level_stats.melee_damage_max = {23, 26, 28, 30, 32, 34, 36, 38, 40, 42}
tt.hero.level_stats.ranged_damage_min = {6, 7, 8, 9, 9, 10, 11, 12, 13, 14}
tt.hero.level_stats.ranged_damage_max = {19, 21, 23, 26, 28, 30, 32, 34, 36, 38}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.damage_min = {30, 60, 90}
tt.hero.skills.skill_a.damage_max = {60, 90, 120}
tt.hero.skills.skill_a.xp_gain = {48, 96, 144}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.cooldown = 18
tt.hero.skills.skill_b.aura = "aura_zefira_skill_b"
tt.hero.skills.skill_b.duration = {4, 5, 6}
tt.hero.skills.skill_b.xp_gain = {72, 144, 216}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_b.disabled = true
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.cooldown = 2
tt.hero.skills.skill_c.duration = {4, 6, 8}
tt.hero.skills.skill_c.damage_factor = {1.3, 1.55, 1.8}
tt.hero.skills.skill_c.xp_gain = {0, 0, 0}
tt.hero.skills.skill_c.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.cooldown = 34
tt.hero.skills.ultimate.spears_count = 21
tt.hero.skills.ultimate.min_targets = 3
tt.hero.skills.ultimate.xp_gain = {136}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.aura = "aura_zefira_talent"
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.crit_chance = 0.2
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_zefira_level_up
tt.hero.respawn_animation = "level_up"
tt.hero.tombstone_show_time = fts(25)
tt.hero.tombstone_decal = "decal_zefira_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.info.hero_portrait = "kr6_hero_portraits_0002"
tt.info.portrait = "kr6_info_portraits_heroes_0003"
tt.main_script.update = hero_zefira_update
tt.motion.max_speed = 120
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_zefiraDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[1].scale = vec_2(1.15, 1.15)
tt.sound_events.change_rally_point = "HeroZefiraTaunt"
tt.sound_events.death = "HeroZefiraDeath"
tt.sound_events.insert = "HeroZefiraTauntIntro"
tt.sound_events.level_up = "HeroZefiraTauntLevelUp"
tt.sound_events.respawn = "HeroZefiraTauntIntro"
tt.sound_events.hero_room_select = "HeroZefiraTauntSelect"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].fn_damage = zefira_crit_damage
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_fx = "fx_zefira_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 20)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "skill_1"
tt.melee.attacks[2].cooldown = 10
tt.melee.attacks[2].damage_min = 20
tt.melee.attacks[2].damage_max = 40
tt.melee.attacks[2].damage_radius = 55
tt.melee.attacks[2].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = "decal_zefira_skill_a_hit"
tt.melee.attacks[2].hit_fx = "fx_zefira_skill_a_hit"
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].hit_offset = vec_2(40, 0)
tt.melee.attacks[2].min_count = 1
tt.melee.attacks[2].mod = "mod_zefira_skill_a_stun"
tt.melee.attacks[2].sound = "HeroZefiraDazzlingHammerCast"
tt.melee.attacks[2].xp_from_skill = "skill_a"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack_1"
tt.ranged.attacks[1].bullet = "bullet_zefira"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(18, 21)}
tt.ranged.attacks[1].cooldown = 1.2
tt.ranged.attacks[1].min_range = 70
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].node_prediction = fts(23)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.teleport.disabled = true
tt.teleport.min_distance = 125
tt.teleport.mod = "mod_zefira_blink_buff"
tt.teleport.side_effect = zefira_blink_side_effect
tt.teleport.sound = "HeroZefiraAstralBlinkInCast"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "ultimate"
tt.timed_attacks.list[1].cast_time = fts(17)
tt.timed_attacks.list[1].cooldown = 30
tt.timed_attacks.list[1].damage_type = DAMAGE_MAGICAL
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].sound = "HeroZefiraEtherealSpears"
tt.timed_attacks.list[1].sound_taunt = "HeroZefiraTauntUltimate"
tt.timed_attacks.list[1].spears_count = 21
tt.timed_attacks.list[1].spear_t = "decal_zefira_ultimate_spear"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.transfer.animations = {"walk_in", "walk", "walk_out"}
tt.transfer.extra_speed = 0

tt = RT("mod_zefira_talent", "modifier")

AC(tt, "render")

tt.armor_factor = 0.3
tt.magic_armor_factor = 0.3
tt.main_script.insert = mod_zefira_talent_insert
tt.main_script.update = mod_zefira_talent_update
tt.main_script.remove = mod_zefira_talent_remove
tt.modifier.duration = 1
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = 0
tt.render.sprites[1].prefix = "hero_zefira_talent_modDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_zefira_talent_decalDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].z = Z_DECALS

tt = RT("aura_zefira_talent", "aura")

tt.aura.duration = 1e+99
tt.aura.radius = 75
tt.aura.cycle_time = 0.5
tt.aura.mod = "mod_zefira_talent"
tt.aura.track_dead = true
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = RT("aura_zefira_skill_b", "aura")
AC(tt, "render", "vis")
tt.aura.cycle_time = 0.25
tt.aura.damage_max = 4
tt.aura.damage_min = 4
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.hit_fx = "fx_zefira_skill_b_hit"
tt.aura.radius = 45
tt.aura.armor_inc = 0.3
tt.aura.magic_armor_inc = 0.3
tt.aura.slow_mod = "mod_zefira_skill_b_slow"
tt.aura.track_source = true
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.insert = aura_zefira_skill_b_insert
tt.main_script.update = aura_zefira_skill_b_update
tt.main_script.remove = aura_zefira_skill_b_remove
tt.render.sprites[1].prefix = "hero_zefira_skill2Def"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -1

tt = RT("mod_zefira_skill_b_slow", "mod_slow")

tt.modifier.duration = 0.3
tt.modifier.vis_flags = bor(F_MOD)
tt.slow.factor = 0.75

tt = RT("mod_zefira_blink_buff", "modifier")

AC(tt, "render")

tt.inflicted_damage_factor = 1.3
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = mod_zefira_blink_update
tt.modifier.duration = 4
tt.modifier.use_mod_offset = false
tt.modifier.vis_bans = 0
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].prefix = "hero_zefira_teleport_decalDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_zefira_teleport_buffDef"
tt.render.sprites[2].name = "in"
tt.render.sprites[2].exo = true
tt.render.sprites[2].sort_y_offset = -1

tt = RT("mod_zefira_skill_a_stun", "mod_stun")

tt.modifier.duration = 1
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = RT("fx_zefira_hit", "fx")

tt.render.sprites[1].prefix = "hero_zefira_attack2_hitDef"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].exo = true

tt = RT("fx_zefira_bullet_hit", "fx")

tt.render.sprites[1].prefix = "hero_zefira_attack_hitDef"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].exo = true

tt = RT("fx_zefira_skill_a_hit", "fx")

tt.render.sprites[1].prefix = "hero_zefira_skill1_hitDef"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].exo = true

tt = RT("fx_zefira_skill_b_hit", "fx")

tt.render.sprites[1].prefix = "hero_zefira_skill2_hitDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true

tt = RT("decal_zefira_skill_a_hit", "decal_scripted")

tt.animation_idle = "idle"
tt.animation_end = "out"
tt.duration = 1
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.render.sprites[1].prefix = "hero_zefira_skill1_decalDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "hero_zefira_skill1_decalfxDef"
tt.render.sprites[2].name = "skill_1"
tt.render.sprites[2].loop = false
tt.render.sprites[2].exo = true

tt = RT("decal_zefira_ultimate_spear", "decal_scripted")
tt.damage_min = 25
tt.damage_max = 25
tt.damage_radius = 35
tt.damage_type = DAMAGE_MAGICAL
tt.decal_t = "decal_zefira_ultimate_spear_floor"
tt.hit_time = fts(3)
tt.main_script.update = decal_zefira_ultimate_spear_update
tt.vis_bans = bor(F_FLYING)
tt.vis_flags = bor(F_AREA)
tt.render.sprites[1].prefix = "hero_zefira_ultimateDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true

tt = RT("decal_zefira_ultimate_spear_floor", "decal_timed")

tt.timed.runs = 1
tt.render.sprites[1].prefix = "hero_zefira_ultimate_decalDef"
tt.render.sprites[1].name = "out"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true

tt = RT("decal_zefira_tombstone", "decal_tween")

tt.tween.disabled = true
tt.render.sprites[1].prefix = "hero_zefiraDef"
tt.render.sprites[1].name = "grave"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].scale = vec_2(1.1, 1.1)

tt = RT("bullet_zefira", "bolt")
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "fx_zefira_bullet_hit"
tt.bullet.xp_gain_factor = 2
tt.bullet.max_speed = 300
tt.bullet.min_speed = 300
tt.bullet.pop = {"pop_zap"}
tt.bullet.pop_conds = DR_KILL
tt.render.sprites[1].prefix = "hero_zefira_attack_projectileDef"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].exo = true
tt.sound_events.insert = "HeroZefiraBasicAttackCast"
