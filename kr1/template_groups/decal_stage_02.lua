local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_stage_02_wisps", "decal", true)
tt.render.sprites[1].prefix = "stage_2_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_2_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true

tt = E:register_t_hot("decal_stage_02_butterfly_1", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_2_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30

tt = E:register_t_hot("decal_stage_02_butterfly_2", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_2_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35

tt = E:register_t_hot("decal_stage_02_butterfly_3", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "stage_2_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 12
tt.delayed_play.max_delay = 32

