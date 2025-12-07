-- chunkname: @./kr1-desktop/data/kui_templates/screen_map_balloon_endless.lua
local CJK = ctx.CJK
return {
	class = "KImageView",
	image_name = "mapBaloon_buyUpgrade_notxt",
	anchor = v(62, 168),
	children = {{
		vertical_align = "middle",
		fit_lines = 2,
		font_size = 28,
		class = "GGLabel",
		text_key = "MAP_NEW_GAMEMODE_UNLOCKED_TITLE",
		font_name = "body",
		size = v(228, 34),
		pos = v(15, 19),
		line_height = CJK(0.7, nil, 1.1, nil),
		colors = {
			text = {0, 102, 158, 255}
		}
	}, {
		vertical_align = "middle",
		fit_lines = 3,
		font_size = 18,
		class = "GGLabel",
		text_key = "MAP_NEW_GAMEMODE_UNLOCKED_DESCRIPTION",
		font_name = "body",
		size = v(228, 72),
		pos = v(15, 62),
		line_height = CJK(0.9, nil, 1.25, nil),
		colors = {
			text = {46, 41, 39, 255}
		}
	}}
}
