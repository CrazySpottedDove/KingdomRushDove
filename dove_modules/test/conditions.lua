-- run_until 支持的条件。JSON 无法传函数，所以条件必须在这里注册成名字。
local LU = require("level_utils")
local conditions = {}

local function store_of(harness)
	local game = harness:get_game()

	return game and game.store or nil
end

conditions.conditions = {
	scene = function(harness, args)
		local item = harness.director and harness.director.active_item

		return item ~= nil and item.item_name == (args.name or "map")
	end,
	scene_ready = function(harness, args)
		local item = harness.director and harness.director.active_item

		if not item or item.item_name ~= (args.name or "map") then
			return false
		end

		return not harness.director.queued_item and not harness.director.next_item_name
	end,
	game_start = function(harness)
		return harness.game_started == true
	end,
	level_outcome = function(harness)
		local store = store_of(harness)

		return store and store.game_outcome ~= nil
	end,
	waves_finished = function(harness)
		local store = store_of(harness)

		return store and store.waves_finished == true
	end,
	no_enemies = function(harness)
		local store = store_of(harness)

		return store ~= nil and not LU.has_alive_enemies(store)
	end,
	next_wave_ready = function(harness)
		local store = store_of(harness)

		return store and store.next_wave_group_ready == true
	end,
	wave_group = function(harness, args)
		local store = store_of(harness)

		return store and (store.wave_group_number or 0) >= (tonumber(args.n) or 0)
	end,
	tick_ts = function(harness, args)
		local store = store_of(harness)

		return store and (store.tick_ts or 0) >= (tonumber(args.n) or 0)
	end,
	tick_ts_or_outcome = function(harness, args)
		local store = store_of(harness)

		if not store then
			return false
		end

		return store.game_outcome ~= nil or (store.tick_ts or 0) >= (tonumber(args.n) or 0)
	end,
	lives_le = function(harness, args)
		local store = store_of(harness)

		return store and (store.lives or 0) <= (tonumber(args.n) or 0)
	end,
	gold_ge = function(harness, args)
		local store = store_of(harness)

		return store and (store.player_gold or 0) >= (tonumber(args.n) or 0)
	end,
	entity_count_ge = function(harness, args)
		local store = store_of(harness)

		if not store then
			return false
		end

		local template = args.template

		return harness:count_entities(function(e)
			return template == nil or e.template_name == template
		end) >= (tonumber(args.n) or 1)
	end,
	never = function()
		return false
	end
}

function conditions.resolve(name)
	local fn = conditions.conditions[name]

	if not fn then
		error("unknown condition: " .. tostring(name))
	end

	return fn
end

return conditions
