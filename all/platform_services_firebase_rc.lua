-- chunkname: @./all/platform_services_firebase_rc.lua

local log = require("lib.klua.log"):new("platform_services_firebase_rc")

require("lib.klua.table")
require("lib.klua.string")

local signal = require("hump.signal")
local PSU = require("platform_services_utils")

require("constants")

local fbrc = {}

fbrc.can_be_paused = true
fbrc.update_interval = 3
fbrc.SRV_ID = 50
fbrc.SRV_DISPLAY_NAME = "Firebase Remote Config"

local proxy

if KR_PLATFORM == "ios" then
	local ffi = require("ffi")

	ffi.cdef("void kfb_set_service_param(const char* key, const char* value);\nint kfb_get_request_status(int rid);\nvoid kfb_delete_request(int rid);\nbool kfb_rc_init_service(void);\nint kfb_rc_create_request_sync_remote_config(void);\nconst char* kfb_rc_get_remote_config_keys(void);\nconst char* kfb_rc_get_remote_config_string(const char* key);\n")

	local C = ffi.C

	proxy = {
		init_service = function(srvid)
			if C.kfb_rc_init_service() then
				return 1
			end
		end,
		set_service_param = function(key, value)
			C.kfb_set_service_param(key, value)
		end,
		create_request_sync_remote_config = function(srvid)
			if not fbrc.inited then
				return -1
			end

			local result = C.kfb_rc_create_request_sync_remote_config()

			return result
		end,
		delete_request = function(rid)
			C.kfb_delete_request(rid)
		end,
		get_request_status = function(rid)
			if fbrc.inited then
				local result = C.kfb_get_request_status(rid)

				return result
			else
				return -1
			end
		end,
		get_remote_config_keys = function(srvid)
			return ffi.string(C.kfb_rc_get_remote_config_keys())
		end,
		get_remote_config_string = function(srvid, key)
			return ffi.string(C.kfb_rc_get_remote_config_string(key))
		end
	}
else
	proxy = require("jni_android")
end

function fbrc:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if KR_PLATFORM == "android" and not require("jni") then
			log.error("%s requires jni.lua. not initialized", name)

			return nil
		end

		if DEBUG then
			proxy.set_service_param("firebase_rc_debug_on", "true")
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s java init failed", name)

				return nil
			end
		end

		self.prq = PSU:new_prq()
		self.inited = true
	end

	return true
end

function fbrc:shutdown(name)
	if self.inited then
		-- block empty
	end

	self.inited = nil
end

function fbrc:get_pending_requests()
	return self.prq
end

function fbrc:get_request_status(rid)
	local result = proxy.get_request_status(rid)

	log.paranoid("get_request_status service:%s rid:%s result:%s", self.name, rid, result)

	return result
end

function fbrc:cancel_request(rid)
	log.debug("cancelling request %s", rid)

	if not rid then
		log.paranoid("cancel_request service:%s rid:%s not found", self.name, rid)

		return
	end

	self.prq:remove(rid)
	proxy.delete_request(rid)
end

function fbrc:get_string(key)
	return proxy.get_remote_config_string(self.SRV_ID, key)
end

function fbrc:get_keys()
	local out = {}
	local str = proxy.get_remote_config_keys(self.SRV_ID)

	if str then
		out = string.split(str, ",")
	end

	return out
end

function fbrc:sync()
	local function cb_sync_rc(status, req)
		local success = status == 0

		signal.emit(SGN_PS_REMOTE_CONFIG_SYNC_FINISHED, "remoteconfig", success)
	end

	local rid = proxy.create_request_sync_remote_config(self.SRV_ID)

	if rid < 0 then
		log.error("remote config sync error: %s", rid)

		return nil
	end

	self.prq:add(rid, "sync_remote_config", cb_sync_rc)

	return rid
end

return fbrc
