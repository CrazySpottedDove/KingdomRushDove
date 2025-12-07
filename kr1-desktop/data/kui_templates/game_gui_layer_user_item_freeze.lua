-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_layer_user_item_freeze.lua
local SW = ctx.SW
local WH = ctx.SH
local F = 1
return {
	propagate_on_click = true,
	propagate_on_down = true,
	id = "layer_user_item_freeze",
	alpha = 0,
	propagate_on_up = true,
	class = "KView",
	hidden = true,
	size = v(SW, WH),
	children = {
		{
			image_name = "freeze_gfx_corner",
			class = "KImageView",
			pos = v(SW, 0),
			scale = v(1, 1),
			anchor = v(F * 504 * 0.5 - 2, F * 4)
		},
		{
			image_name = "freeze_gfx_corner",
			class = "KImageView",
			pos = v(0, 0),
			scale = v(-1, 1),
			anchor = v(F * 504 * 0.5 - 2, F * 4)
		},
		{
			image_name = "freeze_gfx_corner",
			class = "KImageView",
			pos = v(SW, WH),
			scale = v(1, -1),
			anchor = v(F * 504 * 0.5 - 2, F * 4)
		},
		{
			image_name = "freeze_gfx_corner",
			class = "KImageView",
			pos = v(0, WH),
			scale = v(-1, -1),
			anchor = v(F * 504 * 0.5 - 2, F * 4)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0.28 * SW, 0),
			r = rad(0),
			anchor = v(F * 408 / 4, F * 2)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0.5 * SW, 0),
			r = rad(0),
			anchor = v(F * 408 / 4, F * 0)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0, 100),
			r = rad(90),
			anchor = v(F * 408 / 4, F * 2)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0, 200),
			r = rad(90),
			anchor = v(F * 408 / 4, F * 0)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0.27 * SW, WH),
			r = rad(180),
			anchor = v(F * 408 / 4, F * 2)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(0.54 * SW, WH),
			r = rad(180),
			anchor = v(F * 408 / 4, F * 0)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(SW, 100),
			r = rad(270),
			anchor = v(F * 408 / 4, F * 2)
		},
		{
			image_name = "freeze_gfx_side",
			class = "KImageView",
			pos = v(SW, 200),
			r = rad(270),
			anchor = v(F * 408 / 4, F * 0)
		}
	}
}
