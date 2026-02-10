require("lib.klua.table")
require("i18n")
local scripts = require("scripts")

local AC = require("achievements")
local log = require("lib.klua.log"):new("game_scripts")
local SH = require("klove.shader_db")
local EXO = require("all.exoskeleton")
require("lib.klua.table")
require("all.constants")

local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("lib.klua.vector")
local W = require("wave_db")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local IS_PHONE = KR_TARGET == "phone"
local IS_CONSOLE = KR_TARGET == "console"
-- local simulation = require("simulation")
local v = V.v

local function tpos(e)
	return e.tower and e.tower.range_offset and v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local function enemy_ready_to_magic_attack(this, store, attack)
	return this.enemy.can_do_magic and store.tick_ts - attack.ts > attack.cooldown
end

local function ready_to_attack(attack, store, factor)
	return store.tick_ts - attack.ts > attack.cooldown * (factor or 1)
end

local function get_attack_ready(attack, store)
	attack.ts = store.tick_ts - attack.cooldown
end

local function enemy_is_silent_target(e)
	return (band(e.vis.flags, F_SPELLCASTER) ~= 0 or e.ranged or e.timed_attacks or e.auras or e.death_spawns) and e.enemy.can_do_magic
end

local function fts(v)
	return v / FPS
end

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local function soldiers_around_need_heal(this, store, trigger_hp_factor, range)
	local targets = table.filter(store.soldiers, function(k, v)
		return (not v.reinforcement) and (not v.health.dead and v.health.hp < trigger_hp_factor * v.health.hp_max) and U.is_inside_ellipse(v.pos, this.pos, range)
	end)

	if not targets or #targets == 0 then
		return false
	else
		return true
	end
end

local function y_show_taunt_set(store, taunts, set_name, index, wait)
	local set = taunts.sets[set_name]

	index = index or set.idxs and table.random(set.idxs) or math.random(set.start_idx, set.end_idx)

	local duration = taunts.duration
	local taunt_id = _(string.format(set.format, index))

	log.info("show taunt " .. taunt_id)
	signal.emit("show-balloon_tutorial", taunt_id, false)

	if wait then
		U.y_wait(store, duration)
	end
end

scripts.eb_juggernaut = {}

function scripts.eb_juggernaut.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_juggernaut.update(this, store)
	local ma = this.timed_attacks.list[1]
	local ba = this.timed_attacks.list[2]

	local function ready_to_shoot()
		for _, a in pairs(this.timed_attacks.list) do
			if enemy_ready_to_magic_attack(this, store, a) then
				return true
			end
		end

		return false
	end

	local spawn_level = 0

	ma.ts = store.tick_ts
	ba.ts = store.tick_ts

	::label_129_0::

	while true do
		if this.health.dead then
			if store.level_idx == 6 then
				LU.kill_all_enemies(store, true)
			end

			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			for _, a in pairs(this.timed_attacks.list) do
				if store.tick_ts - a.ts < a.cooldown then
				-- block empty
				else
					local target

					if a == ma then
						local targets = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if not targets then
							SU.delay_attack(store, a, 0.5)

							goto label_129_1
						end

						target = targets[1]
					end

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					U.y_wait(store, a.shoot_time)

					local af = this.render.sprites[1].flip_x
					local o = a.bullet_start_offset
					local b = E:create_entity(a.bullet)

					b.bullet.source_id = this.id
					b.bullet.target_id = target and target.id
					b.bullet.from = v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
					b.pos = V.vclone(b.bullet.from)

					if a == ma then
						b.bullet.to = v(b.pos.x + a.launch_vector.x, b.pos.y + a.launch_vector.y)
					else
						b.bullet.to = P:get_random_position(20, TERRAIN_LAND, NF_RANGE, 30)
						E:get_template(b.bullet.hit_payload).level = spawn_level < 7 and spawn_level or 7
						b.bullet.hit_payload = E:create_entity(b.bullet.hit_payload)
						b.bullet.hit_payload.spawner.owner_id = this.id
						spawn_level = spawn_level + 1
					end

					if b.bullet.to then
						queue_insert(store, b)
					else
						log.debug("could not find random position to shoot juggernaut bomb. skipping...")
					end

					U.y_animation_wait(this)

					a.ts = store.tick_ts
				end

				::label_129_1::
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_shoot)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_129_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_shoot() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_129_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_jt = {}

function scripts.eb_jt.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_jt.on_damage(this, store, damage)
	local pd = U.predict_damage(this, damage)

	if pd >= this.health.hp then
		this.dying = true
		this.health_bar.hidden = true
		this.health.ignore_damage = true
		this.ui.can_select = false
		this.vis.bans = F_ALL

		SU.remove_modifiers(store, this)
		SU.stun_inc(this)

		return false
	end

	return true
end

function scripts.eb_jt.update(this, store)
	local fa = this.timed_attacks.list[1]

	local function ready_to_freeze()
		return enemy_ready_to_magic_attack(this, store, fa)
	end

	fa.ts = store.tick_ts

	::label_133_0::

	while true do
		if this.dying then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			if IS_CONSOLE then
				U.y_wait(store, this.tap_timeout)
			else
				local tap = SU.insert_sprite(store, this.tap_decal, this.pos)

				this.ui.clicked = nil

				while not this.ui.clicked do
					coroutine.yield()
				end

				queue_remove(store, tap)
			end

			S:stop_all()
			S:queue(this.sound_events.death_explode)
			U.y_animation_play(this, "death_end", nil, store.tick_ts)

			this.health.ignore_damage = false
			this.health.hp = 0

			coroutine.yield()
			LU.kill_all_enemies(store, true)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned and not this.dying then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_freeze() then
				local towers = U.find_towers_in_range(store.towers, this.pos, fa, function(t)
					return t.tower.can_be_mod
				end)

				if not towers then
					SU.delay_attack(store, fa, 0.5)
				else
					SU.hide_modifiers(store, this, true)
					U.animation_start(this, "freeze", nil, store.tick_ts, 1)
					S:queue(fa.sound, fa.sound_args)
					U.y_wait(store, fa.hit_time)

					local hit_pos = V.vclone(this.pos)
					local af = this.render.sprites[1].flip_x

					if fa.hit_offset then
						hit_pos.x = hit_pos.x + (af and -1 or 1) * fa.hit_offset.x
						hit_pos.y = hit_pos.y + fa.hit_offset.y
					end

					SU.insert_sprite(store, fa.hit_decal, hit_pos)

					for i, t in ipairs(towers) do
						if i >= fa.count then
							break
						end

						local m = E:create_entity(fa.mod)

						m.modifier.target_id = t.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end

					U.y_animation_wait(this)
					SU.show_modifiers(store, this, true)

					fa.ts = store.tick_ts

					U.animation_start(this, "breath", nil, store.tick_ts, -1)
					S:queue(fa.exhausted_sound, fa.exhausted_sound_args)

					if SU.y_enemy_wait(store, this, fa.exhausted_duration) then
						goto label_133_0
					end
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_freeze)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_133_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_freeze() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_133_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.jt_spawner_aura = {}

function scripts.jt_spawner_aura.update(this, store)
	local spawn_ts = {}

	for i = 1, #this.spawn_data do
		spawn_ts[i] = store.tick_ts
	end

	local owner = store.entities[this.aura.source_id]

	if not owner then
		log.error("owner %s was not found. baling out", this.aura.source_id)
	else
		while not owner.dying do
			for i, v in ipairs(this.spawn_data) do
				local template, cooldown, delay, pi, spi = unpack(v)

				if store.tick_ts - spawn_ts[i] >= cooldown + delay then
					local e = E:create_entity(template)

					e.nav_path.pi = pi
					e.nav_path.spi = spi
					e.nav_path.ni = P:get_start_node(pi)

					queue_insert(store, e)

					spawn_ts[i] = store.tick_ts - delay
				end
			end

			coroutine.yield()
		end
	end

	queue_remove(store, this)
end

scripts.mod_jt_tower = {}

function scripts.mod_jt_tower.update(this, store)
	local clicks = 0
	local s_tap = this.render.sprites[2]
	local target = store.entities[this.modifier.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	SU.tower_block_inc(target)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)

	s_tap.hidden = nil

	SU.ui_click_proxy_add(target, this)

	while clicks < this.required_clicks do
		if IS_CONSOLE then
			if target.ui.hover_controller_active then
				s_tap.alpha = s_tap.alpha_focused
				s_tap.name = s_tap.name_focused
			else
				s_tap.alpha = s_tap.alpha_unfocused
				s_tap.name = s_tap.name_unfocused
			end
		end

		if this.ui.clicked then
			S:queue(this.sound_events.click)
			SU.insert_sprite(store, this.ui.click_fx, target.pos)

			this.ui.clicked = nil
			clicks = clicks + 1
		end

		coroutine.yield()
	end

	SU.ui_click_proxy_remove(target, this)

	this.ui.can_click = false
	s_tap.hidden = true

	U.animation_start(this, "end", nil, store.tick_ts, false, 1)
	U.y_wait(store, this.end_delay)
	SU.tower_block_dec(target)
	U.y_animation_wait(this)

	if this.tween then
		this.tween.ts = store.tick_ts
		this.tween.props[1].disabled = nil

		U.y_wait(store, 2)
	end

	queue_remove(store, this)
end

scripts.eb_veznan = {}

function scripts.eb_veznan.get_info(this)
	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = this.melee.attacks[1].damage_min,
		damage_max = this.melee.attacks[1].damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_veznan.on_damage(this, store, damage)
	if this.phase == "battle" then
		local pd = U.predict_damage(this, damage)

		if pd >= this.health.hp then
			this.phase_signal = true

			return false
		end
	elseif this.phase == "demon" then
		local pd = U.predict_damage(this, damage)

		if pd >= this.health.hp then
			this.phase_signal = true

			return false
		end
	end

	return true
end

function scripts.eb_veznan.update(this, store)
	local ba = this.timed_attacks.list[1]
	local pa = this.timed_attacks.list[2]
	local taunt_ts
	local portals = LU.list_entities(store.entities, pa.portal_name)
	local initial_hp = this.health.hp_max

	local function y_taunt(idx, set)
		U.animation_start(this, "laugh", nil, store.tick_ts, true)
		SU.y_show_taunt_set(store, this.taunts, set or this.phase, idx, nil, nil, true)
		U.y_animation_wait(this)
		U.animation_start(this, "idleDown", nil, store.tick_ts, true)
	end

	local function y_block_towers()
		local towers = table.filter(store.towers, function(_, e)
			return e.tower.can_be_mod and not U.has_modifiers(store, e, ba.mod)
		end)

		if not towers or #towers == 0 then
			SU.delay_attack(store, ba, 0.5)

			return
		end

		local start_ts = store.tick_ts

		U.animation_start(this, ba.animation, nil, store.tick_ts)
		U.y_wait(store, ba.hit_time)
		S:queue(ba.sound)

		local random_towers = table.random_order(towers)

		for i, t in ipairs(random_towers) do
			if i > ba.count then
				break
			end

			local m = E:create_entity(ba.mod)

			m.modifier.target_id = t.id
			m.modifier.source_id = this.id

			queue_insert(store, m)
		end

		U.y_animation_wait(this)
		U.y_wait(store, ba.attack_duration - (store.tick_ts - start_ts))

		ba.ts = store.tick_ts

		if this.phase == "castle" then
			U.animation_start(this, "idleDown", nil, store.tick_ts, true)
		end
	end

	local function y_portal()
		local start_ts = store.tick_ts

		U.animation_start(this, pa.animation, nil, store.tick_ts)
		U.y_wait(store, pa.hit_time)
		S:queue(pa.sound)

		pa.count = pa.count + 1

		for _, p in pairs(portals) do
			if pa.portals[p.portal_idx] ~= 1 then
			-- block empty
			else
				p.spawn_signal = true
			end
		end

		U.y_animation_wait(this)
		U.y_wait(store, pa.attack_duration - (store.tick_ts - start_ts))

		pa.ts = store.tick_ts

		if this.phase == "castle" then
			U.animation_start(this, "idleDown", nil, store.tick_ts, true)
		end
	end

	local function signal_ready()
		return this.phase_signal
	end

	local function battle_started()
		return store.wave_group_number >= 1
	end

	local function ready_to_block()
		return not ba.disabled and enemy_ready_to_magic_attack(this, store, ba)
	end

	local function ready_to_portal()
		return not pa.disabled and enemy_ready_to_magic_attack(this, store, pa) and pa.count < pa.max_count
	end

	local function can_break_battle_walk()
		return ready_to_block() or ready_to_portal() or this.phase_signal
	end

	this.phase_signal = nil
	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	for i, d in ipairs(this.taunts.sets.welcome.delays) do
		if U.y_wait(store, d, battle_started) then
			break
		end

		y_taunt(i)
	end

	while not battle_started() do
		coroutine.yield()
	end

	y_taunt(5)

	this.phase = "castle"

	local last_lives = store.lives
	local last_wave
	local taunt_cooldown = math.random(this.taunts.delay_min, this.taunts.delay_max)

	ba.ts = store.tick_ts
	pa.ts = store.tick_ts
	taunt_ts = store.tick_ts
	this.phase_signal = nil

	while not this.phase_signal do
		if store.wave_group_number ~= last_wave and not this.phase_signal then
			local ba_wave_data = ba.data[store.wave_group_number]

			ba.disabled = not ba_wave_data

			if not ba.disabled then
				ba.cooldown = ba_wave_data and ba_wave_data[1] or 0
				ba.count = ba_wave_data and ba_wave_data[2] or 0
			end

			local pa_wave_data = pa.data[store.wave_group_number]

			pa.disabled = not pa_wave_data

			if not pa.disabled then
				pa.cooldown, pa.max_count, pa.portals = unpack(pa_wave_data)
				pa.count = 0
			end

			last_wave = store.wave_group_number
		end

		if taunt_cooldown <= store.tick_ts - taunt_ts and not this.phase_signal then
			y_taunt(nil, last_lives > store.lives and "damage" or nil)

			last_lives = store.lives
			taunt_ts = store.tick_ts
			taunt_cooldown = math.random(this.taunts.delay_min, this.taunts.delay_max)
		end

		if ready_to_block() and not this.phase_signal then
			y_block_towers()
		end

		if ready_to_portal() and not this.phase_signal then
			y_portal()
		end

		coroutine.yield()
	end

	this.phase = "pre_battle"

	local battle_ts = store.tick_ts

	pa.cooldown = this.battle.pa_cooldown
	pa.max_count = this.battle.pa_max_count
	pa.animation = this.battle.pa_animation
	ba.animation = this.battle.ba_animation

	U.y_wait(store, fts(24))
	y_taunt()
	U.y_wait(store, battle_ts + fts(115) - store.tick_ts)
	U.y_animation_play(this, "walkAway", nil, store.tick_ts)

	this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = 1, 1, 1
	this.pos = P:node_pos(this.nav_path)
	pa.ts = store.tick_ts
	ba.ts = store.tick_ts
	this.vis.bans = U.flag_clear(this.vis.bans, F_ALL)
	this.health.ignore_damage = false
	this.health_bar.hidden = nil
	this.phase_signal = nil
	this.phase = "battle"

	while not this.phase_signal do
		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_block() and not this.phase_signal then
				y_block_towers()
			end

			if ready_to_portal() and not this.phase_signal then
				y_portal()
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, can_break_battle_walk, can_break_battle_walk) then
			-- block empty
			else
				coroutine.yield()
			end
		end
	end

	this.health_bar.hidden = true
	this.vis.bans = U.flag_set(this.vis.bans, F_ALL)

	SU.remove_modifiers(store, this)
	S:queue(this.demon.transform_sound)
	U.y_animation_play(this, "demonTransform", nil, store.tick_ts, 1)

	this.enemy.melee_slot = this.demon.melee_slot
	this.health.hp = initial_hp * 1.5
	this.health.hp_max = initial_hp * 1.5
	this.health_bar.offset = this.demon.health_bar_offset
	this.health_bar.frames[1].bar_width = this.health_bar.frames[1].bar_width * this.demon.health_bar_scale
	this.health_bar.frames[2].bar_width = this.health_bar.frames[2].bar_width * this.demon.health_bar_scale
	this.health_bar.frames[1].scale.x = this.health_bar.frames[1].scale.x * this.demon.health_bar_scale
	this.health_bar.frames[2].scale.x = this.health_bar.frames[2].scale.x * this.demon.health_bar_scale
	this.melee.attacks[1].disabled = true
	this.melee.attacks[2].disabled = false
	U.update_max_speed(this, this.demon.speed)
	this.render.sprites[1].prefix = this.demon.sprites_prefix
	this.ui.click_rect = this.demon.ui_click_rect
	this.unit.hit_offset = this.demon.unit_hit_offset
	this.unit.mod_offset = this.demon.unit_mod_offset
	this.unit.size = this.demon.unit_size
	this.info.portrait = this.demon.info_portrait
	this.health_bar.hidden = nil
	this.vis.bans = U.flag_clear(this.vis.bans, F_ALL)
	this.phase_signal = nil
	this.phase = "demon"

	while not this.phase_signal do
		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		elseif not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, signal_ready, signal_ready) then
		-- block empty
		else
			coroutine.yield()
		end
	end

	this.phase = "death"
	this.health_bar.hidden = true
	this.health.ignore_damage = true
	this.ui.can_click = false
	this.vis.bans = U.flag_set(this.vis.bans, F_ALL)

	SU.remove_modifiers(store, this)
	LU.kill_all_enemies(store, true)
	S:stop_all()
	S:queue(this.sound_events.death)
	signal.emit("boss-killed", this)
	U.animation_start(this, "death", nil, store.tick_ts, 1)
	signal.emit("hide-gui")
	U.y_wait(store, fts(110))
	LU.kill_all_enemies(store, true)

	local sc = E:create_entity(this.souls_aura)

	sc.pos = V.vclone(this.pos)
	sc.pos.y = sc.pos.y + 14

	queue_insert(store, sc)
	U.y_animation_wait(this)
	U.animation_start(this, "deathLoop", nil, store.tick_ts, true)
	U.y_wait(store, fts(90))

	sc.interrupt = true

	LU.kill_all_enemies(store, true)
	U.animation_start(this, "deathEnd", nil, store.tick_ts, true)

	local circle = E:create_entity(this.white_circle)

	circle.pos.x, circle.pos.y = this.pos.x + 6, this.pos.y + 12
	circle.tween.ts = store.tick_ts
	circle.render.sprites[1].ts = store.tick_ts

	queue_insert(store, circle)
	U.y_wait(store, fts(65) + 2)

	this.phase = "death-end"

	queue_remove(store, this)
end

scripts.veznan_portal = {}

function scripts.veznan_portal.update(this, store)
	local spawns = this.spawn_groups[this.portal_idx]
	local ni = this.out_nodes[this.pi]

	while true do
		while not this.spawn_signal do
			coroutine.yield()
		end

		U.y_animation_play(this, "start", nil, store.tick_ts)

		local roll = math.random()
		local entity_data

		for _, s in pairs(spawns) do
			if roll <= s[1] then
				entity_data = s[2]

				break
			end
		end

		U.animation_start(this, "active", nil, store.tick_ts, true)

		for _, d in pairs(entity_data) do
			local min, max, template = unpack(d)
			local count = min ~= max and math.random(min, max) or min

			for i = 1, count do
				local e = E:create_entity(template)

				e.nav_path.pi = this.pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = ni
				e.pos = V.vclone(this.pos)

				queue_insert(store, e)
				U.y_wait(store, this.spawn_interval)
			end
		end

		U.y_animation_wait(this)
		U.y_animation_play(this, "end", nil, store.tick_ts)

		this.spawn_signal = nil

		coroutine.yield()
	end
end

scripts.mod_veznan_tower = {}

function scripts.mod_veznan_tower.update(this, store)
	local clicks = 0
	local s_tap = this.render.sprites[2]
	local target = store.entities[this.modifier.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	U.y_animation_play(this, "start", nil, store.tick_ts, 1, 1)

	s_tap.hidden = nil

	U.animation_start(this, "preHold", nil, store.tick_ts, true, 1)
	SU.tower_block_inc(target)

	local hold_ts = store.tick_ts

	SU.ui_click_proxy_add(target, this)

	while clicks < this.required_clicks and store.tick_ts - hold_ts < this.click_time do
		if IS_CONSOLE then
			if target.ui.hover_controller_active then
				s_tap.alpha = s_tap.alpha_focused
				s_tap.name = s_tap.name_focused
			else
				s_tap.alpha = s_tap.alpha_unfocused
				s_tap.name = s_tap.name_unfocused
			end
		end

		if this.ui.clicked then
			S:queue(this.sound_click)

			this.ui.clicked = nil
			clicks = clicks + 1

			if clicks >= this.required_clicks then
				goto label_151_0
			end
		end

		coroutine.yield()
	end

	s_tap.hidden = true

	S:queue(this.sound_blocked)
	U.animation_start(this, "hold", nil, store.tick_ts, 1, 1)
	U.y_wait(store, this.duration)

	::label_151_0::

	SU.ui_click_proxy_remove(target, this)

	s_tap.hidden = true

	S:queue(this.sound_released)
	U.y_animation_play(this, "remove", nil, store.tick_ts, 1, 1)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.veznan_souls_aura = {}

function scripts.veznan_souls_aura.update(this, store)
	local count = 0

	for i = 1, this.souls.count do
		if this.interrupt then
			break
		end

		local e = E:create_entity(this.souls.entity)

		e.angle = U.frandom(this.souls.angles[1], this.souls.angles[2])
		e.pos = V.vclone(this.pos)
		e.soul_phase = 1 - i / this.souls.count

		queue_insert(store, e)

		if this.souls.delay_frames >= 2 then
			this.souls.delay_frames = this.souls.delay_frames - 1
		end

		U.y_wait(store, fts(this.souls.delay_frames))
	end

	queue_remove(store, this)
end

scripts.veznan_soul = {}

function scripts.veznan_soul.update(this, store)
	local speed = math.random(this.speed[1], this.speed[2])
	local inc = math.random() > 0.5 and this.angle_variation or -this.angle_variation
	local angle_var = 0
	local start_ts = store.tick_ts
	local last_ts = store.tick_ts
	local ps = E:create_entity(this.particles_name)

	ps.particle_system.track_id = this.id

	local pl = ps.particle_system.particle_lifetime

	pl[1], pl[2] = pl[1] * this.soul_phase, pl[2] * this.soul_phase

	queue_insert(store, ps)

	while store.tick_ts - start_ts < this.duration do
		local dt = store.tick_ts - last_ts
		local a = this.angle + angle_var
		local x_step, y_step = V.rotate(a, speed * dt, 0)

		this.render.sprites[1].r = a
		this.pos.x = this.pos.x + x_step
		this.pos.y = this.pos.y + y_step
		angle_var = angle_var + inc

		if angle_var >= this.max_angle then
			inc = -this.angle_variation
		elseif angle_var <= this.min_angle then
			inc = this.angle_variation
		end

		last_ts = store.tick_ts

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.eb_greenmuck = {}

function scripts.eb_greenmuck.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_greenmuck.update(this, store)
	local ba = this.timed_attacks.list[1]

	local function ready_to_shoot()
		return enemy_ready_to_magic_attack(this, store, ba)
	end

	ba.ts = store.tick_ts

	::label_155_0::

	while true do
		if this.health.dead then
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			local spawner = LU.list_entities(store.entities, "s15_rotten_spawner")[1]

			if spawner then
				spawner.interrupt = true
			end

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_shoot() then
				local targets = table.filter(store.soldiers, function(_, e)
					return not e.pending_removal and not e.health.dead and band(e.vis.flags, ba.vis_bans) == 0 and band(e.vis.bans, ba.vis_flags) == 0
				end)

				if #targets < 1 then
					SU.delay_attack(store, ba, 0.5)
				else
					U.animation_start(this, ba.animation, nil, store.tick_ts, false)
					U.y_wait(store, ba.shoot_time)

					local af = this.render.sprites[1].flip_x
					local o = ba.bullet_start_offset
					local random_targets = table.random_order(targets)

					for i, t in ipairs(random_targets) do
						if i > ba.count then
							break
						end

						local b = E:create_entity(ba.bullet)

						b.bullet.source_id = this.id
						b.bullet.target_id = t
						b.bullet.from = v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.to = V.vclone(t.pos)
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)
					end

					U.y_animation_wait(this)

					ba.ts = store.tick_ts
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_shoot)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_155_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_shoot() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_155_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_kingpin = {}

function scripts.eb_kingpin.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_kingpin.update(this, store)
	local hs = this.timed_attacks.list[1]
	local ho = this.timed_attacks.list[2]
	local stop_ts

	local function ready_to_stop()
		return store.tick_ts - stop_ts > this.stop_cooldown
	end

	stop_ts = store.tick_ts

	::label_159_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_stop() then
				local stop_start = store.tick_ts
				local a = table.random(this.timed_attacks.list)

				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, this.stop_wait) then
					goto label_159_0
				end

				local targets

				if a == hs and this.health.hp < this.health.hp_max then
					targets = {this}
				elseif a == ho then
					targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
						return e.health.hp < e.health.hp_max and e ~= this
					end)
				end

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = target.id

						queue_insert(store, m)
					end
				end

				if SU.y_enemy_animation_wait(this) then
					goto label_159_0
				end

				U.animation_start(this, a.animation, nil, store.tick_ts, false)

				if SU.y_enemy_animation_wait(this) then
					goto label_159_0
				end

				if SU.y_enemy_wait(store, this, this.stop_time - (store.tick_ts - stop_start)) then
					goto label_159_0
				end

				stop_ts = store.tick_ts
			end

			SU.y_enemy_walk_until_blocked(store, this, false, ready_to_stop)
		end
	end
end

scripts.eb_ulgukhai = {}

function scripts.eb_ulgukhai.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_ulgukhai.update(this, store)
	::label_163_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			this.health.ignore_damage = true
			this.unit.blood_color = BLOOD_NONE
			this.vis.bans = U.flag_set(this.vis.bans, this.shielded_extra_vis_bans)

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false)

			if not cont then
			-- block empty
			else
				if blocker then
					this.health.ignore_damage = nil
					this.unit.blood_color = BLOOD_RED
					this.vis.bans = U.flag_clear(this.vis.bans, this.shielded_extra_vis_bans)

					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_163_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_163_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_moloch = {}

-- function scripts.eb_moloch.get_info(this)
-- 	local ma = this.melee.attacks[1]
-- 	local min, max = ma.damage_min, ma.damage_max
-- 	return {
-- 		type = STATS_TYPE_ENEMY,
-- 		hp = this.health.hp,
-- 		hp_max = this.health.hp_max,
-- 		damage_min = min,
-- 		damage_max = max,
-- 		armor = this.health.armor,
-- 		magic_armor = this.health.magic_armor,
-- 		lives = this.enemy.lives_cost
-- 	}
-- end
function scripts.eb_moloch.update(this, store)
	local ha = this.timed_attacks.list[1]

	local function ready_to_horn()
		return enemy_ready_to_magic_attack(this, store, ha)
	end

	U.animation_start(this, "sitting", nil, store.tick_ts, true)

	this.phase = "sitting"
	this.phase_signal = nil
	this.health_bar.hidden = true

	while not this.phase_signal do
		coroutine.yield()
	end

	U.y_wait(store, this.stand_up_wait_time)
	S:queue(this.stand_up_sound)
	U.y_animation_play(this, "raise", nil, store.tick_ts)

	this.health_bar.hidden = nil
	this.health.ignore_damage = nil
	this.vis.bans = this.active_vis_bans
	ha.ts = store.tick_ts

	::label_165_0::

	while true do
		if this.health.dead then
			-- store.force_next_wave = true
			this.phase = "dead"

			-- LU.kill_all_enemies(store, true)
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			-- LU.kill_all_enemies(store, true)
			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_horn() then
				local dest = V.vclone(this.pos)
				local af = this.render.sprites[1].flip_x and -1 or 1

				if ha.hit_offset then
					dest.x = dest.x + af * ha.hit_offset.x
					dest.y = dest.y + ha.hit_offset.y
				end

				local targets = U.find_soldiers_in_range(store.soldiers, dest, 0, ha.damage_radius, ha.vis_flags or 0, ha.vis_bans or 0)

				if not targets or #targets < ha.min_targets then
					SU.delay_attack(store, ha, 0.5)
				else
					SU.hide_modifiers(store, this, true)
					S:queue(ha.sound, ha.sound_args)
					U.animation_start(this, ha.animation, nil, store.tick_ts, false)

					if SU.y_enemy_wait(store, this, ha.hit_time) then
						goto label_165_0
					end

					targets = U.find_soldiers_in_range(store.soldiers, dest, 0, ha.damage_radius, ha.vis_flags or 0, ha.vis_bans or 0)

					if targets then
						for _, t in pairs(targets) do
							local d = SU.create_attack_damage(ha, t.id, this)

							queue_damage(store, d)
						end
					end

					for _, f in pairs(ha.fx_list) do
						local fx_name, positions = unpack(f)

						for _, p in pairs(positions) do
							local xo, yo = unpack(p)
							local fx = E:create_entity(fx_name)

							fx.render.sprites[1].ts = store.tick_ts
							fx.pos.x = this.pos.x + xo * af
							fx.pos.y = this.pos.y + yo

							queue_insert(store, fx)
						end
					end

					U.y_wait(store, fts(12))
					SU.show_modifiers(store, this, true)
					U.y_animation_wait(this)

					ha.ts = store.tick_ts
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_horn)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_165_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_horn() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_165_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_myconid = {}

-- function scripts.eb_myconid.get_info(this)
-- 	local ma = this.melee.attacks[1]
-- 	local min, max = ma.damage_min, ma.damage_max
-- 	return {
-- 		type = STATS_TYPE_ENEMY,
-- 		hp = this.health.hp,
-- 		hp_max = this.health.hp_max,
-- 		damage_min = min,
-- 		damage_max = max,
-- 		armor = this.health.armor,
-- 		magic_armor = this.health.magic_armor,
-- 		lives = this.enemy.lives_cost
-- 	}
-- end
function scripts.eb_myconid.update(this, store)
	local sa = this.timed_attacks.list[1]
	local si = 1

	local function ready_to_spore()
		return enemy_ready_to_magic_attack(this, store, sa) and this.nav_path.ni > sa.min_nodes
	end

	local function spawn_mushrooms(count, owner)
		local sp = E:create_entity(this.spawner_entity)

		sp.spawner.pi = this.nav_path.pi
		sp.spawner.spi = this.nav_path.spi
		sp.spawner.ni = this.nav_path.ni
		sp.spawner.random_cycle = {0, 1 / count}
		sp.spawner.count = count
		sp.spawner.owner_id = owner

		queue_insert(store, sp)
	end

	sa.ts = store.tick_ts

	::label_168_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			U.animation_start(this, "death", nil, store.tick_ts, false)
			U.y_wait(store, this.on_death_spawn_wait)
			spawn_mushrooms(this.on_death_spawn_count, nil)
			signal.emit("boss-killed", this)
			SU.fade_out_entity(store, this, this.unit.fade_time_after_death)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_spore() then
				local fx_wait, mod_wait, spawner_wait = unpack(sa.wait_times)

				S:queue(sa.sound)
				U.animation_start(this, "spores", nil, store.tick_ts, false)

				if SU.y_enemy_wait(store, this, fx_wait) then
					goto label_168_0
				end

				local fx = E:create_entity(sa.fx)

				fx.render.sprites[1].ts = store.tick_ts
				fx.pos = V.vclone(this.pos)

				if sa.fx_offset then
					fx.pos.x = fx.pos.x + sa.fx_offset.x
					fx.pos.y = fx.pos.y + sa.fx_offset.y
				end

				queue_insert(store, fx)

				if SU.y_enemy_wait(store, this, mod_wait) then
					goto label_168_0
				end

				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, sa.radius, sa.vis_flags, sa.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local m = E:create_entity(sa.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						queue_insert(store, m)
					end
				end

				if SU.y_enemy_wait(store, this, spawner_wait) then
					goto label_168_0
				end

				spawn_mushrooms(sa.summon_counts[si] or sa.summon_counts[#sa.summon_counts], this.id)

				si = si + 1

				if SU.y_enemy_wait(store, this, sa.final_wait) then
					if sp then
						sp.spawner.interrupt = true
					end

					goto label_168_0
				end

				sa.ts = store.tick_ts
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_spore)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_168_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_spore() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_168_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_blackburn = {}

function scripts.eb_blackburn.get_info(this)
	local ma = this.melee.attacks[1]
	local min, max = ma.damage_min, ma.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_blackburn.update(this, store)
	local sa = this.timed_attacks.list[1]

	local function ready_to_smash()
		return enemy_ready_to_magic_attack(this, store, sa)
	end

	sa.ts = store.tick_ts

	::label_172_0::

	while true do
		if this.health.dead then
			if store.level_idx == 26 then
				LU.kill_all_enemies(store, true)
			end

			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			this.ui.can_click = false

			local megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]

			if megaspawner then
				megaspawner.interrupt = true
			end

			if store.level_idx == 26 then
				store.force_next_wave = true
			end

			U.animation_start(this, "death_end", nil, store.tick_ts, true)
			signal.emit("boss-killed", this)

			if store.level_idx == 26 then
				LU.kill_all_enemies(store, true)
			end

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_smash() then
				U.animation_start(this, sa.animation, nil, store.tick_ts, false)
				S:queue(sa.sound, sa.sound_args)

				if SU.y_enemy_wait(store, this, sa.hit_time) then
					goto label_172_0
				end

				local a = E:create_entity(sa.aura_shake)

				queue_insert(store, a)

				local af = this.render.sprites[1].flip_x
				local fx = E:create_entity(sa.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.pos.x = fx.pos.x + (af and -1 or 1) * sa.fx_offset.x
				fx.pos.y = fx.pos.y + (af and -1 or 1) * sa.fx_offset.y

				queue_insert(store, fx)
				SU.insert_sprite(store, sa.hit_decal, fx.pos, af, fts(2))

				local towers = U.find_towers_in_range(store.towers, this.pos, sa, function(t)
					return t.tower.can_be_mod
				end)

				if towers then
					for _, tt in pairs(towers) do
						local tm = E:create_entity(sa.mod_towers)

						tm.modifier.source_id = this.id
						tm.modifier.target_id = tt.id

						queue_insert(store, tm)
					end
				end

				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, sa.damage_radius, sa.vis_flags or 0, sa.vis_bans or 0)

				if targets then
					for _, t in pairs(targets) do
						local d = E:create_entity("damage")

						d.damage_type = sa.damage_type
						d.value = math.random(sa.damage_min, sa.damage_max)
						d.source_id = this.id
						d.target_id = t.id

						queue_damage(store, d)

						local tm = E:create_entity(sa.mod)

						tm.modifier.source_id = this.id
						tm.modifier.target_id = t.id

						queue_insert(store, tm)
					end
				end

				U.y_animation_wait(this)

				if SU.y_enemy_wait(store, this, sa.after_hit_wait) then
					goto label_172_0
				end

				sa.cooldown = sa.after_cooldown
				sa.ts = store.tick_ts
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_smash)

			if not cont then
			-- block empty
			else
				if blocker and blocker.unit and not blocker.unit.is_stunned then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_172_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_smash() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_172_0
						end

						coroutine.yield()
					end
				else
					U.unblock_target(store, blocker)
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_blackburn_tower = {}

function scripts.mod_blackburn_tower.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts

	SU.tower_block_inc(target)

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	if this.tween then
		this.tween.disabled = false
		this.tween.reverse = false
		this.tween.ts = store.tick_ts
	end

	U.y_wait(store, m.duration)

	if this.tween then
		this.tween.ts = store.tick_ts
		this.tween.reverse = true
	end

	SU.tower_block_dec(target)
	U.y_wait(store, this.tween.props[1].keys[2][1])
	queue_remove(store, this)
end

scripts.blackburn_aura = {}

function scripts.blackburn_aura.update(this, store)
	local last_ts = store.tick_ts
	local cg = store.count_groups[this.count_group_type]

	while true do
		local source = store.entities[this.aura.source_id]

		if not source or source.health.dead then
			queue_remove(store, this)

			return
		end

		this.pos = source.pos

		if store.tick_ts - last_ts >= this.aura.cycle_time then
			last_ts = store.tick_ts

			for _, e in pairs(store.soldiers) do
				if e and not e.health.dead and e.soldier.tower_id == source.id then
					tower_skeletons_count = tower_skeletons_count + 1
				end
			end

			local max_spawns = this.count_group_max - (cg[this.count_group_name] or 0)

			if max_spawns < 1 then
			-- block empty
			else
				local dead_soldiers = table.filter(store.soldiers, function(k, v)
					return v.soldier and v.health and v.health.dead and band(v.vis.bans or 0, F_SKELETON) == 0 and store.tick_ts - v.health.death_ts >= this.aura.cycle_time and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
				end)

				dead_soldiers = table.slice(dead_soldiers, 1, max_spawns)

				local spii = math.random(1, 3)

				for _, dead in pairs(dead_soldiers) do
					local nearest_nodes = P:nearest_nodes(dead.pos.x, dead.pos.y, {source.nav_path.pi})

					if #nearest_nodes < 1 then
					-- block empty
					else
						local pi, spi, ni = unpack(nearest_nodes[1])

						if not P:is_node_valid(pi, ni) then
						-- block empty
						else
							U.sprites_hide(dead)

							dead.vis.bans = bor(dead.vis.bans, F_SKELETON)

							local e = E:create_entity(this.aura.raise_entity)

							spii = km.zmod(spii + 1, 3)
							e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, spii, ni
							e.enemy.gold = 0
							e.pos = V.vclone(dead.pos)
							e.render.sprites[1].name = "raise"

							E:add_comps(e, "count_group")

							e.count_group.name = this.count_group_name
							e.count_group.type = this.count_group_type

							queue_insert(store, e)
						end
					end
				end
			end
		end

		coroutine.yield()
	end
end

scripts.eb_efreeti = {}

function scripts.eb_efreeti.get_info(this)
	return {
		damage_min = 500,
		damage_max = 800,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_efreeti.insert(this, store)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)

	if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

	return true
end

function scripts.eb_efreeti.update(this, store)
	local a_poly = this.attacks.list[1]
	local a_des = this.attacks.list[2]
	local a_sand = this.attacks.list[3]
	local a_spawn = this.attacks.list[4]
	local powers_ts = store.tick_ts
	local blocker

	local function do_death()
		local death_start_ts = store.tick_ts

		S:queue(this.sound_events.death)
		U.animation_start(this, "death", nil, store.tick_ts, false, 2)

		local image_x, image_y = 206, 198
		local anchor_x, anchor_y = 0.5, 0.1
		local fx_offsets_and_delays = {{v(127, 74), 1.1}, {v(78, 93), 1.2}, {v(108, 133), 1.3}, {v(96, 47), 1.4}, {v(76, 106), 1.5}, {v(129, 101), 1.6}, {v(136, 82), 1.7}, {v(101, 140), 1.8}, {v(79, 64), 1.9}}

		for _, p in pairs(fx_offsets_and_delays) do
			local pos, delay = unpack(p)
			local fx = E:create_entity("fx")

			fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
			fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
			fx.render.sprites[1].name = "efreeti_explosion"
			fx.render.sprites[1].ts = store.tick_ts + delay

			queue_insert(store, fx)
		end

		while store.tick_ts - death_start_ts < 1.9 do
			coroutine.yield()
		end

		this.render.sprites[1].hidden = true

		while store.tick_ts - death_start_ts < 2.2 do
			coroutine.yield()
		end

		local lamp = E:create_entity("decal")

		lamp.render.sprites[1].loop = false
		lamp.render.sprites[1].anchor.y = 0.09
		lamp.render.sprites[1].name = "efreeti_lamp_fall"
		lamp.render.sprites[1].ts = store.tick_ts
		lamp.render.sprites[1].z = Z_EFFECTS
		lamp.pos.x, lamp.pos.y = this.pos.x, this.pos.y

		queue_insert(store, lamp)

		while not U.animation_finished(this, 2) do
			coroutine.yield()
		end
	end

	local function spawn_efreeti_small(pos, subpath)
		local nodes = P:nearest_nodes(pos.x, pos.y)

		if #nodes > 0 then
			local pi, spi, ni = unpack(nodes[1])

			if subpath then
				spi = subpath
			end

			local e = E:create_entity("enemy_efreeti_small")

			e.nav_path.pi, e.nav_path.spi, e.nav_path.ni = pi, spi, ni

			queue_insert(store, e)

			local fx = E:create_entity("fx")

			fx.pos.x, fx.pos.y = pos.x, pos.y
			fx.render.sprites[1].name = "enemy_efreeti_small_raise"
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].anchor.y = e.render.sprites[1].anchor.y
			fx.render.sprites[1].z = Z_OBJECTS
			fx.render.sprites[1].draw_order = 2

			queue_insert(store, fx)
		else
			log.debug("no nodes nearby %s,%s to spanw enemy_efreeti_small", pos.x, pos.y)
		end
	end

	local function can_polymorph()
		for _, e in pairs(store.soldiers) do
			if not e.health.dead and band(e.vis.bans, F_POLYMORPH) == 0 and U.is_inside_ellipse(e.pos, this.pos, a_poly.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a_poly.min_range) then
				return true
			end
		end

		return false
	end

	local function do_polymorph()
		local targets = table.filter(store.soldiers, function(_, e)
			return not e.health.dead and band(e.vis.bans, F_POLYMORPH) == 0 and U.is_inside_ellipse(e.pos, this.pos, a_poly.max_range) and not U.is_inside_ellipse(e.pos, this.pos, a_poly.min_range)
		end)

		for i = 1, math.min(#targets, a_poly.max_count) do
			local target = targets[i]
			local d = E:create_entity("damage")

			d.damage_type = DAMAGE_EAT
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
			spawn_efreeti_small(target.pos)
		end
	end

	local function do_desintegrate()
		local targets = table.filter(store.soldiers, function(_, e)
			return not e.health.dead and U.is_inside_ellipse(e.pos, this.pos, a_des.max_range)
		end)

		for i = 1, math.min(#targets, a_des.max_count) do
			local target = targets[i]
			local d = E:create_entity("damage")

			d.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL)
			d.source_id = this.id
			d.target_id = target.id

			queue_damage(store, d)
		end
	end

	local function can_sand()
		for _, e in pairs(store.towers) do
			if not e.tower_holder and not e.tower.blocked and V.dist2(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a_sand.max_range * a_sand.max_range then
				return true
			end
		end

		return false
	end

	local function do_sand()
		local towers = table.filter(store.towers, function(_, e)
			return not e.tower_holder and not e.tower.blocked and V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a_sand.max_range
		end)

		for i = 1, math.min(#towers, a_sand.max_count) do
			local t = towers[i]
			local m = E:create_entity(a_sand.mod)

			m.modifier.target_id = t.id
			m.modifier.source_id = this.id
			m.pos = t.pos

			queue_insert(store, m)
		end
	end

	local function do_spawn(spawn_cycle)
		local places = this.health.hp < a_spawn.health_threshold and math.random(3, 4) or 2

		for i = 1, places do
			spawn_efreeti_small(a_spawn.coords[i], km.zmod(spawn_cycle, 3))
		end
	end

	this.phase = "spawn"
	this.health_bar.hidden = true

	local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

	U.animation_start(this, an, af, store.tick_ts)

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[3].ts = store.tick_ts

	U.y_wait(store, 1.5)
	S:queue(this.sound_events.laugh)

	this.tween.disabled = true

	U.y_animation_play(this, "laugh", nil, store.tick_ts, 6)

	this.health_bar.hidden = false
	this.vis.bans = this.vis.bans_in_battlefield
	this.phase = "loop"

	::label_235_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			do_death()
			queue_remove(store, this)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()

			powers_ts = store.tick_ts
		else
			if store.tick_ts - powers_ts > this.attacks.cooldown then
				if math.random() < a_sand.chance then
					if can_sand() then
						S:queue(this.sound_events.sand)
						U.animation_start(this, a_sand.animation, nil, store.tick_ts)
						U.y_wait(store, a_sand.shoot_time)

						if this.unit.is_stunned then
							goto label_235_0
						end

						do_sand()
						U.y_animation_wait(this, 2)
						S:queue(this.sound_events.laugh)
						U.y_animation_play(this, "laugh", nil, store.tick_ts, 6)

						goto label_235_1
					end
				elseif math.random() < a_poly.chance and can_polymorph() then
					S:queue(this.sound_events.polymorph, {
						delay = fts(15)
					})
					U.animation_start(this, a_poly.animation, nil, store.tick_ts, 1)
					U.y_wait(store, a_poly.hit_time)

					if this.unit.is_stunned then
						goto label_235_0
					end

					do_polymorph()
					U.y_animation_wait(this, 2)

					goto label_235_1
				end

				S:queue(this.sound_events.spawn, {
					delay = fts(15)
				})
				U.animation_start(this, a_spawn.animation, nil, store.tick_ts, 1)

				for i = 1, a_spawn.max_count do
					U.y_wait(store, a_spawn.spawn_time)

					if this.unit.is_stunned then
						goto label_235_0
					end

					do_spawn(i)
				end

				U.y_animation_wait(this, 2)

				::label_235_1::

				powers_ts = store.tick_ts
			end

			blocker = U.get_blocker(store, this)

			if blocker and SU.y_wait_for_blocker(store, this, blocker) then
				S:queue(this.sound_events.desintegrate, {
					delay = fts(15)
				})
				U.animation_start(this, "attack", nil, store.tick_ts, 1)
				U.y_wait(store, a_des.hit_time)

				if this.unit.is_stunned then
					goto label_235_0
				end

				do_desintegrate()
				U.y_animation_wait(this, 2)
			end

			if not U.get_blocker(store, this) then
				if not SU.y_enemy_walk_step(store, this) then
					return
				end
			else
				coroutine.yield()
			end
		end
	end
end

scripts.eb_gorilla = {}

function scripts.eb_gorilla.get_info(this)
	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = this.melee.attacks[1].damage_min,
		damage_max = this.melee.attacks[1].damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_gorilla.insert(this, store)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	return true
end

function scripts.eb_gorilla.update(this, store)
	local a_spawn = this.attacks.list[1]
	local a_heal = this.attacks.list[2]
	local a_ranged = this.attacks.list[3]
	local on_tower = false
	local on_tower_ts, blocker

	local function y_jump(from, to, flight_time)
		local from = V.vclone(from)
		local g = -0.9 / (fts(1) * fts(1))

		if not flight_time then
			local dist = V.dist(to.x, to.y, from.x, from.y)

			flight_time = fts(23 + math.floor(dist * 1 / 60))
		end

		local speed = SU.initial_parabola_speed(from, to, flight_time, g)
		local ts = store.tick_ts
		local warped_time = (store.tick_ts - ts) * 2

		while warped_time <= flight_time do
			this.pos.x, this.pos.y = SU.position_in_parabola(warped_time, from, speed, g)

			coroutine.yield()

			warped_time = (store.tick_ts - ts) * 2
		end

		this.pos.x, this.pos.y = to.x, to.y

		coroutine.yield()
	end

	local enter_from = V.vclone(this.pos)
	local enter_to = P:node_pos(this.nav_path)

	U.animation_start(this, "fly", nil, store.tick_ts, true)

	this.render.sprites[1].z = Z_OBJECTS_SKY

	y_jump(enter_from, enter_to, 1)

	this.render.sprites[1].z = Z_OBJECTS

	S:queue(this.sound_events.drop_from_sky)
	U.y_animation_play(this, "jump_down_end", nil, store.tick_ts)
	S:queue(a_spawn.sound)
	U.y_animation_play(this, "call", nil, store.tick_ts)

	a_spawn.ts = store.tick_ts
	a_heal.ts = store.tick_ts
	a_ranged.ts = store.tick_ts
	on_tower_ts = store.tick_ts

	::label_249_0::

	while true do
		if this.health.dead then
			S:queue(this.sound_events.death)
			LU.kill_all_enemies(store, true)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()
		else
			if on_tower then
				if store.tick_ts - on_tower_ts > this.on_tower_time then
					local left_side = this.nav_path.pi == 1

					if not left_side then
						this.nav_path.ni = this.nav_path.ni + this.jump_down_advance_nodes
					end

					this.vis.bans = bor(this.vis.bans, F_FREEZE)

					U.y_animation_play(this, "jump_down_start", nil, store.tick_ts)
					U.animation_start(this, "fly", left_side, store.tick_ts, true)

					this.render.sprites[1].z = Z_OBJECTS_SKY

					y_jump(this.pos, P:node_pos(this.nav_path))

					this.render.sprites[1].z = Z_OBJECTS
					this.render.sprites[1].sort_y_offset = nil

					S:queue(this.sound_events.drop_from_sky)
					U.y_animation_play(this, "jump_down_end", nil, store.tick_ts)

					on_tower = false
					this.vis.bans = band(this.vis.bans, bnot(F_BLOCK))
					this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))
					a_spawn.ts = store.tick_ts

					goto label_249_0
				end

				if store.tick_ts - this.idle_flip.ts > this.idle_flip.cooldown then
					this.idle_flip.ts = store.tick_ts
					this.vis.bans = bor(this.vis.bans, F_FREEZE)

					U.y_animation_play(this, "tower_flip_start", nil, store.tick_ts)

					local left_side = this.nav_path.pi == 1

					if left_side then
						this.pos.x, this.pos.y = this.tower_pos_right.x, this.tower_pos_right.y
						this.nav_path.pi = 2
					else
						this.pos.x, this.pos.y = this.tower_pos_left.x, this.tower_pos_left.y
						this.nav_path.pi = 1
					end

					this.render.sprites[1].flip_x = left_side

					U.y_animation_play(this, "tower_flip_end", nil, store.tick_ts)

					this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))
				end

				if store.tick_ts - a_ranged.ts > a_ranged.cooldown then
					local left_side = this.nav_path.pi == 1
					local target = U.find_random_target(store.entities, this.pos, a_ranged.min_range, a_ranged.max_range, a_ranged.vis_flags, a_ranged.vis_bans, function(e)
						return e and e.pos and (left_side and e.pos.x < this.pos.x or not left_side and e.pos.x > this.pos.x)
					end)

					if target then
						a_ranged.ts = store.tick_ts

						U.animation_start(this, "throw_barrel", nil, store.tick_ts)
						U.y_wait(store, a_ranged.shoot_time)

						if this.unit.is_stunned then
							goto label_249_0
						end

						local bullet = E:create_entity(a_ranged.bullet)
						local offset = a_ranged.bullet_start_offset[1]

						bullet.pos.x, bullet.pos.y = this.pos.x + (left_side and -1 or 1) * offset.x, this.pos.y + offset.y
						bullet.bullet.from = V.vclone(bullet.pos)
						bullet.bullet.to = v(target.pos.x, target.pos.y)
						bullet.bullet.target_id = target.id
						bullet.bullet.rotation_speed = bullet.bullet.rotation_speed * (left_side and 1 or -1)

						queue_insert(store, bullet)
						U.y_animation_wait(this)
					end
				end
			else
				if store.tick_ts - a_spawn.ts > a_spawn.cooldown then
					a_spawn.ts = store.tick_ts

					S:queue(a_spawn.sound)
					U.y_animation_play(this, "call", nil, store.tick_ts)

					if this.unit.is_stunned then
						goto label_249_0
					end

					for i = 1, a_spawn.max_count do
						local pi = math.random() < 0.5 and 1 or 2
						local area = math.random() < 0.7 and 1 or 2
						local right_side = pi == 2
						local node_min, node_max = unpack(a_spawn.spawn_node_ranges[pi][area])
						local ni = math.random(node_min, node_max)
						local spi = math.random(1, 3)
						local dest = P:node_pos(pi, spi, ni)
						local e = E:create_entity(a_spawn.entity)

						e.pos = right_side and v(store.visible_coords.right, dest.y) or v(store.visible_coords.left, dest.y)
						e.render.sprites[1].flip_x = right_side
						e.spawn_dest = dest
						e.delay = 0.3 * (i - 1)

						queue_insert(store, e)
					end

					a_spawn.ts = store.tick_ts

					coroutine.yield()

					if this.unit.is_stunned then
						goto label_249_0
					end

					if this.health.dead then
						goto label_249_0
					end

					local other_pi = this.nav_path.pi == 1 and 2 or 1

					if #P:path(other_pi, 1) - this.nav_path.ni > this.nodes_limit then
						U.unblock_all(store, this)

						this.vis.bans = bor(this.vis.bans, F_BLOCK)
						this.vis.bans = bor(this.vis.bans, F_FREEZE)

						local fx = E:create_entity("fx_gorilla_boss_jump_smoke")

						fx.pos = V.vclone(this.pos)
						fx.render.sprites[1].ts = store.tick_ts + 0.45

						queue_insert(store, fx)

						local right_side = this.nav_path.pi == 2

						U.y_animation_play(this, "jump", right_side, store.tick_ts, 1)
						S:queue(this.sound_events.jump_to_tower)
						U.animation_start(this, "fly", right_side, store.tick_ts, true)

						this.render.sprites[1].z = Z_OBJECTS_SKY

						if right_side then
							y_jump(this.pos, this.tower_pos_right)
						else
							y_jump(this.pos, this.tower_pos_left)
						end

						this.render.sprites[1].z = Z_OBJECTS
						this.render.sprites[1].sort_y_offset = -35

						U.y_animation_play(this, "jump_reach", right_side, store.tick_ts, 1)

						on_tower = true
						on_tower_ts = store.tick_ts
						this.idle_flip.ts = store.tick_ts
						this.vis.bans = band(this.vis.bans, bnot(F_FREEZE))

						goto label_249_0
					end
				end

				if store.tick_ts - a_heal.ts > a_heal.cooldown and this.health.hp / this.health.hp_max < 0.9 then
					a_heal.ts = store.tick_ts
					this.health.hp = this.health.hp + km.clamp(0, this.health.hp_max, a_heal.points)

					S:queue(a_heal.sound)

					local fx = E:create_entity("fx_gorilla_boss_heal")

					fx.pos = this.pos
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					queue_insert(store, fx)
					U.y_animation_play(this, "heal", nil, store.tick_ts)

					goto label_249_0
				end

				blocker = U.get_blocker(store, this)

				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_249_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_249_0
						end

						coroutine.yield()
					end
				end

				if not U.get_blocker(store, this) then
					if not SU.y_enemy_walk_step(store, this) then
						return
					end

					goto label_249_0
				end
			end

			coroutine.yield()
		end
	end
end

scripts.eb_umbra = {}

function scripts.eb_umbra.get_info(this)
	local b = E:get_template("ray_umbra")
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = 2 * min,
		damage_max = 2 * max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_umbra.insert(this, store)
	this.health_bar.black_bar_hp = this.health.hp_max

	return true
end

function scripts.eb_umbra.update(this, store)
	local as = this.attacks.list[1]
	local at = this.attacks.list[2]
	local ars = this.attacks.list[3]
	local art = this.attacks.list[4]
	local ap = this.attacks.list[5]
	local taunt = this.taunt
	local is_in_pieces = false
	local is_at_home = true
	local pieces = {}
	local max_pieces = 10
	local pieces_alive = max_pieces
	local death_cycles = 0
	local teleport_jumps = 0
	local last_jump_center = false
	local last_ray_towers_inner = false
	local piece_arrival_node = 4
	local hp_per_piece = this.health.hp_max / max_pieces
	local body_sid = 1
	local eyes_sid = 2
	local home_node = this.home_node

	local function update_cooldowns()
		if is_at_home then
			as.cooldown = as.cooldowns.at_home[pieces_alive]
			at.cooldown = at.cooldowns.at_home[pieces_alive]
			art.cooldown = art.cooldowns.at_home[pieces_alive]
		else
			as.cooldown = as.cooldowns.on_battlefield[pieces_alive]
			at.cooldown = at.cooldowns.on_battlefield[pieces_alive]
			art.cooldown = art.cooldowns.on_battlefield[pieces_alive]
		end

		as.ts = store.tick_ts
		at.ts = store.tick_ts
		art.ts = store.tick_ts
	end

	local function y_shoot_rays(attack, target, to_offset_y, fake_shot)
		to_offset_y = to_offset_y or 0
		this.render.sprites[eyes_sid].hidden = false

		local start_ts = store.tick_ts

		S:queue(attack.sound)
		U.animation_start(this, attack.animation, nil, store.tick_ts, false, eyes_sid)

		while store.tick_ts - start_ts < attack.shoot_time do
			coroutine.yield()
		end

		for _, o in pairs(attack.bullet_start_offset) do
			local r = E:create_entity(attack.bullet)

			r.bullet.from = v(this.pos.x + o.x, this.pos.y + o.y)
			r.bullet.to = v(target.pos.x, target.pos.y + to_offset_y)
			r.bullet.source_id = this.id
			r.bullet.target_id = target.id
			r.pos = V.vclone(r.bullet.from)

			if fake_shot then
				r.bullet.hit_fx = "fx_ray_umbra_explosion_smoke"
				r.bullet.damage_type = DAMAGE_NONE
			end

			queue_insert(store, r)
		end

		while not U.animation_finished(this, eyes_sid) do
			coroutine.yield()
		end

		this.render.sprites[eyes_sid].hidden = true
	end

	local function show_taunt(idx, duration, flip_x)
		local t = E:create_entity("decal_umbra_shoutbox")

		t.texts.list[1].text = _(string.format(taunt.format, idx))

		if flip_x then
			t.render.sprites[1].flip_x = true
			t.render.sprites[2].offset.x = -1 * t.render.sprites[2].offset.x
			t.pos = taunt.left_pos
		else
			t.pos = taunt.right_pos
		end

		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		local font_sizes = t.texts.list[1].font_sizes

		if idx == 1 then
			t.texts.list[1].font_size = font_sizes[1]
		elseif idx == 2 then
			t.texts.list[1].font_size = font_sizes[2]
		else
			t.texts.list[1].font_size = font_sizes[3]
		end

		queue_insert(store, t)

		return t
	end

	update_cooldowns()

	this.nav_path = home_node
	this.pos = P:node_pos(this.nav_path)
	this.phase = "intro"

	U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
	U.y_wait(store, fts(113))

	local off = v(90, 8)
	local fake_target = {}
	local guy = store.level.guy

	fake_target.id = guy.id
	fake_target.pos = v(guy.pos.x + off.x, guy.pos.y + off.y)

	y_shoot_rays(ars, fake_target, nil, true)
	U.y_wait(store, 0.6)
	show_taunt(1, 2)
	U.y_wait(store, 2)
	show_taunt(2, 2)
	U.y_wait(store, 2)
	show_taunt(3, 2)
	U.y_wait(store, 2)

	this.health_bar.hidden = false
	this.phase = "loop"

	update_cooldowns()

	local force_taunt

	while true do
		if is_in_pieces then
			local callback_pieces = ap.callback_pieces[km.clamp(1, 3, death_cycles)]

			while store.tick_ts - ap.ts < ap.cooldown do
				coroutine.yield()

				for i = #pieces, 1, -1 do
					local p = pieces[i]

					if pieces_alive <= callback_pieces then
						goto label_254_0
					elseif piece_arrival_node > P:nodes_to_goal(p.nav_path) then
						goto label_254_0
					elseif p.health.dead then
						pieces_alive = pieces_alive - 1

						table.remove(pieces, i)
						log.debug("died %s,  alive:%s, pieces:%s", p.id, pieces_alive, #pieces)
					end
				end
			end

			::label_254_0::

			for i = 1, #pieces do
				local p = pieces[i]

				U.unblock_all(store, p)
				SU.remove_modifiers(store, p)

				U.update_max_speed(p, p.motion.max_speed_called)

				SU.stun_dec(p, true)

				p.vis.bans = F_ALL
				p.health.immune_to = DAMAGE_ALL
				p.health_bar.hidden = true
				p.health.dead = false
				p.health.hp = p.health.hp_max
				p.render.sprites[1].hidden = false
				p.call_back = true

				if not p.main_script.co then
					log.debug("rebooting umbra_piece coroutine")

					p.main_script.runs = 1
				end
			end

			local recovered_hp = 0
			local pieces_returned = {}
			local recover_pos = P:node_pos(home_node.pi, 1, P:get_end_node(home_node.pi) - piece_arrival_node)

			while #pieces > 0 do
				for i = #pieces, 1, -1 do
					local p = pieces[i]

					if piece_arrival_node > P:nodes_to_goal(p.nav_path) then
						table.remove(pieces, i)
						table.insert(pieces_returned, p)

						recovered_hp = recovered_hp + hp_per_piece
						U.update_max_speed(p, 0)

						S:queue("FrontiersFinalBossPiecesRegroup")

						if this.render.sprites[1].hidden and #pieces_returned == 2 then
							for _, pr in pairs(pieces_returned) do
								pr.recovered = true
								pr.health.dead = true
								pr.pos = V.vclone(recover_pos)
							end

							this.render.sprites[1].hidden = false
							this.render.sprites[1].scale = v(0.5, 0.5)

							U.animation_start(this, "ball_idle", nil, store.tick_ts, true)
						elseif #pieces_returned > 2 then
							local scale = this.render.sprites[1].scale.x

							scale = km.clamp(0.5, 1, scale + 0.1)
							this.render.sprites[1].scale.x = scale
							this.render.sprites[1].scale.y = scale
							p.recovered = true
							p.health.dead = true
							p.pos = V.vclone(recover_pos)
						end
					end
				end

				coroutine.yield()
			end

			log.debug("waiting for fuse")
			U.y_wait(store, 0.5)
			log.debug("transform")
			S:queue("FrontiersFinalBossRespawn")

			this.render.sprites[1].scale.x = 1
			this.render.sprites[1].scale.y = 1

			U.y_animation_play(this, "transform", nil, store.tick_ts, 1)

			pieces_alive = #pieces_returned
			this.health.hp = recovered_hp
			this.health.hp_max = recovered_hp
			this.health.dead = false
			this.health.immune_to = DAMAGE_NONE
			this.health_bar.hidden = false
			this.vis.bans = this.vis.bans_at_home
			is_in_pieces = false

			update_cooldowns()

			force_taunt = true

			U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
		else
			if this.health.dead then
				LU.kill_all_enemies(store, true)
				SU.remove_modifiers(store, this)
				U.unblock_all(store, this)

				if pieces_alive < ap.min_pieces_to_respawn then
					this.phase = "death-animation"

					S:stop_all()
					S:queue("FrontiersFinalBossDeath")

					local fx_explosions = {
						{v(99, 103), 0},
						{v(99, 103), 0.9},
						{v(99, 103), 1.8},
						{v(99, 103), 2.7},
						{v(134, 54), 0.13},
						{v(134, 54), 1.03},
						{v(134, 54), 1.93},
						{v(134, 54), 2.83},
						{v(147, 104), 0.26},
						{v(147, 104), 1.16},
						{v(147, 104), 2.06},
						{v(147, 104), 2.96},
						{v(68, 78), 0.4},
						{v(68, 78), 1.3},
						{v(68, 78), 2.2},
						{v(68, 78), 3.1},
						{v(169, 76), 0.56},
						{v(169, 76), 1.46},
						{v(169, 76), 2.33},
						{v(118, 89), 0.73},
						{v(118, 89), 1.63},
						{v(118, 89), 2.5}
					}
					local fx_rays = {{v(119, 88), 0.96}, {v(119, 88), 1.2}, {v(119, 88), 1.43}, {v(119, 88), 1.63}, {v(119, 88), 1.86}}

					U.animation_start(this, "death", nil, store.tick_ts, true)
					U.y_wait(store, 3)

					local image_x, image_y = 238, 176
					local anchor_x, anchor_y = 0.5, 0.18

					for _, p in pairs(fx_explosions) do
						local pos, delay = unpack(p)
						local fx = E:create_entity("fx")

						fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
						fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
						fx.render.sprites[1].name = "umbra_death_explosion"
						fx.render.sprites[1].ts = store.tick_ts + delay

						queue_insert(store, fx)
					end

					for _, p in pairs(fx_rays) do
						local pos, delay = unpack(p)
						local fx = E:create_entity("fx")

						fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
						fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
						fx.render.sprites[1].name = "umbra_death_rays"
						fx.render.sprites[1].ts = store.tick_ts + delay

						queue_insert(store, fx)
					end

					local pos, delay = v(119, 85), 2.3
					local fx = E:create_entity("fx")

					fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
					fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
					fx.render.sprites[1].name = "umbra_death_blast_long"
					fx.render.sprites[1].ts = store.tick_ts + delay

					queue_insert(store, fx)
					U.y_wait(store, 2.5)

					local pos = v(119, 80)
					local fx = E:create_entity("fx_umbra_white_circle")

					fx.pos.x = this.pos.x + pos.x - image_x * anchor_x
					fx.pos.y = this.pos.y + pos.y - image_y * anchor_y
					fx.render.sprites[1].ts = store.tick_ts

					queue_insert(store, fx)
					U.y_wait(store, 1)

					this.phase = "dead"

					queue_remove(store, this)
					signal.emit("boss-killed", this)

					return
				else
					S:queue("FrontiersFinalBossExplode")

					this.health_bar.hidden = true
					this.health.immune_to = DAMAGE_ALL
					ap.ts = store.tick_ts

					local fx = E:create_entity("fx_umbra_death_blast")

					fx.render.sprites[1].name = "short"
					fx.render.sprites[1].ts = store.tick_ts
					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

					queue_insert(store, fx)

					pieces = {}

					for i = 1, pieces_alive do
						local p = E:create_entity(ap.payload_entity)

						p.nav_path.pi = table.random(ap.dest_pi)
						p.nav_path.spi = math.random(1, 3)
						p.nav_path.ni = math.random(P:get_start_node(p.nav_path.pi) + ap.initial_ni, P:get_end_node(p.nav_path.pi) - ap.limit_ni)
						p.pos = P:node_pos(p.nav_path)

						if death_cycles > 0 then
							p.piece_respawn_delay = p.piece_respawn_delay_repeating
						end

						table.insert(pieces, p)

						local s = E:create_entity(ap.entity)

						s.pos.x, s.pos.y = this.pos.x, this.pos.y
						s.pos.x = s.pos.x + math.random(ap.start_offset_x[1], ap.start_offset_x[2])
						s.pos.y = s.pos.y + math.random(ap.start_offset_y[1], ap.start_offset_y[2])
						s.bullet.from = V.vclone(s.pos)
						s.bullet.to = V.vclone(p.pos)

						local dist = V.dist(s.bullet.from.x, s.bullet.from.y, s.bullet.to.x, s.bullet.to.y)

						s.bullet.flight_time = s.bullet.flight_time + fts(dist / 30)
						s.bullet.hit_payload = p
						s.render.sprites[1].ts = store.tick_ts

						queue_insert(store, s)
					end

					U.y_animation_play(this, "explode", nil, store.tick_ts, 1)

					this.render.sprites[1].hidden = true
					this.nav_path = home_node
					this.pos = P:node_pos(this.nav_path)
					this.vis.bans = this.vis.bans_in_pieces
					is_at_home = true
					is_in_pieces = true
					death_cycles = death_cycles + 1

					goto label_254_2
				end
			end

			if is_at_home and (force_taunt or store.tick_ts - taunt.ts > taunt.cooldown) and store.tick_ts - at.ts < at.cooldown - 2 then
				force_taunt = nil

				local i = math.random(taunt.start_idx, taunt.end_idx)
				local t = show_taunt(i, taunt.duration, math.random() < 0.5)

				taunt.ts = store.tick_ts + taunt.duration
				taunt.last_id = t.id
			end

			if not this.render.sprites[1].sync_flag or this.render.sprites[1].runs == 0 then
			-- block empty
			else
				if as.cooldown > 0 and store.tick_ts - as.ts > as.cooldown then
					S:queue("FrontiersFinalBossPortal")
					U.animation_start(this, as.animation, nil, store.tick_ts, false, body_sid)

					local nleft = table.random(as.nodes_left)
					local nright = table.random(as.nodes_right)
					local nodes = {nleft, nright}

					for _, n in pairs(nodes) do
						local s = E:create_entity(as.entity)

						s.pos = P:node_pos(n[1])
						s.spawner.allowed_nodes = n
						s.spawner.count = as.count_min + math.floor((max_pieces - pieces_alive) * as.add_per_missing_piece)

						queue_insert(store, s)
					end

					while not U.animation_finished(this, body_sid) and not this.health.dead do
						coroutine.yield()
					end

					as.ts = store.tick_ts

					goto label_254_1
				end

				if store.tick_ts - at.ts > at.cooldown then
					this.health_bar.hidden = true
					this.health.ignore_damage = true

					S:queue("FrontiersFinalBossTeleport")
					U.y_animation_play(this, "teleport_out", nil, store.tick_ts, 1, body_sid)
					U.unblock_all(store, this)

					local jump_node

					if is_at_home then
						teleport_jumps = teleport_jumps + 1

						local idx

						if last_jump_center and teleport_jumps <= at.max_side_jumps then
							idx = math.random(2, 3)
							last_jump_center = false
						else
							idx = 1
							last_jump_center = true
						end

						jump_node = at.nodes_battlefield[idx]
						is_at_home = false
					-- if taunt.last_id and store.entities[last_id] then
					--     queue_remove(store, store.entities[last_id])
					--     taunt.last_id = nil
					-- end
					else
						jump_node = home_node
						is_at_home = true
						force_taunt = true
					end

					this.nav_path = jump_node
					this.pos = P:node_pos(this.nav_path)
					this.vis.bans = is_at_home and this.vis.bans_at_home or this.vis.bans_in_battlefield

					U.y_animation_play(this, "teleport_in", nil, store.tick_ts, 1, body_sid)

					this.health_bar.hidden = false
					this.health.ignore_damage = is_at_home

					update_cooldowns()

					at.ts = store.tick_ts

					goto label_254_1
				end

				if art.cooldown > 0 and store.tick_ts - art.ts > art.cooldown then
					local start_ts = store.tick_ts
					local inner, outer = {}, {}

					for _, e in pairs(store.towers) do
						if not e.tower_holder and not e.tower.blocked and (not is_at_home or not table.contains(art.lower_towers, e.tower.holder_id)) and e.pos.y < this.pos.y then
							if table.contains(art.inner_towers, e.tower.holder_id) then
								table.insert(inner, e)
							else
								table.insert(outer, e)
							end
						end
					end

					local set

					if last_ray_towers_inner then
						set = #outer > 0 and outer or inner
					else
						set = #inner > 0 and inner or outer
					end

					last_ray_towers_inner = set == inner

					if #set > 0 then
						log.debug("Umbra ray set: %s\n outer:%s\n inner:%s", getdump(table.map(set, function(k, v)
							return v.tower.holder_id
						end)), getdump(table.map(outer, function(k, v)
							return v.tower.holder_id
						end)), getdump(table.map(inner, function(k, v)
							return v.tower.holder_id
						end)))

						local target = set[math.random(1, #set)]

						S:queue("VeznanHoldCast")
						y_shoot_rays(art, target, 20)

						art.ts = start_ts + 2
					else
						art.ts = store.tick_ts - art.cooldown + 1
					end

					goto label_254_1
				end

				if store.tick_ts - ars.ts > ars.cooldown then
					local target = U.find_nearest_soldier(store.soldiers, this.pos, ars.min_range, ars.max_range, ars.vis_flags, ars.vis_bans, function(t)
						return t.pos.y - 10 < this.pos.y
					end)

					if target then
						y_shoot_rays(ars, target)

						ars.ts = store.tick_ts
					else
						ars.ts = store.tick_ts - ars.cooldown + 0.5
					end
				end

				::label_254_1::

				U.animation_start(this, "idle", nil, store.tick_ts, true, body_sid)
			end
		end

		::label_254_2::

		coroutine.yield()
	end
end

scripts.umbra_portal = {}

function scripts.umbra_portal.update(this, store)
	local sp = this.spawner
	local s = this.render.sprites[1]
	local spawn_ts

	if sp.animation_start then
		U.y_animation_play(this, sp.animation_start, nil, store.tick_ts, 1)
	end

	if sp.animation_loop then
		U.animation_start(this, sp.animation_loop, nil, store.tick_ts, true)
	end

	for i = 1, sp.count do
		if sp.interrupt then
			break
		end

		local no = table.random(sp.allowed_nodes)
		local spawn = E:create_entity(sp.entity)

		spawn.nav_path.pi = no.pi
		spawn.nav_path.spi = km.zmod(i, 3)
		spawn.nav_path.ni = no.ni + math.random(-sp.ni_var, sp.ni_var)
		spawn.unit.spawner_id = this.id
		spawn.pos = P:node_pos(spawn.nav_path)

		queue_insert(store, spawn)

		if sp.spawn_fx then
			fx = E:create_entity(sp.spawn_fx)
			fx.pos.x, fx.pos.y = spawn.pos.x, spawn.pos.y - 1
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		spawn_ts = store.tick_ts

		while store.tick_ts - spawn_ts < sp.cycle_time do
			if sp.interrupt then
				goto label_262_0
			end

			coroutine.yield()
		end
	end

	::label_262_0::

	if sp.animation_end then
		U.y_animation_play(this, sp.animation_end, nil, store.tick_ts, 1)
	end

	queue_remove(store, this)
end

scripts.enemy_umbra_piece = {}

function scripts.enemy_umbra_piece.update(this, store)
	this.health_bar.hidden = true

	U.y_animation_play(this, "fall", nil, store.tick_ts, 1)
	U.y_wait(store, this.piece_respawn_delay)
	S:queue(this.sound_events.raise)
	U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

	this.vis.bans = this.vis.bans_walking
	this.health_bar.hidden = false

	::label_263_0::

	this.call_back = false

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	::label_263_1::

	while true do
		if this.recovered then
			U.y_animation_play(this, "fuse", nil, store.tick_ts, 1)
			queue_remove(store, this)

			return
		end

		if this.health.dead then
			coroutine.yield()

			if this.call_back then
				goto label_263_0
			end

			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_263_1
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_263_1
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.umbra_guy = {}

function scripts.umbra_guy.update(this, store)
	local at = this.attacks.list[1]
	local taunt = this.taunt
	local last_lives = store.lives

	local function show_taunt(idx, duration)
		local t = E:create_entity("decal_umbra_guy_shoutbox")

		t.texts.list[1].text = _(string.format(taunt.format, idx))
		t.pos = taunt.normal_pos
		t.timed.duration = duration
		t.render.sprites[1].ts = store.tick_ts
		t.render.sprites[2].ts = store.tick_ts

		if #t.texts.list[1].text > 40 then
			t.texts.list[1].line_height = t.texts.list[1].line_heights[2]
		else
			t.texts.list[1].line_height = t.texts.list[1].line_heights[1]
		end

		queue_insert(store, t)

		return t
	end

	U.animation_start(this, "taunt", nil, store.tick_ts, true)

	while this.phase ~= "intro" do
		coroutine.yield()
	end

	show_taunt(1, 4)
	U.y_wait(store, 4)
	show_taunt(2, 4)
	U.y_wait(store, 4)

	at.ts = store.tick_ts
	taunt.ts = store.tick_ts
	this.phase = "intro-finished"

	while true do
		if this.phase == "death" then
			this.phase = "death-started"

			show_taunt(50, 3)
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			U.y_wait(store, 4.1)
			U.animation_start(this, "death", nil, store.tick_ts, false)
			U.y_wait(store, fts(49))

			local t = show_taunt(0, fts(58))

			t.pos.x, t.pos.y = taunt.death_pos.x, taunt.death_pos.y

			U.y_animation_wait(this)
			queue_remove(store, this)

			return
		end

		if last_lives ~= store.lives and store.tick_ts - taunt.ts > taunt.cooldown * 0.5 then
			last_lives = store.lives

			local i = math.random(taunt.lost_life_idx[1], taunt.lost_life_idx[2])
			local t = show_taunt(i, taunt.duration)

			U.animation_start(this, "taunt", nil, store.tick_ts, true)
			U.y_wait(store, taunt.duration)

			taunt.ts = store.tick_ts

			if store.tick_ts - at.ts + 2 > at.cooldown then
				at.ts = at.ts + 2
			end

			goto label_264_0
		end

		if store.tick_ts - taunt.ts > taunt.cooldown then
			local i = math.random(taunt.normal_idx[1], taunt.normal_idx[2])
			local t = show_taunt(i, taunt.duration)

			U.animation_start(this, "taunt", nil, store.tick_ts, true)
			U.y_wait(store, taunt.duration)

			taunt.ts = store.tick_ts

			if store.tick_ts - at.ts + 2 > at.cooldown then
				at.ts = at.ts + 2
			end

			goto label_264_0
		end

		if store.wave_group_number > 0 and store.tick_ts - at.ts > at.cooldown then
			local target = U.find_random_target(store.entities, this.pos, 0, at.max_range, at.vis_flags, at.vis_bans)

			if not target then
			-- block empty
			else
				local start_ts = store.tick_ts

				log.debug(">>> %s: umbra_guy firing at (%s) %s", store.tick_ts, target.id, target.template_name)

				local i = math.random(taunt.attack_idx[1], taunt.attack_idx[2])

				show_taunt(i, taunt.attack_duration)

				taunt.ts = store.tick_ts + taunt.attack_duration

				U.animation_start(this, at.animation, ni, store.tick_ts, false)
				U.y_wait(store, at.shoot_time)

				local off = at.bullet_start_offset
				local toff = v(0, 0)

				if target.unit and target.unit.hit_offset then
					toff.x, toff.y = target.unit.hit_offset.x, target.unit.hit_offset.y
				end

				local r = E:create_entity(at.bullet)

				r.bullet.from = v(this.pos.x + off.x, this.pos.y + off.y)
				r.bullet.to = v(target.pos.x + toff.x, target.pos.y + toff.y)
				r.bullet.source_id = this.id
				r.bullet.target_id = target.id
				r.pos = V.vclone(r.bullet.from)

				queue_insert(store, r)
				U.y_animation_wait(this)

				at.ts = store.tick_ts

				if store.tick_ts - taunt.ts + 2 > taunt.cooldown then
					taunt.ts = taunt.ts + 2
				end
			end
		end

		::label_264_0::

		U.animation_start(this, "idle", nil, store.tick_ts, true)
		coroutine.yield()
	end
end

scripts.eb_leviathan = {}

function scripts.eb_leviathan.get_info(this)
	return {
		damage_min = 500,
		damage_max = 800,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_leviathan.insert(this, store)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)

	if not this.pos or this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

	return true
end

function scripts.eb_leviathan.update(this, store)
	local sid = 2
	local a_t = this.attacks.list[1]
	local tentacles = {}
	local tentacle_seq_idx = 1
	local tentacle_seq = this.tentacle_seq
	local tentacle_pos = this.tentacle_pos

	local function do_death()
		S:queue(this.sound_events.death)
		U.animation_start(this, "death", nil, store.tick_ts, false)

		this.render.sprites[1].hidden = true

		local fxs = {
			{v(-50, 35), fts(20)},
			{v(-22, 49), fts(22)},
			{v(-15, 16), fts(22)},
			{v(30, 47), fts(24)},
			{v(26, 10), fts(24)},
			{v(3, 64), fts(26)},
			{v(-33, 31), fts(27)},
			{v(49, 53), fts(29)},
			{v(48, 31), fts(31)},
			{v(-38, 55), fts(33)},
			{v(-14, 59), fts(36)},
			{v(-3, 41), fts(36)},
			{v(28, 48), fts(36)},
			{v(-2, 37), fts(39)},
			{v(4, 66), fts(39)},
			{v(19, 53), fts(39)},
			{v(3, 63), fts(45)},
			{v(-25, 50), fts(45)},
			{v(-18, 74), fts(45)},
			{v(12, 38), fts(45)},
			{v(47, 41), fts(45)},
			{v(3, 44), fts(50)},
			{v(-6, 59), fts(50)},
			{v(12, 59), fts(50)},
			{v(-4, 64), fts(58)},
			{v(16, 59), fts(58)},
			{v(3, 42), fts(58)}
		}
		local fx_scale = 1

		for i, p in ipairs(fxs) do
			fx_scale = fx_scale - (i % 5 == 0 and 0.1 or 0)

			local offset, delay = unpack(p)
			local fx = E:create_entity("fx_explosion_water")

			fx.pos.x = this.pos.x + offset.x
			fx.pos.y = this.pos.y + offset.y - 15
			fx.render.sprites[1].ts = store.tick_ts + delay
			fx.render.sprites[1].scale = v(fx_scale, fx_scale)

			queue_insert(store, fx)
		end

		U.y_animation_wait(this, sid)
	end

	this.phase = "spawn"

	U.sprites_hide(this)

	this.health_bar.hidden = true

	local fx = E:create_entity("fx_leviathan_incoming")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	U.y_wait(store, 3)
	S:queue("RTBossSpawn")

	this.render.sprites[sid].hidden = nil

	local an, af = U.animation_name_facing_point(this, "spawn", this.motion.dest)

	U.y_animation_play(this, an, af, store.tick_ts, 1, sid)

	local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

	U.animation_start(this, an, af, store.tick_ts, true, sid)

	this.render.sprites[1].hidden = nil
	this.health_bar.hidden = nil
	this.phase = "loop"
	this.vis.bans = this.vis.bans_in_battlefield
	a_t.ts = store.tick_ts

	::label_268_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)

			for _, t in pairs(tentacles) do
				t.interrupt = true
			end

			do_death()
			queue_remove(store, this)
			signal.emit("boss-killed", this)

			return
		end

		if this.unit.is_stunned then
			coroutine.yield()
		else
			if store.tick_ts - a_t.ts > a_t.cooldown then
				local seq = tentacle_seq[tentacle_seq_idx]

				tentacle_seq_idx = km.zmod(tentacle_seq_idx + 1, #tentacle_seq)

				for _, idx in pairs(seq) do
					local tp = tentacle_pos[idx]
					local e = E:create_entity("leviathan_tentacle")

					e.pos.x, e.pos.y = tp[1], tp[2]
					e.flip = tp[3]

					LU.queue_insert(store, e)
					table.insert(tentacles, e)
					U.y_wait(store, U.frandom(0.1, 0.2))
				end

				while #tentacles > 0 do
					U.y_wait(store, 0.25)

					if this.health.dead then
						goto label_268_0
					end

					for i = #tentacles, 1, -1 do
						local t = tentacles[i]

						if not store.entities[t.id] then
							table.remove(tentacles, i)
						end
					end
				end

				a_t.ts = store.tick_ts
			end

			if not SU.y_enemy_walk_step(store, this) then
				return
			end
		end

		if false then
			coroutine.yield()
		end
	end
end

scripts.leviathan_tentacle = {}

function scripts.leviathan_tentacle.update(this, store)
	local s = this.render.sprites[1]

	s.flip_x = this.flip

	local search_pos = v(this.pos.x + (this.flip and -1 or 1) * this.search_off_x, this.pos.y)

	S:queue("RTBossTentacle")
	U.y_animation_play(this, "show", nil, store.tick_ts)
	U.animation_start(this, "wiggle", nil, store.tick_ts, true)

	local start_ts = store.tick_ts

	while not this.interrupt and store.tick_ts - start_ts < this.duration do
		U.y_wait(store, 2)

		local targets = table.filter(store.towers, function(k, e)
			return e and not e.tower_holder and e.tower.type ~= "build_animation" and not e.tower.blocked and not table.contains(this.tower_bans, e.template_name) and U.is_inside_ellipse(e.pos, search_pos, this.range)
		end)

		if #targets > 0 then
			local target = targets[1]

			SU.tower_block_inc(target)
			S:queue("RTBossTentacleAttack")
			U.y_animation_play(this, "attack", nil, store.tick_ts)
			U.animation_start(this, "hold", nil, store.tick_ts, true)

			start_ts = store.tick_ts

			while not this.interrupt and store.tick_ts - start_ts < this.duration do
				coroutine.yield()
			end

			SU.tower_block_dec(target)
			U.y_animation_play(this, "release", nil, store.tick_ts)

			break
		end
	end

	U.y_animation_play(this, "hide", nil, store.tick_ts)
	queue_remove(store, this)
end

scripts.eb_dracula = {}

-- function scripts.eb_dracula.get_info(this)
--     return {
--         damage_min = 150,
--         damage_max = 200,
--         type = STATS_TYPE_ENEMY,
--         hp = this.health.hp,
--         hp_max = this.health.hp_max,
--         armor = this.health.armor,
--         magic_armor = this.health.magic_armor,
--         lives = this.enemy.lives_cost
--     }
-- end
function scripts.eb_dracula.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_dracula.can_lifesteal(this, store, attack, target)
	return not U.is_wraith(target.template_name)
end

function scripts.eb_dracula.update(this, store)
	local function y_fly_to(pos)
		U.animation_start(this, "bat_fly", nil, store.tick_ts, true)
		U.set_destination(this, pos)

		U.update_max_speed(this, this.motion.max_speed_bat)

		while not this.motion.arrived do
			U.walk(this, store.tick_length)
			coroutine.yield()
		end

		local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi})

		this.nav_path.ni = nodes[1][3]
		U.update_max_speed(this, this.motion.max_speed_default)
	end

	this.phase = "intro"

	y_fly_to(v(520, 590))
	U.y_animation_play(this, "bat_exit", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local t = E:create_entity("decal_dracula_shoutbox")

	t.texts.list[1].text = _("DRACULA_TAUNT_FIGHT_0001")
	t.pos.x, t.pos.y = this.pos.x - 1, this.pos.y - 57
	t.timed.duration = 4.7
	t.render.sprites[1].ts = store.tick_ts
	t.render.sprites[2].ts = store.tick_ts

	queue_insert(store, t)
	U.y_wait(store, t.timed.duration + 1)

	this.phase = "fight"

	::label_275_0::

	while true do
		if this.health.dead then
			U.unblock_all(store, this)

			if this.phase == "fight" then
				this.nav_path.pi = 3
				this.health_bar.hidden = true

				local _vis_bans = this.vis.bans

				this.vis.bans = bor(this.vis.bans, F_ALL)

				y_fly_to(v(525, 540))
				y_fly_to(v(525, 790))

				this.vis.bans = _vis_bans
				this.phase = "angry"
				this.health_bar.hidden = nil
				this.health.hp = this.health.hp_max
				this.health.dead = false
				U.update_max_speed(this, this.motion.max_speed_angry)

				local e = E:create_entity("dracula_damage_aura")

				e.aura.source_id = this.id

				queue_insert(store, e)
			else
				this.phase = "dead"

				LU.kill_all_enemies(store, true)
				S:stop_all()
				S:queue(this.sound_events.death)
				U.y_animation_play(this, "death", nil, store.tick_ts)
				signal.emit("boss-killed", this)

				return true
			end
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_275_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_275_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.dracula_damage_aura = {}

function scripts.dracula_damage_aura.update(this, store)
	local a = this.aura

	a.ts = store.tick_ts

	local last_ts = store.tick_ts
	local source = store.entities[a.source_id]

	if not source then
		queue_remove(store, this)

		return
	end

	this.pos = source.pos

	while not source.health.dead and source.enemy.can_do_magic do
		if store.tick_ts - last_ts >= a.cycle_time then
			local dt = store.tick_ts - last_ts

			last_ts = store.tick_ts

			local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in pairs(targets) do
					local value = math.random(a.dps_min, a.dps_max)

					value = value * dt * (target.hero and a.hero_damage_factor or 1)

					if a.dist_factor_min_radius then
						local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, a.radius, a.dist_factor_min_radius)

						value = value * (1 - dist_factor)
					end

					local d = E:create_entity("damage")

					d.damage_type = a.damage_type
					d.value = value
					d.target_id = target.id
					d.source_id = this.id

					queue_damage(store, d)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_dracula_lifesteal = {}

function scripts.mod_dracula_lifesteal.update(this, store)
	local m = this.modifier
	local source = store.entities[m.source_id]
	local target = store.entities[m.target_id]

	m.ts = store.tick_ts

	local last_ts = store.tick_ts

	SU.stun_inc(target)

	while not source.health.dead and store.tick_ts - m.ts < m.duration do
		if store.tick_ts - last_ts > this.cycle_time then
			last_ts = store.tick_ts
			source.health.hp = km.clamp(0, source.health.hp_max, source.health.hp + this.heal_hp)
		end

		coroutine.yield()
	end

	SU.stun_dec(target)

	local d = E:create_entity("damage")

	d.value = this.damage
	d.source_id = this.id
	d.target_id = target.id
	d.damage_type = target.hero and DAMAGE_TRUE or DAMAGE_INSTAKILL

	queue_damage(store, d)
	queue_remove(store, this)
end

scripts.eb_saurian_king = {}

function scripts.eb_saurian_king.get_info(this)
	local m = E:get_template("mod_saurian_king_tongue")
	local min, max = m.modifier.damage_min, m.modifier.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_saurian_king.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_saurian_king.update(this, store)
	local ha = this.timed_attacks.list[1]

	local function ready_to_hammer()
		return enemy_ready_to_magic_attack(this, store, ha)
	end

	local function hammer_hit(idx)
		S:queue("SaurianKingBossQuake", {
			delay = fts(4)
		})

		local a = E:create_entity("aura_screen_shake")

		a.aura.amplitude = idx / #ha.max_damages

		queue_insert(store, a)

		local dmin, dmax = ha.min_damages[idx], ha.max_damages[idx]
		local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, ha.damage_radius, ha.vis_flags, ha.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, ha.damage_radius, ha.max_damage_radius)
				local d = E:create_entity("damage")

				d.damage_type = ha.damage_type
				d.value = dmax - (dmax - dmin) * dist_factor
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		local fx = E:create_entity("decal_saurian_king_hammer")
		local o = ha.fx_offsets[km.zmod(idx, 2)]

		fx.pos = v(this.pos.x + o.x * (this.render.sprites[1].flip_x and -1 or 1), o.y + this.pos.y)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	ha.ts = store.tick_ts

	::label_281_0::

	while true do
		if this.health.dead then
			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return true
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)

			ha.ts = store.tick_ts

			coroutine.yield()
		else
			if ready_to_hammer() then
				U.y_animation_play(this, ha.animations[1], nil, store.tick_ts)

				for i = 1, #ha.max_damages * 0.5 do
					if this.health.dead then
						goto label_281_1
					end

					if this.unit.is_stunned then
						goto label_281_1
					end

					U.animation_start(this, ha.animations[2], nil, store.tick_ts)
					S:queue(ha.sound, {
						delay = fts(3)
					})
					U.y_wait(store, ha.hit_times[1])

					if this.unit.is_stunned then
						goto label_281_1
					end

					hammer_hit(2 * i - 1)
					S:queue(ha.sound, {
						delay = fts(10)
					})
					U.y_wait(store, ha.hit_times[2])

					if this.unit.is_stunned then
						goto label_281_1
					end

					hammer_hit(2 * i)
					U.y_animation_wait(this)
				end

				ha.ts = store.tick_ts
			end

			::label_281_1::

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_hammer()
			end)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_281_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hammer() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_281_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_saurian_king_tongue = {}

function scripts.mod_saurian_king_tongue.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	local d = E:create_entity("damage")

	d.damage_type = target.hero and DAMAGE_TRUE or DAMAGE_EAT
	d.value = math.random(m.damage_min, m.damage_max)
	d.target_id = target.id
	d.source_id = this.id

	queue_damage(store, d)

	return false
end

scripts.eb_saurian_king = {}

function scripts.eb_saurian_king.get_info(this)
	local m = E:get_template("mod_saurian_king_tongue")
	local min, max = m.modifier.damage_min, m.modifier.damage_max

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_saurian_king.insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

function scripts.eb_saurian_king.update(this, store)
	local ha = this.timed_attacks.list[1]

	local function ready_to_hammer()
		return store.tick_ts - ha.ts > ha.cooldown
	end

	local function hammer_hit(idx)
		S:queue("SaurianKingBossQuake", {
			delay = fts(4)
		})

		local a = E:create_entity("aura_screen_shake")

		a.aura.amplitude = idx / #ha.max_damages

		queue_insert(store, a)

		local dmin, dmax = ha.min_damages[idx], ha.max_damages[idx]
		local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, ha.damage_radius, ha.vis_flags, ha.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local dist_factor = U.dist_factor_inside_ellipse(target.pos, this.pos, ha.damage_radius, ha.max_damage_radius)
				local d = E:create_entity("damage")

				d.damage_type = ha.damage_type
				d.value = dmax - (dmax - dmin) * dist_factor
				d.target_id = target.id
				d.source_id = this.id

				queue_damage(store, d)
			end
		end

		local fx = E:create_entity("decal_saurian_king_hammer")
		local o = ha.fx_offsets[km.zmod(idx, 2)]

		fx.pos = v(this.pos.x + o.x * (this.render.sprites[1].flip_x and -1 or 1), o.y + this.pos.y)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	ha.ts = store.tick_ts

	::label_281_0::

	while true do
		if this.health.dead then
			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)

			return true
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)

			ha.ts = store.tick_ts

			coroutine.yield()
		else
			if ready_to_hammer() then
				U.y_animation_play(this, ha.animations[1], nil, store.tick_ts)

				for i = 1, #ha.max_damages * 0.5 do
					if this.health.dead then
						goto label_281_1
					end

					if this.unit.is_stunned then
						goto label_281_1
					end

					U.animation_start(this, ha.animations[2], nil, store.tick_ts)
					S:queue(ha.sound, {
						delay = fts(3)
					})
					U.y_wait(store, ha.hit_times[1])

					if this.unit.is_stunned then
						goto label_281_1
					end

					hammer_hit(2 * i - 1)
					S:queue(ha.sound, {
						delay = fts(10)
					})
					U.y_wait(store, ha.hit_times[2])

					if this.unit.is_stunned then
						goto label_281_1
					end

					hammer_hit(2 * i)
					U.y_animation_wait(this)
				end

				ha.ts = store.tick_ts
			end

			::label_281_1::

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_hammer()
			end)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_281_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_hammer() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_281_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_saurian_king_tongue = {}

function scripts.mod_saurian_king_tongue.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	local d = E:create_entity("damage")

	d.damage_type = target.hero and DAMAGE_TRUE or DAMAGE_EAT
	d.value = math.random(m.damage_min, m.damage_max)
	d.target_id = target.id
	d.source_id = this.id

	queue_damage(store, d)

	return false
end

scripts.eb_gnoll = {}

function scripts.eb_gnoll.update(this, store)
	local fa = this.timed_attacks.list[1]
	local ha = this.timed_attacks.list[2]

	fa.ts = store.tick_ts

	local function ready_to_howl()
		if (not ha._last_ni or this.nav_path.ni > ha._last_ni) and table.contains(ha.nis, this.nav_path.ni) then
			return true
		end
	end

	local function ready_to_flail()
		return store.tick_ts - fa.ts > fa.cooldown and not this.health.dead and P:nodes_to_defend_point(this.nav_path) > 0
	end

	local function y_do_howl()
		S:queue(ha.sound)
		U.animation_start(this, ha.animation, nil, store.tick_ts)
		U.y_wait(store, ha.hit_time)

		ha.wave_idx = km.zmod((ha.wave_idx or 0) + 1, #ha.wave_names)
		this.mega_spawner.manual_wave = ha.wave_names[ha.wave_idx]

		U.y_animation_wait(this)
	end

	this.phase = "intro"
	this.health_bar.hidden = true

	y_do_howl()

	this.phase = "loop"
	this.health_bar.hidden = nil

	::label_321_0::

	while true do
		if this.health.dead then
			this.phase = "dead"
			this.mega_spawner.interrupt = true

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_howl() then
				log.debug("+++++++++++ howling")
				y_do_howl()

				ha._last_ni = this.nav_path.ni
			end

			if ready_to_flail() then
				U.animation_start(this, fa.animation, nil, store.tick_ts)
				U.y_wait(store, fa.hit_time)
				S:queue(fa.sound)

				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, fa.min_range, fa.max_range, fa.vis_flags, fa.vis_bans)

				if targets then
					for _, target in pairs(targets) do
						local d = E:create_entity("damage")

						d.damage_type = fa.damage_type

						if bit.band(target.vis.flags, F_HERO) ~= 0 then
							d.value = math.random(fa.damage_min_hero, fa.damage_max_hero)
						else
							d.value = math.random(fa.damage_min, fa.damage_max)
						end

						d.target_id = target.id
						d.source_id = this.id

						queue_damage(store, d)
					end
				end

				local a = E:create_entity("aura_screen_shake")

				queue_insert(store, a)
				U.y_animation_wait(this)

				fa.ts = store.tick_ts

				goto label_321_0
			end

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_flail() or ready_to_howl()
			end)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_321_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_flail() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_321_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_gnoll_boss = {}

function scripts.mod_gnoll_boss.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead or not target.unit then
		return false
	end

	this._hp_bonus = math.floor(target.health.hp_max * this.extra_health_factor)
	target.health.hp_max = target.health.hp_max + this._hp_bonus
	target.health.hp = target.health.hp + this._hp_bonus
	target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

	return true
end

function scripts.mod_gnoll_boss.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if target then
		target.health.hp_max = target.health.hp_max - this._hp_bonus
		target.health.hp = target.health.hp - this._hp_bonus
		target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
	end

	return true
end

scripts.eb_drow_queen = {}

function scripts.eb_drow_queen.on_damage(this, store, damage)
	if this.phase == "fighting" then
		if this.enemy.can_do_magic then
			this.shield.shield_dps = 0
			this.shield.health.hp = 1
			damage.value = damage.value * 0.6
		else
			this.shield.health.hp = 0
		end

		return true
	elseif this.phase == "casting" then
		log.debug("eb_drow_queen shield takes damage: %s", damage.value)

		this.shield.health.hp = this.shield.health.hp - damage.value

		return false
	end

	return false
end

function scripts.eb_drow_queen.update(this, store)
	local sid_body, sid_fly = 1, 4
	local s_body = this.render.sprites[sid_body]
	local d_shield = E:create_entity("decal_drow_queen_shield")

	d_shield.pos = this.pos

	queue_insert(store, d_shield)

	this.shield = d_shield

	local d_flying = E:create_entity("decal_drow_queen_flying")
	local s_flying = d_flying.render.sprites[1]

	queue_insert(store, d_flying)

	local ps = E:create_entity("ps_drow_queen_trail")

	queue_insert(store, ps)

	ps.particle_system.track_id = d_flying.id

	local function block_tower_ids(holder_ids, duration)
		for _, e in pairs(store.towers) do
			if e.tower.can_be_mod and table.contains(holder_ids, e.tower.holder_id) then
				local m = E:create_entity("mod_drow_queen_tower_block")

				m.modifier.source_id = this.id
				m.modifier.target_id = e.id
				m.pos.x, m.pos.y = e.pos.x, e.pos.y

				if duration then
					m.modifier.duration = duration
				end

				queue_insert(store, m)
			end
		end
	end

	local function block_random_tower()
		local towers = table.filter(store.towers, function(_, e)
			return e.tower.can_be_mod and not e.tower.blocked
		end)
		local tower, tower_id = table.random(towers)

		if tower then
			block_tower_ids({tower.tower.holder_id})
		end

		if #towers > 5 then
			local tower_2, tower_id_2 = table.random(towers)

			if tower_2 and tower_2_id ~= tower_id then
				block_tower_ids({tower_2.tower.holder_id})
			end
		end
	end

	local function block_all_towers()
		local towers = table.filter(store.towers, function(_, e)
			return e.tower and e.tower.can_be_mod and not e.tower.blocked
		end)
		local holder_ids = table.map(towers, function(k, v)
			return v.tower.holder_id
		end)

		block_tower_ids(holder_ids, 1000000000)
	end

	local function y_fly(from, to, speed, dest_pi)
		SU.remove_modifiers(store, this)

		local af = to.x < from.x

		s_flying.r = V.angleTo(to.x - from.x, to.y - from.y)
		s_flying.flip_y = math.abs(s_flying.r) > math.pi * 0.5

		S:queue("ElvesMaliciaTransformIn")
		U.y_animation_play(this, "teleportStart", af, store.tick_ts, 1, sid_body)

		s_body.hidden = true
		s_flying.hidden = false

		local fly_dist = V.dist(to.x, to.y, from.x, from.y)
		local fly_time = this.fly_loop_time * math.ceil(fly_dist / speed / this.fly_loop_time)
		local particles_dist = 10
		local emission_rate = fly_dist / particles_dist / fly_time

		ps.particle_system.emission_rate = emission_rate
		ps.particle_system.emit = true

		local start_ts = store.tick_ts
		local phase

		repeat
			phase = (store.tick_ts - start_ts) / fly_time
			d_flying.pos.x = U.ease_value(from.x, to.x, phase, "sine-outin")
			d_flying.pos.y = U.ease_value(from.y, to.y, phase, "sine-outin") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		ps.particle_system.emit = false
		this.pos.x, this.pos.y = to.x, to.y
		s_flying.hidden = true
		s_body.hidden = false

		S:queue("ElvesMaliciaTransformOut")
		U.y_animation_play(this, "teleportEnd", af, store.tick_ts, 1, sid_body)

		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]
	end

	local function y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_RANGED, F_MOD))
		this.health_bar.hidden = false
		this.shield.health.hp = shield_hp
		this.shield.health.hp_max = shield_hp
		this.shield.shield_dps = shield_hp / shield_duration

		local pow_cooldown = pow_cooldown_min
		local cast_ts = store.tick_ts
		local fx

		SU.y_show_taunt_set(store, this.taunts, this.phase)

		::label_337_0::

		U.y_animation_play(this, "shoutStart", true, store.tick_ts, 1, sid_body)
		U.animation_start(this, "shoutLoop", true, store.tick_ts, true, sid_body)

		while pow_cooldown > store.tick_ts - cast_ts and this.shield.health.hp > 0 do
			coroutine.yield()
		end

		U.y_animation_play(this, "shoutEnd", true, store.tick_ts, 1, sid_body)

		if this.shield.health.hp <= 0 then
		-- block empty
		else
			if not this.enemy.can_do_magic then
				pow_cooldown = pow_cooldown_min
				cast_ts = store.tick_ts

				if this.shield.health.hp > 0 then
					goto label_337_0
				end
			end

			S:queue("ElvesMaliciaSpellCast")
			U.animation_start(this, "cast", true, store.tick_ts, false, sid_body)

			fx = E:create_entity("fx_drow_queen_cast")
			fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = s_body.flip_x

			queue_insert(store, fx)
			U.y_wait(store, fts(13))
			-- if U.random_table_idx(pow_chances) == 2 then
			--     block_random_tower()
			-- else
			--     signal.emit("block-random-power", this.power_block_duration, "drow_queen")
			-- end
			block_random_tower()
			U.y_animation_wait(this)

			pow_cooldown = pow_cooldown_min
			cast_ts = store.tick_ts

			if this.shield.health.hp > 0 then
				goto label_337_0
			end
		end

		U.y_wait(store, fts(12))

		this.health_bar.hidden = true
		this.vis.bans = U.flag_set(this.vis.bans, bor(F_RANGED, F_MOD))
	end

	local function y_fight()
		this.health_bar.hidden = false
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
		this.tween.disabled = false
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		while true do
			if this.health.hp <= this.hp_threshold then
				break
			end

			if this.unit.is_stunned then
				U.animation_start(this, "idle", nil, store.tick_ts, -1)
				coroutine.yield()
			else
				local function break_fn(store, this)
					return this.health.hp <= this.hp_threshold
				end

				if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, break_fn) then
				-- block empty
				else
					coroutine.yield()
				end
			end
		end

		U.unblock_all(store, this)
		SU.remove_modifiers(store, this)

		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.health_bar.hidden = true
		this.vis.bans = U.flag_set(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
	end

	local function y_death()
		this.ui.can_select = false

		S:queue(this.sound_events.death)
		U.y_animation_play(this, "death", true, store.tick_ts)
		U.y_wait(store, 0.5)
		U.y_animation_play(this, "deathEnd", true, store.tick_ts)

		local spider = E:create_entity("decal_s11_mactans")

		spider.pos_drop = v(this.pos.x + 8, this.pos.y - 15)
		spider.pos_start = v(spider.pos_drop.x, 1100)
		spider.pos.x, spider.pos.y = spider.pos_start.x, spider.pos_start.y

		queue_insert(store, spider)

		local shadow = E:create_entity("decal_mactans_shadow")

		shadow.pos.x, shadow.pos.y = spider.pos_drop.x, spider.pos_drop.y + 16

		queue_insert(store, shadow)

		shadow.tween.ts = store.tick_ts

		local thread = E:create_entity("decal_mactans_thread")

		thread.pos = spider.pos

		queue_insert(store, thread)
		U.animation_start(spider, "falling", nil, store.tick_ts, true)
		S:queue("ElvesFinalBossSpiderIn", {
			delay = spider.drop_duration - fts(25)
		})
		U.y_ease_key(store, spider.pos, "y", spider.pos_start.y, spider.pos_drop.y, spider.drop_duration, "quad-in")
		S:queue("ElvesFinalBossWebspin")
		U.y_animation_play(spider, "startingWeb", nil, store.tick_ts)
		U.animation_start(spider, "web", nil, store.tick_ts, true)

		local webbing = E:create_entity("decal_mactans_webbing")

		webbing.pos = v(spider.pos.x, spider.pos.y + 40)

		for i, sprite in ipairs(webbing.render.sprites) do
			sprite.ts = store.tick_ts + (i - 1) * fts(5)
		end

		queue_insert(store, webbing)
		U.y_wait(store, fts(13))

		local cocoon = E:create_entity("decal_s11_drow_queen_cocoon")

		cocoon.pos = spider.pos
		cocoon.render.sprites[1].ts = store.tick_ts

		queue_insert(store, cocoon)
		U.y_wait(store, fts(25))

		this.tween.ts = store.tick_ts
		this.tween.disabled = nil
		this.tween.props[1].disabled = nil
		this.tween.props[2].disabled = true
		this.tween.props[3].disabled = true

		U.y_wait(store, fts(41))
		queue_remove(store, webbing)
		U.animation_start(spider, "malicia_grab", nil, store.tick_ts, false)
		U.y_wait(store, fts(13))
		U.y_ease_key(store, cocoon.render.sprites[1].offset, "y", 15, 8, fts(5), "quad-in")
		U.y_animation_wait(spider)
		U.animation_start(cocoon, "netAnim", nil, store.tick_ts, true)

		cocoon.render.sprites[1].offset.y = -4
		shadow.tween.ts = store.tick_ts
		shadow.tween.reverse = true

		S:queue("ElvesFinalBossSpiderOut")
		U.animation_start(spider, "malicia_climbUp", nil, store.tick_ts, true)
		U.y_ease_key(store, spider.pos, "y", spider.pos_drop.y, spider.pos_start.y, spider.drop_duration)
	end

	this.health.hp_max = this.health.hp_max_rounds[store.level_difficulty][1]
	this.health.hp = this.health.hp_max
	this.pos.x, this.pos.y = this.pos_sitting.x, this.pos_sitting.y
	this.nav_path.pi = this.cast_pi
	this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {this.cast_pi})[1][3]
	this.ui.click_rect = this.ui.click_rect_sitting
	this.ui.can_select = false

	U.animation_start(this, "sittingIdle", false, store.tick_ts, true)

	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "prebattle"
	this.phase_signal = nil

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
	end

	this.phase_signal = nil
	this.phase = "sitting"

	while true do
		if this.phase_signal == "summoner" then
			this.phase_signal = nil

			U.y_animation_play(this, "throneCast", false, store.tick_ts, 1, sid_body)
		elseif this.phase_signal == "taunt" then
			this.phase_signal = nil

			SU.y_show_taunt_set(store, this.taunts, this.phase)
		elseif this.phase_signal == "powers" then
			this.phase_signal = nil

			U.y_animation_play(this, "standUp", false, store.tick_ts, 1, sid_body)

			this.ui.click_rect = this.ui.click_rect_default
			this.phase = "flying"

			y_fly(this.pos, this.pos_casting, this.fly_speed_normal, this.cast_pi)

			this.phase = "casting"
			this.ui.can_select = true

			local __, __, shield_hp, pow_cooldown_min, pow_cooldown_max, pow_chances, shield_duration = unpack(this.phase_params, 1, 7)

			y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)

			this.phase = "flying"
			this.ui.can_select = false

			y_fly(this.pos, this.pos_sitting, this.fly_speed_return, this.cast_pi)
			U.y_animation_play(this, "sitDown", false, store.tick_ts)

			this.phase = "sitting"
			this.ui.click_rect = this.ui.click_rect_sitting
		elseif this.phase_signal == "fight" then
			this.ui.click_rect = this.ui.click_rect_default
			this.phase = "flying"

			y_fly(this.pos, this.pos_casting, this.fly_speed_normal, this.cast_pi)

			this.phase = "casting"
			this.ui.can_select = true

			for i, fight_round in ipairs(this.fight_rounds) do
				local shield_hp, pow_cooldown_min, pow_cooldown_max, pow_chances, shield_duration, packs, pack_pis, fight_pi, tower_set = unpack(fight_round, 1, 9)

				y_power(shield_hp, shield_duration, pow_cooldown_min, pow_chances)

				this.hp = this.health.hp_max_rounds[store.level_difficulty][i]
				this.hp_threshold = this.health.hp_max_rounds[store.level_difficulty][i + 1] or 0

				block_tower_ids(this.tower_block_sets[tower_set])

				this.megaspawner.manual_wave = "BOSSFIGHT0"

				for i, pack_id in ipairs(packs) do
					this.portals[i].pack = {
						pi = pack_pis[i],
						waves = this.portal_packs[pack_id]
					}
					this.portals[i].pack_finished = nil
				end

				this.phase = "flying"
				this.ui.can_select = false

				y_fly(this.pos, this.pos_fighting, this.fly_speed_fight, fight_pi)

				this.ui.can_select = true
				this.phase = "fighting"
				this.health_bar.hidden = nil

				y_fight()

				this.health.hp = this.hp_threshold
				this.health_bar.hidden = true

				if this.health.hp > 0 then
					this.megaspawner.manual_wave = "BOSSRETURN0"
					this.health.dead = false
				else
					-- this.enemy.can_do_magic = false
					this.shield.health.hp = 0

					block_all_towers()

					this.megaspawner.interrupt = true

					for _, portal in pairs(this.portals) do
						portal.pack = nil
					end

					store.wave_spawn_thread = nil
					store.waves_finished = true
					store.waves_active = {}

					LU.kill_all_enemies(store, true)
				end

				this.phase = "flying"
				this.ui.can_select = false

				y_fly(this.pos, this.pos_casting, this.hp == 0 and this.fly_speed_return_die or this.fly_speed_return, this.cast_pi)

				this.phase = "casting"
				this.ui.can_select = true
			end

			this.phase = "mactans"

			S:stop_all()
			y_death()

			this.phase = "dead"

			signal.emit("boss-killed", this)

			return
		end

		coroutine.yield()
	end
end

scripts.decal_drow_queen_shield = {}

function scripts.decal_drow_queen_shield.update(this, store)
	while true do
		while this.health.hp <= 0 do
			coroutine.yield()
		end

		this.tween.reverse = false
		this.tween.ts = store.tick_ts
		this.tween.disabled = nil
		this.health_bar.hidden = false

		while this.health.hp > 0 do
			coroutine.yield()

			this.health.hp = this.health.hp - this.shield_dps * store.tick_length
		end

		this.health_bar.hidden = true
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		local fx = E:create_entity("fx_drow_queen_shield_break")

		fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end
end

scripts.eb_spider = {}

function scripts.eb_spider.get_info(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = b.bullet.damage_min,
		damage_max = b.bullet.damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_spider.update(this, store)
	local boss_rounds = store.level.boss_rounds
	local round_idx = 1
	local hp_max_rounds = this.health.hp_max_rounds[store.level_difficulty]

	this.health.hp_max = hp_max_rounds[round_idx]
	this.health.hp = this.health.hp_max

	local shadow = E:create_entity("decal_shadow_eb_spider")

	queue_insert(store, shadow)

	local function y_jump_out()
		U.unblock_all(store, this)
		SU.remove_modifiers(store, this)

		this.vis.bans = U.flag_set(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))
		this.health_bar.hidden = true
		shadow.pos = v(this.pos.x, this.pos.y)

		U.animation_start(this, "jump", nil, store.tick_ts, false)
		U.y_wait(store, fts(10))

		shadow.tween.reverse = true
		shadow.tween.ts = store.tick_ts

		U.y_animation_wait(this)
		S:queue("ElvesFinalBossJump")

		local smoke = E:create_entity("fx_eb_spider_jump_smoke")

		smoke.pos.x, smoke.pos.y = this.pos.x, this.pos.y
		smoke.render.sprites[1].ts = store.tick_ts

		queue_insert(store, smoke)
		U.animation_start(this, "flyingUp", nil, store.tick_ts, false)

		for _, s in pairs(this.render.sprites) do
			s.sort_y = this.pos.y
		end

		U.y_ease_key(store, this.pos, "y", this.pos.y, math.min(this.pos.y + REF_H, IN_GAME_Y_MAX - 1), 1, "quad-in")
	end

	local function y_jump_in(round_idx)
		this.megaspawner.manual_wave = string.format("BOSS%i", round_idx - 1)
		this.hp_threshold = hp_max_rounds[round_idx + 1] or 0

		local round = boss_rounds[round_idx]
		local pis = P:get_connected_paths(round.pi)
		local nodes = P:nearest_nodes(round.pos.x, round.pos.y, pis, nil, true)
		local dest, dest_node

		if #nodes < 0 then
			log.error("eb_spider: could not find node near %s,%s in paths:%s", round.pos.x, round.pos.y, getdump(pis))

			return
		else
			dest_node = {
				spi = 1,
				dir = 1,
				pi = nodes[1][1],
				ni = nodes[1][3]
			}
		end

		local dest = P:node_pos(dest_node)

		this.nav_path.pi = dest_node.pi
		this.nav_path.ni = dest_node.ni + 1
		this.pos.x, this.pos.y = dest.x, REF_H + 20

		for _, s in pairs(this.render.sprites) do
			s.sort_y = dest.y
		end

		shadow.tween.reverse = nil
		shadow.tween.ts = store.tick_ts
		shadow.pos.x, shadow.pos.y = dest.x, dest.y

		U.animation_start(this, "flyingDown", nil, store.tick_ts, false)

		local landing = false

		U.y_ease_key(store, this.pos, "y", this.pos.y, dest.y, 0.6, "quad-out", function(dt, ph)
			if dt >= 0.5 and not landing then
				landing = true

				S:queue("ElvesFinalBossSpiderGoddessFall")
				U.animation_start(this, "land", nil, store.tick_ts, false)
			end
		end)

		for _, s in pairs(this.render.sprites) do
			s.sort_y = nil
		end

		U.y_animation_wait(this)

		shadow.pos = this.pos
		this.health_bar.hidden = nil
		this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT))

		local aura = E:create_entity("aura_eb_spider_path_web")

		aura.pos.x, aura.pos.y = dest.x, dest.y
		aura.aura.ts = store.tick_ts
		aura.eggs = store.level.mactans_eggs
		aura.qty_per_egg = round.qty_per_egg
		aura.pi = dest_node.pi
		aura.ni = dest_node.ni

		queue_insert(store, aura)
	end

	local function y_death()
		this.health_bar.hidden = true

		S:queue(this.sound_events.death)
		U.y_animation_play(this, "death_first_start", nil, store.tick_ts)
		SU.y_show_taunt_set(store, this.taunts, "death", 1, this.pos, 2, false)
		U.y_animation_play(this, "death_first_loop", nil, store.tick_ts, 10)
		U.animation_start(this, "death_second_start", nil, store.tick_ts, false)
		U.y_wait(store, fts(6))

		local rays = E:create_entity("decal_eb_spider_death_second_rays")

		rays.pos.x, rays.pos.y = this.pos.x, this.pos.y + 68
		rays.tween.ts = store.tick_ts

		queue_insert(store, rays)
		U.y_animation_wait(this)
		U.animation_start(this, "death_second_loop", nil, store.tick_ts, true)
		U.y_wait(store, fts(7) + 2)

		local circle = E:create_entity("decal_eb_spider_death_white_circle")

		circle.pos.x, circle.pos.y = rays.pos.x, rays.pos.y
		circle.tween.ts = store.tick_ts

		queue_insert(store, circle)
		U.y_wait(store, 0.5)
	end

	local function y_destroy_tower()
		local a = this.timed_attacks.list[3]
		local towers = table.filter(store.towers, function(_, e)
			return e.tower.can_be_mod and not e.tower.blocked and not table.contains(a.excluded_templates, e.template_name) and math.abs(e.pos.x - this.pos.x) > 45 and U.is_inside_ellipse(e.pos, this.pos, a.max_range)
		end)

		if #towers < 1 then
			return
		end

		local tower = table.random(towers)

		S:queue(a.sound)

		local af = tower.pos.x < this.pos.x

		U.y_animation_play(this, a.animations[1], af, store.tick_ts)
		U.y_animation_play(this, a.animations[2], af, store.tick_ts, 2)
		U.animation_start(this, a.animations[3], af, store.tick_ts, false)
		U.y_wait(store, a.shoot_time)

		local o = a.bullet_start_offset[1]
		local b = E:create_entity(a.bullet)

		b.bullet.from = v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
		b.bullet.to = v(tower.pos.x, tower.pos.y + 8)
		b.bullet.source_id = this.id
		b.bullet.target_id = tower.id
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
		U.y_animation_wait(this)
	end

	local function reset_cooldowns()
		this.ranged.attacks[1].ts = store.tick_ts
		this.timed_attacks.list[1].ts = store.tick_ts
		this.timed_attacks.list[2].ts = store.tick_ts
	end

	local function ready_to_jump()
		return this.health.hp > 0 and this.health.hp <= this.hp_threshold
	end

	local function ready_to_long_range()
		local a = this.timed_attacks.list[1]

		return store.tick_ts - a.ts > a.cooldown
	end

	local function ready_to_block()
		local a = this.timed_attacks.list[2]

		return store.tick_ts - a.ts > a.cooldown and this.enemy.can_do_magic
	end

	local function break_fn()
		-- return ready_to_jump() or ready_to_long_range() or ready_to_block() or this.unit.is_stunned
		return ready_to_jump() or ready_to_block() or this.unit.is_stunned
	end

	this.health_bar.hidden = true
	shadow.pos = this.pos
	shadow.tween.reverse = nil
	shadow.tween.ts = 0

	local fx = E:create_entity("fx_eb_spider_spawn")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y - 1

	queue_insert(store, fx)
	U.y_wait(store, fts(45))

	fx.tween.disabled = nil
	fx.tween.ts = store.tick_ts

	U.animation_start(this, "shoutOurs", nil, store.tick_ts, false)
	U.y_wait(store, fts(6))
	SU.y_show_taunt_set(store, this.taunts, "intro", 1, v(this.pos.x, this.pos.y - 30), fts(48), true)
	y_jump_out()
	U.y_wait(store, 1)
	y_jump_in(round_idx)
	reset_cooldowns()

	this.phase = "fight"

	local cont, blocker, ranged

	::label_344_0::

	while true do
		if this.health.dead then
			this.phase = "death-animation"
			this.megaspawner.interrupt = true

			LU.kill_all_enemies(store, true)
			S:stop_all()
			y_death()
			signal.emit("boss-killed", this)

			this.phase = "dead"

			LU.kill_all_enemies(store, true)

			return
		end

		if ready_to_jump() then
			y_destroy_tower()

			round_idx = round_idx + 1

			y_jump_out()
			U.y_wait(store, 1)
			y_jump_in(round_idx)
		elseif this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
			coroutine.yield()
		else
			if ready_to_long_range() then
				local a = this.timed_attacks.list[1]
				local targets = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not targets then
					SU.delay_attack(store, a, 1)
				else
					local target = table.random(targets)

					a.ts = store.tick_ts

					SU.y_enemy_do_ranged_attack(store, this, target, a)

					a.ts = store.tick_ts
				end
			end

			if ready_to_block() then
				local a = this.timed_attacks.list[2]

				U.animation_start(this, "blockTower", nil, store.tick_ts, false)
				U.y_wait(store, a.hit_time)
				S:queue(a.hit_sound)

				local towers = table.filter(store.towers, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked
				end)
				local sel_towers = {}

				while #towers > 0 and #sel_towers < a.tower_count[round_idx] + 1 do
					local t, i = table.random(towers)

					table.insert(sel_towers, t)
					table.remove(towers, i)
				end

				for _, e in pairs(sel_towers) do
					local m = E:create_entity(a.mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = e.id
					m.pos.x, m.pos.y = e.pos.x, e.pos.y

					queue_insert(store, m)
				end

				-- signal.emit("block-random-power", a.power_block_duration, "eb_spider")
				-- U.y_animation_wait(this)
				a.ts = store.tick_ts

				goto label_344_0
			end

			cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_344_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not break_fn() do
						if not SU.y_enemy_range_attacks(store, this, blocker) then
							goto label_344_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_bram = {}

function scripts.eb_bram.get_info(this)
	return {
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = this.melee.attacks[1].damage_min,
		damage_max = this.melee.attacks[1].damage_max,
		armor = this.health.armor,
		magic_armor = this.health.magic_armor,
		lives = this.enemy.lives_cost
	}
end

function scripts.eb_bram.update(this, store)
	local ac = this.timed_attacks.list[1]

	local function ready_to_convert()
		return store.tick_ts - ac.ts > ac.cooldown and P:nodes_to_defend_point(this.nav_path) > ac.nodes_limit
	end

	this.phase_signal = nil

	while not this.phase_signal do
		coroutine.yield()
	end

	this.phase = "welcome"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "sitting"
	this.phase_signal = nil

	while not this.phase_signal do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)

		if U.y_wait(store, delay, function()
			return this.phase_signal ~= nil
		end) then
			break
		end

		SU.y_show_taunt_set(store, this.taunts, this.phase, nil, nil, nil, true)
	end

	this.phase = "prebattle"

	U.y_wait(store, 1.5)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 1, nil, 3, true)
	SU.y_show_taunt_set(store, this.taunts, this.phase, 2, nil, 3, true)

	this.phase = "battle"
	this.health_bar.hidden = nil
	this.vis.bans = U.flag_clear(this.vis.bans, bor(F_BLOCK, F_RANGED, F_MOD))

	U.y_animation_play(this, "raise", nil, store.tick_ts)

	::label_358_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_convert() then
				local a = ac
				local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return table.contains(a.allowed_templates, e.template_name)
				end)

				if not targets or #targets < a.min_count then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)

					while store.tick_ts - a.ts < a.cast_time do
						if this.health.dead or this.unit.is_stunned then
							goto label_358_0
						end

						coroutine.yield()
					end

					local decal = E:create_entity(a.hit_decal)

					decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
					decal.tween.ts = store.tick_ts

					queue_insert(store, decal)

					for i, target in ipairs(targets) do
						if i > a.max_count then
							break
						end

						local e = E:create_entity(a.mod)

						e.modifier.target_id = target.id

						queue_insert(store, e)
					end

					SU.y_enemy_animation_wait(this)

					goto label_358_0
				end
			end

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, function(this, store)
				return ready_to_convert()
			end)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_358_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_convert() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_358_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.mod_bram_slap = {}

function scripts.mod_bram_slap.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		target.vis.bans = F_ALL

		SU.stun_inc(target)
	end
end

function scripts.mod_bram_slap.update(this, store)
	local target = store.entities[this.modifier.target_id]
	local source = store.entities[this.modifier.source_id]

	if not target or not source then
		queue_remove(store, this)

		return
	end

	local af = source.pos.x > target.pos.x

	this.pos.x, this.pos.y = target.pos.x, target.pos.y

	local d = E:create_entity("damage")

	d.damage_type = DAMAGE_EAT
	d.source_id = this.id
	d.target_id = target.id

	queue_damage(store, d)

	local es = E:create_entity("decal_bram_enemy_clone")

	es.pos.x, es.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	es.render = U.render_clone(target.render)
	es.render.sprites[1].anchor = this.custom_anchors[target.template_name] or this.custom_anchors.default
	es.tween.disabled = nil
	es.tween.ts = store.tick_ts

	local dx, dy = V.rotate(math.random(20, 45) * math.pi / 180, math.random(180, 240), 0)

	dx = (af and -1 or 1) * dx
	es.tween.props[2].keys[2][2].x, es.tween.props[2].keys[2][2].y = dx, dy
	es.tween.props[3].keys[2][2] = (af and -1 or 1) * math.random(300, 400) * math.pi / 180

	queue_insert(store, es)
	queue_remove(store, this)
end

scripts.eb_bajnimen = {}

function scripts.eb_bajnimen.on_damage(this, store, damage)
	log.debug("  EB_BAJNIMEN ON_DAMAGE: %s", damage.value)

	local ar = this.timed_attacks.list[2]

	if this.health.dead or ar.current_step > #ar.steps then
		return true
	end

	if ar.active then
		return false
	end

	local pd = U.predict_damage(this, damage)

	if ar.steps[ar.current_step].hp_threshold > (this.health.hp - pd) / this.health.hp_max then
		ar.active = true
	end

	return true
end

function scripts.eb_bajnimen.update(this, store)
	local as = this.timed_attacks.list[1]
	local ar = this.timed_attacks.list[2]
	local cont, blocker, ranged

	local function spawn_meteor(pi, spi, ni)
		spi = spi or math.random(1, 3)

		local pos = P:node_pos(pi, spi, ni)

		pos.x = pos.x + math.random(-4, 4)
		pos.y = pos.y + math.random(-5, 5)

		local b = E:create_entity(as.bullet)

		b.bullet.from = v(pos.x + math.random(190, 160), pos.y + REF_H)
		b.bullet.to = pos
		b.pos = V.vclone(b.bullet.from)

		queue_insert(store, b)
	end

	local function ready_to_storm()
		return store.tick_ts - as.ts > as.cooldown
	end

	local function ready_to_regen()
		return ar.active
	end

	local function break_fn()
		return ready_to_storm() or ready_to_regen() or this.unit.is_stunned
	end

	as.ts = store.tick_ts
	ar.ts = store.tick_ts

	::label_366_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_storm() then
				local a = as
				local hero = store.main_hero
				local target

				if hero and not hero.health.dead and band(hero.vis.bans, F_RANGED) == 0 then
					target = hero
				else
					target = U.find_random_target(store.entities, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)
				end

				if not target then
					SU.delay_attack(store, a, 0.2)
				else
					a.ts = store.tick_ts

					S:queue(a.sound)
					U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
					U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

					local nearest = P:nearest_nodes(target.pos.x, target.pos.y)

					if #nearest > 0 then
						local pi, spi, ni = unpack(nearest[1])

						spawn_meteor(pi, spi, ni)

						local count = a.spread
						local sequence = {}

						for i = 1, count do
							sequence[i] = i
						end

						while #sequence > 0 do
							local i = table.remove(sequence, math.random(1, #sequence))
							local delay = U.frandom(0, 1 / count)

							U.y_wait(store, delay * 0.5)

							if P:is_node_valid(pi, ni + i) then
								spawn_meteor(pi, nil, ni + i)
							else
								spawn_meteor(pi, nil, ni - i)
							end

							U.y_wait(store, delay * 0.5)

							if P:is_node_valid(pi, ni - i) then
								spawn_meteor(pi, nil, ni - i)
							else
								spawn_meteor(pi, nil, ni + i)
							end
						end
					end

					if SU.y_enemy_wait(store, this, 1) then
					-- block empty
					else
						U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

						a.ts = store.tick_ts
					end

					goto label_366_0
				end
			end

			if ready_to_regen() then
				local a = ar
				local hp_heal = a.steps[a.current_step].hp_heal

				S:queue(a.sound)
				U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

				local prev_hit_offset = this.unit.hit_offset
				local prev_mod_offset = this.unit.mod_offset

				this.unit.hit_offset = a.hit_offset
				this.unit.mod_offset = a.mod_offset

				U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

				local start_ts, tick_ts = store.tick_ts, store.tick_ts - a.heal_every

				while store.tick_ts - start_ts <= a.duration do
					if store.tick_ts - tick_ts >= a.heal_every then
						tick_ts = tick_ts + a.heal_every
						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + hp_heal)
					end

					coroutine.yield()
				end

				U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

				this.unit.hit_offset = prev_hit_offset
				this.unit.mod_offset = prev_mod_offset
				a.current_step = a.current_step + 1
				a.active = false

				goto label_366_0
			end

			cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
			-- block empty
			else
				if ranged then
					if not SU.can_range_soldier(store, this, ranged) then
						goto label_366_0
					end

					if not SU.y_enemy_range_attacks(store, this, ranged) then
						goto label_366_0
					end
				elseif blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_366_0
					end

					if not SU.can_melee_blocker(store, this, blocker) then
						coroutine.yield()

						goto label_366_0
					end

					if not SU.y_enemy_melee_attacks(store, this, blocker) then
						goto label_366_0
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_balrog = {}

function scripts.eb_balrog.update(this, store)
	local at = this.timed_attacks.list[1]
	local cont, blocker, ranged
	local stage_hero = LU.list_entities(store.soldiers, "hero_bolverk")[1]

	local function ready_to_taint()
		return store.tick_ts - at.ts > at.cooldown
	end

	at.ts = store.tick_ts

	::label_371_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)
			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)
			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_taint() then
				local a = at
				local hero = store.main_hero
				local target

				if hero and not hero.health.dead and U.flags_pass(hero.vis, at) then
					target = hero
				elseif stage_hero and not stage_hero.health.dead and U.flags_pass(stage_hero.vis, at) then
					target = stage_hero
				else
					target = U.find_random_target(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
				end

				if not target then
					SU.delay_attack(store, at, 0.2)
				else
					local nearest = P:nearest_nodes(target.pos.x, target.pos.y)

					if #nearest < 1 then
						SU.delay_attack(store, at, 0.2)
					else
						local pi, spi, ni = unpack(nearest[1])
						local shoot_dest = P:node_pos(pi, 1, ni)

						S:queue(a.sound)

						local an, af, ai = U.animation_name_facing_point(this, a.animation, shoot_dest)

						U.animation_start(this, a.animation, af, store.tick_ts, false)
						U.y_wait(store, a.shoot_time)

						local o = a.bullet_start_offset[1]
						local b = E:create_entity(a.bullet)

						b.bullet.to = shoot_dest
						b.bullet.from = v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.source_id = this.id
						b.pos = V.vclone(b.bullet.from)

						queue_insert(store, b)

						a.ts = store.tick_ts

						U.y_animation_wait(this)

						goto label_371_0
					end
				end
			end

			local cont, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_taint)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_371_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_taint() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_371_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_jack = {}

function scripts.eb_jack.update(this, store)
	local ra = this.ranged.attacks[1]
	local last_quit_hp = this.health.hp
	local quit_threshold = this.health.hp_max * 0.2

	local function quit()
		return last_quit_hp - this.health.hp >= quit_threshold
	end

	::label_25_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)
			LU.kill_all_enemies(store, true)

			store.boss_killed = true

			return
		end

		if last_quit_hp - this.health.hp >= quit_threshold then
			U.unblock_all(store, this)

			this.vis.flags = bor(this.vis.flags, F_BLOCK)

			SU.remove_modifiers(store, this)
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			S:queue("HWHeadlessHorsemanLaugh")

			this.health.immune_to = F_ALL

			U.y_animation_wait(this)

			local ni = km.clamp(P:get_start_node(this.nav_path.pi), P:get_end_node(this.nav_path.pi), this.nav_path.ni + 11)
			local dest = P:node_pos(this.nav_path.pi, this.nav_path.spi, ni)

			this.pos.x, this.pos.y = dest.x, dest.y

			U.y_animation_play(this, "rise", nil, store.tick_ts, 1)

			this.health.immune_to = F_NONE
			this.vis.flags = U.flag_clear(this.vis.flags, F_BLOCK)
			last_quit_hp = this.health.hp
			this.nav_path.ni = ni
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, quit)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_25_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not quit() do
						if ranged then
							SU.y_enemy_range_attacks(store, this, ranged)
						end

						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_25_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and not quit() do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_25_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.eb_jack_spawner_aura = {}

function scripts.eb_jack_spawner_aura.update(this, store)
	local source = store.entities[this.aura.source_id]

	if not source or source.health.dead then
		queue_remove(store, this)

		return
	end

	local a = this.aura

	while true do
		if store.tick_ts - a.ts < a.cycle_time then
			goto continue
		end

		if not source or source.health.dead then
			queue_remove(store, this)

			return
		end

		do
			local pi = source.nav_path.pi
			local ni = source.nav_path.ni
			local spawn_count = math.random(this.min_spawn_count, this.max_spawn_count)

			for i = 1, spawn_count do
				local e = E:create_entity(this.creeps[math.random(1, #this.creeps)])

				e.nav_path.pi = pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = km.clamp(P:get_start_node(pi), P:get_end_node(pi), ni + math.random(-10, 10))
				e.enemy.gold = 0

				queue_insert(store, e)
			end

			a.ts = store.tick_ts
		end

		::continue::

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_krdove_elephant_cannibal = {}
function scripts.mod_krdove_elephant_cannibal.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	U.heal(target, this.heal_amount)

	local s = this.render.sprites[1]

	s.ts = store.tick_ts

	s.name = s.size_names[target.unit.size]

	if target.unit.mod_offset then
		s.offset.x = target.unit.mod_offset.x
		s.offset.y = target.unit.mod_offset.y
	end

	if target.template_name == "krdove_eb_elephant_cannibal" then
		return false
	end

	return true
end

function scripts.mod_krdove_elephant_cannibal.update(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		queue_remove(store, this)

		return
	end

	SU.enemy_scale_mul(store, target, this.scale_factor, this.scale_delay)

	while true do
		local target = store.entities[this.modifier.target_id]

		if not target or target.health.dead then
			break
		end

		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.krdove_eb_elephant_cannibal = {}

function scripts.krdove_eb_elephant_cannibal.update(this, store)
	local a = this.timed_attacks.list[1]

	a.ts = store.tick_ts

	local function ready_to_heal()
		return enemy_ready_to_magic_attack(this, store, a)
	end

	::label_95_0::

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)
			LU.kill_all_enemies(store, true)
			store.force_next_wave = true
			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_heal() then
				local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
					return not U.has_modifier(store, e, "mod_krdove_elephant_cannibal")
				end)

				if not targets then
					SU.delay_attack(store, a, 0.5)
				else
					a.ts = store.tick_ts

					U.animation_start(this, a.animation, nil, store.tick_ts, false)
					S:queue(a.sound)

					if SU.y_enemy_wait(store, this, a.cast_time) then
						goto label_95_0
					end

					local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans, function(e)
						return not U.has_modifier(store, e, "mod_krdove_elephant_cannibal")
					end)

					if targets then
						for _, target in ipairs(targets) do
							local m = E:create_entity(a.mod)

							m.modifier.source_id = this.id
							m.modifier.target_id = target.id

							queue_insert(store, m)
						end
					end

					U.y_animation_wait(this)
				end
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, ready_to_heal, ready_to_heal) then
			-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.boss_corrupted_denas = {}

function scripts.boss_corrupted_denas.update(this, store, script)
	local path_pi, path_spi, path_ni
	local spawn_entities_attack = this.timed_attacks.list[1]
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {4}, {1})

	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])
	end

	this.nav_path.pi = path_pi
	this.nav_path.spi = path_spi
	this.nav_path.ni = path_ni

	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level111_spawner" then
			megaspawner_boss = value
		end
	end

	local current_life_threshold_stun_index = 1
	local next_life_threshold_stun = this.life_threshold_stun.life_percentage[1]
	local cult_leader = table.filter(store.entities, function(k, v)
		return v.template_name == this.cult_leader_template_name
	end)[1]

	local function check_life_threshold_stun()
		if next_life_threshold_stun and this.health.hp * 100 / this.health.hp_max <= next_life_threshold_stun then
			return true
		end

		return false
	end

	local function break_fn()
		if store.tick_ts - spawn_entities_attack.ts >= spawn_entities_attack.cooldown then
			return true
		end

		if this.cage_applied then
			return true
		end

		return check_life_threshold_stun()
	end

	local function y_on_death()
		LU.kill_all_enemies(store, true)
		S:stop_all()

		megaspawner_boss.interrupt = true

		S:queue(this.sound_transform_in)
		U.y_animation_play(this, "stunin", nil, store.tick_ts)
		U.animation_start(this, "stunloop", nil, store.tick_ts, true)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)
	end

	this.vis._flags = this.vis.flags
	this.vis._bans = this.vis.bans
	this.vis.flags = bor(F_ENEMY, F_BOSS)
	this.vis.bans = bor(F_RANGED, F_BLOCK)
	this.render.sprites[1].flip_x = true

	U.y_animation_play(this, "spawn", nil, store.tick_ts)

	local start_ts = store.tick_ts

	while store.tick_ts - start_ts < 10 do
		U.y_animation_play(this, "cagein", nil, store.tick_ts)
		U.y_animation_play(this, "cageloop", nil, store.tick_ts)
		U.y_animation_play(this, "cageout", nil, store.tick_ts)
		U.y_wait(store, 3.5)
	end

	spawn_entities_attack.ts = store.tick_ts

	signal.emit("boss_fight_start", this)

	megaspawner_boss.manual_wave = "BOSS"
	this.vis.flags = this.vis._flags
	this.vis.bans = this.vis._bans

	::label_1216_0::

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned and not this.cage_applied then
			SU.y_enemy_stun(store, this)
		else
			if this.cage_applied then
				this.cage_applied = nil

				U.y_animation_play(this, "cagein", nil, store.tick_ts)
				U.animation_start(this, "cageloop", nil, store.tick_ts, true)

				while true do
					if this.unit.stun_count <= 0 then
						break
					end

					coroutine.yield()
				end

				U.y_animation_play(this, "cageout", nil, store.tick_ts)
			end

			if check_life_threshold_stun() then
				S:queue(this.sound_transform_in)
				U.y_animation_play(this, "stunin", nil, store.tick_ts)

				cult_leader.denas = this

				U.animation_start(this, "stunloop", nil, store.tick_ts, true)

				local stun_ts = store.tick_ts

				while store.tick_ts - stun_ts < this.life_threshold_stun.stun_duration do
					if this.health.dead then
						y_on_death()

						return
					end

					coroutine.yield()
				end

				S:queue(this.sound_transform_out)
				U.y_animation_play(this, "stunout", nil, store.tick_ts)

				current_life_threshold_stun_index = current_life_threshold_stun_index + 1
				next_life_threshold_stun = (not (current_life_threshold_stun_index > #this.life_threshold_stun.life_percentage) or nil) and this.life_threshold_stun.life_percentage[current_life_threshold_stun_index]
				spawn_entities_attack.ts = store.tick_ts
			end

			if store.tick_ts - spawn_entities_attack.ts >= spawn_entities_attack.cooldown then
				local start_ts = store.tick_ts

				this.available_nodes = {}

				local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, spawn_entities_attack.min_range, spawn_entities_attack.max_range, nil, nil, nil, {1, 2, 3})

				nodes = table.random_order(nodes)

				for j = 1, #nodes do
					local is_far = true

					for k = 1, #this.available_nodes do
						local distance = V.dist(nodes[j].x, nodes[j].y, this.available_nodes[k].x, this.available_nodes[k].y)

						if distance < spawn_entities_attack.distance_between_entities then
							is_far = false

							break
						end
					end

					if is_far then
						table.insert(this.available_nodes, nodes[j])

						if #this.available_nodes >= spawn_entities_attack.entities_amount then
							break
						end
					end
				end

				U.animation_start(this, spawn_entities_attack.animation, nil, store.tick_ts)
				U.y_wait(store, fts(28))

				for i = 1, #this.available_nodes do
					local b = E:create_entity(spawn_entities_attack.bullet)
					local bullet_start_offset = spawn_entities_attack.bullet_start_offset

					b.pos.x, b.pos.y = this.pos.x + bullet_start_offset.x, this.pos.y + bullet_start_offset.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = this.available_nodes[i]
					b.bullet.source_id = this.id

					queue_insert(store, b)
					U.y_wait(store, spawn_entities_attack.delay_between)
				end

				U.y_animation_wait(this)
				U.y_wait(store, spawn_entities_attack.idle_time)

				spawn_entities_attack.ts = start_ts
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, nil, break_fn)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_1216_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_1216_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_1216_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.bullet_boss_corrupted_denas_spawn_entities = {}

function scripts.bullet_boss_corrupted_denas_spawn_entities.update(this, store, script)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y
		hp.spawn_from_bullet = true

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		if this.path_to_spawn then
			hp.path_to_spawn = this.path_to_spawn
		end

		queue_insert(store, hp)
		signal.emit("wave-notification", "icon", "enemy_glareling")
	end

	queue_remove(store, this)
end

scripts.controller_stage_15_cult_leader_tower = {}

function scripts.controller_stage_15_cult_leader_tower.update(this, store)
	local last_wave_processed = 0
	local last_attack_ts = store.tick_ts
	local attack_cd, time_to_leave_after_attack

	U.animation_start_group(this, "idlenothing", nil, store.tick_ts, true, "layers")

	this.boss_fight_started = false
	this.soldiers_grabbed = 0

	while true do
		if store.wave_group_number == 0 then
		-- block empty
		else
			if store.wave_group_number ~= last_wave_processed then
				last_wave_processed = store.wave_group_number
				attack_cd = this.config_per_wave[store.wave_group_number].tentacle_cd

				if last_wave_processed == 1 then
					last_attack_ts = store.tick_ts
				end
			end

			if this.transform_out then
				this.transform_out = nil

				U.y_wait(store, 2)
				signal.emit("show-curtains")
				signal.emit("pan-zoom-camera", 2, {
					x = 680,
					y = 860
				}, 2)
				signal.emit("hide-gui")
				signal.emit("start-cinematic")
				U.y_wait(store, 2)
				S:queue("Stage15MydriasEnter")
				U.y_animation_play_group(this, "enter", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				signal.emit("show-balloon_tutorial", "LV15_CULTIST03", false)
				U.y_wait(store, 4)
				signal.emit("show-balloon_tutorial", "LV15_CULTIST04", false)
				U.y_wait(store, 4)
				S:queue("Stage15MutatedMydriasEnter")
				U.y_animation_play_group(this, "transform", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "transformloop", nil, store.tick_ts, true, "layers")
				U.y_animation_play_group(this, "transform2", nil, store.tick_ts, 1, "layers")
				U.y_wait(store, fts(60))

				local boss = E:create_entity(this.boss_to_spawn)

				queue_insert(store, boss)
				U.y_wait(store, 2)

				local denas = E:create_entity("soldier_reinforcement_stage_15_denas")

				denas.pos = v(560, 440)
				denas.nav_rally.center = V.vclone(denas.pos)
				denas.nav_rally.pos = V.vclone(denas.pos)
				denas.reinforcement.squad_id = denas.id

				queue_insert(store, denas)
				U.y_wait(store, 2)
				signal.emit("show-balloon_tutorial", "LV15_DENAS01", false)
				U.y_wait(store, 4)
				S:stop_group("MUSIC")
				S:queue("MusicBossFight_115")
				signal.emit("hide-curtains")
				signal.emit("pan-zoom-camera", 2, {
					x = 400,
					y = 400
				}, 1.3)
				signal.emit("show-gui")
				signal.emit("end-cinematic")

				this.boss_fight_started = true
			end

			if this.boss_fight_started and this.boss_dead then
				queue_remove(store, this)
			end

			if this.boss_fight_started and this.boss_teleport then
				this.boss_teleport = nil

				local soldiers = table.filter(store.entities, function(k, v)
					return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.bans) == 0 and band(v.vis.bans, this.flags) == 0
				end)
				local soldier_groups = {}

				local function closest_soldier_group(pos)
					local closest_group
					local closest_distance = 1e+99

					for _, soldier_group in ipairs(soldier_groups) do
						local soldier_distance = V.dist(soldier_group.pos.x, soldier_group.pos.y, pos.x, pos.y)

						if soldier_distance < closest_distance then
							closest_distance = soldier_distance
							closest_group = soldier_group
						end
					end

					return closest_group, closest_distance
				end

				if soldiers and #soldiers > 0 then
					for _, soldier in ipairs(soldiers) do
						local closest_group, closest_distance = closest_soldier_group(V.vclone(soldier.pos))

						if closest_group and closest_distance < this.distance_to_group then
							table.insert(closest_group.soldiers, soldier)
						else
							table.insert(soldier_groups, {
								soldiers = {soldier},
								pos = V.vclone(soldier.pos)
							})
						end
					end
				end

				if soldier_groups and #soldier_groups > 0 then
					for _, soldier_group in ipairs(soldier_groups) do
						local surrounded_soldier, surrounded_soldiers = U.find_entity_most_surrounded(soldier_group.soldiers)
						local aura = E:create_entity(this.aura)
						local nearest_nodes = P:nearest_nodes(surrounded_soldier.pos.x, surrounded_soldier.pos.y, nil, {1}, true)
						local pi, spi, ni = unpack(nearest_nodes[1])
						local npos = P:node_pos(pi, spi, ni)

						aura.pos = npos
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.mod_duration = this.config_per_wave[store.wave_group_number].tentacle_duration

						queue_insert(store, aura)
					end
				end
			end

			if not this.boss_fight_started and attack_cd <= store.tick_ts - last_attack_ts then
				U.y_animation_play_group(this, "enter", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				--y_show_taunt_set(store, this.taunts, "in_bossfight", false)
				U.y_wait(store, math.random(this.time_before_attack_min, this.time_before_attack_max))
				U.y_animation_wait_group(this, "layers")

				local start_ts = store.tick_ts

				U.y_animation_play_group(this, "attack", nil, store.tick_ts, 1, "layers")
				U.animation_start_group(this, "attackloop", nil, store.tick_ts, true, "layers")

				local soldiers = table.filter(store.entities, function(k, v)
					return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.bans) == 0 and band(v.vis.bans, this.flags) == 0
				end)
				local soldier_groups = {}

				local function closest_soldier_group(pos)
					local closest_group
					local closest_distance = 1e+99

					for _, soldier_group in ipairs(soldier_groups) do
						local soldier_distance = V.dist(soldier_group.pos.x, soldier_group.pos.y, pos.x, pos.y)

						if soldier_distance < closest_distance then
							closest_distance = soldier_distance
							closest_group = soldier_group
						end
					end

					return closest_group, closest_distance
				end

				if soldiers and #soldiers > 0 then
					for _, soldier in ipairs(soldiers) do
						local closest_group, closest_distance = closest_soldier_group(V.vclone(soldier.pos))

						if closest_group and closest_distance < this.distance_to_group then
							table.insert(closest_group.soldiers, soldier)
						else
							table.insert(soldier_groups, {
								soldiers = {soldier},
								pos = V.vclone(soldier.pos)
							})
						end
					end
				end

				if soldier_groups and #soldier_groups > 0 then
					soldier_groups = table.random_order(soldier_groups)
					soldier_groups = table.slice(soldier_groups, 1, this.config_per_wave[store.wave_group_number].targets_amount)

					for _, soldier_group in ipairs(soldier_groups) do
						local surrounded_soldier, surrounded_soldiers = U.find_entity_most_surrounded(soldier_group.soldiers)
						local aura = E:create_entity(this.aura)
						local nearest_nodes = P:nearest_nodes(surrounded_soldier.pos.x, surrounded_soldier.pos.y, nil, {1}, true)
						local pi, spi, ni = unpack(nearest_nodes[1])
						local npos = P:node_pos(pi, spi, ni)

						aura.pos = npos
						aura.aura.source_id = this.id
						aura.aura.ts = store.tick_ts
						aura.mod_duration = this.config_per_wave[store.wave_group_number].tentacle_duration

						queue_insert(store, aura)
					end
				end

				U.y_wait(store, fts(30))
				U.y_animation_wait_group(this, "layers")
				U.y_animation_play_group(this, "attackleave", nil, store.tick_ts, 1, "layers")

				last_attack_ts = start_ts

				U.animation_start_group(this, "idleup", nil, store.tick_ts, true, "layers")
				U.y_wait(store, math.random(this.time_to_leave_after_attack_min, this.time_to_leave_after_attack_max))
				U.y_animation_play_group(this, "leave", nil, store.tick_ts, 1, "layers")
			end
		end

		coroutine.yield()
	end
end

scripts.boss_cult_leader = {}

function scripts.boss_cult_leader.update(this, store)
	local path_pi, path_spi, path_ni
	local is_protected = true
	local current_life_threshold_teleport_index = 1
	local next_life_threshold_teleport = this.life_threshold_teleport.life_percentage[1]
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level115_spawner" then
			megaspawner_boss = value
		end
	end

	local cult_leader = table.filter(store.entities, function(k, v)
		return v.template_name == this.cult_leader_template_name
	end)[1]
	local glare = table.filter(store.entities, function(k, v)
		return v.template_name == this.glare_template_name
	end)[1]

	local function adjust_position(path)
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path}, {1})

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])
		end

		this.nav_path.pi = path_pi
		this.nav_path.spi = path_spi
		this.nav_path.ni = path_ni
	end

	local function aoe_attack(radius, damage_min, damage_max, damage_type, vis, bans, min_targets)
		local targets = table.filter(store.entities, function(_, e)
			return e.health and not e.health.dead and e.vis and band(e.vis.flags, bans) == 0 and band(e.vis.bans, vis) == 0 and U.is_inside_ellipse(e.pos, this.pos, radius)
		end)

		if targets and min_targets <= #targets then
			for _, target in pairs(targets) do
				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = target.id

				local dmin, dmax = damage_min, damage_max

				d.value = math.random(dmin, dmax)
				d.damage_type = damage_type

				queue_damage(store, d)
			end
		end
	end

	local function update_armor()
		if is_protected then
			this.health.armor = this.close_armor
			this.health.magic_armor = this.close_magic_armor
		else
			this.health.armor = this.open_armor
			this.health.magic_armor = this.open_magic_armor
		end
	end

	local function check_life_threshold_stun()
		if next_life_threshold_teleport and this.health.hp * 100 / this.health.hp_max <= next_life_threshold_teleport then
			return true
		end

		return false
	end

	local function break_fn()
		return check_life_threshold_stun()
	end

	local function y_on_death()
		LU.kill_all_enemies(store, true)
		S:stop_all()

		megaspawner_boss.interrupt = true

		S:queue(this.sound_transform_in)
		S:queue("Stage15MydriasDeath")
		U.y_animation_play(this, "deathstart", nil, store.tick_ts)
		U.animation_start(this, "deathloop", nil, store.tick_ts, true)
		U.y_wait(store, this.time_death)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)

		for _, t in pairs(store.entities) do
			if t.template_name == "controller_stage_15_cult_leader_tower" then
				t.boss_dead = true
				break
			end
		end
	end

	local function y_wait_for_blocker_cult_leader(store, this, blocker)
		local idle_anim = "walk"

		if not is_protected then
			idle_anim = "standingidle"
		end

		local pos = blocker.motion.arrived and blocker.pos or blocker.motion.dest
		local an, af = U.animation_name_facing_point(this, idle_anim, pos)

		U.animation_start(this, an, af, store.tick_ts, true)

		while not blocker.motion.arrived do
			coroutine.yield()

			if this.health.dead or this.unit.is_stunned or not table.contains(this.enemy.blockers, blocker.id) or blocker.health.dead or not store.entities[blocker.id] then
				return false
			end

			if blocker.unit.is_stunned then
				U.unblock_target(store, blocker)

				return false
			end
		end

		return true
	end

	local function y_enemy_walk_until_blocked_cult_leader(store, this, ignore_soldiers, func)
		local ranged, blocker
		local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, bor(TERRAIN_LAND, TERRAIN_ICE)))

		while ignore_soldiers or not blocker and not ranged do
			if this.unit.is_stunned then
				return false
			end

			if func and func(store, this) then
				return false, nil, nil
			end

			if this.health.dead then
				return false
			end

			local node_valid = P:is_node_valid(this.nav_path.pi, this.nav_path.ni)

			if node_valid and not ignore_soldiers and this.ranged then
				for _, a in pairs(this.ranged.attacks) do
					if not a.disabled and (not a.requires_magic or this.enemy.can_do_magic) and (a.hold_advance or store.tick_ts - a.ts > a.cooldown) then
						ranged = U.find_nearest_soldier(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

						if ranged ~= nil then
							break
						end
					end
				end
			end

			if node_valid and not ignore_soldiers and #this.enemy.blockers > 0 then
				U.cleanup_blockers(store, this)

				blocker = store.entities[this.enemy.blockers[1]]
			end

			if ignore_soldiers or not blocker and not ranged then
				if not is_protected then
					U.y_animation_play(this, "close", nil, store.tick_ts)

					is_protected = true

					update_armor()
				end

				SU.y_enemy_walk_step(store, this)
			else
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end

			if terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, bor(TERRAIN_LAND, TERRAIN_ICE))) then
				return false, nil, nil
			end
		end

		return true, blocker, ranged
	end

	local function y_enemy_melee_attacks_cult_leader(store, this, target)
		for _, i in ipairs(this.melee.order) do
			do
				local ma = this.melee.attacks[i]
				local cooldown = ma.cooldown

				if ma.shared_cooldown then
					cooldown = this.melee.cooldown
				end

				if not ma.disabled and cooldown <= store.tick_ts - ma.ts and band(ma.vis_flags, target.vis.bans) == 0 and band(ma.vis_bans, target.vis.flags) == 0 and (not ma.fn_can or ma.fn_can(this, store, ma, target)) then
					if ma.type == "area" then
						local hit_pos = V.vclone(this.pos)
						local targets = table.filter(store.entities, function(_, e)
							return e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.flags, ma.vis_bans) == 0 and band(e.vis.bans, ma.vis_flags) == 0 and U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius) and (not ma.fn_filter or ma.fn_filter(this, store, ma, e))
						end)

						if not targets or #targets < ma.min_count then
							goto label_1288_0
						end
					end

					ma.ts = store.tick_ts

					if math.random() >= ma.chance then
					-- block empty
					else
						log.paranoid("attack %i selected for entity %s", i, this.template_name)

						for _, aa in pairs(this.melee.attacks) do
							if aa ~= ma and aa.shared_cooldown then
								aa.ts = ma.ts
							end
						end

						ma.ts = store.tick_ts

						S:queue(ma.sound, ma.sound_args)

						local an, af = U.animation_name_facing_point(this, ma.animation, target.pos)

						for i = 1, #this.render.sprites do
							if this.render.sprites[i].animated then
								U.animation_start(this, an, af, store.tick_ts, 1, i)
							end
						end

						local hit_pos = V.vclone(this.pos)

						if ma.hit_offset then
							hit_pos.x = hit_pos.x + (af and -1 or 1) * ma.hit_offset.x
							hit_pos.y = hit_pos.y + ma.hit_offset.y
						end

						local hit_times = ma.hit_times and ma.hit_times or {ma.hit_time}

						for i = 1, #hit_times do
							local hit_time = hit_times[i]
							local dodged = false

							if ma.dodge_time and target.dodge then
								local dodge_time = ma.dodge_time

								if target.dodge and target.dodge.time_before_hit then
									dodge_time = hit_time - target.dodge.time_before_hit
								end

								while dodge_time > store.tick_ts - ma.ts do
									if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and this.dodge.active and not this.dodge.silent then
										return false
									end

									coroutine.yield()
								end

								dodged = SU.unit_dodges(store, target, false, ma, this)
							end

							while hit_time > store.tick_ts - ma.ts do
								if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and this.dodge.active and not this.dodge.silent then
									return false
								end

								coroutine.yield()
							end

							S:queue(ma.sound_hit, ma.sound_hit_args)

							if ma.type == "melee" and not dodged and table.contains(this.enemy.blockers, target.id) then
								local d = E:create_entity("damage")

								d.source_id = this.id
								d.target_id = target.id
								d.track_kills = this.track_kills ~= nil
								d.track_damage = ma.track_damage
								d.pop = ma.pop
								d.pop_chance = ma.pop_chance
								d.pop_conds = ma.pop_conds

								if ma.instakill then
									d.damage_type = DAMAGE_INSTAKILL

									queue_damage(store, d)
								elseif ma.damage_min then
									d.damage_type = ma.damage_type
									d.value = math.ceil(this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max))

									queue_damage(store, d)
								end

								if ma.mod then
									local mod = E:create_entity(ma.mod)

									mod.modifier.target_id = target.id
									mod.modifier.source_id = this.id

									queue_insert(store, mod)
								end
							elseif ma.type == "area" then
								local targets = table.filter(store.entities, function(_, e)
									return e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.flags, ma.vis_bans) == 0 and band(e.vis.bans, ma.vis_flags) == 0 and U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius) and (not ma.fn_filter or ma.fn_filter(this, store, ma, e))
								end)

								for i, e in ipairs(targets) do
									if e == target and dodged then
									-- block empty
									else
										if ma.count and i > ma.count then
											break
										end

										local d = E:create_entity("damage")

										d.source_id = this.id
										d.target_id = e.id
										d.damage_type = ma.damage_type
										d.value = math.ceil(this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max))
										d.pop = ma.pop
										d.pop_chance = ma.pop_chance
										d.pop_conds = ma.pop_conds

										if e.template_name == "soldier_reinforcement_stage_15_denas" then
											d.value = d.value * this.denas_ray_resistance
										end

										queue_damage(store, d)

										if ma.mod then
											local mod = E:create_entity(ma.mod)

											mod.modifier.target_id = e.id
											mod.modifier.source_id = this.id

											queue_insert(store, mod)
										end
									end
								end
							end

							if ma.hit_fx and (not ma.hit_fx_once or i == 1) then
								local fx = E:create_entity(ma.hit_fx)

								fx.pos = V.vclone(hit_pos)

								if ma.hit_fx_offset then
									fx.pos.x = fx.pos.x + (af and -1 or 1) * ma.hit_fx_offset.x
									fx.pos.y = fx.pos.y + ma.hit_fx_offset.y
								end

								if ma.hit_fx_flip then
									fx.render.sprites[1].flip_x = af
								end

								fx.render.sprites[1].ts = store.tick_ts

								queue_insert(store, fx)
							end

							if ma.hit_decal then
								local fx = E:create_entity(ma.hit_decal)

								fx.pos = V.vclone(hit_pos)
								fx.render.sprites[1].ts = store.tick_ts

								if ma.hit_decal_offset then
									fx.pos.x = fx.pos.x + (af and -1 or 1) * ma.hit_decal_offset.x
									fx.pos.y = fx.pos.y + ma.hit_decal_offset.y
								end

								queue_insert(store, fx)
							end
						end

						while not U.animation_finished(this) do
							if this.health.dead or ma.ignore_stun and this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent then
								return false
							end

							coroutine.yield()
						end

						U.animation_start(this, "standingidle", nil, store.tick_ts, true)

						return true
					end
				end
			end

			::label_1288_0::
		end

		return true
	end

	this.pos = this.teleport_pos[1]

	adjust_position(this.teleport_path[1])

	this.vis._flags = this.vis.flags
	this.vis._bans = this.vis.bans
	this.vis.flags = bor(F_ENEMY, F_BOSS)
	this.vis.bans = bor(F_RANGED, F_BLOCK)

	S:queue(this.sound_burrow_out)
	U.y_animation_play(this, "teleportout", true, store.tick_ts)
	U.animation_start(this, "walk", true, store.tick_ts, true)

	while not cult_leader.boss_fight_started do
		coroutine.yield()
	end

	local start_ts = store.tick_ts

	signal.emit("boss_fight_start", this)
	signal.emit("change_power_button", "power_button_1", "bottom_powers_icons_0002", 25)

	megaspawner_boss.manual_wave = "BOSS1"
	this.vis.flags = this.vis._flags
	this.vis.bans = this.vis._bans
	glare.phase = 1

	::label_1276_0::

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned and not this.cage_applied then
			SU.y_enemy_stun(store, this)
		else
			if check_life_threshold_stun() then
				this.vis._flags = this.vis.flags
				this.vis._bans = this.vis.bans
				this.vis.flags = bor(F_ENEMY, F_BOSS)
				this.vis.bans = bor(F_RANGED, F_BLOCK, F_MOD)
				cult_leader.boss_teleport = true
				this.ui.can_click = false
				this.ui.can_select = false
				this.health_bar.hidden = true

				SU.remove_modifiers(store, this)

				this.unit.marker_hidden = true

				S:queue(this.sound_burrow_in)
				U.y_animation_play(this, "teleportin", true, store.tick_ts)

				current_life_threshold_teleport_index = current_life_threshold_teleport_index + 1

				if current_life_threshold_teleport_index > #this.life_threshold_teleport.life_percentage then
					next_life_threshold_teleport = nil
				else
					next_life_threshold_teleport = this.life_threshold_teleport.life_percentage[current_life_threshold_teleport_index]
					megaspawner_boss.manual_wave = string.format("BOSS%i", current_life_threshold_teleport_index)
				end

				glare.phase = current_life_threshold_teleport_index

				U.y_wait(store, this.teleport_away_duration)

				this.pos = this.teleport_pos[current_life_threshold_teleport_index]

				adjust_position(this.teleport_path[current_life_threshold_teleport_index])
				S:queue(this.sound_burrow_out)
				U.y_animation_play(this, "teleportout", true, store.tick_ts)

				is_protected = true

				update_armor()

				this.health_bar.hidden = false
				this.ui.can_click = true
				this.ui.can_select = true
				this.vis.flags = this.vis._flags
				this.vis.bans = this.vis._bans
			end

			local cont, blocker, ranged = y_enemy_walk_until_blocked_cult_leader(store, this, nil, break_fn)

			if not cont and not blocker and not is_protected then
				U.y_animation_play(this, "close", true, store.tick_ts)

				is_protected = true

				update_armor()
			end

			if not cont then
			-- block empty
			else
				if blocker then
					if not y_wait_for_blocker_cult_leader(store, this, blocker) then
						goto label_1276_0
					end

					if is_protected then
						S:queue(this.sound_uncloak)
						U.animation_start(this, "open", true, store.tick_ts)
						U.y_wait(store, this.block_attack.delay)
						aoe_attack(this.block_attack.radius, this.block_attack.damage_min, this.block_attack.damage_max, this.block_attack.damage_type, this.block_attack.vis, this.block_attack.bans, this.block_attack.min_targets)
						U.y_animation_wait(this)
						U.animation_start(this, "standingidle", true, store.tick_ts, true)

						is_protected = false

						update_armor()
					end

					while SU.can_melee_blocker(store, this, blocker) do
						if not y_enemy_melee_attacks_cult_leader(store, this, blocker) then
							goto label_1276_0
						end

						if break_fn() then
							goto label_1276_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_1276_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

-- 大眼本体
scripts.controller_stage_16_overseer = {}

function scripts.controller_stage_16_overseer.get_info(this)
	return {
		damage_max = 0,
		damage_min = 0,
		lives = 0,
		magic_armor = 0,
		armor = 0,
		type = STATS_TYPE_ENEMY,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_icon = this.info.damage_icon,
		immune = this.health.immune_to == DAMAGE_ALL_TYPES
	}
end

function scripts.controller_stage_16_overseer.update(this, store)
	this.phase = 1

	local change_phase_ts = store.tick_ts
	local change_tower_ts = store.tick_ts
	local destroy_holder_last_ts = store.tick_ts
	local glare_last_ts = store.tick_ts
	local downgrade_last_ts = store.tick_ts
	local slow_last_ts = store.tick_ts
	local last_heal_ts = store.tick_ts
	local next_holder_to_destroy_i = 1
	local next_idle_anim_cooldown = math.random(this.idle_cooldown_min, this.idle_cooldown_max)
	local last_idle_anim_ts = store.tick_ts
	local disable_tower_cooldown, change_tower_cooldown
	local change_tower_first_time = true
	local disable_tower_first_time = true
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level116_spawner" then
			megaspawner_boss = value
		end
	end

	local function set_phase(new_phase)
		this.phase = new_phase
		change_phase_ts = store.tick_ts
		megaspawner_boss.manual_wave = string.format("BOSS%i", this.phase)

		if this.change_tower_cooldown[this.phase] then
			if change_tower_first_time then
				change_tower_cooldown = this.first_time_cooldown
				change_tower_first_time = false
			else
				change_tower_cooldown = this.change_tower_cooldown[this.phase]
			end
		end
	end

	local function check_change_phase()
		for i, v in ipairs(this.phase_per_hp_threshold) do
			if this.health.hp <= this.health.hp_max * (this.phase_per_hp_threshold[i] / 100) and i > this.phase then
				set_phase(i)

				return
			end
		end

		if this.phase <= #this.phase_per_time and store.tick_ts - change_phase_ts >= this.phase_per_time[this.phase] then
			set_phase(this.phase + 1)

			return
		end
	end

	local function check_change_idle_anim()
		if store.tick_ts - last_idle_anim_ts >= next_idle_anim_cooldown then
			U.y_animation_play(this, this.idle_anims[math.random(1, #this.idle_anims)], nil, store.tick_ts, 1, 1)

			next_idle_anim_cooldown = math.random(this.idle_cooldown_min, this.idle_cooldown_max)
			last_idle_anim_ts = store.tick_ts
		end
	end

	local function spawn_blood()
		S:queue(this.sound_hurt)

		local blood = E:create_entity("decal_stage_16_overseer_blood")

		blood.pos = V.vclone(this.pos)
		blood.pos.y = blood.pos.y + 100

		queue_insert(store, blood)
	end

	local function check_change_damaged_state()
		local life_percentage = this.health.hp * 100 / this.health.hp_max

		if life_percentage < this.life_hurt_threshold[1] then
			if table.contains(this.render.sprites[1].exo_hide_prefix, "hurt2") then
				table.remove(this.render.sprites[1].exo_hide_prefix, 1)
				spawn_blood()
			end
		elseif life_percentage < this.life_hurt_threshold[2] and table.contains(this.render.sprites[1].exo_hide_prefix, "hurt1") then
			table.remove(this.render.sprites[1].exo_hide_prefix, 2)
			table.insert(this.render.sprites[1].exo_hide_prefix, "hurt0")
			spawn_blood()
		end
	end

	local function check_last_phase_repeat()
		if this.phase >= #this.phase_per_hp_threshold then
			local time_to_wait = megaspawner_boss.spawner_waves.BOSS6[#megaspawner_boss.spawner_waves.BOSS6][1]

			if time_to_wait <= store.tick_ts - change_phase_ts then
				megaspawner_boss.manual_wave = nil

				coroutine.yield()

				change_phase_ts = store.tick_ts
				megaspawner_boss.manual_wave = string.format("BOSS%i", this.phase)
			end
		end
	end

	local function check_greatly_hurt()
		if this._greatly_hurt then
			this._greatly_hurt = false
			spawn_blood()
			change_tower_ts = change_tower_ts - 1
			destroy_holder_last_ts = destroy_holder_last_ts - 1
			glare_last_ts = glare_last_ts - 1
			downgrade_last_ts = downgrade_last_ts - 1
			last_heal_ts = last_heal_ts - 1
			slow_last_ts = slow_last_ts - 1
		end
	end

	local function check_spawner()
		if megaspawner_boss._spawned_all then
			megaspawner_boss._spawned_all = false
			-- megaspawner_boss.manual_wave = nil
			-- coroutine.yield()
			-- megaspawner_boss.manual_wave = string.format("BOSS%i", this.phase)
			megaspawner_boss.respawn = true
		end
	end

	U.animation_start(this, "startidle1", false, store.tick_ts, false, 1)

	for i = 1, #this.hit_point_pos do
		local h = E:create_entity(this.hit_point_template)

		h.pos = V.vclone(this.hit_point_pos[i])
		h.boss = this

		queue_insert(store, h)
	end

	this.idle_anims = this.idle_start_anims

	while store.wave_group_number == 0 do
		check_change_idle_anim()
		coroutine.yield()
	end

	signal.emit("boss_fight_start", this)
	S:queue(this.sound_unchain_center)
	U.animation_start(this, "startend1", nil, store.tick_ts, false, 1)
	U.y_wait(store, fts(10))
	S:queue(this.sound_rumble)

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.4
	shake.aura.duration = fts(30)
	shake.aura.freq_factor = 2

	queue_insert(store, shake)
	U.y_wait(store, fts(30))

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.7
	shake.aura.duration = fts(20)
	shake.aura.freq_factor = 3

	queue_insert(store, shake)
	U.y_animation_wait(this, 1)

	local start_ts = store.tick_ts

	this.idle_anims = this.idle_fight_anims
	last_idle_anim_ts = store.tick_ts

	set_phase(1)

	while true do
		if this.health.hp < 0 then
			this.health.dead = true
		end

		if this.health.dead then
			LU.kill_all_enemies(store, true)

			megaspawner_boss.interrupt = true

			signal.emit("boss_fight_end")
			signal.emit("pan-zoom-camera", 2, {
				x = 505,
				y = 520
			}, 1.5)
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			U.y_wait(store, 2)
			signal.emit("boss-killed", this)
			S:queue(this.sound_death)
			U.y_animation_play(this, "deathstart", nil, store.tick_ts, 1)
			U.animation_start(this, "deathloop", nil, store.tick_ts, true, 1, true)
			U.y_wait(store, 0.5)
			signal.emit("show-balloon_tutorial", "LV16_DENAS01_BOSSFIGHT_01", false)
			U.y_wait(store, 3.5)
			S:queue(this.sound_rumble)
			U.y_animation_wait(this)

			local death_fx = E:create_entity("decal_stage_16_death_bright")

			death_fx.pos = V.vclone(this.pos)

			queue_insert(store, death_fx)
			U.animation_start(death_fx, "death", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "death", nil, store.tick_ts, 1, 1)
			U.y_wait(store, 2)

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.3
			shake.aura.duration = 8
			shake.aura.freq_factor = 2.5

			queue_insert(store, shake)
			U.y_animation_wait(this)
			LU.kill_all_enemies(store, true)

			break
		end

		if this.destroy_holder_cooldown[this.phase] ~= nil and store.tick_ts - destroy_holder_last_ts >= this.destroy_holder_cooldown[this.phase] and next_holder_to_destroy_i <= #this.holders_to_destroy then
			local holder_by_id = table.filter(store.towers, function(k, v)
				return v.tower and v.tower.holder_id == this.holders_to_destroy[next_holder_to_destroy_i]
			end)

			if holder_by_id and #holder_by_id > 0 then
				S:queue(this.sound_destroy_charge)
				U.animation_start(this, "swaptowers1", false, store.tick_ts, nil, 1)

				if holder_by_id[1].tower and holder_by_id[1].tower.can_be_sold then
					holder_by_id[1].tower.blocked = true
					holder_by_id[1].ui.can_click = false
				end

				U.y_wait(store, fts(70))
				S:queue(this.sound_destroy_ray)

				local bullet = E:create_entity(this.destroy_holders_bullet)

				bullet.pos = V.vclone(this.pos)
				bullet.pos.y = bullet.pos.y + 65
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.vclone(holder_by_id[1].pos)
				bullet.bullet.to.y = bullet.bullet.to.y + 20
				bullet.bullet.target_id = nil
				bullet.bullet.source_id = this.id

				queue_insert(store, bullet)
				U.y_wait(store, fts(2))

				local overseer_fx = E:create_entity("decal_stage_16_overseer_destroy_holder_bright")

				overseer_fx.pos = V.vclone(holder_by_id[1].pos)
				overseer_fx.render.sprites[1].ts = store.tick_ts
				overseer_fx.tween.ts = store.tick_ts

				queue_insert(store, overseer_fx)
				U.y_wait(store, fts(12))
				S:queue(this.sound_destroy_explosion)

				local holder_destroy = E:create_entity(this.destroy_holders_template)

				holder_destroy.pos = V.vclone(holder_by_id[1].pos)
				holder_destroy.render.sprites[1].ts = store.tick_ts

				queue_insert(store, holder_destroy)

				local holder_crater = E:create_entity(this.destroy_holders_crater_template)

				holder_crater.pos = V.vclone(holder_by_id[1].pos)
				holder_crater.render.sprites[1].ts = store.tick_ts

				queue_insert(store, holder_crater)
				queue_remove(store, holder_by_id[1])

				destroy_holder_last_ts = store.tick_ts
				next_holder_to_destroy_i = next_holder_to_destroy_i + 1

				local nav_mesh_patch = this.nav_mesh_patches[holder_by_id[1].ui.nav_mesh_id]

				if nav_mesh_patch then
					log.todo("fixing nav_mesh for mesh_id:%s", holder_by_id[1].ui.nav_mesh_id)

					for k, v in pairs(nav_mesh_patch) do
						store.level.nav_mesh[k] = v
					end
				end

				S:queue(this.sound_rumble)

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.7
				shake.aura.duration = fts(20)
				shake.aura.freq_factor = 3

				queue_insert(store, shake)
				U.y_animation_wait(this)

				last_idle_anim_ts = store.tick_ts
			end
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		if this.downgrade_cooldown[this.phase] ~= nil and store.tick_ts - downgrade_last_ts >= this.downgrade_cooldown[this.phase] then
			local can_downgrade_towers = table.filter(store.towers, function(k, t)
				return (not t.tower_holder) and t.template_name ~= "tower_barrack_1" and t.template_name ~= "tower_archer_1" and t.template_name ~= "tower_mage_1" and t.template_name ~= "tower_engineer_1"
			end)
			if #can_downgrade_towers > 0 then
				local random_can_downgrade_towers = table.random_order(can_downgrade_towers)
				local downgrade_count = math.min(this.downgrade_count[this.phase], #random_can_downgrade_towers)

				downgrade_last_ts = store.tick_ts
				S:queue(this.sound_destroy_charge)
				U.animation_start(this, "swaptowers1", false, store.tick_ts, nil, 1)
				for i = 1, downgrade_count do
					local target = random_can_downgrade_towers[i]
					target.tower.blocked = true
					target.ui.can_click = false
				end
				U.y_wait(store, fts(70))
				S:queue(this.sound_destroy_ray)

				for i = 1, downgrade_count do
					local target = random_can_downgrade_towers[i]
					local bullet = E:create_entity("bullet_stage_16_overseer_downgrade_towers")
					bullet.pos = V.vclone(this.pos)
					bullet.pos.y = bullet.pos.y + 65
					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = V.vclone(target.pos)
					bullet.bullet.to.y = bullet.bullet.to.y + 20
					bullet.bullet.target_id = nil
					bullet.bullet.source_id = this.id

					queue_insert(store, bullet)
				end
				U.y_wait(store, fts(2))

				for i = 1, downgrade_count do
					local target = random_can_downgrade_towers[i]
					local overseer_fx = E:create_entity("decal_stage_16_overseer_destroy_holder_bright")

					overseer_fx.pos = V.vclone(target.pos)
					overseer_fx.render.sprites[1].ts = store.tick_ts
					overseer_fx.tween.ts = store.tick_ts

					queue_insert(store, overseer_fx)
				end

				U.y_wait(store, fts(12))
				S:queue(this.sound_destroy_explosion)

				for i = 1, downgrade_count do
					SU.downgrade_tower(store, random_can_downgrade_towers[i])
				end

				S:queue(this.sound_rumble)

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.6
				shake.aura.duration = fts(20)
				shake.aura.freq_factor = 3

				queue_insert(store, shake)
				U.y_animation_wait(this)

				last_idle_anim_ts = store.tick_ts
			else
				downgrade_last_ts = downgrade_last_ts + 1
			end
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		if this.glare_cooldown[this.phase] ~= nil and store.tick_ts - glare_last_ts >= this.glare_cooldown[this.phase] then
			local can_affect_paths = {}
			local direction
			for _, enemy in pairs(store.enemies) do
				if enemy.template_name ~= "enemy_overseer_hit_point" then
					can_affect_paths[enemy.nav_path.pi] = true
				end
			end

			local can_affect_path_count = 0
			for _, path in pairs(can_affect_paths) do
				if can_affect_paths[path] then
					can_affect_path_count = can_affect_path_count + 1
				end
			end

			local index = math.random(1, can_affect_path_count)
			for path, _ in pairs(can_affect_paths) do
				index = index - 1
				if index == 0 then
					direction = path + 1
				end
			end

			if not direction then
				glare_last_ts = glare_last_ts + 1
			else
				glare_last_ts = store.tick_ts
				local affect_paths = direction <= 3 and {1, 2} or {3, 4}

				U.y_animation_play(this, "marktower" .. direction, false, store.tick_ts, 1, 1)
				for _, enemy in pairs(store.enemies) do
					if table.contains(affect_paths, enemy.nav_path.pi) and enemy.template_name ~= "enemy_overseer_hit_point" then
						local glare_mod = E:create_entity("mod_glare")
						glare_mod.modifier.source_id = this.id
						glare_mod.modifier.target_id = enemy.id
						glare_mod.modifier.duration = this.glare_duration[this.phase]
						queue_insert(store, glare_mod)
					end
				end
				last_idle_anim_ts = store.tick_ts
			end
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		if this.heal_cooldown[this.phase] ~= nil and store.tick_ts - last_heal_ts >= this.heal_cooldown[this.phase] then
			last_heal_ts = store.tick_ts
			local heal_duration = this.heal_duration[this.phase]
			local heal_per_second = this.heal_per_second[this.phase]

			U.y_animation_play(this, "swaptowers1", false, store.tick_ts, nil, 1)

			for _, e in pairs(store.enemies) do
				if e.template_name == "enemy_overseer_hit_point" then
					local glare_mod = E:create_entity("mod_glare")
					glare_mod.modifier.source_id = this.id
					glare_mod.modifier.target_id = e.id
					glare_mod.modifier.duration = heal_duration
					queue_insert(store, glare_mod)
				end
			end

			local heal_mod = E:create_entity("mod_heal_overseer")
			heal_mod.modifier.source_id = this.id
			heal_mod.modifier.target_id = this.id
			heal_mod.modifier.duration = heal_duration
			heal_mod.hps.heal_min = heal_per_second
			heal_mod.hps.heal_max = heal_per_second
			queue_insert(store, heal_mod)

			last_idle_anim_ts = store.tick_ts
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		if this.change_tower_cooldown[this.phase] and change_tower_cooldown and change_tower_cooldown <= store.tick_ts - change_tower_ts then
			local towers = table.filter(store.towers, function(k, v)
				return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.can_be_sold and v.tower.can_be_mod
			end)
			local holders = table.filter(store.towers, function(k, v)
				return v.tower and v.tower.type == "holder"
			end)

			if towers and #towers > 0 then
				towers = table.random_order(towers)

				if holders and #holders > 0 then
					holders = table.random_order(holders)
				end

				S:queue(this.sound_teleport_charge)

				local start_ts = store.tick_ts

				U.animation_start(this, "swaptowers1", false, store.tick_ts, nil, 1)

				local tower_index = 1

				towers = table.filter(store.towers, function(k, v)
					return not v.tower_holder
				end)
				holders = table.filter(store.towers, function(k, v)
					return v.tower_holder
				end)

				for i = 1, this.change_tower_amount[this.phase] do
					if tower_index <= #towers and holders and tower_index <= #holders then
						local change_tower_fx = E:create_entity(this.change_towers_template)

						change_tower_fx.pos = towers[tower_index].pos
						change_tower_fx.render.sprites[1].ts = store.tick_ts
						change_tower_fx.tween.ts = store.tick_ts

						queue_insert(store, change_tower_fx)

						local change_tower_fx = E:create_entity(this.change_towers_template)

						change_tower_fx.pos = holders[tower_index].pos
						change_tower_fx.render.sprites[1].ts = store.tick_ts
						change_tower_fx.tween.ts = store.tick_ts

						queue_insert(store, change_tower_fx)
						towers[tower_index].ui.can_click = false
						holders[tower_index].ui.can_click = false
						towers[tower_index].tower.blocked = true
						holders[tower_index].tower.blocked = true
						signal.emit("force-tower-swap", towers[tower_index], holders[tower_index])
					elseif (not holders or tower_index > #holders) and #towers >= tower_index + 1 then
						local change_tower_fx = E:create_entity(this.change_towers_template)

						change_tower_fx.pos = towers[tower_index].pos
						change_tower_fx.render.sprites[1].ts = store.tick_ts
						change_tower_fx.tween.ts = store.tick_ts

						queue_insert(store, change_tower_fx)

						local change_tower_fx = E:create_entity(this.change_towers_template)

						change_tower_fx.pos = towers[tower_index + 1].pos
						change_tower_fx.render.sprites[1].ts = store.tick_ts
						change_tower_fx.tween.ts = store.tick_ts

						queue_insert(store, change_tower_fx)
						signal.emit("force-tower-swap", towers[tower_index], towers[tower_index + 1])
						towers[tower_index].ui.can_click = false
						towers[tower_index + 1].ui.can_click = false
						towers[tower_index].tower.blocked = true
						towers[tower_index + 1].tower.blocked = true
						tower_index = tower_index + 1
					end

					tower_index = tower_index + 1
				end

				U.y_wait(store, this.swap_delay + 1)
				tower_index = 1

				for i = 1, this.change_tower_amount[this.phase] do
					if tower_index <= #towers and holders and tower_index <= #holders then
						local controller = E:create_entity("controller_tower_swap_overseer")

						controller.tower_1 = towers[tower_index]
						controller.tower_2 = holders[tower_index]

						queue_insert(store, controller)
					elseif (not holders or tower_index > #holders) and #towers >= tower_index + 1 then
						local controller = E:create_entity("controller_tower_swap_overseer")

						controller.tower_1 = towers[tower_index]
						controller.tower_2 = towers[tower_index + 1]

						queue_insert(store, controller)

						tower_index = tower_index + 1
					end

					tower_index = tower_index + 1
				end

				U.y_animation_wait(this)

				tower_index = 1
				for i = 1, this.change_tower_amount[this.phase] do
					if tower_index <= #towers and holders and tower_index <= #holders then
						towers[tower_index].ui.can_click = true
						holders[tower_index].ui.can_click = true
						towers[tower_index].tower.blocked = false
						holders[tower_index].tower.blocked = false
					elseif (not holders or tower_index > #holders) and #towers >= tower_index + 1 then
						towers[tower_index].ui.can_click = true
						towers[tower_index + 1].ui.can_click = true
						towers[tower_index].tower.blocked = false
						towers[tower_index + 1].tower.blocked = false
						tower_index = tower_index + 1
					end

					tower_index = tower_index + 1
				end

				last_idle_anim_ts = store.tick_ts
				change_tower_ts = start_ts
				change_tower_cooldown = this.change_tower_cooldown[this.phase]
			else
				change_tower_ts = change_tower_ts + 1
			end
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		if this.slow_cooldown[this.phase] ~= nil and store.tick_ts - slow_last_ts >= this.slow_cooldown[this.phase] then
			local towers = table.filter(store.towers, function(k, v)
				return not v.tower_holder
			end)
			local slow_count = math.min(this.slow_count[this.phase], #towers)
			if #towers > 0 then
				towers = table.random_order(towers)
				S:queue(this.sound_teleport_charge)
				slow_last_ts = store.tick_ts

				U.animation_start(this, "swaptowers1", false, store.tick_ts, nil, 1)

				for i = 1, slow_count do
					local change_tower_fx = E:create_entity(this.change_towers_template)
					change_tower_fx.pos = towers[i].pos
					change_tower_fx.render.sprites[1].ts = store.tick_ts
					change_tower_fx.tween.ts = store.tick_ts
					queue_insert(store, change_tower_fx)
				end

				U.y_wait(store, this.swap_delay + 1)

				for i = 1, slow_count do
					local slow_mod = E:create_entity("mod_slow_overseer")
					slow_mod.modifier.source_id = this.id
					slow_mod.modifier.target_id = towers[i].id
					queue_insert(store, slow_mod)
				end

				U.y_animation_wait(this)
				last_idle_anim_ts = store.tick_ts
			else
				slow_last_ts = slow_last_ts + 1
			end
		end

		if this.health.hp < 0 then
			this.health.dead = true
			goto continue
		end

		check_change_phase()
		check_last_phase_repeat()
		check_change_damaged_state()
		check_spawner()
		check_change_idle_anim()
		check_greatly_hurt()

		::continue::
		coroutine.yield()
	end
end

scripts.decal_stage_16_overseer_blood = {}

function scripts.decal_stage_16_overseer_blood.update(this, store)
	for i, v in ipairs(this.blood_pos) do
		local blood = E:create_entity(this.fx_template)

		blood.pos.x, blood.pos.y = this.pos.x + v.x, this.pos.y + v.y
		blood.render.sprites[1].ts = store.tick_ts
		blood.tween.ts = store.tick_ts

		queue_insert(store, blood)
		U.y_wait(store, fts(1))
	end

	queue_remove(store, this)
end

-- 大眼的嘴巴出怪口
scripts.controller_stage_16_overseer_mouth_door = {}

function scripts.controller_stage_16_overseer_mouth_door.update(this, store)
	local last_check_enemy = store.tick_ts
	local is_open = false

	U.animation_start(this, "closeidle", nil, store.tick_ts, true)

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	local function search_enemies_nearby()
		local targets = U.find_enemies_in_range(store.entities, this.check_pos, 0, this.check_radius, this.check_vis_flags, this.check_vis_bans, function(e)
			return e.enemy and e.health and not e.health.dead
		end)

		if targets and #targets > 0 then
			if not is_open then
				U.y_animation_wait(this)
				U.y_animation_play(this, "open", nil, store.tick_ts)
				U.animation_start(this, "openidle", nil, store.tick_ts, true, 1, true)

				is_open = true
			end
		elseif is_open then
			U.y_animation_wait(this)
			U.y_animation_play(this, "close", nil, store.tick_ts)
			U.animation_start(this, "closeidle", nil, store.tick_ts, true)

			is_open = false
		end
	end

	local start_ts = store.tick_ts

	last_check_enemy = store.tick_ts

	local last_index_processed = 0

	while true do
		if store.tick_ts - last_check_enemy >= this.check_cooldown then
			search_enemies_nearby()

			last_check_enemy = store.tick_ts
		end

		coroutine.yield()
	end
end

-- 大眼的触手控制
scripts.controller_stage_16_overseer_tentacle = {}

function scripts.controller_stage_16_overseer_tentacle.update(this, store)
	local current_phase = 1
	local can_spawn_enemies = false
	local last_shot_ts = store.tick_ts
	local last_shot_attack_soldiers_ts = store.tick_ts
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]

	U.animation_start(this, "idletrapped", nil, store.tick_ts, true)

	this.tentacle_mouth = E:create_entity(this.tentacle_mouth_template)
	this.tentacle_mouth.pos = this.pos

	queue_insert(store, this.tentacle_mouth)

	local hit_point = E:create_entity("enemy_overseer_hit_point")
	hit_point.pos = V.v(this.pos.x + this.spawn_offset.x + (this.spawn_offset.x < 0 and 35 or -35), this.pos.y + this.spawn_offset.y)
	hit_point.boss = overseer
	queue_insert(store, hit_point)

	while true do
		if overseer.health.dead then
		-- block empty
		else
			if this.config.cooldown[overseer.phase] ~= nil then
				if not can_spawn_enemies then
					U.y_animation_wait(this)
					S:queue(this.sound_rumble)

					local shake = E:create_entity("aura_screen_shake")

					shake.aura.amplitude = 0.3
					shake.aura.duration = fts(120)
					shake.aura.freq_factor = 3

					queue_insert(store, shake)
					S:queue(this.sound_unchain)
					U.y_animation_play(this, "shake", nil, store.tick_ts, 1)

					this.tentacle_mouth.anim_free = true

					U.animation_start(this, "free", nil, store.tick_ts, false, 1)
					U.y_wait(store, fts(50))
					S:queue(this.sound_rumble)

					local shake = E:create_entity("aura_screen_shake")

					shake.aura.amplitude = 0.7
					shake.aura.duration = fts(10)
					shake.aura.freq_factor = 3

					queue_insert(store, shake)
					U.y_animation_wait(this)
					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

					can_spawn_enemies = true
					last_shot_ts = store.tick_ts - this.first_cooldown
				end

				if store.tick_ts - last_shot_ts >= this.config.cooldown[overseer.phase] then
					local start_ts = store.tick_ts

					local shoot_count = 1
					local hp_rate = overseer.health.hp / overseer.health.hp_max
					if hp_rate < 0.25 then
						shoot_count = 3
					elseif hp_rate < 0.4 then
						shoot_count = 2
					end

					local speed_factor = 0.5 * (shoot_count + 1)

					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, speed_factor)
					end

					for i = 1, shoot_count do
						this.tentacle_mouth.anim_shot = true
						S:queue(this.sound_spawn)
						U.animation_start(this, "spawnenemies", nil, store.tick_ts, false)
						U.y_wait(store, this.shot_delay / speed_factor)

						local spawn_pos_i = math.random(1, #this.spawn_pos)
						local b = E:create_entity(this.bullet)

						b.pos.x, b.pos.y = this.pos.x + this.spawn_offset.x, this.pos.y + this.spawn_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = this.spawn_pos[spawn_pos_i]
						b.bullet.source_id = this.id
						b.path_to_spawn = this.spawn_path
						b.overseer = overseer
						b.spawn_path = this.spawn_path[spawn_pos_i]

						queue_insert(store, b)
						U.y_animation_wait(this)
						U.y_animation_wait(this.tentacle_mouth)
						coroutine.yield()
					end

					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, 1 / speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, 1 / speed_factor)
					end

					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

					last_shot_ts = start_ts
				end
			end

			if this.config.cooldown_attack_soldiers[overseer.phase] ~= nil then
				if store.tick_ts - last_shot_attack_soldiers_ts >= this.config.cooldown_attack_soldiers[overseer.phase] then
					local start_ts = store.tick_ts

					local shoot_count = 1
					local hp_rate = overseer.health.hp / overseer.health.hp_max
					if hp_rate < 0.15 then
						shoot_count = 3
					elseif hp_rate < 0.3 then
						shoot_count = 2
					end

					local speed_factor = 0.5 * (shoot_count + 1)

					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, speed_factor)
					end

					for i = 1, shoot_count do
						this.tentacle_mouth.anim_shot = true
						S:queue(this.sound_spawn)
						U.animation_start(this, "spawnenemies", nil, store.tick_ts, false)
						U.y_wait(store, this.shot_delay / speed_factor)

						local soldier = U.find_nearest_soldier(store.soldiers, this.pos, 0, 225, bor(F_AREA, F_RANGED), F_NONE)

						local spawn_pos = soldier and V.vclone(soldier.pos) or V.vclone(this.spawn_pos[math.random(1, #this.spawn_pos)])

						local b = E:create_entity(this.bullet)
						b.pos.x, b.pos.y = this.pos.x + this.spawn_offset.x, this.pos.y + this.spawn_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = spawn_pos
						b.bullet.source_id = this.id
						b.path_to_spawn = this.spawn_path[1]
						b.overseer = overseer
						b.spawn_path = this.spawn_path[1]

						queue_insert(store, b)
						U.y_animation_wait(this)
						U.y_animation_wait(this.tentacle_mouth)
						coroutine.yield()
					end

					if speed_factor ~= 1 then
						SU.change_fps(store.tick_ts, this, 1 / speed_factor)
						SU.change_fps(store.tick_ts, this.tentacle_mouth, 1 / speed_factor)
					end

					U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

					last_shot_attack_soldiers_ts = start_ts
				end
			end
		end

		coroutine.yield()
	end
end

scripts.controller_stage_16_overseer_tentacle_mouth = {}

function scripts.controller_stage_16_overseer_tentacle_mouth.update(this, store)
	this.render.sprites[1].hidden = true

	while true do
		if this.anim_free then
			this.render.sprites[1].hidden = false

			U.y_animation_play(this, "free", nil, store.tick_ts, false)
			U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

			this.anim_free = nil
		end

		if this.anim_shot then
			U.y_animation_play(this, "spawnenemies", nil, store.tick_ts, false)
			U.animation_start(this, "idlemouth", nil, store.tick_ts, true, 1, true)

			this.anim_shot = nil
		end

		coroutine.yield()
	end
end

scripts.mod_slow_overseer = {}

function scripts.mod_slow_overseer.insert(this, store)
	local target = store.towers[this.modifier.target_id]
	if not target then
		return false
	end
	SU.insert_tower_cooldown_buff(store.tick_ts, target, 1 / this.slow_factor)
	U.entity_insert_shader(target, SH:get(this._shader), this._shader_args)
	return true
end

function scripts.mod_slow_overseer.update(this, store)
	local target = store.towers[this.modifier.target_id]
	if not target then
		queue_remove(store, this)
		return
	end

	local stop_time = store.tick_ts + this.modifier.duration
	while store.tick_ts < stop_time do
		coroutine.yield()
	end

	SU.remove_tower_cooldown_buff(store.tick_ts, target, 1 / this.slow_factor)
	U.entity_remove_shader(target)

	queue_remove(store, this)
end

-- 受击点
scripts.enemy_overseer_hit_point = {}

function scripts.enemy_overseer_hit_point.update(this, store)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y)
	local path_pi, path_spi, path_ni
	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])
	end

	this.nav_path.pi = path_pi
	this.nav_path.spi = path_spi
	this.nav_path.ni = path_ni

	local min_x = this.pos.x - this.move_bounds.x / 2
	local max_x = min_x + this.move_bounds.x
	local min_y = this.pos.y - this.move_bounds.y / 2
	local max_y = this.pos.y + this.move_bounds.y

	this.vis._bans = this.vis.bans
	this.vis.bans = bit.bor(F_ALL)

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	U.y_wait(store, fts(60))

	this.vis.bans = this.vis._bans

	local overseer = this.boss

	while true do
		if overseer.health.dead then
			break
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

function scripts.enemy_overseer_hit_point.on_damage(this, store, damage)
	local d = E:create_entity("damage")

	d.damage_type = damage.damage_type
	d.value = damage.value
	d.source_id = damage.source_id
	d.target_id = this.boss.id
	queue_damage(store, d)

	if damage.value >= 600 then
		this.boss._greatly_hurt = true
	end

	return true
end

scripts.bullet_stage_16_overseer_tentacle_spawn = {}

function scripts.bullet_stage_16_overseer_tentacle_spawn.update(this, store, script)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end

		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end

		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end

	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, dradius)
	end)

	for _, enemy in pairs(enemies) do
		local d = E:create_entity("damage")

		d.damage_type = b.damage_type
		d.reduce_armor = b.reduce_armor
		d.reduce_magic_armor = b.reduce_magic_armor

		if b.damage_decay_random then
			d.value = U.frandom(dmin, dmax)
		elseif this.up_alchemical_powder_chance and math.random() < this.up_alchemical_powder_chance or UP:get_upgrade("engineer_efficiency") then
			d.value = dmax
		else
			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)

			d.value = math.floor(dmax - (dmax - dmin) * dist_factor)
		end

		d.value = math.ceil(b.damage_factor * d.value)
		d.source_id = this.id
		d.target_id = enemy.id

		queue_damage(store, d)
		log.paranoid("bomb id:%s, radius:%s, enemy id:%s, dist:%s, damage:%s damage_type:%x", this.id, dradius, enemy.id, V.dist(enemy.pos.x, enemy.pos.y, b.to.x, b.to.y), d.value, d.damage_type)

		if this.up_shock_and_awe_chance and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < this.up_shock_and_awe_chance then
			local mod = E:create_entity("mod_shock_and_awe")

			mod.modifier.target_id = enemy.id

			queue_insert(store, mod)
		end

		if b.mod then
			local mod = E:create_entity(b.mod)

			mod.modifier.target_id = enemy.id
			mod.modifier.source_id = this.id

			queue_insert(store, mod)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	queue_insert(store, p)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)

		local water_fx = E:create_entity(b.hit_fx_water)

		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	local enemy_template = "enemy_glareling"
	local path_pi, path_spi, path_ni

	for i = 1, this.spawn_amounts_per_phase[this.overseer.phase] do
		local enemy = E:create_entity(enemy_template)
		local enemy_pos = V.v(b.to.x + this.spawn_offset[i].x, b.to.y + this.spawn_offset[i].y)
		local nearest = P:nearest_nodes(enemy_pos.x, enemy_pos.y, {this.spawn_path}, {1, 2, 3})

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])
			enemy_pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		enemy.pos.x, enemy.pos.y = enemy_pos.x, enemy_pos.y
		enemy.nav_path.pi = path_pi
		enemy.nav_path.spi = path_spi
		enemy.nav_path.ni = path_ni
		enemy.nav_path_data = nearest[1]

		queue_insert(store, enemy)
	end

	local soldiers = U.find_soldiers_in_range(store.soldiers, b.to, 0, this.explosion_damage.range, this.explosion_damage.vis_flags, this.explosion_damage.vis_bans)

	if soldiers then
		for _, soldier in pairs(soldiers) do
			local d = E:create_entity("damage")

			d.damage_type = this.explosion_damage.damage_type

			local dist_factor = U.dist_factor_inside_ellipse(soldier.pos, b.to, this.explosion_damage.range)

			d.value = math.floor(this.explosion_damage.damage_max - (this.explosion_damage.damage_max - this.explosion_damage.damage_min) * dist_factor)
			d.source_id = this.id
			d.target_id = soldier.id

			queue_damage(store, d)
		end
	end

	queue_remove(store, this)
end

scripts.controller_stage_16_overseer_eye = {}

function scripts.controller_stage_16_overseer_eye.update(this, store)
	local start_ts = store.tick_ts
	local blink_cooldown = math.random(this.blink_min_cooldown, this.blink_max_cooldown)
	local last_blink = store.tick_ts
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	local damaged = false

	this.idle_anims = this.idle_not_damaged

	local function check_change_damaged_state()
		if not damaged then
			local life_percentage = overseer.health.hp * 100 / overseer.health.hp_max

			if life_percentage < this.life_hurt_threshold then
				U.y_animation_play(this, "eyehurt", nil, store.tick_ts)

				this.idle_anims = this.idle_damaged
				damaged = true
			end
		end
	end

	while true do
		if blink_cooldown <= store.tick_ts - last_blink then
			U.y_animation_play(this, this.idle_anims[math.random(1, #this.idle_anims)], nil, store.tick_ts)

			blink_cooldown = math.random(this.blink_min_cooldown, this.blink_max_cooldown)
			last_blink = store.tick_ts
		end

		check_change_damaged_state()
		coroutine.yield()
	end
end

scripts.controller_stage_16_tentacle_bottom = {}

function scripts.controller_stage_16_tentacle_bottom.update(this, store)
	local overseer = table.filter(store.entities, function(k, v)
		return v.template_name == "controller_stage_16_overseer"
	end)[1]
	local is_free = false

	while true do
		if not is_free and overseer.phase == this.phase_to_free then
			is_free = true

			S:queue(this.sound_unchain)
			U.animation_start(this, "free", nil, store.tick_ts, false, 1)
			S:queue(this.sound_rumble)

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.3
			shake.aura.duration = fts(35)
			shake.aura.freq_factor = 3

			queue_insert(store, shake)
			U.y_wait(store, fts(40))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.7
			shake.aura.duration = fts(20)
			shake.aura.freq_factor = 3

			queue_insert(store, shake)
			U.y_animation_wait(this)
			U.animation_start(this, "idle2", false, store.tick_ts, true, 1)
		end

		coroutine.yield()
	end
end

scripts.controller_stage_19_navira = {}

function scripts.controller_stage_19_navira.update(this, store)
	local taunt_ts = store.tick_ts
	local taunt_cd = math.random(this.taunts.delay_min, this.taunts.delay_max) + 5
	local fire_balls_ts = store.tick_ts
	local balls = {}
	local statue_hands

	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_19_statue_hands" then
			statue_hands = e

			break
		end
	end

	local function find_tower(towers_chosen)
		local towers = {}

		for _, v in pairs(store.entities) do
			if v.tower and not v.tower.blocked and not v.tower_holder and v.tower.can_be_mod and not table.contains(towers_chosen, v) then
				table.insert(towers, v)
			end
		end

		return towers[math.random(1, #towers)]
	end

	local function shoot_fire_ball(tower, ball)
		local b = E:create_entity(this.fire_ball_bullet_t)

		b.pos = V.vclone(ball.pos)
		b.pos.y = b.pos.y + 40
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(tower.pos)
		b.bullet.target_id = tower.id
		b.bullet.source_id = this.id

		queue_insert(store, b)
	end

	local function break_fn()
		return this.start_bossfight or store.waves_finished and not LU.has_alive_enemies(store)
	end

	while not this.start_bossfight do
		coroutine.yield()

		if taunt_cd < store.tick_ts - taunt_ts and (store.wave_group_number == 0 or LU.has_alive_enemies(store)) then
			y_show_taunt_set(store, this.taunts, "pre_bossfight", false)

			taunt_ts = store.tick_ts
			taunt_cd = math.random(this.taunts.delay_min, this.taunts.delay_max)
		end

		if store.wave_group_number > 0 and LU.has_alive_enemies(store) and store.tick_ts - fire_balls_ts > this.fire_balls_cd - this.fire_balls_wait_between_balls then
			for i = 1, this.fire_balls_count do
				local ball = E:create_entity(this.fire_ball_t)
				local angle = i * 2 * math.pi / this.fire_balls_count % (2 * math.pi)

				ball.render.sprites[1].name = string.format(ball.render.sprites[1].name, i)
				ball.render.sprites[1].ts = store.tick_ts
				ball.render.sprites[1].hidden = true

				queue_insert(store, ball)
				table.insert(balls, ball)
			end

			local rot_controller = E:create_entity(this.fire_ball_rotation_controller_t)

			rot_controller.balls_count = this.fire_balls_count
			rot_controller.balls = balls
			rot_controller.center_pos = this.pos

			queue_insert(store, rot_controller)

			for _, v in pairs(balls) do
				if U.y_wait(store, this.fire_balls_wait_between_balls, break_fn) then
					goto label_1337_0
				end

				v.render.sprites[1].hidden = false

				S:queue(this.sound_fireball_spawn)
				U.y_animation_play(v, "spawn", nil, store.tick_ts)
				U.animation_start(v, "idle", nil, store.tick_ts, true)
			end

			if U.y_wait(store, this.fire_balls_wait_before_shoot, break_fn) then
				break
			end

			local towers_chosen = {}
			local tower = find_tower(towers_chosen)

			while not tower do
				if U.y_wait(store, fts(10), break_fn) then
					goto label_1337_0
				end

				tower = find_tower(towers_chosen)
			end

			U.animation_start(this, "sealofruin", nil, store.tick_ts, false)

			if U.y_wait(store, fts(50), break_fn) then
				break
			end

			S:queue(this.sound_fireball_cast)

			for _, b in pairs(balls) do
				tower = find_tower(towers_chosen)

				if tower then
					shoot_fire_ball(tower, b)
					table.insert(towers_chosen, tower)
					U.y_wait(store, this.fire_balls_wait_between_shots)
				end

				queue_remove(store, b)
			end

			queue_remove(store, rot_controller)
			U.y_animation_wait(this)
			U.animation_start(this, "idle", nil, store.tick_ts, true)

			balls = {}
			fire_balls_ts = store.tick_ts
		end
	end

	::label_1337_0::

	for _, b in pairs(balls) do
		if b then
			queue_remove(store, b)
		end
	end

	while not this.start_bossfight do
		coroutine.yield()
	end

	local fx = E:create_entity(this.hands_dust_1_t)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local fx = E:create_entity(this.hands_dust_2_t)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local fx = E:create_entity(this.hands_stones_1_t)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	local fx = E:create_entity(this.hands_stones_2_t)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)
	S:queue(this.sound_hands_down)
	S:queue(this.sound_hands_up)
	U.animation_start(statue_hands, "hands_shake", nil, store.tick_ts)
	U.y_animation_play(this, "shake_in", nil, store.tick_ts)
	U.y_animation_play(this, "shake_down", nil, store.tick_ts)
	U.y_animation_play(this, "shake_out", nil, store.tick_ts)

	this.ended_entrance = true
end

scripts.controller_stage_19_navira_ball_rotation = {}

function scripts.controller_stage_19_navira_ball_rotation.update(this, store)
	local rot_phase = 0

	while true do
		rot_phase = rot_phase + this.fire_ball_rot_speed * store.tick_length

		for i, t in ipairs(this.balls) do
			if t then
				local a = (i * 2 * math.pi / this.balls_count + rot_phase) % (2 * math.pi)

				t.pos = U.point_on_ellipse(this.center_pos, this.fire_ball_rot_radius, a)
			end
		end

		coroutine.yield()
	end
end

scripts.bullet_stage_19_navira_fire_ball_ray = {}

function scripts.bullet_stage_19_navira_fire_ball_ray.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target

	if b.target_id then
		target = store.entities[b.target_id]
	end

	local dest = V.vclone(b.to)

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

	s.r = angle
	s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width

	U.animation_start(this, "run", nil, store.tick_ts, false)
	U.y_wait(store, b.hit_time)

	local mods_added = {}

	if target and (b.mod or b.mods) then
		local mods = b.mods or {b.mod}

		for _, mod_name in pairs(mods) do
			local m = E:create_entity(mod_name)

			m.modifier.target_id = b.target_id

			table.insert(mods_added, m)
			queue_insert(store, m)
		end
	end

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.mod_bullet_stage_19_navira_fire_ball_ray_stun = {}

function scripts.mod_bullet_stage_19_navira_fire_ball_ray_stun.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	local source = store.entities[m.source_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts

	SU.tower_block_inc(target)

	this.pos = target.pos

	if this.tween and not this.tween.disabled then
		this.tween.ts = store.tick_ts
	end

	U.y_animation_play(this, "start", nil, store.tick_ts)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	local start_ts = store.tick_ts

	while store.tick_ts - start_ts < m.duration do
		if this.remove then
			break
		end

		coroutine.yield()
	end

	U.y_animation_play(this, "end", nil, store.tick_ts)
	SU.tower_block_dec(target)
	queue_remove(store, this)
end

scripts.boss_navira = {}

function scripts.boss_navira.update(this, store, script)
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level119_spawner" then
			megaspawner_boss = value
		end
	end

	local current_phase = 1
	local is_tornado = false
	local tornado_ts

	this.corruption_ts = store.tick_ts

	local spawn_ts = store.tick_ts

	local function check_tornado_in()
		return not is_tornado and current_phase <= #this.tornado_hp_trigger and this.health.hp < this.tornado_hp_trigger[current_phase] * this.health.hp_max
	end

	local function check_tornado_out()
		return is_tornado and store.tick_ts - tornado_ts > this.tornado_duration
	end

	local function break_fn()
		if not this.corruption_kr5.enabled and not is_tornado and store.tick_ts - this.corruption_ts > this.corruption_kr5.cooldown then
			this.corruption_kr5.enabled = true
		end

		return check_tornado_in() or check_tornado_out()
	end

	local function shoot_fire_ball(target, offset_y, flip_y)
		local b = E:create_entity(this.fire_ball_bullet_t)

		b.pos = V.vclone(this.pos)
		b.pos.y = b.pos.y + offset_y
		b.bullet.from = V.vclone(b.pos)

		if target.id then
			b.bullet.to = V.vclone(target.pos)
			b.bullet.target_id = target.id
		else
			b.bullet.to = V.vclone(target)
			b.bullet.target_id = nil
		end

		b.bullet.source_id = this.id

		if flip_y then
			b.render.sprites[1].scale = V.v(1, -1)
		end

		queue_insert(store, b)
	end

	local function y_on_death()
		LU.kill_all_enemies(store, true)
		S:stop_all()

		megaspawner_boss.interrupt = true

		if is_tornado then
			S:queue(this.sound_transform_out)
			queue_remove(store, this.tornado_aura)
			U.y_animation_play(this, "tornadoend", nil, store.tick_ts)
		end

		S:queue(this.sound_death)
		U.animation_start(this, "death", nil, store.tick_ts, false)

		local x_mult = this.render.sprites[1].flip_x and -1 or 1

		shoot_fire_ball(V.v(this.pos.x + 100 * x_mult, this.pos.y + 100), 25)
		U.y_wait(store, fts(32))
		shoot_fire_ball(V.v(this.pos.x - 70 * x_mult, this.pos.y + 120), 25)
		U.y_wait(store, fts(18))
		shoot_fire_ball(V.v(this.pos.x, this.pos.y + 160), 25)
		U.y_wait(store, fts(61))
		shoot_fire_ball(V.v(this.pos.x - 20 * x_mult, this.pos.y + 160), 0)

		local delays = {9, 7, 5, 5, 3, 2, 2, 2, 2}

		for i = 1, #delays do
			U.y_wait(store, fts(delays[i]))
			shoot_fire_ball(V.v(this.pos.x + math.random(-70, 70), this.pos.y + math.random(120, 160)), 0, math.random(1, 2) > 1)
		end

		U.y_animation_wait(this)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)

		this.bossfight_ended = true
	end

	local function find_tower(towers_chosen)
		local towers = {}

		for _, v in pairs(store.entities) do
			if v.tower and v.tower.can_be_mod and not v.tower.blocked and not v.tower_holder and not table.contains(towers_chosen, v) then
				table.insert(towers, v)
			end
		end

		return towers[math.random(1, #towers)]
	end

	local function tornado_in()
		S:queue(this.sound_transform_in)

		current_phase = current_phase + 1

		U.y_animation_play(this, "tornadoin", nil, store.tick_ts)
		U.animation_start(this, "tornadoloop", nil, store.tick_ts, true)

		this.render.sprites[1].angles.walk = {"tornadoloop", "tornadoloop"}
		tornado_ts = store.tick_ts
		is_tornado = true

		U.unblock_all(store, this)

		this.vis._bans = this.vis.bans
		this.vis.bans = bor(F_BLOCK, F_STUN)
		U.speed_mul_self(this, this.tornado_speed_mult)
		this.health_bar._offset_y = this.health_bar.offset.y
		this.health_bar.offset.y = 115
		this.tornado_aura = E:create_entity(this.tornado_aura_t)
		this.tornado_aura.aura.source_id = this.id

		queue_insert(store, this.tornado_aura)

		this.corruption_kr5.enabled = false
	end

	local function tornado_out()
		S:queue(this.sound_transform_out)
		U.animation_start(this, "tornadoend", nil, store.tick_ts, false)
		U.y_wait(store, fts(18))

		local towers_chosen = {}
		local balls = this.tornado_balls_count[current_phase - 1]

		for i = 1, balls do
			local tower = find_tower(towers_chosen)

			if tower then
				shoot_fire_ball(tower, 80)
				table.insert(towers_chosen, tower)
			end

			U.y_wait(store, fts(10 / balls))
		end

		U.y_animation_wait(this)
		U.animation_start(this, "idle", nil, store.tick_ts, true)

		is_tornado = false
		this.render.sprites[1].angles.walk = {"idle", "idle"}
		this.vis.bans = this.vis._bans
		U.speed_div_self(this, this.tornado_speed_mult)
		this.health_bar.offset.y = this.health_bar._offset_y

		queue_remove(store, this.tornado_aura)

		this.corruption_kr5.enabled = true
	end

	U.animation_start(this, "idle", nil, store.tick_ts, true)
	U.y_wait(store, 2)

	this.tween.disabled = true

	signal.emit("boss_fight_start", this)

	megaspawner_boss.manual_wave = "BOSS"

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		elseif check_tornado_out() then
			tornado_out()
		elseif check_tornado_in() then
			tornado_in()
		else
			if this.render.sprites[1].z >= Z_OBJECTS_COVERS and store.tick_ts - spawn_ts > 5 then
				this.render.sprites[1].z = Z_OBJECTS
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, nil, break_fn)

			if not cont then
			-- block empty
			elseif not blocker or not SU.y_wait_for_blocker(store, this, blocker) then
			-- block empty
			else
				while SU.can_melee_blocker(store, this, blocker) do
					if not SU.y_enemy_melee_attacks(store, this, blocker) then
						break
					end

					coroutine.yield()
				end
			end
		end

		coroutine.yield()
	end
end

function scripts.boss_navira.on_corrupt(this, store)
	if not this.corruption_kr5.enabled then
		return
	end

	this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.corruption_kr5.hp)
	this.corruption_kr5.enabled = false
	this.corruption_ts = store.tick_ts

	local m = E:create_entity(this.mod_heal)

	m.modifier.target_id = this.id

	queue_insert(store, m)
end

scripts.controller_stage_22_boss_crocs = {}

function scripts.controller_stage_22_boss_crocs.update(this, store)
	local previous_wave_index = store.wave_group_number
	local run_this_wave = false
	local cooldown = 0
	local max_casts = 99
	local casts = 0
	local next_ts = store.tick_ts
	local taunt_index = 1
	local idle_anim_next_ts = store.tick_ts

	local function update_idle_anim_next_ts()
		idle_anim_next_ts = store.tick_ts + this.idle_anims_min_cd + (this.idle_anims_max_cd - this.idle_anims_min_cd) * math.random()
	end

	update_idle_anim_next_ts()
	U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

	local function get_towers_to_eat()
		local towers = table.filter(store.entities, function(k, v)
			local is_tower = v.tower and not v.pending_removal and (not this.excluded_templates or not table.contains(this.excluded_templates, v.template_name)) and v.vis and band(v.vis.flags, this.vis_bans) == 0 and band(v.vis.bans, this.vis_flags) == 0 and (not this.exclude_tower_kind or not table.contains(this.exclude_tower_kind, v.tower.kind)) and v.tower.can_be_mod
			--local is_tower = v.tower and not v.pending_removal and (not this.excluded_templates or not table.contains(this.excluded_templates, v.template_name)) and v.vis and band(v.vis.flags, this.vis_bans) == 0 and band(v.vis.bans, this.vis_flags) == 0 and (not this.exclude_tower_kind or not table.contains(this.exclude_tower_kind, v.tower.kind)) and v.tower.can_be_mod

			return is_tower
		end)

		return towers
	end

	while true do
		if previous_wave_index ~= store.wave_group_number then
			previous_wave_index = store.wave_group_number
			run_this_wave = false

			for i, v in ipairs(this.waves) do
				if store.wave_group_number == v then
					run_this_wave = true
					cooldown = this.cooldown[i]
					casts = 0
					max_casts = this.max_casts[i]
					next_ts = store.tick_ts + this.first_cooldown[i]

					break
				end
			end
		end

		if run_this_wave and casts < max_casts and next_ts <= store.tick_ts then
			casts = casts + 1

			local towers = get_towers_to_eat()

			if towers and #towers > 0 then
				U.animation_start(this, this.skill_anim, nil, store.tick_ts, false)

				for _, e in pairs(store.entities) do
					if e.template_name == "tower_stage_22_arborean_mages" then
						e.boss_is_going_to_eat = true

						break
					end
				end

				U.y_wait(store, fts(10))
				S:queue(this.sound_release_arm_cinematic)
				U.y_wait(store, fts(55))

				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
						e.boss_eating = true
					end

					if e.template_name == "tower_stage_22_arborean_mages" then
						e.boss_eating = true
					end
				end

				U.y_wait(store, fts(22))

				towers = get_towers_to_eat()

				if towers and #towers > 0 then
					towers = table.random_order(towers)

					local twr = towers[1]
					local mods_in_tower = table.filter(store.entities, function(_, ee)
						return ee.modifier and ee.modifier.target_id == twr.id
					end)

					for _, mod_in_tower in pairs(mods_in_tower) do
						queue_remove(store, mod_in_tower)
					end

					local mod = E:create_entity(this.mod)

					mod.modifier.target_id = twr.id
					mod.modifier.source_id = this.id
					mod.use_secondary_anim = true
					mod.muted = true

					queue_insert(store, mod)
				end

				U.y_wait(store, fts(2))

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 1.5
				shake.aura.duration = 2
				shake.aura.freq_factor = 2

				queue_insert(store, shake)
				U.y_wait(store, fts(98))
				S:queue(this.sound_catch_arm)
				U.y_wait(store, fts(30))

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 1
				shake.aura.duration = 1
				shake.aura.freq_factor = 2

				queue_insert(store, shake)
				U.y_animation_wait(this)
				U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

				next_ts = store.tick_ts + cooldown

				U.y_wait(store, 0.5)
				signal.emit("show-balloon_tutorial", "LV22_BOSS_BEFORE_FIGHT_EAT_0" .. taunt_index, false)
				U.y_wait(store, 3.5)
				signal.emit("show-balloon_tutorial", "LV22_MAGE_BEFORE_FIGHT_RESPONSE_0" .. taunt_index, false)

				taunt_index = taunt_index + 1

				if taunt_index > this.taunt_keys_amount then
					taunt_index = 1
				end

				update_idle_anim_next_ts()
			else
				next_ts = store.tick_ts + cooldown
			end
		end

		if this.start_cinematic_eat then
			this.start_cinematic_eat = false

			local towers = get_towers_to_eat()

			U.animation_start(this, this.skill_anim, nil, store.tick_ts, false)
			U.y_wait(store, fts(10))
			S:queue(this.sound_release_arm_cinematic)
			U.y_wait(store, fts(55))

			for _, e in pairs(store.entities) do
				if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
					e.boss_eating = true
				end

				if e.template_name == "tower_stage_22_arborean_mages" then
					e.appear = true
					e.boss_eating = true
				end
			end

			U.y_wait(store, fts(22))

			if towers and #towers > 0 then
				towers = table.random_order(towers)

				local twr = towers[1]
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = twr.id
				mod.modifier.source_id = this.id
				mod.use_secondary_anim = true
				mod.muted = true

				queue_insert(store, mod)
			end

			U.y_wait(store, fts(2))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 2.5
			shake.aura.duration = 2
			shake.aura.freq_factor = 2

			queue_insert(store, shake)
			U.y_wait(store, fts(98))
			S:queue(this.sound_catch_arm)
			U.y_wait(store, fts(30))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 1
			shake.aura.duration = 1
			shake.aura.freq_factor = 2

			queue_insert(store, shake)
			U.y_animation_wait(this)
			U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

			next_ts = store.tick_ts + cooldown

			update_idle_anim_next_ts()

			this.cinematic_eat_finished = true
		end

		if idle_anim_next_ts < store.tick_ts then
			local random_idle = table.random(this.idle_anims)

			U.y_animation_wait(this, 1, this.render.sprites[1].runs + 1)
			U.y_animation_play(this, random_idle, nil, store.tick_ts)
			U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)
			update_idle_anim_next_ts()
		end

		if this.do_exit then
			U.y_animation_wait(this, 1, this.render.sprites[1].runs + 1)
			S:queue(this.sound_set_free)
			U.y_animation_play(this, this.anim_exit, nil, store.tick_ts)

			this.finished = true

			while not this.rocks_fall do
				coroutine.yield()
			end

			U.animation_start(this, "bossFight", nil, store.tick_ts, true, 1, true)

			return
		end

		coroutine.yield()
	end
end

scripts.mod_boss_crocs_tower_timed_destroy = {}

function scripts.mod_boss_crocs_tower_timed_destroy.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	target.tower._type = target.tower.type
	target.tower._prevent_timed_destroy_price = this._prevent_timed_destroy_price
	target.tower._prevent_timed_destroy = false
	target.tower.type = "tower_timed_destroy"

	local was_clickeable = target.ui.can_click

	SU.tower_block_inc(target)

	if this.can_prevent_destroy then
		target.ui.can_click = was_clickeable
	end

	return true
end

function scripts.mod_boss_crocs_tower_timed_destroy.update(this, store)
	local target = store.entities[this.modifier.target_id]
	local holder_id = target.tower.holder_id
	local holder = store.entities[holder_id]

	local function find_boss_id()
		local boss_table = table.filter(store.entities, function(k, v)
			return v.boss_crocs_level ~= nil
		end)

		if not boss_table or #boss_table < 1 then
			return nil
		else
			return boss_table[1].id
		end
	end

	local boss_id = find_boss_id()
	local ignore_boss = boss_id == nil

	local function is_boss_alive()
		if not boss_id or not store.entities[boss_id] then
			boss_id = find_boss_id()
		end

		if not boss_id or store.entities[boss_id].health.dead then
			return false
		else
			return true
		end
	end

	this.pos = target.pos

	U.animation_start(this, "spawn", nil, store.tick_ts, false, 1)
	U.animation_start(this, "spawn", nil, store.tick_ts, false, 2)
	U.y_animation_wait(this, 1)
	U.animation_start(this, "run", nil, store.tick_ts, true, 1)
	U.animation_start(this, "run", nil, store.tick_ts, true, 2)

	local arborean_mage_towers_ids = {}

	for _, e in pairs(store.entities) do
		if e.template_name == "tower_stage_22_arborean_mages" then
			table.insert(arborean_mage_towers_ids, e.id)
		end
	end

	local start_ts = store.tick_ts

	while true do
		if not this.can_prevent_destroy then
			if target.tower._prevent_timed_destroy then
				break
			end

			if target.ui.can_click and this.needs_arborean_mages_to_clean then
				local found_arborean_tower = false

				for _, v in pairs(arborean_mage_towers_ids) do
					if store.entities[v] and not store.entities[v].health.dead then
						found_arborean_tower = true

						break
					end
				end

				if not found_arborean_tower then
					target.ui.can_click = false
				end
			end
		end

		if not ignore_boss and not is_boss_alive() then
			break
		end

		if store.tick_ts - start_ts >= this.destroy_tower_cooldown then
			target.ui.can_click = false
			target.tower.type = target.tower._type
			target.tower.blocked = true

			U.animation_start(this, "destroytower", nil, store.tick_ts, false, 1)
			U.animation_start(this, "destroytower", nil, store.tick_ts, false, 2)
			U.y_wait(store, fts(40))

			target.tower.destroy = true

			U.y_animation_wait(this, 1)
			queue_remove(store, this)
		end

		coroutine.yield()
	end

	target.tower.type = target.tower._type

	SU.tower_block_dec(target)
	U.y_animation_wait(this, 1)
	U.animation_start(this, "dissipate", nil, store.tick_ts, false, 1)
	U.animation_start(this, "dissipate", nil, store.tick_ts, false, 2)
	U.y_animation_wait(this, 1)
	queue_remove(store, this)
end

function scripts.mod_boss_crocs_tower_timed_destroy.remove(this, store)
	return true
end

scripts.aura_bullet_boss_crocs_poison_rain_lvl1 = {}

function scripts.aura_bullet_boss_crocs_poison_rain_lvl1.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.soldiers, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in pairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					queue_insert(store, new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_200_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	queue_remove(store, this)
end

scripts.boss_crocs = {}

function scripts.boss_crocs.update(this, store, script)
	if this.boss_crocs_level == 1 and not this._placed_from_tunnel then
		this.vis.bans = U.flag_set(this.vis.bans, F_RANGED)
		this.vis.bans = U.flag_set(this.vis.bans, F_BLOCK)

		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.render.sprites[1].flip_x = true
		this.health_bar.hidden = true

		U.animation_start(this, "fall", nil, store.tick_ts, 1)
		U.y_wait(store, fts(20))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.7
		shake.aura.duration = 0.5
		shake.aura.freq_factor = 3

		LU.queue_insert(store, shake)
		U.y_wait(store, fts(46))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 2

		LU.queue_insert(store, shake)

		for _, e in pairs(store.entities) do
			if e.template_name == "tower_stage_22_arborean_mages" then
				e.escape = true
			end
		end

		local rocks_fall_ts = store.tick_ts

		for _, v in pairs(this.rocks_fall_fx) do
			local fx = E:create_entity(v)

			fx.pos = V.vclone(this.rocks_fall_fx_pos)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
		end

		local rocks_index = 0

		for _, mask_settings in pairs(this.masks_to_spawn) do
			while store.tick_ts < rocks_fall_ts + mask_settings[2] do
				coroutine.yield()
			end

			rocks_index = rocks_index + 1

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 1.4
			shake.aura.duration = 0.5
			shake.aura.freq_factor = 3

			LU.queue_insert(store, shake)

			for _, e in pairs(store.entities) do
				if e.template_name == mask_settings[1] then
					e.render.sprites[1].hidden = false
				end

				if e.template_name == "tower_stage_22_arborean_mages" then
					queue_remove(store, e)
				end

				if e.template_name == "controller_stage_22_boss_crocs" then
					e.rocks_fall = true
				end

				if rocks_index == 3 and e.template_name == "decal_stage_22_rune_rock" and e.pos.x > 400 and e.pos.x < 600 then
					queue_remove(store, e)
				end
			end

			for _, kill_position in pairs(mask_settings[3]) do
				local soldiers = U.find_soldiers_in_range(store.soldiers, kill_position[1], 0, kill_position[2], 0, 0)

				if soldiers and #soldiers > 0 then
					for _, sold in pairs(soldiers) do
						local d = E:create_entity("damage")

						d.source_id = this.id
						d.target_id = sold.id
						d.value = 99
						d.damage_type = DAMAGE_INSTAKILL
						d.pop = nil

						queue_damage(store, d)
					end
				end
			end
		end

		for _, e in pairs(store.entities) do
			if e.pos and e.pos.y < 100 and (e.template_name == "decal_defense_flag" or e.template_name == "decal_defend_point" or e.template_name == "decal_upgrade_alliance_flux_altering_coils" or e.template_name == "decal_upgrade_alliance_seal_of_punishment") then
				queue_remove(store, e)
			end
		end

		SU.y_enemy_animation_wait(this)
		signal.emit("end-cinematic")

		if not this.health.dead then
			this.vis.bans = U.flag_clear(this.vis.bans, F_RANGED)
			this.vis.bans = U.flag_clear(this.vis.bans, F_BLOCK)
			this.health_bar.hidden = nil
		end
	end

	local a
	local ab = this.melee.attacks[1]
	local as = this.timed_attacks.list[1]

	as.ts = store.tick_ts

	local cg = store.count_groups[as.count_group_type]
	local attack_execute = this.timed_attacks.list[2]
	local attack_towers = this.timed_attacks.list[3]
	local attack_rain = this.timed_attacks.list[4]

	attack_towers.ts = store.tick_ts

	if attack_rain then
		attack_rain.ts = store.tick_ts
	end

	if this.evolution_amount == nil then
		this.evolution_amount = 0
	end

	local orig_rain_cooldown, orig_rain_min_range, orig_rain_max_range, orig_rain_shots

	if attack_rain then
		orig_rain_cooldown = attack_rain.cooldown
		orig_rain_min_range = attack_rain.min_range
		orig_rain_max_range = attack_rain.max_range
		orig_rain_shots = attack_rain.shots_amount
	end

	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level122_spawner" then
			megaspawner_boss = value
		end
	end

	local function is_on_valid_node()
		return P:is_node_valid(this.nav_path.pi, this.nav_path.ni)
	end

	local function ready_to_spawn()
		if not is_on_valid_node() then
			return false
		end

		local node_limit = math.floor(as.min_distance_from_end[this.nav_path.pi] / P.average_node_dist)
		local nodes_to_end = P:get_end_node(this.nav_path.pi) - this.nav_path.ni

		return store.tick_ts - as.ts > as.cooldown and node_limit < nodes_to_end and (not cg[as.count_group_name] or cg[as.count_group_name] < as.count_group_max)
	end

	local function attack_is_tower_valid(v, a)
		local is_tower = v.tower and not v.pending_removal and (not a.excluded_templates or not table.contains(a.excluded_templates, v.template_name)) and v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and (not a.exclude_tower_kind or not table.contains(a.exclude_tower_kind, v.tower.kind)) and v.tower.can_be_mod and U.is_inside_ellipse(v.pos, this.pos, a.max_range)

		return is_tower
	end

	local function get_towers_to_eat()
		local targets = table.filter(store.towers, function(k, v)
			return attack_is_tower_valid(v, attack_towers)
		end)

		if targets and #targets > 0 then
			return targets
		end

		return nil
	end

	local function get_executable_blocker()
		local executable_blocker = {}

		for _, blocker_id in pairs(this.enemy.blockers) do
			local blocker = store.entities[blocker_id]

			if not blocker then
			-- block empty
			elseif not blocker.health or blocker.health.dead then
			-- block empty
			elseif blocker.health.hp / blocker.health.hp_max > attack_execute.hp_threshold then
			-- block empty
			elseif not blocker.motion.arrived then
			-- block empty
			else
				table.insert(executable_blocker, blocker)
			end
		end

		return executable_blocker
	end

	local function ready_to_execute()
		if ab.disabled then
			return false
		end

		if store.tick_ts - ab.ts < ab.cooldown then
			return false
		end

		if #get_executable_blocker() < 1 then
			return false
		end

		if not is_on_valid_node() then
			return false
		end

		return true
	end

	local function ready_to_eat_tower()
		if store.tick_ts - attack_towers.ts <= attack_towers.cooldown then
			return false
		end

		if not is_on_valid_node() then
			return false
		end

		local towers_to_eat = get_towers_to_eat()

		if not towers_to_eat or #towers_to_eat < 1 then
			return false
		end

		return true
	end

	local function ready_to_evolve()
		if this.evolution_amount < this.eat_tower_evolution and this.health.hp / this.health.hp_max > this.life_percentage_evolution then
			return false
		end

		if not this.can_evolve then
			return false
		end

		return true
	end

	local function ready_to_rain()
		if not attack_rain then
			return false
		end

		if store.tick_ts - attack_rain.ts <= attack_rain.cooldown then
			return false
		end

		if not is_on_valid_node() then
			return false
		end

		return true
	end

	local function melee_break_fn()
		if ready_to_spawn() then
			return true
		end

		if ready_to_execute() then
			return true
		end

		if ready_to_evolve() then
			return true
		end

		if ready_to_eat_tower() then
			return true
		end

		if ready_to_rain() then
			return true
		end

		return false
	end

	local function break_fn()
		if this.stomp_passive then
			local a = this.render.sprites[1]

			if a.name == "walk" and (a.frame_idx == 16 or a.frame_idx == 36) then
				local step_fx = E:create_entity(this.stomp_passive.step_fx)

				step_fx.pos = V.vclone(this.pos)
				step_fx.render.sprites[1].ts = store.tick_ts

				if a.frame_idx == 36 then
					step_fx.render.sprites[1].flip_x = true
				end

				queue_insert(store, step_fx)

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.3
				shake.aura.duration = 0.5
				shake.aura.freq_factor = 1

				queue_insert(store, shake)

				local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.stomp_passive.range, this.stomp_passive.vis_flags_soldiers, this.stomp_passive.vis_bans_soldiers)

				if soldiers then
					for _, soldier in pairs(soldiers) do
						local d = E:create_entity("damage")

						d.damage_type = this.stomp_passive.damage_type
						d.value = U.frandom(this.stomp_passive.damage_min, this.stomp_passive.damage_max)
						d.source_id = this.id
						d.target_id = soldier.id

						queue_damage(store, d)
					end
				end
			end
		end

		if ready_to_spawn() then
			return true
		end

		if ready_to_evolve() then
			return true
		end

		if ready_to_eat_tower() then
			return true
		end

		if ready_to_rain() then
			return true
		end

		return false
	end

	local function shoot_acid(shot_pos)
		local b = E:create_entity(a.bullet)
		local offset_x = a.bullet_start_offset.x

		if not this.render.sprites[1].flip_x then
			offset_x = -a.bullet_start_offset.x
		end

		b.pos.x, b.pos.y = this.pos.x + offset_x, this.pos.y + a.bullet_start_offset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = shot_pos
		b.bullet.source_id = this.id

		queue_insert(store, b)
	end

	local function y_on_death()
		LU.kill_all_enemies(store, true)
		S:stop_all()

		megaspawner_boss.interrupt = true

		S:queue(this.sound_death)
		U.animation_start(this, "death", nil, store.tick_ts, false)
		U.y_animation_wait(this)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)
		U.y_wait(store, 1)

		store.level.bossfight_ended = true
	end

	if this.boss_crocs_level == 1 then
		signal.emit("show-gui")
		signal.emit("boss_fight_start_tweened", this, 0.3)

		megaspawner_boss.manual_wave = "BOSS"

		for _, e in pairs(store.entities) do
			if e.template_name == "decal_stage_22_remolino" then
				e.start_wave_boss = true

				break
			end
		end
	else
		signal.emit("boss_fight_start", this)
	end

	::label_203_0::

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_execute() then
				local start_ts = store.tick_ts
				local blockers = get_executable_blocker()
				local an, af = U.animation_name_facing_point(this, attack_execute.animation, blockers[1].pos)

				for i = 1, #this.render.sprites do
					if this.render.sprites[i].animated then
						U.animation_start(this, an, af, store.tick_ts, 1, i)
					end
				end

				while store.tick_ts - start_ts < attack_execute.hit_time do
					if this.health.dead or this.unit.is_stunned and not attack_execute.ignore_stun or this.dodge and this.dodge.active and not this.dodge.silent then
						goto label_203_0
					end

					coroutine.yield()
				end

				S:queue(this.melee.attacks[1].sound_instakill)

				blockers = get_executable_blocker()

				for _, block in pairs(blockers) do
					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = block.id
					d.track_kills = this.track_kills ~= nil
					d.track_damage = attack_execute.track_damage
					d.pop = attack_execute.pop
					d.pop_chance = attack_execute.pop_chance
					d.pop_conds = attack_execute.pop_conds
					d.damage_type = attack_execute.damage_type

					queue_damage(store, d)

					if not attack_execute.instakill_all_blockers then
						break
					end
				end

				SU.y_enemy_wait(store, this, attack_execute.action_time_eat - attack_execute.hit_time)

				local hit_pos = V.vclone(this.pos)

				if attack_execute.hit_offset then
					hit_pos.x = hit_pos.x + (af and -1 or 1) * attack_execute.hit_offset.x
					hit_pos.y = hit_pos.y + attack_execute.hit_offset.y
				end

				if attack_execute.hit_decal then
					local fx = E:create_entity(attack_execute.hit_decal)

					fx.pos = V.vclone(hit_pos)
					fx.render.sprites[1].ts = store.tick_ts

					queue_insert(store, fx)
				end

				while not U.animation_finished(this) do
					if this.health.dead or attack_execute.ignore_stun and this.unit.is_stunned or this.dodge and this.dodge.active and not this.dodge.silent then
						return false
					end

					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				ab.ts = store.tick_ts
			end

			if ready_to_spawn() then
				a = as

				local start_ts = store.tick_ts
				local target_path = this.nav_path.pi

				if target_path == 19 then
					target_path = 12
				end

				this.available_nodes = {}

				local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, bor(TERRAIN_LAND, TERRAIN_ICE), function(x, y)
					local nearest_node = P:nearest_nodes(x, y, {target_path}, {1, 2, 3}, true)

					if #nearest_node <= 0 then
						return false
					end

					local pi, spi, ni, dist = unpack(nearest_node[1])

					if ni < this.nav_path.ni then
						return false
					end

					return true
				end, nil, {1, 2, 3})

				nodes = table.random_order(nodes)

				if not nodes then
					SU.delay_attack(store, a, fts(10))

					goto label_203_1
				end

				for j = 1, #nodes do
					local is_far = true

					for k = 1, #this.available_nodes do
						local distance = V.dist(nodes[j].x, nodes[j].y, this.available_nodes[k].pos.x, this.available_nodes[k].pos.y)

						if distance < a.distance_between_entities then
							is_far = false

							break
						end
					end

					if is_far then
						local nearest_node = P:nearest_nodes(nodes[j].x, nodes[j].y, {target_path}, {1, 2, 3}, true)
						local min_distance = 5

						if #nearest_node > 0 and min_distance > nearest_node[1][4] then
							table.insert(this.available_nodes, {
								pos = nodes[j],
								node = nearest_node[1]
							})

							if #this.available_nodes >= a.entities_amount then
								break
							end
						end
					end
				end

				U.y_animation_play(this, a.animation_start, nil, store.tick_ts)

				local total_entities = a.entities_amount
				local total_loops = a.loop_times
				local entities_spawned = 0
				local bullet_start_offset = a.bullet_start_offset[1]

				if this.render.sprites[1].flip_x then
					bullet_start_offset = a.bullet_start_offset[2]
				end

				for current_loop = 1, total_loops do
					local remaining_entities = total_entities - entities_spawned
					local remaining_loops = total_loops - current_loop + 1
					local entities_this_loop = math.ceil(remaining_entities / remaining_loops)

					S:queue(a.sound)
					U.animation_start(this, a.animation_loop, nil, store.tick_ts)
					U.y_wait(store, fts(12))

					for i = 1, entities_this_loop do
						local b = E:create_entity(a.bullet)

						b.pos.x, b.pos.y = this.pos.x + bullet_start_offset.x, this.pos.y + bullet_start_offset.y
						b.bullet.from = V.vclone(b.pos)
						b.bullet.to = V.vclone(this.available_nodes[i].pos)
						b.bullet.source_id = this.id
						b.nav_path_data = this.available_nodes[i].node

						queue_insert(store, b)
						U.y_wait(store, fts(1))
					end

					SU.y_enemy_animation_wait(this)

					entities_spawned = entities_spawned + entities_this_loop
				end

				U.y_animation_play(this, a.animation_end, nil, store.tick_ts)

				a.ts = start_ts
			end

			::label_203_1::

			if ready_to_eat_tower() then
				a = attack_towers

				local target_tower = table.random(get_towers_to_eat())

				U.animation_start(this, a.animation, nil, store.tick_ts)

				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
						e.boss_eating = true
					end
				end

				SU.y_enemy_wait(store, this, a.action_time_mod)

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.7
				shake.aura.duration = 2
				shake.aura.freq_factor = 2

				queue_insert(store, shake)

				local mods_in_tower = table.filter(store.entities, function(_, ee)
					return ee.modifier and ee.modifier.target_id == target_tower.id
				end)

				for _, mod_in_tower in pairs(mods_in_tower) do
					queue_remove(store, mod_in_tower)
				end

				local mod = E:create_entity(a.mod)

				mod.modifier.target_id = target_tower.id
				mod.modifier.source_id = this.id

				queue_insert(store, mod)
				SU.y_enemy_wait(store, this, a.action_time_eat - a.action_time_mod)
				SU.y_enemy_animation_wait(this)

				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
						e.boss_eating = false
					end
				end

				a.ts = store.tick_ts
			end

			if ready_to_rain() then
				a = attack_rain

				U.animation_start(this, a.animation_start, nil, store.tick_ts)
				S:queue(a.sound)
				SU.y_enemy_wait(store, this, a.action_time_shoot)

				local qty_shoots = 0

				for _, e in pairs(store.entities) do
					if e.hero and not U.flag_has(e.vis.flags, F_FLYING) then
						local nodes = P:nearest_nodes(e.pos.x, e.pos.y, nil, nil, true)

						if #nodes < 1 then
						-- block empty
						else
							local pi, spi, ni = unpack(nodes[1])
							local shot_pos = P:node_pos(pi, spi, ni)

							shoot_acid(shot_pos)

							qty_shoots = qty_shoots + 1

							SU.y_enemy_wait(store, this, a.shots_delay)
						end
					end
				end

				for i = 1, a.shots_amount - qty_shoots do
					local shot_pos, pi, spi, ni
					local tries = 0
					local found = false

					while not found and tries < 5 do
						tries = tries + 1
						shot_pos, pi, spi, ni = P:get_random_position(10, bor(bor(TERRAIN_LAND, TERRAIN_ICE)))

						if shot_pos ~= nil then
							found = true

							shoot_acid(shot_pos)
						end
					end

					SU.y_enemy_wait(store, this, a.shots_delay)
				end

				SU.y_enemy_animation_wait(this)

				a.ts = store.tick_ts
			end

			if ready_to_evolve() then
				U.animation_start(this, this.evolution_anim, nil, store.tick_ts, false)
				S:queue(this.evolve_sound)
				U.y_wait(store, this.evolution_health_update_tick_time)

				local next_template = E:get_template(this.next_level_template)

				this.health_bar.offset = V.vclone(next_template.health_bar.offset)

				local hp_start = this.health.hp

				if this.hp_evolution_method == 0 then
					this.health.hp = this.health.hp_max
				elseif this.hp_evolution_method == 1 then
				-- block empty
				elseif this.hp_evolution_method == 2 then
					local tick_hp = this.hp_restore_fixed_amount * 0.5 / this.hp_ticks
					local tick_time = (this.evolution_health_update_time - this.evolution_health_update_tick_time) / this.hp_ticks

					for i = 1, this.hp_ticks do
						this.health.hp = this.health.hp + tick_hp
						this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp)

						U.y_wait(store, tick_time)
					end

					this.health.hp = this.health.hp + this.hp_restore_fixed_amount * 0.5
					this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp)
				end

				local heal_amount = this.health.hp - hp_start

				this.health.hp_healed = (this.health.hp_healed or 0) + heal_amount

				if heal_amount > 0 then
					signal.emit("entity-healed", this, this, heal_amount)
				end

				U.y_animation_wait(this)

				local mod = E:create_entity(this.evolution_mod)

				mod.modifier.target_id = this.id
				mod.modifier.source_id = this.id

				queue_insert(store, mod)

				return
			end

			if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, melee_break_fn) then
			-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

scripts.mod_croc_boss_melee_hit = {}

function scripts.mod_croc_boss_melee_hit.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		return false
	end

	local hit_pos = V.vclone(target.pos)

	if target.unit and target.unit.hit_offset then
		hit_pos.x, hit_pos.y = hit_pos.x + target.unit.hit_offset.x, hit_pos.y + target.unit.hit_offset.y
	end

	local fx = E:create_entity(this.modifier.hit_fx)

	fx.pos = V.vclone(hit_pos)
	fx.render.sprites[1].ts = store.tick_ts

	queue_insert(store, fx)

	return false
end

scripts.mod_boss_crocs_tower_eat = {}

function scripts.mod_boss_crocs_tower_eat.queue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		SU.tower_block_inc(target)
		SU.remove_modifiers(store, target, nil, "mod_boss_crocs_tower_eat")

		this._pushed_bans = U.push_bans(target.vis, F_ALL)
	end
end

function scripts.mod_boss_crocs_tower_eat.dequeue(this, store, insertion)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return
	end

	if insertion then
		SU.tower_block_dec(target)

		if this._pushed_bans then
			U.pop_bans(target.vis, this._pushed_bans)
		end
	end
end

function scripts.mod_boss_crocs_tower_eat.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	target.tower._type = target.tower.type
	target.tower._prevent_timed_destroy_price = this._prevent_timed_destroy_price
	target.tower._prevent_timed_destroy = false
	target.tower.type = "tower_timed_destroy"
	target.ui.can_click = false

	return true
end

function scripts.mod_boss_crocs_tower_eat.update(this, store)
	local target = store.entities[this.modifier.target_id]
	local boss = store.entities[this.modifier.source_id]

	this.pos = target.pos

	local anim = this.use_secondary_anim and "attack2" or "attack1"

	if not this.muted then
		if this.use_secondary_anim then
			S:queue(this.sound_eat, {
				delay = 0.55
			})
		else
			S:queue(this.sound_eat, {
				delay = 0
			})
		end
	end

	U.animation_start(this, anim, nil, store.tick_ts, false, 1)

	target.ui.can_click = false
	target.tower.type = target.tower._type

	local not_finished = U.y_wait(store, fts(6), function(store, time)
		return boss and boss.health and boss.health.dead
	end)

	if not_finished then
		queue_remove(store, this)

		return
	end

	local h_id = target.tower.holder_id

	target.tower.destroy = true

	coroutine.yield()

	local holder = table.filter(store.towers, function(_, v)
		return v.tower and v.tower.holder_id == h_id
	end)

	if holder and #holder > 0 then
		holder = holder[1]
		holder.ui.can_click = false
		holder.tower.can_hover = false
	else
		holder = nil
	end

	U.y_wait(store, this.use_secondary_anim and fts(113) or fts(40))
	S:queue(this.sound_fist_remove)

	while not U.animation_finished(this, 1) do
		if boss and boss.health and boss.health.dead then
			break
		end

		coroutine.yield()
	end

	if holder then
		holder.ui.can_click = true
		holder.tower.can_hover = true
	end

	queue_remove(store, this)
end

function scripts.mod_boss_crocs_tower_eat.remove(this, store)
	return true
end

scripts.mod_croc_boss_evolution_polymorph = {}

function scripts.mod_croc_boss_evolution_polymorph.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		this.target_ref = target

		for _, s in ipairs(target.render.sprites) do
			s.hidden = true
		end

		SU.remove_modifiers(store, target)
		SU.remove_auras(store, target)
		queue_remove(store, target)
		U.unblock_all(store, target)

		if target.ui then
			target.ui.can_click = false
		end

		target.main_script.co = nil
		target.main_script.runs = 0

		if target.count_group then
			target.count_group.in_limbo = true
		end

		local polymorph_template

		for k, v in pairs(this.entity_t) do
			log.info()

			if target.template_name == v[1] then
				polymorph_template = v[2]

				break
			end
		end

		local entity_poly = E:create_entity(polymorph_template)

		entity_poly.pos = target.pos
		entity_poly.nav_path = target.nav_path

		queue_insert(store, entity_poly)

		entity_poly.enemy.gems = target.enemy.gems
		target.enemy.gems = 0
		entity_poly.health.hp_healed = target.health.hp_healed or 0

		local hp_start = target.health.hp
		entity_poly.health.patched = target.health.patched
		entity_poly.health.hp_max = target.health.hp_max

		if this.hp_evolution_method[target.boss_crocs_level] == 0 then
		-- block empty
		elseif this.hp_evolution_method[target.boss_crocs_level] == 1 then
			local current_percentage = target.health.hp / target.health.hp_max

			entity_poly.health.hp = entity_poly.health.hp_max * current_percentage
		elseif this.hp_evolution_method[target.boss_crocs_level] == 2 then
			entity_poly.health.hp = target.health.hp
		end

		local heal_amount = entity_poly.health.hp - hp_start

		entity_poly.health.hp_healed = entity_poly.health.hp_healed + heal_amount

		if heal_amount > 0 then
			signal.emit("entity-healed", this, entity_poly, heal_amount)
		end

		if entity_poly.health.hp < entity_poly.health.hp_max then
			entity_poly.health_bar.hidden = false
		end

		return true
	end

	return false
end

scripts.boss_pig = {}

function scripts.boss_pig.update(this, store, script)
	local sid_body, sid_fly = 1, 4
	local d_flying = E:create_entity("decal_boss_pig_flying")
	local s_flying = d_flying.render.sprites[1]

	queue_insert(store, d_flying)

	local s_body = this.render.sprites[sid_body]
	local node_id = P:nearest_nodes(698, 467, {2})[1][3]
	local jump_id = 1
	local jump_positions = {V.v(698, 467), V.v(150, 278)}
	local reach_positions = {V.v(418, 435), V.v(868, 242)}
	local reach_path_id = {1, 2}

	this.fly_time_up = 0.5
	this.fly_time_down = 0.4
	this.fly_time_out = 1.5
	this.fly_offset_y = 60

	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level106_spawner" then
			megaspawner_boss = value
		end
	end

	local round_idx = 0

	local function y_arrive(to, dest_pi)
		local start_ts = store.tick_ts
		local phase
		local flags = this.vis.flags
		local bans = this.vis.bans

		this.vis.flags = this.vis.flags_jumping
		this.vis.bans = this.vis.bans_jumping
		s_flying.hidden = false

		local shadow = E:create_entity(this.shadow)

		shadow.pos.x, shadow.pos.y = to.x, to.y
		shadow.render.sprites[1].ts = store.tick_ts
		shadow.render.sprites[1].runs = 0
		shadow.tween.props[1].keys[2][1] = this.fly_time_down
		shadow.tween.reverse = true

		queue_insert(store, shadow)
		S:queue(this.sound_falling)

		repeat
			phase = (store.tick_ts - start_ts) / this.fly_time_down
			d_flying.pos.x = U.ease_value(to.x, to.x, phase, "sine-out")
			d_flying.pos.y = U.ease_value(868, to.y + 150, phase, "sine-out") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		S:queue(this.sound_land)

		this.phase = "loop"

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 2

		queue_insert(store, shake)

		round_idx = round_idx + 1
		megaspawner_boss.manual_wave = string.format("BOSS%i", round_idx)

		local damage_on_fall = E:create_entity(this.aura_damage_on_fall)

		damage_on_fall.pos.x, damage_on_fall.pos.y = this.pos.x, this.pos.y
		damage_on_fall.owner = this
		damage_on_fall.aura.source_id = this.id

		queue_insert(store, damage_on_fall)

		this.pos.x, this.pos.y = to.x, to.y
		s_flying.hidden = true
		this.vis.flags = this.vis.flags_normal
		this.vis.bans = this.vis.bans_normal

		for _, value in pairs(this.render.sprites) do
			value.hidden = false
		end

		local ground_decal = E:create_entity("decal_boss_pig_ground_fall")

		ground_decal.render.sprites[1].ts = store.tick_ts
		ground_decal.pos.x = this.pos.x
		ground_decal.pos.y = this.pos.y

		queue_insert(store, ground_decal)
		U.y_animation_play(this, "fall", true, store.tick_ts, 1)

		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]

		U.y_wait(store, 1)
	end

	local function ready_to_jump()
		return this.health.dead or jump_id <= 2 and this.nav_path.ni > node_id
	end

	local function y_fly(to, speed, dest_pi)
		this.vis.flags = this.vis.flags_jumping
		this.vis.bans = this.vis.bans_jumping

		local from = this.pos

		SU.remove_modifiers(store, this)

		local af = to.x < from.x

		s_flying.r = V.angleTo(to.x - from.x, to.y - from.y)
		s_flying.flip_y = math.abs(s_flying.r) > math.pi / 2

		S:queue(this.sound_jump)

		local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts, false)
		U.y_wait(store, 1)
		U.y_animation_play(this, "jump", af, store.tick_ts, 1)

		local ground_decal = E:create_entity("decal_boss_pig_ground_fall")

		ground_decal.render.sprites[1].ts = store.tick_ts
		ground_decal.pos.x = this.pos.x
		ground_decal.pos.y = this.pos.y
		ground_decal.tween.ts = store.tick_ts

		queue_insert(store, ground_decal)

		local shadow = E:create_entity(this.shadow)

		shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
		shadow.render.sprites[1].ts = store.tick_ts
		shadow.render.sprites[1].runs = 0
		shadow.tween.props[1].keys[2][1] = 1.5

		queue_insert(store, shadow)

		s_flying.hidden = false

		for _, value in pairs(this.render.sprites) do
			value.hidden = true
		end

		local start_ts = store.tick_ts
		local phase

		repeat
			phase = (store.tick_ts - start_ts) / this.fly_time_up
			d_flying.pos.x = U.ease_value(from.x, from.x, phase, "sine-in")
			d_flying.pos.y = U.ease_value(from.y, 868, phase, "sine-in") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		U.y_wait(store, this.fly_time_out)

		start_ts = store.tick_ts

		local shadow = E:create_entity(this.shadow)

		shadow.pos.x, shadow.pos.y = to.x, to.y
		shadow.render.sprites[1].ts = store.tick_ts
		shadow.render.sprites[1].runs = 0
		shadow.tween.reverse = true
		shadow.tween.props[1].keys[2][1] = this.fly_time_down

		queue_insert(store, shadow)
		S:queue(this.sound_falling)

		repeat
			phase = (store.tick_ts - start_ts) / this.fly_time_down
			d_flying.pos.x = U.ease_value(to.x, to.x, phase, "sine-out")
			d_flying.pos.y = U.ease_value(868, to.y + 150, phase, "sine-out") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		S:queue(this.sound_land)

		this.pos.x, this.pos.y = to.x, to.y
		s_flying.hidden = true
		this.vis.flags = this.vis.flags_normal
		this.vis.bans = this.vis.bans_normal

		for _, value in pairs(this.render.sprites) do
			value.hidden = false
		end

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 2

		queue_insert(store, shake)

		round_idx = round_idx + 1
		megaspawner_boss.manual_wave = string.format("BOSS%i", round_idx)

		local damage_on_fall = E:create_entity(this.aura_damage_on_fall)

		damage_on_fall.pos.x, damage_on_fall.pos.y = this.pos.x, this.pos.y
		damage_on_fall.owner = this
		damage_on_fall.aura.source_id = this.id

		queue_insert(store, damage_on_fall)

		local ground_decal = E:create_entity("decal_boss_pig_ground_fall")

		ground_decal.render.sprites[1].ts = store.tick_ts
		ground_decal.pos.x = this.pos.x
		ground_decal.pos.y = this.pos.y
		ground_decal.tween.ts = store.tick_ts

		queue_insert(store, ground_decal)
		U.y_animation_play(this, "fall", af, store.tick_ts, 1)

		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]

		U.y_wait(store, 1)
	end

	this.vis.flags = this.vis.flags_jumping
	this.vis.bans = this.vis.bans_jumping
	this.phase = "intro"
	this.health_bar.hidden = true
	this.health_bar.hidden = nil

	for _, value in pairs(this.render.sprites) do
		value.hidden = true
	end

	U.y_wait(store, this.fly_time_out)
	y_arrive(this.pos, 2)
	signal.emit("boss_fight_start", this)

	::label_20_0::

	while true do
		if this.health.dead then
			this.phase = "dead"

			LU.kill_all_enemies(store, true)

			megaspawner_boss.interrupt = true

			S:stop_all()
			S:queue(this.sound_events.death)
			U.y_animation_play(this, "death", nil, store.tick_ts)

			if store.level_difficulty == DIFFICULTY_IMPOSSIBLE then
				signal.emit("no_jump_boss-stage06", jump_id)
			end

			signal.emit("boss-killed", this)
			LU.kill_all_enemies(store, true)

			this.phase = "death-complete"

			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			if ready_to_jump() then
				this.ui.can_select = false
				this.health_bar.hidden = true

				y_fly(reach_positions[jump_id], 300, reach_path_id[jump_id])

				jump_id = jump_id + 1

				if jump_id <= 2 then
					local next_jump = jump_positions[jump_id]

					node_id = P:nearest_nodes(next_jump.x, next_jump.y, {this.nav_path.pi})[1][3]
				end

				this.health_bar.hidden = false
				this.ui.can_select = true
			end

			local ok, blocker = SU.y_enemy_walk_until_blocked(store, this, false, ready_to_jump)

			if not ok then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_20_0
					end

					while SU.can_melee_blocker(store, this, blocker) and not ready_to_jump() do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_20_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.boss_machinist = {}

function scripts.boss_machinist.update(this, store, script)
	local a = this.ranged.attacks[1]
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_boss

	for _, value in pairs(spawners) do
		if value.load_file == "level124_spawner" then
			megaspawner_boss = value
		end
	end

	local spawn_ts = store.tick_ts

	U.animation_start(this, "nopilot", nil, store.tick_ts - fts(10), true, 1, true)
	U.y_wait(store, this.descend_duration)

	this.descended = true

	local machinist

	for _, e in pairs(store.entities) do
		if e.template_name == "enemy_machinist" then
			machinist = e

			break
		end
	end

	while not machinist.ready_to_jump do
		coroutine.yield()
	end

	U.y_animation_play(this, "getin", nil, store.tick_ts, 1)
	U.animation_start(this, "run", nil, store.tick_ts, true)
	U.y_wait(store, 0.5)
	signal.emit("boss_fight_start", this)

	megaspawner_boss.manual_wave = "BOSS"
	this.vis.bans = this.vis._bans
	this.walk_ts = store.tick_ts
	this.burn_aura = E:create_entity(this.burn_aura_t)
	this.burn_aura.aura.source_id = this.id

	queue_insert(store, this.burn_aura)

	local function y_on_death()
		LU.kill_all_enemies(store, true)
		S:stop_all()

		megaspawner_boss.interrupt = true

		S:queue(this.sound_death)
		U.animation_start(this, "dyingloop", nil, store.tick_ts, true)

		local death_ts = store.tick_ts

		while store.tick_ts - death_ts < 3 do
			local smoke = E:create_entity(this.death_smoke_fx)

			smoke.pos = V.vclone(this.pos)
			smoke.pos.x = smoke.pos.x + math.random(-20, 20)
			smoke.pos.y = smoke.pos.y + this.flight_height + math.random(-20, 20)
			smoke.render.sprites[1].ts = store.tick_ts

			queue_insert(store, smoke)
			U.y_wait(store, fts(5))

			local particle = E:create_entity(this.death_particle_fx)

			particle.pos = V.vclone(this.pos)
			particle.pos.x = particle.pos.x + math.random(-20, 20)
			particle.pos.y = particle.pos.y + this.flight_height + math.random(-20, 20)
			particle.render.sprites[1].ts = store.tick_ts

			queue_insert(store, particle)
			U.y_wait(store, fts(5))
			LU.kill_all_enemies(store, true)
		end

		this.render.sprites[2].hidden = true

		LU.kill_all_enemies(store, true)
		U.y_animation_play(this, "diefly", nil, store.tick_ts, 1)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)

		this.bossfight_ended = true
	end

	local function start_burn()
		this.burn_aura.tween.disabled = false
		this.burn_aura.tween.reverse = false
		this.burn_aura.tween.ts = store.tick_ts
		this.burn_aura.aura.radius = this.burn_aura.aura._radius

		U.animation_start(this, "firewalkin", nil, store.tick_ts, false)
	end

	local function end_burn()
		this.burn_aura.tween.reverse = true
		this.burn_aura.tween.ts = store.tick_ts
		this.burn_aura.aura.radius = 0

		U.animation_start(this, "firewalkout", nil, store.tick_ts, false)
	end

	local function y_walk_step()
		if this.render.sprites[1].name == "run" then
			local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.burn_aura.aura._radius * 1.5, this.burn_aura.aura.vis_flags, this.burn_aura.aura.vis_bans, function(e, o)
				return e.pos.x > this.pos.x
			end)

			if soldiers and #soldiers > 0 then
				start_burn()
			end
		end

		if this.render.sprites[1].name == "firewalkin" and U.animation_finished(this) then
			U.animation_start(this, "firewalkloop", nil, store.tick_ts, true)
		end

		if this.render.sprites[1].name == "firewalkloop" then
			local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.burn_aura.aura._radius * 1.5, this.burn_aura.aura.vis_flags, this.burn_aura.aura.vis_bans)

			if not soldiers or #soldiers == 0 then
				end_burn()
			end
		end

		if this.render.sprites[1].name == "firewalkout" and U.animation_finished(this) then
			U.animation_start(this, "run", false, store.tick_ts, true)
		end

		local next, new

		if this.motion.forced_waypoint then
			local w = this.motion.forced_waypoint

			next = w

			local dist_limit = 2 * this.motion.real_speed * store.tick_length

			if V.dist2(w.x, w.y, this.pos.x, this.pos.y) < dist_limit * dist_limit then
				this.pos.x, this.pos.y = w.x, w.y
				this.motion.forced_waypoint = nil

				return
			end
		else
			next, new = P:next_entity_node(this, store.tick_length)

			if not next then
				log.debug("enemy %s ran out of nodes to walk", this.id)
				coroutine.yield()

				return
			end
		end

		U.set_destination(this, next)
		U.walk(this, store.tick_length)
		coroutine.yield()

		this.motion.speed.x, this.motion.speed.y = 0, 0
	end

	local function find_targets()
		local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

		if not soldiers or #soldiers == 0 then
			return nil
		else
			table.sort(soldiers, function(e1, e2)
				return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) < V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
			end)
		end

		return soldiers
	end

	local function y_do_attack()
		local attacks = 0

		while attacks < this.attacks_count do
			local soldiers = find_targets()

			if not soldiers or #soldiers == 0 then
				this.walk_ts = store.tick_ts - this.stop_cooldown + 1

				if attacks == 0 then
					return
				else
					break
				end
			end

			if attacks == 0 then
				if this.render.sprites[1].name == "firewalkloop" or this.render.sprites[1].name == "firewalkin" then
					end_burn()
					U.y_animation_play(this, "firewalkout", nil, store.tick_ts, 1)
				end

				U.y_animation_play(this, "attackin", nil, store.tick_ts, 1)

				soldiers = find_targets()

				if not soldiers or #soldiers == 0 then
					break
				end
			end

			local soldier = soldiers[math.random(1, #soldiers)]
			local attack_ts = store.tick_ts

			SU.y_enemy_range_attacks(store, this, soldier)

			local elapsed_time = store.tick_ts - attack_ts

			U.y_wait(store, a.cooldown - elapsed_time)

			attacks = attacks + 1
		end

		this.walk_ts = store.tick_ts + fts(55)

		U.y_animation_play(this, "attackout", nil, store.tick_ts, 1)
		U.animation_start(this, "run", false, store.tick_ts, true, nil, true)
	end

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if store.tick_ts - this.walk_ts > this.stop_cooldown then
				y_do_attack()
			end

			y_walk_step()
		end
	end
end

scripts.boss_deformed_grymbeard = {}

function scripts.boss_deformed_grymbeard.update(this, store)
	local boss_decal

	for i, v in pairs(store.entities) do
		if v.template_name == this.boss_decal_t then
			boss_decal = v
		end
	end

	this.health.hp_max = this.clones_to_die
	this.health.hp = this.clones_to_die

	local spawn_ts = store.tick_ts

	signal.emit("boss_fight_start", this)
	W:start_manual_wave("BOSS1")

	while this.health.hp > 0 do
		if this.trigger_damage_anim then
			this.trigger_damage_anim = false

			S:queue(this.sound_damage)
			U.y_animation_play(boss_decal, "hit", nil, store.tick_ts, 1)
			U.animation_start(boss_decal, "loop", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

function scripts.boss_deformed_grymbeard.on_clone_death(this, store)
	this.trigger_damage_anim = true
	this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp - 1)

	if this.health.hp <= 0 then
		LU.kill_all_enemies(store, true, false)
		S:stop_all()
		W:stop_manual_wave("BOSS1")

		this.health.dead = true

		signal.emit("boss-killed", this)
	end
end

scripts.enemy_deformed_grymbeard_clone = {}

function scripts.enemy_deformed_grymbeard_clone.insert(this, store, script)
	if scripts.enemy_basic.insert(this, store, script) then
		if this.shield then
			this.shield.render.sprites[1].hidden = this.health.hp / this.health.hp_max < this.shield_hp_threshold
		end

		return true
	end

	return false
end

function scripts.enemy_deformed_grymbeard_clone.update(this, store, script)
	local boss

	for i, v in pairs(store.entities) do
		if v.template_name == "boss_deformed_grymbeard" then
			boss = v
		end
	end

	if not this.shield then
		this.shield = E:create_entity(this.shield_t)
		this.shield.render.sprites[1].offset = this.render.sprites[1].offset

		queue_insert(store, this.shield)
	end

	this.shield.pos = this.pos

	local function break_fn()
		if this.shield.render.sprites[1].name == "idle" and this.health.hp / this.health.hp_max < this.shield_hp_threshold then
			U.animation_start(this.shield, "out", nil, store.tick_ts, false)

			this.health.magic_armor = 0
			U.speed_mul(this, this.no_shield_speed_factor)
		end

		if this.shield.render.sprites[1].name == "out" and U.animation_finished(this.shield) then
			this.shield.render.sprites[1].hidden = true
		end
	end

	while true do
		if this.health.dead then
			queue_remove(store, this.shield)

			this.render.sprites[2].hidden = true

			if boss then
				boss:on_clone_death_f(store)
			end

			SU.y_enemy_death(store, this)

			if this.shield then
				queue_remove(store, this.shield)
			end

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			SU.y_enemy_walk_until_blocked(store, this, true, break_fn)
		end
	end
end

function scripts.enemy_deformed_grymbeard_clone.remove(this, store, script)
	if this.shield then
		this.shield.render.sprites[1].hidden = true
	end

	return true
end

scripts.boss_grymbeard = {}

function scripts.boss_grymbeard.update(this, store, script)
	local spawn_ts = store.tick_ts
	local ra = this.ranged.attacks[1]

	local function shoot_clone(spawn_pos, target_pos)
		local b = E:create_entity(this.death_bullet_clone)

		b.pos = V.vclone(spawn_pos)
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(target_pos)
		b.bullet.source_id = this.id
		b.bullet.flight_time = b.bullet.flight_time + fts(math.random(-5, 5))
		b.bullet.rotation_speed = b.bullet.rotation_speed * (0.5 + math.random() * 1.5)

		if math.random(1, 2) == 1 then
			b.bullet.rotation_speed = -b.bullet.rotation_speed
		end

		queue_insert(store, b)
	end

	local function shoot_himself(spawn_pos, target_pos)
		local b = E:create_entity(this.death_bullet_boss)

		b.pos = V.vclone(spawn_pos)
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(target_pos)
		b.bullet.source_id = this.id

		queue_insert(store, b)
	end

	local function shoot_scrap(spawn_pos, target_pos, type)
		local b = E:create_entity(this.death_bullet_scrap .. type)

		b.pos = V.vclone(spawn_pos)
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(target_pos)
		b.bullet.source_id = this.id
		b.bullet.flight_time = b.bullet.flight_time + fts(math.random(-7, 7))
		b.bullet.rotation_speed = b.bullet.rotation_speed * (0.5 + math.random() * 1.5)

		if math.random(1, 2) == 1 then
			b.bullet.rotation_speed = -b.bullet.rotation_speed
		end

		queue_insert(store, b)
	end

	local function y_on_death()
		local function pick_clone_pos(offset_x, spi)
			if this.render.sprites[1].flip_x then
				offset_x = -offset_x
			end

			local nearest_nodes = P:nearest_nodes(this.pos.x + offset_x, this.pos.y)
			local pi, _, ni = unpack(nearest_nodes[1])
			local ni = ni + math.random(-5, 5)
			local pos = P:node_pos(pi, spi, ni)

			if V.dist2(pos.x, pos.y, this.pos.x, this.pos.y) < 2500 then
				ni = ni - 10

				return P:node_pos(pi, spi, ni)
			else
				return pos
			end
		end

		LU.kill_all_enemies(store, true)
		S:stop_all()
		W:stop_manual_wave("BOSS2")
		S:queue(this.sound_death)
		U.animation_start(this, "death", nil, store.tick_ts, false)

		local x_mult = this.render.sprites[1].flip_x and -1 or 1

		U.y_wait(store, fts(2))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 1

		queue_insert(store, shake)

		local t_pos = pick_clone_pos(-150, 2)

		shoot_clone(V.v(this.pos.x - 30 * x_mult, this.pos.y + 120), t_pos)
		U.y_wait(store, fts(64))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 1

		queue_insert(store, shake)

		t_pos = pick_clone_pos(150, 3)

		shoot_clone(V.v(this.pos.x + 30 * x_mult, this.pos.y + 120), t_pos)

		t_pos = pick_clone_pos(180, 2)

		shoot_clone(V.v(this.pos.x + 30 * x_mult, this.pos.y + 120), t_pos)
		U.y_wait(store, fts(48))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 0.5
		shake.aura.freq_factor = 1

		queue_insert(store, shake)

		t_pos = pick_clone_pos(-200, 3)

		shoot_clone(V.v(this.pos.x - 60 * x_mult, this.pos.y + 120), t_pos)
		U.y_wait(store, fts(26))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = 0.5
		shake.aura.freq_factor = 1

		queue_insert(store, shake)

		t_pos = pick_clone_pos(200, 1)

		shoot_clone(V.v(this.pos.x + 10 * x_mult, this.pos.y + 120), t_pos)

		t_pos = pick_clone_pos(230, 2)

		shoot_clone(V.v(this.pos.x + 10 * x_mult, this.pos.y + 120), t_pos)
		U.y_wait(store, fts(52))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 1.5
		shake.aura.duration = 1
		shake.aura.freq_factor = 1.5

		queue_insert(store, shake)

		t_pos = pick_clone_pos(-130, 1)

		shoot_himself(V.v(this.pos.x - 20 * x_mult, this.pos.y + 120), t_pos)

		t_pos = pick_clone_pos(-100, 2)

		shoot_scrap(V.v(this.pos.x - 20 * x_mult, this.pos.y + 120), t_pos, 1)

		t_pos = pick_clone_pos(100, 3)

		shoot_scrap(V.v(this.pos.x - 20 * x_mult, this.pos.y + 120), t_pos, 1)

		t_pos = pick_clone_pos(150, 2)

		shoot_scrap(V.v(this.pos.x - 20 * x_mult, this.pos.y + 120), t_pos, 2)
		U.y_animation_wait(this)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)

		this.bossfight_ended = true
	end

	U.animation_start(this, "walk", nil, store.tick_ts, true)
	signal.emit("boss_fight_start", this)
	W:start_manual_wave("BOSS2")

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			local function check_ranged()
				if not ra.disabled and (not ra.requires_magic or this.enemy.can_do_magic) and (ra.hold_advance or store.tick_ts - ra.ts > ra.cooldown) then
					local ranged = U.find_nearest_soldier(store.soldiers, this.pos, ra.min_range, ra.max_range, ra.vis_flags, ra.vis_bans)

					return ranged
				end

				return nil
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_1668_0
					end

					while SU.can_melee_blocker(store, this, blocker) do
						ranged = check_ranged()

						if ranged then
							break
						end

						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_1668_0
						end

						coroutine.yield()
					end
				end

				if ranged then
					while SU.can_range_soldier(store, this, ranged) do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							break
						end

						coroutine.yield()
					end
				end
			end
		end

		::label_1668_0::

		coroutine.yield()
	end
end

scripts.bullet_boss_grymbeard = {}

function scripts.bullet_boss_grymbeard.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local source = store.entities[b.source_id]
	local ps

	if not source then
		queue_remove(store, this)
		return
	end

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 8 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	local function fly_to_pos(target_pos)
		local start_ts = store.tick_ts
		local last_pos = V.vclone(this.pos)
		local dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)

		while V.len(dx, dy) > 20 do
			last_pos.x, last_pos.y = this.pos.x, this.pos.y

			move_step(target_pos)

			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
			ps.particle_system.emit_offset.x, ps.particle_system.emit_offset.y = V.rotate(this.render.sprites[1].r, ps.emit_offset_relative.x, ps.emit_offset_relative.y)
			dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)
			dist = V.len(dx, dy)

			coroutine.yield()
		end
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local spawn_pos = V.vclone(this.pos)
	local source_pos = V.vclone(source.pos)
	local attack = source.ranged.attacks[1]

	fm.a.x, fm.a.y = 0, 180

	local target_pos = v(spawn_pos.x, source_pos.y + 230)

	fly_to_pos(target_pos)

	local side_flip = 1

	if target and target.pos.x < spawn_pos.x then
		side_flip = -1
	end

	fm.a.x, fm.a.y = 100, 0

	local target_pos = v(spawn_pos.x + 70 * side_flip, source_pos.y + 230)

	fly_to_pos(target_pos)

	target_pos = v(spawn_pos.x + 35 * side_flip, source_pos.y + 200)

	fly_to_pos(target_pos)

	target_pos = v(spawn_pos.x, source_pos.y + 230)

	fly_to_pos(target_pos)

	target_pos = v(spawn_pos.x, source_pos.y + 280)

	fly_to_pos(target_pos)

	if target then
		target_pos = v(target.pos.x, source_pos.y + 280)

		fly_to_pos(target_pos)
	end

	fm.a_step = 5
	fm.max_a = 2700
	fm.max_v = 900
	ps.particle_system.emission_rate = 90

	if not target or target.health.dead then
		local new_target, targets = U.find_foremost_enemy(store.entities, source_pos, 0, attack.max_range, false, attack.vis_flags, attack.vis_bans, attack.filter_fn)

		if new_target then
			b.target_id = new_target.id
		end
	end

	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	if target and band(target.vis.flags, F_FLYING) ~= 0 then
		b.ignore_hit_offset = false
	end

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local hit_offset = V.v(0, 0)

			if not b.ignore_hit_offset then
				hit_offset.x = target.unit.hit_offset.x
				hit_offset.y = target.unit.hit_offset.y
			end

			b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
			ps.particle_system.emit_offset.x, ps.particle_system.emit_offset.y = V.rotate(this.render.sprites[1].r, ps.emit_offset_relative.x, ps.emit_offset_relative.y)
		end

		coroutine.yield()
	end

	this.render.sprites[1].hidden = 0

	if b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	S:queue(this.sound_events.hit)

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos = V.vclone(b.to)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end

	U.y_animation_wait(this)
	queue_remove(store, this)
end

scripts.boss_spider_queen = {}

function scripts.boss_spider_queen.update(this, store, script)
	local a_stun_towers = this.timed_attacks.list[1]
	local a_webspit = this.timed_attacks.list[2]
	local a_drain_life = this.timed_attacks.list[3]
	local a_call_wardens = this.timed_attacks.list[4]
	local a

	this.fly_time_up = 0.5
	this.fly_time_down = 0.4
	this.fly_time_out = 0.5
	this.fly_offset_y = 60

	local drain_decal_fade_start_ts = store.tick_ts
	local jump_id = 1
	local d_flying = E:create_entity("decal_boss_spider_queen_flying")
	local s_flying = d_flying.render.sprites[1]

	queue_insert(store, d_flying)

	a_webspit.ts = store.tick_ts - (a_webspit.cooldown - a_webspit.first_cooldown)
	a_call_wardens.ts = store.tick_ts - (a_call_wardens.cooldown - a_call_wardens.first_cooldown)

	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		this.health_bar.hidden = true

		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local function filter_tower_fn(v, origin, attack)
		return v.vis and band(v.vis.flags, a.vis_bans) == 0 and band(v.vis.bans, a.vis_flags) == 0 and (not a.exclude_tower_kind or not table.contains(a.exclude_tower_kind, v.tower.kind)) and v.tower.can_be_mod
	end

	local function is_after_nodes_limit(attack)
		local nodes_to_goal = P:nodes_to_goal(this.nav_path)

		return nodes_to_goal < attack.nodes_limit
	end

	local function can_stun_towers()
		local aa = a_stun_towers

		if is_after_nodes_limit(aa) then
			return false
		end

		return store.tick_ts - aa.ts > aa.cooldown
	end

	local function can_webspitting()
		local aa = a_webspit

		if is_after_nodes_limit(aa) then
			return false
		end

		return store.tick_ts - aa.ts > aa.cooldown
	end

	local function can_call_wardens()
		local aa = a_call_wardens

		if jump_id <= 1 or is_after_nodes_limit(aa) then
			return false
		end

		return store.tick_ts - aa.ts > aa.cooldown
	end

	local function can_drain_life()
		local aa = a_drain_life

		if is_after_nodes_limit(aa) then
			return false
		end

		return store.tick_ts - aa.ts > aa.cooldown
	end

	local function ready_to_jump()
		return jump_id <= #this.reach_nodes and this.nav_path.ni > this.reach_nodes[jump_id]
	end

	local function break_fn()
		return can_stun_towers() or can_webspitting() or can_call_wardens() or can_drain_life() or ready_to_jump()
	end

	local function melee_break_fn()
		return break_fn()
	end

	local function range_break_fn()
		return break_fn()
	end

	local function filter_same_side(towers)
		return table.filter(towers, function(k, v)
			return v.pos.x >= this.pos.x and not this.render.sprites[1].flip_x or v.pos.x < this.pos.x and this.render.sprites[1].flip_x
		end)
	end

	local function y_on_death()
		--W:stop_manual_wave("BOSS1")
		LU.kill_all_enemies(store, true)
		S:stop_all()
		S:queue(this.sound_death)
		U.animation_start(this, "death", nil, store.tick_ts, false, 1)
		LU.kill_all_enemies(store, true)
		signal.emit("boss-killed", this)

		store.level.bossfight_ended = true
	end

	local function y_fly(to, speed, dest_pi)
		this.vis.flags = this.vis.flags_jumping
		this.vis.bans = this.vis.bans_jumping

		local from = this.pos

		SU.remove_modifiers(store, this)

		local af = to.x < from.x

		s_flying.r = V.angleTo(to.x - from.x, to.y - from.y)
		s_flying.flip_y = math.abs(s_flying.r) > math.pi / 2

		S:queue(this.sound_jump)

		local an, af = U.animation_name_facing_point(this, "idle", this.motion.dest)

		U.animation_start(this, an, af, store.tick_ts, false, 1)
		U.y_wait(store, 1)
		U.y_animation_play(this, "jump_in", nil, store.tick_ts, 1, 1)
		S:queue("Stage30BossfightJump")

		s_flying.hidden = false

		for _, value in pairs(this.render.sprites) do
			value.hidden = true
		end

		local start_ts = store.tick_ts
		local phase

		repeat
			phase = (store.tick_ts - start_ts) / this.fly_time_up
			d_flying.pos.x = U.ease_value(from.x, from.x, phase, "sine-in")
			d_flying.pos.y = U.ease_value(from.y, 868, phase, "sine-in") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		U.y_wait(store, this.fly_time_out)

		start_ts = store.tick_ts

		repeat
			phase = (store.tick_ts - start_ts) / this.fly_time_down
			d_flying.pos.x = U.ease_value(to.x, to.x, phase, "sine-out")
			d_flying.pos.y = U.ease_value(868, to.y + 20, phase, "sine-out") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		S:queue(this.sound_land)

		this.pos.x, this.pos.y = to.x, to.y
		s_flying.hidden = true
		this.vis.flags = this.vis.flags_normal
		this.vis.bans = this.vis.bans_normal

		for _, value in pairs(this.render.sprites) do
			value.hidden = false
		end

		S:queue("Stage30BossfightFall")
		U.y_animation_play(this, "jump_out", af, store.tick_ts, 1, 1)

		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]

		U.y_wait(store, 1)
	end

	a_drain_life.ts = store.tick_ts - a_drain_life.cooldown + a_drain_life.cooldown_init

	::label_224_0::

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if ready_to_jump() then
				this.ui.can_select = false
				this.health_bar.hidden = true

				local dest = P:node_pos(this.jump_paths[jump_id], 1, this.jump_nodes[jump_id])

				y_fly(dest, 300, this.jump_paths[jump_id])

				if jump_id == 1 then
					a_call_wardens.ts = store.tick_ts - (a_call_wardens.cooldown - a_call_wardens.first_cooldown)
				end

				jump_id = jump_id + 1
				this.health_bar.hidden = false
				this.ui.can_select = true
			end

			a = a_stun_towers

			if can_stun_towers() then
				local towers = U.find_towers_in_range(store.towers, this.pos, a, filter_tower_fn)

				if not towers or #towers < a.min_targets then
					SU.delay_attack(store, a, fts(10))
				else
					local towers_to_same_side = filter_same_side(towers)
					local af

					if towers_to_same_side and #towers_to_same_side > 0 then
						towers = towers_to_same_side
					else
						af = not this.render.sprites[1].flip_x
					end

					U.animation_start(this, a.animation_start, af, store.tick_ts, false, 1)

					if SU.y_enemy_wait(store, this, a.shoot_time) then
						SU.delay_attack(store, a, fts(10))
					else
						towers = U.find_towers_in_range(store.towers, this.pos, a, filter_tower_fn)

						if towers then
							if #towers > a.max_targets then
								towers = table.random_order(towers)
								towers = table.slice(towers, 1, a.max_targets)
							end

							for _, t in pairs(towers) do
								local proy_amount = math.random(2, 4)

								for i = 1, proy_amount do
									local bullet = E:create_entity(a.bullet)

									bullet.pos = V.vclone(this.pos)

									local offset = a.bullet_start_offset[1]

									bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
									bullet.pos.x = bullet.pos.x - 8 + 16

									math.random()

									bullet.pos.y = bullet.pos.y - 8 + 16

									math.random()

									bullet.bullet.from = V.vclone(bullet.pos)
									bullet.bullet.to = V.v(t.pos.x - 30 + 15 * i, t.pos.y + 30 - 10 + 20 * math.random())
									bullet.bullet.target_id = t.id
									bullet.bullet.source_id = this.id
									bullet.render.sprites[1].scale = V.vv(bullet.render.sprites[1].scale.x - 0.3 + 0.3 * math.random())
									bullet.bullet.flight_time = bullet.bullet.flight_time + table.random({fts(-1), fts(0), fts(1)})

									queue_insert(store, bullet)
								end

								U.y_wait(store, fts(4))
							end
						end

						a.ts = store.tick_ts

						U.y_animation_wait(this, 1)
						U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
						U.y_wait(store, 1)
						U.animation_start(this, a.animation_end, nil, store.tick_ts, false, 1, true)
						U.y_wait(store, fts(23))

						local shake = E:create_entity("aura_screen_shake")

						shake.aura.amplitude = 0.4
						shake.aura.duration = fts(30)
						shake.aura.freq_factor = 3

						LU.queue_insert(store, shake)
						U.y_animation_wait(this, 1)

						goto label_224_0
					end
				end
			end

			a = a_webspit

			if can_webspitting() then
				S:queue("Stage30BossfightSpit")
				U.animation_start(this, a.animation, nil, store.tick_ts, false, 1)

				if SU.y_enemy_wait(store, this, a.cast_time) then
					SU.delay_attack(store, a, fts(10))
				else
					local all_decals_pos = {}

					for i = 1, 5 do
						local decal = E:create_entity(a.decal)

						decal.render.sprites[1].name = decal.render.sprites[1].name .. "_000" .. table.random({"1", "2"})
						decal.render.sprites[1].flip_x = table.random({true, false})

						local centerX, centerY = 512, 384
						local offsetX, offsetY = centerX * 1, centerY * 1

						for i = 1, 8 do
							decal.pos = V.v(centerX - offsetX + offsetX * 2 * math.random(), centerY - offsetY + offsetY * 2 * math.random())

							local viable_pos = true

							for _, p in pairs(all_decals_pos) do
								if V.dist(decal.pos.x, decal.pos.y, p.x, p.y) < 170 then
									viable_pos = false

									break
								end
							end

							if viable_pos then
								break
							end
						end

						table.insert(all_decals_pos, V.vclone(decal.pos))

						decal.render.sprites[1].ts = store.tick_ts

						queue_insert(store, decal)
					end

					a.ts = store.tick_ts

					if SU.y_enemy_animation_wait(this) then
					-- block empty
					end

					goto label_224_0
				end
			end

			a = a_call_wardens

			if can_call_wardens() then
				U.animation_start(this, a.animation, nil, store.tick_ts, false, 1)

				if SU.y_enemy_wait(store, this, a.cast_time) then
					SU.delay_attack(store, a, fts(10))
				else
					S:queue("Stage30BossfightBuffCharge")

					if a.use_custom_formation then
						local random_formation = table.random(a.custom_formation)

						for _, v in pairs(random_formation) do
							local ni = this.nav_path.ni + v.n

							if P:is_node_valid(this.nav_path.pi, ni) then
								local obj = E:create_entity(a.object)

								obj.pos = P:node_pos(this.nav_path.pi, v.spi, ni)
								obj.render.sprites[1].flip_x = this.render.sprites[1].flip_x
								obj.pi = this.nav_path.pi
								obj.spi = spi
								obj.ni = ni

								queue_insert(store, obj)
							end
						end
					else
						local sign = 1
						local sign_offset = 1
						local nodes_to_goal = P:nodes_to_goal(this.nav_path)

						if nodes_to_goal < a.nodes_limit_reverse then
							sign_offset = -1
						end

						local current_offset = a.nodes_spread_start

						log.todo("CALL WARDENS SIGN %s", tostring(sign_offset))

						for i = 1, a.amount do
							local ni = this.nav_path.ni + a.nodes_offset * sign_offset + current_offset * sign

							if P:is_node_valid(this.nav_path.pi, ni) then
								local spi = math.random(1, 3)
								local obj = E:create_entity(a.object)

								obj.pos = P:node_pos(this.nav_path.pi, spi, ni)
								obj.render.sprites[1].flip_x = this.render.sprites[1].flip_x
								obj.pi = this.nav_path.pi
								obj.spi = spi
								obj.ni = ni

								queue_insert(store, obj)
							end

							if sign == -1 then
								current_offset = current_offset + a.nodes_spread
							end

							sign = -sign
						end
					end

					a.ts = store.tick_ts

					if SU.y_enemy_animation_wait(this) then
					-- block empty
					end

					goto label_224_0
				end
			end

			a = a_drain_life

			if can_drain_life() then
				local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not soldiers or #soldiers < a.min_targets then
					SU.delay_attack(store, a, fts(10))
				else
					local start_ts = store.tick_ts

					this.render.sprites[2].hidden = false

					U.animation_start(this, "loop", nil, store.tick_ts, true, 2, true)
					U.animation_start(this, a.animation_start, nil, store.tick_ts, 1, 1)
					U.y_wait(store, fts(25))
					S:queue("Stage30BossfightDrainLoopStart")
					SU.y_enemy_animation_wait(this)
					S:queue("Stage30BossfightDrainLoop")
					U.animation_start(this, a.animation_loop, nil, store.tick_ts, true, 1, true)

					local loop_start_ts = store.tick_ts
					local last_loop_lifesteal_ts = store.tick_ts - a.mod_loop_every

					while store.tick_ts - loop_start_ts < a.loop_duration do
						if SU.enemy_interrupted(this) then
							goto label_224_1
						end

						if store.tick_ts - last_loop_lifesteal_ts > a.mod_loop_every then
							last_loop_lifesteal_ts = store.tick_ts
							soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

							if soldiers then
								if #soldiers > a.max_targets then
									soldiers = table.random_order(soldiers)
									soldiers = table.slice(soldiers, 1, a.max_targets)
								end

								for _, s in pairs(soldiers) do
									local mod = E:create_entity(a.mod_loop)

									mod.modifier.target_id = s.id
									mod.modifier.source_id = this.id

									queue_insert(store, mod)
								end

								local rs = table.random(soldiers)
								local bullet = E:create_entity(a.bullet)

								bullet.pos = V.vclone(rs.pos)

								if rs.unit and rs.unit.mod_offset then
									bullet.pos.x, bullet.pos.y = bullet.pos.x + rs.unit.mod_offset.x, bullet.pos.y + rs.unit.mod_offset.y
								end

								bullet.bullet.from = V.vclone(bullet.pos)
								bullet.bullet.to = V.v(this.pos.x + (this.render.sprites[1].flip_x and -a.drain_center_offset.x or a.drain_center_offset.x), this.pos.y + a.drain_center_offset.y)
								bullet.bullet.target_id = rs.id
								bullet.bullet.source_id = this.id

								queue_insert(store, bullet)
							end
						end

						coroutine.yield()
					end

					U.animation_start(this, a.animation_end_success, nil, store.tick_ts, false, 1, true)
					U.y_wait(store, fts(14))

					soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

					if soldiers then
						if #soldiers > a.max_targets then
							soldiers = table.random_order(soldiers)
							soldiers = table.slice(soldiers, 1, a.max_targets)
						end

						for _, s in pairs(soldiers) do
							local bullet = E:create_entity(a.bullet)

							bullet.pos = V.vclone(s.pos)

							if s.unit and s.unit.mod_offset then
								bullet.pos.x, bullet.pos.y = bullet.pos.x + s.unit.mod_offset.x, bullet.pos.y + s.unit.mod_offset.y
							end

							bullet.bullet.from = V.vclone(bullet.pos)
							bullet.bullet.to = V.v(this.pos.x + (this.render.sprites[1].flip_x and -a.drain_center_offset.x or a.drain_center_offset.x), this.pos.y + a.drain_center_offset.y)
							bullet.bullet.target_id = s.id
							bullet.bullet.source_id = this.id
							bullet.bullet.hit_fx = nil

							queue_insert(store, bullet)

							local fx_units = E:create_entity(a.fx_end_units)

							fx_units.pos = V.vclone(s.pos)
							fx_units.render.sprites[1].ts = store.tick_ts

							queue_insert(store, fx_units)

							local mod = E:create_entity(a.mod_end)

							mod.modifier.target_id = s.id
							mod.modifier.source_id = this.id

							queue_insert(store, mod)
						end

						S:stop("Stage30BossfightDrainLoop")
						S:queue("Stage30BossfightDrainExecute")
						U.y_animation_play(this, "out", nil, store.tick_ts, 1, 2)

						this.render.sprites[2].hidden = true

						U.y_animation_wait(this, 1)

						goto label_224_2
					end

					::label_224_1::

					S:stop("Stage30BossfightDrainLoop")
					U.animation_start(this, a.animation_end_fail, nil, store.tick_ts, false, 1, true)

					drain_decal_fade_start_ts = store.tick_ts

					while store.tick_ts - drain_decal_fade_start_ts < fts(16) do
						this.render.sprites[2].alpha = this.render.sprites[2].alpha * 0.9

						coroutine.yield()
					end

					this.render.sprites[2].alpha = 255
					this.render.sprites[2].hidden = true

					U.y_animation_wait(this, 1, 1)

					::label_224_2::

					a.ts = store.tick_ts

					goto label_224_0
				end
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_224_0
					end

					while SU.can_melee_blocker(store, this, blocker) and (not melee_break_fn or not melee_break_fn(store, this)) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_224_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and (not range_break_fn or not range_break_fn(store, this)) do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_224_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end

scripts.decal_boss_spider_queen_spawns = {}

function scripts.decal_boss_spider_queen_spawns.update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
	U.y_wait(store, fts(14))

	local obj = E:create_entity(this.object)

	obj.pos = V.vclone(this.pos)
	obj.render.sprites[1].flip_x = this.render.sprites[1].flip_x
	obj.nav_path.pi = this.pi
	obj.nav_path.spi = this.spi
	obj.nav_path.ni = this.ni

	queue_insert(store, obj)

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
	queue_remove(store, this)
end

scripts.mod_boss_spider_queen_area_lifesteal = {}

function scripts.mod_boss_spider_queen_area_lifesteal.insert(this, store)
	local source = store.entities[this.modifier.source_id]
	local target = store.entities[this.modifier.target_id]
	local damage = 0

	if target and target.health then
		local dmg_value = this.damage

		if this.damage_min then
			local damage_min = SU.get_difficulty_field_value(store, this.damage_min)
			local damage_max = SU.get_difficulty_field_value(store, this.damage_max)

			dmg_value = math.random(damage_min, damage_max)
		end

		local d = E:create_entity("damage")

		d.value = dmg_value
		d.source_id = this.id
		d.target_id = target.id
		d.damage_type = this.damage_type

		queue_damage(store, d)

		damage = U.predict_damage(target, d)
	end

	if source then
		local heal_hp = SU.get_difficulty_field_value(store, this.heal_hp_fixed)

		if this.heal_hp_damage_factor then
			heal_hp = heal_hp + damage * this.heal_hp_damage_factor
		end

		U.heal(source, heal_hp)
	end

	return false
end

scripts.aura_boss_spider_queen_spiderweb = {}

function scripts.aura_boss_spider_queen_spiderweb.update(this, store, script)
	this.aura.ts = store.tick_ts

	local last_pos_created = V.vclone(this.pos)
	local last_ts = store.tick_ts

	while true do
		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead then
				queue_remove(store, this)

				return
			end

			if te and te.pos then
				this.pos.x, this.pos.y = te.pos.x, te.pos.y

				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {te.nav_path.pi}, {1}, false)
				local pi, spi, ni = unpack(nodes[1])
				local n_pos = P:node_pos(pi, spi, ni)

				if V.dist(last_pos_created.x, last_pos_created.y, n_pos.x, n_pos.y) >= this.min_decal_distance or store.tick_ts - last_ts > this.decal_duration - 0.5 then
					local decal = E:create_entity(this.decal)
					local offsetX, offsetY = 6, 6

					decal.pos = V.v(n_pos.x - offsetX + offsetX * 2 * math.random(), n_pos.y - offsetY + offsetY * 2 * math.random())
					decal.render.sprites[1].ts = store.tick_ts

					queue_insert(store, decal)

					last_pos_created = V.vclone(n_pos)
					last_ts = store.tick_ts
				end
			else
				queue_remove(store, this)
			end
		end

		U.y_wait(store, this.aura.cycle_time)
	end
end

scripts.mod_boss_spider_queen_tower_debuff = {}

function scripts.mod_boss_spider_queen_tower_debuff.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.vis or band(this.modifier.vis_flags, target.vis.bans) ~= 0 then
		return false
	end

	return true
end

function scripts.mod_boss_spider_queen_tower_debuff.update(this, store)
	local clicks = 0
	local s_tap = this.render.sprites[this.render.sid_hand]
	local m = this.modifier
	local duration = SU.get_difficulty_field_value(store, m.duration)
	local duration_long = SU.get_difficulty_field_value(store, m.duration_long)
	local target = store.entities[m.target_id]
	local source = store.entities[m.source_id]

	if not target then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts
	this.pos = V.vclone(target.pos)

	local click_rect_y = this.ui.click_rect.pos.y + this.pos.y

	if this.tween and not this.tween.disabled then
		this.tween.ts = store.tick_ts
	end

	this.render.sprites[this.render.sid_mask].pos = V.vclone(this.pos)
	s_tap.pos = V.vclone(this.pos)
	this.pos.y = target.pos.y + REF_H

	U.y_animation_play(this, "in", nil, store.tick_ts, 1, this.render.sid_mask)
	U.animation_start(this, "idle_lvl_1", nil, store.tick_ts, true, this.render.sid_mask)

	s_tap.hidden = nil

	SU.tower_block_inc(target)

	local start_ts = store.tick_ts
	local long_block_ts = store.tick_ts

	SU.ui_click_proxy_add(target, this)

	local spiders_appear_delay = fts(40)
	local spiders_arrive_duration = 2
	local dist_to_top = REF_H - target.pos.y + 50 * math.random()
	local ref_speed = REF_H / spiders_arrive_duration

	spiders_arrive_duration = dist_to_top / ref_speed

	local animation_release
	local animation_started = false
	local spiders_arrived = false
	local spiders_netting = false
	local spiders_exit = false
	local phase, mod_hide

	while clicks < this.required_clicks and duration > store.tick_ts - start_ts do
		if store.tick_ts - start_ts > duration - fts(26) and not animation_started then
			U.animation_start(this, "in_2", nil, store.tick_ts, false, this.render.sid_mask, false)

			animation_started = true
		end

		if IS_CONSOLE then
			if target.ui.hover_controller_active then
				s_tap.alpha = s_tap.alpha_focused
				s_tap.name = s_tap.name_focused
			else
				s_tap.alpha = s_tap.alpha_unfocused
				s_tap.name = s_tap.name_unfocused
			end
		end

		phase = (store.tick_ts - (start_ts + spiders_appear_delay)) / spiders_arrive_duration
		this.pos.y = U.ease_value(target.pos.y + dist_to_top, target.pos.y, phase, "sine-in")
		this.ui.click_rect.pos.y = click_rect_y - this.pos.y

		for i = this.render.sid_threads_start, this.render.sid_threads_end do
			this.render.sprites[i].sort_y_offset = target.pos.y - this.pos.y - 5
		end

		for i = this.render.sid_spiders_start, this.render.sid_spiders_end do
			this.render.sprites[i].sort_y_offset = target.pos.y - this.pos.y - 5
		end

		if this.pos.y < target.pos.y + 20 then
			if not spiders_arrived then
				spiders_arrived = true

				U.animation_start_group(this, "arrive", nil, store.tick_ts, false, "spiders")
			elseif not spiders_netting and U.animation_finished_group(this, "spiders") then
				spiders_netting = true

				U.animation_start_group(this, "netting", nil, store.tick_ts, true, "spiders")
			end
		end

		if this.ui.clicked then
			local fx = E:create_entity(this.tap_fx)

			fx.pos = V.v(target.pos.x - 20 + math.random() * 40, target.pos.y - 20 + math.random() * 40 + 30)
			fx.render.sprites[1].ts = store.tick_ts

			queue_insert(store, fx)
			S:queue(this.sound_click)

			this.ui.clicked = nil
			clicks = clicks + 1

			if clicks >= this.required_clicks then
				animation_release = "death_2"

				for i = this.render.sid_spiders_start, this.render.sid_spiders_end do
					this.render.sprites[i].runs = 0
					this.render.sprites[i].hide_after_runs = 1
				end

				U.animation_start_group(this, "explode", nil, store.tick_ts, false, "spiders")

				goto label_243_0
			end
		end

		if this.remove then
			animation_release = "death_2"

			for i = this.render.sid_spiders_start, this.render.sid_spiders_end do
				this.render.sprites[i].runs = 0
				this.render.sprites[i].hide_after_runs = 1
			end

			U.animation_start_group(this, "explode", nil, store.tick_ts, false, "spiders")

			goto label_243_0
		end

		coroutine.yield()
	end

	mod_hide = E:create_entity("mod_hide_tower")
	mod_hide.modifier.target_id = target.id
	mod_hide.modifier.source_id = this.id
	mod_hide.skip_modifiers = {this.template_name}
	mod_hide.handle_stun = false

	queue_insert(store, mod_hide)
	U.animation_start(this, "idle_lvl_2", nil, store.tick_ts, true, this.render.sid_mask)

	animation_release = "death_1"
	s_tap.hidden = true
	target.ui.can_click = false
	target.tower.blocked = true

	S:queue(this.sound_blocked)
	U.animation_start_group(this, "climbUpStart", nil, store.tick_ts, false, "spiders")

	long_block_ts = store.tick_ts

	while duration_long > store.tick_ts - start_ts do
		if this.remove then
			SU.remove_modifiers(store, target, "mod_hide_tower")

			goto label_243_0
		end

		phase = (store.tick_ts - long_block_ts) / 2
		this.pos.y = U.ease_value(target.pos.y, target.pos.y + REF_H, phase, "sine-out")

		for i = this.render.sid_threads_start, this.render.sid_threads_end do
			this.render.sprites[i].sort_y_offset = target.pos.y - this.pos.y - 5
		end

		for i = this.render.sid_spiders_start, this.render.sid_spiders_end do
			this.render.sprites[i].sort_y_offset = target.pos.y - this.pos.y - 5
		end

		if not spiders_exit and U.animation_finished_group(this, "spiders") then
			spiders_exit = true

			U.animation_start_group(this, "climbingUpIdle", nil, store.tick_ts, true, "spiders")
		end

		coroutine.yield()
	end

	SU.remove_modifiers(store, target, "mod_hide_tower")

	::label_243_0::

	SU.ui_click_proxy_remove(target, this)

	s_tap.hidden = true

	S:queue(this.sound_released)

	this.render.sprites[this.render.sid_mask].runs = 0
	this.render.sprites[this.render.sid_mask].hide_after_runs = 1

	U.animation_start(this, animation_release, nil, store.tick_ts, false, this.render.sid_mask, true)

	local removed_block = false

	for i2 = 1, this.threads_amount do
		for i1 = 1, 3 do
			local sid_thread = this.render.sid_threads_start + this.threads_amount * (i1 - 1) + i2 - 1

			this.render.sprites[sid_thread].runs = 0
			this.render.sprites[sid_thread].hide_after_runs = 1

			U.animation_start(this, "dissolve", nil, store.tick_ts, false, sid_thread, true)
		end

		if not removed_block and (U.animation_finished(this, this.render.sid_mask) or this.render.sprites[this.render.sid_mask].hidden) then
			removed_block = true

			SU.tower_block_dec(target)
		end

		U.y_wait(store, fts(1))
	end

	if not removed_block and (U.animation_finished(this, this.render.sid_mask) or this.render.sprites[this.render.sid_mask].hidden) then
		removed_block = true

		SU.tower_block_dec(target)
	end

	queue_remove(store, this)
end

scripts.bullet_boss_spider_queen_tower_stun = {}

function scripts.bullet_boss_spider_queen_tower_stun.update(this, store, script)
	local b = this.bullet

	if not this.render.sprites[1].scale then
		this.render.sprites[1].scale = V.vv(1)
	end

	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		ps.particle_system.scales_x[1] = this.render.sprites[1].scale.x
		ps.particle_system.scales_y[1] = this.render.sprites[1].scale.y

		queue_insert(store, ps)
	end

	local ps2

	if b.particles_name_2 then
		ps2 = E:create_entity(b.particles_name_2)
		ps2.particle_system.track_id = this.id
		ps.particle_system.scales_x[1] = this.render.sprites[1].scale.x
		ps.particle_system.scales_y[1] = this.render.sprites[1].scale.y

		queue_insert(store, ps2)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	if b.target_id then
		local target = store.entities[b.target_id]

		if target and b.hit_mod then
			local mod = E:create_entity(b.hit_mod)

			mod.modifier.target_id = target.id
			mod.modifier.source_id = b.source

			queue_insert(store, mod)
		end
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(this.pos)
		sfx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, sfx)
	end

	queue_remove(store, this)
end

scripts.editor_aura_spider_web_sprint = {}

function scripts.editor_aura_spider_web_sprint.update(this, store)
	while true do
		this.render.sprites[1].scale = V.vv(this.aura.radius / 50)

		coroutine.yield()
	end
end

scripts.decal_boss_spider_queen_spiderweb = {}

function scripts.decal_boss_spider_queen_spiderweb.insert(this, store, script)
	this.render.sprites[1].name = this.render.sprites[1].name .. "_000" .. table.random({"1", "2"})
	this.render.sprites[1].scale = V.vv(0.85 + math.random() * 0.15)
	this.render.sprites[1].flip_x = table.random({true, false})

	for _, a in pairs(this.auras.list) do
		a.ts = store.tick_ts

		if a.cooldown == 0 then
			local e = E:create_entity(a.name)

			e.pos = V.vclone(this.pos)
			e.aura.source_id = this.id
			e.aura.ts = store.tick_ts
			e.aura.track_source = true

			queue_insert(store, e)
		end
	end

	return true
end

scripts.aura_spider_webs = {}

function scripts.aura_spider_webs.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id) and (not this.aura.ignore_flywalk or not v.on_flywalk)
			end)

			for i, target in ipairs(targets) do
				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					queue_insert(store, new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_247_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	queue_remove(store, this)
end

scripts.boss_redboy_teen = {}

function scripts.boss_redboy_teen.insert(this, store, script)
	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)

		for _, a in pairs(this.melee.attacks) do
			a.ts = store.tick_ts
		end
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)

		for _, a in pairs(this.ranged.attacks) do
			a.ts = store.tick_ts
		end
	end

	if this.auras then
		for _, a in pairs(this.auras.list) do
			a.ts = store.tick_ts

			if a.cooldown == 0 then
				local e = E:create_entity(a.name)

				e.pos = V.vclone(this.pos)
				e.aura.level = this.unit.level
				e.aura.source_id = this.id
				e.aura.ts = store.tick_ts

				queue_insert(store, e)
			end
		end
	end

	this.enemy.gold_bag = math.ceil(this.enemy.gold * 0.3)

	if this.water and this.spawn_data and this.spawn_data.water_ignore_pi then
		this.water.ignore_pi = this.spawn_data.water_ignore_pi
	end

	return true
end

function scripts.boss_redboy_teen.update(this, store, script)
	local a_summon = this.timed_attacks.list[1]
	local a_block_power = this.timed_attacks.list[2]
	local a_meteorite = this.timed_attacks.list[3]
	local a_fireabsorb = this.timed_attacks.list[4]
	local a_stun_towers = this.timed_attacks.list[5]
	local a
	local change_path_node_start = P:nearest_nodes(this.change_path_node_start_pos.x, this.change_path_node_start_pos.y, {this.nav_path.pi})[1][3]
	local jumped = false

	a_summon.ts = store.tick_ts - a_summon.cooldown + a_summon.first_cooldown
	a_block_power.ts = store.tick_ts - a_block_power.cooldown + a_block_power.first_cooldown
	a_fireabsorb.ts = store.tick_ts - a_fireabsorb.cooldown + a_fireabsorb.first_cooldown
	a_stun_towers.ts = store.tick_ts - a_stun_towers.cooldown + a_stun_towers.first_cooldown
	a_meteorite.activate_on_nodes = {}

	for path_i, mconfig_array in pairs(a_meteorite.activate_on_positions) do
		a_meteorite.activate_on_nodes[path_i] = {}

		for _, mconfig in pairs(mconfig_array) do
			local npos = P:nearest_nodes(mconfig.pos.x, mconfig.pos.y, {path_i})[1][3]

			table.insert(a_meteorite.activate_on_nodes[path_i], {
				node = npos,
				side = mconfig.side
			})
		end
	end

	if this.render.sprites[1].name == "spawn" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end

		this.health_bar.hidden = true

		local an, af = U.animation_name_facing_point(this, "spawn", this.motion.dest)

		U.y_animation_play(this, an, af, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local function set_exo_for_anim(anim)
		this.render.sprites[1].prefix = this.exo_anim_map[anim]
	end

	this.fly_time_up = 0.5
	this.fly_time_down = 0.4
	this.fly_offset_y = 0

	local function y_fly(to, dest_pi, skip_landing)
		this.vis.flags = this.vis.flags_jumping
		this.vis.bans = this.vis.bans_jumping

		local from = V.vclone(this.pos)

		SU.remove_modifiers(store, this)

		local dragon_controller

		for k, v in pairs(store.entities) do
			if v.template_name == "controller_stage_32_boss" then
				dragon_controller = v
			end
		end

		local use_attach_point

		if type(to) == "string" then
			use_attach_point = to
			to = EXO:get_last_attach_point_xform(dragon_controller, 1, use_attach_point)
		end

		local af = to.x < from.x

		S:queue(this.sound_jump)

		local jump_in_anim = this.is_dead and "jump_in_02" or "jump_in"
		local jump_fly_up_anim = this.is_dead and "jump_fly_up_02" or "jump_fly_up"
		local jump_fly_down_anim = this.is_dead and "jump_fly_down_02" or "jump_fly_down"
		local hide_possessed_delay = 0.1
		local hide_possessed_delay_dec_mult = 0.9
		local hide_possessed_delay_min = 0.05
		local hide_possessed_max_times = 9
		local hide_possessed_times = 0
		local hide_possessed_ts = store.tick_ts + hide_possessed_delay

		local function manage_hide_possessed()
			if store.tick_ts > hide_possessed_ts and hide_possessed_times < hide_possessed_max_times then
				if hide_possessed_times == hide_possessed_max_times - 1 then
					dragon_controller:hide_possessed()

					hide_possessed_times = 1e+99

					return
				end

				local fire_fx = E:create_entity("fx_stage_32_redboy_transform_fire")

				fire_fx.render.sprites[1].ts = store.tick_ts
				fire_fx.render.sprites[1].track_attach_point = "Base"
				fire_fx.render.sprites[1].track_sprite_id = 1
				fire_fx.render.sprites[1].track_id = dragon_controller.id
				fire_fx.render.sprites[1].offset = V.v(28, -65)
				fire_fx.render.sprites[1].scale = V.vv(0.6)

				queue_insert(store, fire_fx)

				fire_fx = E:create_entity("fx_stage_32_redboy_transform_fire")
				fire_fx.render.sprites[1].ts = store.tick_ts
				fire_fx.render.sprites[1].track_attach_point = "Base"
				fire_fx.render.sprites[1].track_sprite_id = 1
				fire_fx.render.sprites[1].track_id = dragon_controller.id
				fire_fx.render.sprites[1].offset = V.v(-28, -65)
				fire_fx.render.sprites[1].flip_x = true
				fire_fx.render.sprites[1].scale = V.vv(0.6)

				queue_insert(store, fire_fx)

				hide_possessed_times = hide_possessed_max_times - 1
				hide_possessed_ts = store.tick_ts + hide_possessed_delay
			end
		end

		set_exo_for_anim(jump_in_anim)
		U.y_animation_play(this, jump_in_anim, af, store.tick_ts, 1)

		local fx = E:create_entity("fx_redboy_teen_smoke")

		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
		set_exo_for_anim(jump_fly_up_anim)
		U.animation_start(this, jump_fly_up_anim, af, store.tick_ts, true, 1, true)

		local start_ts = store.tick_ts
		local phase, xPhase

		repeat
			if use_attach_point then
				to = EXO:get_last_attach_point_xform(dragon_controller, 1, use_attach_point)
			end

			phase = (store.tick_ts - start_ts) / this.fly_time_up
			xPhase = phase / 2
			this.pos.x = U.ease_value(from.x, to.x, xPhase, "sine-in")
			this.pos.y = U.ease_value(from.y, 600, phase, "sine-in") + this.fly_offset_y

			if this.is_dead then
				manage_hide_possessed()
			end

			coroutine.yield()
		until phase >= 1

		start_ts = store.tick_ts

		set_exo_for_anim(jump_fly_down_anim)
		U.animation_start(this, jump_fly_down_anim, af, store.tick_ts, true, 1, true)
		S:queue(this.sound_falling)

		repeat
			if use_attach_point then
				to = EXO:get_last_attach_point_xform(dragon_controller, 1, use_attach_point)
			end

			phase = (store.tick_ts - start_ts) / this.fly_time_down
			xPhase = phase / 2 + 0.5
			this.pos.x = U.ease_value(from.x, to.x, xPhase, "sine-in")
			this.pos.y = U.ease_value(600, to.y, phase, "sine-out") + this.fly_offset_y

			if this.is_dead then
				manage_hide_possessed()
			end

			coroutine.yield()
		until phase >= 1

		if this.is_dead then
			dragon_controller:hide_possessed()
		end

		S:queue(this.sound_land)

		this.pos.x, this.pos.y = to.x, to.y

		if not skip_landing then
			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.8
			shake.aura.duration = 0.2
			shake.aura.freq_factor = 5

			queue_insert(store, shake)
			set_exo_for_anim("jump_end")
			U.y_animation_play(this, "jump_end", af, store.tick_ts, 1)
			set_exo_for_anim("idle")
			U.animation_start(this, "idle", af, store.tick_ts, true, 1, true)
		end

		this.vis.flags = this.vis.flags_normal
		this.vis.bans = this.vis.bans_normal
		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]
	end

	this.spawn_fly_time_down = 0.1

	local function y_spawn_fly(to, dest_pi, skip_landing)
		this.vis.flags = this.vis.flags_jumping
		this.vis.bans = this.vis.bans_jumping

		local from = V.vclone(this.pos)

		SU.remove_modifiers(store, this)

		local af = to.x < from.x

		this.render.sprites[1]._sort_y_offset = this.render.sprites[1].sort_y_offset
		this.render.sprites[1].sort_y_offset = -200

		set_exo_for_anim("jump_fly_down")
		U.animation_start(this, "jump_fly_down", af, store.tick_ts, true, 1, true)

		local start_ts = store.tick_ts
		local phase

		repeat
			phase = (store.tick_ts - start_ts) / this.spawn_fly_time_down
			this.pos.x = U.ease_value(from.x, to.x, phase, "sine-in")
			this.pos.y = U.ease_value(from.y, to.y, phase, "sine-out") + this.fly_offset_y

			coroutine.yield()
		until phase >= 1

		this.render.sprites[1].sort_y_offset = this.render.sprites[1]._sort_y_offset
		this.render.sprites[1]._sort_y_offset = nil

		S:queue(this.sound_land)

		this.pos.x, this.pos.y = to.x, to.y

		if not skip_landing then
			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.8
			shake.aura.duration = 0.2
			shake.aura.freq_factor = 5

			queue_insert(store, shake)
			set_exo_for_anim("jump_end")
			U.y_animation_play(this, "jump_end", af, store.tick_ts, 1)
			set_exo_for_anim("idle")
			U.animation_start(this, "idle", af, store.tick_ts, true, 1, true)
		end

		this.vis.flags = this.vis.flags_normal
		this.vis.bans = this.vis.bans_normal
		this.nav_path.pi = dest_pi
		this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {dest_pi})[1][3]
	end

	local function is_after_nodes_limit(attack)
		local nodes_to_goal = P:nodes_to_goal(this.nav_path)

		return nodes_to_goal < attack.nodes_limit
	end

	local function ready_to_jump()
		return not jumped and this.nav_path.ni > change_path_node_start
	end

	local function ready_to_meteorite()
		local meteorites_in_path = a_meteorite.activate_on_nodes[this.nav_path.pi]

		if meteorites_in_path then
			for k, v in pairs(meteorites_in_path) do
				if this.nav_path.ni >= v.node then
					return true
				end
			end
		end

		return false
	end

	local function ready_to_stun_towers()
		if a_stun_towers.disabled then
			return false
		end

		if store.tick_ts - a_stun_towers.ts < a_stun_towers.cooldown then
			return false
		end

		if is_after_nodes_limit(a_stun_towers) then
			SU.delay_attack(store, a_stun_towers, 1)

			return false
		end

		return true
	end

	local function ready_to_block_power()
		return false
	end

	local function ready_to_fireabsorb()
		if store.tick_ts - a_fireabsorb.ts < a_fireabsorb.cooldown then
			return false
		end

		if is_after_nodes_limit(a_fireabsorb) then
			SU.delay_attack(store, a_fireabsorb, 1)

			return false
		end

		local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a_fireabsorb.damage_radius, a_fireabsorb.vis_flags, a_fireabsorb.vis_bans)

		if not soldiers or #soldiers == 0 then
			return false
		end

		return true
	end

	local function ready_to_summon()
		return false
	end

	local function break_fn()
		if ready_to_jump() then
			return true
		end

		if ready_to_block_power() then
			return true
		end

		if ready_to_summon() then
			return true
		end

		if ready_to_meteorite() then
			return true
		end

		if ready_to_fireabsorb() then
			return true
		end

		if ready_to_stun_towers() then
			return true
		end

		return false
	end

	local function melee_break_fn()
		return break_fn()
	end

	local function range_break_fn()
		return break_fn()
	end

	local function launch_meteorite(meteor_side)
		S:queue("Stage32RedboySamadhiAsTeen")
		set_exo_for_anim(a_meteorite.animation_start)
		U.animation_start(this, a_meteorite.animation_start, nil, store.tick_ts, false, 1, true)

		if SU.y_enemy_wait(store, this, a_meteorite.cast_time) then
			return false
		end

		local fireball = E:create_entity("fx_stage_32_fireball_" .. meteor_side)

		fireball.pos.x, fireball.pos.y = 512, 382

		LU.queue_insert(store, fireball)

		if SU.y_enemy_animation_wait(this) then
			return false
		end

		set_exo_for_anim(a_meteorite.animation_loop)
		U.animation_start(this, a_meteorite.animation_loop, nil, store.tick_ts, true, 1, true)

		if SU.y_enemy_wait(store, this, 5) then
			return false
		end

		U.animation_start(this, a_meteorite.animation_end, nil, store.tick_ts, false, 1, true)
		U.y_animation_play(this, a_meteorite.animation_end, nil, store.tick_ts, 1, 1)
		set_exo_for_anim("idle")
		U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
	end

	local function do_taunt(key, offset_override)
		if offset_override then
			signal.emit("show-balloon_tutorial-pos", key, false, offset_override)
		else
			signal.emit("show-balloon_tutorial", key, false)
		end

		local taunt_start = store.tick_ts

		set_exo_for_anim(this.is_dead and "talk_02" or "talk")
		U.animation_start(this, this.is_dead and "talk_02" or "talk", nil, store.tick_ts, true, 1, true)

		while taunt_start + 2.5 > store.tick_ts do
			coroutine.yield()
		end

		U.y_animation_wait(this, 1, this.render.sprites[1].runs + 1)
		set_exo_for_anim(this.is_dead and "death_in" or "idle")
		U.animation_start(this, this.is_dead and "death_in" or "idle", nil, store.tick_ts, true, 1, true)
	end

	set_exo_for_anim("idle")
	U.animation_start(this, "idle", true, store.tick_ts, true, 1, true)
	U.y_wait(store, 1)
	do_taunt("LV32_BOSS_PREFIGHT_02")
	signal.emit("pan-zoom-camera", 2, {
		x = 533,
		y = 430
	}, OVm(1, 1.2))
	launch_meteorite("left")
	U.y_wait(store, 1.5)
	signal.emit("hide-curtains")
	signal.emit("show-gui")
	signal.emit("end-cinematic")
	S:queue("Stage32RedboyJumpFromDragon")
	set_exo_for_anim("jump_out")
	U.y_animation_play(this, "jump_out", nil, store.tick_ts, 1, 1)

	this.nav_path.pi = this.spawn_pos.path
	this.nav_path.spi = 1
	this.nav_path.ni = P:nearest_nodes(this.spawn_pos.node_pos.x, this.spawn_pos.node_pos.y, {this.nav_path.pi})[1][3]

	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		log.debug("(%s) %s has no valid next node", this.id, this.template_name)

		return false
	end

	U.set_destination(this, next)
	U.set_heading(this, next)

	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	this.render.sprites[1].track_attach_point = nil
	this.render.sprites[1].track_sprite_id = nil
	this.render.sprites[1].track_id = nil

	signal.emit("boss_fight_start", this)

	local current_manual_wave = "BOSSTEEN1"

	W:start_manual_wave(current_manual_wave)

	local function y_on_death()
		S:queue("Stage32RedboyDeathStart")

		local dragon_controller

		for k, v in pairs(store.entities) do
			if v.template_name == "controller_stage_32_boss" then
				dragon_controller = v
			end
		end

		W:stop_manual_wave(current_manual_wave)
		LU.kill_all_enemies(store, true)
		S:stop_all()
		S:queue(this.sound_death)

		this.is_dead = true

		signal.emit("boss-killed", this)
		signal.emit("boss_fight_end")
		U.y_wait(store, 0.2)
		signal.emit("show-curtains")
		signal.emit("hide-gui")
		signal.emit("start-cinematic")
		signal.emit("pan-zoom-camera", 2, V.v(this.pos.x, this.pos.y), OVm(1, 1.2))

		local af = false

		if this.pos.x > 512 then
			af = true
		end

		set_exo_for_anim("death_hit")
		U.animation_start(this, "death_hit", af, store.tick_ts, false, 1, true)

		while not U.animation_finished(this) do
			coroutine.yield()
		end

		set_exo_for_anim("death_in")
		U.animation_start(this, "death_in", nil, store.tick_ts, true, 1, true)

		local wait_until_ts = store.tick_ts + 2.5

		while wait_until_ts > store.tick_ts do
			coroutine.yield()
		end

		U.y_wait(store, 1.5)
		do_taunt("LV32_BOSS_DEATH", V.v(this.pos.x, this.pos.y + 100))
		U.y_wait(store, 1.5)

		this.render.sprites[1]._z = this.render.sprites[1].z
		this.render.sprites[1].z = Z_OBJECTS_SKY

		signal.emit("pan-zoom-camera", 2, V.v(512, 500), OVm(1, 1))
		S:queue("Stage32RedboyDeathEnd")
		y_fly(V.v(512, 382), this.nav_path.pi, true)
		LU.kill_all_enemies(store, true)

		store.level.bossfight_ended = true

		set_exo_for_anim("baculo")
		U.y_animation_play(this, "baculo", nil, store.tick_ts, 1, 1)
		queue_remove(store, this)
	end

	set_exo_for_anim("jump_end_2")
	U.animation_start(this, "jump_end_2", false, store.tick_ts, false, 1, true)
	U.y_wait(store, fts(3))

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.8
	shake.aura.duration = 0.2
	shake.aura.freq_factor = 5

	queue_insert(store, shake)
	U.y_animation_wait(this, 1)
	set_exo_for_anim("idle")
	U.animation_start(this, "idle", false, store.tick_ts, true, 1, true)

	::label_1910_0::

	while true do
		if this.health.dead then
			y_on_death()

			return
		end

		if this.unit.is_stunned then
			set_exo_for_anim("idle")
			SU.y_enemy_stun(store, this)
		else
			if ready_to_jump() then
				this.ui.can_select = false
				this.health_bar.hidden = true

				local dragon_controller

				for k, v in pairs(store.entities) do
					if v.template_name == "controller_stage_32_boss" then
						dragon_controller = v
					end
				end

				this.render.sprites[1]._sort_y_offset = this.render.sprites[1].sort_y_offset
				this.render.sprites[1]._z = this.render.sprites[1].z
				this.render.sprites[1].sort_y_offset = -400

				y_fly("Base", this.nav_path.pi)

				this.render.sprites[1].track_attach_point = "Base"
				this.render.sprites[1].track_sprite_id = 1
				this.render.sprites[1].track_id = dragon_controller.id

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true)
				launch_meteorite("right")
				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true)
				U.y_wait(store, 2)
				S:queue("Stage32RedboyJumpFromDragon")
				set_exo_for_anim("jump_out")
				U.y_animation_play(this, "jump_out", nil, store.tick_ts, 1, 1)

				this.render.sprites[1].track_attach_point = nil
				this.render.sprites[1].track_sprite_id = nil
				this.render.sprites[1].track_id = nil
				this.render.sprites[1].z = this.render.sprites[1]._z
				this.render.sprites[1]._z = nil
				this.render.sprites[1].sort_y_offset = this.render.sprites[1]._sort_y_offset
				this.render.sprites[1]._sort_y_offset = nil
				this.pos = V.vclone(this.change_path_target.node_pos)
				this.nav_path.pi = this.change_path_target.path
				this.nav_path.ni = P:nearest_nodes(this.pos.x, this.pos.y, {this.change_path_target.path})[1][3]

				set_exo_for_anim("jump_end_2")
				U.animation_start(this, "jump_end_2", false, store.tick_ts, false, 1, true)
				U.y_wait(store, fts(3))

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.8
				shake.aura.duration = 0.2
				shake.aura.freq_factor = 5

				queue_insert(store, shake)
				U.y_animation_wait(this, 1)

				this.health_bar.hidden = false
				this.ui.can_select = true
				jumped = true

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", true, store.tick_ts, true, 1, true)
				W:stop_manual_wave(current_manual_wave)

				current_manual_wave = "BOSSTEEN2"

				W:start_manual_wave(current_manual_wave)

				a_stun_towers.disabled = false
				a_stun_towers.ts = store.tick_ts - a_stun_towers.cooldown + a_stun_towers.first_cooldown
			end

			if ready_to_summon() then
				set_exo_for_anim(a_summon.animation)
				U.animation_start(this, a_summon.animation, nil, store.tick_ts, false, 1, true)

				if SU.y_enemy_wait(store, this, a_summon.cast_time) then
					goto label_1910_0
				end

				local enemy = E:create_entity(a_summon.entity)

				enemy.pi = this.nav_path.pi
				enemy.spi = math.random(1, 3)
				enemy.ni = this.nav_path.ni + math.random(10, 20)
				enemy.pos = P:node_pos(enemy.pi, enemy.spi, enemy.ni)

				queue_insert(store, enemy)

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.35
				shake.aura.duration = 0.5
				shake.aura.freq_factor = 2

				queue_insert(store, shake)

				local fx = E:create_entity(a_summon.decal)

				fx.pos = V.v(this.pos.x, this.pos.y + a_summon.decal_offset.y)

				if this.render.sprites[1].flip_x then
					fx.pos.x = fx.pos.x - a_summon.decal_offset.x
				else
					fx.pos.x = fx.pos.x + a_summon.decal_offset.x
				end

				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				a_summon.ts = store.tick_ts

				if SU.y_enemy_animation_wait(this) then
					goto label_1910_0
				end

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			if ready_to_fireabsorb() then
				local s_debug_circle = this.render.sprites[this.render.sid_debug_circle]

				s_debug_circle.scale = V.vv(a_fireabsorb.damage_radius / 30 * s_debug_circle.scale_mult)
				s_debug_circle.hidden = true

				S:queue("Stage32RedboyAbsorbFire")
				set_exo_for_anim(a_fireabsorb.animation)
				U.animation_start(this, a_fireabsorb.animation, nil, store.tick_ts, false, 1, true)

				if SU.y_enemy_wait(store, this, a_fireabsorb.absorb_time) then
					goto label_1910_0
				end

				local targets = table.filter(store.entities, function(k, v)
					return v.pos and v.is_flaming_ground and v.duration ~= 1e+99 and U.is_inside_ellipse(v.pos, this.pos, a_fireabsorb.absorb_radius)
				end)

				for k, v in pairs(targets) do
					v.duration = 0
				end

				if SU.y_enemy_wait(store, this, a_fireabsorb.cast_time - a_fireabsorb.absorb_time) then
					goto label_1910_0
				end

				local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a_fireabsorb.damage_radius, a_fireabsorb.vis_flags, a_fireabsorb.vis_bans)

				if soldiers then
					for _, s in ipairs(soldiers) do
						local d = E:create_entity("damage")

						d.damage_type = a_fireabsorb.damage_type
						d.value = math.random(a_fireabsorb.damage_min, a_fireabsorb.damage_max)
						d.source_id = this.id
						d.target_id = s.id

						queue_damage(store, d)
					end
				end

				local fx = E:create_entity(a_fireabsorb.decal)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				a_fireabsorb.ts = store.tick_ts

				if SU.y_enemy_animation_wait(this) then
					goto label_1910_0
				end

				s_debug_circle.hidden = true

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			if ready_to_block_power() then
				set_exo_for_anim(a_block_power.animation)
				U.animation_start(this, a_block_power.animation, nil, store.tick_ts, false, 1, true)

				if SU.y_enemy_wait(store, this, a_block_power.fx_time) then
					goto label_1910_0
				end

				local fx = E:create_entity(a_block_power.hand_fx)

				fx.pos = V.v(this.pos.x, this.pos.y + a_block_power.hand_fx_offset.y)

				if this.render.sprites[1].flip_x then
					fx.pos.x = fx.pos.x - a_block_power.hand_fx_offset.x
				else
					fx.pos.x = fx.pos.x + a_block_power.hand_fx_offset.x
				end

				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				if SU.y_enemy_wait(store, this, a_block_power.cast_time - a_block_power.fx_time) then
					goto label_1910_0
				end

				a_block_power.ts = store.tick_ts

				signal.emit("block-random-power", a_block_power.duration, "dragon_boss", true)

				if SU.y_enemy_animation_wait(this) then
					goto label_1910_0
				end

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			if ready_to_meteorite() then
				local meteor_side = "right"
				local meteorites_in_path = a_meteorite.activate_on_nodes[this.nav_path.pi]

				if meteorites_in_path then
					for k, v in pairs(meteorites_in_path) do
						if this.nav_path.ni >= v.node then
							meteor_side = v.side
							meteorites_in_path[k] = nil

							break
						end
					end
				end

				if not launch_meteorite(meteor_side) then
					goto label_1910_0
				end
			end

			if ready_to_stun_towers() then
				local dragon_controller

				for k, v in pairs(store.entities) do
					if v.template_name == "controller_stage_32_boss" then
						dragon_controller = v
					end
				end

				set_exo_for_anim(a_stun_towers.animation_start)
				U.animation_start(this, a_stun_towers.animation_start, true, store.tick_ts, false, 1, true)

				if SU.y_enemy_animation_wait(this) then
					goto label_1910_0
				end

				dragon_controller.do_stun_towers = a_stun_towers.side
				a_stun_towers.ts = store.tick_ts

				set_exo_for_anim(a_stun_towers.animation_loop)
				U.animation_start(this, a_stun_towers.animation_loop, true, store.tick_ts, true, 1, true)

				if SU.y_enemy_wait(store, this, 4.8) then
					goto label_1910_0
				end

				set_exo_for_anim(a_stun_towers.animation_end)
				U.animation_start(this, a_stun_towers.animation_end, true, store.tick_ts, false, 1, true)

				if SU.y_enemy_animation_wait(this) then
					goto label_1910_0
				end

				set_exo_for_anim("idle")
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, break_fn)

			if not cont then
			-- block empty
			else
				if blocker then
					if not SU.y_wait_for_blocker(store, this, blocker) then
						goto label_1910_0
					end

					while SU.can_melee_blocker(store, this, blocker) and (not melee_break_fn or not melee_break_fn(store, this)) do
						if not SU.y_enemy_melee_attacks(store, this, blocker) then
							goto label_1910_0
						end

						coroutine.yield()
					end
				elseif ranged then
					while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and (not range_break_fn or not range_break_fn(store, this)) do
						if not SU.y_enemy_range_attacks(store, this, ranged) then
							goto label_1910_0
						end

						coroutine.yield()
					end
				end

				coroutine.yield()
			end
		end
	end
end
