local P = require("path_db")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local GR = require("grid_db")
local log = require("lib.klua.log"):new("level211")
local function generate_blue_noise_cluster(count, candidates, random_fn, ...)
	local points = {}
	local x, y = random_fn(...)
	points[1] = {
		x = x,
		y = y
	}
	for i = 2, count do
		local bestCandidate
		local bestDistance2 = -1
		for c = 1, candidates do
			local px, py = random_fn(...)
			local minDist2 = math.huge
			for _, p in ipairs(points) do
				local d2 = V.dist2(px, py, p.x, p.y)
				if d2 < minDist2 then
					minDist2 = d2
				end
			end
			if bestDistance2 < minDist2 then
				bestDistance2 = minDist2
				bestCandidate = {
					x = px,
					y = py
				}
			end
		end
		points[i] = bestCandidate
	end
	return points
end
local function random_point_in_rectangle(x_min, y_min, x_max, y_max)
	return math.random(x_min, x_max), math.random(y_min, y_max)
end
local S = require("sound_db")
local SU = require("script_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")
local km = require("lib.klua.macros")
local r = V.r
local v = V.v
local vv = V.vv
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function fts(t)
	return t / 30
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
local function tpos(e)
	return e.tower and e.tower.range_offset and v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end
local function decal_stage_211_spider_eyes_update(this, store, script)
	local target = store.entities[this.target_id]
	if not target or not target.pos then
		queue_remove(store, this)
		return
	end
	this.pos = target.pos
	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end
	if this.tween then
		this.tween.ts = store.tick_ts
	end
	local left_shadow = false
	local radius_offset = 110
	local shadow = find_all_t(store, this.shadow_t)[1]
	while true do
		target = store.entities[this.target_id]
		if not target or target.health.dead then
			queue_remove(store, this)
			return
		end
		local animation = "walk"
		local target_speed = target.motion and target.motion.max_speed
		if target_speed == 0 then
			animation = "idle"
		end
		local an, af = U.animation_name_facing_point(this, animation, target.motion.dest, 1)
		U.animation_start(this, an, af, store.tick_ts, true, 1)
		if not left_shadow and U.is_inside_ellipse(this.pos, shadow.pos, shadow.aura.radius + radius_offset, 0.63) then
			left_shadow = true
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = this.remove_keys
		elseif left_shadow and not U.is_inside_ellipse(this.pos, shadow.pos, shadow.aura.radius + radius_offset, 0.63) then
			left_shadow = false
			this.tween.ts = store.tick_ts
			this.tween.props[1].keys = this.insert_keys
		end
		coroutine.yield()
	end
end
local function decal_stage_211_giant_spider_rappel_spawn_update(this, store, script)
	local shadow, string = scripts.decal_rappel_utils.y_descend(this, store)
	U.animation_start(this, this.short_rappel_anim, nil, store.tick_ts, nil, 1)
	U.y_wait(store, this.wait_detach)
	string.dissolve = true
	U.animation_start(shadow, this.short_rappel_shadow_anim, nil, store.tick_ts, nil, 1)
	U.y_ease_key(store, this.pos, "y", this.pos.y, this.target_pos.y + this.trigger_land_distance, this.short_rappel_duration, this.short_rappel_ease, function(dt, p)
		local dy = this.pos.y - this.target_pos.y
		this.render.sprites[1].sort_y_offset = -dy
		for i, v in ipairs(string.render.sprites) do
			local dy = this.pos.y - v.offset.y - this.target_pos.y
			v.sort_y_offset = -dy
		end
	end)
	local sp = E:create_entity(this.spawn_t)
	sp.pos.x, sp.pos.y = this.target_pos.x, this.target_pos.y
	sp.nav_path.pi = this.pi
	sp.nav_path.spi = this.spi
	sp.nav_path.ni = this.ni
	queue_insert(store, sp)
	queue_remove(store, shadow)
	queue_remove(store, this)
end
local function decal_stage_211_sarelgaz_tower_block_update(this, store, script)
	local start_y = scripts.decal_rappel_utils.set_y(this, store)
	this.pos.y = start_y
	local function find_tower(holder_id)
		local match = table.filter(store.entities, function(k, v)
			return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.type ~= "holder" and v.tower.type ~= "build_animation" and v.tower.holder_id == holder_id
		end)
		if not match or #match == 0 then
			return nil
		end
		return match[1]
	end
	local shadow, string, max_height = scripts.decal_rappel_utils.y_descend(this, store)
	local tap_tut = E:create_entity(this.tap_tutorial)
	tap_tut.pos.x, tap_tut.pos.y = this.pos.x + this.tap_tutorial_offset.x, this.pos.y + this.tap_tutorial_offset.y
	tap_tut.render.sprites[1].ts = store.tick_ts
	tap_tut.render.sprites[1].scale = V.vv(0.6)
	queue_insert(store, tap_tut)
	local spinning_ts = store.tick_ts
	local taps = 0
	local tower = find_tower(this.holder_id)
	if not tower then
	else
		S:queue(this.sound_events.webbing)
		U.y_animation_play(this, this.start_web_anim, nil, store.tick_ts, 1, 1)
		U.animation_start(this, this.loop_web_anim, nil, store.tick_ts, true, 1)
		tower.ui.can_click = false
		SU.tower_block_inc(tower)
		while store.tick_ts - spinning_ts <= this.time_to_block do
			if not tower then
				goto label_1213_0
			end
			if this.ui.clicked then
				this.ui.clicked = false
				taps = taps + 1
			end
			if taps >= this.taps_to_remove then
				S:queue(this.sound_events.interrupt)
				U.y_animation_play(this, this.tapped_anim, nil, store.tick_ts, 1, 1)
				break
			end
			coroutine.yield()
		end
		tower.ui.can_click = true
		SU.tower_block_dec(tower)
		if taps < this.taps_to_remove then
			local block = E:create_entity(this.block_mod)
			block.modifier.target_id = tower.id
			queue_insert(store, block)
		end
	end
	::label_1213_0::
	queue_remove(store, tap_tut)
	if taps < this.taps_to_remove then
		U.y_wait(store, this.wait_after_trap)
	end
	U.animation_start(this, this.ascend_anim, nil, store.tick_ts, false, 1)
	scripts.decal_rappel_utils.y_ascend(this, store, start_y, max_height, shadow, string)
	this.controller._done = true
	queue_remove(store, shadow)
	queue_remove(store, this)
end
local function decal_stage_211_sarelgaz_eggs_spawn_update(this, store, script)
	local start_y = scripts.decal_rappel_utils.set_y(this, store)
	this.pos.y = start_y
	local shadow, string, max_height = scripts.decal_rappel_utils.y_descend(this, store)
	U.animation_start(this, this.place_egg_anim, nil, store.tick_ts, nil, 1)
	U.y_wait(store, this.egg_spawn_time)
	S:queue(this.sound_events.egg)
	local spawner = store.entities[this.nest_id]
	if not spawner then
		U.animation_start(this, this.ascend_anim, nil, store.tick_ts, true, 1)
		scripts.decal_rappel_utils.y_ascend(this, store, start_y, max_height, shadow, string)
		if this.controller then
			this.controller._done = true
		end
		queue_remove(store, shadow)
		queue_remove(store, this)
		return
	end
	local egg = E:create_entity(this.egg_prefix .. "_" .. this.to_spawn)
	egg.pos.x, egg.pos.y = this.target_pos.x, this.target_pos.y
	egg.hatch_amount = this.amount
	egg.path_id = this.path_id
	egg.render.sprites[1].ts = store.tick_ts
	egg.source_id = spawner.id
	queue_insert(store, egg)
	spawner.has_eggs = true
	spawner.current_egg = egg
	U.animation_start(this, this.ascend_anim, nil, store.tick_ts, true, 1)
	scripts.decal_rappel_utils.y_ascend(this, store, start_y, max_height, shadow, string)
	this.controller._done = true
	queue_remove(store, shadow)
	queue_remove(store, this)
end
local function decal_stage_211_sarelgaz_descent_update(this, store, script)
	this.render.sprites[1].ts = store.tick_ts
	local start_y = scripts.decal_rappel_utils.set_y(this, store)
	this.pos.y = start_y
	local shadow = scripts.decal_rappel_utils.y_descend(this, store)
	local boss = find_all_t(store, this.boss_t)[1]
	if boss then
		boss.lower_trigger = true
	end
	local controller = find_all_t(store, this.controller_t)[1]
	controller._done = true
	this.finished = true
	coroutine.yield()
	if not boss then
		coroutine.yield()
	end
	this.render.sprites[1].hidden = true
	U.y_wait(store, fts(10))
	queue_remove(store, shadow)
	queue_remove(store, this)
end
local function decal_stage_211_sarelgaz_ascent_update(this, store, script)
	this.render.sprites[1].ts = store.tick_ts
	local start_y = scripts.decal_rappel_utils.set_y(this, store)
	scripts.decal_rappel_utils.y_ascend(this, store, start_y)
	local controller = find_all_t(store, this.controller_t)[1]
	controller._done = true
	queue_remove(store, this)
end
local function decal_stage_211_torch_insert(this, store)
	local l = E:create_entity(this.torch_light_t)
	l.pos.x, l.pos.y = this.pos.x + this.light_offset.x, this.pos.y + this.light_offset.y
	this._torch_light = l
	queue_insert(store, l)
	return true
end
local function decal_stage_211_torch_update(this, store)
	while this.render.sprites[1].hidden do
		coroutine.yield()
	end
	if this.skip_to_loop then
	else
		this._torch_light.render.sprites[1].hidden = false
		U.animation_start(this, "spawn", nil, store.tick_ts, false, 1)
		U.animation_start(this._torch_light, "spawn", nil, store.tick_ts, false, 1)
		while not U.animation_finished(this, 1) do
			coroutine.yield()
		end
	end
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1)
	U.animation_start(this._torch_light, "loop", nil, store.tick_ts, true, 1)
end
local function aura_stage_211_camp_fire_arrow_fire_update(this, store, script)
	U.animation_start(this, "hit", nil, store.tick_ts, false, 1)
	local ts = store.tick_ts
	while store.tick_ts - ts < this.aura.duration do
		local targets = table.filter(store.entities, function(k, v)
			return string.match(v.template_name, this.eggs_prefix) and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
		end)
		for i, target in ipairs(targets) do
			target.burn = true
			goto label_1236_0
		end
		coroutine.yield()
	end
	::label_1236_0::
	U.y_animation_wait(this, 1)
	queue_remove(store, this)
end
local function controller_stage_211_shadows_update(this, store, script)
	this._ease = false
	while true do
		if this._ease and this._ease_from and this._ease_to then
			local i = 1
			local torches = find_all_t(store, this.torch_t, false, function(k, v)
				return v.camp_level == this._camp_level
			end)
			local function place_torches(dt, p)
				torches[i].render.sprites[1].hidden = false
				i = km.clamp(1, #torches, i + 1)
			end
			local shadow_out = find_all_t(store, this.shadow_decal_prefix .. "_lvl" .. this._camp_level - 1)[1]
			local shadow_in = find_all_t(store, this.shadow_decal_prefix .. "_lvl" .. this._camp_level)[1]
			local eyes = {}
			local all_eyes = find_all_t(store, "decal_stage_211_spider_eyes_", true, function(k, v)
				return v.template_name ~= "decal_stage_211_spider_eyes_medium" and v.template_name ~= "decal_stage_211_spider_eyes_small" and v.template_name ~= "decal_stage_211_spider_eyes_big"
			end)
			table.append(eyes, all_eyes)
			for _, v in pairs(eyes) do
				queue_remove(store, v)
			end
			if shadow_in then
				shadow_in.render.sprites[1].hidden = false
				U.y_ease_key(store, shadow_in.render.sprites[1], "alpha", 0, 255, this.ease_durations, "quad-in")
			end
			while i < #torches do
				place_torches()
			end
			U.y_wait(store, fts(1))
			U.y_ease_key(store, shadow_out.render.sprites[1], "alpha", 255, 0, this.ease_durations, "quad-in")
			this._ease = false
		end
		coroutine.yield()
	end
end
local function aura_stage_211_shadow_update(this, store)
	local affected_enemies = {}
	local grid_copy = {}
	this.grid_changeup = true
	local function enemy_invulnerability()
		local targets = table.filter(store.enemies, function(k, v)
			return v.unit and v.vis and v.health and not v.health.dead and not affected_enemies[v.id] and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and not U.is_inside_ellipse(v.pos, this.pos, this.aura.radius, 0.63)
		end)
		for k, v in pairs(targets) do
			if not affected_enemies[v.id] then
				affected_enemies[v.id] = v
				U.bans_add(v.vis, F_ALL)
			end
		end
		local remove = table.filter(affected_enemies, function(k, v)
			return U.is_inside_ellipse(v.pos, this.pos, this.aura.radius, 0.63)
		end)
		for k, v in pairs(remove) do
			affected_enemies[v.id] = nil
			U.bans_remove(v.vis, F_ALL)
		end
	end
	local function grid_save()
		local grid_long = #GR.grid
		local grid_tall = #GR.grid[1]
		for i = 1, grid_long do
			if not grid_copy[i] then
				grid_copy[i] = {}
			end
			for j = 1, grid_tall do
				if not grid_copy[i][j] then
					grid_copy[i][j] = {GR.grid[i][j]}
				else
					grid_copy[i][j] = GR.grid[i][j]
				end
			end
		end
	end
	local function grid_changeup()
		local grid_long = #GR.grid
		local grid_tall = #GR.grid[1]
		local grid_spacing_x = GR.cell_size
		local grid_spacing_y = GR.cell_size
		for i = 0, grid_long - 1 do
			for j = 0, grid_tall - 1 do
				local ul = v(i * grid_spacing_x + GR.ox, (j + 1) * grid_spacing_y + GR.oy)
				local ur = v((i + 1) * grid_spacing_x + GR.ox, (j + 1) * grid_spacing_y + GR.oy)
				local bl = v(i * grid_spacing_x + GR.ox, j * grid_spacing_y + GR.oy)
				local br = v((i + 1) * grid_spacing_x + GR.ox, j * grid_spacing_y + GR.oy)
				local touches_grid = U.is_inside_ellipse(ul, this.pos, this.aura.radius, 0.63) or U.is_inside_ellipse(ur, this.pos, this.aura.radius, 0.63) or U.is_inside_ellipse(bl, this.pos, this.aura.radius, 0.63) or U.is_inside_ellipse(br, this.pos, this.aura.radius, 0.63)
				if not touches_grid then
					GR.grid[i + 1][j + 1] = bor(band(grid_copy[i + 1][j + 1][1], TERRAIN_PROPS_MASK), TERRAIN_FLYING_NOWALK)
				else
					GR.grid[i + 1][j + 1] = grid_copy[i + 1][j + 1][1]
				end
			end
		end
	end
	grid_save()
	while true do
		if this.grid_changeup then
			grid_changeup()
			this.grid_changeup = false
		end
		enemy_invulnerability()
		U.y_wait(store, 0.2)
	end
end
local function mod_stage_211_tower_web_update(this, store)
	local m = this.modifier
	U.y_animation_wait(this, 1)
	U.animation_start(this, this.idle_anim, nil, store.tick_ts, true, 1)
	local start_ts = store.tick_ts
	while store.tick_ts - start_ts < m.duration do
		coroutine.yield()
	end
	U.y_animation_play(this, this.end_anim, nil, store.tick_ts, 1, 1)
	queue_remove(store, this)
end
local function tower_stage_211_spider_eggs_nest_update(this, store, script)
	local function activate(camp)
		if camp then
			camp._target_nest_id = this.nest_id
		end
	end
	local can_shoot = false
	local camp
	this.has_eggs = false
	while true do
		camp = camp or find_all_t(store, this.camp_t)[1]
		if camp then
			can_shoot = not camp.arrow_in_cooldown
		else
			can_shoot = false
		end
		local usable = can_shoot and this.has_eggs
		this.user_selection.allowed = usable
		this.tower_action.active = not usable
		this.tower.blocked = not this.has_eggs and camp
		this.tower.can_hover = this.has_eggs and camp
		this.ui.can_click = this.has_eggs and camp
		this.ui.can_hover = this.has_eggs and camp
		if this.user_selection.in_progress and usable then
			store.player_gold = store.player_gold - this.tower_action.cost
			this.user_selection.in_progress = nil
			this.user_selection.allowed = false
			activate(camp)
		end
		if this.user_selection.in_progress then
			this.user_selection.in_progress = nil
		end
		coroutine.yield()
	end
end
local function tower_stage_211_camp_on_level_up(this, store, current_level, ignore_animation)
	local a = this.attacks
	local aa = a and a.list[2] or nil
	local function replace_holder(h)
		local holder = E:create_entity(this.hand_insert and this.holder_on_fow_instant or this.holder_on_fow_reveal)
		holder.pos = V.vclone(h.pos)
		holder.tower.terrain_style = h.tower.terrain_style
		holder.tower.default_rally_pos = h.tower.default_rally_pos
		holder.tower.holder_id = h.tower.holder_id
		holder.ui.nav_mesh_id = h.ui.nav_mesh_id
		holder.tower.level = 1
		holder.tower.can_be_mod = false
		if holder.tween then
			holder.tween.props[1].ts = store.tick_ts
		end
		queue_insert(store, holder)
		queue_remove(store, h)
	end
	local function ease_lights(from, to, lvl)
		if this._shadows_controller._ease then
			U.y_wait(store, 1e+99, function()
				return not this._shadows_controller._ease
			end)
		end
		this._shadows_controller._ease = true
		this._shadows_controller._ease_from = from
		this._shadows_controller._ease_to = to
		this._shadows_controller._camp_level = lvl
	end
	this._shadows_aura.aura.radius = this._shadows_aura.radius_levels[current_level]
	if current_level == 1 then
		return
	end
	this._shadows_aura.grid_changeup = true
	local walls_lvlup_anim
	if current_level > 1 then
		walls_lvlup_anim = "levelup"
		local fow_blocked_holders = find_all_t(store, this.fow_holders_t)
		for k, v in pairs(fow_blocked_holders) do
			replace_holder(v)
		end
		local buy_c = find_all_t(store, "controller_show_buy_available")[1]
		if buy_c then
			buy_c.force_check = true
		end
	end
	if current_level == 3 then
		walls_lvlup_anim = "levelup2"
		if not ignore_animation then
			U.animation_start(this, this.anim_level_up, nil, store.tick_ts, false, 1)
		end
	end
	if not ignore_animation then
		S:queue(this.sound_events.level_up)
		S:queue(this.sound_events.level_up_taunt)
	end
	local walls = find_all_t(store, this.walls_t_prefix, true)
	for i, v in ipairs(walls) do
		if not ignore_animation then
			U.animation_start(v, walls_lvlup_anim, nil, store.tick_ts, false, 1)
		else
			U.animation_start(v, "idle" .. current_level, nil, store.tick_ts, false, 1)
		end
	end
	if not ignore_animation then
		U.y_wait(store, 0.5)
	end
	if not ignore_animation then
		ease_lights(this.target_radius[current_level - 1], this.target_radius[current_level], current_level)
	end
	if not ignore_animation then
		U.y_animation_wait(this, 1)
	end
	if current_level == 3 then
		this.render.sprites[2].hidden = false
		this.render.sprites[3].hidden = false
		local arrow_t = E:get_template(aa.bullet)
		aa.pred_time = 2 * (math.sqrt(2 * arrow_t.bullet.fixed_height * arrow_t.bullet.g * -1) / arrow_t.bullet.g * -1)
	end
	U.animation_start(this, "idle" .. current_level - 1, nil, store.tick_ts, true, 1)
end
local function tower_stage_211_camp_insert(this, store)
	local personal_barracks = find_all_t(store, this.barracks_t)
	for i, b in ipairs(personal_barracks) do
		b.barrack.max_soldiers = this.barracks_soldiers[this.tower.level]
		local t = E:get_template(b.barrack.soldier_type)
		t.health.dead_lifetime = this.soldiers_dead_lifetime[this.tower.level]
		for i, s in ipairs(b.barrack.soldiers) do
			s.health.dead_lifetime = this.soldiers_dead_lifetime[this.tower.level]
		end
	end
	local lights_controllers = find_all_t(store, this.shadows_controller)
	if not lights_controllers or #lights_controllers == 0 then
		this._shadows_controller = E:create_entity(this.shadows_controller)
		this._shadows_controller.pos = V.vclone(this.pos)
		this._shadows_controller._camp = this
		queue_insert(store, this._shadows_controller)
	else
		this._shadows_controller = lights_controllers[1]
		this._shadows_controller._camp = this
	end
	local invulnerability_auras = find_all_t(store, this.shadows_aura)
	if not invulnerability_auras or #invulnerability_auras == 0 then
		this._shadows_aura = E:create_entity(this.shadows_aura)
		this._shadows_aura.pos = V.v(this.pos.x + this.shadows_offset.x, this.pos.y + this.shadows_offset.y)
		queue_insert(store, this._shadows_aura)
	else
		this._shadows_aura = invulnerability_auras[1]
		this._shadows_aura.pos = V.v(this.pos.x + this.shadows_offset.x, this.pos.y + this.shadows_offset.y)
	end
	this.damage_state = 1
	this.camp_front = find_all_t(store, this.camp_front)[1]
	this.camp_back = find_all_t(store, this.camp_back)[1]
	this.tent_hit_ts = store.tick_ts
	if this.hand_insert then
		tower_stage_211_camp_on_level_up(this, store, this.tower.level, true)
	end
	return true
end
local function tower_stage_211_camp_enemy_reached_goal_fn(this, store, event_name, e)
	local function hit_animations(defeat_controller)
		if not defeat_controller then
			return
		end
		S:queue(this.sound_events.hit_camp)
		this.tent_hit_ts = store.tick_ts
		local hit_anim = "hit"
		if this.tower.level == 3 then
			hit_anim = "hit2"
			if not defeat_controller.defeat_cinematic then
				if this.fire_arrow_shooter ~= 2 and this.arrow_shooter ~= 2 then
					U.animation_start(this, "hit", nil, store.tick_ts, nil, 2)
				end
				if this.fire_arrow_shooter ~= 3 and this.arrow_shooter ~= 3 then
					U.animation_start(this, "hit", nil, store.tick_ts - fts(math.random(1, 4)), nil, 3)
				end
			end
		end
		if not defeat_controller.defeat_cinematic then
			U.animation_start(this, hit_anim, nil, store.tick_ts, nil, 1)
		end
		U.animation_start(this.camp_front, "hit" .. this.damage_state, nil, store.tick_ts, nil, 1)
		U.animation_start(this.camp_back, "hit" .. (this.damage_state == 1 and "" or this.damage_state), nil, store.tick_ts, nil, 1)
	end
	local size = "small"
	if e.unit.size == UNIT_SIZE_MEDIUM then
		size = "medium"
	end
	if e.unit.size == UNIT_SIZE_LARGE then
		size = "big"
	end
	local fx = E:create_entity(this.camp_damage_fx .. "_" .. size)
	fx.pos.x, fx.pos.y = e.pos.x, e.pos.y
	fx.render.sprites[1].ts = store.tick_ts
	queue_insert(store, fx)
	local defeat_controller = find_all_t(store, "controller_stage_211_loss")[1]
	if not defeat_controller then
		log.debug("tower_stage_211_camp.enemy_reached_goal_fn - defeat_controller removed. skipping...")
		return
	end
	if not defeat_controller.defeat_cinematic and store.lives <= this.lives_thresholds[1] then
		this.damage_state = 2
		hit_animations(defeat_controller)
	end
	if not defeat_controller.defeat_cinematic and store.lives <= this.lives_thresholds[2] then
		this.damage_state = 3
		hit_animations(defeat_controller)
	end
	hit_animations(defeat_controller)
	if not defeat_controller.defeat_cinematic and store.lives <= e.enemy.lives_cost then
		store.game_outcome = {}
		store.ephemeral.defeat_cinematic = true
		defeat_controller.defeat_cinematic = true
		defeat_controller.normal_defeat = true
	end
end
local function tower_stage_211_camp_update(this, store)
	local a = this.attacks
	local afa = a and a.list[1] or nil
	local aa = a and a.list[2] or nil
	local last_shooter = 2
	local nests = find_all_t(store, this.nest_t)
	table.sort(nests, function(v1, v2)
		return v1.nest_id < v2.nest_id
	end)
	this._target_nest_id = -1
	local function shoot_arrow(attack, pos, shooter, enemy, af, egg)
		local b = E:create_entity(attack.bullet)
		local boffset = aa.bullet_start_offset
		local hoffset = enemy and V.vclone(enemy.unit.hit_offset) or v(0, 0)
		b.pos.x = this.pos.x + shooter.offset.x + boffset.x * (not af and 1 or -1)
		b.pos.y = this.pos.y + shooter.offset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(pos.x + hoffset.x, pos.y + hoffset.y)
		b.bullet.source_id = this.id
		if enemy then
			b.bullet.target_id = enemy.id
			b.bullet.damage_factor = this.tower.damage_factor
		elseif egg then
			b.bullet.target_id = egg.id
		end
		if b.bullet.fixed_height then
			b.bullet.flight_time = 2 * (math.sqrt(2 * b.bullet.fixed_height * b.bullet.g * -1) / b.bullet.g * -1)
		end
		queue_insert(store, b)
	end
	if not this.hand_insert then
		tower_stage_211_camp_on_level_up(this, store, this.tower.level, false)
	end
	local archer_flip_ts = {store.tick_ts, store.tick_ts - math.random(1, 9)}
	local fire_arrow_ts = store.tick_ts
	while true do
		if this.tower.level == 3 and not this.destruction_sequence then
			if this._target_nest_id ~= -1 and not this.arrow_in_cooldown then
				this.arrow_in_cooldown = true
				fire_arrow_ts = store.tick_ts
				last_shooter = last_shooter == 2 and 1 or 2
				local shooter = this.render.sprites[last_shooter + 1]
				this.fire_arrow_shooter = last_shooter + 1
				local nest = nests[this._target_nest_id]
				local nest_pos = nest.pos
				local af = true
				if nest_pos.x > this.pos.x + shooter.offset.x then
					af = false
				end
				nest.current_egg.time_to_spawn = 1e+99
				U.animation_start(this, shooter.shoot, af, store.tick_ts, false, last_shooter + 1)
				U.y_wait(store, afa.shoot_time)
				S:queue(afa.sound_shoot)
				S:queue(afa.sound)
				shoot_arrow(afa, nest_pos, shooter, nil, af, nest.current_egg)
				this.fire_arrow_firing = -1
				this._target_nest_id = -1
				signal.emit("protein-rich")
			end
			if store.tick_ts - aa.ts > aa.cooldown then
				local pred_time = aa.shoot_time
				local trigger_enemy, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, pred_time, aa.vis_flags, aa.vis_bans, function(e, o)
					local nodes_vel = e.motion.max_speed / 5.5
					local nodes_in_fly_time = nodes_vel * aa.pred_time
					local nodes_to_end = P:nodes_to_goal(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
					return nodes_in_fly_time < nodes_to_end
				end)
				local final_enemy, final_pos, shooter, af
				if not trigger_enemy then
					SU.delay_attack(store, aa, fts(10))
					goto label_1226_0
				end
				final_pos = V.vclone(pred_pos)
				last_shooter = last_shooter == 2 and 1 or 2
				aa.ts = store.tick_ts
				shooter = this.render.sprites[last_shooter + 1]
				this.arrow_shooter = last_shooter + 1
				af = true
				if trigger_enemy.pos.x > this.pos.x + shooter.offset.x then
					af = false
				end
				U.animation_start(this, shooter.shoot, af, store.tick_ts, false, last_shooter + 1)
				U.y_wait(store, aa.shoot_time)
				final_enemy = trigger_enemy
				if not final_enemy or final_enemy.health and final_enemy.health.dead then
					final_enemy, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)
					if final_enemy then
						final_pos = V.vclone(pred_pos)
					end
				end
				shoot_arrow(aa, final_pos, shooter, final_enemy, af, nil)
				U.y_animation_wait(this, last_shooter + 1)
				this.arrow_shooter = -1
			end
			for i, ts in ipairs(archer_flip_ts) do
				if store.tick_ts - ts > this.flip_time then
					if math.random() > 0.5 then
						this.render.sprites[i + 1].flip_x = not this.render.sprites[i + 1].flip_x
					end
					archer_flip_ts[i] = store.tick_ts
				end
			end
			::label_1226_0::
			if store.tick_ts - fire_arrow_ts > this.attacks.list[1].cooldown then
				this.arrow_in_cooldown = false
			end
		end
		coroutine.yield()
	end
end
local function tower_stage_211_camp_remove(this, store)
	return true
end
local function controller_stage_211_spider_block_and_spawn_update(this, store, script)
	local spawners = find_all_t(store, this.spawner_t)
	local r_interval = U.frandom(this.block_towers_interval_min, this.block_towers_interval_max)
	this.in_use = false
	this._tower_block = true
	this._spawn_eggs = true
	this._lower_boss = true
	this._done = true
	table.sort(spawners, function(v1, v2)
		return v1.nest_id < v2.nest_id
	end)
	U.y_wait(store, 1e+99, function(s, t)
		return store.wave_group_number > 0
	end)
	local block_tower_ts = store.tick_ts
	while true do
		if this._spawn_eggs and this.eggs_queue and #this.eggs_queue > 0 and not this.in_use then
			local egg_spawn = table.remove(this.eggs_queue, 1)
			this._done = false
			this.in_use = true
			local mid = this.nest_id == -1 and math.random(1, #spawners) or egg_spawn.nest_id
			local sp = spawners[mid]
			local egg_spawner = E:create_entity(this.spider_spawn_t)
			egg_spawner.controller = this
			egg_spawner.amount = egg_spawn.amount
			egg_spawner.to_spawn = egg_spawn.to_spawn
			egg_spawner.nest_id = sp.id
			egg_spawner.path_id = sp.path_id
			egg_spawner.pos.x = sp.pos.x
			egg_spawner.target_pos.x, egg_spawner.target_pos.y = sp.pos.x, sp.pos.y
			queue_insert(store, egg_spawner)
			while not this._done do
				coroutine.yield()
			end
			U.y_wait(store, this.global_cooldown)
			this.in_use = false
		end
		if this._tower_block and table.contains(this.active_waves, store.wave_group_number) and store.level_mode == GAME_MODE_CAMPAIGN and r_interval < store.tick_ts - block_tower_ts and not this.in_use then
			r_interval = U.frandom(this.block_towers_interval_min, this.block_towers_interval_max)
			this.in_use = true
			this._done = false
			local towers = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.type ~= "holder" and v.tower.type ~= "build_animation" and v.tower.type ~= "stage_11_spider_eggs_nest" and v.tower.type ~= "stage_11_camp" and v.tower.holder_id ~= "5" and v.tower.holder_id ~= "6" and (not v.tower_holder or not v.tower_holder.blocked) and not U.has_modifier_types(store, v, MOD_TYPE_PROTECTION)
			end)
			if towers and #towers > 0 then
				local r = math.random(1, #towers)
				local blocker = E:create_entity(this.spider_block_t)
				blocker.controller = this
				blocker.holder_id = towers[r].tower.holder_id
				blocker.pos.x = towers[r].pos.x
				blocker.target_pos.x, blocker.target_pos.y = towers[r].pos.x, towers[r].pos.y
				queue_insert(store, blocker)
			else
				this._done = true
			end
			while not this._done do
				coroutine.yield()
			end
			U.y_wait(store, this.global_cooldown)
			block_tower_ts = store.tick_ts
			this.in_use = false
		end
		if this._lower_boss and this.lower_trigger and #this.eggs_queue == 0 and not this.in_use then
			this.in_use = true
			local boss = find_all_t(store, this.boss_t)[1]
			local descent = E:create_entity(this.boss_descent_decal)
			local dest = P:node_pos(this.lower_path_id, 1, this.lower_node_id)
			descent.pos.x = dest.x
			descent.target_pos = V.vclone(dest)
			queue_insert(store, descent)
			boss.lower_path_id = this.lower_path_id
			boss.lower_node_id = this.lower_node_id
			this.in_use = false
			this.lower_trigger = false
		end
		coroutine.yield()
	end
end
local function controller_stage_211_spider_block_and_spawn_on_event(this, store, action, nest_id, amount, to_spawn)
	if not this._spawn_eggs then
		log.info("Received event spider_spawn_eggs, but disabled. Ignore.")
		return
	end
	if this.lower_trigger then
		log.info("Received event spider_spawn_eggs, but Sarelgaz wants to come down. Ignore.")
		return
	end
	local sanitized_to_spawn = this.default_spawn
	if to_spawn then
		for i, v in ipairs(this.allowed_spawns) do
			if to_spawn == v then
				sanitized_to_spawn = to_spawn
			end
		end
	end
	this.to_spawn = sanitized_to_spawn
	if not this.eggs_queue then
		this.eggs_queue = {}
	end
	table.insert(this.eggs_queue, {
		nest_id = tonumber(nest_id),
		amount = tonumber(amount),
		to_spawn = sanitized_to_spawn
	})
	log.info("Received event spider_spawn_eggs, added to queue: nest %s, amount %s, spawn %s", this.eggs_queue[1].nest_id, this.eggs_queue[1].amount, this.eggs_queue[1].to_spawn)
end
local function controller_stage_211_loss_update(this, store)
	local tents_f = find_all_t(store, this.camp_tents_f_t)[1]
	local tents_b = find_all_t(store, this.camp_tents_b_t)[1]
	while true do
		if this.defeat_cinematic and this.normal_defeat then
			local camp = find_all_t(store, this.camp_prefix_t, true)[1]
			camp.destruction_sequence = true
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			signal.emit("pan-zoom-camera", 1.5, {
				x = camp.pos.x,
				y = camp.pos.y + 70
			}, OVm(1, 1.5))
			U.y_wait(store, 1)
			S:queue(this.sound_events.destroyed_start)
			local anim = camp.tower.level == 3 and "defeat2" or "defeat1"
			U.animation_start(camp, anim, nil, store.tick_ts, nil, 1)
			U.y_wait(store, fts(22))
			S:stop(this.sound_events.destroyed_start)
			S:queue(this.sound_events.destroyed_end)
			camp.render.sprites[2].hidden = true
			camp.render.sprites[3].hidden = true
			U.y_wait(store, fts(58))
			store.ephemeral.defeat_cinematic = nil
			signal.emit("end-cinematic")
			store.game_outcome = nil
			store.lives = 0
			queue_remove(store, this)
			return
		end
		if this.defeat_cinematic and this.sarelgaz_defeat then
			local camp = find_all_t(store, this.camp_prefix_t, true)[1]
			local boss = find_all_t(store, this.boss_t)[1]
			camp.destruction_sequence = true
			signal.emit("boss_fight_end")
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			store.game_outcome = {}
			store.lives = 0
			local af = false
			if camp.pos.x - boss.pos.x < 0 then
				af = true
			end
			U.animation_start(boss, "idle", af, store.tick_ts, false, 1)
			U.unblock_all(store, boss)
			U.bans_add(boss.vis, F_ALL)
			boss.ui.can_click = false
			boss.ui.can_hover = false
			boss.health_bar.hidden = true
			signal.emit("pan-zoom-camera", 1.5, {
				x = camp.pos.x,
				y = camp.pos.y + 70
			}, OVm(1, 1.5))
			U.y_wait(store, 1)
			for i = 1, this.boss_kill_tent_strikes do
				U.animation_start(boss, "attack", af, store.tick_ts, false, 1)
				U.y_wait(store, boss.melee.attacks[1].hit_time)
				S:queue(this.sound_events.hit_camp)
				if i == this.boss_kill_tent_strikes then
					U.animation_start(tents_f, "hit3", nil, store.tick_ts, nil, 1)
					U.animation_start(tents_b, "hit3", nil, store.tick_ts, nil, 1)
				else
					U.animation_start(tents_f, "hit" .. camp.damage_state, nil, store.tick_ts, nil, 1)
					U.animation_start(tents_b, "hit" .. (camp.damage_state == 1 and "" or camp.damage_state), nil, store.tick_ts, nil, 1)
				end
				camp.damage_state = km.clamp(1, 3, camp.damage_state + 1)
				U.y_wait(store, 0.3)
			end
			camp.damage_state = 3
			for i, v in ipairs(this.rappels_ending) do
				local sp = E:create_entity(this.spawner_t)
				sp.pos.x, sp.pos.y = v[2].x, v[2].y
				sp.spawner_id = 4 + i
				queue_insert(store, sp)
			end
			local spawning = find_all_t(store, "controller_stage_211_spider_rappel_spawning")[1]
			coroutine.yield()
			spawning.cache_invalidated = true
			coroutine.yield()
			S:queue(this.sound_events.destroyed_end)
			local anim = camp.tower.level == 3 and "defeat2" or "defeat1"
			U.animation_start(camp, anim, nil, store.tick_ts, nil, 1)
			U.y_wait(store, fts(22))
			camp.render.sprites[2].hidden = true
			camp.render.sprites[3].hidden = true
			for i, v in ipairs(this.rappels_ending) do
				scripts.controller_remote_balance_rappel_spawning.on_event(spawning, store, "spider_rappel", 4 + i, v[1], math.random(1, 3))
				U.y_wait(store, 0.15)
			end
			U.animation_start(boss, "jump", nil, store.tick_ts, nil, 1)
			U.y_wait(store, boss.wait_for_ascend_decal)
			local ascent = E:create_entity(boss.ascend_decal)
			ascent.pos.x, ascent.pos.y = boss.pos.x, boss.pos.y
			ascent.render.sprites[1].ts = store.tick_ts
			queue_insert(store, ascent)
			U.y_wait(store, 1.5)
			store.ephemeral.defeat_cinematic = nil
			signal.emit("end-cinematic")
			store.game_outcome = nil
			store.lives = 0
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end
local function controller_stage_211_camp_barrack_insert(this, store)
	this.barrack.rally_pos = this.default_rally_pos
	return true
end
local function controller_stage_211_camp_barrack_update(this, store)
	local b = this.barrack
	while true do
		for i = 1, b.max_soldiers do
			local s = b.soldiers[i]
			if not s or s.health.dead and not store.entities[s.id] then
				s = E:create_entity(b.soldier_type)
				s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, math.pi / 4)
				s.nav_rally.new = true
				queue_insert(store, s)
				b.soldiers[i] = s
			end
		end
		coroutine.yield()
	end
end
local function controller_stage_211_camp_barrack_e_insert(this, store)
	local r = E:create_entity("editor_rally_point")
	queue_insert(store, r)
	r.tower_id = this.id
	this.editor.rally_point_id = r.id
	if this.default_rally_pos and this.default_rally_pos.x ~= 0 and this.default_rally_pos.y ~= 0 then
		r.pos = this.default_rally_pos
	else
		r.pos = V.v(this.pos.x + 50, this.pos.y + 50)
		this.default_rally_pos = r.pos
	end
	if this.barrack then
		this.barrack.rally_pos = r.pos
	end
	return true
end
local function controller_stage_211_camp_barrack_e_remove(this, store)
	local r = store.entities[this.editor.rally_point_id]
	if r then
		queue_remove(store, r)
	end
	return true
end
local function controller_stage_211_boss_lower_on_event(this, store, action, path_id, node_id)
	local boss = find_all_t(store, this.boss_t)[1]
	if not boss.rose then
		return
	end
	local controller = find_all_t(store, this.controller_t)[1]
	controller.lower_trigger = true
	controller.lower_path_id = tonumber(path_id)
	controller.lower_node_id = tonumber(node_id)
	log.info("Received event boss_lower, data: %s, %s", controller.lower_path_id, controller.lower_node_id)
end
local function controller_stage_211_spider_eyes_decos_update(this, store, script)
	local function spawn_eyes(t, p)
		local eyes = E:create_entity(t)
		eyes.pos = V.vclone(p)
		eyes.render.sprites[1].ts = store.tick_ts
		queue_insert(store, eyes)
	end
	local function y_run_sequence(sequence)
		if not sequence then
			return
		end
		while #sequence > 0 do
			local s_roll = math.random(1, #sequence)
			local si = sequence[s_roll]
			local side = si[1]
			local swarms = si[2]
			local severals = si[3]
			local singles = si[4]
			local positions = this.swarm_positions[side]
			local roll = math.random(1, swarms + severals + singles)
			local e
			if roll <= swarms then
				e = this.swarm_t
				si[2] = si[2] - 1
			elseif swarms < roll and roll <= swarms + severals then
				e = this.several_t
				si[3] = si[3] - 1
			elseif roll > swarms + severals and roll <= swarms + severals + singles then
				e = this.single_t
				si[4] = si[4] - 1
			end
			local p = positions[math.random(1, #positions)]
			spawn_eyes(e, p)
			U.y_wait(store, math.random(this.wait_min, this.wait_max))
			if si[2] + si[3] + si[4] == 0 then
				table.remove(sequence, s_roll)
			end
		end
	end
	this.swarm_positions = {}
	for k, v in pairs(this.swarm_boxes) do
		this.swarm_positions[k] = generate_blue_noise_cluster(20, 15, random_point_in_rectangle, v[1].x, v[1].y, v[2].x, v[2].y)
	end
	local in_sequence = false
	local last_wave = store.wave_group_number
	local ts = store.tick_ts
	local cd = math.random(this.pre_battle_periodic_eyes_min, this.pre_battle_periodic_eyes_max)
	local phase = 1
	while true do
		if phase == 1 and store.wave_group_number >= this.waves_phases[1] then
			phase = 2
			this.swarm_positions = {}
			for k, v in pairs(this.swarm_boxes_phase2) do
				this.swarm_positions[k] = generate_blue_noise_cluster(20, 15, random_point_in_rectangle, v[1].x, v[1].y, v[2].x, v[2].y)
			end
		end
		if store.wave_group_number ~= last_wave and not in_sequence then
			in_sequence = true
			local sequence = this.spawn_sequence[store.wave_group_number]
			y_run_sequence(sequence)
			in_sequence = false
		end
		if store.wave_group_number == 0 and cd < store.tick_ts - ts then
			local sides = {"left", "bottom", "right", "top"}
			local side = sides[math.random(#sides)]
			local fake_sequence = {{side, 0, 0, math.random(1, 3)}}
			y_run_sequence(fake_sequence)
			ts = store.tick_ts
			cd = math.random(this.pre_battle_periodic_eyes_min, this.pre_battle_periodic_eyes_max)
		end
		if cd < store.tick_ts - ts and store.wave_group_number > 0 and store.wave_group_number < this.waves_phases[1] then
			local side = this.periodic_sequence[store.wave_group_number][math.random(#this.periodic_sequence[store.wave_group_number])]
			local fake_sequence = {{side, 0, 0, math.random(1, 3)}}
			y_run_sequence(fake_sequence)
			ts = store.tick_ts
			cd = math.random(this.periodic_eyes_min, this.periodic_eyes_max)
		end
		last_wave = store.wave_group_number
		coroutine.yield()
	end
end
local function bullet_stage_211_camp_fire_arrow_insert(this, store)
	local ok = scripts.arrow5_fixed_height.insert(this, store)
	if ok then
		this.bullet.target_id = nil
	end
	return ok
end
local tt = E:register_t_hot("tower_holder_terrain_2_3_ease_in", "tower_holder", true)
AC(tt, "tween")
tt.tower.terrain_style = TERRAIN_STYLE_KR6_TERRAIN_2_3
tt.render.sprites[1].name = "kr6_build_terrain_0008"
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.run_once = false
tt = E:register_t_hot("tower_holder_blocked_terrain_2_3_fog_of_war", "tower_holder_blocked", true)
tt.tower.type = "blocked_holder"
tt.tower.terrain_style = TERRAIN_STYLE_KR6_TERRAIN_2_3
tt.tower.can_hover = false
tt.tower_holder.unblock_price = 1e+99
tt.render.sprites[1].name = "kr6_build_terrain_0008"
tt.render.sprites[1].hidden = true
tt.ui.can_click = false
tt.ui.click_rect = r(0, 0, 0, 0)
tt.ui.can_hover = false
tt = E:register_t_hot("decal_stage_211_mask_1", "decal", true)
tt.render.sprites[1].name = "Stage11_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset = -20
tt = E:register_t_hot("decal_stage_211_mask_2", "decal", true)
tt.render.sprites[1].name = "Stage11_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(0, -92)
tt.render.sprites[1].sort_y_offset = 0
tt = E:register_t_hot("decal_stage_211_mask_3", "decal", true)
tt.render.sprites[1].name = "Stage11_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset = -102
tt = E:register_t_hot("decal_stage_211_mask_4", "decal", true)
tt.render.sprites[1].name = "Stage11_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].offset = v(0, -316)
tt = E:register_t_hot("decal_stage_211_mask_5", "decal", true)
tt.render.sprites[1].name = "Stage11_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset = -102
tt = E:register_t_hot("decal_stage_211_mask_6", "decal", true)
tt.render.sprites[1].name = "Stage11_light"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].sort_y_offset = -102
tt = E:register_t_hot("decal_stage_211_shadows_lvl1", "decal", true)
tt.render.sprites[1].name = "Stage11_shad1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(200, 82)
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.render.sprites[1].scale = vv(2.8125)
tt = E:register_t_hot("decal_stage_211_shadows_lvl2", "decal", true)
tt.render.sprites[1].name = "Stage11_shad2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].offset = v(200, 82)
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.render.sprites[1].scale = vv(2.8125)
tt = E:register_t_hot("decal_stage_211_camp_tents_front", "decal", true)
tt.render.sprites[1].prefix = "CampDef"
tt.render.sprites[1].name = "camp1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].offset = v(200, 172)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_211_camp_tents_back", "decal", true)
tt.render.sprites[1].prefix = "CampBackDef"
tt.render.sprites[1].name = "camp1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = 1
tt.render.sprites[1].offset = v(200, 82)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_211_camp_walls_front", "decal", true)
tt.render.sprites[1].prefix = "CampLevelsDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[1].offset = v(-700.9, 427.65)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_211_camp_walls_back_p1", "decal", true)
tt.render.sprites[1].prefix = "CampLevelsBackDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = -308
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_211_camp_walls_back_p2", "decal", true)
tt.render.sprites[1].prefix = "CampLevelsBack2Def"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = -359
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t_hot("decal_stage_211_torch", "decal_scripted", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "TorchDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.torch_light_t = "decal_stage_211_torch_light"
tt.light_offset = v(0, 5)
tt.main_script.insert = decal_stage_211_torch_insert
tt.main_script.update = decal_stage_211_torch_update
tt.editor.props = {{"camp_level", PT_NUMBER}}
tt = E:register_t_hot("decal_stage_211_torch_light", "decal", true)
tt.render.sprites[1].prefix = "TorchLightDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt = E:register_t_hot("decal_stage_211_spider_eyes_medium", "decal", true)
AC(tt, "main_script", "tween")
tt.main_script.update = decal_stage_211_spider_eyes_update
tt.render.sprites[1].prefix = "spider_eyes"
tt.render.sprites[1].name = "right"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset = v(0, -15)
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {"right_idle", "up_idle", "down_idle"}
tt.render.sprites[1].angles.walk = {"right", "up", "down"}
tt.tween.props[1].keys = {{0, 0}, {1.5, 255}}
tt.tween.props[1].loop = false
tt.tween.props[1].name = "alpha"
tt.tween.disabled = false
tt.tween.remove = false
tt.insert_keys = {{0, 0}, {1.5, 255}}
tt.remove_keys = {{0, 255}, {0.7, 0}}
tt.target_id = nil
tt.shadow_t = "aura_stage_211_shadow"
tt = E:register_t_hot("decal_stage_211_spider_eyes_small", "decal_stage_211_spider_eyes_medium", true)
tt.render.sprites[1].scale = vv(0.7)
tt = E:register_t_hot("decal_stage_211_spider_eyes_big", "decal_stage_211_spider_eyes_medium", true)
tt.render.sprites[1].scale = vv(1.3)
tt = E:register_t_hot("decal_stage_211_spider_eyes_1", "decal_timed", true)
tt.render.sprites[1].prefix = "spiderdeco1Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt = E:register_t_hot("decal_stage_211_spider_eyes_2", "decal_timed", true)
tt.render.sprites[1].prefix = "spiderdeco2Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt = E:register_t_hot("decal_stage_211_spider_eyes_3", "decal_timed", true)
tt.render.sprites[1].prefix = "spiderdeco3Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt = E:register_t_hot("decal_stage_211_spider_eyes_4", "decal_timed", true)
tt.render.sprites[1].prefix = "spiderdeco4Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt = E:register_t_hot("decal_stage_211_giant_spider_rappel_spawn", "decal", true)
AC(tt, "main_script", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].prefix = "giant_spider_creep"
tt.render.sprites[1].name = "drop_1"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].draw_order = 3
tt.target_pos = vv(0)
tt.offset_drop = 45
tt.trigger_land_distance = 15
tt.spawn_t = "enemy_giant_spider_dropped"
tt.string_t = "decal_stage_211_spider_rappel_string"
tt.shadow_t = "decal_stage_211_spider_rappel_shadow"
tt.offset_extra = 0
tt.descend_rappel_ease = "quad-out"
tt.short_rappel_ease = "quad-out"
tt.descend_rappel_duration = 1
tt.short_rappel_duration = fts(5)
tt.wait_detach = fts(6)
tt.end_rappel_anim = "drop_1_end"
tt.short_rappel_anim = "drop_2"
tt.short_rappel_shadow_anim = "drop"
tt.main_script.update = decal_stage_211_giant_spider_rappel_spawn_update
tt.sound_events.rappel_down = "EnemyGiantSpiderClimbDown"
tt = E:register_t_hot("decal_stage_211_spider_rappel_shadow", "decal", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].prefix = "giant_spider_shadow"
tt.render.sprites[1].name = "idle"
tt = E:register_t_hot("decal_stage_211_sarelgaz_rappel_shadow", "decal", true)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_stage_11_shadowDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].sort_y_offset = 1
tt = E:register_t_hot("decal_stage_211_spider_rappel_string", "decal_rappel_string", true)
tt.dissolution_duration = 1
tt.dissolution_ease = "e_o_cubic"
tt.dissolution_movement_duration = 1
tt.dissolution_movement_ease = "linear"
tt.string_prefix = "giant_spider_web"
tt.string_start_anim = "idle"
tt.string_parts = 18
tt.string_offset = 2
tt = E:register_t_hot("decal_stage_211_sarelgaz_rappel_string", "decal_rappel_string", true)
tt.dissolution_duration = 1
tt.dissolution_ease = "e_o_cubic"
tt.dissolution_movement_duration = 1
tt.dissolution_movement_ease = "linear"
tt.string_prefix = "sarelgaz_spawns_web"
tt.string_start_anim = "idle"
tt.string_parts = 86
tt.string_offset = 2
tt = E:register_t_hot("decal_stage_211_sarelgaz_tower_block", "decal", true)
AC(tt, "main_script", "ui", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_stage_11Def"
tt.render.sprites[1].name = "descend"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.target_pos = vv(0)
tt.offset_extra = -10
tt.offset_drop = 110
tt.trigger_land_distance = 15
tt.string_t = "decal_stage_211_sarelgaz_rappel_string"
tt.shadow_t = "decal_stage_211_sarelgaz_rappel_shadow"
tt.tap_tutorial = "decal_tapping_hand"
tt.tap_tutorial_offset = v(10, -10)
tt.descend_rappel_ease = "quad-in"
tt.descend_rappel_duration = 2
tt.ascend_rappel_ease = "quad-out"
tt.ascend_rappel_duration = 1
tt.time_to_block = 3
tt.taps_to_remove = 5
tt.start_web_anim = "web_start"
tt.loop_web_anim = "web_loop"
tt.tapped_anim = "tap"
tt.ascend_anim = "ascend"
tt.wait_after_trap = 1
tt.block_mod = "mod_stage_211_tower_web"
tt.main_script.update = decal_stage_211_sarelgaz_tower_block_update
tt.sound_events.rappel_down = "Stage11SarelgazClimbDown"
tt.sound_events.rappel_up = "Stage11SarelgazClimbUp"
tt.sound_events.webbing = "Stage11SarelgazWebbing"
tt.sound_events.interrupt = "Stage11SarelgazInterrupt"
tt.ui.click_rect = r(-45, -60, 90, 120)
tt.ui.z = 1000
tt = E:register_t_hot("decal_stage_211_sarelgaz_eggs_spawn", "decal", true)
AC(tt, "main_script", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_stage_11Def"
tt.render.sprites[1].name = "descend_egg"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.target_pos = vv(0)
tt.offset_extra = -10
tt.offset_drop = 70
tt.trigger_land_distance = 15
tt.string_t = "decal_stage_211_sarelgaz_rappel_string"
tt.shadow_t = "decal_stage_211_sarelgaz_rappel_shadow"
tt.descend_rappel_ease = "quad-in"
tt.descend_rappel_duration = 2
tt.ascend_rappel_ease = "quad-out"
tt.ascend_rappel_duration = 2
tt.egg_prefix = "decal_stage_211_sarelgaz_egg"
tt.place_egg_anim = "egg"
tt.egg_spawn_time = fts(28)
tt.ascend_anim = "ascend_egg"
tt.main_script.update = decal_stage_211_sarelgaz_eggs_spawn_update
tt.sound_events.rappel_down = "Stage11SarelgazClimbDown"
tt.sound_events.rappel_up = "Stage11SarelgazClimbUp"
tt.sound_events.egg = "EnemySpiderMatriarchLayEgg"
tt = E:register_t_hot("decal_stage_211_sarelgaz_descent", "decal", true)
AC(tt, "main_script", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_stage_11Def"
tt.render.sprites[1].name = "descend"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.target_pos = vv(0)
tt.offset_extra = -10
tt.offset_drop = 110
tt.trigger_land_distance = 15
tt.boss_t = "enemy_boss_stage_11"
tt.controller_t = "controller_stage_211_spider_block_and_spawn"
tt.string_t = "decal_stage_211_sarelgaz_rappel_string"
tt.shadow_t = "decal_stage_211_sarelgaz_rappel_shadow"
tt.descend_rappel_ease = "quad-in"
tt.descend_rappel_duration = 2
tt.main_script.update = decal_stage_211_sarelgaz_descent_update
tt.sound_events.rappel_down = "Stage11SarelgazClimbDown"
tt = E:register_t_hot("decal_stage_211_sarelgaz_ascent", "decal", true)
AC(tt, "main_script", "sound_events")
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_stage_11Def"
tt.render.sprites[1].name = "jumping"
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.target_pos = vv(0)
tt.offset_extra = -10
tt.offset_drop = 110
tt.trigger_land_distance = 15
tt.shadow_t = "decal_stage_211_sarelgaz_rappel_shadow"
tt.controller_t = "controller_stage_211_spider_block_and_spawn"
tt.ascend_rappel_ease = "quad-in"
tt.ascend_rappel_duration = 0.33
tt.main_script.update = decal_stage_211_sarelgaz_ascent_update
tt.sound_events.rappel_up = "Stage11SarelgazClimbUp"
tt = E:register_t_hot("decal_stage_211_sarelgaz_egg_spiderling_kr6", "decal_spider_egg", true)
tt.spawn_e = "enemy_spiderling_kr6"
tt.time_to_spawn = 5
tt = E:register_t_hot("decal_stage_211_sarelgaz_egg_giant_spider", "decal_spider_egg", true)
tt.spawn_e = "enemy_giant_spider"
tt.time_to_spawn = 5
tt = E:register_t_hot("decal_stage_211_sarelgaz_egg_spider_matriarch", "decal_spider_egg", true)
tt.spawn_e = "enemy_spider_matriarch"
tt.time_to_spawn = 5
tt = E:register_t_hot("decal_stage_211_sarelgaz_egg_son_of_sarelgaz", "decal_spider_egg", true)
tt.spawn_e = "enemy_son_of_sarelgaz"
tt.time_to_spawn = 5
tt = E:register_t_hot("aura_stage_211_shadow", "aura", true)
tt.aura.radius = 270
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = 0
tt.aura.cycle_time = 0.4
tt.aura.duration = 1e+99
tt.radius_levels = {290, 500, 600}
tt.main_script.update = aura_stage_211_shadow_update
tt = E:register_t_hot("aura_stage_211_camp_fire_arrow_fire", "aura", true)
AC(tt, "render")
tt.aura.radius = 50
tt.aura.duration = fts(10)
tt.eggs_prefix = "decal_stage_211_sarelgaz_egg"
tt.main_script.update = aura_stage_211_camp_fire_arrow_fire_update
tt.render.sprites[1].prefix = "Archer_Arrow_Fire"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].loop = false
tt = E:register_t_hot("aura_stage_211_spider_webs_speed", "aura", true)
tt.aura.mod = "mod_stage_211_spider_webs_speed"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = 0
tt.aura.cycle_time = 0.4
tt.aura.duration = 1e+99
tt.aura.allowed_templates = {"enemy_spiderling_kr6", "enemy_giant_spider", "enemy_spider_matriarch", "enemy_leaper_spider", "enemy_son_of_sarelgaz", "enemy_boss_stage_11"}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t_hot("aura_stage_211_spider_webs_slow", "aura", true)
tt.aura.mod = "mod_stage_211_spider_webs_slow"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.aura.cycle_time = 0.4
tt.aura.duration = 1e+99
tt.aura.excluded_templates = {"hero_zefira"}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t_hot("mod_stage_211_tower_web", "mod_tower_stun", true)
AC(tt, "render")
tt.main_script.update = mod_stage_211_tower_web_update
tt.modifier.duration = 6
tt.render.sprites[1].prefix = "sarelgaz_spawns_webbed_tower_fx"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "Stage11SarelgazCocoonTower"
tt.idle_anim = "idle"
tt.end_anim = "end"
tt = E:register_t_hot("mod_stage_211_spider_webs_speed", "mod_slow", true)
tt.slow.factor = 1.25
tt.modifier.duration = 0.25
tt = E:register_t_hot("mod_stage_211_spider_webs_slow", "mod_slow", true)
tt.slow.factor = 0.7
tt.modifier.duration = 0.25
tt = E:register_t_hot("ps_stage_211_fire_arrow", "particle_system", true)
tt.particle_system.name = "Archer_Arrow_Fire_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(27), fts(27)}
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.emit_spread = math.pi / 2
tt.particle_system.emission_rate = 50
tt.particle_system.track_direction = true
tt = E:register_t_hot("fx_stage_211_fire_arrow_hit", "fx", true)
tt.render.sprites[1].prefix = "Archer_Arrow_Fire"
tt.render.sprites[1].name = "hit"
tt.render.sprites[1].animated = true
tt = E:register_t_hot("fx_stage_211_spider_camp_hit_small", "fx", true)
tt.render.sprites[1].prefix = "CampSpiderTouchDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(0.6)
tt = E:register_t_hot("fx_stage_211_spider_camp_hit_medium", "fx", true)
tt.render.sprites[1].prefix = "CampSpiderTouchDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(0.8)
tt = E:register_t_hot("fx_stage_211_spider_camp_hit_big", "fx", true)
tt.render.sprites[1].prefix = "CampSpiderTouchDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t_hot("bullet_stage_211_camp_fire_arrow", "arrow5_fixed_height", true)
tt.main_script.insert = bullet_stage_211_camp_fire_arrow_insert
tt.bullet.damage_min = 1
tt.bullet.damage_max = 1
tt.bullet.damage_radius = 0
tt.bullet.fixed_height = 80
tt.bullet.g = -1000
tt.bullet.hit_fx = "fx_stage_211_fire_arrow_hit"
tt.bullet.payload = "aura_stage_211_camp_fire_arrow_fire"
tt.bullet.particles_name = "ps_stage_211_fire_arrow"
tt.bullet.predict_target_pos = false
tt.render.sprites[1].prefix = "Archer_Arrow_Fire"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt = E:register_t_hot("bullet_stage_211_camp_arrow", "arrow5_fixed_height", true)
tt.bullet.hit_distance = 32
tt.bullet.damage_min = 10
tt.bullet.damage_max = 16
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.fixed_height = 50
tt.bullet.g = -1000
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = nil
tt.bullet.hide_radius = 0
tt.render.sprites[1].prefix = "Archer_Arrow"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "TowerArcherGarrisonBasicAttack"
tt = E:register_t_hot("soldier_stage_211_camp", "soldier_militia", true)
AC(tt, "nav_grid")
tt.info.portrait = "kr6_info_portraits_soldiers_0016"
tt.info.random_name_count = 8
tt.info.random_name_format = "SOLDIER_RANDOM_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = scripts.soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.render.sprites[1].prefix = "stage11_soldier"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles.walk = {"walk"}
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 13)
tt.health.hp_max = 100
tt.health.armor = 0
tt.health_bar.offset = v(0, 30)
tt.health.dead_lifetime = 30
tt.regen.health = 100
tt.nav_grid = nil
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.motion.max_speed = 40
tt.melee.range = 65
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].hit_time = fts(10)
tt.soldier.melee_slot_offset = v(4, 0)
tt.ui.click_rect = r(-13, -2, 26, 25)
tt = E:register_t_hot("tower_stage_211_camp_lvl1", "tower", true)
AC(tt, "user_selection", "events")
tt.tower.type = "stage_11_camp"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.menu_offset = v(0, 0)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.disable_spend_highlight = true
tt.tower.can_hover = false
tt.render.sprites[1].prefix = "MainTentDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].offset = v(200, 128)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "Archer"
tt.render.sprites[2].idle = "idle"
tt.render.sprites[2].shoot = "attack"
tt.render.sprites[2].offset = v(22.9, 85)
tt.render.sprites[2].z = Z_OBJECTS_COVERS
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "Archer"
tt.render.sprites[3].idle = "idle"
tt.render.sprites[3].shoot = "attack"
tt.render.sprites[3].offset = v(-29.8, 85.8)
tt.render.sprites[3].flip_x = true
tt.render.sprites[3].z = Z_OBJECTS_COVERS
tt.render.sprites[3].hidden = true
tt.info.portrait = "kr6_info_portraits_towers_0011"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.insert = tower_stage_211_camp_insert
tt.main_script.update = tower_stage_211_camp_update
tt.main_script.remove = tower_stage_211_camp_remove
tt.barracks_t = "controller_stage_211_camp_barrack"
tt.barracks_soldiers = {1, 2, 2}
tt.soldiers_dead_lifetime = {30, 30, 26}
tt.fow_holders_t = "tower_holder_blocked_terrain_2_3_fog_of_war"
tt.holder_on_fow_reveal = "tower_holder_terrain_2_3_ease_in"
tt.holder_on_fow_instant = "tower_holder_terrain_2_3"
tt.walls_t_prefix = "decal_stage_211_camp_walls"
tt.anim_level_up = "lvlup"
tt.shadows_controller = "controller_stage_211_shadows"
tt.shadows_aura = "aura_stage_211_shadow"
tt.shadows_offset = v(0, 40)
tt.camp_damage_fx = "fx_stage_211_spider_camp_hit"
tt.camp_front = "decal_stage_211_camp_tents_front"
tt.camp_back = "decal_stage_211_camp_tents_back"
tt.flip_time = 10
tt.lives_thresholds = {14, 7}
tt.target_radius = {7 * love.graphics.getHeight(), 9 * love.graphics.getHeight(), 12 * love.graphics.getHeight()}
tt.ui.click_rect = r(-80, -40, 150, 150)
tt.ui.hover_sprite_scale = vv(1.4)
tt.ui.hover_sprite_offset = v(0, -8)
tt.sound_events.hit_camp = "Stage11EncampmentDamaged"
tt.events.list[1].name = SYSTEM_EVENT_ENEMY_REACHED_GOAL
tt.events.list[1].on_event = tower_stage_211_camp_enemy_reached_goal_fn
tt = E:register_t_hot("tower_stage_211_camp_lvl2", "tower_stage_211_camp_lvl1", true)
tt.tower.price = 0
tt.tower.level = 2
tt.sound_events.level_up = "Stage11EncampmentLevelUp1"
tt.sound_events.level_up_taunt = "Stage11EncampmentLevelUp1Taunt"
tt = E:register_t_hot("tower_stage_211_camp_lvl3", "tower_stage_211_camp_lvl1", true)
AC(tt, "user_selection", "attacks")
tt.tower.price = 0
tt.tower.level = 3
tt.nest_t = "tower_stage_211_spider_eggs_nest"
tt.attacks.range = 300
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "attack"
tt.attacks.list[1].shoot_time = fts(14)
tt.attacks.list[1].sound_shoot = "Stage11FireArrow"
tt.attacks.list[1].bullet = "bullet_stage_211_camp_fire_arrow"
tt.attacks.list[1].bullet_start_offset = v(8, 16)
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].sound = "Stage11EncampmentAttackTaunt"
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].bullet = "bullet_stage_211_camp_arrow"
tt.attacks.list[2].cooldown = 1
tt.attacks.list[2].shoot_time = fts(14)
tt.attacks.list[2].bullet_start_offset = v(8, 16)
tt.attacks.list[2].pred_time = nil
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[2].vis_bans = 0
tt.attacks.list[2].basic_attack = true
tt.sound_events.level_up = "Stage11EncampmentLevelUp2"
tt.sound_events.level_up_taunt = "Stage11EncampmentLevelUp2Taunt"
tt = E:register_t_hot("tower_stage_211_spider_eggs_nest", "tower", true)
AC(tt, "pos", "editor", "user_selection")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "build_terrain_%04i"
tt.render.sprites[1].hidden = true
tt.editor.props = {{"nest_id", PT_NUMBER}, {"path_id", PT_NUMBER}}
tt.tower.type = "stage_11_spider_eggs_nest"
tt.tower.menu_offset = v(0, 0)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.max_level = 1
tt.info.portrait = "kr6_info_portraits_towers_0010"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.update = tower_stage_211_spider_eggs_nest_update
tt.tower_action = {}
tt.tower_action.cost = 50
tt.camp_t = "tower_stage_211_camp_lvl3"
tt.ui.click_rect = r(-25, -25, 50, 50)
tt.ui.hover_sprite_scale = vv(1)
tt.ui.hover_sprite_offset = v(0, -8)
tt.ui.has_nav_mesh = true
tt = E:register_t_hot("controller_stage_211_camp_barrack", nil, true)
AC(tt, "main_script", "pos", "barrack", "editor", "editor_script")
tt.barrack.soldier_type = "soldier_stage_211_camp"
tt.barrack.rally_range = 200
tt.barrack.respawn_offset = v(0, 9)
tt.barrack.max_soldiers = nil
tt.default_rally_pos = v(0, 0)
tt.main_script.insert = controller_stage_211_camp_barrack_insert
tt.main_script.update = controller_stage_211_camp_barrack_update
tt.editor.props = {{"default_rally_pos", PT_COORDS}}
tt.editor_script.insert = controller_stage_211_camp_barrack_e_insert
tt.editor_script.remove = controller_stage_211_camp_barrack_e_remove
tt = E:register_t_hot("controller_stage_211_shadows", nil, true)
AC(tt, "main_script", "pos")
tt.shadow_decal_prefix = "decal_stage_211_shadows"
tt.torch_t = "decal_stage_211_torch"
tt.ease_durations = 0.4
tt.main_script.update = controller_stage_211_shadows_update
tt = E:register_t_hot("controller_stage_211_spider_block_and_spawn", nil, true)
AC(tt, "main_script", "events")
tt.main_script.update = controller_stage_211_spider_block_and_spawn_update
tt.spawner_t = "tower_stage_211_spider_eggs_nest"
tt.spider_block_t = "decal_stage_211_sarelgaz_tower_block"
tt.spider_spawn_t = "decal_stage_211_sarelgaz_eggs_spawn"
tt.boss_t = "enemy_boss_stage_11"
tt.boss_descent_decal = "decal_stage_211_sarelgaz_descent"
tt.block_towers_interval_min = 15
tt.block_towers_interval_max = 30
tt.global_cooldown = 1
tt.allowed_spawns = {"spiderling_kr6", "giant_spider", "spider_matriarch", "son_of_sarelgaz"}
tt.active_waves = {3, 5, 6, 7, 9, 10, 12, 13, 15}
tt.default_spawn = "spiderling_kr6"
tt.events.list[1].name = "spider_spawn_eggs"
tt.events.list[1].on_event = controller_stage_211_spider_block_and_spawn_on_event
tt = E:register_t_hot("controller_stage_211_spider_rappel_spawner", "controller_remote_balance_rappel_spawner", true)
tt.spawn_decal = "decal_stage_211_giant_spider_rappel_spawn"
tt.node_random = 10
tt = E:register_t_hot("controller_stage_211_spider_rappel_spawning", "controller_remote_balance_rappel_spawning", true)
tt.spawner_t = "controller_stage_211_spider_rappel_spawner"
tt.events.list[1].name = "spider_rappel"
tt = E:register_t_hot("controller_stage_211_boss_lower", nil, true)
AC(tt, "events")
tt.boss_t = "enemy_boss_stage_11"
tt.boss_descent_decal = "decal_stage_211_sarelgaz_descent"
tt.controller_t = "controller_stage_211_spider_block_and_spawn"
tt.events.list[1].name = "boss_lower"
tt.events.list[1].on_event = controller_stage_211_boss_lower_on_event
tt = E:register_t_hot("controller_stage_211_loss", nil, true)
AC(tt, "main_script", "sound_events")
tt.camp_prefix_t = "tower_stage_211_camp"
tt.boss_t = "enemy_boss_stage_11"
tt.camp_tents_f_t = "decal_stage_211_camp_tents_front"
tt.camp_tents_b_t = "decal_stage_211_camp_tents_back"
tt.spawner_t = "controller_stage_211_spider_rappel_spawner"
tt.boss_kill_tent_strikes = 3
tt.rappels_ending = {
	{1, v(262, 373)},
	{6, v(563.9, 567.7)},
	{4, v(798.1, 377.7)},
	{1, v(77, 428.5)},
	{8, v(428.6, 204.6)},
	{2, v(306.2, 511.5)},
	{6, v(461.6, 580)},
	{3, v(720.1, 510)},
	{8, v(310, 227.7)},
	{4, v(655.4, 217.7)},
	{5, v(190.8, 526.2)}
}
tt.main_script.update = controller_stage_211_loss_update
tt.sound_events.destroyed_start = "Stage11EncampmentDestroyedInit"
tt.sound_events.destroyed_end = "Stage11EncampmentDestroyedEnd"
tt.sound_events.hit_camp = "Stage11EncampmentDamaged"
tt = E:register_t_hot("controller_stage_211_spider_eyes_decos", nil, true)
AC(tt, "main_script")
tt.swarm_t = "decal_stage_211_spider_eyes_2"
tt.several_t = "decal_stage_211_spider_eyes_3"
tt.single_t = "decal_stage_211_spider_eyes_1"
tt.main_script.update = controller_stage_211_spider_eyes_decos_update
tt.periodic_sequence = {{"left", "bottom", "right"}, {"left", "top", "right"}, {"top", "bottom"}, {"right", "bottom", "top"}}
tt.spawn_sequence = {{{"left", 0, 1, 2}, {"bottom", 0, 1, 2}, {"right", 0, 1, 2}}, {{"left", 0, 1, 4}, {"top", 0, 1, 4}, {"right", 0, 1, 4}}, {{"top", 0, 2, 4}, {"bottom", 0, 2, 4}}, {{"right", 2, 1, 2}, {"bottom", 0, 3, 2}, {"top", 0, 3, 2}}, {{"right", 0, 2, 2}, {"left", 0, 2, 2}}, {{"right", 0, 2, 4}, {"left", 0, 2, 4}}, {{"right", 0, 3, 2}, {"left", 0, 3, 2}}, {{"right", 0, 3, 4}, {"left", 0, 3, 4}}, {{"right", 0, 4, 4}, {"left", 0, 4, 4}}}
tt.swarm_boxes = {
	top = {v(200, 680), v(500, 750)},
	left = {v(-100, 200), v(50, 600)},
	bottom = {v(300, 30), v(700, 120)},
	right = {v(940, 200), v(1110, 600)}
}
tt.swarm_boxes_phase2 = {
	left = {v(-150, 115), v(-80, 700)},
	right = {v(1100, 115), v(1200, 700)}
}
tt.waves_phases = {5, 10}
tt.positions_offset_max = 30
tt.swarm_spawn_min = 1
tt.swarm_spawn_max = 1
tt.several_spawn_min = 4
tt.several_spawn_max = 6
tt.wait_min = fts(2)
tt.wait_max = fts(5)
tt.periodic_eyes_min = 3
tt.periodic_eyes_max = 10
tt.pre_battle_periodic_eyes_min = 1
tt.pre_battle_periodic_eyes_max = 4
