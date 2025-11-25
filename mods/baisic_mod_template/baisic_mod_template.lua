local log = require("klua.log"):new("baisic_mod_template")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local baisic_mod_template_templates = require("baisic_mod_template_templates")

local hook = {}

setmetatable(hook, mod_utils.auto_table_mt)

function hook:init(mod_data)
	-- 可以访问 mod_data.config 来得到模组配置

	HOOK(E, "load", self.E.load)
end

function hook.E.load(load, self)
	load(self)
	
	baisic_mod_template_templates:init()
end

return hook