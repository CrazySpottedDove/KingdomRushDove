-- chunkname: @./lib/klua/dotnet_bfds.lua

local _TESTING

if ... == "lib.klua.dotnet_bfds" then
	-- block empty
else
	_TESTING = true

	require("lib.klua.dump")
end

local log = require("lib.klua.log"):new("dotnet_bfds")

if _TESTING then
	log.level = log.DEBUG_LEVEL
end

local bf = {}

function bf:parse(buffer)
	if buffer == nil or string.len(buffer) < 16 then
		log.error("Buffer is nil or too small")

		return nil
	end

	bf._library = {}
	bf._object_index = {}

	if _TESTING or _NO_PCALL then
		return bf:_parse(buffer)
	else
		local ok, result = pcall(bf._parse, bf, buffer)

		if ok then
			return result
		else
			log.error("Error parsing buffer: %s", result)

			return nil
		end
	end
end

function bf:flatten(stream, target)
	if _TESTING then
		return bf:_flatten(stream, target)
	else
		local ok, result = pcall(bf._flatten, bf, stream, target)

		if ok then
			return result
		else
			log.error("Error flattening object: %s", result)

			return nil
		end
	end
end

local ffi = require("ffi")
local bit = require("bit")
local lshift = bit.lshift
local band = bit.band
local bnot = bit.bnot
local cast = ffi.cast
local float_p = ffi.typeof("float*")
local int32_p = ffi.typeof("int32_t*")

local function r_str(s, off, len)
	len = len or 1

	return s:sub(off + 1, off + len), off + len
end

local function r_byte(s, off, len)
	len = len or 1

	return string.byte(s, off + 1, off + len), off + len
end

local function r_lstr(s, off)
	local o = off + 1
	local b, shift, count = 0, 0, 0

	repeat
		if shift == 35 then
			log.error("Invalid LengthPrefixedString at offset %s", off)

			return ""
		end

		b = s:byte(o)
		o = o + 1
		count = count + lshift(band(b, 127), shift)
		shift = shift + 7
	until band(b, 128) == 0

	return r_str(s, o - 1, count), off + 1 + count
end

local function r_bool(s, off)
	local v, ff = r_byte(s, off)

	return v == 1, ff
end

local function r_int32(s, off)
	local t = r_str(s, off, 4)
	local o = cast(int32_p, t)[0]

	return o, off + 4
end

local function r_single(s, off)
	local t = r_str(s, off, 4)
	local as_int = cast(int32_p, t)[0]

	if band(as_int, 2139095040) == 2139095040 and band(as_int, 8388607) ~= 0 then
		return 0 / 0, off + 4
	else
		return cast(float_p, t)[0], off + 4
	end
end

local r_ReadRecord

local function r_MemberReference(s, off)
	local v
	local ff = off

	v, ff = r_byte(s, ff)

	if v ~= 9 then
		log.error("MemberReference has wrong RecordTypeEnum at offset %s", ff - 1)

		return nil
	end

	v, ff = r_int32(s, ff)

	return {
		_type = "MemberReference",
		IdRef = v
	}, ff
end

local function r_SerializationHeaderRecord(s, ff)
	local v, rid, hid, vmaj, vmin

	v, ff = r_byte(s, ff)

	if v ~= 0 then
		log.error("SerializationHeaderRecord has wrong RecordTypeEnum at offset %s", ff - 1)

		return nil
	end

	rid, ff = r_int32(s, ff)
	hid, ff = r_int32(s, ff)
	vmaj, ff = r_int32(s, ff)
	vmin, ff = r_int32(s, ff)

	return {
		_type = "SerializationHeaderRecord",
		RootId = rid,
		HeaderId = hid,
		MajorVersion = vmaj,
		MinorVersion = vmin
	}, ff
end

local function r_BinaryLibrary(s, ff)
	local v, lid, lname

	v, ff = r_byte(s, ff)

	if v ~= 12 then
		log.error("BinaryLibrary has wrong RecordTypeEnum at offset %s", ff - 1)

		return nil
	end

	lid, ff = r_int32(s, ff)
	lname, ff = r_lstr(s, ff)

	return {
		_type = "BinaryLibrary",
		LibraryId = lid,
		LibraryName = lname
	}, ff
end

local function r_member_values(s, ff, cla)
	local ov = {}
	local v

	for i = 1, cla.MemberCount do
		local t = cla.BinaryTypeEnums[i]
		local a = cla.member_infos[i]

		if t == 0 then
			if a == 1 then
				v, ff = r_bool(s, ff)
			elseif a == 2 then
				v, ff = r_byte(s, ff)
			elseif a == 3 then
				v, ff = r_str(s, ff)
			elseif a == 4 then
				-- block empty
			elseif a == 5 then
				-- block empty
			elseif a == 6 then
				-- block empty
			elseif a == 7 then
				-- block empty
			elseif a == 8 then
				v, ff = r_int32(s, ff)
			elseif a == 9 then
				-- block empty
			elseif a == 10 then
				-- block empty
			elseif a == 11 then
				v, ff = r_single(s, ff)
			elseif a == 12 then
				-- block empty
			elseif a == 13 then
				-- block empty
			elseif a == 14 then
				-- block empty
			elseif a == 15 then
				-- block empty
			elseif a == 16 then
				-- block empty
			elseif a == 17 then
				-- block empty
			elseif a == 18 then
				v, ff = r_lstr(s, ff)
			end

			if v == nil and a ~= 17 then
				log.error("member value parsing not implemented for primitive type %s at offset %s", a, ff)
			end

			ov[i] = v
		elseif t == 1 then
			-- block empty
		elseif t == 2 then
			-- block empty
		elseif t == 3 then
			ov[i], ff = r_MemberReference(s, ff)
		elseif t == 4 then
			ov[i], ff = r_ReadRecord(s, ff)
		elseif t == 5 then
			ov[i], ff = r_MemberReference(s, ff)
		elseif t == 6 then
			-- block empty
		elseif t == 7 then
			-- block empty
		end
	end

	return ov, ff
end

local function r_ClassInfo(s, off)
	local ff = off
	local o = {}

	o.ObjectId, ff = r_int32(s, ff)
	o.Name, ff = r_lstr(s, ff)
	o.MemberCount, ff = r_int32(s, ff)
	o.MemberNames = {}

	local n

	for i = 1, o.MemberCount do
		n, ff = r_lstr(s, ff)

		table.insert(o.MemberNames, n)
	end

	bf._object_index[o.ObjectId] = o

	return o, ff
end

local function r_ClassWithMembersAndTypes(s, off, is_reading_system)
	local rt = r_byte(s, off)

	if is_reading_system and rt ~= 4 then
		log.error("not a SystemClassWithMemberAndTypes at offset %s. record type:%s", off, s:byte(off + 1))
	elseif not is_reading_system and rt ~= 5 then
		log.error("not a ClassWithMemberAndTypes at offset %s. record type:%s", off, s:byte(off + 1))

		return nil
	end

	local ff = off + 1
	local o

	o, ff = r_ClassInfo(s, ff)
	o.BinaryTypeEnums = {}
	o.member_infos = {}

	local teff, aiff = ff, ff + o.MemberCount
	local t, a

	for i = 1, o.MemberCount do
		t, teff = r_byte(s, teff)
		o.BinaryTypeEnums[i] = t

		if t == 0 then
			a, aiff = r_byte(s, aiff)
			o.member_infos[i] = a
		elseif t == 1 then
			-- block empty
		elseif t == 2 then
			-- block empty
		elseif t == 3 then
			a, aiff = r_lstr(s, aiff)
			o.member_infos[i] = {
				_type = "SystemClass",
				ClassName = a
			}
		elseif t == 4 then
			local ctitn, ctili

			ctitn, aiff = r_lstr(s, aiff)
			ctili, aiff = r_int32(s, aiff)
			o.member_infos[i] = {
				_type = "ClassTypeInfo",
				TypeName = ctitn,
				LibraryId = ctili
			}
		elseif t == 5 then
			-- block empty
		elseif t == 6 then
			-- block empty
		elseif t == 7 then
			a, aiff = r_byte(s, aiff)
			o.member_infos[i] = a
		end
	end

	if is_reading_system then
		ff = aiff
	else
		ff = aiff + 4
	end

	o.member_values, ff = r_member_values(s, ff, o)

	if is_reading_system then
		o._type = "SystemClassWithMemberAndTypes"
	else
		o._type = "ClassWithMemberAndTypes"
	end

	bf._library[o.ObjectId] = o

	return o, ff
end

local function r_SystemClassWithMembersAndTypes(s, ff)
	return r_ClassWithMembersAndTypes(s, ff, true)
end

local function r_ObjectNullMultiple256(s, ff)
	local v

	ff = ff + 1
	v, ff = r_byte(s, ff)

	return {
		_type = "ObjectNullMultiple256",
		NullCount = v
	}, ff
end

local function r_ArraySingleObject(s, ff)
	local v, oid, len
	local values = {}

	ff = ff + 1
	oid, ff = r_int32(s, ff)
	len, ff = r_int32(s, ff)

	local i = 1

	while i <= len do
		v, ff = r_ReadRecord(s, ff)

		if v and v._type == "ObjectNullMultiple256" then
			i = i + v.NullCount
		else
			values[i] = v
		end

		i = i + 1
	end

	local out = {
		_type = "ArraySingleObject",
		ObjectId = oid,
		Length = len,
		values = values
	}

	bf._object_index[oid] = out

	return out, ff
end

local function r_ClassWithId(s, ff)
	local oid, mid, mval

	ff = ff + 1
	oid, ff = r_int32(s, ff)
	mid, ff = r_int32(s, ff)

	local cla = bf._library[mid]

	if cla == nil then
		log.error("No class in _library matches MetadataId %s", mid)

		return nil
	end

	mval, ff = r_member_values(s, ff, cla)

	local out = {
		_type = "ClassWithId",
		ObjectId = oid,
		MetadataId = mid,
		member_values = mval
	}

	bf._object_index[oid] = out

	return out, ff
end

function r_ReadRecord(s, ff)
	local function ee(rt)
		log.error("ReadRecord not implemented for type %s", rt)

		return nil, ff + 1
	end

	local rt

	rt = r_byte(s, ff)

	if rt == 0 then
		return r_SerializationHeaderRecord(s, ff)
	elseif rt == 1 then
		return r_ClassWithId(s, ff)
	elseif rt == 2 then
		return ee(rt)
	elseif rt == 3 then
		return ee(rt)
	elseif rt == 4 then
		return r_SystemClassWithMembersAndTypes(s, ff)
	elseif rt == 5 then
		return r_ClassWithMembersAndTypes(s, ff)
	elseif rt == 6 then
		return ee(rt)
	elseif rt == 7 then
		return ee(rt)
	elseif rt == 8 then
		return ee(rt)
	elseif rt == 9 then
		return r_MemberReference(s, ff)
	elseif rt == 10 then
		return ee(rt)
	elseif rt == 11 then
		return {
			_type = "MessageEnd"
		}, ff + 1
	elseif rt == 12 then
		return r_BinaryLibrary(s, ff)
	elseif rt == 13 then
		return r_ObjectNullMultiple256(s, ff)
	elseif rt == 14 then
		return ee(rt)
	elseif rt == 15 then
		return ee(rt)
	elseif rt == 16 then
		return r_ArraySingleObject(s, ff)
	elseif rt == 17 then
		return ee(rt)
	elseif rt == 21 then
		return ee(rt)
	elseif rt == 22 then
		return ee(rt)
	end
end

function bf:_parse(buf)
	local out = {}

	out.records = {}

	local check_str = r_lstr(buf, 43)

	if check_str ~= "SaveGame" then
		log.error("check_str at 0x2b is not SaveGame: %s", check_str)

		return nil
	end

	local o, ff = 0, 0

	repeat
		o, ff = r_ReadRecord(buf, ff)

		if not o then
			log.error("record read is null at offset %s", ff)
		else
			log.debug("last record: %s", o._type)
		end

		table.insert(out.records, o)
	until not o or o._type == "MessageEnd" or ff > string.len(buf)

	out.library = bf._library
	out.object_index = bf._object_index

	return out
end

function bf:_flatten(stream, target)
	local o = {}

	o._type = target._type
	o._name = target.Name
	o._id = target.ObjectId

	if target._type == "ClassWithMemberAndTypes" or target._type == "SystemClassWithMemberAndTypes" then
		if target.Name == "System.Collections.ArrayList" then
			local iv = bf:_flatten(stream, target.member_values[2])

			o = iv
		else
			for i, k in pairs(target.MemberNames) do
				local v = target.member_values[i]

				if type(v) == "table" then
					log.debug("found table for key %s", k)

					v = bf:_flatten(stream, v)
				end

				o[k] = v
			end
		end
	elseif target._type == "ArraySingleObject" then
		for _, v in pairs(target.values) do
			local fv = bf:_flatten(stream, v)

			table.insert(o, fv)
		end
	elseif target._type == "ClassWithId" then
		local cla = stream.library[target.MetadataId]

		for i, k in pairs(cla.MemberNames) do
			local v = target.member_values[i]

			if type(v) == "table" then
				v = bf:_flatten(stream, v)
			end

			o[k] = v
		end
	elseif target._type == "MemberReference" then
		local v = stream.object_index[target.IdRef]
		local fv = bf:_flatten(stream, v)

		o = fv
	else
		log.error("flattening of record type %s not implemented", target._type)

		return nil
	end

	if o.value__ then
		o = o.value__
	end

	return o
end

if _TESTING then
	local args = {
		...
	}
	local fn = args[1]

	print(fn)

	local f = io.open(fn, "rb")
	local fs = f:read("*a")

	f:close()

	local o = bf:parse(fs)

	require("lib.klua.dump")
	log.error("table: %s", getfulldump(o))
else
	return bf
end
