local bit = require("bit")

bor = bit.bor
band = bit.band
bnot = bit.bnot
E = require("entity_db")

require("all.constants")

IS_PHONE = false
IS_PHONE_OR_TABLET = false
IS_CONSOLE = false

function vec_2(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

function vec_1(v1)
	return {
		x = v1,
		y = v1
	}
end

function r(x, y, w, h)
	return {
		pos = vec_2(x, y),
		size = vec_2(w, h)
	}
end

function fts(v)
	return v / FPS
end

function np(pi, spi, ni)
	return {
		dir = 1,
		pi = pi,
		spi = spi,
		ni = ni
	}
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
