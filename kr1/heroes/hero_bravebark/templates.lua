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

local function mod_bravebark_springsap_insert(this, store)
	if not scripts.mod_hps.insert(this, store) then
		return false
	end

	local target = store.entities[this.modifier.target_id]

	if target.template_name == "hero_bravebark" then
		this.render.sprites[1].hidden = true
	else
		this.render.sprites[1].ts = store.tick_ts
	end

	return true
end

local function decal_bravebark_rootspike_update(this, store)
	this.render.sprites[1].hidden = true
	this.render.sprites[1].flip_x = math.random() < 0.5

	U.y_wait_unconditional(store, this.delay)

	local e = E:create_entity(this.hole_decal)

	e.pos.x, e.pos.y = this.pos.x, this.pos.y
	e.render.sprites[1].scale = V.vv(this.scale)

	simulation:queue_insert_entity(e)

	this.render.sprites[1].hidden = false
	this.render.sprites[1].scale = V.vv(this.scale)

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.y_wait_unconditional(store, this.hold_duration)

	e.tween.disabled = nil
	e.tween.ts = store.tick_ts

	U.y_animation_play(this, "out", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

local function mod_bravebark_branchball_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	U.bans_add(target.vis, F_ALL)
	SU.stun_inc(target)

	return true
end

local function mod_bravebark_branchball_update(this, store)
	local target = store.entities[this.modifier.target_id]
	local source = store.entities[this.modifier.source_id]

	if not target or not source then
		simulation:queue_remove_entity(this)

		return
	end

	local af = source.pos.x > target.pos.x

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_wait_unconditional(store, fts(7))
	S:queue("ElvesHeroForestElementalHomerun")
	U.y_wait_unconditional(store, fts(10))

	this.render.sprites[1].hidden = false
	this.render.sprites[1].ts = store.tick_ts

	local decal = E:create_entity("decal_bravebark_rootspikes_hit")

	decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
	decal.tween.ts = store.tick_ts

	simulation:queue_insert_entity(decal)
	U.y_wait_unconditional(store, fts(16))

	local fx = E:create_entity("fx_bravebark_branchball_hit")

	fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)

	local d = E.assign_damage(DAMAGE_EAT, 0, this.id, target.id)

	queue_damage(store, d)

	local es = E:create_entity("decal_bravebark_branchball_enemy_clone")

	es.pos.x, es.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	es.render = U.render_clone(target.render)
	es.render.sprites[1].anchor = this.custom_anchors[target.template_name] or this.custom_anchors.default
	es.tween.disabled = nil
	es.tween.ts = store.tick_ts

	local dx, dy = V.rotate(math.random(20, 45) * math.pi / 180, math.random(240, 300), 0)

	dx = (af and -1 or 1) * dx
	es.tween.props[2].keys[2][2].x, es.tween.props[2].keys[2][2].y = dx, dy
	es.tween.props[3].keys[2][2] = (af and -1 or 1) * math.random(300, 400) * math.pi / 180

	simulation:queue_insert_entity(es)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end

local function hero_bravebark_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_bravebark_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local node_f = {
		pi = nodes[1][1],
		spi = math.random(1, 3),
		ni = nodes[1][3]
	}
	local node_b = {
		pi = nodes[1][1],
		spi = math.random(1, 3),
		ni = nodes[1][3]
	}
	local count = this.count
	local dir = 1
	local node

	for i = 1, 2 * count do
		node = dir == 1 and node_f or node_b

		local node_pos = P:node_pos(node.pi, node.spi, node.ni)

		if P:is_node_valid(node.pi, node.ni) and not GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
			local nni = node.ni + dir * math.random(this.sep_nodes_min, this.sep_nodes_max - 1)
			local nspi = km.zmod(node.spi + math.random(1, 2), 3)

			node.spi, node.ni = nspi, nni

			local e = E:create_entity(this.decal)

			e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
			e.pos = node_pos
			e.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(e)

			local targets = U.find_enemies_in_range_filter_off(e.pos, this.damage_radius, this.vis_flags, this.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local m = E:create_entity(this.mod)

					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)

					local d = E.assign_damage(DAMAGE_TRUE, this.damage * this.damage_factor, this.id, target.id)

					queue_damage(store, d)
				end
			end

			if count % 2 == 0 then
				U.y_wait_unconditional(store, U.frandom(this.show_delay_min, this.show_delay_max))
			end

			count = count - 1
		end

		if count <= 0 then
			break
		end

		dir = -1 * dir
	end

	simulation:queue_remove_entity(this)
end

local function hero_bravebark_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "rootspikes", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.ts = store.tick_ts
		a.damage_max = s.damage_max[s.level]
		a.damage_min = s.damage_min[s.level]
	end)
	upgrade_skill(this, "oakseeds", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.ts = store.tick_ts

		local st = E:get_template(a.entity)

		st.health.hp_max = s.soldier_hp_max[s.level]
		st.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
		st.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
	end)
	upgrade_skill(this, "branchball", function(this, s)
		local a = this.melee.attacks[2]

		a.hp_max = s.hp_max[s.level]
		a.disabled = nil
		a.ts = store.tick_ts
	end)
	upgrade_skill(this, "springsap", function(this, s)
		local a = this.springsap

		a.disabled = nil
		a.ts = store.tick_ts

		local aura = E:get_template(a.aura)

		aura.aura.duration = s.duration[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.hps.heal_min = s.hp_per_cycle[s.level]
		mod.hps.heal_max = s.hp_per_cycle[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil

		local u = E:get_template("hero_bravebark_ultimate")

		u.count = s.count[s.level]
		u.damage = s.damage[s.level]
	end)
	update_hp(this)
end

local function hero_bravebark_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function spawn_spikes(count, center, radius, angle, delay, scale)
		for i = 1, count do
			local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
			local e = E:create_entity("decal_bravebark_rootspike")

			e.pos.x, e.pos.y = p.x, p.y
			e.delay = delay
			e.scale = scale

			simulation:queue_insert_entity(e)
		end
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

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
					goto label_119_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.springsap
			skill = this.hero.skills.springsap

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and U.is_soldiers_around_need_heal(store.soldiers, this.pos, a.trigger_hp_factor, a.radius) then
				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, skill)
				S:queue(a.sound)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

				local aura = E:create_entity(a.aura)

				aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
				aura.tween.ts = store.tick_ts
				aura.aura.radius = a.radius

				simulation:queue_insert_entity(aura)
				U.animation_start_default(this, a.animations[2], nil, store.tick_ts, true)

				while store.tick_ts - a.ts <= aura.aura.duration do
					if SU.hero_interrupted(this) then
						simulation:queue_remove_entity(aura)

						break
					end

					coroutine.yield()
				end

				U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

				a.ts = store.tick_ts

				goto label_119_0
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.oakseeds

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, 0.5, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.3333333333333333
				else
					local node_offset = P:predict_enemy_node_advance(target, 0.5)
					local ni = target.nav_path.ni + node_offset

					S:queue(a.sound)

					local af = target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, af, store.tick_ts)

					if U.y_wait_conditional(store, a.spawn_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						for i = 1, a.count do
							ni = ni + math.random(4, 6)

							if not P:is_node_valid(target.nav_path.pi, ni) then
							-- block empty
							else
								local e = E:create_entity(a.entity)

								e.pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)
								e.nav_rally.center = V.vclone(e.pos)
								e.nav_rally.pos = V.vclone(e.pos)
								e.melee.attacks[1].xp_dest_id = this.id

								local b = E:create_entity(a.bullet)

								b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y

								b.bullet.from:copy(b.pos)
								b.bullet.to:copy(e.pos)

								b.bullet.hit_payload = e

								simulation:queue_insert_entity(b)
							end
						end

						SU.y_hero_animation_wait(this)

						goto label_119_0
					end
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.rootspikes

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local triggers = U.find_enemies_in_range_filter_off(this.pos, a.max_range, a.vis_flags, a.vis_bans)

				if not triggers or #triggers < a.trigger_count then
					a.ts = a.ts + 0.13333333333333333
				else
					S:queue(a.sound)

					local af = triggers[1].pos.x < this.pos.x

					U.animation_start_default(this, a.animation, af, store.tick_ts)

					if U.y_wait_conditional(store, a.hit_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						local targets = U.find_enemies_in_range_filter_off(this.pos, a.damage_radius, a.vis_flags, a.vis_bans)

						if not targets then
						-- block empty
						else
							a.ts = store.tick_ts

							SU.hero_gain_xp_from_skill(this, skill)

							local hit_center = V.v(this.pos.x + a.hit_offset.x * (af and -1 or 1), this.pos.y + a.hit_offset.y)
							local decal = E:create_entity(a.hit_decal)

							decal.pos.x, decal.pos.y = hit_center.x, hit_center.y
							decal.tween.ts = store.tick_ts

							simulation:queue_insert_entity(decal)
							spawn_spikes(7, hit_center, a.decal_range * 0.5, 0, 0, 1)
							spawn_spikes(9, hit_center, a.decal_range / 1.25, 0, 0.07, 0.75)
							spawn_spikes(13, hit_center, a.decal_range, math.pi * 2 / 26, 0.17, 0.5)

							for _, target in ipairs(targets) do
								local d = SU.create_attack_damage(a, target.id, this)

								queue_damage(store, d)
							end

							SU.y_hero_animation_wait(this)

							goto label_119_0
						end
					end
				end
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, this.ultimate.range, F_RANGED, F_NONE, nil, true)

				if target and target.pos and valid_land_node_nearby(target.pos) then
					U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
					S:queue(this.sound_events.change_rally_point)

					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.pos = V.vclone(target.pos)
					e.owner = this
					e.damage_factor = this.unit.damage_factor

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
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

		::label_119_0::

		coroutine.yield()
	end
end

tt = RT("hero_bravebark", "hero")

AC(tt, "melee", "teleport", "timed_attacks")

tt.hero.level_stats.armor = {0.13, 0.16, 0.19, 0.22, 0.25, 0.28, 0.31, 0.34, 0.37, 0.4}
tt.hero.level_stats.hp_max = {375, 400, 425, 450, 475, 500, 525, 550, 575, 600}
tt.hero.level_stats.melee_damage_max = {29, 34, 38, 43, 48, 53, 58, 62, 67, 72}
tt.hero.level_stats.melee_damage_min = {19, 22, 26, 29, 32, 35, 38, 42, 45, 48}
tt.hero.skills.rootspikes = CC("hero_skill")
tt.hero.skills.rootspikes.damage_max = {60, 90, 120}
tt.hero.skills.rootspikes.damage_min = {40, 60, 80}
tt.hero.skills.rootspikes.xp_gain = {100, 200, 300}
tt.hero.skills.rootspikes.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.oakseeds = CC("hero_skill")
tt.hero.skills.oakseeds.xp_gain = {50, 100, 150}
tt.hero.skills.oakseeds.soldier_hp_max = {50, 100, 150}
tt.hero.skills.oakseeds.soldier_damage_max = {4, 8, 12}
tt.hero.skills.oakseeds.soldier_damage_min = {2, 4, 6}
tt.hero.skills.oakseeds.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.branchball = CC("hero_skill")
tt.hero.skills.branchball.hp_max = {750, 1500, 9000000000}
tt.hero.skills.branchball.xp_gain = {160, 320, 480}
tt.hero.skills.branchball.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.springsap = CC("hero_skill")
tt.hero.skills.springsap.duration = {2, 3, 4}
tt.hero.skills.springsap.hp_per_cycle = {7, 14, 21}
tt.hero.skills.springsap.xp_gain = {200, 300, 400}
tt.hero.skills.springsap.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_bravebark_ultimate"
tt.hero.skills.ultimate.count = {6, 9, 12, 15}
tt.hero.skills.ultimate.damage = {30, 40, 50, 60}
tt.hero.skills.ultimate.xp_gain_factor = 28.8
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_bravebark_level_up
tt.hero.hide_after_death = false
tt.info.hero_portrait = "kr3_hero_portraits_0007"
tt.info.portrait = "kr3_info_portraits_heroes_0007"
tt.main_script.update = hero_bravebark_update
tt.motion.max_speed = 2 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[1].prefix = "hero_bravebark"
tt.soldier.melee_slot_offset = vec_2(24, 0)
tt.sound_events.change_rally_point = "ElvesHeroForestElementalTaunt"
tt.sound_events.death = "ElvesHeroForestElementalDeath"
tt.sound_events.respawn = "ElvesHeroForestElementalTauntIntro"
tt.sound_events.insert = "ElvesHeroForestElementalTauntIntro"
tt.sound_events.hero_room_select = "ElvesHeroForestElementalTauntSelect"
tt.teleport.min_distance = 65
tt.teleport.delay = fts(10)
tt.teleport.fx_out = "fx_bravebark_teleport_out"
tt.teleport.fx_in = "fx_bravebark_teleport_in"
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.mod_offset = vec_2(0, 25)
tt.melee.attacks[1].cooldown = 1.7
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_fx = "fx_bravebark_melee_hit"
tt.melee.attacks[1].hit_decal = "decal_bravebark_melee_hit"
tt.melee.attacks[1].hit_offset = vec_2(42, 0)
tt.melee.attacks[1].xp_gain_factor = 2.7
tt.melee.attacks[1].sound_hit = "ElvesHeroForestElementalAttack"
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].cooldown = 35
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return target.health.hp <= a.hp_max
end
tt.melee.attacks[2].mod = "mod_bravebark_branchball"
tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
tt.melee.attacks[2].animation = "branchBall"
tt.melee.attacks[2].hit_time = 0
tt.melee.attacks[2].ignore_rally_change = true
tt.melee.attacks[2].vis_bans = bor(F_BOSS)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
tt.melee.attacks[2].xp_from_skill = "branchball"
tt.melee.range = 65
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].animation = "rootSpikes"
tt.timed_attacks.list[1].cooldown = 20
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].decal_range = 50
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].hit_decal = "decal_bravebark_rootspikes_hit"
tt.timed_attacks.list[1].hit_offset = vec_2(35, 0)
tt.timed_attacks.list[1].hit_time = fts(17)
tt.timed_attacks.list[1].max_range = 75
tt.timed_attacks.list[1].sound = "ElvesHeroForestElementalSpikes"
tt.timed_attacks.list[1].trigger_count = 3
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[1].xp_from_skill = "rootspikes"
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "oakSeeds"
tt.timed_attacks.list[2].bullet = "bullet_bravebark_seed"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].count = 2
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "soldier_bravebark"
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].sound = "ElvesHeroForestElementalTrees"
tt.timed_attacks.list[2].spawn_offset = vec_2(58, 65)
tt.timed_attacks.list[2].spawn_time = fts(12)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_BLOCK)
tt.timed_attacks.list[2].xp_from_skill = "oakseeds"
tt.springsap = {}
tt.springsap.disabled = true
tt.springsap.animations = {"springsap_start", "springsap_loop", "springsap_end"}
tt.springsap.aura = "aura_bravebark_springsap"
tt.springsap.cooldown = 32
tt.springsap.trigger_hp_factor = 0.3
tt.springsap.radius = 100 -- make sure the same as that in aura_bravebark_springsap
tt.springsap.sound = "ElvesHeroForestElementalHealing"
tt.springsap.ts = 0
tt.ultimate = {
	ts = 0,
	cooldown = 32,
	disabled = true,
	range = 180
}
tt = RT("aura_bravebark_springsap", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(3)
tt.aura.mod = "mod_bravebark_springsap"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.excluded_templates = {"soldier_xin_shadow"}
tt.aura.radius = 100
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "bravebark_hero_springSapDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bravebark_springSapBubbles"
tt.render.sprites[2].anchor.y = 0
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {0.85, 0}}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {0.85, vec_1(1.25)}}
tt.tween.props[2].loop = true
tt = RT("mod_bravebark_springsap", "modifier")

AC(tt, "hps", "render", "tween")

tt.modifier.use_mod_offset = false
tt.modifier.duration = 3 * fts(3)
tt.modifier.ban_types = {MOD_TYPE_POISON}
tt.modifier.remove_banned = true
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = fts(3)
tt.main_script.insert = mod_bravebark_springsap_insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].name = "bravebark_hero_healFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].sort_y_offset = -1
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.15, 255}}
tt = RT("hero_bravebark_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = 32
tt.main_script.update = hero_bravebark_ultimate_update
tt.sound_events.insert = "ElvesHeroForestElementalUltimate"
tt.sep_nodes_min = 2
tt.sep_nodes_max = 4
tt.show_delay_min = 0.1
tt.show_delay_max = 0.2
tt.decal = "decal_bravebark_ultimate"
tt.damage_radius = 40
tt.damage_type = DAMAGE_TRUE
tt.vis_flags = bor(F_STUN)
tt.vis_bans = bor(F_FLYING, F_BOSS)
tt.mod = "mod_bravebark_ultimate"
tt = RT("mod_bravebark_ultimate", "mod_stun")
tt.modifier.duration = 1
tt = RT("fx_bravebark_teleport_out", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "bravebark_teleportOutFx"
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "bravebark_hero_teleportDecal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{fts(12), 0}, {fts(13), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportIn"
tt = RT("fx_bravebark_teleport_in", "fx_bravebark_teleport_out")
tt.render.sprites[1].name = "bravebark_teleportInFx"
tt.tween.props[1].keys = {{fts(1), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportOut"
tt = RT("fx_bravebark_branchball_hit", "fx")
tt.render.sprites[1].name = "bravebark_superHit"
tt = RT("fx_bravebark_melee_hit", "fx")
tt.render.sprites[1].name = "bravebark_hitSmoke"
tt.render.sprites[1].anchor.y = 0.2
tt = RT("fx_bravebark_ultimate", "fx")
tt.render.sprites[1].name = "bravebark_spikedRoots_spawnFx"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt = RT("decal_bravebark_rootspikes_hit", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_handDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
tt = RT("decal_bravebark_melee_hit", "decal_bravebark_rootspikes_hit")
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = RT("decal_bravebark_rootspike", "decal_scripted")
tt.render.sprites[1].prefix = "bravebark_spike"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.25
tt.main_script.update = decal_bravebark_rootspike_update
tt.hold_duration = 1
tt.hole_decal = "decal_bravebark_rootspike_hole"
tt.delay = 0
tt.scale = 1
tt = RT("decal_bravebark_rootspike_hole", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = RT("decal_bravebark_ultimate", "decal_sequence")
tt.render.sprites[1].prefix = "bravebark_spikedRoots"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].scale = vec_1(0.75)
tt.sequence.steps = {"in", 1, "out"}
tt.sequence.fxs = {"fx_bravebark_ultimate", nil, "decal_bravebark_ultimate_crater"}
tt = RT("decal_bravebark_ultimate_crater", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikedRootsDecal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
tt = RT("bullet_bravebark_seed", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(22)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bravebark_hero_mignonSeed"
tt = RT("mod_bravebark_branchball", "modifier")

AC(tt, "render")

tt.main_script.insert = mod_bravebark_branchball_insert
tt.main_script.update = mod_bravebark_branchball_update
tt.custom_anchors = {}
tt.custom_anchors.default = vec_2(0.5, 0.45)
tt.render.sprites[1].name = "bravebark_paralyzeRoots"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].anchor.y = 0.22727272727272727
