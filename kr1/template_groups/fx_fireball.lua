local E = require("entity_db")
local v = V.v
local scripts = require("game_scripts")
local U = require("utils")
local S = require("sound_db")
local signal = require("lib.hump.signal")
local P = require("path_db")
local V = require("lib.klua.vector")
local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end
local function fts(v)
	return v / FPS
end
local tt = E:register_t_tmp("fx_stage_32_redboy_transform_fire", "fx")
tt.render.sprites[1].prefix = "dragon_redboy_transformDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -30)

tt = E:register_t_tmp("fx_stage_32_fireball_right", "decal_scripted")
tt.main_script.update = function(this, store)
	local function y_meteorite_shake(store, duration)
		S:queue("TerrainWukongMeteoriteCast")

		local shake_travel = E:create_entity("aura_screen_shake")

		shake_travel.aura.amplitude = 0.4
		shake_travel.aura.duration = duration
		shake_travel.aura.freq_factor = 5
		shake_travel.aura.reverse_fade = true

		simulation:queue_insert_entity(shake_travel)

		local spawn_wait_time = 1.5

		U.y_wait_unconditional(store, spawn_wait_time)
		S:queue("TerrainWukongMeteoriteTravelLoop")

		local shake_start = E:create_entity("aura_screen_shake")

		shake_start.aura.amplitude = 0.9
		shake_start.aura.duration = 0.5
		shake_start.aura.freq_factor = 4

		simulation:queue_insert_entity(shake_start)
		U.y_wait_unconditional(store, duration - spawn_wait_time)
		S:stop("TerrainWukongMeteoriteTravelLoop")
		S:queue("TerrainWukongMeteoriteImpact")

		local shake_impact = E:create_entity("aura_screen_shake")

		shake_impact.aura.amplitude = 2
		shake_impact.aura.duration = 1.5
		shake_impact.aura.freq_factor = 4

		simulation:queue_insert_entity(shake_impact)
	end

	local function instakill_units(store, max_x, max_y, min_x, min_y)
		for _, v in pairs(store.entities) do
			if v.pending_removal or not v.vis or not v.health or v.health.dead or not v.pos or band(v.vis.bans, this.flags_meteorite) ~= 0 or band(v.vis.flags, this.bans_meteorite) ~= 0 then
			-- block empty
			else
				local inside_kill_radius = false

				for ni = 0, P:get_end_node(this.path), this.ni_step do
					if U.is_inside_ellipse(v.pos, P:node_pos(this.path, 1, ni), this.kill_radius) then
						inside_kill_radius = true

						break
					end
				end

				if not inside_kill_radius then
				-- block empty
				else
					local d = E.assign_damage(bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS), 10, this.id, v.id)

					queue_damage(store, d)
				end
			end
		end
	end

	local function instakill_with_area_id()
		for _, v in pairs(store.entities) do
			if (v.template_name == "decal_generic_kill_area" or v.template_name == "decal_generic_kill_area_rect") and v.kill_area_id == this.kill_area_id then
				v:kill_area_fn(store)
			end
		end
	end

	local function create_fires()
		for path, nodes in pairs(this.path_fires) do
			local ni = nodes.begin

			while ni <= nodes.finish do
				local fx = E:create_entity("decal_dlc_wukong_flaming_ground")

				fx.pos = P:node_pos(path, 1, ni)
				fx.render.sprites[1].scale = V.vv(0.7 + 0.3 * math.random())
				fx.render.sprites[1].flip_x = math.random() > 0.5
				fx.duration = this.fire_duration + 1 * math.random()
				fx.start_wait = 1 * math.random()

				simulation:queue_insert_entity(fx)

				ni = ni + 5

				local fx = E:create_entity("decal_dlc_wukong_flaming_ground_small")

				fx.pos = P:node_pos(path, table.random({2, 3}), ni)
				fx.render.sprites[1].scale = V.vv(0.8)
				fx.render.sprites[1].flip_x = math.random() > 0.5
				fx.duration = this.fire_duration + 1 * math.random()
				fx.start_wait = 1 * math.random()

				simulation:queue_insert_entity(fx)

				ni = ni + 5
			end
		end
	end

	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[2].ts = store.tick_ts

	y_meteorite_shake(store, fts(this.shake_time))

	if this.kill_area_id then
		instakill_with_area_id()
	else
		instakill_units(store, this.max_x, this.max_y, this.min_x, this.min_y)
	end

	create_fires()
	U.y_animation_wait(this, 2)
	U.sprites_hide(this, 2, 2, false)
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end
tt.render.sprites[1].prefix = "stage_32_fireball_rDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_31_sign_decal_rDef"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].exo = true
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS
tt.shake_time = 150
tt.flags_meteorite = bor(F_RANGED, F_AREA)
tt.bans_meteorite = bor(F_BOSS)
tt.ni_step = 3
tt.path = 3
tt.kill_radius = 80
tt.force_move_impact_positions = {v(800, 326)}
tt.fire_duration = 15
tt.path_fires = {
	[3] = {
		finish = 100,
		begin = 20
	},
	[4] = {
		finish = 60,
		begin = 50
	}
}

tt = E:register_t_tmp("fx_stage_32_fireball_left", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_32_fireball_lDef"
tt.render.sprites[2].prefix = "stage_31_sign_decal_lDef"
tt.path = 2
tt.force_move_impact_positions = {v(207, 226)}
tt.path_fires = {
	[2] = {
		finish = 120,
		begin = 20
	},
	{
		finish = 50,
		begin = 40
	}
}

tt = E:register_t_tmp("fx_stage_35_fireball_left", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_35_fireball_lDef"
tt.render.sprites[2].prefix = "stage5_samadhi_2Def"
tt.kill_area_id = 1
tt.path_fires = {{
	finish = 180,
	begin = 20
}}

tt = E:register_t_tmp("fx_stage_35_fireball_right", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_35_fireball_rDef"
tt.render.sprites[2].prefix = "stage5_samadhi_1Def"
tt.kill_area_id = 2
tt.path_fires = {
	[2] = {
		finish = 130,
		begin = 20
	}
}
