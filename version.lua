-- chunkname: @./version.lua
local v
if arg[2] == "debug" or arg[2] == "release" then
    v = "DEBUG"
else
    v = "RELEASE"
end

version = {}
version.identity = "kingdom_rush"
version.title = "王国保卫战 dove 版"
version.string = "kr1-desktop-5.6.12"
version.string_short = "5.6.12"
version.bundle_id = "com.ironhidegames.kingdomrush.standalone"
version.vc = "kr1-desktop-5.6.12"
version.build = v
version.bundle_keywords = "-standalone"
version.id = "5.0.3"