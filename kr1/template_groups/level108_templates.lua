local stage_08_gem_basket
local E = require("entity_db")
local V = require("lib.klua.vector")
local v = V.v
local S = require("sound_db")
local SU = require("script_utils")
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

tt = E:register_t_tmp("soldier_elf_stage_08", "decal_scripted")
E:add_comps(tt, "bullet_attack", "editor")
tt.render.sprites[1].prefix = "elven_warrior"
tt.render.sprites[1].name = "idle"
tt.main_script.update = function(this, store)
	local a = this.bullet_attack

	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)

	if this.elf_rescued == 3 or this.elf_rescued == 2 then
		U.y_animation_play(this, "walk1", nil, store.tick_ts, 1)
	else
		U.y_animation_play(this, "walk2", nil, store.tick_ts, 1)
	end

	local is_resting = true
	local last_shoot = store.tick_ts

	a.ts = store.tick_ts - a.cooldown

	while true do
		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_foremost_enemy_in_range_filter_off(this.pos, a.max_range, false, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.2)

				goto label_1083_0
			elseif target and target.health and not target.health.dead then
				a.ts = store.tick_ts

				local b = E:create_entity(a.bullet)
				local shooting_right = this.pos.x < target.pos.x
				local boffset = a.bullet_start_offset[shooting_right and 1 or 2]

				b.bullet.from = V.v(this.pos.x + boffset.x, this.pos.y + boffset.y)
				b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.pos = V.vclone(b.bullet.from)

				local target_pos = target.pos
				local an, af = U.animation_name_facing_point(this, a.animation, target_pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)
				U.y_wait_unconditional(store, a.shoot_time)
				simulation:queue_insert_entity(b)
				S:queue("ArrowSound")
				U.y_animation_wait_default(this)

				local an, af = U.animation_name_facing_point(this, "back_to_idle2", target_pos)

				U.animation_start_default(this, an, af, store.tick_ts, false)

				is_resting = false
				last_shoot = store.tick_ts

				U.y_animation_wait_default(this)
			end
		end

		if is_resting then
			U.animation_start_default(this, "idle1", nil, store.tick_ts)
		else
			U.animation_start_default(this, "idle2", nil, store.tick_ts)

			if store.tick_ts - last_shoot > this.idle_rest_cooldown then
				U.y_animation_play(this, "back_to_idle1", nil, store.tick_ts, 1)

				is_resting = true
			end
		end

		U.y_animation_wait_default(this)

		::label_1083_0::

		coroutine.yield()
	end
end
tt.bullet_attack.max_range = 202
tt.bullet_attack.bullet = "arrow_soldier_elf_stage_08"
tt.bullet_attack.shoot_time = fts(3)
tt.bullet_attack.cooldown_min = 1.2
tt.bullet_attack.cooldown_max = 1.6
tt.bullet_attack.bullet_start_offset = {v(20, 20), v(-20, 20)}
tt.bullet_attack.animation = "shoot"
tt.bullet_attack.vis_bans = bor(F_MINIBOSS)
tt.idle_rest_cooldown = 2

tt = E:register_t_tmp("arrow_soldier_elf_stage_08", "arrow5_45degrees")
tt.bullet.damage_min = 36
tt.bullet.damage_max = 54
tt.bullet.fixed_height = 50
tt.bullet.miss_decal = "elven_warrior_arrow_0002"
tt.bullet.mod = "mod_arrow_soldier_elf_stage_08"
tt.render.sprites[1].name = "elven_warrior_arrow_0001"

tt = E:register_t_tmp("decal_stage_08_elf_rescue_chains", "decal_scripted")
tt.render.sprites[1].prefix = "ChainDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = function(this, store)
	this.render.sprites[1].z = Z_DECALS

	U.y_animation_play(this, "walk", nil, store.tick_ts)

	this.render.sprites[1].z = Z_OBJECTS

	U.y_animation_play(this, "idle", nil, store.tick_ts)

	while true do
		if this.guard_entity.health.dead then
			U.y_wait_unconditional(store, fts(40))
			U.y_animation_play(this, "death", nil, store.tick_ts)
			simulation:queue_remove_entity(this)
		end

		coroutine.yield()
	end
end

tt = E:register_t_tmp("decal_stage_08_elf_rescue_elf_slave", "decal_scripted")
tt.render.sprites[1].prefix = "ElfSlaveDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.action_cooldown_min = fts(20)
tt.action_cooldown_max = fts(20)
tt.main_script.update = function(this, store)
	this.render.sprites[1].z = Z_DECALS

	U.y_animation_play(this, "walk1", nil, store.tick_ts)

	this.render.sprites[1].z = Z_OBJECTS

	U.y_animation_play(this, "to_idle", nil, store.tick_ts)
	U.y_animation_play(this, "idle", nil, store.tick_ts)

	local action_cooldown = math.random(this.action_cooldown_min, this.action_cooldown_max)
	local last_action_ts = store.tick_ts

	while true do
		if action_cooldown <= store.tick_ts - last_action_ts then
			U.y_animation_play(this, "picando", nil, store.tick_ts)

			last_action_ts = store.tick_ts
			action_cooldown = math.random(this.action_cooldown_min, this.action_cooldown_max)
		end

		if this.guard_entity.health.dead then
			U.y_wait_unconditional(store, fts(65))
			S:queue(this.sound_rescue, {
				delay = fts(20)
			})
			U.y_animation_play(this, "escape", nil, store.tick_ts)

			this.render.sprites[1].z = Z_DECALS

			U.y_animation_play(this, "walk2", nil, store.tick_ts)
			simulation:queue_remove_entity(this)
		end

		coroutine.yield()
	end
end
tt.sound_rescue = "Stage08RescuedElves"

tt = E:register_t_tmp("mod_arrow_soldier_elf_stage_08", "mod_stun")
tt.modifier.duration = fts(24)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

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

