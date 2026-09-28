local level={}
function level:init(store)
local E=require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt=E:register_t_hot("decal_boat_big","decal_loop",true)
tt.render.sprites[1].name="decal_boat_big_idle"
tt=E:register_t_hot("decal_boat_small","decal_loop",true)
tt.render.sprites[1].name="decal_boat_small_idle"
end
return level
