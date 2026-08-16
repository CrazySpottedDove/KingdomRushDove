local plugin_utils = require("plugin_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()

function hook:init(plugin_data)
	self.plugin_data = plugin_data

	HOOK(E, "load", self.E.load)
end

function hook.E.load(load, self)
	load(self)

	package.loaded.plugin_template_scripts = nil
	package.loaded.plugin_template_templates = nil

	require("plugin_template_scripts")
	require("plugin_template_templates")
end

return hook
