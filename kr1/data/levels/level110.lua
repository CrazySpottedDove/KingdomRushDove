local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")
local GR = require("grid_db")
require("constants")
local function fts(v)
	return v / FPS
end
local function find_holder_by_id(store, id)
	local holder = table.filter(store.entities, function(_, v)
		return v.tower and v.tower.holder_id == id
	end)
	return holder[1]
end
local function find_entity_by_name(store, name)
	local entity = table.filter(store.entities, function(_, v)
		return v.template_name == name
	end)
	return entity[1]
end
local level = {}
function level:load(store)
	return
end
function level:update(store)
	P:add_invalid_range(5, P:get_start_node(5), P:get_start_node(5) + 6)
	P:add_invalid_range(6, P:get_start_node(6), P:get_start_node(6) + 6)
	P:add_invalid_range(7, P:get_start_node(7), P:get_start_node(7) + 6)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		local controller = find_entity_by_name(store, "controller_stage_10_obelisk_wave_fixed")
		local holders_to_block = controller.golem_activate_holder
		for _, h in ipairs(holders_to_block) do
			local golem_holder = find_holder_by_id(store, h)
			golem_holder.ui.can_click = false
		end
	elseif store.level_mode == GAME_MODE_IRON then
		local controller = find_entity_by_name(store, "controller_stage_10_obelisk_iron")
		local holders_to_block = controller.golem_activate_holder
		for _, h in ipairs(holders_to_block) do
			local golem_holder = find_holder_by_id(store, h)
			golem_holder.ui.can_click = false
		end
		local starting_gold = store.player_gold
		local holder = table.filter(game.store.entities, function(k, e)
			return e.tower and e.tower.holder_id == "7"
		end)[1]
		holder.tower.upgrade_to = "tower_paladin_covenant_lvl1"
		local holder2 = table.filter(game.store.entities, function(k, e)
			return e.tower and e.tower.holder_id == "10"
		end)[1]
		holder2.tower.upgrade_to = "tower_paladin_covenant_lvl1"
		coroutine.yield()
		store.player_gold = starting_gold
	end
	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end
return level
