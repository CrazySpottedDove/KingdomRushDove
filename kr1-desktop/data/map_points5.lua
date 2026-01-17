-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2-desktop/data/map_points.lua

local V = require("lib.klua.vector")
local v = V.v

local a = {

	--RATE_X = 1920/2432,
	--RATE_Y = 1080/1368,
	OFFSET_X = 215 + 54,
	OFFSET_Y = 475 + 187 + 156,
	OFFSET_X1 = 30,
	OFFSET_Y1 = 100,
	RATE_X = 1,
	RATE_Y = 1,
	--OFFSET_X = 0,
	--OFFSET_Y = 0,
	--OFFSET_X1 = 0,
	--OFFSET_Y1 = 0,

	flags = {
		{
			number = "1",
			pos = v(130.9, 297.95)
		},
		{
			number = "2",
			pos = v(431.15, 406.15)
		},
		{
			number = "3",
			pos = v(358, 184.95)
		},
		{
			number = "4",
			pos = v(298.75, -122.25)
		},
		{
			number = "5",
			pos = v(649.75, -12.3)
		},
		{
			number = "6",
			pos = v(806.95, 160.8)
		},
		{
			number = "7",
			pos = v(1099.1, 22.95)
		},
		{
			number = "8",
			pos = v(889.35, -181.4)
		},
		{
			number = "9",
			pos = v(734.6, -273.65)
		},
		{
			number = "10",
			pos = v(881.7, -376.85)
		},
		{
			number = "11",
			pos = v(1141.6, -359.15)
		},
		{
			number = "12",
			pos = v(1482.05, -550.25)
		},
		{
			number = "13",
			pos = v(1429.85, -315.05)
		},
		{
			number = "14",
			pos = v(1536.55, -118.5)
		},
		{
			number = "15",
			pos = v(1818.8, -226.35)
		},
		{
			number = "16",
			pos = v(1685.9, -415.95)
		},
		{
			number = "17",
			pos = v(-11.8, -199.15)
		},
		{
			number = "18",
			pos = v(178.55, -303.95)
		},
		{
			number = "19",
			pos = v(341.85, -338.5)
		},
		{
			number = "20",
			pos = v(544.5, 497.1)
		},
		{
			number = "21",
			pos = v(683.65, 665.55)
		},
		{
			number = "22",
			pos = v(333.8, 685.05)
		},
		{
			number = "23",
			pos = v(1490.75, 462.8)
		},
		{
			number = "24",
			pos = v(1393.05, 300.9)
		},
		{
			number = "25",
			pos = v(1604.55, 325.65)
		},
		{
			number = "26",
			pos = v(1855, 275.8)
		},
		{
			number = "27",
			pos = v(1761.5, 183.35)
		},
		{
			number = "28",
			pos = v(1035.15, -487.5)
		},
		{
			number = "29",
			pos = v(958.1, -591.5)
		},
		{
			number = "30",
			pos = v(702.05, -600.5)
		},
		{
			number = "31",
			pos = v(1050.6, 641.7)
		},
		{
			number = "32",
			pos = v(1209.2, 783.85)
		--pos = v(1209.2, 703.85)
		},
		{
			number = "33",
			--pos = v(1339.75, 679.5)
			pos = v(1339.75, 759.5)
		},
		{
			number = "34",
			pos = v(1215.5, 596.5)
		},
		{
			number = "35",
			pos = v(1446.05, 657.8)
		}
	},

	endless_flags = {},

	points = {},


	points_20250411 = {
		{
			id = "02",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 102,
			pos = v(186.25, 158.3),
			children = {
				{
					id = "12",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-67.05, 73.35)
				},
				{
					id = "11",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-43.45, 82.05)
				},
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-24.15, 89.6)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-6, 104.65)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(11.45, 122.7)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(28.65, 137.6)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(44.6, 151)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(66.75, 162.6)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(88.85, 168.95)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(117.2, 168.2)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(142.85, 165.8)
				},
				{
					id = "1",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(171.05, 169.9)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 95,
					id = "12",
					f = 8,
					pos = v(-67.05, 73.35)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 88,
					id = "11",
					f = 15,
					pos = v(-43.45, 82.05)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 81,
					id = "10",
					f = 22,
					pos = v(-24.15, 89.6)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 74,
					id = "9",
					f = 29,
					pos = v(-6, 104.65)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 67,
					id = "8",
					f = 36,
					pos = v(11.45, 122.7)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 60,
					id = "7",
					f = 43,
					pos = v(28.65, 137.6)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 53,
					id = "6",
					f = 50,
					pos = v(44.6, 151)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 46,
					id = "5",
					f = 57,
					pos = v(66.75, 162.6)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 39,
					id = "4",
					f = 64,
					pos = v(88.85, 168.95)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 32,
					id = "3",
					f = 71,
					pos = v(117.2, 168.2)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 25,
					id = "2",
					f = 78,
					pos = v(142.85, 165.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 18,
					id = "1",
					f = 85,
					pos = v(171.05, 169.9)
				}
			}
		},
		{
			id = "03",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 95,
			pos = v(408.85, 129.9),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(14.1, 202.95)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(36.65, 189)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(41.2, 169.95)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(35.35, 154.55)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-12.65, 19.7)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-32, 11.3)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-48.55, -2.6)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-67.55, -10.5)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 88,
				id = "7",
				f = 8,
				pos = v(14.1, 202.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 81,
				id = "6",
				f = 15,
				pos = v(36.65, 189)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 74,
				id = "5",
				f = 22,
				pos = v(41.2, 169.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 67,
				id = "4",
				f = 29,
				pos = v(35.35, 154.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 32,
				id = "3",
				f = 64,
				pos = v(-12.65, 19.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 25,
				id = "2",
				f = 71,
				pos = v(-32, 11.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 18,
				id = "1",
				f = 78,
				pos = v(-48.55, -2.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 11,
				id = "0",
				f = 85,
				pos = v(-67.55, -10.5)
			}}
		},
		{
			id = "04",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 93,
			pos = v(304.75, -97.55),
			children = {{
				id = "10",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-7.05, 205)
			}, {
				id = "9",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-31.2, 198.05)
			}, {
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-51.55, 185.6)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-69.15, 165.5)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-83.8, 146.95)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-95.6, 128.5)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-96.95, 107.6)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-85.75, 90.7)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-73.75, -64.55)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-62.25, -81.35)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 79,
				id = "10",
				f = 15,
				pos = v(-7.05, 205)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 72,
				id = "9",
				f = 22,
				pos = v(-31.2, 198.05)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 65,
				id = "8",
				f = 29,
				pos = v(-51.55, 185.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 58,
				id = "7",
				f = 36,
				pos = v(-69.15, 165.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 51,
				id = "6",
				f = 43,
				pos = v(-83.8, 146.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 44,
				id = "5",
				f = 50,
				pos = v(-95.6, 128.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 37,
				id = "4",
				f = 57,
				pos = v(-96.95, 107.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 23,
				id = "2",
				f = 71,
				pos = v(-85.75, 90.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 16,
				id = "1",
				f = 78,
				pos = v(-73.75, -64.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 9,
				id = "0",
				f = 85,
				pos = v(-62.25, -81.35)
			}}
		},
		{
			id = "05",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 97,
			pos = v(424.95, -355.2),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-136.3, 148.4)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-115.1, 137.8)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(19.55, 183.4)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(32.7, 197.7)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(49.7, 207.6)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(135.65, 237.4)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(147.95, 255.2)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(167.75, 262.75)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 90,
				id = "7",
				f = 8,
				pos = v(-136.3, 148.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 83,
				id = "6",
				f = 15,
				pos = v(-115.1, 137.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 48,
				id = "5",
				f = 50,
				pos = v(19.55, 183.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 41,
				id = "4",
				f = 57,
				pos = v(32.7, 197.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 34,
				id = "3",
				f = 64,
				pos = v(49.7, 207.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 27,
				id = "2",
				f = 71,
				pos = v(135.65, 237.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 20,
				id = "1",
				f = 78,
				pos = v(147.95, 255.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 13,
				id = "0",
				f = 85,
				pos = v(167.75, 262.75)
			}}
		},
		{
			id = "06",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 72,
			pos = v(808.05, -156.75),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-177.4, 85.25)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-132.45, 169.05)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-122.55, 187.6)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-111.35, 202.85)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-99.8, 218.2)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-83.6, 233)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-64, 242.35)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 65,
				id = "7",
				f = 8,
				pos = v(-177.4, 85.25)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 45,
				id = "6",
				f = 28,
				pos = v(-132.45, 169.05)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 38,
				id = "5",
				f = 35,
				pos = v(-122.55, 187.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 31,
				id = "4",
				f = 42,
				pos = v(-111.35, 202.85)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 24,
				id = "3",
				f = 49,
				pos = v(-99.8, 218.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 17,
				id = "2",
				f = 56,
				pos = v(-83.6, 233)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 10,
				id = "1",
				f = 63,
				pos = v(-64, 242.35)
			}}
		},
		{
			id = "07",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 137,
			pos = v(862.1, -18.8),
			children = {
				{
					id = "18",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-65.45, 108.55)
				},
				{
					id = "17",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-42, 110.55)
				},
				{
					id = "16",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-20.5, 110.5)
				},
				{
					id = "15",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(3.35, 110.25)
				},
				{
					id = "14",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(26.5, 108.5)
				},
				{
					id = "13",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(48.95, 111.2)
				},
				{
					id = "12",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(70.05, 116.85)
				},
				{
					id = "11",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(92.95, 114.3)
				},
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(114.6, 104.6)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(136.5, 98.35)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(159.25, 92.25)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(179.85, 83.4)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(191.6, 67.85)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(189.6, 48.55)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(181.05, 33.3)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(173.4, 15.3)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(181.4, -0.25)
				},
				{
					id = "1",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(195.05, -12.7)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 130,
					id = "18",
					f = 8,
					pos = v(-65.45, 108.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 124,
					id = "17",
					f = 14,
					pos = v(-42, 110.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 117,
					id = "16",
					f = 21,
					pos = v(-20.5, 110.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 110,
					id = "15",
					f = 28,
					pos = v(3.35, 110.25)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 103,
					id = "14",
					f = 35,
					pos = v(26.5, 108.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 96,
					id = "13",
					f = 42,
					pos = v(48.95, 111.2)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 89,
					id = "12",
					f = 49,
					pos = v(70.05, 116.85)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 82,
					id = "11",
					f = 56,
					pos = v(92.95, 114.3)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 75,
					id = "10",
					f = 63,
					pos = v(114.6, 104.6)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 68,
					id = "9",
					f = 70,
					pos = v(136.5, 98.35)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 61,
					id = "8",
					f = 77,
					pos = v(159.25, 92.25)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 54,
					id = "7",
					f = 84,
					pos = v(179.85, 83.4)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 47,
					id = "6",
					f = 91,
					pos = v(191.6, 67.85)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 40,
					id = "5",
					f = 98,
					pos = v(189.6, 48.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 33,
					id = "4",
					f = 105,
					pos = v(181.05, 33.3)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 26,
					id = "3",
					f = 112,
					pos = v(173.4, 15.3)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 19,
					id = "2",
					f = 119,
					pos = v(181.4, -0.25)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 13,
					id = "1",
					f = 125,
					pos = v(195.05, -12.7)
				}
			}
		},
		{
			id = "08",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 134,
			pos = v(1041.85, -222.45),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(11.6, 157.6)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(3.75, 141.2)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(0, 126.3)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-10.3, 111.95)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-21.55, 97.25)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-143.2, 18.7)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-152.95, 4.35)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-157.15, -12.85)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-175.5, -22)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 96,
				id = "8",
				f = 39,
				pos = v(11.6, 157.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 89,
				id = "7",
				f = 46,
				pos = v(3.75, 141.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 82,
				id = "6",
				f = 53,
				pos = v(0, 126.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 75,
				id = "5",
				f = 60,
				pos = v(-10.3, 111.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 68,
				id = "4",
				f = 67,
				pos = v(-21.55, 97.25)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 42,
				id = "3",
				f = 93,
				pos = v(-143.2, 18.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 35,
				id = "2",
				f = 100,
				pos = v(-152.95, 4.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 28,
				id = "1",
				f = 107,
				pos = v(-157.15, -12.85)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 21,
				id = "0",
				f = 114,
				pos = v(-175.5, -22)
			}}
		},
		{
			id = "09",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 82,
			pos = v(583.75, -496.9),
			children = {{
				id = "10",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(241.65, 241.4)
			}, {
				id = "9",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(224.5, 228.5)
			}, {
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(222.55, 211.65)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(207.8, 200.2)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(156.4, 160)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(136.15, 155)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 75,
				id = "10",
				f = 8,
				pos = v(241.65, 241.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 68,
				id = "9",
				f = 15,
				pos = v(224.5, 228.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 61,
				id = "8",
				f = 22,
				pos = v(222.55, 211.65)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 54,
				id = "7",
				f = 29,
				pos = v(207.8, 200.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 41,
				id = "5",
				f = 42,
				pos = v(156.4, 160)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 35,
				id = "4",
				f = 48,
				pos = v(136.15, 155)
			}}
		},
		{
			id = "10",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 95,
			pos = v(653.7, -606.55),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(18.1, 261.7)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(1.85, 251.55)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(8.45, 236)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(21.9, 224.65)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(98.8, 168.45)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(118.55, 158.7)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(140.6, 154.55)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(162, 158.45)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 88,
				id = "8",
				f = 8,
				pos = v(18.1, 261.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 81,
				id = "7",
				f = 15,
				pos = v(1.85, 251.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 47,
				id = "6",
				f = 49,
				pos = v(8.45, 236)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 40,
				id = "5",
				f = 56,
				pos = v(21.9, 224.65)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 26,
				id = "3",
				f = 70,
				pos = v(98.8, 168.45)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 20,
				id = "2",
				f = 76,
				pos = v(118.55, 158.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 15,
				id = "1",
				f = 81,
				pos = v(140.6, 154.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 10,
				id = "0",
				f = 86,
				pos = v(162, 158.45)
			}}
		},
		{
			id = "11",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 107,
			pos = v(942.25, -541.15),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-73.4, 87.4)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-50.3, 86.3)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-28.4, 88.65)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-7.6, 90.2)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(78, 103.05)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(92.7, 111.6)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(114.15, 109.65)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(135.65, 112.35)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 100,
				id = "7",
				f = 8,
				pos = v(-73.4, 87.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 93,
				id = "6",
				f = 15,
				pos = v(-50.3, 86.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 86,
				id = "5",
				f = 22,
				pos = v(-28.4, 88.65)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 79,
				id = "4",
				f = 29,
				pos = v(-7.6, 90.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 45,
				id = "3",
				f = 63,
				pos = v(78, 103.05)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 38,
				id = "2",
				f = 70,
				pos = v(92.7, 111.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 31,
				id = "1",
				f = 77,
				pos = v(114.15, 109.65)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 24,
				id = "0",
				f = 84,
				pos = v(135.65, 112.35)
			}}
		},
		{
			id = "12",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 121,
			pos = v(1263.75, -635.15),
			children = {
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-136.9, 196.8)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-123.45, 185.15)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-113.55, 170.5)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-118.55, 154.3)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-116.05, 136.55)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-112, 118.7)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(180.35, 139.05)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(192.8, 152.5)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(200.75, 167.65)
				},
				{
					id = "1",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(203.4, 181.45)
				},
				{
					id = "0",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(195.95, 197.65)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 112,
					id = "10",
					f = 10,
					pos = v(-136.9, 196.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 106,
					id = "9",
					f = 16,
					pos = v(-123.45, 185.15)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 100,
					id = "8",
					f = 22,
					pos = v(-113.55, 170.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 93,
					id = "7",
					f = 29,
					pos = v(-118.55, 154.3)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 86,
					id = "6",
					f = 36,
					pos = v(-116.05, 136.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 79,
					id = "5",
					f = 43,
					pos = v(-112, 118.7)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 55,
					id = "4",
					f = 67,
					pos = v(180.35, 139.05)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 48,
					id = "3",
					f = 74,
					pos = v(192.8, 152.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 41,
					id = "2",
					f = 81,
					pos = v(200.75, 167.65)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 34,
					id = "1",
					f = 88,
					pos = v(203.4, 181.45)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 27,
					id = "0",
					f = 95,
					pos = v(195.95, 197.65)
				}
			}
		},
		{
			id = "13",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 95,
			pos = v(1491.45, -516.1),
			children = {{
				id = "9",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-58.85, 105.9)
			}, {
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-60.85, 121.35)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-113.35, 250.55)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-130.8, 265.6)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-142.9, 283.6)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-132.8, 300.25)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-112.4, 310.7)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 88,
				id = "9",
				f = 8,
				pos = v(-58.85, 105.9)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 81,
				id = "8",
				f = 15,
				pos = v(-60.85, 121.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 43,
				id = "7",
				f = 53,
				pos = v(-113.35, 250.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 36,
				id = "6",
				f = 60,
				pos = v(-130.8, 265.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 29,
				id = "5",
				f = 67,
				pos = v(-142.9, 283.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 22,
				id = "4",
				f = 74,
				pos = v(-132.8, 300.25)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 15,
				id = "3",
				f = 81,
				pos = v(-112.4, 310.7)
			}}
		},
		{
			id = "14",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 107,
			pos = v(1438.75, -449.6),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-47.5, 276.3)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-61.75, 289.6)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-80.95, 298.95)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-77.45, 315.8)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-54.95, 324.8)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(32.35, 395.2)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(27.1, 414.6)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(28.35, 432.9)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(40.2, 447.8)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 100,
				id = "8",
				f = 8,
				pos = v(-47.5, 276.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 93,
				id = "7",
				f = 15,
				pos = v(-61.75, 289.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 86,
				id = "6",
				f = 22,
				pos = v(-80.95, 298.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 79,
				id = "5",
				f = 29,
				pos = v(-77.45, 315.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 72,
				id = "4",
				f = 36,
				pos = v(-54.95, 324.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 41,
				id = "3",
				f = 67,
				pos = v(32.35, 395.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 34,
				id = "2",
				f = 74,
				pos = v(27.1, 414.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 27,
				id = "1",
				f = 81,
				pos = v(28.35, 432.9)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 20,
				id = "0",
				f = 88,
				pos = v(40.2, 447.8)
			}}
		},
		{
			id = "15",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 129,
			pos = v(1504.5, -338.8),
			children = {
				{
					id = "13",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(22.75, 346.55)
				},
				{
					id = "12",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(42.5, 351.2)
				},
				{
					id = "11",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(61.65, 358.5)
				},
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(82.65, 360.95)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(102, 353.75)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(115.65, 341.9)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(134.25, 333.3)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(253.2, 281.9)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(274.4, 277.8)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(292.3, 272.55)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(300.85, 259.05)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(296.15, 244.5)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 122,
					id = "13",
					f = 8,
					pos = v(22.75, 346.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 115,
					id = "12",
					f = 15,
					pos = v(42.5, 351.2)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 108,
					id = "11",
					f = 22,
					pos = v(61.65, 358.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 101,
					id = "10",
					f = 29,
					pos = v(82.65, 360.95)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 93,
					id = "9",
					f = 37,
					pos = v(102, 353.75)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 86,
					id = "8",
					f = 44,
					pos = v(115.65, 341.9)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 79,
					id = "7",
					f = 51,
					pos = v(134.25, 333.3)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 43,
					id = "6",
					f = 87,
					pos = v(253.2, 281.9)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 36,
					id = "5",
					f = 94,
					pos = v(274.4, 277.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 29,
					id = "4",
					f = 101,
					pos = v(292.3, 272.55)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 22,
					id = "3",
					f = 108,
					pos = v(300.85, 259.05)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 15,
					id = "2",
					f = 115,
					pos = v(296.15, 244.5)
				}
			}
		},
		{
			id = "16",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 120,
			pos = v(1776.6, -385.1),
			children = {
				{
					id = "15",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-18, 285.35)
				},
				{
					id = "14",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-37.65, 289.15)
				},
				{
					id = "13",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-53.9, 281.7)
				},
				{
					id = "12",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-55.95, 266.15)
				},
				{
					id = "11",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-47.9, 251.5)
				},
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-48.1, 235.8)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-71, 229)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-102.65, 144)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-116.95, 134.1)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-136.9, 134.1)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-136.9, 134.1)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-155.8, 132)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-166.3, 120.45)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-165.25, 106.8)
				},
				{
					id = "1",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-150.55, 98.4)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 113,
					id = "15",
					f = 8,
					pos = v(-18, 285.35)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 106,
					id = "14",
					f = 15,
					pos = v(-37.65, 289.15)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 100,
					id = "13",
					f = 21,
					pos = v(-53.9, 281.7)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 94,
					id = "12",
					f = 27,
					pos = v(-55.95, 266.15)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 88,
					id = "11",
					f = 33,
					pos = v(-47.9, 251.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 82,
					id = "10",
					f = 39,
					pos = v(-48.1, 235.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 76,
					id = "9",
					f = 45,
					pos = v(-71, 229)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 56,
					id = "8",
					f = 65,
					pos = v(-102.65, 144)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 49,
					id = "7",
					f = 72,
					pos = v(-116.95, 134.1)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 43,
					id = "6",
					f = 78,
					pos = v(-136.9, 134.1)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 37,
					id = "5",
					f = 84,
					pos = v(-136.9, 134.1)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 31,
					id = "4",
					f = 90,
					pos = v(-155.8, 132)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 25,
					id = "3",
					f = 96,
					pos = v(-166.3, 120.45)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 19,
					id = "2",
					f = 102,
					pos = v(-165.25, 106.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 14,
					id = "1",
					f = 107,
					pos = v(-150.55, 98.4)
				}
			}
		},
		{
			id = "18",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 98,
			pos = v(122.1, -556.6),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-167.6, 261.8)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-150.9, 248.35)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-131.9, 235.95)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-115.9, 223.25)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-73.55, 171.3)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-50.85, 174.9)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-32.2, 185.4)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-8.6, 189.7)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 91,
				id = "7",
				f = 8,
				pos = v(-167.6, 261.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 84,
				id = "6",
				f = 15,
				pos = v(-150.9, 248.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 78,
				id = "5",
				f = 21,
				pos = v(-131.9, 235.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 72,
				id = "4",
				f = 27,
				pos = v(-115.9, 223.25)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 49,
				id = "3",
				f = 50,
				pos = v(-73.55, 171.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 43,
				id = "2",
				f = 56,
				pos = v(-50.85, 174.9)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 37,
				id = "1",
				f = 62,
				pos = v(-32.2, 185.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 31,
				id = "0",
				f = 68,
				pos = v(-8.6, 189.7)
			}}
		},
		{
			id = "19",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 91,
			pos = v(322.85, -643.5),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-162.2, 255.8)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-148.5, 239.05)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-133.65, 222.4)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-117.55, 209.85)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-99.95, 199.15)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-77.1, 197.8)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-55.8, 205.5)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-40.45, 221.1)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 84,
				id = "8",
				f = 8,
				pos = v(-162.2, 255.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 77,
				id = "7",
				f = 15,
				pos = v(-148.5, 239.05)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 70,
				id = "6",
				f = 22,
				pos = v(-133.65, 222.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 63,
				id = "5",
				f = 29,
				pos = v(-117.55, 209.85)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 56,
				id = "4",
				f = 36,
				pos = v(-99.95, 199.15)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 49,
				id = "3",
				f = 43,
				pos = v(-77.1, 197.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 42,
				id = "2",
				f = 50,
				pos = v(-55.8, 205.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 35,
				id = "1",
				f = 57,
				pos = v(-40.45, 221.1)
			}}
		},
		{
			id = "21",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 107,
			pos = v(689.7, 181.2),
			children = {
				{
					id = "11",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-164.85, 254.25)
				},
				{
					id = "10",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-146.5, 266.7)
				},
				{
					id = "9",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-125.85, 275.05)
				},
				{
					id = "8",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-101.45, 279.5)
				},
				{
					id = "7",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-83.7, 290.5)
				},
				{
					id = "6",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-64.95, 302.8)
				},
				{
					id = "5",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-48.15, 317.1)
				},
				{
					id = "4",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-29.75, 332.2)
				},
				{
					id = "3",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-16.8, 352.5)
				},
				{
					id = "2",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-14.4, 374.75)
				},
				{
					id = "1",
					class = "KView",
					template_name = "map_path_dot",
					pos = v(-26.85, 393.5)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 100,
					id = "11",
					f = 8,
					pos = v(-164.85, 254.25)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 93,
					id = "10",
					f = 15,
					pos = v(-146.5, 266.7)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 86,
					id = "9",
					f = 22,
					pos = v(-125.85, 275.05)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 79,
					id = "8",
					f = 29,
					pos = v(-101.45, 279.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 72,
					id = "7",
					f = 36,
					pos = v(-83.7, 290.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 65,
					id = "6",
					f = 43,
					pos = v(-64.95, 302.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 58,
					id = "5",
					f = 50,
					pos = v(-48.15, 317.1)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 51,
					id = "4",
					f = 57,
					pos = v(-29.75, 332.2)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 44,
					id = "3",
					f = 64,
					pos = v(-16.8, 352.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 37,
					id = "2",
					f = 71,
					pos = v(-14.4, 374.75)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 10,
					frame_duration = 31,
					id = "1",
					f = 77,
					pos = v(-26.85, 393.5)
				}
			}
		},
		{
			id = "22",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 131,
			pos = v(612.4, 236.65),
			children = {{
				id = "9",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(8.05, 374.2)
			}, {
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-14.45, 382.2)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-38.15, 381.75)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-63.3, 379)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-88.65, 374.5)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-116.05, 372.35)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-258.55, 353.4)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-279.2, 357.95)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-296.65, 369.55)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 124,
				id = "9",
				f = 8,
				pos = v(8.05, 374.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 117,
				id = "8",
				f = 15,
				pos = v(-14.45, 382.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 110,
				id = "7",
				f = 22,
				pos = v(-38.15, 381.75)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 103,
				id = "6",
				f = 29,
				pos = v(-63.3, 379)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 96,
				id = "5",
				f = 36,
				pos = v(-88.65, 374.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 89,
				id = "4",
				f = 43,
				pos = v(-116.05, 372.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 51,
				id = "3",
				f = 81,
				pos = v(-258.55, 353.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 44,
				id = "2",
				f = 88,
				pos = v(-279.2, 357.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 37,
				id = "1",
				f = 95,
				pos = v(-296.65, 369.55)
			}}
		},
		{
			id = "24",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 135,
			pos = v(1409.25, 330.85),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(66.05, 250.95)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(86.35, 241.65)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(90.9, 228.05)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(80.85, 213.7)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-3, 121.1)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-18.9, 110.8)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-35.9, 103.75)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 128,
				id = "7",
				f = 8,
				pos = v(66.05, 250.95)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 121,
				id = "6",
				f = 15,
				pos = v(86.35, 241.65)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 114,
				id = "5",
				f = 22,
				pos = v(90.9, 228.05)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 107,
				id = "4",
				f = 29,
				pos = v(80.85, 213.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 58,
				id = "3",
				f = 78,
				pos = v(-3, 121.1)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 51,
				id = "2",
				f = 85,
				pos = v(-18.9, 110.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 44,
				id = "1",
				f = 92,
				pos = v(-35.9, 103.75)
			}}
		},
		{
			id = "25",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 138,
			pos = v(1516.4, 284.55),
			children = {{
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-151.35, 123.75)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-134.45, 114.15)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-117.15, 104.7)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(12.6, 148.6)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(27.85, 158.4)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 131,
				id = "4",
				f = 8,
				pos = v(-151.35, 123.75)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 124,
				id = "3",
				f = 15,
				pos = v(-134.45, 114.15)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 117,
				id = "2",
				f = 22,
				pos = v(-117.15, 104.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 66,
				id = "1",
				f = 73,
				pos = v(12.6, 148.6)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 58,
				id = "0",
				f = 81,
				pos = v(27.85, 158.4)
			}}
		},
		{
			id = "26",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 121,
			pos = v(1776.1, 335.55),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-189.7, 124.45)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-168.7, 133.2)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-148.7, 140.7)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-126.35, 146.1)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-104.15, 145.8)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-82.6, 140.8)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-64.35, 132.35)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-3.5, 59.8)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(15.05, 66.7)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 114,
				id = "8",
				f = 8,
				pos = v(-189.7, 124.45)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 107,
				id = "7",
				f = 15,
				pos = v(-168.7, 133.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 100,
				id = "6",
				f = 22,
				pos = v(-148.7, 140.7)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 93,
				id = "5",
				f = 29,
				pos = v(-126.35, 146.1)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 86,
				id = "4",
				f = 36,
				pos = v(-104.15, 145.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 78,
				id = "3",
				f = 44,
				pos = v(-82.6, 140.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 71,
				id = "2",
				f = 51,
				pos = v(-64.35, 132.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 29,
				id = "1",
				f = 93,
				pos = v(-3.5, 59.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 22,
				id = "0",
				f = 100,
				pos = v(15.05, 66.7)
			}}
		},
		{
			id = "27",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 149,
			pos = v(1967.2, 296.8),
			children = {{
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-128.75, 99.3)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-89.9, -3.5)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-101.7, -16.4)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-116.45, -27.15)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-224.85, -26.5)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-243.9, -18.45)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-262.8, -8.2)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-261.65, 5.2)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 142,
				id = "7",
				f = 8,
				pos = v(-128.75, 99.3)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 107,
				id = "6",
				f = 43,
				pos = v(-89.9, -3.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 100,
				id = "5",
				f = 50,
				pos = v(-101.7, -16.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 93,
				id = "4",
				f = 57,
				pos = v(-116.45, -27.15)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 51,
				id = "3",
				f = 99,
				pos = v(-224.85, -26.5)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 44,
				id = "2",
				f = 106,
				pos = v(-243.9, -18.45)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 37,
				id = "1",
				f = 113,
				pos = v(-262.8, -8.2)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 30,
				id = "0",
				f = 120,
				pos = v(-261.65, 5.2)
			}}
		},
		{
			id = "29",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 63,
			pos = v(992.9, -624.8),
			children = {{
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(23.8, 30.8)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(14.65, 14)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-29.65, -27.4)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-47.9, -34.7)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 56,
				id = "3",
				f = 8,
				pos = v(23.8, 30.8)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 49,
				id = "2",
				f = 15,
				pos = v(14.65, 14)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 42,
				id = "1",
				f = 22,
				pos = v(-29.65, -27.4)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 35,
				id = "0",
				f = 29,
				pos = v(-47.9, -34.7)
			}}
		},
		{
			id = "30",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 119,
			pos = v(857.9, -626.8),
			children = {{
				id = "8",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(31.8, -32.25)
			}, {
				id = "7",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(10.15, -26.55)
			}, {
				id = "6",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-116.15, 13.15)
			}, {
				id = "5",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-133.4, 24.35)
			}, {
				id = "4",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-154.9, 29.85)
			}, {
				id = "3",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-175.45, 25.85)
			}, {
				id = "2",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-190.95, 14.35)
			}, {
				id = "1",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-201.95, -1.15)
			}, {
				id = "0",
				class = "KView",
				template_name = "map_path_dot",
				pos = v(-202.45, -20.2)
			}},
			timeline = {{
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 112,
				id = "8",
				f = 8,
				pos = v(31.8, -32.25)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 105,
				id = "7",
				f = 15,
				pos = v(10.15, -26.55)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 77,
				id = "6",
				f = 43,
				pos = v(-116.15, 13.15)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 70,
				id = "5",
				f = 50,
				pos = v(-133.4, 24.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 63,
				id = "4",
				f = 57,
				pos = v(-154.9, 29.85)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 56,
				id = "3",
				f = 64,
				pos = v(-175.45, 25.85)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 49,
				id = "2",
				f = 71,
				pos = v(-190.95, 14.35)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 42,
				id = "1",
				f = 78,
				pos = v(-201.95, -1.15)
			}, {
				a_from = 1,
				play = "once",
				a_to = 10,
				frame_duration = 35,
				id = "0",
				f = 85,
				pos = v(-202.45, -20.2)
			}}
		},

		{
			id = "timeline_portal_t2",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 62,
			pos = v(1041.85, -222.45),
			children = {{
				class = "GGAni",
				id = "temple",
				pos = v(-185.8, -11.45),
				scale = v(1.45, 1.45),
				anchor = v(-22.95, -1.5),
				animation = {
					to = 37,
					prefix = "map_flags_animation_bridge_door",
					from = 1
				}
			}},
			timeline = {{
				f = 1,
				a_from = 1,
				play = "single",
				id = "temple",
				a_to = 37,
				frame_duration = 15,
				pos = v(-185.8, -11.45),
				scale = v(1.45, 1.45)
			}, {
				f = 16,
				a_from = 1,
				play = "once",
				id = "temple",
				a_to = 37,
				frame_duration = 47,
				pos = v(-185.8, -11.45),
				scale = v(1.45, 1.45)
			}}
		},
		{
			id = "timeline_portal_1",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 17,
			play = "oop",
			pos = v(1158.65, -540.9),
			children = {{
				class = "GGAni",
				id = "portal",
				pos = v(12.7, -12.6),
				scale = v(1, 1),
				anchor = v(48.6, 29.45),
				animation = {
					to = 17,
					prefix = "map_flags_animation_portal",
					from = 1
				}
			}},
			timeline = {{
				f = 1,
				a_from = 1,
				play = "oop",
				id = "portal",
				a_to = 17,
				frame_duration = 17,
				pos = v(12.7, -12.6),
				scale = v(1, 1)
			}}
		},
		{
			id = "timeline_portal_2",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 17,
			play = "oop",
			pos = v(1434.35, -529.3),
			children = {{
				class = "GGAni",
				id = "portal",
				pos = v(12.7, -12.6),
				scale = v(1, 1),
				anchor = v(48.6, 29.45),
				animation = {
					to = 17,
					prefix = "map_flags_animation_portal",
					from = 1
				}
			}},
			timeline = {{
				f = 1,
				a_from = 1,
				play = "oop",
				id = "portal",
				a_to = 17,
				frame_duration = 17,
				pos = v(12.7, -12.6),
				scale = v(1, 1)
			}}
		},
		{
			id = "timeline_flames",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 12,
			play = "oop",
			pos = v(1028.6, -116.85),
			children = {{
				id = "temple_fire",
				class = "GGAni",
				pos = v(-36.45, 2.85),
				anchor = v(-0.15, 19.45),
				animation = {
					to = 12,
					prefix = "map_flags_animation_temple_fire",
					from = 1
				}
			}},
			timeline = {{
				a_from = 1,
				play = "oop",
				a_to = 12,
				frame_duration = 12,
				id = "temple_fire",
				f = 1,
				pos = v(-36.45, 2.85)
			}}
		},
		{
			id = "timeline_stones_portal_t3",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 32,
			play = "oop",
			pos = v(1408.5, -537.15),
			children = {{
				id = "stones_portal",
				class = "GGAni",
				pos = v(-4.6, -0.9),
				anchor = v(-0.85, 0.95),
				animation = {
					to = 32,
					prefix = "map_flags_animation_stones_portal",
					from = 1
				}
			}},
			timeline = {{
				a_from = 1,
				play = "oop",
				a_to = 32,
				frame_duration = 32,
				id = "stones_portal",
				f = 1,
				pos = v(-4.6, -0.9)
			}}
		},
		{
			class = "KImageView",
			image_name = "map_flags_image_sword_",
			id = "image_sword",
			pos = v(792.6, -47.6),
			scale = v(1.7, 1.7),
			anchor = v(0, 0)
		}
	}

}

for i = 1, #a.flags do
	a.flags[i].pos.x = a.flags[i].pos.x * a.RATE_X + a.OFFSET_X
	a.flags[i].pos.y = a.flags[i].pos.y * a.RATE_Y + a.OFFSET_Y
end

return a
