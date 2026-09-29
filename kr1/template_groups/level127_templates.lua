local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local r = V.r
local log = require("lib.klua.log"):new("level127")
local controller_stage_27_platform_update
local controller_stage_27_platform_on_platform_up_event
local controller_stage_27_platform_on_platform_down_event
local controller_stage_27_platform_on_platform_destroy_event
local controller_stage_27_platform_on_cannons_event
local controller_stage_27_platform_on_taunt_event
local decal_stage_27_modes_decos_update
local decal_stage_27_beam_update
controller_stage_27_platform_update = function(this, store)
	local platform, platform_bars, cannon_left, cannon_right, door_mask, cannon_c_right, cannon_c_left
	print("insert controller_stage_27_platform")
	for i, v in pairs(store.entities) do
		if v.template_name == this.platform_t then
			platform = v
		end
		if v.template_name == this.platform_bars_t then
			platform_bars = v
		end
		if v.template_name == this.cannon_left_t then
			cannon_left = v
		end
		if v.template_name == this.cannon_right_t then
			cannon_right = v
		end
		if v.template_name == this.door_mask_t then
			door_mask = v
		end
		if v.template_name == this.cannon_controller_t_l then
			cannon_c_left = v
		end
		if v.template_name == this.cannon_controller_t_r then
			cannon_c_right = v
		end
	end
	cannon_c_left.cannon = cannon_left
	cannon_c_right.cannon = cannon_right
	S:queue(this.sound_intro)
	platform.render.sprites[1].prefix = "dclenanos_stage05_platform_introDef"
	U.y_animation_play(platform, "intro", nil, store.tick_ts, 1)
	platform.render.sprites[1].prefix = "dclenanos_stage05_platformDef"
	U.animation_start_default(platform, "idle", nil, store.tick_ts, true)
	while true do
		if this.platform_up then
			S:queue(this.sound_platform_up)
			U.animation_start_default(platform, "raise", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(23))
			platform.render.sprites[1].z = Z_DECALS
			U.y_wait_unconditional(store, fts(12))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.5
			shake.aura.duration = 0.3
			shake.aura.freq_factor = 2
			simulation:queue_insert_entity(shake)
			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(platform)
			U.animation_start_default(platform, "idleopen", nil, store.tick_ts, true)
			door_mask.render.sprites[1].hidden = false
			this.platform_up = false
		elseif this.platform_down then
			S:queue(this.sound_platform_down)
			door_mask.render.sprites[1].hidden = true
			U.animation_start_default(platform, "lower", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(43))
			platform.render.sprites[1].z = Z_BACKGROUND_COVERS
			U.y_animation_wait_default(platform)
			U.animation_start_default(platform, "idle", nil, store.tick_ts, true)
			this.platform_down = false
		elseif this.platform_destroy then
			S:queue(this.sound_platform_destroy_chains)
			door_mask.render.sprites[1].hidden = true
			platform.render.sprites[1].z = Z_BACKGROUND_COVERS
			U.animation_start_default(platform_bars, "break", nil, store.tick_ts, false)
			U.animation_start_default(platform, "endfirstpart", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(120))
			S:queue(this.sound_platform_destroy_impacts)
			U.y_wait_unconditional(store, fts(13))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.5
			shake.aura.duration = 0.6
			shake.aura.freq_factor = 2
			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, fts(33))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.75
			shake.aura.duration = 0.6
			shake.aura.freq_factor = 2
			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, fts(33))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 1
			shake.aura.duration = 1
			shake.aura.freq_factor = 2
			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(platform)
			platform_bars.render.sprites[1].hidden = true
			this.platform_destroy = false
			local head_c
			for i, v in ipairs(store.entities) do
				if v.template_name == this.head_controller_t then
					head_c = v
				end
			end
			head_c.cannon_c_left = cannon_c_left
			head_c.cannon_c_right = cannon_c_right
			head_c.spawn_head = true
			U.y_wait_unconditional(store, fts(1))
			simulation:queue_remove_entity(platform)
			simulation:queue_remove_entity(this)
		elseif this.cannons_in then
			S:queue(this.sound_cannon_alarm)
			U.animation_start_default(platform, "risecannons", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(52))
			if this.cannons_config == "both" then
				local delay_between = fts(8)
				cannon_c_right.shoot_cannon = true
				cannon_c_right.clones_count = this.cannons_clones_count
				U.y_wait_unconditional(store, delay_between)
				cannon_c_left.shoot_cannon = true
				cannon_c_left.clones_count = this.cannons_clones_count
			elseif this.cannons_config == "left" then
				cannon_c_left.shoot_cannon = true
				cannon_c_left.clones_count = this.cannons_clones_count
			else
				cannon_c_right.shoot_cannon = true
				cannon_c_right.clones_count = this.cannons_clones_count
			end
			U.y_animation_wait_default(platform)
			U.animation_start_default(platform, "idle", nil, store.tick_ts, true)
			this.cannons_in = false
		elseif this.show_taunt then
			local set = this.taunts.sets.fight
			local taunt_id = _(string.format(set.format, this.taunt_idx))
			signal.emit("show-balloon_tutorial", taunt_id, false)
			U.y_animation_play(platform, "taunt" .. math.random(1, 2), nil, store.tick_ts, 1)
			U.animation_start_default(platform, "idle", nil, store.tick_ts, true)
			this.show_taunt = false
		end
		coroutine.yield()
	end
end
controller_stage_27_platform_on_platform_up_event = function(this, store, action)
	log.info("EVENT: RAISE PLATFORM")
	this.platform_up = true
end
controller_stage_27_platform_on_platform_down_event = function(this, store, action)
	log.info("EVENT: LOWER PLATFORM")
	this.platform_down = true
end
controller_stage_27_platform_on_platform_destroy_event = function(this, store, action)
	log.info("EVENT: DESTROY PLATFORM")
	this.platform_destroy = true
end
controller_stage_27_platform_on_cannons_event = function(this, store, action, config, clones_count)
	log.info("EVENT: CANNONS - " .. config)
	this.cannons_in = true
	this.cannons_config = config
	this.cannons_clones_count = clones_count
end
controller_stage_27_platform_on_taunt_event = function(this, store, action, taunt_idx)
	log.info("EVENT: TAUNT - " .. taunt_idx)
	this.show_taunt = true
	this.taunt_idx = taunt_idx
end
decal_stage_27_modes_decos_update = function(this, store)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			S:queue("Stage09SheepyCamera")
			U.y_animation_play(this, "action_" .. math.random(1, 3), nil, store.tick_ts, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			this.ui.can_click = true
		end
		coroutine.yield()
	end
end
decal_stage_27_beam_update = function(this, store)
	local taps = 0
	local idle_ts = store.tick_ts
	local idle_cd = math.random(5, 10)
	local doing_idle = false
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	while true do
		if taps > 1 then
		else
			if this.ui.clicked then
				this.ui.clicked = nil
				this.ui.can_click = false
				doing_idle = false
				taps = taps + 1
				S:queue(this.sound_prefix .. taps)
				if taps == 2 then
					S:queue(this.sound_prefix .. 3, {
						delay = 3
					})
				end
				U.y_animation_play(this, "action_" .. taps, nil, store.tick_ts, 1)
				if taps == 1 then
					this.ui.can_click = true
					U.animation_start_default(this, "idle_3", nil, store.tick_ts, true)
				else
					U.animation_start_default(this, "idle_5", nil, store.tick_ts, true)
					signal.emit("workers-stage27", this)
					goto label_1667_0
				end
			end
			if doing_idle and U.animation_finished_default(this) then
				doing_idle = false
				if taps == 0 then
					U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				else
					U.animation_start_default(this, "idle_3", nil, store.tick_ts, true)
				end
			end
			if not doing_idle and idle_cd < store.tick_ts - idle_ts then
				doing_idle = true
				if taps == 0 then
					U.animation_start_default(this, "idle_2", nil, store.tick_ts, false)
				else
					U.animation_start_default(this, "idle_4", nil, store.tick_ts, false)
				end
				idle_ts = store.tick_ts
				idle_cd = math.random(5, 10)
			end
		end
		::label_1667_0::
		coroutine.yield()
	end
end
local tt
local v = V.v
local km = require("lib.klua.macros")
local P = require("path_db")
local bor = bit.bor
local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local function fts(v)
	return v / FPS
end

local controller_stage_27_head = {}

function controller_stage_27_head.update(this, store)
	local head_pos = V.v(-188, 768)
	local head

	this.towers_stunned = 0

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while not this.spawn_head do
			coroutine.yield()
		end

		head = E:create_entity(this.head_t)
		head.pos = V.vclone(head_pos)
		head.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(head)
	else
		for k, v in pairs(store.entities) do
			if v.template_name == this.head_t then
				head = v

				break
			end
		end

		this.ui.can_click = false
	end

	local taps_count = 0
	local tap_ts = 0
	local ray_shake, shooting_ray

	local function update_click_rect(dt, phase)
		this.ui.click_rect.pos.x = head.render.sprites[1].offset.x - 100
	end

	local function check_tap()
		if taps_count >= this.taps_to_cancel then
			return
		end

		if this.ui.clicked and (head.render.sprites[1].name == "ray" or head.render.sprites[1].name == "charge") then
			this.ui.clicked = nil
			tap_ts = store.tick_ts
			taps_count = taps_count + 1

			if taps_count >= this.taps_to_cancel then
				S:stop(this.sound_shoot)
				S:queue(this.sound_interrupt)
				U.animation_start_default(head, "raycancel", nil, store.tick_ts, false)

				shooting_ray = false

				if ray_shake then
					ray_shake.aura.duration = 0
				end

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 1
				shake.aura.duration = 1
				shake.aura.freq_factor = 1

				simulation:queue_insert_entity(shake)

				return true
			else
				S:queue(this.sound_cancel_tap)
				U.animation_start_default(head, "chargetap", nil, store.tick_ts, false)

				local offset_x = math.random(10, 15)
				local offset_y = math.random(10, 15)

				if math.random(0, 1) == 1 then
					offset_x = -offset_x
				end

				if math.random(0, 1) == 1 then
					offset_y = -offset_y
				end

				head.pos = V.v(head_pos.x + offset_x, head_pos.y + offset_y)
			end
		end

		if head.render.sprites[1].name == "chargetap" and store.tick_ts - tap_ts > fts(1) then
			if not shooting_ray then
				U.animation_start_default(head, "charge", nil, store.tick_ts, true)
			else
				U.animation_start_default(head, "ray", nil, store.tick_ts, true)
			end

			head.pos = V.vclone(head_pos)
		end

		return false
	end

	local function check_ray_end(end_offset, ray)
		if head.render.sprites[1].name == "raycancel" and U.animation_finished_default(head) then
			U.animation_start_default(head, "idle", nil, store.tick_ts, true)
		end

		if not ray then
			return
		end

		if head.render.sprites[1].name == "ray" and math.abs(head.render.sprites[1].offset.x) < math.abs(end_offset) then
			ray_shake.aura.duration = 0

			U.animation_start_default(head, "rayend", nil, store.tick_ts, false)
			U.animation_start_default(ray, "end", nil, store.tick_ts, false)
		end

		if ray.render.sprites[1].name == "end" and U.animation_finished_default(ray) then
			simulation:queue_remove_entity(ray)
		end

		if head.render.sprites[1].name == "rayend" and U.animation_finished_default(head) then
			U.animation_start_default(head, "idle", nil, store.tick_ts, true)
		end
	end

	local function check_ray_dmg(ray)
		if not ray then
			return
		end

		if head.render.sprites[1].name ~= "ray" and head.render.sprites[1].name ~= "chargetap" then
			return
		end

		for k, v in pairs(store.entities) do
			if not v.pending_removal and v.pos and math.abs(v.pos.x - (ray.pos.x + ray.render.sprites[1].offset.x)) < 50 and v.pos.y < ray.pos.y then
				if v.tower and v.tower.type ~= "holder" and not U.has_modifiers(store, v, this.ray_stun_mod_t) then
					this.towers_stunned = this.towers_stunned + 1

					local m = E:create_entity(this.ray_stun_mod_t)

					m.modifier.target_id = v.id
					m.modifier.source_id = this.id

					simulation:queue_insert_entity(m)
				elseif (v.enemy or v.soldier) and v.health and not v.health.dead then
					local d = E.assign_damage(this.ray_damage_type, 1, this.id, v.id)
					d.pop_chance = 0

					queue_damage(store, d)
				end
			end
		end
	end

	while true do
		if this.do_attack then
			local start_offset, end_offset

			if this.attack_side == "left" then
				start_offset = -500
				end_offset = -250
			else
				start_offset = 380
				end_offset = 210
			end

			S:queue(this.sound_move)
			U.y_animation_play(head, "startmove", nil, store.tick_ts, 1)
			U.y_animation_play(head, "startmove" .. this.attack_side, nil, store.tick_ts, 1)
			U.animation_start_default(head, "move" .. this.attack_side, nil, store.tick_ts, true)
			U.y_ease_key(store, head.render.sprites[1].offset, "x", 0, start_offset, fts(60), "sine", update_click_rect)
			U.y_animation_play(head, "endmove" .. this.attack_side, nil, store.tick_ts, 1)

			if this.cannon_clones_count > 0 then
				if this.attack_side == "left" then
					this.cannon_c_right.shoot_cannon = true
					this.cannon_c_right.clones_count = this.cannon_clones_count
				else
					this.cannon_c_left.shoot_cannon = true
					this.cannon_c_left.clones_count = this.cannon_clones_count
				end
			end

			U.y_animation_play(head, "endmovetocharge", nil, store.tick_ts, 1)

			local charge_ts = store.tick_ts

			S:queue(this.sound_charge)
			U.animation_start_default(head, "charge", nil, store.tick_ts, true)

			taps_count = 0
			this.ui.clicked = nil

			local shown_hand = false

			while store.tick_ts - charge_ts < this.charge_time do
				if store.tick_ts - charge_ts > 2 and not shown_hand then
					shown_hand = true

					local hand = E:create_entity(this.hand_decal_t)

					hand.pos = V.v(615, 570)
					hand.render.sprites[1].offset = head.render.sprites[1].offset
					hand.render.sprites[1].ts = store.tick_ts
					hand.tween.ts = store.tick_ts

					simulation:queue_insert_entity(hand)
				end

				if check_tap() then
					break
				end

				coroutine.yield()
			end

			local ray

			if taps_count < this.taps_to_cancel then
				shooting_ray = true

				S:queue(this.sound_shoot)

				ray_shake = E:create_entity("aura_screen_shake")
				ray_shake.aura.amplitude = 0.25
				ray_shake.aura.duration = 10
				ray_shake.aura.freq_factor = 4

				simulation:queue_insert_entity(ray_shake)
				U.animation_start_default(head, "idle", nil, store.tick_ts, true)

				ray = E:create_entity(this.ray_t)
				ray.pos = V.v(591, 517)
				ray.render.sprites[1].offset = head.render.sprites[1].offset
				ray.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(ray)
				U.animation_start_default(ray, "start", nil, store.tick_ts, false)
				U.y_animation_play(head, "raystart", nil, store.tick_ts, 1)
				U.animation_start_default(ray, "loop", nil, store.tick_ts, true)
				U.animation_start_default(head, "ray", nil, store.tick_ts, true)
			end

			local ray_ts = store.tick_ts
			local stun_check_ts = store.tick_ts
			local phase
			local stop_sfx = false

			repeat
				local dt = store.tick_ts - ray_ts

				phase = km.clamp(0, 1, dt / this.attack_duration)
				head.render.sprites[1].offset.x = U.ease_value(start_offset, 0, phase, "quad")

				update_click_rect()

				if check_tap() then
					U.animation_start_default(ray, "end", nil, store.tick_ts, false)
				end

				if not stop_sfx and math.abs(head.render.sprites[1].offset.x) < math.abs(end_offset) then
					stop_sfx = true

					S:queue(this.sound_return)
				end

				check_ray_end(end_offset, ray)

				if store.tick_ts - stun_check_ts > 0.05 then
					check_ray_dmg(ray)

					stun_check_ts = store.tick_ts
				end

				coroutine.yield()
			until phase >= 1

			shooting_ray = false

			if taps_count >= this.taps_to_cancel and ray then
				U.y_animation_wait_default(ray)
			end

			this.do_attack = false
		elseif this.cannons_in then
			if this.cannons_config == "both" then
				local delay_between = fts(8)

				this.cannon_c_right.shoot_cannon = true
				this.cannon_c_right.clones_count = this.cannons_clones_count

				U.y_wait_unconditional(store, delay_between)

				this.cannon_c_left.shoot_cannon = true
				this.cannon_c_left.clones_count = this.cannons_clones_count
			elseif this.cannons_config == "left" then
				this.cannon_c_left.shoot_cannon = true
				this.cannon_c_left.clones_count = this.cannons_clones_count
			else
				this.cannon_c_right.shoot_cannon = true
				this.cannon_c_right.clones_count = this.cannons_clones_count
			end

			this.cannons_in = false
		elseif this.activate_ears then
			if this.ears_config == "open" then
				S:queue(this.sound_ears_open)
				U.y_animation_play(head, "spawnstart", nil, store.tick_ts, 1)
				U.animation_start_default(head, "spawnidle", nil, store.tick_ts, true)
			else
				S:queue(this.sound_ears_close)
				U.y_animation_play(head, "spawnleave", nil, store.tick_ts, 1)
				U.animation_start_default(head, "idle", nil, store.tick_ts, true)
			end

			this.activate_ears = false
		elseif this.destroy_head then
			local function stun_towers()
				local towers = table.filter(store.towers, function(k, v)
					return not v.pending_removal and v.tower and not v.tower.blocked
				end)
				local selected_towers = {}

				if #towers > this.towers_to_stun then
					selected_towers = table.filter(towers, function(k, v)
						return v.tower.type ~= "holder"
					end)

					if #selected_towers < this.towers_to_stun then
						local holders = table.filter(towers, function(k, v)
							return v.tower.type == "holder"
						end)

						for i = #holders, 2, -1 do
							local j = math.random(i)

							holders[i], holders[j] = holders[j], holders[i]
						end

						for i = 1, this.towers_to_stun - #selected_towers do
							table.insert(selected_towers, holders[i])
						end
					elseif #selected_towers > this.towers_to_stun then
						for i = #selected_towers, 2, -1 do
							local j = math.random(i)

							selected_towers[i], selected_towers[j] = selected_towers[j], selected_towers[i]
						end

						for i = 1, #selected_towers - this.towers_to_stun do
							table.remove(selected_towers, 1)
						end
					end
				else
					selected_towers = towers
				end

				for k, v in pairs(selected_towers) do
					local bullet = E:create_entity(this.tower_stun_bullet_t)

					bullet.pos = V.v(591, 508)
					bullet.pos.x = bullet.pos.x - 70 + 140 * (v.pos.x / 1024)
					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = V.vclone(v.pos)
					bullet.bullet.source_id = this.id
					bullet.bullet.target_id = v.id
					bullet.bullet.flight_time = bullet.bullet.flight_time + fts(math.random(-10, 10))

					simulation:queue_insert_entity(bullet)
				end
			end

			S:queue("Stage27PreBossfightCinematic")
			U.y_wait_unconditional(store, fts(12))
			U.y_animation_play(head, "headdeathstart", nil, store.tick_ts, 1)
			U.animation_start_default(head, "headdeathidle", nil, store.tick_ts, true)

			local goblins = E:create_entity(this.goblins_t)

			goblins.pos = V.vclone(head_pos)
			goblins.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(goblins)
			U.animation_start_default(goblins, "headdeath", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(278))
			U.animation_start_default(head, "headdeathbombisplaced", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(60))

			goblins.render.sprites[1].sort_y_offset = -390

			local explotion_ts = store.tick_ts
			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 2
			shake.aura.duration = 2
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			stun_towers()
			U.y_animation_wait_default(head)

			local smoke_back = E:create_entity(this.smoke_back_t)

			smoke_back.render.sprites[1].ts = store.tick_ts
			smoke_back.pos = V.vclone(head.pos)

			simulation:queue_insert_entity(smoke_back)

			local smoke_front = E:create_entity(this.smoke_front_t)

			smoke_front.render.sprites[1].ts = store.tick_ts
			smoke_front.pos = V.vclone(head.pos)

			simulation:queue_insert_entity(smoke_front)

			local sparks = E:create_entity(this.sparks_t)

			sparks.render.sprites[1].ts = store.tick_ts
			sparks.pos = V.vclone(head.pos)

			simulation:queue_insert_entity(sparks)
			U.y_wait_unconditional(store, fts(1))
			U.animation_start_default(head, "headdeathsmokeidle", nil, store.tick_ts, true)
			U.y_wait_unconditional(store, fts(92) - (store.tick_ts - explotion_ts))

			local boss = E:create_entity("boss_grymbeard")

			boss.nav_path.pi = 3

			if math.random(1, 2) == 1 then
				boss.nav_path.pi = 7
			end

			boss.nav_path.spi = 1
			boss.pos = V.v(592, 394)

			local node = P:nearest_nodes(boss.pos.x, boss.pos.y, {boss.nav_path.pi}, {boss.nav_path.spi})[1]
			local _, _, ni = unpack(node)

			boss.nav_path.ni = ni + 5

			simulation:queue_insert_entity(boss)
			U.y_wait_unconditional(store, fts(1))
			U.animation_start_default(goblins, "decal", nil, store.tick_ts, true)

			goblins.render.sprites[1].z = Z_DECALS
			this.destroy_head = false
		elseif this.shoot_scrap then
			local function shuffle_table(nodes)
				for i = #nodes, 2, -1 do
					local j = math.random(i)

					nodes[i], nodes[j] = nodes[j], nodes[i]
				end

				return nodes
			end

			local function shoot_scrap(pos)
				local bullet = E:create_entity(this.scrap_bullet_t)

				bullet.pos = V.v(591, 508)
				bullet.pos.x = bullet.pos.x - 70 + 140 * (pos.x / 1024)
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.vclone(pos)
				bullet.bullet.source_id = this.id
				bullet.bullet.flight_time = bullet.bullet.flight_time + fts(math.random(-7, 7))

				simulation:queue_insert_entity(bullet)

				local fx = E:create_entity(this.scrap_fx_t)

				fx.pos = V.vclone(bullet.pos)
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
			end

			S:queue("Stage27BFRobotScrapCast")
			U.animation_start_default(head, "headdeathscrapshoot", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(4))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 0.5
			shake.aura.duration = 1
			shake.aura.freq_factor = 1

			simulation:queue_insert_entity(shake)

			local selected_positions = {}
			local _, targets = U.find_soldiers_in_range(store.soldiers, this.pos, 150, 1000, bor(F_ENEMY), bor(F_FLYING))
			local max_dist2 = 10000

			for i = 1, this.scrap_count do
				if not targets or #targets == 0 or #selected_positions > this.scrap_count / 2 then
					goto label_1639_0
				end

				local sel_target = targets[1]
				local node_offset = P:predict_enemy_node_advance(sel_target, fts(30))
				local e_ni = sel_target.nav_path.ni + node_offset
				local e_pos = P:node_pos(sel_target.nav_path.pi, sel_target.nav_path.spi, e_ni)

				table.insert(selected_positions, e_pos)
				table.remove(targets, 1)

				for i = #targets, 1, -1 do
					local e = targets[i]

					if max_dist2 > V.dist2(sel_target.pos.x, sel_target.pos.y, e.pos.x, e.pos.y) then
						table.remove(targets, i)
					end
				end
			end

			if #selected_positions == this.scrap_count then
				goto label_1639_1
			end

			::label_1639_0::

			do
				local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, 0, 1000, bor(TERRAIN_LAND, TERRAIN_ICE))

				shuffle_table(nodes)

				for i = #selected_positions + 1, this.scrap_count do
					local sel_node = nodes[1]

					table.insert(selected_positions, sel_node)
					table.remove(nodes, 1)

					for i = #nodes, 1, -1 do
						local n = nodes[i]

						if max_dist2 > V.dist2(sel_node.x, sel_node.y, n.x, n.y) then
							table.remove(nodes, i)
						end
					end
				end
			end

			::label_1639_1::

			shuffle_table(selected_positions)

			for _, p in pairs(selected_positions) do
				shoot_scrap(p)
			end

			U.y_animation_wait_default(head)

			this.shoot_scrap = false
		end

		coroutine.yield()
	end
end

function controller_stage_27_head.on_attack_left_event(this, store, action)
	log.info("EVENT: RAY ATTACK LEFT")

	this.do_attack = true
	this.attack_side = "left"
	this.cannon_clones_count = 0
end

function controller_stage_27_head.on_attack_right_event(this, store, action)
	log.info("EVENT: RAY ATTACK RIGHT")

	this.do_attack = true
	this.attack_side = "right"
	this.cannon_clones_count = 0
end

function controller_stage_27_head.on_attack_left_cannon_event(this, store, action, clones_count)
	log.info("EVENT: RAY ATTACK LEFT WITH CANNON")

	this.do_attack = true
	this.attack_side = "left"
	this.cannon_clones_count = tonumber(clones_count)
end

function controller_stage_27_head.on_attack_right_cannon_event(this, store, action, clones_count)
	log.info("EVENT: RAY ATTACK RIGHT WITH CANNON")

	this.do_attack = true
	this.attack_side = "right"
	this.cannon_clones_count = tonumber(clones_count)
end

function controller_stage_27_head.on_cannons_event(this, store, action, config, clones_count)
	log.info("EVENT: CANNONS - " .. config)

	this.cannons_in = true
	this.cannons_config = config
	this.cannons_clones_count = clones_count
end

function controller_stage_27_head.on_ears_event(this, store, action, config)
	log.info("EVENT: ACTIVATE EARS")

	this.activate_ears = true
	this.ears_config = config
end

function controller_stage_27_head.on_head_destroy_event(this, store, action)
	log.info("EVENT: DESTROY HEAD")

	this.destroy_head = true
end

function controller_stage_27_head.on_scrap_event(this, store, action, scrap_count)
	log.info("EVENT: SHOOT SCRAP")

	this.shoot_scrap = true
	this.scrap_count = scrap_count
end

tt = E:register_t_hot("decal_stage_27_modes_decos", "decal_scripted", true)
E:add_comps(tt, "editor", "ui")
tt.render.sprites[1].prefix = "DLCstage5_deco_modosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_stage_27_modes_decos_update
tt.ui.click_rect = r(-33, 60, 20, 20)

tt = E:register_t_hot("decal_stage_27_platform_bars", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_platform_barsDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN

tt = E:register_t_hot("decal_stage_27_mask_3", "decal", true)
tt.render.sprites[1].name = "stage27_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("decal_stage_27_beam", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.render.sprites[1].prefix = "DLCstage5_enanos_vigaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.main_script.update = decal_stage_27_beam_update
tt.ui.click_rect = r(-470, 200, 150, 60)
tt.sound_prefix = "Stage27BeamWorkersTap"

tt = E:register_t_hot("decal_stage_27_mask_2", "decal", true)
tt.render.sprites[1].name = "stage27_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_27_platform", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_platformDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("decal_stage_27_snow", "decal", true)
tt.render.sprites[1].prefix = "dclenanos_stage05_snowfallDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS

tt = E:register_t_hot("controller_stage_27_platform", nil, true)
E:add_comps(tt, "main_script", "events", "taunts", "editor")
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = controller_stage_27_platform_update
tt.platform_t = "decal_stage_27_platform"
tt.platform_bars_t = "decal_stage_27_platform_bars"
tt.cannon_left_t = "decal_stage_27_cannon_left"
tt.cannon_right_t = "decal_stage_27_cannon_right"
tt.cannon_controller_t_l = "controller_stage_27_cannon_L"
tt.cannon_controller_t_r = "controller_stage_27_cannon_R"
tt.head_controller_t = "controller_stage_27_head"
tt.door_mask_t = "decal_stage_27_mask_3"
tt.events.list[1].name = "platform_up"
tt.events.list[1].on_event = controller_stage_27_platform_on_platform_up_event
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "platform_down"
tt.events.list[2].on_event = controller_stage_27_platform_on_platform_down_event
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "platform_destroy"
tt.events.list[3].on_event = controller_stage_27_platform_on_platform_destroy_event
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "cannons"
tt.events.list[4].on_event = controller_stage_27_platform_on_cannons_event
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "taunt"
tt.events.list[5].on_event = controller_stage_27_platform_on_taunt_event
tt.load_file = "level101_taunts"
tt.taunts.sets = {}
tt.taunts.sets.preparation = CC("taunt_set")
tt.taunts.sets.preparation.format = "LV27_GRYMBEARD_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx = 4
tt.taunts.sets.fight = CC("taunt_set")
tt.taunts.sets.fight.format = "LV27_GRYMBEARD_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx = 4
tt.sound_intro = "Stage27Intro"
tt.sound_platform_up = "Stage27PlatformUp"
tt.sound_platform_down = "Stage27PlatformDown"
tt.sound_platform_destroy_chains = "Stage27PlatformDestroyChains"
tt.sound_platform_destroy_impacts = "Stage27PlatformDestroyHeadImpacts"
tt.sound_cannon_alarm = "Stage27CloneCannonAlarm"

tt = E:register_t_hot("decal_stage_27_mask_5", "decal", true)
tt.render.sprites[1].name = "stage27_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 2

tt = E:register_t_hot("decal_stage_27_mask_4", "decal", true)
tt.render.sprites[1].name = "stage27_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 2

tt = E:register_t_hot("decal_stage_27_mask_1", "decal", true)
tt.render.sprites[1].name = "stage27_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 3

tt = E:register_t_hot("decal_stage_27_cannon_right", "decal", true)
tt.render.sprites[1].prefix = "dlcenanos_stage05_cannonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.shot_pos = v(924, 509)
tt.shot_target_pos = v(815, 364)

tt = E:register_t_hot("decal_stage_27_cannon_left", "decal", true)
tt.render.sprites[1].prefix = "dlcenanos_stage05_cannonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.shot_pos = v(238, 532)
tt.shot_target_pos = v(361, 345)

tt = E:register_t_hot("decal_stage_27_head", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_headDef"
tt.render.sprites[1].name = "headdeathsmokeidle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 1

tt = E:register_t_hot("decal_stage_27_smoke_back", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSmokeBackDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN

tt = E:register_t_hot("decal_stage_27_smoke_front", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSmokeFrontDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1

tt = E:register_t_hot("decal_stage_27_sparks", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSparksDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1

tt = E:register_t_hot("controller_stage_27_cannon_L", "controller_stage_27_cannon", true)
E:add_comps(tt, "events")
tt.events.list[1].name = "shoot-cannons-L"
tt._decal = "decal_stage_27_cannon_left"
tt.events.list[1].on_event = scripts.controller_stage_27_cannon.on_cannons_event

tt = E:register_t_hot("controller_stage_27_cannon_R", "controller_stage_27_cannon", true)
E:add_comps(tt, "events")
tt.events.list[1].name = "shoot-cannons-R"
tt._decal = "decal_stage_27_cannon_right"
tt.events.list[1].on_event = scripts.controller_stage_27_cannon.on_cannons_event

tt = E:register_t_hot("controller_stage_27_head", nil, true)
E:add_comps(tt, "main_script", "events", "ui", "editor")
tt.main_script.update = controller_stage_27_head.update
tt.head_t = "decal_stage_27_head"
tt.ray_t = "decal_stage_27_ray"
tt.ray_stun_mod_t = "mod_stage_27_ray_stun"
tt.ray_damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD, DAMAGE_NO_DODGE)
tt.goblins_t = "decal_stage_27_goblins"
tt.smoke_back_t = "decal_stage_27_smoke_back"
tt.smoke_front_t = "decal_stage_27_smoke_front"
tt.sparks_t = "decal_stage_27_sparks"
tt.scrap_bullet_t = "bullet_stage_27_scrap"
tt.scrap_fx_t = "fx_stage_27_scrap"
tt.tower_stun_bullet_t = "bullet_stage_27_tower_stun"
tt.hand_decal_t = "decal_mod_stage_25_torso_missile_stun_hand"
tt.towers_to_stun = 13
tt.events.list[1].name = "head_attack_left"
tt.events.list[1].on_event = controller_stage_27_head.on_attack_left_event
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "head_attack_right"
tt.events.list[2].on_event = controller_stage_27_head.on_attack_right_event
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "head_attack_left_cannon"
tt.events.list[3].on_event = controller_stage_27_head.on_attack_left_cannon_event
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "head_attack_right_cannon"
tt.events.list[4].on_event = controller_stage_27_head.on_attack_right_cannon_event
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "head_cannons"
tt.events.list[5].on_event = controller_stage_27_head.on_cannons_event
tt.events.list[6] = E:clone_c("event")
tt.events.list[6].name = "head_ears"
tt.events.list[6].on_event = controller_stage_27_head.on_ears_event
tt.events.list[7] = E:clone_c("event")
tt.events.list[7].name = "head_destroy"
tt.events.list[7].on_event = controller_stage_27_head.on_head_destroy_event
tt.events.list[8] = E:clone_c("event")
tt.events.list[8].name = "head_scrap"
tt.events.list[8].on_event = controller_stage_27_head.on_scrap_event
tt.ui.click_rect = r(-100, 50, 350, 250)
tt.charge_time = 3
tt.attack_duration = 6
tt.taps_to_cancel = 20
tt.sound_ears_open = "Stage27HeadOpen"
tt.sound_ears_close = "Stage27HeadClose"
tt.sound_move = "Stage27HeadMove"
tt.sound_charge = "Stage27HeadFireblastCharge"
tt.sound_shoot = "Stage27HeadFireblastRelease"
tt.sound_cancel_tap = "Stage27HeadFireblastCancelTap"
tt.sound_interrupt = "Stage27HeadFireblastInterrupt"
tt.sound_return = "Stage27HeadReturn"

