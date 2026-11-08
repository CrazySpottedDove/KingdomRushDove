-- 测试命令共用的小工具：取当前场景、点击视图、按路径取状态等。
local util = {}

--- 按 a.b.c 取表里的值。取不到返回 nil。
function util.get_path(root, path)
	local cur = root

	for part in tostring(path):gmatch("[^%.]+") do
		if type(cur) ~= "table" then
			return nil
		end

		cur = cur[part]
	end

	return cur
end

--- 当前 director / 当前场景 / 当前 game。
function util.director(harness)
	return harness.director
end

function util.active_item(harness)
	return harness.director and harness.director.active_item
end

function util.scene(harness, name)
	local item = util.active_item(harness)

	if not item or (name and item.item_name ~= name) then
		error(string.format("active scene is %s, expected %s", tostring(item and item.item_name), tostring(name)))
	end

	return item
end

function util.game(harness)
	local item = util.active_item(harness)

	if item and item.item_name == "game" then
		return item
	end

	return nil
end

function util.require_game(harness)
	local game = util.game(harness)

	if not game then
		error("no active game")
	end

	return game
end

function util.store(harness)
	local game = util.require_game(harness)

	return game.store
end

--- 用真实鼠标按下/抬起点击一个 KView。坐标由 view_to_screen 计算，包含父级变换。
function util.click_view(view, button)
	if not view then
		error("click target not found")
	end

	if not view.size then
		error("click target has no size")
	end

	local window = view:get_window()

	if not window then
		error("click target is not attached to a window")
	end

	local x, y = view:view_to_screen(view.size.x * 0.5, view.size.y * 0.5)

	window:mousepressed(x, y, button or 1)
	window:mousereleased(x, y, button or 1)

	return x, y
end

function util.count_entities(store, filter)
	local n = 0

	for _, e in pairs(store.entities or {}) do
		if not e.pending_removal and (not filter or filter(e)) then
			n = n + 1
		end
	end

	return n
end

function util.find_holder(store, holder_id)
	for _, e in pairs(store.entities or {}) do
		if e.tower_holder and e.tower and e.tower.type == "holder" and tostring(e.tower.holder_id) == tostring(holder_id) then
			return e
		end
	end

	return nil
end

function util.find_tower_by_holder(store, holder_id)
	for _, e in pairs(store.entities or {}) do
		if e.tower and e.tower.type ~= "holder" and tostring(e.tower.holder_id) == tostring(holder_id) then
			return e
		end
	end

	return nil
end

function util.tower_holder_ids(store)
	local ids = {}

	for _, e in pairs(store.entities or {}) do
		if e.tower_holder and not e.tower_holder.blocked and e.tower and e.tower.type == "holder" then
			ids[#ids + 1] = e.tower.holder_id
		end
	end

	table.sort(ids, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return ids
end

function util.clone(v)
	if type(v) ~= "table" then
		return v
	end

	local out = {}

	for k, val in pairs(v) do
		out[k] = util.clone(val)
	end

	return out
end

return util
