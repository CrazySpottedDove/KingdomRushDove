local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local log = require("lib.klua.log"):new("level123")
local controller_darksteel_guardian_insert
local controller_stage_23_roboboots_update
local decal_stage_23_crane_update
controller_darksteel_guardian_insert = function(this, store)
	local guardian = E:create_entity(this.guardian_t)
	guardian.pos = V.vclone(this.pos)
	guardian.nav_path.pi = this.editor.path
	guardian.nav_path.spi = 1
	guardian.nav_path.ni = 1
	guardian.source_id = this.id
	guardian.render.sprites[1].flip_x = this.editor.flip_x > 0
	guardian.start_asleep = true
	guardian.ignore_seen_tracker = true
	simulation:queue_insert_entity(guardian)
end
controller_stage_23_roboboots_update = function(this, store)
	local mask_boot_left
	local BOOT_STATE_CLOSED = 0
	local BOOT_STATE_OPENING = 1
	local BOOT_STATE_OPEN = 2
	local BOOT_STATE_CLOSING = 3
	local legs_data = {{
		timing_index = 1,
		state = BOOT_STATE_CLOSED,
		paths = {{
			pi = 4,
			to = 30,
			from = 15
		}, {
			pi = 10,
			to = 30,
			from = 15
		}}
	}, {
		timing_index = 1,
		state = BOOT_STATE_CLOSED,
		paths = {{
			pi = 5,
			to = 30,
			from = 15
		}}
	}}
	for _, ldata in pairs(legs_data) do
		for _, pdata in pairs(ldata.paths) do
			P:add_invalid_range(pdata.pi, 0, pdata.from)
			P:add_invalid_range(pdata.pi, pdata.from, pdata.to)
		end
	end
	local function kill_enemies(pi, from, to)
		for _, e in pairs(store.entities) do
			if not e.pending_removal and e.enemy and e.nav_path and e.health and not e.health.dead and e.nav_path.pi == pi and from <= e.nav_path.ni and to >= e.nav_path.ni then
				simulation:queue_remove_entity(e)
			end
		end
	end
	while store.wave_group_number == 0 do
		coroutine.yield()
	end
	local last_wave = 0
	local start_wave_ts = store.tick_ts
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_23_mask_5" then
		elseif e.template_name == "decal_stage_23_mask_6" then
			mask_boot_left = e.id
		end
	end
	while true do
		local current_wave = store.wave_group_number
		local current_wave_data = this.wave_config[store.level_mode][current_wave]
		if current_wave ~= last_wave then
			last_wave = current_wave
			start_wave_ts = store.tick_ts
			legs_data[1].timing_index = 1
			legs_data[2].timing_index = 1
			legs_data[1].next_ts = nil
			legs_data[2].next_ts = nil
			if current_wave_data and #current_wave_data > 0 then
				for index, wave_data in ipairs(current_wave_data) do
					if wave_data then
						local leg_index = wave_data.leg
						local current_leg = legs_data[leg_index]
						if current_leg.state == BOOT_STATE_OPEN then
							current_leg.next_ts = start_wave_ts + (wave_data.timings[1][2] or 0)
							log.info("BOOT_STATE_OPEN " .. current_leg.next_ts)
						else
							current_leg.next_ts = start_wave_ts + (wave_data.timings[1][1] or 0)
							log.info("BOOT_STATE_CLOSE " .. current_leg.next_ts)
						end
					end
				end
			end
		end
		if current_wave_data and #current_wave_data > 0 then
			for index, wave_data in ipairs(current_wave_data) do
				local leg_index = wave_data.leg
				local current_leg = legs_data[leg_index]
				if current_leg.state == BOOT_STATE_CLOSED then
					if current_leg.next_ts and store.tick_ts >= current_leg.next_ts then
						S:queue(this.sound_open)
						U.animation_start(this, "open", nil, store.tick_ts, false, leg_index)
						U.animation_start(this, "open", nil, store.tick_ts, false, leg_index + 2)
						if leg_index == 1 then
							this.render.sprites[leg_index + 2].z = Z_OBJECTS
							this.render.sprites[leg_index + 2].sort_y_offset = 100
						elseif leg_index == 2 then
							this.render.sprites[leg_index + 2].z = Z_OBJECTS_COVERS
						end
						current_leg.state = BOOT_STATE_OPENING
						if #wave_data.timings[current_leg.timing_index] > 1 and wave_data.timings[current_leg.timing_index][2] then
							local timing_data = wave_data.timings[current_leg.timing_index]
							current_leg.next_ts = start_wave_ts + timing_data[2]
						else
							current_leg.next_ts = nil
						end
					end
				elseif current_leg.state == BOOT_STATE_OPENING then
					if U.animation_finished(this, leg_index) then
						if leg_index == 1 then
							store.entities[mask_boot_left].render.sprites[1].hidden = false
						end
						current_leg.state = BOOT_STATE_OPEN
						for _, pdata in pairs(current_leg.paths) do
							log.info("unlock paths ")
							P:remove_invalid_range(pdata.pi, pdata.from, pdata.to)
						end
						U.animation_start(this, "idleopen", nil, store.tick_ts, true, leg_index)
						U.animation_start(this, "idleopen", nil, store.tick_ts, true, leg_index + 2)
					end
				elseif current_leg.state == BOOT_STATE_OPEN then
					if current_leg.next_ts and store.tick_ts >= current_leg.next_ts then
						S:queue(this.sound_close)
						U.animation_start(this, "close", nil, store.tick_ts, false, leg_index)
						U.animation_start(this, "close", nil, store.tick_ts, false, leg_index + 2)
						if leg_index == 1 then
							store.entities[mask_boot_left].render.sprites[1].hidden = true
						end
						for _, pdata in pairs(current_leg.paths) do
							P:add_invalid_range(pdata.pi, pdata.from, pdata.to)
						end
						U.y_wait_unconditional(store, 1)
						for _, pdata in pairs(current_leg.paths) do
							kill_enemies(pdata.pi, 0, pdata.to)
						end
						U.y_wait_unconditional(store, 0.5)
						this.render.sprites[leg_index + 2].z = Z_OBJECTS
						if leg_index == 2 then
						end
						current_leg.state = BOOT_STATE_CLOSING
						current_leg.timing_index = current_leg.timing_index + 1
						if #wave_data.timings >= current_leg.timing_index then
							local timing_data = wave_data.timings[current_leg.timing_index]
							current_leg.next_ts = start_wave_ts + timing_data[1]
						else
							current_leg.next_ts = nil
						end
					end
				elseif current_leg.state == BOOT_STATE_CLOSING and U.animation_finished(this, leg_index) then
					current_leg.state = BOOT_STATE_CLOSED
					U.animation_start(this, "idle", nil, store.tick_ts, true, leg_index)
					U.animation_start(this, "idle", nil, store.tick_ts, true, leg_index + 2)
				end
			end
		end
		coroutine.yield()
	end
end
decal_stage_23_crane_update = function(this, store)
	local taps = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			taps = taps + 1
			if taps < 3 then
				S:queue(this.sound_tap_1_2)
				U.y_animation_play(this, "action", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				this.ui.can_click = true
			else
				S:queue(this.sound_tap_3)
				U.y_animation_play(this, "explosion", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle_dead", nil, store.tick_ts, true)
				signal.emit("crane-stage23", this)
			end
		end
		coroutine.yield()
	end
end
local tt
local SU = require("script_utils")
local controller_basic_clone_darksteel_guardian = {}

function controller_basic_clone_darksteel_guardian.update(this, store)
	local function reached_guardian()
		local nodes_to_end = P:get_end_node(this.nav_path.pi) - this.nav_path.ni

		return nodes_to_end < 2
	end

	while true do
		if this.health.dead then
			SU.y_enemy_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			if reached_guardian() then
				local guardian

				for k, v in pairs(store.entities) do
					if v.template_name == this.guardian_t and V.dist2(this.pos.x, this.pos.y, v.pos.x, v.pos.y) < 900 then
						guardian = v

						break
					end
				end

				guardian.wake_up = true

				simulation:queue_remove_entity(this)

				return
			end

			local cont, _ = SU.y_enemy_walk_until_blocked(store, this, true, reached_guardian)

			if not cont then
			-- block empty
			else
				coroutine.yield()
			end
		end
	end
end

tt = E:register_t_hot("controller_darksteel_guardian", nil, true)
E:add_comps(tt, "main_script", "editor")
tt.main_script.insert = controller_darksteel_guardian_insert
tt.guardian_t = "enemy_darksteel_guardian"
tt.editor.flip_x = false
tt.editor.path = 1
tt.editor.props = {{"editor.flip_x", PT_NUMBER}, {"editor.path", PT_NUMBER}}

tt = E:register_t_hot("decal_stage_23_crane", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "DLCenanos_stage1_deco_gruaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_stage_23_crane_update
tt.ui.click_rect = r(400, -220, 110, 100)
tt.sound_tap_1_2 = "Stage23TruckOneShot"
tt.sound_tap_3 = "Stage23TruckTap3"

tt = E:register_t_hot("decal_stage_23_mask_2", "decal", true)
tt.render.sprites[1].name = "stage23_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 51
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_23_mask_1", "decal", true)
tt.render.sprites[1].name = "stage23_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 170

tt = E:register_t_hot("decal_stage_23_torches", "decal", true)
tt.render.sprites[1].prefix = "dclenanos_stage01_torchesDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("controller_stage_23_roboboots", "decal_scripted", true)
E:add_comps(tt, "editor")
tt.main_script.update = controller_stage_23_roboboots_update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "dclenanos_stage01_robobootDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -1)
tt.render.sprites[1].sort_y_offset = 200
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "dclenanos_stage01_roboboot2Def"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(2.3, -3.1)
tt.render.sprites[2].sort_y_offset = 50
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "dclenanos_stage01_roboboot_topDef"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].exo = true
tt.render.sprites[3].sort_y_offset = 200
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "dclenanos_stage01_roboboot2_topDef"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].exo = true
tt.render.sprites[4].offset = v(2.3, -2.1)
tt.render.sprites[4].sort_y_offset = 50
tt.wave_config = {{
	{},
	{{
		leg = 2,
		timings = {{0}}
	}},
	{{
		leg = 2,
		timings = {{nil, 1}}
	}},
	{},
	{{
		leg = 1,
		timings = {{10}}
	}},
	{{
		leg = 1,
		timings = {{nil, 7}}
	}, {
		leg = 2,
		timings = {{17}}
	}},
	{{
		leg = 2,
		timings = {{nil, 8}}
	}},
	{},
	{{
		leg = 1,
		timings = {{1}}
	}},
	{{
		leg = 1,
		timings = {{nil, 8}}
	}, {
		leg = 2,
		timings = {{1}}
	}},
	{{
		leg = 1,
		timings = {{5, 25}}
	}, {
		leg = 2,
		timings = {{nil, 10}}
	}},
	{},
	{{
		leg = 2,
		timings = {{1}}
	}},
	{{
		leg = 2,
		timings = {{nil, 5}}
	}},
	{{
		leg = 1,
		timings = {{10, 76}}
	}, {
		leg = 2,
		timings = {{1, 72}}
	}}
}, {{}, {}, {{
	leg = 1,
	timings = {{1}}
}}, {{
	leg = 1,
	timings = {{nil, 6}}
}, {
	leg = 2,
	timings = {{1}}
}}, {{
	leg = 2,
	timings = {{nil, 6}}
}}, {{
	leg = 1,
	timings = {{20, 46}}
}, {
	leg = 2,
	timings = {{13, 72}}
}}}, {{{
	leg = 1,
	timings = {{2, 45}, {114, 163}, {200, 230}, {295, 340}, {345, 370}}
}, {
	leg = 2,
	timings = {{170, 205}, {280, 345}}
}}}}
tt.sound_open = "Stage23BootOpen"
tt.sound_close = "Stage23BootClose"

tt = E:register_t_hot("decal_stage_23_snow", "decal", true)
tt.render.sprites[1].prefix = "dclenanos_stage01_snowfallDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_23_mask_4", "decal", true)
tt.render.sprites[1].name = "stage23_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -8
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_23_mask_5", "decal", true)
tt.render.sprites[1].name = "stage23_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 50
tt.render.sprites[1].hidden = false

tt = E:register_t_hot("decal_stage_23_mask_6", "decal", true)
tt.render.sprites[1].name = "stage23_mask6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 123
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("decal_stage_23_rock", "decal", true)
tt.render.sprites[1].prefix = "darksteel_guardian_stage_rock"
tt.render.sprites[1].name = "idle"

tt = E:register_t_hot("controller_basic_clone_darksteel_guardian", "enemy", true)
tt.info.portrait = "kr5_info_portraits_enemies_0001"
tt.motion.max_speed = 36
tt.main_script.update = controller_basic_clone_darksteel_guardian.update
tt.render.sprites[1].prefix = "common_clone_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.vis.bans = F_ALL
tt.ui.can_click = false
tt.guardian_t = "enemy_darksteel_guardian"

