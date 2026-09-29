local E = require("entity_db")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local tt
tt = E:register_t_hot("decal_s13_relic_book", "decal_delayed_click_play", true)
AC(tt, "tween")
tt.render.sprites[1].prefix = "decal_s13_relic_book"
tt.ui.click_rect = r(-20, -30, 40, 30)
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 6
tt.delayed_play.required_clicks = 1
tt.delayed_play.achievement_flag = {"SORCERERS_APPRENTICE", 1}
tt.delayed_play.play_once = true
tt.delayed_play.clicked_sound = "ElvesAchievementSorcapprenticeBook"
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0, 1)}, {fts(60), vec_2(0, -1)}, {fts(80), vec_2(0, 0)}}
tt = E:register_t_hot("decal_s13_relic_broom", "decal_click_play", true)
tt.render.sprites[1].prefix = "decal_s13_relic_broom"
tt.ui.click_rect = r(24, 0, 40, 50)
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 2}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeBroom"
tt = E:register_t_hot("decal_s13_relic_hat", "decal_click_play", true)
AC(tt, "tween")
tt.render.sprites[1].prefix = "decal_s13_relic_hat"
tt.ui.click_rect = r(-20, -40, 40, 30)
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0, 1)}, {fts(60), vec_2(0, -1)}, {fts(80), vec_2(0, 0)}}
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 4}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeHat"
