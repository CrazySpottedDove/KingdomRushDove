-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_defeat_view.lua
local WW = ctx.SW
local WH = ctx.SH
return {
	hidden = false,
	class = "KView",
	id = "defeat_view",
	pos = v(WW * 0.5, 0),
	size = v(WW, WH),
	anchor = v(WW * 0.5, 0),
	children = {{
		image_name = "win_Gnome",
		class = "KImageView",
		id = "gems_view",
		shown_x = 616,
		pos = v(516, 282),
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
	}, {
		hidden = true,
		shown_y = 570,
		class = "KView",
		id = "defeat_endless_view_quit",
		pos = v(WW * 0.5, 520),
		children = {{
			class = "KImageView",
			image_name = "button_restart_chains",
			pos = v(0, 0),
			anchor = v(78, 30)
		}, {
			id = "defeat_endless_view_quit_button",
			large = false,
			class = "GGBorderButton",
			label_text_key = "BUTTON_ENDLESS_QUIT",
			pos = v(0, 0),
			anchor = v(73, 0)
		}}
	}, {
		hidden = true,
		shown_y = 500,
		class = "KView",
		id = "defeat_endless_view_try_again",
		pos = v(WW * 0.5, 420),
		children = {{
			class = "KImageView",
			image_name = "button_continue_chains",
			pos = v(0, 0),
			anchor = v(78, 68)
		}, {
			id = "defeat_endless_view_try_again_button",
			large = true,
			class = "GGBorderButton",
			label_text_key = "BUTTON_ENDLESS_TRYAGAIN",
			pos = v(0, 0),
			anchor = v(89, 0)
		}}
	}, {
		id = "badge_view",
		image_name = "victory_shield_endless",
		class = "KImageView",
		pos = v(WW * 0.5, 300),
		anchor = v(238, 213.5),
		children = {{
			font_size = 56,
			text_shadow = true,
			fit_lines = 1,
			text = "999",
			class = "GGLabel",
			id = "waves_label",
			font_name = "numbers_bold",
			pos = v(240, 170),
			size = v(120, 26),
			anchor = v(60, 0),
			text_shadow_offset = v(2, 2),
			colors = {
				text = {252, 219, 139, 255},
				text_shadow = {0, 0, 0, 255}
			}
		}, {
			font_size = 18,
			text_shadow = true,
			fit_lines = 1,
			class = "GGLabel",
			text_key = "ENDLESS_GUI_VICTORY_WAVES_SURVIVED",
			font_name = "h",
			pos = v(240, 222),
			size = v(180, 12),
			anchor = v(90, 0),
			text_shadow_offset = v(1, 1),
			colors = {
				text = {228, 208, 181, 255},
				text_shadow = {0, 0, 0, 255}
			}
		}, {
			font_size = 36,
			text_shadow = true,
			fit_lines = 1,
			text = "99999999",
			class = "GGLabel",
			id = "score_label",
			font_name = "numbers_bold",
			pos = v(240, 279),
			size = v(140, 26),
			anchor = v(70, 0),
			text_shadow_offset = v(2, 2),
			colors = {
				text = {252, 219, 139, 255},
				text_shadow = {0, 0, 0, 255}
			}
		}, {
			font_size = 18,
			text_shadow = true,
			fit_lines = 1,
			class = "GGLabel",
			text_key = "ENDLESS_GUI_VICTORY_FINAL_SCORE",
			font_name = "h",
			pos = v(240, 314),
			size = v(140, 12),
			anchor = v(70, 0),
			text_shadow_offset = v(1, 1),
			colors = {
				text = {228, 208, 181, 255},
				text_shadow = {0, 0, 0, 255}
			}
		}, {
			vertical_align = "middle-caps",
			text_shadow = true,
			font_size = 26,
			text = "TAUNT",
			class = "GGLabel",
			id = "taunt_label",
			fit_size = true,
			font_name = "button",
			pos = v(240, 354),
			size = v(240, 30),
			anchor = v(120, 0),
			text_shadow_offset = v(1, 1),
			colors = {
				text = {81, 51, 39, 255},
				text_shadow = {233, 209, 107, 255},
				background = {0, 0, 0, 0}
			}
		}}
	}}
}
