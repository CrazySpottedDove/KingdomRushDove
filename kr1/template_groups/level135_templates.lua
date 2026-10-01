local signal = require("lib.hump.signal")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local GR = require("grid_db")
local SU = require("script_utils")
local vv = V.vv
local anchor_y = 0.15
local image_y = 64
local function ady(v)
	return v - anchor_y * image_y
end
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

tt = E:register_t_tmp("fx_stage_35_cannonball", "decal_scripted")
tt.main_script.update = function(this, store)
	if this.start_delay then
		U.sprites_hide(this, nil, nil, true)
		U.y_wait_unconditional(store, this.start_delay)
		U.sprites_show(this, nil, nil, true)
	end

	if not this.unit_spawns and not this.force_eyes then
		this.render.sprites[1].prefix = "stage5_destruccion_holder_sinojosDef"
	end

	U.animation_start(this, "run", nil, store.tick_ts, false, 1, true)
	U.y_wait_unconditional(store, fts(38))

	if this.unit_spawns then
		local nearest_nodes = P:nearest_nodes(this.rally_dest.x, this.rally_dest.y)
		local n = nearest_nodes[1]

		for _, spawn_cfg in pairs(this.unit_spawns) do
			local npos = P:node_pos(n[1], spawn_cfg.spi, n[3] + spawn_cfg.ni_offset)
			local e = E:create_entity(spawn_cfg.unit)

			e.pos.x = this.pos.x + math.random(-15, 15)
			e.pos.y = this.pos.y + math.random(-15, 15)
			e.nav_rally.pos = V.vclone(npos)
			e.nav_rally.center = V.vclone(npos)

			simulation:queue_insert_entity(e)
			U.y_wait_unconditional(store, fts(2))
		end
	end

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 1.5
	shake.aura.duration = 0.5
	shake.aura.freq_factor = 4

	simulation:queue_insert_entity(shake)

	if this.destroy_path then
		for _, e in pairs(store.entities) do
			if e.template_name == "decal_stage_35_mask_path_closed" then
				e.render.sprites[1].hidden = false
			elseif e.template_name == "decal_defense_flag" or e.template_name == "decal_defend_point" or e.template_name == "decal_upgrade_alliance_flux_altering_coils" or e.template_name == "decal_upgrade_alliance_seal_of_punishment" then
				if e.pos and e.pos.x > 420 and e.pos.x < 680 then
					simulation:queue_remove_entity(e)
				end
			elseif e.enemy and not e.health.dead and not e.pending_removal and e.nav_path and P:is_node_valid(e.nav_path.pi, e.nav_path.ni) then
				if e.nav_path.pi == 1 then
					e.nav_path.pi = 13
					e.nav_path.ni = e.nav_path.ni + 3
				elseif e.nav_path.pi == 2 then
					e.nav_path.pi = 14
					e.nav_path.ni = e.nav_path.ni + 3
				elseif e.nav_path.pi == 7 then
					e.nav_path.pi = 15
					e.nav_path.ni = e.nav_path.ni + 3
				end
			elseif e.soldier and e.nav_rally and not U.flag_has(e.vis.flags, F_FLYING) and not e.soldier.tower_id then
				local x, y = GR:get_coords(e.pos.x, e.pos.y)

				if x > 42 and x < 50 and y > 1 and y < 9 then
					local pos_new_x, pos_new_y = GR:cell_pos(x, math.random(10, 12))

					e.nav_grid.waypoints = {}

					table.insert(e.nav_grid.waypoints, V.v(pos_new_x, pos_new_y))

					e.nav_rally.new = true
					e.nav_rally.center.x = pos_new_x
					e.nav_rally.center.y = pos_new_y
					e.nav_rally.pos.x = pos_new_x
					e.nav_rally.pos.y = pos_new_y
				end
			end
		end

		for i = 42, 50 do
			for j = 1, 9 do
				GR:set_cell(i, j, TERRAIN_NOWALK)
			end
		end

		for i = 12, 15 do
			local boss_path_start = P:nearest_nodes(555, 270, {i})[1][3]
			local boss_path_end = P:get_end_node(i)

			P:remove_invalid_range(i, boss_path_start, boss_path_end)

			for k, ignored_path in pairs(store.level.ignore_walk_backwards_paths) do
				if ignored_path == i then
					store.level.ignore_walk_backwards_paths[k] = nil

					break
				end
			end
		end
	end

	local targets = U.find_enemies_in_range_filter_off(this.pos, 100, F_AREA, F_BOSS)

	if targets and #targets > 0 then
		for _, target in ipairs(targets) do
			target.health.hp = 0
		end
	end

	if this.boss_entity_ref then
		if this.rage_boss then
			this.boss_entity_ref.do_rage = true
		end

		if this.damage_boss then
			this.boss_entity_ref.health.hp = this.boss_entity_ref.health.hp - 500
		end
	end

	if this.spawn_escombro then
		local decal

		if this.spawn_escombro == "camino" then
			decal = E:create_entity(this.escombro_camino)
		else
			decal = E:create_entity(this.escombro_holder)
		end

		if math.random() > 0.5 then
			decal.render.sprites[1].flip_x = true
		end

		decal.pos.x, decal.pos.y = this.pos.x, this.pos.y
		decal.tween.ts = store.tick_ts
		decal.render.sprites[1].scale = this.render.sprites[1].scale

		simulation:queue_insert_entity(decal)
	end

	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end
tt.render.sprites[1].prefix = "stage5_destruccion_holderDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -30
tt.escombro_camino = "decal_stage_35_escombros_cannonball_camino"
tt.escombro_holder = "decal_stage_35_escombros_cannonball_holder"

tt = E:register_t_tmp("fx_stage_35_cannonball_open_path", "decal_scripted")
tt.main_script.update = function(this, store)
	U.y_wait_unconditional(store, fts(60))
	this.render.sprites[1].hidden = false
	U.animation_start_default(this, "in", nil, store.tick_ts, false)
	U.y_wait_unconditional(store, fts(39))

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 1.5
	shake.aura.duration = 0.5
	shake.aura.freq_factor = 4

	simulation:queue_insert_entity(shake)
	U.y_animation_wait_default(this)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
end
tt.render.sprites[1].prefix = "stage_5_pokebola_tntDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -130

tt = E:register_t_tmp("fx_stage_35_cannonball_block_path", "decal_scripted")
tt.main_script.update = function(this, store)
	U.animation_start_default(this, "in", nil, store.tick_ts, false)
	U.y_wait_unconditional(store, fts(39))

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 1.5
	shake.aura.duration = 1
	shake.aura.freq_factor = 4

	simulation:queue_insert_entity(shake)
	U.y_animation_wait_default(this)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
end
tt.render.sprites[1].prefix = "stage_5_bloqueo_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -450

tt = E:register_t_tmp("soldier_stage_35_cannonball", "soldier_militia")
E:add_comps(tt, "reinforcement", "nav_path", "tween")
-- tt.info.portrait = "gui_bottom_info_image_soldiers_0076"
tt.info.portrait = "kr5_info_portraits_soldiers_0001"
tt.health.hp_max = 90
tt.health.armor = 0
tt.health_bar.offset = v(0, 35)
tt.info.random_name_count = 5
tt.info.random_name_format = "SOLDIER_CANNONBALL_%i_NAME"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = function(this, store)
	local attack = this.melee.attacks[1]
	local brk, sta, nearest
	local next_pos = V.vclone(this.pos)
	local target
	local moving_forward = false
	local search_enemies_ts = store.tick_ts

	this.reinforcement.ts = store.tick_ts

	local starting_pos = V.vclone(this.nav_rally.pos)

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true
		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local patrol_pos = V.vclone(this.nav_rally.pos)

	patrol_pos.x, patrol_pos.y = patrol_pos.x + this.patrol_pos_offset.x, patrol_pos.y + this.patrol_pos_offset.y

	local nearest_node = P:nearest_nodes(patrol_pos.x, patrol_pos.y, nil, nil, false)[1]
	local pi, spi, ni = unpack(nearest_node)
	local npos = P:node_pos(pi, spi, ni)
	local patrol_pos_2 = V.vclone(this.nav_rally.pos)

	patrol_pos_2.x, patrol_pos_2.y = patrol_pos_2.x - this.patrol_pos_offset.x, patrol_pos_2.y - this.patrol_pos_offset.y

	local nearest_node = P:nearest_nodes(patrol_pos_2.x, patrol_pos_2.y, nil, nil, false)[1]
	local pi, spi, ni = unpack(nearest_node)
	local npos_2 = P:node_pos(pi, spi, ni)

	if V.dist2(patrol_pos.x, patrol_pos.y, npos.x, npos.y) > V.dist2(patrol_pos_2.x, patrol_pos_2.y, npos_2.x, npos_2.y) then
		patrol_pos = V.vclone(patrol_pos_2)
	end

	local idle_ts = store.tick_ts
	local patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

	while true do
		if this.health.dead or not next_pos then
			if not next_pos then
				this.reinforcement.fade = true
				this.reinforcement.fade_out = true
			end

			SU.y_soldier_death(store, this)
			simulation:queue_remove_entity(this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)

			idle_ts = store.tick_ts
			patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
		else
			if not moving_forward then
				if search_enemies_ts < store.tick_ts then
					search_enemies_ts = store.tick_ts + fts(7)

					local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, 0, 100, nil, F_BLOCK, bit.bor(F_CLIFF), true)

					if targets_info and #targets_info > 0 then
						moving_forward = true
						next_pos = V.vclone(this.pos)

						local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, {1, 2, 3, 4})
						local n = nearest_nodes[1]

						this.nav_path.pi = n[1]
						this.nav_path.spi = n[2]
						this.nav_path.ni = n[3]
					end
				end

				if SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)

					if patrol_cd < store.tick_ts - idle_ts then
						if this.nav_rally.pos == starting_pos then
							this.nav_rally.pos = patrol_pos
						else
							this.nav_rally.pos = starting_pos
						end

						idle_ts = store.tick_ts
						patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
					end
				end
			else
				this.nav_rally.center.x, this.nav_rally.center.y = this.pos.x, this.pos.y
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
				-- block empty
				else
					nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

					if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
						this.nav_path.ni = nearest[1][3]
					end

					while next_pos and not target and not this.health.dead and not this.unit.is_stunned do
						U.set_destination(this, next_pos)

						local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

						U.animation_start_default(this, an, af, store.tick_ts, true)
						U.walk_off__accel__unsnapped(this, store.tick_length)
						coroutine.yield()

						target = U.find_foremost_enemy_in_range_filter_off(this.pos, this.melee.range, false, attack.vis_flags, attack.vis_bans)
						next_pos = P:next_entity_node(this, store.tick_length)

						if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or GR:cell_is(next_pos.x, next_pos.y, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) then
							next_pos = nil
						end
					end

					target = nil
				end
			end
		end

		coroutine.yield()
	end
end
tt.melee.range = 100
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 13
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].hit_time = fts(11)
tt.soldier.melee_slot_offset = v(8, 0)
tt.render.sprites[1].prefix = "sate_5_mono_unit"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = vv(0.5)
tt.soldier.melee_slot_offset.x = 3
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.reinforcement.fade_out = false
tt.unit.mod_offset = v(0, ady(22))
tt.ui.click_rect = r(-15, -2, 30, 35)
tt.patrol_pos_offset = v(15, 10)
tt.patrol_min_cd = 5
tt.patrol_max_cd = 10
tt.nav_path.dir = -1
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.loop = false
tt.tween.disabled = true

tt = E:register_t_tmp("fx_stage_35_small_spawner_fx", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage_5_spawner_fxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].delay_start = fts(2)
tt.render.sprites[1].hidden = true

tt = E:register_t_tmp("decal_stage_35_escombros_holder_1", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(2, -16)

tt = E:register_t_tmp("decal_stage_35_escombros_holder_2", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(0, -3)

tt = E:register_t_tmp("decal_stage_35_escombros_holder_3", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_tmp("decal_stage_35_escombros_cannonball_camino", "decal_tween")
tt.render.sprites[1].name = "destruccion_holder_escombros_camino"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {14, 255}, {16, 0}}
tt.tween.disabled = false

tt = E:register_t_tmp("decal_stage_35_escombros_cannonball_holder", "decal_stage_35_escombros_cannonball_camino")
tt.render.sprites[1].name = "destruccion_holder_escombros_oro"
tt.render.sprites[1].offset = v(0, 20)

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_1", "tower_holder_blocked")
tt.pre_destroy = function(this, store)
	if this.sound then
		S:queue(this.sound)
	end

	if not this.pre_destroy_cannonballs_list then
		return
	end

	if #this.pre_destroy_cannonballs_list == 0 then
		return
	end

	for _, t in pairs(this.pre_destroy_cannonballs_list) do
		local e = E:create_entity(this.cannonball_fx)

		e.pos.x, e.pos.y = t.pos.x, t.pos.y
		e.start_delay = t.delay
		e.unit_spawns = t.unit_spawns
		e.rally_dest = t.rally_dest
		e.spawn_escombro = t.spawn_escombro

		simulation:queue_insert_entity(e)
	end
end
tt.destroy_house = function(this, store)
	if not this.unlock_holder_type then
		return
	end

	if this.cannonball_fx then
		local cannonball = E:create_entity(this.cannonball_fx)

		cannonball.start_delay = 0
		cannonball.pos = V.vclone(this.pos)
		cannonball.render.sprites[1].ts = store.tick_ts
		cannonball.spawn_escombro = this.spawn_escombro
		cannonball.force_eyes = true

		simulation:queue_insert_entity(cannonball)
		U.y_wait_unconditional(store, fts(38))
	end

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 2
	shake.aura.duration = 0.7
	shake.aura.freq_factor = 3

	simulation:queue_insert_entity(shake)

	this.tower.upgrade_to = this.unlock_holder_type
	this.tower.can_hover = true
	this.ui.can_click = true

	if this.destroy_small_spawner_nmbr then
		for _, e in pairs(store.entities) do
			if e.template_name == "controller_stage_35_small_spawner" and e.spawner_nmbr == this.destroy_small_spawner_nmbr then
				simulation:queue_remove_entity(e)
			end
		end
	end

	if this.decal then
		local e = E:create_entity(this.decal)

		e.pos.x, e.pos.y = 512, 384

		simulation:queue_insert_entity(e)
	end

	if this.unit_spawns then
		local nearest_nodes = P:nearest_nodes(this.tower.default_rally_pos.x, this.tower.default_rally_pos.y)
		local n = nearest_nodes[1]

		for _, spawn_cfg in pairs(this.unit_spawns) do
			local npos = P:node_pos(n[1], spawn_cfg.spi, n[3] + spawn_cfg.ni_offset)
			local e = E:create_entity(spawn_cfg.unit)

			e.pos.x = this.pos.x + math.random(-15, 15)
			e.pos.y = this.pos.y + math.random(-15, 15)
			e.nav_rally.pos = V.vclone(npos)
			e.nav_rally.center = V.vclone(npos)

			simulation:queue_insert_entity(e)
			U.y_wait_unconditional(store, fts(2))
		end
	end
end
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "stage35_deco1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.13035714285714287, 0.2727864583333333)
tt.cannonball_fx = "fx_stage_35_cannonball"
tt.spawn_escombro = "holder"
tt.sound = "Stage35Cinematic1"
tt.unit_spawns = {{
	unit = "soldier_stage_35_cannonball",
	spi = 2,
	ni_offset = 0
}, {
	unit = "soldier_stage_35_cannonball",
	spi = 1,
	ni_offset = 8
}, {
	unit = "soldier_stage_35_cannonball",
	spi = 3,
	ni_offset = 4
}}
tt.pre_destroy_cannonballs_list = {{
	delay = 5.6,
	spawn_escombro = "camino",
	pos = v(150, 240)
}, {
	delay = 6,
	spawn_escombro = "camino",
	pos = v(80, 350)
}}
tt.cinematic_camera_duration_offset = 0
tt.ui.can_click = false
tt.ui.can_select = false

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_2", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco2"
tt.render.sprites[1].anchor = v(0.7857142857142857, 0.7272135416666666)
tt.unit_spawns = nil
tt.spawn_escombro = "holder"
tt.cinematic_camera_duration_offset = -1.4
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_3", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco3"
tt.render.sprites[1].anchor = v(0.23, 0.673828125)
tt.unit_spawns = nil
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = {{
	delay = 5.5,
	spawn_escombro = "camino",
	pos = v(300, 460)
}}
tt.sound = "Stage35Cinematic3"

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_4", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco4"
tt.render.sprites[1].anchor = v(0.7767857142857143, 0.3190104166666667)
tt.spawn_escombro = "holder"
tt.pre_destroy_cannonballs_list = {{
	delay = 5.8,
	spawn_escombro = "camino",
	pos = v(883, 397)
}}
tt.sound = "Stage35Cinematic2"

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_5", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 1
tt.decal = "decal_stage_35_escombros_holder_2"
tt.cinematic_camera_duration_offset = -0.4
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = {{
	delay = 1.1,
	spawn_escombro = "camino",
	pos = v(872, 527)
}}
tt.sound = nil

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_6", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 3
tt.decal = "decal_stage_35_escombros_holder_1"
tt.spawn_escombro = "holder"
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil

tt = E:register_t_tmp("tower_holder_blocked_stage_35_house_7", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 2
tt.decal = "decal_stage_35_escombros_holder_3"
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil

tt = E:register_t_tmp("controller_stage_35_small_spawner", "decal_scripted")
E:add_comps(tt, "events", "editor")
tt.unit_spawned = function(this, store)
	local fx = E:create_entity("fx_stage_35_small_spawner_fx")

	fx.pos.x, fx.pos.y = this.pos.x, this.pos.y - 10
	fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(fx)
end
tt.main_script.update = function(this, store)
	local nearest_node = P:nearest_nodes(this.pos.x, this.pos.y, {9, 10, 11}, {1, 2, 3})[1]
	local pi = nearest_node[1]

	if not store.level.small_spawner then
		store.level.small_spawner = {}
	end

	store.level.small_spawner[pi] = this.id

	while true do
		if this.activate then
			local p = this.activate

			this.activate = nil

			if p == "open" then
				S:queue(this.sound_open)
				U.sprites_show(this, 3, 3, true)
				U.y_animation_play(this, "in", nil, store.tick_ts, 1, 3)
				U.animation_start(this, "loop_portal", nil, store.tick_ts, true, 3, true)
			elseif p == "close" then
				U.y_animation_play(this, "out", nil, store.tick_ts, 1, 3)
				U.sprites_hide(this, 3, 3, true)
			end
		end

		coroutine.yield()
	end
end
tt.render.sprites[1].name = "stage35_spawner_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage35_spawner_puerta"
tt.render.sprites[2].animated = false
tt.render.sprites[2].sort_y_offset = -23
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "stage_5_spawnerDef"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].exo = true
tt.render.sprites[3].hidden = true
tt.render.sprites[3].sort_y_offset = -23
tt.spawner_nmbr = 0
tt.events.list[1].name = "spawner_open"
tt.events.list[1].on_event = function(this, store, action, nmbr)
	if this.spawner_nmbr ~= tonumber(nmbr) then
		return
	end

	this.activate = "open"
end
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "spawner_close"
tt.events.list[2].on_event = function(this, store, action, nmbr)
	if this.spawner_nmbr ~= tonumber(nmbr) then
		return
	end

	this.activate = "close"
end
tt.sound_open = "Stage35Spawners"

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

tt = E:register_t_hot("controller_stage_35_golden_eyed_right", "controller_stage_35_golden_eyed_left", true)
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.events.list[1].name = "golden_beast_right"
tt.path_id = 6

