-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2-desktop/data/map_points.lua

local V = require("lib.klua.vector")
local v = V.v

local a = {
	OFFSET_X = 215 + 54,
	OFFSET_Y = 475 + 187 + 156 + 478,
	RATE_X = 1,
	RATE_Y = 1,

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
		},
		{
			number = "33",
			pos = v(1339.75, 759.5)
		},
		{
			number = "34",
			pos = v(1215.5, 596.5)
		},
		{
			number = "35",
			pos = v(1446.05, 657.8)
		},
		{
			number = "36",
			pos = v(1176.65, -668.4)
		},
		{
			number = "37",
			pos = v(1189.8, -902.85)
		},
		{
			number = "38",
			pos = v(1419.55, -793.85)
		},
		{
			number = "39",
			pos = v(1439.85, -978.85)
		},
		{
			number = "40",
			pos = v(1753.5, -908.85)
		}
	},
	endless_flags = {},
	points = {}
}

for i = 1, #a.flags do
	a.flags[i].pos.x = a.flags[i].pos.x * a.RATE_X + a.OFFSET_X
	a.flags[i].pos.y = a.flags[i].pos.y * a.RATE_Y + a.OFFSET_Y
end

return a
