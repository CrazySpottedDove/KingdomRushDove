--- Lua 词法分析器
--- @param source string
--- @param chunkname string
--- @return table tokens
local M = {}

local KEYWORDS = {}
for _, word in ipairs({
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"goto",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while"
}) do
	KEYWORDS[word] = true
end

local SINGLE_OPS = {}
for _, op in ipairs({
	"+",
	"-",
	"*",
	"/",
	"%",
	"^",
	"#",
	"=",
	"<",
	">",
	"(",
	")",
	"{",
	"}",
	"[",
	"]",
	";",
	":",
	",",
	".",
	"&",
	"|",
	"~"
}) do
	SINGLE_OPS[op] = true
end

local MULTI_OPS = {"...", "..", "==", "~=", "<=", ">=", "::", "//", "<<", ">>"}

local ESCAPES = {
	a = "\a",
	b = "\b",
	f = "\f",
	n = "\n",
	r = "\r",
	t = "\t",
	v = "\v",
	["\\"] = "\\",
	['"'] = '"',
	["'"] = "'"
}

local function is_digit(b)
	return b ~= nil and b >= 48 and b <= 57
end

local function is_hex(b)
	return is_digit(b) or (b ~= nil and ((b >= 65 and b <= 70) or (b >= 97 and b <= 102)))
end

local function is_name_start(b)
	return b ~= nil and (b == 95 or (b >= 65 and b <= 90) or (b >= 97 and b <= 122))
end

local function is_name_char(b)
	return is_name_start(b) or is_digit(b)
end

local function long_bracket_level(source, i)
	if source:sub(i, i) ~= "[" then
		return nil
	end
	local j = i + 1
	while source:sub(j, j) == "=" do
		j = j + 1
	end
	if source:sub(j, j) ~= "[" then
		return nil
	end
	return j - i - 1, j + 1
end

function M.tokenize(source, chunkname)
	local tokens = {}
	local i, n = 1, #source
	local line, col = 1, 1

	local function advance(count)
		for _ = 1, count do
			if source:byte(i) == 10 then
				line = line + 1
				col = 1
			else
				col = col + 1
			end
			i = i + 1
		end
	end

	local function error_at(msg, ln, cl)
		error(string.format("%s:%d:%d: %s", chunkname or "?", ln or line, cl or col, msg), 0)
	end

	local function push(type, value, ln, cl)
		tokens[#tokens + 1] = {
			type = type,
			value = value,
			line = ln,
			col = cl
		}
	end

	if source:sub(1, 3) == "\239\187\191" then
		advance(3)
	end
	if source:sub(i, i + 1) == "#!" then
		while i <= n and source:byte(i) ~= 10 do
			advance(1)
		end
	end

	while i <= n do
		local b = source:byte(i)

		if b == 32 or b == 9 or b == 13 then
			advance(1)
		elseif b == 10 then
			advance(1)
		elseif b == 45 and source:byte(i + 1) == 45 then
			advance(2)
			local level, start = long_bracket_level(source, i)
			if level then
				local close = "]" .. string.rep("=", level) .. "]"
				local stop = source:find(close, start, true)
				if not stop then
					error_at("unfinished long comment")
				end
				advance(stop + #close - i)
			else
				while i <= n and source:byte(i) ~= 10 do
					advance(1)
				end
			end
		elseif b == 91 then
			local level, start = long_bracket_level(source, i)
			if level then
				local close = "]" .. string.rep("=", level) .. "]"
				local stop = source:find(close, start, true)
				if not stop then
					error_at("unfinished long string")
				end
				local content = source:sub(start, stop - 1)
				if content:sub(1, 1) == "\n" then
					content = content:sub(2)
				elseif content:sub(1, 2) == "\r\n" then
					content = content:sub(3)
				end
				local ln, cl = line, col
				advance(stop + #close - i)
				push("string", content, ln, cl)
			else
				local ln, cl = line, col
				advance(1)
				push("op", "[", ln, cl)
			end
		elseif b == 34 or b == 39 then
			local quote = b
			local ln, cl = line, col
			local bytes = {}
			advance(1)
			local closed = false
			while i <= n do
				local c = source:byte(i)
				if c == quote then
					advance(1)
					closed = true
					break
				elseif c == 10 then
					error_at("unfinished string", ln, cl)
				elseif c == 92 then
					advance(1)
					local e = source:sub(i, i)
					if e == "" then
						error_at("unfinished string", ln, cl)
					elseif e == "\n" or e == "\r" then
						if e == "\r" and source:sub(i + 1, i + 1) == "\n" then
							advance(2)
						else
							advance(1)
						end
						bytes[#bytes + 1] = "\n"
					elseif ESCAPES[e] then
						bytes[#bytes + 1] = ESCAPES[e]
						advance(1)
					elseif e == "x" then
						advance(1)
						local hex = source:sub(i, i + 1)
						if not hex:match("^%x%x$") then
							error_at("invalid hex escape")
						end
						bytes[#bytes + 1] = string.char(tonumber(hex, 16))
						advance(2)
					elseif e == "z" then
						advance(1)
						while i <= n do
							local z = source:byte(i)
							if z == 32 or z == 9 or z == 10 or z == 13 then
								advance(1)
							else
								break
							end
						end
					elseif is_digit(source:byte(i)) then
						local digits = source:sub(i, i + 2):match("^%d%d?%d?")
						local value = tonumber(digits, 10)
						if value > 255 then
							error_at("decimal escape too large")
						end
						bytes[#bytes + 1] = string.char(value)
						advance(#digits)
					else
						error_at("invalid escape sequence \\" .. e)
					end
				else
					bytes[#bytes + 1] = string.char(c)
					advance(1)
				end
			end
			if not closed then
				error_at("unfinished string", ln, cl)
			end
			push("string", table.concat(bytes), ln, cl)
		elseif is_digit(b) or (b == 46 and is_digit(source:byte(i + 1))) then
			local ln, cl = line, col
			local start = i
			if b == 48 and (source:sub(i + 1, i + 1) == "x" or source:sub(i + 1, i + 1) == "X") then
				advance(2)
				while is_hex(source:byte(i)) do
					advance(1)
				end
				if source:sub(i, i) == "." then
					advance(1)
					while is_hex(source:byte(i)) do
						advance(1)
					end
				end
				local pe = source:sub(i, i)
				if pe == "p" or pe == "P" then
					advance(1)
					local sign = source:sub(i, i)
					if sign == "+" or sign == "-" then
						advance(1)
					end
					while is_digit(source:byte(i)) do
						advance(1)
					end
				end
			else
				while is_digit(source:byte(i)) do
					advance(1)
				end
				if source:sub(i, i) == "." and source:sub(i + 1, i + 1) ~= "." then
					advance(1)
					while is_digit(source:byte(i)) do
						advance(1)
					end
				end
				local e = source:sub(i, i)
				if e == "e" or e == "E" then
					advance(1)
					local sign = source:sub(i, i)
					if sign == "+" or sign == "-" then
						advance(1)
					end
					while is_digit(source:byte(i)) do
						advance(1)
					end
				end
			end
			local raw = source:sub(start, i - 1)
			local value = tonumber(raw)
			if not value then
				error_at("malformed number " .. raw, ln, cl)
			end
			push("number", value, ln, cl)
		elseif is_name_start(b) then
			local ln, cl = line, col
			local start = i
			while is_name_char(source:byte(i)) do
				advance(1)
			end
			local value = source:sub(start, i - 1)
			push(KEYWORDS[value] and "kw" or "name", value, ln, cl)
		else
			local ln, cl = line, col
			local matched = false
			for _, op in ipairs(MULTI_OPS) do
				if source:sub(i, i + #op - 1) == op then
					advance(#op)
					push("op", op, ln, cl)
					matched = true
					break
				end
			end
			if not matched then
				local ch = source:sub(i, i)
				if not SINGLE_OPS[ch] then
					error_at("unexpected symbol '" .. ch .. "'")
				end
				advance(1)
				push("op", ch, ln, cl)
			end
		end
	end

	push("eof", "<eof>", line, col)
	return tokens
end

return M
