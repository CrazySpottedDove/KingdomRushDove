local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local vv = V.vv
local controller_stage_29_spider_holders_update
controller_stage_29_spider_holders_update = function(this, store)
	local previous_wave_index = store.wave_group_number
	local run_this_wave = false
	local cooldown = 0
	local max_casts = 99
	local casts = 0
	local next_ts = store.tick_ts
	this.render.sprites[1].hidden = true
	this.waves = this.waves[store.level_mode] and this.waves[store.level_mode] or this.waves[GAME_MODE_CAMPAIGN]
	this.first_cooldown = this.first_cooldown[store.level_mode] and this.first_cooldown[store.level_mode] or this.first_cooldown[GAME_MODE_CAMPAIGN]
	this.cooldown = this.cooldown[store.level_mode] and this.cooldown[store.level_mode] or this.cooldown[GAME_MODE_CAMPAIGN]
	this.max_casts = this.max_casts[store.level_mode] and this.max_casts[store.level_mode] or this.max_casts[GAME_MODE_CAMPAIGN]
	this.game_start_blocked_holders = this.game_start_blocked_holders[store.level_mode] and this.game_start_blocked_holders[store.level_mode] or this.game_start_blocked_holders[GAME_MODE_CAMPAIGN]
	local taps_count = 0
	local shown_hand = false
	local function check_tap()
		if taps_count >= this.taps_to_cancel then
			return
		end
		if this.ui.clicked then
			this.ui.clicked = nil
			taps_count = taps_count + 1
			if taps_count >= this.taps_to_cancel then
				return "canceled"
			else
				return "clicked"
			end
		end
	end
	local function get_holders_to_block()
		local holders = table.filter(store.entities, function(k, v)
			local is_holder = v.tower_holder and not v.tower_holder.blocked and not v.tower.blocked and (not v.vis or band(v.vis.bans, F_STUN) == 0)
			return is_holder
		end)
		return holders
	end
	local function replace_holder(store, hldr, new_hldr, select_new)
		local th = E:create_entity(new_hldr)
		th.pos = V.vclone(hldr.pos)
		th.tower.holder_id = hldr.tower.holder_id
		th.tower.flip_x = hldr.tower.flip_x
		if hldr.tower.default_rally_pos then
			th.tower.default_rally_pos = hldr.tower.default_rally_pos
		end
		if hldr.tower.terrain_style then
			th.tower.terrain_style = hldr.tower.terrain_style
		end
		if th.ui and hldr.ui then
			th.ui.nav_mesh_id = hldr.ui.nav_mesh_id
		end
		simulation:queue_insert_entity(th)
		simulation:queue_remove_entity(hldr)
		signal.emit("tower-removed", hldr, th, select_new)
		return th
	end
	local holders_to_block_game_start = table.filter(store.entities, function(k, v)
		local is_holder = v.tower_holder and not v.tower_holder.blocked and not v.tower.blocked and (not v.vis or band(v.vis.bans, F_STUN) == 0) and table.contains(this.game_start_blocked_holders, v.tower.holder_id)
		return is_holder
	end)
	for _, v in pairs(holders_to_block_game_start) do
		replace_holder(store, v, "tower_holder_blocked_spiders")
	end
	local buy_tower = false
	local flag
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
			local holders = get_holders_to_block()
			if holders and #holders > 0 then
				casts = casts + 1
				next_ts = store.tick_ts + cooldown
				holders = table.random_order(holders)
				local hldr = holders[1]
				taps_count = 0
				for i = 1, this.threads_amount do
					this.render.sprites[i + 1].hidden = false
					this.render.sprites[i + 1].name = table.random(this.threads_idles)
				end
				this.pos = V.v(hldr.pos.x, REF_H + 50)
				this.render.sprites[1].hidden = false
				U.animation_start(this, "climb_down", nil, store.tick_ts, true, 1)
				local start_ts = store.tick_ts
				local phase
				repeat
					if not table.contains(store.entities, hldr) then
						goto label_1545_0
					end
					phase = (store.tick_ts - start_ts) / this.time_to_down
					this.pos.y = U.ease_value(REF_H + 100, hldr.pos.y + 80, phase, "quad")
					coroutine.yield()
				until phase >= 1
				U.animation_start(this, "arrive", nil, store.tick_ts, false, 1)
				while not U.animation_finished_default(this) do
					if not table.contains(store.entities, hldr) then
						buy_tower = true
						goto label_1545_1
					end
					coroutine.yield()
				end
				hldr.ui.can_click = false
				hldr.tower.blocked = true
				S:queue(this.sound_loop)
				U.animation_start(this, "netting", nil, store.tick_ts, true, 1)
				flag = E:create_entity("tower_holder_pre_blocked_spiders")
				flag.pos = V.vclone(hldr.pos)
				simulation:queue_insert_entity(flag)
				U.y_wait_unconditional(store, fts(1))
				start_ts = store.tick_ts
				while store.tick_ts - start_ts < this.time_netting do
					if not shown_hand then
						shown_hand = true
						local hand = E:create_entity(this.hand_decal_t)
						hand.pos = V.vclone(hldr.pos)
						hand.render.sprites[1].ts = store.tick_ts
						hand.tween.ts = store.tick_ts
						simulation:queue_insert_entity(hand)
					end
					local status = check_tap()
					if status == "canceled" then
						S:stop(this.sound_loop)
						S:queue(this.sound_death)
						buy_tower = true
						goto label_1545_1
					end
					if status == "clicked" then
					end
					coroutine.yield()
				end
				if flag then
					simulation:queue_remove_entity(flag)
					flag = nil
				end
				::label_1545_0::
				S:stop(this.sound_loop)
				U.animation_start(this, "climb_up_start", nil, store.tick_ts, false, 1)
				U.y_animation_wait_default(this)
				U.animation_start(this, "climbing_up_idle", nil, store.tick_ts, true, 1)
				U.y_ease_key(store, this.pos, "y", this.pos.y, REF_H + 100, this.time_to_up, "quad")
				::label_1545_1::
				if buy_tower then
					buy_tower = false
					hldr.ui.can_click = true
					hldr.tower.blocked = false
					if flag then
						simulation:queue_remove_entity(flag)
						flag = nil
					end
					U.animation_start(this, "explode", nil, store.tick_ts, false, 1)
					U.y_wait_unconditional(store, fts(5))
				end
				for i = 2, #this.render.sprites do
					local s = this.render.sprites[i]
					s.name = "dissolve"
					s.ts = store.tick_ts
				end
				U.y_animation_wait_default(this)
				this.render.sprites[1].hidden = true
			else
				next_ts = store.tick_ts + cooldown
			end
		end
		U.y_wait_unconditional(store, fts(10))
		coroutine.yield()
	end
end
local tt
local decal_achievement_a_coon_of_surprises
decal_achievement_a_coon_of_surprises = {}

function decal_achievement_a_coon_of_surprises.update(this, store)
	local touch_times = 0

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1

			if touch_times < this.required_touches then
				U.y_animation_play(this, "clicked", nil, store.tick_ts, 1, this.render.sid_animated)
				U.animation_start(this, "idle", nil, store.tick_ts, true, this.render.sid_animated)

				this.ui.can_click = true
			else
				U.animation_start(this, "broken", nil, store.tick_ts, false, this.render.sid_animated)
				U.y_wait_unconditional(store, this.change_z_time)

				this.render.sprites[this.render.sid_animated].z = Z_OBJECTS
				this.render.sprites[this.render.sid_animated].sort_y_offset = this.change_y_sort_offset

				U.y_animation_wait(this, this.render.sid_animated, 1)
				U.animation_start(this, "idle_2", nil, store.tick_ts, true, this.render.sid_animated)

				if this.give_achievement then
					signal.emit("spiders-a-coon-of-surprises")
				end
			end
		end

		coroutine.yield()
	end
end

local function fts(v)
	return v / FPS
end

local stage_29_cocoon = {}

function stage_29_cocoon.update(this, store)
	if this.broken_on_iron and store.level_mode == GAME_MODE_IRON or this.broken_on_heroic and store.level_mode == GAME_MODE_HEROIC then
		U.animation_start(this, this.animation_spawner_idle_broken, nil, store.tick_ts, true, 1)

		return
	end

	local sp = this.spawner
	local state = 1

	U.animation_start(this, this.animation_spawner_idle, nil, store.tick_ts - fts(math.random(0, 20)), true, 1, true)

	while true do
		if sp.interrupt then
		-- block empty
		elseif state == 1 then
			if sp.spawn_data then
				local enable = sp.spawn_data.enable

				if enable then
					state = 2

					S:queue(this.sound_inflate)
					S:queue(this.sound_explode)
					U.y_animation_play(this, this.animation_spawner_start, nil, store.tick_ts, 1, 1)
				end
			end
		elseif state == 2 and sp.spawn_data then
			local enable = sp.spawn_data.enable

			if not enable then
				S:queue(this.sound_regenerate)
				U.y_animation_play(this, this.animation_spawner_end, nil, store.tick_ts, 1, 1)
				U.animation_start(this, this.animation_spawner_idle, nil, store.tick_ts, true, 1)

				state = 1
			end
		end

		sp.interrupt = nil

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = E:register_t_hot("controller_stage_29_spider_holders", "decal_scripted", true)
E:add_comps(tt, "editor", "ui")
tt.main_script.update = controller_stage_29_spider_holders_update
tt.render.sprites[1].prefix = "spiderholder_spiderholder"
tt.render.sprites[1].anchor = v(0.5, 0.4)
tt.render.sprites[1].name = "climbing_up_idle"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.waves = {{5, 6, 7, 9, 10, 11, 12, 13, 14, 15}, {2, 3, 4, 5, 6}, {1}}
tt.first_cooldown = {{5, 40, 5, 45, 1, 22, 1, 1, 1, 1}, {1, 35, 5, 25, 40}, {30}}
tt.cooldown = {{35, 20, 0, 0, 30, 30, 40, 30, 30, 25}, {0, 0, 42, 0, 20}, {50}}
tt.max_casts = {{2, 2, 1, 1, 3, 2, 2, 3, 3, 4}, {1, 1, 2, 1, 2}, {50}}
tt.game_start_blocked_holders = {{}, {}, {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"10",
	"11",
	"12",
	"13",
	"14",
	"15"
}}
tt.time_to_down = 3
tt.time_to_up = 2
tt.time_netting = 5
tt.taps_to_cancel = 3
tt.hand_decal_t = "decal_mod_stage_29_holder_block_hand"
tt.ui.click_rect = r(-35, -40, 70, 70)
tt.vis_bans = 0
tt.vis_flags = 0
tt.threads_separation = 38
tt.threads_amount = math.ceil(REF_H / tt.threads_separation)
tt.threads_idles = {"idle1", "idle1", "idle2", "idle3", "idle4", "idle4"}
for i = 1, tt.threads_amount do
	local s = E:clone_c("sprite")
	s.prefix = "glarewarden_web_spiderweb"
	s.name = tt.threads_idles[1]
	s.loop = false
	s.anchor.y = 0
	s.offset.y = (i - 1) * tt.threads_separation
	s.z = Z_OBJECTS_SKY - 1
	s.hidden = true
	tt.render.sprites[i + 1] = s
end
tt.sound_loop = "EnemySpidersMechanicTowerSpiderWorkingLoop"
tt.sound_death = "EnemySpidersMechanicTowerSpiderDeath"

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_fredo", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.ui.click_rect = r(-20, -50, 40, 40)
tt.main_script.update = decal_achievement_a_coon_of_surprises.update
tt.give_achievement = true
tt.required_touches = 3
tt.change_z_time = fts(8)
tt.change_y_sort_offset = -160
tt.render.sid_animated = 2
tt.render.sprites[1].name = "coonsuprices_cuerdafredo"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].anchor = v(0.5, 0.115385)
tt.render.sprites[tt.render.sid_animated] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_fredo"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_animated].offset = v(5, 4)
tt.render.sprites[tt.render.sid_animated].anchor = v(0.5, 0.973404)

tt = E:register_t_hot("decal_stage_29_background_eyes", "decal", true)
tt.render.sprites[1].prefix = "spiders_stage29_eyes_stageDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_arak", "decal_achievement_a_coon_of_surprises_fredo", true)
tt.give_achievement = false
tt.ui.click_rect = r(-20, -40, 62, 75)
tt.change_y_sort_offset = 0
tt.render.sid_animated = 1
tt.render.sprites[2] = nil
tt.render.sprites[tt.render.sid_animated].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_arak"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].animated = true
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_darkcrystal", "decal_achievement_a_coon_of_surprises_fredo", true)
tt.give_achievement = false
tt.change_z_time = fts(37)
tt.change_y_sort_offset = -260
tt.ui.click_rect = r(-20, -80, 40, 80)
tt.render.sprites[1].name = "coonsuprices_cuerdadarkcrystal"
tt.render.sprites[1].anchor = v(0.5, 0.239583)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_darkcrystal"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(0, 0)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_silksong", "decal_achievement_a_coon_of_surprises_fredo", true)
tt.give_achievement = false
tt.change_z_time = fts(36)
tt.change_y_sort_offset = -400
tt.ui.click_rect = r(-18, -70, 40, 60)
tt.render.sprites[1].name = "coonsuprices_cuerdasilksong"
tt.render.sprites[1].anchor = v(0.5, 0.239583)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_silksong"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(2, -30)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_jarra", "decal_achievement_a_coon_of_surprises_fredo", true)
tt.give_achievement = false
tt.change_z_time = fts(32)
tt.change_y_sort_offset = -210
tt.ui.click_rect = r(-20, -60, 47, 55)
tt.render.sprites[1].name = "coonsuprices_cuerdajarra"
tt.render.sprites[1].anchor = v(0.5, 0.239583)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_jarra"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(-2, -22)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)

tt = E:register_t_hot("decal_achievement_a_coon_of_surprises_sheepy", "decal_achievement_a_coon_of_surprises_fredo", true)
tt.give_achievement = false
tt.change_z_time = fts(30)
tt.change_y_sort_offset = -336
tt.ui.click_rect = r(-17, -60, 40, 70)
tt.render.sprites[1].name = "coonsuprices_cuerdadarkcrystal"
tt.render.sprites[1].anchor = v(0.5, 0.239583)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_sheepy"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(0, 0)
tt.render.sprites[tt.render.sid_animated].anchor = v(0.5, 0.517391)

tt = E:register_t_hot("stage_29_cocoon", "decal_scripted", true)
E:add_comps(tt, "spawner")
tt.render.sprites[1].prefix = "cocon_stage2_coocoon"
tt.render.sprites[1].name = "idle"
tt.animation_spawner_start = "summon_in"
tt.animation_spawner_idle = "idle_anim"
tt.animation_spawner_end = "summon_out"
tt.animation_spawner_idle_broken = "idle_broken"
tt.broken_on_heroic = true
tt.broken_on_iron = true
tt.main_script.update = stage_29_cocoon.update
tt.spawner.eternal = true
tt.sound_inflate = "EnemySpidersMechanicSpawnerInflate"
tt.sound_explode = "EnemySpidersMechanicSpawnerExplode"
tt.sound_regenerate = "EnemySpidersMechanicSpawnerRegenerate"

