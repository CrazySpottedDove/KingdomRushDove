local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
require("lib.klua.table")
local scripts = require("scripts")
local decal_stage_39_floor_veins_controller_update
local decal_stage_39_floor_veins_controller_activate_veins_fn
decal_stage_39_floor_veins_controller_update = function(this, store, script)
	this.boss_veins_attack_nmbr = 0
	local veins_list = {}
	for i, v in pairs(this.veins_configs) do
		local vein = E:create_entity("decal_stage_39_floor_vein")
		vein.render.sprites[1].prefix = "stage_39_stun_tower" .. i .. "Def"
		vein.holder_id = v.holder_id
		simulation:queue_insert_entity(vein)
		table.insert(veins_list, vein)
	end
	local controller_boss
	for _, e in pairs(store.entities) do
		if e.template_name == "controller_stage_39_boss" then
			controller_boss = e
			controller_boss.veins_controller = this
			break
		end
	end
	while not this.start_sequence do
		coroutine.yield()
	end
	local current_sequence = 0
	while true do
		while controller_boss.health.dead do
			coroutine.yield()
		end
		current_sequence = current_sequence + 1
		if not this.veins_sequences[current_sequence] then
			break
		end
		this.do_veins = this.veins_sequences[current_sequence].veins
		local veins_per_cast = this.veins_sequences[current_sequence].veins_per_cast
		veins_per_cast = veins_per_cast or 1
		if this.veins_sequences[current_sequence].delay then
			U.y_wait_unconditional(store, this.veins_sequences[current_sequence].delay)
		end
		if this.veins_sequences[current_sequence].kill_units == "START" then
			LU.kill_all_enemies(store, true)
		end
		controller_boss.do_veins_attack = true
		this.boss_veins_attack_nmbr = 0
		if this.do_veins then
			local veins_to_activate = this.do_veins
			this.do_veins = nil
			local current_casts = 0
			for _, vein in pairs(veins_to_activate) do
				while this.boss_veins_attack_nmbr == 0 do
					coroutine.yield()
				end
				current_casts = current_casts + 1
				veins_list[vein.vein].activate = true
				if vein.delay then
					veins_list[vein.vein].delay = vein.delay
				end
				if veins_per_cast <= current_casts then
					this.boss_veins_attack_nmbr = this.boss_veins_attack_nmbr - 1
					current_casts = 0
				end
			end
			while true do
				local finished = true
				for _, vein in pairs(veins_list) do
					if vein.activate then
						finished = false
						break
					end
				end
				if finished then
					break
				end
				coroutine.yield()
			end
			if this.veins_sequences[current_sequence].kill_units == "END" then
				LU.kill_all_enemies(store, true)
			end
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
decal_stage_39_floor_veins_controller_activate_veins_fn = function(this)
	this.start_sequence = true
end
local tt
local v = V.v
local S = require("sound_db")
local signal = require("lib.hump.signal")
local SU = require("script_utils")
local function fts(v)
	return v / FPS
end

local decal_stage_39_easter_egg_sheepy = {}

function decal_stage_39_easter_egg_sheepy.update(this, store, script)
	local clics = 0
	local next_idle_anim_ts = store.tick_ts + 1 + 2 * math.random()

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			clics = clics + 1

			S:queue("Stage38EasterEggSheepyPart" .. clics)
			U.y_animation_play(this, "click_" .. clics, nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle_" .. clics + 1, nil, store.tick_ts, true, 1, true)

			if clics < 2 then
				this.ui.can_click = true
			end
		end

		if clics < 2 and next_idle_anim_ts < store.tick_ts then
			U.y_animation_play(this, "idle_" .. clics + 1 .. "_anim", nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle_" .. clics + 1, nil, store.tick_ts, true, 1, true)

			next_idle_anim_ts = store.tick_ts + 1 + 2 * math.random()
		end

		coroutine.yield()
	end
end

local stage_39_cocoon = {}

function stage_39_cocoon.update(this, store, script)
	local camera_posX, camera_posY, zoom_value
	local sprites_group = this.render.sprites[1].group

	local function animation_start(name, ts, loop)
		if sprites_group then
			U.animation_start_group(this, name, nil, ts, loop, sprites_group)
		else
			U.animation_start(this, name, nil, ts, loop)
		end
	end

	local function y_animation_play(name)
		if sprites_group then
			U.y_animation_play_group(this, name, nil, store.tick_ts, 1, sprites_group)
		else
			U.y_animation_play(this, name, nil, store.tick_ts, 1, 1)
		end
	end

	local function y_animation_wait()
		if sprites_group then
			U.y_animation_wait_group(this, sprites_group, 1)
		else
			U.y_animation_wait_default(this)
		end
	end

	for _, e in pairs(store.entities) do
		if e.template_name == "controller_stage_39_boss" then
			this.boss_controller_id = e.id

			break
		end
	end

	if this.broken_on_iron and store.level_mode == GAME_MODE_IRON or this.broken_on_heroic and store.level_mode == GAME_MODE_HEROIC then
		animation_start(this.animation_spawner_idle_broken, store.tick_ts, true)

		return
	end

	local active = false

	if this.active == "active" then
		active = true

		animation_start(this.animation_spawner_idle, store.tick_ts - fts(math.random(0, 20)), true)
	else
		animation_start(this.animation_spawner_idle_broken, store.tick_ts - fts(math.random(0, 20)), true)
	end

	if this.vena then
		this.vena_fx = E:create_entity(this.vena)
		this.vena_fx.pos = v(512, 384)
		this.vena_fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(this.vena_fx)

		this.vena_fx.render.sprites[1].hidden = true
	end

	if this.back then
		for _, e in pairs(store.entities) do
			if e.template_name == this.back then
				this.back_entity = e

				break
			end
		end
	end

	local function spawn_enemy(store)
		S:queue(this.sound_spawn)

		local exp = E:create_entity(this.explosion_fx)

		exp.pos.x, exp.pos.y = this.spawn_enemy.x + this.explosion_fx_offset.x, this.spawn_enemy.y + this.explosion_fx_offset.y
		exp.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(exp)

		if this.back_entity then
			U.animation_start(this.back_entity, this.animation_spawn_in, nil, store.tick_ts, false, 1)
		end

		y_animation_play(this.animation_spawn_in)
		animation_start(this.animation_spawner_idle, store.tick_ts, true)

		if this.back_entity then
			U.animation_start(this.back_entity, this.animation_spawner_idle, nil, store.tick_ts, true, 1)
		end
	end

	while true do
		if not active and this.active == "active" then
			if this.show_cinematic then
				signal.emit("show-curtains")
				signal.emit("hide-gui")
				signal.emit("start-cinematic")

				--camera_posX = game.camera.x / game.game_scale
				--camera_posY = game.ref_h - game.camera.y / game.game_scale
				--zoom_value = game.camera.zoom

				U.y_wait_unconditional(store, 2.5)
				signal.emit("pan-zoom-camera", 2, {
					x = this.pos.x - 250,
					y = this.pos.y + 200
				}, 1.3)
				U.y_wait_unconditional(store, 1.5)
			end

			U.y_wait_unconditional(store, 1)

			active = true

			if this.vena_fx then
				this.vena_fx.render.sprites[1].hidden = false

				S:queue(this.sound_vena)
				U.y_animation_play(this.vena_fx, "in", nil, store.tick_ts, 1, 1)
				U.animation_start(this.vena_fx, "loop", nil, store.tick_ts, true, 1)
			end

			S:queue(this.sound_inflate, this.sound_inflate_args)
			animation_start(this.animation_spawner_start, store.tick_ts, false)
			U.y_wait_unconditional(store, 0.8)
			SU.shake_screen(store, 0.7, 0.5, 1.5)
			y_animation_wait()
			animation_start(this.animation_spawner_idle, store.tick_ts, true)

			if this.show_cinematic then
				local start_ts = store.tick_ts

				while store.tick_ts - start_ts < 3 do
					if this.spawn_enemy then
						spawn_enemy(store)

						this.spawn_enemy = false
					end

					coroutine.yield()
				end

				signal.emit("pan-zoom-camera", 1, {
					x = camera_posX,
					y = camera_posY
				}, zoom_value)
				U.y_wait_unconditional(store, 1)
				signal.emit("hide-curtains")
				signal.emit("show-gui")
				signal.emit("end-cinematic")
				U.y_wait_unconditional(store, 1)

				this.show_cinematic = false
			end
		elseif active and this.active == "desactive" then
			S:queue(this.sound_regenerate)
			y_animation_play(this.animation_spawner_end)
			animation_start(this.animation_spawner_idle_broken, store.tick_ts, true)

			if this.vena_fx then
				U.y_animation_play(this.vena_fx, "out", nil, store.tick_ts, 1, 1)

				this.vena_fx.render.sprites[1].hidden = true

				U.animation_start(this.vena_fx, "loop", nil, store.tick_ts, true, 1)
			end

			active = false
		end

		if this.active == "active" and this.spawn_enemy then
			spawn_enemy(store)

			this.spawn_enemy = false
		end

		coroutine.yield()
	end
end

function stage_39_cocoon.on_activate_spawner(this, store, event_name, path_index, active)
	if table.contains(this.path_index, tonumber(path_index)) then
		this.active = active

		if not store.entities[this.boss_controller_id].show_cinematic then
			this.show_cinematic = true
			store.entities[this.boss_controller_id].show_cinematic = true

			U.y_wait_unconditional(store, 4)
		end

		store.entities[this.boss_controller_id].activate_spawner = active == "active"
	end
end

tt = E:register_t_hot("decal_stage_39_cocoon_center_5_back", "decal_scripted", true)
tt.render.sprites[1].prefix = "spawner_centro_5_backDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 55

tt = E:register_t_hot("decal_stage_39_cocoon_vena_1", "decal_scripted", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].exo = true

tt = E:register_t_hot("decal_stage_39_floor_veins_controller", nil, true)
E:add_comps(tt, "pos", "main_script")
tt.main_script.update = decal_stage_39_floor_veins_controller_update
tt.activate_veins = decal_stage_39_floor_veins_controller_activate_veins_fn
tt.veins_configs = {{
	holder_id = "4"
}, {
	holder_id = "2"
}, {
	holder_id = "10"
}, {
	holder_id = "8"
}, {
	holder_id = "6"
}}
tt.veins_sequences = {{
	veins = {{
		vein = 4
	}}
}, {
	veins = {{
		vein = 3
	}, {
		vein = 5
	}}
}, {
	kill_units = "END",
	veins = {{
		vein = 1
	}, {
		vein = 2
	}}
}, {
	delay = 7,
	veins_per_cast = 2,
	veins = {{
		vein = 1
	}, {
		delay = 10,
		vein = 2
	}, {
		delay = 5,
		vein = 3
	}, {
		delay = 15,
		vein = 4
	}, {
		vein = 5
	}}
}}

tt = E:register_t_hot("decal_stage_39_cocoon_vena_3", "decal_stage_39_cocoon_vena_1", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_03Def"

tt = E:register_t_hot("decal_stage_39_cocoon_vena_4", "decal_stage_39_cocoon_vena_1", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_04Def"

tt = E:register_t_hot("decal_stage_39_cocoon_vena_2", "decal_stage_39_cocoon_vena_1", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_02Def"

tt = E:register_t_hot("decal_stage_39_cocoon_vena_2_2", "decal_stage_39_cocoon_vena_1", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_02_02Def"

tt = E:register_t_hot("decal_stage_39_cocoon_center_2_back", "decal_scripted", true)
tt.render.sprites[1].prefix = "spawner_centro_2_backDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 5

tt = E:register_t_hot("decal_stage_39_cocoon_vena_5", "decal_stage_39_cocoon_vena_1", true)
tt.render.sprites[1].prefix = "stage_39_venas_spawner_05Def"

tt = E:register_t_hot("decal_stage_39_easter_egg_sheepy", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_39_easter_egg_sheepy.update
tt.render.sprites[1].prefix = "dragon_sheepy"
tt.render.sprites[1].name = "idle_1"
tt.ui.click_rect = r(-15, -5, 30, 30)

tt = E:register_t_hot("stage_39_cocoon", "decal_scripted", true)
E:add_comps(tt, "events", "editor")
tt.render.sprites[1].prefix = "stage_39_spawnerDef"
tt.render.sprites[1].name = "spawner_inactivo_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -13
tt.render.sprites[1].group = "layers"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_39_spawner_backDef"
tt.render.sprites[2].sort_y_offset = 40
tt.animation_spawner_start = "spawner_activo_in"
tt.animation_spawner_idle = "idle_activos"
tt.animation_spawner_end = "spawner_activo_out"
tt.animation_spawner_idle_broken = "spawner_inactivo_idle"
tt.animation_spawn_in = "spawn_in"
tt.broken_on_heroic = true
tt.broken_on_iron = true
tt.spawn_enemy = false
tt.active = "desactive"
tt.explosion_fx = "decal_stage_39_cocoon_explosion_2"
tt.explosion_fx_offset = v(0, -30)
tt.main_script.update = stage_39_cocoon.update
tt.sound_inflate = "Stage39EggsGrow"
tt.sound_inflate_args = {
	delay = fts(25)
}
tt.sound_vena = "Stage39VeinsExtend"
tt.sound_spawn = "Stage39VeinsSpawnEnemy"
tt.events.list[1].name = "activate_spawner"
tt.events.list[1].on_event = stage_39_cocoon.on_activate_spawner
tt.editor.props = {{"path_index", PT_STRING}}

tt = E:register_t_hot("stage_39_cocoon_center_1", "stage_39_cocoon", true)
tt.render.sprites[1].prefix = "spawner_centro_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = nil
tt.explosion_fx = "decal_stage_39_cocoon_explosion"
tt.animation_spawn_in = "spawn"
tt.animation_spawner_idle = "idle"
tt.active = "active"
tt.events = nil
tt.render.sprites[1].sort_y_offset = -11
tt.animation_spawner_idle_broken = "idle"

tt = E:register_t_hot("stage_39_cocoon_center_3", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_3Def"
tt.render.sprites[1].sort_y_offset = 68

tt = E:register_t_hot("stage_39_cocoon_center_4", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_4Def"
tt.render.sprites[1].sort_y_offset = 134

tt = E:register_t_hot("stage_39_cocoon_center_5", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_5_frontDef"
tt.render.sprites[1].sort_y_offset = 16
tt.back = "decal_stage_39_cocoon_center_5_back"

tt = E:register_t_hot("stage_39_cocoon_center_2", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_2_frontDef"
tt.render.sprites[1].sort_y_offset = -25
tt.back = "decal_stage_39_cocoon_center_2_back"

