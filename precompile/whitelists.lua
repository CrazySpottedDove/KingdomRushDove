--- 按脚本族维护的编译期常量路径
--- 同一族（如 arrow.insert / arrow.update）共用一份；不同族可以不同。
require("lib.klua.table")

local M = {}

M.enemies = table.to_map({
	"render",
	"render.sprites",
	"render.sprites.1.angles",
	"render.sprites.1.angles.walk",
	"render.sprites.1.angles_custom",
	"render.sprites.1.angles_custom.walk",
	"render.sprites.1.angles_flip_horizontal",
	"render.sprites.1.angles_flip_vertical",
	"render.sprites.1.angles_stickiness",
	"render.sprites.1.angles_stickiness.walk",
	"render.sprites.1.ignore_start",
	"render.sprites.1.animated",
	"heading",
	"melee",
	"melee.attacks",
	"ranged",
	"ranged.attacks",
	"auras",
	"auras.list",
	"water",
	"cliff",
	"teleport",
	"enemy",
	"unit",
	"health",
	"motion",
	"pos",
	"nav_path",
	"spawn_data",
	"vis",
	"health_bar",
	"regen",
	"powers",
	"track_kills",
	"track_damage",
	"sound_events"
})

M.soldiers = table.to_map({
	"render",
	"render.sprites",
	"melee",
	"melee.attacks",
	"ranged",
	"ranged.attacks",
	"auras",
	"auras.list",
	"unit",
	"health",
	"motion",
	"pos",
	"nav_path",
	"vis",
	"health_bar",
	"regen",
	"powers",
	"soldier",
	"track_kills",
	"track_damage",
	"sound_events"
})

M.arrow = table.to_map({
	"bullet",
	"render",
	"render.sprites",
	"sound_events",
	"bullet.flight_time_min",
	"bullet.flight_time_per_dist",
	"bullet.reset_to_target_pos",
	"bullet.ignore_hit_offset",
	"bullet.predict_target_pos",
	"bullet.straight_forward_distance",
	"bullet.rotation_speed",
	"bullet.hide_radius",
	"bullet.particles_name",
	"bullet.damage_min_inc",
	"bullet.damage_max_inc",
	"bullet.hit_fx",
	"bullet.hit_blood_fx",
	"bullet.asymmetrical",
	"bullet.hit_chance",
	"bullet.miss_fx_water",
	"bullet.miss_fx",
	"bullet.miss_decal",
	"bullet.miss_decal_rotation",
	"bullet.miss_decal_anchor",
	"bullet.payload",
	"bullet.payload_props",
	"bullet.mod",
	"bullet.mods",
	"sound_events.raise",
	"use_blood_color",
	"aura"
})

M.bomb = table.to_map({
	"bullet",
	"render",
	"render.sprites",
	"sound_events",
	"bullet.use_hit_offset",
	"bullet.rotation_speed",
	"bullet.hide_radius",
	"bullet.damage_radius_inc",
	"bullet.damage_min_inc",
	"bullet.damage_max_inc",
	"bullet.particles_name",
	"bullet.pop",
	"bullet.hit_fx_water",
	"bullet.hit_decal",
	"bullet.hit_fx",
	"bullet.align_with_trajectory",
	"sound_events.hit",
	"sound_events.hit_water"
})

M.bolt = table.to_map({
	"bullet",
	"render",
	"render.sprites",
	"sound_events",
	"bullet.particles_name",
	"bullet.ignore_rotation",
	"bullet.ignore_hit_offset",
	"bullet.hit_fx",
	"bullet.store",
	"sound_events.summon",
	"sound_events.travel",
	"render.sprites.1",
	"render.sprites.1.size_names"
})

M.mod_dps = table.to_map({
	"modifier",
	"dps",
	"render",
	"render.sprites",
	"dps.damage_first",
	"dps.damage_inc",
	"dps.damage_every",
	"dps.fx",
	"dps.fx_every",
	"dps.fx_tracks_target",
	"dps.fx_target_flip",
	"dps.damage_last",
	"dps.kill",
	"modifier.use_mod_offset",
	"render.sprites.1",
	"render.sprites.1.size_names",
	"render.sprites.1.size_scales",
	"render.sprites.1.use_blood_color"
})

M.mod_track_target = table.to_map({"modifier", "render", "render.sprites", "modifier.duration", "modifier.last_node", "modifier.health_bar_offset", "modifier.use_mod_offset", "render.sprites.1", "render.sprites.1.size_names"})

M.aura_apply_mod = table.to_map({
	"aura",
	"render",
	"render.sprites",
	"aura.with_fade",
	"aura.apply_duration",
	"aura.cycles",
	"aura.max_count",
	"aura.track_source",
	"aura.track_dead",
	"aura.track_target",
	"aura.vis_bans",
	"aura.vis_flags",
	"aura.apply_delay",
	"aura.targets_per_cycle",
	"aura.duration",
	"aura.source_vis_flags",
	"aura.requires_alive_source",
	"aura.cast_resets_sprite_id",
	"aura.hide_source_fx",
	"aura.allowed_templates",
	"aura.excluded_templates",
	"aura.filter_source",
	"aura.mods",
	"aura.mod",
	"aura.duration_inc",
	"aura.use_mod_offset",
	"ps_names",
	"ps_spread_follow_radius"
})

M.aura_apply_damage = table.to_map({
	"aura",
	"render",
	"render.sprites",
	"aura.cycles",
	"aura.duration",
	"aura.duration_inc",
	"aura.track_source",
	"aura.allowed_templates",
	"aura.excluded_templates",
	"aura.vis_bans",
	"aura.vis_flags",
	"aura.filter_source",
	"aura.damage_inc",
	"aura.hide_source_fx",
	"aura.mods",
	"aura.mod"
})

M.nullable = {
	mod_dps = table.to_map({"dps.fx"})
}

return M
