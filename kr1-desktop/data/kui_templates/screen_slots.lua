-- chunkname: @./kr1-desktop/data/kui_templates/screen_slots.lua
local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "KWindow",
	id = "99001",
	colors = {
		background = {200, 200, 200, 255}
	},
	size = {
		x = 1440,
		y = 1080
	},
	children = {{
		id = "bg_view",
		class = "KImageView",
		image_name = "homeMenu_bg",
		anchor = {
			x = 960,
			y = 540
		},
		pos = {
			x = 720,
			y = 540
		},
		size = {
			x = 1920,
			y = 1080
		},
		children = {{
			class = "KView",
			id = "logo",
			image_name = "homeMenu_logo_0017",
			animation = {
				to = 17,
				prefix = "homeMenu_logo",
				from = 1
			},
			anchor = v(0, 0),
			pos = v(math.max(130, ctx.left_margin), 0)
		}, {
			id = "slot_panel",
			class = "KImageView",
			image_name = "homeMenu_submenues_0001",
			anchor = {
				x = -380,
				y = 420
			},
			pos = {
				x = 0,
				y = 1080
			},
			children = {{
				id = "slot_1",
				class = "SlotView",
				template_name = "slot_view",
				slot_idx = 1,
				pos = {
					x = 72,
					y = 60
				}
			}, {
				id = "slot_2",
				class = "SlotView",
				template_name = "slot_view",
				slot_idx = 2,
				pos = {
					x = 88,
					y = 170
				}
			}, {
				id = "slot_3",
				class = "SlotView",
				template_name = "slot_view",
				slot_idx = 3,
				pos = {
					x = 110,
					y = 282
				}
			}}
		}, {
			id = "banner",
			class = "KImageView",
			image_name = "homeMenu_buttonsBg",
			anchor = {
				x = 0,
				y = 448
			},
			pos = {
				x = 100,
				y = 1080
			},
			children = {{
				hover_image_name = "homeMenu_btnStart_en_0002",
				click_image_name = "homeMenu_btnStart_en_0003",
				class = "KImageButton",
				id = "banner_button_start",
				default_image_name = "homeMenu_btnStart_en_0001",
				pos = {
					x = 179,
					y = 107
				}
			}, {
				hover_image_name = "homeMenu_btnOptions_en_0002",
				click_image_name = "homeMenu_btnOptions_en_0003",
				class = "KImageButton",
				id = "banner_button_options",
				default_image_name = "homeMenu_btnOptions_en_0001",
				pos = {
					x = 210,
					y = 262
				}
			}, {
				hover_image_name = "homeMenu_btnCredits_en_0002",
				click_image_name = "homeMenu_btnCredits_en_0003",
				class = "KImageButton",
				id = "banner_button_credits",
				default_image_name = "homeMenu_btnCredits_en_0001",
				pos = {
					x = 230,
					y = 362
				}
			}}
		}, {
			r = -0.1,
			hover_image_name = "homeMenu_quit_0002",
			label_font_size = 38,
			label_text_key = "QUIT",
			label_text_align = "center",
			label_fit_lines = 1,
			class = "GGButton",
			label_vertical_align = "middle",
			id = "banner_button_quit",
			default_image_name = "homeMenu_quit_0001",
			pos = {
				x = 1550,
				y = 1080
			},
			anchor = v(100, 170),
			label_size = v(110, 50),
			label_pos = v(58, 76)
		}, {
			class = "PopUpView",
			id = "delete_view",
			colors = {
				background = {0, 0, 0, 80}
			},
			size = {
				x = 1920,
				y = 1080
			},
			children = {{
				id = "99029",
				class = "KImageView",
				image_name = "homeMenu_confirm_menu_0001",
				anchor = {
					x = 360,
					y = 130
				},
				pos = {
					x = 960,
					y = 490
				},
				size = {
					x = 960,
					y = 260
				},
				children = {{
					id = "99030",
					font_size = 28.125,
					class = "GGOptionsLabel",
					text_key = "DELETE SLOT?",
					font_name = "h",
					anchor = {
						x = 280,
						y = 15
					},
					pos = {
						x = 360,
						y = 86.666666666667
					},
					size = {
						x = 560,
						y = 30
					}
				}, {
					id = "delete_button_yes",
					class = "GGOptionsButton",
					label_text_key = "Yes",
					anchor = {
						x = 97,
						y = 0
					},
					pos = {
						x = 250,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}, {
					id = "delete_button_no",
					class = "GGOptionsButton",
					label_text_key = "No",
					anchor = {
						x = 97,
						y = 0
					},
					pos = {
						x = 470,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}}
			}}
		}, {
			class = "PopUpView",
			id = "quit_view",
			colors = {
				background = {0, 0, 0, 80}
			},
			size = {
				x = 1920,
				y = 1080
			},
			children = {{
				id = "99036",
				class = "KImageView",
				image_name = "homeMenu_confirm_menu_0001",
				anchor = {
					x = 360,
					y = 130
				},
				pos = {
					x = 960,
					y = 540
				},
				size = {
					x = 960,
					y = 260
				},
				children = {{
					id = "99037",
					font_size = 28.125,
					class = "GGOptionsLabel",
					text_key = "ARE YOU SURE YOU WANT TO QUIT?",
					font_name = "h",
					anchor = {
						x = 280,
						y = 15
					},
					pos = {
						x = 360,
						y = 86.666666666667
					},
					size = {
						x = 560,
						y = 30
					}
				}, {
					id = "quit_button_yes",
					class = "GGOptionsButton",
					label_text_key = "Yes",
					anchor = {
						x = 97,
						y = 0
					},
					pos = {
						x = 250,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}, {
					id = "quit_button_no",
					class = "GGOptionsButton",
					label_text_key = "No",
					anchor = {
						x = 97,
						y = 0
					},
					pos = {
						x = 470,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}}
			}}
		}, {
			class = "PopUpView",
			id = "options_view",
			colors = {
				background = {0, 0, 0, 80}
			},
			size = {
				x = 1920,
				y = 1080
			},
			children = {{
				id = "99043",
				class = "KImageView",
				image_name = "main_options_bg_notxt",
				anchor = {
					x = 350,
					y = 185
				},
				pos = {
					x = 960,
					y = 490
				},
				size = {
					x = 700,
					y = 370
				},
				children = {{
					text = "OPCIONES",
					text_key = "OPTIONS",
					class = "GGPanelHeader",
					id = "99044",
					pos = {
						x = 232,
						y = 18
					},
					size = {
						x = 242,
						y = 45
					}
				}, {
					vertical_align = "top",
					text_key = "SFX",
					class = "GGOptionsLabel",
					fit_size = true,
					id = "99045",
					pos = {
						x = 250,
						y = 78
					},
					size = {
						x = 200,
						y = 32
					}
				}, {
					image_name = "options_barBg",
					style = "sfx",
					class = "VolumeSlider",
					id = "s_sfx",
					pos = {
						x = 139,
						y = 118
					},
					size = {
						x = 422,
						y = 34
					}
				}, {
					vertical_align = "top",
					text_key = "Music",
					class = "GGOptionsLabel",
					fit_size = true,
					id = "99049",
					pos = {
						x = 250,
						y = 170
					},
					size = {
						x = 200,
						y = 32
					}
				}, {
					image_name = "options_barBg",
					style = "music",
					class = "VolumeSlider",
					id = "s_music",
					pos = {
						x = 139,
						y = 210
					},
					size = {
						x = 422,
						y = 34
					}
				}, {
					hover_image_name = "options_button_bg_0002",
					label_text_key = "Done",
					image_name = "options_button_bg_0001",
					class = "GGOptionsButton",
					id = "options_button_done",
					default_image_name = "options_button_bg_0001",
					click_image_name = "options_button_bg_0002",
					anchor = {
						x = 97,
						y = 0
					},
					pos = {
						x = 350,
						y = 255
					},
					size = {
						x = 194,
						y = 76
					}
				}}
			}}
		}, {
			class = "PopUpView",
			id = "cloudsave_progress_view",
			colors = {
				background = {0, 0, 0, 80}
			},
			size = {
				x = 1920,
				y = 1080
			},
			children = {{
				class = "KImageView",
				image_name = "homeMenu_confirm_menu_0001",
				anchor = {
					x = 360,
					y = 130
				},
				colors = {},
				pos = {
					x = 960,
					y = 540
				},
				size = {
					x = 960,
					y = 260
				},
				children = {{
					font_size = 28.125,
					fit_step = 0.5,
					class = "GGOptionsLabel",
					text_key = "UPDATING_CLOUDSAVE_MESSAGE",
					font_name = "h",
					anchor = {
						x = 280,
						y = 15
					},
					colors = {
						text = {233, 233, 178, 255}
					},
					pos = {
						x = 360,
						y = 86.666666666667
					},
					size = {
						x = 560,
						y = 30
					},
					text_shadow_offset = {
						x = 1,
						y = 1
					}
				}, {
					hover_image_name = "options_button_bg_0002",
					label_font_name = "h",
					label_font_size = 23.90625,
					label_text = "Cancel",
					image_name = "options_button_bg_0001",
					label_text_key = "Cancel",
					class = "GGOptionsButton",
					id = "cloudsave_cancel_button",
					default_image_name = "options_button_bg_0001",
					click_image_name = "options_button_bg_0002",
					anchor = {
						x = 97,
						y = 0
					},
					label_colors = {
						default = {233, 233, 178, 255},
						hover = {246, 228, 132, 255}
					},
					pos = {
						x = 350,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}}
			}}
		}, {
			class = "PopUpView",
			id = "cloudsave_error_view",
			colors = {
				background = {0, 0, 0, 80}
			},
			size = {
				x = 1920,
				y = 1080
			},
			children = {{
				class = "KImageView",
				image_name = "homeMenu_confirm_menu_0001",
				anchor = {
					x = 360,
					y = 130
				},
				colors = {},
				pos = {
					x = 960,
					y = 540
				},
				size = {
					x = 960,
					y = 260
				},
				children = {{
					text_key = "ERROR_MESSAGE_GENERIC",
					font_size = 28.125,
					fit_step = 0.5,
					class = "GGOptionsLabel",
					id = "cloudsave_error_label",
					font_name = "h",
					anchor = {
						x = 280,
						y = 15
					},
					colors = {
						text = {233, 233, 178, 255}
					},
					pos = {
						x = 360,
						y = 75
					},
					size = {
						x = 560,
						y = 30
					},
					text_shadow_offset = {
						x = 1,
						y = 1
					}
				}, {
					text = "Error code: XXX",
					font_size = 28.125,
					fit_step = 0.5,
					class = "GGOptionsLabel",
					id = "cloudsave_error_code_label",
					font_name = "h",
					anchor = {
						x = 280,
						y = 15
					},
					colors = {
						text = {233, 233, 178, 255}
					},
					pos = {
						x = 360,
						y = 110
					},
					size = {
						x = 560,
						y = 30
					},
					text_shadow_offset = {
						x = 1,
						y = 1
					}
				}, {
					hover_image_name = "options_button_bg_0002",
					label_font_name = "h",
					label_font_size = 23.90625,
					label_text_key = "Done",
					image_name = "options_button_bg_0001",
					class = "GGOptionsButton",
					id = "cloudsave_close_button",
					default_image_name = "options_button_bg_0001",
					click_image_name = "options_button_bg_0002",
					anchor = {
						x = 97,
						y = 0
					},
					label_colors = {
						default = {233, 233, 178, 255},
						hover = {246, 228, 132, 255}
					},
					pos = {
						x = 350,
						y = 130
					},
					size = {
						x = 194,
						y = 76
					}
				}}
			}}
		}}
	}}
}
