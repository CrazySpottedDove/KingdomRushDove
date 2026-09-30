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
local v = V.v
local r = V.r
local decal_stage_09_sheepy_easteregg_update
decal_stage_09_sheepy_easteregg_update = function(this, store)
	local bridge_down = false
	local function check_bridge_down()
		if not bridge_down and store.wave_group_number == 10 then
			bridge_down = true
			return true
		end
		return false
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			S:queue("Stage09SheepyCamera")
			U.animation_start_default(this, "action_" .. math.random(1, 3), nil, store.tick_ts)
			signal.emit("sheepy_tap_achievement", 1)
			while not U.animation_finished_default(this) do
				if check_bridge_down() then
					U.y_wait_unconditional(store, fts(13))
					S:queue("Stage09SheepyBridge")
					U.y_animation_play(this, "bridge", true, store.tick_ts)
					goto label_1416_0
				end
				coroutine.yield()
			end
		end
		if check_bridge_down() then
			U.y_wait_unconditional(store, fts(13))
			S:queue("Stage09SheepyBridge")
			U.y_animation_play(this, "bridge", true, store.tick_ts)
			break
		end
		coroutine.yield()
	end
	::label_1416_0::
	simulation:queue_remove_entity(this)
end
local tt
local decal_stage_09_bridge = {}

function decal_stage_09_bridge.insert(this, store)
	local mask = E:create_entity(this.mask_entity)

	mask.pos.x, mask.pos.y = this.pos.x, this.pos.y

	simulation:queue_insert_entity(mask)

	this.mask = mask

	return true
end

function decal_stage_09_bridge.update(this, store)
	if this.start_in_loop then
		U.animation_start_default(this.mask, this.mask_loop_animation, nil, store.tick_ts, true)
	else
		this.render.sprites[1].hidden = true
		this.mask.render.sprites[1].hidden = true

		if this.in_delay then
			U.y_wait_unconditional(store, this.in_delay)
		end

		this.render.sprites[1].hidden = false
		this.render.sprites[1].ts = store.tick_ts

		if this.mask_before then
			this.mask.render.sprites[1].hidden = false
			this.mask.render.sprites[1].ts = store.tick_ts

			U.animation_start_default(this.mask, this.mask_in_animation, nil, store.tick_ts)
		end

		U.y_animation_play(this, this.animation_in, nil, store.tick_ts)

		if not this.mask_before then
			this.mask.render.sprites[1].hidden = false
			this.mask.render.sprites[1].ts = store.tick_ts
		else
			U.animation_start_default(this.mask, this.mask_loop_animation, nil, store.tick_ts, true)
		end
	end

	while true do
		U.y_animation_play(this, this.animation_loop, nil, store.tick_ts)
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = E:register_t_tmp("aura_stage_09_spawn_nightmare_convert", "aura")
tt.aura.duration = 1e+99
tt.aura.radius = 4
tt.include_templates = {"enemy_lesser_sister_nightmare"}
tt.entity_to_spawn = "enemy_armored_nightmare"
tt.spawn_fx = "fx_stage_09_portal_path_spawn_fx"
tt.portal_offset = v(-15, 0)
tt.main_script.update = function(this, store)
	this.entities_spawned = 0

	while true do

		if this.path_portal.render.sprites[1].name ~= "idle" then
			local targets = U.find_enemies_in_range_filter_on(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
				return e ~= this and e.health.hp and e.can_be_converted and (this.include_templates and table.contains(this.include_templates, e.template_name) or not this.include_templates)
			end)

			if targets and #targets > 0 then
				for _, enemy in ipairs(targets) do
					local pos = V.vclone(enemy.pos)
					local nav_path = enemy.nav_path

					simulation:queue_remove_entity(enemy)

					local entity = E:create_entity(this.spawn_fx)

					entity.pos = v(512 + this.portal_offset.x, 384 + this.portal_offset.y)
					entity.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(entity)

					entity = E:create_entity(this.entity_to_spawn)
					entity.pos = pos
					entity.nav_path = nav_path

					local original_speed = entity.motion.max_speed
					U.update_max_speed(entity, 0)
					entity.source_id = this.id

					simulation:queue_insert_entity(entity)
					S:queue(this.sound_spawn)
					U.y_wait_unconditional(store, fts(5))

					U.update_max_speed(entity, original_speed)
					this.entities_spawned = this.entities_spawned + 1
				end
			end
		end

		coroutine.yield()
	end
end
tt.wave_config = {{
	{},
	{},
	{{
		duration = 28,
		time_start = 10
	}},
	{{
		duration = 28,
		time_start = 10
	}},
	{},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 52,
		time_start = 10
	}},
	{{
		duration = 40,
		time_start = 10
	}},
	{},
	{{
		duration = 40,
		time_start = 12
	}},
	{{
		duration = 70,
		time_start = 10
	}}
}, {{}, {}, {}, {{
	duration = 70,
	time_start = 20
}}, {}, {{
	duration = 107,
	time_start = 21
}}}, {{{
	duration = 110,
	time_start = 74
}, {
	duration = 330,
	time_start = 310
}}}}
tt.sound_spawn = "EnemyTwistedSisterSummonSpawn"

tt = E:register_t_tmp("aura_stage_09_spawn_nightmare_convert_spawn_fx", "aura")
tt.aura.duration = 1e+99
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.include_templates = {"enemy_lesser_sister_nightmare"}
tt.main_script.update = function(this, store)
	local enemies_spawned = {}

	while true do
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans, function(e)
			return table.contains(this.include_templates, e.template_name)
		end)

		if targets and #targets > 0 then
			for _, e in ipairs(targets) do
				if not table.contains(enemies_spawned, e.id) then
					e.can_be_converted = true

					table.insert(enemies_spawned, e.id)

					this.portal.enemy_spawned = true
				end
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_tmp("fx_stage_09_portal_path_spawn_fx", "fx")
tt.render.sprites[1].prefix = "stage_9_portal_path_spawn_FXDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("decal_stage_09_bridge_mask", "decal", true)
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_09_bridge1_mask", "decal_stage_09_bridge_mask", true)
tt.render.sprites[1].prefix = "stage_9_bridge1_maskDef"
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_09_bridge2_mask", "decal_stage_09_bridge_mask", true)
tt.render.sprites[1].prefix = "stage_9_bridge2_maskDef"

tt = E:register_t_hot("decal_stage_09_bridge3_mask", "decal_stage_09_bridge_mask", true)
tt.render.sprites[1].prefix = "stage_9_bridge3_maskDef"

tt = E:register_t_hot("decal_stage_09_candle", "decal_scripted", true)
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "idle_off"
tt.main_script.update = function(this, store)
	local is_on = false

	while true do
		if this.turn_on then
			this.turn_on = nil

			U.y_animation_play(this, "on", nil, store.tick_ts)

			is_on = true
		elseif this.turn_off then
			this.turn_off = nil

			U.y_animation_play(this, "off", nil, store.tick_ts)

			is_on = false
		end

		if is_on then
			U.animation_start_default(this, "idle_on", nil, store.tick_ts, true)
		else
			U.animation_start_default(this, "idle_off", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_09_candle_back1", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_back_1Def"

tt = E:register_t_hot("decal_stage_09_candle_back2", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_back_2Def"

tt = E:register_t_hot("decal_stage_09_candle_back3", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_back_3Def"

tt = E:register_t_hot("decal_stage_09_candle_front1", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_front_1Def"

tt = E:register_t_hot("decal_stage_09_candle_front2", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_front_2Def"

tt = E:register_t_hot("decal_stage_09_candle_front3", "decal_stage_09_candle", true)
tt.render.sprites[1].prefix = "stage_9_candles_front_3Def"

tt = E:register_t_hot("decal_stage_09_candle_glow_back", "decal", true)
tt.render.sprites[1].prefix = "stage_9_candles_glow_backDef"
tt.render.sprites[1].name = "off"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_09_candle_glow_front", "decal", true)
tt.render.sprites[1].prefix = "stage_9_candles_glow_frontDef"
tt.render.sprites[1].name = "off"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_09_portal_path_spawn", "decal_scripted", true)
tt.render.sprites[1].prefix = "stage_9_portal_pathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = function(this, store)
	local is_on = false

	while true do
		if this.turn_on then
			this.turn_on = nil

			U.y_animation_play(this, "light_on", nil, store.tick_ts)

			is_on = true
		elseif this.turn_off then
			this.turn_off = nil

			U.y_animation_play(this, "light_off", nil, store.tick_ts)

			is_on = false
		end

		if is_on then
			U.animation_start_default(this, "idle_on", nil, store.tick_ts, true)
		else
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_09_portal", "decal", true)
tt.render.sprites[1].prefix = "stage_9_portalDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_09_fire", "decal", true)
tt.render.sprites[1].prefix = "stage_9_fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1

tt = E:register_t_hot("decal_stage_09_sheepy_easteregg", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.render.sprites[1].prefix = "stage_9_sheepyDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.main_script.update = decal_stage_09_sheepy_easteregg_update
tt.ui.click_rect = r(-20, -10, 40, 40)

tt = E:register_t_hot("controller_stage_09_spawn_nightmares", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.insert = function(this, store)
	local portal_spawned = E:create_entity(this.entity_portal)

	portal_spawned.pos = v(526, 380)

	simulation:queue_insert_entity(portal_spawned)

	this.portal_spawned = portal_spawned

	local path_portal = E:create_entity(this.path_portal)

	path_portal.pos = v(512 + this.portal_offset.x, 384 + this.portal_offset.y)

	simulation:queue_insert_entity(path_portal)

	this.path_portal = path_portal
	this.candles = {}
	this.glows = {}

	return true
end
tt.main_script.update = function(this, store)
	local portal_spawned = this.portal_spawned

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	local last_wave = 0
	local start_wave_ts = store.tick_ts
	local last_index_processed = 0
	local auras = {}

	local function get_wave_data_index(current_wave_data)
		for index, wave_data in ipairs(current_wave_data) do
			if index > last_index_processed and wave_data.time_start + wave_data.duration > store.tick_ts - start_wave_ts then
				return index
			end
		end

		return nil
	end

	for _, pos in ipairs(this.pos_aura) do
		local aura_spawned = E:create_entity(this.entity_aura)

		aura_spawned.pos = pos
		aura_spawned.path_portal = this.path_portal

		simulation:queue_insert_entity(aura_spawned)
		table.insert(auras, aura_spawned)
	end

	local aura_spawned_fx = E:create_entity(this.spawn_fx_aura)

	aura_spawned_fx.pos = this.pos_portal
	aura_spawned_fx.portal = this

	simulation:queue_insert_entity(aura_spawned_fx)

	while true do
		if store.game_outcome and store.game_outcome.victory then
			local entities_spawned = false

			for _, aura in ipairs(auras) do
				if aura.entities_spawned > 0 then
					entities_spawned = true

					break
				end
			end

			if not entities_spawned then
				signal.emit("portal_not_spawned-stage09", this)
			end
		end

		local current_wave = store.wave_group_number
		local current_wave_data = this.wave_config[store.level_mode][current_wave]

		if current_wave ~= last_wave then
			last_wave = current_wave
			start_wave_ts = store.tick_ts
			last_index_processed = 0
		end

		if current_wave_data and #current_wave_data > 0 then
			local next_index_to_check = get_wave_data_index(current_wave_data)

			if next_index_to_check and next_index_to_check ~= last_index_processed then
				local wave_data = current_wave_data[next_index_to_check]

				if store.tick_ts - start_wave_ts >= wave_data.time_start then
					S:queue(this.sound_candles_in)

					for _, candle in ipairs(this.candles) do
						candle.turn_on = true
					end

					for _, glow in ipairs(this.glows) do
						glow.render.sprites[1].hidden = false

						U.animation_start_default(glow, "on", nil, store.tick_ts)
					end

					this.path_portal.turn_on = true

					S:queue(this.sound_portal_in)
					U.y_animation_play(portal_spawned, "on", nil, store.tick_ts)
					U.y_animation_play(portal_spawned, "idle_on", nil, store.tick_ts)

					local start_ts = store.tick_ts

					while store.tick_ts - start_ts < wave_data.duration do
						if this.enemy_spawned then
							this.enemy_spawned = nil

							U.y_animation_play(portal_spawned, "spawn", nil, store.tick_ts)
						end

						coroutine.yield()
					end

					last_index_processed = next_index_to_check

					for _, candle in ipairs(this.candles) do
						candle.turn_off = true
					end

					for _, glow in ipairs(this.glows) do
						U.animation_start_default(glow, "off", nil, store.tick_ts)
					end

					U.y_animation_play(portal_spawned, "off", nil, store.tick_ts)
					U.y_animation_play(portal_spawned, "idle", nil, store.tick_ts)

					local start_ts = store.tick_ts

					while store.tick_ts - start_ts < this.path_portal_off_delay and current_wave == store.wave_group_number do
						coroutine.yield()
					end

					this.path_portal.turn_off = true
				end
			end
		end

		coroutine.yield()
	end
end
tt.wave_config = {{
	{},
	{},
	{{
		duration = 28,
		time_start = 10
	}},
	{{
		duration = 28,
		time_start = 10
	}},
	{},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 52,
		time_start = 10
	}},
	{{
		duration = 40,
		time_start = 10
	}},
	{},
	{{
		duration = 40,
		time_start = 12
	}},
	{{
		duration = 70,
		time_start = 10
	}}
}, {{}, {}, {}, {{
	duration = 70,
	time_start = 20
}}, {}, {{
	duration = 107,
	time_start = 21
}}}, {{{
	duration = 110,
	time_start = 74
}, {
	duration = 330,
	time_start = 310
}}}}
tt.entity_portal = "decal_stage_09_portal"
tt.entity_aura = "aura_stage_09_spawn_nightmare_convert"
tt.spawn_fx_aura = "aura_stage_09_spawn_nightmare_convert_spawn_fx"
tt.entity_candles = {"decal_stage_09_candle_back1", "decal_stage_09_candle_back2", "decal_stage_09_candle_back3", "decal_stage_09_candle_front1", "decal_stage_09_candle_front2", "decal_stage_09_candle_front3"}
tt.entity_glows = {"decal_stage_09_candle_glow_back", "decal_stage_09_candle_glow_front"}
tt.path_portal = "decal_stage_09_portal_path_spawn"
tt.portal_offset = v(-15, 0)
tt.pos_portal = v(1048 + tt.portal_offset.x, 446 + tt.portal_offset.y)
tt.pos_aura = {v(661 + tt.portal_offset.x, 280 + tt.portal_offset.y), v(659 + tt.portal_offset.x, 300 + tt.portal_offset.y), v(658 + tt.portal_offset.x, 260 + tt.portal_offset.y)}
tt.path_portal_off_delay = 10
tt.sound_candles_in = "Stage09NightmarePortalCandles"
tt.sound_portal_in = "Stage09NightmarePortalEye"

tt = E:register_t_hot("decal_stage_09_mask", "decal", true)
tt.render.sprites[1].name = "T2_Stage_9_chains_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_09_bridge", "decal_scripted", true)
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].loop = false
tt.animation_in = "in"
tt.animation_loop = "loop"
tt.mask_before = false
tt.main_script.insert = decal_stage_09_bridge.insert
tt.main_script.update = decal_stage_09_bridge.update

tt = E:register_t_hot("decal_stage_09_bridge1", "decal_stage_09_bridge", true)
tt.render.sprites[1].prefix = "stage_9_bridge1Def"
tt.mask_entity = "decal_stage_09_bridge1_mask"
tt.in_delay = 1

tt = E:register_t_hot("decal_stage_09_bridge2", "decal_stage_09_bridge", true)
tt.render.sprites[1].prefix = "stage_9_bridge2Def"
tt.mask_entity = "decal_stage_09_bridge2_mask"
tt.in_delay = 2.5

tt = E:register_t_hot("decal_stage_09_bridge3", "decal_stage_09_bridge", true)
tt.render.sprites[1].prefix = "stage_9_bridge3Def"
tt.mask_entity = "decal_stage_09_bridge3_mask"
tt.mask_before = true
tt.mask_in_animation = "in"
tt.mask_loop_animation = "loop"

