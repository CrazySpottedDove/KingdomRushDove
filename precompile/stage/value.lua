--- 特化期抽象值
local M = {}

local SAFE_ROOTS = {}
for _, name in ipairs({
	"render",
	"melee",
	"ranged",
	"auras",
	"water",
	"bullet",
	"modifier",
	"aura",
	"soldier",
	"dps",
	"info",
	"tower",
	"barrack",
	"enemy",
	"unit",
	"health",
	"motion",
	"pos",
	"nav_path",
	"spawn_data",
	"vis",
	"tween",
	"main_script",
	"health_bar",
	"regen",
	"powers",
	"track_kills",
	"track_damage",
	"sound_events",
	"ui",
	"decal",
	"controller",
	"particle_system",
	"user_power",
	"buff",
	"buffs",
	"abilities",
	"skills",
	"level_stats",
	"hero",
	"attacks",
	"exoskeleton"
}) do
	SAFE_ROOTS[name] = true
end

local SAFE_PATHS = {
	["render.sprites"] = true,
	["melee.attacks"] = true,
	["ranged.attacks"] = true,
	["auras.list"] = true
}

local function path_key(path)
	return table.concat(path, ".")
end

function M.const(value, safe, path)
	return {
		known = true,
		value = value,
		safe = safe == true,
		path = path
	}
end

function M.unknown()
	return {
		known = false
	}
end

function M.child(obj, key)
	if not obj.known or type(obj.value) ~= "table" then
		return M.unknown()
	end
	if type(key) ~= "string" and type(key) ~= "number" then
		return M.unknown()
	end

	local path
	if obj.path then
		path = {}
		for i = 1, #obj.path do
			path[i] = obj.path[i]
		end
		path[#path + 1] = key
	end

	local safe = false
	if path then
		if #path == 1 and SAFE_ROOTS[path[1]] then
			safe = true
		elseif SAFE_PATHS[path_key(path)] then
			safe = true
		end
	end

	return M.const(obj.value[key], safe, path)
end

return M
