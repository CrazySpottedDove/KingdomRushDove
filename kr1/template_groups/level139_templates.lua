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
tt = E:register_t_hot("stage_39_cocoon_center_3", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_3Def"
tt.render.sprites[1].sort_y_offset = 68
tt = E:register_t_hot("stage_39_cocoon_center_4", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_4Def"
tt.render.sprites[1].sort_y_offset = 134
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
tt = E:register_t_hot("stage_39_cocoon_center_5", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_5_frontDef"
tt.render.sprites[1].sort_y_offset = 16
tt.back = "decal_stage_39_cocoon_center_5_back"
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
tt = E:register_t_hot("stage_39_cocoon_center_2", "stage_39_cocoon_center_1", true)
tt.render.sprites[1].prefix = "spawner_centro_2_frontDef"
tt.render.sprites[1].sort_y_offset = -25
tt.back = "decal_stage_39_cocoon_center_2_back"
