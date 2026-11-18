local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local S = require("sound_db")
local SU = require("script_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")
local v = V.v
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local fts = U.fts
local km = require("lib.klua.macros")

-- =====================================================================
-- 过场：被绑架的公主三人组
-- =====================================================================

local function bandit_princess_blackguard_update(this, store, script)
	if this.emoji_start_delay and this.emoji_start_delay > 0 then
		U.y_wait(store, this.emoji_start_delay)
	end

	this.render.sprites[2].hidden = false

	U.y_animation_play(this, "bandit_princess_emoji_in", nil, store.tick_ts, 1, 2)
	U.animation_start(this, "bandit_princess_emoji_run", nil, store.tick_ts, true, 2)
	U.y_wait(store, this.emoji_run_duration or 0)
	U.y_animation_play(this, "bandit_princess_emoji_out", nil, store.tick_ts, 1, 2)

	this.render.sprites[2].hidden = true
end

local tt = E:register_t("bandit_princess_trickster", "fx", true)
AC(tt, "editor")
tt.render.sprites[1].name = "bandit_princess_trickster_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.runs = INT_32_MAX

tt = E:register_t("bandit_princess_bandit", "fx", true)
AC(tt, "editor")
tt.render.sprites[1].name = "bandit_princess_bandit_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.runs = INT_32_MAX

tt = E:register_t("bandit_princess_blackguard", "fx", true)
AC(tt, "main_script", "editor")
tt.render.sprites[1].name = "bandit_princess_blackguard_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bandit_princess_emoji_run"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].hidden = true
tt.timed.runs = INT_32_MAX
tt.emoji_start_delay = 0
tt.emoji_run_duration = 3
tt.main_script.update = bandit_princess_blackguard_update

-- =====================================================================
-- 静态遮罩 / 水面 / 猫头鹰彩蛋
-- =====================================================================

for i = 1, 5 do
	tt = E:register_t("decal_stage_219_mask_" .. i, "decal", true)
	tt.render.sprites[1].name = string.format("bandits_stage_mask_%02d", i)
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = ({200, 110, 0, 300, -115})[i]
end

tt = E:register_t("stage_219_water_1", "decal", true)
tt.render.sprites[1].prefix = "stage_1_water_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t("stage_219_water_2", "decal", true)
tt.render.sprites[1].prefix = "stage_1_water_2Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

local function decal_stage_219_owl_update(this, store, script)
	local taps_count = 0

	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			taps_count = taps_count + 1

			S:queue(this.sound_events["click_" .. taps_count])
			U.y_animation_play(this, "click_" .. taps_count, nil, store.tick_ts, 1)

			if taps_count == 3 then
				U.animation_start(this, "idle_2", nil, store.tick_ts, true)
				signal.emit("easter_egg_owl_stage_19", this)

				break
			else
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t("decal_stage_219_owl", "decal_scripted", true)
AC(tt, "ui", "editor", "sound_events")
tt.render.sprites[1].prefix = "easter_egg_owl_stage_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.main_script.update = decal_stage_219_owl_update
tt.ui.click_rect = r(385, -174, 50, 50)
tt.sound_events.click_1 = "Stage19OwlEEClick1"
tt.sound_events.click_2 = "Stage19OwlEEClick2"
tt.sound_events.click_3 = "Stage19OwlEEClick3"

-- =====================================================================
-- 黑骑士爵士（Sir Noyt）特殊兵营塔 / 士兵
-- =====================================================================

local function black_knight_tower_get_info(this)
	local s = E:create_entity(this.barrack.soldier_type)
	local info = s.info.fn(s)
	info.type = STATS_TYPE_TOWER_BARRACK

	return info
end

local function tower_barracks_stage_219_insert(this, store, script)
	scripts.tower_barrack.insert(this, store)

	local b = this.barrack
	local i = 1
	local s = E:create_entity(b.soldier_type)

	s.soldier.tower_id = this.id
	s.soldier.tower_soldier_idx = i
	s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
	s.pos = V.vclone(s.nav_rally.pos)
	s.nav_rally.new = false

	local cinematic = store.level_mode == GAME_MODE_CAMPAIGN and not store.restarted and not main.params.skip_cutscenes

	if cinematic then
		s.render.sprites[1].name = "stun_idle"
	else
		s.render.sprites[1].name = "idle"
	end

	simulation:queue_insert_entity(s)

	b.soldiers[i] = s

	signal.emit("tower-spawn", this, s)

	return true
end

local function tower_barracks_stage_219_update(this, store, script)
	local function apply_aoe(s)
		local lvl = this.powers.aoe.level

		if lvl >= 1 and s.melee and s.melee.attacks[2] then
			s.melee.attacks[2].disabled = false
			s.melee.attacks[2].damage_min = this.aoe_damage_min[lvl]
			s.melee.attacks[2].damage_max = this.aoe_damage_max[lvl]
		end
	end

	local function apply_ricochet(s)
		local lvl = this.powers.ricochet.level

		if lvl >= 1 and s.ranged and s.ranged.attacks[1] then
			s.ranged.attacks[1].disabled = false
			s.ranged.attacks[1].level = lvl
		end
	end

	while true do
		local b = this.barrack

		for _, s in ipairs(b.soldiers) do
			apply_aoe(s)
			apply_ricochet(s)
		end

		if not this.tower.blocked then
			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]
				local first_spawn = not s
				local respawn_after_death = s and s.health.dead and not store.entities[s.id]

				if first_spawn or respawn_after_death then
					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
					s.pos = V.vclone(s.nav_rally.pos)
					s.nav_rally.new = false

					if first_spawn then
						local cinematic = store.level_mode == GAME_MODE_CAMPAIGN and not store.restarted and not main.params.skip_cutscenes

						if cinematic then
							s.render.sprites[1].name = "stun_idle"
						end
					end

					apply_aoe(s)
					apply_ricochet(s)
					simulation:queue_insert_entity(s)

					b.soldiers[i] = s

					signal.emit("tower-spawn", this, s)
				end
			end
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
				s.nav_rally.new = true
				all_dead = all_dead and s.health.dead
			end

			if not all_dead and this.sound_events.change_rally_point then
				S:queue(this.sound_events.change_rally_point)
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t("tower_barracks_stage_219", "tower", true)
AC(tt, "barrack", "user_selection", "powers")
tt.tower.type = "barracks_stage_19"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.render.sprites[1].animated = false
-- 马车本体由关卡背景绘制，隐藏通用塔位底图，避免与背景重叠
tt.render.sprites[1].hidden = true
tt.info.fn = black_knight_tower_get_info
tt.info.i18n_key = "TOWER_BARRACKS_STAGE_19"
tt.info.portrait = "kr6_info_portraits_towers_0030"
tt.main_script.insert = tower_barracks_stage_219_insert
tt.main_script.update = tower_barracks_stage_219_update
tt.main_script.remove = scripts.tower_barrack.remove
tt.barrack.soldier_type = "soldier_black_knight_barracks_stage_219"
tt.barrack.rally_range = 150
tt.barrack.respawn_offset = v(0, 10)
tt.barrack.max_soldiers = 1
tt.barrack.has_door = false
tt.sound_events.change_rally_point = "Stage19SirNoytMove"
tt.ui.click_rect = r(-50, -50, 100, 100)
tt.vis.bans = F_ALL
tt.user_selection.ignore_point = true
tt.user_selection.allowed = true
tt.powers.aoe = E:clone_c("power")
tt.powers.aoe.price_base = 100
tt.powers.aoe.price_inc = 150
tt.powers.aoe.max_level = 3
tt.powers.aoe.enc_icon = 1
tt.powers.ricochet = E:clone_c("power")
tt.powers.ricochet.price_base = 75
tt.powers.ricochet.price_inc = 100
tt.powers.ricochet.max_level = 3
tt.powers.ricochet.enc_icon = 1
tt.aoe_damage_min = {50, 70, 150}
tt.aoe_damage_max = {60, 90, 190}

local function soldier_black_knight_update(this, store, script)
	local function in_stun_pose()
		local n = this.render.sprites[1].name

		return n == "stun_idle" or n == "stun_end"
	end

	if in_stun_pose() then
		this.health_bar.hidden = true

		while in_stun_pose() and not this.health.dead do
			coroutine.yield()
		end

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	return scripts.soldier_barrack.update(this, store, script)
end

tt = E:register_t("soldier_black_knight_barracks_stage_219", "soldier_militia", true)
AC(tt, "nav_grid", "ranged")
tt.info.portrait = "kr6_info_portraits_soldiers_0021"
tt.regen.cooldown = 1
tt.regen.health = 15
tt.health.armor = 0.75
tt.health.hp_max = 320
tt.health.hp = 320
tt.health.dead_lifetime = 30
tt.health_bar.offset = v(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "SOLDIER_STAGE_19_BLACK_KNIGHT"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = soldier_black_knight_update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.sound_events.death = "Stage19SirNoytDeath"
tt.melee.attacks[1].cooldown = 1.4
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].damage_max = 28
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].hit_fx = "fx_stage_219_black_knight_hit"
tt.melee.attacks[1].hit_offset = v(34, 8)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].fn_can = function(this, store, a, target)
	if math.random() < 0.5 then
		a.animation = "attack_1"
		a.hit_time = fts(9)
	else
		a.animation = "attack_2"
		a.hit_time = fts(12)
	end

	return true
end
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].animation = "attack_area"
tt.melee.attacks[2].cooldown = 1.4
tt.melee.attacks[2].hit_time = fts(61)
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].damage_min = 50
tt.melee.attacks[2].damage_max = 60
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].damage_radius = 50
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].vis_flags = F_AREA
tt.melee.attacks[2].damage_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].hit_decal = "decal_stage_219_castle_warrior_area_decal"
tt.melee.attacks[2].hit_offset = v(34, 4)
tt.melee.attacks[2].sound = "Stage19SirNoytZhornhauCast"
tt.melee.attacks[2].sound_args = {
	delay = fts(14)
}
tt.melee.attacks[2].sound_hit = "Stage19SirNoytZhornhauImpact"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].disabled = true
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].bullet = "bullet_soldier_black_knight_stage_219"
tt.ranged.attacks[1].cooldown = 7
tt.ranged.attacks[1].min_range = 80
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].animation = "attack_attack"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 20)}
tt.ranged.attacks[1].node_prediction = fts(17)
tt.ranged.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.range = 70
tt.motion.max_speed = 45
tt.render.sprites[1].prefix = "castle_warrior_unit"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset.x = 8
tt.unit.hit_offset = v(0, 17)
tt.unit.mod_offset = v(0, 15)
tt.vis.bans = 0
tt.vis.flags = F_FRIEND

-- =====================================================================
-- 黑骑士的盾牌投掷 / 弹射 / 特效
-- =====================================================================

local function bullet_black_knight_insert(this, store, script)
	if scripts.bolt.insert(this, store, script) then
		U.animation_start(this, "idle", nil, store.tick_ts, true)

		return true
	else
		return false
	end
end

local function bullet_black_knight_update(this, store, script)
	local b = this.bullet
	local s = this.render.sprites[1]
	local mspeed = b.min_speed
	local target, ps
	local new_target = false
	local target_invalid = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	if b.in_anim then
		U.y_animation_play(this, b.in_anim, nil, store.tick_ts, 1, 1)
	end

	::label_1694_0::

	S:queue(this.sound_events.travel)

	s.z = Z_BULLETS
	s.sort_y_offset = nil

	U.animation_start(this, "idle", nil, store.tick_ts, s.loop)

	if ps then
		ps.particle_system.emit = true
	end

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length * mspeed * store.tick_length do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target and not new_target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		if target and target.health and not target.health.dead then
			if b.ignore_hit_offset then
				b.to.x, b.to.y = target.pos.x, target.pos.y
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end

			new_target = false
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if not b.ignore_rotation then
			s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end

		if ps then
			ps.particle_system.emit_direction = s.r
		end
	end

	while b.store and not b.target_id do
		coroutine.yield()

		if b.target_id then
			mspeed = b.min_speed
			new_target = true

			goto label_1694_0
		end
	end

	this.pos.x, this.pos.y = b.to.x, b.to.y

	local hit = target and not target.health.dead

	if hit then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		U.queue_damage(store, d)
		S:queue(this.sound_hit)

		if b.mod or b.mods then
			local mods = b.mods or {b.mod}

			for _, mod_name in pairs(mods) do
				local mod = E:create_entity(mod_name)

				mod.modifier.source_id = this.id
				mod.modifier.target_id = target.id
				mod.modifier.level = b.level
				mod.modifier.source_damage = d

				simulation:queue_insert_entity(mod)
			end
		end
	end

	if b.payload then
		local p = E:create_entity(b.payload)

		p.pos.x, p.pos.y = b.to.x, b.to.y
		p.target_id = b.target_id
		p.source_id = this.id
		p.missed = not hit

		if p.aura then
			p.aura.level = b.level
		end

		if b.level and p.max_bounces and this.ricochet_max_bounces then
			p.max_bounces = this.ricochet_max_bounces[b.level] or p.max_bounces
		end

		simulation:queue_insert_entity(p)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].r = s.r

		simulation:queue_insert_entity(sfx)
	end

	simulation:queue_remove_entity(this)
end

local function bullet_black_knight_bounce_insert(this, store)
	local b = this.bullet
	local targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
		return v.id ~= this.target_id
	end)

	if not targets or #targets == 0 or this.missed then
		return false
	end

	table.sort(targets, function(e1, e2)
		return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) < V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
	end)

	local target = targets[1]

	b.from = V.vclone(this.pos)
	b.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
	b.target_id = target.id
	b.damage_min = math.max(1, math.floor(b.damage_min * this.bounce_damage_mult))
	b.damage_max = math.max(1, math.floor(b.damage_max * this.bounce_damage_mult))

	return true
end

local function bullet_black_knight_bounce_update(this, store)
	local b = this.bullet
	local target, ps

	this.bounces = 0
	local already_hit = {this.target_id}
	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	::label_635_0::

	while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > b.fixed_speed * store.tick_length * (b.fixed_speed * store.tick_length) do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		b.speed.x, b.speed.y = V.mul(b.fixed_speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

		if not b.ignore_rotation then
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		U.queue_damage(store, SU.create_bullet_damage(b, target.id, this.id))
		table.insert(already_hit, target.id)
		S:queue(this.sound_hit)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if this.sound_events.hit then
		S:queue(this.sound_events.hit)
	end

	this.bounces = this.bounces + 1

	if this.bounces < this.max_bounces then
		local targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(v)
			return not table.contains(already_hit, v.id)
		end)

		if targets and #targets > 0 then
			table.sort(targets, function(e1, e2)
				return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) < V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
			end)

			local t = targets[1]

			b.to.x, b.to.y = t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y
			b.target_id = t.id
			b.damage_min = math.max(1, math.floor(b.damage_min * this.bounce_damage_mult))
			b.damage_max = math.max(1, math.floor(b.damage_max * this.bounce_damage_mult))

			goto label_635_0
		end
	end

	simulation:queue_remove_entity(this)
end

tt = E:register_t("bullet_soldier_black_knight_stage_219", "bolt", true)
tt.bullet.damage_min = 40
tt.bullet.damage_max = 80
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.ignore_rotation = true
tt.bullet.use_unit_damage_factor = true
tt.bullet.acceleration_factor = 0.2
tt.bullet.min_speed = 500
tt.bullet.max_speed = 500
tt.bullet.hit_fx = "fx_bullet_black_knight_shield_hit"
tt.bullet.particles_name = "ps_bullet_black_knight_shield_trail"
tt.bullet.pop = {"pop_zap"}
tt.bullet.pop_conds = DR_KILL
tt.bullet.payload = "bullet_soldier_black_knight_stage_219_bounce_clone"
tt.ricochet_max_bounces = {1, 2, 4}
tt.render.sprites[1].prefix = "castle_warrior_shield_projectile"
tt.render.sprites[1].name = "idle"
tt.main_script.insert = bullet_black_knight_insert
tt.main_script.update = bullet_black_knight_update
tt.sound_events.insert = "Stage19SirNoytRicochetShieldCast"
tt.sound_hit = "Stage19SirNoytRicochetShieldBounce"

tt = E:register_t("bullet_soldier_black_knight_stage_219_bounce_clone", "bullet", true)
tt.bullet.damage_min = 40
tt.bullet.damage_max = 80
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.g = 0
tt.bullet.fixed_speed = FPS * 15
tt.bullet.hide_radius = 0
tt.bullet.ignore_rotation = true
tt.bullet.hit_fx = "fx_bullet_black_knight_shield_hit"
tt.bullet.particles_name = "ps_bullet_black_knight_shield_trail"
tt.render.sprites[1].prefix = "castle_warrior_shield_projectile"
tt.render.sprites[1].name = "idle"
tt.main_script.insert = bullet_black_knight_bounce_insert
tt.main_script.update = bullet_black_knight_bounce_update
tt.sound_hit = "Stage19SirNoytRicochetShieldBounce"
tt.bounces = 0
tt.max_bounces = 1
tt.bounce_range = 100
tt.bounce_damage_mult = 1.1

tt = E:register_t("fx_stage_219_black_knight_hit", "fx", true)
tt.render.sprites[1].prefix = "castle_warrior_hit"
tt.render.sprites[1].name = "run"

tt = E:register_t("decal_stage_219_castle_warrior_area_decal", "decal_timed", true)
tt.render.sprites[1].name = "castle_warrior_area_decal_run"
tt.render.sprites[1].animated = true
tt.timed.runs = 1

tt = E:register_t("fx_bullet_black_knight_shield_hit", "fx", true)
tt.render.sprites[1].prefix = "castle_warrior_shield_projectile_hit"
tt.render.sprites[1].name = "run"

tt = E:register_t("ps_bullet_black_knight_shield_trail", "particle_system", true)
AC(tt, "main_script")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.name = "castle_warrior_shield_projectile_trail_idle"
tt.particle_system.particle_lifetime = {fts(5), fts(5)}
tt.particle_system.emission_rate = 60
tt.particle_system.alphas = {255, 0}
