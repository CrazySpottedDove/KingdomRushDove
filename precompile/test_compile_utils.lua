local M = require('precompile.compile_utils')

local function test(name, fn)
	local ok = fn()
	if ok then
		io.write("  OK: ", name, "\n")
	else
		io.write("  FAIL: ", name, "\n")
		os.exit(1)
	end
end

test("basic", function()
	return M.process('hello', {}) == 'hello\n'
end)

test("constif then", function()
	local r = M.process('constif(1)\nyes\nconstend', {
		this = {}
	})
	return r:match('yes') ~= nil
end)

test("constif else (false)", function()
	local r = M.process('constif(false)\nno\nconstend', {
		this = {}
	})
	return #r == 0
end)

test("constif else (nil)", function()
	local r = M.process('constif(nil)\nno\nconstend', {
		this = {}
	})
	return #r == 0
end)

test("constelseif", function()
	local r = M.process('constif(false)\na\nconstelseif(1)\nb\nconstend', {
		this = {}
	})
	return r:match('b') ~= nil and r:match('a') == nil
end)

test("constfor", function()
	local r = M.process('constfor i=1,3 do\n(i)\nconstend', {
		this = {}
	})
	return r:match('%(1%)') ~= nil and r:match('%(3%)') ~= nil
end)

test("nested constfor", function()
	local r = M.process('constfor i=1,2 do\nconstfor j=1,2 do\n(i)(j)\nconstend\nconstend', {
		this = {}
	})
	return r:match('%(2%)%(2%)') ~= nil
end)

test("template", function()
	M.define('greet', 'function()\nhello\nend')
	local r = M.process('template greet()', {
		this = {}
	})
	return r:match('hello') ~= nil
end)

test("@constif", function()
	local r = M.process('@constif(1)\nshown', {
		this = {}
	})
	return r:match('shown') ~= nil
end)

test("@constif false", function()
	local r = M.process('@constif(false)\nhidden', {
		this = {}
	})
	return r:match('hidden') == nil
end)

test("constvar", function()
	local r = M.process('constvar x=42\nconststring(x)', {
		this = {}
	})
	return r:match('42') ~= nil
end)

test("conststmt", function()
	local r = M.process('conststmt(x=1)\nconststring(x)', {})
	return r:match('1') ~= nil
end)

test("this.field", function()
	local r = M.process('constif(this.x == 1)\nyes\nconstend', {
		this = {
			x = 1
		}
	})
	return #r > 0
end)

test("this.field false", function()
	local r = M.process('constif(this.x == 0)\nyes\nconstend', {
		this = {
			x = 1
		}
	})
	return #r == 0
end)

test("comment ignored", function()
	local r = M.process('text -- comment\nconstif(1)\ninner\nconstend', {
		this = {}
	})
	return r:match('inner') ~= nil
end)

-- Check globals
local leaked = {}
for k in pairs(_G) do
	if k == '_exec_tpl' or k == 'exec_insts_outer' then
		leaked[#leaked + 1] = k
	end
end
test("no global leaks", function()
	return #leaked == 0
end)
if #leaked > 0 then
	io.write("  Leaked globals: ", table.concat(leaked, ", "), "\n")
end

-- Profile report
M.profile_report()

io.write("ALL TESTS PASSED\n")
