local c = require('precompile.compile_utils')
local bit = require("bit")
local env = {
	print = print,
	bit = bit,
	band = bit.band,
	bor = bit.bor,
	bnot = bit.bnot,
	U = {
		attack_order = function(a)
			return #a
		end,
		set_destination = function()
		end,
		set_heading = function()
		end,
		find_nearest_soldier = function()
			return nil
		end,
		cleanup_blockers = function()
		end,
		animation_start = function()
		end,
		animation_name_facing_point = function()
			return "", ""
		end,
		y_animation_play = function()
		end
	},
	SU = {
		y_enemy_death = function()
		end,
		y_enemy_stun = function()
		end,
		y_enemy_walk_step = function()
		end,
		y_wait_for_blocker = function()
			return true
		end,
		y_enemy_range_attacks = function()
			return true
		end,
		y_enemy_melee_attacks = function()
			return true
		end,
		can_melee_blocker = function()
			return false
		end,
		can_range_soldier = function()
			return false
		end
	},
	P = {
		next_entity_node = function()
			return true
		end,
		node_pos = function()
			return {
				x = 0,
				y = 0
			}
		end,
		is_node_valid = function()
			return true
		end
	},
	GR = {
		cell_type = function()
			return 0
		end
	},
	S = {
		queue = function()
		end
	},
	E = {
		create_entity = function()
			return {
				pos = {
					x = 0,
					y = 0
				},
				aura = {}
			}
		end
	},
	TERRAIN_WATER = 1,
	TERRAIN_LAND = 2,
	FPS = 60,
	queue_insert = function()
	end
}

local tpl = require("precompile.templates.enemy_mixed")
local e = {
	ranged = nil,
	melee = {
		attacks = {{
			dmg = 1
		}}
	},
	render = {
		sprites = {{
			name = 't'
		}}
	},
	unit = {
		level = 1
	},
	health = {
		dead = false
	},
	pos = {
		x = 100,
		y = 100
	},
	enemy = {
		gold = 10,
		blockers = {}
	},
	nav_path = {
		pi = 1,
		spi = 1,
		ni = 1
	},
	water = nil,
	sound_events = nil,
	health_bar = {
		hidden = false
	},
	motion = {
		dest = {
			x = 200,
			y = 200
		}
	}
}

local code = c.process(tpl.update, env, e)
local fn, err = load(code, "test", "t", env)
if fn then
	print("OK")
else
	print("ERR:", err)
	for line in code:gmatch("([^\n]*)\n?") do
		print(ln, line)
		ln = ln + 1
	end
end
