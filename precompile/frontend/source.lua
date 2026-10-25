--- 函数源码定位与解析缓存
local parser = require("precompile.frontend.parser")

local M = {}

local file_cache = {}

local function walk(node, by_line)
	if type(node) ~= "table" then
		return
	end
	if node.tag == "Function" then
		by_line[node.line] = by_line[node.line] or node
	end
	for _, value in pairs(node) do
		if type(value) == "table" then
			walk(value, by_line)
		end
	end
end

local function load_file(path)
	local cached = file_cache[path]
	if cached then
		return cached
	end

	local file, err = io.open(path, "rb")
	if not file then
		return nil, err
	end
	local source = file:read("*a")
	file:close()

	local ok, ast = pcall(parser.parse, source, path)
	if not ok then
		return nil, ast
	end

	local by_line = {}
	walk(ast, by_line)

	cached = {
		path = path,
		source = source,
		ast = ast,
		by_line = by_line
	}
	file_cache[path] = cached
	return cached
end

--- @param fn function
--- @return table|nil location
function M.resolve(fn)
	local info = debug.getinfo(fn, "S")
	if not info or not info.source or info.source:sub(1, 1) ~= "@" then
		return nil
	end
	return {
		path = info.source:sub(2),
		line = info.linedefined,
		last_line = info.lastlinedefined
	}
end

--- @param fn function
--- @return table|nil func_node
--- @return table|nil file
--- @return string|nil err
function M.find_function(fn)
	local location = M.resolve(fn)
	if not location then
		return nil, nil, "function has no source file"
	end

	local file, err = load_file(location.path)
	if not file then
		return nil, nil, err
	end

	local func = file.by_line[location.line]
	if func then
		return func, file
	end

	local best
	local best_delta
	for line, candidate in pairs(file.by_line) do
		local delta = line - location.line
		if delta >= 0 and delta <= 2 and (not best_delta or delta < best_delta) then
			best = candidate
			best_delta = delta
		end
	end

	if best then
		return best, file
	end

	return nil, file, string.format("function definition not found at %s:%d", location.path, location.line)
end

function M.clear_cache()
	file_cache = {}
end

return M
