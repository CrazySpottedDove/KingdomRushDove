local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_malik")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage

local function aura_fissure_update(this, store)
	local a = this.aura

	local function do_attack(pos)
		local fx = E:create_entity(a.fx)

		fx.pos.x, fx.pos.y = pos.x, pos.y
		fx.render.sprites[2].ts = store.tick_ts
		fx.tween.ts = store.tick_ts

		simulation:queue_insert_entity(fx)

		local targets = U.find_enemies_in_range_filter_off(pos, a.damage_radius, a.vis_flags, a.vis_bans)

		if targets then
			for _, t in ipairs(targets) do
				local d = E.assign_damage(a.damage_type, math.random(a.damage_min, a.damage_max), this.id, t.id)

				queue_damage(store, d)

				if U.flags_pass(t.vis, this.stun) then
					local m = E:create_entity(this.stun.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			end

			log.paranoid(">>>> aura_malik_fissure POS:%s,%s  damaged:%s", pos.x, pos.y, table.concat(table.map(targets, function(k, v)
				return v.id
			end), ","))
		end
	end

	do_attack(this.pos)

	local pi, ni, pis

	if a.target_id and store.entities[a.target_id] then
		local np = store.entities[a.target_id].nav_path

		pi, ni = np.pi, np.ni
	else
		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

		if #nodes < 1 then
			log.error("aura_malik_fissure could not find valid nodes near %s,%s", this.pos.x, this.pos.y)

			goto label_201_0
		end

		pi, ni = nodes[1][1], nodes[1][3]
	end

	pis = {{
		pi = pi,
		ni1 = ni,
		ni2 = ni
	}}

	for i = 1, a.level do
		U.y_wait_unconditional(store, a.spread_delay)

		local node_pos1 = P:node_pos(pi, 1, pis[1].ni1 + a.spread_nodes)
		local node_pos2 = P:node_pos(pi, 1, pis[1].ni2 - a.spread_nodes)
		local nodes = P:nearest_nodes(node_pos1.x, node_pos1.y, nil, nil, true)

		if #nodes > 1 then
			local npi, _, nni = unpack(nodes[2])
			local new = true

			for _, p in pairs(pis) do
				if p.pi == npi then
					new = false

					break
				end
			end

			if new then
				table.insert(pis, {
					pi = npi,
					ni1 = nni,
					ni2 = nni
				})
			end
		end

		local nodes = P:nearest_nodes(node_pos2.x, node_pos2.y, nil, nil, true)

		if #nodes > 1 then
			local npi, _, nni = unpack(nodes[2])
			local new = true

			for _, p in pairs(pis) do
				if p.pi == npi then
					new = false

					break
				end
			end

			if new then
				table.insert(pis, {
					pi = npi,
					ni1 = nni,
					ni2 = nni
				})
			end
		end

		for _, p in pairs(pis) do
			p.ni1 = p.ni1 + a.spread_nodes
			p.ni2 = p.ni2 - a.spread_nodes

			do_attack(P:node_pos(p.pi, 1, p.ni1))
			do_attack(P:node_pos(p.pi, 1, p.ni2))
		end

		if i > 1 then
			for _, p in pairs(pis) do
				do_attack(P:node_pos(p.pi, 2, p.ni1 - a.spread_nodes))
				do_attack(P:node_pos(p.pi, 2, p.ni2 + a.spread_nodes))
				do_attack(P:node_pos(p.pi, 3, p.ni1 - a.spread_nodes))
				do_attack(P:node_pos(p.pi, 3, p.ni2 + a.spread_nodes))
			end
		end
	end

	::label_201_0::

	simulation:queue_remove_entity(this)
end

local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "smash", function(this, s)
		local a = this.melee.attacks[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.mod_chance = s.stun_chance[s.level]
	end)
	upgrade_skill(this, "fissure", function(this, s)
		local a = this.melee.attacks[4]

		a.disabled = nil

		local au = E:get_template(a.hit_aura)

		au.aura.level = s.level
		au.aura.damage_min = s.damage_min[s.level]
		au.aura.damage_max = s.damage_max[s.level]
	end)
	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local brk, sta

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
					goto label_81_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
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

		::label_81_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_malik", "hero")

AC(tt, "melee")

tt.hero.level_stats.armor = {0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2}
tt.hero.level_stats.hp_max = {450, 500, 550, 600, 650, 720, 790, 860, 930, 1000}
tt.hero.level_stats.melee_damage_max = {26, 29, 31, 34, 36, 38, 41, 43, 45, 47}
tt.hero.level_stats.melee_damage_min = {19, 20, 23, 24, 26, 28, 29, 31, 34, 37}
tt.hero.skills.smash = CC("hero_skill")
tt.hero.skills.smash.damage_min = {26, 31, 41}
tt.hero.skills.smash.damage_max = {35, 42, 52}
tt.hero.skills.smash.stun_chance = {0.3, 0.4, 0.5}
tt.hero.skills.smash.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
-- tt.hero.skills.smash.xp_gain = {50, 100, 150}
tt.hero.skills.fissure = CC("hero_skill")
tt.hero.skills.fissure.damage_min = {5, 14, 23, 32}
tt.hero.skills.fissure.damage_max = {25, 34, 43, 52}
tt.hero.skills.fissure.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.fissure.xp_gain = {50, 100, 150, 200}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 38)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0003"
tt.info.portrait = "info_portraits_heroes_0003"
tt.main_script.update = hero_update
tt.motion.max_speed = 2.6 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.1)
tt.render.sprites[1].prefix = "hero_malik"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.hero_room_select = "HeroReinforcementTauntSelect"
tt.sound_events.insert = "HeroReinforcementTauntIntro"
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.unit.mod_offset = vec_2(0, 20)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 1.6
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.3
tt.melee.attacks[2].xp_gain_factor = 3.6
tt.melee.attacks[2].mod = "mod_malik_stun"
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "smash"
tt.melee.attacks[3].cooldown = 3.2
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 90
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_bomb_crater"
tt.melee.attacks[3].hit_fx = "decal_malik_ring"
tt.melee.attacks[3].hit_time = fts(14)
tt.melee.attacks[3].hit_offset = vec_2(22, 0)
tt.melee.attacks[3].min_count = 1
tt.melee.attacks[3].sound = "HeroReinforcementSpecial"
-- tt.melee.attacks[3].xp_from_skill = "smash"
tt.melee.attacks[3].mod = "mod_malik_stun"
tt.melee.attacks[3].mod_chance = 0.2
tt.melee.attacks[3].xp_gain_factor = 1.6
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "fissure"
tt.melee.attacks[4].cooldown = 10 + fts(37)
tt.melee.attacks[4].damage_radius = 50
tt.melee.attacks[4].damage_type = DAMAGE_NONE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_aura = "aura_malik_fissure"
tt.melee.attacks[4].hit_offset = vec_2(22, 0)
tt.melee.attacks[4].hit_time = fts(17)
tt.melee.attacks[4].sound = "HeroReinforcementJump"
tt.melee.attacks[4].xp_from_skill = "fissure"
tt = RT("aura_malik_fissure", "aura")
tt.aura.fx = "decal_malik_earthquake"
tt.aura.damage_radius = 40
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.spread_delay = fts(4)
tt.aura.spread_nodes = 4
tt.main_script.update = aura_fissure_update
tt.stun = {
	vis_flags = bor(F_RANGED, F_STUN),
	vis_bans = bor(F_FLYING, F_BOSS),
	mod = "mod_malik_stun"
}
tt = RT("mod_malik_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_FLYING, F_BOSS)
tt = RT("decal_malik_ring", "decal_timed")
tt.render.sprites[1].name = "decal_malik_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
