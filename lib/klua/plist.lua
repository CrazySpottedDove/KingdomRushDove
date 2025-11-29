-- chunkname: @./lib/klua/plist.lua

local log = require("lib.klua.log"):new("lib.klua.plist")
local plist = {}
local bplist = {}
local xplist = {}

function plist:parse(buffer)
	if buffer == nil or string.len(buffer) < 6 then
		log.error("Buffer is nil or too small")

		return nil
	end

	local ref, parser

	if buffer:sub(1, 6) == "bplist" then
		log.debug("binary parsing...")

		ref = bplist
		parser = bplist.parse
	elseif buffer:sub(1, 5) == "<?xml" then
		log.debug("xml parsing...")

		ref = xplist
		parser = xplist.parse
	else
		log.error("Unknown buffer header")

		return nil
	end

	local ok, result = pcall(parser, ref, buffer)

	if ok then
		return result
	else
		log.error("Error parsing buffer: %s", result)

		return nil
	end
end

local XS = require("xmlSimple")

function xplist:parse(buf)
	local x = XS.newParser():ParseXmlText(buf)
	local xt = self:dict2table(x.plist.dict)

	return xt
end

function xplist:dict2table(x)
	if x == nil then
		-- block empty
	elseif x:numChildren() == 0 then
		local name = x:name()

		if name == "string" or name == "date" or name == "data" then
			return x:value()
		elseif name == "true" then
			return true
		elseif name == "false" then
			return false
		else
			return tonumber(x:value())
		end
	else
		local o = {}

		if x:name() == "dict" then
			local i, v

			i, v = next(x:children(), i)

			while i do
				local ck = v:value()

				i, v = next(x:children(), i)
				o[ck] = self:dict2table(v)
				i, v = next(x:children(), i)
			end

			return o
		elseif x:name() == "array" then
			for ci, cv in pairs(x:children()) do
				table.insert(o, self:dict2table(cv))
			end

			return o
		end
	end
end

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local cast = ffi.cast
local split_int32_p = ffi.typeof("struct { int32_t hi, lo; } *")
local double_p = ffi.typeof("double*")
local float_p = ffi.typeof("float*")
local uint64_p = ffi.typeof("uint64_t*")
local uint32_p = ffi.typeof("uint32_t*")
local uint16_p = ffi.typeof("uint16_t*")
local uint8_p = ffi.typeof("uint8_t*")
local int64_p = ffi.typeof("int64_t*")
local int32_p = ffi.typeof("int32_t*")
local int16_p = ffi.typeof("int16_t*")
local int8_p = ffi.typeof("int8_t*")

local function r_str(s, off, len)
	return s:sub(off + 1, off + len)
end

local function r_ustr(s, off, len)
	return r_str(s, off, len)
end

local function r_uint(s, off, len)
	local t = s:sub(off + 1, off + len)

	if ffi.abi("le") then
		t = t:reverse()
	end

	local result = 0

	if len == 8 then
		result = cast(uint64_p, t)[0]
	elseif len == 4 then
		result = cast(uint32_p, t)[0]
	elseif len == 2 then
		result = cast(uint16_p, t)[0]
	elseif len == 1 then
		result = cast(uint8_p, t)[0]
	else
		log.error("uint: invalid len: %s", len)
	end

	result = tonumber(result)

	return result
end

local function r_int(s, off, len)
	local t = s:sub(off + 1, off + len)

	if ffi.abi("le") then
		t = t:reverse()
	end

	local result = 0

	if len == 8 then
		result = cast(int64_p, t)[0]
	elseif len == 4 then
		result = cast(int32_p, t)[0]
	elseif len == 2 then
		result = cast(int16_p, t)[0]
	elseif len == 1 then
		result = cast(int8_p, t)[0]
	else
		log.error("int: invalid len :%s", len)
	end

	result = tonumber(result)

	return result
end

local function r_float(s, off, len)
	local t = s:sub(off + 1, off + len)

	if len == 4 then
		local as_int = cast(int32_p, t)[0]

		if band(as_int, 2139095040) == 2139095040 and band(as_int, 8388607) ~= 0 then
			return 0 / 0
		else
			if ffi.abi("le") then
				t = t:reverse()
			end

			return cast(float_p, t)[0]
		end
	elseif len == 8 then
		local q = cast(split_int32_p, t)

		if band(q.hi, 2146435072) == 2146435072 and bor(q.lo, band(q.hi, 1048575)) ~= 0 then
			return 0 / 0
		else
			if ffi.abi("le") then
				t = t:reverse()
			end

			return cast(double_p, t)[0]
		end
	else
		log.error("real numbers of length %s not supported", len)

		return 0
	end
end

bplist.offset_table = {}
bplist.offset_size = 0
bplist.object_ref_size = 0
bplist.num_objects = 0
bplist.top_object = 0
bplist.offset_table_offset = 0

function bplist:parse(buf)
	self.buf = buf

	local out = {}

	if not buf or string.len(buf) < 6 then
		return nil
	end

	local magic_str = r_str(buf, 0, 6)

	log.debug("magic_number:%s", magic_str)

	if magic_str ~= "bplist" then
		return nil
	end

	local trailer = buf:len() - 32

	log.debug("trailer offset: %x", trailer)
	log.debug("trailer offset_size: %x", r_uint(buf, trailer + 6, 1))

	self.offset_table = {}
	self.offset_size = r_uint(buf, trailer + 6, 1)
	self.object_ref_size = r_uint(buf, trailer + 7, 1)
	self.num_objects = r_uint(buf, trailer + 8, 8)
	self.top_object = r_uint(buf, trailer + 16, 8)
	self.offset_table_offset = r_uint(buf, trailer + 24, 8)

	log.debug("offset_size: %x", self.offset_size)
	log.debug("object_ref_size: %x", self.object_ref_size)
	log.debug("num_objects: %x", self.num_objects)
	log.debug("top_object: %x", self.top_object)
	log.debug("offset_table_offset: %x", self.offset_table_offset)

	for i = 0, self.num_objects do
		local offset_bytes = r_uint(buf, self.offset_table_offset + i * self.offset_size, self.offset_size)

		self.offset_table[i] = offset_bytes
	end

	out = self:parse_object(self.top_object)

	return out
end

function bplist:parse_object(table_offset)
	log.paranoid("parse_object(%s)", table_offset)

	local buf = self.buf
	local start_pos = self.offset_table[table_offset]

	assert(start_pos ~= nil, string.format("start_pos is nil for table_offset:%x", table_offset))

	local h = r_uint(buf, start_pos, 1)
	local obj_type = bit.rshift(h, 4)
	local obj_info = bit.band(h, 15)

	log.paranoid(" start_pos:%x obj_type:%x obj_info:%x", start_pos, obj_type, obj_info)

	if obj_type == 0 and obj_info == 0 then
		return nil
	elseif obj_type == 0 and obj_info == 8 then
		return false
	elseif obj_type == 0 and obj_info == 9 then
		return true
	elseif obj_type == 0 and obj_info == 15 then
		return nil
	elseif obj_type == 1 then
		local length = 2^obj_info

		if length < 8 then
			return r_uint(buf, start_pos + 1, length)
		else
			return r_int(buf, start_pos + 1, length)
		end
	elseif obj_type == 2 then
		local length = 2^obj_info

		return r_float(buf, start_pos + 1, length)
	elseif obj_type == 3 then
		if obj_info ~= 3 then
			log.error("Error: Unknown date type :", obj_info)
		end

		return r_float(buf, start_pos + 1, 8)
	elseif obj_type == 4 then
		local length = obj_info
		local data_offset = 1

		if obj_info == 15 then
			local int_type = r_int(buf, start_pos + 1, 1)
			local intType = bit.band(int_type, 240) / 16

			if intType ~= 1 then
				log.error("Error : 0x4 Unexpected length - int-type", intType)
			end

			local intInfo = bit.band(int_type, 15)
			local intLength = 2^intInfo

			data_offset = 2 + intLength
			length = r_int(buf, start_pos + 2, intLength)
		end

		return r_str(buf, start_pos + data_offset, length)
	elseif obj_type == 5 then
		local length = obj_info
		local strOffset = 1

		if obj_info == 15 then
			local int_type = r_int(buf, start_pos + 1, 1)
			local intType = bit.band(int_type, 240) / 16

			if intType ~= 1 then
				log.error("Error : 0x5 Unexpected length - int-type", intType)
			end

			intInfo = bit.band(int_type, 15)
			intLength = 2^intInfo
			strOffset = 2 + intLength
			length = r_int(buf, start_pos + 2, intLength)
		end

		return r_str(buf, start_pos + strOffset, length)
	elseif obj_type == 6 then
		local length = obj_info
		local strOffset = 1

		if obj_info == 15 then
			local int_type = r_int(buf, start_pos + 1, 1)
			local intType = bit.band(int_type, 240) / 16

			if intType ~= 1 then
				log.error("Error : 0x6 Unexpected length - int-type", intType)
			end

			intInfo = bit.band(int_type, 15)
			intLength = 2^intInfo
			strOffset = 2 + intLength
			length = r_int(buf, start_pos + 2, intLength)
		end

		length = length * 2

		return r_ustr(buf, start_pos + strOffset, length)
	elseif obj_type == 8 then
		local length = obj_info + 1

		return r_uint(buf, start_pos + 1, length)
	elseif obj_type == 10 then
		local length = obj_info
		local arrayOffset = 1

		if obj_info == 15 then
			local int_type = r_int(buf, start_pos + 1, 1)
			local intType = bit.band(int_type, 240) / 16

			if intType ~= 1 then
				log.error("Error : 0xA Unexpected length - int-type", intType)
			end

			intInfo = bit.band(int_type, 15)
			intLength = 2^intInfo
			arrayOffset = 2 + intLength
			length = r_int(buf, start_pos + 2, intLength)
		end

		local array = {}

		for i = 0, length - 1 do
			objRef = r_int(buf, start_pos + arrayOffset + i * self.object_ref_size, self.object_ref_size)
			array[i + 1] = self:parse_object(objRef)
		end

		return array
	elseif obj_type == 12 then
		return "TODO: Sets not implemented"
	elseif obj_type == 13 then
		local length = obj_info
		local dictOffset = 1

		if obj_info == 15 then
			local int_type = r_int(buf, start_pos + 1, 1)
			local intType = bit.band(int_type, 240) / 16

			if intType ~= 1 then
				log.error("Error : 0xD Unexpected length - int-type", intType)
			end

			intInfo = bit.band(int_type, 15)
			intLength = 2^intInfo
			dictOffset = 2 + intLength
			length = r_int(buf, start_pos + 2, intLength)
		end

		local dict = {}

		for i = 0, length - 1 do
			local keyOff = start_pos + dictOffset + i * self.object_ref_size
			local valOff = start_pos + dictOffset + length * self.object_ref_size + i * self.object_ref_size
			local keyRef = r_uint(buf, keyOff, self.object_ref_size)
			local valRef = r_uint(buf, valOff, self.object_ref_size)

			log.paranoid("  keyOff:%x keyRef:%s  valOff:%x valRef:%s", keyOff, keyRef, valOff, valRef)

			local key = self:parse_object(keyRef)
			local val = self:parse_object(valRef)

			dict[key] = val
		end

		return dict
	end

	return "Error : Unknown object type - " .. obj_type
end

return plist
