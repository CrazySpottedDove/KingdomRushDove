local M = {}

local math = require("math")
local PI = math.pi
local random = math.random
local bit = require("bit")
local band = bit.band
local perf = require("dove_modules.perf.perf")
local E = require("entity_db")
local V = require("lib.klua.vector")

function M.register(sys)

	local function queue_insert(store, e)
		simulation:queue_insert_entity(e)
	end

	local function queue_remove(store, e)
		simulation:queue_remove_entity(e)
	end

	sys.pops = {}
	sys.pops.name = "pops"

	function sys.pops:on_update(dt, ts, store)
		local damages_applied = store.damages_applied
		local entities = store.entities

		for i = 1, #damages_applied do
			local d = damages_applied[i]
			local pop, target_id = d.pop, d.target_id

			if pop and target_id then
				local source = entities[d.source_id]
				local target = entities[target_id]
				local pop_entity = (source and (source.enemy or source.soldier)) and source or target

				if pop_entity then
					local pop_chance = d.pop_chance
					local pop_conds = d.pop_conds

					if (not pop_chance or random() < pop_chance) and (not pop_conds or band(d.damage_result, pop_conds) ~= 0) then
						local name = pop[random(1, #pop)]
						local e = E:create_entity(name)

						if e.pop_over_target and target then
							pop_entity = target
						end

						local pos_x, pos_y = pop_entity.pos.x, pop_entity.pos.y + e.pop_y_offset

						if pop_entity.unit and pop_entity.unit.pop_offset then
							pos_y = pos_y + pop_entity.unit.pop_offset.y
						elseif pop_entity == target and pop_entity.unit and pop_entity.unit.hit_offset then
							pos_y = pos_y + pop_entity.unit.hit_offset.y
						end

						e.pos = V.v(pos_x, pos_y)
						e.render.sprites[1].r = random(-21, 21) * PI / 180
						e.render.sprites[1].ts = store.tick_ts

						queue_insert(store, e)
					end
				end
			end
		end
	end
end

return M
