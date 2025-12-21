-- chunkname: @./kr1/achievements_handlers.lua
local log = require("lib.klua.log"):new("achievements_handlers")
local signal = require("hump.signal")
local bit = require("bit")
local E = require("entity_db")
local GS = require("game_settings")
local storage = require("storage")
local ah = {}

function ah:register_handlers(A)
	self.A = A

	local function reg(name, fn)
		signal.register(name, function(...)
			fn(ah, ...)
		end)
	end

	reg("aura-apply-mod-victims", ah.h_aura_apply_mod_victims)
	reg("boss-killed", ah.h_boss_killed)
	reg("early-wave-called", ah.h_early_wave_called)
	reg("entity-damaged", ah.h_entity_damaged)
	reg("entity-healed", ah.h_entity_healed)
	reg("entity-killed", ah.h_entity_killed)
	reg("game-victory", ah.h_game_victory)
	reg("health-regen", ah.h_health_regen)
	reg("hero-level-increased", ah.h_hero_level_increased)
	reg("mod-applied", ah.h_mod_applied)
	reg("next-wave-ready", ah.h_next_wave_ready)
	reg("notification-shown", ah.h_notification_shown)
	reg("power-used", ah.h_power_used)
	reg("rally-point-changed", ah.h_rally_point_changed)
	reg("soldier-attack", ah.h_soldier_attack)
	reg("tower-power-upgraded", ah.h_tower_power_upgraded)
	reg("tower-removed", ah.h_tower_removed)
	reg("tower-spawn", ah.h_tower_spawn)
	reg("tower-upgraded", ah.h_tower_upgraded)
end

function ah:h_boss_killed(entity)
	if entity.template_name == "eb_juggernaut" then
		self.A:got("DEFEAT_JUGGERNAUT")
	elseif entity.template_name == "eb_jt" then
		self.A:got("DEFEAT_MOUNTAIN_BOSS")
	elseif entity.template_name == "eb_veznan" then
		self.A:got("DEFEAT_END_BOSS")
	elseif entity.template_name == "eb_kingpin" then
		self.A:got("DEFEAT_KINGPING_BOSS")
	elseif entity.template_name == "eb_ulgukhai" then
		self.A:got("DEFEAT_TROLL_BOSS")
	elseif entity.template_name == "eb_moloch" then
		self.A:got("HELL_O")
	elseif entity.template_name == "eb_myconid" then
		self.A:got("SUPER_MUSHROOM")
	elseif entity.template_name == "eb_blackburn" then
		self.A:got("GOC")
	end
end

function ah:h_early_wave_called(group, reward, remaining_time)
	local count, ad = self.A:inc("FEARLESS", 1)

	if game.store and game.store.wave_group_total > 1 and count == game.store.wave_group_total - 1 then
		self.A:got(ad.name)
	end

	self.A:lap_check("IMPATIENT")
	self.A:inc_check("DARING", 1)
end

function ah:h_entity_damaged(entity, damage)
	if damage and damage.source_id then
		local s = game.store.entities[damage.source_id]

		if entity.health and entity.health.hp > 0 and s and table.contains({"aura_demon_death", "aura_demon_mage_death", "aura_demon_wolf_death", "aura_flareon_death", "aura_gulaemon_death", "aura_demon_cerberus_death"}, s.template_name) then
			self.A:inc_check("WE_DINE_IN_HELL")
		elseif s and s.template_name == "soldier_elf" then
			self.A:inc_check("STILL_COUNTS_AS_ONE", damage.value)
		end
	end
end

function ah:h_entity_killed(entity, damage)
	if not entity then
		log.debug("nil entity")

		return
	end

	if entity.enemy then
		self.A:inc_check("FIRST_BLOOD", 1)
		self.A:inc_check("BLOODLUST", 1)
		self.A:inc_check("SLAYER", 1)
		self.A:inc_check("MULTIKILL", 1)
	end

	if entity.soldier and not entity.hero then
		self.A:inc_check("CANNON_FODDER", 1)
	end

	if damage and damage.source_id then
		local s = game.store.entities[damage.source_id]

		if s and entity.enemy then
			if s.template_name == "power_fireball" then
				self.A:inc_check("DEATH_FROM_ABOVE")
			end

			if s.template_name == "shotgun_musketeer_sniper_instakill" then
				self.A:inc_check("SNIPER")
			end

			if s.template_name == "mod_ranger_poison" then
				self.A:inc_check("TOXICITY")
			end

			if s.template_name == "mod_ray_arcane_disintegrate" then
				self.A:inc_check("DUST_TO_DUST")
			end

			if s.template_name == "mod_ray_tesla" then
				self.A:inc_check("ACDC")
			end

			if s.template_name == "mod_tesla_overcharge" then
				self.A:inc_check("ACDC")
			end

			if s.template_name == "soldier_barbarian" then
				s._barbarian_rush_counter = 1 + (s._barbarian_rush_counter or 0)

				self.A:high_check("BARBARIAN_RUSH", s._barbarian_rush_counter)
			end
		end
	end

	if entity.template_name == "enemy_troll_skater" and entity._last_on_ice then
		self.A:inc_check("DEFEAT_COOL_RUNNING")
	elseif entity.template_name == "enemy_demon_legion" then
		local a = entity.timed_attacks.list[1]

		if not entity._summoned and a and a.count == a.generation then
			self.A:inc_check("ARMY_OF_ONE")
		end
	elseif entity.template_name == "enemy_wererat" and not entity._has_infected_soldiers then
		self.A:inc_check("RATATOUILLE")
	end
end

function ah:h_game_victory(store)
	local slot = storage:load_slot()
	local go = store.game_outcome

	if store.level_idx == 6 then
		local count = 0

		for _, e in pairs(store.soldiers) do
			if e.template_name == "soldier_s6_imperial_guard" and not e.health.dead then
				count = count + 1
			end
		end

		self.A:high_check("IMPERIAL_SAVIOUR", count)
	elseif store.level_idx == 13 then
		self.A:got("DEFEAT_SARELGAZ")
	elseif store.level_idx == 14 then
		self.A:got("DEFEAT_GULTHAK_BOSS")
	elseif store.level_idx == 15 then
		self.A:got("DEFEAT_TREANT_BOSS")
	end

	local stars = 0

	if slot and slot.levels then
		for i = 1, GS.last_level1 do
			local l = slot.levels[i]

			if not l then
				log.debug("level %i missing in slot.levels", i)
			elseif i == go.level_idx then
				local l_stars = l.stars or 0
				local go_stars = go.stars or 0

				stars = stars + (go.level_mode == GAME_MODE_CAMPAIGN and math.max(l_stars, go_stars) or l_stars) + ((go.level_mode == GAME_MODE_HEROIC or l[GAME_MODE_HEROIC]) and 1 or 0) + ((go.level_mode == GAME_MODE_IRON or l[GAME_MODE_IRON]) and 1 or 0)
			else
				stars = stars + (l.stars or 0) + (l[GAME_MODE_HEROIC] and 1 or 0) + (l[GAME_MODE_IRON] and 1 or 0)
			end

			log.paranoid("level:%s stars:%s", i, stars)
		end
	end

	self.A:high_check("EARN15_STARS", stars)
	self.A:high_check("EARN30_STARS", stars)
	self.A:high_check("EARN45_STARS", stars)

	local done_c, done_h, done_i, done_g = true, true, true, true

	if slot and slot.levels then
		for i = 1, GS.main_campaign_levels do
			local lv = table.deepclone(slot.levels[i])

			if not lv then
				done_c, done_h, done_i, done_g = false, false, false, false

				break
			end

			if i == store.level_idx then
				lv[store.level_mode] = store.level_difficulty
			end

			done_c = done_c and lv[GAME_MODE_CAMPAIGN] ~= nil
			done_h = done_h and lv[GAME_MODE_HEROIC] ~= nil
			done_i = done_i and lv[GAME_MODE_IRON] ~= nil
			done_g = done_g and lv[GAME_MODE_CAMPAIGN] == DIFFICULTY_HARD
		end
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		if done_c then
			self.A:got("GREAT_DEFENDER")
		end

		if done_g then
			self.A:got("DEFEAT_COMPLETE_HARD")
		end
	elseif store.level_mode == GAME_MODE_HEROIC and done_h then
		self.A:got("HEROIC_DEFENDER")
	elseif store.level_mode == GAME_MODE_IRON and done_i then
		self.A:got("IRON_DEFENDER")
	end
end

function ah:h_hero_level_increased(entity)
	if entity.hero then
		self.A:high_check("HERO_MEDIUM", entity.hero.level)
		self.A:high_check("HERO_HARD", entity.hero.level)
	end
end

function ah:h_mod_applied(mod, target)
	if mod.template_name == "mod_thorn" then
		self.A:inc_check("ENTANGLED")
	elseif mod.template_name == "mod_teleport_arcane" then
		self.A:inc_check("BEAM_ME_UP")
	elseif mod.template_name == "mod_polymorph_sorcerer" then
		self.A:inc_check("SHEPARD")
	elseif mod.template_name == "mod_wererat_poison" then
		local s = game.store.entities[mod.modifier.source_id]

		if s then
			s._has_infected_soldiers = true
		end
	end
end

function ah:h_notification_shown(n)
	if n.layout == N_ENEMY or n.template == "enemy" then
		self.A:inc_check("WHATS_THAT", 1)
	end
end

function ah:h_power_used(power_id)
	if power_id == 1 then
		self.A:inc_check("ARMAGGEDON", 1)
	end
end

function ah:h_tower_upgraded(new_tower, old_tower)
	if new_tower.template_name == "tower_tesla" then
		self.A:inc_check("ENERGY_NETWORK")
	end

	if old_tower.tower_holder and not new_tower.tower_holder then
		self.A:inc_check("EASY_TOWER_BUILDER", 1)
		self.A:inc_check("MEDIUM_TOWER_BUILDER", 1)
		self.A:inc_check("HARD_TOWER_BUILDER", 1)
	end

	if not self.A:have("UPGRADE_LEVEL3") then
		if new_tower.template_name == "tower_archer_3" then
			self.A:flag_check("UPGRADE_LEVEL3", 1)
		end

		if new_tower.template_name == "tower_barrack_3" then
			self.A:flag_check("UPGRADE_LEVEL3", 2)
		end

		if new_tower.template_name == "tower_engineer_3" then
			self.A:flag_check("UPGRADE_LEVEL3", 4)
		end

		if new_tower.template_name == "tower_mage_3" then
			self.A:flag_check("UPGRADE_LEVEL3", 8)
		end
	end

	if not self.A:have("SPECIALIZATION") then
		if new_tower.template_name == "tower_arcane_wizard" then
			self.A:flag_check("SPECIALIZATION", 1)
		end

		if new_tower.template_name == "tower_sorcerer" then
			self.A:flag_check("SPECIALIZATION", 2)
		end

		if new_tower.template_name == "tower_bfg" then
			self.A:flag_check("SPECIALIZATION", 4)
		end

		if new_tower.template_name == "tower_tesla" then
			self.A:flag_check("SPECIALIZATION", 8)
		end

		if new_tower.template_name == "tower_ranger" then
			self.A:flag_check("SPECIALIZATION", 16)
		end

		if new_tower.template_name == "tower_musketeer" then
			self.A:flag_check("SPECIALIZATION", 32)
		end

		if new_tower.template_name == "tower_paladin" then
			self.A:flag_check("SPECIALIZATION", 64)
		end

		if new_tower.template_name == "tower_barbarian" then
			self.A:flag_check("SPECIALIZATION", 128)
		end
	end
end

function ah:h_tower_power_upgraded(tower, power)
	if tower.template_name == "tower_sorcerer" and tower.powers.elemental == power and power.level == 1 then
		self.A:inc_check("ELEMENTALIST")
	end
end

function ah:h_entity_healed(mod, entity, amount)
	if mod.template_name == "mod_healing_paladin" then
		self.A:inc_check("MEDIC", amount)
	end
end

function ah:h_health_regen(entity, amount)
	if entity and entity.soldier then
		self.A:inc_check("DIE_HARD", amount)
	end
end

function ah:h_next_wave_ready(group)
	if group.group_idx > 1 then
		self.A:lap_start("IMPATIENT")
	end
end

function ah:h_rally_point_changed(tower)
	self.A:inc_check("TACTICIAN", 1)
end

function ah:h_soldier_attack(entity, attack, signal_prop)
	if signal_prop == "holystrike" then
		self.A:inc_check("HOLY_CHORUS")
	end
end

function ah:h_tower_spawn(tower, entity)
	if entity and entity.soldier then
		self.A:inc_check("GI_JOE", 1)
	end

	if tower.template_name == "tower_elf" and #tower.barrack.soldiers == tower.barrack.max_soldiers then
		self.A:got("MAX_ELVES")
	end
end

function ah:h_tower_removed(tower)
	if tower.tower and tower.tower.sell then
		self.A:inc_check("REAL_STATE")
		self.A:inc_check("INDECISIVE")
	end
end

function ah:h_aura_apply_mod_victims(aura, victims_count)
	if aura.template_name == "aura_rotten_lesser_death" and victims_count == 0 then
		self.A:inc_check("SPORE")
	end
end

return ah
