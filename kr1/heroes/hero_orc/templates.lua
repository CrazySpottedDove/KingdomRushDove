local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
local V = require("lib.klua.vector")
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function aura_hero_orc_aimed_slash_update(this, store)
	local a = this.aura
	local target = store.entities[a.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local last_buff_level = 0

	a.ts = store.tick_ts

	local upgrade_ts = store.tick_ts

	while store.entities[target.id] do
		if store.tick_ts - a.ts > a.cycle_time then
			a.ts = store.tick_ts

			if target.soldier.target_id then
				if last_buff_level == 0 then
					upgrade_ts = store.tick_ts - this.upgrade_cycle_time
				end

				if store.tick_ts - upgrade_ts >= this.upgrade_cycle_time and last_buff_level < this.max_buff_level then
					SU.insert_unit_damage_factor_buff(target, this.damage_factor_inc)

					last_buff_level = last_buff_level + 1
					upgrade_ts = store.tick_ts
					this.render.sprites[1].hidden = false
				end
			else
				if last_buff_level > 0 then
					SU.remove_unit_damage_factor_buff(target, this.damage_factor_inc)

					last_buff_level = last_buff_level - 1
					upgrade_ts = store.tick_ts

					if last_buff_level <= 0 then
						this.render.sprites[1].hidden = true
					end
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function hero_orc_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[4].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[4].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "duelist", function(this, s)
		this.melee.attacks[3].disabled = nil
		this.melee.attacks[3].damage_min = s.damage_config[s.level]
		this.melee.attacks[3].damage_max = s.damage_config[s.level]
	end)
	upgrade_skill(this, "brute_force", function(this, s)
		this.melee.attacks[4].disabled = nil
		this.melee.attacks[4].cooldown = s.cooldown[s.level]

		local e = E:get_template(this.melee.attacks[4].mod)

		e.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "inspiring_leader", function(this, s)
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].cooldown = s.cooldown[s.level]

		local e = E:get_template(this.timed_attacks.list[1].entity)

		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.health.hp_max = s.hp_max[s.level]
	end)
	upgrade_skill(this, "aimed_slash", function(this, s)
		E:get_template("aura_hero_orc_aimed_slash").max_buff_level = s.max_buff_level[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local e = E:get_template("soldier_hero_orc_spear_goblin")

		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.health.hp_max = s.hp_max[s.level]
		e = E:get_template(e.ranged.attacks[1].bullet)
		e.bullet.damage_min = s.ranged_damage_min[s.level]
		e.bullet.damage_max = s.ranged_damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_orc_update(this, store)
	local h = this.health
	local sa = this.timed_attacks.list[1]

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	do
		local e = E:create_entity("aura_hero_orc_regen")

		e.aura.source_id = this.id

		simulation:queue_insert_entity(e)

		e = E:create_entity("aura_hero_orc_aimed_slash")
		e.aura.source_id = this.id
		e.aura.target_id = this.id
		e.pos = this.pos

		simulation:queue_insert_entity(e)

		e = E:get_template("user_power_2")

		if not e._hero_orc_ultimate_applied then
			local origin_insert = e.main_script.insert

			e.main_script.insert = function(this, store)
				e = E:create_entity("fx_hero_orc_ultimate")

				e.pos:copy(this.pos)

				e.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(e)

				e = E:create_entity("soldier_hero_orc_spear_goblin")

				e.pos:copy(this.pos)
				e.nav_rally.center:copy(this.pos)
				e.nav_rally.pos:copy(this.pos)
				simulation:queue_insert_entity(e)

				return origin_insert(this, store)
			end
			e._hero_orc_ultimate_applied = true
		end
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			local e = E:create_entity("aura_hero_orc_regen")

			e.aura.source_id = this.id

			simulation:queue_insert_entity(e)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto continue
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts)
			end

			if ready_to_use_skill(sa, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, this.melee.range, sa.vis_flags, sa.vis_bans)

				if target then
					S:queue(sa.sound)
					U.animation_start_once_specific(this, sa.animation, target.pos.x < this.pos.x, store.tick_ts, 1)

					if SU.y_hero_wait(store, this, sa.spawn_time) then
						goto continue
					end

					sa.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.inspiring_leader)

					local ni = P:nearest_node_with_nav_path_info(this.pos, target.nav_path)

					for i = 1, sa.count do
						local e = E:create_entity(sa.entity)

						e.pos:copy(P:node_pos_ref(target.nav_path.pi, km.zmod(i + 1, 3), ni))
						e.nav_rally.center:copy(e.pos)
						e.nav_rally.pos:copy(e.pos)
						simulation:queue_insert_entity(e)
					end

					if SU.y_hero_animation_wait(this) then
						goto continue
					end
				else
					sa.ts = sa.ts + 0.1
				end
			end

			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::continue::

		coroutine.yield()
	end
end

tt = RT("hero_orc", "hero")

AC(tt, "melee", "timed_attacks")

tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_orc_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr4_hero_portraits_0001"
tt.info.portrait = "kr4_info_portraits_heroes_0001"
tt.main_script.update = hero_orc_update
tt.motion.max_speed = 90
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_orc"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_orc_shadow"
tt.render.sprites[2].anchor.y = 0.12
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "group_orc_taunt"
tt.sound_events.death = "hero_orc_death"
tt.sound_events.hero_room_select = "hero_orc_taunt_1"
tt.sound_events.insert = "hero_orc_taunt_1"
tt.sound_events.respawn = "hero_orc_taunt_1"
tt.hero.level_stats.armor = {0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.24, 0.26, 0.28, 0.3}
tt.hero.level_stats.hp_max = {240, 276, 312, 348, 384, 420, 456, 492, 528, 564}
tt.hero.level_stats.melee_damage_max = {19, 22, 25, 28, 31, 34, 37, 40, 43, 46}
tt.hero.level_stats.melee_damage_min = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
tt.regen.cooldown = 1
tt.hero.skills.duelist = CC("hero_skill")
tt.hero.skills.duelist.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.duelist.xp_gain = {120, 240, 360}
tt.hero.skills.duelist.damage_config = {90, 135, 180}
tt.hero.skills.brute_force = CC("hero_skill")
tt.hero.skills.brute_force.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.brute_force.xp_gain = {120, 240, 360}
tt.hero.skills.brute_force.duration = {2, 3, 4}
tt.hero.skills.brute_force.cooldown = {16, 15, 14}
tt.hero.skills.aimed_slash = CC("hero_skill")
tt.hero.skills.aimed_slash.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.aimed_slash.max_buff_level = {3, 4, 5}
tt.hero.skills.inspiring_leader = CC("hero_skill")
tt.hero.skills.inspiring_leader.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.inspiring_leader.xp_gain = {90, 180, 270}
tt.hero.skills.inspiring_leader.cooldown = {12, 10.5, 9}
tt.hero.skills.inspiring_leader.hp_max = {50, 70, 90}
tt.hero.skills.inspiring_leader.damage_min = {3, 5, 7}
tt.hero.skills.inspiring_leader.damage_max = {4, 7, 10}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.hp_max = {90, 120, 150, 180}
tt.hero.skills.ultimate.damage_min = {16, 20, 24, 28}
tt.hero.skills.ultimate.damage_max = {18, 26, 34, 42}
tt.hero.skills.ultimate.ranged_damage_min = {11, 17, 23, 29}
tt.hero.skills.ultimate.ranged_damage_max = {13, 23, 33, 43}
-- 近战攻击
tt.melee.range = 60
tt.ui.click_rect = r(-23, -5, 46, 50)
tt.unit.head_offset = v(0, 48)
tt.unit.hit_offset = v(0, 30)
tt.unit.mod_offset = v(0, 30)
tt.soldier.melee_slot_offset = v(18, 0)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2.3
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].animation = "melee2"
tt.melee.attacks[3] = CC("melee_attack")
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].sound = "hero_orc_slash"
tt.melee.attacks[3].animations = {nil, "slash"}
tt.melee.attacks[3].loops = 1
tt.melee.attacks[3].hit_times = {fts(11), fts(27)}
tt.melee.attacks[3].damage_type = DAMAGE_RUDE
tt.melee.attacks[3].cooldown = 15
tt.melee.attacks[3].xp_from_skill = "duelist"
tt.melee.attacks[3].damage_min = 90
tt.melee.attacks[3].damage_max = 90
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "stun"
tt.melee.attacks[4].mod = "mod_veruk_stun"
tt.melee.attacks[4].sound = "hero_orc_bruteforce"
tt.melee.attacks[4].damage_radius = 65
tt.melee.attacks[4].xp_from_skill = "brute_force"
tt.melee.attacks[4].damage_type = DAMAGE_RUDE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].cooldown = 20
tt.melee.attacks[4].hit_decal = "decal_hero_orc_stun"
tt.melee.attacks[4].hit_offset = v(22, 0)
tt.melee.attacks[4].hit_time = fts(15)
tt.melee.attacks[4].vis_flags = bor(F_BLOCK)
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_hero_orc_goblin"
tt.timed_attacks.list[1].count = 3
tt.timed_attacks.list[1].cooldown = 12
tt.timed_attacks.list[1].spawn_time = fts(10)
tt.timed_attacks.list[1].sound = "hero_orc_leader"
tt.timed_attacks.list[1].animation = "call"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_BLOCK)
tt.timed_attacks.list[1].xp_from_skill = "inspiring_leader"
tt = RT("aura_hero_orc_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = 1
tt.regen.health = 18
tt.regen.ignore_stun = true
tt.regen.ignore_mods = true
tt = RT("aura_hero_orc_aimed_slash", "aura")

AC(tt, "render")

tt.render.sprites[1].name = "aura_hero_orc_aimed_slash_run"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].offset = v(0, 5)
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = aura_hero_orc_aimed_slash_update
tt.damage_factor_inc = 0.24
tt.upgrade_cycle_time = 4
tt.max_buff_level = 3
tt = RT("decal_hero_orc_stun", "decal_timed")
tt.render.sprites[1].name = "hero_orc_stun_decal_run"
tt = RT("mod_veruk_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 1
tt = RT("soldier_hero_orc_goblin", "soldier_militia")

AC(tt, "reinforcement", "tween", "nav_grid")

tt.controable = true
tt.controable_other = true
tt.health.hp_max = 35
tt.health_bar.offset = v(0, 32)
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 29)
tt.unit.mod_offset = v(0, 16)
tt.unit.marker_offset = v(0, 0)
tt.info.portrait = "kr4_info_portraits_soldiers_0016"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.motion.max_speed = 85
tt.render.sprites[1].prefix = "reinforcement_goblin"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_orc_spear_goblin_shadow"
tt.render.sprites[2].anchor.y = 0.125
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(16, 0)
tt.melee.range = 75
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].hit_time = fts(8)
tt.regen.health = 0
tt.regen.cooldown = 2
tt.reinforcement.duration = 10
tt.ui.click_rect = r(-20, -5, 40, 28)
tt.reinforcement.fade_out = true
tt.reinforcement.fade = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.tween.disabled = true
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("soldier_hero_orc_spear_goblin", "soldier_hero_orc_goblin")

AC(tt, "ranged")

tt.render.sprites[1].prefix = "hero_orc_spear_goblin"
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 11
tt.info.portrait = "kr4_info_portraits_soldiers_0020"
tt.health.hp_max = 70
tt.controable_other = nil
tt.regen.health = nil
tt.reinforcement.duration = 16
tt.melee.range = 60
tt.melee.attacks[1].hit_time = fts(12)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "arrow_soldier_hero_orc_spear_goblin"
tt.ranged.attacks[1].bullet_start_offset = {v(6, 12)}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].check_target_before_shot = true
tt = RT("arrow_soldier_hero_orc_spear_goblin", "arrow")
tt.bullet.damage_max = 11
tt.bullet.damage_min = 5
tt.bullet.flight_time = fts(20)
tt.bullet.flip_x = true
tt.render.sprites[1].name = "hero_orc_spear_goblin_proyectile"
tt.render.sprites[1].scale = v(-1, 1)
tt.bullet.miss_decal = "hero_orc_spear_goblin_proyectile_decal_0007"
tt.bullet.miss_decal_anchor = v(1, 0.5)
tt.bullet.miss_decal_rotation = 0.5 * math.pi
tt = RT("fx_hero_orc_ultimate", "fx")
tt.render.sprites[1].name = "hero_orc_spear_goblin_fx_run"
