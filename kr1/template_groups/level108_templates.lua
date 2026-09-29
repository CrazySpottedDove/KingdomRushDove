local stage_08_gem_basket
local E = require("entity_db")
local V = require("lib.klua.vector")
local v = V.v
local S = require("sound_db")
local U = require("utils")
local signal = require("lib.hump.signal")
local tt
stage_08_gem_basket = {}

function stage_08_gem_basket.update(this, store)
	local tap_count = 0
	local taps_to_fall = 3
	local controller

	for _, v in pairs(store.entities) do
		if v.template_name == "controller_stage_08_gem_baskets" then
			controller = v
		end
	end

	while true do
		if this.ui.clicked then
			tap_count = tap_count + 1
			this.ui.clicked = nil
			this.ui.can_click = false

			if tap_count == taps_to_fall then
				S:queue("Stage08BasketBreak")
				U.animation_start_default(this, "action2", nil, store.tick_ts, false)

				if this.gold_pos_offset then
					U.y_wait_unconditional(store, fts(5))

					local rect_pos = v(this.ui.click_rect.pos.x + this.ui.click_rect.size.x / 2, this.ui.click_rect.pos.y + this.ui.click_rect.size.y / 2)
					local gold_pos = V.v(this.pos.x + rect_pos.x + this.gold_pos_offset.x, this.pos.y + rect_pos.y + this.gold_pos_offset.y)

					signal.emit("got-gold", gold_pos, this.gold_amount)
				end

				break
			else
				S:queue("Stage08BasketTap")
				U.y_animation_play(this, "action", nil, store.tick_ts, 1)
			end

			this.ui.can_click = true
		end

		coroutine.yield()
	end

	controller.baskets_down = controller.baskets_down + 1
end

local scripts = require("game_scripts")
local function fts(v)
	return v / FPS
end

local controller_stage_08_elf_rescue = {}

function controller_stage_08_elf_rescue.update(this, store)
	if store.level_mode == GAME_MODE_IRON then
		for i = 1, 4 do
			local elf_spawned = E:create_entity(this.entity_elf)

			elf_spawned.pos = this.elf_pos[i]
			elf_spawned.elf_rescued = i

			simulation:queue_insert_entity(elf_spawned)
			U.y_wait_unconditional(store, fts(math.random(10, 30)))
		end

		simulation:queue_remove_entity(this)

		return
	end

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	local elf_rescued = 0
	local guard_spawned
	local guard_dead_ts = store.tick_ts - this.spawn_cooldown
	local chain_spawned, elf_slave_spawned

	while true do
		if guard_spawned and guard_spawned.health.dead then
			guard_spawned = nil
			elf_rescued = elf_rescued + 1
			guard_dead_ts = store.tick_ts

			U.y_wait_unconditional(store, fts(280))

			local elf_spawned = E:create_entity(this.entity_elf)

			elf_spawned.pos = this.elf_pos[elf_rescued]
			elf_spawned.elf_rescued = elf_rescued

			simulation:queue_insert_entity(elf_spawned)

			if elf_rescued >= #this.elf_pos then
				U.y_wait_unconditional(store, 1)
				signal.emit("elves-stage08", this)
			end
		end

		if not guard_spawned and elf_rescued < #this.elf_pos and store.tick_ts - guard_dead_ts > this.spawn_cooldown then
			guard_spawned = E:create_entity(this.entity_guard)
			guard_spawned.pos = this.pos_guard

			simulation:queue_insert_entity(guard_spawned)

			chain_spawned = E:create_entity(this.entity_chain)
			chain_spawned.pos = this.pos_chain
			chain_spawned.guard_entity = guard_spawned

			simulation:queue_insert_entity(chain_spawned)

			elf_slave_spawned = E:create_entity(this.entity_elf_slave)
			elf_slave_spawned.pos = this.pos_elf_slave
			elf_slave_spawned.guard_entity = guard_spawned

			simulation:queue_insert_entity(elf_slave_spawned)
		end

		coroutine.yield()
	end
end

local controller_stage_08_gem_baskets = {}

function controller_stage_08_gem_baskets.update(this, store)
	this.baskets_down = 0

	while true do
		if this.baskets_down == 3 then
			signal.emit("baskets-stage08", this)

			break
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_08_fire", "decal", true)
tt.render.sprites[1].prefix = "fire_stage_8Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1

tt = E:register_t_hot("decal_stage_08_gem_basket_big_clickable", "decal_scripted", true)
E:add_comps(tt, "editor", "ui")
tt.render.sprites[1].prefix = "stage_8_gems_basket_bigDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = stage_08_gem_basket.update
tt.ui.click_rect = r(-525, 200, 50, 50)
tt.gold_pos_offset = v(0, -30)
tt.gold_amount = 30

tt = E:register_t_hot("decal_stage_08_gem_basket_small_clickable", "decal_stage_08_gem_basket_big_clickable", true)
tt.render.sprites[1].prefix = "stage_8_gems_basket_smallDef"
tt.ui.click_rect = r(138, 248, 40, 40)

tt = E:register_t_hot("decal_stage_08_gem_basket_third_clickable", "decal_stage_08_gem_basket_big_clickable", true)
tt.render.sprites[1].prefix = "stage_8_gems_basket_thirdDef"
tt.ui.click_rect = r(477, -260, 50, 50)
tt.gold_pos_offset = nil

tt = E:register_t_hot("controller_stage_08_elf_rescue", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.update = controller_stage_08_elf_rescue.update
tt.entity_elf = "soldier_elf_stage_08"
tt.entity_guard = "enemy_unblinded_abomination_stage_8"
tt.entity_elf_slave = "decal_stage_08_elf_rescue_elf_slave"
tt.entity_chain = "decal_stage_08_elf_rescue_chains"
tt.elf_pos = {v(390, 625), v(750, 675), v(230, 625), v(930, 640)}
tt.pos_guard = v(490, 550)
tt.pos_chain = v(448, 541)
tt.pos_elf_slave = v(428, 540)
tt.spawn_cooldown = 90

tt = E:register_t_hot("stage_08_mask_1", "decal", true)
tt.render.sprites[1].name = "T2_Stage_8_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.y = -235

tt = E:register_t_hot("stage_08_mask_2", "decal", true)
tt.render.sprites[1].name = "T2_Stage_8_mask_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.y = -235

tt = E:register_t_hot("stage_08_mask_3", "decal", true)
tt.render.sprites[1].name = "T2_Stage_8_mask_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.y = -185

tt = E:register_t_hot("stage_08_mask_4", "decal", true)
tt.render.sprites[1].name = "T2_Stage_8_mask_4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.y = -250

tt = E:register_t_hot("controller_stage_08_gem_baskets", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_08_gem_baskets.update

