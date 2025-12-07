-- chunkname: @./kr1-desktop/data/kui_templates/shop_bag_item_view.lua
local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "ShopBagItemView",
	children = {{
		vertical_align = "middle",
		text_align = "left",
		fit_lines = 1,
		font_size = 18,
		shader_margin = 8,
		text = "6",
		class = "GGShaderLabel",
		id = "bag_item_qty",
		font_name = "numbers_italic",
		pos = v(4, 34),
		size = v(50, 20),
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
	}}
}
