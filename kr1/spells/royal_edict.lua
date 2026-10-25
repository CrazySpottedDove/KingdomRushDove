local V = require("lib.klua.vector")
local v = V.v
local vv = V.vv
local bit = require("bit")
local E = require("entity_db")
local U = require("utils")
local signal = require("lib.hump.signal")
local S = require("sound_db")
local GR = require("grid_db")
local P = require("path_db")

local fts = U.fts
local M = {}

M.id = "royal_edict"
M.i18n = "POWER_ROYAL_EDICT"
M.control = "power_royal_edict_control"
M.button_icon = "in_game_icon_power_royal_edict"
M.pointer_icon = "pointer_power_royal_edict"
M.portrait = "power_portraits_big_royal_edict"
M.name_style = {
	font_name = "h",
	font_size = 30,
	color = {212, 170, 255, 255},
	shaders = {"p_outline", "p_glow"},
	shader_args = {{
		thickness = 3,
		outline_color = {0.18, 0.07, 0.30, 1}
	}, {
		thickness = 2,
		glow_color = {0.55, 0.30, 0.90, 0.7}
	}},
	shader_margin = 16
}
M.required_textures = {"go_power_royal_edict"}
M.plugin_required_textures = {}
M.required_sounds = {"spell_royal_edict"}
M.plugin_required_sounds = {}
M.required_exoskeletons = {"royal_edictDef", "royal_edict_underDef", "royal_edict_decalDef", "royal_edict_confettiDef", "royal_edict_towerbuffDef"}
M.plugin_required_exoskeletons = {}

function M.register_templates(E)
	local scripts = require("game_scripts")
	local SU = require("script_utils")
	local tt

	tt = E:register_t_tmp(M.control, "power_control_custom")
	tt.main_script.insert = function(this, store)
		local towers = table.filter(store.towers, function(_, e)
			return e.tower.can_be_mod and not e.tower.blocked and U.is_inside_ellipse(e.pos, this.pos, this.range)
		end)

		for _, t in ipairs(towers) do
			for _, m in ipairs(this.mods) do
				local nm = E:create_entity(m)

				nm.modifier.target_id = t.id
				nm.modifier.source_id = this.id
				nm.pos.x, nm.pos.y = t.pos.x, t.pos.y
				simulation:queue_insert_entity(nm)
			end
		end

		return true
	end
	tt.main_script.update = function(this, store)
		local k = E:create_entity(this.king_decal)

		k.pos.x, k.pos.y = this.pos.x, this.pos.y

		simulation:queue_insert_entity(k)

		k = E:create_entity(this.rug_decal)
		k.pos.x, k.pos.y = this.pos.x, this.pos.y

		simulation:queue_insert_entity(k)

		local kd = E:create_entity(this.area_decal)

		kd.pos.x, kd.pos.y = this.pos.x, this.pos.y
		kd.tween.ts = store.tick_ts
		kd.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(kd)

		S:queue(this.sound_cast)

		if this.gold_mod then
			local duration = E:get_template(this.mods[1]).modifier.duration
			local ts = store.tick_ts
			local buffed = {}

			local function apply_gold_mod(e, remaining)
				buffed[e.id] = true

				local gm = E:create_entity(this.gold_mod)

				gm.modifier.target_id = e.id
				gm.modifier.source_id = this.id
				gm.modifier.duration = remaining

				simulation:queue_insert_entity(gm)
			end

			local check_interval = fts(10)

			while duration > store.tick_ts - ts do
				local remaining = duration - (store.tick_ts - ts)

				if this.is_global then
					for _, e in pairs(store.enemies) do
						if not buffed[e.id] and not e.health.dead then
							apply_gold_mod(e, remaining)
						end
					end
				else
					local enemies = U.find_enemies_in_range_filter_off(this.pos, this.range, F_NONE, F_NONE)

					if enemies then
						for _, e in ipairs(enemies) do
							if not buffed[e.id] then
								apply_gold_mod(e, remaining)
							end
						end
					end
				end

				U.y_wait_unconditional(store, check_interval)
			end
		end

		simulation:queue_remove_entity(this)
	end
	tt.user_selection.can_select_point_fn = scripts.user_power_3.can_select_point
	tt.cooldown = 50
	tt.range = 200
	tt.duration = 0.5
	tt.is_global = false
	tt.gold_mod = nil
	tt.king_decal = "decal_power_royal_edict_king"
	tt.rug_decal = "decal_power_royal_edict_rug"
	tt.area_decal = "decal_power_royal_edict_area"
	tt.mods = {"mod_power_royal_edict_towerbuff"}
	tt.sound_cast = "PowersRoyalDecreeCastLvl1"
	tt.sound_cast_upgraded = "PowersRoyalDecreeCastLvl6"

	-- 设置技能
	E:set_template("user_power_3", tt)

	tt = E:register_t_tmp("decal_power_royal_edict_king", "decal_scripted")
	tt.render.sprites[1].prefix = "royal_edictDef"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_OBJECTS
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
	tt.duration = 0.5
	tt.animation_start = "lvl1run"
	tt.animation_idle = "lvl1loop"
	tt.animation_end = "lvl1loopend"

	tt = E:register_t_tmp("decal_power_royal_edict_rug", "decal_scripted")
	tt.render.sprites[1].prefix = "royal_edict_underDef"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_DECALS
	tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
	tt.duration = 0.5
	tt.animation_start = "lvl1run"
	tt.animation_idle = "lvl1loop"
	tt.animation_end = "lvl1loopend"

	tt = E:register_t_tmp("decal_power_royal_edict_area", "decal_tween")
	E:add_comps(tt, "main_script")
	tt.render.sprites[1].prefix = "royal_edict_decalDef"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_DECALS - 1
	tt.tween.props[1].name = "alpha"
	tt.tween.props[1].keys = {{0, 0}, {fts(30), 255}}
	tt.tween.remove = false
	tt.tween.run_once = true
	tt.main_script.remove = scripts.tween_utils.reverse_remove
	tt.main_script.update = scripts.tween_utils.wait_update
	tt.wait_time = 0.5 + 1

	tt = E:register_t_tmp("decal_power_royal_edict_confetti", "decal_scripted")
	tt.render.sprites[1].prefix = "royal_edict_confettiDef"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.main_script.update = scripts.tween_utils.wait_update

	tt = E:register_t_tmp("mod_power_royal_edict_towerbuff", "modifier")
	E:add_comps(tt, "render", "tween")
	tt.render.sprites[1].prefix = "royal_edict_towerbuffDef"
	tt.render.sprites[1].name = "start"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].offset = v(0, 11)
	tt.render.sprites[1].scale = vv(0.95)
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].draw_order = 19
	tt.tween.props[1].name = "alpha"
	tt.tween.props[1].keys = {{0, 0}, {1, 255}}
	tt.tween.disabled = true
	tt.tween.remove = false
	tt.tween.run_once = true
	tt.main_script.insert = function(this, store)
		if not scripts.mod_tower_factors.insert(this, store) then
			return false
		end

		local target = store.entities[this.modifier.target_id]
		if not target then
			return false
		end

		if this.respawn_barracks and target.barrack then
			for _, e in pairs(target.barrack.soldiers) do
				if e.health and e.health.dead then
					simulation:queue_remove_entity(e)
				end
			end
		end

		if this.reset_skills_cd then
			if target.attacks then
				for _, a in ipairs(target.attacks.list) do
					if a.cooldown then
						a.ts = store.tick_ts - a.cooldown
					end
				end
			end
			if target.barrack then
				for _, s in ipairs(target.barrack.soldiers) do
					if s.melee then
						for _, a in ipairs(s.melee.attacks) do
							if a.cooldown then
								a.ts = store.tick_ts - a.cooldown
							end
						end
					end

					if s.ranged then
						for _, a in ipairs(s.ranged.attacks) do
							if a.cooldown then
								a.ts = store.tick_ts - a.cooldown
							end
						end
					end
				end
			end
		end
		return true
	end
	tt.main_script.remove = scripts.mod_tower_factors.remove
	tt.main_script.update = function(this, store)
		local m = this.modifier
		local target = store.entities[m.target_id]

		if target then
			this.pos = target.pos
		end

		local target_lost = false

		::label_royal_edict_replay::

		target_lost = false

		for i, val in ipairs(this.animations) do
			if val[2] then
				if i == #this.animations then
					U.animation_start(this, val[1], nil, store.tick_ts, true)
				elseif val[3] then
					U.animation_start(this, val[1], nil, store.tick_ts, val[3])
				else
					U.animation_start(this, val[1], nil, store.tick_ts, false)
				end
			else
				U.y_animation_play(this, val[1], nil, store.tick_ts)
			end
		end

		m = this.modifier

		local fade_out_time = this.tween.props[1].keys[2][1]

		m.ts = store.tick_ts

		local cycle_ts = store.tick_ts

		while store.tick_ts - m.ts < m.duration - fade_out_time do
			-- 目标塔在 update 期间被移除：跳过剩余持续时间，直接淡出
			if not store.entities[m.target_id] then
				target_lost = true

				break
			end

			if this.confetti and store.tick_ts - cycle_ts > this.confetti_cycle_time then
				local r = v(U.frandom(-this.confetti_range, this.confetti_range), U.frandom(-this.confetti_range, this.confetti_range))
				local c = E:create_entity(this.confetti)
				local s = this.render.sprites[1]

				c.pos.x, c.pos.y = this.pos.x + s.offset.x + r.x, this.pos.y + s.offset.y + r.y

				simulation:queue_insert_entity(c)

				cycle_ts = store.tick_ts
			end

			coroutine.yield()
		end

		this.tween.disabled = false
		this.tween.reverse = true
		this.tween.ts = store.tick_ts

		local fade_ts = store.tick_ts

		while fade_out_time > store.tick_ts - fade_ts do
			-- 目标已消失时不再 replay，保证淡出后正常移除
			if not target_lost and m.resets_same and store.tick_ts - m.ts < m.duration - fade_out_time then
				this.tween.reverse = false
				this.tween.ts = store.tick_ts

				goto label_royal_edict_replay
			end

			coroutine.yield()
		end

		simulation:queue_remove_entity(this)
	end
	tt.modifier.duration = 6
	tt.modifier.use_mod_offset = false
	tt.modifier.resets_same = true
	tt.animations = {{"start", false}, {"loop", true}}
	tt.confetti = nil
	tt.confetti_cycle_time = 1
	tt.confetti_range = 60
	tt.range_factor = 1
	tt.damage_factor = 1.4
	tt.respawn_barracks = false
	tt.reset_skills_cd = false

	tt = E:register_t_tmp("mod_power_royal_edict_golddebuff", "modifier")
	tt.main_script.insert = scripts.mod_track_target.insert
	tt.main_script.update = scripts.mod_track_target.update
	tt.main_script.remove = function(this, store)
		local target = store.entities[this.modifier.target_id]
		if target then
			if target.health.dead then
				SU.get_gold(store, this.extra_gold, target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			end
		end
		return true
	end
	tt.modifier.duration = 1
	tt.extra_gold = 3
end

-- 法术的科技生效接口
function M.apply(level)
	local buff = E:get_template("mod_power_royal_edict_towerbuff")
	local ctrl = E:get_template("power_royal_edict_control")

	if level >= 2 then
		buff.range_factor = buff.range_factor * 1.2
		buff.respawn_barracks = true
	end

	if level >= 3 then
		ctrl.range = ctrl.range * 1.5
		buff.confetti = "decal_power_royal_edict_confetti"
	end

	if level >= 4 then
		buff.damage_factor = buff.damage_factor + 0.2
		ctrl.gold_mod = "mod_power_royal_edict_golddebuff"
	end

	if level >= 5 then
		buff.reset_skills_cd = true
		buff.modifier.duration = buff.modifier.duration * 1.33
	end

	if level >= 6 then
		ctrl.range = math.huge
		ctrl.sound_cast = ctrl.sound_cast_upgraded
	end
end

return M
