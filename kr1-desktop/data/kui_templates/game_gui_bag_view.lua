-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_bag_view.lua
return {
	image_name = "bagbar_bg",
	propagate_on_down = true,
	hidden = true,
	propagate_on_click = true,
	propagate_on_up = true,
	class = "GG9View",
	id = "bag_view",
	size = v(400, 90),
	slice_rect = r(15, 15, 20, 12),
	anchor = v(0, 0),
	children = {{
		class = "KView",
		pos = v(42, 6),
		size = v(384, 60),
		children = {{
			class = "KImageView",
			image_name = "bagbar_separator",
			pos = v(30, 27.5),
			anchor = v(8.5, 27.5)
		}, {
			class = "KImageView",
			image_name = "bagbar_separator",
			pos = v(94, 27.5),
			anchor = v(8.5, 27.5)
		}, {
			class = "KImageView",
			image_name = "bagbar_separator",
			pos = v(158, 27.5),
			anchor = v(8.5, 27.5)
		}, {
			class = "KImageView",
			image_name = "bagbar_separator",
			pos = v(222, 27.5),
			anchor = v(8.5, 27.5)
		}, {
			class = "KImageView",
			image_name = "bagbar_separator",
			pos = v(286, 27.5),
			anchor = v(8.5, 27.5)
		}}
	}, {
		class = "KView",
		id = "bag_contents_view",
		pos = v(42, 6),
		size = v(384, 60),
		children = {{
			item = "coins",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_coins",
			image_suffix = "0006",
			pos = v(0, 27.5),
			anchor = v(29, 27.5)
		}, {
			item = "hearts",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_hearts",
			image_suffix = "0005",
			pos = v(64, 27.5),
			anchor = v(29, 27.5)
		}, {
			item = "freeze",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_freeze",
			image_suffix = "0004",
			pos = v(128, 27.5),
			anchor = v(29, 27.5)
		}, {
			item = "dynamite",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_dynamite",
			image_suffix = "0003",
			pos = v(192, 27.5),
			anchor = v(29, 27.5)
		}, {
			item = "atomic_freeze",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_atomic_freeze",
			image_suffix = "0002",
			pos = v(256, 27.5),
			anchor = v(29, 27.5)
		}, {
			item = "atomic_bomb",
			class = "BagItemButton",
			template_name = "game_gui_bag_item_button",
			id = "bag_item_atomic_bomb",
			image_suffix = "0001",
			pos = v(320, 27.5),
			anchor = v(29, 27.5)
		}}
	}}
}
