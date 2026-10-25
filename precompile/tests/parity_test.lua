package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

require("scripts.ci.love_stub")

local source = require("precompile.frontend.source")
local specialize = require("precompile.stage.specialize")

local failed = 0

local function check(condition, message)
	if not condition then
		failed = failed + 1
		print("FAIL: " .. message)
	end
end

local function clone(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in pairs(value) do
		out[clone(k)] = clone(v)
	end
	return out
end

local queue = {}

local mock_E = {
	create_entity = function(_, name)
		return {
			name = name,
			pos = {
				x = 0,
				y = 0
			},
			aura = {},
			modifier = {},
			unit = {}
		}
	end
}

local mock_P = {
	next_entity_node = function()
		return {
			x = 100,
			y = 50
		}
	end,
	node_pos = function()
		return {
			x = 3,
			y = 4
		}
	end
}

local mock_U = {
	set_destination = function(e, node)
		e.motion.dest.x, e.motion.dest.y = node.x, node.y
	end,
	set_heading = function(e, node)
		e.heading = {
			angle = node.x - node.y
		}
	end,
	attack_order = function(attacks)
		local order = {}
		for i = 1, #attacks do
			order[i] = i
		end
		return order
	end,
	fts = function(v)
		return v / 30
	end,
	tpos = function()
	end,
	queue_damage = function()
	end,
	bans_add = function(vis, flags)
		vis.bans = flags
	end,
	frandom = function()
		return 0.25
	end
}

package.loaded["entity_db"] = mock_E
package.loaded["path_db"] = mock_P
package.loaded["utils"] = mock_U

_G.E = mock_E
_G.P = mock_P
_G.U = mock_U

_G.simulation = {
	queue_insert_entity = function(_, e)
		queue[#queue + 1] = e
	end
}

local bit = require("bit")
_G.band = bit.band
_G.bor = bit.bor
_G.bnot = bit.bnot
_G.F_ALL = 65535
_G.signal = require("lib.hump.signal")

local scripts = require("scripts")

local function base_entity()
	return {
		template_name = "parity_enemy",
		pos = {
			x = 0,
			y = 0
		},
		motion = {
			dest = {
				x = 0,
				y = 0
			}
		},
		nav_path = {
			pi = 1,
			spi = 1,
			ni = 1
		},
		unit = {
			level = 3
		},
		enemy = {
			gold = 17
		},
		render = {
			sprites = {{
				ts = 0
			}, {
				ts = 0
			}}
		},
		melee = {
			attacks = {{
				ts = 0
			}, {
				ts = 0
			}}
		},
		ranged = {
			attacks = {{
				ts = 0
			}}
		},
		auras = {
			list = {{
				cooldown = 0,
				name = "aura_test"
			}}
		}
	}
end

local function run(fn, entity, store)
	queue = {}
	local result = fn(entity, store)
	return result, queue
end

local original_insert = scripts.enemy_basic.insert
local func, file = assert(source.find_function(original_insert))

local function compare(entity)
	local store = {
		tick_length = 1 / 30,
		tick_ts = 7
	}

	local old_entity = clone(entity)
	local old_result, old_queue = run(original_insert, old_entity, store)

	local new_entity = clone(entity)
	local generated = specialize.specialize(func, clone(entity), {
		file = file.path
	})
	local fn = assert(load(generated.code, "generated_enemy_basic", "t", _G))
	local new_result, new_queue = run(fn(), new_entity, store)

	check(old_result == new_result, "enemy_basic return parity")
	check(old_entity.enemy.gold_bag == new_entity.enemy.gold_bag, "gold_bag parity")
	check(old_entity.pos.x == new_entity.pos.x and old_entity.pos.y == new_entity.pos.y, "pos parity")
	check(#old_queue == #new_queue, "queued entity count parity")
	for i = 1, math.min(#old_queue, #new_queue) do
		check(old_queue[i].name == new_queue[i].name, "queued entity name parity")
		check(old_queue[i].pos.x == new_queue[i].pos.x, "queued entity pos parity")
	end
	if old_entity.render and new_entity.render then
		for i = 1, #old_entity.render.sprites do
			check(old_entity.render.sprites[i].ts == new_entity.render.sprites[i].ts, "sprite ts parity")
		end
	end
	if old_entity.melee then
		check(old_entity.melee.order[1] == new_entity.melee.order[1], "melee order parity")
	end
	if old_entity.ranged then
		check(old_entity.ranged.order[1] == new_entity.ranged.order[1], "ranged order parity")
	end
	if old_entity.auras then
		check(old_entity.auras.list[1].ts == new_entity.auras.list[1].ts, "aura ts parity")
	end
end

local function deep_equal(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for key, value in pairs(a) do
		if not deep_equal(value, b[key]) then
			return false
		end
	end
	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end
	return true
end

local function compare_insert(label, source_fn, entity, store)
	local func, file = assert(source.find_function(source_fn))
	local generated = specialize.specialize(func, clone(entity), {
		file = file.path
	})
	local generated_fn = assert(load(generated.code, "generated_" .. label, "t", _G))()

	local old_entity = clone(entity)
	local new_entity = clone(entity)
	queue = {}
	local old_result = source_fn(old_entity, store)
	local old_queue = queue
	queue = {}
	local new_result = generated_fn(new_entity, store)
	local new_queue = queue

	check(old_result == new_result, label .. " return parity")
	check(deep_equal(old_entity, new_entity), label .. " entity parity")
	check(deep_equal(old_queue, new_queue), label .. " queue parity")
end

compare(base_entity())

local minimal = base_entity()
minimal.render = nil
minimal.melee = nil
minimal.ranged = nil
minimal.auras = nil
compare(minimal)

local aura_store = {
	tick_ts = 7,
	entities = {
		[1] = {
			pos = {
				x = 1,
				y = 2
			},
			unit = {
				mod_offset = {
					x = 3,
					y = 4
				}
			}
		}
	}
}
local aura_entity = {
	template_name = "aura_parity",
	pos = {
		x = 0,
		y = 0
	},
	render = {
		sprites = {{
			ts = 0,
			offset = {
				x = 0,
				y = 0
			}
		}}
	},
	aura = {
		ts = 0,
		source_id = 1,
		duration = 2,
		duration_inc = 0.5,
		level = 2,
		use_mod_offset = true
	}
}
compare_insert("aura_apply_mod.insert", scripts.aura_apply_mod.insert, aura_entity, aura_store)

local mod_store = {
	tick_ts = 7,
	entities = {
		[2] = {
			id = 2,
			template_name = "target",
			health = {
				dead = false
			},
			vis = {
				bans = 0,
				flags = 0
			},
			unit = {
				size = "small"
			},
			render = {
				sprites = {{
					flip_x = true,
					z = 5
				}}
			}
		}
	}
}
local track_entity = {
	template_name = "track_mod",
	modifier = {
		target_id = 2,
		vis_flags = 0,
		vis_bans = 0
	},
	render = {
		sprites = {{
			ts = 0,
			flip_x = false,
			size_names = {
				small = "small_sprite"
			}
		}}
	}
}
compare_insert("mod_track_target.insert", scripts.mod_track_target.insert, track_entity, mod_store)

local dps_entity = {
	template_name = "dps_mod",
	modifier = {
		target_id = 2,
		vis_flags = 0,
		vis_bans = 0,
		ts = 0
	},
	render = {
		sprites = {{
			ts = 0,
			size_names = {
				small = "small_sprite"
			},
			size_scales = {
				small = 0.5
			}
		}}
	},
	dps = {
		ts = 0,
		damage_every = 1
	}
}
compare_insert("mod_dps.insert", scripts.mod_dps.insert, dps_entity, mod_store)

local soldier_entity = {
	template_name = "soldier_parity",
	id = 7,
	pos = {
		x = 5,
		y = 6
	},
	unit = {
		level = 2
	},
	vis = {},
	melee = {
		attacks = {{
			ts = 0
		}, {
			ts = 0
		}}
	},
	ranged = {
		attacks = {{
			ts = 0
		}}
	},
	auras = {
		list = {{
			cooldown = 0,
			name = "aura_soldier"
		}}
	},
	track_kills = {
		mod = "mod_kill_track"
	},
	track_damage = {
		mod = "mod_damage_track"
	},
	render = {
		sprites = {{
			ts = 0
		}, {
			ts = 0
		}}
	}
}
compare_insert("soldier_barrack.insert", scripts.soldier_barrack.insert, soldier_entity, {
	tick_length = 1 / 30,
	tick_ts = 9
})

if failed > 0 then
	print(string.format("%d 个检查失败", failed))
	os.exit(1)
end

print("parity_test 通过")
