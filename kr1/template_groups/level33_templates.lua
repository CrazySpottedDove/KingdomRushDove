local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_lumberjack_shaman", "decal", true)
tt.render.sprites[1].prefix = "lumberjack_shaman"
tt.render.sprites[1].anchor.y = 0.18
