-- chunkname: @./all/systems.lua
require("lib.klua.table")
require("lib.klua.dump")

local SystemsIndex = require("all.systems.index")

local sys = {}

SystemsIndex.register_systems(sys)

return sys
