local E = require("entity_db")
local U = require("utils")
local SU = require("script_utils")
local V = require("lib.klua.vector")
local GR = require("grid_db")
local S = require("sound_db")
local EL = require("kr1.data.endless")
local Common = require("kr1.endless.tech_handlers.common")
local bit = require("bit")
local band = bit.band

local function fts(t)
	return t / FPS
end

local function fireball_quick_up(this, store, ctx)
	store.game_gui.power_1:wait_time_dec(ctx.friend_buff.engineer_fireball * store.endless.upgrade_levels.engineer_fireball / FPS)
	return true
end

local function engineer_focus_bomb_update(this, store)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end

		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end

		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end

	if b.particles_name then
		local ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		Common.queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius * b.hide_radius or V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius * b.hide_radius
		end
	end

	local enemies = U.find_enemies_in_range_filter_off(b.to, dradius, b.damage_flags, b.damage_bans)

	if enemies then
		for i = 1, #enemies do
			local enemy = enemies[i]
			local d = E:create_entity("damage")

			d.damage_type = b.damage_type
			d.reduce_armor = b.reduce_armor
			d.reduce_magic_armor = b.reduce_magic_armor

			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)
			d.value = dmax + (dmax - (dmax - dmin) * dist_factor) * (store.endless.upgrade_levels.engineer_focus * EL.friend_buff.engineer_focus)
			d.value = b.damage_factor * d.value
			d.source_id = this.id
			d.target_id = enemy.id

			Common.queue_damage(store, d)

			local mods
			if b.mod then
				mods = type(b.mod) == "string" and {b.mod} or b.mod
			elseif b.mods then
				mods = b.mods
			end

			if mods then
				for _, mod_name in pairs(mods) do
					local mod = E:create_entity(mod_name)
					mod.modifier.damage_factor = b.damage_factor
					mod.modifier.target_id = enemy.id
					mod.modifier.source_id = this.id

					if U.flags_pass(enemy.vis, mod.modifier) then
						Common.queue_insert(store, mod)
					end
				end
			end
		end
	end

	local p = SU.create_bullet_pop(store, this)
	Common.queue_insert(store, p)

	local cell_type = GR:cell_type(b.to.x, b.to.y)
	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)
		local water_fx = E:create_entity(b.hit_fx_water)
		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		Common.queue_insert(store, water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)
		local sfx = E:create_entity(b.hit_fx)
		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		Common.queue_insert(store, sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)
		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts
		Common.queue_insert(store, decal)
	end

	if b.hit_payload then
		local hp = type(b.hit_payload) == "string" and E:create_entity(b.hit_payload) or b.hit_payload
		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		Common.queue_insert(store, hp)
	end

	Common.queue_remove(store, this)
end

local function patch_engineer_seek(level, ctx)
	local function clear_flying_bans(attack)
		attack.vis_bans = U.flag_clear(attack.vis_bans, F_FLYING)
	end

	local t = E:get_template("tower_engineer_1")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("tower_engineer_2")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("tower_engineer_3")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("tower_bfg")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("soldier_mecha")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("tower_druid")
	clear_flying_bans(t.attacks.list[1])
	t = E:get_template("tower_entwood")
	clear_flying_bans(t.attacks.list[1])
	clear_flying_bans(t.attacks.list[2])
	t = E:get_template("tower_tricannon_lvl4")
	clear_flying_bans(t.attacks.list[1])
	clear_flying_bans(t.attacks.list[2])
	t = E:get_template("soldier_mecha")
	clear_flying_bans(t.attacks.list[1])

	t = E:get_template("tower_tesla")
	t.attacks.range = t.attacks.range * (1 + level * ctx.friend_buff.engineer_seek)
	t = E:get_template("tower_frankenstein")
	t.attacks.range = t.attacks.range * (1 + level * ctx.friend_buff.engineer_seek)
	t = E:get_template("tower_dwaarp")
	t.attacks.range = t.attacks.range * (1 + level * ctx.friend_buff.engineer_seek)
	t = E:get_template("tower_flamespitter_lvl4")
	t.attacks.range = t.attacks.range * (1 + level * ctx.friend_buff.engineer_seek)
end

local function patch_engineer_seek_runtime(level, store, endless, ctx)
	patch_engineer_seek(level, ctx)

	for _, t in pairs(store.towers) do
		if table.contains({"tower_engineer_1", "tower_engineer_2", "tower_engineer_3", "tower_bfg", "tower_druid", "tower_entwood", "tower_tricannon_lvl4"}, t.template_name) then
			t.attacks.list[1].vis_bans = U.flag_clear(t.attacks.list[1].vis_bans, F_FLYING)
		end

		if t.template_name == "tower_entwood" or t.template_name == "tower_tricannon_lvl4" then
			t.attacks.list[2].vis_bans = U.flag_clear(t.attacks.list[2].vis_bans, F_FLYING)
		elseif t.template_name == "tower_tesla" then
			t.attacks.range = t.attacks.range * (1 + ctx.friend_buff.engineer_seek)
		elseif t.template_name == "tower_frankenstein" then
			t.attacks.range = t.attacks.range * (1 + ctx.friend_buff.engineer_seek)
		elseif t.template_name == "tower_dwaarp" then
			t.attacks.range = t.attacks.range * (1 + ctx.friend_buff.engineer_seek)
		elseif t.template_name == "tower_mech" then
			for _, s in pairs(t.barrack.soldiers) do
				s.attacks.list[1].vis_bans = U.flag_clear(s.attacks.list[1].vis_bans, F_FLYING)
			end
		elseif t.template_name == "tower_flamespitter_lvl4" then
			t.attacks.range = t.attacks.range * (1 + ctx.friend_buff.engineer_seek)
		end
	end
end

local bombs = {
	"bomb",
	"bomb_dynamite",
	"bomb_black",
	"bomb_musketeer",
	"dwarf_barrel",
	"pirate_watchtower_bomb",
	"bomb_molotov",
	"bomb_molotov_big",
	"bomb_bfg",
	"bomb_bfg_fragment",
	"bomb_mecha",
	"tower_tricannon_bomb",
	"tower_tricannon_bomb_bombardment_bomb",
	"rock_druid",
	"rock_entwood",
	"rock_druid",
	"bullet_tower_demon_pit_basic_attack_lvl4",
	"bullet_tower_flamespitter_skill_bomb"
}

local function patch_engineer_focus(level, ctx)
	for _, name in pairs(bombs) do
		local b = E:get_template(name)

		if not b._endless_engineer_focus then
			if name == "rock_druid" then
				b.main_script.update = function(this, store)
					local bullet = this.bullet

					this.render.sprites[1].z = Z_OBJECTS
					S:queue(this.sound_events.load, {
						delay = fts(4)
					})
					U.y_animation_play(this, "load", nil, store.tick_ts)
					U.y_animation_play(this, "travel", nil, store.tick_ts)
					this.tween.disabled = false

					while not bullet.target_id do
						coroutine.yield()
					end

					local fx = E:create_entity("fx_rock_druid_launch")
					fx.pos.x, fx.pos.y = bullet.from.x, bullet.from.y
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].flip_x = bullet.to.x < fx.pos.x
					Common.queue_insert(store, fx)

					this.render.sprites[1].sort_y_offset = nil
					this.render.sprites[1].z = Z_BULLETS
					this.tween.disabled = true
					bullet.speed = SU.initial_parabola_speed(bullet.from, bullet.to, bullet.flight_time, bullet.g)
					bullet.ts = store.tick_ts
					bullet.last_pos = V.vclone(bullet.from)
					bullet.rotation_speed = bullet.rotation_speed * (bullet.to.x > bullet.from.x and -1 or 1)

					engineer_focus_bomb_update(this, store)
				end
			else
				b.main_script.update = engineer_focus_bomb_update
			end

			b._endless_engineer_focus = true
		end
	end

	local tower = E:get_template("tower_tesla")
	tower.tower.damage_factor = tower.tower.damage_factor + level * ctx.friend_buff.engineer_focus * 0.8
	tower = E:get_template("tower_dwaarp")
	tower.tower.damage_factor = tower.tower.damage_factor + level * ctx.friend_buff.engineer_focus * 0.8
	tower = E:get_template("tower_frankenstein")
	tower.tower.damage_factor = tower.tower.damage_factor + level * ctx.friend_buff.engineer_focus * 0.8
	tower = E:get_template("tower_flamespitter_lvl4")
	tower.tower.damage_factor = tower.tower.damage_factor + level * ctx.friend_buff.engineer_focus * 0.8

	local missile = E:get_template("missile_bfg")
	if not missile.bullet._engineer_focus_damage_min then
		missile.bullet._engineer_focus_damage_min = missile.bullet.damage_min
		missile.bullet._engineer_focus_damage_max = missile.bullet.damage_max
	end
	missile.bullet.damage_min = missile.bullet._engineer_focus_damage_min * (1 + 0.8 * ctx.friend_buff.engineer_focus * level)
	missile.bullet.damage_max = missile.bullet._engineer_focus_damage_max * (1 + 0.8 * ctx.friend_buff.engineer_focus * level)

	missile = E:get_template("missile_mecha")
	if not missile.bullet._engineer_focus_damage_min then
		missile.bullet._engineer_focus_damage_min = missile.bullet.damage_min
		missile.bullet._engineer_focus_damage_max = missile.bullet.damage_max
	end
	missile.bullet.damage_min = missile.bullet._engineer_focus_damage_min * (1 + 0.8 * ctx.friend_buff.engineer_focus * level)
	missile.bullet.damage_max = missile.bullet._engineer_focus_damage_max * (1 + 0.8 * ctx.friend_buff.engineer_focus * level)
end

local function endless_engineer_aftermath_ray_remove(this, store)
	local after_math = E:create_entity("aura_endless_engineer_aftermath_ray")
	after_math.pos.x, after_math.pos.y = this.bullet.to.x, this.bullet.to.y
	after_math.aura.source_id = this.id
	after_math.aura.level = store.endless.upgrade_levels.engineer_aftermath
	Common.queue_insert(store, after_math)
	return true
end

local function patch_engineer_aftermath(level, ctx)
	for _, name in pairs(table.append(bombs, {"missile_mecha"}, true)) do
		local b = E:get_template(name)
		if not b._endless_engineer_aftermath then
			U.append_mod(b.bullet, "mod_endless_engineer_aftermath")
			b._endless_engineer_aftermath = true
		end
	end

	local dwarrp_attack = E:get_template("tower_dwaarp").attacks.list[1]
	if not dwarrp_attack._endless_engineer_aftermath then
		U.append_mod(dwarrp_attack, "mod_endless_engineer_aftermath")
		dwarrp_attack._endless_engineer_aftermath = true
	end

	local mod = E:get_template("mod_endless_engineer_aftermath")
	mod.value = level * ctx.friend_buff.engineer_aftermath

	local ray = E:get_template("ray_tesla")
	if not ray._endless_engineer_aftermath then
		ray.main_script.remove = U.function_append(ray.main_script.remove, endless_engineer_aftermath_ray_remove)
		ray._endless_engineer_aftermath = true
	end

	ray = E:get_template("ray_frankenstein")
	if not ray._endless_engineer_aftermath then
		ray.main_script.remove = U.function_append(ray.main_script.remove, endless_engineer_aftermath_ray_remove)
		ray._endless_engineer_aftermath = true
	end

	local tower = E:get_template("tower_flamespitter_lvl4")
	if not tower._endless_engineer_aftermath then
		tower.attacks.range = tower.attacks.range * (1 + ctx.friend_buff.engineer_seek)
		tower._endless_engineer_aftermath = true
		tower._endless_engineer_aftermath_last_level = 0
	end

	tower.tower.damage_factor = tower.tower.damage_factor + (level - tower._endless_engineer_aftermath_last_level) * ctx.friend_buff.engineer_aftermath * 0.8
	tower._endless_engineer_aftermath_last_level = level
end

local function patch_engineer_fireball(level, ctx)

	for _, name in pairs(bombs) do
		local b = E:get_template(name)

		if not b._endless_engineer_fireball then
			b.main_script.remove = U.function_append(b.main_script.remove, function(this, store)
				return fireball_quick_up(this, store, ctx)
			end)
			b._endless_engineer_fireball = true
		end
	end

	local ray = E:get_template("ray_tesla")
	if not ray._endless_engineer_fireball then
		ray.main_script.remove = U.function_append(ray.main_script.remove, function(this, store)
			return fireball_quick_up(this, store, ctx)
		end)
		ray._endless_engineer_fireball = true
	end

	ray = E:get_template("ray_frankenstein")
	if not ray._endless_engineer_fireball then
		ray.main_script.remove = U.function_append(ray.main_script.remove, function(this, store)
			return fireball_quick_up(this, store, ctx)
		end)
		ray._endless_engineer_fireball = true
	end

	local flame = E:get_template("fx_tower_flamespitter_flame")
	if not flame._endless_engineer_fireball then
		E:add_comps(flame, "main_script")
		flame._endless_engineer_fireball = true
		flame.main_script.remove = U.function_append(flame.main_script.remove, function(this, store)
			return fireball_quick_up(this, store, ctx)
		end)
	end
end

local function register_engineer_techs(registry, ctx)
	registry.register({
		id = "engineer_seek",
		group = "engineer",
		apply_template = function(level, endless)
			patch_engineer_seek(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_engineer_seek_runtime(level, store, endless, ctx)
		end,
	})

	registry.register({
		id = "engineer_fireball",
		group = "engineer",
		apply_template = function(level, endless)
			patch_engineer_fireball(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_engineer_fireball(1, ctx)
		end,
	})

	registry.register({
		id = "engineer_focus",
		group = "engineer",
		apply_template = function(level, endless)
			patch_engineer_focus(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_engineer_focus(1, ctx)
			for _, t in pairs(store.towers) do
				if t.template_name == "tower_tesla" or t.template_name == "tower_dwaarp" or t.template_name == "tower_frankenstein" or t.template_name == "tower_flamespitter_lvl4" then
					SU.insert_tower_damage_factor_buff(t, ctx.friend_buff.engineer_focus * 0.8)
				end
			end
		end,
	})

	registry.register({
		id = "engineer_aftermath",
		group = "engineer",
		apply_template = function(level, endless)
			patch_engineer_aftermath(level, ctx)
		end,
		apply_runtime = function(level, store, endless)
			patch_engineer_aftermath(level, ctx)
		end,
	})
end

return {
	register = register_engineer_techs,
}
