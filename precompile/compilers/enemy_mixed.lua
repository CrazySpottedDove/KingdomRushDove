local M = require("precompile.enemy")
local binkey = require("lib.binkey")

M.enemy_mixed = {
	update = {
		binkey = binkey.new(),
		cache = {}
	}
}

local env = M.env
local c = M.enemy_mixed
local cu = c.update

function cu.compile(e)
	if e.melee then
		if e.ranged then
			return env.scripts.enemy_melee_ranged.update
		else
			return env.scripts.enemy_melee.update
		end
	end
end
