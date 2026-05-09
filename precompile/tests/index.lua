--[[
precompile/tests/index.lua
==========================
预编译测试入口 — 统一管理正确性测试与性能基准测试。

用法：
  luajit precompile/tests/index.lua [命令]

命令：
  help                 显示此帮助
  list                 列出所有可用测试
  all                  运行全部测试
  correctness          运行全部正确性测试
  performance          运行全部性能测试
  <test_name>          运行指定测试

示例：
  luajit precompile/tests/index.lua help
  luajit precompile/tests/index.lua all
  luajit precompile/tests/index.lua correctness
  luajit precompile/tests/index.lua bench_aura
--]]

-- 确保 package.path 包含项目目录
local project_root = (...):match("^(.+%.)precompile%.tests%.index$") or (...):match("^(.+%.)precompile%.tests%)") or ""
local base_path = project_root:gsub("%.", "/")
if base_path == "" then
	base_path = "."
end

local function add_path(p)
	if not package.path:find(p, 1, true) then
		package.path = package.path .. ";" .. p
	end
end
add_path("./?.lua")
add_path("./all/?.lua")
add_path("./all/systems/?.lua")
add_path("./lib/?.lua")
add_path("./lib/klua/?.lua")
add_path("./lib/hump/?.lua")
add_path("./lib/klove/?.lua")
add_path("./kr1/?.lua")
add_path("./precompile/?.lua")
add_path("./precompile/templates/?.lua")
add_path("./precompile/tests/?.lua")
add_path("./dove_modules/?.lua")
add_path("./dove_modules/perf/?.lua")
add_path("./data/?.lua")

-- ===================== 测试注册 =====================

local test_registry = {
	correctness = {{
		name = "constvar",
		description = "constvar 编译期常量解析 — 验证 constvar 在基本作用域、constif 分支、constfor 循环、template 展开中的行为",
		file = "precompile/tests/test_constvar.lua"
	}},
	performance = {{
		name = "bench_runtime",
		description = "constif 运行时微基准 — 对比 256 种不同配置下编译消除分支 vs 运行时分支的执行速度",
		file = "precompile/tests/bench_runtime.lua"
	}, {
		name = "bench_enemy_mixed",
		description = "enemy_mixed.update 运行时 — 模拟敌人行走/索敌/攻击，对比纯近战和混合敌人在编译前后的性能",
		file = "precompile/tests/bench_enemy_mixed.lua"
	}, {
		name = "bench_aura",
		description = "aura_apply_mod 运行时 — 模拟光环对范围内目标施加效果，对比简单光环和复杂光环在编译前后的性能",
		file = "precompile/tests/bench_aura.lua"
	}}
-- bench_pipeline (benchmark.lua) 需要完整的 love2d 环境，未包含在自动测试中
}

-- 扁平索引（name → test_info）
local by_name = {}
for group, tests in pairs(test_registry) do
	for _, t in ipairs(tests) do
		t.group = group
		by_name[t.name] = t
	end
end

-- ===================== 运行器 =====================

local results = {
	ok = 0,
	fail = 0,
	ok_names = {},
	fail_names = {}
}

local function run_test(test)
	local file = test.file
	if file:sub(1, 1) ~= "/" then
	-- 相对路径，基于当前目录
	end
	local full_path = file

	print("")
	print(string.rep("=", 70))
	print("  [" .. test.group .. "] " .. test.name)
	print("  " .. test.description)
	print(string.rep("=", 70))
	print("")

	local ok, err = pcall(dofile, full_path)
	if ok then
		results.ok = results.ok + 1
		table.insert(results.ok_names, test.name)
		print("")
		print(string.format("  ✅ %s 完成", test.name))
	else
		results.fail = results.fail + 1
		table.insert(results.fail_names, test.name)
		print("")
		print(string.format("  ❌ %s 失败: %s", test.name, tostring(err)))
		print(debug.traceback())
	end
	print("")
end

local function run_group(group_name)
	local tests = test_registry[group_name]
	if not tests then
		print("未知测试组: " .. group_name)
		print("可用组: correctness, performance")
		return
	end
	print(string.format("运行测试组 [%s] (%d 个测试)...", group_name, #tests))
	for _, t in ipairs(tests) do
		run_test(t)
	end
end

local function run_all()
	local total = 0
	for _, tests in pairs(test_registry) do
		total = total + #tests
	end
	print(string.format("运行全部测试 (%d 个)...", total))
	for group_name, tests in pairs(test_registry) do
		for _, t in ipairs(tests) do
			run_test(t)
		end
	end
end

local function run_single(name)
	local test = by_name[name]
	if not test then
		print("未知测试: " .. name)
		print("可用测试:")
		for _, t in by_name do
			print(string.format("  %-25s %s", t.name, t.description))
		end
		return
	end
	run_test(test)
end

local function print_help()
	print([[
╔══════════════════════════════════════════════════════════════════════╗
║             预编译测试工具                                           ║
╚══════════════════════════════════════════════════════════════════════╝

用法:
  luajit precompile/tests/index.lua [命令]

命令:
  help                 显示此帮助
  list                 列出所有可用测试
  all                  运行全部测试
  correctness          运行全部正确性测试
  performance          运行全部性能测试
  <test_name>          运行指定测试

测试分组:
]])
	for group_name, tests in pairs(test_registry) do
		print(string.format("  [%s]", group_name))
		for _, t in ipairs(tests) do
			print(string.format("    %-25s %s", t.name, t.description))
		end
		print("")
	end
	print("示例:")
	print("  luajit precompile/tests/index.lua help")
	print("  luajit precompile/tests/index.lua list")
	print("  luajit precompile/tests/index.lua all")
	print("  luajit precompile/tests/index.lua correctness")
	print("  luajit precompile/tests/index.lua bench_aura")
	print("")
end

local function print_list()
	print("可用测试:")
	print("")
	for group_name, tests in pairs(test_registry) do
		print(string.format("  [%s]", group_name))
		for _, t in ipairs(tests) do
			print(string.format("    %-25s %s", t.name, t.description))
		end
		print("")
	end
	print(string.format("共 %d 个测试 (%d 个正确性, %d 个性能)", (function()
		local c, p = 0, 0
		for _, tests in pairs(test_registry) do
			if _ == "correctness" then
				c = #tests
			elseif _ == "performance" then
				p = #tests
			end
		end
		return c + p, c, p
	end)()))
end

-- ===================== 主入口 =====================

local cmd = arg and arg[1]

if not cmd or cmd == "help" or cmd == "--help" or cmd == "-h" then
	print_help()
elseif cmd == "list" or cmd == "ls" then
	print_list()
elseif cmd == "all" then
	run_all()
elseif cmd == "correctness" or cmd == "correct" then
	run_group("correctness")
elseif cmd == "performance" or cmd == "perf" then
	run_group("performance")
else
	run_single(cmd)
end

-- 输出汇总
if results.ok > 0 or results.fail > 0 then
	print("")
	print(string.rep("=", 70))
	print(string.format("  汇总: %d 通过, %d 失败 (共 %d)", results.ok, results.fail, results.ok + results.fail))
	if results.fail > 0 then
		print("  失败: " .. table.concat(results.fail_names or {}, ", "))
	end
	print(string.rep("=", 70))
	print("")
end

-- 如果有失败，非零退出
if results.fail > 0 then
	os.exit(1)
end
