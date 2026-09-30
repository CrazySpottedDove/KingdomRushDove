local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local SU = require("script_utils")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_02_fishing_link_insert
local decal_stage_02_fishing_link_update
local decal_stage_02_lion_king_insert
local decal_stage_02_lion_king_update
local trees_guardian_tree_insert
local trees_guardian_tree_update
decal_stage_02_fishing_link_insert = function(this, store)
	local e = E:create_entity(this.entity_line)
	e.pos = this.pos
	e.fishing_link = this
	simulation:queue_insert_entity(e)
	return true
end
decal_stage_02_fishing_link_update = function(this, store)
	local c = this.click_play
	local line_move_cd = math.random(this.min_line_move_cd, this.max_line_move_cd)
	local last_water_move_ts = store.tick_ts
	local water_move_cd = math.random(this.min_water_move_cd, this.max_water_move_cd)
	local last_line_move_ts = store.tick_ts
	this.window_duration = math.random(this.min_window_duration, this.max_window_duration)
	local started_first_wave = false
	while true do
		if not started_first_wave and store.wave_group_number > 0 then
			this.line_move = false
			line_move_cd = math.random(this.min_line_move_cd, this.max_line_move_cd)
			last_line_move_ts = store.tick_ts
			water_move_cd = math.random(this.min_water_move_cd, this.max_water_move_cd)
			last_water_move_ts = store.tick_ts
			this.window_duration = math.random(this.min_window_duration, this.max_window_duration)
			this.water_move = false
			started_first_wave = true
		end
		if this.ui.clicked then
			this.fish_anim = 1
			if store.wave_group_number > 0 then
				this.fish_anim = math.random(2, 3)
			end
			this.fishing = true
			U.animation_start_default(this, this.fish_animations[this.fish_anim], nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(30))
			S:queue(c.clicked_sound)
			U.y_animation_wait_default(this)
			line_move_cd = math.random(this.min_line_move_cd, this.max_line_move_cd)
			last_line_move_ts = store.tick_ts
			this.ui.clicked = nil
			this.fishing = false
		end
		if water_move_cd < store.tick_ts - last_water_move_ts then
			water_move_cd = math.random(this.min_water_move_cd, this.max_water_move_cd)
			last_water_move_ts = store.tick_ts
			this.water_move = true
			while this.water_move do
				coroutine.yield()
			end
		end
		if store.wave_group_number > 0 and line_move_cd < store.tick_ts - last_line_move_ts then
			this.line_move = true
			U.y_animation_play(this, "rupees_notice_in", nil, store.tick_ts)
			U.animation_start_default(this, "rupees_notice_loop", nil, store.tick_ts, true)
			local start_ts = store.tick_ts
			while true do
				if this.ui.clicked then
					this.fishing = true
					this.fish_anim = 4
					U.animation_start_default(this, "rupees_notice_clicked", nil, store.tick_ts, false)
					U.y_wait_unconditional(store, fts(10))
					S:queue(c.clicked_sound)
					U.y_wait_unconditional(store, fts(30))
					local gold_pos = V.v(this.pos.x + this.gold_pos_offset.x, this.pos.y + this.gold_pos_offset.y)
					signal.emit("got-gold", gold_pos, this.gold_amount)
					signal.emit("link-stage02", this)
					U.y_animation_wait_default(this)
					this.ui.clicked = nil
					this.fishing = false
					break
				end
				if store.tick_ts - start_ts > this.window_duration then
					U.y_animation_play(this, "rupees_notice_out", nil, store.tick_ts)
					break
				end
				coroutine.yield()
			end
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			this.line_move = false
			line_move_cd = math.random(this.min_line_move_cd, this.max_line_move_cd)
			last_line_move_ts = store.tick_ts
			water_move_cd = math.random(this.min_water_move_cd, this.max_water_move_cd)
			last_water_move_ts = store.tick_ts
			this.window_duration = math.random(this.min_window_duration, this.max_window_duration)
			this.water_move = false
		end
		coroutine.yield()
	end
end
decal_stage_02_lion_king_insert = function(this, store)
	this.light = E:create_entity(this.entity_light)
	this.light.pos = v(979, 428)
	simulation:queue_insert_entity(this.light)
	return true
end
decal_stage_02_lion_king_update = function(this, store)
	local last_change = store.tick_ts
	local stick_cd = math.random(this.min_cooldown_idle, this.max_cooldown_idle)
	while true do
		if this.ui.clicked then
			this.ui.can_click = false
			this.ui.clicked = nil
			S:queue(this.clicked_sound)
			this.light.tween.disabled = false
			this.light.tween.ts = store.tick_ts
			this.light.render.sprites[1].hidden = false
			U.y_animation_play_group(this, this.animation_click, nil, store.tick_ts, false, "layers")
			last_change = store.tick_ts
			stick_cd = math.random(this.min_cooldown_idle, this.max_cooldown_idle)
			signal.emit("lion_king-stage02", this)
		end
		if this.ui.can_click and stick_cd < store.tick_ts - last_change then
			U.y_animation_play_group(this, this.animation_idle2, nil, store.tick_ts, false, "layers")
			last_change = store.tick_ts
			stick_cd = math.random(this.min_cooldown_idle, this.max_cooldown_idle)
		end
		coroutine.yield()
	end
end
trees_guardian_tree_insert = function(this, store)
	return true
end
trees_guardian_tree_update = function(this, store)
	local a = this.custom_attack
	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)
	a.ts = store.tick_ts - a.cooldown
	local is_active_on_wave = false
	local function should_be_on()
		local current_wave = store.wave_group_number
		local current_config = this.wave_config[current_wave]
		return current_config
	end
	local function can_shoot()
		return store.tick_ts - a.ts > a.cooldown
	end
	U.y_animation_play_group(this, this.animation_idle_sleep, nil, store.tick_ts, false, "layers")
	while true do
		if is_active_on_wave then
			if not should_be_on() then
				U.y_animation_play_group(this, this.animation_go_to_sleep, nil, store.tick_ts, false, "layers")
				U.y_animation_play_group(this, this.animation_idle_sleep, nil, store.tick_ts, false, "layers")
				is_active_on_wave = false
			else
				if can_shoot() then
					local enemies = U.find_enemies_between_range_filter_off(this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
					if not enemies then
						SU.delay_attack(store, a, 0.133333)
						goto label_790_0
					end
					a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)
					a.ts = store.tick_ts
					S:queue(this.sound_pre_cast)
					U.animation_start_group(this, a.animation, nil, store.tick_ts, false, "layers")
					if U.y_wait_unconditional(store, a.shoot_time) then
						goto label_790_0
					end
					S:queue(this.sound_cast)
					local p = E:create_entity(a.entity)
					p.pos = V.vclone(this.pos)
					local ni = P:get_end_node(p.wave_pi)
					p.wave_ni = ni
					simulation:queue_insert_entity(p)
					S:queue(this.sound_roots)
					U.y_animation_wait_default(this)
				end
				U.animation_start_default(this, this.animation_idle_awake, nil, store.tick_ts)
				U.y_wait_unconditional(store, fts(95), can_shoot())
			end
		elseif should_be_on() then
			U.y_animation_play_group(this, this.animation_go_to_awake, nil, store.tick_ts, false, "layers")
			is_active_on_wave = true or is_active_on_wave
		end
		::label_790_0::
		coroutine.yield()
	end
end
local tt
local decal_stage_02_rune
local ACH = require("achievements")
decal_stage_02_rune = {}

function decal_stage_02_rune.insert(this, store)
	this.base_rock = E:create_entity(this.base_rock_entity)
	this.base_rock.pos = this.pos

	simulation:queue_insert_entity(this.base_rock)

	return true
end

function decal_stage_02_rune.update(this, store)
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
		-- block empty
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

			signal.emit("achievements_custom_event", "RUNEQUEST_2")

			if c.achievement then
				ACH:got(c.achievement)
			end

			if c.achievement_flag then
				ACH:flag_check(unpack(c.achievement_flag))
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_02_elder_rune_static", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_2_rapido_elder_rune_2_0117"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false

tt = E:register_t_hot("decal_stage_02_lion_king", "decal_scripted", true)
E:add_comps(tt, "ui")
for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "lion_king_easter_egg_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end
tt.main_script.insert = decal_stage_02_lion_king_insert
tt.main_script.update = decal_stage_02_lion_king_update
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.clicked_sound = "Stage02LionKing"
tt.animation_idle = "idle"
tt.animation_idle2 = "stick"
tt.animation_click = "action"
tt.min_cooldown_idle = 4
tt.max_cooldown_idle = 7
tt.entity_light = "decal_stage_02_lion_king_light"

tt = E:register_t_hot("decal_stage_02_veznan", "decal_scripted", true)
E:add_comps(tt, "editor", "editor_script")
tt.render.sprites[1].prefix = "veznan_cinematic_veznan"
tt.render.sprites[1].name = "idle"

tt = E:register_t_hot("decal_stage_02_fishing_link", "decal_click_play", true)
tt.render.sprites[1].prefix = "fishing_link"
tt.render.sprites[1].loop = true
tt.main_script.insert = decal_stage_02_fishing_link_insert
tt.main_script.update = decal_stage_02_fishing_link_update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage02LinkFishing"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.entity_line = "decal_stage_02_fishing_link_line"
tt.entity_water_splash = "decal_stage_02_fishing_link_water_splash"
tt.min_water_move_cd = 3
tt.max_water_move_cd = 7
tt.min_line_move_cd = 60
tt.max_line_move_cd = 90
tt.min_window_duration = 3
tt.max_window_duration = 3
tt.animation_line_move = ""
tt.gold_pos_offset = v(-10, 40)
tt.gold_amount = 25
tt.fish_animations = {"fishing_nothing", "fishing_nothing", "fishing_fish_or_boot", "fishing_nothing", "fishing_nothing"}

tt = E:register_t_hot("decal_waterfall_splash", "decal_loop", true)
tt.render.sprites[1].name = "stage_2_props_waterfall_splash"

tt = E:register_t_hot("decal_waterfall", "decal_loop", true)
tt.render.sprites[1].name = "stage_2_props_waterfall"

tt = E:register_t_hot("trees_guardian_tree", "decal_scripted", true)
E:add_comps(tt, "custom_attack", "cheats", "editor")
tt.tree_disabled = false
tt.wave_config = {true, true, true, true, true, true, true, true}
tt.custom_attack.cooldown = nil
tt.custom_attack.cooldown_min = 16
tt.custom_attack.cooldown_max = 16
tt.custom_attack.max_range = 450
tt.custom_attack.min_range = 15
tt.custom_attack.animation = "attack"
tt.custom_attack.aura = "trees_guardian_tree_vine_aura_decal"
tt.custom_attack.sound = "ElvesPlantMissile"
tt.custom_attack.shoot_time = fts(35)
tt.custom_attack.entity = "trees_guardian_tree_wave_of_roots"
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_BOSS, F_FLYING, F_FRIEND, F_HERO)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "Stage02TreePart2Def"
tt.render.sprites[1].name = "idle_sleep"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "Stage02TreeDef"
tt.render.sprites[2].name = "idle_sleep"
tt.render.sprites[2].exo = true
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].sort_y_offset = -40
tt.animation_idle_sleep = "idle_sleep"
tt.animation_go_to_awake = "back_to_idle_awake"
tt.animation_idle_awake = "idle_awake"
tt.animation_go_to_sleep = "back_to_idle_sleep"
tt.main_script.insert = trees_guardian_tree_insert
tt.main_script.update = trees_guardian_tree_update
tt.editor.overrides = {
	["render.sprites[2].name"] = "idle_sleep"
}
tt.cheats.buttons[1].text = "TreeDecal"
tt.cheats.buttons[1].fn = function(button, store, e)
end
tt.cheats.buttons[2] = E:clone_c("cheats_text_button")
tt.cheats.buttons[2].text = "TreeCD"
tt.cheats.buttons[2].fn = function(button, store, e)
	e.custom_attack.ts = store.tick_ts - e.custom_attack.cooldown
end
tt.cheats.buttons[3] = E:clone_c("cheats_text_button")
tt.cheats.buttons[3].text = "TreeRanges"
tt.cheats.buttons[3].fn = function(button, store, e)
	for _, range in ipairs({e.custom_attack.max_range, e.custom_attack.min_range}) do
		local hp = E:create_entity("decal_debug_range")
		hp.pos.x, hp.pos.y = e.pos.x, e.pos.y
		hp.radius = range
		simulation:queue_insert_entity(hp)
	end
end
tt.cheats.buttons[4] = E:clone_c("cheats_text_button")
tt.cheats.buttons[4].text = "TreeONOFF"
tt.cheats.buttons[4].fn = function(button, store, e)
	local current_wave = store.wave_group_number
	local current_config = e.wave_config[current_wave]
	e.wave_config[current_wave] = not current_config
end
tt.sound_pre_cast = "Stage02GuardianTreePreCast"
tt.sound_cast = "Stage02GuardianTreeCast"
tt.sound_roots = "Stage02GuardianTreeRoots"

tt = E:register_t_hot("decal_stage_02_elder_rune", "decal_click_play", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "stage_2_rapido_elder_rune_2_fx"
tt.render.sprites[1].loop = true
tt.main_script.insert = decal_stage_02_rune.insert
tt.main_script.update = decal_stage_02_rune.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0203Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(0, -30, 60, 60)
tt.base_rock_entity = "decal_stage_02_elder_rune_base"

tt = E:register_t_hot("decal_stage_02_fishing_link_water_splash", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "water_splash"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = true

