-- chunkname: @./kr1-desktop/data/kui_templates/hero_room_view.lua

local BC = {
	255,
	255,
	255,
	0
}
local W, H = 920, 752
-- local W, H = 1420, 1128
local scale = 1.4
local function vscale(x, y)
    return {
        x = x * scale,
        y = y * scale
    }
end
local hero_room_view = {
	class = "HeroRoomViewKR1",
	colors = {
		background = {
			0,
			0,
			0,
			80
		}
	},
	size = {
        x = 1920,
        y = 1080
    },
	children = {
		{
			id = "back",
			image_name = "heroroom_bg",
			class = "KImageView",
			size = v(W, H),
			anchor = v(W * 0.5, H * 0.5),
			pos = v(960, 540),
            scale = vscale(1, 1),
			children = {
				{
					text_key = "HERO ROOM",
					class = "GGPanelHeader",
					pos = v(W * 0.5 + 5, 30),
					size = v(260, 45),
					anchor = v(130, 0),
					colors = {
						background = BC
					}
				},
				{
					text_key = "Select hero",
					class = "GGPanelHeader",
					pos = v(307, 112),
					size = v(300, 45),
					anchor = v(150, 0),
					scale = v(0.5, 0.5),
					colors = {
						background = BC
					}
				},
				{
					id = "hero_thumbs",
					class = "KView",
					pos = v(113, 146),
					size = v(310, 244)
				},
				{
					id = "hero_portraits",
					class = "KView",
					pos = v(358, -40),
					children = {
						{
							id = "portrait_hero_gerald",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0001"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0001",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 28,
										prefix = "heroroom_animations_lighseeker_a"
									}
								},
								{
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 18,
										prefix = "heroroom_animations_lighseeker_b"
									}
								}
							}
						},
						{
							id = "portrait_hero_alleria",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0003"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0003",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_2"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_3"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_4"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_5"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 93,
										prefix = "pa_alleria_6"
									}
								}
							}
						},
						{
							id = "portrait_hero_malik",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0002"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0002",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 28,
										prefix = "heroroom_animations_malik_a"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 81,
										prefix = "heroroom_animations_malik_b"
									}
								}
							}
						},
						{
							id = "portrait_hero_bolin",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0004"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0004",
									class = "KImageView"
								},
								{
									loop_wait_hidden = true,
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 20,
										prefix = "heroroom_animations_bolin_a"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 73,
										prefix = "pa_bolin_b1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 73,
										prefix = "pa_bolin_b2"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 60,
										prefix = "heroroom_animations_bolin_c"
									}
								}
							}
						},
						{
							id = "portrait_hero_magnus",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0005"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0005",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 56,
										prefix = "pa_magnus_a1"
									}
								},
								{
									class = "KImageView",
									image_name = "pa_magnus_a2_0001"
								},
								{
									ani_alpha_loop = true,
									class = "HPAni",
									image_name = "pa_magnus_b1_0022",
									ani_alpha = {
										{
											0,
											0
										},
										{
											1,
											1
										},
										{
											3,
											0
										},
										{
											7,
											0
										}
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 47,
										prefix = "pa_magnus_b2"
									}
								}
							}
						},
						{
							id = "portrait_hero_ignus",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0006"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0006",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									fps = 15,
									scale = v(2, 2),
									animation = {
										to = 35,
										prefix = "pa_ignus_a",
										from = 1
									}
								},
								{
									loop = true,
									class = "HPAni",
									fps = 15,
									scale = v(2, 2),
									animation = {
										to = 70,
										prefix = "pa_ignus_a",
										from = 36
									}
								},
								{
									loop = true,
									fps = 15,
									class = "HPAni",
									animation = {
										to = 30,
										prefix = "pa_ignus_b",
										from = 1
									}
								},
								{
									loop = true,
									fps = 15,
									class = "HPAni",
									animation = {
										to = 60,
										prefix = "pa_ignus_b",
										from = 31
									}
								},
								{
									class = "KImageView",
									image_name = "pa_ignus_b_0061"
								},
								{
									loop = true,
									fps = 30,
									class = "HPAni",
									animation = {
										to = 70,
										prefix = "pa_ignus_c",
										from = 1
									}
								},
								{
									loop = true,
									fps = 30,
									class = "HPAni",
									animation = {
										to = 140,
										prefix = "pa_ignus_c",
										from = 71
									}
								}
							}
						},
						{
							id = "portrait_hero_denas",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0007"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0007",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 59,
										prefix = "heroroom_animations_denas_a"
									}
								},
								{
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 30,
										prefix = "pa_denas_b",
										from = 1
									}
								},
								{
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 60,
										prefix = "pa_denas_b",
										from = 31
									}
								},
								{
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 90,
										prefix = "pa_denas_b",
										from = 61
									}
								},
								{
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 120,
										prefix = "pa_denas_b",
										from = 91
									}
								},
								{
									loop_wait_hidden = true,
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 31,
										prefix = "heroroom_animations_denas_c"
									}
								}
							}
						},
						{
							id = "portrait_hero_elora",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0008"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0008",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a2"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a3"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a4"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a5"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 138,
										prefix = "pa_elora_a6"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 28,
										prefix = "heroroom_animations_frost_b"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 42,
										prefix = "heroroom_animations_frost_c"
									}
								}
							}
						},
						{
							id = "portrait_hero_ingvar",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0009"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0009",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 47,
										prefix = "pa_ingvar_b1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										to = 47,
										prefix = "pa_ingvar_b2"
									}
								},
								{
									loop_wait_hidden = true,
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 27,
										prefix = "heroroom_animations_vicking_d"
									}
								},
								{
									loop_wait_hidden = true,
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 33,
										prefix = "heroroom_animations_vicking_e"
									}
								},
								{
									ani_alpha_loop = true,
									class = "HPAni",
									image_name = "heroroom_animations_vicking_c_0044",
									ani_alpha = {
										{
											0,
											0
										},
										{
											3,
											1
										},
										{
											5,
											0
										},
										{
											9,
											0
										}
									}
								}
							}
						},
						{
							id = "portrait_hero_hacksaw",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0011"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0011",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(96, 6),
									scale = v(2, 2),
									animation = {
										to = 90,
										prefix = "pa_hacksaw_a",
										from = 1
									}
								},
								{
									class = "HPAni",
									pos = v(186, 316),
									loop_wait = {
										2,
										5
									},
									scale = v(2, 2),
									animation = {
										to = 18,
										prefix = "pa_hacksaw_b",
										from = 1
									}
								}
							}
						},
						{
							id = "portrait_hero_oni",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0010"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0010",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(125, 95),
									animation = {
										to = 18,
										prefix = "pa_oni_1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(525, 95),
									scale = v(-1, 1),
									animation = {
										to = 18,
										prefix = "pa_oni_1"
									}
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(125, 95),
									animation = {
										to = 18,
										prefix = "pa_oni_3"
									}
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(125, 95),
									animation = {
										to = 18,
										prefix = "pa_oni_4"
									}
								},
								{
									loop = true,
									class = "HPAni",
									pos = v(125, 95),
									animation = {
										to = 18,
										prefix = "pa_oni_5"
									}
								},
								{
									ani_alpha_loop = true,
									class = "HPAni",
									image_name = "pa_oni_f_0001",
									pos = v(125, 95),
									ani_alpha = {
										{
											0,
											0
										},
										{
											2,
											1
										},
										{
											3,
											0
										},
										{
											6,
											0
										}
									}
								}
							}
						},
						{
							id = "portrait_hero_thor",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0012"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0012",
									class = "KImageView"
								},
								{
									loop_wait_hidden = true,
									class = "HPAni",
									loop_wait = {
										2,
										5
									},
									animation = {
										to = 25,
										prefix = "heroroom_animations_thor",
										from = 1
									}
								}
							}
						},
						{
							id = "portrait_hero_10yr",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "heroroom_bigportraits_0013"
								},
								{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
								{
									loop = true,
									class = "HPAni",
									animation = {
										fps = 15,
										prefix = "heroroom_animations_10yr",
										from = 1,
										to = 10
									}
								}
							}
						},
                        {
							id = "portrait_hero_mirage",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0002"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_wizard",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0007"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_alric",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_beastmaster",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0005"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_priest",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0003"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_dracolich",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0013"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_pirate",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0004"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_dragon",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0009"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_van_helsing",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0012"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_alien",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0008"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_monk",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0011"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_voodoo_witch",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0015"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_crab",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0010"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_giant",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0006"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_minotaur",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0014"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_monkey_god",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "portrait_notxt_0016"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_elves_archer",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_arivan",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0002"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_catha",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0003"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_regson",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0004"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_elves_denas",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0005"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_rag",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0010"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_bravebark",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0007"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_veznan",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0006"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_phoenix",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0011"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_xin",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0008"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_durax",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0012"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_lynn",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0013"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_bruce",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0014"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_lilith",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0015"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_wilbur",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0016"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_faustus",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "kr3_portrait_notxt_0009"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(140, 95),
                            scale = v(0.85,0.85)
						},
                        {
							id = "portrait_hero_hunter",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_hunter_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
                        {
							id = "portrait_hero_space_elf",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_space_elf_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
                        {
							id = "portrait_hero_raelyn",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_raelyn_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
                        {
							id = "portrait_hero_venom",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_venom_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
                        {
							id = "portrait_hero_dragon_gem",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_dragon_gem_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
                        {
							id = "portrait_hero_witch",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_witch_0001"
								},{
									id = "name_img",
									image_name = "heroroom_bigportraits_name_0013",
									class = "KImageView"
								},
							},
                            pos = v(220, 140),
                            scale = v(0.67,0.67)
						},
						{
							id = "portrait_hero_dragon_bone",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_dragon_bone_0001"
								}, {
								id = "name_img",
								image_name = "heroroom_bigportraits_name_0013",
								class = "KImageView"
							},
							},
							pos = v(220, 140),
							scale = v(0.67, 0.67)
						},
						{
							id = "portrait_hero_lumenir",
							hidden = true,
							class = "KView",
							children = {
								{
									class = "KImageView",
									image_name = "hero_room_portraits_big_hero_lumenir_0001"
								}, {
								id = "name_img",
								image_name = "heroroom_bigportraits_name_0013",
								class = "KImageView"
							},
							},
							pos = v(220, 140),
							scale = v(0.67, 0.67)
						},
						{
							id = "portrait_hero_name_label",
							class = "HeroNameLabel",
							pos = v(230, 335),
							size = v(200, 100)
						}
					}
				},
				{
					class = "KImageView",
					image_name = "heroroom_descriptionBox",
					pos = v(89, 432),
					size = v(705, 240),
					children = {
						{
							vertical_align = "bottom",
							text_key = "MAP_HEROROOM_BIO",
							font_size = 17,
							text_align = "left",
							class = "GGLabel",
							id = "skills_bio_title",
							fit_size = true,
							font_name = "body_bold",
							pos = v(47, 10),
							size = v(330, 24),
							colors = {
								text = {
									155,
									78,
									29,
									255
								},
								background = BC
							}
						},
						{
							text_align = "left",
							text = "A Hero with unmatched strength and unbroken will. A destructive force with an attitude!",
							font_size = 15,
							class = "GGLabel",
							id = "skills_bio_desc",
							fit_size = true,
							font_name = "body",
                            -- font_name = "NotoSansCJKkr-Regular",
                            -- font_name = "taunts",
							pos = v(47, 36),
							size = v(330, 78),
							line_height = ctx.cjk(0.85, 0.85, 1.2, 0.85),
							colors = {
								text = {
									231,
									225,
									181,
									255
								},
								background = BC
							}
						},
						{
							vertical_align = "bottom",
							text_key = "Special abilities",
							font_size = 17,
							text_align = "left",
							class = "GGLabel",
							id = "skills_spec_title",
							fit_size = true,
							font_name = "body_bold",
							pos = v(47, 124),
							size = v(330, 24),
							colors = {
								text = {
									155,
									78,
									29,
									255
								},
								background = BC
							}
						},
						{
							text_align = "left",
							font_size = 15,
							text = "Hammer smash, Earthquake.",
							class = "GGLabel",
							id = "skills_spec_desc",
							fit_size = true,
							font_name = "body",
							pos = v(47, 150),
							size = v(330, 24),
							colors = {
								text = {
									231,
									225,
									181,
									255
								},
								background = BC
							}
						}
					}
				},
				{
					class = "KView",
					id = "hero_room_stats",
					pos = v(610, 483),
					size = v(170, 150),
					children = {
						{
							id = "hero_room_stat_health",
							class = "HeroStatDots",
							pos = v(0, 0)
						},
						{
							id = "hero_room_stat_damage",
							class = "HeroStatDots",
							pos = v(0, 35)
						},
						{
							id = "hero_room_stat_range",
							class = "HeroStatDots",
							pos = v(0, 69)
						},
						{
							id = "hero_room_stat_speed",
							class = "HeroStatDots",
							pos = v(0, 104)
						}
					}
				},
				{
					id = "hero_room_sel",
					class = "KView",
					pos = v(687, 436),
					children = {
						{
							id = "hero_room_sel_deselect",
							class = "GGKR1SelectButton",
							label_text_key = "MAP_HERO_ROOM_DESELECT",
							hidden = true,
							default_image_name = "heroroom_selectBtn_0001",
							click_image_name = "heroroom_selectBtn_0002"
						},
						{
							id = "hero_room_sel_select",
							class = "GGKR1SelectButton",
							label_text_key = "MAP_HERO_ROOM_SELECT",
							hidden = false,
							default_image_name = "heroroom_selectBtn_0003",
							click_image_name = "heroroom_selectBtn_0004"
						},
						{
							vertical_align = "middle",
							text_shadow = true,
							font_size = 13,
							id = "hero_room_sel_locked",
							image_name = "heroroom_unlock",
							text = "UNLOCKS AT STAGE 4",
							line_height = 0.85,
							class = "GGLabel",
							hidden = true,
							fit_size = true,
							font_name = "sans_bold",
							anchor = v(120, 40),
							text_size = v(108, 36),
							text_offset = v(95, 21),
							colors = {
								text = {
									240,
									240,
									240,
									255
								},
								text_shadow = {
									0,
									0,
									0,
									150
								}
							}
						}
					}
				},
				{
					class = "GGDoneButton",
					label_text_key = "BUTTON_DONE",
					id = "done_button",
					pos = v(737, 698),
					anchor = v(71.5, 35.5)
				},
				{
					hover_image_name = "levelSelect_closeBtn_0002",
					class = "KImageButton",
					click_image_name = "levelSelect_closeBtn_0003",
					id = "close_button",
					default_image_name = "levelSelect_closeBtn_0001",
					pos = v(886, 39),
					anchor = v(17, 16)
				}
			}
		}
	}
}

-- local function recursively_scale(table, scale)
--     for _, child in pairs(table) do
--         if child.x then
--             child.x = child.x * scale
--             child.y = child.y * scale
--         end
--         if type(child) == "table" then
--             recursively_scale(child, scale)
--         end
--     end
-- end

-- recursively_scale(hero_room_view, 1.5)

return hero_room_view