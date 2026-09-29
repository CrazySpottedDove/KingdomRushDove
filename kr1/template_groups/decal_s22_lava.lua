local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_s22_lava_bubble", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "decal_s22_lava_bubble"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1.5)
tt.delayed_play.min_delay = 2
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil

tt = E:register_t_hot("decal_s22_lava_smoke", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "decal_s22_lava_smoke"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 8
tt.delayed_play.idle_animation = nil

