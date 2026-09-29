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
local RLU = require("all.rally_utils")
local function fts(v)
	return v / FPS
end

local function move_to(store, this, destination, duration, easing)
	local start_ts = store.tick_ts
	local from = V.vclone(this.pos)

	while duration > store.tick_ts - start_ts do
		local phase = (store.tick_ts - start_ts) / duration

		this.pos.x = U.ease_value(from.x, destination.x, phase, easing)
		this.pos.y = U.ease_value(from.y, destination.y, phase, easing)
		this.render.sprites[1].sort_y_offset = U.ease_value(0, from.y - destination.y, phase, easing)

		coroutine.yield()
	end

	this.pos = V.vclone(destination)
end

local decal_stage_36_mask_islas = {}

function decal_stage_36_mask_islas.insert(this, store, script)
	for _, p in ipairs(this.tween.props) do
		p.ts = store.tick_ts - p.keys[2][1] * math.random()
	end

	return true
end

local decal_stage_37_bridge = {}

function decal_stage_37_bridge.destroy(this, store)
	U.animation_start(this, "out", nil, store.tick_ts, true, 1, true)
end

local decal_stage_37_easter_daenerys = {}

local function move_to(store, this, destination, duration, easing)
	local start_ts = store.tick_ts
	local from = V.vclone(this.pos)

	while duration > store.tick_ts - start_ts do
		local phase = (store.tick_ts - start_ts) / duration

		this.pos.x = U.ease_value(from.x, destination.x, phase, easing)
		this.pos.y = U.ease_value(from.y, destination.y, phase, easing)
		this.render.sprites[1].sort_y_offset = U.ease_value(0, from.y - destination.y, phase, easing)

		coroutine.yield()
	end

	this.pos = V.vclone(destination)
end

function decal_stage_37_easter_daenerys.update(this, store, script)
	local clics = 0

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			clics = clics + 1

			if clics == 1 then
				S:queue("Stage37EasterEggDaenerysPart1")
				U.y_animation_play(this, "click_1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_2", nil, store.tick_ts, true, 1, true)
			elseif clics == 2 then
				S:queue("Stage37EasterEggDaenerysPart2")
				U.y_animation_play(this, "click_2", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "loop_salida", nil, store.tick_ts, true, 1, true)

				local destination = V.v(-300, 800)

				move_to(store, this, destination, 2, "sine-out")
				simulation:queue_remove_entity(this)

				return
			end

			this.ui.can_click = true
		end

		coroutine.yield()
	end
end

local decal_stage_37_tall_tower = {}

function decal_stage_37_tall_tower.update(this, store)
	if this.template_name == "decal_stage_37_tall_tower_right" then
		return
	end

	local bridge, barrack_warden

	if this.destroy_warden_barrack then
		for _, v in pairs(store.entities) do
			if v.template_name == "stage_37_barrack_dragon_wardens" and V.dist(this.pos.x, this.pos.y, v.pos.x, v.pos.y) < 200 then
				barrack_warden = v
			elseif v.template_name == "decal_stage_37_bridge" and V.dist(this.pos.x, this.pos.y, v.pos.x, v.pos.y) < 200 then
				bridge = v
			end
		end
	end

	while true do
		if this.destroyed_event then
			this.destroyed_event = nil

			local immediate = this.immediate_destroy

			this.immediate_destroy = nil

			if not immediate then
				if this.sid_front then
					U.sprites_show(this, this.sid_front, this.sid_front)
				end

				this.render.sprites[this.sid_back].scale = V.v(2, 2)

				U.animation_start_group(this, "destruccion_torre", nil, store.tick_ts, false, "layers")
			end

			if barrack_warden then
				if not immediate then
					U.y_wait_unconditional(store, this.destroy_warden_barrack)
				end

				barrack_warden:destroy(store)
			end

			if bridge then
				bridge:destroy(store)
			end

			if not immediate then
				U.y_animation_wait_group(this, "layers", 1)

				if this.sid_front then
					U.sprites_hide(this, this.sid_front, this.sid_front)
				end
			end

			this.render.sprites[this.sid_back].scale = V.v(1, 1)

			U.animation_start_group(this, "idle_rota", nil, store.tick_ts, true, "layers")

			return
		end

		coroutine.yield()
	end
end

function decal_stage_37_tall_tower.spawn_anim(this, store)
	local fx = E:create_entity(this.spawn_fx)

	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
end

function decal_stage_37_tall_tower.destroy(this, store, immediate)
	this.destroyed_event = true
	this.immediate_destroy = immediate
end

local stage_36_paths_controller = {}

function stage_36_paths_controller.update(this, store, script)
	local radius = 32

	if store.level_idx == 37 then
		radius = 16
	end

	local function set_pos_terrain(x, y, terrain_type, radius)
		radius = radius or GR.cell_size

		local i, j = GR:get_coords(x, y)

		GR:set_cell(i, j, terrain_type)

		if radius > GR.cell_size then
			local cells_radius = math.ceil(radius / GR.cell_size)

			for di = -cells_radius, cells_radius do
				for dj = -cells_radius, cells_radius do
					local ci, cj = i + di, j + dj

					if ci > 0 and ci <= GR.grid_w and cj > 0 and cj <= GR.grid_h then
						GR:set_cell(ci, cj, terrain_type)
					end
				end
			end
		end
	end

	local function set_path_cells_terrain(path_index, terrain_type, radius)
		radius = radius or GR.cell_size

		local subpath_indexes = {1, 2, 3}

		for _, spi in pairs(subpath_indexes) do
			local path = P.paths[path_index][spi]

			if path then
				for ni = 1, #path do
					local node = path[ni]

					set_pos_terrain(node.x, node.y, terrain_type, radius)
				end
			end
		end
	end

	local function instant_deploy_islands_1_and_2(this, store)
		local function dist2(ax, ay, bx, by)
			local dx, dy = ax - bx, ay - bx

			return dx * dx + dy * dy
		end

		local towers_cached

		local function get_towers()
			if towers_cached then
				return towers_cached
			end

			local out = {}

			for _, e in pairs(store.entities) do
				if e.tower and e.pos then
					out[#out + 1] = e
				end
			end

			towers_cached = out

			return out
		end

		local function tower_by_pos(pos)
			if not pos then
				return nil
			end

			local best, best_d2 = nil, math.huge

			for _, t in ipairs(get_towers()) do
				local dx, dy = pos.x - t.pos.x, pos.y - t.pos.y
				local d2 = dx * dx + dy * dy

				if d2 < best_d2 then
					best_d2 = d2
					best = t
				end
			end

			return best
		end

		this._left_island_up = true
		this._right_island_up = true

		U.sprites_show(this, 1, 1, true)

		if this.render.sprites[2] then
			U.sprites_show(this, 2, 2, true)
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)

		if this.render.sprites[2] then
			U.animation_start(this, "idle", nil, store.tick_ts, true, 2, true)
		end

		local function reveal_group(holders_group)
			if not holders_group then
				return
			end

			for _, hcfg in pairs(holders_group) do
				if not hcfg.objects then
					local holder = hcfg.pos and tower_by_pos(hcfg.pos) or nil

					if holder then
						if U and U.sprites_show then
							U.sprites_show(holder, nil, nil, true)
						end

						if holder.ui then
							holder.ui.can_click = true
						end

						if holder.tower then
							holder.tower.can_hover = true
						end
					end
				else
					local hidden_objects_names = {}

					do
						local controller_upg

						for _, e in pairs(store.entities) do
							if e.template_name == "controller_upgrades_alliance" then
								controller_upg = e

								break
							end
						end

						if controller_upg then
							if controller_upg.coil then
								table.insert(hidden_objects_names, controller_upg.coil)
							end

							if controller_upg.seal then
								table.insert(hidden_objects_names, controller_upg.seal)
							end
						else
							table.insert(hidden_objects_names, "decal_defense_flag")
							table.insert(hidden_objects_names, "decal_defend_point")
						end
					end

					local hidden_objects_y_threshold = 384

					for _, e in pairs(store.entities) do
						if e.pos and hidden_objects_y_threshold <= e.pos.y and e.template_name and table.contains(hidden_objects_names, e.template_name) and U and U.sprites_show then
							U.sprites_show(e, nil, nil, true)
						end
					end
				end

				hcfg.done = true
			end
		end

		reveal_group(this.holders_list and this.holders_list[1])
		reveal_group(this.holders_list and this.holders_list[2])

		for k, unlock_cfg in pairs(this.path_unlocks) do
			for _, pi in pairs(unlock_cfg.paths) do
				P:activate_path(pi)
			end

			for _, pi in pairs(unlock_cfg.terrain_paths) do
				set_path_cells_terrain(pi, TERRAIN_LAND, radius)
			end

			for _, extra_cfg in pairs(unlock_cfg.extra_terrains) do
				set_pos_terrain(extra_cfg.x, extra_cfg.y, extra_cfg.terrain_type, extra_cfg.radius)
			end
		end
	end

	local islands_up = {}

	local function tower_by_pos(pos)
		local towers = table.filter(store.entities, function(k, e)
			return e.tower
		end)
		local min_distance = 9999999
		local tower

		for index, candidate in ipairs(towers) do
			local distance = V.dist(pos.x, pos.y, candidate.pos.x, candidate.pos.y)

			if distance < min_distance or not tower then
				min_distance = distance
				tower = candidate
			end
		end

		return tower
	end

	for _, v in pairs(this.holders_list) do
		for _, hcfg in pairs(v) do
			if hcfg.pos then
				local h = tower_by_pos(hcfg.pos)

				U.sprites_hide(h, nil, nil, true)

				h.ui.can_click = false
				h.tower.can_hover = false
			end
		end
	end

	local controller_upg

	for _, e in pairs(store.entities) do
		if e.template_name == "controller_upgrades_alliance" then
			controller_upg = e

			break
		end
	end

	local hidden_objects_names = {}
	local coil = "decal_defense_flag"
	local seal = "decal_defend_point"

	if controller_upg then
		if controller_upg.coil then
			coil = controller_upg.coil
		end

		if controller_upg.seal then
			seal = controller_upg.seal
		end
	end

	table.insert(hidden_objects_names, coil)
	table.insert(hidden_objects_names, seal)

	local path_flags = table.filter(store.entities, function(k, e)
		if not table.contains(hidden_objects_names, e.template_name) then
			return false
		end

		if not e.pos then
			return false
		end

		for _, rect in pairs(this.hide_exits_rects) do
			if V.is_inside(e.pos, rect) then
				return true
			end
		end

		return false
	end)

	for _, v in pairs(path_flags) do
		U.sprites_hide(v, nil, nil, true)
	end

	if this.modos and not this._deployed_once then
		instant_deploy_islands_1_and_2(this, store)

		this._deployed_once = true
	end

	while true do
		if this.show_path then
			if store.level_idx == 36 then
				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_36_easter_egg_spyro" then
						e.leave = true

						break
					end
				end
			end

			table.insert(islands_up, this.show_path)

			local sprite_sid = this.show_path
			local holders_list = this.holders_list[this.show_path]
			local cinematic = this.cinematic[this.show_path]

			this.show_path = nil

			local camera_posX, camera_posY, zoom_value

			if cinematic then
				signal.emit("show-curtains")
				signal.emit("hide-gui")
				signal.emit("start-cinematic")

				--camera_posX = game.camera.x / game.game_scale
				--camera_posY = game.ref_h - game.camera.y / game.game_scale
				--zoom_value = game.camera.zoom

				U.y_wait_unconditional(store, 1.5)
				signal.emit("pan-zoom-camera", cinematic.time, {
					x = cinematic.pos.x,
					y = cinematic.pos.y
				}, cinematic.zoom)
				U.y_wait_unconditional(store, 1.5)
			end

			S:queue("Stage36PathOpen" .. sprite_sid)

			if store.level_idx == 38 then
				local options = {
					delay = 0.6
				}

				S:queue("Stage38OpenPath", options)
			end

			U.sprites_show(this, sprite_sid, sprite_sid, true)
			U.animation_start(this, "in", nil, store.tick_ts, false, sprite_sid)

			if not this.skip_shake then
				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 0.5
				shake.aura.duration = 4
				shake.aura.freq_factor = 2

				simulation:queue_insert_entity(shake)
			end

			local start_ts = store.tick_ts

			while true do
				local elapsed_time = store.tick_ts - start_ts
				local holders_yet_to_show = false

				for k, hcfg in pairs(holders_list) do
					if not hcfg.done then
						holders_yet_to_show = true
					end

					if elapsed_time >= hcfg.ts and not hcfg.done then
						if hcfg.shake then
							local shake = E:create_entity("aura_screen_shake")

							shake.aura.amplitude = 0.5
							shake.aura.duration = 1
							shake.aura.freq_factor = 2

							simulation:queue_insert_entity(shake)
						end

						if hcfg.objects then
							for _, v in pairs(path_flags) do
								local fx = E:create_entity(this.show_fx)

								fx.pos.x, fx.pos.y = v.pos.x, v.pos.y
								fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(fx)

								if v.template_name == "decal_upgrade_alliance_seal_of_punishment" then
									fx.pos.y = fx.pos.y - 20
								end

								U.y_wait_unconditional(store, fts(6))
								U.sprites_show(v, nil, nil, true)
							end
						end

						if hcfg.pos then
							local holder = tower_by_pos(hcfg.pos)

							if holder then
								local fx = E:create_entity(this.show_fx)

								fx.pos.x, fx.pos.y = holder.pos.x, holder.pos.y
								fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(fx)
								U.y_wait_unconditional(store, fts(6))
								U.sprites_show(holder, nil, nil, true)

								holder.ui.can_click = true
								holder.tower.can_hover = true
							end
						end

						hcfg.done = true
					end
				end

				if not holders_yet_to_show then
					break
				end

				coroutine.yield()
			end

			for k, unlock_cfg in pairs(this.path_unlocks) do
				local all_islands_up = true

				for _, island in pairs(unlock_cfg.islands_required) do
					if not table.contains(islands_up, island) then
						all_islands_up = false

						break
					end
				end

				if all_islands_up then
					for _, pi in pairs(unlock_cfg.paths) do
						P:activate_path(pi)
					end

					for _, pi in pairs(unlock_cfg.terrain_paths) do
						set_path_cells_terrain(pi, TERRAIN_LAND, radius)
					end

					for _, extra_cfg in pairs(unlock_cfg.extra_terrains) do
						set_pos_terrain(extra_cfg.x, extra_cfg.y, extra_cfg.terrain_type, extra_cfg.radius)
					end

					this.path_unlocks[k] = nil
				end
			end

			U.y_animation_wait_default(this)
			U.animation_start(this, "idle", nil, store.tick_ts, true, sprite_sid, true)

			if cinematic then
				U.y_wait_unconditional(store, 1)
				signal.emit("pan-zoom-camera", 1, {
					x = camera_posX,
					y = camera_posY
				}, zoom_value)
				U.y_wait_unconditional(store, 1)
				signal.emit("hide-curtains")
				signal.emit("show-gui")
				signal.emit("end-cinematic")
				U.y_wait_unconditional(store, 1)
			end
		end

		coroutine.yield()
	end
end

function stage_36_paths_controller.on_show_path(this, store, action, path)
	this.show_path = tonumber(path)
end

local stage_37_barrack_dragon_wardens = {}

function stage_37_barrack_dragon_wardens.update(this, store, script)
	local next_respawn_ts = store.tick_ts
	local tall_tower

	for _, e in pairs(store.entities) do
		if (e.template_name == "decal_stage_37_tall_tower_mid" or e.template_name == "decal_stage_37_tall_tower_left") and (not tall_tower or V.dist(this.pos.x, this.pos.y, tall_tower.pos.x, tall_tower.pos.y) > V.dist(this.pos.x, this.pos.y, e.pos.x, e.pos.y)) then
			tall_tower = e
		end
	end

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	local function set_waypoints_for_unit(e, pos)
		local waypoints = GR:find_waypoints(e.pos, e.nav_rally.center, pos, e.nav_grid.valid_terrains)
		local offset_x = e.nav_rally.pos.x - e.nav_rally.center.x
		local offset_y = e.nav_rally.pos.y - e.nav_rally.center.y

		e.nav_rally.new = true
		e.nav_rally.pos = V.v(offset_x + pos.x, offset_y + pos.y)

		if not e.nav_grid.ignore_waypoints and waypoints and #waypoints > 0 then
			e.nav_grid.waypoints = table.deepclone(waypoints)

			if offset_x ~= 0 or offset_y ~= 0 then
				local lw = e.nav_grid.waypoints[#e.nav_grid.waypoints]

				if lw then
					lw.x = lw.x + offset_x
					lw.y = lw.y + offset_y
				end
			end
		end
	end

	while true do
		local b = this.barrack

		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					for _, s in ipairs(b.soldiers) do
						s.powers[pn].level = p.level
						s.powers[pn].changed = true
					end
				end
			end
		end

		if next_respawn_ts < store.tick_ts and not this.destroyed and not this.tower.blocked then
			local all_alive = true

			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					all_alive = false

					break
				end
			end

			if all_alive then
				next_respawn_ts = store.tick_ts + this.respawn_time
			else
				for i = 1, b.max_soldiers do
					local s = b.soldiers[i]

					if not s or s.health.dead and not store.entities[s.id] then
						all_alive = false

						tall_tower:spawn_anim(store)
						U.animation_start(this, "spawn", nil, store.tick_ts, false, 1, true)
						U.y_wait_unconditional(store, fts(20))

						s = E:create_entity(b.soldier_type)
						s.reinforcement.squad_id = this.id
						s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))

						local amount_soldiers = 0
						local center_pos = V.vv(0)

						for ii = 1, b.max_soldiers do
							local ss = b.soldiers[ii]

							-- if not ss or ss.health.dead and not store.entities[ss.id] or not ss.nav_rally.center then
							if not ss or ss.health.dead and not store.entities[ss.id] then
							-- block empty
							else
								amount_soldiers = amount_soldiers + 1
								center_pos.x, center_pos.y = center_pos.x + ss.nav_rally.center.x, center_pos.y + ss.nav_rally.center.y
							end
						end

						if amount_soldiers > 0 then
							center_pos.x = center_pos.x / amount_soldiers
							center_pos.y = center_pos.y / amount_soldiers
							b.rally_pos = center_pos
						end

						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
						s.nav_rally.new = true

						if this.powers then
							for pn, p in pairs(this.powers) do
								s.powers[pn].level = p.level
							end
						end

						set_waypoints_for_unit(s, b.rally_pos)
						simulation:queue_insert_entity(s)

						b.soldiers[i] = s

						signal.emit("tower-spawn", this, s)

						next_respawn_ts = store.tick_ts + this.respawn_time

						U.y_animation_wait_default(this)
						U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)

						break
					end
				end
			end
		end

		coroutine.yield()
	end
end

function stage_37_barrack_dragon_wardens.destroy(this, store)
	this.render.sprites[1].hidden = true
	this.destroyed = true
end

tt = E:register_t_hot("decal_stage_37_layer02", "decal", true)
tt.render.sprites[1].name = "stage_37_layer02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN + 1

tt = E:register_t_hot("decal_stage_37_mask_islas", "decal_tween", true)
E:add_comps(tt, "main_script")
tt.main_script.insert = decal_stage_36_mask_islas.insert
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

tt = E:register_t_hot("decal_stage_37_tall_tower_mid", "decal_scripted", true)
tt.sid_back = 1
tt.sid_front = 2
tt.render.sprites[tt.sid_back].prefix = "destruccion_torres_stage_37_torre_2_back"
tt.render.sprites[tt.sid_back].name = "idle_sana"
tt.render.sprites[tt.sid_back].sort_y_offset = 0
tt.render.sprites[tt.sid_back].group = "layers"
tt.render.sprites[tt.sid_front] = E:clone_c("sprite")
tt.render.sprites[tt.sid_front].prefix = "destruccion_torres_stage_37_torre_2_front"
tt.render.sprites[tt.sid_front].name = "idle_sana"
tt.render.sprites[tt.sid_front].sort_y_offset = 0
tt.render.sprites[tt.sid_front].z = Z_EFFECTS
tt.render.sprites[tt.sid_front].hidden = true
tt.render.sprites[tt.sid_front].group = "layers"
tt.render.sprites[tt.sid_front].scale = vv(2)
tt.spawn_fx = "fx_decal_stage_37_tall_tower_spawn"
tt.main_script.update = decal_stage_37_tall_tower.update
tt.spawn_anim = decal_stage_37_tall_tower.spawn_anim
tt.destroy = decal_stage_37_tall_tower.destroy
tt.destroy_warden_barrack = fts(16)

tt = E:register_t_hot("decal_stage_37_tall_tower_left", "decal_stage_37_tall_tower_mid", true)
tt.render.sprites[tt.sid_back].prefix = "destruccion_torres_stage_37_torre_3_back"
tt.render.sprites[tt.sid_back].name = "idle_sana"
tt.render.sprites[tt.sid_front].prefix = "destruccion_torres_stage_37_torre_3_front"
tt.render.sprites[tt.sid_front].name = "idle_sana"

tt = E:register_t_hot("decal_stage_37_tall_tower_right", "decal_stage_37_tall_tower_mid", true)
tt.render.sprites[tt.sid_back].name = "destruccion_torres_stage_37_torre_1_back_0001"
tt.render.sprites[tt.sid_back].animated = false
tt.render.sprites[tt.sid_front] = nil
tt.sid_front = nil
tt.destroy_warden_barrack = nil

tt = E:register_t_hot("decal_stage_37_bridge", "decal", true)
tt.render.sprites[1].prefix = "stage_37_anim_props_puente"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.destroy = decal_stage_37_bridge.destroy

tt = E:register_t_hot("decal_stage_37_easter_daenerys", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_37_easter_daenerys.update
tt.render.sprites[1].prefix = "daenerys_easter_eggDef"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].exo = true
tt.ui.click_rect = r(-25, -10, 50, 50)

tt = E:register_t_hot("decal_stage_37_fires_exo", "decal", true)
tt.spr_cfgs = {
	{
		sort_y_offset = 0
	},
	{
		sort_y_offset = 0
	},
	{
		sort_y_offset = -300
	},
	[6] = {
		sort_y_offset = 150
	},
	[7] = {
		sort_y_offset = -32
	}
}
tt.render.sprites[1] = nil

for k, v in pairs(tt.spr_cfgs) do
	local i = #tt.render.sprites + 1

	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "fuego_fx_stage2_fire" .. k .. "Def"
	tt.render.sprites[i].name = "run"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].exo = true
	tt.render.sprites[i].z = Z_OBJECTS
	tt.render.sprites[i].sort_y_offset = v.sort_y_offset
end

tt = E:register_t_hot("stage_37_barrack_dragon_wardens", "tower", true)
E:add_comps(tt, "barrack")
tt.tower.type = "stage_37_barrack_dragon_wardens"
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.info.portrait = "kr5_portraits_towers_0008"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.ui.can_click = false
tt.ui.can_hover = false
tt.ui.can_select = false
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = stage_37_barrack_dragon_wardens.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.destroy = stage_37_barrack_dragon_wardens.destroy
tt.render.sprites[1].prefix = "stage_37_anim_props_spawner"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 50
tt.render.door_sid = 3
tt.barrack.soldier_type = "soldier_dragon_warden_warrior"
tt.barrack.rally_range = 300
tt.barrack.respawn_offset = v(-3, 2)
tt.barrack.rally_fn = RLU.rally_fn_default
tt.respawn_time = 30
tt.destroyed = false

tt = E:register_t_hot("stage_37_paths_controller", "decal_scripted", true)
E:add_comps(tt, "events", "editor")
tt.main_script.update = stage_36_paths_controller.update
tt.render.sprites[1].prefix = "mecanica_camino_2_stage_2Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.events.list[1].name = "show_path"
tt.events.list[1].on_event = stage_36_paths_controller.on_show_path
tt.skip_shake = true
tt.holders_list = {{{
	ts = fts(165),
	pos = v(750, 448)
}, {
	shake = true,
	ts = fts(165)
}}}
tt.path_unlocks = {{
	islands_required = {1},
	paths = {3, 4},
	terrain_paths = {3, 4},
	extra_terrains = {{
		radius = 36,
		x = 380,
		y = 260,
		terrain_type = bor(TERRAIN_LAND)
	}, {
		radius = 36,
		x = 463,
		y = 311,
		terrain_type = bor(TERRAIN_LAND)
	}, {
		radius = 46,
		x = 815,
		y = 416,
		terrain_type = bor(TERRAIN_LAND)
	}, {
		radius = 32,
		x = 742,
		y = 406,
		terrain_type = bor(TERRAIN_LAND)
	}}
}}
tt.hide_exits_rects = {}
tt.cinematic = {}
tt.show_fx = "fx_stage_36_path_dust"
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].name"] = "idle"
}

