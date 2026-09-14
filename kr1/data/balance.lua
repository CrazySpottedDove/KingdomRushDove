local V = require("lib.klua.vector")
local v = V.v
local function fts(v)
	return v / FPS
end
local heroes = {
	common = {
		melee_attack_range = 72
	},
	hero_wukong = {
		distance_to_flywalk = 150,
		speed = 80,
		tp_duration = 1,
		regen_cooldown = 1,
		flywalk_speed_mult = 2.2,
		tp_delay = 0.4,
		dead_lifetime = 15,
		teleport_min_distance = 250,
		shared_cooldown = 3,
		armor = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1},
		hp_max = {260, 286, 312, 338, 354, 390, 416, 442, 468, 494},
		melee_attacks = {
			can_repeat_attack = false,
			cooldown = 1,
			spin = {
				xp_gain_factor = 1.55,
				damage_type = DAMAGE_TRUE,
				damage_max = {11, 14, 16, 18, 20, 24, 26, 29, 31, 36},
				damage_min = {8, 9, 10, 11, 13, 15, 17, 20, 23, 26}
			},
			jump = {
				xp_gain_factor = 1.55,
				damage_type = DAMAGE_TRUE,
				damage_max = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38},
				damage_min = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
			},
			simple = {
				xp_gain_factor = 1.55,
				damage_type = DAMAGE_TRUE,
				damage_max = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38},
				damage_min = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
			},
			fast_hits = {
				xp_gain_factor = 1.55,
				damage_type = DAMAGE_TRUE,
				damage_max = {11, 13, 15, 16, 18, 20, 24, 27, 29, 31},
				damage_min = {8, 9, 10, 11, 12, 14, 16, 18, 20, 24}
			}
		},
		pole_ranged = {
			max_range = 200,
			min_range = 0,
			min_targets = 3,
			damage_radius = 50,
			stun_duration = 3,
			cooldown = {17, 17, 17},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {19, 32, 39},
			damage_min = {13, 18, 23},
			pole_amounts = {3, 5, 7},
			xp_gain = {160, 320, 480}
		},
		hair_clones = {
			max_range = 160,
			min_targets = 2,
			cooldown = {24, 22, 20},
			xp_gain = {160, 320, 480},
			soldier = {
				max_speed = 60,
				armor = 0,
				hp_max = {104, 130, 156},
				duration = {9, 9, 9},
				melee_attack = {
					cooldown = 1,
					range = 72,
					damage_min = {4, 8, 12},
					damage_max = {5, 10, 15},
					damage_type = DAMAGE_PHYSICAL
				}
			}
		},
		zhu_apprentice = {
			dead_lifetime = 9,
			max_speed = 100,
			armor = 0,
			hp_max = {78, 117, 182},
			melee_attack = {
				range = 150,
				cooldown = 1,
				damage_min = {3, 5, 10},
				damage_max = {4, 7, 15},
				damage_type = DAMAGE_PHYSICAL
			},
			smash_attack = {
				cooldown = 5,
				damage_radius = 72,
				damage_min = {39, 71, 97},
				damage_max = {45, 91, 117},
				damage_type = DAMAGE_PHYSICAL,
				chance = {0.3, 0.4, 0.5}
			}
		},
		giant_staff = {
			cooldown = {50.5, 47.5, 44},
			xp_gain = {160, 320, 480},
			area_damage = {
				damage_radius = 90,
				damage_type = DAMAGE_TRUE,
				damage_max = {140, 200, 260},
				damage_min = {120, 160, 200}
			}
		},
		ultimate = {
			cooldown = {42, 42, 42, 42},
			damage_total = {260, 390, 520, 650},
			damage_type = DAMAGE_TRUE,
			slow_duration = {3, 3.5, 4, 4.5},
			slow_factor = {0.5, 0.5, 0.5, 0.5}
		}
	},
	hero_space_elf = {
		speed = 90,
		dead_lifetime = 15,
		teleport_min_distance = 72.5,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {208, 221, 234, 247, 260, 273, 286, 299, 312, 325},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2.36,
			damage_max = {9, 11, 13, 15, 16, 19, 20, 23, 26, 31},
			damage_min = {6, 7, 9, 10, 11, 13, 14, 15, 16, 19}
		},
		basic_ranged = {
			max_range = 160,
			xp_gain_factor = 1.6,
			cooldown = 1.5,
			min_range = 68,
			damage_max = {26, 28, 32, 36, 40, 44, 47, 52, 57, 62},
			damage_min = {14, 15, 18, 19, 22, 23, 26, 28, 31, 33},
			damage_type = DAMAGE_MAGICAL
		},
		astral_reflection = {
			max_range = 175,
			cooldown = {25, 25, 25},
			xp_gain = {200, 400, 600},
			entity = {
				range = 50,
				duration = 12,
				hp_max = {247, 286, 325},
				basic_melee = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_min = {10, 14, 19},
					damage_max = {15, 20, 31}
				},
				basic_ranged = {
					max_range = 160,
					min_range = 68,
					cooldown = 1.5,
					damage_type = DAMAGE_MAGICAL,
					damage_min = {19, 26, 33},
					damage_max = {36, 47, 62}
				}
			}
		},
		black_aegis = {
			range = 200,
			explosion_range = 80,
			xp_gain = {120, 240, 360},
			cooldown = {18, 16, 14},
			duration = {6, 8, 10},
			shield_base = {50, 85, 120},
			explosion_damage = {25, 50, 75},
			explosion_damage_type = DAMAGE_MAGICAL_EXPLOSION
		},
		void_rift = {
			radius = 120,
			min_targets = 2,
			max_range_effect = 300,
			max_range_trigger = 200,
			damage_every = 0.25,
			cooldown = {30, 25, 20},
			xp_gain = {240, 480, 720},
			duration = {6, 8, 10},
			cracks_amount = {1, 2, 3},
			damage_min = {3, 3, 3},
			damage_max = {6, 6, 6},
			damage_type = DAMAGE_MAGICAL_EXPLOSION,
			slow_factor = 0.8
		},
		spatial_distortion = {
			cooldown = {25, 23, 20},
			duration = {6, 7, 8},
			xp_gain = {200, 400, 600},
			range_factor = {1.04, 1.06, 1.08},
			damage_factor = {1.04, 1.06, 1.08},
			cooldown_factor = {0.96, 0.94, 0.92},
			s_range_factor = {0.1, 0.12, 0.15}
		},
		ultimate = {
			radius = 90,
			cooldown = {45, 45, 45, 45},
			damage = {39, 117, 234, 351},
			damage_type = DAMAGE_TRUE,
			duration = {5, 6, 7, 8}
		}
	},
	hero_muyrn = {
		distance_to_treewalk = 75,
		speed = 75,
		treewalk_speed = 95,
		dead_lifetime = 15,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {162, 175, 188, 201, 214, 226, 240, 253, 266, 279},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2,
			damage_max = {10, 11, 12, 13, 14, 16, 17, 18, 19, 20},
			damage_min = {6, 7, 8, 9, 10, 10, 11, 12, 13, 14}
		},
		basic_ranged = {
			max_range = 180,
			xp_gain_factor = 1.52,
			cooldown = 1.5,
			min_range = 68,
			damage_max = {27, 30, 33, 36, 39, 42, 45, 47, 50, 53},
			damage_min = {17, 19, 21, 23, 25, 27, 29, 31, 33, 35},
			damage_type = DAMAGE_MAGICAL
		},
		sentinel_wisps = {
			max_range_trigger = 200,
			min_targets = 1,
			cooldown = {17.5, 17.5, 17.5},
			max_summons = {1, 2, 3},
			wisp = {
				shoot_range = 150,
				cooldown = 1,
				hero_max_distance = 100,
				duration = {6, 6, 6},
				damage_min = {3, 6, 9},
				damage_max = {6, 12, 18},
				damage_type = DAMAGE_MAGICAL
			},
			xp_gain = {140, 280, 420}
		},
		verdant_blast = {
			max_range = 300,
			min_range = 100,
			cooldown = {22.5, 22.5, 22.5},
			damage_max = {150, 300, 450},
			damage_min = {150, 300, 450},
			s_damage = {120, 240, 360},
			damage_type = DAMAGE_MAGICAL_EXPLOSION,
			xp_gain = {168, 336, 504}
		},
		leaf_whirlwind = {
			radius = 50,
			min_targets = 1,
			max_range_trigger = 60,
			heal_every = 0.25,
			damage_every = 0.25,
			cooldown = {25, 23.5, 21},
			duration = {8, 8, 8},
			damage_type = DAMAGE_STAB,
			damage_max = {4, 8, 12},
			damage_min = {2, 4, 6},
			s_damage_min = {8, 16, 24},
			s_damage_max = {16, 32, 56},
			heal_max = {3, 4, 5},
			heal_min = {2, 3, 4},
			xp_gain = {224, 448, 672}
		},
		faery_dust = {
			radius = 80,
			min_targets = 1,
			max_range_trigger = 160,
			max_range_effect = 180,
			cooldown = {14, 14, 14},
			duration = {5, 6, 8},
			damage_factor = {0.4, 0.25, 0.1},
			s_damage_factor = {0.6, 0.75, 0.9},
			xp_gain = {140, 280, 420}
		},
		ultimate = {
			radius = 60,
			damage_every = 0.25,
			cooldown = {32, 32, 32, 32},
			slow_factor = {0.6, 0.6, 0.6, 0.6},
			roots_count = {10, 15, 20, 25},
			duration = {4, 5, 6, 7},
			damage_type = DAMAGE_TRUE,
			damage_min = {4, 5, 6, 7},
			damage_max = {6, 7, 9, 11},
			s_damage_min = {16, 20, 24, 27},
			s_damage_max = {24, 28, 36, 44}
		}
	},
	hero_vesper = {
		dead_lifetime = 15,
		speed = 105,
		regen_cooldown = 1,
		armor = {0.18, 0.21, 0.24, 0.27, 0.3, 0.33, 0.36, 0.39, 0.42, 0.45},
		hp_max = {220, 240, 260, 280, 300, 320, 340, 360, 380, 400},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2,
			damage_max = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30},
			damage_min = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30}
		},
		basic_ranged_short = {
			max_range = 150,
			xp_gain_factor = 2,
			cooldown = 1,
			min_range = 70,
			damage_max = {13, 14, 17, 18, 21, 22, 25, 26, 29, 30},
			damage_min = {8, 9, 10, 12, 13, 14, 16, 17, 19, 20}
		},
		basic_ranged_long = {
			max_range = 205,
			xp_gain_factor = 2,
			cooldown = 2,
			min_range = 150,
			damage_max = {28, 30, 37, 39, 46, 48, 55, 57, 63, 66},
			damage_min = {17, 19, 22, 26, 28, 30, 35, 37, 41, 44}
		},
		arrow_to_the_knee = {
			max_range = 225,
			min_range = 67.5,
			cooldown = {15, 13, 11},
			damage_min = {54, 108, 162},
			damage_max = {72, 144, 216},
			s_damage = {40, 70, 90},
			stun_duration = {1, 1.5, 2},
			xp_gain = {120, 180, 360},
			damage_type = DAMAGE_TRUE
		},
		ricochet = {
			max_range = 205,
			min_range = 70,
			min_targets = 2,
			max_range_trigger = 200,
			bounce_range = 120,
			damage_min = {45, 50, 55},
			damage_max = {45, 50, 55},
			cooldown = {15, 13, 11},
			s_damage = {35, 35, 35},
			bounces = {3, 5, 7},
			damage_type = DAMAGE_PHYSICAL,
			slow_factor = 0.7,
			duration = 2,
			xp_gain = {112, 196, 240}
		},
		martial_flourish = {
			cooldown = {16, 14, 12},
			damage_min = {50, 80, 120},
			damage_max = {50, 80, 120},
			s_damage = {90, 180, 270},
			damage_type = DAMAGE_PHYSICAL,
			xp_gain = {144, 256, 384}
		},
		disengage = {
			distance = 130,
			total_shoots = 3,
			min_distance_from_end = 300,
			cooldown = {16, 14, 12},
			damage_min = {60, 110, 160},
			damage_max = {60, 110, 160},
			damage_type = DAMAGE_PHYSICAL,
			s_damage = {40, 80, 120},
			xp_gain = {160, 320, 480}
		},
		ultimate = {
			enemies_range = 100,
			node_prediction_offset = 0,
			duration = 0.8,
			slow_duration = 1,
			slow_factor = 0.5,
			damage_type = DAMAGE_TRUE,
			damage_radius = 40,
			spread = {8, 10, 12, 14},
			damage = {26, 32, 39, 45},
			cooldown = {40, 40, 40, 40}
		}
	},
	hero_lumenir = {
		dead_lifetime = 15,
		speed = 120,
		regen_cooldown = 1,
		armor = {0, 0.04, 0.08, 0.12, 0.16, 0.2, 0.24, 0.28, 0.32, 0.36},
		hp_max = {357, 390, 422, 455, 487, 520, 552, 585, 617, 650},
		mini_dragon_death = {
			max_range = 150,
			cooldown = 1,
			min_range = 50,
			damage_type = DAMAGE_TRUE,
			damage_max = {15, 15, 15, 15, 31, 31, 31, 46, 46, 46},
			damage_min = {10, 10, 10, 10, 20, 20, 20, 31, 31, 31}
		},
		basic_ranged_shot = {
			max_range = 240,
			xp_gain_factor = 1.46,
			cooldown = 2,
			min_range = 0,
			damage_type = DAMAGE_TRUE,
			damage_max = {33, 40, 46, 54, 61, 67, 74, 80, 88, 96},
			damage_min = {18, 22, 26, 28, 32, 36, 40, 44, 46, 49}
		},
		fire_balls = {
			max_range = 250,
			damage_radius = 55,
			min_targets = 3,
			damage_rate = 0.25,
			min_range = 0,
			duration = 8,
			cooldown = {20, 20, 20},
			damage_type = DAMAGE_TRUE,
			xp_gain = {160, 320, 480},
			flames_count = {5, 6, 7},
			flame_damage_min = {1, 2, 4},
			flame_damage_max = {3, 6, 8}
		},
		mini_dragon = {
			max_range = 150,
			min_range = 50,
			cooldown = {30, 30, 30},
			xp_gain = {240, 480, 720},
			dragon = {
				max_speed = 75,
				duration = {10, 12, 15},
				ranged_attack = {
					max_range = 120,
					cooldown = 1,
					min_range = 0,
					damage_type = DAMAGE_TRUE,
					damage_min = {13, 20, 24},
					damage_max = {18, 31, 37}
				}
			}
		},
		celestial_judgement = {
			range = 300,
			stun_range = 40,
			stun_duration = {2, 2, 2},
			cooldown = {32, 32, 32},
			damage = {240, 480, 720},
			damage_type = DAMAGE_TRUE,
			xp_gain = {280, 560, 840}
		},
		shield = {
			min_targets = 2,
			range = 300,
			spiked_armor = {0.2, 0.4, 0.6},
			armor = {0.1, 0.2, 0.3},
			duration = {8, 8, 8},
			cooldown = {20, 20, 20},
			xp_gain = {160, 320, 480}
		},
		ultimate = {
			range = 200,
			stun_target_duration = 5,
			stun_range = 40,
			max_attack_count = 2,
			stun_duration = 1,
			damage_max = {19, 29, 48, 77},
			damage_min = {13, 19, 32, 51},
			soldier_count = {3, 3, 3, 3},
			cooldown = {30, 30, 30, 30},
			damage_type = DAMAGE_TRUE
		}
	},
	hero_raelyn = {
		dead_lifetime = 15,
		speed = 60,
		regen_cooldown = 1,
		armor = {0.43, 0.46, 0.49, 0.52, 0.55, 0.58, 0.61, 0.64, 0.67, 0.7},
		hp_max = {286, 312, 338, 364, 390, 416, 442, 468, 494, 520},
		melee_damage_max = {20, 24, 26, 30, 34, 36, 39, 44, 48, 50},
		melee_damage_min = {14, 15, 17, 19, 22, 25, 26, 29, 30, 34},
		basic_melee = {
			cooldown = 2,
			xp_gain_factor = 2.6
		},
		unbreakable = {
			min_targets = 1,
			max_range_trigger = 72,
			max_range_effect = 140,
			max_targets = 4,
			cooldown = {25, 25, 25},
			duration = {6, 6, 6},
			shield_base = {0.2, 0.2, 0.2},
			soldier_factor = 0.6,
			shield_per_enemy = {0.1, 0.15, 0.2},
			xp_gain = {280, 560, 840}
		},
		inspire_fear = {
			min_targets = 1,
			max_range_trigger = 72,
			max_range_effect = 120,
			cooldown = {21, 21, 21},
			damage_duration = {6, 6, 6},
			stun_duration = {2, 2.5, 3},
			inflicted_damage_factor = {0.6, 0.4, 0.2},
			damage = {45, 60, 75},
			damage_type = DAMAGE_TRUE,
			xp_gain = {240, 480, 720}
		},
		brutal_slash = {
			cooldown = {20, 19, 18},
			damage_max = {180, 360, 540},
			damage_min = {180, 360, 540},
			s_damage = {160, 320, 480},
			damage_type = DAMAGE_TRUE,
			xp_gain = {240, 480, 720}
		},
		onslaught = {
			radius = 75,
			min_targets = 2,
			xp_gain_factor = 4,
			max_range_trigger = 150,
			cooldown = {24, 20, 18},
			melee_cooldown = {1, 1, 1},
			duration = {6, 8, 10},
			damage_type = DAMAGE_PHYSICAL,
			damage_factor = {0.6, 0.8, 1},
			speed_inc_factor = 0.4,
			cooldown_factor = 0.8
		},
		ultimate = {
			cooldown = {48, 48, 48, 48},
			entity = {
				range = 72,
				duration = 20,
				speed = {60, 60, 60, 60},
				cooldown = {1.5, 1.5, 1.5, 1.5},
				damage_min = {10, 15, 20, 28},
				damage_max = {15, 23, 31, 44},
				damage_type = DAMAGE_TRUE,
				hp_max = {156, 260, 364, 468},
				armor = {0.3, 0.4, 0.55, 0.7}
			}
		}
	},
	hero_builder = {
		dead_lifetime = 15,
		speed = 75,
		regen_cooldown = 1,
		hp_max = {325, 364, 403, 442, 481, 520, 559, 598, 637, 676},
		armor = {0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21, 0.24, 0.27, 0.3},
		melee_damage_max = {16, 19, 21, 23, 24, 26, 28, 30, 32, 34},
		melee_damage_min = {10, 12, 14, 15, 16, 18, 19, 20, 21, 22},
		basic_melee = {
			cooldown = 2,
			xp_gain_factor = 2.6
		},
		overtime_work = {
			max_range = 120,
			min_targets = 2,
			cooldown = {11, 11, 11},
			xp_gain = {100, 200, 300},
			soldier = {
				max_speed = 60,
				armor = 0.15,
				duration = 12,
				hp_max = {50, 75, 100},
				melee_attack = {
					cooldown = 1,
					range = 80,
					damage_min = {2, 4, 6},
					damage_max = {4, 8, 12}
				}
			}
		},
		lunch_break = {
			lost_health = 0.4,
			cooldown = {30, 28, 26},
			heal_hp = {125, 250, 375},
			xp_gain = {240, 480, 720}
		},
		demolition_man = {
			radius = 100,
			max_range = 75,
			damage_every = 0.25,
			min_targets = 2,
			cooldown = {16, 16, 16},
			duration = {1.25, 1.25, 1.25},
			damage_type = DAMAGE_PHYSICAL,
			damage_min = {5, 10, 15},
			damage_max = {8, 16, 24},
			xp_gain = {160, 320, 480}
		},
		defensive_turret = {
			max_range = 180,
			build_speed = 168,
			min_targets = 1,
			cooldown = {30, 30, 30},
			duration = {12, 13.5, 15},
			xp_gain = {240, 480, 720},
			stun_duration = 0.25,
			attack = {
				range = 150,
				cooldown = {0.8, 0.8, 0.8},
				damage_min = {8, 16, 24},
				damage_max = {12, 24, 36}
			}
		},
		ultimate = {
			radius = 80,
			cooldown = {35, 35, 35, 35},
			stun_duration = {2, 2, 2, 2},
			damage = {120, 180, 240, 300},
			damage_type = DAMAGE_AGAINST_ARMOR
		}
	},
	hero_mecha = {
		dead_lifetime = 15,
		speed = 50,
		regen_cooldown = 1,
		hp_max = {260, 273, 286, 299, 312, 325, 338, 351, 364, 377},
		armor = {0.1, 0.16, 0.22, 0.28, 0.34, 0.4, 0.46, 0.52, 0.58, 0.64},
		basic_ranged = {
			max_range = 250,
			min_range = 0,
			cooldown = 2,
			xp_gain_factor = 2.15,
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {18, 20, 24, 26, 28, 31, 34, 37, 40, 45},
			damage_min = {12, 14, 15, 17, 19, 20, 23, 24, 26, 29},
			damage_radius = 50
		},
		goblidrones = {
			units = 2,
			min_targets = 1,
			spawn_range = 110,
			cooldown = {25, 25, 25},
			drone = {
				max_speed = 60,
				duration = {8, 10, 12},
				ranged_attack = {
					max_range = 100,
					cooldown = 1,
					min_range = 10,
					damage_type = DAMAGE_SHOT,
					damage_min = {4, 7, 10},
					damage_max = {5, 10, 15}
				}
			},
			xp_gain = {200, 400, 600}
		},
		tar_bomb = {
			max_range = 200,
			node_prediction = 60,
			min_targets = 1,
			slow_factor = 0.5,
			min_range = 50,
			cooldown = {30, 28, 26},
			duration = {5, 6, 7},
			xp_gain = {240, 448, 624}
		},
		power_slam = {
			min_targets = 2,
			damage_radius = 85,
			cooldown = {20, 20, 20},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {30, 60, 90},
			damage_min = {30, 60, 90},
			s_damage = {26, 52, 78},
			stun_time = {30, 45, 60},
			xp_gain = {160, 320, 480}
		},
		mine_drop = {
			max_range = 80,
			min_dist_between_mines = 30,
			min_range = 35,
			damage_radius = 75,
			cooldown = {10, 8, 6},
			max_mines = {2, 3, 4},
			damage_max = {26, 38, 50},
			damage_min = {16, 24, 32},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {80, 128, 144}
		},
		ultimate = {
			speed_out_of_range = 200,
			attack_radius = 125,
			speed_in_range = 30,
			cooldown = {36, 36, 36, 36},
			ranged_attack = {
				max_range = 200,
				damage_radius = 50,
				cooldown = 0.5,
				min_range = 10,
				damage_type = DAMAGE_TRUE,
				damage_max = {60, 72, 84, 96},
				damage_min = {40, 48, 56, 64}
			}
		}
	},
	hero_venom = {
		slimewalk_speed = 95,
		dead_lifetime = 15,
		speed = 75,
		shared_cooldown = 3,
		distance_to_slimewalk = 72,
		regen_cooldown = 1,
		hp_max = {234, 266, 299, 341, 364, 396, 429, 461, 494, 520},
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		basic_melee = {
			xp_gain_factor = 1.55,
			cooldown = 1,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {15, 18, 20, 22, 24, 27, 29, 31, 33, 36},
			damage_min = {10, 11, 13, 15, 16, 18, 19, 20, 23, 26}
		},
		ranged_tentacle = {
			max_range = 150,
			min_range = 50,
			node_prediction = 60,
			cooldown = {10, 9, 8},
			damage_type = DAMAGE_RUDE,
			damage_max = {30, 60, 90},
			damage_min = {30, 60, 90},
			s_damage = {12, 36, 60},
			bleed_damage_min = {3, 4, 5},
			bleed_damage_max = {3, 4, 5},
			bleed_every = {0.25, 0.25, 0.25},
			bleed_duration = {4, 4, 4},
			xp_gain = {80, 160, 240}
		},
		inner_beast = {
			duration = 10,
			trigger_hp = 0.5,
			cooldown = {35, 35, 35},
			basic_melee = {
				regen_health = 0.1,
				xp_gain_factor = 1,
				cooldown = 2.1,
				damage_type = DAMAGE_RUDE,
				damage_factor = {1.25, 1.5, 1.75},
				s_damage_factor = {0.2, 0.4, 0.6}
			},
			xp_gain = {0, 0, 0}
		},
		floor_spikes = {
			damage_radius = 35,
			min_targets = 3,
			range_trigger_min = 20,
			range_trigger_max = 100,
			cooldown = {30, 30, 30},
			damage_type = DAMAGE_TRUE,
			damage_max = {20, 40, 60},
			damage_min = {20, 40, 60},
			s_damage = {18, 36, 54},
			spikes = {15, 15, 15},
			xp_gain = {240, 480, 720}
		},
		eat_enemy = {
			hp_trigger = 0.3,
			cooldown = {55, 50, 45},
			damage_type = DAMAGE_INSTAKILL,
			regen = {0.1, 0.15, 0.2},
			damage = {40, 50, 60},
			extra_damage_type = DAMAGE_RUDE,
			xp_gain = {100, 200, 300}
		},
		ultimate = {
			radius = 70,
			slow_factor = 0.5,
			slow_delay = 0.5,
			cooldown = {50, 50, 50, 50},
			duration = {3, 3, 3, 3},
			damage_type = DAMAGE_TRUE,
			damage_max = {190, 250, 315, 370},
			damage_min = {190, 250, 315, 370},
			s_damage = {150, 200, 250, 300}
		}
	},
	hero_robot = {
		distance_to_flywalk = 80,
		regen_cooldown = 1,
		speed = 45,
		shared_cooldown = 3,
		dead_lifetime = 15,
		flywalk_speed = 110,
		hp_max = {260, 279, 299, 318, 338, 357, 377, 396, 416, 435},
		armor = {0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7},
		basic_melee = {
			xp_gain_factor = 2.2,
			cooldown = 1,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {14, 15, 16, 17, 19, 22, 24, 25, 28, 31},
			damage_min = {7, 9, 10, 11, 13, 13, 14, 15, 16, 19}
		},
		jump = {
			max_range = 180,
			radius = 60,
			min_range = 0,
			damage_radius = 100,
			cooldown = {15, 14, 13, 12},
			stun_duration = {2, 2, 2, 2},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {30, 60, 90, 120},
			damage_min = {30, 60, 90, 120},
			loops = {1, 2, 3, 4},
			s_damage = {30, 60, 90, 120},
			xp_gain = {100, 200, 300, 400}
		},
		fire = {
			max_range = 180,
			min_targets = 3,
			slow_factor = 0.5,
			min_range = 0,
			damage_radius = 30,
			cooldown = {20, 20, 20},
			xp_gain = {200, 400, 600},
			damage_type = DAMAGE_TRUE,
			damage_max = {40, 80, 120},
			damage_min = {20, 40, 60},
			smoke_duration = {5, 5, 5},
			slow_duration = {1, 1, 1}
		},
		uppercut = {
			life_threshold = {25, 30, 40},
			cooldown = {32, 28, 24}
		},
		explode = {
			max_range = 90,
			min_range = 0,
			min_targets = 2,
			damage_every = 0.25,
			damage_radius = 80,
			burning_duration = 4,
			cooldown = {20, 19, 18},
			damage_max = {40, 80, 120},
			damage_min = {30, 60, 90},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {160, 320, 480},
			burning_damage_type = DAMAGE_TRUE,
			burning_damage_min = {1, 2, 3},
			burning_damage_max = {1, 2, 3}
		},
		ultimate = {
			burning_duration = 4,
			radius = 70,
			speed = 200,
			damage_every = 0.25,
			duration = 5,
			cooldown = {40, 40, 40, 40},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {60, 130, 200, 270},
			damage_min = {60, 130, 200, 270},
			s_damage = {40, 80, 160, 260},
			burning_damage_min = {1, 2, 3, 4},
			burning_damage_max = {1, 2, 3, 4},
			burning_damage_type = DAMAGE_TRUE
		}
	},
	hero_hunter = {
		distance_to_flywalk = 90,
		dead_lifetime = 15,
		flywalk_speed = 95,
		speed = 75,
		shared_cooldown = 1,
		regen_cooldown = 1,
		hp_max = {195, 213, 234, 252, 273, 291, 312, 330, 351, 364},
		armor = {0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.24, 0.26, 0.28, 0.3},
		basic_melee = {
			xp_gain_factor = 1.45,
			cooldown = 0.8,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
			damage_min = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
		},
		basic_ranged = {
			max_range = 250,
			min_range = 72,
			cooldown = 1,
			xp_gain_factor = 1.8,
			damage_type = DAMAGE_SHOT,
			damage_max = {24, 29, 35, 40, 45, 50, 56, 61, 66, 70},
			damage_min = {16, 20, 23, 27, 30, 34, 37, 41, 44, 48}
		},
		heal_strike = {
			damage_type = DAMAGE_TRUE,
			damage_max = {40, 52, 64},
			damage_min = {28, 40, 52},
			heal_factor = {0.08, 0.12, 0.16},
			xp_gain = {40, 80, 100}
		},
		ricochet = {
			bounce_range = 120,
			min_targets = 2,
			max_range_trigger = 200,
			cooldown = {15, 15, 15},
			damage_type = DAMAGE_RUDE,
			damage_max = {43, 77, 105},
			damage_min = {27, 52, 72},
			bounces = {2, 3, 4},
			xp_gain = {120, 240, 360},
			back_radius = 60
		},
		shoot_around = {
			max_range = 78,
			radius = 80,
			min_targets = 3,
			cooldown = {20, 20, 20},
			damage_type = DAMAGE_TRUE,
			damage_every = fts(3),
			damage_min = {3, 4, 5},
			damage_max = {6, 7, 8},
			s_damage_min = {44, 66, 88},
			s_damage_max = {110, 132, 154},
			slow_factor = 0.7,
			slow_duration = 2,
			duration = {3, 3.5, 4},
			xp_gain = {160, 320, 480}
		},
		beasts = {
			max_range = 100,
			attack_range = 150,
			attack_cooldown = 0.5,
			max_distance_from_owner = 250,
			chance_to_steal = 0.25,
			cooldown = {18, 18, 18},
			damage_min = {6, 12, 18},
			damage_max = {10, 20, 30},
			duration = {8, 10, 12},
			gold_to_steal = {1, 2, 3},
			damage_type = DAMAGE_RUDE,
			xp_gain = {144, 288, 432}
		},
		ultimate = {
			duration = 12,
			slow_duration = 0.5,
			distance_to_revive = 150,
			slow_factor = 0.75,
			slow_radius = 80,
			cooldown = {50, 50, 50, 50},
			damage_factor = {2, 2.5, 3, 3.5},
			entity = {
				basic_ranged = {
					max_range = 150,
					cooldown = 1,
					min_range = 0,
					damage_min = {7, 14, 19, 28},
					damage_max = {11, 19, 30, 42},
					damage_type = DAMAGE_TRUE
				}
			}
		}
	},
	hero_dragon_gem = {
		speed = 100,
		dead_lifetime = 15,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {390, 429, 468, 507, 546, 585, 624, 663, 707, 754},
		basic_ranged_shot = {
			max_range = 220,
			damage_range = 75,
			cooldown = 2,
			min_range = 50,
			xp_gain_factor = 1.45,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {21, 29, 33, 39, 44, 48, 53, 57, 63, 71},
			damage_min = {16, 19, 23, 26, 28, 32, 35, 39, 41, 45}
		},
		stun = {
			range = 180,
			min_targets = 2,
			stun_radius = 80,
			duration = {2, 3, 4},
			cooldown = {16, 16, 16},
			xp_gain = {128, 256, 384}
		},
		floor_impact = {
			damage_range = 50,
			min_targets = 3,
			max_nodes_trigger = 30,
			nodes_between_shards = 8,
			shards = 3,
			min_nodes_trigger = 0,
			cooldown = {25, 25, 25},
			xp_gain = {200, 400, 600},
			damage_type = DAMAGE_PHYSICAL,
			damage_min = {31, 62, 93},
			damage_max = {46, 93, 140}
		},
		crystal_instakill = {
			max_range = 200,
			damage_range = 100,
			hp_max = {260, 520, 1040},
			cooldown = {35, 35, 35},
			xp_gain = {280, 560, 840},
			damage_aoe_min = {41, 98, 124},
			damage_aoe_max = {41, 98, 124},
			damage_type = DAMAGE_PHYSICAL,
			s_damage = {32, 76, 96},
			explode_time = fts(27)
		},
		crystal_totem = {
			slow_duration = 1,
			min_targets = 2,
			slow_factor = 0.75,
			max_range_trigger = 160,
			aura_radius = 80,
			cooldown = {20, 20, 20},
			xp_gain = {160, 320, 480},
			duration = {6, 8, 10},
			damage_min = {10, 20, 32},
			damage_max = {10, 20, 32},
			damage_type = DAMAGE_MAGICAL,
			s_damage = {8, 16, 25},
			trigger_every = fts(30)
		},
		passive_charge = {
			distance_threshold = 250,
			shots_amount = 1,
			damage_factor = 3
		},
		ultimate = {
			damage_range = 30,
			range = 500,
			random_ni_spread = 30,
			distance_between_shards = 10,
			damage_max = {93, 140, 171, 202},
			damage_min = {62, 93, 114, 135},
			damage_type = DAMAGE_TRUE,
			cooldown = {45, 45, 45, 45},
			max_shards = {3, 4, 6, 8}
		}
	},
	hero_bird = {
		dead_lifetime = 15,
		speed = 120,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {364, 390, 416, 442, 468, 494, 520, 546, 572, 598},
		basic_attack = {
			max_range = 200,
			xp_gain_factor = 1.7,
			cooldown = 1.5,
			min_range = 0,
			damage_radius = 75,
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {18, 20, 23, 25, 27, 29, 32, 34, 37, 38},
			damage_min = {12, 14, 15, 17, 18, 20, 21, 23, 24, 26}
		},
		cluster_bomb = {
			max_range = 220,
			min_targets = 2,
			min_range = 100,
			first_explosion_height = 150,
			fire_radius = 50,
			explosion_damage_radius = 75,
			cooldown = {20, 20, 20},
			xp_gain = {160, 320, 480},
			explosion_damage_type = DAMAGE_EXPLOSION,
			explosion_damage_min = {16, 24, 36},
			explosion_damage_max = {16, 24, 36},
			fire_duration = {3, 6, 9},
			burning = {
				cycle_time = 0.25,
				duration = 3,
				damage = {1, 1, 1},
				damage_type = DAMAGE_TRUE
			}
		},
		shout_stun = {
			radius = 100,
			min_targets = 2,
			slow_factor = 0.5,
			cooldown = {20, 18, 16},
			xp_gain = {160, 288, 384},
			stun_duration = {1, 1.5, 2},
			slow_duration = {3, 4, 6}
		},
		gattling = {
			max_range = 180,
			min_range = 80,
			cooldown = {12, 12, 12},
			xp_gain = {96, 192, 288},
			duration = {3, 3, 3},
			damage_min = {1, 3, 4},
			damage_max = {3, 5, 6},
			damage_type = DAMAGE_SHOT,
			shoot_every = fts(4),
			s_damage_min = {21, 63, 84},
			s_damage_max = {63, 105, 126}
		},
		eat_instakill = {
			max_range = 50,
			min_range = 0,
			cooldown = {25, 22, 20},
			xp_gain = {200, 352, 480},
			hp_max = {520, 1040, 1560}
		},
		ultimate = {
			cooldown = {28, 28, 28, 28},
			bird = {
				chase_range = 250,
				target_range = 180,
				duration = {8, 10, 12, 15},
				melee_attack = {
					range = 15,
					cooldown = 0.1,
					damage_max = {16, 25, 36, 50},
					damage_min = {16, 25, 36, 50},
					damage_type = DAMAGE_TRUE
				}
			}
		}
	},
	hero_lava = {
		dead_lifetime = 15,
		speed = 55,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {292, 305, 318, 331, 344, 357, 370, 383, 396, 409},
		melee_damage_max = {15, 17, 18, 20, 21, 23, 24, 26, 28, 32},
		melee_damage_min = {10, 11, 12, 13, 14, 15, 16, 17, 18, 20},
		basic_melee = {
			cooldown = 1.25,
			xp_gain_factor = 1.8
		},
		temper_tantrum = {
			stun_duration = 2,
			cooldown = {15, 15, 15},
			duration = {2, 2, 2},
			s_damage_min = {56, 105, 162},
			s_damage_max = {84, 156, 240},
			damage_min = {19, 35, 54},
			damage_max = {28, 52, 80},
			damage_type = DAMAGE_PHYSICAL,
			xp_gain = {120, 240, 360}
		},
		hotheaded = {
			range = 180,
			cooldown = {5, 5, 5},
			damage_factors = {1.2, 1.3, 1.4},
			durations = {6, 6, 6},
			xp_gain = {2560, 3600, 4640}
		},
		double_trouble = {
			max_range = 150,
			min_range = 100,
			damage_radius = 70,
			cooldown = {20, 20, 20},
			s_damage = {30, 50, 75},
			damage_min = {30, 50, 75},
			damage_max = {30, 50, 75},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {160, 320, 480},
			soldier = {
				armor = 0,
				max_speed = 36,
				cooldown = 1,
				duration = 10,
				hp_max = {97, 130, 162},
				damage_min = {10, 13, 16},
				damage_max = {14, 19, 24}
			}
		},
		death_aura = {
			damage_min = 5,
			damage_radius = 70,
			cycle_time = 0.25,
			damage_max = 7,
			damage_type = DAMAGE_TRUE
		},
		wild_eruption = {
			max_range_effect = 100,
			radius = 90,
			min_targets = 3,
			damage_every = 0.25,
			max_range_trigger = 60,
			loop_duration = 1.5,
			cooldown = {30, 30, 30},
			duration = {4, 4, 4},
			damage_min = {10, 12, 15},
			damage_max = {10, 12, 15},
			s_damage = {40, 48, 60},
			damage_type = DAMAGE_TRUE,
			xp_gain = {240, 480, 720}
		},
		ultimate = {
			max_spread = 30,
			cooldown = {48, 48, 48, 48},
			fireball_count = {3, 4, 5, 6},
			bullet = {
				damage_radius = 60,
				s_damage = {40, 80, 130, 200},
				damage_min = {40, 80, 130, 200},
				damage_max = {40, 80, 130, 200},
				damage_type = DAMAGE_TRUE,
				scorch = {
					duration = 4,
					damage_radius = 60,
					cycle_time = 0.25,
					damage_min = {1, 1, 1, 1},
					damage_max = {1, 1, 1, 1},
					damage_type = DAMAGE_TRUE
				}
			}
		},
		ultimate_combo = {
			max_targets = 12,
			max_radius = 400,
			min_radius = 100
		}
	},
	hero_witch = {
		dead_lifetime = 15,
		speed = 180,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {169, 188, 208, 227, 247, 266, 288, 305, 325, 344},
		melee_damage_max = {13, 14, 16, 18, 19, 22, 23, 24, 27, 28},
		melee_damage_min = {9, 10, 10, 11, 13, 14, 15, 16, 18, 19},
		ranged_damage_max = {14, 15, 17, 19, 20, 24, 25, 26, 29, 30},
		ranged_damage_min = {10, 11, 11, 12, 14, 15, 16, 18, 19, 20},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2.2
		},
		ranged_attack = {
			max_range = 200,
			xp_gain_factor = 1.7,
			cooldown = 1.5,
			min_range = 50,
			damage_type = DAMAGE_MAGICAL_EXPLOSION
		},
		skill_soldiers = {
			min_targets = 2,
			max_range = 180,
			cooldown = {17.5, 17.5, 17.5},
			xp_gain = {144, 288, 432},
			soldiers_amount = {2, 3, 4},
			soldier = {
				max_speed = 60,
				armor = 0,
				duration = 8,
				hp_max = {60, 85, 110},
				melee_attack = {
					cooldown = 1,
					range = 100,
					damage_min = {2, 5, 7},
					damage_max = {3, 7, 11},
					damage_type = DAMAGE_PHYSICAL
				}
			}
		},
		skill_polymorph = {
			range = 200,
			max_nodes_to_goal = 50,
			cooldown = {20, 20, 20},
			hp_max = {1000, 2000, 3000},
			duration = {8, 8, 8},
			xp_gain = {160, 320, 480},
			pumpkin = {
				speed = 20,
				armor = 0,
				magic_armor = 0,
				hp = {0.7, 0.55, 0.4}
			}
		},
		skill_path_aoe = {
			max_range = 180,
			min_targets = 1,
			slow_factor = 0.5,
			min_range = 75,
			node_prediction = 30,
			cooldown = {16, 16, 16},
			duration = {5, 6, 8},
			xp_gain = {128, 256, 384},
			damage_min = {65, 104, 156},
			damage_max = {65, 104, 156},
			s_damage = {50, 80, 120},
			damage_type = DAMAGE_MAGICAL_EXPLOSION
		},
		disengage = {
			min_distance_from_end = 270,
			distance = 130,
			hp_to_trigger = 0.4,
			cooldown = {12, 12, 12},
			xp_gain = {160, 320, 480},
			decoy = {
				max_speed = 60,
				armor = 0,
				duration = 8,
				hp_max = {65, 97, 130},
				melee_attack = {
					cooldown = 1,
					range = 80,
					damage_min = {10, 15, 20},
					damage_max = {15, 23, 31}
				},
				explotion = {
					radius = 45,
					stun_duration = {2, 2.5, 3}
				}
			}
		},
		ultimate = {
			radius = 100,
			nodes_teleport = 50,
			nodes_limit = 20,
			cooldown = {27, 27, 27, 27},
			duration = {3, 4, 5, 6},
			max_targets = {4, 6, 8, 10}
		}
	},
	hero_dragon_bone = {
		dead_lifetime = 15,
		speed = 130,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {409, 442, 474, 507, 539, 572, 604, 637, 669, 702},
		basic_attack = {
			max_range = 220,
			radius = 60,
			cooldown = 2,
			min_range = 0,
			xp_gain_factor = 1.4,
			damage_type = DAMAGE_TRUE,
			damage_max = {22, 26, 31, 35, 39, 44, 48, 52, 57, 59},
			damage_min = {14, 16, 20, 23, 26, 28, 32, 35, 37, 41}
		},
		plague = {
			damage_min = 1,
			every = 0.25,
			duration = 4,
			damage_max = 1,
			damage_type = DAMAGE_TRUE,
			explotion = {
				damage_radius = 60,
				damage_min = 15,
				damage_max = 30,
				damage_type = DAMAGE_EXPLOSION
			}
		},
		cloud = {
			max_range = 225,
			radius = 100,
			min_targets = 3,
			slow_factor = 0.5,
			min_range = 50,
			cooldown = {15, 15, 15},
			duration = {4, 6, 10},
			xp_gain = {120, 240, 360}
		},
		nova = {
			max_range = 75,
			min_targets = 3,
			min_range = 0,
			damage_radius = 75,
			cooldown = {24, 24, 24},
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {52, 153, 202},
			damage_min = {26, 80, 109},
			xp_gain = {192, 384, 576}
		},
		rain = {
			max_range = 200,
			min_targets = 3,
			min_range = 50,
			stun_time = 0.25,
			cooldown = {20, 20, 20},
			damage_max = {23, 46, 70},
			damage_min = {15, 31, 46},
			damage_type = DAMAGE_TRUE,
			bones_count = {4, 6, 8},
			xp_gain = {160, 320, 400}
		},
		burst = {
			max_range = 300,
			min_targets = 5,
			min_range = 0,
			cooldown = {32, 32, 32},
			damage_max = {46, 112, 169},
			damage_min = {31, 75, 112},
			damage_type = DAMAGE_TRUE,
			proj_count = {6, 8, 10},
			xp_gain = {240, 480, 720}
		},
		ultimate = {
			cooldown = {36, 36, 36, 36},
			dog = {
				speed = 95,
				armor = 0,
				cooldown = 1,
				duration = {10, 15, 20, 25},
				hp = {130, 156, 195, 234},
				melee_attack = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {18, 22, 28, 40},
					damage_min = {13, 14, 18, 27}
				}
			}
		}
	},
	hero_dragon_arb = {
		dead_lifetime = 15,
		speed = 130,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		magic_armor = {0.03, 0.06, 0.09, 0.12, 0.15, 0.18, 0.21, 0.24, 0.27, 0.3},
		hp_max = {254, 286, 318, 351, 384, 416, 448, 481, 514, 546},
		passive_plant_zones = {
			zone_duration = 25,
			radius = 15,
			expansion_cooldown = 0.3,
			slow_factor = 0.5
		},
		basic_breath_attack = {
			max_range = 300,
			xp_gain_factor = 1.82,
			cooldown = 1.75,
			min_range = 10,
			damage_type = DAMAGE_MAGICAL,
			damage_max = {16, 20, 25, 29, 35, 39, 44, 48, 53, 58},
			damage_min = {11, 14, 16, 19, 23, 26, 29, 31, 35, 38}
		},
		arborean_spawn = {
			max_range = 10000,
			spawn_max_range_to_enemy = 200,
			min_targets = 2,
			min_range = 0,
			max_targets = 3,
			cooldown = {35, 35, 35},
			xp_gain = {280, 560, 840},
			arborean = {
				speed = 30,
				armor = 0,
				magic_armor = 0,
				hp = {104, 143, 182},
				duration = {10, 12, 14},
				basic_attack = {
					cooldown = 2,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {4, 6, 8},
					damage_min = {2, 3, 5}
				}
			},
			paragon = {
				speed = 40,
				armor = 0,
				magic_armor = 0,
				hp = {156, 208, 260},
				duration = {10, 12, 14},
				basic_attack = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {12, 16, 20},
					damage_min = {8, 12, 16}
				}
			}
		},
		tower_runes = {
			max_range = 300,
			min_range = 0,
			cooldown = {35, 35, 35},
			xp_gain = {280, 560, 840},
			max_targets = {3, 3, 3},
			duration = {6, 7, 8},
			damage_factor = {1.3, 1.45, 1.6},
			s_damage_factor = {0.3, 0.45, 0.6}
		},
		thorn_bleed = {
			damage_every = 0.75,
			damage_type = DAMAGE_MAGICAL,
			xp_gain = {280, 560, 840},
			damage_speed_ratio = {0.375, 0.564, 0.825},
			cooldown = {12, 10, 8},
			instakill_chance = {0.3, 0.3, 0.3},
			duration = {5, 5, 5}
		},
		tower_plants = {
			max_range = 300,
			min_range = 0,
			cooldown = {20, 20, 20},
			xp_gain = {280, 560, 840},
			max_targets = {1, 2, 3},
			duration = {8, 10, 12},
			linirea = {
				cooldown_min = 0.5,
				range = 240,
				heal_every = 0.2,
				heal_duration = 1.5,
				cooldown_max = 0.5,
				heal_max = {15, 15, 15},
				heal_min = {15, 15, 15}
			},
			dark_army = {
				cooldown_min = 2,
				range = 120,
				damage_every = 0.25,
				cooldown_max = 2,
				slow_factor = {0.5, 0.4, 0.3},
				damage_type = DAMAGE_MAGICAL,
				damage_min = {5, 7, 9},
				damage_max = {5, 7, 9}
			}
		},
		ultimate = {
			duration = {8, 10, 13, 15},
			cooldown = {36, 36, 36, 36},
			extra_armor = {0.3, 0.4, 0.5, 0.6},
			extra_magic_armor = {0.3, 0.4, 0.5, 0.6},
			speed_factor = {1.3, 1.4, 1.5, 1.6},
			inflicted_damage_factor = {1.3, 1.4, 1.5, 1.6},
			s_bonuses = {0.3, 0.4, 0.5, 0.6}
		}
	},
	hero_spider = {
		dead_lifetime = 15,
		tp_delay = 0.4,
		speed = 90,
		tp_duration = 0.35,
		teleport_min_distance = 180,
		shared_cooldown = 3,
		regen_cooldown = 1,
		armor = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1},
		magic_armor = {0.34, 0.38, 0.42, 0.46, 0.5, 0.54, 0.58, 0.62, 0.66, 0.7},
		hp_max = {245, 259, 273, 286, 300, 313, 327, 341, 354, 368},
		basic_melee = {
			xp_gain_factor = 2.36,
			cooldown = 1,
			damage_max = {12, 14, 16, 18, 20, 23, 25, 27, 29, 33},
			damage_min = {10, 11, 13, 15, 17, 18, 20, 23, 24, 26},
			damage_type = DAMAGE_PHYSICAL,
			dot = {
				poison_mod_duration = 1.5,
				poison_damage_every = 0.25,
				poison_radius = 80,
				poison_damage_min = {2, 2, 2, 3, 3, 3, 4, 4, 4, 5},
				poison_damage_max = {2, 2, 2, 3, 3, 3, 4, 4, 4, 5},
				damage_type = DAMAGE_POISON
			}
		},
		basic_ranged = {
			max_range = 160,
			xp_gain_factor = 1.5,
			cooldown = 1.5,
			min_range = 68,
			damage_max = {22, 24, 27, 30, 34, 37, 40, 44, 48, 52},
			damage_min = {12, 13, 15, 16, 18, 19, 22, 24, 26, 28},
			damage_type = DAMAGE_MAGICAL
		},
		instakill_melee = {
			life_threshold = {1000, 1500, 2000},
			cooldown = {5, 4, 3},
			xp_gain = {160, 320, 480},
			heal_factor = 0.4
		},
		area_attack = {
			min_targets = 2,
			damage_radius = 85,
			cooldown = {18, 16, 14},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {50, 75, 100},
			damage_min = {25, 50, 75},
			s_damage = {0, 0, 0},
			stun_time = {90, 120, 150},
			s_stun_time = {3, 4, 5},
			xp_gain = {144, 272, 384}
		},
		tunneling = {
			min_targets = 1,
			damage_radius = 85,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {40, 70, 100},
			damage_min = {30, 45, 60},
			stun_duration = 0.35,
			s_damage = {36, 54, 84},
			xp_gain = {56, 56, 56}
		},
		supreme_hunter = {
			min_targets = 1,
			cooldown = {25, 25, 25},
			damage_type = DAMAGE_RUDE,
			damage_max = {168, 336, 504},
			damage_min = {112, 224, 336},
			dot_damage_min = {8, 12, 16},
			dot_damage_max = {8, 12, 16},
			dot_damage_type = DAMAGE_POISON,
			damage_every = 0.25,
			s_damage = {50, 80, 115},
			xp_gain = {200, 400, 600}
		},
		ultimate = {
			cooldown = {28, 28, 28, 28},
			spawn_amount = {2, 3, 4, 5},
			spider = {
				speed = 95,
				armor = 0,
				stun_duration = 3,
				cooldown = 1,
				stun_chance = 0.15,
				duration = {5, 7, 8, 10},
				hp = {150, 150, 150, 150},
				melee_attack = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {12, 12, 12, 12},
					damage_min = {8, 8, 8, 8}
				}
			}
		}
	},
	hero_dragon_sun = {
		dead_lifetime = 15,
		speed = 190,
		regen_cooldown = 1,
		armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		hp_max = {273, 292, 312, 331, 351, 370, 390, 409, 435, 461},
		basic_attack = {
			max_range = 220,
			xp_gain_factor = 1.4,
			cooldown = 2,
			min_range = 0,
			speed = 100,
			damage_radius = 45,
			damage_every = 0.25,
			damage_type = DAMAGE_TRUE,
			damage_max = {8, 10, 12, 14, 16, 18, 20, 22, 24, 26},
			damage_min = {6, 8, 10, 11, 13, 15, 17, 18, 20, 23},
			flier = {
				xp_gain_factor = 1.4,
				damage_type = DAMAGE_TRUE,
				damage_max = {20, 25, 33, 40, 45, 53, 58, 65, 75, 85},
				damage_min = {13, 18, 23, 25, 30, 35, 40, 43, 48, 55}
			},
			burn_dot = {
				damage_every = 0.3,
				duration = 2,
				damage_type = DAMAGE_TRUE,
				damage_max = {2, 2, 3, 3, 4, 4, 5, 5, 6, 7},
				damage_min = {1, 2, 2, 3, 3, 4, 4, 5, 5, 5}
			}
		},
		worthy_foe = {
			enemy_minimum_hp = 500,
			cooldown = {40, 36, 32},
			damages_target = {
				damage_max = {300, 540, 720},
				damage_min = {200, 360, 400},
				damage_type = DAMAGE_TRUE
			},
			damages_radius = {
				radius = 70,
				damage_max = {30, 40, 50},
				damage_min = {20, 30, 40},
				damage_type = DAMAGE_TRUE
			},
			xp_gain = {200, 400, 600}
		},
		solar_cleansing = {
			radius = 100,
			heal_every = 0.25,
			trigger_requirements = {
				hero_health_threshold = 0.5,
				allies_health_threshold = 0.4,
				ally_count_needed = 3,
				cooldown = {35, 35, 35}
			},
			duration = {6, 6, 6},
			heal = {5, 10, 15},
			xp_gain = {200, 400, 600}
		},
		overcharge = {
			cooldown = {6, 6, 6},
			damage_max = {100, 200, 300},
			damage_min = {75, 150, 225},
			flier = {
				damage_max = {200, 350, 500},
				damage_min = {150, 200, 400}
			}
		},
		solar_stones = {
			max_range = 105,
			min_dist_between_mines = 30,
			mines_duration = 90,
			min_range = 60,
			time_to_activate = 3,
			damage_radius = 50,
			no_targets_cooldown = 6,
			cooldown = {10, 10, 10},
			damage_max = {70, 120, 190},
			damage_min = {50, 90, 130},
			damage_type = DAMAGE_TRUE,
			xp_gain = {200, 400, 600},
			max_mines = {3, 4, 5}
		},
		ultimate = {
			damage_every = 0.1,
			initial_damage_factor = 1.2,
			final_damage_factor = 0.8,
			speed = 70,
			damage_radius = 80,
			duration = 3,
			cooldown = {62, 62, 62, 62},
			damage_max = {10, 20, 30, 40},
			damage_min = {6, 12, 18, 24},
			damage_type = DAMAGE_TRUE
		}
	}
}
local towers = {}
local specials = {
	trees = {
		guardian_tree = {
			max_range = 450,
			cooldown_min = 16,
			sep_nodes_min = 4,
			immune_for_seconds = 3,
			effect_duration = 4,
			cooldown_max = 16,
			min_range = 15,
			roots_count = 14,
			show_delay_max = 0.04,
			show_delay_min = 0.04,
			disabled = false,
			sep_nodes_max = 5,
			wave_config = {true, true, true, true, true, true, true, true}
		},
		heart_of_the_arborean = {
			max_range = 1400,
			cooldown_min = 90,
			min_targets = 10,
			damage_radius = 80,
			min_dist_between_tgts = 130,
			cooldown_max = 90,
			damage_max = 40,
			damage_min = 30,
			max_targets = 10,
			damage_type = DAMAGE_TRUE,
			wait_between_shots = fts(2)
		},
		blocked_holders = {
			price = 60
		}
	},
	terrain_2 = {
		blocked_holders = {
			price = 100
		}
	},
	terrain_3 = {
		blocked_holders = {
			price = 150
		}
	},
	terrain_6 = {
		blocked_holders = {
			price = 150
		}
	},
	terrain_7 = {
		spider_floor_webs = {
			sprint_factor = 1.7,
			slow_factor = 0.3
		}
	},
	terrain_8 = {
		flaming_ground = {
			dps = {
				duration = 0.25,
				damage_min = 2,
				damage_every = 0.25,
				damage_max = 2,
				damage_type = DAMAGE_PHYSICAL
			},
			sprint = {
				sprint_factor = 1.7,
				duration = 1
			},
			healing = {
				heal_every = 0.25,
				heal_duration = 1,
				heal_max = 30,
				heal_min = 10
			}
		},
		elemental_holders = {
			wooden_holder = {
				range_factor = 1.25,
				first_cooldown = 2,
				duration = 8,
				slow_factor = 0.5,
				cooldown = 50,
				default_max_range = 200,
				damage_max = 5,
				skill_detection_range_factor = 0.8,
				rally_range_factor = 1.25,
				damage_min = 3,
				damage_every = 0.25,
				price = 150,
				damage_type = DAMAGE_TRUE
			},
			wooden_holder_enhance = {
				range_factor = 2,
				first_cooldown = 999999,
				duration = 8,
				slow_factor = 0.5,
				cooldown = 999999,
				default_max_range = 200,
				damage_max = 5,
				skill_detection_range_factor = 0.8,
				rally_range_factor = 2,
				damage_min = 3,
				damage_every = 0.25,
				price = 150,
				damage_type = DAMAGE_TRUE
			},
			fire_holder = {
				price = 150,
				first_cooldown = 2,
				cooldown = 52,
				default_max_range = 200,
				damage_factor = 1.25
			},
			water_holder = {
				default_max_range = 200,
				price = 150,
				healing = {
					min_health_factor = 0.8,
					heal_min = 5,
					heal_every = 1,
					duration = 1,
					heal_max = 6
				},
				teleport = {
					tp_distance_nodes_max = 55,
					first_cooldown = 2,
					tp_distance_nodes_min = 20,
					tp_radius = 50,
					cooldown = 20,
					delay_between_tps = 2,
					chase_speed = 40,
					tp_max_targets = 5,
					duration = 9,
					wander_interval = 1.5
				}
			},
			earth_holder = {
				max_spawns = 3,
				first_cooldown = 2,
				extra_health_multiplier = 1.25,
				cooldown = 30,
				price = 150,
				spawn_amount = 1,
				soldier = {
					armor = 0.3,
					max_speed = 24,
					hp_max = 68,
					melee_attack = {
						cooldown = 3,
						range = 50,
						damage_min = 18,
						damage_max = 30
					}
				},
				holder_spawn_pos = {
					["22"] = {{
						x = 282,
						y = 361
					}},
					["23"] = {{
						x = 85,
						y = 361
					}},
					["25"] = {{
						x = 109,
						y = 433
					}},
					["26"] = {{
						x = 367,
						y = 515
					}},
					["29"] = {{
						x = 770,
						y = 515
					}}
				},
				default_max_range = 200
			},
			metal_holder = {
				first_cooldown = 0,
				cooldown = 15,
				default_max_range = 200,
				price = 150,
				upgrade_price_multiplier = 0.75,
				steal_gold = {
					delay_between_steals = 2,
					first_cooldown = 2,
					gold_steal_group_max_size = 3,
					cooldown = 18,
					steal_radius = 50,
					chase_speed = 40,
					gold_steal_amount_boss = 50,
					gold_steal_amount = 1,
					duration = 9,
					wander_interval = 1.5
				}
			}
		}
	},
	stage07_temple = {
		activation_wave = 10
	},
	stage08_elf_rescue = {
		spawn_cooldown = 90,
		elf = {
			cooldown_min = 1.2,
			range = 202,
			damage_min = 36,
			stun_duration = 24,
			cooldown_max = 1.6,
			damage_max = 54,
			damage_type = DAMAGE_PHYSICAL
		}
	},
	stage09_spawn_nightmares = {
		path_portal_off_delay = 10,
		wave_config = {{
			{},
			{},
			{{
				duration = 28,
				time_start = 10
			}},
			{{
				duration = 28,
				time_start = 10
			}},
			{},
			{},
			{{
				duration = 30,
				time_start = 10
			}},
			{},
			{{
				duration = 30,
				time_start = 10
			}},
			{},
			{{
				duration = 52,
				time_start = 10
			}},
			{{
				duration = 40,
				time_start = 10
			}},
			{},
			{{
				duration = 40,
				time_start = 12
			}},
			{{
				duration = 70,
				time_start = 10
			}}
		}, {{}, {}, {}, {{
			duration = 70,
			time_start = 20
		}}, {}, {{
			duration = 107,
			time_start = 21
		}}}, {{{
			duration = 110,
			time_start = 74
		}, {
			duration = 330,
			time_start = 310
		}}}}
	},
	stage10_obelisk = {
		mode_first_delay = 1,
		min_enemies = 2,
		start_delay = {20, 0, 30},
		per_wave_config_campaign = {
			{
				delay = 30,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 30,
				mode = "heal",
				duration = 12
			},
			{
				delay = 8,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 1,
				mode = "sacrifice"
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 1,
				mode = "sacrifice"
			},
			{
				delay = 25,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 10,
				mode = "sacrifice"
			}
		},
		per_wave_config_heroic = {{
			delay = 30,
			mode = "heal",
			duration = 10
		}, {
			delay = 48,
			mode = "heal",
			duration = 10
		}, {
			delay = 20,
			mode = "heal",
			duration = 10
		}, {
			delay = 45,
			mode = "heal",
			duration = 10
		}, {
			delay = 30,
			mode = "heal",
			duration = 10
		}, {
			delay = 120,
			mode = "heal",
			duration = 10
		}},
		iron_config = {
			golem_activate_delay = {50, 190, 270, 350, 370}
		},
		stun = {
			cooldown = 26,
			stun_duration = 3
		},
		heal = {
			heal_duration = 10,
			cooldown = 50,
			heal_min = 1,
			heal_every = 0.25,
			heal_max = 3
		},
		teleport = {
			max_targets = 4,
			nodes_advance = 25,
			aura_radius = 100,
			nodes_limit = 30,
			cooldown = 5,
			nodes_from_selectable = 30,
			nodes_to_goal_selectable = 80
		},
		sacrifice = {
			inactive_time = 20,
			waves = {5, 10, 15}
		}
	},
	stage10_ymca = {
		soldier = {
			armor = 0,
			hp = 100,
			max_speed = 90,
			melee_attack = {
				cooldown = 1,
				damage_min = 6,
				damage_max = 12
			}
		}
	},
	stage11_cult_leader = {
		deck_chain_ability = 1,
		ability_cooldown_bossfight = 30,
		ability_first_delay = 30,
		stun_time = 15,
		ability_cooldown = 90,
		deck_total_cards = 2,
		illusion = {
			max_speed = 20,
			hp_max = 150,
			magic_armor = 0,
			armor = 0,
			spawn_charge_time = 5,
			nodes_limit = 20,
			melee_attack = {
				cooldown = 1,
				damage_min = 5,
				damage_max = 5
			},
			ranged_attack = {
				max_range = 100,
				damage_max = 24,
				damage_min = 16,
				cooldown = 1.5,
				min_range = 10,
				damage_type = DAMAGE_MAGICAL
			},
			chain = {
				max_range = 160,
				duration = 12,
				cooldown = 1
			},
			shield = {
				duration = 12,
				radius = 80
			}
		},
		config_per_wave = {
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 3
			},
			{
				illusions = 3
			}
		}
	},
	stage11_portal = {
		waves_campaign = {
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			13,
			14,
			15
		},
		waves_heroic = {2, 3, 4, 5, 6},
		waves_iron = {1}
	},
	stage11_veznan = {
		cooldown = 12,
		skill_soldiers = {
			soldier = {
				armor = 0,
				regen_health = 8,
				max_speed = 30,
				hp_max = 200,
				nodes_from_start = 20,
				melee_attack = {
					damage_min = 24,
					range = 50,
					damage_max = 40
				}
			}
		},
		skill_cage = {
			duration = 5
		}
	},
	stage14_amalgam = {
		sacrifices_to_show_2 = 2,
		sacrifices_to_show_1 = 1,
		sacrifices_to_spawn = 5
	},
	stage15_denas = {
		damage_max = 49,
		spawn_stun_radius = 50,
		hp_max = 600,
		cooldown = 30,
		regen_health = 15,
		attack_cooldown = 2,
		damage_special_max = 500,
		attack_cooldown_special = 8,
		duration = 20,
		range = 72,
		magic_armor = 0.5,
		speed = 60,
		armor = 0.5,
		damage_min = 30,
		damage_special_min = 400,
		damage_type = DAMAGE_TRUE
	},
	stage15_cult_leader_tower = {
		aura_duration = 7.5,
		aura_time_before_stun = 5,
		aura_radius = 40,
		config_per_wave = {
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 40
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 25
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			}
		}
	},
	stage16_overseer = {
		hp = 40000,
		first_time_cooldown = 5,
		phase_per_hp_threshold = {100, 90, 80, 70, 50, 20},
		phase_per_time = {30, 75, 90, 120, 100000000},
		change_tower_cooldown = {nil, 60, 60, 45, 30},
		glare_cooldown = {nil, nil, nil, 36, 33, 30},
		glare_duration = {nil, nil, nil, 4, 5, 6},
		heal_cooldown = {nil, nil, nil, 30, 30, 15},
		heal_duration = {nil, nil, nil, 6, 8, 10},
		heal_per_second = {nil, nil, nil, 150, 450, 200},
		change_tower_amount = {nil, 1, 1, 2, 3},
		destroy_holder = {
			cooldown = {nil, nil, nil, nil, nil, 20}
		},
		downgrade_cooldown = {nil, nil, 60, 55, 45, 40},
		downgrade_count = {nil, nil, 1, 2, 2, 2},
		tentacle_spawns_per_phase = {0, 0, 3, 3, 4, 5},
		tentacle_left = {
			cooldown = {nil, nil, nil, 40, 30, 20},
			cooldown_attack_soldiers = {nil, nil, nil, nil, 35, 25}
		},
		tentacle_right = {
			cooldown = {nil, nil, 45, 45, 35, 25},
			cooldown_attack_soldiers = {nil, nil, nil, 40, 30, 20}
		},
		tentacle_bullet_explosion_damage = {
			damage_max = 180,
			range = 70,
			damage_min = 120,
			damage_type = DAMAGE_PHYSICAL
		},
		glare1 = {{-1, 0}, {-1, 0}, {-1, 0}, {6, 30}, {6, 20}, {60, 30}},
		glare2 = {{-1, 0}, {8, 25}, {6, 30}, {-1, 0}, {-1, 0}, {6, 30}},
		slow = {
			factor = 0.5,
			duration = 12
		},
		slow_cooldown = {nil, 50, 50, 45, 40, 35},
		slow_count = {nil, 1, 2, 3, 3, 2}
	},
	stage18_eridan = {
		ranged_attack = {
			range = 380,
			damage_min = 18,
			cooldown = 4,
			damage_max = 30,
			damage_type = DAMAGE_PHYSICAL
		},
		instakill = {
			hp_threshold = 700,
			range = 250,
			cooldown = 18,
			damage_type = DAMAGE_INSTAKILL
		}
	},
	stage19_mausoleum = {
		path_portal_off_delay = 10,
		wave_config = {{
			{},
			{},
			{},
			{{
				duration = 60,
				time_start = 2
			}},
			{},
			{{
				duration = 42,
				time_start = 2
			}},
			{},
			{{
				duration = 50,
				time_start = 2
			}},
			{{
				duration = 55,
				time_start = 2
			}},
			{},
			{{
				duration = 30,
				time_start = 2
			}},
			{},
			{},
			{{
				duration = 68,
				time_start = 2
			}},
			{{
				duration = 75,
				time_start = 2
			}}
		}, {{}, {{
			duration = 55,
			time_start = 2
		}}, {{
			duration = 27,
			time_start = 2
		}}, {{
			duration = 56,
			time_start = 2
		}}, {}, {{
			duration = 75,
			time_start = 2
		}}}, {{{
			duration = 325,
			time_start = 2
		}}}}
	},
	stage20_arborean_house = {
		armor = 0.3,
		magic_armor = 0,
		hp_max = 280
	},
	stage21_falling_rocks = {
		damage_radius = 60,
		damage = 2000,
		damage_type = DAMAGE_PHYSICAL
	},
	stage22_remolino = {{
		[3] = {{28, 41}},
		[4] = {{35, 48}, {67, 80}},
		[6] = {{12, 25}, {32, 45}},
		[7] = {{25, 95}},
		[9] = {{15, 24}, {75, 84}},
		[10] = {{5, 52}},
		[12] = {{12, 21}, {42, 51}},
		[13] = {{5, 48}},
		[14] = {{5, 20}, {70, 85}},
		[15] = {{8, 18}, {48, 58}},
		BOSS = {{31, 480}}
	}, {
		[2] = {{19.5, 27.5}, {43, 51.5}},
		[3] = {{0.2, 4}},
		[4] = {{27, 90}},
		[5] = {{14, 24}},
		[6] = {{0, 5}, {25, 63}}
	}, {{{115, 319}}}},
	stage22_tower_destroyed = {
		repair_cost = 220
	},
	stage23_roboboots = {
		wave_config = {{
			{},
			{{
				leg = 2,
				timings = {{0}}
			}},
			{{
				leg = 2,
				timings = {{nil, 1}}
			}},
			{},
			{{
				leg = 1,
				timings = {{10}}
			}},
			{{
				leg = 1,
				timings = {{nil, 7}}
			}, {
				leg = 2,
				timings = {{17}}
			}},
			{{
				leg = 2,
				timings = {{nil, 8}}
			}},
			{},
			{{
				leg = 1,
				timings = {{1}}
			}},
			{{
				leg = 1,
				timings = {{nil, 8}}
			}, {
				leg = 2,
				timings = {{1}}
			}},
			{{
				leg = 1,
				timings = {{5, 25}}
			}, {
				leg = 2,
				timings = {{nil, 10}}
			}},
			{},
			{{
				leg = 2,
				timings = {{1}}
			}},
			{{
				leg = 2,
				timings = {{nil, 5}}
			}},
			{{
				leg = 1,
				timings = {{10, 76}}
			}, {
				leg = 2,
				timings = {{1, 72}}
			}}
		}, {{}, {}, {{
			leg = 1,
			timings = {{1}}
		}}, {{
			leg = 1,
			timings = {{nil, 6}}
		}, {
			leg = 2,
			timings = {{1}}
		}}, {{
			leg = 2,
			timings = {{nil, 6}}
		}}, {{
			leg = 1,
			timings = {{20, 46}}
		}, {
			leg = 2,
			timings = {{13, 72}}
		}}}, {{{
			leg = 1,
			timings = {{2, 45}, {114, 163}, {200, 230}, {295, 340}, {345, 370}}
		}, {
			leg = 2,
			timings = {{170, 205}, {280, 345}}
		}}}}
	},
	stage24_factory = {
		wave_config = {{
			{},
			{},
			{},
			{},
			{},
			{},
			{{
				duration = 40,
				time_start = 10
			}},
			{},
			{{
				duration = 40,
				time_start = 10
			}},
			{},
			{{
				duration = 40,
				time_start = 8
			}},
			{},
			{{
				duration = 40,
				time_start = 12
			}},
			{},
			{{
				duration = 40,
				time_start = 15
			}}
		}, {{}, {}, {}, {}, {}, {}}, {{}}}
	},
	stage24_upgrade_station = {
		wave_config = {{
			{},
			{},
			{},
			{},
			{{
				duration = 60,
				time_start = 1
			}},
			{},
			{},
			{{
				duration = 60,
				time_start = 10
			}},
			{},
			{},
			{},
			{{
				duration = 50,
				time_start = 1
			}},
			{},
			{{
				duration = 45,
				time_start = 1
			}},
			{}
		}, {{}, {{
			duration = 55,
			time_start = 2
		}}, {}, {}, {{
			duration = 56,
			time_start = 2
		}}, {}}, {{{
			duration = 560,
			time_start = 2
		}}}}
	},
	stage25_torso = {
		fist = {
			radius = 140
		},
		missile = {
			repair_cost = 50,
			max_duration = 30
		},
		wave_config = {{
			{},
			{},
			{},
			{},
			{},
			{},
			{},
			{{
				action = "open",
				time_start = 8
			}, {
				action = "fist",
				time_start = 13
			}, {
				action = "close",
				time_start = 23
			}},
			{{
				action = "open",
				time_start = 13
			}, {
				action = "missile",
				time_start = 18
			}, {
				action = "close",
				time_start = 28
			}},
			{},
			{{
				action = "open",
				time_start = 2
			}, {
				action = "fist",
				time_start = 8
			}, {
				action = "fist",
				time_start = 16
			}},
			{{
				action = "missile",
				time_start = 12
			}, {
				action = "missile",
				time_start = 22
			}},
			{{
				action = "fist",
				time_start = 10
			}, {
				action = "fist",
				time_start = 26
			}},
			{{
				action = "missile",
				time_start = 2
			}, {
				action = "missile",
				time_start = 9
			}, {
				action = "missile",
				time_start = 17
			}},
			{{
				action = "missile",
				time_start = 11
			}, {
				action = "missile",
				time_start = 23
			}, {
				action = "missile",
				time_start = 33
			}, {
				action = "missile",
				time_start = 47
			}, {
				action = "missile",
				time_start = 57
			}, {
				action = "missile",
				time_start = 67
			}, {
				action = "missile",
				time_start = 77
			}, {
				action = "missile",
				time_start = 87
			}, {
				action = "missile",
				time_start = 97
			}}
		}, {{{
			action = "open",
			time_start = 2
		}, {
			action = "fist",
			time_start = 17
		}, {
			action = "fist",
			time_start = 27
		}}, {{
			action = "missile",
			time_start = 12
		}, {
			action = "missile",
			time_start = 22
		}, {
			action = "missile",
			time_start = 32
		}}, {{
			action = "missile",
			time_start = 8
		}, {
			action = "missile",
			time_start = 26
		}, {
			action = "missile",
			time_start = 38
		}}, {{
			action = "fist",
			time_start = 12
		}, {
			action = "fist",
			time_start = 28
		}}, {{
			action = "fist",
			time_start = 17
		}, {
			action = "fist",
			time_start = 26
		}}, {{
			action = "fist",
			time_start = 17
		}, {
			action = "missile",
			time_start = 24
		}, {
			action = "missile",
			time_start = 34
		}, {
			action = "fist",
			time_start = 46
		}, {
			action = "missile",
			time_start = 59
		}, {
			action = "missile",
			time_start = 72
		}, {
			action = "missile",
			time_start = 83
		}, {
			action = "missile",
			time_start = 94
		}, {
			action = "missile",
			time_start = 106
		}, {
			action = "missile",
			time_start = 120
		}}}, {{
			{
				action = "open",
				time_start = 12
			},
			{
				action = "missile",
				time_start = 24
			},
			{
				action = "missile",
				time_start = 48
			},
			{
				action = "fist",
				time_start = 66
			},
			{
				action = "missile",
				time_start = 84
			},
			{
				action = "missile",
				time_start = 104
			},
			{
				action = "missile",
				time_start = 132
			},
			{
				action = "missile",
				time_start = 145
			},
			{
				action = "fist",
				time_start = 160
			},
			{
				action = "fist",
				time_start = 180
			},
			{
				action = "missile",
				time_start = 230
			},
			{
				action = "missile",
				time_start = 260
			},
			{
				action = "missile",
				time_start = 272
			},
			{
				action = "missile",
				time_start = 300
			},
			{
				action = "fist",
				time_start = 312
			},
			{
				action = "missile",
				time_start = 325
			},
			{
				action = "missile",
				time_start = 347
			},
			{
				action = "fist",
				time_start = 360
			},
			{
				action = "missile",
				time_start = 372
			},
			{
				action = "missile",
				time_start = 383
			},
			{
				action = "missile",
				time_start = 405
			},
			{
				action = "missile",
				time_start = 416
			},
			{
				action = "fist",
				time_start = 430
			},
			{
				action = "missile",
				time_start = 442
			},
			{
				action = "missile",
				time_start = 455
			},
			{
				action = "missile",
				time_start = 472
			},
			{
				action = "missile",
				time_start = 483
			},
			{
				action = "missile",
				time_start = 505
			},
			{
				action = "missile",
				time_start = 516
			},
			{
				action = "missile",
				time_start = 527
			}
		}}}
	},
	stage26_spawners = {
		wave_config = {{
			{},
			{},
			{{
				action = "open",
				time_start = 8,
				spawner = "fist",
				count = 2
			}, {
				action = "close",
				time_start = 17,
				spawner = "fist"
			}, {
				action = "open",
				time_start = 18,
				spawner = "fist",
				count = 2
			}, {
				action = "close",
				time_start = 27,
				spawner = "fist"
			}},
			{},
			{{
				action = "open",
				time_start = 1,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 6,
				spawner = "fist",
				count = 2
			}, {
				action = "close",
				time_start = 11,
				spawner = "clone_left"
			}, {
				action = "close",
				time_start = 16,
				spawner = "fist"
			}, {
				action = "open",
				time_start = 18,
				spawner = "clone_left"
			}, {
				action = "close",
				time_start = 38,
				spawner = "clone_left"
			}},
			{{
				action = "activate",
				time_start = 1,
				spawner = "hulk"
			}, {
				action = "open",
				time_start = 4,
				spawner = "fist",
				count = 4
			}, {
				action = "close",
				time_start = 25,
				spawner = "fist"
			}},
			{{
				action = "open",
				time_start = 1,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 9,
				spawner = "clone_right"
			}, {
				action = "open",
				time_start = 10,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 19,
				spawner = "clone_right"
			}, {
				action = "open",
				time_start = 23,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 32,
				spawner = "clone_right"
			}},
			{{
				action = "open",
				time_start = 1,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 4,
				spawner = "fist",
				count = 2
			}, {
				action = "close",
				time_start = 13,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 11,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 12,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 14,
				spawner = "fist",
				count = 4
			}, {
				action = "close",
				time_start = 24,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 26,
				spawner = "clone_left"
			}, {
				action = "close",
				time_start = 30,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 36,
				spawner = "clone_left"
			}},
			{{
				action = "activate",
				time_start = 1,
				spawner = "hulk"
			}},
			{{
				action = "activate",
				time_start = 1,
				spawner = "hulk"
			}},
			{{
				action = "open",
				time_start = 2,
				spawner = "fist",
				count = 4
			}, {
				action = "open",
				time_start = 9,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 18,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 19,
				spawner = "clone_right"
			}, {
				action = "open",
				time_start = 31,
				spawner = "fist",
				count = 4
			}, {
				action = "open",
				time_start = 38,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 47,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 48,
				spawner = "clone_right"
			}},
			{{
				action = "open",
				time_start = 1,
				spawner = "fist",
				count = 2
			}, {
				action = "open",
				time_start = 4,
				spawner = "clone_left"
			}, {
				action = "close",
				time_start = 10,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 15,
				spawner = "clone_left"
			}, {
				action = "open",
				time_start = 16,
				spawner = "fist",
				count = 2
			}, {
				action = "open",
				time_start = 20,
				spawner = "clone_left"
			}, {
				action = "close",
				time_start = 26,
				spawner = "fist"
			}, {
				action = "close",
				time_start = 31,
				spawner = "clone_left"
			}},
			{{
				action = "activate",
				time_start = 1,
				spawner = "hulk"
			}, {
				action = "open",
				time_start = 3,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 14,
				spawner = "clone_right"
			}, {
				action = "activate",
				time_start = 20,
				spawner = "hulk"
			}, {
				action = "open",
				time_start = 26,
				spawner = "clone_right"
			}, {
				action = "close",
				time_start = 38,
				spawner = "clone_right"
			}},
			{
				{
					action = "open",
					time_start = 1,
					spawner = "clone_left"
				},
				{
					action = "open",
					time_start = 3,
					spawner = "clone_right"
				},
				{
					action = "open",
					time_start = 5,
					spawner = "fist",
					count = 4
				},
				{
					action = "close",
					time_start = 13,
					spawner = "clone_left"
				},
				{
					action = "close",
					time_start = 14,
					spawner = "clone_right"
				},
				{
					action = "open",
					time_start = 15,
					spawner = "clone_left"
				},
				{
					action = "open",
					time_start = 17,
					spawner = "clone_right"
				},
				{
					action = "close",
					time_start = 20.5,
					spawner = "fist"
				},
				{
					action = "open",
					time_start = 20.5,
					spawner = "fist",
					count = 4
				},
				{
					action = "close",
					time_start = 28,
					spawner = "clone_left"
				},
				{
					action = "close",
					time_start = 30,
					spawner = "clone_right"
				},
				{
					action = "close",
					time_start = 37,
					spawner = "fist"
				},
				{
					action = "open",
					time_start = 38,
					spawner = "clone_left"
				},
				{
					action = "open",
					time_start = 40,
					spawner = "clone_right"
				},
				{
					action = "close",
					time_start = 48,
					spawner = "clone_left"
				},
				{
					action = "close",
					time_start = 50,
					spawner = "clone_right"
				}
			},
			{{
				action = "open",
				time_start = 1,
				spawner = "fist",
				count = 4
			}, {
				action = "activate",
				time_start = 3,
				spawner = "hulk"
			}, {
				action = "close",
				time_start = 16,
				spawner = "fist"
			}, {
				action = "open",
				time_start = 23,
				spawner = "fist",
				count = 4
			}, {
				action = "activate",
				time_start = 27,
				spawner = "hulk"
			}, {
				action = "close",
				time_start = 38,
				spawner = "fist"
			}, {
				action = "open",
				time_start = 48,
				spawner = "fist",
				count = 4
			}, {
				action = "activate",
				time_start = 52,
				spawner = "hulk"
			}, {
				action = "close",
				time_start = 63,
				spawner = "fist"
			}}
		}, {{}, {{
			action = "open",
			time_start = 0,
			spawner = "fist",
			count = 4
		}, {
			action = "close",
			time_start = 16,
			spawner = "fist"
		}, {
			action = "open",
			time_start = 34,
			spawner = "fist",
			count = 4
		}, {
			action = "close",
			time_start = 50,
			spawner = "fist"
		}}, {{
			action = "activate",
			time_start = 0,
			spawner = "hulk"
		}, {
			action = "open",
			time_start = 4,
			spawner = "clone_right"
		}, {
			action = "close",
			time_start = 15,
			spawner = "clone_right"
		}, {
			action = "open",
			time_start = 33,
			spawner = "clone_right"
		}, {
			action = "close",
			time_start = 43,
			spawner = "clone_right"
		}, {
			action = "open",
			time_start = 53,
			spawner = "clone_right"
		}, {
			action = "close",
			time_start = 63,
			spawner = "clone_right"
		}}, {{
			action = "activate",
			time_start = 0,
			spawner = "hulk"
		}}, {{
			action = "open",
			time_start = 0,
			spawner = "fist",
			count = 4
		}, {
			action = "open",
			time_start = 7,
			spawner = "clone_left"
		}, {
			action = "close",
			time_start = 16,
			spawner = "fist"
		}, {
			action = "open",
			time_start = 21,
			spawner = "fist",
			count = 4
		}, {
			action = "close",
			time_start = 23,
			spawner = "clone_left"
		}, {
			action = "open",
			time_start = 28,
			spawner = "clone_left"
		}, {
			action = "close",
			time_start = 37,
			spawner = "fist"
		}, {
			action = "close",
			time_start = 42,
			spawner = "clone_left"
		}}, {{
			action = "open",
			time_start = 0,
			spawner = "fist",
			count = 4
		}, {
			action = "activate",
			time_start = 10,
			spawner = "hulk"
		}, {
			action = "close",
			time_start = 16,
			spawner = "fist"
		}, {
			action = "open",
			time_start = 34,
			spawner = "clone_left"
		}, {
			action = "activate",
			time_start = 56,
			spawner = "hulk"
		}, {
			action = "close",
			time_start = 62,
			spawner = "clone_left"
		}, {
			action = "activate",
			time_start = 74,
			spawner = "hulk"
		}, {
			action = "open",
			time_start = 76,
			spawner = "fist",
			count = 4
		}, {
			action = "close",
			time_start = 92,
			spawner = "fist"
		}}}, {{
			{
				action = "open",
				time_start = 1,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 9,
				spawner = "clone_left"
			},
			{
				action = "open",
				time_start = 15,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 24,
				spawner = "clone_left"
			},
			{
				action = "open",
				time_start = 54,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 64,
				spawner = "clone_left"
			},
			{
				action = "open",
				time_start = 80,
				spawner = "fist",
				count = 6
			},
			{
				action = "close",
				time_start = 106,
				spawner = "fist"
			},
			{
				action = "open",
				time_start = 109,
				spawner = "fist",
				count = 4
			},
			{
				action = "close",
				time_start = 125,
				spawner = "fist"
			},
			{
				action = "open",
				time_start = 142,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 145,
				spawner = "fist",
				count = 3
			},
			{
				action = "close",
				time_start = 151,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 154,
				spawner = "clone_right"
			},
			{
				action = "close",
				time_start = 158,
				spawner = "fist"
			},
			{
				action = "open",
				time_start = 159,
				spawner = "fist",
				count = 7
			},
			{
				action = "close",
				time_start = 163,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 173,
				spawner = "clone_right"
			},
			{
				action = "close",
				time_start = 188,
				spawner = "fist"
			},
			{
				action = "close",
				time_start = 195,
				spawner = "clone_right"
			},
			{
				action = "activate",
				time_start = 260,
				spawner = "hulk"
			},
			{
				action = "open",
				time_start = 264,
				spawner = "fist",
				count = 4
			},
			{
				action = "close",
				time_start = 279,
				spawner = "fist"
			},
			{
				action = "open",
				time_start = 294,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 295,
				spawner = "fist",
				count = 4
			},
			{
				action = "close",
				time_start = 305,
				spawner = "clone_right"
			},
			{
				action = "close",
				time_start = 309,
				spawner = "fist"
			},
			{
				action = "open",
				time_start = 325,
				spawner = "clone_right"
			},
			{
				action = "close",
				time_start = 335,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 342,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 352,
				spawner = "clone_left"
			},
			{
				action = "open",
				time_start = 370,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 380,
				spawner = "clone_left"
			},
			{
				action = "open",
				time_start = 397,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 400,
				spawner = "clone_left"
			},
			{
				action = "activate",
				time_start = 419,
				spawner = "hulk"
			},
			{
				action = "close",
				time_start = 430,
				spawner = "clone_right"
			},
			{
				action = "open",
				time_start = 431,
				spawner = "fist",
				count = 4
			},
			{
				action = "close",
				time_start = 432,
				spawner = "clone_left"
			},
			{
				action = "close",
				time_start = 445,
				spawner = "fist"
			},
			{
				action = "activate",
				time_start = 464,
				spawner = "hulk"
			},
			{
				action = "open",
				time_start = 469,
				spawner = "fist",
				count = 8
			},
			{
				action = "close",
				time_start = 506,
				spawner = "fist"
			}
		}}}
	},
	stage27_head = {
		ray_stun_duration = 15,
		taps_to_cancel = 20,
		attack_duration = 6,
		towers_to_stun = 13,
		charge_time = 3,
		scrap_attack = {
			damage_radius = 50,
			damage_max = 72,
			damage_min = 48,
			damage_type = DAMAGE_EXPLOSION
		},
		tower_stun_repair_cost = {50, 75, 100, 125, 150, 175, 200, 225, 250, 275}
	},
	stage29_holder_block = {
		time_to_up = 2,
		time_to_down = 3,
		time_netting = 5,
		taps_to_cancel = 3,
		waves = {{5, 6, 7, 9, 10, 11, 12, 13, 14, 15}, {2, 3, 4, 5, 6}, {1}},
		first_cooldown = {{5, 40, 5, 45, 1, 22, 1, 1, 1, 1}, {1, 35, 5, 25, 40}, {30}},
		cooldown = {{35, 20, 0, 0, 30, 30, 40, 30, 30, 25}, {0, 0, 42, 0, 20}, {50}},
		max_casts = {{2, 2, 1, 1, 3, 2, 2, 3, 3, 4}, {1, 1, 2, 1, 2}, {50}},
		blocked_holders = {
			price = {65, 65, 30}
		},
		game_start_blocked_holders = {{}, {}, {
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
			"10",
			"11",
			"12",
			"13",
			"14",
			"15"
		}}
	},
	stage30_door = {{
		[5] = {{32, 42}, {58, 68}},
		[9] = {{21, 31}, {48, 58}},
		[11] = {{10, 25}, {43, 58}},
		[13] = {{1, 10}, {18, 28}, {41, 55}},
		[15] = {{1, 10}, {18, 28}, {52, 62}}
	}, {{{44, 52}}, {{57, 67}}, {{0.2, 10}, {44, 60}}, {{46, 60}}, {{0.5, 19}}, {{24, 34}, {70, 80}}}, {{{155, 180}, {220, 250}}}},
	stage31_water_mechanic = {
		unlock_wave = 4,
		warn_duration = 5,
		first_warn_minimum_targets = 3,
		cooldown = 50,
		damage_max = 320,
		damage_min = 280,
		duration = 4,
		path = {1, 4},
		nodes = {{46, 138}, {50, 130}},
		damage_type = DAMAGE_PHYSICAL
	},
	stage32_lightning_strike = {
		chain_strikes_chance = 0,
		force_target_soldier_chance = 0.2,
		warning_duration = 0.75,
		max_chains = 2,
		areas_configs = {
			CAMPAIGN = {
				["1"] = {
					[5] = {{
						max_casts = 10,
						first_cd = 1,
						max_cd = 6,
						min_cd = 4.5
					}},
					[6] = {{
						max_casts = 15,
						first_cd = 3,
						max_cd = 5.5,
						min_cd = 4
					}},
					[8] = {{
						max_casts = 4,
						first_cd = 3,
						max_cd = 5,
						min_cd = 4
					}},
					[10] = {{
						max_casts = 15,
						first_cd = 5,
						max_cd = 5,
						min_cd = 4
					}},
					[11] = {{
						max_casts = 10,
						first_cd = 15,
						max_cd = 7,
						min_cd = 5
					}},
					[13] = {{
						max_casts = 40,
						first_cd = 5,
						max_cd = 3.5,
						min_cd = 3
					}},
					[15] = {{
						max_casts = 75,
						first_cd = 1,
						max_cd = 4,
						min_cd = 3.75
					}}
				},
				["10"] = {},
				["2"] = {
					[6] = {{
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 10,
						max_casts = 6,
						max_cd = 3,
						min_cd = 2
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 42,
						max_casts = 6,
						max_cd = 3,
						min_cd = 2
					}},
					[8] = {{
						max_casts = 8,
						first_cd = 1,
						max_cd = 4,
						min_cd = 2
					}},
					[9] = {{
						max_casts = 11,
						first_cd = 2,
						max_cd = 6,
						min_cd = 5
					}},
					[11] = {{
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 48.5,
						max_casts = 6,
						max_cd = 3,
						min_cd = 2.5
					}},
					[13] = {{
						max_casts = 10,
						first_cd = 2,
						max_cd = 1.5,
						min_cd = 1
					}, {
						max_casts = 20,
						first_cd = 70,
						max_cd = 1.25,
						min_cd = 0.75
					}},
					[15] = {{
						spawn_unit = "enemy_storm_elemental",
						first_cd = 6.5,
						max_casts = 1,
						max_cd = 1,
						min_cd = 1
					}, {
						spawn_unit = "enemy_storm_elemental",
						first_cd = 52,
						max_casts = 1,
						max_cd = 12,
						min_cd = 10
					}}
				},
				["3"] = {
					[9] = {{
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 6,
						max_casts = 7,
						max_cd = 1.5,
						min_cd = 1
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 70,
						max_casts = 7,
						max_cd = 1.5,
						min_cd = 1
					}},
					[11] = {{
						max_casts = 6,
						first_cd = 3,
						max_cd = 8,
						min_cd = 6
					}},
					[13] = {{
						max_casts = 10,
						first_cd = 10,
						max_cd = 1.25,
						min_cd = 0.75
					}, {
						spawn_unit = "enemy_storm_elemental",
						first_cd = 25,
						max_casts = 2,
						max_cd = 23,
						min_cd = 23
					}},
					[15] = {{
						max_casts = 1e+99,
						first_cd = 1,
						max_cd = 4,
						min_cd = 3
					}}
				},
				["4"] = {
					[9] = {{
						max_casts = 11,
						first_cd = 5,
						max_cd = 6,
						min_cd = 5
					}},
					[11] = {{
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 4,
						max_casts = 8,
						max_cd = 3,
						min_cd = 2
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 50,
						max_casts = 6,
						max_cd = 3,
						min_cd = 2.5
					}},
					[15] = {{
						spawn_unit = "enemy_storm_elemental",
						first_cd = 8,
						max_casts = 1,
						max_cd = 12,
						min_cd = 10
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 22,
						max_casts = 6,
						max_cd = 1.25,
						min_cd = 1
					}, {
						spawn_unit = "enemy_storm_elemental",
						first_cd = 50,
						max_casts = 1,
						max_cd = 12,
						min_cd = 10
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 63,
						max_casts = 8,
						max_cd = 0.75,
						min_cd = 0.5
					}}
				},
				["5"] = {
					[13] = {{
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 5,
						max_casts = 8,
						max_cd = 1.5,
						min_cd = 1
					}, {
						spawn_unit = "enemy_water_spirit_spawnless",
						first_cd = 34,
						max_casts = 8,
						max_cd = 1.5,
						min_cd = 1
					}}
				},
				["6"] = {
					[10] = {{
						max_casts = 3,
						first_cd = 3,
						max_cd = 1,
						min_cd = 0.75
					}, {
						spawn_unit = "enemy_storm_elemental",
						first_cd = 39,
						max_casts = 1,
						max_cd = 1,
						min_cd = 0.75
					}},
					[13] = {{
						max_casts = 10,
						first_cd = 13,
						max_cd = 1.25,
						min_cd = 0.75
					}},
					[15] = {{
						spawn_unit = "enemy_storm_elemental",
						first_cd = 5,
						max_casts = 1,
						max_cd = 12,
						min_cd = 10
					}, {
						spawn_unit = "enemy_storm_elemental",
						first_cd = 54,
						max_casts = 1,
						max_cd = 12,
						min_cd = 10
					}, {
						max_casts = 11,
						first_cd = 60,
						max_cd = 6,
						min_cd = 5
					}}
				},
				["7"] = {
					[15] = {{
						max_casts = 10,
						first_cd = 6,
						max_cd = 5,
						min_cd = 4
					}}
				},
				["8"] = {}
			},
			HEROIC = {},
			IRON = {
				["1"] = {{{
					max_casts = 1e+99,
					first_cd = 169,
					max_cd = 7,
					min_cd = 4
				}}},
				["2"] = {{{
					max_casts = 10,
					first_cd = 171,
					max_cd = 5,
					min_cd = 4
				}, {
					spawn_unit = "enemy_water_spirit_spawnless",
					first_cd = 225,
					max_casts = 10,
					max_cd = 2,
					min_cd = 1.5
				}}},
				["3"] = {{{
					spawn_unit = "enemy_storm_elemental",
					first_cd = 174,
					max_casts = 1,
					max_cd = 1,
					min_cd = 1
				}, {
					max_casts = 1e+99,
					first_cd = 176,
					max_cd = 8,
					min_cd = 5
				}}},
				["4"] = {{{
					max_casts = 6,
					first_cd = 172.5,
					max_cd = 7,
					min_cd = 4
				}, {
					spawn_unit = "enemy_water_spirit_spawnless",
					first_cd = 212,
					max_casts = 7,
					max_cd = 2.5,
					min_cd = 2
				}}}
			}
		},
		damage_config = {
			radius = 100,
			damage_type = DAMAGE_TRUE,
			damage_max = {50, 50, 85},
			damage_min = {50, 50, 60}
		}
	},
	stage33_envelops = {
		cooldown_min = 20,
		max_speed = 20,
		decoy_chance = 0.5,
		gold = 5,
		min_speed = 10,
		cooldown_max = 40,
		gold_balatro = 1000
	},
	stage35_cannonball_soldier = {
		speed = 75,
		armor = 0,
		hp = 90,
		basic_attack = {
			cooldown = 1,
			range = 100,
			damage_max = 13,
			damage_min = 8
		}
	},
	stage_37_dragon_wardens = {
		max_soldiers = 3,
		rally_range = 300,
		respawn_time = 30,
		soldiers = {
			warrior = {
				speed = 70,
				armor = 0,
				hp_max = 350,
				magic_armor = 0,
				melee = {
					cooldown = 1.5,
					damage_min = 60,
					damage_max = 75,
					damage_type = DAMAGE_PHYSICAL
				}
			}
		}
	},
	stage_38_dragon_wardens = {
		soldiers = {
			dragon_raider = {
				speed = 36,
				armor = 0,
				hp_max = 180,
				balloon_duration = 3,
				magic_armor = 0,
				melee = {
					cooldown = 1.25,
					damage_min = 12,
					damage_max = 24,
					damage_type = DAMAGE_PHYSICAL
				}
			},
			dragon_raider_mounted = {
				wait_after_max_spawns = 5,
				wander_radius = 250,
				max_spawns = 3,
				hp_max = 450,
				magic_armor = 0,
				speed = 60,
				armor = 0,
				ranged = {
					max_range = 150,
					min_range = 0,
					damage_min = 38,
					cooldown = 1.25,
					damage_max = 60,
					damage_type = DAMAGE_MAGICAL
				}
			}
		}
	},
	stage_40_moving_island = {
		speed = 7,
		stop_steps = {500, 310, 100, 20},
		ranged = {
			max_count = 3,
			range = 350,
			damage_min = 38,
			cooldown = 1.25,
			damage_max = 60,
			damage_type = DAMAGE_MAGICAL
		},
		soldiers = {
			max_speed = 32,
			armor = 0,
			hp_max = 550,
			magic_armor = 0,
			ranged = {
				max_range = 350,
				damage_min = 38,
				cooldown = 1.25,
				damage_max = 60,
				damage_type = DAMAGE_MAGICAL
			}
		}
	},
	stage_40_warden_reinforcements = {
		warrior = {
			speed = 70,
			armor = 0,
			hp_max = 150,
			magic_armor = 0,
			melee = {
				range = 130,
				damage_min = 25,
				cooldown = 1.5,
				damage_max = 42,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		mage = {
			speed = 70,
			armor = 0,
			hp_max = 70,
			magic_armor = 0,
			ranged = {
				max_range = 200,
				damage_min = 15,
				cooldown = 1.5,
				damage_max = 27,
				damage_type = DAMAGE_MAGICAL
			}
		}
	},
	towers = {
		tower_stage_28_priests_barrack = {
			max_soldiers = 4,
			price = 200,
			rally_range = 174.4,
			priest = {
				armor = 0,
				max_speed = 45,
				hp_max = 110,
				price = 105,
				dead_lifetime = 12,
				melee = {
					cooldown = 1,
					damage_min = 10,
					damage_max = 15,
					damage_type = DAMAGE_MAGICAL
				},
				ranged = {
					range = 218,
					damage_min = 45,
					cooldown = 2.5,
					damage_max = 65,
					damage_type = DAMAGE_MAGICAL
				},
				melee_range = 60
			},
			explosion = {
				price_inc = 120,
				price_base = 200,
				damage_type = DAMAGE_MAGICAL,
				damage_min = 2,
				damage_max = 6,
				damage_inc = 6,
				damage_radius = 50
			},
			abomination = {
				price_base = 120,
				price_inc = 200,
				armor = 0,
				max_speed = 25,
				regen_health = 0,
				hp_max = 450,
				duration = 10,
				melee_attack = {
					cooldown = 2,
					damage_min = 45,
					damage_max = 65
				},
				eat = {
					cooldown = 8,
					hp_required = 0.3
				},
				melee_range = 70
			},
			tentacle = {
				duration = 10,
				area_attack = {
					radius = 50,
					cooldown_min = 1,
					damage_min = 12,
					cooldown_max = 2,
					damage_max = 20,
					damage_type = DAMAGE_PHYSICAL
				}
			}
		},
		arborean_sentinels = {
			spearmen = {
				armor = 0.1,
				regen_health = 8,
				max_speed = 75,
				hp_max = 92,
				price = 50,
				melee_attack = {
					cooldown = 1.2,
					range = 60,
					damage_min = 12,
					damage_max = 18
				},
				ranged_attack = {
					max_range = 165,
					min_range = 60.5,
					damage_min = 9,
					cooldown = 1.5,
					damage_max = 14,
					damage_type = DAMAGE_PHYSICAL
				}
			},
			barkshield = {
				max_speed = 60,
				regen_health = 30,
				armor = 0.5,
				hp_max = 300,
				price = 90,
				melee_attack = {
					cooldown = 3,
					range = 60,
					damage_min = 25,
					damage_max = 50
				}
			}
		},
		stage_13_sunray = {
			attacks_before_special_min_iron = 6,
			attacks_before_special_max = 12,
			attacks_before_special_max_iron = 10,
			attacks_before_special_min = 8,
			repair_cost = {300, 250, 200, 150},
			repair_cost_iron = {200, 150, 100, 50},
			basic_attack = {
				range = 250,
				damage_min = 140,
				cooldown = 2,
				damage_max = 260,
				damage_every = fts(2),
				duration = fts(40),
				damage_type = DAMAGE_TRUE
			},
			special_attack = {
				radius = 40,
				range = 350,
				cooldown = 2,
				damage_max = 780,
				speed = 20,
				damage_min = 560,
				damage_every = fts(2),
				duration = fts(60),
				damage_type = DAMAGE_DISINTEGRATE
			}
		},
		stage_17_weirdwood = {
			holder_cost = 150,
			basic_attack = {
				max_range = 190,
				min_range = 40,
				damage_min = 28,
				damage_radius = 55,
				cooldown = 5,
				damage_max = 50
			},
			corruption_phases = {1, 2, 3}
		},
		stage_18_elven_barrack = {
			max_soldiers = 3,
			rally_range = 160,
			spawn_cooldown = 5,
			soldier = {
				speed = 75,
				armor = 0.5,
				hp = 120,
				dead_lifetime = 10,
				regen_hp = 10,
				price = {50, 75, 100, 100},
				basic_attack = {
					cooldown = 1,
					range = 75,
					damage_max = 24,
					damage_min = 16
				}
			},
			corruption_phases = {1, 2, 3}
		},
		stage_20_arborean_oldtree = {
			max_range = 50,
			path_index_iron = 3,
			node_index_iron = 105,
			cooldown = 90,
			price_iron = 100,
			path_index = 2,
			damage_max = 450,
			damage_min = 350,
			node_index = 170,
			price = 250,
			damage_type = DAMAGE_PHYSICAL
		},
		stage_20_arborean_honey = {
			max_range = 180,
			aura_duration = 4,
			price_heroic = 300,
			slow_factor = 0.6,
			cooldown = 5,
			damage_radius = 100,
			damage_max = 30,
			damage_min = 20,
			slow_mod_duration = 0.5,
			price = 500,
			damage_type = DAMAGE_PHYSICAL
		},
		tower_stage_20_arborean_barrack = {
			soldier_hp_max = 120,
			spawn_cooldown_max = 0.6,
			hp_max = 500,
			spawn_cooldown_min = 0.3,
			cooldown_disable = 2,
			magic_armor = 0,
			price = 50,
			armor = 0.3,
			soldier_damage_max = 8,
			soldier_damage_min = 4,
			spawns = 3,
			soldier_armor = 0.1,
			life_thresholds = {0.7, 0.4, 0}
		},
		stage_20_arborean_watchtower = {
			tunnel_check_cooldown = 3,
			basic_attack = {
				max_range = 260,
				damage_min = 19,
				cooldown = 2.4,
				damage_max = 28,
				damage_type = DAMAGE_PHYSICAL
			},
			picked_enemies_to_destroy = {2, 4, 6}
		},
		stage_22_arborean_mages_tower = {
			armor = 0.3,
			magic_armor = 0,
			hp_max = 500,
			basic_attack = {
				max_range = 260,
				damage_min = 38,
				cooldown = 2.5,
				damage_max = 52,
				damage_type = DAMAGE_MAGICAL
			}
		},
		tower_dragons_warden = {
			basic_attack = {
				max_range = 400,
				damage_min = 60,
				cooldown = 3.5,
				damage_max = 75,
				damage_type = DAMAGE_MAGICAL
			},
			increase_damage = {
				damage_factor = {1.5, 2, 3},
				price = {150, 300, 600}
			},
			increase_rate = {
				attack_cooldown = {3, 2.4, 1.6},
				price = {150, 250, 500}
			}
		}
	}
}
local reinforcements = {
	soldier = {
		armor = 0,
		regen_health = 8,
		max_speed = 64,
		hp_max = 40,
		cooldown = 15,
		duration = 12,
		melee_attack = {
			cooldown = 1,
			range = 72,
			damage_min = 1,
			damage_max = 2
		}
	}
}
local balance = {
	heroes = heroes,
	towers = towers,
	specials = specials,
	reinforcements = reinforcements
}
return balance
