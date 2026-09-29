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
local ACH = require("achievements")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_05_elder_rune_update
local decal_stage_05_bear_woodcutter_update
decal_stage_05_elder_rune_update = function(this, store)
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
			signal.emit("achievements_custom_event", "RUNEQUEST_5")
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
decal_stage_05_bear_woodcutter_update = function(this, store)
	local entity = E:create_entity(this.entity)
	local nodes = P:nearest_nodes(this.waypoint_pos.x, this.waypoint_pos.y, nil, nil, false)
	local pi, spi, ni = unpack(nodes[1])
	entity.pos = this.spawn_pos
	entity.nav_path.pi = pi
	entity.nav_path.spi = spi
	entity.nav_path.ni = ni
	entity.motion.forced_waypoint = P:node_pos(entity.nav_path.pi, entity.nav_path.spi, entity.nav_path.ni)
	U.set_destination(entity, this.waypoint_pos)
	while true do
		U.animation_start_group(this, "loop", false, store.tick_ts, false, "layers")
		U.y_animation_wait_group(this, "layers")
		if store.wave_group_number < 8 then
		else
			U.animation_start_group(this, "wakeup", false, store.tick_ts, false, "layers")
			U.y_wait_unconditional(store, fts(85))
			S:queue("Stage05WoodcutterBearRoar")
			U.y_wait_unconditional(store, fts(94))
			for _, e in pairs(store.entities) do
				if e.template_name == "stage_05_trees_mask" then
					simulation:queue_remove_entity(e)
					break
				end
			end
			S:queue("Stage05WoodcutterBearChop")
			U.y_wait_unconditional(store, fts(99))
			S:queue("Stage05WoodcutterBearChop")
			U.y_wait_unconditional(store, fts(130))
			S:queue("Stage05WoodcutterBearChop")
			U.y_animation_wait_group(this, "layers")
			if this.holder then
				this.holder.render.sprites[1].z = Z_DECALS
				this.holder.render.sprites[2].z = Z_OBJECTS
				this.holder.ui.can_click = true
				this.holder.tower.can_hover = true
			end
			break
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
	simulation:queue_insert_entity(entity)
	SU.y_enemy_walk_step(store, entity)
end
local tt
tt = E:register_t_hot("decal_stage_05_bear_woodcutter", "decal_scripted", true)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "bear_woodcutterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.main_script.update = decal_stage_05_bear_woodcutter_update
tt.entity = "enemy_bear_woodcutter"
tt.spawn_pos = v(242, 459)
tt.waypoint_pos = v(220, 459)

tt = E:register_t_hot("decal_stage_05_elder_rune", "decal_click_play", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "stage_5_elder_rune_5"
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 1
tt.main_script.update = decal_stage_05_elder_rune_update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0506Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-50, -10, 50, 50)

tt = E:register_t_hot("decal_stage_05_elder_rune_static", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_5_elder_rune_5_0125"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false

tt = E:register_t_hot("stage_05_bridge_mask_right", "decal", true)
tt.render.sprites[1].name = "stage_5_MaskBridge_right"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("stage_05_bridge_mask_left", "decal", true)
tt.render.sprites[1].name = "stage_5_MaskBridge_left"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_05_elder_rune_base", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_5_elder_rune_5_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 0

tt = E:register_t_hot("stage_05_trees_mask", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_5_MaskTree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

