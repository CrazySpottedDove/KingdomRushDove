package.path = "./?.lua;./precompile/?.lua;" .. package.path

local source = require("precompile.frontend.source")
local specialize = require("precompile.stage.specialize")

local failed = 0

local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local function fixture(this, store)
	if this.render then
		for i = 1, #this.render.sprites do
			store.count = (store.count or 0) + 1
		end
	end

	if this.ranged then
		store.ranged = true
	end

	if this.pos.x == 0 then
		store.at_origin = true
	end

	if store.x then
		return 1
	end

	return 2
end

local function fixture_multi(this, f)
	local _, b, c = f()
	if b then
		return 1
	end
	if c then
		return 2
	end
	return 3
end

local func = assert(source.find_function(fixture))
local entity = {
	render = {
		sprites = {{}, {}}
	},
	pos = {
		x = 0,
		y = 0
	}
}
local result = specialize.specialize(func, entity, {
	file = "fixture"
})
check(result.folded > 0, "component branch folded")
check(result.unrolled > 0, "render loop unrolled")
check(not result.code:find("this.ranged", 1, true), "absent ranged branch removed")
check(result.code:find("this.pos.x", 1, true) ~= nil, "mutable pos condition kept")

local generated = assert(load(result.code, "generated", "t", _G))()
local original_store = {
	x = false
}
local generated_store = {
	x = false
}
local original_result = fixture(entity, original_store)
local generated_result = generated(entity, generated_store)

check(original_result == generated_result, "return value parity")
check(original_store.count == generated_store.count, "loop side effect parity")
check(original_store.ranged == generated_store.ranged, "ranged side effect parity")
check(original_store.at_origin == generated_store.at_origin, "mutable condition parity")

local ranged_result = specialize.specialize(func, {
	render = {
		sprites = {{}}
	},
	ranged = {},
	pos = {
		x = 1,
		y = 0
	}
}, {
	file = "fixture"
})
check(ranged_result.code:find("store.ranged = true", 1, true) ~= nil, "ranged branch kept")
check(not ranged_result.code:find("this.ranged", 1, true), "ranged condition folded")
check(ranged_result.code:find("this.pos.x", 1, true) ~= nil, "pos condition not folded")

local multi_func = assert(source.find_function(fixture_multi))
local multi_result = specialize.specialize(multi_func, {
	pos = {
		x = 0
	}
}, {
	file = "fixture"
})
check(multi_result.code:find("if b", 1, true) ~= nil, "multi-return lhs stays unknown")
check(multi_result.code:find("if c", 1, true) ~= nil, "multi-return extra lhs stays unknown")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("specialize_test 通过")
