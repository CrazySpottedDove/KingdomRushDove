-- chunkname: @./all/privacy_policy_consent.lua
local log = require("lib.klua.log"):new("privacy_policy_consent")

require("lib.klua.table")

local features = require("features")
local storage = require("storage")
local json = require("json")
local PS = require("platform_services")
local signal = require("lib.hump.signal")

require("version")

local INT_1Y = 31536000
local PH_INIT = "INIT"
local PH_REMOTE_TOKEN_ERROR = "REMOTE_TOKEN_ERROR"
local PH_REMOTE_TOKEN_SUCCESS = "REMOTE_TOKEN_SUCCESS"
local PH_STORE_TOKEN = "STORE_TOKEN"
local PH_SERVICES = "SERVICES"
local pp = {}

pp.default_age_of_consent = 16
pp.api_url = "https://dataprotection.ironhidegames.com/api/v1/privacy/consent"
pp.api_key = "MpPdno0CQkJlricHAa6gnwoVvxmV68g7G57ncK1zkDYR3iin6eHRPA=="
pp.request_timeout = 15
pp.should_ask_player = yes
pp.token_template = {
	deviceId = "NONE",
	offline = true,
	bundleId = version.bundle_id,
	age = pp.default_age_of_consent
}

function pp:load_token()
	local global = storage:load_global()

	return global.privacy_policy_token
end

function pp:save_token(token)
	local global = storage:load_global()

	global.privacy_policy_token = token

	storage:save_global(global)
end

function pp:delete_token()
	local global = storage:load_global()

	global.privacy_policy_token = nil

	storage:save_global(global)
end

function pp:get_remote_token()
	local function cb_remote_token(status, req, url, code, header, data)
		log.debug("cb_remote_token(status:%s, req.id:%s url:%s http_code:%s)", status, req.id, url, code)

		local ok, token
		local success = status == 0

		if not success then
			log.debug("http error: request failed. status:%s url:%s", status, url)
		elseif not data then
			log.debug("http error: data is empty for url:%s", url)
		else
			ok, token = PS.services.http:parse_json(data)

			if not ok then
				log.error("http error: failed parsing json %s", data)
			else
				self.remote_token = token

				self:do_phase(PH_REMOTE_TOKEN_SUCCESS)

				goto label_5_0
			end
		end

		self:do_phase(PH_REMOTE_TOKEN_ERROR)

		::label_5_0::

		signal.emit(SGN_PS_HTTP_GET_FINISHED, "http", success, req.id)
	end

	local headers = {
		["ih-deviceId"] = "NONE",
		Accept = "application/json",
		["x-functions-key"] = self.api_key,
		["ih-bundleId"] = version.bundle_id
	}

	self.remote_token = nil

	local rid = PS.services.http:get(self.api_url, headers, cb_remote_token, self.request_timeout)

	log.debug("requesting pp token %s", rid)

	return rid
end

function pp:is_token_valid(token)
	return token ~= nil and token.dateOfConsent ~= nil
end

function pp:time_of_consent(token)
	if not token or not token.dateOfConsent then
		log.error("token has no dateOfConsent: %s", token)

		return os.time() + INT_1Y
	end

	return PS.services.http:date_to_time(token.dateOfConsent)
end

function pp:time_overage(token)
	if not token or not token.birthdate then
		log.error("token has no birthdate: %s", token)

		return os.time() + INT_1Y
	end

	local age_of_consent = token.age or self.default_age_of_consent
	local birthtime = PS.services.http:date_to_time(token.birthdate)

	return birthtime + age_of_consent * INT_1Y
end

function pp:was_overage_with_updated_age(local_token, remote_token)
	if not remote_token.age or not local_token.birthdate or not local_token.dateOfConsent then
		return false
	end

	local birthtime = PS.services.http:date_to_time(local_token.birthdate)
	local time_overage = birthtime + remote_token.age * INT_1Y
	local time_of_consent = self:time_of_consent(local_token)

	return time_overage < time_of_consent
end

function pp:is_token_now_overage(token)
	local now = os.time()
	local time_overage = self:time_overage(token)
	local time_of_consent = self:time_of_consent(token)

	return time_overage < now and time_of_consent < time_overage
end

function pp:init()
	if not features.requires_privacy_policy then
		log.info("privacy policy not enabled. skipping init.")

		self.should_ask_player = false

		return
	end

	if not PS.services.http then
		log.error("privacy_policy_consent requires platform_services_http.")

		return
	end

	self:do_phase(PH_INIT)
end

function pp:is_underage()
	if not features.requires_privacy_policy then
		return false
	end

	if not self:is_token_valid(self.token) then
		return true
	end

	local now = os.time()
	local time_overage = self:time_overage(self.token)

	return now < time_overage
end

function pp:can_show(name)
	if self:is_underage() then
		local hfu = features.hidden_for_underage

		if hfu and table.contains(hfu, name) then
			log.debug("underage players cannot see %s")

			return false
		end
	end

	return true
end

function pp:has_consent()
	if not features.requires_privacy_policy then
		return true
	end

	return self:is_token_valid(self.token)
end

function pp:should_ask()
	if not features.requires_privacy_policy then
		return false
	end

	return self.should_ask_player
end

function pp:give_consent_with_age(month, year)
	if not features.requires_privacy_policy then
		log.error("ignoring consent as features.requires_privacy_policy is disabled")

		return
	end

	if not self.token then
		self.token = table.deepclone(self.token_template)
	end

	self.token.birthdate = string.format("%04i-%02i-%02i", year, month, 1)
	self.token.dateOfConsent = PS.services.http:time_to_date(os.time())

	self:do_phase(PH_STORE_TOKEN)
end

function pp:do_phase(phase)
	if phase == PH_INIT then
		log.debug("phase:%s", phase)

		self.token = self:load_token()

		if not self:is_token_valid(self.token) or self.token.offline or self:is_token_now_overage(self.token) then
			self.should_ask_player = not self:is_token_valid(self.token)

			self:get_remote_token()

			return
		end

		log.debug("phase:%s - valid token found. underage:%s dateOfConsent:%s ", phase, self:is_underage(), self.token.dateOfConsent)

		return self:do_phase(PH_SERVICES)
	elseif phase == PH_REMOTE_TOKEN_ERROR then
		if self:is_token_valid(self.token) then
			log.debug("phase:%s - failed, but have valid stored token", phase)

			return self:do_phase(PH_SERVICES)
		else
			log.debug("phase:%s - failed, so a new offline token", phase)

			self.token = table.deepclone(self.token_template)
			self.token.offline = true

			return
		end
	elseif phase == PH_REMOTE_TOKEN_SUCCESS then
		if self:is_token_valid(self.token) and self:was_overage_with_updated_age(self.token, self.remote_token) then
			log.info("phase:%s - local token underage + remote token over age => silent consent ", phase)

			self.token.age = self.remote_token.age
			self.token.offline = nil
			self.should_ask_player = false

			return self:do_phase(PH_STORE_TOKEN)
		else
			log.debug("phase:%s - store token and ask player for consent", phase)

			self.token = table.deepclone(self.remote_token)
			self.should_ask_player = true

			return
		end
	elseif phase == PH_STORE_TOKEN then
		self:save_token(self.token)

		return self:do_phase(PH_SERVICES)
	elseif phase == PH_SERVICES then
		self.should_ask_player = false

		self:configure_services()
	end
end

function pp:configure_services()
	local s = features.platform_services

	if self:is_underage() then
		if s.news then
			s.news.enabled = false
		end

		if s.push_noti then
			s.push_noti.enabled = false
		end
	end
end

if DEBUG then
	function pp:test_overage_now()
		local now = os.time()
		local bt = now - INT_1Y * 20
		local ct = now - INT_1Y * 10
		local d = {
			deviceId = "NONE",
			bundleId = version.bundle_id,
			age = pp.default_age_of_consent,
			birthdate = PS.services.http:time_to_date(bt),
			dateOfConsent = PS.services.http:time_to_date(ct)
		}

		self:save_token(d)

		self.token = d

		log.error("-----------------------------------------------------")
		log.error("-----------------------------------------------------")
		log.error("RESTART GAME TO TEST. IT SHOULD ASK FOR CONSENT AGAIN")
	end

	function pp:test_was_overage_with_new_age_of_consent()
		local now = os.time()
		local bt = now - INT_1Y * 20
		local ct = now - INT_1Y * 1
		local d = {
			offline = true,
			age = 99,
			deviceId = "NONE",
			bundleId = version.bundle_id,
			birthdate = PS.services.http:time_to_date(bt),
			dateOfConsent = PS.services.http:time_to_date(ct)
		}

		self:save_token(d)

		self.token = d

		log.error("---------------------------------------------------------------")
		log.error("---------------------------------------------------------------")
		log.error("RESTART GAME TO TEST. IT SHOULD SILENTLY TRANSITION TO OVER AGE")
	end
end

return pp
