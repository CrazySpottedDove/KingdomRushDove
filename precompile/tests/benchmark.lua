-- precompile 性能基准测试
-- 模拟 entity_db:precompile() 的流程，测量各阶段耗时

-- 设置 love 存根（被所有模块依赖）
if not _G.love then
	_G.love = {}
	love.filesystem = {
		getInfo = function()
			return nil
		end,
		loadWithPreference = function()
			return nil, "stub"
		end
	}
	love.graphics = {
		newImage = function()
			return {}
		end,
		newQuad = function()
			return {}
		end
	}
	love.audio = {
		newSource = function()
			return {}
		end
	}
end
_G.IS_ANDROID = false
_G.LLDEBUGGER = nil
_G.F_ENEMY = 2048
_G.F_FRIEND = 1024
_G.F_MOD = 4
_G.F_RANGED = 2
_G.F_BLOCK = 1
_G.F_FLYING = 128
_G.TERRAIN_LAND = 1
_G.TERRAIN_WATER = 2
_G.FPS = 30
_G.DAMAGE_PHYSICAL = 2
_G.DAMAGE_TRUE = 1
_G.DAMAGE_MAGICAL = 4

-- 扩展 table 模块
if not table.deepclone then
	function table.keys(t)
		local kk = {}
		for k in pairs(t) do
			kk[#kk + 1] = k
		end
		return kk
	end
	function table.clone(t)
		local c = {}
		for k, v in pairs(t) do
			c[k] = v
		end
		return c
	end
	function table.deepclone(t)
		if type(t) ~= "table" then
			return t
		end
		local c = {}
		for k, v in pairs(t) do
			c[k] = table.deepclone(v)
		end
		return c
	end
	function table.contains(t, o)
		for _, v in pairs(t) do
			if v == o then
				return true
			end
		end
		return false
	end
	function table.merge(t1, t2, new)
		local m = new and table.clone(t1) or t1
		for k, v in pairs(t2) do
			m[k] = v
		end
		return m
	end
end

-- 模块存根
local stubs = {
	["lib.hump.signal"] = {
		emit = function()
		end,
		register = function()
		end
	},
	["lib.klua.log"] = {
		new = function(name)
			return {
				debug = function()
				end,
				info = function()
				end,
				warn = function()
				end,
				error = function()
				end
			}
		end
	},
	["dove_modules.perf.perf"] = {
		start = function()
		end,
		stop = function()
		end,
		tmp_start = function()
		end,
		tmp_stop = function()
		end
	},
	["i18n"] = setmetatable({}, {
		__call = function(_, s)
			return s
		end
	}),
	["kr1.game_settings"] = {
		difficulty_enemy_speed_factor = {
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1
		}
	},
	["kr1.upgrades"] = {},
	["achievements"] = {},
	["level_utils"] = {},
	["sound_db"] = {
		queue = function()
		end,
		stop_all = function()
		end
	},
	["grid_db"] = {
		cell_type = function()
			return 1
		end,
		get_coords = function()
			return 1, 1
		end
	},
	["path_db"] = {
		next_entity_node = function()
			return {
				x = 0,
				y = 0
			}, true
		end,
		is_node_valid = function()
			return true
		end
	},
	["all.constants"] = true
}
for name, mod in pairs(stubs) do
	if not package.loaded[name] then
		package.loaded[name] = mod
	end
end

package.loaded["lib.klua.table"] = true

local function bench(name, fn)
	collectgarbage("collect")
	local t0 = os.clock()
	fn()
	local t1 = os.clock()
	print(string.format("%-40s %.3f ms", name, (t1 - t0) * 1000))
	return t1 - t0
end

-- 构造测试 entities
local function make_entities(n)
	local ents = {}
	for i = 1, n do
		ents[i] = {
			enemy = {
				gold = 10,
				blockers = {},
				can_do_magic = true
			},
			melee = {
				attacks = {{
					dmg = 1,
					ts = 0,
					cooldown = 0.5,
					disabled = false
				}},
				order = 1
			},
			ranged = i % 2 == 0 and nil or {
				attacks = {{
					dmg = 2,
					ts = 0,
					cooldown = 1,
					min_range = 100,
					max_range = 300,
					hold_advance = true
				}, {
					dmg = 3,
					ts = 0,
					cooldown = 1.5,
					min_range = 100,
					max_range = 300,
					hold_advance = false
				}},
				order = 2,
				range_while_blocking = true
			},
			render = {
				sprites = {{
					name = "test",
					ts = 0
				}, {
					name = "idle",
					ts = 0
				}}
			},
			unit = {
				level = 1,
				is_stunned = false
			},
			health = {
				dead = false,
				bar = {
					hidden = false
				}
			},
			health_bar = {
				hidden = false
			},
			pos = {
				x = 100,
				y = 100
			},
			nav_path = {
				pi = 1,
				spi = 1,
				ni = 1
			},
			water = nil,
			auras = nil,
			sound_events = nil,
			motion = {
				dest = {
					x = 200,
					y = 200
				}
			},
			main_script = {
				insert = require("scripts").enemy_basic.insert,
				update = require("scripts").enemy_mixed.update
			}
		}
	end
	return ents
end

-- 加载编译器
local CU = require("precompile.compile_utils")
local MI = require("precompile.interface")

print("=== Precompile Benchmark ===")
print("")

-- 初始化
local compiler
bench("1. compiler:init()", function()
	collectgarbage("collect")
	local t0 = os.clock()
	compiler = MI
	compiler:init()
	print("   " .. string.format("%.3f ms", (os.clock() - t0) * 1000))
end)

-- 模板初始大小
local template_insert = compiler.enemy_basic.insert
local template_update = compiler.enemy_mixed.update
print(string.format("   enemy_basic.insert: %d bytes, %d lines", #template_insert, select(2, template_insert:gsub("\n", "\n"))))
print(string.format("   enemy_mixed.update: %d bytes, %d lines", #template_update, select(2, template_update:gsub("\n", "\n"))))

-- entity 数量
local entities = make_entities(10)
print(string.format("   test entities: %d", #entities))
print("")

-- 逐 entity 计时
local total_process = 0
local total_load = 0
local process_calls = 0
local load_calls = 0

for idx, e in ipairs(entities) do
	local m = e.main_script
	if e.enemy and m.insert == compiler.enemy_basic.insert then
		process_calls = process_calls + 1
		local t0 = os.clock()
		local code = CU.process(compiler.enemy_basic.insert, compiler.env, e)
		total_process = total_process + (os.clock() - t0)

		local fn, err = load(code, nil, "t", compiler.env)
		if fn then
			total_load = total_load + (os.clock() - t0) -- includes process time, approximate
		end
		load_calls = load_calls + 1
	end

	if e.enemy and (e.melee or e.ranged) and m.update == compiler.enemy_mixed.update then
		process_calls = process_calls + 1
		local t0 = os.clock()
		local code = CU.process(compiler.enemy_mixed.update, compiler.env, e)
		total_process = total_process + (os.clock() - t0)

		local fn, err = load(code, nil, "t", compiler.env)
		if fn then
			total_load = total_load + (os.clock() - t0)
		end
		load_calls = load_calls + 1
	end
end

print(string.format("2. CU.process total:   %.3f ms (%d calls, avg %.3f ms)", total_process * 1000, process_calls, total_process * 1000 / process_calls))
print(string.format("3. CU.process+load:    %.3f ms (%d calls)", total_load * 1000, load_calls))
print(string.format("   load() per entity:  %.3f ms", (total_load - total_process) * 1000 / load_calls))
print("")

-- 整体预编译计时
print("4. Full precompile (10 entities):")
local t0 = os.clock()
for _, e in ipairs(entities) do
	compiler:compile(e)
end
print(string.format("   total: %.3f ms", (os.clock() - t0) * 1000))

-- 插入 CU.process 内部计时
print("")
print("=== CU.process internal timing ===")
local e = entities[1]

-- eval_expr 次数统计
local orig_eval = CU.eval_expr
-- (we can't easily count calls without modifying the module)
-- Instead, instrument CU.process directly

local function timed_process(template, env, entity, label)
	local t0 = os.clock()
	local code = CU.process(template, env, entity)
	local dt = (os.clock() - t0) * 1000
	print(string.format("   %-30s %.3f ms -> %d bytes", label, dt, #code))
	return code
end

local code_insert = timed_process(compiler.enemy_basic.insert, compiler.env, entities[1], "enemy_basic.insert")
local code_update = timed_process(compiler.enemy_mixed.update, compiler.env, entities[1], "enemy_mixed.update")
local code_update2 = timed_process(compiler.enemy_mixed.update, compiler.env, entities[5], "enemy_mixed.update(5)")

-- load+chunk 计时
local _, first_load_err
local t0 = os.clock()
local fn, err = load(code_update, nil, "t", compiler.env)
local load_dt = (os.clock() - t0) * 1000
if fn then
	print(string.format("   load(%d bytes):         %.3f ms", #code_update, load_dt))
	t0 = os.clock()
	fn()
	print(string.format("   chunk():                %.3f ms", (os.clock() - t0) * 1000))
else
	print("   load() FAILED:", err)
end

print("")
print("Done.")
