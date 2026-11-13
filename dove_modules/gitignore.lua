local gitignore = {}
local character_classes = {
	alnum = "%w",
	alpha = "%a",
	blank = " \t",
	cntrl = "%c",
	digit = "%d",
	graph = "%g",
	lower = "%l",
	print = "%g ",
	punct = "%p",
	space = "%s",
	upper = "%u",
	xdigit = "%x"
}

local function literal(c)
	return (c:gsub("(%W)", "%%%1"))
end

local function segment_pattern(glob)
	local out = {"^"}
	local i = 1
	while i <= #glob do
		local c = glob:sub(i, i)
		if c == "\\" and i < #glob then
			i = i + 1
			out[#out + 1] = literal(glob:sub(i, i))
		elseif c == "*" then
			out[#out + 1] = ".*"
		elseif c == "?" then
			out[#out + 1] = "."
		elseif c == "[" then
			local j = i + 1
			local chars = {"["}
			if glob:sub(j, j) == "!" or glob:sub(j, j) == "^" then
				chars[#chars + 1] = "^"
				j = j + 1
			end
			if glob:sub(j, j) == "]" then
				chars[#chars + 1] = "]"
				j = j + 1
			end
			while j <= #glob and glob:sub(j, j) ~= "]" do
				local ch = glob:sub(j, j)
				local class_name = glob:sub(j):match("^%[:(%a+):%]")
				if class_name and character_classes[class_name] then
					ch = character_classes[class_name]
					j = j + #class_name + 3
				elseif ch == "\\" and j < #glob then
					j = j + 1
					ch = literal(glob:sub(j, j))
				elseif ch == "%" then
					ch = "%%"
				end
				chars[#chars + 1] = ch
				j = j + 1
			end
			if j <= #glob then
				out[#out + 1] = table.concat(chars) .. "]"
				i = j
			else
				out[#out + 1] = "%["
			end
		else
			out[#out + 1] = literal(c)
		end
		i = i + 1
	end
	return table.concat(out) .. "$"
end

-- Rules are appended while descending, then removed when leaving the directory.
function gitignore.append(rules, contents, base)
	for line in (contents .. "\n"):gmatch("([^\n]*)\n") do
		line = line:gsub("\r$", "")
		while line:sub(-1) == " " do
			local slashes = line:match("(\\*) $")
			if #slashes % 2 == 1 then
				break
			end
			line = line:sub(1, -2)
		end
		if line ~= "" and line:sub(1, 1) ~= "#" then
			local negate = line:sub(1, 1) == "!"
			if negate then
				line = line:sub(2)
			end
			local directory = line:sub(-1) == "/"
			if directory then
				line = line:sub(1, -2)
			end
			local anchored = line:find("/", 1, true) ~= nil
			line = line:gsub("^/", "")
			local parts = {}
			for part in line:gmatch("[^/]+") do
				parts[#parts + 1] = part == "**" and "**" or segment_pattern(part)
			end
			if #parts > 0 then
				rules[#rules + 1] = {
					base = base,
					parts = parts,
					anchored = anchored,
					directory = directory,
					negate = negate
				}
			end
		end
	end
end

local function matches(patterns, parts, i, j)
	if i > #patterns then
		return j > #parts
	end
	if patterns[i] == "**" then
		if i == #patterns then
			return j <= #parts
		end
		for k = j, #parts + 1 do
			if matches(patterns, parts, i + 1, k) then
				return true
			end
		end
		return false
	end
	return j <= #parts and parts[j]:match(patterns[i]) ~= nil and matches(patterns, parts, i + 1, j + 1)
end

-- Call for directories before descending: excluded parents cannot be re-included.
function gitignore.ignored(rules, path, is_directory)
	local ignored = false
	for _, rule in ipairs(rules) do
		if (not rule.directory or is_directory) and (rule.base == "" or path:sub(1, #rule.base + 1) == rule.base .. "/") then
			local relative = rule.base == "" and path or path:sub(#rule.base + 2)
			local parts = {}
			for part in relative:gmatch("[^/]+") do
				parts[#parts + 1] = part
			end
			if matches(rule.parts, parts, 1, rule.anchored and 1 or #parts) then
				ignored = not rule.negate
			end
		end
	end
	return ignored
end

return gitignore
