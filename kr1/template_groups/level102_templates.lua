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

tt = E:register_t_hot("decal_stage_02_elder_rune_base", "decal", true)
E:add_comps(tt, "main_script")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_2_rapido_elder_rune_2_base"
tt.render.sprites[1].sort_y_offset = 1

tt = E:register_t_hot("decal_stage_02_fishing_link_line", "decal_scripted", true)
tt.render.sprites[1].prefix = "fishing_link_line"
tt.render.sprites[1].loop = true
tt.main_script.update = function(this, store)
	local water_splash

	for _, v in pairs(store.entities) do
		if v.template_name == "decal_stage_02_fishing_link_water_splash" then
			water_splash = v

			break
		end
	end

	water_splash.render.sprites[1].hidden = true

	while true do
		if this.fishing_link.water_move then
			water_splash.render.sprites[1].hidden = false

			U.y_animation_play(water_splash, "idle", nil, store.tick_ts, false)

			water_splash.render.sprites[1].hidden = true
			this.fishing_link.water_move = false
		end

		if this.fishing_link.line_move then
			U.y_animation_play(this, "fishing_rupee_in", nil, store.tick_ts)
			U.animation_start_default(this, "fishing_rupee_loop", nil, store.tick_ts, true)

			local start_ts = store.tick_ts

			while not this.fishing_link.fishing do
				if store.tick_ts - start_ts > this.fishing_link.window_duration then
					U.y_animation_play(this, "fishing_rupee_out", nil, store.tick_ts)

					break
				end

				coroutine.yield()
			end
		end

		if this.fishing_link.fishing then
			if this.render.sprites[1].name == "fishing_rupee_loop" then
				water_splash.render.sprites[1].hidden = false

				U.animation_start_default(water_splash, "splash_out", nil, store.tick_ts, false)
				U.animation_start_default(this, "fishing_rupee_clicked", nil, store.tick_ts)
				U.y_wait_unconditional(store, fts(61))
				U.animation_start_default(water_splash, "splash_in", nil, store.tick_ts, false)
				U.y_animation_wait_default(this)
			else
				if this.fishing_link.fish_anim == 1 or this.fishing_link.fish_anim == 2 then
					U.y_wait_unconditional(store, fts(1))
				end

				U.animation_start_default(this, this.fish_animations[this.fishing_link.fish_anim], nil, store.tick_ts, false)
				U.y_wait_unconditional(store, fts(41))

				water_splash.render.sprites[1].hidden = false

				if this.fishing_link.fish_anim ~= 1 and this.fishing_link.fish_anim ~= 5 then
					U.animation_start_default(water_splash, "splash_out", nil, store.tick_ts, false)
				end

				if this.fishing_link.fish_anim == 3 then
					U.y_wait_unconditional(store, fts(78))
				else
					U.y_wait_unconditional(store, fts(52))
				end

				U.animation_start_default(water_splash, "splash_in", nil, store.tick_ts, false)
			end

			U.y_animation_wait_default(this.fishing_link)

			this.fishing_link.water_move = false
		end

		coroutine.yield()
	end
end
tt.fish_animations = {"fishing_nothing", "fishing_boot", "fishing_fish", "fishing_rupee", "fishing_nothing"}

tt = E:register_t_hot("decal_stage_02_lion_king_light", "decal_scripted", true)
E:add_comps(tt, "ui", "tween")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "light_copy"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].hidden = true
tt.tween.props[1].keys = {{0, 0}, {fts(29), 255}, {fts(77), 255}, {fts(102), 0}}
tt.tween.remove = false
tt.tween.disabled = true

tt = E:register_t_hot("trees_guardian_tree_wave_of_roots", nil, true)
E:add_comps(tt, "pos", "main_script")
tt.main_script.update = function(this, store)
	local count = this.count
	local wave_pi = this.wave_pi
	local wave_ni = this.wave_ni + this.start_offset
	local rootCounter = 0
	local max_duration = 6

	local function createDecal(node_pos)
		local e = E:create_entity(this.decal)

		e.render.sprites[1].prefix = e.render.sprites[1].prefix .. 1 + rootCounter % 5
		rootCounter = rootCounter + 1
		e.pos = node_pos
		e.pos.x = e.pos.x + math.random(-10, 10)
		e.render.sprites[1].ts = store.tick_ts
		e.render.sprites[1].flip_x = math.random(0, 1) == 1
		e.sequence.steps[2] = max_duration - rootCounter * 0.1

		simulation:queue_insert_entity(e)
	end

	local pos1 = this.root_hand_L_pos
	local pos2 = this.root_hand_R_pos
	local node_pos = P:node_pos(wave_pi, 1, wave_ni + this.root_hand_offset_path_merge)
	local length1 = V.dist(pos1.x, pos1.y, node_pos.x, node_pos.y)
	local length2 = V.dist(pos2.x, pos2.y, node_pos.x, node_pos.y)
	local v1 = v(node_pos.x - pos1.x, node_pos.y - pos1.y)
	local v2 = v(node_pos.x - pos2.x, node_pos.y - pos2.y)

	v1.x = v1.x / length1
	v1.y = v1.y / length1

	local v1perpendicular = v(v1.y, -v1.x)

	v2.x = v2.x / length2
	v2.y = v2.y / length2

	local v2perpendicular = v(v2.y, -v2.x)
	local distance = 0
	local patterns = {{20, -20}, {0}}
	local counter = 0

	while length1 > distance + 50 do
		local pattern = patterns[1 + counter % #patterns]

		counter = counter + 1

		for i = 1, #pattern do
			local x = pos1.x + v1.x * distance + v1perpendicular.x * pattern[i]
			local y = pos1.y + v1.y * distance + v1perpendicular.y * pattern[i]

			createDecal(v(x, y))

			x = pos2.x + v2.x * distance + v2perpendicular.x * pattern[i]
			y = pos2.y + v2.y * distance + v2perpendicular.y * pattern[i]

			createDecal(v(x, y))
		end

		U.y_wait_unconditional(store, U.frandom(this.show_delay_min, this.show_delay_max))

		distance = distance + math.random(10, 30)
	end

	patterns = {{3, 2}, {1}}

	for j = 1, count do
		local pattern = patterns[1 + j % #patterns]

		wave_ni = wave_ni - math.random(this.sep_nodes_min, this.sep_nodes_max)

		for i = 1, #pattern do
			local node = {
				pi = wave_pi,
				spi = pattern[i],
				ni = wave_ni
			}
			local node_pos = P:node_pos(node.pi, node.spi, node.ni)

			if P:is_node_valid(node.pi, node.ni) then
				createDecal(node_pos)

				local targets = U.find_enemies_in_range_filter_off(node_pos, this.radius, this.vis_flags, this.vis_bans)

				if targets then
					for _, target in ipairs(targets) do
						local m = E:create_entity(this.mod)

						m.modifier.target_id = target.id
						m.modifier.source_id = this.id

						simulation:queue_insert_entity(m)
					end
				end
			end

			U.y_wait_unconditional(store, U.frandom(this.show_delay_min, this.show_delay_max))
		end
	end

	simulation:queue_remove_entity(this)
end
tt.sep_nodes_min = 4
tt.sep_nodes_max = 5
tt.show_delay_min = 0.04
tt.show_delay_max = 0.04
tt.count = 14
tt.radius = 50
tt.wave_pi = 1
tt.root_hand_L_pos = v(0, 350)
tt.root_hand_R_pos = v(250, 450)
tt.start_offset = -20
tt.root_hand_offset_path_merge = -8
tt.decal = "trees_guardian_tree_wave_of_roots_decal"
tt.vis_flags = bor(F_STUN)
tt.vis_bans = bor(F_FLYING, F_BOSS)
tt.mod = "mod_stage_guardian_tree_wave_of_roots_stun"

tt = E:register_t_hot("trees_guardian_tree_wave_of_roots_decal", "decal_sequence", true)
tt.render.sprites[1].prefix = "stage_2_special_treeFX_groundFX0"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].z = Z_DECALS
tt.sequence.steps = {"start", nil, "end"}

tt = E:register_t_hot("mod_stage_guardian_tree_wave_of_roots_stun", "modifier", true)
E:add_comps(tt, "render")
tt.modifier.duration = 4
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.use_mod_offset = false
tt.modifier.immune_for_seconds = 3
tt.render.sprites[1].prefix = "stage_2_special_treeFX_holdFX"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].sort_y_offset = -3
tt.main_script.insert = function(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if target.guardian_tree_vine_mod_ts and store.tick_ts - target.guardian_tree_vine_mod_ts < this.modifier.immune_for_seconds then
		return false
	end

	if target and target.unit and this.render then
		local s = this.render.sprites[1]

		if s.size_names then
			s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
			s.flip_x = target.render.sprites[1].flip_x
		end

		if s.size_scales then
			local scale = s.size_scales[target.unit.size]

			s.scale = V.v(s.scale.x * scale, s.scale.y * scale)
		end

		if this.modifier.use_mod_offset and target.unit.mod_offset then
			s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		s.flip_x = false
	end

	this.modifier.ts = store.tick_ts

	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		SU.stun_inc(target)
	end

	target.guardian_tree_vine_mod_ts = store.tick_ts

	return true
end
tt.main_script.remove = function(this, store)
	local target = store.entities[this.modifier.target_id]

	if target then
		SU.stun_dec(target)
	end

	return true
end
tt.main_script.update = function(this, store)
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if target and not target.health.dead then
		this.pos = target.pos

		U.animation_start_default(this, "start", nil, store.tick_ts)

		while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
			coroutine.yield()
		end

		U.y_animation_play(this, "end", nil, store.tick_ts, 1)
	end

	simulation:queue_remove_entity(this)
end
