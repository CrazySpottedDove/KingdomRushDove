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

local function hero_jigou_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	-- 1技能 雪球
	upgrade_skill(this, "ice_shard", function(this, s)
		this.ranged.attacks[1].disabled = nil
		this.ranged.attacks[1].max_range = s.max_range[s.level]

		local b = E:get_template(this.ranged.attacks[1].bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]
	end)
	-- 2技能 霜冻吐息
	upgrade_skill(this, "frozen_breath", function(this, s)
		this.timed_attacks.list[2].disabled = nil
		this.timed_attacks.list[2].step = s.count[s.level]
	end)
	-- 3技能 猛击地球
	upgrade_skill(this, "earthshake", function(this, s)
		this.melee.attacks[2].disabled = nil
		this.melee.attacks[2].loops = s.loops[s.level]
	end)
	-- 4技能 冰川形态
	upgrade_skill(this, "glacial_form", function(this, s)
		this.timed_attacks.list[1].disabled = nil

		local m = E:get_template("jigou_healing_mod")

		m.modifier.duration = s.duration[s.level]
		m.hps.heal_min = s.hps[s.level]
		m.hps.heal_max = s.hps[s.level]
	end)
	-- 大招 冰区
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template(s.controller_name)
		local a = E:get_template(u.aura)

		a.aura.damage_min = s.damage_config[s.level]
		a.aura.damage_max = s.damage_config[s.level]

		local a2 = E:get_template("mod_jigou_ultimate_slow")

		a2.slow.factor = s.slow_factor[s.level]
	end)
	update_hp(this)
end

local function hero_jigou_update(this, store)
	local h = this.health
	local a_mock = this.timed_attacks.list[1]
	local chill_attack = this.timed_attacks.list[2]
	local skill, brk, sta

	this.health_bar.hidden = true

	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	local mocked_targets = {}

	local function do_mock()
		local enemies = U.find_enemies_in_range_filter_on(this.pos, a_mock.range, a_mock.vis_flags, a_mock.vis_bans, SU.is_valid_mock_target)

		if enemies then
			for i = 1, #enemies do
				if not table.arraycontains(mocked_targets, enemies[i]) then
					SU.mock_enemy(this, enemies[i])

					mocked_targets[#mocked_targets + 1] = enemies[i]
				end
			end
		end
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				SU.y_hero_new_rally(store, this)
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts)
			end

			if ready_to_use_skill(a_mock, store, this.unit.cooldown_factor) then
				if U.find_first_enemy_in_range_filter_on(this.pos, this.melee.range, a_mock.vis_flags, a_mock.vis_bans, SU.is_valid_mock_target) then
					local start_ts = store.tick_ts

					U.animation_start_default(this, a_mock.animation .. "_start", nil, store.tick_ts)
					S:queue(a_mock.sound)

					if SU.y_hero_wait(store, this, a_mock.hit_time) then
						goto label_1561_0
					end

					a_mock.ts = start_ts

					for _, m in ipairs(a_mock.mods) do
						local mod = E:create_entity(m)

						mod.modifier.target_id = this.id
						mod.modifier.source_id = this.id
						mod.modifier.level = this.hero.skills.glacial_form.level

						simulation:queue_insert_entity(mod)
					end

					local aura = E:create_entity("aura_jigou_slow")

					aura.aura.radius = this.melee.range
					aura.aura.duration = a_mock.duration
					aura.aura.source_id = this.id

					aura.pos:copy(this.pos)
					simulation:queue_insert_entity(aura)
					SU.insert_received_damage_factor_mul_buff(this, a_mock.damage_factor)
					SU.hero_gain_xp_from_skill(this, this.hero.skills.glacial_form)
					do_mock()
					U.y_animation_wait_default(this)
					U.animation_start_default(this, a_mock.animation .. "_loop", nil, store.tick_ts, true)

					start_ts = store.tick_ts

					local last_mock_ts = start_ts

					while store.tick_ts - start_ts < a_mock.duration do
						if this.nav_rally.new then
							break
						end

						if this.health.dead then
							break
						end

						if store.tick_ts - last_mock_ts > 0.1 then
							last_mock_ts = store.tick_ts

							do_mock()
						end

						coroutine.yield()
					end

					U.animation_start_default(this, a_mock.animation .. "_end", nil, store.tick_ts)

					local fx = E:create_entity("fx_jigou_igloo_explosion")

					fx.pos:copy(this.pos)

					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
					SU.remove_received_damage_factor_mul_buff(this, a_mock.damage_factor)

					local enemy_continue_to_block

					if not this.nav_rally.new and #mocked_targets > 0 and not this.soldier.target_id then
						enemy_continue_to_block = table.find_best(mocked_targets, function(e)
							return e.health.hp
						end)
					end

					for i = #mocked_targets, 1, -1 do
						SU.unmock_enemy(mocked_targets[i])

						mocked_targets[i] = nil
					end

					if enemy_continue_to_block then
						U.block_enemy(store, this, enemy_continue_to_block)
					end

					simulation:queue_remove_entity(aura)

					if SU.y_hero_animation_wait(this) then
						goto label_1561_0
					end
				else
					a_mock.ts = a_mock.ts + 0.1
				end
			end

			-- 2技能 霜冻吐息
			local a = chill_attack

			skill = this.hero.skills.frozen_breath

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.13333333333333333
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						a.ts = a.ts + 0.4
					else
						local s_pi, _, s_ni = unpack(nodes[1])
						local flip = target.pos.x < this.pos.x
						local start_ts = store.tick_ts

						U.animation_start_default(this, "frozenBreath", flip, store.tick_ts)
						S:queue(a.sound)

						if SU.y_hero_wait(store, this, a.cast_time) then
							goto label_1561_0
						end

						target = U.detect_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if target then
							pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
						end

						a.ts = start_ts

						SU.hero_gain_xp_from_skill(this, skill)

						local delay = 0
						local n_step = ni < s_ni and -a.step or a.step

						ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + a.nodes_offset or ni)

						for i = 1, skill.count[skill.level] do
							local b = E:create_entity(a.bullet)

							b.pos = P:node_pos(pi, spi, ni)
							b.render.sprites[1].prefix = b.render.sprites[1].prefix .. math.random(1, 3)
							b.render.sprites[1].flip_x = not flip
							b.delay = delay
							b.aura.damage_factor = this.unit.damage_factor

							simulation:queue_insert_entity(b)

							delay = delay + 0.05
							ni = ni + n_step
							spi = km.zmod(spi + 1, 3)
						end

						if SU.y_hero_animation_wait(this) then
							goto label_1561_0
						end
					end
				end
			end

			-- 大招 冰区
			skill = this.hero.skills.ultimate

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ultimate.range, F_RANGED, F_NONE, nil, true, true)

				if target then
					apply_ultimate(this, store, target.pos, "levelup")
				else
					this.ultimate.ts = this.ultimate.ts + 1
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

		::label_1561_0::

		coroutine.yield()
	end
end

local function controller_jigou_ultimate_update(this, store)
	local e = E:create_entity(this.aura)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.aura.damage_factor = this.damage_factor

	simulation:queue_insert_entity(e)
	S:queue(this.sound)
	simulation:queue_remove_entity(this)
end

local function aura_jigou_ultimate_update(this, store)
	local a = this.aura

	local function do_attack(pos, last_attack)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y

		if not last_attack then
			fx.render.sprites[2].scale = V.v(0.8, 0.8)
		end

		fx.render.sprites[2].name = fx.render.sprites[2].name .. "_" .. math.random(1, 4)
		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
		local targets = U.find_enemies_in_range_filter_off(pos, radius, a.vis_flags, a.vis_bans)

		if targets then
			S:queue(this.sound)

			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max) * this.aura.damage_factor, this.id, t.id)

				queue_damage(store, d)

				if U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			end
		end
	end

	local pi, spi, ni, tni, target, origin
	local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil, a.vis_flags, a.vis_bans)

	if target_info then
		target = target_info[1].enemy
		origin = target_info[1].origin
		pi, spi, ni = unpack(origin)
		tni = target.nav_path.ni

		for i = 1, a.steps do
			local nni_fwd = ni + i * a.step_nodes * km.sign(tni - ni)
			local oni_fwd = ni + i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos = P:node_pos(pi, spi, nni_fwd)

			do_attack(spos, i == a.steps)

			if i == 1 then
				local opos = P:node_pos(pi, spi, oni_fwd)

				do_attack(opos, false)
			end

			local nni_bwd = ni - i * a.step_nodes * km.sign(tni - ni)
			local oni_bwd = ni - i * a.step_nodes * km.sign(tni - ni) * -1

			spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

			U.y_wait(store, a.step_delay)

			local spos2 = P:node_pos(pi, spi, nni_bwd)

			do_attack(spos2, i == a.steps)

			if i == 1 then
				local opos2 = P:node_pos(pi, spi, oni_bwd)

				do_attack(opos2, false)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

tt = RT("hero_jigou", "hero")

AC(tt, "melee", "timed_attacks", "ranged", "auras")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_jigou_regen"
tt.auras.list[1].cooldown = 0
tt.melee.range = 60
tt.health_bar.offset = v(0, 68)
tt.health.dead_lifetime = 15
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.tombstone_show_time = fts(90)
tt.hero.skills.ice_shard = CC("hero_skill")
tt.hero.skills.ice_shard.damage_min = {40, 100, 160}
tt.hero.skills.ice_shard.damage_max = {105, 150, 195}
tt.hero.skills.ice_shard.max_range = {200, 250, 300}
tt.hero.skills.ice_shard.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ice_shard.xp_gain = {60, 120, 180}
tt.hero.skills.frozen_breath = CC("hero_skill")
tt.hero.skills.frozen_breath.count = {3, 4, 5}
tt.hero.skills.frozen_breath.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.frozen_breath.xp_gain = {80, 160, 240}
tt.hero.skills.earthshake = CC("hero_skill")
tt.hero.skills.earthshake.loops = {5, 9, 13}
tt.hero.skills.earthshake.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.earthshake.xp_gain = {180, 360, 540}
tt.hero.skills.glacial_form = CC("hero_skill")
tt.hero.skills.glacial_form.duration = {5, 7, 9}
tt.hero.skills.glacial_form.hps = {37, 52, 67}
tt.hero.skills.glacial_form.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.glacial_form.xp_gain = {240, 480, 720}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.damage_config = {125, 175, 225, 275}
tt.hero.skills.ultimate.slow_factor = {0.85, 0.7, 0.55, 0.4}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain = {150, 300, 450, 600}
tt.hero.skills.ultimate.controller_name = "hero_jigou_ultimate"
tt.hero.level_stats.armor = {0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.18, 0.20, 0.22, 0.24}
tt.hero.level_stats.hp_max = {360, 420, 480, 540, 600, 660, 720, 780, 840, 900}
tt.hero.level_stats.melee_damage_min = {24, 28, 32, 36, 40, 46, 51, 57, 62, 67}
tt.hero.level_stats.melee_damage_max = {28, 36, 44, 52, 60, 69, 77, 85, 94, 102}
tt.regen.cooldown = 1
tt.ultimate = {
	ts = 0,
	cooldown = 44,
	disabled = true,
	range = 200
}
tt.info.hero_portrait = "kr4_hero_portraits_0007"
tt.info.portrait = "kr4_info_portraits_heroes_0007"
tt.main_script.update = hero_jigou_update
tt.hero.fn_level_up = hero_jigou_level_up
tt.motion.max_speed = 55
tt.soldier.melee_slot_offset = v(15, 0)
tt.sound_events.change_rally_point = "group_jigou_taunt"
tt.sound_events.death = "hero_jigou_death"
tt.sound_events.hero_room_select = "hero_jigou_taunt_1"
tt.sound_events.insert = "group_jigou_taunt"
tt.sound_events.respawn = "HeroPaladinTauntIntro"
tt.unit.marker_offset = v(0, 12)
tt.unit.mod_offset = v(0, 32)
tt.render.sprites[1].anchor = v(0.5, 0.04)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_jigou"
tt.render.sprites[1].offset = v(0, -16)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].offset = v(0, 28)
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_jigou_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_radius = 40
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].pop = {"pop_whaam", "pop_kapow"}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.35
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "iceland"
tt.melee.attacks[2].animations = {"specialIn", "specialLoop", "specialOut"}
tt.melee.attacks[2].cooldown = 30
tt.melee.attacks[2].count = 99
tt.melee.attacks[2].loops = 4
tt.melee.attacks[2].damage_radius = 100
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].damage_min = 20
tt.melee.attacks[2].damage_max = 20
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(10)
tt.melee.attacks[2].hit_fx = "decal_hero_jigou_attack"
tt.melee.attacks[2].mod = "mod_jigou_stun"
tt.melee.attacks[2].sound = "hero_jigou_earthshake"
tt.melee.attacks[2].xp_from_skill = "earthshake"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].cooldown = 10
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "bullet_jigou"
tt.ranged.attacks[1].xp_from_skill = "ice_shard"
tt.ranged.attacks[1].shoot_time = fts(37)
tt.ranged.attacks[1].node_prediction = fts(28)
tt.ranged.attacks[1].check_target_before_shot = true
tt.ranged.attacks[1].bullet_start_offset = {v(-8, 36)}
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "igloo"
tt.timed_attacks.list[1].cooldown = 40
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_time = fts(10)
tt.timed_attacks.list[1].vis_flags = F_BLOCK
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[1].duration = 3
tt.timed_attacks.list[1].mods = {"jigou_healing_mod"}
tt.timed_attacks.list[1].sound = "hero_jigou_glacial"
tt.timed_attacks.list[1].range = 100
tt.timed_attacks.list[1].damage_factor = 0.4
tt.timed_attacks.list[2] = CC("aura_attack")
tt.timed_attacks.list[2].animation = "chill"
tt.timed_attacks.list[2].bullet = "aura_chill_jigou"
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].max_range = tt.melee.range
tt.timed_attacks.list[2].min_range = 10
tt.timed_attacks.list[2].sound = "hero_jigou_breath"
tt.timed_attacks.list[2].step = 3
tt.timed_attacks.list[2].nodes_offset = 6
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_STUN)
tt.timed_attacks.list[2].xp_from_skill = "frozen_breath"
tt = RT("aura_jigou_regen", "aura_beastmaster_regeneration")
tt.hps.heal_every = 0.2
tt = RT("aura_jigou_slow", "aura")

AC(tt, "render")

tt.aura.mod = "mod_jigou_slow"
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = F_FRIEND
tt.aura.cycle_time = 0.3
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "hero_jigou_iceland_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = RT("mod_jigou_slow", "mod_eiskalt_cold")
tt.modifier.duration = 1
tt.slow.factor = 0.7
tt.modifier.vis_bans = F_NONE
tt = RT("aura_chill_jigou", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 1
tt.aura.mod = "mod_jigou_freeze"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_chill_elora.update
tt.render.sprites[1].prefix = "hero_jigou_frozen_breath_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.2, 0}}
tt = RT("mod_jigou_freeze", "mod_freeze")

AC(tt, "render")

tt.modifier.duration = 3
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 32)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {"start", "end"}
tt = RT("bullet_jigou", "bomb")
tt.bullet.flight_time = fts(28)
tt.bullet.damage_radius = 60
tt.bullet.damage_max = 63
tt.bullet.damage_min = 35
tt.bullet.use_hit_offset = true
tt.bullet.hit_fx = "fx_jigou_stone_explosion"
tt.bullet.hit_decal = nil
tt.bullet.pop = {"pop_artillery"}
tt.render.sprites[1].name = "hero_jigou_iceshard"
tt.sound_events.insert = "hero_jigou_glacial"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = RT("fx_jigou_stone_explosion", "fx")
tt.render.sprites[1].name = "hero_jigou_iceshard_hit_run"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_jigou_igloo_explosion", "fx")
tt.render.sprites[1].name = "hero_jigou_igloo_end_run"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = RT("decal_hero_jigou_attack", "decal_ground_hit")
tt.render.sprites[1].name = "hero_jigou_attack_fx_run"
tt = RT("mod_jigou_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt.modifier.duration = 0.5
tt = RT("jigou_healing_mod", "modifier")

AC(tt, "hps")

tt.modifier.duration = 3
tt.modifier.resets_same = false
tt.hps.heal_min = 37
tt.hps.heal_max = 37
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt = RT("hero_jigou_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = controller_jigou_ultimate_update
tt.aura = "aura_jigou_ultimate"
tt.vis_flags = bor(F_RANGED, F_BLOCK)
tt.vis_bans = F_FLYING
tt.sound = "hero_jigou_icezone"
tt = RT("aura_jigou_ultimate", "aura")
tt.aura.fx = "decal_jigou_ultimate_spike"
tt.aura.damage_radius = 44
tt.aura.last_attack_damage_radius = 55
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.step_delay = fts(2)
tt.aura.step_nodes = 2
tt.aura.steps = 9
tt.main_script.update = aura_jigou_ultimate_update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_FLYING)
tt.stun.mod = "mod_jigou_ultimate_slow"
tt.aura.damage_min = 15
tt.aura.damage_max = 15
tt.aura.min_nodes = 0
tt.aura.max_nodes = 25
tt.aura.min_count = 1
tt = RT("mod_jigou_ultimate_slow", "mod_slow")
tt.modifier.duration = 6
tt.slow.factor = 0.85
tt = RT("decal_jigou_ultimate_spike", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_jigou_ultimate_ice_shards"
tt.render.sprites[2].scale = v(1.5, 1.5)
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
