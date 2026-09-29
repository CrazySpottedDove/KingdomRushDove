local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_water_shine", "decal_loop", true)
tt.render.sprites[1].name = "props_water_shine"

tt = E:register_t_hot("decal_waterfall_waves", "decal_loop", true)
tt.render.sprites[1].name = "props_waterfall_waves"
tt.render.sprites[1].z = Z_DECALS + 1
tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].scale", PT_COORDS}, {"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].z", PT_NUMBER}}

tt = E:register_t_hot("decal_water_spark", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_spark_play"

tt = E:register_t_hot("decal_water_wave", "decal_delayed_play", true)
tt.render.sprites[1].name = "decal_water_wave_play"
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_water_wave_play"

tt = E:register_t_hot("decal_water_sparks", "decal_loop", true)
tt.render.sprites[1].name = "decal_water_sparks_idle"

tt = E:register_t_hot("decal_water_wave_delayed_2", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"

