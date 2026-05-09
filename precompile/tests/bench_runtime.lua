-- 预编译性能对比测试（lua / luajit 通用）
local CU = require("precompile.compile_utils")

local tpl = [[return function()
    local s = 0
    constif(this.a) s = s + 1 constend
    constif(this.b) s = s + 2 constend
    constif(this.c) s = s + 3 constend
    constif(this.d) s = s + 4 constend
    constif(this.e) s = s + 5 constend
    constif(this.f) s = s + 6 constend
    constif(this.g) s = s + 7 constend
    constif(this.h) s = s + 8 constend
    constif(this.i) s = s + 9 constend
    constif(this.j) s = s + 10 constend
    return s
end]]
-- NOTE: constif(cond) body constend 必须各占一行，上面格式是错的！
-- 用多行格式重写：
local tpl2 = [[return function()
    local s = 0
    constif(this.a)
    s = s + 1
    constend
    constif(this.b)
    s = s + 2
    constend
    constif(this.c)
    s = s + 3
    constend
    constif(this.d)
    s = s + 4
    constend
    constif(this.e)
    s = s + 5
    constend
    constif(this.f)
    s = s + 6
    constend
    constif(this.g)
    s = s + 7
    constend
    constif(this.h)
    s = s + 8
    constend
    constif(this.i)
    s = s + 9
    constend
    constif(this.j)
    s = s + 10
    constend
    return s
end]]

local entities = {}
for bits = 0, 255 do
	entities[bits + 1] = {}
	local n = bits
	for _, nm in ipairs{"a", "b", "c", "d", "e", "f", "g", "h", "i", "j"} do
		entities[bits + 1][nm] = (n % 2 == 1)
		n = math.floor(n / 2)
	end
end

local env = {}
local compiled, runtime = {}, {}
for _, e in ipairs(entities) do
	local code = CU.process(tpl2, env, e)
	compiled[#compiled + 1] = assert(load(code, nil, "t", env))()
	local a, b, c, d, ee, f, g, h, i, j = e.a, e.b, e.c, e.d, e.e, e.f, e.g, e.h, e.i, e.j
	runtime[#runtime + 1] = function()
		local s = 0
		if a then
			s = s + 1
		end
		if b then
			s = s + 2
		end
		if c then
			s = s + 3
		end
		if d then
			s = s + 4
		end
		if ee then
			s = s + 5
		end
		if f then
			s = s + 6
		end
		if g then
			s = s + 7
		end
		if h then
			s = s + 8
		end
		if i then
			s = s + 9
		end
		if j then
			s = s + 10
		end
		return s
	end
end
for i = 1, 256 do
	assert(compiled[i]() == runtime[i]())
end
print(string.format("Engine: %s | 256 functions OK", type(jit) == "table" and "LuaJIT" or _VERSION))

local function bench(fns)
	collectgarbage()
	local t0 = os.clock()
	for k = 1, 100000 do
		for _, f in ipairs(fns) do
			f()
		end
	end
	return os.clock() - t0
end
local ct, rt = bench(compiled), bench(runtime)
print(string.format("compiled: %.3fs", ct))
print(string.format("runtime:  %.3fs", rt))
print(string.format("speedup:  %.1fx  -- %s", rt / ct, ct < rt and "COMPILED WIN" or "RUNTIME WIN"))
