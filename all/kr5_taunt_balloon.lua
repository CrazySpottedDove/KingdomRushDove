local V = require("lib.klua.vector")
local E = require("entity_db")

local balloons = require("data.kr5_text_balloons")

local M = {}

M.FIRST_LEVEL = 101

local by_text

local function ensure_text_index()
	if by_text then
		return
	end

	by_text = {}

	for _, bd in pairs(balloons) do
		if type(bd) == "table" and bd.text then
			by_text[bd.text] = bd
		end
	end
end

function M.is_kr5(store)
	return store and store.level_idx and store.level_idx >= M.FIRST_LEVEL
end

function M.get_def(taunt_id)
	local bd = balloons[taunt_id]

	if bd then
		return bd
	end

	ensure_text_index()

	return by_text[taunt_id]
end

function M.get_text(taunt_id, bd)
	bd = bd or M.get_def(taunt_id)

	if not bd then
		return nil
	end

	if bd.text then
		return _(bd.text)
	end

	return _(taunt_id)
end

function M.is_gui_balloon(bd)
	if not bd or not bd.flags then
		return false
	end

	return string.find(bd.flags, "callout", 1, true) ~= nil or string.find(bd.flags, "yellow_text", 1, true) ~= nil
end

function M.taunt_duration(time)
	if not time or time <= 0 then
		return 3
	end

	if time > 8 then
		return 8
	end

	return time
end

-- 106等关卡的boss用专用 shoutbox 贴图
local function shoutbox_template(taunt_id, bd)
	local id = taunt_id or (bd and bd.text)

	if id and string.find(id, "BOSS_PIG", 1, true) then
		local tpl = E:get_template("decal_stage06_boss_pig_shoutbox")

		if tpl and tpl.texts then
			return "decal_stage06_boss_pig_shoutbox"
		end
	end

	if E:get_template("decal_stage06_cultist_shoutbox") then
		return "decal_stage06_cultist_shoutbox"
	end

	if E:get_template("decal_kr5_boss_shoutbox") then
		return "decal_kr5_boss_shoutbox"
	end

	return "decal_stage06_cultist_shoutbox"
end

function M.spawn(store, taunt_id, pos_override)
	local bd = M.get_def(taunt_id)

	if not bd then
		return nil
	end

	local text = M.get_text(taunt_id, bd)
	local pos = pos_override

	if not pos and bd.offset then
		pos = V.vclone(bd.offset)
	end

	if not pos then
		pos = V.v(512, 560)
	end

	local tpl_name = shoutbox_template(taunt_id, bd)
	local t = E:create_entity(tpl_name)

	if not t or not t.texts or not t.texts.list or not t.texts.list[1] then
		return nil, text
	end

	t.texts.list[1].text = text
	t.pos = V.v(pos.x, pos.y)
	t.tween.ts = store.tick_ts
	t.duration = M.taunt_duration(bd.time)
	t.start_ts = store.tick_ts

	return t, text
end

return M
