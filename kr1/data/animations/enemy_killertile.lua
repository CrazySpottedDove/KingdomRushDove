-- chunkname: @./kr5/data/animations/enemy_killertile.lua
local a = {
	killertile_creep_idle = {
		prefix = "killertile_creep",
		to = 1,
		from = 1
	},
	killertile_creep_walk = {
		prefix = "killertile_creep",
		to = 33,
		from = 2
	},
	killertile_creep_walk_front = {
		prefix = "killertile_creep",
		to = 65,
		from = 34
	},
	killertile_creep_walk_back = {
		prefix = "killertile_creep",
		to = 97,
		from = 66
	},
	killertile_creep_attack = {
		prefix = "killertile_creep",
		to = 127,
		from = 98
	},
	killertile_creep_death = {
		prefix = "killertile_creep",
		to = 161,
		from = 128
	}
}
return a
