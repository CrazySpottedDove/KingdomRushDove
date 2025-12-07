-- chunkname: @./kr3/data/levels/level14_mactans.lua
return {
	sequence_groups = {
		towers = {{"10"}, {"13"}, {"6"}, {"12"}, {"4"}, {"1"}}
	},
	sequence = {
		[GAME_MODE_CAMPAIGN] = {
			[3] = {{fts(400), "tower_block", 2, 5, 4}},
			[5] = {{fts(200), "tower_block", 4, 5, 4}, {fts(1100), "tower_block", 5, 5, 4}},
			[6] = {{fts(500), "tower_block", 2, 5, 3}, {fts(1000), "tower_block", 1, 5, 3}},
			[9] = {{fts(200), "tower_block", 3, 5, 3}, {fts(850), "tower_block", 6, 5, 3}},
			[11] = {{fts(700), "tower_block", 5, 5, 3}, {fts(1400), "tower_block", 3, 5, 3}, {fts(2100), "tower_block", 1, 5, 3}},
			[12] = {{fts(640), "tower_block", 2, 5, 2}, {fts(1500), "tower_block", 4, 5, 2}},
			[13] = {{fts(600), "tower_block", 1, 5, 2}, {fts(1700), "tower_block", 3, 5, 2}},
			[14] = {{fts(300), "tower_block", 4, 5, 2}, {fts(550), "tower_block", 2, 5, 2}, {fts(1400), "tower_block", 6, 5, 2}},
			[15] = {{fts(500), "tower_block", 1, 5, 1}, {fts(1500), "tower_block", 3, 5, 1}, {fts(2100), "tower_block", 6, 5, 1}}
		},
		[GAME_MODE_HEROIC] = {},
		[GAME_MODE_IRON] = {{{fts(0), "tower_block", 1, 5, 1}, {fts(300), "tower_block", 3, 5, 1}, {fts(700), "tower_block", 5, 5, 1}, {fts(1000), "tower_block", 2, 5, 1}, {fts(1300), "tower_block", 4, 5, 1}, {fts(1700), "tower_block", 6, 5, 1}, {fts(1900), "tower_block", 1, 5, 1}, {fts(2000), "tower_block", 3, 5, 1}, {fts(2200), "tower_block", 5, 5, 1}, {fts(2400), "tower_block", 2, 5, 1}}}
	}
}
