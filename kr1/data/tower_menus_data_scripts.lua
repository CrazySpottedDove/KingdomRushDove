local scripts = {}

function scripts.merge(table1, table2)
	return table.merge(table1, table2, true)
end

require("lib.klua.table")

--- 自动处理向防御塔升级菜单中添加项的情况，以保证显示起来正常
---@param upgrade_table any
---@param upgrade_item any
function scripts.clever_add(upgrade_table, upgrade_item)
	local strong_item_action_map = table.to_map({"tw_upgrade", "upgrade_power", "tw_buy_soldier", "tw_buy_attack", "tw_unblock"})

	local strong_item_count = 0
	local strong_item_indices = {}

	upgrade_table[#upgrade_table + 1] = upgrade_item

	for i, item in ipairs(upgrade_table) do
		if strong_item_action_map[item.action] then
			strong_item_count = strong_item_count + 1
			strong_item_indices[#strong_item_indices + 1] = i
		end
	end

	if strong_item_count == 4 then
		for i, index in ipairs(strong_item_indices) do
			upgrade_table[index].place = i
		end
	else
		for i, index in ipairs(strong_item_indices) do
			if i <= 3 then
				upgrade_table[index].place = i + 4
			else
				upgrade_table[index].place = i + 6
			end
		end
	end
end

return scripts
