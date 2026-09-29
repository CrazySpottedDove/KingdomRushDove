local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_inferno_bubble", "decal_delayed_play", true)
tt.render.sprites[1].name = "decal_inferno_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_inferno_bubble_jump"

tt = E:register_t_hot("decal_lava_splash", "decal_inferno_bubble", true)
tt.render.sprites[1].name = "decal_lava_splash_jump"
tt.delayed_play.play_animation = "decal_lava_splash_jump"

