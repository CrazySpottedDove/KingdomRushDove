-- 由 scripts/gen_component_cloner.lua 生成，请勿手改
return {
	["area_attack"] = function(tpl)
		return {
			animation = "attack",
			chance = 1,
			damage_bans = 128,
			damage_flags = 8,
			damage_max = 0,
			damage_min = 0,
			damage_radius = 0,
			damage_type = 8,
			dodge_time = 0.13333333333333,
			level = 1,
			max_range = 0,
			min_range = 0,
			ts = 0,
			type = "area",
			vis_bans = 128,
			vis_flags = 2
		}
	end,
	["armor_buff"] = function(tpl)
		return {
			cycle_time = 1,
			magic = false,
			max_factor = 0,
			step_factor = 0
		}
	end,
	["attacks"] = function(tpl)
		return {
			list = {},
			order = {},
			range = 0
		}
	end,
	["aura"] = function(tpl)
		return {
			cycle_time = 0.5,
			damage_factor = 1,
			duration = 0,
			duration_inc = 0,
			level = 1,
			radius = 0,
			track_source = false,
			ts = 0,
			use_mod_offset = true,
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["aura_attack"] = function(tpl)
		return {
			ts = 0,
			type = "aura"
		}
	end,
	["auras"] = function(tpl)
		return {
			list = {}
		}
	end,
	["barrack"] = function(tpl)
		return {
			door_hold_time = 0.5,
			door_open = false,
			door_open_ts = 0,
			has_door = true,
			max_soldiers = 3,
			rally_angle_offset = 0,
			rally_pos = tpl["rally_pos"]:clone(),
			rally_radius = 25,
			rally_range = 0,
			rally_terrains = 2049,
			soldier_type = "",
			soldiers = {}
		}
	end,
	["betray"] = function(tpl)
		return {
			duration = 10,
			ts = 0
		}
	end,
	["bullet"] = function(tpl)
		return {
			damage_bans = 0,
			damage_factor = 1,
			damage_flags = 0,
			damage_hooks = {},
			damage_max = 0,
			damage_min = 0,
			damage_radius = 0,
			damage_type = 2,
			from = tpl["from"]:clone(),
			g = -900,
			level = 0,
			max_track_distance = 64,
			reduce_armor = 0,
			reduce_magic_armor = 0,
			speed = tpl["speed"]:clone(),
			to = tpl["to"]:clone(),
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["bullet_attack"] = function(tpl)
		return {
			animation = "shoot",
			bullet = "",
			chance = 1,
			count = 0,
			level = 1,
			max_range = 0,
			max_track_distance = 128,
			min_range = 0,
			shoot_time = 0,
			ts = 0,
			type = "bullet",
			vis_bans = 0,
			vis_flags = 2
		}
	end,
	["cheats"] = function(tpl)
		return {
			buttons = {
				[1] = {}
			}
		}
	end,
	["cheats_text_button"] = function(tpl)
		return {}
	end,
	["click_play"] = function(tpl)
		return {
			click_animation = "clicked",
			idle_animation = "idle",
			play_once = false,
			required_clicks = 1
		}
	end,
	["cliff"] = function(tpl)
		return {
			fall_accel = 300,
			speed_factor = 0.7,
			sprite_suffix = "_cliff",
			vis_bans = 33701889
		}
	end,
	["cloak"] = function(tpl)
		return {
			bans = 0,
			flags = 0
		}
	end,
	["constant_spiked_armor"] = function(tpl)
		return tpl:clone()
	end,
	["corruption_kr5"] = function(tpl)
		return {
			count = 0,
			enabled = true,
			limit = 3
		}
	end,
	["count_group"] = function(tpl)
		return {
			type = 1
		}
	end,
	["crystal"] = function(tpl)
		return {}
	end,
	["custom_attack"] = function(tpl)
		return {
			chance = 1,
			ts = 0,
			type = "custom",
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["death_spawns"] = function(tpl)
		return {
			name = "",
			quantity = 1,
			spread_nodes = 0
		}
	end,
	["delayed_play"] = function(tpl)
		return {
			clicked_animation = "clicked",
			flip_chance = 0,
			idle_animation = "idle",
			loop_idle = false,
			loop_play = false,
			max_delay = 5,
			min_delay = 1,
			play_animation = "play"
		}
	end,
	["delayed_sequence"] = function(tpl)
		return {
			animations = {},
			max_delay = 5,
			min_delay = 1
		}
	end,
	["dodge"] = function(tpl)
		return {
			active = false,
			chance = 0,
			counter_attack_pending = false,
			ts = 0
		}
	end,
	["dps"] = function(tpl)
		return {
			damage_every = 1,
			damage_inc = 0,
			damage_max = 0,
			damage_min = 0,
			damage_type = 2,
			kill = true,
			ts = 0
		}
	end,
	["editor"] = function(tpl)
		return {
			game_mode = 0
		}
	end,
	["editor_script"] = function(tpl)
		return {
			runs = 1
		}
	end,
	["enemy"] = function(tpl)
		return {
			blockers = {},
			can_accept_magic = true,
			can_do_magic = true,
			counts = {},
			gold = 0,
			gold_bag = 0,
			lives_cost = 1,
			melee_slot = tpl["melee_slot"]:clone(),
			remove_at_goal_line = true,
			valid_terrains = 1
		}
	end,
	["event"] = function(tpl)
		return {}
	end,
	["events"] = function(tpl)
		return {
			list = {
				[1] = {}
			}
		}
	end,
	["fast"] = function(tpl)
		return {
			factor = 1
		}
	end,
	["force_motion"] = function(tpl)
		return {
			a = tpl["a"]:clone(),
			a_step = 10,
			fr = 0.1,
			ramp_max_factor = 1,
			ramp_min_factor = 0.1,
			v = tpl["v"]:clone()
		}
	end,
	["glare_kr5"] = function(tpl)
		return {
			regen_hp = 0
		}
	end,
	["graveyard"] = function(tpl)
		return {
			dead_time = 0.5,
			spawn_interval = 0.1,
			vis_bans = 0,
			vis_flags = 0,
			vis_has = 0
		}
	end,
	["heading"] = function(tpl)
		return tpl:clone()
	end,
	["heal_on_kill"] = function(tpl)
		return {}
	end,
	["health"] = function(tpl)
		return {
			armor = 0,
			armor_buff = 0,
			armor_resilience = 0,
			damage_factor = 1,
			damage_factor_magical = 1,
			dead = false,
			dead_lifetime = 2,
			death_ts = 0,
			hp_max = 10,
			ignore_damage = false,
			immune_to = 0,
			instakill_resistance = 0,
			last_damage_types = 0,
			magic_armor = 0,
			magic_armor_buff = 0,
			poison_armor = 0,
			spiked_armor = 0
		}
	end,
	["health_bar"] = function(tpl)
		return {
			_last_ts = 0,
			frames = {},
			hidden = false,
			offset = tpl["offset"]:clone(),
			type = "small",
			z = 3000
		}
	end,
	["hero"] = function(tpl)
		return {
			level = 1,
			level_stats = {},
			skills = {},
			tombstone_decal = "decal_hero_tombstone",
			xp = 0,
			xp_queued = 0
		}
	end,
	["hero_skill"] = function(tpl)
		return {
			hr_order = 1,
			level = 0,
			xp_gain_factor = 1
		}
	end,
	["hps"] = function(tpl)
		return {
			heal_every = 1,
			heal_max = 0,
			heal_min = 0,
			ts = 0
		}
	end,
	["idle_flip"] = function(tpl)
		return {
			chance = 0.4,
			cooldown = 5,
			last_animation = "idle",
			last_dir = 1,
			loop = true,
			ts = 0,
			ts_counter = 0,
			walk_dist = 0
		}
	end,
	["info"] = function(tpl)
		return {}
	end,
	["jump"] = function(tpl)
		return {
			g = -900,
			v = 100
		}
	end,
	["lifespan"] = function(tpl)
		return {
			duration = 21,
			fade = false,
			ts = 0
		}
	end,
	["light"] = function(tpl)
		return {
			radius = 0
		}
	end,
	["lights"] = function(tpl)
		return {
			[1] = {
				radius = 0
			}
		}
	end,
	["main_script"] = function(tpl)
		return {
			runs = 1
		}
	end,
	["mark_flags"] = function(tpl)
		return {
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["melee"] = function(tpl)
		return {
			arrived_slot_animation = "idle",
			attacks = {
				[1] = {
					animation = "attack",
					chance = 1,
					damage_max = 0,
					damage_min = 0,
					damage_type = 2,
					dodge_time = 0.13333333333333,
					level = 0,
					pop = {"pop_sok", "pop_pow"},
					pop_chance = 0.1,
					ts = 0,
					type = "melee",
					vis_bans = 0,
					vis_flags = 0
				}
			},
			forced_ts = 0,
			order = {1}
		}
	end,
	["melee_attack"] = function(tpl)
		return {
			animation = "attack",
			chance = 1,
			damage_max = 0,
			damage_min = 0,
			damage_type = 2,
			dodge_time = 0.13333333333333,
			level = 0,
			pop = {"pop_sok", "pop_pow"},
			pop_chance = 0.1,
			ts = 0,
			type = "melee",
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["mod_attack"] = function(tpl)
		return {
			chance = 1,
			ts = 0,
			type = "mod",
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["modifier"] = function(tpl)
		return {
			damage_factor = 1,
			damage_hooks = {},
			level = 1,
			replaces_lower = true,
			resets_same = true,
			ts = 0,
			use_mod_offset = true,
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["moon"] = function(tpl)
		return {}
	end,
	["motion"] = function(tpl)
		return {
			arrived = true,
			buff = 0,
			dest = tpl["dest"]:clone(),
			factor = 1,
			max_speed = 0,
			real_speed = 0,
			speed = tpl["speed"]:clone()
		}
	end,
	["nav_grid"] = function(tpl)
		return {
			valid_terrains = 2049,
			valid_terrains_dest = 2049,
			waypoints = {}
		}
	end,
	["nav_path"] = function(tpl)
		return tpl:clone()
	end,
	["nav_rally"] = function(tpl)
		return tpl:clone()
	end,
	["particle_system"] = function(tpl)
		return {
			alphas = {255},
			anchor = tpl["anchor"]:clone(),
			animated = false,
			emission_rate = 1,
			emit = true,
			emit_direction = 0,
			emit_rotation_spread = 0,
			emit_spread = 0,
			emit_ts = 0,
			frames = {},
			last_pos = tpl["last_pos"]:clone(),
			loop = true,
			particle_count = 0,
			particle_lifetime = {0.9, 1},
			particles = {},
			ts = 0,
			ts_offset = 0,
			z = 3200
		}
	end,
	["pickpocket"] = function(tpl)
		return {
			chance = 0,
			steal_max = 0,
			steal_min = 0
		}
	end,
	["plant"] = function(tpl)
		return {
			block_count = 0
		}
	end,
	["polymorph"] = function(tpl)
		return {
			custom_entity_names = {}
		}
	end,
	["pos"] = function(tpl)
		return tpl:clone()
	end,
	["power"] = function(tpl)
		return {
			level = 0,
			max_level = 3,
			price_base = 0,
			price_inc = 0
		}
	end,
	["powers"] = function(tpl)
		return {}
	end,
	["ranged"] = function(tpl)
		return {
			attacks = {
				[1] = {
					animation = "shoot",
					bullet = "",
					chance = 1,
					count = 0,
					level = 1,
					max_range = 0,
					max_track_distance = 128,
					min_range = 0,
					shoot_time = 0,
					ts = 0,
					type = "bullet",
					vis_bans = 0,
					vis_flags = 2
				}
			},
			forced_ts = 0,
			last_range_ts = 0,
			order = {1}
		}
	end,
	["regen"] = function(tpl)
		return {
			cooldown = 0,
			last_hit_standoff_time = 2,
			last_hit_ts = 0,
			ts = 0,
			ts_counter = 0
		}
	end,
	["reinforcement"] = function(tpl)
		return {
			duration = 21,
			fade = true
		}
	end,
	["render"] = function(tpl)
		return {
			sprites = {
				[1] = {
					alpha = 255,
					anchor = tpl["sprites"][1]["anchor"]:clone(),
					animated = true,
					flip_x = false,
					frame_idx = 1,
					hidden_count = 0,
					loop = true,
					name = "idle",
					offset = tpl["sprites"][1]["offset"]:clone(),
					r = 0,
					runs = 0,
					time_offset = 0,
					ts = 0,
					z = 3000
				}
			}
		}
	end,
	["revive"] = function(tpl)
		return {
			chance = 0,
			disabled = true,
			health_recover = 0,
			health_recover_inc = 0,
			hit_time = 0,
			protect = 0,
			remove_modifiers = true,
			ts = 0
		}
	end,
	["selfdestruct"] = function(tpl)
		return {
			animation = "selfdestruct",
			damage_type = 2,
			vis_bans = 0,
			vis_flags = 2
		}
	end,
	["sequence"] = function(tpl)
		return {
			fxs = {},
			loop = false,
			sprite_id = 1,
			steps = {}
		}
	end,
	["slow"] = function(tpl)
		return {
			factor = 0.5
		}
	end,
	["soldier"] = function(tpl)
		return {
			courage_ts = 0,
			last_block_ts = 0,
			melee_slot_offset = tpl["melee_slot_offset"]:clone()
		}
	end,
	["sound_events"] = function(tpl)
		return {}
	end,
	["spawn_attack"] = function(tpl)
		return {
			chance = 1,
			entity = "",
			ts = 0,
			type = "spawn",
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["spawner"] = function(tpl)
		return {
			allowed_subpaths = {1, 2, 3},
			count = 0,
			cycle_time = 0,
			entity = "",
			initial_spawn_animation = "idle",
			node_offset = 0,
			pos_offset = tpl["pos_offset"]:clone()
		}
	end,
	["spell"] = function(tpl)
		return {}
	end,
	["spell_attack"] = function(tpl)
		return {
			animation = "cast",
			cast_time = 0,
			chance = 1,
			max_range = 0,
			min_range = 0,
			spell = "",
			ts = 0,
			type = "spell",
			vis_bans = 0,
			vis_flags = 0
		}
	end,
	["sprite"] = function(tpl)
		return {
			alpha = 255,
			anchor = tpl["anchor"]:clone(),
			animated = true,
			flip_x = false,
			frame_idx = 1,
			hidden_count = 0,
			loop = true,
			name = "idle",
			offset = tpl["offset"]:clone(),
			r = 0,
			runs = 0,
			time_offset = 0,
			ts = 0,
			z = 3000
		}
	end,
	["taunt_set"] = function(tpl)
		return {
			end_idx = 1,
			start_idx = 1
		}
	end,
	["taunts"] = function(tpl)
		return {
			delay_max = 20,
			delay_min = 15,
			duration = 4,
			next_ts = 0,
			offset = tpl["offset"]:clone(),
			sets = {},
			ts = 0
		}
	end,
	["teleport"] = function(tpl)
		return {
			animations = {"teleport_out", "teleport_in"},
			delay = 0,
			min_distance = 0
		}
	end,
	["text"] = function(tpl)
		return {
			alignment = "center",
			color = {94, 217, 229},
			font = "Comic Book Italic-13",
			size = tpl["size"]:clone(),
			text = ""
		}
	end,
	["texts"] = function(tpl)
		return {
			list = {
				[1] = {
					alignment = "center",
					color = {94, 217, 229},
					font = "Comic Book Italic-13",
					size = tpl["list"][1]["size"]:clone(),
					text = ""
				}
			}
		}
	end,
	["timed"] = function(tpl)
		return tpl:clone()
	end,
	["timed_actions"] = function(tpl)
		return {
			list = {}
		}
	end,
	["timed_attacks"] = function(tpl)
		return {
			list = {}
		}
	end,
	["tower"] = function(tpl)
		return {
			block_count = 0,
			can_be_mod = true,
			can_be_sold = true,
			can_do_magic = true,
			can_hover = true,
			cooldown_factor = 1,
			cooldown_factor_divider = 1,
			damage_factor = 1,
			default_rally_pos = tpl["default_rally_pos"]:clone(),
			long_idle_cooldown = 3,
			long_idle_pos = tpl["long_idle_pos"]:clone(),
			menu_offset = tpl["menu_offset"]:clone(),
			name = "",
			price = 0,
			range_offset = tpl["range_offset"]:clone(),
			refund_factor = 0.6,
			silence_cast_count = 0,
			size = 1,
			spent = 0
		}
	end,
	["tower_holder"] = function(tpl)
		return {
			blocked = false,
			preview_ids = {},
			unblock_price = 0
		}
	end,
	["tower_upgrade_persistent_data"] = function(tpl)
		return {
			current_mode = 0,
			max_current_mode = 0,
			upgrade_functions = {}
		}
	end,
	["track_damage"] = function(tpl)
		return {
			damaged = {}
		}
	end,
	["track_kills"] = function(tpl)
		return {
			killed = {}
		}
	end,
	["transfer"] = function(tpl)
		return {
			animations = {"transfer_start", "transfer_loop", "transfer_end"},
			extra_speed = 90,
			min_distance = 0
		}
	end,
	["tunnel"] = function(tpl)
		return {
			entrance_nodes = 15,
			exit_nodes = 15,
			picked_enemies = {},
			speed_factor = 2
		}
	end,
	["tween"] = function(tpl)
		return {
			props = {
				[1] = {
					keys = {},
					loop = false,
					name = "alpha",
					sprite_id = 1
				}
			},
			remove = true,
			reverse = false
		}
	end,
	["tween_prop"] = function(tpl)
		return {
			keys = {},
			loop = false,
			name = "alpha",
			sprite_id = 1
		}
	end,
	["ui"] = function(tpl)
		return {
			can_click = true,
			can_select = true,
			click_rect = {
				pos = tpl["click_rect"]["pos"]:clone(),
				size = tpl["click_rect"]["size"]:clone()
			},
			z = 0
		}
	end,
	["unit"] = function(tpl)
		return {
			blood_color = "red",
			can_disintegrate = true,
			can_explode = true,
			cooldown_factor = 1,
			cooldown_factor_divider = 1,
			damage_buff = 0,
			damage_factor = 1,
			death_animation = "death",
			disintegrate_fx = "fx_enemy_desintegrate",
			explode_fx = "fx_unit_explode",
			hit_offset = tpl["hit_offset"]:clone(),
			level = 0,
			marker_offset = tpl["marker_offset"]:clone(),
			mod_offset = tpl["mod_offset"]:clone(),
			price = 0,
			show_blood_pool = true,
			size = 1,
			stun_count = 0
		}
	end,
	["user_power"] = function(tpl)
		return {
			level = 1
		}
	end,
	["user_selection"] = function(tpl)
		return {
			allowed = false
		}
	end,
	["vis"] = function(tpl)
		return {
			bans = 0,
			flags = 0
		}
	end,
	["water"] = function(tpl)
		return {
			angles_flip_vertical = {
				walk = true
			},
			speed_factor = 1,
			sprite_suffix = "_water",
			vis_bans = 33554433
		}
	end
}
