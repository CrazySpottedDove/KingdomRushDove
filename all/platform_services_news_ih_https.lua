-- chunkname: @./all/platform_services_news_ih_https.lua
local log = require("lib.klua.log"):new("platform_services_news_ih_https")

require("lib.klua.table")
require("lib.klua.string")

local signal = require("hump.signal")
local PS = require("platform_services")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local I = require("klove.image_db")
local i18n = require("i18n")
local storage = require("storage")

require("constants")
require("version")

local news = {}

news.can_be_paused = true
news.update_interval = 1
news.texture_group = "cached_news_images"
news.cached_data = nil
news.cache = {}
news.texture_scale = 1

function news:init(name, params)
	if self.inited then
		log.debug("service %s already inited", name)
	else
		if not PS.services.http or not PS.services.http.inited then
			log.error("platform_services_news_ih requires platform_services_http inited")

			return nil
		end

		if not params or not params.news_id or not params.news_store then
			log.error("platform_services_news_ih requires news_id and news_store params")

			return nil
		end

		self.news_id = params.news_id
		self.news_store = params.news_store
		self.inited = true
	end

	return true
end

function news:shutdown(name)
	if self.inited then
	-- block empty
	end

	self.inited = nil
end

function news:cache_news()
	local url = self:get_url()

	if not url then
		log.debug("news URL is nil. skipping...")

		return
	end

	local function cb_dl_news(status, req, url, code, header, data)
		log.debug("cb_dl_news(status:%s, req.id:%s)", status, req.id)

		local success = status == 0

		if success then
			self:store_response(req.id, url, code, header, data)

			if data then
				log.debug("cached request contents:%s", data)

				local ok, dl = PS.services.http:parse_json(data)

				if ok then
					self.cached_data = dl
				else
					success = false
					self.cached_data = nil
				end
			end
		end

		signal.emit(SGN_PS_NEWS_CACHED, "news", success, req.id)
	end

	local rid = PS.services.http:get(url, self:get_headers(url), cb_dl_news)

	log.debug("caching news from %s", url, rid)

	return rid
end

function news:cache_image(suffix)
	local url = self:get_url(suffix)

	if not url then
		log.debug("image URL is nil. skipping...")

		return
	end

	local function cb_dl_image(status, req, url, code, header, data)
		local success = status == 0

		if success then
			self:store_response(req.id, suffix, code, header, data)

			if header["Content-Type"] and (header["Content-Type"] == "image/png" or header["Content-Type"] == "image/jpeg") then
				local fd, ok, imd, im

				if data then
					fd = love.filesystem.newFileData(data, suffix)
				end

				if fd then
					ok, imd = pcall(love.image.newImageData, fd)
				end

				if ok and imd then
					im = love.graphics.newImage(imd)
				end

				if im then
					I:add_image(suffix, im, self.texture_group, self.texture_scale)
					log.debug("Image loaded as %s", suffix)
				else
					success = false

					log.error("Image could not be created from suffix: %s. error:%s", suffix, imd)
				end
			end
		end

		signal.emit(SGN_PS_NEWS_IMAGE_CACHED, "image", success, req.id, status)
	end

	local rid = PS.services.http:get(url, self:get_headers(url), cb_dl_image)

	log.debug("caching image %s", url, rid)

	return rid
end

function news:get_cached_request(rid)
	return self.cache[rid]
end

function news:get_news()
	local d = self.cached_data

	if d and d.items and #d.items > 0 then
		return d.items
	end

	return nil
end

function news:has_force_show()
	local d = self.cached_data

	if not d or not d.forceShow or not self:has_unseen() then
		return false
	end

	return d.forceShow == true
end

function news:has_unseen()
	local d = self.cached_data

	if not d or not d.items or #d.items < 1 or not d.lastUpdated then
		return false
	end

	local rtime = self:date_to_time(d.lastUpdated)

	if not rtime then
		return false
	end

	local nd = self:load_news_data()

	return not nd.last_seen_time or rtime > nd.last_seen_time or nd.last_refresh_id ~= d.refreshId
end

function news:mark_seen()
	local nd = self:load_news_data()
	local d = self.cached_data
	local rtime = d and d.lastUpdated and self:date_to_time(d.lastUpdated)

	if rtime then
		nd.last_seen_time = rtime
	else
		nd.last_seen_time = os.time()
	end

	nd.last_refresh_id = d.refreshId

	self:save_news_data(nd)
end

function news:get_url(path)
	local url = RC.v.news_url

	if DEBUG_NEWS_URL then
		log.error("overriding news url with debug value %s", DEBUG_NEWS_URL)

		url = DEBUG_NEWS_URL
	end

	if path then
		if string.starts(path, "http") then
			url = path
		elseif string.starts(path, "/") then
			local parts = string.split(url, "/")

			url = parts[1] .. "//" .. parts[2] .. path
		else
			url = url .. "/" .. path
		end
	end

	return url
end

function news:get_headers(url)
	local headers = {
		ih_engine = "love",
		accept = "application/json, image/jpeg, image/png",
		["accept-language"] = i18n.current_locale,
		ih_appid = self.news_id,
		ih_appversion = version.string_short,
		ih_bundle = version.bundle_id,
		ih_store = self.news_store,
		ih_platform = KR_PLATFORM,
		ih_game = KR_GAME,
		ih_target = KR_TARGET,
		ih_appversion_long = version.string,
		ih_localtime = self:time_to_date(os.time())
	}

	return headers
end

function news:store_response(rid, url, code, header, data)
	log.debug("caching response for rid:%s, url:%s, header:%s", rid, url, header, data)

	self.cache[rid] = {
		url = url,
		ts = os.time(),
		code = code,
		header = header,
		body = data
	}

	return data, header, code
end

function news:load_news_data()
	local global = storage:load_global()

	return global.news or {}
end

function news:save_news_data(md)
	local global = storage:load_global()

	if not global.news then
		global.news = {}
	end

	table.merge(global.news, md)
	storage:save_global(global)
end

function news:date_to_time(date)
	local m = {string.match(date, "(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d)")}

	if m and #m > 0 then
		return os.time({
			year = m[1],
			month = m[2],
			day = m[3],
			hour = m[4],
			min = m[5]
		})
	else
		return os.time()
	end
end

function news:time_to_date(time)
	return os.date("%Y-%m-%dT%TZ", time)
end

return news
