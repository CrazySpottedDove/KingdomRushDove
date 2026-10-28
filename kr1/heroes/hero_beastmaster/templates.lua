local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")
local log = require("lib.klua.log"):new("hero_beastmaster")

require("lib.klua.table")
require("all.constants")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function beastmaster_rhino_insert(this, store)
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not this.pos then
		return false
	end

	return true
end

local function beastmaster_rhino_update(this, store)
	local attack = this.attack

	this.tween.ts = store.tick_ts

	while true do
		local next = P:next_entity_node(this, store.tick_length)

		if not next then
			log.debug("  X not next for %s", this.id)
			simulation:queue_remove_entity(this)

			return
		end

		if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or band(GR:cell_type(next.x, next.y), bor(TERRAIN_CLIFF, TERRAIN_WATER, TERRAIN_FAERIE)) ~= 0 then
			if store.tick_ts - this.tween.ts < this.duration - 0.25 then
				log.debug("  FF finish early for %s", this.id)

				this.tween.ts = store.tick_ts - this.duration + 0.25
			end
		end

		U.set_destination(this, next)

		local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start_default(this, an, af, store.tick_ts)
		U.walk_off__accel__unsnapped(this, store.tick_length)

		if store.tick_ts - attack.ts >= attack.cooldown then
			attack.ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_on(this.pos, attack.damage_radius, attack.damage_flags, attack.damage_bans, function(v)
				return not table.contains(this.shared_enemies_hit, v)
			end)

			if not targets then
			-- block empty
			else
				for _, e in ipairs(targets) do
					if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 and math.random() < attack.mod_chance then
						local m = E:create_entity(attack.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id

						simulation:queue_insert_entity(m)
					end

					local d = E.assign_damage(attack.damage_type, attack.damage, this.id, e.id)

					queue_damage(store, d)
					table.insert(this.shared_enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end
end

local function beastmaster_falcon_get_info(this)
	return {
		armor = 0,
		type = STATS_TYPE_SOLDIER,
		hp = this.fake_hp,
		hp_max = this.fake_hp,
		damage_min = this.custom_attack.damage_min,
		damage_max = this.custom_attack.damage_max
	}
end

local function beastmaster_falcon_update(this, store)
	local sf = this.render.sprites[1]
	local h = this.owner
	local fm = this.force_motion
	local ca = this.custom_attack

	sf.offset.y = this.flight_height

	U.y_animation_play(this, "respawn", nil, store.tick_ts)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		if h.health.dead then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			simulation:queue_remove_entity(this)

			return
		end

		if store.tick_ts - ca.ts > ca.cooldown then
			local target = U.find_nearest_enemy(store, this.pos, ca.min_range, ca.max_range, ca.vis_flags, ca.vis_bans)

			if not target then
				ca.ts = ca.ts + 0.13333333333333333
			else
				S:queue(ca.sound)
				U.animation_start_default(this, "attack_fly", nil, store.tick_ts, false)

				local accel = 180
				local max_speed = 300
				local min_speed = 60
				local mspeed = min_speed
				local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
				local start_dist = dist
				local start_h = sf.offset.y
				local target_h = target.unit.hit_offset.y

				while dist > mspeed * store.tick_length and not target.health.dead do
					local tx, ty = target.pos.x, target.pos.y
					local dx, dy = V.mul(mspeed * store.tick_length, V.normalize(V.sub(tx, ty, this.pos.x, this.pos.y)))

					this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, dx, dy)
					sf.offset.y = km.clamp(0, this.flight_height * 1.5, start_h + (target_h - start_h) * (1 - dist / start_dist))
					sf.flip_x = dx < 0

					coroutine.yield()

					dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
					mspeed = km.clamp(min_speed, max_speed, mspeed + accel * store.tick_length)
				end

				if target.health.dead then
					ca.ts = store.tick_ts
				else
					this.pos.x, this.pos.y = target.pos.x, target.pos.y - 1

					local d = E.assign_damage(ca.damage_type, math.random(ca.damage_min, ca.damage_max), this.id, target.id)

					d.xp_gain_factor = ca.xp_gain_factor
					d.xp_dest_id = h.id

					queue_damage(store, d)

					local m = E:create_entity(ca.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = target.id

					simulation:queue_insert_entity(m)
					U.y_animation_play(this, "attack_hit", nil, store.tick_ts, 1)

					ca.ts = store.tick_ts
				end
			end
		end

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)

		local dx, dy = V.sub(h.pos.x, h.pos.y, this.pos.x, this.pos.y)

		if V.len(dx, dy) > 50 then
			fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(1440, V.mul(4, dx, dy)))
		end

		if V.len(fm.a.x, fm.a.y) > 1 then
			fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
			fm.a.x, fm.a.y = 0, 0
		else
			fm.v.x, fm.v.y = 0, 0
			fm.a.x, fm.a.y = 0, 0
		end

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = V.trim(1800, V.mul(-0.75, fm.v.x, fm.v.y))
		sf.offset.y = km.clamp(0, this.flight_height, sf.offset.y + this.flight_speed * store.tick_length)
		sf.flip_x = fm.v.x < 0

		coroutine.yield()
	end
end

local function beastmaster_pet_insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function beastmaster_pet_update(this, store)
	local brk, sta

	if this.template_name == "beastmaster_boar" then
		U.y_animation_play(this, "spawn", nil, store.tick_ts)
	end

	while true do
		if this.health.dead then
			table.removeobject(this.owner.boars, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos, this.nav_grid.valid_terrains)

				if SU.y_hero_new_rally(store, this) then
					goto label_344_0
				end
			end

			if this.melee then
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
					goto label_344_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_344_0::

		coroutine.yield()
	end
end

local function beastmaster_pet_level_up(this, s)
	if this.template_name == "beastmaster_boar" then
		this.health.hp_max = s.boar_hp_max[s.level]
	elseif this.template_name == "beastmaster_wolf" then
		this.health.hp_max = s.wolf_hp_max[s.level]
	end

	update_hp(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "boarmaster", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.max = s.boars[s.level]

		local e = E:get_template(a.entities[1])

		e.health.hp_max = s.boar_hp_max[s.level]

		local e = E:get_template(a.entities[2])

		e.health.hp_max = s.wolf_hp_max[s.level]

		for _, pet in pairs(this.boars) do
			pet.fn_level_up(this, s)
		end
	end)
	upgrade_skill(this, "stampede", function(this, s)
		this.timed_attacks.list[1].disabled = nil
		this.timed_attacks.list[1].count = s.rhinos[s.level]

		local r = E:get_template(this.timed_attacks.list[1].entity)

		r.duration = s.duration[s.level]
		r.attack.damage = s.damage[s.level]
		r.attack.mod_chance = s.stun_chance[s.level]

		local m = E:get_template(r.attack.mod)

		m.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "deeplashes", function(this, s)
		local a = this.melee.attacks[2]

		a.disabled = nil
		a.damage_min = s.damage[s.level]
		a.damage_max = s.damage[s.level]
		a.cooldown = s.cooldown[s.level]

		local m = E:get_template(a.mod)

		m.dps.damage_min = s.blood_damage[s.level] / m.modifier.duration
		m.dps.damage_max = s.blood_damage[s.level] / m.modifier.duration
	end)
	upgrade_skill(this, "falconer", function(this, s)
		this.falcons_max = s.count[s.level]
	end)
	update_hp(this)

	this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
end

local function hero_insert(this, store)
	this.hero.fn_level_up(this, store)

	this.melee.order = U.attack_order(this.melee.attacks)

	local e = E:create_entity("aura_beastmaster_regeneration")

	e.aura.source_id = this.id
	e.aura.ts = store.tick_ts

	simulation:queue_insert_entity(e)

	return true
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	local function distribute_boars(x, y, qty)
		if qty < 1 then
			return nil
		end

		local nodes = P:nearest_nodes(x, y, nil, nil, true)

		if #nodes < 1 then
			log.debug("cannot insert boars, no valid nodes nearby %s,%s", x, y)

			return nil
		end

		local opi, ospi, oni = unpack(nodes[1])
		local offset_options = {-2, -4, -6, -8, 2, 4, 6, 8}
		local positions = {}

		for i, offset in ipairs(offset_options) do
			if qty <= #positions then
				break
			end

			local ni = oni + offset
			local spi = km.zmod(ospi + i, 3)
			local npos = P:node_pos(opi, spi, ni)

			if P:is_node_valid(opi, ni) and band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) == 0 then
				table.insert(positions, npos)
			end
		end

		if qty > #positions then
			log.debug("could not find valid offsets for boars around %s,%s", x, y)

			return nil
		end

		return positions
	end

	U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			this.falcons = {}

			SU.y_hero_death_and_respawn(store, this)
		end

		if #this.falcons < this.falcons_max then
			local e = E:create_entity(this.falcons_name)

			e.pos = V.v(math.random(10, 30) * km.rand_sign(), math.random(-15, 15))
			e.pos.x, e.pos.y = e.pos.x + this.pos.x, e.pos.y + this.pos.y

			simulation:queue_insert_entity(e)

			e.owner = this

			table.insert(this.falcons, e)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local positions = distribute_boars(this.nav_rally.pos.x, this.nav_rally.pos.y, #this.boars)

				if positions then
					for i, boar in ipairs(this.boars) do
						local pos = positions[i]

						boar.nav_rally.center = pos
						boar.nav_rally.pos = pos
						boar.nav_rally.new = true
					end
				end

				if SU.y_hero_new_rally(store, this) then
					goto label_339_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.boarmaster

			if not a.disabled and #this.boars >= a.max then
				-- a.ts = store.tick_ts
				a.disabled = true
			elseif a.disabled and #this.boars < a.max then
				a.disabled = nil
				a.ts = store.tick_ts
			end

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) and #this.boars < a.max then
				local positions = distribute_boars(this.pos.x, this.pos.y, a.max)

				if not positions then
				-- block empty
				else
					local start_ts = store.tick_ts

					this.health.immune_to = F_ALL

					S:queue(a.sound)
					U.animation_start_default(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - start_ts < a.spawn_time do
						if this.nav_rally.new then
							goto label_339_0
						end

						if this.health.dead then
							goto label_339_0
						end

						if this.unit.is_stunned then
							goto label_339_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					while #this.boars < a.max do
						local e

						if math.random() < 0.5 then
							e = E:create_entity(a.entities[1])
						else
							e = E:create_entity(a.entities[2])
						end

						e.pos = positions[#this.boars + 1]
						e.nav_rally.center = V.vclone(e.pos)
						e.nav_rally.pos = V.vclone(e.pos)
						e.melee.attacks[1].xp_dest_id = this.id
						e.render.sprites[1].flip_x = math.random() < 0.5

						simulation:queue_insert_entity(e)

						e.owner = this

						table.insert(this.boars, e)
					end

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_339_0
						end

						if this.health.dead then
							goto label_339_0
						end

						if this.unit.is_stunned then
							goto label_339_0
						end

						coroutine.yield()
					end

					this.health.immune_to = 0
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
				end
			end

			a = this.timed_attacks.list[1]
			skill = this.hero.skills.stampede

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max, 60, a.vis_flags, a.vis_bans, true)

				if not target_info then
					a.ts = a.ts + 1
				else
					local target = target_info[1].enemy
					local origin = target_info[1].origin
					local start_ts = store.tick_ts

					this.health.immune_to = F_ALL

					S:queue(a.sound)

					local flip = target.pos.x < this.pos.x

					U.animation_start_default(this, a.animation, flip, store.tick_ts)

					while store.tick_ts - start_ts < a.spawn_time do
						if this.nav_rally.new then
							goto label_339_0
						end

						if this.health.dead then
							goto label_339_0
						end

						if this.unit.is_stunned then
							goto label_339_0
						end

						coroutine.yield()
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local sni = origin[3] + 2

					for i = 1, a.count do
						local spawn = E:create_entity(a.entity)

						spawn.nav_path.pi = origin[1]
						spawn.nav_path.spi = km.zmod(i, 3)
						spawn.nav_path.ni = sni
						spawn.shared_enemies_hit = {}

						simulation:queue_insert_entity(spawn)

						sni = km.clamp(1, origin[3] + 2, sni - 2)
					end

					while not U.animation_finished_default(this) do
						if this.nav_rally.new then
							goto label_339_0
						end

						if this.health.dead then
							goto label_339_0
						end

						if this.unit.is_stunned then
							goto label_339_0
						end

						coroutine.yield()
					end

					this.health.immune_to = 0
					a.ts = store.tick_ts
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

		::label_339_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_beastmaster", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.hp_max = {330, 360, 390, 420, 450, 480, 510, 540, 570, 600}
tt.hero.level_stats.armor = {0, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18}
tt.hero.level_stats.melee_damage_min = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
tt.hero.level_stats.melee_damage_max = {12, 14, 16, 18, 20, 22, 24, 26, 28, 30}
tt.hero.skills.boarmaster = CC("hero_skill")
tt.hero.skills.boarmaster.boars = {1, 2, 3, 4}
tt.hero.skills.boarmaster.boar_hp_max = {160, 200, 240, 280}
tt.hero.skills.boarmaster.wolf_hp_max = {80, 100, 120, 140}
tt.hero.skills.boarmaster.xp_level_steps = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
	[8] = 4
}
tt.hero.skills.boarmaster.xp_gain = {40, 80, 120, 160}
tt.hero.skills.stampede = CC("hero_skill")
tt.hero.skills.stampede.rhinos = {2, 3, 4, 5}
tt.hero.skills.stampede.duration = {3, 6, 9, 12}
tt.hero.skills.stampede.stun_chance = {0.25, 0.375, 0.5, 0.625}
tt.hero.skills.stampede.stun_duration = {1.5, 2.5, 3.5, 4.5}
tt.hero.skills.stampede.damage = {20, 25, 30, 35}
tt.hero.skills.stampede.xp_gain = {60, 120, 180, 240}
tt.hero.skills.stampede.xp_level_steps = {
	[3] = 1,
	[5] = 2,
	[7] = 3,
	[9] = 4
}
tt.hero.skills.falconer = CC("hero_skill")
tt.hero.skills.falconer.count = {1, 2, 3}
tt.hero.skills.falconer.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.deeplashes = CC("hero_skill")
tt.hero.skills.deeplashes.damage = {20, 40, 60, 80}
tt.hero.skills.deeplashes.blood_damage = {20, 40, 60, 80}
tt.hero.skills.deeplashes.cooldown = {6.9, 6.2, 5.5, 4.8}
tt.hero.skills.deeplashes.xp_gain = {50, 100, 150, 200}
tt.hero.skills.deeplashes.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.idle_flip.cooldown = 1
tt.info.hero_portrait = "kr2_hero_portraits_0004"
tt.info.portrait = "kr2_info_portraits_heroes_0004"
tt.main_script.insert = hero_insert
tt.main_script.update = hero_update
tt.motion.max_speed = 100
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.175
tt.render.sprites[1].prefix = "hero_beastmaster"
tt.soldier.melee_slot_offset.x = 13
tt.sound_events.change_rally_point = "HeroBeastMasterTaunt"
tt.sound_events.death = "HeroBeastMasterDeath"
tt.sound_events.respawn = "HeroBeastMasterTauntIntro"
tt.sound_events.insert = "HeroBeastMasterTauntIntro"
tt.sound_events.hero_room_select = "HeroBeastMasterTauntSelect"
tt.unit.mod_offset = vec_2(0, 18)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.range = 75
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 4.4
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].animation = "lash"
tt.melee.attacks[2].cooldown = 6 + 0.9
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_BLOOD)
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].sound = "HeroBeastMasterAttack"
tt.melee.attacks[2].mod = "mod_beastmaster_lash"
tt.melee.attacks[2].pop = nil
tt.melee.attacks[2].xp_from_skill = "deeplashes"
tt.boars = {}
tt.falcons = {}
tt.falcons_max = 0
tt.falcons_name = "beastmaster_falcon"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "stampede"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "beastmaster_rhino"
tt.timed_attacks.list[1].range_nodes_max = 40
tt.timed_attacks.list[1].range_nodes_min = 5
tt.timed_attacks.list[1].sound = "HeroBeastMasterSummonRhinos"
tt.timed_attacks.list[1].spawn_time = fts(15)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_WATER, F_CLIFF)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = CC("spawn_attack")
tt.timed_attacks.list[2].animation = "pets"
tt.timed_attacks.list[2].cooldown = 13.5
tt.timed_attacks.list[2].max = 0
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entities = {"beastmaster_boar", "beastmaster_wolf"}
tt.timed_attacks.list[2].sound = "HeroBeastMasterSummonBoar"
tt.timed_attacks.list[2].spawn_time = fts(35)
tt.vis.bans = F_POISON
tt = RT("mod_beastmaster_lash", "mod_blood")
tt.modifier.duration = 6
tt.modifier.level = 0
tt = RT("beastmaster_boar", "soldier")

AC(tt, "melee", "nav_grid")

tt.info.portrait = "kr2_info_portraits_soldiers_0016"
tt.health.armor = 0.1
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 28)
tt.info.fn = scripts.soldier_barrack.get_info
tt.main_script.insert = beastmaster_pet_insert
tt.main_script.update = beastmaster_pet_update
tt.fn_level_up = beastmaster_pet_level_up
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "HeroBeastMasterBoarAttack"
tt.melee.attacks[1].xp_gain_factor = 1
tt.melee.range = 85
tt.motion.max_speed = 69
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.29
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "beastmaster_boar"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.soldier.melee_slot_offset.x = 9
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.hide_after_death = true
tt.unit.explode_fx = nil
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("beastmaster_wolf", "soldier")

AC(tt, "melee", "nav_grid", "dodge")

tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.health.magic_armor = 0.5
tt.health.hp_max = 150
tt.health_bar.offset = vec_2(0, 42)
tt.regen.cooldown = 1
tt.info.enc_icon = 14
tt.info.portrait = "info_portraits_enemies_0011"
tt.info.fn = scripts.soldier_barrack.get_info
tt.main_script.insert = beastmaster_pet_insert
tt.main_script.update = beastmaster_pet_update
tt.fn_level_up = beastmaster_pet_level_up
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].sound = "WolfAttack"
tt.melee.attacks[1].damage_max = 16
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.range = 85
tt.motion.max_speed = 80
tt.render.sprites[1].anchor = vec_2(0.6, 0.31)
tt.render.sprites[1].prefix = "enemy_wolf"
tt.render.sprites[1].scale = vec_2(1.2, 1.2)
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 15.6)
tt.unit.marker_offset.y = 2.4
tt.unit.mod_offset = vec_2(4.8, 18.2)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = RT("beastmaster_rhino", "decal_scripted")

AC(tt, "nav_path", "motion", "sound_events", "tween")

tt.attack = CC("area_attack")
tt.attack.cooldown = fts(6)
tt.attack.damage = 15
tt.attack.damage_radius = 32.5
tt.attack.damage_type = DAMAGE_RUDE
tt.attack.mod = "mod_beastmaster_rhino"
tt.attack.damage_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.main_script.insert = beastmaster_rhino_insert
tt.main_script.update = beastmaster_rhino_update
tt.motion.max_speed = 90
tt.nav_path.dir = -1
tt.render.sprites[1].anchor.y = 0.45
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].angles_custom = {
	walk = {55, 135, 240, 315}
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].prefix = "decal_rhino"
tt.sound_events.insert = "HeroBeastMasterStampede"
tt.sound_events.insert_args = {
	ignore = 1
}
tt.sound_events.remove_stop = "HeroBeastMasterStampede"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}, {"this.duration", 255}, {"this.duration+0.5", 0}}
tt = RT("mod_beastmaster_rhino", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.render.sprites[1].prefix = "stun"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt = RT("beastmaster_falcon", "decal_scripted")

AC(tt, "force_motion", "info", "ui", "custom_attack")

tt.fake_hp = 60
tt.main_script.update = beastmaster_falcon_update
tt.info.fn = beastmaster_falcon_get_info
tt.info.portrait = "kr2_info_portraits_soldiers_0017"
tt.flight_speed = 45
tt.flight_height = 80
tt.custom_attack = CC("custom_attack")
tt.custom_attack.min_range = 0
tt.custom_attack.max_range = 150
tt.custom_attack.damage_min = 12
tt.custom_attack.damage_max = 36
tt.custom_attack.cooldown = 2.5
tt.custom_attack.xp_gain_factor = 0.85
tt.custom_attack.damage_type = DAMAGE_RUDE
tt.custom_attack.vis_flags = F_RANGED
tt.custom_attack.sound = "HeroBeastMasterFalconAttack"
tt.custom_attack.mod = "mod_beastmaster_falcon"
tt.render.sprites[1].prefix = "decal_falcon"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.ui.click_rect = r(-15, 65, 30, 30)
tt = RT("mod_beastmaster_falcon", "mod_slow")
tt.modifier.duration = 1.5
