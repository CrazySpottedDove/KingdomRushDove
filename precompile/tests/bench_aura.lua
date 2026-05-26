--[[
precompile/tests/bench_aura.lua
================================
测试 aura_apply_mod (insert + update) 在预编译前后的运行时性能。

测试场景：
  1. 简单光环      — 永久持续，无额外选项
  2. 复杂光环      — 带有限周期、延迟、track_source 等选项

用法：在 KingdomRushDove/ 目录下运行：
  luajit precompile/tests/bench_aura.lua
--]]

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

-- ========== 2. 加载 scripts + 全局 ==========
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

-- 辅助：生成模板时预置 insert 会设置的字段（benchmark 跳过 insert 直接跑 update）
local function set_aura_fields(e)
	e.actual_duration = e.aura.duration
	e.aura.ts = 0
end

-- 简单光环 (永久, 无额外选项)
local e_simple = E:register_t("ba_simple", "aura")
e_simple.aura.mod = "modifier"
e_simple.aura.duration = -1 -- 永久
e_simple.aura.cycle_time = 1 -- 每秒触发一次
e_simple.aura.radius = 200
e_simple.aura.vis_flags = H.F_MOD
e_simple.aura.vis_bans = H.F_FRIEND
e_simple.aura.targets_per_cycle = 5
set_aura_fields(e_simple)
e_simple.pos.x = 300
e_simple.pos.y = 0
e_simple.main_script.insert = scripts.aura_apply_mod.insert
e_simple.main_script.update = scripts.aura_apply_mod.update

-- 复杂光环 (带周期、延迟、track_source 等)
local e_complex = E:register_t("ba_complex", "aura")
e_complex.aura.mod = "modifier"
e_complex.aura.duration = -1 -- 永久
e_complex.aura.cycle_time = 0.5 -- 每 0.5 秒
e_complex.aura.radius = 250
e_complex.aura.vis_flags = H.F_MOD
e_complex.aura.vis_bans = H.F_FRIEND
e_complex.aura.targets_per_cycle = 8
e_complex.aura.max_count = 50
e_complex.aura.apply_delay = 0.1
e_complex.aura.duration_inc = nil
e_complex.aura.hide_source_fx = nil
e_complex.aura.cast_resets_sprite_id = nil
e_complex.aura.allowed_templates = nil
e_complex.aura.excluded_templates = nil
e_complex.aura.filter_source = nil
e_complex.aura.requires_alive_source = nil
e_complex.aura.source_vis_flags = nil
e_complex.aura.use_mod_offset = nil
set_aura_fields(e_complex)
e_complex.pos.x = 300
e_complex.pos.y = 0
e_complex.main_script.insert = scripts.aura_apply_mod.insert
e_complex.main_script.update = scripts.aura_apply_mod.update

-- ========== 4. 编译 ==========
local interface = require("precompile.interface")
interface:init()

local function compile_entity(e)
	local ec = table.deepclone(e)
	local name = "_bc_" .. (e.template_name or "x")
	E.entities[name] = ec
	ec.template_name = name
	interface:compile(ec)
	E.entities[name] = nil
	return ec.main_script.insert, ec.main_script.update
end

local orig_aura_update = scripts.aura_apply_mod.update

local _, comp_simple_update = compile_entity(e_simple)
local _, comp_complex_update = compile_entity(e_complex)

print("")
print("═══  aura_apply_mod  运行时基准测试  ═══")
print("")

-- ========== 5. 测试运行器 ==========
local function run_test(name, entity_tpl, comp_update, orig_update, targets)
	local function run_sim(count, use_compiled)
		local store = H.create_store()
		-- 添加目标实体
		for _, t in ipairs(targets or {}) do
			local tc = table.deepclone(t)
			H.store_add_entity(store, tc)
		end
		-- 添加光环
		for i = 1, count do
			local e = H.clone_entity_for_test(entity_tpl)
			e.id = 30000 + i
			e.pos.x = 300 + (i - 1) * 20
			e.pos.y = 0
			if use_compiled then
				e.main_script.update = comp_update
			else
				e.main_script.update = orig_update
			end
			H.store_add_entity(store, e)
		end
		-- 运行 500 帧
		for f = 1, 500 do
			H.run_simulation_frame(store)
		end
	end

	local result = H.benchmark_stable(name, function(count, compiled)
		run_sim(count, compiled)
	end, nil, {
		min_duration = 0.15,
		max_entities = 200
	})
	H.print_result(result)
	return result
end

-- ========== 6. 运行测试 ==========
local all_results = {}

-- 创建目标实体（50个敌人作为光环目标）
local target_count = 50
local targets = {}
for i = 1, target_count do
	local t = H.create_target_entity(E, 40000 + i, 200 + (i - 1) * 15, -50 + (i % 5) * 25, H.F_ENEMY, 0, 500)
	t.unit = {
		is_stunned = false
	}
	targets[i] = t
end

table.insert(all_results, run_test("aura_apply_mod · 简单光环 (永久, 无选项)", e_simple, comp_simple_update, orig_aura_update, targets))

table.insert(all_results, run_test("aura_apply_mod · 复杂光环 (带多个选项)", e_complex, comp_complex_update, orig_aura_update, targets))

H.print_summary(all_results)
