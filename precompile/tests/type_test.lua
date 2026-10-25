package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

local stub = require("scripts.ci.love_stub")
local E = require("entity_db")
local scripts = require("scripts")
local compiler = require("precompile.interface")
E:Load()

local failed = 0
local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local function custom_coroutine(this, store)
	coroutine.yield()
end

local function custom_state_machine(this, store)
	this.main_script.context.state = (this.main_script.context.state or 0) + 1
end

local e = E:register_t_hot("pc_type_test", "arrow_ranger", true)
e.main_script.update = scripts.arrow.update
e.main_script.type = 1
compiler:ensure_entity_type(e)
check(e.main_script.type == 0, "coroutine script type corrected")

e.main_script.update = scripts.arrow.update_sm
e.main_script.type = 0
compiler:ensure_entity_type(e)
check(e.main_script.type == 1, "state machine script type corrected")

e.main_script.update = custom_coroutine
e.main_script.type = 1
compiler:ensure_entity_type(e)
check(e.main_script.type == 0, "unknown function defaults to coroutine")

e.main_script.update = custom_state_machine
e.main_script.type = 0
compiler:ensure_entity_type(e)
check(e.main_script.type == 0, "unknown custom state machine stays coroutine fallback")
check(e.main_script.context ~= nil, "unknown function gets context")

local base = E.entities["arrow_ranger"]
check(compiler:script_type(base.main_script.update) == 1, "generated arrow marked state machine")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("type_test 通过")
