-- chunkname: @./kr1-desktop/data/kui_templates/shop_view.lua
local BG_W = 1024
local BG_H = 768
local OY = 130
return {
	id = "shop_view",
	hidden = true,
	class = "ShopView",
	size = v(BG_W, BG_H),
	anchor = v(BG_W * 0.5, 0),
	children = {{
		class = "KImageView",
		image_name = "shop_view_frame",
		pos = v(0, 10 + OY),
		children = {{
			id = "shop_done_button",
			hover_image_name = "levelSelect_closeBtn_0002",
			class = "KImageButton",
			click_image_name = "levelSelect_closeBtn_0003",
			default_image_name = "levelSelect_closeBtn_0001",
			pos = v(986, 47),
			anchor = v(17, 16)
		}, {
			text_key = "MAP_BUTTON_SHOP",
			class = "GGPanelHeader",
			pos = v(364, 44),
			size = v(274, 32)
		}}
	}, {
		class = "KImageView",
		image_name = "inaps_BG",
		pos = v(-10, 20 + OY)
	}, {
		class = "KView",
		pos = v(BG_W * 0.5 - 10, BG_H * 0.5 + 20 + OY),
		size = v(1024, 768),
		children = {
			{
				id = "shop_board_image",
				image_name = "inaps_boardDrawings_0001",
				class = "KImageView",
				pos = v(96, -93),
				anchor = v(82, 86)
			},
			{
				vertical_align = "middle",
				text_align = "center",
				fit_lines = 1,
				font_size = 29,
				text = "Fat Boy",
				class = "GGLabel",
				id = "shop_board_title",
				font_name = "body_bold",
				pos = v(189, -206),
				size = v(320, 40),
				anchor = v(160, 20),
				colors = {
					text = {159, 175, 160, 255}
				}
			},
			{
				text_align = "left",
				font_size = 16,
				text = "The big bad boy",
				class = "GGLabel",
				id = "shop_board_desc",
				fit_size = true,
				font_name = "body",
				pos = v(268, -110),
				size = v(180, 114),
				anchor = v(90, 57),
				colors = {
					background = {255, 255, 255, 0},
					text = {188, 205, 189, 255}
				}
			},
			{
				vertical_align = "middle",
				text_align = "center",
				font_size = 28,
				text = "999",
				class = "GGLabel",
				id = "shop_board_price",
				font_name = "numbers_italic",
				pos = v(270, -31),
				size = v(72, 35),
				anchor = v(36, 17.5),
				colors = {
					text = {159, 175, 160, 255}
				}
			},
			{
				vertical_align = "middle",
				text_align = "left",
				fit_lines = 1,
				font_size = 35,
				text = "99999",
				class = "GGLabel",
				id = "shop_gems",
				font_name = "numbers_italic",
				pos = v(-173, -233),
				size = v(130, 44),
				anchor = v(65, 22),
				colors = {
					text = {254, 238, 207, 255}
				}
			},
			{
				class = "KView",
				id = "shop_items",
				initial_item = 6,
				pos = v(0, 0),
				children = {{
					item_name = "atomic_freeze",
					class = "ShopItemView",
					pos = v(303, 121),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(132, 102, 160, 115)
				}, {
					item_name = "atomic_bomb",
					class = "ShopItemView",
					pos = v(106, 171),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(60, 4, 160, 240)
				}, {
					item_name = "freeze",
					class = "ShopItemView",
					pos = v(-177, 250),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(102, 81, 85, 115)
				}, {
					item_name = "hearts",
					class = "ShopItemView",
					pos = v(-295, 229),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(100, 85, 80, 115)
				}, {
					item_name = "coins",
					class = "ShopItemView",
					pos = v(257, 178),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(115, 125, 65, 95)
				}, {
					item_name = "dynamite",
					class = "ShopItemView",
					pos = v(-35, 243),
					size = v(292, 284),
					padding = v(0, 0),
					hit_rect = r(85, 100, 95, 95)
				}}
			},
			{
				class = "KImageView",
				image_name = "inaps_backPack",
				pos = v(-404, -70),
				anchor = v(60, 214)
			},
			{
				id = "shop_bag_items",
				class = "KView",
				pos = v(-404, -148),
				children = {{
					item_name = "atomic_bomb",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0001",
					pos = v(0, 0),
					anchor = v(30, 28)
				}, {
					item_name = "atomic_freeze",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0002",
					pos = v(2, 56),
					anchor = v(30, 28)
				}, {
					item_name = "dynamite",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0003",
					pos = v(4, 104),
					anchor = v(30, 28)
				}, {
					item_name = "freeze",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0004",
					pos = v(0, 155),
					anchor = v(30, 28)
				}, {
					item_name = "hearts",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0005",
					pos = v(2, 209),
					anchor = v(30, 28)
				}, {
					item_name = "coins",
					hidden = true,
					class = "ShopBagItemView",
					template_name = "shop_bag_item_view",
					image_name = "inaps_backPackIcons_0006",
					pos = v(2, 256),
					anchor = v(30, 28)
				}}
			},
			{
				vertical_align = "middle",
				text_shadow = true,
				fit_lines = 1,
				default_image_name = "inaps_gemsButton_0001",
				font_size = 22,
				text_key = "MAP_INAPP_MORE_GEMS",
				class = "GGImageButton",
				id = "shop_more_gems_button",
				click_image_name = "inaps_gemsButton_0002",
				font_name = "button",
				UNLESS = ctx.fullads,
				pos = v(-202, -147),
				anchor = v(160, 54),
				text_size = v(162, 50),
				text_offset = v(80, 28),
				colors = {
					text = {255, 233, 184, 255},
					text_shadow = {53, 36, 14, 255}
				}
			},
			{
				vertical_align = "middle",
				text_shadow = true,
				fit_lines = 1,
				font_size = 32,
				id = "shop_buy_button",
				default_image_name = "inaps_buyButton_0001",
				class = "GGImageButton",
				text_key = "BUTTON_BUY",
				click_image_name = "inaps_buyButton_0002",
				font_name = "button",
				pos = v(258, 37),
				anchor = v(80, 42),
				text_size = v(115, 40),
				text_offset = v(23, 26),
				colors = {
					text = {255, 233, 184, 255},
					text_shadow = {53, 36, 14, 255}
				}
			},
			{
				vertical_align = "middle",
				propagate_on_down = true,
				fit_lines = 2,
				image_name = "inaps_bubble",
				font_size = 23,
				hidden = true,
				text_key = "MAP_INAPPS_BUBBLE_SUCCESSFUL",
				propagate_on_up = true,
				class = "GGLabel",
				propagate_on_click = true,
				id = "shop_success_balloon",
				font_name = "body_bold",
				pos = v(-40, -150),
				text_size = v(210, 90),
				text_offset = v(13, 10)
			},
			{
				id = "shop_failure_arm",
				class = "KImageView",
				image_name = "inaps_armUp",
				hidden = true,
				pos = v(-99, 23),
				anchor = v(57, 113)
			},
			{
				vertical_align = "middle",
				propagate_on_down = true,
				fit_lines = 2,
				id = "shop_failure_balloon",
				hidden = true,
				font_size = 28,
				image_name = "inaps_bubble_needMore",
				class = "GGLabel",
				propagate_on_up = true,
				text_key = "MAP_INAPPS_BUBBLE_MORE_GEMS",
				propagate_on_click = true,
				font_name = "body_bold",
				pos = v(100, -70),
				anchor = v(160, 129),
				text_size = v(125, 75),
				text_offset = v(85, 65)
			},
			{
				id = "shop_help_view",
				class = "KView",
				hidden = true,
				pos = v(-(BG_W - 568) * 0.5, 0),
				size = v(BG_W, BG_H),
				colors = {
					background = {0, 0, 0, 0}
				},
				children = {{
					class = "KImageView",
					image_name = "inaps_bubble",
					pos = v(130, -130),
					children = {{
						vertical_align = "middle",
						propagate_on_down = true,
						propagate_on_up = true,
						font_size = 18,
						propagate_on_click = true,
						class = "GGLabel",
						text_key = "MAP_INAPPS_BUBBLE_INFO_1",
						fit_size = true,
						font_name = "body_bold",
						pos = v(14, 5),
						size = v(200, 50),
						colors = {
							text = {0, 133, 160, 255}
						}
					}, {
						vertical_align = "middle",
						propagate_on_down = true,
						propagate_on_up = true,
						font_size = 18,
						propagate_on_click = true,
						class = "GGLabel",
						text_key = "MAP_INAPPS_BUBBLE_INFO_2",
						fit_size = true,
						font_name = "body",
						pos = v(14, 55),
						size = v(200, 50),
						colors = {
							text = {0, 0, 0, 255}
						}
					}}
				}}
			}
		}
	}}
}
