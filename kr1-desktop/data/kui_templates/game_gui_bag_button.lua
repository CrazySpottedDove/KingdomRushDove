-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_bag_button.lua
return {
	id = "bag_button",
	selected_image_name = "power_bag_button_0003",
	class = "BagButton",
	default_image_name = "power_bag_button_0001",
	focused_image_name = "power_bag_button_0002",
	anchor = v(0, 62),
	children = {{
		propagate_on_down = true,
		class = "KView",
		id = "bag_button_icons",
		propagate_on_up = true,
		propagate_on_click = true,
		pos = v(0, 0),
		children = {{
			image_name = "power_bag_button_0004",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "default",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0005",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "atomic_bomb",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0006",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "atomic_freeze",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0007",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "dynamite",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0008",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "freeze",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0009",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "hearts",
			propagate_on_up = true
		}, {
			image_name = "power_bag_button_0010",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_click = true,
			id = "coins",
			propagate_on_up = true
		}}
	}, {
		id = "doors",
		propagate_on_down = true,
		class = "KImageView",
		propagate_on_up = true,
		hidden = true,
		propagate_on_click = true,
		image_name = "power_bag_button_doors_0001",
		animation = {
			hide_at_end = true,
			prefix = "power_bag_button_doors",
			from = 1,
			to = 16
		}
	}}
}
