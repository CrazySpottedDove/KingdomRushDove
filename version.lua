local is_build = (arg[2] == "debug" or arg[2] == "release") and "DEBUG" or "RELEASE"

local version = {
	identity = "kingdom_rush_dove",
	title = "Kingdom Rush Dove",
	string = "CYCLE 2:",
	string_short = "5.6.12",
	bundle_id = "com.ironhidegames.kingdomrush.standalone",
	build = is_build,
	bundle_keywords = "-standalone",
	id = "2.1.0.4",
	branch = "master"
}

local ok, build_info = pcall(require, "build_info")
if ok and type(build_info) == "table" then
	version.branch = build_info.branch or version.branch
end

return version
