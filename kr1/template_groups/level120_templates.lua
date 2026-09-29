local E = require("entity_db")
require("lib.klua.table")
local AC = require("achievements")
local scripts = require("scripts")
local tt
local decal_stage20_ruperto_easter_egg
local v = V.v
local U = require("utils")
decal_stage20_ruperto_easter_egg = {}

function decal_stage20_ruperto_easter_egg.update(this, store)
	local last_ts = store.tick_ts
	local appear_cd = math.random(this.appear_cd_min, this.appear_cd_max)
	local random_animation = this.animations_random
	local b = E:create_entity("decal_stage20_ruperto_ruperto_easter_egg")

	b.pos = v(this.pos.x - 50, this.pos.y)

	simulation:queue_insert_entity(b)

	last_ts = store.tick_ts
	appear_cd = math.random(this.appear_cd_min, this.appear_cd_max)

	while true do
		if appear_cd < store.tick_ts - last_ts then
			local anim = random_animation[math.random(1, #random_animation)]

			U.y_animation_play(this, anim, nil, store.tick_ts, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)

			appear_cd = math.random(this.appear_cd_min, this.appear_cd_max)
			last_ts = store.tick_ts
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("stage_20_arborean_oldtree_tree_2", "decal_scripted", true)
E:add_comps(tt, "nav_path", "motion", "custom_attack")
tt.render.sprites[1].prefix = "arborean_woodDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"idle", "idle", "idle"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].exo = true
tt.main_script.update = scripts.stage_20_arborean_oldtree_tree.update
tt.nav_path.dir = -1
tt.nav_path.pi = 3
tt.nav_path.ni = 105
tt.nav_path.spi = 1
tt.motion.max_speed = 5 * FPS
tt.custom_attack.max_range = 50
tt.custom_attack.damage_min = 350
tt.custom_attack.damage_max = 450
tt.custom_attack.damage_type = DAMAGE_PHYSICAL
tt.custom_attack.hit_fx = "fx_tower_arborean_oldtree_hit"
tt.custom_attack.cycle_time = 0.3
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)

tt = E:register_t_hot("decal_stage20_ruperto_easter_egg", "decal_scripted", true)
E:add_comps(tt)
tt.render.sprites[1].prefix = "anim_arborean_ruperto_arborean"
tt.render.sprites[1].name = "idle"
tt.main_script.update = decal_stage20_ruperto_easter_egg.update
tt.animations_random = {"action1", "action2"}
tt.appear_cd_min = 7
tt.appear_cd_max = 14
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage20_ruperto_ruperto_easter_egg", "decal_scripted", true)
E:add_comps(tt)
tt.render.sprites[1].name = "anim_arborean_ruperto_ruperto"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS

