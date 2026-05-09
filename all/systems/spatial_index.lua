local M = {}

local perf = require("dove_modules.perf.perf")

local log = require("lib.klua.log"):new("systems")

function M.register(sys)

	sys.spatial_index = {}
	sys.spatial_index.name = "spatial_index"

	function sys.spatial_index:init(store)
		package.loaded["spatial_index"] = nil
		store.enemy_spatial_index = require("spatial_index")

		store.enemy_spatial_index.set_entities(store.enemies)
		store.enemy_spatial_index.gc_locked(store)

		local seek = require("seek")

		seek.set_id_arrays(store.enemy_spatial_index.get_id_arrays())
		seek.set_entities(store.enemies)
	end

	function sys.spatial_index:on_insert_unconditional(entity, store)
		if entity.enemy then
			store.enemy_spatial_index.insert_entity(entity)
		end

	-- return true
	end

	function sys.spatial_index:on_remove_unconditional(entity, store)
		if entity.enemy then
			store.enemy_spatial_index.remove_entity(entity)
		end

		return true
	end

	function sys.spatial_index:on_update(dt, ts, store)
		perf.start("spatial_index")
		store.enemy_spatial_index.on_update(dt)
		perf.stop("spatial_index")
	end
end

return M
