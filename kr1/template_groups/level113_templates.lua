local E = require("entity_db")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_stage_13_mask_1", "decal", true)
tt.render.sprites[1].name = "stage13_mask1"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_stage_13_mask_2", "decal_stage_13_mask_1", true)
tt.render.sprites[1].name = "stage13_mask2"
tt = E:register_t_hot("decal_stage_13_mask_4", "decal_stage_13_mask_1", true)
tt.render.sprites[1].name = "stage13_masktentacle2"
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t_hot("decal_stage_13_glare", "decal_stage_12_glare", true)
tt.render.sprites[1].prefix = "stage_13_glareDef"
tt = E:register_t_hot("decal_stage_13_mask_3", "decal_stage_13_mask_1", true)
tt.render.sprites[1].name = "stage13_masktentacle1"
tt.render.sprites[1].z = Z_DECALS + 1
