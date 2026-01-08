-- chunkname: @./all-desktop/platform_services_fairplay.lua
local log = require("lib.klua.log"):new("platform_services_fairplay")
local PSU = require("platform_services_utils")
local signal = require("lib.hump.signal")
local srv = {}

srv.can_be_paused = false
srv.update_interval = 1
srv.lib = nil
srv.inited = false

local ffi = require("ffi")

ffi.cdef("bool kfairplay_initialize();\n")

function srv:init(name, params)
	local ids, lib_name

	if self.inited then
		log.debug("service %s already inited", name)
	else
		lib_name = PSU:get_library_file("kfairplay")
		self.lib = ffi.load(lib_name)

		if not self.lib then
			log.error("FairPlay library could not be loaded from %s", lib_name)

			return
		end

		if self.lib.kfairplay_initialize() then
			log.info("FairPlay inited properly")
		end

		self.inited = true
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function srv:shutdown(name)
	self.inited = nil
end

function srv:get_status()
	return self.inited
end

return srv
