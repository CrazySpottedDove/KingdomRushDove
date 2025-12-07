-- chunkname: @./all/platform_services_kvideo.lua
local log = require("lib.klua.log"):new("platform_services_kvideo")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local srv = {}
srv.can_be_paused = false
srv.update_interval = 1
srv.lib = nil
srv.inited = false
local ffi = require("ffi")
ffi.cdef("bool kvideo_initialize();\nvoid kvideo_shutdown();\nvoid kvideo_set_video(const char* name, bool absolute);\nvoid kvideo_play();\nvoid kvideo_stop();\nbool kvideo_is_finished();\n")

function srv:init(name, params)
	local ids, lib_name

	if self.inited then
		log.debug("service %s already inited", name)
	else
		self.lib = PSU:load_library("kvideo", ffi)

		if not self.lib then
			log.error("KVideo library could not be loaded from %s", lib_name)
			return false
		end

		if self.lib.kvideo_initialize() then
			log.info("Kvideo inited properly")
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

function srv:is_finished()
	return self.lib.kvideo_is_finished()
end

function srv:set_video_name(name, absolute)
	self.lib.kvideo_set_video(name, absolute)
end

function srv:play()
	self.lib.kvideo_play()
end

function srv:stop()
	self.lib.kvideo_stop()
end

return srv
