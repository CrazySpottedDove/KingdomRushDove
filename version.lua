local is_build = (arg[2] == "debug" or arg[2] == "release") and "DEBUG" or "RELEASE"

local version = {
	identity = "kingdom_rush_dove",
	title = "王国保卫战 dove 版",
	string = "CYCLE 2:",
	string_short = "5.6.12",
	bundle_id = "com.ironhidegames.kingdomrush.standalone",
	build = is_build,
	bundle_keywords = "-standalone",
	id = "0.0.8"
}

return version
