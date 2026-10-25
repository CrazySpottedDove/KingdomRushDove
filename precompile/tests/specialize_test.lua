package.path = "./?.lua;./precompile/?.lua;" .. package.path

local source = require("precompile.frontend.source")
local specialize = require("precompile.stage.specialize")
local whitelists = require("precompile.whitelists")
local km = require("lib.klua.macros")

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

local function fixture_nullable(this, store)
	if this.fx and store.x then
		store.hit = true
	end
end

local function fixture_get_template(this, store)
	if E:get_template(this.fx).render.sprites[1].use_blood_color then
		store.colored = true
	end
end

local function fixture_condition(this, store)
	if this.ranged and store.x then
		store.hit = true
	end
	if not this.ranged or store.y then
		store.other = true
	end
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
	file = "fixture",
	whitelist = whitelists.enemies
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
	file = "fixture",
	whitelist = whitelists.enemies
})
check(ranged_result.code:find("store.ranged = true", 1, true) ~= nil, "ranged branch kept")
check(not ranged_result.code:find("this.ranged", 1, true), "ranged condition folded")
check(ranged_result.code:find("this.pos.x", 1, true) ~= nil, "pos condition not folded")

local nullable_func = assert(source.find_function(fixture_nullable))
local nullable_result = specialize.specialize(nullable_func, {
	fx = "fx_test"
}, {
	file = "fixture",
	whitelist = table.to_map({"fx"}),
	nullable = table.to_map({"fx"})
})
check(nullable_result.code:find("this.fx", 1, true) ~= nil, "nullable runtime guard kept")

local saved_entity_db = package.loaded["entity_db"]
package.loaded["entity_db"] = {
	get_template = function()
		return {
			render = {
				sprites = {{
					use_blood_color = true
				}}
			}
		}
	end
}
local get_template_func = assert(source.find_function(fixture_get_template))
local get_template_result = specialize.specialize(get_template_func, {
	fx = "fx_test"
}, {
	file = "fixture",
	whitelist = table.to_map({"fx", "render", "render.sprites", "render.sprites.1", "render.sprites.1.use_blood_color"})
})
package.loaded["entity_db"] = saved_entity_db
check(get_template_result.code:find("get_template", 1, true) == nil, "get_template folded")
check(get_template_result.code:find("store.colored = true", 1, true) ~= nil, "get_template branch kept")

local condition_func = assert(source.find_function(fixture_condition))
local condition_result = specialize.specialize(condition_func, {
	ranged = {}
}, {
	file = "fixture",
	whitelist = whitelists.enemies
})
check(condition_result.code:find("if store.x", 1, true) ~= nil, "and condition simplified")
check(condition_result.code:find("if store.y", 1, true) ~= nil, "or condition simplified")
check(condition_result.code:find("this.ranged", 1, true) == nil, "known condition subexpression removed")

local multi_func = assert(source.find_function(fixture_multi))
local multi_result = specialize.specialize(multi_func, {
	pos = {
		x = 0
	}
}, {
	file = "fixture",
	whitelist = whitelists.enemies
})
check(multi_result.code:find("if b", 1, true) ~= nil, "multi-return lhs stays unknown")
check(multi_result.code:find("if c", 1, true) ~= nil, "multi-return extra lhs stays unknown")

-- helper 的 this 必须按实参绑定，不能按形参名强制当作当前实体。
-- 敌人近战攻击士兵时，target 没有 .enemy；旧实现会把守卫折叠掉。
function fixture_dodge(store, this)
	if not this.enemy or this.enemy.can_do_magic then
		return true
	end
	return false
end

function fixture_dodge_caller(this, store, target)
	return fixture_dodge(store, target)
end

local dodge_caller = assert(source.find_function(fixture_dodge_caller))
local dodge_result = specialize.specialize(dodge_caller, {
	enemy = {
		can_do_magic = false
	}
}, {
	file = "fixture",
	whitelist = whitelists.enemies
})
if dodge_result.helpers_code ~= "" then
	check(dodge_result.helpers_code:find("not this.enemy", 1, true) ~= nil, "helper this guard kept from argument binding")
end

local dodge_chunk = assert(load(dodge_result.helpers_code .. "\n" .. dodge_result.code, "generated_dodge", "t", _G))
local dodge_generated = dodge_chunk()
local soldier_target = {
	dodge = {},
	unit = {}
}
check(dodge_generated({
	enemy = {
		can_do_magic = false
	}
}, {}, soldier_target) == true, "soldier target does not index enemy")

-- 带 upvalue 的模块局部函数不能直接内联，否则 upvalue 会变成不存在的全局。
function fixture_clamp(this, store)
	store.v = km.clamp(0, 1, this.v)
end

local clamp_func = assert(source.find_function(fixture_clamp))
local clamp_result = specialize.specialize(clamp_func, {
	v = 0.5
}, {
	file = "fixture",
	whitelist = whitelists.soldiers,
	globals = {
		km = km
	}
})
check(clamp_result.helpers_code:find("CLAMP_SIGNED", 1, true) == nil, "unsafe upvalue function not inlined")
local clamp_env = setmetatable({
	km = km
}, {
	__index = _G
})
local clamp_chunk = assert(load(clamp_result.helpers_code .. "\n" .. clamp_result.code, "generated_clamp", "t", clamp_env))
local clamp_generated = clamp_chunk()
local clamp_store = {}
check(clamp_generated({
	v = 0.5
}, clamp_store) == nil and clamp_store.v == 0.5, "inlined caller still runs")

-- 能按同名同值解析的 upvalue 不应阻止内联。
local safe_helpers = {}
function safe_helpers.mark(this, store)
	if this.render then
		store.marked = true
	end
end

function fixture_safe_upvalue(this, store)
	safe_helpers.mark(this, store)
end

function fixture_safe_caller(this, store)
	fixture_safe_upvalue(this, store)
end

local safe_caller = assert(source.find_function(fixture_safe_caller))
local safe_result = specialize.specialize(safe_caller, {
	render = {}
}, {
	file = "fixture",
	whitelist = whitelists.soldiers,
	globals = setmetatable({
		safe_helpers = safe_helpers
	}, {
		__index = _G
	})
})
local safe_code = safe_result.code .. "\n" .. safe_result.helpers_code
check(safe_code:find("store.marked = true", 1, true) ~= nil, "safe upvalue helper still inlined")
check(safe_code:find("fixture_safe_upvalue", 1, true) == nil, "safe upvalue caller inlined")

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("specialize_test 通过")
