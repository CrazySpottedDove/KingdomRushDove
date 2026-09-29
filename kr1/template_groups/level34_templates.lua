local V = require("lib.klua.vector")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local P = require("path_db")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end
local function carnivorous_plant_update(this, store)
	local a = this.area_attack
	U.animation_start_default(this, "inactive", nil, store.tick_ts, true)
	while store.wave_group_number < this.activates_on_wave do
		coroutine.yield()
	end
	U.y_animation_play(this, "activate", nil, store.tick_ts)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	local attack_ts = store.tick_ts
	while true do
		while store.tick_ts - attack_ts < a.cooldown do
			coroutine.yield()
		end
		local trigger
		for _, e in pairs(store.entities) do
			if (e.enemy or e.soldier) and e.health and not e.health.dead and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, this.attack_pos, a.damage_radius) then
				trigger = e
				break
			end
		end
		if not trigger then
			attack_ts = store.tick_ts - a.cooldown + 1
		else
			attack_ts = store.tick_ts
			local attack_animation = this.attack_pos.y > this.pos.y and "attack_up" or "attack_down"
			U.animation_start_default(this, attack_animation, nil, store.tick_ts)
			U.y_wait_unconditional(store, a.hit_time)
			S:queue("SpecialCarnivorePlant")
			local e = E:create_entity("pop_slurp")
			local x_off = this.render.sprites[1].flip_x and -40 or 40
			local y_off = this.attack_pos.y > this.pos.y and 40 or -50
			e.pos = v(this.pos.x + x_off, this.pos.y + e.pop_y_offset + y_off)
			e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
			e.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(e)
			local targets = table.filter(store.entities, function(_, e)
				return (e.enemy or e.soldier) and e.health and not e.health.dead and e.vis and band(e.vis.bans, a.vis_flags) == 0 and band(e.vis.flags, a.vis_bans) == 0 and U.is_inside_ellipse(e.pos, this.attack_pos, a.damage_radius)
			end)
			if #targets > 0 then
				for _, target in ipairs(targets) do
					local d = E.assign_damage(a.damage_type, 0, this.id, target.id)
					queue_damage(store, d)
				end
			end
			U.y_animation_wait_default(this)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end
	end
end
local function decal_bouncing_bridge_update(this, store)
	local last_loaded = false
	while true do
		local loaded = false
		for _, e in pairs(store.entities) do
			if (e.enemy or e.soldier) and not e.health.dead and e.vis and not U.flag_has(e.vis.flags, F_FLYING) and U.is_inside_ellipse(e.pos, this.pos, this.bridge_width * 0.5) then
				loaded = true
				break
			end
		end
		if loaded ~= last_loaded then
			if loaded then
				U.animation_start_default(this, "bounce", nil, store.tick_ts, true)
			else
				U.animation_start_default(this, "idle", nil, store.tick_ts)
			end
			last_loaded = loaded
		end
		U.y_wait_unconditional(store, fts(10))
	end
end
local tt
tt = E:register_t_hot("carnivorous_plant", "decal_scripted", true)
AC(tt, "area_attack")
tt.main_script.update = carnivorous_plant_update
tt.render.sprites[1].prefix = "carnivorous_plant"
tt.render.sprites[1].name = "inactive"
tt.render.sprites[1].anchor.y = 0.41
tt.activates_on_wave = 1
tt.area_attack.cooldown = 40
tt.area_attack.damage_radius = 55
tt.area_attack.hit_time = fts(10)
tt.area_attack.vis_flags = F_EAT
tt.area_attack.damage_type = DAMAGE_EAT
tt = E:register_t_hot("decal_bouncing_bridge", "decal_scripted", true)
tt.main_script.update = decal_bouncing_bridge_update
tt.render.sprites[1].prefix = "decal_bouncing_bridge"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "Stage6_Bridge_Front_Pillars"
tt.render.sprites[2].animated = false
tt.render.sprites[2].sort_y = 495
tt.bridge_width = 160
P:deactivate_path(4)
P:add_invalid_range(3, 1, 40)
