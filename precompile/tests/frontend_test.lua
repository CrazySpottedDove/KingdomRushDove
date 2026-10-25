package.path = "./?.lua;./precompile/?.lua;" .. package.path

local parser = require("precompile.frontend.parser")
local source = require("precompile.frontend.source")

local failed = 0

local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local function parse(source_text, name)
	local ok, result = pcall(parser.parse, source_text, name or "test")
	check(ok, name .. ": " .. tostring(result))
	return ok and result or nil
end

parse([[
local a, b = 1, 2
function f(x, ...)
	if x > 1 then
		return a + b * x
	elseif x == 0 then
		return 0
	else
		return -x
	end
end
]], "basic")

local ast = parse([[
local t = { a = 1, [2] = "x", 3 }
for i = 1, 3 do
	t[i] = i
end
for k, v in pairs(t) do
	print(k, v)
end
::again::
goto again
]], "control")
check(ast and #ast.body.stats >= 3, "control statements")

parse([[
function M:method(a, b)
	return a and b or nil
end
local function inner() return ... end
]], "functions")

local files = {"all/scripts.lua", "all/script_utils.lua", "all/utils.lua", "all/entity_db.lua", "all/path_db.lua", "all/grid_db.lua", "kr1/game_scripts.lua", "kr1/tower_scripts.lua", "kr1/hero_scripts.lua"}

for _, path in ipairs(files) do
	local file = assert(io.open(path, "rb"))
	local text = file:read("*a")
	file:close()
	parse(text, path)
end

local function fixture(a, b)
	return a + b
end

local func, file = source.find_function(fixture)
check(func ~= nil, "source.find_function")
check(file ~= nil and file.path:find("frontend_test", 1, true) ~= nil, "source path")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("frontend_test 通过")
