local signal = require("lib.hump.signal")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local controller_stage_35_update
local controller_stage_35_on_event
local decal_stage_35_fume_entradas_update
controller_stage_35_update = function(this, store)
	local controller_boss, controller_redboy, controller_portal_left, controller_princess, controller_portal_right, controller_golden_eyed
	local destroy_houses_times = 0
	for _, e in pairs(store.entities) do
		if e.template_name == "controller_stage_35_bull_king" then
			controller_boss = e
		elseif e.template_name == "controller_stage_35_princess_powers" then
			controller_princess = e
		elseif e.template_name == "controller_stage_35_redboy_powers" then
			controller_redboy = e
		elseif e.template_name == "controller_stage_35_portal_left" then
			controller_portal_left = e
		elseif e.template_name == "controller_stage_35_portal_right" then
			controller_portal_right = e
		elseif e.template_name == "controller_stage_35_golden_eyed_left" then
			controller_golden_eyed = e
		end
	end
	while true do
		if this.activate then
			local activate_string = "return {" .. this.activate .. "}"
			local f = load(activate_string)
			local activate = f()
			local houses_templates = {}
			local cinematic = activate.cinematic or false
			local action = activate.action or nil
			if activate.houses then
				for _, house_id in ipairs(activate.houses) do
					table.insert(houses_templates, "tower_holder_blocked_stage_35_house_" .. house_id)
				end
			end
			local houses_unordered = {}
			for _, e in pairs(store.entities) do
				if table.contains(houses_templates, e.template_name) then
					table.insert(houses_unordered, e)
				end
			end
			local houses = {}
			if activate.houses then
				for _, house_id in ipairs(houses_templates) do
					for _, h in ipairs(houses_unordered) do
						if h.template_name == house_id then
							table.insert(houses, h)
							break
						end
					end
				end
			end
			this.activate = nil
			if action == "destroy_houses" then
				destroy_houses_times = destroy_houses_times + 1
				local camera_posX, camera_posY, zoom_value
				if cinematic then
					signal.emit("show-curtains")
					signal.emit("hide-gui")
					signal.emit("start-cinematic")
				end
				for h_index, house in ipairs(houses) do
					if cinematic then
						signal.emit("pan-zoom-camera", (h_index == 1 and 1 or 2) + house.cinematic_camera_duration_offset, {
							x = house.pos.x,
							y = house.pos.y + 50
						}, 1.5)
						house:pre_destroy(store)
					end
					U.y_wait_unconditional(store, 0.5 + house.cinematic_camera_duration_offset)
					if h_index == 1 then
						U.sprites_show(this, nil, nil, false)
						local cox, coy = this.fixed_screen_offset.x, this.fixed_screen_offset.y
						if store.safe_frame then
							cox = math.max(cox, math.max(store.safe_frame.rb, store.safe_frame.lb))
						end
						this.render.sprites[1].pos.y = coy
						if house.pos.x < 512 then
							this.render.sprites[1].pos.x = cox
							this.render.sprites[1].flip_x = false
						else
							this.render.sprites[1].pos.x = REF_W - cox
							this.render.sprites[1].flip_x = true
						end
						U.y_animation_play(this, "run", nil, store.tick_ts, 1, 1)
						U.sprites_hide(this, nil, nil, false)
					end
					house:destroy_house(store)
				end
				if cinematic then
					signal.emit("pan-zoom-camera", 1, {
						x = 512,
						y = 700
					}, 1.5)
					U.y_wait_unconditional(store, 1.2)
					controller_boss.do_taunt = "LV35_BOSS_DESTROY_HOUSE_0" .. destroy_houses_times
					U.y_wait_unconditional(store, 3.5)
					if destroy_houses_times == 1 then
						controller_boss.activate = "redboy"
						U.y_wait_unconditional(store, 3.5)
						signal.emit("pan-zoom-camera", 1, {
							x = 300,
							y = 500
						}, OVtargets(nil, 1.2))
						controller_redboy.activate = "portal_in"
						controller_portal_left.activate = "open"
						U.y_wait_unconditional(store, 1.5)
					elseif destroy_houses_times == 2 then
						controller_boss.activate = "princess"
						U.y_wait_unconditional(store, 3.5)
						signal.emit("pan-zoom-camera", 1, {
							x = 800,
							y = 500
						}, OVtargets(nil, 1.2))
						controller_princess.activate = "portal_in"
						controller_portal_right.activate = "open"
						U.y_wait_unconditional(store, 1.5)
					elseif destroy_houses_times == 3 then
						controller_golden_eyed.activate = true
						controller_boss.activate = "golden_eyed"
						U.y_wait_unconditional(store, 6)
					end
				end
				U.y_wait_unconditional(store, 1.5)
				if cinematic then
					signal.emit("pan-zoom-camera", 1, {
						x = camera_posX,
						y = camera_posY
					}, zoom_value)
				end
				U.y_wait_unconditional(store, 2)
				if cinematic then
					signal.emit("hide-curtains")
					signal.emit("show-gui")
					signal.emit("end-cinematic")
					U.y_wait_unconditional(store, 1)
					signal.emit("barrage_end")
				end
			end
		end
		coroutine.yield()
	end
end
controller_stage_35_on_event = function(this, store, action, house)
	this.activate = tostring(house)
end
decal_stage_35_fume_entradas_update = function(this, store)
	U.animation_start_default(this, "loop", nil, store.tick_ts, true)
	while not this.finish do
		coroutine.yield()
	end
	U.y_animation_play(this, "put", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end
local tt
local S = require("sound_db")
local P = require("path_db")
local band = bit.band
local function fts(v)
	return v / FPS
end

local controller_stage_35_bull_king = {}

function controller_stage_35_bull_king.update(this, store)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	local function manage_taunts()
		if this.do_taunt then
			U.y_animation_play(this, "speak_in", nil, store.tick_ts, 1)
			signal.emit("show-balloon_tutorial", this.do_taunt, false)
			U.y_animation_play(this, "speak_loop", nil, store.tick_ts, 2, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)

			this.do_taunt = nil
		end
	end

	while true do
		if this.activate then
			local p = this.activate

			this.activate = nil

			if p == "redboy" then
				U.y_animation_play(this, "skill_family_in", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_red_boy", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "princess" then
				U.y_animation_play(this, "skill_family_in", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_princess", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "stun_hero" then
				U.y_animation_play(this, "skill_family_in", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_princess_hero", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "samadhi_fire" then
				U.y_animation_play(this, "skill_family_in", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_princess_fire", nil, store.tick_ts, 1)
				U.y_animation_play(this, "skill_family_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "golden_eyed" then
				U.y_animation_play(this, "order_warriors", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			end
		end

		manage_taunts()

		if this.summon_boss then
			signal.emit("show-curtains")
			signal.emit("hide-gui")
			signal.emit("start-cinematic")
			signal.emit("pan-zoom-camera", 1, {
				x = 512,
				y = 500
			}, OVtargets(nil, 1.4))
			U.y_wait_unconditional(store, 2.5)
			U.y_animation_play(this, "spawn_in", nil, store.tick_ts, 1)

			this.do_taunt = "LV35_BOSS_PREFIGHT_01"

			manage_taunts()
			U.animation_start_default(this, "spawn_run", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, 0.9)
			S:queue("Stage35BossBullKingStand")

			local shake = E:create_entity("aura_screen_shake")

			shake.aura.amplitude = 2
			shake.aura.duration = 0.7
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, 2.5)
			S:queue("Stage35BossBullKingEat")
			U.y_wait_unconditional(store, 0.7)

			shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.4
			shake.aura.duration = 0.7
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, 0.2)

			shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 2
			shake.aura.duration = 0.7
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, 2.2)
			S:queue("Stage35BossBullKingJumpToPath")
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idle_silla", nil, store.tick_ts, true)

			local boss = E:create_entity("boss_bull_king")
			local ni = P:nearest_nodes(boss.spawn_pos.node_pos.x, boss.spawn_pos.node_pos.y, {boss.spawn_pos.path}, {1}, true)[1][3]

			boss.nav_path.pi = boss.spawn_pos.path
			boss.nav_path.spi = 1
			boss.nav_path.ni = ni
			boss.pos = V.vclone(boss.spawn_pos.node_pos)

			simulation:queue_insert_entity(boss)
			signal.emit("pan-zoom-camera", 1, {
				x = boss.pos.y,
				y = boss.pos.y
			}, OVtargets(nil, 1.1))
			U.y_wait_unconditional(store, 0.7)

			shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 2
			shake.aura.duration = 0.7
			shake.aura.freq_factor = 2

			simulation:queue_insert_entity(shake)
			U.y_wait_unconditional(store, 0.7)
			signal.emit("hide-curtains")
			signal.emit("show-gui")
			signal.emit("end-cinematic")

			return
		end

		coroutine.yield()
	end
end

function controller_stage_35_bull_king.on_samadhi_right(this, store, action)
	this.activate = "samadhi_fire"
end

function controller_stage_35_bull_king.on_samadhi_left(this, store, action)
	this.activate = "samadhi_fire"
end

function controller_stage_35_bull_king.on_stun_hero(this, store, action)
	this.activate = "stun_hero"
end

function controller_stage_35_bull_king.on_golden_eyed(this, store, action)
	this.activate = "golden_eyed"
end

function controller_stage_35_bull_king.on_portal_left(this, store, action)
	this.activate = "redboy"
end

function controller_stage_35_bull_king.on_portal_right(this, store, action)
	this.activate = "princess"
end

local controller_stage_35_golden_beast = {}

function controller_stage_35_golden_beast.update(this, store)
	U.animation_start_default(this, "loop_leon", nil, store.tick_ts, true)

	this.can_spawn = true
	this.defeated = false

	while true do
		if this.activate then

			this.can_spawn = false
			this.activate = nil

			S:queue(this.summon_sound)
			U.y_wait_unconditional(store, 2)
			U.animation_start_default(this, "out", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(100))

			local e = E:create_entity(this.golden_eyed_entity)

			e.nav_path.pi = this.path_id
			e.nav_path.spi = 1
			e.nav_path.ni = 1
			e.pos = V.vclone(this.pos)
			e.do_jump_anim = this

			simulation:queue_insert_entity(e)
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "loop_empty", nil, store.tick_ts, true)
			U.y_wait_unconditional(store, this.empty_wait)
			U.y_animation_play(this, "in", nil, store.tick_ts, 1)

			this.can_spawn = true
		end

		coroutine.yield()
	end
end

function controller_stage_35_golden_beast.on_golden_eyed(this, store, action)
	this.activate = true
end

local controller_stage_35_lava_splash = {}

function controller_stage_35_lava_splash.update(this, store)
	while true do
		local enemies = table.filter(store.entities, function(k, v)
			if v.pending_removal then
				return false
			end

			if not v.enemy or not v.vis or not v.nav_path then
				return false
			end

			if not v.pos then
				return false
			end

			if band(v.vis.flags, this.vis_bans) ~= 0 then
				return false
			end

			if band(v.vis.bans, this.vis_flags) ~= 0 then
				return false
			end

			if not this.paths_x[v.nav_path.pi] then
				return false
			end

			if this.apply_if_enemy_is_to_right then
				if v.pos.x < this.paths_x[v.nav_path.pi] then
					return false
				end
			elseif v.pos.x > this.paths_x[v.nav_path.pi] then
				return false
			end

			if v.passed_lava_tunnel then
				return false
			end

			if v.template_name == "boss_redboy_teen" then
				return false
			end

			return true
		end)

		if #enemies > 0 then
			for _, e in ipairs(enemies) do
				local mod = E:create_entity(this.mod)

				mod.modifier.target_id = e.id
				mod.modifier.source_id = this.id

				simulation:queue_insert_entity(mod)

				e.passed_lava_tunnel = true
			end
		end

		coroutine.yield()
	end
end

local controller_stage_35_portal_door_bosses = {}

function controller_stage_35_portal_door_bosses.update(this, store)
	U.animation_start_default(this, "loop_vacio", nil, store.tick_ts, true)

	while true do
		if this.activate then
			local p = this.activate

			this.activate = nil

			if p == "open" then
				U.y_wait_unconditional(store, fts(69))
				S:queue(this.sound_open)
				U.y_animation_play(this, "in", nil, store.tick_ts, 1)
				U.animation_start(this, "loop_portal", nil, store.tick_ts, true, 1, true)
			elseif p == "close" then
				U.y_animation_play(this, "out", nil, store.tick_ts, 1)
				U.animation_start(this, "loop_vacio", nil, store.tick_ts, true, 1, true)
			end
		end

		coroutine.yield()
	end
end

function controller_stage_35_portal_door_bosses.on_portal_open(this, store, action)
	this.activate = "open"
end

function controller_stage_35_portal_door_bosses.on_portal_close(this, store, action)
	this.activate = "close"
end

local controller_stage_35_princess_powers = {}

function controller_stage_35_princess_powers.update(this, store)
	if not store.restarted and not main.params.skip_cutscenes then
		this.render.sprites[1].hidden = true

		while not this.appear do
			coroutine.yield()
		end

		this.render.sprites[1].hidden = false

		U.y_animation_play(this, "walk", nil, store.tick_ts, 1)
	end

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	local function stun_hero()
		local heroes = U.find_soldiers_in_range(store.soldiers, this.pos, 0, 1e+99, this.stun_hero_vis_flags, this.stun_hero_vis_bans, function(e)
			return e.hero
		end)

		if not heroes or #heroes == 0 then
			return
		end

		local decal_pos = V.vclone(table.random(heroes).pos)

		U.y_animation_play(this, "stun_hero_in", nil, store.tick_ts)
		U.animation_start_default(this, "stun_hero_loop", nil, store.tick_ts, true)

		local heroes = U.find_soldiers_in_range(store.soldiers, this.pos, 0, 1e+99, this.stun_hero_vis_flags, this.stun_hero_vis_bans, function(e)
			return e.hero
		end)

		if heroes and #heroes > 0 then
			decal_pos = V.vclone(table.random(heroes).pos)
		end

		local decal = E:create_entity(this.stun_hero_decal)

		decal.pos = decal_pos

		simulation:queue_insert_entity(decal)

		local failed = false
		local wait_until_ts = store.tick_ts + this.stun_hero_warning_duration

		while wait_until_ts > store.tick_ts do
			if decal:hero_escaped(store) then
				failed = true

				break
			end

			coroutine.yield()
		end

		if not failed and decal:capture_hero(store) then
			U.y_animation_play(this, "stun_hero_action", nil, store.tick_ts)
		else
			decal:finish(store)
			U.y_animation_play(this, "stun_hero_canceled", nil, store.tick_ts)
		end

		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	end

	while true do
		if this.activate then
			local p = this.activate

			this.activate = nil

			if p == "block_tower" then
				local towers = table.filter(store.entities, function(_, e)
					return e.tower and e.tower.can_be_mod and not e.tower.blocked
				end)

				if towers and #towers > 0 then
					local t = table.random(towers)
					local m = E:create_entity(this.block_tower_mod)

					m.modifier.source_id = this.id
					m.modifier.target_id = t.id

					simulation:queue_insert_entity(m)
				end
			elseif p == "stun_hero" then
				U.y_wait_unconditional(store, 3)
				stun_hero()
			elseif p == "portal_in" then
				U.y_wait_unconditional(store, 1.5)
				U.y_animation_play(this, "portal_in", nil, store.tick_ts, 1)
				U.y_animation_play(this, "summon_terracota", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			end
		end

		if this.do_taunt then
			U.y_animation_play(this, "speak_in1", nil, store.tick_ts, 1, 1)
			signal.emit("show-balloon_tutorial", this.do_taunt, false)

			this.do_taunt = nil

			U.y_animation_play(this, "speak_loop1", nil, store.tick_ts, 3, 1)
			U.y_animation_play(this, "speak_out1", nil, store.tick_ts, 1, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		if this.defeated then
			U.y_animation_play(this, "derrota_in", nil, store.tick_ts, 1)
			U.animation_start_default(this, "derrota_loop", nil, store.tick_ts, true)

			return
		end

		coroutine.yield()
	end
end

function controller_stage_35_princess_powers.on_block_tower(this, store, action)
	this.activate = "block_tower"
end

function controller_stage_35_princess_powers.on_stun_hero(this, store, action)
	this.activate = "stun_hero"
end

function controller_stage_35_princess_powers.on_portal_right(this, store, action)
	this.activate = "portal_in"
end

local controller_stage_35_redboy_powers = {}

function controller_stage_35_redboy_powers.update(this, store)
	if not store.restarted and not main.params.skip_cutscenes then
		this.render.sprites[1].hidden = true

		while not this.appear do
			coroutine.yield()
		end

		this.render.sprites[1].hidden = false

		U.y_animation_play(this, "walk", nil, store.tick_ts, 1)
	end

	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	while true do
		if this.activate then
			local p = this.activate

			this.activate = nil

			if p == "samadhi_right" then
				U.y_wait_unconditional(store, 3)
				S:queue("Stage32RedboyDragonSamadhiFireEnd", {
					delay = fts(1)
				})

				local fireball = E:create_entity("fx_stage_35_fireball_right")

				fireball.pos.x, fireball.pos.y = 512, 382

				simulation:queue_insert_entity(fireball)
				U.y_animation_play(this, "samadhi_loop", nil, store.tick_ts, 3)
				U.y_animation_play(this, "samadhi_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "samadhi_left" then
				U.y_wait_unconditional(store, 3)
				S:queue("Stage32RedboyDragonSamadhiFireEnd", {
					delay = fts(1)
				})

				local fireball = E:create_entity("fx_stage_35_fireball_left")

				fireball.pos.x, fireball.pos.y = 512, 382

				simulation:queue_insert_entity(fireball)
				U.y_animation_play(this, "samadhi_loop", nil, store.tick_ts, 3)
				U.y_animation_play(this, "samadhi_end", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			elseif p == "portal_in" then
				U.y_wait_unconditional(store, 1.5)
				U.y_animation_play(this, "activate_portal", nil, store.tick_ts, 1)
				U.y_animation_play(this, "summon_creeps", nil, store.tick_ts, 1)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end
		end

		if this.do_taunt then
			signal.emit("show-balloon_tutorial", this.do_taunt, false)

			this.do_taunt = nil

			U.y_animation_play(this, "talk", nil, store.tick_ts, 2, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		if this.defeated then
			U.y_animation_play(this, "defeat_in", nil, store.tick_ts, 1)
			U.animation_start_default(this, "defeat_loop", nil, store.tick_ts, true)

			return
		end

		coroutine.yield()
	end
end

function controller_stage_35_redboy_powers.on_samadhi_right(this, store, action)
	this.activate = "samadhi_right"
end

function controller_stage_35_redboy_powers.on_samadhi_left(this, store, action)
	this.activate = "samadhi_left"
end

function controller_stage_35_redboy_powers.on_portal_left(this, store, action)
	this.activate = "portal_in"
end

tt = E:register_t_hot("decal_stage_35_mask_boss_bull_left", "decal", true)
tt.render.sprites[1].name = "stage35_mask_shadow_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_35_fume_entradas", "decal_scripted", true)
tt.main_script.update = decal_stage_35_fume_entradas_update
tt.render.sprites[1].prefix = "stage_35_fumeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_35_mask_boss_bull_right", "decal_stage_35_mask_boss_bull_left", true)
tt.render.sprites[1].flip_x = true

tt = E:register_t_hot("decal_stage_35_mask_redboy_bottom", "decal", true)
tt.render.sprites[1].name = "stage35_mask_mask_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -30

tt = E:register_t_hot("decal_stage_35_mask_princess_bottom", "decal_stage_35_mask_redboy_bottom", true)
tt.render.sprites[1].flip_x = true

tt = E:register_t_hot("controller_stage_35", "decal_scripted", true)
E:add_comps(tt, "editor", "ui", "events")
tt.main_script.update = controller_stage_35_update
tt.render.sprites[1].prefix = "stage_5_cinematicaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].pos = v(0, 0)
tt.events.list[1].name = "barrage"
tt.events.list[1].on_event = controller_stage_35_on_event
tt.fixed_screen_offset = v(40, 40)

tt = E:register_t_hot("decal_stage_35_mask_boss_bull", "decal", true)
tt.render.sprites[1].name = "stage35_mask_boss"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 200

tt = E:register_t_hot("decal_stage_35_mask_path_open", "decal", true)
tt.render.sprites[1].name = "stage35_mask_path_open"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("decal_stage_35_mask_redboy_top", "decal", true)
tt.render.sprites[1].name = "stage35_mask_bosses"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].sort_y_offset = -86

tt = E:register_t_hot("decal_stage_35_mask_princess_top", "decal_stage_35_mask_redboy_top", true)
tt.render.sprites[1].flip_x = true

tt = E:register_t_hot("controller_stage_35_redboy_powers", "decal_scripted", true)
E:add_comps(tt, "events")
tt.main_script.update = controller_stage_35_redboy_powers.update
tt.render.sprites[1].prefix = "redboy_stage5Def"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].sort_y_offset = -85
tt.events.list[1].name = "samadhi_right"
tt.events.list[1].on_event = controller_stage_35_redboy_powers.on_samadhi_right
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "samadhi_left"
tt.events.list[2].on_event = controller_stage_35_redboy_powers.on_samadhi_left
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "portal_left"
tt.events.list[3].on_event = controller_stage_35_redboy_powers.on_portal_left

tt = E:register_t_hot("controller_stage_35_princess_powers", "decal_scripted", true)
E:add_comps(tt, "events")
tt.main_script.update = controller_stage_35_princess_powers.update
tt.render.sid_unit = 1
tt.render.sprites[tt.render.sid_unit].prefix = "ironfan_stage5Def"
tt.render.sprites[tt.render.sid_unit].exo = true
tt.render.sprites[tt.render.sid_unit].flip_x = true
tt.render.sprites[tt.render.sid_unit].name = "idle"
tt.render.sprites[tt.render.sid_unit].sort_y_offset = -85
tt.block_tower_mod = "boss_princess_iron_fan_tower_debuff"
tt.stun_hero_decal = "decal_boss_princess_iron_fan_stun_heroes_waves"
tt.stun_hero_vis_flags = bor(F_MOD, F_STUN, F_AREA)
tt.stun_hero_vis_bans = bor(0)
tt.stun_hero = {
	WARNING_DURATION = 4,
	DURATION = 13,
	[5] = {
		cd = 15,
		first_cd = {5}
	},
	[9] = {
		cd = 12.5,
		first_cd = {8}
	},
	[14] = {
		cd = 8,
		first_cd = {13}
	},
	[15] = {
		cd = 7.5,
		first_cd = {10}
	}
}
tt.stun_hero_warning_duration = 4
tt.events.list[1].name = "block_tower"
tt.events.list[1].on_event = controller_stage_35_princess_powers.on_block_tower
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "stun_hero"
tt.events.list[2].on_event = controller_stage_35_princess_powers.on_stun_hero
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "portal_right"
tt.events.list[3].on_event = controller_stage_35_princess_powers.on_portal_right

tt = E:register_t_hot("controller_stage_35_portal_left", "decal_scripted", true)
E:add_comps(tt, "events")
tt.main_script.update = controller_stage_35_portal_door_bosses.update
tt.render.sprites[1].prefix = "stage_5_puerta_redboyDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.events.list[1].name = "portal_left"
tt.events.list[1].on_event = controller_stage_35_portal_door_bosses.on_portal_open
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "portal_left_close"
tt.events.list[2].on_event = controller_stage_35_portal_door_bosses.on_portal_close

tt = E:register_t_hot("controller_stage_35_portal_right", "controller_stage_35_portal_left", true)
tt.render.sprites[1].prefix = "stage_5_puerta_princessDef"
tt.render.sprites[1].flip_x = true
tt.events.list[1].name = "portal_right"
tt.events.list[2].name = "portal_right_close"
tt.sound_open = "Stage35PortalWater"

tt = E:register_t_hot("controller_stage_35_lava_splash", "controller_stage_32_lava_splash", true)
tt.main_script.update = controller_stage_35_lava_splash.update
tt.apply_if_enemy_is_to_right = false
tt.mod = "mod_stage_35_lava_splash"
tt.paths_x = {
	[15] = 0,
	[7] = 0
}

tt = E:register_t_hot("controller_stage_35_bull_king", "decal_scripted", true)
E:add_comps(tt, "events", "editor")
tt.main_script.update = controller_stage_35_bull_king.update
tt.render.sprites[1].prefix = "stage_35_boss_bull_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 205
tt.events.list[1].name = "samadhi_right"
tt.events.list[1].on_event = controller_stage_35_bull_king.on_samadhi_right
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "samadhi_left"
tt.events.list[2].on_event = controller_stage_35_bull_king.on_samadhi_left
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "stun_hero"
tt.events.list[3].on_event = controller_stage_35_bull_king.on_stun_hero
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "golden_beast_right"
tt.events.list[4].on_event = controller_stage_35_bull_king.on_golden_eyed
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "golden_beast_left"
tt.events.list[5].on_event = controller_stage_35_bull_king.on_golden_eyed
tt.events.list[6] = E:clone_c("event")
tt.events.list[6].name = "portal_left"
tt.events.list[6].on_event = controller_stage_35_bull_king.on_portal_left
tt.events.list[7] = E:clone_c("event")
tt.events.list[7].name = "portal_right"
tt.events.list[7].on_event = controller_stage_35_bull_king.on_portal_right

tt = E:register_t_hot("controller_stage_35_golden_eyed_left", "decal_scripted", true)
E:add_comps(tt, "events")
tt.main_script.update = controller_stage_35_golden_beast.update
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.render.sprites[1].name = "loop_leon"
tt.render.sprites[1].exo = true
tt.events.list[1].name = "golden_beast_left"
tt.events.list[1].on_event = controller_stage_35_golden_beast.on_golden_eyed
tt.path_id = 5
tt.empty_wait = 2
tt.golden_eyed_entity = "enemy_golden_eyed"
tt.summon_sound = "EnemyGoldenEyedSummon"

tt = E:register_t_hot("controller_stage_35_water_splash", "controller_stage_35_lava_splash", true)
tt.apply_if_enemy_is_to_right = true
tt.mod = "mod_stage_35_water_splash"
tt.paths_x = {
	[8] = 1025
}

tt = E:register_t_hot("controller_stage_35_golden_eyed_right", "controller_stage_35_golden_eyed_left", true)
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.events.list[1].name = "golden_beast_right"
tt.path_id = 6

