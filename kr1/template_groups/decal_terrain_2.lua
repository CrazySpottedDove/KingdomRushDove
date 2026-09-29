local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_terrain_2_smoke", "decal", true)
tt.render.sprites[1].prefix = "t2_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_terrain_2_dust", "decal", true)
tt.render.sprites[1].prefix = "t2_dustDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

