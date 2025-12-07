-- chunkname: @./kr1-desktop/data/kui_templates/map_counters_view.lua
local SW = ctx.sw
local BW = ctx.premium and 408 or 312
local PSI = ctx.premium and 180 or 60
local PSL = ctx.premium and 235 or 115
return {
	class = "GG9View",
	id = "map_counters_view",
	image_name = "mapStarsContainerEmpty",
	pos = v(SW - 35, 30),
	size = v(BW, 62),
	anchor = v(BW, 0),
	slice_rect = r(90, 20, 96, 14),
	children = {{
		class = "KImageView",
		image_name = "mapStarsContainerIcons_0002",
		pos = v(50, 0),
		hidden = not ctx.premium
	}, {
		vertical_align = "middle-caps",
		text_shadow = true,
		id = "map_counters_gems",
		font_size = 30,
		text_align = "left",
		text = "999",
		class = "GGLabel",
		fit_size = true,
		font_name = "numbers_bold",
		pos = v(105, 10),
		hidden = not ctx.premium,
		size = v(85, 36),
		text_shadow_offset = v(2, 2),
		colors = {
			text = {228, 188, 114, 255},
			text_shadow = {37, 36, 30, 255},
			background = {255, 255, 255, 0}
		}
	}, {
		class = "KImageView",
		image_name = "mapStarsContainerIcons_0001",
		pos = v(PSI, 0)
	}, {
		vertical_align = "middle-caps",
		text_shadow = true,
		text_align = "left",
		font_size = 30,
		text = "199/199",
		class = "GGLabel",
		id = "map_counters_stars",
		fit_size = true,
		font_name = "numbers_bold",
		pos = v(PSL, 10),
		size = v(110, 36),
		text_shadow_offset = v(2, 2),
		colors = {
			text = {228, 188, 114, 255},
			text_shadow = {37, 36, 30, 255},
			background = {255, 255, 255, 0}
		}
	}}
}
