local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local anchor_y = 0
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local tt

local function hero_elves_archer_ultimate_update(this, store)
	local function spawn_arrow(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(this.bullet)

		b.bullet.damage_max = this.damage[this.level]
		b.bullet.damage_min = this.damage[this.level]
		b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
		b.bullet.to = pos
		b.bullet.damage_factor = this.damage_factor

		b.pos:copy(b.bullet.from)
		simulation:queue_insert_entity(b)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

	if #nearest > 0 then
		local pi, spi, ni = unpack(nearest[1])

		spawn_arrow(pi, spi, ni)

		local count = this.spread[this.level]
		local sequence = {}

		for i = 1, count do
			sequence[i] = i
		end

		while #sequence > 0 do
			local i = table.remove(sequence, math.random(1, #sequence))
			local delay = U.frandom(0, 1 / count)

			U.y_wait_unconditional(store, delay * 0.5)

			if P:is_node_valid(pi, ni + i) then
				spawn_arrow(pi, nil, ni + i)
			else
				spawn_arrow(pi, nil, ni - i)
			end

			U.y_wait_unconditional(store, delay * 0.5)

			if P:is_node_valid(pi, ni - i) then
				spawn_arrow(pi, nil, ni - i)
			else
				spawn_arrow(pi, nil, ni + i)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function hero_elves_archer_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "multishot", function(this, s)
		local a = this.ranged.attacks[2]

		a.disabled = nil
		a.max_loops = s.loops[s.level]
	end)
	upgrade_skill(this, "porcupine", function(this, s)
		bt.bullet.damage_inc = s.damage_inc[s.level]
	end)
	upgrade_skill(this, "nimble_fencer", function(this, s)
		this.dodge.disabled = nil
		this.dodge.chance = s.chance[s.level]
	end)
	upgrade_skill(this, "double_strike", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "guards", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil

		local e = E:get_template(a.entity)

		e.health.hp_max = s.hp_max[s.level]
		e.health.armor = s.armor[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
	end)
	update_hp(this)
end

local function hero_elves_archer_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	local a = E:create_entity("aura_elves_archer_regen")

	a.aura.source_id = this.id
	a.aura.ts = store.tick_ts
	a.pos = this.pos

	simulation:queue_insert_entity(a)

	return true
end

local function hero_elves_archer_update(this, store)
	local h = this.health
	local skill
	local is_sword = false
	local guard_attack = this.timed_attacks.list[1]
	local porcupine_target, porcupine_level = nil, 0

	local function update_porcupine(attack, target)
		if porcupine_target == target then
			porcupine_level = math.min(porcupine_level + 1, 3)
			attack.level = porcupine_level
		else
			porcupine_level = 0
			attack.level = 0
		end

		porcupine_target = target
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		this.regen.is_idle = nil

		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			if this.dodge and this.dodge.active then
				this.dodge.active = false
				this.dodge.counter_attack_pending = true
				this.melee.attacks[2].ts = this.melee.attacks[2].ts - 1
			end

			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_79_4
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local enemy = find_target_at_critical_moment(this, this.ranged.attacks[1].max_range, F_RANGED, F_NONE, nil, true)

				if enemy and enemy.pos then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)

					ultimate_entity.damage_factor = this.unit.damage_factor
					ultimate_entity.pos = V.vclone(enemy.pos)
					ultimate_entity.level = this.hero.skills.ultimate.level

					simulation:queue_insert_entity(ultimate_entity)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			skill = this.hero.skills.guards

			if ready_to_use_skill(guard_attack, store, this.unit.cooldown_factor) then
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

				if #nodes < 1 then
					guard_attack.ts = guard_attack.ts + 0.4
				else
					U.animation_start_default(this, guard_attack.animation, nil, store.tick_ts)
					S:queue(guard_attack.sound)
					SU.hero_gain_xp_from_skill(this, skill)

					guard_attack.ts = store.tick_ts

					local pi, _, ni = unpack(nodes[1])
					local new_soldier = E:create_entity(guard_attack.entity)
					local e_spi, e_ni = math.random(1, 3), ni

					new_soldier.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
					new_soldier.nav_rally.pos = V.vclone(new_soldier.nav_rally.center)
					new_soldier.pos = V.vclone(new_soldier.nav_rally.center)
					new_soldier.owner = this

					simulation:queue_insert_entity(new_soldier)
				end

				SU.y_hero_animation_wait(this)

				::label_79_4::
			end

			-- 近战状态
			local target = SU.soldier_pick_melee_target(store, this)

			if not target then
			-- block empty
			else
				if ready_to_use_skill(this.ranged.attacks[2], store, this.unit.cooldown_factor) then
					goto bow_ready_in_sword
				end

				if is_sword then
					local slot_pos = U.melee_slot_position(this, target)

					if slot_pos and not V.veq(slot_pos, this.pos) then
						U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

						is_sword = false
					end
				end

				if SU.soldier_move_to_slot_step(store, this, target) then
					goto label_79_4
				end

				local attack = SU.soldier_pick_melee_attack(store, this, target)

				if not attack then
					goto label_79_4
				end

				if not is_sword then
					U.y_animation_play(this, "bow2sword", nil, store.tick_ts)

					is_sword = true
				end

				if attack.xp_from_skill then
					SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
				end

				SU.y_soldier_do_single_melee_attack(store, this, target, attack)
				U.animation_start_default(this, "idle_sword", nil, store.tick_ts, true)

				goto label_79_4
			end

			::bow_ready_in_sword::

			do
				if is_sword then
					U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

					is_sword = false
				end

				local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

				if not target then
					goto label_79_3
				end

				this.regen.is_idle = true

				if not attack then
					goto label_79_3
				end

				U.set_destination(this, this.pos)

				local attack_done
				local start_ts = store.tick_ts

				if attack.max_loops then
					local an, af = U.animation_name_facing_point(this, attack.animations[1], target.pos)

					U.y_animation_play(this, an, af, store.tick_ts, 1)

					local retarget_flag
					local loops, loops_done = attack.max_loops, 0
					local pred_shots
					local b = E:create_entity(attack.bullet)

					b.bullet.damage_factor = this.unit.damage_factor

					local d = SU.create_bullet_damage(b.bullet)

					::label_79_0::

					if retarget_flag then
						retarget_flag = nil

						local n_target, _, n_pred_pos = U.find_foremost_enemy_between_range_filter_on(this.pos, attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags, attack.vis_bans, function(v)
							return v ~= target
						end)

						if n_target then
							target = n_target
							pred_pos = n_pred_pos
						else
							goto label_79_1
						end
					end

					update_porcupine(attack, target)

					d.value = (b.bullet.damage_min + b.bullet.damage_max + 2 * attack.level * (b.bullet.damage_inc or 0)) * 0.5
					pred_shots = math.ceil(target.health.hp / U.predict_damage(target, d))
					loops = math.min(attack.max_loops - loops_done, pred_shots)

					for i = 1, loops do
						an, af = U.animation_name_facing_point(this, attack.animations[2], target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)

						while store.tick_ts - this.render.sprites[1].ts < attack.shoot_times[1] do
							if SU.hero_interrupted(this) then
								goto label_79_2
							end

							coroutine.yield()
						end

						local b = E:create_entity(attack.bullet)

						b.pos:copy(this.pos)

						if attack.bullet_start_offset then
							local offset = attack.bullet_start_offset[1]

							b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
						end

						b.bullet.from:copy(b.pos)

						b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
						b.bullet.target_id = target.id
						b.bullet.source_id = this.id
						b.bullet.xp_dest_id = this.id
						b.bullet.level = attack.level
						b.bullet.damage_factor = this.unit.damage_factor

						simulation:queue_insert_entity(b)

						if attack.xp_from_skill then
							SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
						end

						attack_done = true
						loops_done = loops_done + 1

						while not U.animation_finished_default(this) do
							if SU.hero_interrupted(this) then
								goto label_79_2
							end

							coroutine.yield()
						end

						if target.health.dead or band(F_RANGED, target.vis.bans) ~= 0 then
							retarget_flag = true

							goto label_79_0
						end

						update_porcupine(attack, target)
					end

					if loops_done < attack.max_loops then
						retarget_flag = true

						goto label_79_0
					end

					::label_79_1::

					an, af = U.animation_name_facing_point(this, attack.animations[3], target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					while not U.animation_finished_default(this) do
						if SU.hero_interrupted(this) then
							break
						end

						coroutine.yield()
					end
				else
					update_porcupine(attack, target)

					attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
				end

				::label_79_2::

				if attack_done then
					attack.ts = start_ts
				end

				goto label_79_4
			end

			::label_79_3::

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)

				this.regen.is_idle = true
			end
		end

		::label_79_4::

		coroutine.yield()
	end
end

tt = RT("hero_elves_archer", "hero")
AC(tt, "melee", "ranged", "dodge", "timed_attacks")
anchor_y = 16 / 68
tt.hero.level_stats.hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400}
tt.hero.level_stats.armor = {0.19, 0.23, 0.27, 0.31, 0.35, 0.39, 0.43, 0.47, 0.51, 0.55}
tt.hero.level_stats.melee_damage_min = {11, 11, 12, 13, 14, 15, 15, 16, 17, 18}
tt.hero.level_stats.melee_damage_max = {13, 14, 16, 17, 18, 19, 20, 22, 23, 25}
tt.hero.level_stats.ranged_damage_min = {11, 11, 12, 13, 14, 15, 15, 16, 17, 18}
tt.hero.level_stats.ranged_damage_max = {13, 14, 16, 17, 18, 19, 20, 22, 23, 25}
tt.hero.skills.double_strike = CC("hero_skill")
tt.hero.skills.double_strike.damage_max = {120, 180, 240}
tt.hero.skills.double_strike.damage_min = {60, 90, 120}
tt.hero.skills.double_strike.xp_gain_factor = 50
tt.hero.skills.double_strike.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.multishot = CC("hero_skill")
tt.hero.skills.multishot.loops = {5, 7, 10}
tt.hero.skills.multishot.xp_gain_factor = 30
tt.hero.skills.multishot.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.nimble_fencer = CC("hero_skill")
tt.hero.skills.nimble_fencer.chance = {0.4, 0.5, 0.6}
tt.hero.skills.nimble_fencer.xp_gain = {25, 25, 25}
tt.hero.skills.nimble_fencer.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.porcupine = CC("hero_skill")
tt.hero.skills.porcupine.damage_inc = {2, 4, 6, 8}
tt.hero.skills.porcupine.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
-- TODO: 召唤三代3级兵，补强丹哥拦截能力
tt.hero.skills.guards = CC("hero_skill")
tt.hero.skills.guards.hp_max = {100, 125, 150}
tt.hero.skills.guards.armor = {0.4, 0.45, 0.5}
tt.hero.skills.guards.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.guards.xp_gain_factor = 30
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_elves_archer_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 32
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_elves_archer_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr3_hero_portraits_0001"
tt.info.portrait = "kr3_info_portraits_heroes_0001"
tt.main_script.insert = hero_elves_archer_insert
tt.main_script.update = hero_elves_archer_update
tt.motion.max_speed = 110
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.ranged = {"shoot"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_elves_archer"
tt.sound_events.change_rally_point = "ElvesHeroEridanTaunt"
tt.sound_events.death = "ElvesHeroEridanDeath"
tt.sound_events.respawn = "ElvesHeroEridanTauntIntro"
tt.sound_events.insert = "ElvesHeroEridanTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroEridanTauntSelect"
tt.soldier.melee_slot_offset.x = 5
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.dodge.disabled = true
tt.dodge.counter_attack = CC("melee_attack")
tt.dodge.counter_attack.animation = "nimble_fencer"
tt.dodge.counter_attack.cooldown = 0.5
tt.dodge.counter_attack.damage_max = 50
tt.dodge.counter_attack.damage_min = 30
tt.dodge.counter_attack.hit_time = fts(8)
tt.dodge.counter_attack.sound = "ElvesHeroEridanNimbleFencing"
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 3
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "double_strike"
tt.melee.attacks[2].cooldown = 10
tt.melee.attacks[2].damage_max = nil
tt.melee.attacks[2].damage_min = nil
tt.melee.attacks[2].damage_type = bor(DAMAGE_RUDE, DAMAGE_FX_EXPLODE, DAMAGE_NO_DODGE)
tt.melee.attacks[2].never_interrupt = true
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].vis_bans = bor(F_CLIFF)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].xp_from_skill = "double_strike"
tt.melee.attacks[2].sound = "ElvesHeroEridanDoubleStrike"
tt.melee.cooldown = 1
tt.melee.range = 67.5
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "arrow_hero_elves_archer"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 28)}
tt.ranged.attacks[1].cooldown = 0.8
tt.ranged.attacks[1].max_range = 215
tt.ranged.attacks[1].min_range = 67.5
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[2] = CC("bullet_attack")
tt.ranged.attacks[2].animations = {"shoot_start", "shoot_loop", "shoot_end"}
tt.ranged.attacks[2].bullet = "arrow_hero_elves_archer"
tt.ranged.attacks[2].bullet_start_offset = {vec_2(9, 28)}
tt.ranged.attacks[2].cooldown = 9
tt.ranged.attacks[2].disabled = true
tt.ranged.attacks[2].max_range = 215
tt.ranged.attacks[2].shoot_times = {fts(3)}
tt.ranged.attacks[2].xp_from_skill = "multishot"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "levelup"
tt.timed_attacks.list[1].cooldown = 13
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "soldier_hero_elves_archer_guard"
tt.timed_attacks.list[1].sound = "ElvesHeroEridanTaunt"
tt.ultimate = {}
tt.ultimate.ts = 0
tt.ultimate.cooldown = 32
tt.ultimate.disabled = true
tt = RT("soldier_hero_elves_archer_guard", "soldier_barrack_3")

AC(tt, "reinforcement", "nav_grid", "tween")

tt.controable = true
tt.controable_other = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.reinforcement.duration = 14
tt.motion.max_speed = 100
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt = RT("aura_elves_archer_regen", "aura")
tt.aura.duration = -1
tt.main_script.update = scripts.aura_hero_regen.update
tt = RT("arrow_hero_elves_archer", "arrow")
tt.render.sprites[1].name = "archer_hero_proy_0001-f"
tt.bullet.miss_decal = "archer_hero_proy_0002-f"
tt.bullet.flight_time = fts(15)
tt.bullet.pop = {"pop_archer"}
tt.bullet.hide_radius = 1
tt.bullet.xp_gain_factor = 2.8
tt = RT("hero_elves_archer_ultimate")

AC(tt, "pos", "main_script")

tt.cooldown = 40
tt.bullet = "arrow_hero_elves_archer_ultimate"
tt.spread = {6, 8, 10, 12}
tt.damage = {20, 35, 50, 65}
tt.main_script.update = hero_elves_archer_ultimate_update
