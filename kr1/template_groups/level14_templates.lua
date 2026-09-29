local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local tt
tt = E:register_t_hot("decal_orc_burner", "decal_loop", true)
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = E:register_t_hot("decal_orc_flag", "decal_loop", true)
tt.render.sprites[1].anchor = vec_2(0.5, 0.07)
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_orc_flag_idle"
