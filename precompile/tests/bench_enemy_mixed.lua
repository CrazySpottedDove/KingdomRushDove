--[[
precompile/tests/bench_enemy_mixed.lua
=======================================
测试 enemy_mixed.update 在预编译前后的运行时性能。

测试场景：
  1. 纯近战敌人 (melee only)        — 只有 melee 组件
  2. 混合敌人 (melee + ranged)     — 同时有 melee 和 ranged 组件

每个场景都对比"原始脚本"和"预编译脚本"的执行速度。

用法：在 KingdomRushDove/ 目录下运行：
  luajit precompile/tests/bench_enemy_mixed.lua
--]]

-- 设置 package.path
package.path = package.path .. ";./?.lua;./all/?.lua;./lib/?.lua;./lib/klua/?.lua;./lib/hump/?.lua;./kr1/?.lua;./precompile/?.lua;./precompile/templates/?.lua;./dove_modules/?.lua"

local H = require("precompile.tests.harness")
H.ensure_initialized()

-- ========== 1. 搭建环境 ==========
local E = {
	last_id = 1,
	entities = {},
	components = {},
	create_entity = function(self, name)
		local tpl = self.entities[name]
		if not tpl then
			error("template not found: " .. name)
		end
		local out = {}
		for k, v in pairs(tpl) do
			out[k] = H.deepclone(v)
		end
		out.id = self.last_id
		self.last_id = self.last_id + 1
		return out
	end
}
function E:register_t(name, base)
	local t = base and H.deepclone(self.entities[base]) or {}
	t.template_name = name
	self.entities[name] = t
	return t
end
function E:register_c(name, base)
	local c = base and H.deepclone(self.components[base]) or {}
	self.components[name] = c
	return c
end
function E:clone_c(name)
	return H.deepclone(self.components[name])
end
function E:add_comps(e, ...)
	for _, cn in ipairs({...}) do
		if self.components[cn] then
			e[cn] = H.deepclone(self.components[cn])
		end
	end
end
function E:get_template(name)
	return self.entities[name]
end

H.register_base_components(E)

-- ========== 2. 加载 scripts + 设置全局 ==========
local sim = H.make_simulation()
local U = H.make_utils()
local SU = H.make_script_utils(U)
package.loaded["utils"] = U
package.loaded["script_utils"] = SU
_G.SU = SU
_G.U = U

H.set_globals(E, sim)

local scripts = require("scripts")
_G.scripts = scripts

-- ========== 3. 注册测试模板 ==========

-- 纯近战敌人 (no ranged)
local e_melee = E:register_t("bm_melee", "enemy")
E:add_comps(e_melee, "melee")
e_melee.health.hp = 5000
e_melee.health.hp_max = 5000
e_melee.motion.real_speed = 2
e_melee.motion.max_speed = 2
e_melee.pos.x = 0
e_melee.pos.y = 0
e_melee.main_script.insert = scripts.enemy_basic.insert
e_melee.main_script.update = scripts.enemy_mixed.update

-- 混合敌人 (melee + ranged)
local e_mixed = E:register_t("bm_mixed", "enemy")
E:add_comps(e_mixed, "melee", "ranged")
e_mixed.health.hp = 5000
e_mixed.health.hp_max = 5000
e_mixed.motion.real_speed = 2.5
e_mixed.motion.max_speed = 2.5
e_mixed.pos.x = 0
e_mixed.pos.y = 0
e_mixed.enemy.can_do_magic = true
e_mixed.main_script.insert = scripts.enemy_basic.insert
e_mixed.main_script.update = scripts.enemy_mixed.update

-- ========== 4. 编译 ==========
local interface = require("precompile.interface")
interface:init()

local function compile_entity(e)
	local ec = table.deepclone(e)
	local name = "_benchc_" .. (e.template_name or "x")
	E.entities[name] = ec
	ec.template_name = name
	interface:compile(ec)
	E.entities[name] = nil
	return ec.main_script.insert, ec.main_script.update
end

local scripts_orig = {
	enemy_insert = scripts.enemy_basic.insert,
	enemy_update = scripts.enemy_mixed.update
}

local _, compiled_melee_update = compile_entity(e_melee)
local _, compiled_mixed_update = compile_entity(e_mixed)

print("")
print("═══  enemy_mixed.update  运行时基准测试  ═══")
print("")

-- ========== 5. 基准测试运行器 ==========
local function run_test(name, entity_tpl, compiled_update, orig_update, soldiers)
	local function run_sim(count, use_compiled)
		local store = H.create_store()
		-- 添加士兵
		for _, s in ipairs(soldiers or {}) do
			local sc = table.deepclone(s)
			H.store_add_entity(store, sc)
		end
		-- 添加敌人
		for i = 1, count do
			local e = H.clone_entity_for_test(entity_tpl)
			e.id = 10000 + i
			e.pos.x = 0
			e.pos.y = 0
			e.nav_path.pi = 0
			e.nav_path.spi = 1
			e.nav_path.ni = 1
			if use_compiled then
				e.main_script.update = compiled_update
			else
				e.main_script.update = orig_update
			end
			H.store_add_entity(store, e)
		end
		-- 运行 1000 帧
		for f = 1, 1000 do
			H.run_simulation_frame(store)
		end
	end

	local result = H.benchmark_stable(name, function(count, compiled)
		run_sim(count, compiled)
	end, nil, {
		-- no explicit compile fn, it's in run_sim
		min_duration = 0.15,
		max_entities = 250
	})
	H.print_result(result)
	return result
end

-- ========== 6. 运行测试 ==========
local all_results = {}

-- 测试 1: 纯近战
local soldiers_20 = H.create_soldiers(E, 20, 200, 0)
table.insert(all_results, run_test("enemy_mixed.update · 纯近战 (no ranged)", e_melee, compiled_melee_update, scripts_orig.enemy_update, soldiers_20))

-- 测试 2: 混合
table.insert(all_results, run_test("enemy_mixed.update · 混合 (melee+ranged)", e_mixed, compiled_mixed_update, scripts_orig.enemy_update, soldiers_20))

H.print_summary(all_results)
