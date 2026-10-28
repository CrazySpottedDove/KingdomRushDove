local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
local scripts = require("scripts")

require("lib.klua.table")
require("all.constants")

local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local ready_to_attack = U.ready_to_attack
local queue_damage = U.queue_damage

local function aura_slow_update(this, store)
	local last_hit_ts = store.tick_ts - this.aura.cycle_time

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.aura.duration then
			U.animation_start_default(this, "end", nil, store.tick_ts)

			this.tween.disabled = false
			this.tween.ts = store.tick_ts

			return
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)

			if targets then
				for i, target in ipairs(targets) do
					local new_mod = E:create_entity(this.aura.mod)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					simulation:queue_insert_entity(new_mod)
				end
			end
		end

		coroutine.yield()
	end
end

local function decal_mine_update(this, store)
	local ts = store.tick_ts

	while true do
		if store.tick_ts - ts >= this.duration then
			break
		end

		local targets = U.find_enemies_in_range_filter_off(this.pos, this.radius, this.vis_flags, this.vis_bans)

		if targets and #targets > 0 then
			local dec = E:create_entity(this.hit_decal)

			dec.pos:copy(this.pos)

			dec.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(dec)
			S:queue(this.sound)

			local fx = E:create_entity(this.hit_fx)

			fx.pos:copy(this.pos)

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)

			local new_targets = U.find_enemies_in_range_filter_off(this.pos, 2 * this.radius, this.vis_flags, this.vis_bans)

			for _, t in ipairs(new_targets) do
				local d = E.assign_damage(DAMAGE_EXPLOSION, math.random(this.damage_min, this.damage_max), this.id, t.id)

				queue_damage(store, d)
			end

			break
		end

		U.y_wait_unconditional(store, this.check_interval)
	end

	simulation:queue_remove_entity(this)
end

-- 博林
local function hero_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	local rf = this.timed_attacks.list[1]
	local b = E:get_template(rf.bullet)

	b.bullet.damage_min = ls.ranged_damage_min[hl]
	b.bullet.damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "tar", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil

		local tar = E:get_template("aura_bolin_tar")

		tar.duration = s.duration[s.level]
	end)
	upgrade_skill(this, "mines", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil

		local m = E:get_template("decal_bolin_mine")

		m.damage_min = s.damage_min[s.level]
		m.damage_max = s.damage_max[s.level]
	end)

	if hl == 10 then
		this.timed_attacks.list[5].disabled = nil
	end

	update_hp(this)
end

local function hero_update(this, store)
	local h = this.health
	local a, skill, brk, sta

	U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_47_0
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
			end

			a = this.timed_attacks.list[2]
			skill = this.hero.skills.tar

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + 0.5
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + 5

					if not P:is_node_valid(pi, ni) then
						ni = target.nav_path.ni
					end

					if not P:is_node_valid(pi, ni) then
						a.ts = a.ts + 0.5
					else
						local start_ts = store.tick_ts
						local flip = target.pos.x < this.pos.x

						U.animation_start_default(this, "tar", flip, store.tick_ts)
						SU.hero_gain_xp_from_skill(this, skill)

						if U.y_wait_conditional(store, a.shoot_time, function()
							return SU.hero_interrupted(this)
						end) then
						-- block empty
						else
							a.ts = start_ts

							local af = this.render.sprites[1].flip_x
							local b = E:create_entity(a.bullet)
							local o = a.bullet_start_offset

							b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
							b.bullet.to = P:node_pos(pi, spi, ni)

							b.pos:copy(b.bullet.from)

							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)

							if not U.y_animation_wait_default(this) then
								goto label_47_0
							end
						end
					end
				end
			end

			a = this.timed_attacks.list[3]
			skill = this.hero.skills.mines

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

				if not nearest or #nearest < 1 then
					a.ts = a.ts + 0.5
				else
					local mine_pos
					local _, enemy_pos = U.find_random_enemy_with_pos(store, this.pos, a.min_range, a.max_range, fts(24), a.vis_flags, a.vis_bans)

					if enemy_pos then
						mine_pos = enemy_pos
					end

					if not mine_pos then
						local pi, spi, ni = unpack(nearest[1])

						spi = math.random(1, 3)

						local no = math.random(a.node_offset[1], a.node_offset[2])

						ni = ni + no

						if not P:is_node_valid(pi, ni) then
							ni = ni - no
						end

						mine_pos = P:node_pos(pi, spi, ni)
					end

					local start_ts = store.tick_ts
					local flip = mine_pos.x < this.pos.x

					U.animation_start_default(this, "mine", flip, store.tick_ts)
					SU.hero_gain_xp_from_skill(this, skill)

					if U.y_wait_conditional(store, a.shoot_time, function()
						return SU.hero_interrupted(this)
					end) then
					-- block empty
					else
						a.ts = start_ts

						local af = this.render.sprites[1].flip_x
						local b = E:create_entity(a.bullet)
						local o = a.bullet_start_offset

						b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
						b.bullet.to = mine_pos

						b.pos:copy(b.bullet.from)

						b.bullet.source_id = this.id

						simulation:queue_insert_entity(b)

						if not U.y_animation_wait_default(this) then
							goto label_47_0
						end
					end
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			else
				-- 连射或普攻
				if ready_to_use_skill(this.timed_attacks.list[5], store, this.unit.cooldown_factor) then
					a = this.timed_attacks.list[5]
				elseif math.random() < this.timed_attacks.list[4].chance then
					a = this.timed_attacks.list[4]
				else
					a = this.timed_attacks.list[1]
				end

				if ready_to_attack(a, store) then
					local target, targets

					if a.filter_fn then
						target, targets = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn)
					else
						target, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)
					end

					if not target then
					-- block empty
					else
						local b, an, af, ai

						an, af, ai = U.animation_name_facing_point(this, a.aim_animation, target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)
						U.set_destination(this, this.pos)

						for si, st in ipairs(a.shoot_times) do
							if U.y_wait_conditional(store, a.shoot_times[si], function()
								return SU.hero_interrupted(this)
							end) then
								goto label_47_0
							end

							if not target then
							-- block empty
							end

							local target_dist = V.dist(target.pos.x, target.pos.y, this.pos.x, this.pos.y)

							if si > 1 and (not target or target.health.death or not target_dist or not (target_dist >= a.min_range) or target_dist <= a.max_range or true) then
								if a.filter_fn then
									target, targets = U.find_foremost_enemy_between_range_filter_on(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn)
								else
									target, targets = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)
								end

								if not target then
									break
								end
							end

							an, af, ai = U.animation_name_facing_point(this, a.shoot_animation, target.pos)

							U.animation_start_default(this, an, af, store.tick_ts, false)

							if U.y_wait_conditional(store, a.shoot_time, function()
								return SU.hero_interrupted(this)
							end) then
								goto label_47_0
							end

							for i = 1, a.count do
								target = targets[km.zmod(i, #targets)]
								b = E:create_entity(a.bullet)

								b.pos:copy(this.pos)

								b.bullet.damage_type = a.damage_type

								if a == this.timed_attacks.list[4] then
									b.bullet.damage_min = b.bullet.damage_max
									b.bullet.pop = {"pop_splat"}
								end

								if a.bullet_start_offset then
									local offset = a.bullet_start_offset[ai]

									b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
								end

								b.bullet.from:copy(b.pos)

								b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
								b.bullet.target_id = target.id
								b.bullet.shot_index = si
								b.bullet.source_id = this.id
								b.bullet.xp_dest_id = this.id
								b.bullet.damage_factor = this.unit.damage_factor

								simulation:queue_insert_entity(b)
							end
						end

						U.y_animation_wait_default(this)

						a.ts = store.tick_ts

						U.animation_start_default(this, "reload", nil, store.tick_ts)

						if U.y_animation_wait_default(this) then
							goto label_47_0
						end
					end
				end

				if SU.soldier_go_back_step(store, this) then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::label_47_0::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_bolin", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {400, 430, 460, 490, 520, 550, 580, 610, 640, 670}
tt.hero.level_stats.melee_damage_max = {15, 18, 20, 23, 25, 28, 30, 33, 35, 38}
tt.hero.level_stats.melee_damage_min = {9, 11, 12, 14, 15, 17, 18, 20, 21, 23}
tt.hero.level_stats.ranged_damage_max = {31, 37, 42, 48, 54, 61, 68, 74, 81, 87}
tt.hero.level_stats.ranged_damage_min = {9, 11, 12, 14, 15, 17, 18, 20, 21, 23}
tt.hero.skills.mines = CC("hero_skill")
tt.hero.skills.mines.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.mines.xp_gain = {25, 50, 75}
tt.hero.skills.mines.damage_min = {30, 60, 100}
tt.hero.skills.mines.damage_max = {60, 120, 150}
tt.hero.skills.tar = CC("hero_skill")
tt.hero.skills.tar.duration = {4, 6, 8}
tt.hero.skills.tar.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.tar.xp_gain = {50, 100, 150}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_level_up
tt.hero.tombstone_show_time = fts(60)
tt.info.hero_portrait = "hero_portraits_0004"
tt.info.portrait = "info_portraits_heroes_0004"
tt.melee.range = 25
tt.main_script.update = hero_update
tt.motion.max_speed = 2.7 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor = vec_2(0.5, 0.24)
tt.render.sprites[1].prefix = "hero_bolin"
tt.render.sprites[1].angles.shoot = {"shootRightLeft", "shootUp", "shootDown"}
tt.render.sprites[1].angles.shootAim = {"shootAimRightLeft", "shootAimUp", "shootAimDown"}
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.sound_events.change_rally_point = "HeroRiflemanTaunt"
tt.sound_events.death = "HeroRiflemanDeath"
tt.sound_events.hero_room_select = "HeroRiflemanTauntSelect"
tt.sound_events.insert = "HeroRiflemanTauntIntro"
tt.sound_events.respawn = "HeroRiflemanTauntIntro"
tt.ui.click_rect = r(-15, -5, 30, 35)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].xp_gain_factor = 2
-- 普攻
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "shotgun_bolin"
tt.timed_attacks.list[1].aim_animation = "shootAim"
tt.timed_attacks.list[1].shoot_animation = "shoot"
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20)}
tt.timed_attacks.list[1].cooldown = 2
tt.timed_attacks.list[1].shoot_times = {fts(10), fts(12), fts(12), fts(12), fts(12)}
tt.timed_attacks.list[1].min_range = 40
tt.timed_attacks.list[1].max_range = 200
tt.timed_attacks.list[1].shoot_time = fts(2)
tt.timed_attacks.list[1].xp_gain_factor = 3
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_SHOT, DAMAGE_NO_DODGE)
tt.timed_attacks.list[1].count = 1
-- 倒油
tt.timed_attacks.list[2] = CC("bullet_attack")
tt.timed_attacks.list[2].bullet = "bomb_tar_bolin"
tt.timed_attacks.list[2].bullet_start_offset = vec_2(0, 30)
tt.timed_attacks.list[2].cooldown = 12 + fts(27)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].min_range = 100
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].shoot_time = fts(13)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
-- 地雷
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].bullet = "bomb_mine_bolin"
tt.timed_attacks.list[3].bullet_start_offset = vec_2(0, 12)
tt.timed_attacks.list[3].count = 5
tt.timed_attacks.list[3].cooldown = 6 + fts(19)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].min_range = 30
tt.timed_attacks.list[3].max_range = 200
tt.timed_attacks.list[3].shoot_time = fts(3)
tt.timed_attacks.list[3].node_offset = {-12, 12}
-- 狂热射击
tt.timed_attacks.list[4] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[4].chance = 0.3
tt.timed_attacks.list[4].bullet_start_offset = {vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20), vec_2(0, 20)}
tt.timed_attacks.list[4].shoot_times = {fts(10), fts(12), fts(12), fts(12), fts(12), fts(12), fts(12)}
tt.timed_attacks.list[5] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[5].cooldown = 15
tt.timed_attacks.list[5].disabled = true
tt.timed_attacks.list[5].shoot_times = {fts(10)}
tt.timed_attacks.list[5].bullet = "bomb_shrapnel_bolin"
tt.timed_attacks.list[5].count = 3
tt = RT("bomb_shrapnel_bolin", "bomb")
tt.bullet.damage_max = 72
tt.bullet.damage_min = 36
tt.bullet.damage_radius = 72
tt.bullet.flight_time = fts(6)
tt.bullet.hit_fx = "fx_explosion_shrapnel_bolin"
tt.bullet.pop = nil
tt.render.sprites[1].name = "bombs_0007"
tt.sound_events.insert = "ShrapnelSound"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = RT("fx_explosion_shrapnel_bolin", "fx")
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].prefix = "explosion"
tt.render.sprites[1].name = "shrapnel"
tt.render.sprites[1].scale = vec_1(1.5)
tt = RT("bomb_mine_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 35
tt.bullet.flight_time = fts(24)
tt.bullet.pop = nil
tt.bullet.hit_payload = "decal_bolin_mine"
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_mine_proy"
tt.sound_events.insert = "HeroRiflemanMine"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = RT("decal_bolin_mine", "decal_scripted")
tt.check_interval = fts(3)
tt.damage_type = DAMAGE_EXPLOSION
tt.duration = 50
tt.hit_decal = "decal_bomb_crater"
tt.hit_fx = "fx_explosion_fragment"
tt.main_script.update = decal_mine_update
tt.radius = 25
tt.render.sprites[1].name = "decal_bolin_mine"
tt.render.sprites[1].z = Z_DECALS
tt.sound = "BombExplosionSound"
tt.vis_bans = bor(F_FRIEND, F_FLYING)
tt.vis_flags = bor(F_ENEMY)
tt = RT("bomb_tar_bolin", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(34)
tt.bullet.flight_time_factor = fts(0.0167)
tt.bullet.pop = nil
tt.bullet.hit_payload = "aura_bolin_tar"
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = nil
tt.render.sprites[1].name = "hero_artillery_brea_shot"
tt.sound_events.insert = "HeroRiflemanBrea"
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt = RT("aura_bolin_tar", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 6
tt.aura.mod = "mod_bolin_slow"
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_slow_update
tt.render.sprites[1].prefix = "decal_bolin_tar"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.3, 0}}
tt = RT("mod_bolin_slow", "mod_slow")
tt.modifier.duration = 4
tt.slow.factor = 0.6
