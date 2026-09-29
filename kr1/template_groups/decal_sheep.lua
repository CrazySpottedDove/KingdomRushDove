local E = require("entity_db")
local decal_sheep_big = {}

function decal_sheep_big.insert(this, store)
	if math.random() < this.delayed_play.required_clicks_fx_alt_chance then
		local d = this.delayed_play

		d.required_clicks_fx = d.required_clicks_fx_alt
		d.clicked_sound = d.clicked_sound_alt
	end

	return true
end

local tt
tt = E:register_t_hot("decal_sheep_big", "decal_delayed_click_play", true)
AC(tt, "tween")
tt.delayed_play.achievement_inc = "SHEEP_KILLER"
tt.delayed_play.click_interrupts = true
tt.delayed_play.click_tweens = true
tt.delayed_play.click_sound = "Sheep"
tt.delayed_play.clicked_animation = nil
tt.delayed_play.clicked_sound = "DeathEplosion"
tt.delayed_play.clicked_sound_alt = "BombExplosionSound"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 8
tt.delayed_play.required_clicks_fx = "fx_unit_explode"
tt.delayed_play.required_clicks_fx_alt = "fx_explosion_small"
tt.delayed_play.required_clicks_fx_alt_chance = 0.1
tt.delayed_play.required_clicks_hide = true
tt.main_script.insert = decal_sheep_big.insert
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "decal_sheep_big"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.12, vec_2(1.2, 1.2)}, {0.16, vec_2(1, 1)}}
tt.tween.props[1].name = "scale"
tt.tween.remove = false
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.ui.can_select = false

tt = E:register_t_hot("decal_sheep_small", "decal_sheep_big", true)
tt.render.sprites[1].prefix = "decal_sheep_small"

tt = E:register_t_hot("decal_goat", "decal_sheep_big", true)
tt.render.sprites[1].prefix = "decal_goat"

