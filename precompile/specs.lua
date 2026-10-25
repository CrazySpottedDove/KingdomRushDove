--- 预编译入口 spec：原脚本函数 -> 生成目标
local scripts = require("scripts")

local M = {}

local list = {
	{
		key = "insert",
		source = scripts.enemy_basic.insert,
		family = "enemies",
		when = function(e)
			return e.enemy ~= nil
		end,
		group = "enemies"
	},
	{
		key = "update",
		source = scripts.enemy_mixed.update,
		family = "enemies",
		when = function(e)
			return e.enemy ~= nil and (e.melee ~= nil or e.ranged ~= nil)
		end,
		group = "enemies"
	},
	{
		key = "update",
		source = scripts.enemy_passive.update,
		family = "enemies",
		when = function(e)
			return e.enemy ~= nil
		end,
		group = "enemies"
	},
	{
		key = "insert",
		source = scripts.arrow.insert,
		family = "arrow",
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "insert",
		source = scripts.bomb.insert,
		family = "bomb",
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "insert",
		source = scripts.bolt.insert,
		family = "bolt",
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "update",
		source = scripts.arrow.update,
		compile_source = scripts.arrow.update_sm,
		family = "arrow",
		state_machine = true,
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "update",
		source = scripts.bomb.update,
		compile_source = scripts.bomb.update_sm,
		family = "bomb",
		state_machine = true,
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "update",
		source = scripts.bolt.update,
		compile_source = scripts.bolt.update_sm,
		family = "bolt",
		state_machine = true,
		when = function(e)
			return e.bullet ~= nil
		end,
		group = "bullets"
	},
	{
		key = "insert",
		source = scripts.soldier_barrack.insert,
		family = "soldiers",
		when = function(e)
			return e.soldier ~= nil
		end,
		group = "soldiers"
	},
	{
		key = "update",
		source = scripts.soldier_barrack.update,
		family = "soldiers",
		when = function(e)
			return e.soldier ~= nil
		end,
		group = "soldiers"
	},
	{
		key = "insert",
		source = scripts.mod_dps.insert,
		family = "mod_dps",
		when = function(e)
			return e.modifier ~= nil
		end,
		group = "modifiers"
	},
	{
		key = "insert",
		source = scripts.mod_track_target.insert,
		family = "mod_track_target",
		when = function(e)
			return e.modifier ~= nil
		end,
		group = "modifiers"
	},
	{
		key = "update",
		source = scripts.mod_dps.update,
		compile_source = scripts.mod_dps.update_sm,
		family = "mod_dps",
		state_machine = true,
		when = function(e)
			return e.modifier ~= nil
		end,
		group = "modifiers"
	},
	{
		key = "update",
		source = scripts.mod_track_target.update,
		compile_source = scripts.mod_track_target.update_sm,
		family = "mod_track_target",
		state_machine = true,
		when = function(e)
			return e.modifier ~= nil and e.modifier.duration ~= nil
		end,
		group = "modifiers"
	},
	{
		key = "insert",
		source = scripts.aura_apply_mod.insert,
		family = "aura_apply_mod",
		when = function(e)
			return e.aura ~= nil
		end,
		group = "auras"
	},
	{
		key = "update",
		source = scripts.aura_apply_mod.update,
		compile_source = scripts.aura_apply_mod.update_sm,
		family = "aura_apply_mod",
		state_machine = true,
		when = function(e)
			return e.aura ~= nil and e.aura.duration ~= nil
		end,
		group = "auras"
	},
	{
		key = "update",
		source = scripts.aura_apply_damage.update,
		compile_source = scripts.aura_apply_damage.update_sm,
		family = "aura_apply_damage",
		state_machine = true,
		when = function(e)
			return e.aura ~= nil and e.aura.duration ~= nil
		end,
		group = "auras"
	}
}

local by_source = {}
for _, spec in ipairs(list) do
	by_source[spec.source] = by_source[spec.source] or {}
	table.insert(by_source[spec.source], spec)
end

function M.list()
	return list
end

--- @param e table
--- @param key string
--- @param fn function
--- @return table|nil
function M.match(e, key, fn)
	local candidates = by_source[fn]
	if not candidates then
		return nil
	end
	for _, spec in ipairs(candidates) do
		if spec.key == key and spec.when(e) then
			return spec
		end
	end
	return nil
end

--- @param e table
--- @return table list of { key, spec, source }
function M.for_entity(e)
	local result = {}
	local main_script = e.main_script
	if not main_script then
		return result
	end
	for key, fn in pairs(main_script) do
		if type(fn) == "function" then
			local spec = M.match(e, key, fn)
			if spec then
				result[#result + 1] = {
					key = key,
					spec = spec,
					source = fn
				}
			end
		end
	end
	table.sort(result, function(a, b)
		return a.key < b.key
	end)
	return result
end

return M
