-- chunkname: @./all/platform_services_iap_premium.lua
local log = require("lib.klua.log"):new("platform_services_iap_premium")

log.level = log.DEBUG_LEVEL

require("lib.klua.table")

local signal = require("hump.signal")
local storage = require("storage")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local tiap = {}

tiap.can_be_paused = true
tiap.update_interval = 1
tiap.rc_suffix = "iap_premium"
tiap.purchases_cache = {}
tiap.products_cache = {}
tiap.sync_times = {}
tiap._request_delay = 2
tiap._rid = 1
tiap.signal_handlers = {}

function tiap:init(name, params)
	log.debug("platform_services_iap_premium loaded")

	if self.inited then
		log.debug("platform_services_iap_premium %s already inited", name)
	else
		self.prq = PSU:new_prq()

		for sn, fn in pairs(self.signal_handlers) do
			signal.register(sn, fn)
		end

		self.inited = true
	end

	if not self.names then
		self.names = {}
	end

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function tiap:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function tiap:get_status()
	return true
end

function tiap:is_premium()
	return true
end

function tiap:get_pending_requests()
	return self.prq
end

function tiap:get_sync_status()
	return self.sync_times
end

function tiap:get_request_status(rid)
	local req = self.prq[rid]

	if not req then
		return -1
	elseif love.timer.getTime() - req.ts < self._request_delay then
		return 1
	else
		return 0
	end
end

function tiap:cancel_request(rid)
	self.prq:remove(rid)
end

function tiap:sync_purchases(silent)
	self.sync_times.purchases = os.time()
end

function tiap:purchase_product(id)
	log.debug("platform_services_iap_premium does not support purchase_product")

	return nil
end

function tiap:get_product(id, reference)
	log.debug("platform_services_iap_premium does not support get_product")

	return nil
end

function tiap:get_offers()
	log.debug("platform_services_iap_premium does not show offers")

	return {}
end

function tiap:get_hero_sales()
	log.debug("platform_services_iap_premium does not show hero sales")

	return {}
end

function tiap:get_formatted_currency(amount_micros, currency_code)
	return string.format("$%.2f", amount_micros / 1000000)
end

function tiap:sync_products()
	return -1
end

return tiap
