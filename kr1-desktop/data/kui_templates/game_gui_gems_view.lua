-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_gems_view.lua
local OX = 170
local PX = ctx.level_mode == 2 and 240 or 220
return {
	image_name = "win_Gnome",
	class = "KImageView",
	id = "gems_view",
	pos = v(PX, 90),
	shown_x = PX + OX,
	children = {{
		vertical_align = "middle-caps",
		fit_lines = 1,
		font_size = 44,
		shader_margin = 8,
		text = "999",
		class = "GGShaderLabel",
		id = "gems_label",
		font_name = "numbers_bold",
		pos = v(106, 145),
		size = v(60, 48),
		r = rad(-14),
		colors = {
			text = {255, 255, 255, 255},
			background = {0, 0, 0, 0}
		},
		shaders = {"p_outline", "p_glow"},
		shader_args = {{
			thickness = 1.5,
			outline_color = {0, 0.6196078431372549, 0.7058823529411765, 1}
		}, {
			thickness = 1,
			glow_color = {0, 0.6196078431372549, 0.7058823529411765, 1}
		}}
	}}
}
