local M = {}

M.skills_by_tower = {
	tower_barrel_lvl4 = {
		{
			id = "barrel_field_ration",
			cooldown = 12,
			target = {
				type = "soldiers_in_range",
				range = 170
			},
			effect = {
				type = "heal_percent",
				percent = 0.2,
				max_targets = 6
			}
		}
	},
	tower_arcane_wizard_lvl4 = {
		{
			id = "arcane_overload",
			cooldown = 10,
			target = {
				type = "enemies_in_range",
				range = 180
			},
			effect = {
				type = "damage",
				damage_min = 90,
				damage_max = 140,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_arcane"},
				max_targets = 4
			}
		}
	},
	tower_ballista_lvl4 = {
		{
			id = "ballista_salvo",
			cooldown = 11,
			target = {
				type = "enemies_in_range",
				range = 190
			},
			effect = {
				type = "damage",
				damage_min = 110,
				damage_max = 170,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_artillery"},
				max_targets = 3
			}
		}
	},
	tower_paladin_covenant_lvl4 = {
		{
			id = "paladin_battle_prayer",
			cooldown = 14,
			target = {
				type = "soldiers_in_range",
				range = 200
			},
			effect = {
				type = "heal_percent",
				percent = 0.25,
				max_targets = 8
			}
		}
	},
	tower_elven_stargazers_lvl4 = {
		{
			id = "stargazer_comet_burst",
			cooldown = 9,
			target = {
				type = "enemies_in_range",
				range = 200
			},
			effect = {
				type = "damage",
				damage_min = 80,
				damage_max = 130,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_lightning1", "pop_lightning2"},
				max_targets = 5
			}
		}
	},
	tower_flamespitter_lvl4 = {
		{
			id = "flamespitter_burst",
			cooldown = 10,
			target = {
				type = "enemies_in_range",
				range = 180
			},
			effect = {
				type = "damage",
				damage_min = 95,
				damage_max = 145,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_artillery"},
				max_targets = 4
			}
		}
	},
	tower_dark_elf_lvl4 = {
		{
			id = "dark_elf_execution_order",
			cooldown = 12,
			target = {
				type = "enemies_in_range",
				range = 185
			},
			effect = {
				type = "damage",
				damage_min = 100,
				damage_max = 160,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_headshot"},
				max_targets = 4
			}
		}
	},
	tower_tricannon_lvl4 = {
		{
			id = "tricannon_shock_barrage",
			cooldown = 11,
			target = {
				type = "enemies_in_range",
				range = 195
			},
			effect = {
				type = "damage",
				damage_min = 120,
				damage_max = 175,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_artillery"},
				max_targets = 3
			}
		}
	},
	tower_ray_lvl4 = {
		{
			id = "ray_chain_overload",
			cooldown = 10,
			target = {
				type = "enemies_in_range",
				range = 200
			},
			effect = {
				type = "damage",
				damage_min = 85,
				damage_max = 135,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_lightning2", "pop_lightning3"},
				max_targets = 5
			}
		}
	},
	tower_dwarf_lvl4 = {
		{
			id = "dwarf_battle_ale",
			cooldown = 13,
			target = {
				type = "soldiers_in_range",
				range = 180
			},
			effect = {
				type = "heal_percent",
				percent = 0.22,
				max_targets = 6
			}
		}
	},
	tower_ghost_lvl4 = {
		{
			id = "ghost_reap_order",
			cooldown = 12,
			target = {
				type = "enemies_in_range",
				range = 190
			},
			effect = {
				type = "damage",
				damage_min = 105,
				damage_max = 165,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_mage"},
				max_targets = 4
			}
		}
	},
	tower_necromancer_lvl4 = {
		{
			id = "necromancer_death_chant",
			cooldown = 12,
			target = {
				type = "enemies_in_range",
				range = 190
			},
			effect = {
				type = "damage",
				damage_min = 95,
				damage_max = 150,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_death"},
				max_targets = 4
			}
		}
	},
	tower_hermit_toad_lvl4 = {
		{
			id = "toad_toxic_burst",
			cooldown = 11,
			target = {
				type = "enemies_in_range",
				range = 180
			},
			effect = {
				type = "damage",
				damage_min = 100,
				damage_max = 155,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_artillery"},
				max_targets = 3
			}
		}
	},
	tower_demon_pit_lvl4 = {
		{
			id = "demon_pit_hell_pressure",
			cooldown = 13,
			target = {
				type = "enemies_in_range",
				range = 185
			},
			effect = {
				type = "damage",
				damage_min = 110,
				damage_max = 165,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_mage"},
				max_targets = 3
			}
		}
	},
	tower_rocket_gunners_lvl4 = {
		{
			id = "rocket_gunners_saturation_fire",
			cooldown = 10,
			target = {
				type = "enemies_in_range",
				range = 200
			},
			effect = {
				type = "damage",
				damage_min = 90,
				damage_max = 145,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_artillery"},
				max_targets = 5
			}
		}
	},
	tower_sand_lvl4 = {
		{
			id = "sandstorm_focus_fire",
			cooldown = 10,
			target = {
				type = "enemies_in_range",
				range = 190
			},
			effect = {
				type = "damage",
				damage_min = 90,
				damage_max = 145,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_archer"},
				max_targets = 4
			}
		}
	},
	tower_royal_archers_lvl4 = {
		{
			id = "royal_archers_hail_order",
			cooldown = 11,
			target = {
				type = "enemies_in_range",
				range = 200
			},
			effect = {
				type = "damage",
				damage_min = 95,
				damage_max = 150,
				damage_type = DAMAGE_PHYSICAL,
				pop = {"pop_headshot"},
				max_targets = 5
			}
		}
	},
	tower_pandas_lvl4 = {
		{
			id = "panda_storm_combo",
			cooldown = 12,
			target = {
				type = "enemies_in_range",
				range = 185
			},
			effect = {
				type = "damage",
				damage_min = 105,
				damage_max = 160,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_mage"},
				max_targets = 4
			}
		}
	},
	tower_sparking_geode_lvl4 = {
		{
			id = "geode_overcharge_pulse",
			cooldown = 9,
			target = {
				type = "enemies_in_range",
				range = 200
			},
			effect = {
				type = "damage",
				damage_min = 85,
				damage_max = 140,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_lightning1", "pop_lightning3"},
				max_targets = 5
			}
		}
	},
	tower_arborean_emissary_lvl4 = {
		{
			id = "arborean_nature_surge",
			cooldown = 11,
			target = {
				type = "enemies_in_range",
				range = 195
			},
			effect = {
				type = "damage",
				damage_min = 95,
				damage_max = 150,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_mage"},
				max_targets = 4
			}
		}
	},
	tower_dragons_lvl4 = {
		{
			id = "dragons_sky_ruin",
			cooldown = 13,
			target = {
				type = "enemies_in_range",
				range = 210
			},
			effect = {
				type = "damage",
				damage_min = 120,
				damage_max = 180,
				damage_type = DAMAGE_MAGICAL,
				pop = {"pop_lightning3"},
				max_targets = 5
			}
		}
	}
}

return M
