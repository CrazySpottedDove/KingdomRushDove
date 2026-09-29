local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_wisp_501", "decal_delayed_play", true)
tt.render.sprites[1].name = "props_wisp"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 30
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "props_wisp"
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}}

