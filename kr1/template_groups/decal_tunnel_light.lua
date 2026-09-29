local E = require("entity_db")
local scripts = require("game_scripts")
local tt
tt = E:register_t_hot("decal_tunnel_light", "decal_scripted", true)
AC(tt, "tween")
tt.main_script.update = scripts.decal_tunnel_light.update
tt.render.sprites[1].name = "cave_light_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, 255}, {0.15, 200}, {0.3, 255}, {0.4, 220}, {0.7, 255}}

