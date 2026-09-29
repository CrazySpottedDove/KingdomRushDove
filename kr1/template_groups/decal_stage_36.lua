local E = require("entity_db")
local v = V.v
local scripts = require("game_scripts")
local tt
local U = require("utils")
local S = require("sound_db")
local ACH = require("achievements")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end

local decal_stage_36_easter_egg_spyro = {}

function decal_stage_36_easter_egg_spyro.insert(this, store, script)
	return store.level_mode == GAME_MODE_CAMPAIGN
end

function decal_stage_36_easter_egg_spyro.update(this, store, script)
	local islas

	for _, v in pairs(store.entities) do
		if v.template_name == "decal_stage_36_mask_islas" then
			islas = v

			break
		end
	end

	local spyro = this.render.sprites[1]
	local column = this.render.sprites[2]
	local coupled_island = islas.render.sprites[this.stay_island[1]]
	local first_island = islas.render.sprites[this.stay_island[1]]

	spyro.offset = coupled_island.offset

	local clicks = 0

	while true do
		spyro.offset = coupled_island.offset
		column.offset = first_island.offset

		if (store.wave_group_number > 2 or this.leave) and clicks < 2 then
			S:queue("Stage36EasterEggSpyroJump")
			U.animation_start_specific(this, "fly_in", false, store.tick_ts, false, 1)

			local wait_start_ts = store.tick_ts

			while store.tick_ts - wait_start_ts < fts(8) do
				column.offset = first_island.offset

				coroutine.yield()
			end

			local speed = V.v(-160, 30)
			local g = -20
			local wind = 30

			while this.pos.x > -1000 do
				if U.animation_finished_default(this) and spyro.name == "fly_in" then
					U.animation_start(this, "fly_loop", nil, store.tick_ts, true, 1, true)
				end

				column.offset = first_island.offset
				this.pos.x = this.pos.x + speed.x * store.tick_length
				this.pos.y = this.pos.y + speed.y * store.tick_length

				if this.pos.x < 50 then
					speed.x = speed.x + wind * store.tick_length
				end

				speed.y = speed.y + g * store.tick_length

				coroutine.yield()
			end
		end

		if this.ui.clicked then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false

			if clicks == 1 then
				S:queue("Stage36EasterEggSpyroJump")
				U.animation_start(this, "fly_in", nil, store.tick_ts, false, 1, true)

				local wait_start_ts = store.tick_ts

				while store.tick_ts - wait_start_ts < fts(8) do
					column.offset = first_island.offset

					coroutine.yield()
				end

				coupled_island = islas.render.sprites[this.stay_island[2]]

				local end_pos = V.v(-36, 530)
				local speed = V.v(-160, 120)
				local g = -220
				local wind = 30

				while V.dist(this.pos.x, this.pos.y, end_pos.x, end_pos.y) > 20 do
					if U.animation_finished_default(this) and spyro.name == "fly_in" then
						U.animation_start(this, "fly_loop", nil, store.tick_ts, true, 1, true)
					end

					local offset_diff = coupled_island.offset.y - spyro.offset.y

					if math.abs(offset_diff) < 1 then
						spyro.offset.y = coupled_island.offset.y
					else
						spyro.offset.y = spyro.offset.y + offset_diff * 4 * store.tick_length
					end

					column.offset = first_island.offset
					this.pos.x = this.pos.x + speed.x * store.tick_length
					this.pos.y = this.pos.y + speed.y * store.tick_length

					if this.pos.x < 100 then
						speed.x = speed.x + wind * store.tick_length
					end

					speed.y = speed.y + g * store.tick_length

					coroutine.yield()
				end

				local fx = E:create_entity(this.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
				U.animation_start(this, "fly_out", nil, store.tick_ts, false, 1, true)

				while math.abs(speed.x) > 10 do
					column.offset = first_island.offset
					speed.x = speed.x * 0.6
					this.pos.x = this.pos.x + speed.x * store.tick_length

					coroutine.yield()
				end

				U.y_animation_wait_default(this)
				U.animation_start(this, "idle2", nil, store.tick_ts, true, 1, true)

				this.ui.can_click = true
			elseif clicks == 2 then
				S:queue("Stage36EasterEggSpyroJump")
				S:queue("Stage36EasterEggSpyroFall")
				U.y_animation_play(this, "death", nil, store.tick_ts, 1, 1)
				U.y_wait_unconditional(store, 0.2)
				ACH:got("DLC3_SPYRO")
				simulation:queue_remove_entity(this)

				return
			end
		end

		coroutine.yield()
	end
end

local decal_stage_36_mask_islas = {}

function decal_stage_36_mask_islas.insert(this, store, script)
	for _, p in ipairs(this.tween.props) do
		p.ts = store.tick_ts - p.keys[2][1] * math.random()
	end

	return true
end

tt = E:register_t_hot("decal_stage_36_mask_islas", "decal_tween", true)
E:add_comps(tt, "main_script")
tt.main_script.insert = decal_stage_36_mask_islas.insert
tt.islas_levels = {
	TOP = Z_BACKGROUND_COVERS + 1,
	MID = Z_BACKGROUND_BETWEEN - 1,
	BACK = Z_BACKGROUND_BETWEEN - 2
}
tt.islas_settings = {
	{
		str = 6,
		z = "TOP",
		freq = 120
	},
	{
		str = 6,
		z = "MID",
		freq = 120,
		skip = true
	},
	{
		str = 6,
		z = "MID",
		freq = 120
	},
	{
		str = 6,
		z = "MID",
		freq = 120
	},
	{
		str = 6,
		z = "MID",
		freq = 120
	},
	{
		str = -6,
		z = "MID",
		freq = 120
	},
	{
		str = 6,
		z = "MID",
		freq = 120
	},
	{
		str = 6,
		z = "MID",
		freq = 120
	},
	{
		str = 6,
		z = "BACK",
		freq = 120
	},
	{
		str = 6,
		z = "BACK",
		freq = 120
	},
	{
		str = 6,
		z = "BACK",
		freq = 120
	},
	{
		str = 6,
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
		tt.render.sprites[tt.temp_i].name = "stage_36_isla_" .. i
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

tt = E:register_t_hot("decal_stage_36_easter_egg_spyro", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.insert = decal_stage_36_easter_egg_spyro.insert
tt.main_script.update = decal_stage_36_easter_egg_spyro.update
tt.render.sprites[1].prefix = "spyro_me_creep"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN + 2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_36_isla_6_mask"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BACKGROUND_BETWEEN + 3
tt.render.sprites[2].pos = v(512, 384)
tt.fx = "fx_spyro_smoke"
tt.stay_island = {
	[1] = 5,
	[2] = 4
}
tt.ui.click_rect = r(-40, -20, 80, 80)

