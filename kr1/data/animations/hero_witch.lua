-- chunkname: @./kr5/data/animations/hero_witch.lua

local a = {
	hero_witch_hero_layerX_idle = {
		layer_to = 3,
		from = 1,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 22,
		layer_from = 1
	},
	hero_witch_hero_layerX_walk = {
		layer_to = 3,
		from = 23,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 40,
		layer_from = 1
	},
	hero_witch_hero_layerX_range_attack = {
		layer_to = 3,
		from = 41,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 76,
		layer_from = 1
	},
	hero_witch_hero_layerX_melee_attack = {
		layer_to = 3,
		from = 77,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 110,
		layer_from = 1
	},
	hero_witch_hero_layerX_skill_1 = {
		layer_to = 3,
		from = 111,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 162,
		layer_from = 1
	},
	hero_witch_hero_layerX_skill_2 = {
		layer_to = 3,
		from = 163,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 190,
		layer_from = 1
	},
	hero_witch_hero_layerX_skill_3 = {
		layer_to = 3,
		from = 191,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 238,
		layer_from = 1
	},
	hero_witch_hero_layerX_skill_4 = {
		layer_to = 3,
		from = 239,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 292,
		layer_from = 1
	},
	hero_witch_hero_layerX_levelup = {
		layer_to = 3,
		from = 293,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 328,
		layer_from = 1
	},
	hero_witch_hero_layerX_respawn = {
		layer_to = 3,
		from = 329,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 366,
		layer_from = 1
	},
	hero_witch_hero_layerX_death = {
		layer_to = 3,
		from = 367,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 419,
		layer_from = 1
	},
	hero_witch_hero_layerX_grave = {
		layer_to = 3,
		from = 420,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 420,
		layer_from = 1
	},
	hero_witch_walk_particle = {
		prefix = "hero_witch_walk_particle",
		to = 10,
		from = 1
	},
	hero_witch_ranged_attack_projectile_loop = {
		prefix = "hero_witch_ranged_attack_projectile",
		to = 10,
		from = 1
	},
	hero_witch_ranged_attack_particle = {
		prefix = "hero_witch_ranged_attack_particle",
		to = 7,
		from = 1
	},
	hero_witch_ranged_attack_hit = {
		prefix = "hero_witch_ranged_attack_hit",
		to = 9,
		from = 1
	},
	hero_witch_skill_1_particle_idle = {
		prefix = "hero_witch_skill_1_particle",
		to = 9,
		from = 1
	},
	hero_witch_skill_1_hit_run = {
		prefix = "hero_witch_skill_1_hit",
		to = 19,
		from = 1
	},
	hero_witch_pumpkling_flying_idle = {
		prefix = "hero_witch_pumpkling_flying",
		to = 16,
		from = 1
	},
	hero_witch_pumpkling_flying_walk = {
		prefix = "hero_witch_pumpkling_flying",
		to = 32,
		from = 17
	},
	hero_witch_pumpkling_flying_walk_front = {
		prefix = "hero_witch_pumpkling_flying",
		to = 48,
		from = 33
	},
	hero_witch_pumpkling_flying_walk_back = {
		prefix = "hero_witch_pumpkling_flying",
		to = 64,
		from = 49
	},
	hero_witch_pumpkling_flying_death = {
		prefix = "hero_witch_pumpkling_flying",
		to = 77,
		from = 65
	},
	hero_witch_pumpkling_idle = {
		prefix = "hero_witch_pumpkling",
		to = 1,
		from = 1
	},
	hero_witch_pumpkling_walk = {
		prefix = "hero_witch_pumpkling",
		to = 15,
		from = 2
	},
	hero_witch_pumpkling_walk_front = {
		prefix = "hero_witch_pumpkling",
		to = 29,
		from = 16
	},
	hero_witch_pumpkling_walk_back = {
		prefix = "hero_witch_pumpkling",
		to = 43,
		from = 30
	},
	hero_witch_pumpkling_death = {
		prefix = "hero_witch_pumpkling",
		to = 65,
		from = 44
	},
	hero_witch_decoy_idle = {
		prefix = "hero_witch_decoy",
		to = 1,
		from = 1
	},
	hero_witch_decoy_in = {
		prefix = "hero_witch_decoy",
		to = 20,
		from = 2
	},
	hero_witch_decoy_walk = {
		prefix = "hero_witch_decoy",
		to = 36,
		from = 21
	},
	hero_witch_decoy_attack = {
		prefix = "hero_witch_decoy",
		to = 64,
		from = 37
	},
	hero_witch_decoy_death = {
		prefix = "hero_witch_decoy",
		to = 89,
		from = 65
	},
	hero_witch_skill_2_stun_mod_loop = {
		prefix = "hero_witch_skill_2_stun_mod",
		to = 28,
		from = 1
	},
	hero_witch_skill_2_stun_decal_death = {
		prefix = "hero_witch_skill_2_stun_decal",
		to = 25,
		from = 1
	},
	hero_witch_skill_2_stun_fx_death = {
		prefix = "hero_witch_skill_2_stun_fx",
		to = 25,
		from = 1
	},
	hero_witch_cat_idle = {
		prefix = "hero_witch_cat",
		to = 1,
		from = 1
	},
	hero_witch_cat_in = {
		prefix = "hero_witch_cat",
		to = 18,
		from = 2
	},
	hero_witch_cat_walk = {
		prefix = "hero_witch_cat",
		to = 32,
		from = 19
	},
	hero_witch_cat_attack = {
		prefix = "hero_witch_cat",
		to = 60,
		from = 33
	},
	hero_witch_cat_out = {
		prefix = "hero_witch_cat",
		to = 77,
		from = 61
	},
	hero_witch_skill_4_potion_decal_2 = {
		prefix = "hero_witch_skill_4_potion_decal_2",
		to = 1,
		from = 1
	},
	hero_witch_skill_4_potion_decal_1 = {
		prefix = "hero_witch_skill_4_potion_decal_1",
		to = 1,
		from = 1
	},
	hero_witch_skill_4_potion_in_in = {
		prefix = "hero_witch_skill_4_potion_in",
		to = 52,
		from = 15
	},
	hero_witch_skill_4_potion_in_layerX_in = {
		layer_to = 2,
		from = 1,
		layer_prefix = "hero_witch_skill_4_potion_in_layer%i",
		to = 39,
		layer_from = 1
	},
	hero_witch_ultimate_teleport_fx = {
		prefix = "hero_witch_ultimate_teleport_fx",
		to = 16,
		from = 1
	},
	hero_witch_ultimate_teleport_decal = {
		prefix = "hero_witch_ultimate_teleport_decal",
		to = 21,
		from = 1
	},
	hero_witch_ultimate_sleep_fx_loop = {
		prefix = "hero_witch_ultimate_sleep_fx",
		to = 42,
		from = 1
	},
	hero_witch_ultimate_sleep_particles_loop = {
		prefix = "hero_witch_ultimate_sleep_particles",
		to = 21,
		from = 1
	},
	hero_witch_ranged_attack_projectile_flying = {
		prefix = "hero_witch_ranged_attack_projectile",
		to = 10,
		from = 1
	},
	hero_witch_skill_1_hit_run_flying = {
		prefix = "hero_witch_skill_1_hit",
		to = 19,
		from = 1
	},
	hero_witch_skill_4_potion_in_custom = {
		prefix = "hero_witch_skill_4_potion_in",
		to = 39,
		from = 1
	},
	hero_witch_skill_1_particle_idle_flying = {
		prefix = "hero_witch_skill_1_particle",
		to = 9,
		from = 1
	},
	hero_witch_skill_1_hit_run = {
		prefix = "hero_witch_skill_1_hit",
		to = 16,
		from = 1
	},
	hero_witch_hero_layerX_disengage_disappear = {
		layer_to = 3,
		from = 163,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 173,
		layer_from = 1
	},
	hero_witch_hero_layerX_disengage_appear = {
		layer_to = 3,
		from = 174,
		layer_prefix = "hero_witch_hero_layer%i",
		to = 190,
		layer_from = 1
	}
}

return a
