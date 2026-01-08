-- chunkname: @./all/platform_services_appstore_rating.lua
require("lib.klua.string")

local log = require("lib.klua.log"):new("platform_services_appstore_rating")
local PSU = require("platform_services_utils")
local signal = require("lib.hump.signal")
local rr = {}

rr.can_be_paused = true
rr.update_interval = 5
rr.lib = nil
rr.inited = false

local ffi = require("ffi")

ffi.cdef("bool skw_initialize(void);\nvoid skw_shutdown(void);\nint  skw_get_status(void);\nvoid skw_request_review(void);\n")

function rr:init(name, params)
	if self.initied then
		log.debug("service %s already inited", name)
	else
		self.lib = PSU:load_library("kstore", ffi)

		if not self.lib then
			log.error("Error loading kstore library")

			return false
		end

		self.inited = self.lib.skw_initialize()

		if not self.inited then
			log.error("Error initializing kstorekit")

			return false
		end
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function rr:shutdown(name)
	log.debug("Shutting down ")

	if self.inited then
		self.lib.skw_shutdown()
	end

	self.names = nil
	self.lib = nil
	self.inited = false
end

function rr:get_status()
	return self.inited
end

function rr:request_review()
	self.lib.skw_request_review()
end

return rr
