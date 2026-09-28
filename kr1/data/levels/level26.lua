local level={}
function level:init(store)
local E=require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt=E:register_t_hot("decal_s26_cage","decal_delayed_play",true)
tt.render.sprites[1].prefix="decal_s26_cage"
tt.delayed_play.min_delay=2
tt.delayed_play.max_delay=6
tt.delayed_play.idle_animation="idle"
tt.delayed_play.play_animation="play"
tt=E:register_t_hot("decal_s26_hangmen","decal_s26_cage",true)
tt.render.sprites[1].prefix="decal_s26_hangmen"
end
return level
