local package_path = "./?.lua;./all/?.lua;./all/systems/?.lua;./kr1/?.lua;./kr1-desktop/?.lua;./all-desktop/?.lua;./lib/?.lua;./lib/klua/?.lua;./lib/hump/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;"
package.path = package_path .. package.path

require("scripts.ci.love_stub")

local E = require("entity_db")
require("components")

local generator = require("all.component_cloner")
local code = generator.generate_table(E.components)
local path = "all/component_cloner_generated.lua"

local chunk, err = load(code, "@" .. path, "t", _G)
if not chunk then
	error("generated component cloner is invalid: " .. tostring(err))
end

local count = 0
for _ in pairs(E.components) do
	count = count + 1
end

local current = io.open(path, "rb")
local old = current and current:read("*a")
if current then
	current:close()
end

if old == code then
	print(string.format("component cloner unchanged: %d components", count))
	return
end

local file = assert(io.open(path, "wb"))
file:write(code)
file:close()

print(string.format("component cloner generated: %d components -> %s", count, path))
