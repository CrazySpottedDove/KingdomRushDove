-- chunkname: @./all/platform_services_utils.lua
local log = require("lib.klua.log"):new("platform_services_utils")
local signal = require("lib.hump.signal")
local storage = require("storage")
local psu = {}

function psu:new_prq()
	local t = {}
	local mt = {}

	mt.__index = {
		add = function(this, rid, kind, callback, timeout)
			local item = {
				id = rid,
				kind = kind,
				callback = callback,
				ts = love.timer.getTime(),
				timeout = timeout
			}

			rawset(this, rid, item)

			return item
		end,
		remove = function(this, rid)
			local item = rawget(this, rid)

			rawset(this, rid, nil)

			return item
		end,
		contains = function(this, rid)
			return rawget(this, rid) ~= nil
		end
	}

	setmetatable(t, mt)

	return t
end

function psu:load_library(name, ffi)
	local osname = love.system.getOS()

	if osname == "iOS" then
		return ffi.C
	else
		local lib_name = self:get_library_file(name)

		return ffi.load(lib_name)
	end
end

function psu:get_library_path()
	if love.filesystem.isFused() then
		return ""
	else
		local osname = love.system.getOS()
		local path = love.filesystem.getSourceBaseDirectory() .. "/platform/bin"

		if osname == "Windows" then
			return string.format("%s/%s.%s", path, osname, jit.arch)
		elseif osname == "OS X" then
			return string.format("%s/macOS", path)
		elseif osname == "iOS" then
			return string.format("%s/iOS", path)
		elseif osname == "Linux" or osname == "Android" then
			return string.format("%s/%s", path, osname)
		else
			return name
		end
	end
end

function psu:get_library_file(name)
	if love.filesystem.isFused() then
		return name
	else
		local path = self:get_library_path()
		local osname = love.system.getOS()

		if osname == "Windows" then
			return string.format("%s/%s.dll", path, name)
		elseif osname == "OS X" then
			return string.format("%s/lib%s.dylib", path, name)
		elseif osname == "iOS" then
			return string.format("%s/lib%s.a", path, name)
		elseif osname == "Linux" or osname == "Android" then
			return string.format("%s/lib%s.so", path, name)
		else
			return name
		end
	end
end

function psu:deliver_rewards(rewards)
	if not rewards then
		log.debug("rewards empty. skipping")

		return
	end

	local slot = storage:load_slot()

	if not slot then
		log.error("error giving ad reward. slot could not be loaded")

		return
	end

	if rewards.items then
		local bag = slot.bag or {}

		for _, item in pairs(rewards.items) do
			bag[item] = (bag[item] or 0) + 1
		end

		slot.bag = bag
	end

	if rewards.crowns and rewards.crowns > 0 then
		slot.crowns = (slot.crowns or 0) + rewards.crowns
	end

	if rewards.gems and rewards.gems > 0 then
		slot.gems = (slot.gems or 0) + rewards.gems
	end

	storage:save_slot(slot, nil, true)
end

return psu
