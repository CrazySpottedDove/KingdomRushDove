local log = require("klua.log"):new("mod_template")
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()

function hook:init(mod_data)
	self.mod_data = mod_data

	HOOK(E, "load", self.E.load)
end

function hook.E.load(load, self)
	load(self)

	package.loaded.mod_template_templates = nil
	package.loaded.mod_template_scripts = nil

	local mod_template_templates = require("mod_template_templates")
	local mod_template_scripts = require("mod_template_scripts")

	require("mod_template_templates")
	require("mod_template_scripts")
end

return hook
