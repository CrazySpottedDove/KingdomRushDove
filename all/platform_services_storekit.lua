-- chunkname: @./all/platform_services_storekit.lua
require("lib.klua.string")
local log = require("lib.klua.log"):new("platform_services_storekit")
local PSU = require("platform_services_utils")
local signal = require("hump.signal")
local storage = require("storage")
local RC = require("remote_config")
local sk = {}
sk.can_be_paused = true
sk.update_interval = 1
sk.SRV_DISPLAY_NAME = "Apple App Store"
sk.rc_suffix = "storekit"
sk.LONG_TIMEOUT = 900
sk.sku_index = {}
sk.sync_times = {}
sk.purchases_cache = {}
sk.products_cache = {}
sk.lib = nil
sk.inited = false
local ffi = require("ffi")
ffi.cdef("void skw_set_service_param(const char* key, const char* value);\nbool skw_initialize(void);\nvoid skw_shutdown(void);\nint  skw_get_status(void);\n\nvoid skw_delete_request(int rid);\nint skw_get_request_status(int rid);\n\nint skw_create_request_sync_products(const char* skus);\nint skw_create_request_purchase_product(const char* sku);\nint skw_create_request_restore_purchases(void);\n\nbool skw_can_make_payments(void);\nconst char* skw_get_formatted_currency(const char* amount, const char* locale);\n\nconst char* skw_get_cached_products(void);\nconst char* skw_pop_purchased_skus(void);\n\nvoid skw_request_review(void);\n")

function sk:init(name, params)
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

		self.prq = PSU:new_prq()
	end

	self.names = self.names or {}

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	self:update_sku_index()
	return true
end

function sk:shutdown(name)
	log.debug("Shutting down ")

	if self.inited then
		self.lib.skw_shutdown()
	end

	self.names = nil
	self.lib = nil
	self.inited = false
end

function sk:get_status()
	if self.inited and self.lib.skw_get_status() == 1 then
		return true
	else
		return nil
	end
end

function sk:is_premium()
	return self.premium
end

function sk:get_sync_status()
	return self.sync_times
end

function sk:get_pending_requests()
	return self.prq
end

function sk:get_request_status(rid)
	local result = self.lib.skw_get_request_status(rid)
	return result
end

function sk:cancel_request(rid)
	if not rid then
		return 
	end

	self.prq:remove(rid)
	self.lib.skw_delete_request(rid)
end

function sk:sync_purchases(silent)
	local all_ids = {}
	local purchased_ids = {}

	if not silent then
		local new_skus_str = ffi.string(self.lib.skw_pop_purchased_skus())
		local new_purchases = self:parse_purchases(new_skus_str)

		for _, pu in pairs(new_purchases) do
			table.insert(all_ids, pu.id)

			if pu.source == "purchased" then
				table.insert(purchased_ids, pu.id)
			end
		end
	end

	local global = storage:load_global()

	for _, id in pairs(global.purchased_heroes or {}) do
		table.insert(all_ids, id)
	end

	for _, id in pairs(all_ids) do
		local p = self:get_product(id, true)

		if not p then
			log.error("Sync purchases error. Product with id:%s not found in remote_config", id)
		else
			self:deliver_purchase(id)

			if not silent then
				signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", status == 0, id, "", not table.contains(purchased_ids, id))
			end
		end
	end

	local purchased_heroes = {}

	for id, v in pairs(self.purchases_cache) do
		if string.starts(id, "hero_") and not table.contains(purchased_heroes, id) then
			table.insert(purchased_heroes, id)
		end
	end

	global = storage:load_global()
	global.purchased_heroes = purchased_heroes
	storage:save_global(global)
	self.sync_times.purchases = os.time()
end

function sk:restore_purchases()
	local function cb_restore_purchases(status, req)
		if not self.prq:contains(req.id) then
			return 
		end

		log.info("restore_purchases complete for req.id:%s status:%s", req.id, status)
		local success

		if status == 0 then
			success = true
			local global = storage:load_global()
			global.purchased_heroes = nil
			storage:save_global()
			self:sync_purchases()
			self.sync_times.restore = os.time()
		else
			success = false
			self.sync_times.restore = false
		end

		signal.emit(SGN_PS_RESTORE_PURCHASES_FINISHED, "iap", success)
	end

	local rid = self.lib.skw_create_request_restore_purchases()

	if rid < 0 then
		log.error("error creating requst to restore products")
		return nil
	else
		self.prq:add(rid, "restore_purchases", cb_restore_purchases, self.LONG_TIMEOUT)
		return rid
	end
end

function sk:sync_purchase_history()
	return 
end

function sk:purchase_product(id)
	local function cb_purchase(status, req)
		if not self.prq:contains(req.id) then
			return 
		end

		log.info("purchase_product complete for req.id:%s status:%s", req.id, status)
		local success

		if status == 0 then
			success = true
			self:sync_purchases()
		else
			success = false
		end

		signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", success, req.product_id)
	end

	local p = self:get_product(id, true)

	if not p then
		log.error("could not initiate purchase of product %s. not found in remote_config", id)
		return nil
	end

	log.info("purchasing product:%s consume:%s", id, p.consumable)
	local sku = p.skus and (p.skus[self.rc_suffix] or p.skus.default)

	if not sku then
		log.error("missing sku for product: %s", id)
		return nil
	end

	local rid = self.lib.skw_create_request_purchase_product(sku)

	if rid < 0 then
		log.error("error creating request to purchase iap %s", id)
		return nil
	else
		local req = self.prq:add(rid, "purchase", cb_purchase, sk.LONG_TIMEOUT)
		req.product_id = id
		req.sku = sku
		req.consumable = p.consumable
		return rid
	end
end

function sk:sync_products()
	local function cb_sync_products(status, req)
		if not self.prq:contains(req.id) then
			return 
		end

		log.info("sync_products complete for req.id:%s status:%s", req.id, status)
		local success

		if status == 0 then
			success = true
			local products_string = ffi.string(self.lib.skw_get_cached_products())
			log.debug("products_string:%s", products_string)
			local store_products = self:parse_products(products_string)

			for _, sp in pairs(store_products) do
				local p = self:get_product(sp.id)

				if not p then
					log.error("iap product %s not found in remote config", sp.id)
				else
					if not self.products_cache[sp.id] then
						self.products_cache[sp.id] = {}
					end

					local cp = self.products_cache[sp.id]
					cp.sku = sp.sku
					cp.title = sp.title
					cp.description = sp.description
					cp.price = sp.price
					cp.price_micros = sp.price_micros
					cp.price_currency_code = sp.price_currency_code
					log.debug("iap cached product %s: %s", sp.id, getfulldump(p))
				end
			end

			self.sync_times.products = os.time()
		else
			success = false
			self.sync_times.products = false
		end

		signal.emit(SGN_PS_SYNC_PRODUCTS_FINISHED, "iap", success)
	end

	self:update_sku_index()
	local skus_table = {}

	for _, n in pairs(RC.v["products_" .. self.rc_suffix]) do
		local p = self:get_product(n)

		if not p then
			log.error("product %s not defined in remote_config")
		elseif not p.skus or not p.skus[self.rc_suffix] and not p.skus.default then
		-- block empty
		else
			table.insert(skus_table, p.skus[self.rc_suffix] or p.skus.default)
		end
	end

	local skus = table.concat(skus_table, ";")
	local rid = self.lib.skw_create_request_sync_products(skus)

	if rid < 0 then
		log.error("error creating request to sync products")
		return nil
	else
		self.prq:add(rid, "sync_products", cb_sync_products)
		return rid
	end
end

function sk:get_product(id, reference)
	if not id then
		log.error("trying to get product with nil id")
		return nil
	end

	local k = "product_" .. id
	local p = RC.v[k]

	if not p then
		log.error("product %s not found in remote_config %s", id, k)
		return nil
	end

	if reference then
		return p
	end

	local o = table.deepclone(p)

	if self.products_cache[id] then
		o = table.merge(o, self.products_cache[id])
	end

	if self.purchases_cache[id] then
		o = table.merge(o, self.purchases_cache[id])
	end

	o.id = id
	return o
end

function sk:get_offers()
	if self:is_premium() then
		log.debug("storekit is premium. no offers shown")
		return {}
	end

	local offers = RC.v["offers_" .. self.rc_suffix]

	if not offers then
		log.error("offers_storekit not found in remote_config")
		return {}
	end

	return offers
end

function sk:get_hero_sales()
	if self:is_premium() then
		log.debug("storekit is premium. no hero sales shown")
		return {}
	end

	local offers = RC.v["hero_sales_" .. self.rc_suffix]

	if not offers then
		log.error("hero_sales_storekit not found in remote_config")
		return {}
	end

	return offers
end

function sk:get_formatted_currency(amount_micros, currency_code)
	log.debug("get_formatted_currency(%s,%s)", amount_micros, currency_code)

	if not currency_code or currency_code == "" then
		log.error("get_formatted_currency error. currency code is nil. default to en_US!")
		currency_code = "en_US"
	end

	local amount_string = "0"

	if amount_micros and type(amount_micros) == "number" then
		amount_string = tostring(amount_micros / 1000000)
	end

	return ffi.string(self.lib.skw_get_formatted_currency(amount_string, currency_code))
end

function sk:request_review()
	self.lib.skw_request_review()
end

function sk:update_sku_index()
	for _, n in pairs(RC.v["products_" .. self.rc_suffix]) do
		local p = self:get_product(n)
		local sku = p and p.skus and (p.skus[self.rc_suffix] or p.skus.default)

		if sku then
			self.sku_index[sku] = n
		end
	end
end

function sk:parse_products(str)
	if not str or str == "" then
		return {}
	end

	local lines = string.split(str, "\n")

	if not lines or #lines == 0 then
		return {}
	end

	local out = {}

	for _, line in pairs(lines) do
		local sku, title, description, price, price_micros, price_currency_code = unpack(string.split(line, ";"))
		local id = self.sku_index[sku]

		if not id then
			log.debug("sku:%s not found in sku_index", sku)
		else
			local t = {
				sku = sku,
				title = title,
				description = description,
				price = price,
				price_micros = tonumber(price_micros),
				price_currency_code = price_currency_code
			}
			t.id = id
			table.insert(out, t)
		end
	end

	return out
end

function sk:parse_purchases(str)
	if not str or str == "" then
		return {}
	end

	local out = {}

	for _, item in pairs(string.split(str, ";")) do
		local sku, source = unpack(string.split(item, ":"))
		local id = self.sku_index[sku]

		if not id then
			log.debug("sku:%s not found in sku_index", sku)
		else
			local t = {
				sku = sku,
				id = id,
				source = source
			}
			table.insert(out, t)
		end
	end

	return out
end

function sk:deliver_purchase(id)
	log.info("delivering purchase for id: %s", id)
	local p = self:get_product(id, true)

	if not p then
		log.error("id:%s not found in remote_config", id)
		return false
	end

	if not self.purchases_cache[id] then
		self.purchases_cache[id] = {}
	end

	local cp = self.purchases_cache[id]

	if p.includes then
		for _, subid in pairs(p.includes) do
			log.debug("  delivering product pack:%s item:%s", id, subid)
			self:deliver_purchase(subid)
		end

		cp.owned = true
	elseif p.gems then
		local slot = storage:load_slot()

		if slot then
			slot.gems = slot.gems + p.reward

			if not slot.gems_purchased then
				slot.gems_purchased = 0
			end

			slot.gems_purchased = slot.gems_purchased + p.reward
			storage:save_slot(slot, nil, true)
		end
	else
		cp.owned = true
	end

	return true
end

return sk
