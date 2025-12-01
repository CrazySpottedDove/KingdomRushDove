-- chunkname: @./all/platform_services_firebase_dl.lua

local log = require("lib.klua.log"):new("platform_services_firebase_dl")
local signal = require("hump.signal")

require("lib.klua.table")
require("lib.klua.string")
require("constants")

local fbdl = {}

fbdl.can_be_paused = true
fbdl.update_interval = 5
fbdl.SRV_ID = 53
fbdl.SRV_DISPLAY_NAME = "Firebase Dynamic Links"

local proxy

if KR_PLATFORM == "ios" then
	local ffi = require("ffi")

	ffi.cdef("bool kfb_dl_init_service(void);\nconst char* kfb_dl_get_deep_link(void);\nbool kfb_dl_check_link(const char* url);\n")

	local C = ffi.C

	proxy = {
		init_service = function(srvid)
			if C.kfb_dl_init_service() then
				return 1
			end
		end,
		get_deep_link = function(srvid)
			return ffi.string(C.kfb_dl_get_deep_link())
		end,
		check_link = function(url)
			return C.kfb_dl_check_link(url)
		end
	}
else
	proxy = require("jni_android")
end

function fbdl:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if KR_PLATFORM == "android" and not require("jni") then
			log.error("%s requires jni.lua. not initialized", name)

			return nil
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s native init failed", name)

				return nil
			end
		end

		self.inited = true
	end

	return true
end

function fbdl:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
end

function fbdl:get_deep_link()
	return proxy.get_deep_link(self.SRV_ID)
end

return fbdl
