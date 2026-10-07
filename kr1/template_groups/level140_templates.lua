local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local SU = require("script_utils")
local scripts = require("scripts")
local v = V.v
local vv = V.vv
local controller_stage_40_boss_shadow_waves_update
local controller_stage_40_boss_shadow_waves_on_stun_stage
controller_stage_40_boss_shadow_waves_update = function(this, store, script)
	local number_attack = 0
	local path_rock_1, path_rock_2, path_rock_3
	local decoy_positions = {}
	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_40_path_rock_1" then
			path_rock_1 = e
		elseif e.template_name == "decal_stage_40_path_rock_2" then
			path_rock_2 = e
		elseif e.template_name == "decal_stage_40_path_rock_final" then
			path_rock_3 = e
		elseif e.template_name == "decal_boss_40_waves_stun_decoy_position" then
			table.insert(decoy_positions, e)
		end
	end
	local a_stun_towers = this.timed_attacks.list[this.attack_towers_index]
	local a_stun_units = this.timed_attacks.list[this.attack_units_index]
	if not a_stun_units.stun_fliers then
		a_stun_units.vis_bans = bor(a_stun_units.vis_bans, F_FLYING)
	end
	local function appear()
		S:queue("Stage40BossDriveby")
		U.sprites_show(this, 1, 1, true)
		U.animation_start(this, "fly", nil, store.tick_ts, false, 1, true)
	end
	local function get_towers(side)
		local allowed_holders = a_stun_towers.holders_ids[side]
		return U.find_towers_in_range(store.towers, this.pos, a_stun_towers, function(t)
			if not t.tower.can_be_mod then
				return false
			end
			if not table.contains(allowed_holders, t.tower.holder_id) then
				return false
			end
			return true
		end)
	end
	local function stun_tower(t, delay, decal_warning, side)
		local decal_stun = E:create_entity(a_stun_towers.decal_stun)
		decal_stun.pos = V.vclone(t.pos)
		decal_stun.target_id = t.id
		decal_stun.holder_id = t.tower.holder_id
		decal_stun.delay_start = delay
		decal_stun.decal_warning = decal_warning
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function stun_unit(u, delay, side)
		local decal_stun = E:create_entity(a_stun_units.decal_stun)
		decal_stun.pos = V.vclone(u.pos)
		decal_stun.target_id = u.id
		decal_stun.delay_start = delay + 0.3 * math.random()
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function stun_decoy(pos, delay, side)
		local decal_stun = E:create_entity("decal_boss_40_waves_stun_decoy")
		decal_stun.pos = V.vclone(pos)
		decal_stun.delay_start = delay + 0.3 * math.random()
		decal_stun.side = side
		simulation:queue_insert_entity(decal_stun)
	end
	local function y_attack_side(side)
		number_attack = number_attack + 1
		local dir
		local extra_dist = -500
		local speed = 700
		if this.stun_with_fps then
			this.render.sprites[1].fps = this.stun_with_fps
			speed = speed * (this.stun_with_fps / 30)
		end
		if side == "LEFT" then
			this.pos.x = REF_W + extra_dist
			dir = 1
			this.render.sprites[1].flip_x = false
			this.imaginary_position = V.v(0, 384)
		else
			this.pos.x = -extra_dist
			dir = -1
			this.render.sprites[1].flip_x = true
			this.imaginary_position = V.v(REF_W, 384)
		end
		local function do_once(name, condition, fn)
			if not this.do_once[name] and condition() then
				this.do_once[name] = true
				fn()
			end
		end
		local function reset_do_once(name)
			if not this.do_once then
				this.do_once = {}
			end
			this.do_once[name] = false
		end
		if number_attack ~= 5 then
			reset_do_once("stun")
			local stuns_amount = 0
			local towers = get_towers(side)
			local units = U.find_soldiers_in_range(store.soldiers, this.pos, a_stun_units.min_range, a_stun_units.max_range, a_stun_units.vis_flags, a_stun_units.vis_bans)
			local decal
			local decal_warning_i = 0
			local bullet_delay = 0
			local pixel_delay_mult = 0.002
			if towers and #towers > 0 then
				for _, t in pairs(towers) do
					decal = E:create_entity(a_stun_towers.decal_warning)
					decal.pos = V.vclone(t.pos)
					decal.delay_start = decal_warning_i * fts(2)
					simulation:queue_insert_entity(decal)
					decal_warning_i = decal_warning_i + 1
					if side == "LEFT" then
						bullet_delay = (t.pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - t.pos.x) * pixel_delay_mult
					end
					stun_tower(t, bullet_delay, decal, side)
					stuns_amount = stuns_amount + 1
				end
			end
			if a_stun_units.enabled and units and #units > 0 then
				for k, u in pairs(units) do
					if side == "LEFT" then
						bullet_delay = (u.pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - u.pos.x) * pixel_delay_mult
					end
					if u.template_name ~= "soldier_warden_stage_40_moving_island" then
						stun_unit(u, bullet_delay, side)
						stuns_amount = stuns_amount + 1
					end
				end
			end
			local total_decoys = 12 - stuns_amount
			if total_decoys > 0 then
				decoy_positions = table.random_order(decoy_positions)
				for i = 1, total_decoys do
					if i > #decoy_positions then
						break
					end
					local decoy_pos = decoy_positions[i].pos
					if side == "LEFT" then
						bullet_delay = (decoy_pos.x - this.imaginary_position.x) * pixel_delay_mult
					else
						bullet_delay = (this.imaginary_position.x - decoy_pos.x) * pixel_delay_mult
					end
					stun_decoy(decoy_pos, bullet_delay, side)
				end
			end
		end
		appear()
		local start_shake_ts = store.tick_ts + 0.3
		local up_rocks
		if number_attack == 2 then
			up_rocks = {{
				ts = store.tick_ts + 0.5,
				rock = path_rock_1
			}, {
				ts = store.tick_ts + 0.8,
				rock = path_rock_2
			}, {
				ts = store.tick_ts + 1.1,
				rock = path_rock_3
			}}
		end
		while not U.animation_finished_default(this) do
			this.imaginary_position.x = this.imaginary_position.x + dir * speed * store.tick_length
			if start_shake_ts and start_shake_ts < store.tick_ts then
				start_shake_ts = nil
				if store.wave_group_number ~= 10 and store.wave_group_number ~= 9 then
					SU.shake_screen(store, 0.3, 4, 4)
				end
			end
			if up_rocks and #up_rocks > 0 and store.tick_ts >= up_rocks[1].ts then
				up_rocks[1].rock.go_up = true
				table.remove(up_rocks, 1)
			end
			coroutine.yield()
		end
		U.sprites_hide(this, nil, nil, true)
		this.render.sprites[1].fps = nil
	end
	while true do
		if this.stun_side then
			y_attack_side(this.stun_side)
			this.stun_side = nil
		end
		coroutine.yield()
	end
end
controller_stage_40_boss_shadow_waves_on_stun_stage = function(this, store, action, side)
	this.stun_side = side
end
local tt
local ACH = require("achievements")
local signal = require("lib.hump.signal")
local P = require("path_db")
local GS = require("kr1.game_settings")
local log = require("lib.klua.log"):new("templates")
local function fts(v)
	return v / FPS
end

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local controller_stage_40_ballista = {}

function controller_stage_40_ballista.update(this, store, script)
	U.sprites_hide(this, nil, nil, true)

	while not this.boss_ref do
		coroutine.yield()
	end

	U.y_wait_unconditional(store, 11.5)

	local moving_island

	for _, v in pairs(store.entities) do
		if v.template_name == "controller_stage_40_moving_island" then
			moving_island = v

			break
		end
	end

	moving_island:talk()
	signal.emit("show-balloon_tutorial", "LV40_BOSSFIGHT_START_TAUNT_02", false)
	U.y_wait_unconditional(store, 3.5)

	moving_island.ballista = this

	U.y_wait_unconditional(store, 0.3)
	U.sprites_show(this, 1, 1, true)
	SU.spawn_fx("fx_stage_40_warden_spawn_magic", V.v(this.pos.x, this.pos.y + 200), store)
	U.y_animation_play(this, "spawn_in", nil, store.tick_ts, 1, 1)
	U.animation_start(this, "in_2", nil, store.tick_ts - 90, false, 1, true)

	this.next_attack_ts = store.tick_ts

	local function can_shoot()
		return store.tick_ts >= this.next_attack_ts
	end

	local first_time = true

	local function y_wait_for_shot()
		local function y_animation_play_destroyed(name, sprite_id)
			U.animation_start(this, name, nil, store.tick_ts, false, sprite_id, true)

			while not U.animation_finished(this, sprite_id, 1) do
				if this.get_destroyed then
					return false
				end

				coroutine.yield()
			end

			return true
		end

		if this.render.sprites[1].name ~= "in_2" then
			if not y_animation_play_destroyed("in_2", 1) then
				return false
			end

			U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
		end

		if first_time then
			first_time = false

			if not y_animation_play_destroyed("in", 1) then
				return false
			end

			U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
		end

		U.sprites_show(this, 2, 2, true)

		if not y_animation_play_destroyed("in", 2) then
			U.sprites_hide(this, 2, 2, true)

			return false
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 2, true)

		this.ui.clicked = nil
		this.ui.can_click = true

		local next_hand_ts = store.tick_ts

		while not this.ui.clicked do
			if next_hand_ts < store.tick_ts then
				next_hand_ts = store.tick_ts + 2

				local hand = E:create_entity(this.hand_decal_t)

				hand.pos = V.v(this.pos.x, this.pos.y)
				hand.render.sprites[1].ts = store.tick_ts
				hand.tween.ts = store.tick_ts

				simulation:queue_insert_entity(hand)
			elseif this.get_destroyed then
				U.sprites_hide(this, 2, 2, true)

				return false
			end

			coroutine.yield()
		end

		this.ui.clicked = nil
		this.ui.can_click = false

		if not y_animation_play_destroyed("out", 2) then
			U.sprites_hide(this, 2, 2, true)

			return false
		end

		U.sprites_hide(this, 2, 2, true)

		return true
	end

	local function shoot()
		if this.shoot_nmbr == 0 then
			signal.emit("pan-zoom-camera", 1, {
				x = 512,
				y = 384
			}, 1)
		end

		this.shoot_nmbr = math.min(this.shoot_nmbr + 1, #this.damage)

		if this.shoot_nmbr == 1 then
			U.y_wait_unconditional(store, 0.5)
		end

		U.animation_start(this, "shot", nil, store.tick_ts, false, 1, true)
		U.y_wait_unconditional(store, fts(16))

		local damage_config = math.ceil(this.damage[this.shoot_nmbr] * math.max(GS.difficulty_enemy_hp_max_factor[store.level_difficulty] / 1.1, 1))
		this.boss_ref:get_hit_by_ballista_fn(store, damage_config)
		U.y_animation_wait_default(this)
		U.animation_start(this, "loop_2", nil, store.tick_ts, true, 1, true)

		this.next_attack_ts = store.tick_ts + this.cooldown - fts(137) - fts(192)
	end

	local function get_destroyed()
		if not this.get_destroyed then
			return false
		end

		U.sprites_hide(this, nil, nil, true)

		return true
	end

	while true do
		if get_destroyed() then
			return
		end

		if can_shoot() and y_wait_for_shot() then
			shoot()
		end

		coroutine.yield()
	end
end

function controller_stage_40_ballista.ready_ballista_fn(this, store)
	this.next_attack_ts = store.tick_ts
end

local controller_stage_40_moving_island = {}

function controller_stage_40_moving_island.insert(this, store)
	if not store.restarted and not main.params.skip_cutscenes and not main.params.skip_to_boss then
		this.intro_fx_egg = SU.spawn_fx("decal_stage_40_moving_island_intro_egg_fx", this.pos, store)
		this.intro_fx_particles = SU.spawn_fx("decal_stage_40_moving_island_intro_egg_particles", this.pos, store)

		U.sprites_hide(this, this.sid_top_warden, this.sid_top_warden, true)
	end

	return true
end

function controller_stage_40_moving_island.update(this, store)
	local path_rock_1, path_rock_2, path_rock_3
	local aa = this.attacks.list[1]

	aa.ts = store.tick_ts
	this.can_attack = false

	local spell_effects = {}

	for _, e in pairs(store.entities) do
		if e.template_name == "decal_stage_40_path_rock_1" then
			path_rock_1 = e
		elseif e.template_name == "decal_stage_40_path_rock_2" then
			path_rock_2 = e
		elseif e.template_name == "decal_stage_40_path_rock_final" then
			path_rock_3 = e
		end
	end

	path_rock_1.tween.ts = 1000 * math.random()
	path_rock_2.tween.ts = 1000 * math.random()

	local function talk()
		local num_times = (store.wave_group_number == 10 or store.wave_group_number == 9) and 9 or 7

		if this.do_talk then
			this.do_talk = false

			U.animation_start(this, "talk_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
		elseif this.do_talk == false and this.render.sprites[this.sid_top_warden].name == "talk_loop" and U.animation_finished(this, this.sid_top_warden, num_times) then
			this.do_talk = nil

			U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
		end
	end

	local function shot_animation(attack, shooter_idx, pos)
		local soffset = this.render.sprites[shooter_idx].offset
		local an = U.animation_name_facing_point(this, attack.animation, pos, shooter_idx, soffset)

		U.animation_start(this, an, true, store.tick_ts, false, shooter_idx)
	end

	local function shot_bullet(attack, shooter_idx, enemy)
		local soffset = this.render.sprites[shooter_idx].offset
		local boffset = attack.bullet_start_offset
		local b = E:create_entity(attack.bullet)

		b.pos.x = this.pos.x + soffset.x + boffset.x
		b.pos.y = this.pos.y + soffset.y + boffset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
		b.bullet.target_id = enemy.id
		b.bullet.source_id = this.id
		b.bullet.level = 1
		b.bullet.damage_factor = 1

		simulation:queue_insert_entity(b)
	end

	local function range_attack()
		if this.can_attack and store.tick_ts - aa.ts > aa.cooldown then
			local trigger_enemy, _ = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.max_range, false, aa.vis_flags, aa.vis_bans)

			if not trigger_enemy then
				SU.delay_attack(store, aa, fts(10))
			else
				shot_animation(aa, this.sid_top_warden, trigger_enemy.pos)

				local wait_until_ts = store.tick_ts + aa.shoot_time

				while wait_until_ts > store.tick_ts do
					if this.lose_stage then
						goto label_2566_0
					end

					coroutine.yield()
				end

				local _, enemies = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.max_range, false, aa.vis_flags, aa.vis_bans)

				if enemies and #enemies > 0 then
					local i = 0

					for _, enemy in ipairs(enemies) do
						shot_bullet(aa, this.sid_top_warden, enemy)

						i = i + 1

						if i >= aa.max_count then
							break
						end
					end
				else
					shot_bullet(aa, this.sid_top_warden, trigger_enemy)
				end

				aa.ts = store.tick_ts

				while not U.animation_finished(this, this.sid_top_warden) do
					if this.lose_stage then
						goto label_2566_0
					end

					coroutine.yield()
				end

				U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden)
			end
		end

		::label_2566_0::
	end

	local function update_warden_positions()
		for i = 1, #this.warden_ids do
			local warden = store.entities[this.warden_ids[i]]

			if warden then
				warden.pos.x = this.pos.x + this.warden_offsets[i].x + this.render.sprites[this.sid_island_warden_1 + i - 1].offset.x
				warden.pos.y = this.pos.y + this.warden_offsets[i].y + this.render.sprites[this.sid_island_warden_1 + i - 1].offset.y
			end
		end

		for k, v in pairs(spell_effects) do
			if type(k) == "string" then
				v[1].pos.x = v[2].pos.x + this.decal_spell_effect_offsets[k].x + v[2].render.sprites[1].offset.x
				v[1].pos.y = v[2].pos.y + this.decal_spell_effect_offsets[k].y + v[2].render.sprites[1].offset.y
			else
				v.pos.x = this.pos.x + this.decal_spell_effect_offsets[k].x + this.render.sprites[k].offset.x
				v.pos.y = this.pos.y + this.decal_spell_effect_offsets[k].y + this.render.sprites[k].offset.y
			end
		end
	end

	local remove_rock_times = 0

	local function start_remove_rock(rock, string_id)
		S:queue("Stage40MageStatueStart")

		local rock_object, sid_rock

		if type(rock) == "table" then
			rock_object = rock
		else
			rock_object = this
			sid_rock = rock
		end

		remove_rock_times = remove_rock_times + 1

		local wait_until_runs = this.render.sprites[this.sid_top_warden].runs + 1

		while not U.animation_finished(this, this.sid_top_warden, wait_until_runs) do
			update_warden_positions()
			coroutine.yield()
		end

		local flip = remove_rock_times <= 2

		U.animation_start(this, "select_in", flip, store.tick_ts, false, this.sid_top_warden, true)

		if not sid_rock then
			rock_object.selected = true
		else
			U.animation_start(rock_object, "select_in", nil, store.tick_ts, false, sid_rock, true)
		end

		while not U.animation_finished(this, this.sid_top_warden, 1) do
			update_warden_positions()
			coroutine.yield()
		end

		U.animation_start(this, "select_loop", nil, store.tick_ts, true, this.sid_top_warden, true)

		if not sid_rock then
			rock_object.selected_loop = true
		else
			U.animation_start(rock_object, "select_loop", nil, store.tick_ts, true, sid_rock, true)
		end

		update_warden_positions()
	end

	local function y_remove_rock(rock_param, sid_effect)
		S:queue("Stage40MageStatueDown")

		local rock_object, sid_rock

		if type(rock_param) == "table" then
			rock_object = rock_param
		else
			rock_object = this
			sid_rock = rock_param
		end

		local wait_until_runs = this.render.sprites[this.sid_top_warden].runs + 1

		while not U.animation_finished(this, this.sid_top_warden, wait_until_runs) do
			update_warden_positions()
			coroutine.yield()
		end

		U.animation_start(this, "glow_in", nil, store.tick_ts, false, this.sid_top_warden, true)

		if not sid_rock then
			rock_object.glow_in = true
		else
			U.animation_start(rock_object, "glow_in", nil, store.tick_ts, false, sid_rock, true)
		end

		while not U.animation_finished(this, this.sid_top_warden) do
			update_warden_positions()
			coroutine.yield()
		end

		local first = true
		local wait_until_ts = store.tick_ts + 3

		while wait_until_ts > store.tick_ts do
			if first then
				SU.shake_screen(store, 0.4, 5.5, 3)
				U.animation_start(this, "move_down_loop", nil, store.tick_ts, true, this.sid_top_warden, true)

				if not sid_rock then
					rock_object.move_down_loop = true
				else
					U.animation_start(rock_object, "move_down_loop", nil, store.tick_ts, true, sid_rock, true)
				end

				first = false
			end

			update_warden_positions()
			coroutine.yield()
		end

		local wait_until

		if type(rock_param) == "table" then
			wait_until = rock_object:tweens_go_down_fn(store)
		else
			rock_object.tween.props[sid_rock].ts = store.tick_ts
			rock_object.tween.props[sid_rock].disabled = false
			wait_until = store.tick_ts + rock_object.tween.props[sid_rock].keys[2][1]
		end

		local spell_out_ts = wait_until - 3
		local next_spark_ts = store.tick_ts

		while wait_until > store.tick_ts do
			update_warden_positions()

			if spell_out_ts and spell_out_ts < store.tick_ts and this.render.sprites[this.sid_top_warden].name == "move_down_loop" then
				U.animation_start(this, "glow_out", nil, store.tick_ts, false, this.sid_top_warden, true)
			end

			if next_spark_ts and next_spark_ts < store.tick_ts then
				next_spark_ts = store.tick_ts + fts(10)

				local override_sorting_offset
				local fx_pos = V.v(0, 0)
				local fx_offset = V.v(0, 0)

				if type(rock_param) == "table" then
				-- block empty
				else
					fx_pos.x = rock_object.pos.x
					fx_pos.y = rock_object.pos.y
					fx_offset.x = rock_object.render.sprites[sid_rock].offset.x
					fx_offset.y = rock_object.render.sprites[sid_rock].offset.y
				end

				if remove_rock_times == 1 then
					override_sorting_offset = -20
				elseif remove_rock_times == 2 then
					override_sorting_offset = 0
				elseif remove_rock_times == 3 then
					override_sorting_offset = 10
				end

				local fx = SU.spawn_fx("decal_stage_40_moving_island_rock_sparks", fx_pos, store)

				fx.render.sprites[1].offset = fx_offset

				if override_sorting_offset then
					fx.render.sprites[1].sort_y_offset = override_sorting_offset
				end
			end

			coroutine.yield()
		end

		if this.render.sprites[this.sid_top_warden].name == "glow_out" then
			while not U.animation_finished(this, this.sid_top_warden, 1) do
				update_warden_positions()
				coroutine.yield()
			end

			U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
		end

		if type(rock_param) == "table" then
		-- block empty
		else
			this.render.sprites[sid_rock].hidden = true
			this.tween.props[sid_rock].disabled = true
		end
	end

	local start_node = P:nearest_nodes(this.pos.x, this.pos.y, {11}, {1}, false)[1]
	local pi, spi, ni = unpack(start_node)

	this.nav_path.pi = pi
	this.nav_path.spi = spi
	this.nav_path.ni = ni
	this.pos = P:node_pos(pi, spi, ni)

	S:queue("Stage40MageIntroFullSeq")

	if not store.restarted and not main.params.skip_cutscenes and not main.params.skip_to_boss then
		U.y_wait_unconditional(store, 2)
		SU.spawn_fx("decal_stage_40_moving_island_intro_warden", this.pos, store)
		U.y_wait_unconditional(store, 3.3)

		this.intro_fx_egg.tween.ts = store.tick_ts
		this.intro_fx_egg.tween.disabled = false
		this.intro_fx_egg = nil
		this.intro_fx_particles.tween.ts = store.tick_ts
		this.intro_fx_particles.tween.disabled = false
		this.intro_fx_particles = nil

		U.y_wait_unconditional(store, 0.2)
	end

	U.sprites_show(this, this.sid_top_warden, this.sid_top_warden, true)

	while store.wave_group_number < 1 do
		talk()

		if this.do_talk == nil and this.remove_stone_1 then
			this.remove_stone_1 = nil

			start_remove_rock(this.sid_bottom_rock)
		end

		coroutine.yield()
	end

	while store.wave_group_number < 2 do
		coroutine.yield()
	end

	y_remove_rock(this.sid_bottom_rock, this.sid_bottom_rock)
	start_remove_rock(this.sid_right_rock)

	while store.wave_group_number < 3 do
		coroutine.yield()
	end

	y_remove_rock(this.sid_right_rock, this.sid_right_rock)
	start_remove_rock(this.sid_left_rock)

	while this.current_step == 0 do
		coroutine.yield()
	end

	signal.emit("show-curtains")
	signal.emit("hide-gui")
	signal.emit("start-cinematic")

	local cam_pos, cam_zoom = SU.get_camera_values()

	signal.emit("pan-zoom-camera", 1.5, {
		x = 800,
		y = 384
	}, 1.3)

	local wait_until_ts = store.tick_ts + 1.5

	while wait_until_ts > store.tick_ts do
		talk()
		update_warden_positions()
		coroutine.yield()
	end

	y_remove_rock(this.sid_left_rock, this.sid_left_rock)
	U.animation_start(this, "idle_no_runas_in", nil, store.tick_ts, false, this.sid_egg, true)
	this:talk()
	talk()
	signal.emit("show-balloon_tutorial", "LV40_MOVING_ISLAND_START_TAUNT_01", false)
	U.y_wait_unconditional(store, 3)
	U.animation_start_specific(this, "call_allies", true, store.tick_ts, false, this.sid_top_warden)

	for i = this.sid_right_rock + 1, this.sid_right_rock + 3 do
		this.tween.props[i].ts = store.tick_ts
		this.tween.props[i].disabled = false
	end

	coroutine.yield()

	this.render.sprites[this.sid_island_warden_1].hidden = false
	this.render.sprites[this.sid_island_warden_2].hidden = false
	this.render.sprites[this.sid_island_warden_3].hidden = false

	local wardens_spawn_ts = {store.tick_ts + 1.2, store.tick_ts + 1.5, store.tick_ts + 1.7}
	local wait_until_ts = store.tick_ts + 2

	while wait_until_ts > store.tick_ts do
		if #wardens_spawn_ts > 0 and store.tick_ts > wardens_spawn_ts[1] then
			table.remove(wardens_spawn_ts, 1)

			local warden = E:create_entity("soldier_warden_stage_40_moving_island")

			simulation:queue_insert_entity(warden)
			table.insert(this.warden_ids, warden.id)

			if #this.warden_ids == 2 then
				warden.render.sprites[1].z = Z_OBJECTS
			end
		end

		update_warden_positions()
		coroutine.yield()
	end

	for i = this.sid_right_rock + 1, this.sid_right_rock + 3 do
		this.tween.props[i].disabled = true
	end

	while not U.animation_finished(this, this.sid_top_warden, 1) do
		update_warden_positions()
		coroutine.yield()
	end

	U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
	U.y_wait_unconditional(store, 0.1)

	this.render.sprites[this.sid_top_warden].flip_x = false

	U.y_wait_unconditional(store, 0.2)
	S:queue("Stage40EggMovementStart")
	SU.shake_screen(store, 0.4, 1, 2)

	this.tween.props[this.sid_main_island].ts = store.tick_ts
	this.tween.props[this.sid_main_island].disabled = false
	this.tween.props[this.sid_top_warden].ts = store.tick_ts
	this.tween.props[this.sid_top_warden].disabled = false
	this.tween.props[this.sid_egg].ts = store.tick_ts
	this.tween.props[this.sid_egg].disabled = false
	this.tween.props[this.sid_island_warden_1].ts = store.tick_ts * math.random()
	this.tween.props[this.sid_island_warden_1].disabled = false
	this.tween.props[this.sid_island_warden_2].ts = store.tick_ts * math.random()
	this.tween.props[this.sid_island_warden_2].disabled = false
	this.tween.props[this.sid_island_warden_3].ts = store.tick_ts * math.random()
	this.tween.props[this.sid_island_warden_3].disabled = false

	local end_cinematic_ts = store.tick_ts + 3
	local return_camera_ts = store.tick_ts + 2
	local removed_rock_1 = false
	local removed_rock_2 = false
	local step_position_x
	local old_runa = 0
	local moving = false

	while true do
		talk()
		range_attack()

		if this.lose_stage then
			U.y_wait_unconditional(store, 1.5)
			U.y_animation_play(this, "death", nil, store.tick_ts, 1, this.sid_top_warden)
			U.y_wait_unconditional(store, 4)

			game.store.lives = 0

			return
		end

		if this.current_step == 2 and not removed_rock_1 then
			y_remove_rock(path_rock_1, "BLOCK_1")

			removed_rock_1 = true

			goto label_2562_0
		elseif this.current_step == 3 and not removed_rock_2 then
			y_remove_rock(path_rock_2, "BLOCK_2")

			removed_rock_2 = true

			goto label_2562_0
		end

		if this.remove_last_stone and store.tick_ts > this.remove_last_stone then
			this.remove_last_stone = nil

			y_remove_rock(path_rock_3, "BLOCK_3")

			U.update_max_speed(this, 21)
			this.current_step = this.current_step + 1
			this.reached_destination = false
		end

		step_position_x = this.stop_steps[this.current_step]

		if not step_position_x then
			break
		end

		if step_position_x < this.pos.x then
			local next = P:next_entity_node(this, store.tick_length)

			if not next then
				break
			end

			if not moving then
				moving = true

				U.animation_start(this, "glow_in", nil, store.tick_ts, false, this.sid_main_island, true)
				U.animation_start(this, "egg_move_in", nil, store.tick_ts, false, this.sid_top_warden, true)
			end

			if this.render.sprites[this.sid_main_island].name == "glow_in" and U.animation_finished(this, this.sid_main_island, 1) then
				U.animation_start(this, "glow_loop", nil, store.tick_ts, true, this.sid_main_island, true)
			end

			if this.render.sprites[this.sid_top_warden].name == "egg_move_in" and U.animation_finished(this, this.sid_top_warden, 1) then
				U.animation_start(this, "egg_move_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
			end

			U.set_destination(this, next)
			U.walk_off__accel__unsnapped(this, store.tick_length)
		elseif not this.reached_destination then
			this.reached_destination = true
			moving = false

			U.animation_start(this, "glow_out", nil, store.tick_ts, false, this.sid_main_island, true)
			U.animation_start(this, "angry", nil, store.tick_ts, false, this.sid_top_warden, true)

			if this.current_step < #this.stop_steps then
				local rock_to_remove = path_rock_1
				local string_id = "BLOCK_1"

				if removed_rock_1 then
					rock_to_remove = path_rock_2
					string_id = "BLOCK_2"
				end

				if removed_rock_2 then
					rock_to_remove = path_rock_3
					string_id = "BLOCK_3"
				end

				start_remove_rock(rock_to_remove, string_id)
			end
		end

		if return_camera_ts and return_camera_ts < store.tick_ts then
			return_camera_ts = nil

			signal.emit("pan-zoom-camera", 1.5, cam_pos, cam_zoom)
		-- signal.emit("pan-zoom-camera", 1.5, 512, 384)
		end

		if end_cinematic_ts and end_cinematic_ts < store.tick_ts then
			end_cinematic_ts = nil

			signal.emit("hide-curtains")
			signal.emit("show-gui")
			signal.emit("end-cinematic", true)
		end

		if this.next_runa_wave and store.wave_group_number >= this.next_runa_wave then
			this.next_runa_wave = store.wave_group_number + 1
			this.runa = this.runa + 1
		end

		if this.next_runa_wave and store.wave_group_number >= this.next_runa_wave then
			this.next_runa_wave = nil
			this.next_runa_ts = store.tick_ts + 20
			this.runa = this.runa + 1
		end

		if this.runa ~= old_runa and old_runa < 10 then
			if old_runa > 0 then
				if old_runa == 9 then
					U.y_animation_play(this, "runa_all_out", nil, store.tick_ts, 1, this.sid_egg)
				else
					U.y_animation_play(this, "runa_" .. old_runa .. "_in", nil, store.tick_ts, 1, this.sid_egg)
				end
			else
				U.animation_start(this, "egg_move_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
			end

			old_runa = this.runa

			if old_runa < 10 then
				U.y_animation_play(this, "runa_" .. this.runa .. "_load_in", nil, store.tick_ts, 1, this.sid_egg)
				U.animation_start(this, "runa_" .. this.runa .. "_load_loop", nil, store.tick_ts, true, this.sid_egg, true)
			end
		end

		if this.remove_runas then
			this.remove_runas = nil
			old_runa = nil
			this.runa = nil
			this.next_runa_wave = nil
			this.next_runa_ts = nil

			S:queue("Stage40MageRuneDisappearOp2")
			U.y_animation_play(this, "runa_all_out", nil, store.tick_ts, 1, this.sid_egg)
			U.animation_start(this, "idle_no_runas", nil, store.tick_ts, true, this.sid_egg, true)
		end

		if this.ballista then
			U.y_animation_play(this, "call_allies", nil, store.tick_ts, 1, this.sid_top_warden)
			U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden, true)
			U.y_wait_unconditional(store, 2)
			U.animation_start(this, "point_out", nil, store.tick_ts, true, this.sid_top_warden, true)

			while this.ballista.shoot_nmbr <= 0 do
				coroutine.yield()
			end

			U.y_animation_wait(this, this.sid_top_warden, this.render.sprites[this.sid_top_warden].runs + 1)
			U.animation_start(this, "idle_loop", nil, store.tick_ts, true, this.sid_top_warden, true)

			this.ballista = nil
		end

		::label_2562_0::

		update_warden_positions()
		coroutine.yield()
	end
end

function controller_stage_40_moving_island.move_island(this, store, event_name)
	this.current_step = this.current_step + 1
	this.reached_destination = false
end

function controller_stage_40_moving_island.island_soldiers(this, store, event_name)
	store.level.island_soldiers_cinematic = true
	this.remove_last_stone = store.tick_ts + 1

	local wardens_amount = 0

	for i = 1, #this.warden_ids do
		local warden = store.entities[this.warden_ids[i]]

		if warden and not warden.health.dead then
			wardens_amount = wardens_amount + 1
		end
	end

	if wardens_amount >= 3 then
		ACH:got("DLC3_WARDENS_40_REACH_END")
	end
end

function controller_stage_40_moving_island.on_open_path(this)
	this.tween.disabled = true

	local diff = -this.render.sprites[1].offset.y

	this.render.sprites[1].offset.y = 0
	this.render.sprites[2].offset.y = 0
	this.render.sprites[this.sid_top_warden].offset.y = this.render.sprites[this.sid_top_warden].offset.y + diff
end

function controller_stage_40_moving_island.spawn_soldiers_fn(this, store)
	local rally_pos = V.v(280, 360)
	local rally_radius = 25
	local wardens_amount = 0

	for i = 1, #this.warden_ids do
		local warden = store.entities[this.warden_ids[i]]

		if warden and not warden.health.dead then
			wardens_amount = wardens_amount + 1
		end
	end

	local function rally_formation_position(idx, angle_offset)
		local pos

		angle_offset = angle_offset or 0

		if wardens_amount == 1 then
			pos = V.vclone(rally_pos)
		else
			local a = 2 * math.pi / wardens_amount

			pos = U.point_on_ellipse(rally_pos, rally_radius, (idx - 1) * a - math.pi / 2 + angle_offset)
		end

		local center = V.vclone(rally_pos)

		return pos, center
	end

	for i = 1, #this.warden_ids do
		local warden = store.entities[this.warden_ids[i]]

		if warden then
			local soldier = E:create_entity("soldier_warden_stage_40_island_stopped")
			local pos = V.v(warden.pos.x + warden.render.sprites[1].offset.y, warden.pos.y + warden.render.sprites[1].offset.y)

			soldier.pos = V.vclone(pos)

			log.todo(warden.pos.x .. "    " .. warden.pos.y)

			soldier.nav_rally.pos, soldier.nav_rally.center = rally_formation_position(i, math.pi * 0.25)
			soldier.reinforcement.squad_id = this.id

			simulation:queue_insert_entity(soldier)
			simulation:queue_remove_entity(warden)
		end
	end

	this.warden_ids = {}
end

function controller_stage_40_moving_island.tp_to_next_step_fn(this, store)
	this.current_step = this.current_step + 1

	if this.current_step > #this.stop_steps then
		this.current_step = #this.stop_steps
	end

	this.reached_destination = false

	while not this.reached_destination do
		local step_position_x = this.stop_steps[this.current_step]

		if step_position_x < this.pos.x then
			local next = P:next_entity_node(this, store.tick_length)

			if not next then
				return
			end

			U.set_destination(this, next)
			U.walk_off__accel__unsnapped(this, store.tick_length)
		elseif not this.reached_destination then
			this.reached_destination = true
		end
	end
end

function controller_stage_40_moving_island.talk_fn(this)
	this.do_talk = true
end

local decal_stage_40_boss_fires_steps = {}

function decal_stage_40_boss_fires_steps.update(this, store)
	while true do
		if this.do_fire then
			this.do_fire = nil

			for i, s in pairs(this.render.sprites) do
				if s.hidden then
					U.sprites_show(this, i, i, true)
					U.y_animation_play(this, "in", nil, store.tick_ts, 1, i)
					U.animation_start(this, "idle", nil, store.tick_ts, true, i)

					break
				end
			end
		end

		coroutine.yield()
	end
end

function decal_stage_40_boss_fires_steps.start_next_fire(this, store)
	this.do_fire = true
end

local decal_stage_40_path_rock = {}

function decal_stage_40_path_rock.update(this, store)
	this.tween.ts = 1000 * math.random()

	local small_rocks = {}

	if this.small_rocks then
		for _, s in pairs(this.small_rocks) do
			local e = E:create_entity("decal_stage_40_path_rock_small")

			e.pos = V.v(this.pos.x + s.pos.x, this.pos.y + s.pos.y)
			e.render.sprites[1].scale = s.scale
			e.render.sprites[1].flip_x = s.flip

			simulation:queue_insert_entity(e)
			table.insert(small_rocks, e)
		end
	end

	local function go_up()
		if not this.go_up then
			return
		end

		this.go_up = nil

		for _, s in pairs(small_rocks) do
			s.go_up = true
		end

		if this.random_delay_up then
			local random_delay = this.random_delay_up[1] + (this.random_delay_up[2] - this.random_delay_up[1]) * math.random()

			U.y_wait_unconditional(store, random_delay)
		end

		U.sprites_show(this)
		U.animation_start_group(this, "up", nil, store.tick_ts, false, "layers")

		local orig_z

		if this.render.sprites[2] then
			orig_z = this.render.sprites[2].z
			this.render.sprites[2].z = this.render.sprites[1].z
		end

		local change_z_ts = store.tick_ts + 1
		local fx_ts = store.tick_ts + 1.15

		while not U.animation_finished_group(this, "layers") do
			if orig_z and change_z_ts <= store.tick_ts then
				this.render.sprites[2].z = orig_z
				orig_z = nil
			end

			if not this.skip_big_dust and fx_ts and fx_ts <= store.tick_ts then
				fx_ts = nil

				local fx = SU.spawn_fx("fx_stage_40_moving_island_explosion_dirt", this.pos, store)

				fx.render.sprites[1].z = Z_OBJECTS + 1
				fx.render.sprites[1].scale = V.vv(2.5)

				if #this.render.sprites > 1 then
					fx.render.sprites[1].scale = V.vv(3.5)
					fx.pos.y = fx.pos.y - 20
				end
			end

			coroutine.yield()
		end

		U.animation_start_group(this, "idle", nil, store.tick_ts, true, "layers")
	end

	local function selected()
		if not this.selected then
			return
		end

		this.selected = nil

		for _, s in pairs(small_rocks) do
			s.selected = true
		end

		U.animation_start_group(this, "select_in", nil, store.tick_ts, false, "layers")
	end

	local function selected_loop()
		if not this.selected_loop then
			return
		end

		this.selected_loop = nil

		for _, s in pairs(small_rocks) do
			s.selected_loop = true
		end

		U.animation_start_group(this, "select_loop", nil, store.tick_ts, true, "layers")
	end

	local function glow_in()
		if not this.glow_in then
			return
		end

		this.glow_in = nil

		for _, s in pairs(small_rocks) do
			s.glow_in = true
		end

		U.animation_start_group(this, "glow_in", nil, store.tick_ts, false, "layers")
	end

	local function move_down_loop()
		if not this.move_down_loop then
			return
		end

		this.move_down_loop = nil

		for _, s in pairs(small_rocks) do
			s.move_down_loop = true
		end

		U.animation_start_group(this, "move_down_loop", nil, store.tick_ts, true, "layers")
	end

	local function tweens_go_down()
		if not this.tweens_go_down then
			return
		end

		this.tweens_go_down = nil

		for _, s in pairs(small_rocks) do
			s:tweens_go_down_fn(store)
		end

		local next_spark_ts = not this.skip_sparks and store.tick_ts or nil

		while store.tick_ts < this.tweens_go_down_wait_until do
			if this.tweens_go_down_change_z_ts and store.tick_ts > this.tweens_go_down_change_z_ts then
				this.tweens_go_down_change_z_ts = nil
				this.render.sprites[2].z = this.render.sprites[1].z
			end

			if next_spark_ts and next_spark_ts < store.tick_ts then
				next_spark_ts = store.tick_ts + fts(10)

				local override_sorting_offset = -4000
				local fx_pos = V.vclone(this.pos)
				local fx_offset = V.vclone(this.render.sprites[1].offset)
				local fx = SU.spawn_fx("decal_stage_40_moving_island_rock_sparks", fx_pos, store)

				fx.render.sprites[1].offset = fx_offset
				fx.render.sprites[1].sort_y_offset = override_sorting_offset
			end

			coroutine.yield()
		end
	end

	while true do
		go_up()
		selected()
		selected_loop()
		glow_in()
		move_down_loop()
		tweens_go_down()
		coroutine.yield()
	end
end

function decal_stage_40_path_rock.tweens_go_down(this, store)
	this.tweens_go_down = true
	this.tweens_go_down_change_z_ts = nil
	this.tweens_go_down_wait_until = nil

	for i = 1, #this.tween.props do
		if this.random_delay_down then
			local random_delay = this.random_delay_down[1] + (this.random_delay_down[2] - this.random_delay_down[1]) * math.random()

			this.tween.props[i].keys = {{0, this.render.sprites[1].offset}, {random_delay, this.render.sprites[1].offset}, {4 + random_delay, v(this.render.sprites[1].offset.x, this.render.sprites[1].offset.y - 200)}}
		else
			this.tween.props[i].keys = {{0, this.render.sprites[1].offset}, {4, v(this.render.sprites[1].offset.x, this.render.sprites[1].offset.y - 200)}}
		end

		this.tween.props[i].loop = false
	end

	this.tween.ts = store.tick_ts
	this.tween.remove = true

	if this.random_delay then
		this.tweens_go_down_wait_until = store.tick_ts + this.tween.props[1].keys[3][1]
	else
		this.tweens_go_down_wait_until = store.tick_ts + this.tween.props[1].keys[2][1]
	end

	if #this.tween.props > 1 then
		this.tweens_go_down_change_z_ts = store.tick_ts + 0.6
	end

	return this.tweens_go_down_wait_until
end

tt = E:register_t_hot("decal_stage_40_top_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_mask_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("decal_stage_40_storm_decos", "decal", true)
tt.render.sprites[1].prefix = "stage_40_storm_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].scale = vv(4)
tt.render.sprites[1].pos = v(512, 384)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_y = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "stage_40_storm_02Def"
tt.render.sprites[3].z = Z_OBJECTS_COVERS
tt.render.sprites[3].scale = vv(1)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].prefix = "stage_40_storm_04Def"
tt.render.sprites[4].z = Z_BACKGROUND_COVERS
tt.render.sprites[4].sort_y_offset = -1
tt.render.sprites[5] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[5].pos = v(300, 330)
tt.render.sprites[5].prefix = "stage_40_storm_04Def"
tt.render.sprites[5].z = Z_BACKGROUND_COVERS + 2
tt.render.sprites[5].sort_y_offset = 55
tt.render.sprites[5].hidden = true
tt.render.sprites[6] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[6].prefix = "stage_40_storm_05Def"
tt.render.sprites[6].z = Z_BACKGROUND_COVERS - 1
tt.render.sprites[7] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[7].pos = v(800, 340)
tt.render.sprites[7].prefix = "stage_40_storm_04Def"
tt.render.sprites[7].z = Z_BACKGROUND_COVERS
tt.render.sprites[7].sort_y_offset = -1
tt.render.sprites[8] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[8].pos = v(800, 370)
tt.render.sprites[8].prefix = "stage_40_storm_04Def"
tt.render.sprites[8].z = Z_BACKGROUND_COVERS - 1

tt = E:register_t_hot("decal_stage_40_holders_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_holder_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_40_holder_mask_2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BACKGROUND_COVERS + 10

tt = E:register_t_hot("decal_stage_40_bottom_mask", "decal", true)
tt.render.sprites[1].name = "stage_40_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 2

tt = E:register_t_hot("controller_stage_40_boss_shadow_waves", "decal_scripted", true)
E:add_comps(tt, "editor", "timed_attacks", "events")
tt.main_script.update = controller_stage_40_boss_shadow_waves_update
tt.render.sprites[1].prefix = "stage_40_bossDef"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].exo = true
tt.attack_towers_index = 1
tt.timed_attacks.list[tt.attack_towers_index] = E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_towers_index].decal_stun = "decal_boss_40_waves_stun_towers"
tt.timed_attacks.list[tt.attack_towers_index].decal_warning = "decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_towers_index].max_range = 99999999
tt.timed_attacks.list[tt.attack_towers_index].min_range = 0
tt.timed_attacks.list[tt.attack_towers_index].holders_ids = {
	RIGHT = {"1", "4", "5", "10", "12", "6", "7", "8", "9"},
	LEFT = {"1", "4", "5", "10", "12", "6", "7", "8", "9"}
}
tt.attack_units_index = 2
tt.timed_attacks.list[tt.attack_units_index] = E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_units_index].vis_flags = bor(F_MOD, F_STUN)
tt.timed_attacks.list[tt.attack_units_index].decal_stun = "decal_boss_40_waves_stun_units"
tt.timed_attacks.list[tt.attack_units_index].decal_warning = "decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_units_index].max_range = 99999999
tt.timed_attacks.list[tt.attack_units_index].min_range = 0
tt.timed_attacks.list[tt.attack_units_index].enabled = true
tt.timed_attacks.list[tt.attack_units_index].stun_fliers = true
tt.timed_attacks.list[tt.attack_units_index].mod_stun_wardens = "mod_boss_stage_40_stun_wardens"
tt.events.list[1].name = "stun_stage"
tt.events.list[1].on_event = controller_stage_40_boss_shadow_waves_on_stun_stage

tt = E:register_t_hot("decal_stage_40_boss_fires_steps", "decal_scripted", true)
tt.main_script.update = decal_stage_40_boss_fires_steps.update
tt.start_next_fire = decal_stage_40_boss_fires_steps.start_next_fire
tt.render.sprites[1].prefix = "stage_40_fire_paso_1Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_40_fire_paso_2Def"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "stage_40_fire_paso_3Def"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].prefix = "stage_40_fire_paso_4Def"
tt.render.sprites[5] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[5].prefix = "stage_40_fire_paso_5Def"

tt = E:register_t_hot("decal_stage_40_open_middle_mask", "decal", true)
tt.render.sprites[1].prefix = "mecanica_rocas_stage_40Def"
tt.render.sprites[1].name = "rocas_in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1

tt = E:register_t_hot("decal_stage_40_path_rock_1", "decal_tween", true)
E:add_comps(tt, "main_script")
tt.main_script.update = decal_stage_40_path_rock.update
tt.tweens_go_down_fn = decal_stage_40_path_rock.tweens_go_down
tt.render.sprites[1].prefix = "roca_blockDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt.render.sprites[1].scale = vv(0.8)
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].hidden = true
tt.levitate_duration = 2
tt.levitate_height_div2 = 5
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].loop = true

local soff = tt.render.sprites[1].offset

tt.tween.props[1].keys = {{0, v(soff.x, soff.y - tt.levitate_height_div2)}, {tt.levitate_duration, v(soff.x, soff.y + tt.levitate_height_div2)}, {tt.levitate_duration * 2, v(soff.x, soff.y - tt.levitate_height_div2)}}
tt.tween.disabled = false
tt.tween.remove = false
tt.small_rocks = {{
	flip = false,
	pos = v(-80, 26),
	scale = vv(1.2)
}, {
	flip = true,
	pos = v(45, -45),
	scale = vv(1)
}}

tt = E:register_t_hot("decal_stage_40_path_rock_2", "decal_stage_40_path_rock_1", true)
tt.render.sprites[1].prefix = "roca_block02Def"
tt.small_rocks = {{
	flip = false,
	pos = v(-80, 20),
	scale = vv(0.7)
}, {
	flip = false,
	pos = v(-90, -25),
	scale = vv(1)
}, {
	flip = false,
	pos = v(55, -45),
	scale = vv(0.9)
}}

tt = E:register_t_hot("decal_stage_40_path_rock_final", "decal_stage_40_path_rock_1", true)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "roca_block_dragonDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].scale = vv(0.8)
tt.render.sprites[2].sort_y_offset = -2
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].hidden = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt.tween.props[2].keys = {{0, v(soff.x, soff.y - tt.levitate_height_div2)}, {tt.levitate_duration, v(soff.x, soff.y + tt.levitate_height_div2)}, {tt.levitate_duration * 2, v(soff.x, soff.y - tt.levitate_height_div2)}}
tt.small_rocks = {{
	flip = true,
	pos = v(45, -40),
	scale = vv(0.6)
}, {
	flip = true,
	pos = v(-40, -60),
	scale = vv(0.4)
}, {
	flip = false,
	pos = v(-75, 0),
	scale = vv(0.4)
}, {
	flip = true,
	pos = v(40, 40),
	scale = vv(0.4)
}}

tt = E:register_t_hot("controller_stage_40_ballista", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = controller_stage_40_ballista.update
tt.ready_ballista_fn = controller_stage_40_ballista.ready_ballista_fn
tt.render.sprites[1].prefix = "stage_40_canonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "canon_balloonDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(-3, 77)
tt.ui.click_rect = r(-45, -5, 105, 85)
tt.cooldown = 20
tt.damage = {2000, 2500, 3000, 4000, 5000, 7000, 7000}
tt.shoot_nmbr = 0
tt.hand_decal_t = "dlc2_generic_tap_hand"

tt = E:register_t_hot("controller_stage_40_moving_island", "decal_scripted", true)
E:add_comps(tt, "tween", "nav_path", "motion", "events", "attacks", "editor")
tt.main_script.insert = controller_stage_40_moving_island.insert
tt.main_script.update = controller_stage_40_moving_island.update
tt.spawn_soldiers = controller_stage_40_moving_island.spawn_soldiers_fn
tt.tp_to_next_step = controller_stage_40_moving_island.tp_to_next_step_fn
tt.on_open_path = controller_stage_40_moving_island.on_open_path
tt.talk = controller_stage_40_moving_island.talk_fn
tt.current_step = 0
tt.warden_ids = {}
tt.stop_steps = {500, 310, 100, 20}
tt.warden_offsets = {v(0, 0), v(0, 0), v(0, 0)}
tt.motion.max_speed = 7
tt.sid_egg = 1
tt.sid_main_island = 2
tt.sid_top_warden = 3
tt.sid_island_warden_1 = 4
tt.sid_island_warden_2 = 5
tt.sid_island_warden_3 = 6
tt.sid_bottom_rock = 7
tt.sid_left_rock = 8
tt.sid_right_rock = 9
tt.render.sprites[tt.sid_egg] = E:clone_c("sprite")
tt.render.sprites[tt.sid_egg].prefix = "stage_40_eggDef"
tt.render.sprites[tt.sid_egg].name = "idle"
tt.render.sprites[tt.sid_egg].exo = true
tt.render.sprites[tt.sid_egg].sort_y_offset = 30
tt.render.sprites[tt.sid_egg].scale = v(0.93, 0.93)
tt.render.sprites[tt.sid_egg].offset = v(0, 5)
tt.render.sprites[tt.sid_main_island] = E:clone_c("sprite")
tt.render.sprites[tt.sid_main_island].prefix = "roca_eggDef"
tt.render.sprites[tt.sid_main_island].name = "idle"
tt.render.sprites[tt.sid_main_island].exo = true
tt.render.sprites[tt.sid_main_island].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_main_island].sort_y_offset = -50
tt.render.sprites[tt.sid_top_warden] = E:clone_c("sprite")
tt.render.sprites[tt.sid_top_warden].prefix = "warden_eggDef"
tt.render.sprites[tt.sid_top_warden].name = "idle_loop"
tt.render.sprites[tt.sid_top_warden].exo = true
tt.render.sprites[tt.sid_top_warden].offset = v(0, 115)
tt.original_warden_offset_y = tt.render.sprites[tt.sid_top_warden].offset.y
tt.render.sprites[tt.sid_top_warden].sort_y_offset = -30
tt.render.sprites[tt.sid_island_warden_1] = E:clone_c("sprite")
tt.render.sprites[tt.sid_island_warden_1].name = "egg_roca_wardens"
tt.render.sprites[tt.sid_island_warden_1].animated = false
tt.render.sprites[tt.sid_island_warden_1].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_island_warden_1].sort_y_offset = -70
tt.render.sprites[tt.sid_island_warden_1].offset = v(135, 0)
tt.render.sprites[tt.sid_island_warden_1].hidden = true
tt.render.sprites[tt.sid_island_warden_2] = E:clone_c("sprite")
tt.render.sprites[tt.sid_island_warden_2].name = "egg_roca_wardens"
tt.render.sprites[tt.sid_island_warden_2].animated = false
tt.render.sprites[tt.sid_island_warden_2].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_island_warden_2].sort_y_offset = -40
tt.render.sprites[tt.sid_island_warden_2].offset = v(110, 30)
tt.render.sprites[tt.sid_island_warden_2].hidden = true
tt.render.sprites[tt.sid_island_warden_3] = E:clone_c("sprite")
tt.render.sprites[tt.sid_island_warden_3].name = "egg_roca_wardens"
tt.render.sprites[tt.sid_island_warden_3].animated = false
tt.render.sprites[tt.sid_island_warden_3].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_island_warden_3].sort_y_offset = -70
tt.render.sprites[tt.sid_island_warden_3].offset = v(110, -30)
tt.render.sprites[tt.sid_island_warden_3].hidden = true
tt.render.sprites[tt.sid_bottom_rock] = E:clone_c("sprite")
tt.render.sprites[tt.sid_bottom_rock].prefix = "roca_dragon_2Def"
tt.render.sprites[tt.sid_bottom_rock].name = "idle"
tt.render.sprites[tt.sid_bottom_rock].exo = true
tt.render.sprites[tt.sid_bottom_rock].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_bottom_rock].sort_y_offset = -60
tt.render.sprites[tt.sid_bottom_rock].offset = v(128, -60)
tt.render.sprites[tt.sid_left_rock] = E:clone_c("sprite")
tt.render.sprites[tt.sid_left_rock].prefix = "roca_dragon_1Def"
tt.render.sprites[tt.sid_left_rock].name = "idle"
tt.render.sprites[tt.sid_left_rock].exo = true
tt.render.sprites[tt.sid_left_rock].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_left_rock].sort_y_offset = 2
tt.render.sprites[tt.sid_left_rock].offset = v(-185, 0)
tt.render.sprites[tt.sid_right_rock] = E:clone_c("sprite")
tt.render.sprites[tt.sid_right_rock].prefix = "roca_dragon_3Def"
tt.render.sprites[tt.sid_right_rock].name = "idle"
tt.render.sprites[tt.sid_right_rock].exo = true
tt.render.sprites[tt.sid_right_rock].z = Z_BACKGROUND_COVERS
tt.render.sprites[tt.sid_right_rock].sort_y_offset = 0
tt.render.sprites[tt.sid_right_rock].offset = v(130, 40)
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_stage_40_island_wardens"
tt.attacks.list[1].cooldown = 1.25
tt.attacks.list[1].max_range = 350
tt.attacks.list[1].shoot_time = fts(24)
tt.attacks.list[1].prediction_time = fts(30)
tt.attacks.list[1].bullet_start_offset = v(0, 50)
tt.attacks.list[1].animation = "attack"
tt.attacks.list[1].max_count = 3
tt.levitate_duration = 2
tt.levitate_height_div2 = 5

for i = 1, tt.sid_island_warden_3 do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].name = "offset"

	local soff = tt.render.sprites[i].offset

	tt.tween.props[i].keys = {{0, v(soff.x, soff.y - tt.levitate_height_div2)}, {tt.levitate_duration, v(soff.x, soff.y + tt.levitate_height_div2)}, {tt.levitate_duration * 2, v(soff.x, soff.y - tt.levitate_height_div2)}}
	tt.tween.props[i].loop = true
	tt.tween.props[i].interp = "sine"
	tt.tween.props[i].sprite_id = i
	tt.tween.props[i].disabled = true
end

for i = tt.sid_bottom_rock, tt.sid_right_rock do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].name = "offset"

	local remove_duration = 4
	local soff = tt.render.sprites[i].offset

	tt.tween.props[i].keys = {{0, v(soff.x, soff.y)}, {remove_duration, v(soff.x, soff.y - 300)}}
	tt.tween.props[i].loop = false
	tt.tween.props[i].interp = "sine"
	tt.tween.props[i].sprite_id = i
	tt.tween.props[i].disabled = true
end

for i = tt.sid_right_rock + 1, tt.sid_right_rock + 3 do
	local sid = i - (tt.sid_right_rock + 1) + tt.sid_island_warden_1

	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].name = "offset"

	local show_duration = 2
	local soff = tt.render.sprites[sid].offset

	tt.tween.props[i].keys = {{0, v(soff.x, soff.y - 300)}, {show_duration, v(soff.x, soff.y)}}
	tt.tween.props[i].loop = false
	tt.tween.props[i].interp = "sine"
	tt.tween.props[i].sprite_id = sid
	tt.tween.props[i].disabled = true
end

tt.runa = 0
tt.tween.remove = false
tt.events.list[1].name = "move_island"
tt.events.list[1].on_event = controller_stage_40_moving_island.move_island
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "island_soldiers"
tt.events.list[2].on_event = controller_stage_40_moving_island.island_soldiers
tt.decal_spell_effect = "decal_stage_40_moving_island_spell_effect"
tt.decal_spell_effect_offsets = {
	[tt.sid_bottom_rock] = v(4, 4),
	[tt.sid_left_rock] = v(7, 8),
	[tt.sid_right_rock] = v(10, 18),
	BLOCK_1 = v(0, 18),
	BLOCK_2 = v(0, 18),
	BLOCK_3 = v(0, 18)
}

tt = E:register_t_hot("decal_boss_40_waves_stun_decoy_position", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "waveFlag_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vv(0.35)
tt.render.sprites[1].offset = v(-6, -6)
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset = v(6, -6)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].offset = v(0, 6)
tt.editor.overrides = {
	["render.sprites[2].hidden"] = false,
	["render.sprites[1].hidden"] = false,
	["render.sprites[3].hidden"] = false
}

tt = E:register_t_hot("decal_stage_40_path_rock_small", "decal_stage_40_path_rock_1", true)
tt.render.sprites[1].prefix = "roca_block_smallDef"
tt.skip_sparks = true
tt.skip_big_dust = true
tt.random_delay_up = {0.1, 0.5}
tt.random_delay_down = {0.3, 0.8}
tt.small_rocks = {}

tt = E:register_t_hot("decal_stage_40_open_middle_mask_iron", "decal_stage_40_open_middle_mask", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "rocas_idle"

