local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_blackburn_weed", "decal_loop", true)
tt.render.sprites[1].random_ts = fts(34)
tt.render.sprites[1].name = "decal_blackburn_weed_idle"

tt = E:register_t_hot("decal_blackburn_bubble", "decal_delayed_play", true)
tt.render.sprites[1].name = "decal_blackburn_bubble_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_bubble_jump"

tt = E:register_t_hot("decal_blackburn_waves", "decal_delayed_play", true)
tt.render.sprites[1].name = "decal_blackburn_waves_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_waves_jump"

tt = E:register_t_hot("decal_blackburn_smoke", "decal_loop", true)
tt.render.sprites[1].random_ts = fts(21)
tt.render.sprites[1].name = "decal_blackburn_smoke_jump"

