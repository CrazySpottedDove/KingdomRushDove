local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local valid_land_node_nearby = HU.valid_land_node_nearby
local tt

local function hero_xin_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nodes < 1 then
		log.error("hero_xin_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node = {
		spi = 1,
		pi = nodes[1][1],
		ni = nodes[1][3]
	}
	local node_pos = P:node_pos(node.pi, node.spi, node.ni)
	local count = this.count
	local target, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, this.range, fts(10), this.vis_flags, this.vis_bans)
	local idx = 1

	while count > 0 do
		local e = E:create_entity(this.entity)

		if targets then
			target = targets[km.zmod(idx, #targets)]
			idx = idx + 1

			if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
				local m = E:create_entity("mod_xin_stun")

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				simulation:queue_insert_entity(m)
			end

			if band(target.vis.flags, F_BLOCK) ~= 0 then
				U.block_enemy(store, e, target)
			else
				e.unblocked_target_id = target.id
			end

			local lpos, lflip = U.melee_slot_position(e, target, 1)

			e.pos.x, e.pos.y = lpos.x, lpos.y
			e.render.sprites[1].flip_x = lflip
		else
			local nni = node.ni + math.random(-10, 10)
			local nspi = math.random(1, 3)
			local npos = P:node_pos(node.pi, nspi, nni)

			if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
				npos = node_pos
			end

			e.pos.x, e.pos.y = npos.x, npos.y
		end

		e.nav_rally.center = V.vclone(e.pos)
		e.nav_rally.pos = V.vclone(e.pos)

		simulation:queue_insert_entity(e)

		count = count - 1

		U.y_wait_unconditional(store, this.spawn_delay)
	end

	simulation:queue_remove_entity(this)
end

local function hero_xin_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "daring_strike", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "inspire", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = store.tick_ts

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "mind_over_body", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.ts = store.tick_ts
		this.mind_over_body_damage_buff_max = s.damage_buff[s.level]
		this.mind_over_body_duration = s.duration[s.level]

		local m = E:get_template(a.mod)

		m.modifier.duration = s.duration[s.level]
		m.hps.heal_every = s.heal_every[s.level]
		m.hps.heal_min = s.heal_hp[s.level]
		m.hps.heal_max = s.heal_hp[s.level]
	end)
	upgrade_skill(this, "panda_style", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_xin_ultimate")

		u.count = s.count[s.level]

		local e = E:get_template(u.entity)

		for _, ma in ipairs(e.melee.attacks) do
			ma.damage_max = s.damage[s.level]
			ma.damage_min = s.damage[s.level]
		end
	end)
	update_hp(this)
end

local function hero_xin_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local mod_clear_ts = store.tick_ts

	while true do
		if this.mind_over_body_active and store.tick_ts - this.mind_over_body_last_ts >= this.mind_over_body_duration then
			this.unit.damage_buff = this.unit.damage_buff - this.mind_over_body_damage_buff
			this.mind_over_body_active = false
			this.melee.attacks[3].ts = this.melee.attacks[3].ts - this.melee.attacks[3].cooldown * 0.1
			this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - this.timed_attacks.list[1].cooldown * 0.1
			this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - this.timed_attacks.list[2].cooldown * 0.1
		end

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				-- if SU.y_hero_new_rally(store, this) then
				--     goto label_126_1
				-- end
				this.motion.arrived = false
				a = this.timed_attacks.list[1]

				local initial_flip = this.render.sprites[1].flip_x
				local shadow

				S:queue(a.sounds[1])
				U.animation_start_default(this, a.animations[1], nil, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)

				this.health_bar.hidden = true

				if U.is_blocked_valid(store, this) then
					local blocked = store.entities[this.soldier.target_id]
					local m = E:create_entity("mod_xin_stun")

					m.modifier.target_id = blocked.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)

					shadow = E:create_entity("soldier_xin_shadow")
					shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y

					shadow.nav_rally.center:copy(this.pos)
					shadow.nav_rally.pos:copy(this.pos)

					shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					simulation:queue_insert_entity(shadow)
					U.replace_blocker(store, this, shadow)
				end

				U.y_animation_wait_default(this)

				this.health_bar.hidden = nil
				this.pos.x = this.nav_rally.pos.x
				this.pos.y = this.nav_rally.pos.y

				SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)

				if shadow then
					shadow.health.dead = true
				end

				this.nav_rally.new = false
				this.motion.arrived = true
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if this.mind_over_body_active and store.tick_ts - mod_clear_ts > fts(10) then
				local mods = U.find_modifiers_with_flags(this, bor(F_POISON, F_STUN, F_BLOOD))

				mod_clear_ts = store.tick_ts

				for _, mod in ipairs(mods) do
					mod.modifier.removed_by_ban = true

					simulation:queue_remove_entity(mod)
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.mind_over_body

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and this.health.hp / this.health.hp_max <= a.min_health_factor then
				SU.hero_gain_xp_from_skill(this, skill)

				this.health.ignore_damage = true

				U.animation_start_default(this, a.animation, nil, store.tick_ts)
				U.y_wait_unconditional(store, a.cast_time)
				S:queue(a.sound)
				SU.insert_sprite(store, "decal_xin_drink_circle", this.pos)

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)

				this.mind_over_body_active = true
				this.mind_over_body_damage_buff = this.mind_over_body_damage_buff_max
				this.mind_over_body_last_ts = store.tick_ts
				this.unit.damage_buff = this.unit.damage_buff + this.mind_over_body_damage_buff

				U.y_animation_wait_default(this)

				this.health.ignore_damage = false
				a.ts = store.tick_ts
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.inspire

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local enemies = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not enemies then
					a.ts = a.ts + 0.3333333333333333
				else
					local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

					this.health.ignore_damage = true

					U.animation_start_default(this, a.animation, nil, store.tick_ts)
					U.y_wait_unconditional(store, a.cast_time)
					S:queue(a.sound)
					SU.insert_sprite(store, "decal_xin_inspire", this.pos)

					for i = 1, #soldiers do
						local soldier = soldiers[i]
						local m = E:create_entity(a.mod)

						m.modifier.target_id = soldier.id
						m.modifier.source_id = this.id
						m.modifier.ts = store.tick_ts

						simulation:queue_insert_entity(m)
					end

					U.y_animation_wait_default(this)
					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts
					this.health.ignore_damage = false
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.daring_strike

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local blocked_enemy = this.soldier.target_id and store.entities[this.soldier.target_id]

				if not blocked_enemy and SU.soldier_pick_melee_target(store, this) then
					a.ts = a.ts + 0.3333333333333333

					goto label_126_0
				end

				local targets = U.find_enemies_between_range_filter_on(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(e)
					local ni_s = P:get_visible_start_node(e.nav_path.pi)
					local ni_e = P:get_visible_end_node(e.nav_path.pi)

					return e ~= blocked_enemy and e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e - a.node_margin
				end)

				if not targets then
					a.ts = a.ts + 0.3333333333333333

					goto label_126_0
				end

				table.sort(targets, function(e1, e2)
					return e1.health.hp > e2.health.hp
				end)

				local target = targets[1]
				local initial_pos = V.vclone(this.pos)
				local initial_flip = this.render.sprites[1].flip_x
				local shadow

				U.bans_add(this.vis, F_ALL)

				this.health.ignore_damage = true

				S:queue(a.sounds[1])
				U.animation_start_default(this, a.animations[1], nil, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)

				-- U.y_wait_unconditional(store, fts(14))
				this.health_bar.hidden = true

				-- U.y_wait_unconditional(store, fts(3))
				if U.is_blocked_valid(store, this) then
					local blocked = store.entities[this.soldier.target_id]
					local m = E:create_entity("mod_xin_stun")

					m.modifier.target_id = blocked.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)

					shadow = E:create_entity("soldier_xin_shadow")
					shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y

					shadow.nav_rally.center:copy(this.pos)
					shadow.nav_rally.pos:copy(this.pos)

					shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					simulation:queue_insert_entity(shadow)
					U.replace_blocker(store, this, shadow)
				end

				U.y_animation_wait_default(this)

				local m = E:create_entity("mod_xin_stun")

				m.modifier.target_id = target.id
				m.modifier.source_id = this.id

				simulation:queue_insert_entity(m)

				local lpos, lflip = U.melee_slot_position(this, target, 2)

				this.pos.x, this.pos.y = lpos.x, lpos.y

				U.animation_start_default(this, a.animations[2], lflip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_hit", this.pos, lflip)
				-- U.y_wait_unconditional(store, fts(5))
				S:queue(a.sounds[2])

				this.health_bar.hidden = nil

				queue_damage(store, SU.create_attack_damage(a, target.id, this))
				U.y_animation_wait_default(this)

				if target and not target.health.dead then
					U.animation_start_default(this, a.animations[3], lflip, store.tick_ts)
					queue_damage(store, SU.create_attack_damage(a, target.id, this))
					U.y_animation_wait_default(this)
				end

				if target and not target.health.dead then
					local m = E:create_entity(a.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id
					m.modifier.ts = store.tick_ts

					simulation:queue_insert_entity(m)
				end

				this.health_bar.hidden = true

				U.animation_start_default(this, a.animations[4], lflip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_hit_out", this.pos, lflip)
				U.y_animation_wait_default(this)

				if this.nav_rally.new then
					this.nav_rally.new = false
					this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
				else
					this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
				end

				S:queue(a.sounds[5])
				U.animation_start_default(this, a.animations[5], initial_flip, store.tick_ts)
				SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)

				if shadow then
					shadow.health.dead = true

					U.replace_blocker(store, shadow, this)
				end

				-- U.y_wait_unconditional(store, fts(5))
				this.health_bar.hidden = nil

				U.bans_remove(this.vis, F_ALL)

				this.health.ignore_damage = nil

				U.y_animation_wait_default(this)
				SU.hero_gain_xp_from_skill(this, skill)

				a.ts = store.tick_ts
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ultimate.range, F_RANGED, F_NONE)

				if target and target.pos and valid_land_node_nearby(target.pos) then
					this.health.ignore_damage = true

					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

					this.health.ignore_damage = false

					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(target.pos)

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			::label_126_0::

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

		::label_126_1::

		coroutine.yield()
	end
end

tt = RT("hero_xin", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25}
tt.hero.level_stats.hp_max = {330, 360, 390, 420, 450, 480, 510, 540, 570, 600}
tt.hero.level_stats.melee_damage_max = {14, 17, 20, 23, 25, 28, 31, 33, 36, 40}
tt.hero.level_stats.melee_damage_min = {10, 11, 13, 15, 17, 19, 20, 22, 24, 25}
tt.hero.skills.daring_strike = CC("hero_skill")
tt.hero.skills.daring_strike.damage_max = {70, 140, 210}
tt.hero.skills.daring_strike.damage_min = {50, 100, 150}
tt.hero.skills.daring_strike.xp_gain_factor = 66
tt.hero.skills.daring_strike.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.inspire = CC("hero_skill")
tt.hero.skills.inspire.duration = {4, 6, 8}
tt.hero.skills.inspire.xp_gain_factor = 55
tt.hero.skills.inspire.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.mind_over_body = CC("hero_skill")
tt.hero.skills.mind_over_body.duration = {4, 7, 10}
tt.hero.skills.mind_over_body.heal_every = {fts(5), fts(5), fts(5)}
tt.hero.skills.mind_over_body.heal_hp = {4, 6, 8}
tt.hero.skills.mind_over_body.damage_buff = {14, 23, 31}
tt.hero.skills.mind_over_body.xp_gain_factor = 55
tt.hero.skills.mind_over_body.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.panda_style = CC("hero_skill")
tt.hero.skills.panda_style.damage_max = {55, 100, 140}
tt.hero.skills.panda_style.damage_min = {30, 55, 80}
tt.hero.skills.panda_style.xp_gain_factor = 88
tt.hero.skills.panda_style.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_xin_ultimate"
tt.hero.skills.ultimate.count = {2, 4, 5, 6}
tt.hero.skills.ultimate.damage = {45, 60, 80, 90}
tt.hero.skills.ultimate.xp_gain_factor = 24
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_xin_level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.hero_portrait = "kr3_hero_portraits_0009"
tt.info.portrait = "kr3_info_portraits_heroes_0009"
tt.main_script.update = hero_xin_update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt.render.sprites[1].prefix = "hero_xin"
tt.soldier.melee_slot_offset = vec_2(12, 0)
tt.sound_events.change_rally_point = "ElvesHeroXinTaunt"
tt.sound_events.death = "ElvesHeroXinDeath"
tt.sound_events.respawn = "ElvesHeroXinTauntIntro"
tt.sound_events.insert = "ElvesHeroXinTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroXinTauntSelect"
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 23)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].xp_gain_factor = 4.3
tt.melee.attacks[1].sound_hit = "ElvesHeroXinPoleHit"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].side_effect = function(this, store, damage, target)
	this.timed_attacks.list[3].ts = this.timed_attacks.list[3].ts - this.timed_attacks.list[3].cooldown * 0.1
end
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].side_effect = function(this, store, damage, target)
	if this.mind_over_body_active then
		this.melee.attacks[3].ts = this.melee.attacks[3].ts - this.melee.attacks[3].cooldown * 0.1
		this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - this.timed_attacks.list[1].cooldown * 0.1
		this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - this.timed_attacks.list[2].cooldown * 0.1
		this.ultimate.ts = this.ultimate.ts - this.ultimate.cooldown * 0.1
	end
end
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "buttStrike"
tt.melee.attacks[3].cooldown = 25
tt.melee.attacks[3].count = 999
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 60
tt.melee.attacks[3].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_fx = "fx_xin_panda_style_smoke"
tt.melee.attacks[3].hit_time = fts(19)
tt.melee.attacks[3].sound = "ElvesHeroXinPandaStyle"
tt.melee.attacks[3].xp_from_skill = "panda_style"
tt.melee.range = 65
tt.nav_grid.ignore_waypoints = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"teleport_out", "teleport_hit", "teleport_hit2", "teleport_hit_out", "teleport_in"}
tt.timed_attacks.list[1].sounds = {"ElvesHeroXinAfterTeleportOut", "ElvesHeroXinDaringStrikeHit", nil, nil, "ElvesHeroXinAfterTeleportIn"}
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].max_range = 9999
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].node_margin = 10
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].mod = "mod_xin_slow"
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "inspire"
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].max_range = 90
tt.timed_attacks.list[2].mod = "mod_xin_inspire"
tt.timed_attacks.list[2].sound = "ElvesHeroXinInspire"
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3] = CC("mod_attack")
tt.timed_attacks.list[3].animation = "drink"
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cooldown = 20
tt.timed_attacks.list[3].min_health_factor = 0.7
tt.timed_attacks.list[3].mod = "mod_xin_mind_over_body"
tt.timed_attacks.list[3].cast_time = fts(15)
tt.timed_attacks.list[3].sound = "ElvesHeroXinMindOverBody"
tt.ultimate = {
	ts = 0,
	cooldown = 24,
	disabled = true,
	range = 180
}
tt.mind_over_body_last_ts = 0
tt.mind_over_body_active = false
tt.mind_over_body_damage_buff_max = 0
tt.mind_over_body_damage_buff = 0
tt.mind_over_body_duration = 0
tt = RT("hero_xin_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 24
tt.range = 125
tt.spawn_delay = 0.5
tt.main_script.update = hero_xin_ultimate_update
tt.sound_events.insert = "ElvesHeroXinPandamonium"
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FLYING)
tt.entity = "soldier_xin_ultimate"
tt = RT("mod_xin_stun", "mod_stun")
tt.modifier.duration = 1.3
tt = RT("mod_xin_inspire", "modifier")

AC(tt, "render")

tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 2
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_xin_inspire"
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_xin_mind_over_body", "modifier")

AC(tt, "render", "hps")

tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = nil
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.use_mod_offset = false
tt.modifier.remove_banned = true
tt.modifier.ban_types = {MOD_TYPE_BLEED, MOD_TYPE_POISON, MOD_TYPE_STUN}
tt.render.sprites[1].name = "fx_xin_drink_bubbles"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "xin_hero_drink_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt = RT("mod_xin_slow", "mod_slow")
tt.modifier.duration = 6
tt = RT("fx_xin_smoke_teleport_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_xin_smoke_teleport_hit", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_xin_smoke_teleport_hit_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_xin_smoke_teleport_in", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_in"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_xin_panda_style_smoke", "fx")
tt.render.sprites[1].name = "fx_xin_panda_style_smoke"
tt.render.sprites[1].anchor.y = 0.4
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_xin_inspire", "decal_tween")
tt.render.sprites[1].name = "xin_hero_scream_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 63}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {fts(10), vec_1(0.68)}, {fts(20), vec_1(1.25)}}
tt = RT("decal_xin_drink_circle", "decal_tween")
tt.render.sprites[1].name = "xin_hero_drink_auraCircle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.7)}, {fts(20), vec_1(1.5)}}
