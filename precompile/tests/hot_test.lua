package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

local stub = require("scripts.ci.love_stub")
local E = require("entity_db")
E:Load()

local failed = 0
local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local base = E.entities["enemy_goblin"]
check(base and base.main_script and base.main_script.update ~= nil, "base entity")
check(debug.getinfo(base.main_script.update, "S").source:find("generated/shared.lua", 1, true) ~= nil, "base uses generated update")

local hot = E:register_t_hot("pc_hot_a", "enemy_goblin", true)
hot.enemy.gold = 999
E:precompile_hot()
check(debug.getinfo(hot.main_script.update, "S").source:find("generated/pc_hot_a.update", 1, true) ~= nil, "hot template recompiled")
check(debug.getinfo(hot.main_script.insert, "S").source:find("generated/pc_hot_a.insert", 1, true) ~= nil, "hot insert recompiled")
check(E.entities_backup["pc_hot_a"] == nil, "temporary template not backed up")

local chain = E:register_t_hot("pc_hot_b", "pc_hot_a", true)
chain.enemy.gold = 1000
E:precompile_hot()
check(debug.getinfo(chain.main_script.update, "S").source:find("generated/pc_hot_b.update", 1, true) ~= nil, "chain template recompiled")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("hot_test 通过")
