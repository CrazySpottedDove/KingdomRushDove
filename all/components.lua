-- chunkname: @./all/components.lua

local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")

require("constants")

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function r(x, y, w, h)
	return {
		pos = v(x, y),
		size = v(w, h)
	}
end

local function fts(v)
	return v / FPS
end

local pos = E:register_c("pos")

pos.x = 0
pos.y = 0

local heading = E:register_c("heading")

heading.angle = 0

local health = E:register_c("health")

health.hp_max = 10
health.hp = nil
health.hp_healed = nil
health.dead = false
health.dead_lifetime = 2
health.ignore_damage = false
health.ignore_delete_after = nil
health.armor_buff = 0
health.magic_armor_buff = 0
health.armor = 0
health.magic_armor = 0
health.poison_armor = 0
health.spiked_armor = 0
health.damage_factor = 1
health.damage_factor_magical = 1
health.immune_to = 0
health.last_damage_types = 0
health.on_damage = nil
health.delete_after = nil
health.death_ts = 0
health.instakill_resistance = 0
health.armor_resilience = 0

-- controable: 可操控

local health_bar = E:register_c("health_bar")

health_bar.offset = v(0, 35)
health_bar.type = HEALTH_BAR_SIZE_SMALL
health_bar.hidden = false
health_bar.z = Z_OBJECTS
health_bar.draw_order = nil
health_bar.sort_y_offset = nil
health_bar.frames = {}

local regen = E:register_c("regen")

regen.health = nil
regen.cooldown = 0
regen.ignore_stun = nil
regen.ignore_freeze = nil
regen.ts_counter = 0
regen.last_hit_standoff_time = 2
regen.last_hit_ts = 0
regen.is_idle = nil
regen.ts = 0

local damage = E:register_c("damage")

damage.damage_type = DAMAGE_TRUE
damage.value = 0
damage.reduce_armor = 0
damage.reduce_magic_armor = 0
damage.sfx = nil
damage.pop = nil
damage.pop_chance = nil
damage.pop_conds = nil
damage.track_kills = nil
damage.track_damage = nil
damage.target_id = nil
damage.source_id = nil
damage.damage_applied = nil
damage.damage_result = 0
damage.xp_dest_id = nil
damage.xp_gain_factor = nil

local motion = E:register_c("motion")

motion.dest = v(0, 0)
motion.forced_waypoint = nil
motion.invulnerable = nil
motion.max_speed = 0
motion.factor = 1
motion.buff = 0
motion.real_speed = 0
motion.speed = v(0, 0)
motion.arrived = true

local force_motion = E:register_c("force_motion")

force_motion.a = v(0, 0)
force_motion.v = v(0, 0)
force_motion.fr = 0.1
force_motion.a_step = 10
force_motion.max_a = nil
force_motion.max_v = nil
force_motion.ramp_radius = nil
force_motion.ramp_min_factor = 0.1
force_motion.ramp_max_factor = 1

local nav_path = E:register_c("nav_path")

nav_path.pi = 1
nav_path.spi = 1
nav_path.ni = 1
nav_path.dir = 1
nav_path.prev_pis = nil

local nav_rally = E:register_c("nav_rally")

nav_rally.pos = v(0, 0)
nav_rally.center = nil
nav_rally.requires_node_nearby = true
nav_rally.immune_to = band(DAMAGE_ALL_TYPES, bnot(DAMAGE_POISON))
nav_rally.new = false

local nav_grid = E:register_c("nav_grid")

nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_ICE)
nav_grid.valid_terrains_dest = bor(TERRAIN_LAND, TERRAIN_ICE)
nav_grid.waypoints = {}
nav_grid.ignore_waypoints = nil

local fade = E:register_c("fade")

fade.duration = 0
fade.after = 0
fade.ts = 0

local tween_prop = E:register_c("tween_prop")

tween_prop.name = "alpha"
tween_prop.disabled = nil
tween_prop.ignore_reverse = nil
tween_prop.interp = nil
tween_prop.keys = {}
tween_prop.loop = false
tween_prop.multiply = nil
tween_prop.sprite_id = 1
tween_prop.time_offset = nil
tween_prop.ts = nil

local tween = E:register_c("tween")

tween.props = {}
tween.props[1] = E:clone_c("tween_prop")
tween.remove = true
tween.reverse = false
tween.disabled = nil
tween.run_once = nil
tween.ts = nil
tween.random_ts = nil

local timed = E:register_c("timed")

timed.duration = nil
timed.runs = 1
timed.sprite_id = 1
timed.disabled = nil

local delayed_play = E:register_c("delayed_play")

delayed_play.min_delay = 1
delayed_play.max_delay = 5
delayed_play.play_duration = nil
delayed_play.flip_chance = 0
delayed_play.idle_animation = "idle"
delayed_play.play_animation = "play"
delayed_play.clicked_animation = "clicked"
delayed_play.loop_idle = false
delayed_play.loop_play = false
delayed_play.play_sound = nil
delayed_play.click_sound = nil
delayed_play.clicked_sound = nil
delayed_play.required_clicks = nil
delayed_play.required_clicks_fx = nil
delayed_play.required_clicks_hides = nil
delayed_play.play_once = nil
delayed_play.click_interrupts = nil
delayed_play.achievement = nil
delayed_play.achievement_flag = nil
delayed_play.disabled = nil
delayed_play.delay = nil

local sequence = E:register_c("sequence")

sequence.steps = {}
sequence.fxs = {}
sequence.sprite_id = 1
sequence.loop = false

local delayed_sequence = E:register_c("delayed_sequence")

delayed_sequence.animations = {}
delayed_sequence.min_delay = 1
delayed_sequence.max_delay = 5
delayed_sequence.random = nil

local click_play = E:register_c("click_play")

click_play.idle_animation = "idle"
click_play.click_animation = "clicked"
click_play.required_clicks = 1
click_play.achievement = nil
click_play.achievement_flag = nil
click_play.play_once = false

local sprite = E:register_c("sprite")

sprite.animated = true
sprite.group = nil
sprite.prefix = nil
sprite.name = "idle"
sprite.anchor = v(0.5, 0.5)
sprite.offset = v(0, 0)
sprite.pos = nil
sprite.loop = true
sprite.loop_forced = nil
sprite.flip_x = false
sprite.r = 0
sprite.scale = nil
sprite.angles = nil
sprite.angles_flip_horizontal = nil
sprite.angles_flip_vertical = nil
sprite.angles_custom = nil
sprite.angles_stickiness = nil
sprite.alpha = 255
sprite.hidden = nil
sprite.hidden_count = 0
sprite.z = Z_OBJECTS
sprite.draw_order = nil
sprite.size_names = nil
sprite.size_scales = nil
sprite.sort_y = nil
sprite.sort_y_offset = nil
sprite.sync_idx = nil
sprite.time_offset = 0
sprite.hide_after_runs = nil
sprite.fps = nil
sprite.random_ts = nil
sprite.ignore_start = nil
sprite.ts = 0
sprite.runs = 0
sprite.frame_idx = 1
sprite.frame_name = nil
sprite.sync_flag = nil

local render = E:register_c("render")

render.sprites = {}
render.sprites[1] = E:clone_c("sprite")
render.frames = {}

local text = E:register_c("text")

text.text = ""
text.size = v(0, 0)
text.font = "Comic Book Italic-13"
text.color = {
	94,
	217,
	229
}
text.alignment = "center"
text.sprite_id = nil
text.debug_bg = nil

local texts = E:register_c("texts")

texts.list = {}
texts.list[1] = E:clone_c("text")

local particle_system = E:register_c("particle_system")

particle_system.alphas = {
	255
}
particle_system.anchor = v(0.5, 0.5)
particle_system.animated = false
particle_system.animation_fps = nil
particle_system.cycle_names = nil
particle_system.draw_order = nil
particle_system.emission_rate = 1
particle_system.emit = true
particle_system.emit_area_spread = nil
particle_system.emit_direction = 0
particle_system.emit_duration = nil
particle_system.emit_offset = nil
particle_system.emit_rotation = nil
particle_system.emit_rotation_spread = 0
particle_system.emit_speed = nil
particle_system.emit_spread = 0
particle_system.loop = true
particle_system.name = nil
particle_system.names = nil
particle_system.particle_lifetime = {
	0.9,
	1
}
particle_system.scale_same_aspect = true
particle_system.scale_var = nil
particle_system.scales_x = nil
particle_system.scales_y = nil
particle_system.sort_y = nil
particle_system.sort_y_offset = nil
particle_system.sort_y_offsets = nil
particle_system.source_lifetime = nil
particle_system.spin = nil
particle_system.track_id = nil
particle_system.track_offset = nil
particle_system.track_rotation = nil
particle_system.ts_offset = 0
particle_system.z = Z_BULLET_PARTICLES
particle_system.frames = {}
particle_system.particles = {}

local main_script = E:register_c("main_script")

main_script.insert = nil
main_script.update = nil
main_script.remove = nil
main_script.runs = 1
main_script.co = nil

local power = E:register_c("power")

power.max_level = 3
power.level = 0
power.price_base = 0
power.price_inc = 0
power.changed = nil
power.name = nil
power.enc_icon = nil
power.on_power_upgrade = nil

local powers = E:register_c("powers")
local user_power = E:register_c("user_power")

user_power.level = 1

local user_item = E:register_c("user_item")
local water = E:register_c("water")

water.vis_bans = bor(F_BLOCK, F_SKELETON)
water.sprite_suffix = "_water"
water.angles_flip_vertical = {
	walk = true
}
water.speed_factor = 1
water.hit_offset = nil
water.mod_offset = nil
water.health_bar_offset = nil
water.health_bar_hidden = nil
water.last_terrain_type = nil

local cliff = E:register_c("cliff")

cliff.vis_bans = bor(F_BLOCK, F_SKELETON, F_BURN, F_DRILL)
cliff.sprite_suffix = "_cliff"
cliff.hide_sprite_ids = nil
cliff.speed_factor = 0.7
cliff.fall_accel = 300
cliff.last_terrain_type = nil
cliff.fall_to_pos = nil

local user_selection = E:register_c("user_selection")

user_selection.allowed = false
user_selection.custom_pointer_name = nil
user_selection.in_progress = nil
user_selection.menu_shown = nil
user_selection.can_select_point_fn = nil
user_selection.ignore_point = nil
user_selection.new_pos = nil
user_selection.arg = nil

local ui = E:register_c("ui")

ui.can_click = true
ui.can_select = true
ui.can_hover = nil
ui.can_drag = nil
ui.click_proxies = nil
ui.click_rect = r(-10, -10, 20, 20)
ui.hover_active = nil
ui.hover_controller_active = nil
ui.args = nil
ui.clicked = nil
ui.alert_view = nil
ui.z = 0
ui.has_nav_mesh = nil
ui.nav_mesh_id = nil
ui.hover_sprite_name = nil
ui.hover_sprite_anchor = nil

local info = E:register_c("info")

info.fn = nil
info.portrait = nil
info.hero_portrait = nil
info.i18n_key = nil
info.enc_icon = nil
info.damage_icon = nil
info.ultimate_icon = nil
info.ultimate_pointer_style = nil

local unit = E:register_c("unit")

unit.name = nil
unit.size = UNIT_SIZE_SMALL
unit.blood_color = BLOOD_RED
unit.can_explode = true
unit.can_disintegrate = true
unit.explode_fx = "fx_unit_explode"
unit.disintegrate_fx = "fx_enemy_desintegrate"
unit.death_animation = "death"
unit.show_blood_pool = true
unit.hit_offset = v(0, 0)
unit.mod_offset = v(0, 0)
unit.marker_offset = v(0, 0)
unit.marker_hidden = nil
unit.pop_offset = nil
unit.damage_factor = 1
unit.level = 0
unit.ignore_stun = nil
unit.is_stunned = nil
unit.stun_count = 0
unit.hide_after_death = nil
unit.hide_during_death = nil
unit.fade_time_after_death = nil
unit.spawner_id = nil
unit.price = 0

local tower = E:register_c("tower")

tower.can_be_mod = true
tower.can_be_sold = true
tower.can_do_magic = true
tower.damage_factor = 1
tower.cooldown_factor = 1
tower.default_rally_pos = v(0, 0)
tower.flip_x = nil
tower.hide_dust = nil
tower.level = nil
tower.name = ""
tower.price = 0
tower.range_offset = v(0, 12)
tower.menu_offset = v(0, 2)
tower.refund_factor = 0.6
tower.size = TOWER_SIZE_SMALL
tower.terrain_style = nil
tower.type = nil
tower.can_hover = true
tower.long_idle_cooldown = 3
tower.long_idle_pos = v(REF_W, 0)
tower.block_count = 0
tower.blocked = nil
tower.destroy = nil
tower.holder_id = nil
tower.sell = nil
tower.spent = 0
tower.upgrade_to = nil
tower.guard_time = fts(1)

local tower_holder = E:register_c("tower_holder")

tower_holder.blocked = false
tower_holder.unblock_price = 0
tower_holder.preview_ids = {}
tower_holder.custom = nil

local enemy = E:register_c("enemy")

enemy.name = nil
enemy.can_do_magic = true
enemy.can_accept_magic = true
enemy.blockers = {}
enemy.max_blockers = nil
enemy.melee_slot = v(38, 0)
enemy.necromancer_offset = v(0, 0)
enemy.valid_terrains = TERRAIN_LAND
enemy.gold = 0
enemy.gold_bag = 0
enemy.lives_cost = 1
enemy.gems = 0
enemy.counts = {}
enemy.remove_at_goal_line = true

local soldier = E:register_c("soldier")

soldier.name = nil
soldier.tower_id = nil
soldier.melee_slot_offset = v(0, 0)
soldier.target_id = nil
-- -- max_targets 不为 nil 时，允许士兵拦截多个敌方单位
-- soldier.max_targets = nil
-- soldier.target_ids = nil
soldier.courage_ts = 0
soldier.guard_time = fts(1)

local reinforcement = E:register_c("reinforcement")

reinforcement.duration = 21
reinforcement.fade = true
reinforcement.fade_in = nil
reinforcement.fade_out = nil
reinforcement.hp_before_timeout = nil

local lifespan = E:register_c("lifespan")

lifespan.duration = 21
lifespan.fade = false
lifespan.ts = 0

local hero = E:register_c("hero")

hero.level = 1
hero.xp = 0
hero.xp_queued = 0
hero.level_stats = {}
hero.skills = {}
hero.fixed_stat_health = nil
hero.fixed_stat_attack = nil
hero.fixed_stat_range = nil
hero.fixed_stat_speed = nil
hero.stage_hero = nil
hero.tombstone_show_time = nil
hero.tombstone_decal = "decal_hero_tombstone"
hero.respawn_point = nil
hero.use_custom_spawn_point = nil

local hero_skill = E:register_c("hero_skill")

hero_skill.name = nil
hero_skill.level = 0
hero_skill.xp_gain_factor = 1
hero_skill.xp_gain = nil
hero_skill.xp_level_steps = nil
hero_skill.hr_order = 1
hero_skill.hr_cost = nil
hero_skill.hr_icon = nil

local barrack = E:register_c("barrack")

barrack.max_soldiers = 3
barrack.soldier_type = ""
barrack.rally_range = 0
barrack.rally_radius = 25
barrack.rally_angle_offset = 0
barrack.rally_terrains = bor(TERRAIN_LAND, TERRAIN_ICE)
barrack.rally_anywhere = nil
barrack.has_door = true
barrack.door_hold_time = fts(15)
barrack.door_open = false
barrack.door_open_ts = 0
barrack.soldiers = {}
barrack.rally_pos = nil
barrack.rally_new = false
barrack.unit_bought = nil

local melee_attack = E:register_c("melee_attack")

melee_attack.type = "melee"
melee_attack.animation = "attack"
melee_attack.duration = nil
melee_attack.cooldown = nil
melee_attack.cooldown_group = nil
melee_attack.shared_cooldown = nil
melee_attack.fn_can = nil
melee_attack.fn_chance = nil
melee_attack.fn_damage = nil
melee_attack.hit_time = nil
melee_attack.hit_times = nil
melee_attack.interrupt_on_dead_target = nil
melee_attack.interrupt_loop_on_dead_target = nil
melee_attack.dodge_time = fts(4)
melee_attack.damage_min = 0
melee_attack.damage_max = 0
melee_attack.damage_inc = nil
melee_attack.damage_min_inc = nil
melee_attack.damage_max_inc = nil
melee_attack.damage_type = DAMAGE_PHYSICAL
melee_attack.ignore_stun = nil
melee_attack.ignore_rally_change = nil
melee_attack.instakill = false
melee_attack.loops = nil
melee_attack.chance = 1
melee_attack.chance_inc = nil
melee_attack.level = 0
melee_attack.xp_gain_factor = nil
melee_attack.xp_from_skill = nil
melee_attack.xp_dest_id = nil
melee_attack.vis_flags = 0
melee_attack.vis_bans = 0
melee_attack.disabled = nil
melee_attack.hit_fx = nil
melee_attack.hit_fx_offset = nil
melee_attack.hit_decal = nil
melee_attack.hit_decal_offset = nil
melee_attack.sound = nil
melee_attack.sound_hit = nil
melee_attack.sound_args = nil
melee_attack.track_damage = nil
melee_attack.pop = {
	"pop_sok",
	"pop_pow"
}
melee_attack.pop_chance = 0.1
melee_attack.ts = 0

local spell_attack = E:register_c("spell_attack")

spell_attack.type = "spell"
spell_attack.spell = ""
spell_attack.animation = "cast"
spell_attack.min_range = 0
spell_attack.max_range = 0
spell_attack.cooldown = nil
spell_attack.cast_time = 0
spell_attack.chance = 1
spell_attack.vis_flags = 0
spell_attack.vis_bans = 0
spell_attack.sound = nil
spell_attack.ts = 0

local bullet_attack = E:register_c("bullet_attack")

bullet_attack.animation = "shoot"
bullet_attack.bullet = ""
bullet_attack.bullet_start_offset = nil
bullet_attack.bullet_shot_start_offset = nil
bullet_attack.chance = 1
bullet_attack.cooldown = nil
bullet_attack.damage_factor = nil
bullet_attack.filter_fn = nil
bullet_attack.hold_advance = nil
bullet_attack.check_target_before_shot = nil
bullet_attack.ignore_hit_offset = nil
bullet_attack.ignore_stun = nil
bullet_attack.level = 1
bullet_attack.loops = nil
bullet_attack.max_range = 0
bullet_attack.min_range = 0
bullet_attack.range_inc = nil
bullet_attack.max_track_distance = REF_H / 6
bullet_attack.node_prediction = nil
bullet_attack.requires_magic = true
bullet_attack.reset_to_target_pos = nil
bullet_attack.shoot_time = 0
bullet_attack.shoot_times = nil
bullet_attack.sprite_group = nil
bullet_attack.sync_animation = nil
bullet_attack.type = "bullet"
bullet_attack.vis_bans = 0
bullet_attack.vis_flags = F_RANGED
bullet_attack.count = 0
bullet_attack.ts = 0
bullet_attack.target_pos = nil

local area_attack = E:register_c("area_attack")

area_attack.animation = "attack"
area_attack.chance = 1
area_attack.cooldown = nil
area_attack.count = nil
area_attack.min_count = nil
area_attack.damage_max = 0
area_attack.damage_min = 0
area_attack.damage_radius = 0
area_attack.damage_type = DAMAGE_EXPLOSION
-- area_attack.dodge_time = nil
area_attack.dodge_time = fts(4)
area_attack.fn_filter = nil
area_attack.hit_decal = nil
area_attack.hit_fx = nil
area_attack.hit_fx_offset = nil
area_attack.hit_time = nil
area_attack.hit_times = nil
area_attack.hit_offset = nil
area_attack.instakill = false
area_attack.level = 1
area_attack.max_range = 0
area_attack.min_range = 0
area_attack.mod = nil
area_attack.signal = nil
area_attack.sound = nil
area_attack.sound_args = nil
area_attack.type = "area"
area_attack.vis_bans = F_FLYING
area_attack.vis_flags = F_RANGED
area_attack.damage_bans = F_FLYING
area_attack.damage_flags = F_AREA
area_attack.ts = 0

local aura_attack = E:register_c("aura_attack")

aura_attack.type = "aura"
aura_attack.bullet = nil
aura_attack.cooldown = nil
aura_attack.interrupt_to_cast = nil
aura_attack.ts = 0

local mod_attack = E:register_c("mod_attack")

mod_attack.type = "mod"
mod_attack.mod = nil
mod_attack.cast_time = nil
mod_attack.chance = 1
mod_attack.vis_flags = 0
mod_attack.vis_bans = 0
mod_attack.ts = 0

local spawn_attack = E:register_c("spawn_attack")

spawn_attack.type = "spawn"
spawn_attack.entity = ""
spawn_attack.cooldown = nil
spawn_attack.chance = 1
spawn_attack.spawn_time = nil
spawn_attack.animation = nil
spawn_attack.ts = 0
spawn_attack.vis_bans = 0
spawn_attack.vis_flags = 0
spawn_attack.disabled = nil

local custom_attack = E:register_c("custom_attack")

custom_attack.type = "custom"
custom_attack.cooldown = nil
custom_attack.chance = 1
custom_attack.ts = 0
custom_attack.vis_flags = 0
custom_attack.vis_bans = 0

local melee = E:register_c("melee")

melee.continue_in_cooldown = nil
melee.range = nil
melee.cooldown = nil
melee.fn_can_pick = nil
melee.forced_cooldown = nil
melee.arrived_slot_animation = "idle"
melee.attacks = {}
melee.attacks[1] = E:clone_c("melee_attack")
melee.order = {
	1
}
melee.last_attack = nil
melee.forced_ts = 0

local ranged = E:register_c("ranged")

ranged.range = nil
ranged.cooldown = nil
ranged.forced_cooldown = nil
ranged.go_back_during_cooldown = nil
ranged.range_while_blocking = nil
ranged.attacks = {}
ranged.attacks[1] = E:clone_c("bullet_attack")
ranged.order = {
	1
}
ranged.forced_ts = 0

local timed_attacks = E:register_c("timed_attacks")

timed_attacks.list = {}

local timed_actions = E:register_c("timed_actions")

timed_actions.list = {}

local attacks = E:register_c("attacks")

attacks.range = 0
attacks.cooldown = nil
attacks.hide_range = nil
attacks.list = {}
attacks.order = {}

local auras = E:register_c("auras")

auras.list = {}

local revive = E:register_c("revive")

revive.disabled = true
revive.chance = 0
revive.health_recover = 0
revive.health_recover_inc = 0
revive.animation = nil
revive.fx = nil
revive.hit_time = 0
revive.power_name = nil
revive.remove_modifiers = true
revive.sound = nil
revive.ts = 0
revive.last_target_id = nil
revive.resist = nil
revive.protect = 0

local death_spawns = E:register_c("death_spawns")

death_spawns.name = ""
death_spawns.quantity = 1
death_spawns.spread_nodes = 0
death_spawns.concurrent_with_death = nil
death_spawns.delay = nil
death_spawns.offset = nil
death_spawns.spawn_animation = nil
death_spawns.no_spawn_damage_types = nil
death_spawns.fx = nil
death_spawns.fx_flip_to_source = nil

local dodge = E:register_c("dodge")

dodge.chance = 0
dodge.cooldown = nil
dodge.animation = nil
dodge.ranged = nil
dodge.requires_magic = true
dodge.counter_attack = nil
dodge.time_before_hit = nil
dodge.can_dodge = nil
dodge.silent = nil
dodge.counter_attack_pending = false
dodge.active = false
dodge.ts = 0
dodge.last_attack = nil

local vis = E:register_c("vis")

vis.flags = 0
vis.bans = 0

local cloak = E:register_c("cloak")

cloak.flags = 0
cloak.bans = 0
cloak.alpha = nil

local pickpocket = E:register_c("pickpocket")

pickpocket.chance = 0
pickpocket.chance_inc = nil
pickpocket.steal_min = 0
pickpocket.steal_max = 0

local idle_flip = E:register_c("idle_flip")

idle_flip.cooldown = 5
idle_flip.chance = 0.4
idle_flip.walk_dist = 0
idle_flip.animations = nil
idle_flip.loop = true
idle_flip.ts = 0
idle_flip.last_dir = 1
idle_flip.last_animation = "idle"
idle_flip.ts_counter = 0

local spawner = E:register_c("spawner")

spawner.allowed_subpaths = {
	1,
	2,
	3
}
spawner.animation_loop = nil
spawner.animation_end = nil
spawner.animation_start = nil
spawner.check_node_valid = nil
spawner.count = 0
spawner.count_group_name = nil
spawner.count_group_type = nil
spawner.count_group_max = nil
spawner.cycle_time = 0
spawner.entity = ""
spawner.eternal = nil
spawner.forced_waypoint_offset = nil
spawner.initial_spawn_animation = "idle"
spawner.keep_gold = nil
spawner.name = nil
spawner.node_offset = 0
spawner.patch_props = nil
spawner.pos_offset = v(0, 0)
spawner.random_cycle = nil
spawner.random_subpath = nil
spawner.random_node_offset_range = nil
spawner.use_node_pos = nil
spawner.pi = nil
spawner.spi = nil
spawner.ni = nil
spawner.interrupt = nil
spawner.spawn_data = nil

local graveyard = E:register_c("graveyard")

graveyard.dead_time = 0.5
graveyard.spawn_interval = 0.1
graveyard.spawns_by_health = nil
graveyard.spawn_pos = nil
graveyard.excluded_templates = nil
graveyard.vis_bans = 0
graveyard.vis_flags = 0
graveyard.vis_has = 0
graveyard.pi = nil

local track_kills = E:register_c("track_kills")

track_kills.mod = nil
track_kills.killed = {}

local track_damage = E:register_c("track_damage")

track_damage.mod = nil
track_damage.damaged = {}

local modifier = E:register_c("modifier")

modifier.target_id = nil
modifier.source_id = nil
modifier.level = 1
modifier.duration = nil
modifier.last_node = nil
modifier.bans = nil
modifier.ban_types = nil
modifier.vis_bans = 0
modifier.vis_flags = 0
modifier.allows_duplicates = nil
modifier.max_duplicates = nil
modifier.replaces_lower = true
modifier.resets_same = true
modifier.resets_same_tween = nil
modifier.resets_same_tween_offset = nil
modifier.use_mod_offset = true
modifier.health_bar_offset = nil
modifier.remove_banned = nil
modifier.removed_by_ban = nil
modifier.damage_factor = 1
modifier.ts = 0
modifier.type = nil

local dps = E:register_c("dps")

dps.damage_min = 0
dps.damage_max = 0
dps.damage_inc = 0
dps.damage_last = nil
dps.damage_every = 1
dps.damage_type = DAMAGE_PHYSICAL
dps.kill = true
dps.fx = nil
dps.fx_target_flip = nil
dps.fx_every = nil
dps.fx_tracks_target = nil
dps.ts = 0

local hps = E:register_c("hps")

hps.heal_every = 1
hps.heal_min = 0
hps.heal_max = 0
hps.heal_min_inc = nil
hps.heal_max_inc = nil
hps.fx = nil
hps.ts = 0

local armor_buff = E:register_c("armor_buff")

armor_buff.magic = false
armor_buff.max_factor = 0
armor_buff.step_factor = 0
armor_buff.cycle_time = 1
armor_buff.factor = nil

local heal_on_kill = E:register_c("heal_on_kill")

heal_on_kill.hp = nil

local slow = E:register_c("slow")

slow.factor = 0.5
slow.factor_inc = nil

local fast = E:register_c("fast")

fast.factor = 1
fast.factor_inc = nil

local bullet = E:register_c("bullet")

bullet.acceleration_factor = nil
bullet.align_with_trajectory = nil
bullet.asymmetrical = nil
bullet.damage_bans = 0
bullet.damage_factor = 1
bullet.damage_flags = 0
bullet.damage_max = 0
bullet.damage_min = 0
bullet.damage_radius = 0
bullet.damage_type = DAMAGE_PHYSICAL
bullet.flight_time = nil
bullet.flight_time_base = nil
bullet.flight_time_factor = nil
bullet.from = nil
bullet.g = -1 / (fts(1) * fts(1))
bullet.hide_radius = nil
bullet.hit_decal = nil
bullet.hit_fx = nil
bullet.hit_fx_ignore_hit_offset = nil
bullet.hit_mod = nil
bullet.hit_payload = nil
bullet.ignore_hit_offset = nil
bullet.ignore_rotation = nil
bullet.level = 0
bullet.max_speed = nil
bullet.max_track_distance = REF_H / 12
bullet.min_speed = nil
bullet.miss_decal = nil
bullet.mod = nil
bullet.node_prediction = nil
bullet.particles_name = nil
bullet.payload = nil
bullet.pop = nil
bullet.pop_chance = nil
bullet.pop_conds = nil
bullet.predict_target_pos = nil
bullet.prediction_error = nil
bullet.reduce_armor = 0
bullet.reduce_magic_armor = 0
bullet.rotation_speed = nil
bullet.shot_index = nil
bullet.loop_index = nil
bullet.start_fx = nil
bullet.target_id = nil
bullet.track_damage = nil
bullet.to = nil
bullet.turn_speed = nil
bullet.use_unit_damage_factor = nil
bullet.vis_bans = 0
bullet.vis_flags = 0
bullet.xp_gain_factor = nil
bullet.speed = v(0, 0)
bullet.ts = nil

local spell = E:register_c("spell")

spell.target_id = nil
spell.source_id = nil
spell.ts = nil

local aura = E:register_c("aura")

aura.duration = 0
aura.duration_inc = 0
aura.radius = 0
aura.cycle_time = 0.5
aura.cycles = nil
aura.targets_per_cycle = nil
aura.mod = nil
aura.damage_min = nil
aura.damage_max = nil
aura.damage_inc = nil
aura.damage_type = nil
aura.damage_factor = 1
aura.level = 1
aura.vis_flags = 0
aura.vis_bans = 0
aura.requires_magic = true
aura.filter_source = nil
aura.track_source = false
aura.track_dead = nil
aura.allowed_templates = nil
aura.excluded_templates = nil
aura.source_id = nil
aura.ts = 0
aura.use_mod_offset = true
aura.xp_dest_id = nil
aura.xp_gain_factor = nil

local sound_events = E:register_c("sound_events")

sound_events.mute_on_level_insert = nil
sound_events.insert = nil
sound_events.remove = nil
sound_events.death = nil
sound_events.death_by_explosion = nil
sound_events.new_node = nil
sound_events.change_rally_point = nil
sound_events.insert_args = nil
sound_events.remove_args = nil
sound_events.death_args = nil
sound_events.new_node_args = nil

local tunnel = E:register_c("tunnel")

tunnel.pick_pi = nil
tunnel.pick_ni = nil
tunnel.place_pi = nil
tunnel.place_ni = nil
tunnel.speed_factor = 2
tunnel.entrance_nodes = 15
tunnel.exit_nodes = 15
tunnel.picked_enemies = {}
tunnel.pick_fx = nil
tunnel.place_fx = nil
tunnel.name = nil

local count_group = E:register_c("count_group")

count_group.name = nil
count_group.type = COUNT_GROUP_CONCURRENT
count_group.in_limbo = nil

local mark_flags = E:register_c("mark_flags")

mark_flags.vis_bans = 0
mark_flags.vis_flags = 0

local teleport = E:register_c("teleport")

teleport.min_distance = 0
teleport.animations = {
	"teleport_out",
	"teleport_in"
}
teleport.delay = 0

local polymorph = E:register_c("polymorph")

polymorph.custom_entity_names = {}
polymorph.custom_entity_names.default = nil
polymorph.hit_fx_sizes = nil
polymorph.transfer_lives_cost_factor = nil
polymorph.transfer_gold_factor = nil
polymorph.transfer_health_factor = nil
polymorph.transfer_speed_factor = nil

local selfdestruct = E:register_c("selfdestruct")

selfdestruct.animation = "selfdestruct"
selfdestruct.damage = nil
selfdestruct.damage_min = nil
selfdestruct.damage_max = nil
selfdestruct.damage_radius = nil
selfdestruct.damage_type = DAMAGE_PHYSICAL
selfdestruct.dead_lifetime = nil
selfdestruct.hit_time = nil
selfdestruct.hit_fx = nil
selfdestruct.sound = nil
selfdestruct.sound_args = nil
selfdestruct.sound_hit = nil
selfdestruct.vis_bans = 0
selfdestruct.vis_flags = F_RANGED
selfdestruct.xp_from_skill = nil

local taunts = E:register_c("taunts")

taunts.delay_min = 15
taunts.delay_max = 20
taunts.duration = 4
taunts.sets = {}
taunts.offset = v(0, 0)
taunts.decal_name = nil
taunts.ts = 0
taunts.next_ts = 0

local taunt_set = E:register_c("taunt_set")

taunt_set.format = nil
taunt_set.start_idx = 1
taunt_set.end_idx = 1
taunt_set.idxs = nil
taunt_set.decal_name = nil
taunt_set.pos = nil

local moon = E:register_c("moon")

moon.active = nil
moon.speed_factor = nil
moon.damage_factor = nil
moon.regen_hp = nil
moon.transform_name = nil
moon.lifesteal_damage_factor = nil

local endless = E:register_c("endless")

endless.factor_map = nil

local plant = E:register_c("plant")

plant.block_count = 0
plant.blocked = nil

local crystal = E:register_c("crystal")
local transfer = E:register_c("transfer")

transfer.min_distance = 0
transfer.animations = {
	"transfer_start",
	"transfer_loop",
	"transfer_end"
}
transfer.extra_speed = 3 * FPS

local editor = E:register_c("editor")

editor.game_mode = 0
editor.scaffold = nil
editor.props = nil
editor.device_profile = nil

local editor_script = E:register_c("editor_script")

editor_script.insert = nil
editor_script.remove = nil
editor_script.update = nil
editor_script.runs = 1
editor_script.co = nil
