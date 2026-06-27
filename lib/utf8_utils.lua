local utf8 = require("utf8")

local M = {}

function M.sanitize(s)
	if type(s) ~= "string" then
		return tostring(s)
	end
	s = s:gsub("%z", "")
	local ok = pcall(utf8.len, s)
	if ok then
		return s
	end
	local parts = {}
	local i = 1
	local n = #s
	while i <= n do
		local ok, cp = pcall(utf8.codepoint, s, i)
		if ok then
			local ch = utf8.char(cp)
			parts[#parts + 1] = ch
			i = i + #ch
		else
			parts[#parts + 1] = "?"
			i = i + 1
		end
	end
	return table.concat(parts)
end

function M.truncate_bytes(s, max_bytes)
	if #s <= max_bytes then
		return s
	end
	local n = #s
	local last_ok = 0
	local i = 1
	while i <= n do
		local ok, err = utf8.len(s, i, i)
		if not ok then
			i = i + 1
		else
			local cp = utf8.codepoint(s, i)
			local char_len = #utf8.char(cp)
			if i + char_len - 1 > max_bytes then
				break
			end
			last_ok = i + char_len - 1
			i = i + char_len
		end
	end
	if last_ok <= 0 then
		return ""
	end
	return s:sub(1, last_ok)
end

function M.sub(s, max_chars)
	if type(s) ~= "string" or max_chars <= 0 then
		return ""
	end
	local parts = {}
	local count = 0
	local i = 1
	local n = #s
	while i <= n and count < max_chars do
		local ok, cp = pcall(utf8.codepoint, s, i)
		if ok then
			local ch = utf8.char(cp)
			parts[#parts + 1] = ch
			count = count + 1
			i = i + #ch
		else
			i = i + 1
		end
	end
	return table.concat(parts)
end

function M.safe_label_desc(s)
	s = M.sanitize(s)
	if #s > 130 then
		return M.truncate_bytes(s, 127) .. "..."
	end
	return s
end

return M
