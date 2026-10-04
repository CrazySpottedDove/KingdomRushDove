local P = require("path_db")
local E = require("entity_db")
local U = require("utils")
local EXO = require("all.exoskeleton")
local GR = require("grid_db")
local V = require("lib.klua.vector")
local km = require("lib.klua.macros")
local S = require("sound_db")
local scripts = require("scripts")
local signal = require("lib.hump.signal")
local r = V.r
local v = V.v
local vv = V.vv
local fts = function(t)
	return t / 30
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end
local function find_all_t(store, template_name, contains, fn)
	if not store or not store.entities then
		return {}
	end
	return table.filter(store.entities, function(k, val)
		return (contains and string.find(val.template_name, template_name) or val.template_name == template_name) and (not fn or fn(k, val))
	end)
end
local function shake_step(t, amp, freq, phase, duration)
	local fade = km.clamp(0, 1, 1 - t / duration) * amp
	local fx, fy, fy2 = 10 * freq, 8 * freq, 20 * freq
	return math.sin(t * fx + phase) * 12 * fade, math.sin(t * fy + phase) * 9 * fade + math.cos(t * fy2) * 9 * fade
end
local function towers_portrait_get_info(this)
	return {
		type = STATS_TYPE_TEXT,
		desc = (this.info.i18n_key or string.upper(this.template_name)) .. "_DESCRIPTION"
	}
end
local function aura_shake_entity_update(this, store)
	local target = store.entities[this.aura.target_id]
	local phase = math.random(0, 2 * math.pi)
	local shake_ts = store.tick_ts
	local amp = this.aura.amplitude
	while store.tick_ts - shake_ts < this.aura.duration do
		local t = store.tick_ts - shake_ts
		local wox, woy = shake_step(t, amp, this.aura.freq_factor, phase, this.aura.duration)
		for i, sp in ipairs(this.aura.sprites_to_shake) do
			target.render.sprites[sp].offset.x, target.render.sprites[sp].offset.y = wox, woy
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end
local function decal_stage_213_boss_shield_update(this, store)
	this.shake = false
	local phase = math.random(0, 2 * math.pi)
	local sp = this.render.sprites[1]
	local target = store.entities[sp.track_id]
	while true do
		if target.render.sprites[sp.track_sprite_id or 1].last_attach_point_xform then
			EXO:track_attach_point(this, target, 1)
		end
		if this.shake then
			this.shake = false
			local shake_ts = store.tick_ts
			local damage_factor = km.clamp(0, 1, this.damage_received / this.shake_damage_ratio)
			local amp = this.shake_amplitude * damage_factor
			while store.tick_ts - shake_ts < this.shake_duration and not this.shake do
				local t = store.tick_ts - shake_ts
				local wox, woy = shake_step(t, amp, this.shake_frequency, phase, this.shake_duration)
				this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = wox, woy
				coroutine.yield()
			end
		end
		coroutine.yield()
	end
end
local function controller_stage_213_sunray_tower_health_update(this, store)
	this.current_health_boss_hits = this.health_boss_hits
	while true do
		if this.current_health_boss_hits <= 0 then
			local tower = find_all_t(store, this.broken_sunray_tower_t)[1]
			tower = tower or find_all_t(store, this.sunray_tower_t)[1]
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			signal.emit("pan-zoom-camera", 1.5, {
				x = tower.pos.x,
				y = tower.pos.y + 70
			}, OVm(1, 1.5))
			U.y_wait(store, 3)
			signal.emit("end-cinematic")
			store.lives = 0
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end
local function controller_stage_213_spawn_sorcerer_queue_sorcerer(this, store, path_no_boss)
	local boss = find_all_t(store, this.boss_t)[1]
	local spot, boss_spawn
	if not boss or not boss.on_ground then
		spot = this._tower.determine_spot_for_sorcerer(path_no_boss)
	else
		spot = this._tower.determine_spot_for_sorcerer(boss.nav_path.pi == this.boss_left_path and this.right_path or this.left_path)
		boss_spawn = boss.nav_path.pi
	end
	if not spot then
		return
	end
	table.insert(this.to_spawn, {spot, boss_spawn})
	this.sorcerer_spawn_ts = store.tick_ts
end
local function controller_stage_213_spawn_sorcerer_update(this, store)
	if not this._tower then
		this._tower = find_all_t(store, this.tower_t)[1]
	end
	local count = 0
	this.sorcerer_spawn_ts = store.tick_ts
	this.to_spawn = {}
	while true do
		if this.automatic_spawning and store.tick_ts - this.sorcerer_spawn_ts >= this.sorcerer_spawn_time then
			controller_stage_213_spawn_sorcerer_queue_sorcerer(this, store, count % 2 == 0 and this.left_path or this.right_path)
		end
		if #this.to_spawn > 0 then
			local sp = table.remove(this.to_spawn, 1)
			local sorc_preamble
			local left = false
			if sp[2] == nil then
				if this._tower.spot_is_left_side(sp[1]) then
					left = true
				else
					left = false
				end
			elseif sp[2] == this.boss_left_path then
				left = false
			else
				left = true
			end
			sorc_preamble = E:create_entity(this.sorcerer_preamble_prefix .. (left and "_left" or "_right"))
			sorc_preamble.pos.x, sorc_preamble.pos.y = this.spawn_sorcerer_preamble_pos.x, this.spawn_sorcerer_preamble_pos.y
			sorc_preamble.render.sprites[1].ts = store.tick_ts
			queue_insert(store, sorc_preamble)
			U.y_animation_wait(sorc_preamble, 1)
			local door_light = E:create_entity(this.sorcerer_door_light_t .. (left and "_left" or "_right"))
			door_light.pos.x, door_light.pos.y = 512, 384
			door_light.tween.ts = store.tick_ts
			queue_insert(store, door_light)
			U.y_wait(store, this.sorcerer_door_wait - door_light.tween.props[1].keys[2][1])
			door_light.tween.disabled = true
			queue_remove(store, door_light)
			U.y_wait(store, door_light.tween.props[1].keys[2][1])
			if sp[2] == nil then
				this._tower.spawn_sorcerer(sp[1])
			else
				this._tower.spawn_sorcerer(sp[1], sp[2] == this.boss_left_path and "ov_right" or "ov_left")
			end
			count = count + 1
		end
		coroutine.yield()
	end
end
local function controller_stage_213_spawn_sorcerer_on_spawn_event(this, store, action, path_id)
	if not this._tower then
		this._tower = find_all_t(store, this.tower_t)[1]
	end
	local number_path_id = tonumber(path_id)
	controller_stage_213_spawn_sorcerer_queue_sorcerer(this, store, number_path_id)
end
local function controller_stage_213_spawn_sorcerer_on_activate_automatic_event(this, store, action)
	this.automatic_spawning = true
	this.sorcerer_spawn_ts = store.tick_ts
end
local function controller_stage_213_spawn_sorcerer_on_deactivate_automatic_event(this, store, action)
	this.automatic_spawning = false
	this.sorcerer_spawn_ts = store.tick_ts
end
local function tower_stage_213_broken_sunray_obelisk_update(this, store)
	this.tower.blocked = true
	this.tower.can_hover = false
	this.ui.can_click = false
	this.ui.can_hover = false
	while not this.summoned do
		coroutine.yield()
	end
	U.y_animation_play(this, this.appear_anim, nil, store.tick_ts, 1, 1)
	this.tower.blocked = false
	this.ui.can_click = true
	this.ui.can_hover = true
	while true do
		coroutine.yield()
	end
end
local function tower_stage_213_sunray_tower_insert(this, store)
	return true
end
local function tower_stage_213_sunray_tower_update(this, store)
	local obelisks
	local health_controller = find_all_t(store, this.controller_health)[1]
	local charge_acum = 0
	local started_charging_once = false
	local charged_last_frame = false
	local charging_last_frame = false
	local is_shooting = false
	local ray_decal, last_shake
	this.sorcerers = {{nil, v(this.pos.x + this.sorcerer_slots_offsets[1].x, this.pos.y + this.sorcerer_slots_offsets[1].y), true, false, true}, {nil, v(this.pos.x + this.sorcerer_slots_offsets[2].x, this.pos.y + this.sorcerer_slots_offsets[2].y), true, false, false}, {nil, v(this.pos.x + this.sorcerer_slots_offsets[3].x, this.pos.y + this.sorcerer_slots_offsets[3].y), false, false, true}, {nil, v(this.pos.x + this.sorcerer_slots_offsets[4].x, this.pos.y + this.sorcerer_slots_offsets[4].y), false, false, false}}
	local function count_charging_sorcerers(left)
		return #table.filter(this.sorcerers, function(k, val)
			return val[1] ~= nil and (left == nil or left == val[3])
		end)
	end
	local function animation_start_all(e, anim, flip_x, ts, loop)
		U.animation_start(e, anim, flip_x, ts, loop, 1)
		U.animation_start(e, anim, flip_x, ts, loop, 2)
	end
	local function y_animation_play_all(e, anim, flip_x, ts)
		animation_start_all(e, anim, flip_x, ts, false)
		while not U.animation_finished(e, 1) and not U.animation_finished(e, 2) do
			coroutine.yield()
		end
	end
	local function is_charged()
		return charge_acum >= this.sunray.points_to_charge
	end
	local function spot_is_left_side(spot)
		return this.sorcerers[spot][3]
	end
	local function spot_open(spot)
		return this.sorcerers[spot][1] == nil and not this.sorcerers[spot][4]
	end
	local function determine_spot_for_sorcerer(path_id)
		local left = path_id == this.left_path
		local spot
		local left_spaces = #table.filter(this.sorcerers, function(k, val)
			return val[3] and not val[1] and not val[4]
		end)
		local right_spaces = #table.filter(this.sorcerers, function(k, val)
			return not val[3] and not val[1] and not val[4]
		end)
		for i, val in ipairs(this.sorcerers) do
			if left then
				if left_spaces > 0 then
					if not this.sorcerers[i][1] and not this.sorcerers[i][4] and this.sorcerers[i][3] then
						spot = i
						break
					end
				elseif right_spaces > 0 and not this.sorcerers[i][1] and not this.sorcerers[i][4] and not this.sorcerers[i][3] then
					spot = i
					break
				end
			elseif right_spaces > 0 then
				if not this.sorcerers[i][1] and not this.sorcerers[i][4] and not this.sorcerers[i][3] then
					spot = i
					break
				end
			elseif left_spaces > 0 and not this.sorcerers[i][1] and not this.sorcerers[i][4] and this.sorcerers[i][3] then
				spot = i
				break
			end
		end
		if spot then
			this.sorcerers[spot][4] = true
		end
		return spot
	end
	local function spawn_sorcerer(spot, override)
		if not spot then
			return
		end
		local left = not override and spot_is_left_side(spot) or override == "ov_left"
		local path = left and this.left_path or this.right_path
		local sorcerer = E:create_entity(this.sunray.sorcerer_t)
		local pp = P:node_pos(path, 1, 1)
		sorcerer.pos.x, sorcerer.pos.y = pp.x, pp.y
		sorcerer.path_id = path
		sorcerer.left_path = left
		sorcerer.is_top = this.sorcerers[spot][5]
		sorcerer.ritual_spot = spot
		sorcerer.final_destination = this.sorcerers[sorcerer.ritual_spot][2]
		queue_insert(store, sorcerer)
	end
	local function on_sorcerer_arrived(sorc)
		this.sorcerers[sorc.ritual_spot][1] = sorc
		this.sorcerers[sorc.ritual_spot][4] = false
		sorc.raise_arms = charge_acum < this.sunray.points_to_charge and count_charging_sorcerers() >= this.sunray.sorcerers_to_charge
	end
	local function is_charging()
		return count_charging_sorcerers() >= this.sunray.sorcerers_to_charge
	end
	local function has_sorcerers(left)
		if left == nil then
			return count_charging_sorcerers() > 0
		end
		return count_charging_sorcerers(left) > 0
	end
	local function get_sorcerer_position(is_left)
		if count_charging_sorcerers() <= 0 then
			return nil
		end
		if is_left and count_charging_sorcerers(true) <= 0 then
			is_left = not is_left
		end
		if not is_left and count_charging_sorcerers(false) <= 0 then
			is_left = not is_left
		end
		local sorcerers_per_side = #this.sorcerers / 2
		local start = is_left and 1 or sorcerers_per_side + 1
		local ending = is_left and #this.sorcerers - sorcerers_per_side or #this.sorcerers
		for i = start, ending do
			if this.sorcerers[i][1] then
				return i, this.sorcerers[i][2]
			end
		end
		return nil, nil
	end
	local function get_sorcerer(sorc_id)
		return this.sorcerers[sorc_id][1]
	end
	local function kill_sorcerer(sorc_id, left)
		local sorc = this.sorcerers[sorc_id][1]
		if this.sorcerers[sorc_id][4] then
			this.sorcerers[sorc_id][4] = false
		end
		if sorc then
			if not sorc.health.dead then
				sorc.health.hp = 0
			end
			this.sorcerers[sorc_id][1] = nil
		end
		local achievement_controller = find_all_t(store, "controller_stage_213_achievement")
		if achievement_controller[1] then
			achievement_controller[1].sorcerer_died = true
		end
	end
	local function on_lose_health(current_health)
		if current_health > 0 then
			if last_shake and store.entities[last_shake.id] then
				queue_remove(store, last_shake)
			end
			last_shake = E:create_entity("aura_shake_entity")
			last_shake.aura.target_id = this.id
			last_shake.aura.source_id = this.id
			last_shake.aura.duration = this.shake_duration
			last_shake.aura.amplitude = this.shake_amplitude
			last_shake.aura.freq_factor = this.shake_frequency
			last_shake.aura.sprites_to_shake = {2}
			queue_insert(store, last_shake)
		end
		if current_health == 2 then
			this.render.sprites[2].prefix = this.sunray.damaged_health_prefix
		end
		if current_health == 1 then
			this.render.sprites[2].prefix = this.sunray.very_damaged_health_prefix
		end
		if not is_shooting then
			if is_charged() then
				animation_start_all(this, this.sunray.charged_loop_anim, nil, store.tick_ts, true)
			elseif is_charging() then
				animation_start_all(this, this.sunray.charge_loop_anim, nil, store.tick_ts, true)
			else
				animation_start_all(this, this.sunray.off_anim, nil, store.tick_ts, true)
			end
		end
	end
	this.on_sorcerer_arrived = on_sorcerer_arrived
	this.is_charging = is_charging
	this.has_sorcerers = has_sorcerers
	this.get_sorcerer_position = get_sorcerer_position
	this.kill_sorcerer = kill_sorcerer
	this.get_sorcerer = get_sorcerer
	this.spawn_sorcerer = spawn_sorcerer
	this.spot_is_left_side = spot_is_left_side
	this.determine_spot_for_sorcerer = determine_spot_for_sorcerer
	this.on_lose_health = on_lose_health
	this.spot_open = spot_open
	this.is_charged = is_charged
	local function sorcerers_set_raise_arms(b)
		for i, sorc in ipairs(this.sorcerers) do
			if sorc[1] then
				sorc[1].raise_arms = b
			end
		end
	end
	local function y_stop_charge_animation()
		charging_last_frame = false
		sorcerers_set_raise_arms(false)
		S:queue(this.sound_events.ray_end)
		y_animation_play_all(this, this.sunray.charge_cancel_anim, nil, store.tick_ts)
		animation_start_all(this, this.sunray.off_anim, nil, store.tick_ts, true)
	end
	local function y_charge_animation()
		charging_last_frame = true
		sorcerers_set_raise_arms(true)
		S:queue(this.sound_events.charge_start)
		y_animation_play_all(this, this.sunray.charge_start_anim, nil, store.tick_ts)
		if not is_charging() then
			y_stop_charge_animation()
		else
			animation_start_all(this, this.sunray.charge_loop_anim, nil, store.tick_ts, true)
		end
	end
	local function shoot_bullet(attack, enemy, to_boss)
		local roffset = attack.ray_start_offset
		local hoffset = to_boss and V.vclone(enemy.unit.hit_offset) or v(0, 0)
		local b = E:create_entity(attack.bullet)
		b.pos.x = this.pos.x + roffset.x
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + hoffset.x, enemy.pos.y + hoffset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.damage_factor = this.tower.damage_factor
		ray_decal = E:create_entity(attack.hit_decal)
		ray_decal.pos.x, ray_decal.pos.y = b.bullet.to.x, b.bullet.to.y
		ray_decal.render.sprites[1].ts = store.tick_ts
		ray_decal.render.sprites[1].sort_y_offset = b.pos.y - ray_decal.pos.y + 1
		if to_boss then
			local to_from = v(b.bullet.to.x - b.bullet.from.x, b.bullet.to.y - b.bullet.from.y)
			ray_decal.render.sprites[1].r = V.angleTo(to_from.x, to_from.y) + math.pi / 2
		end
		queue_insert(store, ray_decal)
		queue_insert(store, b)
	end
	local function shoot_bullet_pos(attack, target_pos, to_boss)
		local shooting_right = not this.render.sprites[1].flip_x
		local roffset = attack.ray_start_offset
		local b = E:create_entity(attack.bullet)
		b.pos.x = this.pos.x + roffset.x * (shooting_right and 1 or -1)
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(target_pos.x, target_pos.y)
		b.bullet.source_id = this.id
		b.bullet.damage_factor = this.tower.damage_factor
		ray_decal = E:create_entity(attack.hit_decal)
		ray_decal.render.sprites[1].ts = store.tick_ts
		ray_decal.pos.x, ray_decal.pos.y = b.bullet.to.x, b.bullet.to.y
		ray_decal.render.sprites[1].sort_y_offset = b.pos.y - ray_decal.pos.y + 1
		if to_boss then
			local to_from = v(b.bullet.to.x - b.bullet.from.x, b.bullet.to.y - b.bullet.from.y)
			ray_decal.render.sprites[1].r = V.angleTo(to_from.x, to_from.y)
		end
		queue_insert(store, ray_decal)
		queue_insert(store, b)
	end
	local function y_shoot_ray(a)
		local trigger_target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, o)
			return e.template_name ~= "enemy_boss_stage_213" and GR:cell_is(e.pos.x, e.pos.y, a.accepted_terrains)
		end)
		if not targets or #targets == 0 then
			SU.delay_attack(store, a, fts(10))
			return false
		end
		local target_pos = V.vclone(trigger_target.pos)
		S:queue(this.sound_events.ray_fire)
		animation_start_all(this, a.start_anim, nil, store.tick_ts)
		U.y_wait(store, a.shoot_time)
		S:queue(this.sound_events.ray_loop)
		local _, targets2 = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, o)
			return e.template_name ~= "enemy_boss_stage_213" and GR:cell_is(e.pos.x, e.pos.y, a.accepted_terrains)
		end)
		if targets2 and #targets2 > 0 then
			local hp_max = 0
			local final_target
			for k, t in pairs(targets2) do
				if hp_max < t.health.hp_max then
					hp_max = t.health.hp_max
					final_target = t
				end
			end
			shoot_bullet(a, final_target)
		else
			shoot_bullet_pos(a, target_pos)
		end
		U.y_animation_wait(this, 1)
		animation_start_all(this, a.loop_anim, nil, store.tick_ts, true)
		U.y_wait(store, this.sunray.ray_duration - (a.start_anim_duration - a.shoot_time))
		queue_remove(store, ray_decal)
		S:stop(this.sound_events.ray_loop)
		S:queue(this.sound_events.ray_end)
		y_animation_play_all(this, a.end_anim, nil, store.tick_ts)
		if is_charging() then
			y_charge_animation()
		else
			charging_last_frame = false
			animation_start_all(this, this.sunray.off_anim, nil, store.tick_ts, true)
		end
		charged_last_frame = false
		a.ts = store.tick_ts
		return true
	end
	local function y_shoot_ray_at_boss(boss, a)
		local target_pos = V.vclone(boss.pos)
		is_shooting = true
		S:queue(this.sound_events.ray_fire)
		animation_start_all(this, a.start_anim, nil, store.tick_ts)
		U.y_wait(store, a.shoot_time)
		S:queue(this.sound_events.ray_loop)
		local boss_still_here = find_all_t(store, this.sunray.boss_t)[1]
		if boss_still_here then
			boss.tanking_ray = true
			shoot_bullet(a, boss, true)
		else
			shoot_bullet_pos(a, target_pos)
		end
		U.y_animation_wait(this, 1)
		animation_start_all(this, a.loop_anim, nil, store.tick_ts, true)
		U.y_wait(store, this.sunray.boss_ray_duration - (a.start_anim_duration - a.shoot_time))
		queue_remove(store, ray_decal)
		S:stop(this.sound_events.ray_loop)
		S:queue(this.sound_events.ray_end)
		y_animation_play_all(this, a.end_anim, nil, store.tick_ts)
		is_shooting = false
		if is_charging() then
			y_charge_animation()
		else
			charging_last_frame = false
			animation_start_all(this, this.sunray.off_anim, nil, store.tick_ts, true)
		end
		charged_last_frame = false
		a.ts = store.tick_ts
	end
	local function y_animations(clf, chlf)
		if not clf and charge_acum >= this.sunray.points_to_charge then
			sorcerers_set_raise_arms(false)
			S:queue(this.sound_events.charge_end)
			y_animation_play_all(this, this.sunray.charged_start_anim, nil, store.tick_ts)
			animation_start_all(this, this.sunray.charged_loop_anim, nil, store.tick_ts, true)
			return
		end
		if this.render.sprites[2].name == this.sunray.charged_loop_anim then
			return
		end
		if not chlf and is_charging() then
			y_charge_animation()
			return
		end
		if chlf and not is_charging() then
			y_stop_charge_animation()
		end
	end
	while true do
		if not obelisks or #obelisks < this.expected_obelisks then
			obelisks = find_all_t(store, this.obelisk_t)
		end
		if health_controller.current_health_boss_hits <= 0 then
			this.user_selection.allowed = false
			this.user_selection.in_progress = nil
			U.animation_start(this, this.sunray.destroyed_anim, nil, store.tick_ts, nil, 2)
			U.y_wait(store, fts(10))
			local sorc_ids = {}
			for k, sorc_spot in pairs(this.sorcerers) do
				if sorc_spot[1] then
					sorc_spot[1].health.hp = 0
					table.insert(sorc_ids, sorc_spot[1])
					U.y_wait(store, U.frandom(0, fts(6)))
				end
			end
			local all_other_sorcs = find_all_t(store, this.sorcerer_t, false, function(k, val)
				return not table.contains(sorc_ids, val.id)
			end)
			for k, sorc in pairs(all_other_sorcs) do
				sorc.health.hp = 0
				U.y_wait(store, U.frandom(0, fts(6)))
			end
			U.y_animation_wait(this, 2)
			break
		end
		if charge_acum < this.sunray.points_to_charge and is_charging() then
			if not started_charging_once then
				started_charging_once = true
				for i, obelisk in ipairs(find_all_t(store, this.broken_obelisk_t)) do
					obelisk.summoned = true
				end
			end
			charge_acum = charge_acum + store.tick_length * this.sunray.points_per_second[count_charging_sorcerers()]
			if charge_acum >= this.sunray.points_to_charge then
				this.ui.can_select = false
				if obelisks and #obelisks > 0 then
					for i, obelisk in ipairs(obelisks) do
						obelisk.set_charged()
					end
				end
				sorcerers_set_raise_arms(false)
			end
		end
		y_animations(charged_last_frame, charging_last_frame)
		this.user_selection.allowed = is_charged()
		if is_charged() and this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_select = true
			local boss = find_all_t(store, this.sunray.boss_t)[1]
			if boss and boss.on_ground then
				y_shoot_ray_at_boss(boss, this.attacks.list[2])
			elseif not y_shoot_ray(this.attacks.list[1]) then
				goto continue
			end
			charge_acum = 0
		end
		::continue::
		if this.ui.clicked then
			this.ui.clicked = nil
		end
		charged_last_frame = is_charged()
		charging_last_frame = is_charging()
		coroutine.yield()
	end
end
local function tower_stage_213_sunray_tower_remove(this, store)
	return true
end
local function soldier_stage_213_sorcerer_update(this, store)
	local brk, sta
	local path_ni = 1
	local path_spi = 1
	local target_pos = P:node_pos(this.path_id, path_spi, path_ni)
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	local function do_step()
		if V.veq(this.pos, target_pos) then
			this.motion.arrived = true
		else
			U.set_destination(this, target_pos)
			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest, 1)
			U.animation_start(this, an, af, store.tick_ts, true, 1)
			U.walk(this, store.tick_length)
		end
	end
	local function run_to_tower()
		local distSq = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)
		if distSq < 25 then
			path_ni = path_ni + 2
			target_pos = P:node_pos(this.path_id, path_spi, path_ni)
		end
		do_step()
	end
	local sunray = find_all_t(store, this.sunray_tower)[1]
	while true do
		if P:nodes_to_goal(this.path_id, 1, path_ni) < 3 then
			break
		end
		if this.health.dead then
			sunray.kill_sorcerer(this.ritual_spot, this.left_path)
			SU.y_soldier_death(store, this)
			return
		end
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
			if brk or sta ~= A_NO_TARGET then
				if sta == A_DONE then
					local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.path_id})
					local _, spi, ni = unpack(nearest[1])
					path_ni = ni + 2
					target_pos = P:node_pos(this.path_id, spi, path_ni)
				end
			else
				run_to_tower()
			end
		end
		coroutine.yield()
	end
	target_pos = this.final_destination
	while true do
		if this.motion.arrived then
			break
		end
		if this.health.dead then
			sunray.kill_sorcerer(this.ritual_spot, this.left_path)
			SU.y_soldier_death(store, this)
			return
		end
		do_step()
		coroutine.yield()
	end
	sunray.on_sorcerer_arrived(this)
	this.health.hp = this.health.hp_max
	this.health_bar.hidden = true
	this.ui.can_click = false
	this.ui.can_select = false
	this.ui.can_hover = false
	U.bans_add(this.vis, F_ALL)
	if game.game_gui.selected_entity and game.game_gui.selected_entity.id == this.id then
		signal.emit("hide-bottom-info")
	end
	local suffix = this.is_top and "front" or "back"
	local raising_arms = false
	U.animation_start(this, this.cast_idle_anim .. suffix, not this.left_path, store.tick_ts, true, 1)
	while not this.health.dead do
		if this.raise_arms and not raising_arms then
			U.y_animation_play(this, this.cast_start_anim .. suffix, not this.left_path, store.tick_ts, 1, 1)
			U.animation_start(this, this.cast_loop_anim .. suffix, not this.left_path, store.tick_ts, true, 1)
			raising_arms = true
		end
		if not this.raise_arms and raising_arms then
			U.y_animation_play(this, this.cast_end_anim .. suffix, not this.left_path, store.tick_ts, 1, 1)
			U.animation_start(this, this.cast_idle_anim .. suffix, not this.left_path, store.tick_ts, true, 1)
			raising_arms = false
		end
		coroutine.yield()
	end
	sunray.kill_sorcerer(this.ritual_spot, this.left_path)
	SU.y_soldier_death(store, this)
end
local function tower_stage_213_sunray_obelisk_insert(this, store)
	return true
end
local function tower_stage_213_sunray_obelisk_update(this, store)
	local charged = false
	local charged_this_frame = false
	local sunray = find_all_t(store, this.sunray_tower)[1]
	local function set_charged()
		charged = true
		charged_this_frame = true
		this.ui.can_select = false
	end
	this.set_charged = set_charged
	local function shoot_bullet(attack, enemy)
		local roffset = attack.ray_start_offset
		local hoffset = enemy.unit.hit_offset
		local b = E:create_entity(attack.bullet)
		b.pos.x = this.pos.x + roffset.x
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + hoffset.x, enemy.pos.y + hoffset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.damage_factor = this.tower.damage_factor
		queue_insert(store, b)
	end
	local function shoot_bullet_pos(attack, target_pos)
		local roffset = attack.ray_start_offset
		local random_offset = v(U.frandom(attack.hit_offset_random_min, attack.hit_offset_random_max), U.frandom(attack.hit_offset_random_min, attack.hit_offset_random_max))
		local b = E:create_entity(attack.bullet)
		b.pos.x = this.pos.x + roffset.x
		b.pos.y = this.pos.y + roffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(target_pos.x + random_offset.x, target_pos.y + random_offset.y)
		b.bullet.source_id = this.id
		b.bullet.damage_factor = this.tower.damage_factor
		queue_insert(store, b)
	end
	U.y_animation_play(this, this.sunray.buy_start_anim, nil, store.tick_ts, 1, 1)
	U.animation_start(this, this.sunray.idle_loop_anim, nil, store.tick_ts, true, 1)
	if sunray.is_charged() then
		set_charged()
	end
	while true do
		if charged_this_frame then
			S:queue(this.sound_events.power_up)
			U.y_animation_play(this, this.sunray.charged_anim, nil, store.tick_ts, 1, 1)
			U.animation_start(this, this.sunray.charged_loop_anim, nil, store.tick_ts, true, 1)
			charged_this_frame = false
		end
		if charged then
			local a = this.attacks.list[1]
			local action_allowed = charged
			if action_allowed and this.ui.clicked then
				this.ui.clicked = nil
				this.ui.can_select = true
				S:queue(this.sound_events.power_up)
				for i = 1, this.sunray.shots do
					local _, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)
					if targets and #targets > 0 then
						U.animation_start(this, a.animation, nil, store.tick_ts, false, 1)
						shoot_bullet(a, targets[1])
					else
						U.y_animation_wait(this, 1)
						U.animation_start(this, a.animation_idle, nil, store.tick_ts, true, 1)
					end
					U.y_wait(store, this.sunray.time_between_shots)
				end
				S:queue(this.sound_events.power_down)
				U.y_animation_play(this, this.sunray.shoot_end_anim, nil, store.tick_ts, 1, 1)
				U.animation_start(this, this.sunray.idle_loop_anim, nil, store.tick_ts, true, 1)
				if not charged_this_frame then
					charged = false
				end
			end
			if this.ui.clicked then
				this.ui.clicked = nil
			end
		end
		coroutine.yield()
	end
end
local tt = E:register_t_hot("aura_shake_entity", "aura", true)
tt.main_script.update = aura_shake_entity_update
tt.aura.sprites_to_shake = {1}
tt.aura.duration = 0.5
tt.aura.amplitude = 1
tt.aura.freq_factor = 1
tt = E:register_t_hot("decal_stage_213_mask_1", "decal", true)
tt.render.sprites[1].name = "Stage_13_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 2
tt = E:register_t_hot("decal_stage_213_mask_2", "decal", true)
tt.render.sprites[1].name = "Stage_13_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, -82)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_mask_3", "decal", true)
tt.render.sprites[1].name = "Stage_13_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, -162)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_mask_4", "decal", true)
tt.render.sprites[1].name = "Stage_13_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, -82)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_mask_5", "decal", true)
tt.render.sprites[1].name = "Stage_13_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 2
tt = E:register_t_hot("decal_stage_213_mask_6", "decal", true)
tt.render.sprites[1].name = "Stage_13_over1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt = E:register_t_hot("decal_stage_213_mask_7", "decal", true)
tt.render.sprites[1].name = "Stage_13_over2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt = E:register_t_hot("decal_stage_213_mask_8", "decal", true)
tt.render.sprites[1].name = "Stage_13_over3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt = E:register_t_hot("decal_stage_213_mask_9", "decal", true)
tt.render.sprites[1].name = "Stage_13_over4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt = E:register_t_hot("decal_stage_213_water", "decal", true)
tt.render.sprites[1].prefix = "watershineS13Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(0.6)
tt.render.sprites[1].z = Z_TOWER_BASES - 1
tt = E:register_t_hot("decal_stage_213_sorcerer_door_light_left", "decal_tween", true)
AC(tt, "main_script")
tt.render.sprites[1].name = "Stage_13_light_left"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS - 1
tt.main_script.update = scripts.tween_utils.wait_update
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt = E:register_t_hot("decal_stage_213_sorcerer_door_light_right", "decal_stage_213_sorcerer_door_light_left", true)
tt.render.sprites[1].name = "Stage_13_light_right"
tt = E:register_t_hot("decal_stage_213_sorcerer_upper_walk_right", "decal_timed", true)
tt.render.sprites[1].prefix = "sorcerersideDef"
tt.render.sprites[1].name = "walkback"
tt.render.sprites[1].fps = 260 / (4.3)
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].offset = v(0, -200)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_sorcerer_upper_walk_left", "decal_stage_213_sorcerer_upper_walk_right", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("decal_stage_213_boss_cinematics", "decal", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].prefix = "trollboss_cinematicsDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 3
tt = E:register_t_hot("decal_stage_213_boss_shield", "decal", true)
AC(tt, "main_script", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].prefix = "trollboss_shieldDef"
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.shake_duration = 0.3
tt.shake_frequency = 0.25
tt.shake_amplitude = 0.6
tt.shake_damage_ratio = 28
tt.main_script.update = decal_stage_213_boss_shield_update
tt.sound_events.insert = "Stage13TrollKingShieldbreakShieldrop"
tt = E:register_t_hot("decal_stage_213_boss_hit_fx", "decal", true)
AC(tt, "main_script", "tween")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "trollboss_decalattackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].loop = false
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.wait_time = 2
tt.main_script.update = scripts.tween_utils.wait_update
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt = E:register_t_hot("decal_stage_213_boss_land_dust", "decal_timed", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].prefix = "trollboss_landDef"
tt.render.sprites[1].name = "landorjump"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_boss_jump_dust", "decal_timed", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].prefix = "trollboss_landDef"
tt.render.sprites[1].name = "landorjump"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_boss_land_cracks", "decal", true)
AC(tt, "main_script", "tween")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "trollboss_decallandDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].loop = false
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.wait_time = 2
tt.main_script.update = scripts.tween_utils.wait_update
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt = E:register_t_hot("decal_stage_213_boss_strik_tower_cinematic", "decal", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].prefix = "trollboss_cinematicsDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_213_sunray_tower_ray_ground", "decal", true)
AC(tt, "main_script", "tween")
tt.render.sprites[1].name = "RayDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
tt.tween.disabled = false
tt.tween.run_once = true
tt.wait_time = 2 + 1
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.main_script.update = scripts.tween_utils.wait_update
tt = E:register_t_hot("decal_stage_213_sunray_tower_ray", "decal", true)
AC(tt, "main_script")
tt.render.sprites[1].prefix = "RayHit"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt = E:register_t_hot("decal_stage_213_cliff_mask_small", "decal", true)
tt.render.sprites[1].name = "Stage_13_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(1.5, 1.2)
tt.render.sprites[1].alpha = 180
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("fx_stage_213_boss_hit_tower", "fx", true)
tt.render.sprites[1].prefix = "sunraytowers13hurtoverlayDef"
tt.render.sprites[1].name = "destroy"
tt.render.sprites[1].exo = true
tt = E:register_t_hot("fx_stage_213_sunray_tower_hit_fx", "fx", true)
tt.render.sprites[1].name = "RayHitFX_hit"
tt = E:register_t_hot("bullet_stage_213_sunray_tower_ray", "bullet", true)
tt.bullet.flight_time = fts(6)
tt.bullet.hit_time = fts(1)
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_payload = "aura_stage_213_sunray_tower_ray"
tt.bullet.hit_decal = "decal_stage_213_sunray_tower_ray_ground"
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].prefix = "Ray"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[1].sort_y_offset = 1
tt.track_target = false
tt.hit_over_duration = true
tt.hit_cycle_time = 0.1
tt.hit_decal_times = -1
tt.hit_decal_offset = v(0, 0)
tt.image_width = 205
tt.ray_duration = 2
tt.hit_delay = fts(1)
tt = E:register_t_hot("bullet_stage_213_sunray_tower_ray_boss", "bullet", true)
tt.bullet.flight_time = fts(6)
tt.bullet.hit_time = fts(1)
tt.bullet.damage_min = 40
tt.bullet.damage_max = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.level = 1
tt.bullet.hit_payload = nil
tt.bullet.hit_decal = nil
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].prefix = "Ray"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[1].sort_y_offset = 1
tt.track_target = false
tt.hit_over_duration = true
tt.hit_cycle_time = 0.25
tt.hit_decal_times = -1
tt.hit_decal_offset = v(0, 0)
tt.image_width = 205
tt.ray_duration = fts(58)
tt.hit_delay = fts(1)
tt = E:register_t_hot("bullet_stage_213_sunray_obelisk_ray", "bullet", true)
tt.bullet.flight_time = fts(6)
tt.bullet.hit_time = fts(1)
tt.bullet.hit_fx_ignore_hit_offset = false
tt.bullet.damage_min = 48
tt.bullet.damage_max = 72
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.level = 1
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].prefix = "MiniRay"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].sort_y_offset = -1
tt.image_width = 62.5
tt.ray_duration = fts(22)
tt.hit_delay = fts(1)
tt.sound_events.insert = "Stage13SunrayObeliskFire"
tt = E:register_t_hot("aura_stage_213_sunray_tower_ray", "aura", true)
tt.aura.duration = 1e+99
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.hit_fx = "fx_stage_213_sunray_tower_hit_fx"
tt.aura.cycles = 1
tt.aura.cycle_time = fts(1)
tt.aura.damage_min = 75
tt.aura.damage_max = 75
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.track_damage = true
tt.main_script.update = scripts.aura_apply_damage.update
tt = E:register_t_hot("controller_stage_213_sunray_tower_health", nil, true)
AC(tt, "main_script")
tt.main_script.update = controller_stage_213_sunray_tower_health_update
tt.health_boss_hits = 3
tt.broken_sunray_tower_t = "tower_stage_213_broken_sunray_tower"
tt.sunray_tower_t = "tower_stage_213_sunray_tower"
tt = E:register_t_hot("controller_stage_213_spawn_sorcerer", nil, true)
AC(tt, "events", "main_script")
tt.sorcerer_t = "soldier_stage_213_sorcerer"
tt.tower_t = "tower_stage_213_sunray_tower"
tt.boss_t = "enemy_boss_stage_213"
tt.left_path = 9
tt.right_path = 10
tt.boss_left_path = 11
tt.spawn_sorcerer_preamble_pos = v(512, 578)
tt.sorcerer_preamble_prefix = "decal_stage_213_sorcerer_upper_walk"
tt.sorcerer_spawn_time = 6
tt.sorcerer_door_wait = 3
tt.sorcerer_door_light_t = "decal_stage_213_sorcerer_door_light"
tt.main_script.update = controller_stage_213_spawn_sorcerer_update
tt.events.list[1].name = "spawn_sorcerer"
tt.events.list[1].on_event = controller_stage_213_spawn_sorcerer_on_spawn_event
tt.events.list[2] = {}
tt.events.list[2].name = "activate_automatic_spawn_sorcerer"
tt.events.list[2].on_event = controller_stage_213_spawn_sorcerer_on_activate_automatic_event
tt.events.list[3] = {}
tt.events.list[3].name = "deactivate_automatic_spawn_sorcerer"
tt.events.list[3].on_event = controller_stage_213_spawn_sorcerer_on_deactivate_automatic_event
tt = E:register_t_hot("controller_stage_213_achievement", nil, true)
tt.sorcerer_died = false
tt = E:register_t_hot("soldier_stage_213_sorcerer", "soldier_militia", true)
AC(tt, "nav_grid")
tt.info.portrait = "kr6_info_portraits_soldiers_0060"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.info.i18n_key = "SOLDIER_STAGE_213_SORCERER"
tt.main_script.update = soldier_stage_213_sorcerer_update
tt.render.sprites[1].prefix = "Sorcerer"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles.walk = {"walk", "walkback", "walkfront"}
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.health.hp_max = 120
tt.health.armor = 0
tt.health_bar.offset = v(0, 30)
tt.health.dead_lifetime = 12
tt.sunray_tower = "tower_stage_213_sunray_tower"
tt.cast_idle_anim = "idlecasting"
tt.cast_start_anim = "startcasting"
tt.cast_loop_anim = "casting"
tt.cast_end_anim = "stopcasting"
tt.regen.health = 0
tt.nav_grid = nil
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.motion.max_speed = 50
tt.melee.range = 35
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].hit_time = fts(10)
tt.soldier.melee_slot_offset = v(4, 0)
tt.sound_events.death = "Stage13SorcererDeath"
tt.ui.click_rect = r(-13, -2, 26, 25)
tt = E:register_t_hot("tower_stage_213_broken_sunray_obelisk", "tower", true)
AC(tt, "user_selection")
tt.tower.type = "stage_213_broken_sunray_obelisk"
tt.tower.level = 1
tt.tower.menu_offset = v(0, 0)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.disable_spend_highlight = true
tt.tower.can_hover = false
tt.info.fn = towers_portrait_get_info
tt.info.i18n_key = "TOWER_STAGE_213_SUNRAY_OBELISK"
tt.info.portrait = "kr6_info_portraits_towers_0012"
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "sunraytowerminiDef"
tt.render.sprites[1].name = "nothing"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.appear_anim = "appears"
tt.main_script.update = tower_stage_213_broken_sunray_obelisk_update
tt.ui.click_rect = r(-25, -20, 50, 80)
tt.ui.hover_sprite_scale = vv(0.8)
tt = E:register_t_hot("tower_stage_213_sunray_obelisk", "tower", true)
AC(tt, "user_selection", "attacks")
tt.tower.type = "stage_213_sunray_obelisk"
tt.tower.level = 1
tt.tower.price = 150
tt.tower.menu_offset = v(0, 0)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.disable_spend_highlight = true
tt.tower.can_hover = false
tt.info.fn = towers_portrait_get_info
tt.info.i18n_key = "TOWER_STAGE_213_SUNRAY_OBELISK"
tt.info.portrait = "kr6_info_portraits_towers_0012"
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "sunraytowerminiDef"
tt.render.sprites[1].name = "buy"
tt.render.sprites[1].exo = true
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_stage_213_sunray_obelisk_ray"
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].animation_idle = "shootidle"
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = 0
tt.attacks.list[1].min_range = 0
tt.attacks.list[1].max_range = 200
tt.attacks.list[1].cooldown = fts(10)
tt.attacks.list[1].node_prediction = fts(6)
tt.attacks.list[1].ray_start_offset = v(0, 70)
tt.attacks.list[1].hit_offset_random_min = -10
tt.attacks.list[1].hit_offset_random_max = 10
tt.sunray = {}
tt.sunray.points_to_charge = 2
tt.sunray.shots = 10
tt.sunray.time_between_shots = fts(8)
tt.sunray.buy_start_anim = "buy"
tt.sunray.idle_loop_anim = "off"
tt.sunray.charged_anim = "turnon"
tt.sunray.charged_loop_anim = "on"
tt.sunray.shoot_end_anim = "shootend"
tt.sunray_tower = "tower_stage_213_sunray_tower"
tt.main_script.insert = tower_stage_213_sunray_obelisk_insert
tt.main_script.update = tower_stage_213_sunray_obelisk_update
tt.sound_events.insert = "Stage13SunrayObeliskActivation"
tt.sound_events.power_up = "Stage13SunrayObeliskPowerUp"
tt.sound_events.power_down = "Stage13SunrayObeliskPowerDown"
tt.ui.click_rect = r(-25, -20, 50, 80)
tt.ui.hover_sprite_scale = vv(0.8)
tt = E:register_t_hot("tower_stage_213_sunray_tower", "tower", true)
AC(tt, "user_selection", "attacks")
tt.tower.type = "stage_213_sunray_tower"
tt.tower.level = 1
tt.tower.price = 200
tt.tower.menu_offset = v(0, 0)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.disable_spend_highlight = true
tt.tower.can_hover = false
tt.info.portrait = "kr6_info_portraits_towers_0012"
tt.info.fn = towers_portrait_get_info
tt.info.i18n_key = "TOWER_STAGE_213_SUNRAY_TOWER"
tt.render.sprites[1].prefix = "sunraytowers13baseDef"
tt.render.sprites[1].name = "off"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "sunraytowers13Def"
tt.render.sprites[2].name = "off"
tt.render.sprites[2].exo = true
tt.render.sprites[2].z = Z_OBJECTS
tt.sorcerer_slots_offsets = {v(-31, 23), v(-37, -23), v(31, 23), v(37, -23)}
tt.sunray = {}
tt.sunray.points_to_charge = 28
tt.sunray.points_per_second = {0.61, 0.74, 0.87, 1}
tt.sunray.sorcerers_to_charge = 1
tt.sunray.sorcerer_t = "soldier_stage_213_sorcerer"
tt.sunray.boss_t = "enemy_boss_stage_213"
tt.sunray.ray_duration = 2
tt.sunray.boss_ray_duration = fts(58)
tt.sunray.off_anim = "off"
tt.sunray.charge_start_anim = "chargestart"
tt.sunray.charge_loop_anim = "chargeloop"
tt.sunray.charged_start_anim = "chargedstart"
tt.sunray.charged_loop_anim = "chargedidle"
tt.sunray.shoot_start_anim = "shotstart"
tt.sunray.shoot_loop_anim = "shotloop"
tt.sunray.shoot_end_anim = "shotendbacktooff"
tt.sunray.charge_cancel_anim = "chargecancel"
tt.sunray.destroyed_anim = "destroy"
tt.sunray.damaged_health_prefix = "sunraytowers13brokenDef"
tt.sunray.very_damaged_health_prefix = "sunraytowers13broken2Def"
tt.shake_duration = 2
tt.shake_amplitude = 0.15
tt.shake_frequency = 3
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_stage_213_sunray_tower_ray"
tt.attacks.list[1].hit_decal = "decal_stage_213_sunray_tower_ray"
tt.attacks.list[1].shoot_time = fts(18)
tt.attacks.list[1].start_anim_duration = fts(27)
tt.attacks.list[1].start_anim = tt.sunray.shoot_start_anim
tt.attacks.list[1].loop_anim = tt.sunray.shoot_loop_anim
tt.attacks.list[1].end_anim = tt.sunray.shoot_end_anim
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].accepted_terrains = bor(TERRAIN_LAND)
tt.attacks.list[1].min_range = 0
tt.attacks.list[1].max_range = 1500
tt.attacks.list[1].cooldown = fts(10)
tt.attacks.list[1].node_prediction = fts(6)
tt.attacks.list[1].ray_start_offset = v(0, 140)
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].bullet = "bullet_stage_213_sunray_tower_ray_boss"
tt.attacks.list[2].hit_decal = "decal_stage_213_sunray_tower_ray"
tt.attacks.list[2].shoot_time = fts(18)
tt.attacks.list[2].start_anim_duration = fts(27)
tt.attacks.list[2].start_anim = tt.sunray.shoot_start_anim
tt.attacks.list[2].loop_anim = tt.sunray.shoot_loop_anim
tt.attacks.list[2].end_anim = tt.sunray.shoot_end_anim
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[2].vis_bans = bor(F_FRIEND)
tt.attacks.list[2].min_range = 0
tt.attacks.list[2].max_range = 1500
tt.attacks.list[2].cooldown = fts(10)
tt.attacks.list[2].ray_start_offset = v(0, 140)
tt.left_path = 9
tt.right_path = 10
tt.obelisk_t = "tower_stage_213_sunray_obelisk"
tt.broken_obelisk_t = "tower_stage_213_broken_sunray_obelisk"
tt.sorcerer_t = "soldier_stage_213_sorcerer"
tt.expected_obelisks = 2
tt.main_script.insert = tower_stage_213_sunray_tower_insert
tt.main_script.update = tower_stage_213_sunray_tower_update
tt.main_script.remove = tower_stage_213_sunray_tower_remove
tt.sound_events.charge_start = "Stage13SunrayTowerActivation"
tt.sound_events.charge_end = "Stage13SunrayTowerPowerUp"
tt.sound_events.ray_fire = "Stage13SunrayRayCast"
tt.sound_events.ray_loop = "Stage13SunrayRayLoop"
tt.sound_events.ray_end = "Stage13SunrayTowerPowerDown"
tt.controller_health = "controller_stage_213_sunray_tower_health"
tt.anim_death = "death"
tt.ui.click_rect = r(-40, -40, 80, 180)
tt.ui.hover_sprite_scale = vv(1)
