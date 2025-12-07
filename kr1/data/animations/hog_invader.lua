-- chunkname: @./kr5/data/animations/hog_invader.lua
local a = {
	hog_invader_raise = {
		prefix = "hog_invader",
		to = 2,
		from = 2
	},
	hog_invader_idle = {
		prefix = "hog_invader",
		to = 1,
		from = 1
	},
	hog_invader_walkingRightLeft = {
		prefix = "hog_invader",
		to = 21,
		from = 2
	},
	hog_invader_walkingDown = {
		prefix = "hog_invader",
		to = 41,
		from = 22
	},
	hog_invader_walkingUp = {
		prefix = "hog_invader",
		to = 61,
		from = 42
	},
	hog_invader_attack = {
		prefix = "hog_invader",
		to = 85,
		from = 62
	},
	hog_invader_death = {
		prefix = "hog_invader",
		to = 104,
		from = 86
	}
}
return a
