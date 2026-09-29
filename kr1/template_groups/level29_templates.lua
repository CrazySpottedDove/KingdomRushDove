local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_tusken_update(this, store)
	local a = this.bullet_attack
	a.cooldown = U.frandom(a.cooldown_min, a.cooldown_max)
	while true do
		U.animation_start_default(this, "idle", nil, store.tick_ts)
		local targets = table.filter(store.soldiers, function(_, e)
			return e.soldier.target_id and not e.health.dead and U.is_inside_ellipse(e.pos, this.target_center, a.max_range)
		end)
		if #targets == 0 then
			U.y_wait_unconditional(store, 1)
		else
			local attack_ts = store.tick_ts
			local target = targets[1]
			if math.random() < 0.7 then
				target = store.entities[target.soldier.target_id]
			end
			if target and target.health and not target.health.dead then
				local b = E:create_entity(a.bullet)
				b.bullet.from = v(this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
				b.bullet.to = v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.pos = V.vclone(b.bullet.from)
				U.animation_start_default(this, a.animation, nil, store.tick_ts)
				S:queue("SpecialTusken", {
					delay = fts(19)
				})
				U.y_wait_unconditional(store, a.shoot_time)
				simulation:queue_insert_entity(b)
				S:queue("ShotgunSound")
				U.y_animation_wait_default(this)
				U.y_wait_unconditional(store, a.cooldown - (store.tick_ts - attack_ts))
			end
		end
	end
end
local tt
tt = E:register_t_hot("decal_tusken", "decal_scripted", true)
AC(tt, "bullet_attack")
tt.render.sprites[1].prefix = "decal_tusken"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.main_script.update = decal_tusken_update
tt.bullet_attack.max_range = 350
tt.bullet_attack.bullet = "bullet_tusken"
tt.bullet_attack.shoot_time = fts(2)
tt.bullet_attack.cooldown_min = 10
tt.bullet_attack.cooldown_max = 20
tt.bullet_attack.bullet_start_offset = vec_2(3, 7)
tt = E:register_t_hot("bullet_tusken", "shotgun", true)
tt.bullet.damage_min = 100
tt.bullet.damage_max = 200
tt.bullet.min_speed = 40 * FPS
tt.bullet.max_speed = 40 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
