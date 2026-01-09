-- chunkname: @./all/platform_services_ads.lua
local log = require("lib.klua.log"):new("platform_services_ads")

require("lib.klua.table")

local signal = require("lib.hump.signal")
local storage = require("storage")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local S = require("sound_db")

require("all.constants")

local ads = {}

ads.can_be_paused = true
ads.update_interval = 3
ads.TIMEOUT = -1
ads.signal_handlers = {}

local proxy

if KR_PLATFORM == "ios" then
	proxy = {}

	local ffi = require("ffi")

	ffi.cdef("void kadmob_set_service_param(const char* key, const char* value);\nbool kadmob_init_service(void);\nvoid kadmob_cache_video_ad(const char* type);\nint kadmob_create_request_show_video_ad(const char* type);\nvoid kadmob_delete_request(int rid);\nint kadmob_get_request_status(int rid);\nbool kadmob_has_video_ad(const char* type);\n")

	local C = ffi.C

	function proxy.set_service_param(key, value)
		C.kadmob_set_service_param(key, value)
	end

	function proxy.init_service()
		if C.kadmob_init_service() then
			return 1
		end
	end

	function proxy.delete_request(rid)
		C.kadmob_delete_request(rid)
	end

	function proxy.get_request_status(rid)
		return C.kadmob_get_request_status(rid)
	end

	function proxy.cache_video_ad(srvid, ad_type)
		return C.kadmob_cache_video_ad(ad_type)
	end

	function proxy.create_request_show_video_ad(srvid, ad_type)
		return C.kadmob_create_request_show_video_ad(ad_type)
	end

	function proxy.has_video_ad(srvid, ad_type)
		return C.kadmob_has_video_ad(ad_type)
	end
end

function ads:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not require("jni") then
			log.error("%s requires jni.lua. not initialized", name)

			return nil
		end

		if not params or not params.providers then
			log.error("%s requires params.providers", name)

			return nil
		end

		self.providers = {}
		self.prio = params.prio

		for k, v in pairs(params.providers) do
			local result

			if not v.enabled then
				log.debug("%s-%s disabled", name, k)
			else
				self.providers[k] = v

				if v.srvparams then
					for sk, sv in pairs(v.srvparams) do
						local param_name = k .. "_" .. sk

						proxy.set_service_param(param_name, sv)
					end
				end

				result = proxy.init_service(v.srvid)

				log.debug("%s-%s java init result:%s", name, k, result)

				if result ~= 1 then
					log.error("%s-%s java init failed", name, k)
				end
			end
		end

		self.prq = PSU:new_prq()

		for sn, fn in pairs(self.signal_handlers) do
			signal.register(sn, fn)
		end

		self.inited = true
	end

	return true
end

function ads:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.inited = nil
end

function ads:get_pending_requests()
	return self.prq
end

function ads:get_request_status(rid)
	local result = proxy.get_request_status(rid)

	log.paranoid("get_request_status service:%s rid:%s jni_result:%s", self.name, rid, result)

	return result
end

function ads:cancel_request(rid)
	log.debug("cancelling request %s", rid)

	if not rid then
		log.paranoid("cancel_request service:%s rid:%s not found", self.name, rid)

		return
	end

	self.prq:remove(rid)
	proxy.delete_request(rid)
end

function ads:cache_video_ad(provider)
	for k, v in pairs(self.providers) do
		if not provider or k == provider then
			proxy.cache_video_ad(v.srvid, "rewarded")
		end
	end
end

function ads:get_provider_with_video_ad()
	local prio = RC.v.ads_prio or self.prio

	if not prio then
		log.debug("no prio configured. checking all of them in any order")

		for k, v in pairs(self.providers) do
			if proxy.has_video_ad(v.srvid, "rewarded") then
				log.debug("selected provider:%s with a video ad ready", k)

				return k
			end
		end
	else
		for i, tier in ipairs(prio) do
			log.paranoid("processing tier %s", i)

			if type(tier) == "string" then
				log.paranoid("  string")

				local k = tier
				local v = self.providers[k]

				if v and proxy.has_video_ad(v.srvid, "rewarded") then
					log.debug("selected tier:%s provider:%s with a video ad ready", i, k)

					return k
				end
			elseif type(tier) == "table" then
				log.paranoid("  table")

				local pool = {}

				for _, k in pairs(tier) do
					local v = self.providers[k]

					if v and proxy.has_video_ad(v.srvid, "rewarded") then
						pool[#pool + 1] = k
					end
				end

				log.paranoid("  pool:%s", getfulldump(pool))

				if #pool > 0 then
					local rk = table.random(pool)

					log.debug("selected tier:%s random provider:%s with a video ad ready", i, rk)

					return rk
				end
			end
		end
	end

	return nil
end

function ads:show_video_ad(provider, data, style)
	local function cb_show_video_ad(status, req)
		local success = status == 0

		if success and data then
			PSU:deliver_rewards(data.rewards)
		end

		S:resume()
		signal.emit(SGN_PS_AD_SHOW_VIDEO_FINISHED, "ads", success, data, status)
	end

	local srvid = self.providers[provider].srvid
	local rid = proxy.create_request_show_video_ad(srvid, "rewarded")

	if rid < 0 then
		log.error("error creating request to show video ad from:%s error:%s", provider, rid)

		return nil
	end

	self.prq:add(rid, "show_ad", cb_show_video_ad, self.TIMEOUT)
	S:pause()
	signal.emit(SGN_PS_AD_SHOW_VIDEO_STARTED, "ads")

	return rid
end

return ads
