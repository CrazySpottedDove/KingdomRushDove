local signal = require("lib.hump.signal")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local controller_stage_35_update
local controller_stage_35_on_event
local decal_stage_35_fume_entradas_update
controller_stage_35_update = function(this, store)
	local controller_boss, controller_redboy, controller_portal_left, controller_princess, controller_portal_right, controller_golden_eyed
	local destroy_houses_times = 0
	for _, e in pairs(store.entities) do
		if e.template_name == "controller_stage_35_bull_king" then
			controller_boss = e
		elseif e.template_name == "controller_stage_35_princess_powers" then
			controller_princess = e
		elseif e.template_name == "controller_stage_35_redboy_powers" then
			controller_redboy = e
		elseif e.template_name == "controller_stage_35_portal_left" then
			controller_portal_left = e
		elseif e.template_name == "controller_stage_35_portal_right" then
			controller_portal_right = e
		elseif e.template_name == "controller_stage_35_golden_eyed_left" then
			controller_golden_eyed = e
		end
	end
	while true do
		if this.activate then
			local activate_string = "return {" .. this.activate .. "}"
			local f = load(activate_string)
			local activate = f()
			local houses_templates = {}
			local cinematic = activate.cinematic or false
			local action = activate.action or nil
			if activate.houses then
				for _, house_id in ipairs(activate.houses) do
					table.insert(houses_templates, "tower_holder_blocked_stage_35_house_" .. house_id)
				end
			end
			local houses_unordered = {}
			for _, e in pairs(store.entities) do
				if table.contains(houses_templates, e.template_name) then
					table.insert(houses_unordered, e)
				end
			end
			local houses = {}
			if activate.houses then
				for _, house_id in ipairs(houses_templates) do
					for _, h in ipairs(houses_unordered) do
						if h.template_name == house_id then
							table.insert(houses, h)
							break
						end
					end
				end
			end
			this.activate = nil
			if action == "destroy_houses" then
				destroy_houses_times = destroy_houses_times + 1
				local camera_posX, camera_posY, zoom_value
				if cinematic then
					signal.emit("show-curtains")
					signal.emit("hide-gui")
					signal.emit("start-cinematic")
				end
				for h_index, house in ipairs(houses) do
					if cinematic then
						signal.emit("pan-zoom-camera", (h_index == 1 and 1 or 2) + house.cinematic_camera_duration_offset, {
							x = house.pos.x,
							y = house.pos.y + 50
						}, 1.5)
						house:pre_destroy(store)
					end
					U.y_wait_unconditional(store, 0.5 + house.cinematic_camera_duration_offset)
					if h_index == 1 then
						U.sprites_show(this, nil, nil, false)
						local cox, coy = this.fixed_screen_offset.x, this.fixed_screen_offset.y
						if store.safe_frame then
							cox = math.max(cox, math.max(store.safe_frame.rb, store.safe_frame.lb))
						end
						this.render.sprites[1].pos.y = coy
						if house.pos.x < 512 then
							this.render.sprites[1].pos.x = cox
							this.render.sprites[1].flip_x = false
						else
							this.render.sprites[1].pos.x = REF_W - cox
							this.render.sprites[1].flip_x = true
						end
						U.y_animation_play(this, "run", nil, store.tick_ts, 1, 1)
						U.sprites_hide(this, nil, nil, false)
					end
					house:destroy_house(store)
				end
				if cinematic then
					signal.emit("pan-zoom-camera", 1, {
						x = 512,
						y = 700
					}, 1.5)
					U.y_wait_unconditional(store, 1.2)
					controller_boss.do_taunt = "LV35_BOSS_DESTROY_HOUSE_0" .. destroy_houses_times
					U.y_wait_unconditional(store, 3.5)
					if destroy_houses_times == 1 then
						controller_boss.activate = "redboy"
						U.y_wait_unconditional(store, 3.5)
						signal.emit("pan-zoom-camera", 1, {
							x = 300,
							y = 500
						}, OVtargets(nil, 1.2))
						controller_redboy.activate = "portal_in"
						controller_portal_left.activate = "open"
						U.y_wait_unconditional(store, 1.5)
					elseif destroy_houses_times == 2 then
						controller_boss.activate = "princess"
						U.y_wait_unconditional(store, 3.5)
						signal.emit("pan-zoom-camera", 1, {
							x = 800,
							y = 500
						}, OVtargets(nil, 1.2))
						controller_princess.activate = "portal_in"
						controller_portal_right.activate = "open"
						U.y_wait_unconditional(store, 1.5)
					elseif destroy_houses_times == 3 then
						controller_golden_eyed.activate = true
						controller_boss.activate = "golden_eyed"
						U.y_wait_unconditional(store, 6)
					end
				end
				U.y_wait_unconditional(store, 1.5)
				if cinematic then
					signal.emit("pan-zoom-camera", 1, {
						x = camera_posX,
						y = camera_posY
					}, zoom_value)
				end
				U.y_wait_unconditional(store, 2)
				if cinematic then
					signal.emit("hide-curtains")
					signal.emit("show-gui")
					signal.emit("end-cinematic")
					U.y_wait_unconditional(store, 1)
					signal.emit("barrage_end")
				end
			end
		end
		coroutine.yield()
	end
end
controller_stage_35_on_event = function(this, store, action, house)
	this.activate = tostring(house)
end
decal_stage_35_fume_entradas_update = function(this, store)
	U.animation_start_default(this, "loop", nil, store.tick_ts, true)
	while not this.finish do
		coroutine.yield()
	end
	U.y_animation_play(this, "put", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_stage_35_mask_boss_bull_left", "decal", true)
tt.render.sprites[1].name = "stage35_mask_shadow_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_35_fume_entradas", "decal_scripted", true)
tt.main_script.update = decal_stage_35_fume_entradas_update
tt.render.sprites[1].prefix = "stage_35_fumeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("controller_stage_35_water_splash", "controller_stage_35_lava_splash", true)
tt.apply_if_enemy_is_to_right = true
tt.mod = "mod_stage_35_water_splash"
tt.paths_x = {
	[8] = 1025
}
tt = E:register_t_hot("decal_stage_35_mask_boss_bull_right", "decal_stage_35_mask_boss_bull_left", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("decal_stage_35_mask_redboy_bottom", "decal", true)
tt.render.sprites[1].name = "stage35_mask_mask_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -30
tt = E:register_t_hot("decal_stage_35_mask_princess_bottom", "decal_stage_35_mask_redboy_bottom", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("controller_stage_35", "decal_scripted", true)
E:add_comps(tt, "editor", "ui", "events")
tt.main_script.update = controller_stage_35_update
tt.render.sprites[1].prefix = "stage_5_cinematicaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].pos = v(0, 0)
tt.events.list[1].name = "barrage"
tt.events.list[1].on_event = controller_stage_35_on_event
tt.fixed_screen_offset = v(40, 40)
tt = E:register_t_hot("decal_stage_35_mask_princess_top", "decal_stage_35_mask_redboy_top", true)
tt.render.sprites[1].flip_x = true
tt = E:register_t_hot("controller_stage_35_golden_eyed_right", "controller_stage_35_golden_eyed_left", true)
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.events.list[1].name = "golden_beast_right"
tt.path_id = 6
