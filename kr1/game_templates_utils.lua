local bit = require("bit")

bor = bit.bor
band = bit.band
bnot = bit.bnot
E = require("entity_db")

require("all.constants")

IS_PHONE = false
IS_PHONE_OR_TABLET = false
IS_CONSOLE = false

local V = require("lib.klua.vector")
vec_2 = V.v
vec_1 = V.vv
r = V.r

function fts(v)
	return v / FPS
end
local nav_path = require("lib.nav_path")

function np(pi, spi, ni)
	return nav_path.new(pi, spi, ni, 1)
end

function d2r(d)
	return d * math.pi / 180
end

function RT(name, ref)
	return E:register_t(name, ref)
end

function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end

function CC(comp_name)
	return E:clone_c(comp_name)
end

-- 合成 insert 函数
function fn_group(...)
	local functions = {...}
	return function(this, store)
		for i = 1, #functions do
			if not functions[i](this, store) then
				return false
			end
		end

		return true
	end
end
