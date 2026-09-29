local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_lava_fall", "decal_loop", true)
tt.render.sprites[1].name = "decal_lava_fall_idle"
