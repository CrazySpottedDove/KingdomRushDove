local E = require("entity_db")
local v = V.v
local scripts = require("game_scripts")
local tt
local U = require("utils")
local S = require("sound_db")
local signal = require("lib.hump.signal")
local P = require("path_db")
local V = require("lib.klua.vector")
local band = bit.band
local function fts(v)
	return v / FPS
end

local random = math.random

local controller_stage_32_boss = {}

function controller_stage_32_boss.toggle_possessed(this)
	if not this.render.sprites[1].exo_hide_prefix then
		this:hide_possessed()

		return
	end

	if not table.contains(this.render.sprites[1].exo_hide_prefix, "posessed") then
		this:hide_possessed()

		return
	end

	this:show_possessed()
end

function controller_stage_32_boss.show_possessed(this)
	if not this.render.sprites[1].exo_hide_prefix then
		return
	end

	if table.contains(this.render.sprites[1].exo_hide_prefix, "posessed") then
		table.removeobject(this.render.sprites[1].exo_hide_prefix, "posessed")
	end
end

function controller_stage_32_boss.hide_possessed(this)
	table.insert(this.render.sprites[1].exo_hide_prefix, "posessed")
end

function controller_stage_32_boss.insert(this, store)
	local mode_key = "campaign"

	if store.level_mode == GAME_MODE_IRON then
		mode_key = "iron"
	end

	if store.level_mode == GAME_MODE_HEROIC then
		mode_key = "heroic"
	end

	local b = this.boss_controler_balance[mode_key]

	if b.path_fissure_fixed and b.node_fissure_fixed then
		this.path_fissure_fixed = b.path_fissure_fixed
		this.node_fissure_fixed = b.node_fissure_fixed

		for i, v in ipairs(this.path_fissure_fixed) do
			local flaming_ground = E:create_entity(this.decal_fissure_fixed)

			flaming_ground.pos = P:node_pos(this.path_fissure_fixed[i], 1, this.node_fissure_fixed[i])
			flaming_ground.render.sprites[1].ts = store.tick_ts
			flaming_ground.duration = 1e+99

			U.sprites_hide(flaming_ground, nil, nil, false)
			simulation:queue_insert_entity(flaming_ground)
		end
	end

	if b.no_boss ~= nil and b.no_boss == true then
		return false
	end

	this.waves_block_power = b.pre_fight_block_power.waves
	this.first_cooldown_block_power = b.pre_fight_block_power.first_cooldown
	this.cooldown_block_power = b.pre_fight_block_power.cooldown
	this.max_casts_block_power = b.pre_fight_block_power.max_casts
	this.duration_block_power = b.pre_fight_block_power.duration
	this.waves_fissure = b.pre_fight_fissure.waves
	this.first_cooldown_fissure = b.pre_fight_fissure.first_cooldown
	this.cooldown_fissure = b.pre_fight_fissure.cooldown
	this.max_casts_fissure = b.pre_fight_fissure.max_casts
	this.duration_fissure = b.pre_fight_fissure.duration
	this.path_fissure = b.pre_fight_fissure.path
	this.node_fissure = b.pre_fight_fissure.node
	this.cached_fissures = {}

	for i, v in ipairs(this.path_fissure) do
		local fissure = E:create_entity(this.decal_fissure)

		fissure.pos = P:node_pos(this.path_fissure[i], 1, this.node_fissure[i])

		simulation:queue_insert_entity(fissure)
		table.insert(this.cached_fissures, fissure.id)

		if #this.cached_fissures ~= 1 then
			fissure.render.sprites[1].hidden = false
		end
	end

	this.waves_block_towers = b.pre_fight_block_towers.waves
	this.first_cooldown_block_towers = b.pre_fight_block_towers.first_cooldown
	this.cooldown_block_towers = b.pre_fight_block_towers.cooldown
	this.max_casts_block_towers = b.pre_fight_block_towers.max_casts
	this.quantity_block_towers = b.pre_fight_block_towers.quantity
	this.side_block_towers = b.pre_fight_block_towers.side

	local mod_tower_block = E:get_template("mod_stage_32_tower_block")

	mod_tower_block.repair_cost = b.pre_fight_block_towers.repair_cost
	mod_tower_block.modifier.duration = b.pre_fight_block_towers.duration
	this.waves_meteorite = b.pre_fight_meteorite.waves
	this.first_cooldown_meteorite = b.pre_fight_meteorite.first_cooldown
	this.cooldown_meteorite = b.pre_fight_meteorite.cooldown
	this.max_casts_meteorite = b.pre_fight_meteorite.max_casts
	this.side_meteorite = b.pre_fight_meteorite.side

	return true
end

function controller_stage_32_boss.update(this, store)
	local previous_wave_index = {store.wave_group_number, store.wave_group_number, store.wave_group_number}
	local run_this_wave = {false, false, false}
	local cooldown = {0, 0, 0}
	local max_casts = {99, 99, 99}
	local casts = {0, 0, 0}
	local next_ts = {store.tick_ts, store.tick_ts, store.tick_ts}
	local duration = {0, 0, 0}
	local quantity_block_towers = 0
	local side_block_towers = 1
	local block_towers_current_wave_index = 1
	local side_meteorite = "right"
	local down_bubbles = E:create_entity(this.down_bubbles_decal)

	down_bubbles.pos = this.pos

	simulation:queue_insert_entity(down_bubbles)

	local dragon_up_position_y = this.pos.y
	local dragon_down_position_y = dragon_up_position_y - 30

	down_bubbles.dragon_up_pos_y = dragon_up_position_y
	down_bubbles.dragon_down_pos_y = dragon_down_position_y
	this.render.sprites[1].exo_hide_prefix = {}

	local function hide_baby()
		table.insert(this.render.sprites[1].exo_hide_prefix, "redboy_asst")
		table.insert(this.render.sprites[1].exo_hide_prefix, "asst_light01")
		table.insert(this.render.sprites[1].exo_hide_prefix, "asst_swipe01")
		table.insert(this.render.sprites[1].exo_hide_prefix, "asst_swipe02")
	end

	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		hide_baby()
		this:hide_possessed()
	end

	local is_under_lava = false

	local function change_is_under_lava_by_anim(name, do_splash)
		local was_under_lava = is_under_lava
		local bubbles_timing = 0

		if name == "under_in" or name == "apear_in" then
			bubbles_timing = fts(29)
			is_under_lava = false
		elseif name == "death_in" then
			bubbles_timing = fts(15)
			is_under_lava = false
		elseif name == "under_out" then
			is_under_lava = true
			bubbles_timing = fts(26)
		elseif name == "lava_crack" then
			is_under_lava = true
			bubbles_timing = fts(47)
		end

		local changed = was_under_lava ~= is_under_lava

		if not changed then
			return
		end

		down_bubbles.activate_ts = store.tick_ts + bubbles_timing
		down_bubbles.going_down = is_under_lava
		down_bubbles.do_splash = do_splash
	end

	local function dragon_animation_start(name, loop)
		this.render.sprites[this.render.sid_dragon].prefix = this.exo_anim_map[name]

		change_is_under_lava_by_anim(name)
		U.animation_start(this, name, nil, store.tick_ts, loop, this.render.sid_dragon, true)
	end

	local function y_dragon_animation_play(name)
		this.render.sprites[this.render.sid_dragon].prefix = this.exo_anim_map[name]

		change_is_under_lava_by_anim(name)
		U.y_animation_play(this, name, nil, store.tick_ts, 1, this.render.sid_dragon)
	end

	local function run_dragon_idle()
		local name = is_under_lava and "under_idle" or "idle"

		this.render.sprites[this.render.sid_dragon].prefix = this.exo_anim_map[name]

		U.animation_start(this, name, nil, store.tick_ts, true, this.render.sid_dragon, true)
	end

	this.last_taunt = nil
	this.current_taunt = nil

	local function manage_taunts()
		if not this.do_taunt then
			return false
		end

		local taunt = this.do_taunt

		this.do_taunt = nil
		this.last_taunt = this.current_taunt
		this.current_taunt = taunt

		U.y_animation_wait(this, this.render.sid_dragon, this.render.sprites[this.render.sid_dragon].runs + 1)
		signal.emit("show-balloon_tutorial", taunt, false)
		y_dragon_animation_play(is_under_lava and "under_talk" or "talk")
		run_dragon_idle()
		U.y_wait_unconditional(store, 2)

		this.last_taunt = this.current_taunt
		this.current_taunt = nil

		return true
	end

	if not this.restarted and store.level_mode == GAME_MODE_CAMPAIGN then
		change_is_under_lava_by_anim("under_out", false)

		down_bubbles.moving_towards = "down"
		this.pos.y = dragon_down_position_y
	end

	run_dragon_idle()

	this.render.sprites[this.render.sid_dragon].ts = store.tick_ts - 1

	if not this.restarted and store.level_mode == GAME_MODE_CAMPAIGN then
		while not this.end_intro do
			manage_taunts()
			coroutine.yield()
		end

		S:queue("Stage32RedboyDragonRoar")
		dragon_animation_start("apear_in", false)
		U.y_wait_unconditional(store, fts(85))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.5
		shake.aura.duration = fts(45)
		shake.aura.freq_factor = 2

		simulation:queue_insert_entity(shake)
		U.y_animation_wait(this, this.render.sid_dragon)
		run_dragon_idle()
		U.y_wait_unconditional(store, 1)
	end

	local function shuffle(tbl)
		local shuffled = {}

		for i = 1, #tbl do
			shuffled[i] = tbl[i]
		end

		for i = #shuffled, 2, -1 do
			local j = math.random(i)

			shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
		end

		return shuffled
	end

	local function power_block_powers(fixed_wave)
		local was_under_lava = is_under_lava

		if not is_under_lava then
			y_dragon_animation_play("under_out")
		end

		S:queue("Stage32RedboyDragonSpellBlock")
		dragon_animation_start("under_screen_block", false)
		U.y_wait_unconditional(store, fts(4))

		local fx = E:create_entity(this.ui_block_hand_fx)

		fx.pos = V.v(this.pos.x + -32, this.pos.y + 102)
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].scale = V.vv(0.45499999999999996)

		simulation:queue_insert_entity(fx)
		U.y_wait_unconditional(store, fts(20))

		casts[1] = casts[1] + 1

		local d = fixed_wave and this.duration_block_power[fixed_wave] or duration[1]

		signal.emit("block-random-power", d, "dragon_boss", true)

		next_ts[1] = store.tick_ts + cooldown[1]

		U.y_animation_wait(this, this.render.sid_dragon, 1)

		if not was_under_lava then
			y_dragon_animation_play("under_in")
		end

		run_dragon_idle()
	end

	local function power_fissures(fixed_wave)
		if is_under_lava then
			y_dragon_animation_play("under_in")
		end

		S:queue("Stage32RedboyDragonLavaSurge")

		local anim_name = "lava_crack"
		local wait_time = fts(47)

		if store.level_mode ~= GAME_MODE_CAMPAIGN then
			anim_name = "under_out"
			wait_time = fts(26)
		end

		dragon_animation_start(anim_name, false)

		this.render.sprites[this.render.sid_dragon].runs = 0
		casts[2] = casts[2] + 1
		next_ts[2] = store.tick_ts + cooldown[2]

		U.y_wait_unconditional(store, wait_time)

		local d = fixed_wave and this.duration_fissure[fixed_wave] or duration[2]

		for _, fissure_id in pairs(this.cached_fissures) do
			local fissure = store.entities[fissure_id]

			if fissure then
				fissure.duration = d
				fissure.activate = true
			end
		end

		this.end_fissures_ability_ts = store.tick_ts + d

		U.y_animation_wait(this, this.render.sid_dragon, 1)
		run_dragon_idle()
	end

	local function power_block_towers(fixed_wave, force_animation_without_towers, reset_height_after_power)
		casts[3] = casts[3] + 1
		next_ts[3] = store.tick_ts + cooldown[3]

		local side_pattern_number = casts[3] % #this.side_block_towers[block_towers_current_wave_index]

		if side_pattern_number == 0 then
			side_pattern_number = #this.side_block_towers[block_towers_current_wave_index]
		end

		side_block_towers = shuffle(this.side_block_towers[fixed_wave and fixed_wave or block_towers_current_wave_index][side_pattern_number])

		local towers = table.filter(store.towers, function(k, v)
			return not v.tower_holder and v.tower.can_be_mod and table.contains(side_block_towers, tonumber(v.tower.holder_id))
		end)
		local avg_x = 0

		if #towers > 0 then
			for k, v in pairs(towers) do
				avg_x = avg_x + v.pos.x
			end

			avg_x = avg_x / #towers
		elseif not force_animation_without_towers then
			return
		end

		local anim = avg_x < this.pos.x and "stun_l" or "stun_r"
		local was_under_lava = is_under_lava

		if is_under_lava then
			y_dragon_animation_play("under_in")
		end

		S:queue("Stage32RedboyDragonBlockTowers")
		dragon_animation_start(anim, false)
		U.y_wait_unconditional(store, fts(70))

		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = 0.4
		shake.aura.duration = fts(55)
		shake.aura.freq_factor = 2

		simulation:queue_insert_entity(shake)

		local fx = E:create_entity(this.tower_block_mouth_fx .. (anim == "stun_r" and "_right" or "_left"))

		fx.pos = V.v(this.pos.x + this.tower_block_mouth_fx_offset.x, this.pos.y + this.tower_block_mouth_fx_offset.y)

		if anim == "stun_r" then
			fx.pos.x = fx.pos.x - this.tower_block_mouth_fx_offset.x * 2
		end

		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
		U.y_wait_unconditional(store, fts(28))

		local towers = table.filter(store.entities, function(k, v)
			return not v.pending_removal and v.tower and not v.tower_holder and v.tower.can_be_mod and table.contains(side_block_towers, tonumber(v.tower.holder_id))
		end)

		side_block_towers = shuffle(this.side_block_towers[fixed_wave and fixed_wave or block_towers_current_wave_index][side_pattern_number])

		local blocked_amount = 0
		local max_towers = quantity_block_towers

		if fixed_wave then
			max_towers = this.quantity_block_towers[fixed_wave]
		end

		for i, holder_id in ipairs(side_block_towers) do
			for k, v in pairs(towers) do
				if tonumber(v.tower.holder_id) == holder_id and not U.has_modifiers(store, v, this.mod_tower_block) then
					local block_tower_mod = E:create_entity(this.mod_tower_block)

					block_tower_mod.modifier.target_id = v.id

					simulation:queue_insert_entity(block_tower_mod)

					blocked_amount = blocked_amount + 1
				end

				if max_towers <= blocked_amount then
					goto label_1899_0
				end
			end
		end

		::label_1899_0::

		U.y_animation_wait(this, this.render.sid_dragon, 1)

		if reset_height_after_power and was_under_lava then
			y_dragon_animation_play("under_out")
		end

		run_dragon_idle()
	end

	local function power_meteorites(fixed_wave, fixed_loop_time, skip_taunt)
		local was_under_lava = is_under_lava

		if not was_under_lava then
			y_dragon_animation_play("under_out")
		end

		if not skip_taunt then
			if not this.taunts_meteorites then
				this.taunts_meteorites = {"LV32_BOSS_ABILITY_01", "LV32_BOSS_ABILITY_02", "LV32_BOSS_ABILITY_03", "LV32_BOSS_ABILITY_04", "LV32_BOSS_ABILITY_05"}
				this.taunt_meteorite_index = 1
			end

			this.do_taunt = this.taunts_meteorites[this.taunt_meteorite_index] .. (is_under_lava and "_LOW" or "_HIGH")
			this.taunt_meteorite_index = this.taunt_meteorite_index + 1

			if this.taunt_meteorite_index > #this.taunts_meteorites then
				this.taunt_meteorite_index = 1
			end

			manage_taunts()
		end

		casts[4] = casts[4] + 1
		next_ts[4] = store.tick_ts + cooldown[4]

		local side = side_meteorite

		if fixed_wave then
			side = this.side_meteorite[fixed_wave]
		end

		local side_anims = {
			left = {
				loop = "under_samadhi_l_loop",
				out = "under_samadhi_l_end",
				["in"] = "under_samadhi_l"
			},
			right = {
				loop = "under_samadhi_r_loop",
				out = "under_samadhi_r_end",
				["in"] = "under_samadhi_r_in"
			}
		}

		S:queue("Stage32RedboyDragonSamadhiFireStart")
		S:queue("Stage32RedboyDragonSamadhiFireEnd")
		y_dragon_animation_play(side_anims[side]["in"])

		local fireball = E:create_entity("fx_stage_32_fireball_" .. side)

		fireball.pos.x, fireball.pos.y = 512, 382

		simulation:queue_insert_entity(fireball)
		dragon_animation_start(side_anims[side].loop, true)
		U.y_wait_unconditional(store, fixed_loop_time and fixed_loop_time or 5.6)
		U.y_animation_wait(this, this.render.sid_dragon, this.render.sprites[this.render.sid_dragon].runs + 1)
		y_dragon_animation_play(side_anims[side].out)

		if not was_under_lava then
			y_dragon_animation_play("under_in")
		end

		run_dragon_idle()
	end

	local function stop_fissures()
		for _, fissure_id in pairs(this.cached_fissures) do
			local fissure = store.entities[fissure_id]

			if fissure then
				fissure.stop = true
			end
		end
	end

	while not this.in_bossfight do
		if manage_taunts() then
		-- block empty
		else
			if previous_wave_index[1] ~= store.wave_group_number then
				previous_wave_index[1] = store.wave_group_number
				run_this_wave[1] = false

				for i, v in ipairs(this.waves_block_power) do
					if store.wave_group_number == v then
						run_this_wave[1] = true
						cooldown[1] = this.cooldown_block_power[i]
						casts[1] = 0
						max_casts[1] = this.max_casts_block_power[i]
						duration[1] = this.duration_block_power[i]
						next_ts[1] = store.tick_ts + this.first_cooldown_block_power[i]

						break
					end
				end
			end

			if run_this_wave[1] and casts[1] < max_casts[1] and store.tick_ts >= next_ts[1] then
				power_block_powers()
			else
				if previous_wave_index[2] ~= store.wave_group_number then
					previous_wave_index[2] = store.wave_group_number
					run_this_wave[2] = false

					for i, v in ipairs(this.waves_fissure) do
						if store.wave_group_number == v then
							run_this_wave[2] = true
							cooldown[2] = this.cooldown_fissure[i]
							casts[2] = 0
							max_casts[2] = this.max_casts_fissure[i]
							duration[2] = this.duration_fissure[i]
							next_ts[2] = store.tick_ts + this.first_cooldown_fissure[i]

							break
						end
					end
				end

				if run_this_wave[2] and casts[2] < max_casts[2] and store.tick_ts >= next_ts[2] then
					power_fissures()
				elseif this.end_fissures_ability_ts and store.tick_ts > this.end_fissures_ability_ts then
					this.end_fissures_ability_ts = nil

					y_dragon_animation_play("under_in")
					run_dragon_idle()
				else
					if previous_wave_index[3] ~= store.wave_group_number or this.force_stun_towers then
						previous_wave_index[3] = store.wave_group_number
						run_this_wave[3] = false

						if this.force_stun_towers then
							block_towers_current_wave_index = "boss_jump"
							run_this_wave[3] = true
							this.force_stun_towers = nil
						else
							for i, v in ipairs(this.waves_block_towers) do
								if store.wave_group_number == v then
									block_towers_current_wave_index = i
									run_this_wave[3] = true

									break
								end
							end
						end

						if run_this_wave[3] then
							casts[3] = 0
							cooldown[3] = this.cooldown_block_towers[block_towers_current_wave_index]
							max_casts[3] = this.max_casts_block_towers[block_towers_current_wave_index]
							quantity_block_towers = this.quantity_block_towers[block_towers_current_wave_index]
							next_ts[3] = store.tick_ts + this.first_cooldown_block_towers[block_towers_current_wave_index]
						end
					end

					if run_this_wave[3] and casts[3] < max_casts[3] and store.tick_ts >= next_ts[3] then
						power_block_towers()
					else
						if previous_wave_index[4] ~= store.wave_group_number then
							previous_wave_index[4] = store.wave_group_number
							run_this_wave[4] = false

							for i, v in ipairs(this.waves_meteorite) do
								if store.wave_group_number == v then
									run_this_wave[4] = true
									cooldown[4] = this.cooldown_meteorite[i]
									casts[4] = 0
									max_casts[4] = this.max_casts_meteorite[i]
									side_meteorite = this.side_meteorite[i]
									next_ts[4] = store.tick_ts + this.first_cooldown_meteorite[i]

									break
								end
							end
						end

						if run_this_wave[4] and casts[4] < max_casts[4] and store.tick_ts >= next_ts[4] then
							power_meteorites()
						end
					end
				end
			end
		end

		coroutine.yield()
	end

	U.y_wait_unconditional(store, 4.5)
	signal.emit("pan-zoom-camera", 1.5, {
		x = 512,
		y = 450
	}, 1.65)
	signal.emit("show-curtains")
	signal.emit("hide-gui")
	signal.emit("start-cinematic")
	U.y_wait_unconditional(store, 2)
	power_fissures()

	this.do_taunt = "LV32_BOSS_PREFIGHT_01"

	manage_taunts()
	dragon_animation_start("under_transform")
	S:queue("Stage32RedboyTransform")
	U.y_wait_unconditional(store, fts(8))

	local fire_fx = E:create_entity("fx_stage_32_redboy_transform_fire")

	fire_fx.render.sprites[1].ts = store.tick_ts
	fire_fx.render.sprites[1].track_attach_point = "Base"
	fire_fx.render.sprites[1].track_sprite_id = 1
	fire_fx.render.sprites[1].track_id = this.id

	simulation:queue_insert_entity(fire_fx)
	U.y_wait_unconditional(store, fts(5))

	local u = E:create_entity(this.boss_unit_spawn)

	u.render.sprites[1].z = Z_OBJECTS
	u.render.sprites[1].track_attach_point = "Base"
	u.render.sprites[1].track_sprite_id = 1
	u.render.sprites[1].track_id = this.id

	simulation:queue_insert_entity(u)
	hide_baby()
	U.y_animation_wait(this, this.render.sid_dragon, this.render.sprites[this.render.sid_dragon].runs + 1)
	run_dragon_idle()

	while not this.do_boss_death do
		if this.do_stun_towers then
			power_block_towers(this.do_stun_towers, true, true)

			this.do_stun_towers = nil
		end

		coroutine.yield()
	end

	local mouth_phases = {"death_eat_loop_a", "death_eat_loop_b", "death_eat_loop_c", "death_eat_loop_d"}
	local current_mouth_phase = 1

	y_dragon_animation_play("death_in")
	dragon_animation_start(mouth_phases[current_mouth_phase], true)

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.35
	shake.aura.duration = 1e+99
	shake.aura.freq_factor = 2

	simulation:queue_insert_entity(shake)
	U.y_wait_unconditional(store, 1.5)

	for i = current_mouth_phase + 1, #mouth_phases do
		dragon_animation_start(mouth_phases[i], true)
		U.y_wait_unconditional(store, 1.5)
	end

	simulation:queue_remove_entity(shake)
	y_dragon_animation_play("death_end_01")
	dragon_animation_start("death_end_02", false)

	local start_end_anim_ts = store.tick_ts
	local anim_duration = fts(87)

	U.y_wait_unconditional(store, fts(44))

	local screen_fx = E:create_entity("fx_redboy_screen")

	screen_fx.pos = V.v(512, 384)
	screen_fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(screen_fx)
	U.y_wait_unconditional(store, fts(6))

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.35
	shake.aura.duration = 0.4
	shake.aura.freq_factor = 2

	simulation:queue_insert_entity(shake)

	local wait_ts_start = store.tick_ts

	while store.tick_ts - wait_ts_start < fts(38) do
		if anim_duration < store.tick_ts - start_end_anim_ts and this.render.sprites[this.render.sid_dragon].name == "death_end_02" then
			run_dragon_idle()
		end

		coroutine.yield()
	end

	if this.render.sprites[this.render.sid_dragon].name == "death_end_02" then
		U.y_animation_wait(this, this.render.sid_dragon, 1)
		run_dragon_idle()
	end

	this.boss_death_ended = true
end

local controller_stage_32_lava_splash = {}

function controller_stage_32_lava_splash.update(this, store)
	while true do
		local enemies = table.filter(store.enemies, function(k, v)
			if v.pending_removal then
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

			if not this.paths_y[v.nav_path.pi] then
				return false
			end

			if v.pos.y < this.paths_y[v.nav_path.pi] then
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

tt = E:register_t_hot("controller_stage_32_lava_splash", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_32_lava_splash.update
tt.mod = "mod_stage_32_lava_splash"
tt.paths_y = {
	[2] = 560
}
tt.vis_flags = 0
tt.vis_bans = 0

tt = E:register_t_hot("controller_stage_32_boss", "decal_scripted", true)
E:add_comps(tt, "editor", "ui")
tt.boss_controler_balance = {
	death_duration = 12,
	death_taps_per_mouth_phase = 5,
	campaign = {
		node_fissure_fixed = {26, 7, 10, 14, 7, 10, 14},
		path_fissure_fixed = {1, 2, 2, 2, 3, 3, 3},
		pre_fight_block_power = {
			waves = {},
			first_cooldown = {},
			cooldown = {},
			max_casts = {},
			duration = {}
		},
		pre_fight_fissure = {
			waves = {3, 6, 7, 8, 10, 13, 15},
			first_cooldown = {13, 7, 14, 1, 24, 1, 14},
			cooldown = {0, 0, 0, 0, 26, 0, 35},
			max_casts = {1, 1, 1, 1, 1, 1, 2},
			duration = {
				18,
				14,
				33,
				58,
				45,
				72,
				30,
				boss_jump = 1e+99
			},
			path = {1, 1, 2, 3},
			node = {50, 41, 40, 36}
		},
		pre_fight_block_towers = {
			repair_cost = 100,
			duration = 30,
			waves = {5, 9, 11, 12, 14, 15},
			first_cooldown = {20, 13, 12, 20, 7, 35},
			cooldown = {0, 33, 0, 19, 40, 0},
			max_casts = {1, 2, 1, 2, 2, 1},
			quantity = {
				1,
				2,
				2,
				2,
				2,
				3,
				boss_jump = 3
			},
			side = {
				{{7, 8, 9}},
				{{7, 8, 9}},
				{{4, 3, 6}},
				{{7, 8, 9}},
				{{7, 8, 9}},
				{{4, 3, 6}},
				boss_jump = {{7, 8, 9}, {7, 8, 9}}
			}
		},
		pre_fight_meteorite = {
			fire_duration = 15,
			waves = {4, 7, 10, 14},
			first_cooldown = {0, 0, 0, 0},
			cooldown = {0, 0, 0, 0},
			max_casts = {1, 1, 1, 1},
			side = {
				"right",
				"left",
				"left",
				"right",
				boss_jump = "right"
			}
		}
	},
	heroic = {
		no_boss = true,
		node_fissure_fixed = {26, 7, 10, 14, 7, 10, 14},
		path_fissure_fixed = {1, 2, 2, 2, 3, 3, 3}
	},
	iron = {
		node_fissure_fixed = {26, 7, 10, 14, 7, 10, 14},
		path_fissure_fixed = {1, 2, 2, 2, 3, 3, 3},
		pre_fight_block_power = {
			waves = {},
			first_cooldown = {},
			cooldown = {},
			max_casts = {},
			duration = {}
		},
		pre_fight_fissure = {
			waves = {1},
			first_cooldown = {0},
			cooldown = {42},
			max_casts = {9},
			duration = {33},
			path = {1, 1, 2, 3},
			node = {50, 41, 40, 36}
		},
		pre_fight_block_towers = {
			repair_cost = 100,
			duration = 30,
			waves = {1},
			first_cooldown = {35},
			cooldown = {45},
			max_casts = {8},
			quantity = {1},
			side = {{{47, 48, 49}, {43, 44, 45, 46}, {47, 48, 49}, {43, 44, 45, 46}, {47, 48, 49}, {47, 48, 49}, {43, 44, 45, 46}, {43, 44, 45, 46}}}
		},
		pre_fight_meteorite = {
			waves = {},
			first_cooldown = {},
			cooldown = {},
			max_casts = {},
			side = {}
		}
	}
}
tt.main_script.insert = controller_stage_32_boss.insert
tt.main_script.update = controller_stage_32_boss.update
tt.toggle_possessed = controller_stage_32_boss.toggle_possessed
tt.show_possessed = controller_stage_32_boss.show_possessed
tt.hide_possessed = controller_stage_32_boss.hide_possessed
tt.render.sid_dragon = 1
tt.exo_anim_map = {
	under_in = "dragon_redboy_BDef",
	under_samadhi_r_end = "dragon_redboy_BDef",
	idle = "dragon_redboy_CDef",
	under_samadhi_r_in = "dragon_redboy_BDef",
	under_samadhi_r_loop = "dragon_redboy_BDef",
	death_end_01 = "dragon_redboy_ADef",
	lava_crack = "dragon_redboy_CDef",
	under_samadhi_l_end = "dragon_redboy_BDef",
	under_screen_block = "dragon_redboy_BDef",
	death_in = "dragon_redboy_ADef",
	under_transform = "dragon_redboy_BDef",
	death_end_02 = "dragon_redboy_ADef",
	attack_basic_c = "dragon_redboy_ADef",
	under_talk = "dragon_redboy_BDef",
	stun_r = "dragon_redboy_CDef",
	under_idle = "dragon_redboy_BDef",
	under_samadhi_l_loop = "dragon_redboy_BDef",
	under_out = "dragon_redboy_CDef",
	death_eat_loop_b = "dragon_redboy_ADef",
	stun_l = "dragon_redboy_CDef",
	apear_in = "dragon_redboy_ADef",
	death_eat_loop_d = "dragon_redboy_ADef",
	talk = "dragon_redboy_CDef",
	death_eat_loop_a = "dragon_redboy_ADef",
	under_samadhi_l = "dragon_redboy_BDef",
	death_eat_loop_c = "dragon_redboy_ADef"
}
tt.render.sprites[tt.render.sid_dragon].prefix = tt.exo_anim_map.idle
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "idle"
tt.render.sprites[tt.render.sid_dragon].offset = v(0, 20)
tt.death_taps_per_mouth_phase = 5
tt.bossfight_start_meteorite_side = "left"
tt.death_duration = 12
tt.ui_block_hand_fx = "fx_redboy_teen_hand"
tt.hand_decal_t = "dlc2_generic_tap_hand"
tt.boss_unit_spawn = "boss_redboy_teen"
tt.decal_fissure_fixed = "decal_dlc_wukong_flaming_ground"
tt.decal_fissure = "decal_stage_32_boss_fissure_ability"
tt.mod_tower_block = "mod_stage_32_tower_block"
tt.tower_block_mouth_fx = "fx_stage_32_dragon_mouth_fire"
tt.tower_block_mouth_fx_offset = v(0, 0)
tt.down_bubbles_decal = "decal_stage_32_boss_bubbles"
tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.has_nav_mesh = false
tt.ui.click_rect = r(-140, -100, 280, 400)

