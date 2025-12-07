-- chunkname: @./kr3/data/levels/level14_spawner.lua
return {
	groups = {
		{1},
		eggAll = {
			"egg0",
			"egg1",
			"egg2",
			"egg3",
			"egg4",
			"egg5",
			"egg6",
			"egg7",
			"egg8",
			"egg9",
			"egg10"
		},
		eggCentral = {"egg0", "egg1", "egg2", "egg3"},
		eggDownpLeft = {"egg4", "egg5", "egg6"},
		eggRight = {"egg7", "egg8"},
		eggUpLeft = {"egg9", "egg10"},
		eggUpper = {"egg0", "egg1", "egg2", "egg3", "egg7", "egg8", "egg9", "egg10"},
		som1 = {"som1"},
		som2 = {"som2"},
		som3 = {"som3"},
		som4 = {"som4"},
		som5 = {"som5"},
		som6 = {"som6"},
		som7 = {"som7"},
		som8 = {"som8"},
		som9 = {"som9"},
		som10 = {"som10"},
		som11 = {"som11"},
		som12 = {"som12"},
		som13 = {"som13"},
		som14 = {"som14"},
		som15 = {"som15"},
		som16 = {"som16"},
		som17 = {"som17"},
		som18 = {"som18"},
		som19 = {"som19"},
		som20 = {"som20"},
		somAll = {
			"som1",
			"som2",
			"som3",
			"som4",
			"som5",
			"som6",
			"som8",
			"som9",
			"som10",
			"som11",
			"som12",
			"som13",
			"som14",
			"som15",
			"som16",
			"som17",
			"som18",
			"som19",
			"som20",
			"som7"
		},
		somCaveDer = {"som5", "som6"},
		somCaveIzq = {"som1", "som2", "som3", "som4"},
		somCentral = {"som10", "som11", "som12", "som13"},
		somPaths = {"som14", "som15", "som16", "som17", "som18", "som19", "som20", "som7"},
		somRight = {"som8", "som9"}
	},
	points = {
		{
			path = 1,
			from = {
				x = 830,
				y = 150
			},
			to = {
				x = 830,
				y = 250
			}
		},
		som1 = {
			path = 1,
			from = {
				x = 191,
				y = 585
			},
			to = {
				x = 191,
				y = 585
			}
		},
		som2 = {
			path = 1,
			from = {
				x = 225,
				y = 617
			},
			to = {
				x = 225,
				y = 617
			}
		},
		som3 = {
			path = 1,
			from = {
				x = 266,
				y = 597
			},
			to = {
				x = 266,
				y = 597
			}
		},
		som4 = {
			path = 1,
			from = {
				x = 234,
				y = 572
			},
			to = {
				x = 234,
				y = 572
			}
		},
		som5 = {
			path = 2,
			from = {
				x = 562,
				y = 617
			},
			to = {
				x = 562,
				y = 617
			}
		},
		som6 = {
			path = 3,
			from = {
				x = 593,
				y = 636
			},
			to = {
				x = 593,
				y = 636
			}
		},
		som7 = {
			path = 4,
			from = {
				x = 745,
				y = 610
			},
			to = {
				x = 745,
				y = 610
			}
		},
		som8 = {
			path = 3,
			from = {
				x = 708,
				y = 464
			},
			to = {
				x = 708,
				y = 464
			}
		},
		som9 = {
			path = 5,
			from = {
				x = 765,
				y = 456
			},
			to = {
				x = 765,
				y = 456
			}
		},
		som10 = {
			path = 3,
			from = {
				x = 504,
				y = 430
			},
			to = {
				x = 504,
				y = 430
			}
		},
		som11 = {
			path = 2,
			from = {
				x = 459,
				y = 410
			},
			to = {
				x = 459,
				y = 410
			}
		},
		som12 = {
			path = 2,
			from = {
				x = 499,
				y = 351
			},
			to = {
				x = 499,
				y = 351
			}
		},
		som13 = {
			path = 3,
			from = {
				x = 557,
				y = 351
			},
			to = {
				x = 557,
				y = 351
			}
		},
		som14 = {
			path = 1,
			from = {
				x = 135,
				y = 417
			},
			to = {
				x = 135,
				y = 417
			}
		},
		som15 = {
			path = 1,
			from = {
				x = 244,
				y = 401
			},
			to = {
				x = 244,
				y = 401
			}
		},
		som16 = {
			path = 4,
			from = {
				x = 286,
				y = 302
			},
			to = {
				x = 286,
				y = 302
			}
		},
		som17 = {
			path = 2,
			from = {
				x = 399,
				y = 282
			},
			to = {
				x = 399,
				y = 282
			}
		},
		som18 = {
			path = 3,
			from = {
				x = 646,
				y = 269
			},
			to = {
				x = 646,
				y = 269
			}
		},
		som19 = {
			path = 7,
			from = {
				x = 784,
				y = 282
			},
			to = {
				x = 784,
				y = 282
			}
		},
		som20 = {
			path = 7,
			from = {
				x = 864,
				y = 475
			},
			to = {
				x = 864,
				y = 475
			}
		}
	},
	waves = {{
		{{2.5, 0.5, "somCaveIzq", nil, 3, false, true, 6, 6, "spider_son_of_mactans_drop_spawner"}, {9.166666666666666, 0.5, "som4", nil, 3, false, true, 5, 6, "spider_son_of_mactans_drop_spawner"}, {9.166666666666666, 0.5, "som14", nil, 2, false, true, 5, 6, "spider_son_of_mactans_drop_spawner"}},
		[3] = {{
			0.6666666666666666,
			0,
			"eggCentral",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {0.6666666666666666, 0.5, "somCaveIzq", nil, 4, false, true, 8, 8, "spider_son_of_mactans_drop_spawner"}, {
			13.333333333333334,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			26.666666666666668,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			36.666666666666664,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			41.666666666666664,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			46.666666666666664,
			0,
			"eggDownpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}},
		[4] = {{
			0.6666666666666666,
			0,
			"eggUpper",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			31.666666666666668,
			0,
			"eggCentral",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {
			31.666666666666668,
			0,
			"eggRight",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}},
		[5] = {{13.333333333333334, 0.5, "som1", nil, 1, false, true, 2, 3, "spider_son_of_mactans_drop_spawner"}, {16.333333333333336, 0.5, "som14", nil, 1, false, true, 2, 3, "spider_son_of_mactans_drop_spawner"}, {19.333333333333336, 0.5, "som16", nil, 1, false, true, 2, 3, "spider_son_of_mactans_drop_spawner"}},
		[6] = {{
			0.6666666666666666,
			0,
			"eggAll",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 1
			}
		}, {11.666666666666666, 0.5, "somCentral", nil, 4, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"}, {20, 0.5, "somCaveIzq", nil, 4, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"}, {27, 0.5, "som14", nil, 1, false, true, 2, 3, "spider_son_of_mactans_drop_spawner"}, {29, 0.5, "som16", nil, 1, false, true, 2, 3, "spider_son_of_mactans_drop_spawner"}},
		[8] = {{
			0.6666666666666666,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 2
			}
		}, {
			8.333333333333334,
			0,
			"eggRight",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 2
			}
		}, {
			13.333333333333334,
			0,
			"eggUpLeft",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 2
			}
		}, {
			38.333333333333336,
			0,
			"eggRight",
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"CUSTOM",
			{
				cantSpiders = 2
			}
		}},
		[9] = {
			{3.3333333333333335, 0.5, "som17", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{3.3333333333333335, 0.5, "som14", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{3.3333333333333335, 0.5, "som15", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{10, 0.5, "som18", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{10, 0.5, "som19", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{10, 0.5, "som20", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "somRight", nil, 4, false, true, 1, 2, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som7", nil, 3, false, true, 1, 2, "spider_son_of_mactans_drop_spawner"},
			{41.666666666666664, 0.5, "som1", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{41.666666666666664, 0.5, "som2", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{42.666666666666664, 0.5, "som3", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{43.666666666666664, 0.5, "som4", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{41.666666666666664, 0.5, "som10", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{41.666666666666664, 0.5, "som11", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{42.666666666666664, 0.5, "som12", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{43.666666666666664, 0.5, "som13", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{50, 0.5, "som5", nil, 2, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{53, 0.5, "som11", nil, 1, false, true, 1, 2, "spider_son_of_mactans_drop_spawner"}
		},
		[14] = {
			{6.666666666666667, 0.5, "som1", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{7.666666666666667, 0.5, "som3", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{7.666666666666667, 0.5, "som4", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{6.666666666666667, 0.5, "som10", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{6.666666666666667, 0.5, "som12", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{6.666666666666667, 0.5, "som13", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som17", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som18", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som15", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som19", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som14", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{25, 0.5, "som20", nil, 1, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"},
			{30, 0.5, "somRight", nil, 4, false, true, 3, 3, "spider_son_of_mactans_drop_spawner"},
			{30, 0.5, "som7", nil, 3, false, true, 1, 2, "spider_son_of_mactans_drop_spawner"},
			{55, 0.5, "somRight", nil, 4, false, true, 4, 4, "spider_son_of_mactans_drop_spawner"},
			{59, 0.5, "som20", nil, 4, false, true, 4, 4, "spider_son_of_mactans_drop_spawner"},
			{60, 0.5, "somCaveDer", nil, 4, false, true, 4, 4, "spider_son_of_mactans_drop_spawner"}
		},
		[15] = {{20, 0.5, "somAll", nil, 12, false, true, 3, 3, "spider_son_of_mactans_drop_spawner"}, {61.666666666666664, 0.5, "somAll", nil, 15, false, true, 1, 1, "spider_son_of_mactans_drop_spawner"}}
	}, {
		{{2.3333333333333335, 0.5, "som8", nil, 1, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {2.3333333333333335, 0.5, "som20", nil, 1, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {2.3333333333333335, 0.5, "som6", nil, 1, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som8", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som20", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som6", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}},
		[4] = {{2.3333333333333335, 0.5, "som1", nil, 2, false, true, 2, 5, "spider_son_of_mactans_drop_spawner"}, {2.3333333333333335, 0.5, "som15", nil, 2, false, true, 2, 5, "spider_son_of_mactans_drop_spawner"}, {2.3333333333333335, 0.5, "som16", nil, 2, false, true, 2, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som8", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som20", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}, {19, 0.5, "som6", nil, 2, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}}
	}, {{{
		0.3333333333333333,
		0,
		"eggAll",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"CUSTOM",
		{
			cantSpiders = 1
		}
	}, {
		13.333333333333334,
		0,
		"eggAll",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"CUSTOM",
		{
			cantSpiders = 1
		}
	}, {
		46.666666666666664,
		0,
		"eggCentral",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"CUSTOM",
		{
			cantSpiders = 1
		}
	}, {
		26.666666666666668,
		0,
		"eggCentral",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"CUSTOM",
		{
			cantSpiders = 1
		}
	}, {1.6666666666666667, 0.5, "somAll", nil, 3, false, true, 3, 4, "spider_son_of_mactans_drop_spawner"}, {16.666666666666668, 0.5, "somAll", nil, 7, false, true, 2, 4, "spider_son_of_mactans_drop_spawner"}, {26.666666666666668, 0.5, "somCaveIzq", nil, 4, false, true, 3, 4, "spider_son_of_mactans_drop_spawner"}, {31.666666666666668, 0.5, "somCaveDer", nil, 4, false, true, 3, 4, "spider_son_of_mactans_drop_spawner"}, {50, 0.5, "somCaveIzq", nil, 6, false, true, 4, 5, "spider_son_of_mactans_drop_spawner"}}}}
}
