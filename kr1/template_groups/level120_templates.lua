local E = require("entity_db")
require("lib.klua.table")
local AC = require("achievements")
local scripts = require("scripts")
local tt
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
