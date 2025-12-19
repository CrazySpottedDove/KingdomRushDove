-- chunkname: @./lib/klua/string.lua
function string.split(s, sepchars)
	local ret = {}

	for w in string.gmatch(s, "[^" .. sepchars .. "]+") do
		ret[#ret + 1] = w
	end

	return ret
end

function string.trim(s)
	return string.gsub(string.gsub(s, "%s+$", ""), "^%s+", "")
end

function string.starts(s, a)
	if s == a then
		return true
	end

	if not s or not a or a == "" or string.len(s) < string.len(a) then
		return false
	end

	local sa = string.sub(s, 1, string.len(a))

	return sa == a
end
