local M = require("precompile.enemy")
local binkey = require("lib.binkey")

M.enemy_basic = {
	insert = {
		binkey = binkey.new(),
		cache = {}
	}
}

local env = M.env
local c = M.enemy_basic
local ci = c.insert

ci.template = [[
return function(this, store)
	local next, new = P:next_entity_node(this, store.tick_length)

	if not next then
		return false
	end

	U.set_destination(this, next)
	U.set_heading(this, next)

	if this.pos.x == 0 and this.pos.y == 0 then
		this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	end

    -- render_1
    %s

    -- melee_1
    %s

    -- ranged_1
    %s

    -- auras_1
    %s

	this.enemy.gold_bag = this.enemy.gold

    -- water_1
    %s

	return true
end
]]

ci.render = {[[
    for i = 1, #this.render.sprites do
        this.render.sprites[i].ts = store.tick_ts
    end
]]}

ci.melee = {[[
    for i = 1, #this.melee.attacks do
        this.melee.attacks[i].ts = store.tick_ts
    end
]]}

ci.ranged = {[[
    for i = 1, #this.ranged.attacks do
        this.ranged.attacks[i].ts = store.tick_ts
    end
]]}

ci.auras = {[[
    for i = 1, #this.auras.list do
        local a = this.auras.list[i]
        a.ts = store.tick_ts

        if a.cooldown == 0 then
            local e = E:create_entity(a.name)

            e.pos.x = this.pos.x
            e.pos.y = this.pos.y
            e.aura.level = this.unit.level
            e.aura.source_id = this.id
            e.aura.ts = store.tick_ts

            queue_insert(store, e)
        end
    end
]]}

ci.water = {[[
    if this.spawn_data and this.spawn_data.water_ignore_pi then
        this.water.ignore_pi = this.spawn_data.water_ignore_pi
    end
]]}

ci.binkey:define_keys({"render", "melee", "ranged", "auras", "water"})

function ci.compile(e)
	local template_key = ci.binkey:calculate_key(e)
	local fn = ci.cache[template_key]

	if not fn then
		local render_1 = e.render and ci.render[1] or ""

		local melee_1 = ""
		if e.melee then
			melee_1 = ci.melee[1]
			e.melee.order = env.U.attack_order(e.melee.attacks)
		end

		local ranged_1 = ""
		if e.ranged then
			ranged_1 = ci.ranged[1]
			e.ranged.order = env.U.attack_order(e.ranged.attacks)
		end

		local auras_1 = e.auras and ci.auras[1] or ""

		local water_1 = e.water and ci.water[1] or ""

		local code = string.format(ci.template, render_1, melee_1, ranged_1, auras_1, water_1)
		local chunk, err = load(code, "enemy_basic.insert" .. template_key, "t", M.env)

		if not chunk then
			error(err)
		end

		fn = chunk()

		if type(fn) ~= "function" then
			error("enemy_basic.insert precompile did not return a function")
		end

		ci.cache[template_key] = fn
	end

	return fn
end
