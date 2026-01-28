-- chunkname: @./lib/klua/tsv.lua

local log = require("klua.log"):new("klog.tsv")
local FS = love.filesystem

require("klua.string")

local tsv = {}

function tsv.csv_row_to_table(s)
	s = s .. ","

	local t = {}
	local fieldstart = 1

	repeat
		if string.find(s, "^\"", fieldstart) then
			local a, c
			local i = fieldstart

			repeat
				a, i, c = string.find(s, "\"(\"?)", i + 1)
			until c ~= "\""

			if not i then
				error("unmatched \" for string: " .. s)
			end

			local f = string.sub(s, fieldstart + 1, i - 1)

			table.insert(t, (string.gsub(f, "\"\"", "\"")))

			fieldstart = string.find(s, ",", i) + 1
		else
			local nexti = string.find(s, ",", fieldstart)

			table.insert(t, string.sub(s, fieldstart, nexti - 1))

			fieldstart = nexti + 1
		end
	until fieldstart > string.len(s)

	t[#t] = string.gsub(t[#t], "\r$", "")

	return t
end

function tsv.parse_csv(s)
	local rows = {}

	for row in string.gmatch(s, "[^\n]+") do
		if string.sub(row, 1, 3) == "﻿" then
			row = string.sub(row, 4)
		end

		table.insert(rows, tsv.csv_row_to_table(row))
	end

	return rows
end

function tsv.tsv_row_to_table(row_string)
	local row = {}

	row_string = row_string .. "\t"

	for col in row_string:gmatch("(.-)\t") do
		table.insert(row, col)
	end

	return row
end

function tsv.parse_tsv(s)
	local rows = {}

	for row in string.gmatch(s, "[^\n]+") do
		if string.sub(row, 1, 3) == "﻿" then
			row = string.sub(row, 4)
		end

		table.insert(rows, tsv.tsv_row_to_table(row))
	end

	return rows
end

function tsv.load(filename)
	local ok, tsv_string = pcall(FS.read, filename)

	if not ok then
		log.error("TSV: failed to read %s: error: %s", filename, tsv_string)

		return
	end

	return tsv.parse_tsv(tsv_string)
end

return tsv
