local Configer = {}

local cache = {}
local sio = require("all.storage_io_generic")
require("lib.klua.table")

local REGISTRY = {
	config = {
		filename = "config.lua",
		default = require("patches.default")
	},
	criket = {
		filename = "criket.lua",
		default = require("patches.criket_template")
	},
	keyset = {
		filename = "keyset.lua",
		default = require("patches.keyset_default")
	},
	ui_settings = {
		filename = "ui_settings.lua",
		default = require("patches.ui_settings_template")
	}
}

local function load_from_disk(name)
	local entry = REGISTRY[name]
	local ok, data = sio:load_file(entry.filename)
	return data, ok
end

local function save_to_disk(name, data)
	local entry = REGISTRY[name]
	sio:write_file(entry.filename, data)
end

local function merge_defaults(name, data)
	local entry = REGISTRY[name]
	if name == "criket" and not data.on then
		return
	end
	for k, v in pairs(entry.default) do
		if data[k] == nil then
			if name == "criket" and type(v) == "table" then
				data[k] = table.deepclone(v)
			else
				data[k] = v
			end
		elseif type(data[k]) ~= type(v) then
			data[k] = v
		end
	end
end

function Configer.get_all(name)
	if cache[name] then
		return cache[name]
	end
	local entry = REGISTRY[name]
	local data = load_from_disk(name)
	if not data then
		data = table.deepclone(entry.default)
		merge_defaults(name, data)
		save_to_disk(name, data)
	else
		merge_defaults(name, data)
	end
	cache[name] = data
	return data
end

function Configer.save(name)
	if not cache[name] then
		return
	end
	save_to_disk(name, cache[name])
end

function Configer.save_all()
	for name in pairs(cache) do
		Configer.save(name)
	end
end

function Configer.reload(name)
	cache[name] = nil
	return Configer.get_all(name)
end

function Configer.reset(name)
	local entry = REGISTRY[name]
	local data = table.deepclone(entry.default)
	merge_defaults(name, data)
	save_to_disk(name, data)
	cache[name] = data
	return data
end

function Configer.config()
	return Configer.get_all("config")
end

function Configer.criket()
	return Configer.get_all("criket")
end

function Configer.keyset()
	return Configer.get_all("keyset")
end

function Configer.ui_settings()
	return Configer.get_all("ui_settings")
end

return Configer
