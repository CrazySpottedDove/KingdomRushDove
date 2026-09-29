local log = require("lib.klua.log"):new("level01")
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
local AC = require("achievements")
local scripts = require("scripts")
local v = V.v
local r = V.r
local controller_stage_06_tiki_bar_insert
local controller_stage_06_tiki_bar_update
local decal_stage_06_door_update
local controller_stage_06_minecraft_easter_egg_update
local decal_stage_06_elder_rune_update
local decal_boss_pig_pool_update
controller_stage_06_tiki_bar_insert = function(this, store)
	this.baby1 = E:create_entity(this.entity_baby1)
	this.baby1.pos = this.pos
	simulation:queue_insert_entity(this.baby1)
	this.baby2 = E:create_entity(this.entity_baby2)
	this.baby2.pos = this.pos
	simulation:queue_insert_entity(this.baby2)
	this.barman = E:create_entity(this.entity_barman)
	this.barman.pos = this.pos
	simulation:queue_insert_entity(this.barman)
	this.old_man = E:create_entity(this.entity_old_man)
	this.old_man.pos = this.pos
	simulation:queue_insert_entity(this.old_man)
	return true
end
controller_stage_06_tiki_bar_update = function(this, store)
	local baby_1_ts = store.tick_ts
	local baby_1_cd = math.random(8, 12)
	local baby_2_ts = store.tick_ts
	local baby_2_cd = math.random(8, 12)
	local barman_ts = store.tick_ts
	local barman_cd = math.random(8, 12)
	while true do
		if baby_1_cd < store.tick_ts - baby_1_ts then
			U.animation_start_default(this.baby1, "Idle2", false, store.tick_ts, false)
			baby_1_ts = store.tick_ts
			baby_1_cd = math.random(8, 12)
		end
		if baby_2_cd < store.tick_ts - baby_2_ts then
			U.animation_start_default(this.baby2, "idle2", false, store.tick_ts, false)
			baby_2_ts = store.tick_ts
			baby_2_cd = math.random(8, 12)
		end
		if barman_cd < store.tick_ts - barman_ts then
			U.animation_start_default(this.barman, "action", false, store.tick_ts, false)
			barman_ts = store.tick_ts
			barman_cd = math.random(8, 12)
		end
		coroutine.yield()
	end
end
decal_stage_06_door_update = function(this, store)
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_door
	this.opened = false
	for key, value in pairs(spawners) do
		if value.load_file == "level106_door" then
			megaspawner_door = value
		end
	end
	local door = this.render.sprites[5]
	local pig = this.render.sprites[6]
	local pig_handle = this.render.sprites[7]
	local sp = this.spawner
	local pigOrigin = v(-120, 150)
	local pigDestination = v(-75, 20)
	local door_height = 50
	local wave_counter = 1
	local start_ts = store.tick_ts
	local phase
	local pig_clicks = 0
	local pig_dead = false
	local door_time = 10
	local offset_base_x = door.offset.x
	local offset_base_y = door.offset.y
	while true do
		if sp.spawn_data == nil then
		elseif not sp.spawn_data.open then
		else
			start_ts = store.tick_ts
			phase = 0
			pig_clicks = 0
			pig_dead = false
			this.ui.can_click = true
			U.animation_start_specific(this, "walkingDown", false, store.tick_ts, true, 6)
			this.tween.disabled = false
			this.tween.reverse = true
			this.tween.ts = store.tick_ts
			repeat
				phase = (store.tick_ts - start_ts) / 5
				pig.offset.x = U.ease_value(pigOrigin.x, pigDestination.x, phase, "linear")
				pig.offset.y = U.ease_value(pigOrigin.y, pigDestination.y, phase, "linear")
				pig.hidden = false
				this.ui.click_rect = r(pig.offset.x - 25, pig.offset.y - 10, 50, 50)
				if this.ui.clicked then
					this.ui.clicked = nil
					S:queue(this.pig_click_sound)
					pig_clicks = pig_clicks + 1
					if pig_clicks >= this.clicks_to_kill then
						pig_dead = true
						break
					else
						this.tween.props[2].disabled = false
						this.tween.props[2].ts = store.tick_ts
						this.tween.props[3].disabled = true
					end
				end
				coroutine.yield()
			until phase >= 1
			if pig_dead then
				sp.spawn_data = nil
				S:queue(this.pig_death_sound)
				U.animation_start(this, "death", nil, store.tick_ts, false, 6)
				U.y_animation_wait(this, 6)
				this.tween.disabled = false
				this.tween.ts = store.tick_ts
				this.tween.reverse = false
				this.ui.can_click = false
			else
				pig.hidden = true
				start_ts = store.tick_ts
				door.hidden = false
				U.animation_start_specific(this, "ability1_1", false, store.tick_ts, true, 7)
				pig_handle.hidden = false
				U.animation_start_group(this, "ability1_1", nil, store.tick_ts, true, "layers")
				S:queue("Stage06WoodenDoorOpen")
				repeat
					phase = (store.tick_ts - start_ts) / door_time
					door.offset.y = U.ease_value(offset_base_y, door_height, phase, "linear")
					door.offset.x = offset_base_x + math.random(-1, 1)
					if this.ui.clicked then
						this.ui.clicked = nil
						S:queue(this.pig_click_sound)
						pig_clicks = pig_clicks + 1
						if pig_clicks >= this.clicks_to_kill then
							pig_dead = true
							break
						else
							this.tween.props[2].disabled = true
							this.tween.props[3].ts = store.tick_ts
							this.tween.props[3].disabled = false
						end
					end
					coroutine.yield()
				until phase >= 1
				S:stop("Stage06WoodenDoorOpen")
				if pig_dead then
					sp.spawn_data = nil
					U.animation_start_specific(this, "ability5_1", false, store.tick_ts, false, 4)
					S:queue("Stage06WoodenDoorClose")
					S:queue(this.pig_death_sound)
					U.animation_start_specific(this, "death1_1", false, store.tick_ts, false, 7)
					U.y_animation_wait(this, 7)
					repeat
						phase = (store.tick_ts - start_ts) / 0.5
						door.offset.y = U.ease_value(door_height, offset_base_y, phase, "sine-out")
						coroutine.yield()
					until phase >= 1
					U.animation_start_group(this, "ability5_1", nil, store.tick_ts, false, "layers")
					door.hidden = true
				else
					this.opened = true
					U.animation_start_group(this, "idle1_1", nil, store.tick_ts, true, "layers")
					U.animation_start_specific(this, "ability2_1", false, store.tick_ts, true, 7)
					megaspawner_door.manual_wave = "DOOR" .. wave_counter
					wave_counter = wave_counter + 1
					while sp.spawn_data == nil do
						coroutine.yield()
					end
					while sp.spawn_data.open do
						if this.ui.clicked then
							this.ui.clicked = nil
							S:queue(this.pig_click_sound)
							pig_clicks = pig_clicks + 1
							if not pig_dead and pig_clicks >= this.clicks_to_kill then
								pig_dead = true
								S:queue(this.pig_death_sound)
								U.animation_start_specific(this, "death1_1", false, store.tick_ts, false, 7)
								U.y_animation_wait(this, 7)
							else
								this.tween.props[3].disabled = false
								this.tween.props[3].ts = store.tick_ts
								this.tween.props[2].disabled = true
							end
						end
						coroutine.yield()
					end
					if not pig_dead then
						S:queue(this.pig_death_sound)
						U.animation_start_specific(this, "death1_1", false, store.tick_ts, false, 7)
					end
					log.info("close the door")
					start_ts = store.tick_ts
					U.animation_start_group(this, "ability4_1", nil, store.tick_ts, true, "layers")
					S:queue("Stage06WoodenDoorClose")
					repeat
						phase = (store.tick_ts - start_ts) / 0.5
						door.offset.y = U.ease_value(door_height, offset_base_y, phase, "sine-out")
						coroutine.yield()
					until phase >= 1
					door.hidden = true
					U.animation_start_group(this, "ability5_1", nil, store.tick_ts, false, "layers")
				end
			end
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
controller_stage_06_minecraft_easter_egg_update = function(this, store)
	local miners = {}
	local count = 0
	for k, v in pairs(store.entities) do
		if v.template_name == "decal_stage_06_minecraft_easter_egg" then
			miners[count + 1] = v
			v.controller = this
			count = count + 1
		end
	end
	this.dead = 0
	while true do
		if this.dead == 3 then
			signal.emit("minecraft-stage06", this)
			return true
		end
		coroutine.yield()
	end
end
decal_stage_06_elder_rune_update = function(this, store)
	local s = this.render.sprites[1]
	local c = this.click_play
	local clicks = 0
	local already_played = false
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
		end
		if c.play_once and already_played then
		elseif clicks >= c.required_clicks then
			if this.tween then
				this.tween.disabled = false
			elseif not c.idle_animation then
				s.hidden = false
			end
			S:queue(c.clicked_sound)
			U.y_animation_play(this, c.click_animation, nil, store.tick_ts, 1)
			this.ui.clicked = nil
			clicks = 0
			already_played = true
			if not c.idle_animation then
				s.hidden = true
			else
				U.animation_start_default(this, c.idle_animation, nil, store.tick_ts, true)
			end
			signal.emit("achievements_custom_event", "RUNEQUEST_6")
			if c.achievement then
				AC:got(c.achievement)
			end
			if c.achievement_flag then
				AC:flag_check(unpack(c.achievement_flag))
			end
		end
		coroutine.yield()
	end
end
decal_boss_pig_pool_update = function(this, store)
	local function boss_pig_on_field()
		for _, e in pairs(store.entities) do
			if not e.pending_removal and e.template_name == "boss_pig" then
				return true
			end
		end
		return false
	end
	local function can_taunt()
		if this.taunts_disabled or this.pending_removal or boss_pig_on_field() then
			return false
		end
		local anim = this.render.sprites[1] and this.render.sprites[1].name
		if anim == "salto" then
			return false
		end
		return LU.has_alive_enemies(store)
	end
	while store.wave_group_number < 10 do
		coroutine.yield()
	end
	while not this.taunts_disabled and (not store.waves_finished or LU.has_alive_enemies(store)) do
		local delay = math.random(this.taunts.delay_min, this.taunts.delay_max)
		U.y_wait_unconditional(store, delay)
		if this.taunts_disabled then
			break
		end
		if store.waves_finished and not LU.has_alive_enemies(store) then
			break
		end
		if can_taunt() then
			local set = this.taunts.sets.from_pool
			local index = math.random(set.start_idx, set.end_idx)
			signal.emit("show-balloon_tutorial", string.format(set.format, index), false)
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_pool_party5", "decal", true)
E:add_comps(tt, "editor")
for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_volleyball_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end
tt = E:register_t_hot("stage_06_hole_mask", "decal", true)
tt.render.sprites[1].name = "stage_6_maskmadriguera"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -75
tt = E:register_t_hot("decal_boss_pig_pool", "decal_scripted", true)
E:add_comps(tt, "taunts", "editor")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "GoregrindPoolDef"
tt.render.sprites[1].name = "sleeping"
tt.main_script.update = decal_boss_pig_pool_update
tt.taunts.delay_min = 10
tt.taunts.sets = {}
tt.taunts.sets.from_pool = CC("taunt_set")
tt.taunts.sets.from_pool.format = "LV06_BOSS_TAUNT_%02i"
tt.taunts.sets.from_pool.end_idx = 6
tt.sound_horn = "Stage06BossPigHorn"
tt = E:register_t_hot("stage_06_hole", "decal", true)
tt.render.sprites[1].prefix = "stage_6_madriguera"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_pool_party1", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_6_poolparty_deco_water"
tt.render.sprites[1].z = Z_DECALS - 1
tt = E:register_t_hot("decal_pool_party2", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "stage_6_poolparty_deco"
tt.render.sprites[1].z = Z_DECALS - 1
tt = E:register_t_hot("stage_06_mask_door", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_6_maskascensor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t_hot("decal_pool_party4", "decal", true)
E:add_comps(tt, "editor")
for i = 1, 2 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_demon_jump_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end
tt = E:register_t_hot("stage_06_door", "decal_scripted", true)
E:add_comps(tt, "spawner", "sound_events", "editor", "ui", "tween")
tt.main_script.update = decal_stage_06_door_update
for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "stage_6_ascensor_ascensor_layer" .. i
	tt.render.sprites[i].name = "idle1_1"
	tt.render.sprites[i].group = "layers"
end
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "stage_6_ascensor_door"
tt.render.sprites[5].animated = false
tt.render.sprites[5].z = Z_OBJECTS_COVERS
tt.render.sprites[5].offset.x = 8.9
tt.render.sprites[5].offset.y = -13.2
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].prefix = "tusked_brawler"
tt.render.sprites[6].hidden = true
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].prefix = "stage_6_ascensor_jabali"
tt.render.sprites[7].hidden = true
tt.render.sprites[7].offset.x = -70
tt.render.sprites[7].offset.y = 15
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].name = "stage_6_ascensor_ascensor_dust"
tt.render.sprites[8].animated = false
tt.render.sprites[8].z = Z_DECALS
tt.spawner.eternal = true
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].name = "stage_6_ascensor_ascensor_dust"
tt.render.sprites[8].animated = false
tt.render.sprites[8].z = Z_DECALS
tt.render.sprites[8].offset.x = 15
tt.render.sprites[8].offset.y = -55
tt.render.sprites[7].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[4].z = Z_OBJECTS_COVERS + 2
tt.render.sprites[3].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[1].z = Z_DECALS
tt.ui.can_click = false
tt.ui.click_rect = r(0, 0, 50, 50)
tt.clicks_to_kill = 3
tt.pig_death_sound = "EnemyTuskedBrawlerDeath"
tt.pig_click_sound = "Stage06EasterEggMinecraftClick"
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {5, 0}}
tt.tween.props[1].sprite_id = 6
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(1, 1)}, {fts(1), v(1.2, 1.2)}, {fts(3), v(1, 1)}}
tt.tween.props[2].disabled = true
tt.tween.props[2].sprite_id = 6
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, v(1, 1)}, {fts(1), v(1.2, 1.2)}, {fts(3), v(1, 1)}}
tt.tween.props[3].disabled = true
tt.tween.props[3].sprite_id = 7
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.run_once = false
tt = E:register_t_hot("controller_stage_06_tiki_bar", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.insert = controller_stage_06_tiki_bar_insert
tt.main_script.update = controller_stage_06_tiki_bar_update
tt.entity_baby1 = "decal_tiki_bar2"
tt.entity_baby2 = "decal_tiki_bar3"
tt.entity_barman = "decal_tiki_bar5"
tt.entity_old_man = "decal_tiki_bar4"
tt = E:register_t_hot("decal_pool_party6", "decal", true)
E:add_comps(tt, "editor")
for i = 1, 2 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_music_arborean_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end
tt = E:register_t_hot("decal_pool_party7", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = TEXTURE_SIZE_ALIAS
tt.render.sprites[1].name = "stage_6_poolparty_deco_baby"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_06_cult_leader", "decal_scripted", true)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "mydrias_cinematic"
tt.render.sprites[1].name = "idle"
tt = E:register_t_hot("controller_stage_06_minecraft_easter_egg", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_06_minecraft_easter_egg_update
tt = E:register_t_hot("decal_gold_mount", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_06_parches_espada"
tt.render.sprites[1].z = Z_DECALS - 1
tt = E:register_t_hot("decal_pool_party3", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "stage_6_poolparty_deco_sleeping_arborean"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("stage_06_mask_1", "decal", true)
tt.render.sprites[1].name = "stage_6_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_06_elder_rune_static", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_6_elder_rune_6_0125"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt = E:register_t_hot("decal_pool_party8", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_6_poolparty_deco_weapons"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_tiki_bar6", "decal_tiki_bar1", true)
tt.render.sprites[1].name = "stage_06_parches_tiki_top"
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t_hot("decal_stage_06_elder_rune", "decal_click_play", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "stage_6_elder_rune_6"
tt.render.sprites[1].loop = true
tt.main_script.update = decal_stage_06_elder_rune_update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0506Rune"
tt.ui.click_rect = r(-70, -10, 90, 60)
