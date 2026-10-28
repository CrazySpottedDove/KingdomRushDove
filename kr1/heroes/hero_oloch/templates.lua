local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local km = require("lib.klua.macros")
local apply_ultimate = HU.apply_ultimate
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function oloch_magma_update(this, store)
	local b = this.bullet

	U.sprites_hide(this)
	U.y_wait_unconditional(store, this.delay)
	U.sprites_show(this)

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start_once_specific_no_flip(this, "run", store.tick_ts, 1)

	this.tween.ts = store.tick_ts

	U.y_wait_unconditional(store, fts(15))

	local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in ipairs(targets) do
			local d = SU.create_bullet_damage_without_pops(b, target.id, this.id)

			queue_damage(store, d)
		end
	end

	local p = E:create_entity(b.hit_payload)

	p.pos.x, p.pos.y = this.pos.x, this.pos.y
	p.render.sprites[1].ts = 0

	simulation:queue_insert_entity(p)
	U.y_wait_unconditional(store, fts(10))
	simulation:queue_remove_entity(this)
end

local function mod_oloch_heat_update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	m.ts = store.tick_ts
	this.tween.ts = store.tick_ts

	while store.tick_ts - m.ts < m.duration do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function hero_oloch_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)

	if #nodes < 1 then
		return false
	end

	local pi, spi, ni = unpack(nodes[1])
	local npos = P:node_pos_ref(pi, spi, ni)

	S:queue(this.sound_cast)

	local d = E:create_entity(this.teleport_decal)

	d.pos = V.vclone(npos)
	d.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(d)
	U.y_wait_unconditional(store, fts(5))

	local target, targets = U.find_nearest_enemy(store, npos, 0, this.radius, this.vis_flags, this.vis_bans)

	if not target then
		return true
	end

	local num_targets = math.min(#targets, this.max_targets)

	S:queue(this.sound_teleport_in)
	S:queue(this.sound_teleport_out, {
		delay = E:get_template(this.mod_teleport).hold_time
	})

	for i = 1, num_targets do
		local t = targets[i]
		local mod_teleport = E:create_entity(this.mod_teleport)

		mod_teleport.modifier.level = this.level
		mod_teleport.modifier.target_id = t.id
		mod_teleport.modifier.source_id = this.id

		simulation:queue_insert_entity(mod_teleport)
	end

	simulation:queue_remove_entity(this)
end

local function hero_oloch_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]
	this.selfdestruct.damage_min = ls.selfdestruct_damage_config[hl]
	this.selfdestruct.damage_max = ls.selfdestruct_damage_config[hl]

	local e = E:get_template(this.timed_attacks.list[1].entity)

	e.selfdestruct.damage_min = ls.selfdestruct_damage_config[hl] * 0.4
	e.selfdestruct.damage_max = ls.selfdestruct_damage_config[hl] * 0.4

	upgrade_skill(this, "duplication", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local e = E:get_template("bolt_oloch_duplication")

		e.bullet.damage_max = s.damage_max[s.level]
		e.bullet.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "magma_eruption", function(this, s)
		this.timed_attacks.list[2].disabled = nil

		local e = E:get_template(this.timed_attacks.list[2].entity)

		e.bullet.damage_min = s.damage_config[s.level]
		e.bullet.damage_max = s.damage_config[s.level]

		local p = E:get_template(e.bullet.hit_payload)
		local a = E:get_template(p.aura.mod)

		a.dps.damage_min = s.damage_aura_config[s.level]
		a.dps.damage_max = s.damage_aura_config[s.level]
	end)
	upgrade_skill(this, "hellish_infusion", function(this, s)
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown[s.level]

		local m = E:get_template(this.timed_attacks.list[3].mod)

		m.damage_factor = s.damage_factor_config[s.level]
	end)
	upgrade_skill(this, "demonic_blast", function(this, s)
		this.ranged.attacks[2].disabled = nil

		local b = E:get_template(this.ranged.attacks[2].bullet)

		b.bullet.damage_max = s.damage_max[s.level]
		b.bullet.damage_min = s.damage_min[s.level]

		local e = E:get_template(this.timed_attacks.list[1].entity)

		e.ranged.attacks[2].disabled = nil

		local b2 = E:get_template(e.ranged.attacks[2].bullet)

		b2.bullet.damage_max = s.damage_max[s.level] * 0.6
		b2.bullet.damage_min = s.damage_min[s.level] * 0.6
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.cooldown = s.cooldown[s.level]
		this.ultimate.disabled = nil

		local e = E:get_template("mod_hero_oloch_ultimate_teleport")

		e.nodes_offset = s.offset_config[s.level]
	end)
	update_hp(this)
end

local function hero_oloch_update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, brk, sta
	local ha = this.timed_attacks.list[3]

	U.y_animation_play_once_specific_no_flip(this, "levelup", store.tick_ts, 1)

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
					goto label_40884_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play_once_specific_no_flip(this, "levelup", store.tick_ts, 1)
			end

			-- 大招
			if ready_to_use_skill(this.ultimate, store) then
				local target = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_BOSS, nil, nil, nil)

				if target then
					apply_ultimate(this, store, target.pos, "levelup")
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			-- 1技能 分身
			skill = he.skills.duplication
			a = this.timed_attacks.list[1]

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if target then
					S:queue(a.sound)
					U.animation_start_once_specific(this, a.animation, target.pos.x < this.pos.x, store.tick_ts, 1)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_40884_0
					end

					SU.hero_gain_xp_from_skill(this, skill)

					a.ts = store.tick_ts

					for i = 1, a.count do
						local angle = 2 * math.pi * i / a.count
						local o = V.v(V.rotate(angle, a.initial_pos.x, a.initial_pos.y))
						local r = V.v(V.rotate(angle, a.initial_rally.x, a.initial_rally.y))
						local e = E:create_entity(a.entity)
						local rx, ry = this.pos.x + r.x, this.pos.y + r.y

						e.nav_rally.center = V.v(rx, ry)
						e.nav_rally.pos = V.v(rx, ry)
						e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
						e.tween.ts = store.tick_ts
						e.tween.props[1].keys[1][2].x = -o.x
						e.tween.props[1].keys[1][2].y = -o.y + e.tween.props[1].keys[1][2].y
						e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
						e.owner = this

						simulation:queue_insert_entity(e)
					end

					if SU.y_hero_animation_wait(this) then
						goto label_40884_0
					end
				else
					a.ts = a.ts + 0.1
				end
			end

			-- 2技能 岩浆池
			a = this.timed_attacks.list[2]
			skill = he.skills.magma_eruption

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.1
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.1
					else
						local s_pi, _, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x

						U.animation_start_once_specific(this, a.animation, flip, store.tick_ts, 1)

						if SU.y_hero_wait(store, this, a.spawn_time) then
							goto label_40884_0
						end

						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -4 or 4

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

						for i = 1, skill.count[skill.level] do
							local e = E:create_entity(a.entity)

							e.pos = P:node_pos(pi, spi, ni)
							e.render.sprites[1].prefix = e.render.sprites[1].prefix
							e.render.sprites[1].flip_x = not flip
							e.delay = delay
							e.bullet.source_id = this.id
							e.bullet.level = skill.level
							e.bullet.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(e)

							delay = delay + fts(U.frandom(1, 3))
							ni = ni + n_step
							spi = km.zmod(spi + math.random(1, 2), 3)

							U.y_wait_unconditional(store, fts(5) * this.unit.cooldown_factor)
						end

						if SU.y_hero_animation_wait(this) then
							goto label_40884_0
						end
					end
				end
			end

			-- 3技能 地狱注入
			if ready_to_use_skill(ha, store, this.unit.cooldown_factor) then
				local has_tower = false

				for _, e in pairs(store.towers) do
					if e.tower.can_be_mod and U.is_inside_ellipse(e.pos, this.pos, ha.range) then
						has_tower = true

						break
					end
				end

				if has_tower then
					U.animation_start_once_specific_no_flip(this, ha.animation, store.tick_ts, 1)

					if SU.y_hero_wait(store, this, ha.cast_time) then
						goto label_40884_0
					end

					SU.hero_gain_xp_from_skill(this, he.skills.hellish_infusion)

					ha.ts = store.tick_ts

					local towers = table.filter(store.towers, function(_, e)
						return e.tower.can_be_mod and U.is_inside_ellipse(e.pos, this.pos, ha.range)
					end)

					for _, tower in ipairs(towers) do
						local new_mod = E:create_entity(ha.mod)

						new_mod.modifier.target_id = tower.id
						new_mod.modifier.source_id = this.id
						new_mod.pos = tower.pos

						simulation:queue_insert_entity(new_mod)
					end

					if SU.y_hero_animation_wait(this) then
						goto label_40884_0
					end
				else
					ha.ts = ha.ts + 0.1
				end
			end

			-- 近战普攻
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			-- 远程普攻
			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				elseif SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_40884_0::

		coroutine.yield()
	end
end

tt = RT("hero_oloch", "hero")

AC(tt, "melee", "ranged", "timed_attacks", "selfdestruct")

tt.melee.range = 30
tt.health_bar.offset = v(0, 52)
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.main_script.update = hero_oloch_update
tt.hero.fn_level_up = hero_oloch_level_up
tt.info.portrait = "kr4_info_portraits_heroes_0003"
tt.info.hero_portrait = "kr4_hero_portraits_0003"
tt.motion.max_speed = 65
tt.soldier.melee_slot_offset = v(5, 0)
tt.sound_events.change_rally_point = "group_oloch_taunt"
tt.sound_events.death = "hero_oloch_death"
tt.sound_events.hero_room_select = "hero_oloch_taunt_1"
tt.sound_events.insert = "hero_oloch_taunt_1"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.mod_offset = v(0, 20)
tt.hero.skills.duplication = CC("hero_skill")
tt.hero.skills.duplication.xp_gain = {200, 400, 600}
tt.hero.skills.duplication.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.duplication.damage_min = {16, 20, 24}
tt.hero.skills.duplication.damage_max = {24, 48, 72}
tt.hero.skills.magma_eruption = CC("hero_skill")
tt.hero.skills.magma_eruption.xp_gain = {180, 360, 540}
tt.hero.skills.magma_eruption.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.magma_eruption.count = {3, 4, 5}
tt.hero.skills.magma_eruption.damage_config = {30, 50, 70}
tt.hero.skills.magma_eruption.damage_aura_config = {9, 12, 15}
tt.hero.skills.hellish_infusion = CC("hero_skill")
tt.hero.skills.hellish_infusion.xp_gain = {150, 300, 450}
tt.hero.skills.hellish_infusion.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.hellish_infusion.cooldown = {18, 18, 18}
tt.hero.skills.hellish_infusion.damage_factor_config = {1.1, 1.2, 1.3}
tt.hero.skills.demonic_blast = CC("hero_skill")
tt.hero.skills.demonic_blast.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.demonic_blast.damage_min = {100, 150, 200}
tt.hero.skills.demonic_blast.damage_max = {200, 400, 600}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.xp_gain = {100, 200, 300, 400}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.cooldown = {24, 21.6, 19.2, 16}
tt.hero.skills.ultimate.offset_config = {-15, -25, -35, -45}
tt.hero.skills.ultimate.controller_name = "controller_hero_oloch_ultimate"
tt.ultimate = {
	ts = 0,
	cooldown = 24,
	disabled = true
}
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.magic_armor = {0.41, 0.42, 0.43, 0.44, 0.45, 0.46, 0.47, 0.48, 0.49, 0.5}
tt.hero.level_stats.hp_max = {180, 198, 216, 234, 252, 270, 288, 306, 324, 342}
tt.hero.level_stats.melee_damage_max = {9, 11, 13, 15, 17, 19, 21, 23, 25, 27}
tt.hero.level_stats.melee_damage_min = {9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
tt.hero.level_stats.ranged_damage_max = {20, 22, 26, 30, 34, 38, 42, 48, 52, 56}
tt.hero.level_stats.ranged_damage_min = {14, 16, 18, 20, 22, 24, 26, 28, 30, 32}
tt.hero.level_stats.selfdestruct_damage_config = {150, 200, 250, 300, 350, 400, 450, 500, 550, 600}
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].offset = v(0, -18)
tt.render.sprites[1].prefix = "hero_oloch"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, -18)
tt.render.sprites[2].name = "hero_oloch_shadow"
tt.render.sprites[2].anchor.y = 0.12
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 9
tt.melee.attacks[1].damage_min = 9
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].min_range = 30
tt.ranged.attacks[1].max_range = 170
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "bolt_oloch"
tt.ranged.attacks[1].shoot_time = fts(31)
tt.ranged.attacks[1].bullet_start_offset = {v(-8, 44)}
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].cooldown = 27
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].animation = "megaBolt"
tt.ranged.attacks[2].sound = "hero_oloch_demonic_cast"
tt.ranged.attacks[2].min_range = 30
tt.ranged.attacks[2].max_range = 185
tt.ranged.attacks[2].bullet = "bolt_oloch_big"
tt.ranged.attacks[2].shoot_time = fts(45)
tt.ranged.attacks[2].bullet_start_offset = {v(0, 52)}
tt.ranged.attacks[2].check_target_before_shot = true
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "duplication"
tt.timed_attacks.list[1].cooldown = 25
tt.timed_attacks.list[1].cast_time = fts(12)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_oloch_illusion"
tt.timed_attacks.list[1].sound = "hero_oloch_respawn"
tt.timed_attacks.list[1].spawn_time = fts(19)
tt.timed_attacks.list[1].initial_rally = v(0, 30)
tt.timed_attacks.list[1].initial_pos = v(0, 33)
tt.timed_attacks.list[1].radius = 30
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 170
tt.timed_attacks.list[1].count = 2
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "magmaEruption"
tt.timed_attacks.list[2].cooldown = 22.5
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "oloch_magma"
tt.timed_attacks.list[2].spawn_time = fts(30)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 185
tt.timed_attacks.list[3] = CC("mod_attack")
tt.timed_attacks.list[3].mod = "mod_oloch_heat"
tt.timed_attacks.list[3].sound = "hero_oloch_hellish"
tt.timed_attacks.list[3].animation = "hellishInfusion"
tt.timed_attacks.list[3].cooldown = 36
tt.timed_attacks.list[3].range = 170
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].cast_time = fts(42)
tt.selfdestruct.animation = "death"
tt.selfdestruct.damage_radius = 70
tt.selfdestruct.damage_max = 50
tt.selfdestruct.damage_min = 50
tt.selfdestruct.hit_time = fts(29)
tt.selfdestruct.sound = "BombExplosionSound"
tt.selfdestruct.sound_args = {
	delay = fts(29)
}
tt = RT("soldier_oloch_illusion", "soldier_militia")

AC(tt, "reinforcement", "ranged", "tween", "selfdestruct", "nav_grid")

tt.controable = true
tt.controable_other = true
tt.melee = nil
tt.selfdestruct.animation = "death"
tt.selfdestruct.damage_radius = 70
tt.selfdestruct.damage_max = 50
tt.selfdestruct.damage_min = 50
tt.selfdestruct.hit_time = fts(29)
tt.selfdestruct.sound = "BombExplosionSound"
tt.selfdestruct.sound_args = {
	delay = fts(29)
}
tt.health.hp_max = 300
tt.health_bar.offset = v(0, 52)
tt.health.dead_lifetime = 2
tt.info.portrait = "kr4_info_portraits_heroes_0003"
tt.info.random_name_format = nil
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.motion.max_speed = 65
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_oloch_duplication"
tt.ranged.attacks[1].bullet_start_offset = {v(-8, 44)}
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].shoot_time = fts(31)
tt.ranged.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].cooldown = 27
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].animation = "megaBolt"
tt.ranged.attacks[2].sound = "hero_oloch_demonic_cast"
tt.ranged.attacks[2].min_range = 20
tt.ranged.attacks[2].max_range = 185
tt.ranged.attacks[2].bullet = "bolt_oloch_big_duplication"
tt.ranged.attacks[2].shoot_time = fts(45)
tt.ranged.attacks[2].bullet_start_offset = {v(0, 52)}
tt.ranged.attacks[2].check_target_before_shot = true
tt.render.sprites[1].anchor.y = 0.12
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].offset = v(0, -18)
tt.render.sprites[1].prefix = "hero_oloch"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].alpha = 180
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, -18)
tt.render.sprites[2].name = "hero_oloch_shadow"
tt.render.sprites[2].anchor.y = 0.12
tt.render.sprites[2].z = Z_DECALS + 1
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, v(0, -18)}, {fts(6), v(0, -18)}}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE, F_RANGED)
tt = RT("oloch_magma", "bullet")

AC(tt, "tween")

tt.main_script.update = oloch_magma_update
tt.bullet.damage_max = 20
tt.bullet.damage_min = 20
tt.bullet.damage_radius = 25
tt.bullet.hit_payload = "oloch_magma_lavapool"
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.hit_time = fts(4)
tt.bullet.duration = 2
tt.render.sprites[1].prefix = "hero_oloch_magma_eruption_explotion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor.y = 0.09027777777777778
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(3), 0}, {fts(6), 255}, {tt.bullet.duration, 255}, {tt.bullet.duration + fts(10), 0}}
tt.sound_events.delayed_insert = "hero_oloch_duplication"
tt.delay = 0
tt = RT("oloch_magma_lavapool", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.3
tt.aura.duration = 5
tt.aura.mod = "mod_oloch_magma"
tt.aura.radius = 40
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "hero_oloch_magma_eruption_decal_run"
tt.render.sprites[1].offset.y = 20
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt = RT("mod_oloch_magma", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_min = 7
tt.dps.damage_max = 7
tt.dps.damage_every = 0.1
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 1
tt.modifier.allows_duplicates = false
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].draw_order = 10
tt = RT("mod_oloch_heat", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 6
tt.damage_factor = 1.1
tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = mod_oloch_heat_update
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, v(1, 1)}, {0.5, v(0.9, 0.9)}, {1, v(1, 1)}}
tt.render.sprites[1].name = "hero_oloch_hellish_infusion_run"
tt.render.sprites[1].anchor.y = 0.21
tt.render.sprites[1].offset.y = -10
tt.render.sprites[1].z = Z_TOWER_BASES + 1
tt = RT("bolt_oloch", "bolt")
tt.bullet.damage_max = 78
tt.bullet.damage_min = 42
tt.bullet.hit_fx = "fx_bolt_oloch_hit"
tt.bullet.max_speed = 600
tt.bullet.xp_gain_factor = 2
tt.bullet.particles_name = "ps_bolt_oloch"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].name = "hero_oloch_bolt_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "InfernalMageAttack"
tt = RT("bolt_oloch_duplication", "bolt_oloch")
tt.bullet.xp_gain_factor = nil
tt.render.sprites[1].alpha = 180
tt = RT("bolt_oloch_big", "bolt")
tt.bullet.damage_max = 78
tt.bullet.damage_min = 42
tt.bullet.xp_gain_factor = 2
tt.bullet.hit_fx = "fx_bolt_oloch_big_hit"
tt.bullet.max_speed = 600
tt.bullet.particles_name = "ps_bolt_oloch_big"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].name = "hero_oloch_mega_bolt_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "hero_oloch_demonic_travel"
tt = RT("bolt_oloch_big_duplication", "bolt_oloch_big")
tt.bullet.xp_gain_factor = nil
tt.render.sprites[1].alpha = 180
tt = RT("fx_bolt_oloch_hit", "fx")
tt.render.sprites[1].prefix = "hero_oloch_bolt"
tt.render.sprites[1].name = "hit"
tt = RT("ps_bolt_oloch", "ps_bullet_tower_wicked_sisters_basic_trail")
tt.particle_system.name = "hero_oloch_bolt_particle_run"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt = RT("fx_bolt_oloch_big_hit", "fx")
tt.render.sprites[1].prefix = "hero_oloch_mega_bolt"
tt.render.sprites[1].name = "hit"
tt = RT("ps_bolt_oloch_big", "ps_bullet_tower_wicked_sisters_basic_trail")
tt.particle_system.name = "hero_oloch_mega_bolt_particle_run"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt = RT("controller_hero_oloch_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = hero_oloch_ultimate_update
tt.teleport_decal = "decal_hero_oloch_ultimate"
tt.vis_bans = bor(F_BOSS)
tt.vis_flags = bor(F_TELEPORT)
tt.sound_cast = "hero_oloch_ultimate"
tt.radius = 85
tt.max_targets = 10
tt.mod_teleport = "mod_hero_oloch_ultimate_teleport"
tt = RT("decal_hero_oloch_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_oloch_teleport_decal_run"
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_hero_oloch_ultimate_teleport", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.duration = 1
tt.nodes_offset = -15
tt.max_times_applied = 1e+99
tt.delay_start = fts(3)
tt.hold_time = 0.34
tt.delay_end = fts(3)
tt.fx_start = "fx_hero_oloch_ultimate"
tt.fx_end = "fx_hero_oloch_ultimate"
tt.damage_base = 10
tt.damage_inc = 20
tt = RT("fx_hero_oloch_ultimate", "fx")
tt.render.sprites[1].name = "hero_oloch_teleport_modifier_run"
