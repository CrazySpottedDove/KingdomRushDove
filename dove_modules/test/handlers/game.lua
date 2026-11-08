-- 局内命令：下一波、资源、造塔/升级、状态查询。
local storage = require("all.storage")
local util = require("dove_modules.test.util")
local autoplay = require("dove_modules.test.handlers.autoplay")
local game = {}

local function store(harness)
	return util.store(harness)
end

local function ensure_slot()
	if not storage:load_slot(1) then
		storage:create_slot(1)
	end

	storage:set_active_slot(1)

	return storage:load_slot()
end

--- 开局前配置（法术选择/法术等级/难度等），必须在 open_level 之前调用。
function game.configure(harness, args)
	local slot = ensure_slot()

	if args.spell ~= nil then
		slot.spell_power_id = args.spell
	end

	if args.difficulty ~= nil then
		slot.difficulty = tonumber(args.difficulty)
	end

	if args.spell_level ~= nil then
		local level = tonumber(args.spell_level)
		local UP = require("kr1.upgrades")

		UP.levels.rain = level
		UP.levels.reinforcements = level
	end

	storage:save_slot(slot)

	return {
		spell = slot.spell_power_id,
		difficulty = slot.difficulty,
		spell_level = args.spell_level
	}
end

function game.click_next_wave(harness)
	store(harness).send_next_wave = true

	return {
		send_next_wave = true
	}
end

function game.force_next_wave(harness)
	store(harness).force_next_wave = true

	return {
		force_next_wave = true
	}
end

function game.set_lives(harness, args)
	local s = store(harness)

	if args.n == nil then
		error("set_lives requires n")
	end

	s.lives = tonumber(args.n)

	return {
		lives = s.lives
	}
end

function game.set_gold(harness, args)
	local s = store(harness)

	if args.n == nil then
		error("set_gold requires n")
	end

	s.player_gold = tonumber(args.n)

	return {
		gold = s.player_gold
	}
end

function game.set_speed(harness, args)
	local s = store(harness)
	local factor = tonumber(args.factor) or 1

	s.speed_factor = factor

	return {
		speed_factor = factor
	}
end

function game.build_all_towers(harness, args)
	return autoplay.build_all_towers(harness, args)
end

function game.build_tower(harness, args)
	return autoplay.build_tower(harness, args)
end

function game.upgrade_tower(harness, args)
	local s = store(harness)

	if not args.holder_id then
		error("upgrade_tower requires holder_id")
	end

	local e = util.find_tower_by_holder(s, args.holder_id)

	if not e then
		error("tower not found at holder: " .. tostring(args.holder_id))
	end

	local tmd = require("kr1.data.tower_menus_data")
	local menus = tmd[e.tower.type]
	local list = menus and (menus[e.tower.level or 1] or menus[1])

	if not list then
		error("tower menu missing for type: " .. tostring(e.tower.type))
	end

	local target = args.tower

	if not target then
		for _, item in pairs(list) do
			if item.action == "tw_upgrade" then
				target = item.action_arg

				break
			end
		end
	end

	if not target then
		error("no upgrade entry for tower: " .. tostring(e.tower.type))
	end

	if target == "tower_random_foundamental" then
		target = table.random({"tower_archer_1", "tower_mage_1", "tower_engineer_1", "tower_barrack_1"})
	end

	s.player_gold = math.max(s.player_gold or 0, 1000000)

	local TU = require("tower_utils")

	TU.upgrade_tower(s, e, target)

	return {
		holder_id = args.holder_id,
		upgrade_to = target
	}
end

function game.sell_tower(harness, args)
	local s = store(harness)

	if not args.holder_id then
		error("sell_tower requires holder_id")
	end

	local e = util.find_tower_by_holder(s, args.holder_id)

	if not e then
		error("tower not found at holder: " .. tostring(args.holder_id))
	end

	require("tower_utils").sell_tower(s, e)

	return {
		holder_id = args.holder_id,
		sold = true
	}
end

function game.get_tower_holders(harness)
	local s = store(harness)
	local ids = util.tower_holder_ids(s)

	return {
		holders = ids,
		count = #ids
	}
end

function game.get_entities(harness, args)
	local s = store(harness)
	local list = {}

	for _, e in pairs(s.entities or {}) do
		if not e.pending_removal and (not args.template or e.template_name == args.template) then
			list[#list + 1] = {
				id = e.id,
				template = e.template_name,
				x = e.pos and e.pos.x or nil,
				y = e.pos and e.pos.y or nil,
				hp = e.health and e.health.hp or nil,
				tower = e.tower and e.tower.type or nil,
				enemy = e.enemy ~= nil
			}
		end
	end

	return {
		entities = list,
		count = #list
	}
end

function game.cast_spell(harness, args)
	return autoplay.cast_spell(harness, args)
end

function game.autoplay_start(harness, args)
	return autoplay.autoplay_start(harness, args)
end

function game.autoplay_stop(harness)
	return autoplay.autoplay_stop(harness)
end

function game.set_auto_click(harness, args)
	return autoplay.set_auto_click(harness, args)
end

function game.set_force_boss(harness, args)
	return autoplay.set_force_boss(harness, args)
end

function game.report(harness)
	return autoplay.report(harness)
end

function game.set_lives_old(harness, args)
	return game.set_lives(harness, args)
end

return game
