-- chunkname: @./all-desktop/data/kui_templates/game_editor_gui.lua

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "KWindow",
	r = 0,
	alpha = 1,
	clip = false,
	id = "window",
	anchor = {
		x = 0,
		y = 0
	},
	colors = {
		background = {
			0,
			0,
			0,
			0
		}
	},
	disabled_tint_color = {
		150,
		150,
		150,
		255
	},
	origin = {
		x = 0,
		y = 0
	},
	padding = {
		x = 0,
		y = 0
	},
	pos = {
		x = 0,
		y = 0
	},
	scale = {
		x = 1,
		y = 1
	},
	size = {
		x = 1440,
		y = 1080
	},
	children = {
		{
			id = "picker",
			class = "KEPicker",
			colors = {
				background = {
					0,
					0,
					0,
					0
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "tools",
			pos = {
				x = 100,
				y = 100
			},
			size = {
				x = 200,
				y = 500
			},
			colors = {
				background = {
					200,
					200,
					200,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "tools_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "关卡编辑器",
					class = "KLabel",
					id = "tools_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							class = "KEPointerPos",
							id = "tools_pointer_pos"
						},
						{
							class = "KESep",
							title = "Level"
						},
						{
							id = "tools_level_name",
							title = "关卡",
							class = "KEPropNum",
							value = 1
						},
						{
							id = "tools_game_mode",
							title = "游戏模式",
							class = "KEPropNum",
							value = 1
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "tools_save",
									class = "KEButton",
									title = "保存",
									size = {
										x = 86,
										y = 20
									}
								},
								{
									id = "tools_load",
									class = "KEButton",
									title = "加载",
									size = {
										x = 86,
										y = 20
									}
								}
							}
						},
						{
							id = "tools_undo",
							title = "撤销",
							class = "KEButton"
						},
						{
							class = "KESep",
							title = "Tools"
						},
						{
							id = "tools_general",
							title = "常规",
							class = "KEButton"
						},
						{
							id = "tools_entities",
							title = "实体",
							class = "KEButton"
						},
						{
							id = "tools_paths",
							title = "路径",
							class = "KEButton"
						},
						{
							id = "tools_grid",
							title = "网格",
							class = "KEButton"
						},
						{
							id = "tools_nav",
							title = "方向键导航",
							class = "KEButton"
						},
						{
							class = "KESep",
							title = "Toggles"
						},
						{
							id = "tg_safe_frame",
							title = "切换安全框",
							class = "KEButton"
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "general",
			pos = {
				x = 300,
				y = 100
			},
			size = {
				x = 200,
				y = 200
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "general_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "常规",
					class = "KLabel",
					id = "general_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "entities",
			pos = {
				x = 500,
				y = 100
			},
			size = {
				x = 200,
				y = 500
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "entities_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "实体",
					class = "KLabel",
					id = "entities_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "entities_selected",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							id = "entities_delete",
							title = "删除实体",
							class = "KEButton"
						},
						{
							id = "entities_duplicate",
							title = "复制实体",
							class = "KEButton"
						},
						{
							id = "entities_id",
							title = "Id",
							class = "KEProp",
							prop_name = "id"
						},
						{
							id = "entities_template",
							title = "模板名",
							class = "KEProp",
							prop_name = "template_name"
						},
						{
							id = "entities_pos",
							title = "坐标",
							class = "KEPropCoords",
							prop_name = "pos"
						},
						{
							id = "entities_custom_props",
							style = "vertical",
							class = "KELayout"
						}
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "entities_deselected",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "entities_show",
									title = "显示实体",
									class = "KEButton",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "entities_hide",
									title = "隐藏实体",
									class = "KEButton",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							id = "entities_insert",
							title = "插入实体",
							class = "KEButton"
						},
						{
							id = "entities_insert_template",
							title = "模板名",
							class = "KEProp",
							editable = true
						},
						{
							id = "entities_search",
							title = "搜索",
							class = "KEButton"
						},
						{
							class = "KEList",
							id = "entities_search_suggestions"
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "paths",
			pos = {
				x = 700,
				y = 100
			},
			size = {
				x = 200,
				y = 700
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "paths_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "路径",
					class = "KLabel",
					id = "paths_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "paths_props",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							style = "vertical",
							class = "KELayout",
							id = "paths_list_section",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									class = "KESep",
									title = "路径列表"
								},
								{
									id = "paths_list",
									class = "KEList",
									size = {
										x = 0,
										y = 80
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_create",
											title = "创建新路径",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_remove",
											title = "移除路径",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_move_up",
											title = "上移",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_move_down",
											title = "下移",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_duplicate",
											title = "复制路径",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_flip",
											title = "镜像",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									id = "path_preview",
									title = "查看子路径",
									class = "KEButton"
								},
								{
									id = "path_active",
									class = "KEPropBool",
									value = true,
									title = "活跃的",
									inactive_title = "inactive"
								},
								{
									id = "path_connects_to",
									title = "连接到路径",
									class = "KEPropNum",
									value = -1
								}
							}
						},
						{
							style = "vertical",
							class = "KELayout",
							id = "paths_node_selected",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									class = "KESep",
									title = "节点"
								},
								{
									id = "path_node_id",
									title = "当前选择的节点",
									class = "KEProp"
								},
								{
									id = "path_node_pos",
									title = "坐标",
									class = "KEPropCoords"
								},
								{
									id = "path_node_width",
									title = "路径节点宽度",
									class = "KEPropNum",
									value = 20
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_node_subdivide",
											title = "细分路径",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_node_extend",
											title = "扩充路径",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									id = "path_node_remove",
									title = "移除",
									class = "KEButton"
								}
							}
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "grid",
			pos = {
				x = 900,
				y = 100
			},
			size = {
				x = 200,
				y = 450
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "grid_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "网格",
					class = "KLabel",
					id = "grid_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							class = "KECellInfo",
							id = "cell_info"
						},
						{
							class = "KESep",
							title = "地形"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_type_none",
									class = "KEButton",
									title = "无",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_type_land",
									class = "KEButton",
									title = "陆地",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_type_water",
									class = "KEButton",
									title = "水",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_type_cliff",
									class = "KEButton",
									title = "悬崖",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "标签"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_shallow",
									class = "KEButton",
									title = "浅滩",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_flag_nowalk",
									class = "KEButton",
									title = "无法行走",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_faerie",
									class = "KEButton",
									title = "仙子",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_flag_ice",
									class = "KEButton",
									title = "冰",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_flying_nw",
									class = "KEButton",
									title = "飞行",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "笔刷大小"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "brush_size_inc",
									class = "KEButton",
									title = "+",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "brush_size_dec",
									class = "KEButton",
									title = "-",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "网格"
						},
						{
							style = "vertical",
							class = "KELayout",
							children = {
								{
									prop_name = "grid_size",
									class = "KEPropCoords",
									id = "grid_size",
									title = "单元格大小",
									step = 2
								},
								{
									prop_name = "grid_offset",
									class = "KEPropCoords",
									id = "grid_offset",
									title = "偏移 (px)",
									step = 16
								}
							}
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "nav",
			pos = {
				x = 300,
				y = 100
			},
			size = {
				x = 200,
				y = 440
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "nav_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "方向键导航",
					class = "KLabel",
					id = "nav_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = v(10, 30),
					children = {
						{
							class = "KESep",
							title = "模式"
						},
						{
							id = "nav_mode_override_active",
							class = "KEPropBool",
							value = true,
							title = "网",
							inactive_title = "默认"
						},
						{
							id = "nav_sel_id",
							title = "选择的 id",
							class = "KEProp",
							prop_name = "nav_sel_id"
						},
						{
							id = "nav_holder_id",
							title = "塔位 id",
							class = "KEProp",
							prop_name = "nav_holder_id"
						},
						{
							class = "KESep",
							title = "上/左/右/下"
						},
						{
							class = "KEEnum",
							id = "nav_id_top"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "nav_id_left",
									style = "half",
									class = "KEEnum"
								},
								{
									id = "nav_id_right",
									style = "half",
									class = "KEEnum"
								}
							}
						},
						{
							class = "KEEnum",
							id = "nav_id_bottom"
						},
						{
							class = "KESep",
							title = "actions"
						},
						{
							id = "nav_adds_missing_numbers",
							title = "adds missing numbers",
							class = "KEButton"
						},
						{
							id = "nav_nearest_sel",
							title = "nearest selected",
							class = "KEButton"
						},
						{
							id = "nav_nearest_all",
							title = "nearest all",
							class = "KEButton"
						},
						{
							id = "nav_clear_all",
							title = "clear all",
							class = "KEButton"
						},
						{
							id = "nav_renumber_holders",
							title = "renumber (WARN!)",
							class = "KEButton"
						}
					}
				}
			}
		}
	}
}
