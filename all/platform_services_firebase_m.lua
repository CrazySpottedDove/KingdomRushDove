-- chunkname: @./all/platform_services_firebase_m.lua

local log = require("lib.klua.log"):new("platform_services_firebase_m")

require("lib.klua.table")
require("lib.klua.string")
require("constants")

local fbm = {}

fbm.can_be_paused = true
fbm.update_interval = 5
fbm.SRV_ID = 52
fbm.SRV_DISPLAY_NAME = "Firebase Messaging"

local proxy

if KR_PLATFORM == "ios" then
	local ffi = require("ffi")

	ffi.cdef("bool kfb_m_init_service(void);\nconst char* kfb_m_get_messaging_token(void);\n")

	local C = ffi.C

	proxy = {
		init_service = function(srvid)
			if C.kfb_m_init_service() then
				return 1
			end
		end,
		get_messaging_token = function(srvid)
			return ffi.string(C.kfb_m_get_messaging_token())
		end
	}
else
	proxy = require("jni_android")
end

function fbm:init(name, params)
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

function fbm:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
end

function fbm:get_token()
	return proxy.get_messaging_token(self.SRV_ID)
end

return fbm
