local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local r = V.r
local decal_stage_22_easteregg_sheepy_update
decal_stage_22_easteregg_sheepy_update = function(this, store)
	local touch_times = 0
	local speed = 30
	local start_pos = V.vclone(this.pos)
	local function y_sheepy_walk(dest)
		U.animation_start_default(this, "running", nil, store.tick_ts, true)
		this.render.sprites[1].flip_x = dest.x > this.pos.x
		local distance = 1000
		while distance > 5 do
			local vx, vy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
			local v_angle = V.angleTo(vx, vy)
			local v_len = V.len(vx, vy)
			distance = v_len
			if distance > 5 then
				local step = speed * store.tick_length
				local nx, ny = V.normalize(V.rotate(v_angle, 1, 0))
				local sx, sy = V.mul(step, nx, ny)
				this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
			else
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				return
			end
			coroutine.yield()
		end
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1
			if touch_times == 1 then
				y_sheepy_walk(V.v(start_pos.x - 65, start_pos.y))
				U.y_wait_unconditional(store, 0.4)
				y_sheepy_walk(V.v(start_pos.x, start_pos.y))
				U.y_wait_unconditional(store, 0.4)
				y_sheepy_walk(V.v(start_pos.x - 20, start_pos.y + 10))
				this.ui.can_click = true
			elseif touch_times == 2 then
				U.y_animation_play(this, "action1", nil, store.tick_ts)
				this.ui.can_click = true
			elseif touch_times == 3 then
				y_sheepy_walk(V.v(start_pos.x - 20, start_pos.y - 23))
				U.y_animation_play(this, "death", nil, store.tick_ts)
				simulation:queue_remove_entity(this)
				return
			end
		end
		coroutine.yield()
	end
end
local tt
local decal_achievement_stage_22_croc_king
local decal_stage_22_remolino
local decal_stage_22_rune_rock
local signal = require("lib.hump.signal")
decal_achievement_stage_22_croc_king = {}

function decal_achievement_stage_22_croc_king.update(this, store)
	local touch_times = 0
	local flying = false

	while not flying do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1

			if touch_times == 1 then
				U.y_animation_play(this, "tap1", nil, store.tick_ts)
				U.animation_start_default(this, "idle2", nil, store.tick_ts, true)

				this.ui.can_click = true
			elseif touch_times == 2 then
				U.y_animation_play(this, "tap2", nil, store.tick_ts)
				U.animation_start_default(this, "idle2", nil, store.tick_ts, true)

				this.ui.can_click = true
			elseif touch_times == 3 then
				U.y_animation_play(this, "tap3", nil, store.tick_ts)
				U.animation_start_default(this, "loop", nil, store.tick_ts, true)

				this.pos.y = this.pos.y - 5
				flying = true
				this.render.sprites[1].z = Z_OBJECTS_SKY
			end
		end

		coroutine.yield()
	end

	local speedX = -0.05
	local max_speedX = -4

	while flying do
		this.pos.x = this.pos.x + speedX
		this.pos.y = this.pos.y + 5
		speedX = math.max(max_speedX, speedX * 1.1)

		if this.pos.y > 900 then
			signal.emit("flying-king-croc-stage22")
			simulation:queue_remove_entity(this)
		end

		coroutine.yield()
	end
end

decal_stage_22_remolino = {}

function decal_stage_22_remolino.update(this, store)
	local wave_index = 0
	local run_this_wave = false
	local wave_start_ts = store.tick_ts
	local interval_index = 1
	local wave_config = {}
	local waves_mode = this.waves[store.level_mode]
	local FROM = 1
	local TO = 2

	while true do
		if wave_index ~= store.wave_group_number or this.start_wave_boss then
			wave_index = store.wave_group_number

			if this.start_wave_boss then
				wave_config = waves_mode.BOSS
			else
				wave_config = waves_mode[store.wave_group_number]
			end

			run_this_wave = wave_config and #wave_config > 0
			wave_start_ts = store.tick_ts
			interval_index = 1
			this.start_wave_boss = false
		end

		if run_this_wave and store.tick_ts >= wave_start_ts + wave_config[interval_index][FROM] then
			this.render.sprites[1].hidden = false

			U.y_animation_play(this, this.animation_start, nil, store.tick_ts)
			U.animation_start_default(this, this.animation_loop, nil, store.tick_ts, true)
			U.y_wait_unconditional(store, wave_config[interval_index][TO] - wave_config[interval_index][FROM])
			U.y_animation_wait_default(this)
			U.y_animation_play(this, this.animation_end, nil, store.tick_ts)

			this.render.sprites[1].hidden = true
			interval_index = interval_index + 1

			if interval_index > #wave_config then
				run_this_wave = false
			end
		end

		coroutine.yield()
	end
end

decal_stage_22_rune_rock = {}

function decal_stage_22_rune_rock.update(this, store)
	while true do
		if this.boss_eating then
			U.y_animation_play(this, this.animation_start, nil, store.tick_ts)
			U.animation_start_default(this, this.animation_loop, nil, store.tick_ts, true)

			while this.boss_eating do
				coroutine.yield()
			end

			U.y_animation_play(this, this.animation_end, nil, store.tick_ts)
			U.animation_start_default(this, this.animation_idle, nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

local S = require("sound_db")
local band = bit.band
local function fts(v)
	return v / FPS
end

local controller_stage_22_boss_crocs = {}

function controller_stage_22_boss_crocs.update(this, store)
	local previous_wave_index = store.wave_group_number
	local run_this_wave = false
	local cooldown = 0
	local max_casts = 99
	local casts = 0
	local next_ts = store.tick_ts
	local taunt_index = 1
	local idle_anim_next_ts = store.tick_ts

	local function update_idle_anim_next_ts()
		idle_anim_next_ts = store.tick_ts + this.idle_anims_min_cd + (this.idle_anims_max_cd - this.idle_anims_min_cd) * math.random()
	end

	update_idle_anim_next_ts()
	U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

	local function get_towers_to_eat()
		local towers = table.filter(store.towers, function(k, v)
			local is_tower = not v.pending_removal and (not this.excluded_templates or not table.contains(this.excluded_templates, v.template_name)) and v.vis and band(v.vis.flags, this.vis_bans) == 0 and band(v.vis.bans, this.vis_flags) == 0 and v.tower.can_be_mod
			return is_tower
		end)

		return towers
	end

	while true do
		if previous_wave_index ~= store.wave_group_number then
			previous_wave_index = store.wave_group_number
			run_this_wave = false

			for i, v in ipairs(this.waves) do
				if store.wave_group_number == v then
					run_this_wave = true
					cooldown = this.cooldown[i]
					casts = 0
					max_casts = this.max_casts[i]
					next_ts = store.tick_ts + this.first_cooldown[i]

					break
				end
			end
		end

		if run_this_wave and casts < max_casts and next_ts <= store.tick_ts then
			casts = casts + 1

			local towers = get_towers_to_eat()

			if towers and #towers > 0 then
				U.animation_start_default(this, this.skill_anim, nil, store.tick_ts, false)

				for _, e in pairs(store.entities) do
					if e.template_name == "tower_stage_22_arborean_mages" then
						e.boss_is_going_to_eat = true

						break
					end
				end

				U.y_wait_unconditional(store, fts(10))
				S:queue(this.sound_release_arm_cinematic)
				U.y_wait_unconditional(store, fts(55))

				for _, e in pairs(store.entities) do
					if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
						e.boss_eating = true
					end

					if e.template_name == "tower_stage_22_arborean_mages" then
						e.boss_eating = true
					end
				end

				U.y_wait_unconditional(store, fts(22))

				towers = get_towers_to_eat()

				if towers and #towers > 0 then
					towers = table.random_order(towers)

					local twr = towers[1]
					local mods_in_tower = table.filter(store.entities, function(_, ee)
						return ee.modifier and ee.modifier.target_id == twr.id
					end)

					for _, mod_in_tower in pairs(mods_in_tower) do
						simulation:queue_remove_entity(mod_in_tower)
					end

					local mod = E:create_entity(this.mod)

					mod.modifier.target_id = twr.id
					mod.modifier.source_id = this.id
					mod.use_secondary_anim = true
					mod.muted = true

					simulation:queue_insert_entity(mod)
				end

				U.y_wait_unconditional(store, fts(2))

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 1.5
				shake.aura.duration = 2
				shake.aura.freq_factor = 2

				simulation:queue_insert_entity(shake)
				U.y_wait_unconditional(store, fts(98))
				S:queue(this.sound_catch_arm)
				U.y_wait_unconditional(store, fts(30))

				local shake = E:create_entity("aura_screen_shake")

				shake.aura.amplitude = 1
				shake.aura.duration = 1
				shake.aura.freq_factor = 2

				simulation:queue_insert_entity(shake)
				U.y_animation_wait_default(this)
				U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

				next_ts = store.tick_ts + cooldown

				U.y_wait_unconditional(store, 0.5)
				signal.emit("show-balloon_tutorial", "LV22_BOSS_BEFORE_FIGHT_EAT_0" .. taunt_index, false)
				U.y_wait_unconditional(store, 3.5)
				signal.emit("show-balloon_tutorial", "LV22_MAGE_BEFORE_FIGHT_RESPONSE_0" .. taunt_index, false)

				taunt_index = taunt_index + 1

				if taunt_index > this.taunt_keys_amount then
					taunt_index = 1
				end

				update_idle_anim_next_ts()
			else
				next_ts = store.tick_ts + cooldown
			end
		end

		if this.start_cinematic_eat then
			this.start_cinematic_eat = false

			local towers = get_towers_to_eat()

			U.animation_start_default(this, this.skill_anim, nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(10))
			S:queue(this.sound_release_arm_cinematic)
			U.y_wait_unconditional(store, fts(55))

			for _, e in pairs(store.entities) do
				if e.template_name == "decal_stage_22_rune_rock" or e.template_name == "decal_stage_22_rune_doors" then
					e.boss_eating = true
				end

				if e.template_name == "tower_stage_22_arborean_mages" then
					e.appear = true
					e.boss_eating = true
				end
			end

			U.y_wait_unconditional(store, fts(22))

			if towers and #towers > 0 then
				towers = table.random_order(towers)

				local twr = towers[1]
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = twr.id
				mod.modifier.source_id = this.id
				mod.use_secondary_anim = true
				mod.muted = true

				simulation:queue_insert_entity(mod)
			end

			U.y_wait_unconditional(store, fts(2))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 2.5
			shake.aura.duration = 2
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, fts(98))
			S:queue(this.sound_catch_arm)
			U.y_wait_unconditional(store, fts(30))

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 1
			shake.aura.duration = 1
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(this)
			U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)

			next_ts = store.tick_ts + cooldown

			update_idle_anim_next_ts()

			this.cinematic_eat_finished = true
		end

		if idle_anim_next_ts < store.tick_ts then
			local random_idle = table.random(this.idle_anims)

			U.y_animation_wait(this, 1, this.render.sprites[1].runs + 1)
			U.y_animation_play(this, random_idle, nil, store.tick_ts)
			U.animation_start(this, this.default_idle, nil, store.tick_ts, true, 1, true)
			update_idle_anim_next_ts()
		end

		if this.do_exit then
			U.y_animation_wait(this, 1, this.render.sprites[1].runs + 1)
			S:queue(this.sound_set_free)
			U.y_animation_play(this, this.anim_exit, nil, store.tick_ts)

			this.finished = true

			while not this.rocks_fall do
				coroutine.yield()
			end

			U.animation_start(this, "bossFight", nil, store.tick_ts, true, 1, true)

			return
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_22_easteregg_sheepy", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.main_script.update = decal_stage_22_easteregg_sheepy_update
tt.render.sprites[1].prefix = "croco_sheepy"
tt.render.sprites[1].name = "idle"
tt.ui.click_rect = r(-15, -5, 30, 50)

tt = E:register_t_hot("decal_stage_22_water_vfx1", "decal", true)
tt.render.sprites[1].prefix = "stage_22_bubbles_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_22_puerta5", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta5"
tt.render.sprites[1].animated = false

tt = E:register_t_hot("decal_stage_22_puerta3", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 290

tt = E:register_t_hot("decal_stage_22_puerta4", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 290

tt = E:register_t_hot("tunnel_KR5_stage22_boss", "tunnel_KR5", true)
tt.untargetable_distance = 20
tt.tunnel.speed_factor = 1000

tt = E:register_t_hot("decal_stage_22_puerta1", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta1"
tt.render.sprites[1].animated = false

tt = E:register_t_hot("decal_stage_22_sombras", "decal", true)
tt.render.sprites[1].name = "stage_22_sombras"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("decal_stage_22_puerta6", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_22_water_vfx2", "decal_stage_22_water_vfx1", true)
tt.render.sprites[1].prefix = "stage_22_bubbles_02Def"

tt = E:register_t_hot("decal_stage_22_puerta2", "decal", true)
tt.render.sprites[1].name = "stage_22_puerta2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_22_rune_rock", "decal_scripted", true)
tt.main_script.update = decal_stage_22_rune_rock.update
tt.animation_idle = "idle1"
tt.animation_start = "redin"
tt.animation_loop = "redloop"
tt.animation_end = "redout"
tt.render.sprites[1].prefix = "rune_rockDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("decal_stage_22_rune_doors", "decal_scripted", true)
tt.main_script.update = decal_stage_22_rune_rock.update
tt.animation_idle = "idleblue"
tt.animation_start = "redin"
tt.animation_loop = "idlered"
tt.animation_end = "redout"
tt.render.sprites[1].prefix = "stage_22_Glow_Rock1Def"
tt.render.sprites[1].name = tt.animation_idle
tt.render.sprites[1].exo = true
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_22_Glow_Rock2Def"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "stage_22_Glow_Rock3Def"
tt.render.sprites[3].sort_y_offset = 100
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].prefix = "stage_22_Glow_Rock4Def"
tt.render.sprites[5] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[5].prefix = "stage_22_Glow_Rock5Def"
tt.render.sprites[5].sort_y_offset = -100
tt.render.sprites[5].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_22_remolino", "decal_scripted", true)

tt.main_script.update = decal_stage_22_remolino.update
tt.animation_start = "in"
tt.animation_loop = "loop"
tt.animation_end = "out"
tt.render.sprites[1].prefix = "remolino_stage_3_anim"
tt.render.sprites[1].name = tt.animation_start
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.waves = {{
	[3] = {{28, 41}},
	[4] = {{35, 48}, {67, 80}},
	[6] = {{12, 25}, {32, 45}},
	[7] = {{25, 95}},
	[9] = {{15, 24}, {75, 84}},
	[10] = {{5, 52}},
	[12] = {{12, 21}, {42, 51}},
	[13] = {{5, 48}},
	[14] = {{5, 20}, {70, 85}},
	[15] = {{8, 18}, {48, 58}},
	BOSS = {{31, 480}}
}, {
	[2] = {{19.5, 27.5}, {43, 51.5}},
	[3] = {{0.2, 4}},
	[4] = {{27, 90}},
	[5] = {{14, 24}},
	[6] = {{0, 5}, {25, 63}}
}, {{{115, 319}}}}

tt = E:register_t_hot("decal_achievement_stage_22_croc_king", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.ui.click_rect = r(-20, -10, 40, 40)
tt.main_script.update = decal_achievement_stage_22_croc_king.update
tt.render.sprites[1].prefix = "achievement_donkey_kong_creep"
tt.render.sprites[1].name = "idle"

tt = E:register_t_hot("controller_stage_22_boss_crocs", "decal_scripted", true)
E:add_comps(tt, "editor")
tt.main_script.update = controller_stage_22_boss_crocs.update
tt.render.sprites[1].prefix = "boss_crocs_intro_bossDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].sort_y_offset = 300
tt.mod = "mod_boss_crocs_tower_eat"
tt.waves = {3, 5, 7, 9, 11, 13, 15}
tt.first_cooldown = {5, 5, 7, 1, 15, 10, 10, 5, 1}
tt.cooldown = {0, 0, 0, 40, 45, 35, 40, 26, 20}
tt.max_casts = {1, 1, 1, 1, 1, 1, 1}
tt.excluded_templates = {"tower_stage_22_arborean_mages"}
tt.default_idle = "idle_1"
tt.idle_anims = {"idle_2"}
tt.idle_anims_min_cd = 4
tt.idle_anims_max_cd = 10
tt.taunt_keys_amount = 8
tt.skill_anim = "skill"
tt.anim_exit = "exit"
tt.vis_bans = 0
tt.vis_flags = 0
tt.sound_set_free = "Stage22AbominorSetFree"
tt.sound_release_arm = "Stage22AbominorReleaseArm"
tt.sound_release_arm_cinematic = "Stage22AbominorReleaseArmEatTowerOneshot"
tt.sound_catch_arm = "Stage22AbominorCatchArm"

