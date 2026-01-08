-- chunkname: @./all/platform_services_firebase_a.lua
local log = require("lib.klua.log"):new("platform_services_firebase_a")
local signal = require("lib.hump.signal")

require("lib.klua.table")
require("lib.klua.string")
require("all.constants")

local fba = {}

fba.can_be_paused = true
fba.update_interval = 3
fba.SRV_ID = 51
fba.SRV_DISPLAY_NAME = "Firebase Analytics"
fba.signal_handlers = {
	["game-start"] = function(store)
		fba:log_event("kr_game_init", "level", tostring(store.level_idx))
	end,
	["game-defeat"] = function(store)
		fba:log_event("kr_game_defeat", "level", tostring(store.level_idx))

		if store.restarted then
			fba:log_event("kr_game_defeat_multiple", "level", tostring(store.level_idx))
		end
	end,
	["game-victory"] = function(store)
		fba:log_event("kr_game_victory", "level", tostring(store.level_idx))
	end,
	["got-achievement"] = function(ach_id)
		fba:log_event("kr_got_achievement", "id", ach_id)
	end,
	[SGN_MARKETING_OFFER_SHOWN] = function(o_name)
		fba:log_event("kr_offer_shown", "name", o_name)
	end,
	[SGN_MARKETING_OFFER_ICON_TOUCHED] = function(o_name)
		fba:log_event("kr_offer_icon_touched", "name", o_name)
	end,
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(srv, ok, prod, currency, is_restored)
		if is_restored then
			fba:log_event("kr_purchase_restore", "prod_id", prod)
		elseif currency ~= nil and currency ~= "" then
			fba:log_event("kr_purchase_" .. currency, "prod_id", prod)
		else
			fba:log_event("kr_purchase", "prod_id", prod)
		end
	end,
	[SGN_PS_PREMIUM_UNLOCKED] = function(srv, id)
		fba:log_event("premium_unlock_" .. id)
	end
}

local proxy

if KR_PLATFORM == "ios" then
	proxy = {}

	local ffi = require("ffi")

	ffi.cdef("bool kfb_a_init_service(void);\nvoid kfb_a_log_analytics_event(const char* name, const char* key, const char* value);\nvoid kfb_a_log_and_crash(const char* msg);\nvoid kfb_cr_set_collection(bool value);\n")

	local C = ffi.C

	function proxy.init_service(srvid)
		if C.kfb_a_init_service() then
			return 1
		end
	end

	function proxy.log_analytics_event(srvid, name, key, value)
		if not fba.inited then
			return -1
		end

		C.kfb_a_log_analytics_event(name, key, value)
	end

	function proxy.crashlytics_log_and_crash(msg)
		if not fba.inited then
			return -1
		end

		C.kfb_a_log_and_crash(msg)
	end

	function proxy.crashlytics_set_collection(value)
		C.kfb_cr_set_collection(value)
	end
end

function fba:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if KR_PLATFORM == "android" and not require("jni") then
			log.error("%s requires jni.lua. not initialized", name)

			return nil
		end

		if not params or params.disable_crashlytics ~= true then
			proxy.crashlytics_set_collection(true)
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("%s native init failed", name)

				return nil
			end
		end

		if self.signal_handlers then
			for sn, fn in pairs(self.signal_handlers) do
				log.debug("registering signal %s", sn)
				signal.register(sn, fn)
			end
		end

		self.inited = true
	end

	return true
end

function fba:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.inited = nil
end

function fba:log_event(name, key, value)
	value = string.format("%s", value)

	proxy.log_analytics_event(self.SRV_ID, name, key, value)
end

function fba:log_and_crash(msg)
	proxy.crashlytics_log_and_crash(msg)
end

function fba:set_crash_collection(value)
	proxy.crashlytics_set_collection(value)
end

return fba
