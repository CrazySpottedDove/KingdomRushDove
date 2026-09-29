local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local tt
tt = E:register_t_hot("decal_s16_land_1", "decal_background", true)
AC(tt, "tween")
tt.render.sprites[1].name = "Stage16_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = E:register_t_hot("decal_s16_land_2", "decal_s16_land_1", true)
tt.render.sprites[1].name = "Stage04_0002"
tt.render.sprites[1].z = Z_DECALS - 1
tt = E:register_t_hot("decal_s16_ground_archers_land", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].name = "groundArchers"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = E:register_t_hot("decal_s16_bush_holder", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].name = "stage16_bushHolders"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = E:register_t_hot("decal_s16_bush_burner", "decal", true)
AC(tt, "editor")
tt.render.sprites[1].name = "stage16_bushGnollBurner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2777777777777778
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt = E:register_t_hot("fx_s16_bush_burner", "fx", true)
tt.render.sprites[1].name = "fx_s16_bush_burner"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt = E:register_t_hot("fx_s16_burner_explosion", "decal_timed", true)
AC(tt, "editor")
tt.timed.runs = INT_32_MAX
tt.render.sprites[1].name = "fx_s16_burner_explosion"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor.y = 0.09740259740259741
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
