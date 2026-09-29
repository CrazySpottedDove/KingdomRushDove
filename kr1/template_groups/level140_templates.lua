local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local SU = require("script_utils")
local scripts = require("scripts")
local v = V.v
local vv = V.vv
local controller_stage_40_boss_shadow_waves_update
local controller_stage_40_boss_shadow_waves_on_stun_stage
controller_stage_40_boss_shadow_waves_update = function(this, store, script)
	local number_attack = 0
	local path_rock_1, path_rock_2, path_rock_3
	local decoy_positions = {}
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_40_path_rock_1" then
			path_rock_1 = e
		elseif e.template_name == "decal_stage_40_path_rock_2" then
			path_rock_2 = e
		elseif e.template_name == "decal_stage_40_path_rock_final" then
			path_rock_3 = e
		elseif e.template_name == "decal_boss_40_waves_stun_decoy_position" then
			table.insert(decoy_positions, e)
		end
	end
	local a_stun_towers = this.timed_attacks.list[this.attack_towers_index]
	local a_stun_units = this.timed_attacks.list[this.attack_units_index]
	if not a_stun_units.stun_fliers then
		a_stun_units.vis_bans = bor(a_stun_units.vis_bans, F_FLYING)
	end
	local function appear()
		S:queue("Stage40BossDriveby")
		U.sprites_show(this, 1, 1, true)
		U.animation_start(this, "fly", nil, store.tick_ts, false, 1, true)
	end
	local function get_towers(side)
		local allowed_holders = a_stun_towers.holders_ids[side]
		return U.find_towers_in_range(store.towers, this.pos, a_stun_towers, function(t)
			if not t.tower.can_be_mod then
				return false
			end
			if not table.contains(allowed_holders, t.tower.holder_id) then
				return false
			end
			return true
		end)
	end
	local function stun_tower(t, delay, decal_warning, side)
		local decal_stun = E:create_entity(a_stun_towers.decal_stun)
		decal_stun.pos = V.vclone(t.pos)
		decal_stun.target_id = t.id
		decal_stun.holder_id = t.tower.holder_id
		decal_stun.delay_start = delay
		decal_stun.decal_warning = decal_warning
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function stun_unit(u, delay, side)
		local decal_stun = E:create_entity(a_stun_units.decal_stun)
		decal_stun.pos = V.vclone(u.pos)
		decal_stun.target_id = u.id
		decal_stun.delay_start = delay + 0.3 * math.random()
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function stun_decoy(pos, delay, side)
		local decal_stun = E:create_entity("decal_boss_40_waves_stun_decoy")
		decal_stun.pos = V.vclone(pos)
		decal_stun.delay_start = delay + 0.3 * math.random()
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function y_attack_side(side)
		number_attack = number_attack + 1
		local dir
		local extra_dist = -500
		local speed = 700
		if this.stun_with_fps then
			this.render.sprites[1].fps = this.stun_with_fps
			speed = speed * (this.stun_with_fps / 30)
		end
		if side == "LEFT" then
			this.pos.x = REF_W + extra_dist
			dir = 1
			this.render.sprites[1].flip_x = false
			this.imaginary_position = V.v(0, 384)
		else
			this.pos.x = -extra_dist
			dir = -1
			this.render.sprites[1].flip_x = true
			this.imaginary_position = V.v(REF_W, 384)
		end
		local function do_once(name, condition, fn)
			if not this.do_once[name] and condition() then
				this.do_once[name] = true
				fn()
			end
		end
		local function reset_do_once(name)
			if not this.do_once then
				this.do_once = {}
			end
			this.do_once[name] = false
		end
		if number_attack ~= 5 then
			reset_do_once("stun")
			local stuns_amount = 0
			local towers = get_towers(side)
			local units = U.find_soldiers_in_range(store.soldiers, this.pos, a_stun_units.min_range, a_stun_units.max_range, a_stun_units.vis_flags, a_stun_units.vis_bans)
			local decal
			local decal_warning_i = 0
			local bullet_delay = 0
			local pixel_delay_mult = 0.002
			if towers and #towers > 0 then
				for _, t in pairs(towers) do
					decal = E:create_entity(a_stun_towers.decal_warning)
					decal.pos = V.vclone(t.pos)
					decal.delay_start = decal_warning_i * fts(2)
					simulation:queue_insert_entity(decal)
					decal_warning_i = decal_warning_i + 1
					if side == "LEFT" then
						bullet_delay = (t.pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - t.pos.x) * pixel_delay_mult
					end
					stun_tower(t, bullet_delay, decal, side)
					stuns_amount = stuns_amount + 1
				end
			end
			if a_stun_units.enabled and units and #units > 0 then
				for k, u in pairs(units) do
					if side == "LEFT" then
						bullet_delay = (u.pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - u.pos.x) * pixel_delay_mult
					end
					if u.template_name ~= "soldier_warden_stage_40_moving_island" then
						stun_unit(u, bullet_delay, side)
						stuns_amount = stuns_amount + 1
					end
				end
			end
			local total_decoys = 12 - stuns_amount
			if total_decoys > 0 then
				decoy_positions = table.random_order(decoy_positions)
				for i = 1, total_decoys do
					if i > #decoy_positions then
						break
					end
					local decoy_pos = decoy_positions[i].pos
					if side == "LEFT" then
						bullet_delay = (decoy_pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - decoy_pos.x) * pixel_delay_mult
					end
					stun_decoy(decoy_pos, bullet_delay, side)
				end
			end
		end
		appear()
		local start_shake_ts = store.tick_ts + 0.3
		local up_rocks
		if number_attack == 2 then
			up_rocks = {{
				ts = store.tick_ts + 0.5,
				rock = path_rock_1
			}, {
				ts = store.tick_ts + 0.8,
				rock = path_rock_2
			}, {
				ts = store.tick_ts + 1.1,
				rock = path_rock_3
			}}
		end
		while not U.animation_finished_default(this) do
			this.imaginary_position.x = this.imaginary_position.x + dir * speed * store.tick_length
			if start_shake_ts and start_shake_ts < store.tick_ts then
				start_shake_ts = nil
				if store.wave_group_number ~= 10 and store.wave_group_number ~= 9 then
					SU.shake_screen(store, 0.3, 4, 4)
				end
			end
			if up_rocks and #up_rocks > 0 and store.tick_ts >= up_rocks[1].ts then
				up_rocks[1].rock.go_up = true
				table.remove(up_rocks, 1)
			end
			coroutine.yield()
		end
		U.sprites_hide(this, nil, nil, true)
		this.render.sprites[1].fps = nil
	end
	while true do
		if this.stun_side then
			y_attack_side(this.stun_side)
			this.stun_side = nil
		end
		coroutine.yield()
	end
end
controller_stage_40_boss_shadow_waves_on_stun_stage = function(this, store, action, side)
	this.stun_side = side
end
local tt
tt = E:register_t_hot("decal_stage_40_top_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_mask_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t_hot("decal_stage_40_storm_decos", "decal", true)
tt.render.sprites[1].prefix = "stage_40_storm_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].scale = vv(4)
tt.render.sprites[1].pos = v(512, 384)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_y = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "stage_40_storm_02Def"
tt.render.sprites[3].z = Z_OBJECTS_COVERS
tt.render.sprites[3].scale = vv(1)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].prefix = "stage_40_storm_04Def"
tt.render.sprites[4].z = Z_BACKGROUND_COVERS
tt.render.sprites[4].sort_y_offset = -1
tt.render.sprites[5] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[5].pos = v(300, 330)
tt.render.sprites[5].prefix = "stage_40_storm_04Def"
tt.render.sprites[5].z = Z_BACKGROUND_COVERS + 2
tt.render.sprites[5].sort_y_offset = 55
tt.render.sprites[5].hidden = true
tt.render.sprites[6] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[6].prefix = "stage_40_storm_05Def"
tt.render.sprites[6].z = Z_BACKGROUND_COVERS - 1
tt.render.sprites[7] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[7].pos = v(800, 340)
tt.render.sprites[7].prefix = "stage_40_storm_04Def"
tt.render.sprites[7].z = Z_BACKGROUND_COVERS
tt.render.sprites[7].sort_y_offset = -1
tt.render.sprites[8] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[8].pos = v(800, 370)
tt.render.sprites[8].prefix = "stage_40_storm_04Def"
tt.render.sprites[8].z = Z_BACKGROUND_COVERS - 1
tt = E:register_t_hot("decal_stage_40_open_middle_mask_iron", "decal_stage_40_open_middle_mask", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "rocas_idle"
tt = E:register_t_hot("decal_stage_40_holders_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_holder_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_40_holder_mask_2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BACKGROUND_COVERS + 10
tt = E:register_t_hot("decal_stage_40_bottom_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 2
tt = E:register_t_hot("controller_stage_40_boss_shadow_waves", "decal_scripted", true)
E:add_comps(tt, "editor", "timed_attacks", "events")
tt.main_script.update = controller_stage_40_boss_shadow_waves_update
tt.render.sprites[1].prefix = "stage_40_bossDef"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].exo = true
tt.attack_towers_index = 1
tt.timed_attacks.list[tt.attack_towers_index] = E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_towers_index].decal_stun = "decal_boss_40_waves_stun_towers"
tt.timed_attacks.list[tt.attack_towers_index].decal_warning = "decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_towers_index].max_range = 99999999
tt.timed_attacks.list[tt.attack_towers_index].min_range = 0
tt.timed_attacks.list[tt.attack_towers_index].holders_ids = {
	RIGHT = {"1", "4", "5", "10", "12", "6", "7", "8", "9"},
	LEFT = {"1", "4", "5", "10", "12", "6", "7", "8", "9"}
}
tt.attack_units_index = 2
tt.timed_attacks.list[tt.attack_units_index] = E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_units_index].vis_flags = bor(F_MOD, F_STUN)
tt.timed_attacks.list[tt.attack_units_index].decal_stun = "decal_boss_40_waves_stun_units"
tt.timed_attacks.list[tt.attack_units_index].decal_warning = "decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_units_index].max_range = 99999999
tt.timed_attacks.list[tt.attack_units_index].min_range = 0
tt.timed_attacks.list[tt.attack_units_index].enabled = true
tt.timed_attacks.list[tt.attack_units_index].stun_fliers = true
tt.timed_attacks.list[tt.attack_units_index].mod_stun_wardens = "mod_boss_stage_40_stun_wardens"
tt.events.list[1].name = "stun_stage"
tt.events.list[1].on_event = controller_stage_40_boss_shadow_waves_on_stun_stage
