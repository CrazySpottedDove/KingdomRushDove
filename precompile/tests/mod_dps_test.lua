package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

local stub = require("scripts.ci.love_stub")
local U = require("utils")
U.queue_damage = function()
end
local E = require("entity_db")
E:Load()

local failed = 0
local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local queued = {}
_G.simulation = {
	queue_insert_entity = function(_, e)
		queued[#queued + 1] = e
	end,
	queue_remove_entity = function()
	end
}

local this = E:create_entity("mod_blood_elves")
this.id = 100
this.main_script.context = E:clone_c("context")
this.main_script.type = 1
this.modifier.target_id = 200
this.modifier.ts = 0
this.pos = {
	x = 0,
	y = 0
}

local target = {
	id = 200,
	health = {
		dead = false,
		hp = 100
	},
	unit = {
		blood_color = "red",
		size = 1
	},
	render = {
		sprites = {{
			flip_x = true
		}}
	},
	pos = {
		x = 1,
		y = 2
	},
	vis = {
		bans = 0,
		flags = 0
	}
}
local store = {
	entities = {
		[200] = target
	},
	tick_ts = 0.5,
	tick_length = 1 / 30
}

local ok, err = pcall(this.main_script.update, this, store)
check(ok, "mod_dps state machine runs: " .. tostring(err))

local fx
for _, e in ipairs(queued) do
	if e.template_name == "fx_bleeding" then
		fx = e
	end
end
check(fx ~= nil, "mod_dps creates bleeding fx")
check(fx and fx.render.sprites[1].name == "small_red", "blood color appended to sprite name")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("mod_dps_test 通过")
