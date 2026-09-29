local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local GR = require("grid_db")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local vv = V.vv
local decal_stage_37_easter_egg_how_to_train_dragon_update
local controller_stage_37_dragon_boss_insert
local controller_stage_37_dragon_boss_update
local controller_stage_37_dragon_boss_on_block_towers
local controller_stage_37_dragon_boss_on_go_to_tower
decal_stage_37_easter_egg_how_to_train_dragon_update = function(this, store, script)
	local clics = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			clics = clics + 1
			if clics == 1 then
				S:queue("Stage37EasterEggTrainDragonPart1")
				S:queue("Stage37EasterEggTrainDragonPart2")
				U.y_animation_play(this, "tap1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle2", nil, store.tick_ts, true, 1, true)
			elseif clics == 2 then
				U.y_animation_play(this, "tap2", nil, store.tick_ts, 1, 1)
				local spawn = E:create_entity(this.spawn_entity)
				spawn.pos = V.v(this.pos.x, this.pos.y - 15)
				spawn.tween.ts = store.tick_ts - 0.2
				spawn.spawn_pos = V.v(300, 250)
				spawn.tween.props[4].keys = {{0, v(0, 0)}, {0.5, v(0, spawn.flight_height)}}
				simulation:queue_insert_entity(spawn)
				simulation:queue_remove_entity(this)
				return
			end
			this.ui.can_click = true
		end
		coroutine.yield()
	end
end
controller_stage_37_dragon_boss_insert = function(this, store, script)
	local mode_key = "campaign"
	if store.level_mode == GAME_MODE_IRON then
		mode_key = "iron"
	end
	if store.level_mode == GAME_MODE_HEROIC then
		mode_key = "heroic"
	end
	if mode_key ~= "campaign" then
		U.sprites_hide(this, nil, nil, true)
	end
	return true
end
controller_stage_37_dragon_boss_update = function(this, store, script)
	local tall_towers = {}
	local last_tower_block_ts = store.tick_ts
	local paths_controller
	local current_position = 1
	local idle_positions = {}
	local sides = {"left", "right"}
	local positions_key = {"start", "mid", "final"}
	local mode_key = "campaign"
	if store.level_mode == GAME_MODE_IRON then
		mode_key = "iron"
	end
	if store.level_mode == GAME_MODE_HEROIC then
		mode_key = "heroic"
	end
	local b = this.boss_controler_balance[mode_key]
	local geiser_decal_t = E:get_template("aura_boss_37_geiser_decal_dmg_bossfight")
	local next_area_attack_ts = store.tick_ts
	local shadow_sprite = this.render.sprites[this.render.sid_shadow]
	local function update_shadow()
		local has_no_shadow = GR:cell_is(this.pos.x, this.pos.y + shadow_sprite.offset.y, TERRAIN_NO_SHADOW)
		shadow_sprite.hidden = has_no_shadow
	end
	local function get_power_fissure_side()
		local available_sides = {}
		for _, side in ipairs(sides) do
			local position = positions_key[current_position]
			local side_vals = b.pre_fight_area_attack[position][side]
			local pi = side_vals.path
			local ni = side_vals.node
			for i = 1, b.area_attack_extension do
				if P:is_node_valid(pi, ni) then
					local npos = P:node_pos(pi, math.random(1, 3), ni + i * 2 * (i % 2 == 0 and 1 or -1))
					local soldiers = U.find_soldiers_in_range(store.soldiers, npos, 0, geiser_decal_t.aura.radius, geiser_decal_t.aura.vis_flags, geiser_decal_t.aura.vis_bans, function(e)
						if e.motion then
							return e.motion.arrived
						end
						return true
					end)
					if soldiers and #soldiers > 0 then
						table.insert(available_sides, side)
						break
					end
				end
			end
		end
		if #available_sides == 0 then
			return nil
		end
		return table.random(available_sides)
	end
	local function power_fissures(side)
		if not side then
			next_area_attack_ts = store.tick_ts + fts(10)
			return
		end
		if current_position == 1 then
			side = "left"
		end
		if side == "left" and not this.render.sprites[1].flip_x then
			U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
			this.render.sprites[1].flip_x = true
		end
		if side == "right" and this.render.sprites[1].flip_x then
			U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
			this.render.sprites[1].flip_x = false
		end
		U.y_animation_play(this, "torre_ataque_basic_in", nil, store.tick_ts, 1, 1)
		local fires_positions = {}
		local position = positions_key[current_position]
		local side_vals = b.pre_fight_area_attack[position][side]
		local pi = side_vals.path
		local ni = side_vals.node
		for i = 1, b.area_attack_extension do
			if P:is_node_valid(pi, ni) then
				local npos = P:node_pos(pi, math.random(1, 3), ni + i * 2 * (i % 2 == 0 and 1 or -1))
				table.insert(fires_positions, npos)
			end
		end
		local offset = V.vclone(this.decal_bullets_offset)
		local offset_escalation = V.v(-5, -5)
		if this.render.sprites[1].flip_x then
			offset.x = -offset.x
			offset_escalation.x = -offset_escalation.x
		end
		for i, pos in ipairs(fires_positions) do
			local b = E:create_entity(this.decal_bullet[store.level_mode])
			b.bullet.to = pos
			b.bullet.from = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
			b.pos = V.vclone(b.bullet.from)
			simulation:queue_insert_entity(b)
			U.animation_start(this, "torre_ataque_basic_loop", nil, store.tick_ts, false, 1, true)
			U.y_animation_wait_default(this)
		end
		U.y_animation_play(this, "torre_ataque_basic_out", nil, store.tick_ts, 1, 1)
		next_area_attack_ts = store.tick_ts + b.area_attack_cooldown
		U.y_animation_wait_default(this)
		if not this.render.sprites[1].flip_x then
			U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
			this.render.sprites[1].flip_x = true
		end
		U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
	end
	local function y_move_to_position(pos, cinematic)
		current_position = pos
		local speed = 100
		local desired_pos = idle_positions[current_position]
		local flip = this.pos.x > desired_pos.x and true or false
		if cinematic then
			signal.emit("pan-zoom-camera", 1, {
				x = this.pos.x,
				y = this.pos.y
			}, OVtargets(nil, 1.5))
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			U.y_wait_unconditional(store, 1)
		end
		U.y_animation_play(this, "roar_in", nil, store.tick_ts, 1, 1)
		S:queue("Stage37Cinematic1Roar")
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = 0.5
		shake.aura.duration = 3
		shake.aura.freq_factor = 4
		simulation:queue_insert_entity(shake)
		U.animation_start(this, "roar_loop", nil, store.tick_ts, true, 1, true)
		U.y_wait_unconditional(store, 2)
		this.render.sprites[1].runs = 0
		U.y_animation_wait_default(this)
		U.y_animation_play(this, "roar_out", nil, store.tick_ts, 1, 1)
		U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
		U.y_wait_unconditional(store, 0.5)
		U.animation_start(this, "torre_out", nil, store.tick_ts, false, 1, true)
		U.y_wait_unconditional(store, fts(1))
		S:queue("Stage37Cinematic1Aleteo")
		U.y_wait_unconditional(store, fts(6))
		S:queue("Stage37Cinematic1Aleteo")
		U.y_wait_unconditional(store, fts(6))
		this.tween.ts = store.tick_ts
		this.tween.props[1].disabled = false
		this.tween.props[2].disabled = true
		local fx = E:create_entity("fx_boss_stage_37_tower_out")
		fx.pos = V.vclone(this.pos)
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = 0.3
		shake.aura.duration = 0.5
		shake.aura.freq_factor = 4
		simulation:queue_insert_entity(shake)
		U.y_animation_wait_default(this)
		if cinematic then
			local dist = V.dist(this.pos.x, this.pos.y, desired_pos.x, desired_pos.y)
			local time = dist / speed
			signal.emit("pan-zoom-camera", time, {
				x = desired_pos.x,
				y = desired_pos.y
			}, OVtargets(nil, 1.5))
		end
		U.animation_start(this, "walk", flip, store.tick_ts, true, 1, true)
		local forward_offset1 = 40
		local lateral_offset1 = 18
		local overshoot_forward = 350
		local lateral_offset2 = 200
		if desired_pos.x < this.pos.x then
			overshoot_forward = 0
			lateral_offset2 = -lateral_offset2 / 2
		end
		local P0x, P0y = this.pos.x, this.pos.y
		local dirx, diry = V.normalize(desired_pos.x - P0x, desired_pos.y - P0y)
		local px, py = -diry, dirx
		local P3x, P3y = desired_pos.x, desired_pos.y
		local C1x = P0x + dirx * forward_offset1 + px * lateral_offset1
		local C1y = P0y + diry * forward_offset1 + py * lateral_offset1
		local C2x = P3x + dirx * overshoot_forward + px * lateral_offset2
		local C2y = P3y + diry * overshoot_forward + py * lateral_offset2
		local function bez3(u, ax, ay, bx, by, cx, cy, dx, dy)
			local iu = 1 - u
			local iu2 = iu * iu
			local u2 = u * u
			local x = iu2 * iu * ax + 3 * iu2 * u * bx + 3 * iu * u2 * cx + u2 * u * dx
			local y = iu2 * iu * ay + 3 * iu2 * u * by + 3 * iu * u2 * cy + u2 * u * dy
			return x, y
		end
		local function approx_len(steps)
			local len, prevx, prevy = 0, P0x, P0y
			for i = 1, steps do
				local u = i / steps
				local x, y = bez3(u, P0x, P0y, C1x, C1y, C2x, C2y, P3x, P3y)
				len = len + V.dist(prevx, prevy, x, y)
				prevx, prevy = x, y
			end
			return len
		end
		local L = approx_len(32)
		local u = 0
		local destruccion_torre_ts
		local did_pan_zoom = false
		local pan_zoom_timing = 0.6
		local animation_timing = current_position == 1 and 0.95 or 0.8
		while u < 1 do
			u = math.min(1, u + speed * store.tick_length / math.max(1e-06, L))
			local x, y = bez3(u, P0x, P0y, C1x, C1y, C2x, C2y, P3x, P3y)
			this.render.sprites[1].flip_x = x < this.pos.x
			this.pos.x, this.pos.y = x, y
			if animation_timing <= u and this.render.sprites[1].name ~= "in_destruccion_torre" and this.render.sprites[1].name ~= "destruccion_torre" then
				U.animation_start(this, "in_destruccion_torre", nil, store.tick_ts, false, 1, true)
				this.tween.ts = store.tick_ts
				this.tween.props[1].disabled = true
				this.tween.props[2].disabled = false
			end
			if pan_zoom_timing <= u and cinematic and not did_pan_zoom then
				did_pan_zoom = true
				signal.emit("pan-zoom-camera", 1.3, {
					x = this.pos.x,
					y = this.pos.y
				}, OVtargets(nil, 1.2))
			end
			if this.render.sprites[1].name == "in_destruccion_torre" and U.animation_finished_default(this) then
				U.animation_start(this, "destruccion_torre", nil, store.tick_ts, false, 1, true)
				S:queue("Stage37Cinematic1Arrive")
				destruccion_torre_ts = store.tick_ts + fts(2)
			end
			if destruccion_torre_ts and destruccion_torre_ts <= store.tick_ts then
				destruccion_torre_ts = nil
				if tall_towers[current_position] then
					tall_towers[current_position]:destroy(store)
				end
				local shake = E:create_entity("aura_screen_shake")
				shake.aura.amplitude = 1
				shake.aura.duration = 0.5
				shake.aura.freq_factor = 4
				simulation:queue_insert_entity(shake)
				if current_position == 1 then
					local fx = E:create_entity("fx_boss_stage_37_tower_out")
					fx.pos = V.vclone(this.pos)
					fx.render.sprites[1].ts = store.tick_ts
					simulation:queue_insert_entity(fx)
				end
			end
			update_shadow()
			if this.render.sprites[1].name == "walk" and this.render.sprites[1].frame_idx == 10 then
				S:queue("Stage37Cinematic1Aleteo")
			end
			coroutine.yield()
		end
		while V.dist(this.pos.x, this.pos.y, P3x, P3y) > 1 do
			local nx, ny = V.normalize(P3x - this.pos.x, P3y - this.pos.y)
			this.pos.x = this.pos.x + nx * store.tick_length * speed
			this.pos.y = this.pos.y + ny * store.tick_length * speed
			update_shadow()
			coroutine.yield()
		end
		if this.render.sprites[1].name ~= "destruccion_torre" then
			U.y_animation_wait_default(this)
			U.animation_start(this, "destruccion_torre", nil, store.tick_ts, false, 1, true)
			U.y_wait_unconditional(store, fts(2))
			S:queue("Stage37Cinematic1Arrive")
			if tall_towers[current_position] then
				tall_towers[current_position]:destroy(store)
			end
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 1
			shake.aura.duration = 0.5
			shake.aura.freq_factor = 4
			simulation:queue_insert_entity(shake)
			if current_position == 1 then
				local fx = E:create_entity("fx_boss_stage_37_tower_out")
				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
		U.y_animation_wait_default(this)
		U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
		if cinematic then
			U.y_wait_unconditional(store, 0.4)
			paths_controller.show_path = 1
			U.y_animation_play(this, "roar_in", nil, store.tick_ts, 1, 1)
			S:queue("Stage37Cinematic2")
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.5
			shake.aura.duration = 6.5
			shake.aura.freq_factor = 4
			simulation:queue_insert_entity(shake)
			U.animation_start(this, "roar_loop", nil, store.tick_ts, true, 1, true)
			U.y_wait_unconditional(store, 6)
			this.render.sprites[1].runs = 0
			U.y_animation_wait_default(this)
			U.y_animation_play(this, "roar_out", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
			signal.emit("hide-curtains")
			signal.emit("show-gui")
			signal.emit("end-cinematic", true)
		end
	end
	local mode_key = "campaign"
	if store.level_mode == GAME_MODE_IRON then
		mode_key = "iron"
	end
	if store.level_mode == GAME_MODE_HEROIC then
		mode_key = "heroic"
	end
	local b = this.boss_controler_balance[mode_key]
	for _, v in pairs(store.entities) do
		if v.template_name == "decal_stage_37_tall_tower_mid" then
			idle_positions[2] = V.v(v.pos.x + this.towers_idle_position_offset.x, v.pos.y + this.towers_idle_position_offset.y)
			tall_towers[2] = v
		elseif v.template_name == "decal_stage_37_tall_tower_left" then
			idle_positions[3] = V.v(v.pos.x + this.towers_idle_position_offset.x, v.pos.y + this.towers_idle_position_offset.y)
			tall_towers[3] = v
		elseif v.template_name == "decal_stage_37_tall_tower_right" then
			idle_positions[1] = V.v(v.pos.x + this.towers_idle_position_offset.x, v.pos.y + this.towers_idle_position_offset.y)
			tall_towers[1] = v
			this.pos.x, this.pos.y = idle_positions[1].x, idle_positions[1].y
		elseif v.template_name == "stage_37_paths_controller" then
			paths_controller = v
		end
	end
	if mode_key ~= "campaign" then
		current_position = #idle_positions
		this.pos.x, this.pos.y = idle_positions[current_position].x, idle_positions[current_position].y
		for _, v in pairs(tall_towers) do
			v:destroy(store, true)
		end
		simulation:queue_remove_entity(this)
		return
	end
	this.last_taunt = nil
	this.current_taunt = nil
	local function manage_taunts()
		if not this.do_taunt then
			return false
		end
		local taunt = this.do_taunt
		this.do_taunt = nil
		this.last_taunt = this.current_taunt
		this.current_taunt = taunt
		U.y_animation_play(this, "roar_in", nil, store.tick_ts, 1, 1)
		S:queue("Stage37MurglunIntroRoar")
		signal.emit("show-balloon_tutorial", taunt, false)
		local shake = E:create_entity("aura_screen_shake")
		shake.aura.amplitude = 0.1
		shake.aura.duration = 4
		shake.aura.freq_factor = 4
		simulation:queue_insert_entity(shake)
		U.animation_start(this, "roar_loop", nil, store.tick_ts, true, 1, true)
		U.y_wait_unconditional(store, 3.2)
		this.render.sprites[1].runs = 0
		U.y_animation_wait_default(this)
		U.y_animation_play(this, "roar_out", nil, store.tick_ts, 1, 1)
		U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
		this.last_taunt = this.current_taunt
		this.current_taunt = nil
		return true
	end
	while store.wave_group_number < 1 do
		manage_taunts()
		coroutine.yield()
	end
	next_area_attack_ts = store.tick_ts + b.area_attack_cooldown
	while true do
		if this.activate_block_towers then
			while store.tick_ts < last_tower_block_ts + 3 do
				coroutine.yield()
			end
			local side_block_towers = this.activate_block_towers
			local duration = this.activate_block_towers_duration
			this.activate_block_towers = nil
			this.activate_block_towers_duration = nil
			local towers = table.filter(store.towers, function(k, v)
				return not v.pending_removal and v.tower and not v.tower_holder and v.tower.can_be_mod and not v.tower.blocked and table.contains(side_block_towers, tonumber(v.tower.holder_id))
			end)
			if #towers == 0 then
				goto label_2172_0
			end
			local target = towers[math.random(1, #towers)]
			if target.pos.x <= this.pos.x and not this.render.sprites[1].flip_x then
				U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
				this.render.sprites[1].flip_x = true
			end
			if target.pos.x > this.pos.x and this.render.sprites[1].flip_x then
				U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
				this.render.sprites[1].flip_x = false
			end
			U.animation_start(this, "torre_stun", nil, store.tick_ts, false, 1, true)
			U.y_wait_unconditional(store, fts(37))
			local offset = V.v(-4, 160)
			if not this.render.sprites[1].flip_x then
				offset.x = -offset.x
			end
			local bullet = E:create_entity("boss_murglun_proyectil_tower_stun")
			bullet.pos.x, bullet.pos.y = this.pos.x + offset.x, this.pos.y + offset.y
			bullet.bullet.from = V.vclone(bullet.pos)
			bullet.bullet.to = V.vclone(target.pos)
			bullet.bullet.target_id = target.id
			bullet.bullet.mod_duration = duration
			simulation:queue_insert_entity(bullet)
			U.y_animation_wait_default(this)
			if not this.render.sprites[1].flip_x then
				U.y_animation_play(this, "giro_torre", nil, store.tick_ts, 1, 1)
				this.render.sprites[1].flip_x = true
			end
			U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
			last_tower_block_ts = store.tick_ts
		end
		::label_2172_0::
		if next_area_attack_ts < store.tick_ts then
			power_fissures(get_power_fissure_side())
		end
		if this.activate_next_tower then
			local new_pos = this.activate_next_tower
			local cinematic = this.next_tower_cinematic
			this.activate_next_tower = nil
			this.next_tower_cinematic = nil
			y_move_to_position(new_pos, cinematic)
		end
		if this.do_boss_unit_spawn then
			this.do_boss_unit_spawn = nil
			U.y_wait_unconditional(store, 3)
			local boss = E:create_entity("boss_murglum")
			boss.nav_path.pi = 4
			boss.nav_path.spi = 1
			boss.nav_path.ni = boss.spawn_node
			boss.pos = P:node_pos(boss.nav_path.pi, boss.nav_path.spi, boss.nav_path.ni)
			local boss_pushed_bans = U.push_bans(boss.vis, F_ALL)
			U.sprites_hide(boss)
			local boss_speed = boss.motion.max_speed
			U.update_max_speed(boss, 0)
			simulation:queue_insert_entity(boss)
			shadow_sprite.offset.y = 0
			S:queue("Stage37MurglunIntroRoar")
			U.y_animation_play(this, "roar_in", nil, store.tick_ts, 1, 1)
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.5
			shake.aura.duration = 3
			shake.aura.freq_factor = 4
			simulation:queue_insert_entity(shake)
			U.animation_start(this, "roar_loop", nil, store.tick_ts, true, 1, true)
			U.y_wait_unconditional(store, 2)
			signal.emit("boss_fight_start_tweened", boss, 0.5)
			this.render.sprites[1].runs = 0
			U.y_animation_wait_default(this)
			U.y_animation_play(this, "roar_out", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "torre_idle", nil, store.tick_ts, true, 1, true)
			U.y_wait_unconditional(store, 0.5)
			U.animation_start(this, "torre_out", nil, store.tick_ts, false, 1, true)
			U.y_wait_unconditional(store, fts(13))
			this.tween.ts = store.tick_ts
			this.tween.props[1].disabled = false
			this.tween.props[2].disabled = true
			local fx = E:create_entity("fx_boss_stage_37_tower_out")
			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.3
			shake.aura.duration = 0.5
			shake.aura.freq_factor = 4
			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(this)
			U.animation_start(this, "walk", nil, store.tick_ts, true, 1, true)
			local diff, norm_x, norm_y
			local speed = 100
			while V.dist(this.pos.x, this.pos.y, boss.pos.x, boss.pos.y) > 1 do
				diff = V.v(boss.pos.x - this.pos.x, boss.pos.y - this.pos.y)
				norm_x, norm_y = V.normalize(diff.x, diff.y)
				local speed_diff = boss_speed * 2 - speed
				speed = speed + speed_diff * 1 * store.tick_length
				this.pos.x, this.pos.y = this.pos.x + norm_x * speed * store.tick_length, this.pos.y + norm_y * speed * store.tick_length
				update_shadow()
				coroutine.yield()
			end
			U.pop_bans(boss.vis, boss_pushed_bans)
			U.sprites_show(boss)
			U.sprites_hide(this)
			boss.render.sprites[1].ts = this.render.sprites[1].ts
			U.update_max_speed(boss, boss_speed)
			simulation:queue_remove_entity(this)
		end
		manage_taunts()
		coroutine.yield()
	end
end
controller_stage_37_dragon_boss_on_block_towers = function(this, store, action, towers_list, duration)
	this.activate_block_towers = {}
	for num in string.gmatch(towers_list, "([^,]+)") do
		table.insert(this.activate_block_towers, tonumber(num))
	end
	this.activate_block_towers_duration = tonumber(duration)
end
controller_stage_37_dragon_boss_on_go_to_tower = function(this, store, action, twr_index, cinematic)
	this.activate_next_tower = tonumber(twr_index)
	this.next_tower_cinematic = cinematic == "cinematic"
end
local tt
tt = E:register_t_hot("decal_stage_37_layer02", "decal", true)
tt.render.sprites[1].name = "stage_37_layer02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN + 1
tt = E:register_t_hot("decal_stage_37_mask_islas", "decal_tween", true)
E:add_comps(tt, "main_script")
tt.main_script.insert = scripts.decal_stage_36_mask_islas.insert
tt.islas_levels = {
	TOP = Z_BACKGROUND_COVERS + 2,
	MID = Z_BACKGROUND_BETWEEN - 1,
	BACK = Z_BACKGROUND_BETWEEN - 2
}
tt.islas_settings = {
	{
		str = -6,
		z = "TOP",
		freq = 120
	},
	{
		str = -6,
		z = "TOP",
		freq = 120
	},
	{
		str = -6,
		z = "TOP",
		freq = 120
	},
	{
		str = -6,
		z = "TOP",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	},
	{
		str = -6,
		z = "BACK",
		freq = 120
	}
}
tt.temp_i = 0
for i = 1, #tt.islas_settings do
	if not tt.islas_settings[i].skip then
		tt.temp_i = tt.temp_i + 1
		local str = tt.islas_settings[i].str
		local freq = tt.islas_settings[i].freq
		local z = tt.islas_levels[tt.islas_settings[i].z]
		freq = freq + math.random(-20, 20)
		tt.render.sprites[tt.temp_i] = E:clone_c("sprite")
		tt.render.sprites[tt.temp_i].name = "stage_02_islas_flotantes00" .. (i < 10 and "0" or "") .. i
		tt.render.sprites[tt.temp_i].animated = false
		tt.render.sprites[tt.temp_i].z = z
		tt.tween.props[tt.temp_i] = E:clone_c("tween_prop")
		tt.tween.props[tt.temp_i].sprite_id = tt.temp_i
		tt.tween.props[tt.temp_i].name = "offset"
		tt.tween.props[tt.temp_i].interp = "sine"
		tt.tween.props[tt.temp_i].keys = {{fts(0), v(0, 0)}, {fts(freq), v(0, -str)}, {fts(freq * 2), v(0, 0)}}
		tt.tween.props[tt.temp_i].loop = true
	end
end
tt.temp_i = nil
tt.tween.remove = false
tt = E:register_t_hot("decal_stage_37_mask_01", "decal", true)
tt.render.sprites[1].name = "stage_37_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 263
tt = E:register_t_hot("decal_stage_37_mask_04", "decal", true)
tt.render.sprites[1].name = "stage_37_mask_04"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 86
tt = E:register_t_hot("decal_stage_37_layer01", "decal", true)
tt.render.sprites[1].name = "stage_37_layer01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt = E:register_t_hot("decal_stage_37_easter_egg_how_to_train_dragon", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_37_easter_egg_how_to_train_dragon_update
tt.render.sprites[1].prefix = "train_dragon_characters"
tt.render.sprites[1].name = "idle1"
tt.ui.click_rect = r(-25, -20, 75, 40)
tt.spawn_entity = "soldier_dragon_warden_dragon_raider_mounted"
tt = E:register_t_hot("decal_stage_37_mask_02", "decal", true)
tt.render.sprites[1].name = "stage_37_mask_02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 145
tt = E:register_t_hot("controller_stage_37_dragon_boss", "decal_scripted", true)
E:add_comps(tt, "events", "editor", "tween")
tt.boss_controler_balance = {
	hp = 10400,
	max_towers_blocked = 2,
	spawn_node = 50,
	magic_armor = 0,
	speed = 27,
	armor = 0,
	basic_attack = {
		only_foward = true,
		min_range = 50,
		max_range = 150,
		cooldown = 1.3,
		damage_max = 150,
		hold_advance = true,
		damage_min = 100,
		damage_radius = 50,
		only_foward_range = 50,
		damage_type = DAMAGE_MAGICAL
	},
	block_towers_bossfight = {
		repair_cost = 100,
		first_cooldown = 10,
		duration = 10,
		nodes_limit = 30,
		cooldown = 5,
		max_towers_blocked = 1,
		min_range = 100,
		max_range = 250
	},
	geisers_bossfight = {
		only_foward = true,
		first_cooldown = 10,
		duration = 6,
		geisers_amount = 7,
		cooldown = 13,
		max_damage = 15,
		min_damage = 10,
		nodes_limit = 30,
		damage_every = 0.3,
		damage_type = DAMAGE_MAGICAL
	},
	feral_bite = {
		cooldown = 5,
		first_cooldown = 10,
		nodes_limit = 30,
		area_damage = {
			min_damage = 300,
			radius = 50,
			max_damage = 500,
			damage_type = DAMAGE_PHYSICAL
		}
	},
	campaign = {
		area_attack_damage_max = 30,
		max_towers_blocked = 1,
		area_attack_cooldown = 20,
		area_attack_duration = 10,
		area_attack_extension = 7,
		pre_fight_area_attack = {
			start = {
				left = {
					node = 90,
					path = 2
				},
				right = {
					node = 90,
					path = 2
				}
			},
			mid = {
				left = {
					node = 120,
					path = 4
				},
				right = {
					node = 87,
					path = 4
				}
			},
			final = {
				left = {
					node = 100,
					path = 1
				},
				right = {
					node = 65,
					path = 1
				}
			}
		},
		area_attack_damage_type = DAMAGE_EXPLOSION
	},
	heroic = {
		path = {1},
		node = {50}
	},
	pre_fight_area_attack = {},
	iron = {
		max_towers_blocked = 2,
		pre_fight_area_attack = {
			path = {1},
			node = {50}
		}
	}
}
tt.main_script.insert = controller_stage_37_dragon_boss_insert
tt.main_script.update = controller_stage_37_dragon_boss_update
tt.decal_bullet = {
	[GAME_MODE_CAMPAIGN] = "bullet_boss_stage_37_geisers_waves_campaign",
	[GAME_MODE_IRON] = "bullet_boss_stage_37_geisers_waves_campaign",
	[GAME_MODE_HEROIC] = "bullet_boss_stage_37_geisers_waves_campaign"
}
tt.decal_bullets_offset = v(45, -20)
tt.render.sprites[1].prefix = "boss_murglun_boss"
tt.render.sprites[1].name = "torre_idle"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].sort_y_offset = -50
tt.render.sid_shadow = 2
tt.render.sprites[tt.render.sid_shadow] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow].animated = false
tt.render.sprites[tt.render.sid_shadow].name = "decal_flying_shadow_hard"
tt.render.sprites[tt.render.sid_shadow].hidden = false
tt.render.sprites[tt.render.sid_shadow].scale = vv(2)
tt.render.sprites[tt.render.sid_shadow].z = Z_DECALS
tt.render.sprites[tt.render.sid_shadow].offset = v(0, -80)
tt.events.list[1].name = "block_tower"
tt.events.list[1].on_event = controller_stage_37_dragon_boss_on_block_towers
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "go_to_tower"
tt.events.list[2].on_event = controller_stage_37_dragon_boss_on_go_to_tower
tt.flight_height = 70
tt.towers_idle_position_offset = v(0, 85)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{0, v(0, 0)}, {fts(3), v(0, tt.flight_height * 0.8)}, {fts(10), v(0, tt.flight_height)}}
tt.tween.props[1].disabled = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].keys = {{0, v(0, tt.flight_height)}, {fts(6), v(0, tt.flight_height)}, {fts(11), v(0, tt.flight_height + 50)}, {fts(19), v(0, tt.flight_height + 70)}, {fts(24), v(0, tt.flight_height + 70)}, {fts(26), v(0, 0)}}
tt.tween.props[2].disabled = true
tt = E:register_t_hot("decal_stage_37_mask_03", "decal", true)
tt.render.sprites[1].name = "stage_37_mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 192
tt = E:register_t_hot("decal_stage_37_mask_05", "decal", true)
tt.render.sprites[1].name = "stage_37_mask_05"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -239
