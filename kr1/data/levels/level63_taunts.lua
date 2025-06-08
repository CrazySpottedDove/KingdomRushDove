﻿-- chunkname: @./kr3/data/levels/level15_taunts.lua

return {
	sequence = {
		[GAME_MODE_CAMPAIGN] = {
			[0] = {
				{
					1,
					"welcome_mactans",
					1
				},
				{
					3,
					"welcome_malicia",
					1
				},
				{
					15,
					{
						"pre_mactans",
						"pre_malicia"
					},
					0,
					true
				}
			},
			{
				{
					13.33,
					"mactans",
					-1
				}
			},
			{
				{
					4,
					"malicia",
					0
				},
				{
					13.33,
					"mactans",
					0
				}
			},
			{
				{
					13.16,
					"malicia",
					-1
				}
			},
			{
				{
					33.33,
					"mactans",
					-1
				}
			},
			{
				{
					24,
					"malicia",
					-1
				}
			},
			[7] = {
				{
					15.33,
					"mactans",
					-1
				},
				{
					44.66,
					"malicia",
					-1
				}
			},
			[9] = {
				{
					30,
					"malicia",
					-1
				}
			},
			[10] = {
				{
					40,
					"mactans",
					-1
				}
			},
			[12] = {
				{
					22.33,
					"malicia",
					-1
				},
				{
					37.5,
					"mactans",
					-1
				}
			},
			[13] = {
				{
					7,
					"malicia",
					-1
				}
			},
			[14] = {
				{
					4.666,
					"malicia",
					-1
				},
				{
					38.33,
					"mactans",
					-1
				}
			},
			[15] = {
				{
					10,
					"malicia",
					-1
				},
				{
					53.33,
					"mactans",
					-1
				},
				{
					63.33,
					"malicia",
					-1
				}
			}
		},
		[GAME_MODE_HEROIC] = {},
		[GAME_MODE_IRON] = {}
	}
}
