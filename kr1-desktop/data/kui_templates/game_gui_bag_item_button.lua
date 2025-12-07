-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_bag_item_button.lua
return {
	class = "BagItemButton",
	children = {{
		disabled_image_name = "backPack_icons_off_0001",
		class = "GGImageButton",
		id = "bag_item_button",
		default_image_name = "backPack_icons_0001",
		down_scale = 0.95,
		pos = v(29, 27.5),
		anchor = v(29, 27.5)
	}, {
		vertical_align = "middle",
		text_align = "left",
		fit_lines = 1,
		font_size = 15,
		shader_margin = 8,
		text = "6",
		class = "GGShaderLabel",
		id = "bag_item_qty",
		font_name = "infobar_stats",
		pos = v(6, 32),
		size = v(38, 16),
		colors = {
			text = {255, 255, 255, 255}
		},
		shaders = {"p_outline", "p_glow"},
		shader_args = {{
			thickness = 1,
			outline_color = {0, 0, 0, 1}
		}, {
			thickness = 1,
			glow_color = {0, 0, 0, 1}
		}}
	}, {
		id = "bag_item_plus",
		default_image_name = "backPack_icons_0007",
		class = "GGImageButton",
		click_image_name = "backPack_icons_0008"
	}}
}
