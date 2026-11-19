local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local S = require("sound_db")
local P = require("path_db")
local RLU = require("all.rally_utils")
require("lib.klua.table")

local SU = require("script_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")
local v = V.v
local vv = V.vv
local r = V.r

local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end

local fts = U.fts
local km = require("lib.klua.macros")
-- =====================================================================
-- 第 20 关专属装饰 / 彩蛋
-- =====================================================================
local tt

for _, def in ipairs({{1, "bandits_stage_2_mask_01", -200}, {2, "bandits_stage_2_mask_02", -1080}, {3, "bandits_stage_2_mask_03", -1080}, {4, "bandits_stage_2_mask_04", -800}, {6, "bandits_stage_2_mask_06", 150}, {7, "bandits_stage_2_mask_07", -1080}, {8, "bandits_stage_2_mask_08", 0}}) do
	tt = E:register_t("decal_stage_220_mask_" .. def[1], "decal", true)
	tt.render.sprites[1].name = def[2]
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = def[3]
end

local function stage_220_monkey_update(this, store, script)
	local clicks_count = 0
	local finished = false

	while true do
		if finished then
		-- block empty
		elseif this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			clicks_count = clicks_count + 1

			S:queue(this.sound_events["click_" .. clicks_count])
			U.y_animation_play(this, "click_" .. clicks_count, nil, store.tick_ts, 1)

			if clicks_count < 3 then
				this.ui.can_click = true

				U.animation_start(this, "baile_loop", nil, store.tick_ts, true)
			else
				U.animation_start(this, "stunned_loop", nil, store.tick_ts, true)
				U.y_wait(store, fts(30))
				U.y_animation_play(this, "click_4", nil, store.tick_ts, 1)
				U.animation_start(this, "idle_nomonkey", nil, store.tick_ts, true)
				signal.emit("easter_egg_monkey_stage_20", this)

				finished = true
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t("decal_stage_220_monkey", "decal_scripted", true)

AC(tt, "ui", "editor", "sound_events")

tt.render.sprites[1].prefix = "st_2_monkey_easter_eggDef"
tt.render.sprites[1].name = "idle_arbusto"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = stage_220_monkey_update
tt.ui.click_rect = r(-135, 230, 50, 50)
tt.sound_events.click_1 = "Stage20MonkeyEEClick1"
tt.sound_events.click_2 = "Stage20MonkeyEEClick2"
tt.sound_events.click_3 = "Stage20MonkeyEEClick3"
tt.editor.props = {{"random_wait_clickeable_min", PT_NUMBER}, {"random_wait_clickeable_max", PT_NUMBER}, {"random_wait_min", PT_NUMBER}, {"random_wait_max", PT_NUMBER}}

-- =====================================================================
-- 猎人前哨（本关专属兵营塔及其士兵/猫头鹰）
-- =====================================================================
local fx_celtic_tower_projectile_hit_floor_spawn_count = 0

local function fx_celtic_tower_projectile_hit_floor_insert(this, store, script)
	fx_celtic_tower_projectile_hit_floor_spawn_count = fx_celtic_tower_projectile_hit_floor_spawn_count + 1

	if fx_celtic_tower_projectile_hit_floor_spawn_count % 2 == 0 then
		this.pos.x = this.pos.x - 5
		this.pos.y = this.pos.y + 5
	end

	return true
end

tt = E:register_t("fx_celtic_tower_projectile_hit", "fx", true)
tt.render.sprites[1].name = "celtic_tower_projectile_hit_run"
tt = E:register_t("fx_celtic_tower_projectile_hit_floor", "decal", true)

AC(tt, "main_script")

tt.render.sprites[1].prefix = "celtic_tower_projectile_hit_floor"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = fx_celtic_tower_projectile_hit_floor_insert
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.duration = 2
tt.animation_start = "run"
tt.animation_idle = "idle"
tt.animation_end = "out"

local function celtic_tower_projectile_insert(this, store, script)
	local base = this.bullet.fixed_height
	local base_rotation_speed = this.bullet.rotation_speed

	this.bullet.fixed_height = base * (1 + (math.random() * 0.8 - 0.4))
	this.bullet.rotation_speed = base_rotation_speed * (1 + (math.random() * 0.4 - 0.2))

	if not this._is_twin then
		local twin = E:create_entity("celtic_tower_projectile")

		twin._is_twin = true
		twin.pos = V.vclone(this.pos)
		twin.bullet.from = V.vclone(this.bullet.from)
		twin.bullet.to = V.vclone(this.bullet.to)
		twin.bullet.target_id = this.bullet.target_id
		twin.bullet.source_id = this.bullet.source_id
		twin.bullet.xp_dest_id = this.bullet.xp_dest_id
		twin.bullet.level = this.bullet.level
		twin.bullet.damage_factor = this.bullet.damage_factor

		simulation:queue_insert_entity(twin)
	end

	return scripts.arrow5_fixed_height.insert(this, store, script)
end

tt = E:register_t("celtic_tower_projectile", "arrow5_fixed_height", true)
tt.main_script.insert = celtic_tower_projectile_insert
tt.render.sprites[1].name = "celtic_tower_projectile_0001"
tt.render.sprites[1].animated = false
tt.bullet.rotation_speed = 15
tt.bullet.fixed_height = 70
tt.bullet.g = -1000
tt.bullet.hide_radius = 0
tt.bullet.reset_to_target_pos = true
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = true
tt.bullet.miss_decal = "celtic_tower_projectile_hit_floor_0001"
tt.bullet.hit_fx = "fx_celtic_tower_projectile_hit"
tt.bullet.damage_min = 12
tt.bullet.damage_max = 20
tt.bullet.damage_type = DAMAGE_PHYSICAL

local HUNTER_FOREMOST_SLOT = 1

local function soldier_tower_update1_hunter_outpost_insert(this, store, script)
	local a = this.ranged.attacks[1]

	if a and this.soldier.tower_soldier_idx ~= HUNTER_FOREMOST_SLOT then
		local pick_ts = -1
		local picked_id

		function a.filter_fn(e, origin)
			if store.tick_ts ~= pick_ts then
				pick_ts = store.tick_ts

				local _, enemies = U.find_foremost_enemy(store, origin, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, nil, F_FLYING)

				if enemies and #enemies > 1 then
					picked_id = enemies[math.random(1, #enemies)].id
				else
					picked_id = nil
				end
			end

			if picked_id then
				return e.id == picked_id
			end

			return true
		end
	end

	return scripts.soldier_barrack.insert(this, store, script)
end

tt = E:register_t("soldier_tower_update1_hunter_outpost", "soldier_militia", true)
AC(tt, "powers", "nav_grid", "ranged")
tt.controable = true
tt.controable_other = true
tt.health.armor = 0
tt.health.hp_max = 150
tt.health.dead_lifetime = 12
tt.regen.health = 5
tt.health_bar.offset = v(0, 35)
tt.info.portrait = "kr6_info_portraits_soldiers_0027"
tt.info.random_name_format = "SOLDIER_STAGE_20_HUNTER_OUTPOST_%i_NAME"
tt.info.random_name_count = 9
tt.main_script.insert = soldier_tower_update1_hunter_outpost_insert
tt.main_script.update = scripts.soldier_barrack.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.range = 60
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "celtic_tower_projectile"
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].bullet_start_offset = {v(5, 29)}
tt.ranged.attacks[1].disabled = true
tt.motion.max_speed = 65
tt.render.sprites[1].prefix = "celtic_tower_hunter_lvl1"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(0.9)
tt.soldier.melee_slot_offset = v(5, 0)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 12)
tt.unit.price = 75
tt.unit.fade_time_after_death = 1
tt.sound_events.insert = nil
tt.sound_events.change_rally_point = "Stage20HuntersOutpostMove"

local CROW_FOREMOST_SLOT = 1

local function crow_tower_update1_hunter_outpost_update(this, store)
	local sd = this.render.sprites[1]
	local ss = this.render.sprites[2]
	local a = this.melee.attacks[1]
	local fm = this.force_motion
	local target, targets, dist
	local dest = V.v(this.pos.x, this.pos.y)

	this.start_ts = store.tick_ts

	local orbit_phase = 0

	this.owner = store.entities[this.soldier.tower_id]
	this._current_height = this.flight_height

	local function update_shadow_height(target_height)
		local lerp = target_height < this._current_height and this.shadow_lerp_descend or this.shadow_lerp_ascend

		this._current_height = this._current_height + (target_height - this._current_height) * lerp
		ss.offset.y = -this._current_height
	end

	local function target_in_cover(t)
		return t.nav_path and not P:is_node_valid(t.nav_path.pi, t.nav_path.ni)
	end

	local function targetable_filter(e)
		return not target_in_cover(e)
	end

	fm.a_step = fm.a_step + math.random(-3, 3)
	this.tween.ts = U.frandom(0, 1)

	local oos = {V.v(-20, 0), V.v(20, 7)}
	local oo = table.random(oos)

	this.tween.ts = store.tick_ts

	S:queue(this.sound_events.spawn)
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start(this, "idle", true, store.tick_ts, true)

	while true do
		target, targets = U.find_foremost_enemy(store, this.owner.pos, 0, this.target_range, 0, a.vis_flags, a.vis_bans, targetable_filter)

		if target and targets and #targets > 1 and this.soldier.tower_soldier_idx ~= CROW_FOREMOST_SLOT then
			target = targets[math.random(1, #targets)]
		end

		if target and store.tick_ts - this.start_ts > 0.7 then
			this.owner.raise_arms = true

			::label_1835_0::

			local chase_dest_x = target.pos.x + oo.x + target.unit.hit_offset.x
			local chase_dest_y = target.pos.y + oo.y + target.unit.hit_offset.y
			local initial_dist = V.dist(this.pos.x, this.pos.y, chase_dest_x, chase_dest_y)

			repeat
				if not target_in_cover(target) then
					dest.x, dest.y = target.pos.x + oo.x + target.unit.hit_offset.x, target.pos.y + oo.y + target.unit.hit_offset.y
				end

				sd.flip_x = dest.x < this.pos.x

				U.force_motion_step(this, store.tick_length, dest)
				coroutine.yield()

				dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)

				local t = math.max(0, math.min(1, 1 - dist / math.max(initial_dist, 1)))
				local target_height = this.flight_height + (this.attack_height - this.flight_height) * t

				update_shadow_height(target_height)
			until dist < a.range or target.health.dead or band(a.vis_flags, target.vis.bans) ~= 0 or not store.entities[target.id] or target_in_cover(target) or V.dist2(this.owner.pos.x, this.owner.pos.y, target.pos.x, target.pos.y) > this.chase_range * this.chase_range

			if dist < a.range and store.entities[target.id] and not target.health.dead and band(a.vis_flags, target.vis.bans) == 0 and not target_in_cover(target) then
				if math.random() < a.sound_chance then
					S:queue(a.sound)
				end

				local an, af = U.animation_name_facing_point(this, a.animation, target.pos, 1)

				U.animation_start(this, an, af, store.tick_ts, false)
				U.y_wait(store, a.hit_time)

				local d = SU.create_attack_damage(a, target.id, this)

				store.damage_queue[#store.damage_queue + 1] = d

				if a.hit_fx then
					local fx = E:create_entity(a.hit_fx)

					fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].runs = 0

					simulation:queue_insert_entity(fx)
				end

				while not U.animation_finished(this) do
					U.force_motion_step(this, store.tick_length, dest)

					sd.flip_x = this.pos.x > target.pos.x

					update_shadow_height(this.attack_height)
					coroutine.yield()
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)
				U.y_wait(store, a.cooldown)

				local dx, dy = V.sub(target.pos.x, target.pos.y, this.owner.pos.x, this.owner.pos.y)
				local dist2 = V.len2(dx, dy)

				attack_ts = store.tick_ts

				if not target.health.dead and dist2 < this.chase_range * this.chase_range then
					goto label_1835_0
				end
			else
				while V.dist(this.pos.x, this.pos.y, dest.x, dest.y) >= a.range do
					U.force_motion_step(this, store.tick_length, dest)

					sd.flip_x = dest.x < this.pos.x

					update_shadow_height(this.attack_height)
					coroutine.yield()
				end

				local new_target = U.find_nearest_enemy(store, this.pos, 0, this.chase_range, a.vis_flags, a.vis_bans, targetable_filter)

				if new_target then
					target = new_target

					goto label_1835_0
				end

				this.owner.raise_arms = false
			end
		end

		update_shadow_height(this.flight_height)

		orbit_phase = orbit_phase + this.orbit_speed * store.tick_length

		local a2 = (math.pi + orbit_phase) % (2 * math.pi)
		local orb_center = V.vclone(this.owner.pos)

		orb_center.y = orb_center.y + this.flight_height
		dest = U.point_on_ellipse(orb_center, this.orbit_radius, a2)
		this.render.sprites[1].flip_x = dest.x < this.pos.x

		U.force_motion_step(this, store.tick_length, dest)

		this.owner.raise_arms = false
		this.owner.crows_idle = true

		coroutine.yield()
	end
end

tt = E:register_t("crow_tower_update1_hunter_outpost", "decal_scripted")
AC(tt, "force_motion", "melee", "tween", "unit", "soldier", "sound_events")
tt.main_script.update = crow_tower_update1_hunter_outpost_update
tt.sound_events.spawn = "TowerHunterOutpostOwlSummon"
tt.unit.price = 25
tt.flight_height = 60
tt.attack_height = 15
tt.shadow_lerp_descend = 0.1
tt.shadow_lerp_ascend = 0.04
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 180
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.05
tt.force_motion.a_step = 20
tt.start_ts = nil
tt.render.sprites[1].prefix = "celtic_tower_owl"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "celtic_tower_owl_shadow"
tt.render.sprites[2].offset = v(0, -tt.flight_height)
tt.render.sprites[2].scale = vv(1)
tt.melee.attacks[1] = E:clone_c("bullet_attack")
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].range = 10
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].search_cooldown = 0.1
tt.melee.attacks[1].sound_chance = 0.5
tt.melee.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].hit_fx = "fx_celtic_tower_projectile_hit"
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, v(0, 0)}, {0.5, v(0, 3)}, {1, v(0, 0)}, {1.5, v(0, -3)}, {2, v(0, 0)}}
tt.tween.props[1].loop = true
tt.orbit_radius = 30
tt.orbit_speed = 3 * FPS * math.pi / 180
tt.target_range = 450
tt.chase_range = 450

local function tower_update1_hunter_outpost_insert(this, store, script)
	if this.render.sprites[1].flip_x == true then
		this.barrack.respawn_offset.x = this.barrack.respawn_offset.x * -1
	end

	return scripts.tower_barrack.insert(this, store, script)
end

local function tower_update1_hunter_outpost_update(this, store, script)
	local b = this.barrack
	local door_sid = this.render.door_sid or 3

	if not this.tower_upgrade_persistent_data.spawns_count then
		this.tower_upgrade_persistent_data.spawns_count = {
			[this.crow_template] = 0,
			[this.soldier_template] = 0
		}
	end

	local formation_offset = 0

	local function open_door()
		if b.has_door and not b.door_open then
			U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = true
			b.door_open_ts = store.tick_ts
		end
	end

	local function apply_ranged_enabled(s)
		if this.tower_upgrade_persistent_data.ranged_enabled and s.ranged and s.ranged.attacks[1] then
			s.ranged.attacks[1].disabled = false
			s.render.sprites[1].prefix = "celtic_tower_hunter_lvl2"
		end
	end

	local function refresh_rally_positions()
		for i, ss in ipairs(b.soldiers) do
			if ss.nav_rally then
				ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(i, b, this.barrack.max_soldiers, formation_offset)
			end
		end
	end

	local function spawn_soldier(template, slot_idx)
		this.tower_upgrade_persistent_data.spawns_count[template] = this.tower_upgrade_persistent_data.spawns_count[template] + 1

		open_door()

		local s = E:create_entity(template)

		s.soldier.tower_id = this.id

		if slot_idx then
			s.soldier.tower_soldier_idx = slot_idx
		end

		s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))

		if s.nav_rally then
			s.nav_rally.new = true
		end

		s.mercenary_spawn_number = this.tower_upgrade_persistent_data.spawns_count[template]

		if this.spawn_waypoint_offset and s.motion then
			s.motion.forced_waypoint = v(this.pos.x + this.spawn_waypoint_offset.x, this.pos.y + this.spawn_waypoint_offset.y)
		end

		apply_ranged_enabled(s)
		simulation:queue_insert_entity(s)
		signal.emit("tower-spawn", this, s)

		return s
	end

	local function find_free_crow_slot()
		local used = {}

		for _, s in ipairs(b.soldiers) do
			if s.template_name == this.crow_template and store.entities[s.id] and s.soldier and s.soldier.tower_soldier_idx then
				used[s.soldier.tower_soldier_idx] = true
			end
		end

		local max = b.max_soldiers_by_type[this.crow_template] or 1

		for i = 1, max do
			if not used[i] then
				return i
			end
		end

		return 1
	end

	local function spawn_owl()
		local s = spawn_soldier(this.crow_template, find_free_crow_slot())

		table.insert(b.soldiers, s)
		refresh_rally_positions()
	end

	local function apply_ranged()
		this.tower_upgrade_persistent_data.ranged_enabled = true

		for _, s in pairs(b.soldiers) do
			apply_ranged_enabled(s)
		end

		if this.repair.sound then
			S:queue(this.repair.sound)
		end
	end

	while true do
		local old_count = #b.soldiers
		local cleaned = {}

		for i, s in ipairs(b.soldiers) do
			if i <= b.max_soldiers or store.entities[s.id] then
				cleaned[#cleaned + 1] = s
			end
		end

		b.soldiers = cleaned

		if #b.soldiers ~= old_count then
			refresh_rally_positions()
		end

		if not this.tower.blocked then
			for i = 1, b.max_soldiers do
				local slot = b.soldiers[i]

				if not slot or slot.health.dead and not store.entities[slot.id] then
					local s = spawn_soldier(this.soldier_template, i)

					if s.nav_rally then
						s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, formation_offset)
					end

					b.soldiers[i] = s
				end
			end
		end

		local owls_have = 0

		for _, s in ipairs(b.soldiers) do
			if s.template_name == this.crow_template and store.entities[s.id] then
				owls_have = owls_have + 1
			end
		end

		while owls_have < this.powers.owls.level do
			spawn_owl()

			owls_have = owls_have + 1
		end

		if this.powers.ranged.level >= 1 and not this.tower_upgrade_persistent_data.ranged_enabled then
			apply_ranged()
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
			U.y_animation_wait(this, door_sid)

			b.door_open = false
		end

		coroutine.yield()
	end
end

tt = E:register_t("tower_update1_hunter_outpost", "tower", true)
AC(tt, "vis", "barrack", "user_selection", "powers")
tt.tower.disable_spend_highlight = true
tt.tower.type = "update_1_hunter_outpost"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = false
tt.tower.terrain_style = TERRAIN_STYLE_KR6_TERRAIN_1_1
tt.info.portrait = "kr6_info_portraits_towers_0028"
tt.info.i18n_key = "TOWER_UPDATE1_HUNTER_OUTPOST"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.insert = tower_update1_hunter_outpost_insert
tt.main_script.update = tower_update1_hunter_outpost_update
tt.main_script.remove = scripts.tower_barrack.remove
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "celtic_tower_house_shadow"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "celtic_tower_door"
tt.render.sprites[2].name = "close"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -8
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "celtic_tower_house"
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].sort_y_offset = -8
tt.render.door_sid = 2
tt.barrack.soldier_type = "soldier_tower_update1_hunter_outpost"
tt.barrack.max_soldiers = 3
tt.barrack.rally_range = 209.28
tt.barrack.respawn_offset = v(0, 5)
tt.barrack.has_door = true
tt.barrack.door_hold_time = 0.6
tt.barrack.rally_fn = RLU.rally_fn_default
tt.sound_events.change_rally_point = "Stage20HuntersOutpostMove"
tt.crow_template = "crow_tower_update1_hunter_outpost"
tt.soldier_template = "soldier_tower_update1_hunter_outpost"
tt.barrack.max_soldiers_by_type = {
	[tt.crow_template] = 3
}
tt.user_selection.ignore_point = true
tt.user_selection.allowed = true
tt.powers.owls = E:clone_c("power")
tt.powers.owls.price_base = 100
tt.powers.owls.price_inc = 50
tt.powers.owls.max_level = 3
tt.powers.owls.enc_icon = 1
tt.powers.ranged = E:clone_c("power")
tt.powers.ranged.price_base = 150
tt.powers.ranged.price_inc = 0
tt.powers.ranged.max_level = 1
tt.powers.ranged.enc_icon = 1
tt.repair = {}
