local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local SU = require("script_utils")
local scripts = require("scripts")
local r = V.r
local controller_stage_19_navira_update
local decal_stage_19_statue_update
controller_stage_19_navira_update = function(this, store)
	local taunt_ts = store.tick_ts
	local taunt_cd = math.random(this.taunts.delay_min, this.taunts.delay_max) + 5
	local fire_balls_ts = store.tick_ts
	local balls = {}
	local statue_hands
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_19_statue_hands" then
			statue_hands = e
			break
		end
	end
	local function find_tower(towers_chosen)
		local towers = {}
		for _, v in pairs(store.entities) do
			if v.tower and not v.tower.blocked and not v.tower_holder and v.tower.can_be_mod and not table.contains(towers_chosen, v) then
				table.insert(towers, v)
			end
		end
		return towers[math.random(1, #towers)]
	end
	local function shoot_fire_ball(tower, ball)
		local b = E:create_entity(this.fire_ball_bullet_t)
		b.pos = V.vclone(ball.pos)
		b.pos.y = b.pos.y + 40
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.vclone(tower.pos)
		b.bullet.target_id = tower.id
		b.bullet.source_id = this.id
		simulation:queue_insert_entity(b)
	end
	local function break_fn()
		return this.start_bossfight or store.waves_finished and not LU.has_alive_enemies(store)
	end
	while not this.start_bossfight do
		coroutine.yield()
		if taunt_cd < store.tick_ts - taunt_ts and (store.wave_group_number == 0 or LU.has_alive_enemies(store)) then
			SU.y_show_taunt_set(store, this.taunts, "pre_bossfight", false)
			taunt_ts = store.tick_ts
			taunt_cd = math.random(this.taunts.delay_min, this.taunts.delay_max)
		end
		if store.wave_group_number > 0 and LU.has_alive_enemies(store) and store.tick_ts - fire_balls_ts > this.fire_balls_cd - this.fire_balls_wait_between_balls then
			for i = 1, this.fire_balls_count do
				local ball = E:create_entity(this.fire_ball_t)
				ball.render.sprites[1].name = string.format(ball.render.sprites[1].name, i)
				ball.render.sprites[1].ts = store.tick_ts
				ball.render.sprites[1].hidden = true
				simulation:queue_insert_entity(ball)
				table.insert(balls, ball)
			end
			local rot_controller = E:create_entity(this.fire_ball_rotation_controller_t)
			rot_controller.balls_count = this.fire_balls_count
			rot_controller.balls = balls
			rot_controller.center_pos = this.pos
			simulation:queue_insert_entity(rot_controller)
			for _, v in pairs(balls) do
				if U.y_wait_conditional(store, this.fire_balls_wait_between_balls, break_fn) then
					goto label_1337_0
				end
				v.render.sprites[1].hidden = false
				S:queue(this.sound_fireball_spawn)
				U.y_animation_play(v, "spawn", nil, store.tick_ts)
				U.animation_start_default(v, "idle", nil, store.tick_ts, true)
			end
			if U.y_wait_conditional(store, this.fire_balls_wait_before_shoot, break_fn) then
				break
			end
			local towers_chosen = {}
			local tower = find_tower(towers_chosen)
			while not tower do
				if U.y_wait_unconditional(store, fts(10), break_fn) then
					goto label_1337_0
				end
				tower = find_tower(towers_chosen)
			end
			U.animation_start_default(this, "sealofruin", nil, store.tick_ts, false)
			if U.y_wait_unconditional(store, fts(50), break_fn) then
				break
			end
			S:queue(this.sound_fireball_cast)
			for _, b in pairs(balls) do
				tower = find_tower(towers_chosen)
				if tower then
					shoot_fire_ball(tower, b)
					table.insert(towers_chosen, tower)
					U.y_wait_unconditional(store, this.fire_balls_wait_between_shots)
				end
				simulation:queue_remove_entity(b)
			end
			simulation:queue_remove_entity(rot_controller)
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			balls = {}
			fire_balls_ts = store.tick_ts
		end
	end
	::label_1337_0::
	for _, b in pairs(balls) do
		if b then
			simulation:queue_remove_entity(b)
		end
	end
	while not this.start_bossfight do
		coroutine.yield()
	end
	local fx = E:create_entity(this.hands_dust_1_t)
	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(fx)
	local fx = E:create_entity(this.hands_dust_2_t)
	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(fx)
	local fx = E:create_entity(this.hands_stones_1_t)
	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(fx)
	local fx = E:create_entity(this.hands_stones_2_t)
	fx.pos = V.vclone(this.pos)
	fx.render.sprites[1].ts = store.tick_ts
	simulation:queue_insert_entity(fx)
	S:queue(this.sound_hands_down)
	S:queue(this.sound_hands_up)
	U.animation_start_default(statue_hands, "hands_shake", nil, store.tick_ts)
	U.y_animation_play(this, "shake_in", nil, store.tick_ts)
	U.y_animation_play(this, "shake_down", nil, store.tick_ts)
	U.y_animation_play(this, "shake_out", nil, store.tick_ts)
	this.ended_entrance = true
end
decal_stage_19_statue_update = function(this, store)
	local current_step = 1
	if store.level_mode == GAME_MODE_CAMPAIGN then
		this.ui.can_click = false
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			if current_step < 3 then
				S:queue(this.sound_12)
			else
				S:queue(this.sound_3)
			end
			local action_name = "action_" .. current_step
			local idle_name = "idle_" .. current_step + 1
			U.y_animation_play(this, action_name, nil, store.tick_ts, 1)
			U.animation_start_default(this, idle_name, nil, store.tick_ts, true)
			current_step = current_step + 1
			if current_step < 4 then
				this.ui.can_click = true
			else
				signal.emit("rock-paper-scissors-stage19", this)
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_19_bubbles_water", "decal", true)
tt.render.sprites[1].prefix = "stage_19_bubbles_waterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_19_mask_3", "decal", true)
tt.render.sprites[1].name = "stage19_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("controller_stage_19_navira", "decal_scripted", true)
E:add_comps(tt, "taunts", "editor")
tt.main_script.update = controller_stage_19_navira_update
tt.render.sprites[1].prefix = "navira_navira"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].hidden = true
tt.taunts.delay_min = 20
tt.taunts.delay_max = 30
tt.taunts.sets = {}
tt.taunts.sets.pre_bossfight = CC("taunt_set")
tt.taunts.sets.pre_bossfight.format = "LV19_NAVIRA_TAUNT_%02i"
tt.taunts.sets.pre_bossfight.end_idx = 6
tt.fire_balls_count = 3
tt.fire_balls_cd = 25
tt.fire_balls_wait_between_balls = 5
tt.fire_balls_wait_before_shoot = 1
tt.fire_balls_wait_between_shots = 0.2
tt.fire_ball_t = "navira_fire_ball"
tt.fire_ball_bullet_t = "bullet_stage_19_navira_fire_ball_ray"
tt.fire_ball_rotation_controller_t = "controller_stage_19_navira_ball_rotation"
tt.hands_dust_1_t = "fx_stage_19_statue_hands_dust_1"
tt.hands_dust_2_t = "fx_stage_19_statue_hands_dust_2"
tt.hands_stones_1_t = "fx_stage_19_statue_hands_stones_1"
tt.hands_stones_2_t = "fx_stage_19_statue_hands_stones_2"
tt.cape_t = "decal_stage_19_navira_cape"
tt.sound_enter = "Stage19NaviraEnter"
tt.sound_fireball_spawn = "Stage19NaviraFireballSpawn"
tt.sound_fireball_cast = "Stage19NaviraFireballCast"
tt.sound_hands_down = "Stage19NaviraHandsDown"
tt.sound_hands_up = "Stage19NaviraHandsUp"
tt = E:register_t_hot("decal_stage_19_smoke", "decal", true)
tt.render.sprites[1].prefix = "stage_19_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t_hot("decal_stage_19_bubbles", "decal", true)
tt.render.sprites[1].prefix = "stage_19_bubblesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_19_mask_2", "decal", true)
tt.render.sprites[1].name = "stage19_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_19_statue", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.ui.click_rect = r(272, 110, 60, 60)
tt.main_script.update = decal_stage_19_statue_update
tt.render.sprites[1].prefix = "stage_19_statue_decoDef"
tt.render.sprites[1].name = "idle_campaign"
tt.render.sprites[1].exo = true
tt.sound_12 = "Stage19Statue12"
tt.sound_3 = "Stage19Statue3"
