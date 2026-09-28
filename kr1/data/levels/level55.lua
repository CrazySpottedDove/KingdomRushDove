local level={}
function level:init(store)
local E=require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt=E:register_t_hot("decal_obelix","decal_delayed_click_play",true)
tt.render.sprites[1].prefix="decal_obelix"
tt.ui.click_rect=r(-50,-40,100,80)
tt.ui.can_select=false
tt.delayed_play.min_delay=2
tt.delayed_play.max_delay=3
tt.delayed_play.clicked_animation="eat"
tt.delayed_play.clicked_sound="ElvesObelix"
tt.delayed_play.play_animation="hammer"
tt.delayed_play.required_clicks=1
end
return level
