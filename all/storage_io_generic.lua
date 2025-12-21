-- chunkname: @./all/storage_io_generic.lua
local log = require("lib.klua.log"):new("storage_io_generic")
local signal = require("hump.signal")
local km = require("lib.klua.macros")
local persistence = require("lib.klua.persistence")

require("lib.klua.table")

local sio = {}

sio.cache_str = {}
sio.cache_data = {}
sio.write_queue = {}
sio.checksum_enabled = nil
sio.CHECKSUM_EXTRA = "Found it! Now you can avoid paying for gems, making it harder for us to make more games. Happy?"

function sio:load_file(filename, force_load)
	local str, ok, chunk, data, siz, err

	if force_load then
		sio.cache_str[filename] = nil
		sio.cache_data[filename] = nil
	end

	if sio.cache_data[filename] then
		log.debug("loading file %s from cache_data", filename)

		return true, sio.cache_data[filename]
	elseif sio.cache_str[filename] then
		log.debug("loading file %s from cache_str", filename)

		ok, str = true, sio.cache_str[filename]
	else
		log.debug("loading file %s from filesystem", filename)

		ok, str, siz = pcall(love.filesystem.read, filename)
	end

	if not ok then
		log.error("error reading %s", filename)

		return nil
	end

	if not str then
		log.info("error reading %s. %s", filename, tostring(siz))

		return nil
	end

	ok, chunk, err = pcall(loadstring, str, "@" .. filename)

	if not ok or err then
		log.error("error parsing %s. %s", filename, err)

		return nil
	end

	local env = {}

	setfenv(chunk, env)

	ok, data = pcall(chunk)

	if not ok then
		log.error("error evaluating chunk. %s", tostring(data))

		return nil
	end

	if ok and data then
		sio.cache_str[filename] = str
		sio.cache_data[filename] = data
	end

	return ok, data
end

function sio:write_file(filename, data_table)
	local data_string = persistence.serialize_to_string(data_table)

	if sio.cache_str[filename] == data_string then
		log.debug("written file %s has no changes. skipping...", filename)

		return true
	end

	sio.cache_str[filename] = data_string
	sio.cache_data[filename] = data_table

	log.debug("writing file %s.", filename)

	return love.filesystem.write(filename, data_string)
end

function sio:remove_file(filename)
	sio.cache_str[filename] = nil
	sio.cache_data[filename] = nil

	log.debug("removing file %s", filename)

	return love.filesystem.remove(filename)
end

function sio:commit()
	return true
end

function sio:update()
	return
end

function sio:is_busy()
	return false
end

function sio:is_pending()
	return false
end

return sio
