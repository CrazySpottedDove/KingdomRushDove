local templates = require("data.tower_menus_data_templates")
local scripts = require("kr1.data.tower_menus_data_scripts")
local merge = scripts.merge
local tower_menus_data = require("kr1.data.tower_menus_data")
local mage = tower_menus_data.mage[3]
local archer = tower_menus_data.archer[3]
local engineer = tower_menus_data.engineer[3]
local barrack = tower_menus_data.barrack[3]
local data = {}
for _, item in ipairs(archer) do
	if item.action ~= "tw_sell" and item.action ~= "tw_rally" then
		table.insert(data, item)
	end
end
for _, item in ipairs(barrack) do
	if item.action ~= "tw_sell" and item.action ~= "tw_rally" then
		table.insert(data, item)
	end
end
for _, item in ipairs(mage) do
	if item.action ~= "tw_sell" and item.action ~= "tw_rally" then
		table.insert(data, item)
	end
end
for _, item in ipairs(engineer) do
	if item.action ~= "tw_sell" and item.action ~= "tw_rally" then
		table.insert(data, item)
	end
end
return data
