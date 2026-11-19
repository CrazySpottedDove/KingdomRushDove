-- 场景/地图界面命令。这里集中知道 screen_map 的字段名，
-- 不把测试命名散回 screen_map 里。
local LEGACY = require("generations.legacy")
local storage = require("all.storage")
local util = require("dove_modules.test.util")
local screen = {}

local function ensure_slot()
	if not storage:load_slot(1) then
		storage:create_slot(1)
	end

	storage:set_active_slot(1)

	local slot = storage:load_slot()

	if slot.difficulty == nil then
		slot.difficulty = DIFFICULTY_NORMAL

		storage:save_slot(slot)
	end

	return slot
end

local VIEWS = {
	hero_room = "HeroRoomViewKR1",
	encyclopedia = "EncyclopediaView",
	upgrades = "UpgradesView",
	spell_view = "SpellSelectView"
}

local function map(harness)
	return util.scene(harness, "map")
end

local function open_view(harness, button, field)
	local sm = map(harness)

	if not button or not button.on_click then
		error(VIEWS[field] .. " button has no on_click")
	end

	button.on_click(button)

	local view = sm[field]

	if not view then
		error(VIEWS[field] .. " was not created")
	end

	if view.hidden then
		error(VIEWS[field] .. " did not open")
	end

	return VIEWS[field]
end

local function mode(args)
	return tonumber(args.mode) or GAME_MODE_CAMPAIGN
end

local function difficulty(args)
	return tonumber(args.difficulty) or DIFFICULTY_NORMAL
end

function screen.open_map(harness, args)
	local slot = ensure_slot()

	if args.gen_id then
		slot.last_generation = args.gen_id

		storage:save_slot(slot)
	end

	harness.game_started = false
	harness.autoplay = nil
	harness.director.next_item_name = "map"
	harness.director.next_item_args = {
		next_item_name = "map"
	}

	return {
		queued = "map",
		gen_id = slot.last_generation
	}
end

function screen.open_level(harness, args)
	local gen_id = args.gen_id
	local level_idx = tonumber(args.level_idx or args.level)

	if not gen_id then
		local level = tonumber(args.level)

		if not level then
			error("open_level requires level or gen_id/level_idx")
		end

		gen_id, level_idx = LEGACY.to_ref(level)
	end

	if not gen_id or not level_idx then
		error("cannot resolve level: " .. tostring(args.level))
	end

	ensure_slot()

	harness.game_started = false
	harness.autoplay = nil
	harness.director.next_item_name = "game"
	harness.director.next_item_args = {
		next_item_name = "game",
		gen_id = gen_id,
		level_idx = level_idx,
		level_mode = mode(args),
		level_difficulty = difficulty(args)
	}

	return {
		queued = "game",
		gen_id = gen_id,
		level_idx = level_idx,
		mode = mode(args),
		difficulty = difficulty(args)
	}
end

function screen.open_screen(harness, args)
	if not args.name then
		error("open_screen requires name")
	end

	ensure_slot()

	harness.game_started = false
	harness.autoplay = nil
	harness.director.next_item_name = args.name
	harness.director.next_item_args = {
		next_item_name = args.name,
		custom = args.custom,
		texture_size = args.texture_size
	}

	return {
		queued = args.name
	}
end

function screen.back_to_map(harness)
	ensure_slot()

	harness.game_started = false
	harness.autoplay = nil
	harness.director.next_item_name = "map"
	harness.director.next_item_args = {
		next_item_name = "map"
	}

	return {
		queued = "map"
	}
end

function screen.click_upgrade_button(harness)
	local sm = map(harness)

	return {
		clicked = "upgrade_button",
		opened = open_view(harness, sm.u_button or sm._u_btn, "upgrades")
	}
end

function screen.click_encyclopedia_button(harness)
	local sm = map(harness)

	return {
		clicked = "encyclopedia_button",
		opened = open_view(harness, sm._e_btn, "encyclopedia")
	}
end

function screen.click_hero_room_button(harness)
	local sm = map(harness)

	return {
		clicked = "hero_room_button",
		opened = open_view(harness, sm.hero_but or sm._h_btn, "hero_room")
	}
end

function screen.click_change_generation_button(harness)
	local sm = map(harness)

	return {
		clicked = "change_generation_button",
		x = util.click_view(sm._change_btn)
	}
end

function screen.click_spell_button(harness)
	local sm = map(harness)

	return {
		clicked = "spell_button",
		opened = open_view(harness, sm.spell_button, "spell_view")
	}
end

function screen.close_view(harness, args)
	local sm = map(harness)
	local field = args.field or args.name

	if not VIEWS[field] then
		for key, name in pairs(VIEWS) do
			if name == args.name then
				field = key
			end
		end
	end

	if not VIEWS[field] then
		error("close_view requires a known view name")
	end

	local view = sm[field]

	if not view then
		error(VIEWS[field] .. " was not created")
	end

	local close = view.close_button or view:get_child_by_id("close_button")

	if not close or not close.on_click then
		error(VIEWS[field] .. " close button has no on_click")
	end

	close.on_click(close)

	return {
		closed = VIEWS[field]
	}
end

function screen.click_map_flag(harness, args)
	local sm = map(harness)
	local level_idx = tonumber(args.level)

	if not level_idx then
		error("click_map_flag requires level")
	end

	local flag = sm.map_view and sm.map_view.flags and sm.map_view.flags[level_idx]

	if not flag then
		error("map flag not found: " .. tostring(level_idx))
	end

	return {
		clicked = "map_flag",
		level = level_idx,
		x = util.click_view(flag.button or flag)
	}
end

function screen.click_level(harness, args)
	local sm = map(harness)
	local level_idx = tonumber(args.level)

	if not level_idx then
		error("click_level requires level")
	end

	harness.game_started = false
	harness.autoplay = nil
	sm.user_data.difficulty = difficulty(args)

	storage:save_slot(sm.user_data)
	sm:start_level(level_idx, mode(args))

	return {
		clicked = "level",
		level = level_idx,
		mode = mode(args)
	}
end

function screen.select_generation(harness, args)
	local sm = map(harness)

	if not args.gen_id then
		error("select_generation requires gen_id")
	end

	if sm.gen_id ~= args.gen_id then
		sm:change_generation(args.gen_id)
	end

	return {
		gen_id = args.gen_id
	}
end

function screen.snapshot_map(harness)
	local sm = map(harness)

	return {
		gen_id = sm.gen_id,
		total_stars = sm.total_stars,
		progress = sm.progress
	}
end

return screen
