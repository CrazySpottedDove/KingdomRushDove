local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_s01_trees", "decal", true)
tt.render.sprites[1].name = "stage1_trees"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.234375
