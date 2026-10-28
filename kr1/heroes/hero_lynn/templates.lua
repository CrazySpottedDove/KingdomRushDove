local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local signal = require("lib.hump.signal")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function hero_lynn_ultimate_update(this, store)
	local targets = table.filter(store.enemies, function(_, e)
		return e.ui and e.ui.can_click and e.nav_path and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(this.pos.x, this.pos.y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
	end)

	table.sort(targets, function(e1, e2)
		return V.dist2(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) < V.dist2(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
	end)

	local target = targets[1]

	if target then
		local m = E:create_entity(this.mod)

		m.modifier.source_id = this.id
		m.modifier.target_id = target.id
		m.modifier.damage_factor = this.damage_factor

		simulation:queue_insert_entity(m)
	end

	simulation:queue_remove_entity(this)
end

local function mod_lynn_curse_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or math.random() >= this.modifier.chance or not U.flags_pass(target.vis, this.modifier) then
		return false
	end

	U.cast_silence(target, store.tick_ts)

	return true
end

local function mod_lynn_curse_update(this, store)
	this.modifier.ts = store.tick_ts

	local target

	repeat
		coroutine.yield()

		target = store.entities[this.modifier.target_id]
	until store.tick_ts - this.modifier.ts >= this.modifier.duration or not target or target.health.dead

	simulation:queue_remove_entity(this)
end

local function mod_lynn_curse_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	U.remove_silence(target, store.tick_ts)

	return true
end

local function mod_lynn_weakening_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
		return false
	end

	if this.magic_armor_reduction > target.health.magic_armor then
		this.armor_reduction = this.armor_reduction + 0.5 * target.health.magic_armor
	else
		this.armor_reduction = this.armor_reduction + 0.5 * this.magic_armor_reduction
	end

	SU.armor_dec(target, this.armor_reduction)
	SU.magic_armor_dec(target, this.magic_armor_reduction)
	signal.emit("mod-applied", this, target)

	return true
end

local function mod_lynn_weakening_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.armor_inc(target, this.armor_reduction)
		SU.magic_armor_inc(target, this.magic_armor_reduction)
	end

	return true
end

local function mod_lynn_despair_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.unit or not target.motion then
		return false
	end

	SU.insert_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)

	if not target.motion.invulnerable then
		U.speed_mul(target, this.speed_factor)
	end

	this.modifier.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

local function mod_lynn_despair_remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit and target.motion then
		SU.remove_unit_damage_factor_by_factor(target, this.inflicted_damage_factor)

		if not target.motion.invulnerable then
			U.speed_div(target, this.speed_factor)
		end
	end

	return true
end

local function hero_lynn_fn_damage_melee(this, store, attack, target)
	local skill = this.hero.skills.hexfury
	local value = math.random(attack.damage_min, attack.damage_max)
	local mods = {"mod_lynn_curse", "mod_lynn_despair", "mod_lynn_ultimate", "mod_lynn_weakening"}

	if skill.level > 0 then
		for _, mod in ipairs(mods) do
			if U.has_modifier(store, target, mod) then
				value = value + skill.extra_damage
			end
		end
	end

	return value
end

local function hero_lynn_on_damage(this, store, damage)
	if math.random() < this.charm_of_unluck then
		return false
	end

	return true
end

local function hero_lynn_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "hexfury", function(this, s)
		this.melee.attacks[1].mod = "mod_lynn_curse"
		this.melee.attacks[2].mod = "mod_lynn_curse"
		this.melee.attacks[3].mod = "mod_lynn_curse"
		this.melee.attacks[3].loops = s.loops[s.level]
		this.melee.attacks[3].disabled = nil
	end)
	upgrade_skill(this, "despair", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.max_count = s.max_count[s.level]
		this.timed_attacks.list[2].max_count = s.max_count[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.speed_factor = s.speed_factor[s.level]
		m.inflicted_damage_factor = s.damage_factor[s.level]
		m = E:get_template("mod_lynn_despair_self")
		m.modifier.duration = s.duration[s.level]
		m.speed_factor = 2 - s.speed_factor[s.level]
		m.inflicted_damage_factor = 2 - s.damage_factor[s.level]
	end)
	upgrade_skill(this, "weakening", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max_count = s.max_count[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.armor_reduction = s.armor_reduction[s.level]
		m.magic_armor_reduction = s.magic_armor_reduction[s.level]
		m = E:get_template("mod_lynn_weakening_self")
		m.modifier.duration = s.duration[s.level]
		m.armor_reduction = -s.armor_reduction[s.level] * 0.5
		m.magic_armor_reduction = -s.magic_armor_reduction[s.level] * 0.5
	end)
	upgrade_skill(this, "charm_of_unluck", function(this, s)
		this.charm_of_unluck = s.chance[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local m = E:get_template("mod_lynn_ultimate")

		m.dps.damage_max = s.damage[s.level]
		m.dps.damage_min = s.damage[s.level]
		m.explode_damage = s.explode_damage[s.level]
		this.ultimate.curse_damage_all = s.damage[s.level] * 10
	end)
	update_hp(this)
end

local function hero_lynn_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	this.health_bar.hidden = false

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_183_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = U.find_biggest_enemy_in_range_filter_on(this.pos, this.timed_attacks.list[1].range, F_RANGED, F_NONE, function(e, origin)
					return e.health.hp <= this.ultimate.curse_damage_all * this.unit.damage_factor * e.health.damage_factor
				end)

				if enemy and enemy.pos then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.level = this.hero.skills.ultimate.level
					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.pos = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.despair

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local targets = U.find_enemies_in_range_filter_off(this.pos, a.range, a.vis_flags, a.vis_bans)

				if not targets or #targets < a.min_count then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
					-- block empty
					else
						SU.hero_gain_xp_from_skill(this, skill)

						a.ts = store.tick_ts
						targets = U.find_enemies_in_range_filter_off(this.pos, a.range * 1.2, a.vis_flags, a.vis_bans)

						if targets then
							for i, target in ipairs(targets) do
								if i > a.max_count then
									break
								end

								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								simulation:queue_insert_entity(m)
							end
						end

						local m = E:create_entity("mod_lynn_despair_self")

						m.modifier.source_id = this.id
						m.modifier.target_id = this.id

						simulation:queue_insert_entity(m)
						SU.y_hero_animation_wait(this)
					end

					goto label_183_0
				end
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.weakening

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local blocked = U.get_blocked(store, this)

				if not blocked or blocked.health.armor < 0.1 and blocked.health.magic_armor < 0.1 or not U.is_blocked_valid(store, this) then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound, a.sound_args)
					U.animation_start_default(this, a.animation, nil, store.tick_ts)

					if SU.y_soldier_wait(store, this, a.hit_time) then
					-- block empty
					else
						a.ts = store.tick_ts
						blocked = U.get_blocked(store, this)

						if blocked and U.is_blocked_valid(store, this) then
							SU.hero_gain_xp_from_skill(this, skill)

							local targets = U.find_enemies_in_range_filter_off(this.pos, a.range * 1.2, a.vis_flags, a.vis_bans)

							for i, target in ipairs(targets) do
								if i > a.max_count then
									break
								end

								local m = E:create_entity(a.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = target.id

								simulation:queue_insert_entity(m)
							end

							local m = E:create_entity("mod_lynn_weakening_self")

							m.modifier.source_id = this.id
							m.modifier.target_id = this.id

							simulation:queue_insert_entity(m)
						end

						SU.y_hero_animation_wait(this)
					end

					goto label_183_0
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

		::label_183_0::

		coroutine.yield()
	end
end

tt = RT("hero_lynn", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.4}
tt.hero.level_stats.magic_armor = {0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.4}
tt.hero.level_stats.hp_max = {350, 370, 390, 410, 430, 450, 470, 490, 510, 530}
tt.hero.level_stats.melee_damage_max = {14, 17, 19, 22, 24, 26, 29, 31, 34, 36}
tt.hero.level_stats.melee_damage_min = {10, 11, 13, 14, 16, 18, 19, 21, 22, 24}
tt.hero.skills.hexfury = CC("hero_skill")
tt.hero.skills.hexfury.extra_damage = 15
tt.hero.skills.hexfury.loops = {1, 2, 3, 4}
tt.hero.skills.hexfury.xp_gain = {30, 60, 90, 120}
tt.hero.skills.hexfury.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3,
	[10] = 4
}
tt.hero.skills.despair = CC("hero_skill")
tt.hero.skills.despair.duration = {4, 6, 8}
tt.hero.skills.despair.damage_factor = {0.9, 0.8, 0.7}
tt.hero.skills.despair.speed_factor = {0.7, 0.6, 0.5}
tt.hero.skills.despair.max_count = {5, 7, 9}
tt.hero.skills.despair.xp_gain = {25, 50, 100}
tt.hero.skills.despair.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.weakening = CC("hero_skill")
tt.hero.skills.weakening.duration = {4, 6, 8}
tt.hero.skills.weakening.armor_reduction = {0.1, 0.2, 0.3}
tt.hero.skills.weakening.magic_armor_reduction = {0.5, 0.7, 0.9}
tt.hero.skills.weakening.max_count = {5, 7, 9}
tt.hero.skills.weakening.xp_gain = {25, 50, 100}
tt.hero.skills.weakening.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.charm_of_unluck = CC("hero_skill")
tt.hero.skills.charm_of_unluck.chance = {0.15, 0.3, 0.45}
tt.hero.skills.charm_of_unluck.xp_gain = {10, 10, 10}
tt.hero.skills.charm_of_unluck.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_lynn_ultimate"
tt.hero.skills.ultimate.damage = {24, 34, 52, 70}
tt.hero.skills.ultimate.explode_damage = {80, 160, 200, 225}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 24
tt.charm_of_unluck = 0.15
tt.health.dead_lifetime = 15
tt.health.on_damage = hero_lynn_on_damage
tt.health_bar.offset = vec_2(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_lynn_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0012"
tt.info.portrait = "kr3_info_portraits_heroes_0012"
tt.main_script.update = hero_lynn_update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_lynn"
tt.soldier.melee_slot_offset = vec_2(0, -1)
tt.sound_events.change_rally_point = "ElvesHeroLynnTaunt"
tt.sound_events.death = "ElvesHeroLynnDeath"
tt.sound_events.hero_room_select = "ElvesHeroLynnTauntSelect"
tt.sound_events.insert = "ElvesHeroLynnTauntIntro"
tt.sound_events.respawn = "ElvesHeroLynnTauntIntro"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.cooldown = 1
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].xp_gain_factor = 2.7
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].animations = {nil, "hexfury"}
tt.melee.attacks[3].cooldown = 16
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].damage_max = 60
tt.melee.attacks[3].damage_min = 60
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].fn_damage = hero_lynn_fn_damage_melee
tt.melee.attacks[3].hit_times = {fts(13), fts(21)}
tt.melee.attacks[3].interrupt_loop_on_dead_target = true
tt.melee.attacks[3].sound_loop = "ElvesHeroLynnHexfury"
tt.melee.attacks[3].sound_loop_args = {
	delay = fts(3)
}
tt.melee.attacks[3].xp_from_skill = "hexfury"
tt.melee.attacks[3].xp_gain_factor = 5
tt.melee.range = 60
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "curseOfDespair"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(21)
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].mod = "mod_lynn_despair"
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].sound = "ElvesHeroLynnCurseDespair"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(4)
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "weakeningCurse"
tt.timed_attacks.list[2].cooldown = 14
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].hit_time = fts(21)
tt.timed_attacks.list[2].max_count = 5
tt.timed_attacks.list[2].mod = "mod_lynn_weakening"
tt.timed_attacks.list[2].range = 200
tt.timed_attacks.list[2].sound = "ElvesHeroLynnWeakening"
tt.ultimate = {
	ts = 0,
	cooldown = 24,
	disabled = true
}
tt = RT("hero_lynn_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_lynn_ultimate_update
tt.mod = "mod_lynn_ultimate"
tt.range = 50
tt.vis_flags = F_RANGED
tt.vis_bans = 0
tt.sound_events.insert = "ElvesHeroLynnFateSealed"
tt = RT("mod_lynn_curse", "modifier")
tt.modifier.chance = 0.25
tt.modifier.duration = 2
tt.main_script.insert = mod_lynn_curse_insert
tt.main_script.update = mod_lynn_curse_update
tt.main_script.remove = mod_lynn_curse_remove
tt = RT("mod_lynn_despair", "modifier")

AC(tt, "tween", "render")

tt.modifier.health_bar_offset = vec_2(0, 11)
tt.modifier.duration = 8
tt.speed_factor = 0.5
tt.inflicted_damage_factor = 0.7
tt.main_script.insert = mod_lynn_despair_insert
tt.main_script.remove = mod_lynn_despair_remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_lynn_despair"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_despair_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt = RT("mod_lynn_despair_self", "mod_lynn_despair")
tt.speed_factor = 2 - tt.speed_factor
tt.inflicted_damage_factor = 2 - tt.inflicted_damage_factor
tt = RT("mod_lynn_weakening", "modifier")

AC(tt, "tween", "render")

tt.armor_reduction = 0.7
tt.magic_armor_reduction = 0.7
tt.main_script.insert = mod_lynn_weakening_insert
tt.main_script.remove = mod_lynn_weakening_remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 8
tt.modifier.health_bar_offset = vec_2(0, 11)
tt.render.sprites[1].name = "mod_lynn_weakening"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_lynn_weakening_decal_loop"
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt = RT("mod_lynn_weakening_self", "mod_lynn_weakening")
tt.armor_reduction = -tt.armor_reduction * 0.5
tt.magic_armor_reduction = -tt.magic_armor_reduction * 0.5
