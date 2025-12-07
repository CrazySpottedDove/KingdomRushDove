-- chunkname: @./kr1-desktop/data/kui_templates/slot_view.lua
return {
	id = "slot_3",
	class = "SlotView",
	pos = {
		x = 503,
		y = 357
	},
	children = {{
		id = "slot_used",
		class = "KView",
		children = {{
			id = "button_slot",
			class = "CSinkButton",
			hover_image_name = "homeMenu_btnSlot_en_0002",
			default_image_name = "homeMenu_btnSlot_en_0001",
			click_image_name = "homeMenu_btnSlot_en_0003",
			children = {{
				class = "KView",
				propagate_on_down = true,
				propagate_on_enter = true,
				propagate_on_up = true,
				propagate_on_click = true,
				children = {{
					hover_image_name = "homeMenu_btnSlot_delete_0002",
					click_image_name = "homeMenu_btnSlot_delete_0003",
					class = "KImageButton",
					id = "button_slot_delete",
					default_image_name = "homeMenu_btnSlot_delete_0001",
					pos = {
						x = 190,
						y = 12
					}
				}, {
					class = "KView",
					r = 0.06,
					pos = {
						x = 42,
						y = 70
					},
					size = {
						x = 193,
						y = 0
					},
					children = {{
						text = "0/110",
						font_size = 12,
						class = "KLabel",
						text_align = "left",
						id = "l_stars",
						font_name = "numbers_italic",
						pos = {
							x = 14,
							y = 2
						},
						size = {
							x = 64,
							y = 27
						}
					}, {
						text = "0",
						font_size = 12,
						class = "KLabel",
						text_align = "left",
						id = "l_heroic",
						font_name = "numbers_italic",
						pos = {
							x = 108,
							y = 4
						},
						size = {
							x = 64,
							y = 27
						}
					}, {
						text = "0",
						font_size = 12,
						class = "KLabel",
						text_align = "left",
						id = "l_iron",
						font_name = "numbers_italic",
						pos = {
							x = 154,
							y = 4
						},
						size = {
							x = 64,
							y = 27
						}
					}}
				}}
			}}
		}}
	}, {
		id = "slot_empty",
		class = "KView",
		children = {{
			id = "button_slot_new",
			class = "KImageButton",
			hover_image_name = "homeMenu_btnSlot_en_0005",
			default_image_name = "homeMenu_btnSlot_en_0004",
			click_image_name = "homeMenu_btnSlot_en_0006"
		}}
	}}
}
