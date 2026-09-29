local E = require("entity_db")
local tt
tt = E:register_t_hot("decal_terrain_3_floating_rock", "decal", true)
E:add_comps(tt, "tween", "editor")
tt.render.sprites[1].name = "T3_Stage_12_floating_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.tween_amplitude = 15
tt.tween_frecueny = 150
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}, {"render.sprites[1].draw_order", PT_NUMBER}, {"render.sprites[1].name", PT_STRING}, {"render.sprites[1].z", PT_NUMBER}}

tt = E:register_t_hot("decal_stage_12_tentacles", "decal", true)
tt.render.sprites[1].prefix = "BKtentacleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].fps = 15

tt = E:register_t_hot("decal_stage_13_tentacles", "decal_stage_12_tentacles", true)
tt.render.sprites[1].prefix = "BKtentacle13Def"

