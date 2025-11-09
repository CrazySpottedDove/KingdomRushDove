-- chunkname: @./all/remote_config.lua

local log = require("klua.log"):new("remote_config")
local signal = require("hump.signal")
local PS = require("platform_services")

require("constants")
require("version")

rc = {}
rc.signal_handlers = {
	[SGN_PS_REMOTE_CONFIG_SYNC_FINISHED] = function(service_name, success)
		if success then
			rc:apply_remote_config()
		end
	end
}

function rc:init()
	self.v = {}
	self.v_defaults = {}
	self._vmt = {}

	setmetatable(rc.v, rc._vmt)
	self:reload()

	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end
end

function rc:destroy()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end
end

function rc:reload()
	local filename = KR_PATH_GAME_TARGET .. "/data/remote_config_defaults.lua"

	if not love.filesystem.getInfo(filename) then
		log.info("error loading %s. File not found", filename)

		return
	end

	log.debug("loading from file %s", filename)

	local str = love.filesystem.read(filename)
	local chunk, err = loadstring(str)

	if not chunk then
		log.error("error loading %s. Error: %s", filename, err)

		return
	end

	local env = {}

	env.bundle_id = version.bundle_id
	env.pairs = pairs
	env.type = type
	env.string = string

	setfenv(chunk, env)

	local ok, result = pcall(chunk)

	if not ok then
		log.error("error calling %s. Error: %s", filename, tostring(result))

		return
	end

	self.v_defaults = result
	self._vmt.__index = self.v_defaults
end

function rc:sync()
	if not PS.services.remoteconfig then
		log.debug("PS.services.remoteconfig not available")

		return
	end

	PS.services.remoteconfig:sync()
end

function rc:apply_remote_config()
	log.debug("applying remote config...")

	local psrc = PS.services.remoteconfig

	if not psrc then
		log.debug("PS.services.remoteconfig not available")

		return
	end

	local lkeys = table.keys(self.v_defaults)
	local fkeys = table.filter(psrc:get_keys(), function(k, v)
		return not table.contains(lkeys, v)
	end)
	local keys = table.append(lkeys, fkeys, true)
	local env = {}

	for _, k in pairs(keys) do
		local rv = psrc:get_string(k)

		if rv and rv ~= "" then
			local s_expr = "return " .. rv
			local fs, err = loadstring(s_expr)

			if not fs then
				log.error("error loading remote config string for key:%s value:%s. reactivating default", k, s_expr)

				self.v[k] = nil
			else
				setfenv(fs, env)

				local ok, s_val = pcall(fs)

				if ok then
					log.debug("  %s = %s", k, s_val)

					self.v[k] = s_val
				else
					log.error("error evaluating remote config key:%s value:%s. reactivating default", k, rv)

					self.v[k] = nil
				end
			end
		end
	end

	signal.emit(SGN_REMOTE_CONFIG_UPDATED)
end

return rc
