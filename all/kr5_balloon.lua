-- KR5 战役气泡：GUI callout / 场景 shoutbox，供 game_gui:show_balloon 调用
local log = require("lib.klua.log"):new("kr5_balloon")
local tb = require("kr5_taunt_balloon")
local kr5_gui_balloon = require("kr5_gui_balloon")

local M = {}

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

function M.clear(gui, store)
	if gui.kr5_taunt_entity and store.entities[gui.kr5_taunt_entity.id] then
		queue_remove(store, gui.kr5_taunt_entity)
	end

	gui.kr5_taunt_entity = nil

	if gui.kr5_gui_balloon then
		gui.kr5_gui_balloon:remove(false)
		gui.kr5_gui_balloon = nil
	end
end

---@return boolean handled 是否按 KR5 逻辑处理（含失败日志）
function M.show(gui, store, taunt_id, pos_override)
	if not tb.is_kr5(store) then
		return false
	end

	M.clear(gui, store)

	local bd = tb.get_def(taunt_id)

	if bd and tb.is_gui_balloon(bd) then
		gui.kr5_gui_balloon = kr5_gui_balloon.show(gui, taunt_id, pos_override)

		if not gui.kr5_gui_balloon then
			log.error("show_balloon: failed to show callout for %s", taunt_id)
		end

		return true
	end

	if not bd then
		return false
	end

	local t = tb.spawn(store, taunt_id, pos_override)

	if not t then
		log.error("show_balloon: missing shoutbox for %s", taunt_id)

		return true
	end

	queue_insert(store, t)
	gui.kr5_taunt_entity = t

	return true
end

function M.update(gui, dt)
	if gui.kr5_gui_balloon and not gui.kr5_gui_balloon.remove_requested then
		gui.kr5_gui_balloon:update(dt)
	end
end

return M
