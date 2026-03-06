local v = (arg[2] == "debug" or arg[2] == "release") and "DEBUG" or "RELEASE"

local version = {
	identity = "kingdom_rush",
	title = "王国保卫战 dove 版",
	string = "kr1-desktop-5.6.12",
	string_short = "5.6.12",
	bundle_id = "com.ironhidegames.kingdomrush.standalone",
	vc = "kr1-desktop-5.6.12",
	build = v,
	bundle_keywords = "-standalone",
	id = "9.7.2"
}

return version
