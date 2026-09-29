local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local tt
tt = E:register_t_hot("decal_inferno_portal", "decal_demon_portal_big", true)
tt.render.sprites[1].name = "decal_inferno_portal_active"
tt = E:register_t_hot("decal_inferno_ground_portal", "decal_demon_portal_big", true)
tt.render.sprites[1].name = "decal_inferno_ground_portal_active"
tt = E:register_t_hot("decal_s21_hellboy", "decal", true)
tt.render.sprites[1].name = "decal_s21_hellboy_idle"
tt = E:register_t_hot("decal_s21_veznan", "decal", true)
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated = false
tt = E:register_t_hot("decal_s21_veznan_free", "decal", true)
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated = false
