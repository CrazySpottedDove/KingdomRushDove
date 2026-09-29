local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local AC = require("achievements")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_01_robin_hood_update
local decal_stage_01_campfire_guy_campfire_update
local decal_stage_01_rune_update
decal_stage_01_robin_hood_update = function(this, store)
	local can_click = true
	local clicked = false
	local last_attack = store.tick_ts
	this.attack_cooldown = math.random(this.attack_cooldown_min, this.attack_cooldown_max)
	U.y_animation_play_group(this, this.animation_idle, nil, store.tick_ts, false, "layers")
	local d = E:create_entity(this.mask_to_spawn)
	d.pos = V.v(512, 384)
	simulation:queue_insert_entity(d)
	while true do
		if clicked then
		elseif can_click and this.ui.clicked then
			this.ui.clicked = nil
			S:queue(this.clicked_sound)
			while true do
				U.animation_start_group(this, this.animation_click, nil, store.tick_ts, false, "layers")
				if U.y_wait_unconditional(store, fts(87)) then
				else
					d.render.sprites[1].hidden = false
					signal.emit("robin-stage01", this)
					U.y_animation_wait_group(this, "layers")
					break
				end
				coroutine.yield()
			end
			can_click = false
			clicked = true
		elseif store.tick_ts - last_attack > this.attack_cooldown then
			U.y_animation_play_group(this, this.animation_attack, nil, store.tick_ts, false, "layers")
			this.attack_cooldown = math.random(this.attack_cooldown_min, this.attack_cooldown_max)
			last_attack = store.tick_ts
		else
			U.y_animation_play_group(this, this.animation_idle, nil, store.tick_ts, false, "layers")
		end
		coroutine.yield()
	end
end
decal_stage_01_campfire_guy_campfire_update = function(this, store)
	local count = 0
	local count_limit = 2
	while true do
		if this.ui.clicked then
			if count < count_limit then
				S:queue(this.sound_fire_off)
				U.y_animation_play(this, "extinguish", nil, store.tick_ts, 1, this.campfire_sprite_id)
				U.animation_start(this, "smoke_idle", nil, store.tick_ts, true, this.campfire_sprite_id)
				U.y_animation_play(this, "action", nil, store.tick_ts, 1, this.guy_sprite_id)
				S:queue(this.sound_fire_on)
				U.y_animation_play(this, "lit", nil, store.tick_ts, 1, this.campfire_sprite_id)
				this.ui.clicked = nil
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
				count = count + 1
			elseif count == count_limit then
				S:queue(this.sound_fire_final)
				U.y_animation_play(this, "extinguish", nil, store.tick_ts, 1, this.campfire_sprite_id)
				U.animation_start(this, "smoke_idle", nil, store.tick_ts, true, this.campfire_sprite_id)
				U.animation_start(this, "leaves", nil, store.tick_ts, false, this.guy_sprite_id)
				U.y_wait_unconditional(store, fts(64))
				U.y_animation_play(this, "big_fire", nil, store.tick_ts, 1, this.campfire_sprite_id)
				U.animation_start(this, "idle_burnt", nil, store.tick_ts, false, this.campfire_sprite_id)
				this.ui.clicked = nil
				this.render.sprites[this.guy_sprite_id].draw_order = 10
				U.y_animation_wait(this, this.guy_sprite_id, 1)
				U.animation_start(this, "idle_gone", nil, store.tick_ts, false, this.guy_sprite_id)
				U.y_animation_play(this, "closes", nil, store.tick_ts, 1, this.tent_front_sprite_id)
				U.animation_start(this, "idle_closed_tent", nil, store.tick_ts, false, this.tent_front_sprite_id)
				count = count + 1
				signal.emit("bonfire-stage01", this)
			end
		end
		coroutine.yield()
	end
end
decal_stage_01_rune_update = function(this, store)
	local s = this.render.sprites[1]
	local c = this.click_play
	local clicks = 0
	while true do
		if clicks >= c.required_clicks and c.play_once then
		else
			if this.ui.clicked then
				this.ui.clicked = nil
				clicks = clicks + 1
			end
			if clicks >= c.required_clicks then
				if this.tween then
					this.tween.disabled = false
				elseif not c.idle_animation then
					s.hidden = false
				end
				S:queue(c.clicked_sound)
				U.y_animation_play(this, c.click_animation, nil, store.tick_ts, 1)
				this.ui.clicked = nil
				U.animation_start_default(this, c.idle_on_animation, nil, store.tick_ts, true)
				signal.emit("achievements_custom_event", "RUNEQUEST_1")
				if c.achievement then
					AC:got(c.achievement)
				end
				if c.achievement_flag then
					AC:flag_check(unpack(c.achievement_flag))
				end
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_01_butterfly_2", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_1_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt = E:register_t_hot("decal_stage_01_robin_hood", "decal_scripted", true)
E:add_comps(tt, "editor", "editor_script", "ui")
for i = 2, 6 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "robin_hood_easter_egg_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end
tt.clicked_sound = "Stage01RobinHood"
tt.animation_idle = "idle"
tt.animation_click = "fall"
tt.animation_attack = "attack"
tt.attack_cooldown_min = 4
tt.attack_cooldown_max = 7
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.main_script.update = decal_stage_01_robin_hood_update
tt.mask_to_spawn = "decal_stage_01_robin_hood_mask"
tt = E:register_t_hot("decal_stage1_waterfall1", "decal_loop", true)
tt.render.sprites[1].name = "stage1_waterfall_1"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage1_waterfall_ripples", "decal_loop", true)
tt.render.sprites[1].name = "stage1_waterfall_ripples"
tt = E:register_t_hot("decal_stage_01_decos_waterfall", "decal", true)
tt.render.sprites[1].name = "Stage_1_decos_waterfall_1"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_stage_01_campfire_guy_campfire", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].name = "campfire_guy_tent_back"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "campfire_guy_guy"
tt.render.sprites[2].offset = v(-36, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "campfire_guy_campfire"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "campfire_guy_tent_front"
tt.render.sprites[4].offset = v(-36, 5)
tt.render.sprites[4].draw_order = 11
tt.main_script.update = decal_stage_01_campfire_guy_campfire_update
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.sound_fire_off = "Stage01FireOff"
tt.sound_fire_on = "Stage01FireOn"
tt.sound_fire_final = "Stage01FireFinal"
tt.guy_sprite_id = 2
tt.campfire_sprite_id = 3
tt.tent_front_sprite_id = 4
tt = E:register_t_hot("decal_stage_01_butterfly_1", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_1_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30
tt = E:register_t_hot("stage_01_bush", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "Stage_1_tutorial_bush"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage1_waterfall2", "decal_loop", true)
tt.render.sprites[1].name = "stage1_waterfall_2"
tt = E:register_t_hot("decal_stage_01_elder_rune", "decal_click_play", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "Stage_1_rapido_elder_rune_1"
tt.render.sprites[1].loop = true
tt.main_script.update = decal_stage_01_rune_update
tt.click_play.idle_animation = "idle"
tt.click_play.click_animation = "activation"
tt.click_play.idle_on_animation = "idle_2"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage01Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt = E:register_t_hot("decal_stage1_decos_waterfalltop", "decal", true)
tt.render.sprites[1].name = "Stage_1_decos_waterfalltop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_stage_01_wisps", "decal", true)
tt.render.sprites[1].prefix = "stage_1_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_1_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt = E:register_t_hot("stage_01_shaman", "decal", true)
tt.render.sprites[1].prefix = "Stage_1_tutorial_shaman"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
