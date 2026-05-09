-- constvar 编译期常量测试
local c = require("precompile.compile_utils")

local test_env = setmetatable({
	print = print,
	U = {
		clamp = function(v, min, max)
			return math.max(min, math.min(max, v))
		end
	}
}, {
	__index = _G
})

local function test(name, template, entity, expected_substrings)
	local code = c.process(template, test_env, entity)
	local all_ok = true
	for _, sub in ipairs(expected_substrings) do
		if not code:find(sub, 1, true) then
			print("FAIL:", name, "- missing:", sub)
			all_ok = false
		end
	end
	if all_ok then
		local fn, err = load(code, "test_" .. name, "t", test_env)
		if fn then
			print("OK:", name)
		else
			print("FAIL:", name, "- load error:", err)
			print(code)
		end
	end
end

-- 测试1: constvar 基本功能
test("constvar_basic", [[
return function()
    constvar x = 1 + 2
    conststmt(print("x =", x))
    return constexpr(x)
end
]], {}, {"x =", "3", "return 3"})

-- 测试2: constvar 在 if constexpr 分支中隔离
test("constvar_scope", [[
return function()
    constvar a = 10
    constif(true)
        constvar b = 20
        conststmt(print("a =", a, "b =", b))
    constend
    conststmt(print("a =", a))
end
]], {}, {"a = 10", "b = 20", "a = 10"})

-- 测试3: constvar 在 constfor 中每次迭代独立
test("constvar_for", [[
return function()
    constfor i = 1, 3 do
        constvar x = tonumber(i) * 2
        conststmt(print("x =", x))
    constend
end
]], {}, {"x = 2", "x = 4", "x = 6"})

-- 测试4: constvar 在 template 体内不泄漏
c.define("test_tpl", [[
function()
    constvar inner = 42
    conststmt(print("inner =", inner))
end
]])
test("constvar_template", [[
return function()
    constvar outer = 99
    template test_tpl()
    conststmt(print("outer =", outer))
end
]], {}, {"outer = 99"})

print("All tests done.")
