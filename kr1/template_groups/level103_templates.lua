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
local AC = require("achievements")
local scripts = require("scripts")
local v = V.v
local r = V.r
local vv = V.vv
local controller_stage_03_arborean_babies_update
local decal_stage_03_fat_arborean_update
local decal_stage_03_elder_rune_update
local trees_heart_of_the_arborean_decal_insert
local trees_heart_of_the_arborean_decal_update
controller_stage_03_arborean_babies_update = function(this, store)
	local babies = {}
	local count = 1
	for _, v in pairs(store.entities) do
		if v.template_name == "decal_arborean_baby_clickeable" then
			babies[count] = v
			count = count + 1
		end
	end
	while true do
		local all_hidden = true
		for k, v in pairs(babies) do
			if not v.is_hidden then
				all_hidden = false
				break
			end
		end
		if all_hidden then
			signal.emit("playful_friends-stage03", this)
			break
		end
		coroutine.yield()
	end
end
decal_stage_03_fat_arborean_update = function(this, store)
	local c = this.click_play
	local clicks = 0
	local already_played = false
	while true do
		if c.play_once and already_played then
		else
			if this.ui.clicked then
				this.ui.clicked = nil
				clicks = clicks + 1
				S:queue(c.clicked_sound)
				if clicks >= c.required_clicks then
					U.y_animation_play(this, c.end_animation, nil, store.tick_ts, 1)
					already_played = true
					this.ui.can_click = false
					signal.emit("most_delicious-stage03", this)
					goto label_1048_0
				else
					U.y_animation_play(this, c.click_animation, nil, store.tick_ts, 1)
				end
			end
			U.animation_start_default(this, c.idle_animation, nil, store.tick_ts, true)
		end
		::label_1048_0::
		coroutine.yield()
	end
end
decal_stage_03_elder_rune_update = function(this, store)
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
			signal.emit("achievements_custom_event", "RUNEQUEST_3")
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
trees_heart_of_the_arborean_decal_insert = function(this, store)
	this.danger_zones = {V.v(300, 565), V.v(710, 570)}
	this.safe_dist2 = 3600
	local a = this.custom_attack
	local function avoid_danger_zone(x, y)
		local dz = this.danger_zones
		local sd2 = this.safe_dist2
		return sd2 < V.dist2(x, y, dz[1].x, dz[1].y) and sd2 < V.dist2(x, y, dz[2].x, dz[2].y)
	end
	this.nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, 0, a.max_range, nil, avoid_danger_zone, nil)
	return true
end
trees_heart_of_the_arborean_decal_update = function(this, store)
	local a = this.custom_attack
	local selected_positions = {}
	local max_dist2 = a.min_dist_between_tgts * a.min_dist_between_tgts
	this.clicked = false
	local function avoid_danger_zone(e, origin)
		local dz = this.danger_zones
		local sd2 = this.safe_dist2
		return sd2 < V.dist2(e.pos.x, e.pos.y, dz[1].x, dz[1].y) and sd2 < V.dist2(e.pos.x, e.pos.y, dz[2].x, dz[2].y)
	end
	local function get_pos_from_target(target)
		local node = table.deepclone(target.nav_path)
		node.spi = 1
		local node_pos = P:node_pos(node.pi, node.spi, node.ni)
		return node_pos
	end
	local function shoot_bullet(pos)
		local b = E:create_entity(a.bullet)
		b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = pos
		b.bullet.source_id = this.id
		simulation:queue_insert_entity(b)
	end
	local function shuffle_table(nodes)
		for i = #nodes, 2, -1 do
			local j = math.random(i)
			nodes[i], nodes[j] = nodes[j], nodes[i]
		end
		return nodes
	end
	local shamans = table.filter(store.entities, function(_, e)
		return e.template_name == "trees_heart_of_the_arborean_shaman_decal"
	end)
	for _, shaman in ipairs(shamans) do
		shaman.shaman_state = "waiting"
	end
	U.animation_start_default(this, "idleLoading", nil, store.tick_ts, true)
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	::label_801_0::
	U.animation_start_default(this, "idleLoading", nil, store.tick_ts, true)
	for _, shaman in ipairs(shamans) do
		shaman.shaman_state = "charging"
	end
	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)
	a.ts = store.tick_ts
	while store.tick_ts - a.ts < a.cooldown do
		coroutine.yield()
	end
	for _, shaman in ipairs(shamans) do
		shaman.shaman_state = "charged"
		S:queue(this.sound_ready)
	end
	U.y_animation_play(this, "toLoaded", nil, store.tick_ts)
	U.animation_start_default(this, "idleLoaded", nil, store.tick_ts, true)
	this.ui.clicked = nil
	while true do
		if this.ui.clicked then
			selected_positions = {}
			S:queue(this.sound_cast)
			U.animation_start_default(this, "toLoading", nil, store.tick_ts)
			U.y_wait_unconditional(store, a.cast_time / 2)
			for _, shaman in ipairs(shamans) do
				shaman.shaman_state = "shoot"
			end
			U.y_wait_unconditional(store, a.cast_time / 2)
			S:queue(a.sound)
			local _, targets = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, a.cast_time, a.vis_flags, a.vis_bans)
			if targets then
				for i = #targets, 1, -1 do
					local e = targets[i]
					local dz = this.danger_zones
					local sd2 = this.safe_dist2
					local node_offset = P:predict_enemy_node_advance(e, a.cast_time + a.node_prediction)
					local e_ni = e.nav_path.ni + node_offset
					local e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
					if sd2 > V.dist2(e_pos.x, e_pos.y, dz[1].x, dz[1].y) or sd2 > V.dist2(e_pos.x, e_pos.y, dz[2].x, dz[2].y) then
						table.remove(targets, i)
					end
				end
			end
			for i = 1, a.max_targets do
				if not targets or #targets <= 0 or #selected_positions > a.max_targets / 2 then
					goto label_801_1
				end
				local sel_target = targets[1]
				local node_offset = P:predict_enemy_node_advance(sel_target, a.cast_time + a.node_prediction)
				local e_ni = sel_target.nav_path.ni + node_offset
				local e_pos = P:node_pos(sel_target.nav_path.pi, sel_target.nav_path.spi, e_ni)
				table.insert(selected_positions, e_pos)
				table.remove(targets, 1)
				for i = #targets, 1, -1 do
					local e = targets[i]
					if max_dist2 > V.dist2(sel_target.pos.x, sel_target.pos.y, e.pos.x, e.pos.y) then
						table.remove(targets, i)
					end
				end
			end
			if #selected_positions == a.max_targets then
				goto label_801_2
			end
			::label_801_1::
			do
				local nodes = table.deepclone(this.nodes)
				shuffle_table(nodes)
				for i = #selected_positions + 1, a.max_targets do
					local sel_node = nodes[1]
					table.insert(selected_positions, sel_node)
					table.remove(nodes, 1)
					for i = #nodes, 1, -1 do
						local n = nodes[i]
						if max_dist2 > V.dist2(sel_node.x, sel_node.y, n.x, n.y) then
							table.remove(nodes, i)
						end
					end
				end
			end
			::label_801_2::
			shuffle_table(selected_positions)
			for _, p in pairs(selected_positions) do
				shoot_bullet(p)
				U.y_wait_unconditional(store, a.wait_between_shots)
			end
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idleLoading", nil, store.tick_ts, true)
			a.ts = store.tick_ts
			this.ui.clicked = nil
			U.y_wait_unconditional(store, a.node_prediction - fts(30))
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.5
			shake.aura.duration = 1.3
			shake.aura.freq_factor = 4
			simulation:queue_insert_entity(shake)
			this.clicked = true
			goto label_801_0
		end
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("trees_heart_of_the_arborean_decal", "decal_scripted", true)
E:add_comps(tt, "custom_attack", "ui", "cheats")
tt.render.sprites[1].prefix = "heartDef"
tt.render.sprites[1].name = "idleLoading"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = trees_heart_of_the_arborean_decal_insert
tt.main_script.update = trees_heart_of_the_arborean_decal_update
tt.custom_attack.cooldown_max = 90
tt.custom_attack.cooldown_min = 90
tt.custom_attack.max_range = 1400
tt.custom_attack.damage_radius = 80
tt.custom_attack.damage_max = 40
tt.custom_attack.damage_min = 30
tt.custom_attack.damage_type = DAMAGE_TRUE
tt.custom_attack.max_targets = 10
tt.custom_attack.min_targets = 10
tt.custom_attack.door1Pos = v(757, 568)
tt.custom_attack.door2Pos = v(318, 566)
tt.custom_attack.cast_time = fts(21)
tt.custom_attack.wait_between_shots = fts(2)
tt.custom_attack.min_dist_between_tgts = 130
tt.custom_attack.node_prediction = fts(45)
tt.custom_attack.sound = nil
tt.custom_attack.bullet = "bullet_stage_03_heart_of_the_arborean"
tt.custom_attack.bullet_start_offset = v(0, 90)
tt.ui.click_rect = r(-100, -100, 200, 200)
tt.cheats.buttons[1].text = "H_CD"
tt.cheats.buttons[1].fn = function(button, store, e)
	if e.custom_attack.cooldown then
		e.custom_attack.ts = store.tick_ts - e.custom_attack.cooldown
	end
end
tt.sound_ready = "Stage03HeartOfTheForestReady"
tt.sound_cast = "Stage03HeartOfTheForestCast"
tt = E:register_t_hot("decal_stage_03_butterfly_2", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_3_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt = E:register_t_hot("controller_stage_03_arborean_babies", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_03_arborean_babies_update
tt = E:register_t_hot("decal_stage_03_elder_rune", "decal_click_play", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "stage_3_decos_REF_elder_rune_3"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.main_script.update = decal_stage_03_elder_rune_update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0203Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt = E:register_t_hot("trees_heart_of_the_arborean_shaman_water_decal", "decal", true)
tt.render.sprites[1].prefix = "wavesDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_03_wisps", "decal", true)
tt.render.sprites[1].prefix = "stage_3_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_3_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt = E:register_t_hot("decal_stage_03_river", "decal", true)
tt.render.sprites[1].prefix = "riverDef"
tt.render.sprites[1].name = "riverRunning"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_03_heart_back_waves", "decal", true)
tt.render.sprites[1].prefix = "heart_back_wavesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t_hot("decal_stage_03_heart_front_waves", "decal", true)
tt.render.sprites[1].prefix = "heart_front_wavesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t_hot("stage3_decos_barriles2", "decal_scripted", true)
local time_between_animations = fts(30 * math.random(10, 30))
tt.render.sprites[1].prefix = "stage3_decos_barriles2"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.animations = {{"action", time_between_animations}, {"idle", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t_hot("decal_stage_03_butterfly_3", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_3_butterfly_3Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 12
tt.delayed_play.max_delay = 32
tt = E:register_t_hot("decal_stage_03_fat_arborean", "decal_click_play", true)
tt.render.sprites[1].prefix = "stage3_decos_gordito"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vv(1.1)
tt.main_script.update = decal_stage_03_fat_arborean_update
tt.click_play.idle_animation = "idle"
tt.click_play.click_animation = "comer"
tt.click_play.end_animation = "muerte"
tt.click_play.required_clicks = 3
tt.click_play.play_once = true
tt.click_play.clicked_sound = "EasterEggCommonTap"
tt.ui.can_click = true
tt.ui.click_rect = r(-60, -10, 60, 60)
tt = E:register_t_hot("decal_stage_03_butterfly_1", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_3_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30
tt = E:register_t_hot("stage3_decos_barriles1", "decal_scripted", true)
local time_between_animations = fts(30 * math.random(10, 30))
tt.render.sprites[1].prefix = "stage3_decos_barriles1"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.animations = {{"action", time_between_animations}, {"idle", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
