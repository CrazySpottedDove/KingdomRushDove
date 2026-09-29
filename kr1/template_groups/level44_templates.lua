local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_water_barricade", "decal", true)
tt.render.sprites[1].prefix = "decal_water_barricade"
tt.render.sprites[1].name = "idle"
