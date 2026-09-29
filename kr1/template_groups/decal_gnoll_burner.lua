local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_gnoll_burner", "decal", true)
tt.render.sprites[1].anchor = vec_2(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.render.sprites[1].name = "idle"

