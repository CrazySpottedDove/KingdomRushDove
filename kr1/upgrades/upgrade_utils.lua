local E = require("entity_db")
local V = require("lib.klua.vector")

require("all.constants")

local H = {}

function H.T(name)
	return E:get_template(name)
end

function H.get_SU()
	return require("script_utils")
end

function H.mul_field(obj, key, factor)
	obj[key] = obj[key] * factor
end

function H.mul_keys(obj, factor, ...)
	for _, k in ipairs({...}) do
		obj[k] = obj[k] * factor
	end
end

function H.mul_dmg(owner, factor, min_key, max_key)
	local mn = min_key or "damage_min"
	local mx = max_key or "damage_max"
	owner[mn] = owner[mn] * factor
	owner[mx] = owner[mx] * factor
end

function H.mul_arr(arr, factor)
	for i = 1, #arr do
		arr[i] = arr[i] * factor
	end
end

function H.avg_dmg_mul(owner, factor)
	local damage = (owner.damage_min + owner.damage_max) * 0.5 * factor
	owner.damage_min = damage
	owner.damage_max = damage
end

function H.add_damage_hooks(template_names, hook)
	for _, n in ipairs(template_names) do
		local b = H.T(n).bullet
		b.damage_hooks[#b.damage_hooks + 1] = hook
	end
end

function H.scale_tower_price(towers, factor, round_fn)
	for _, n in ipairs(towers) do
		local t = H.T(n)
		if t.tower and t.tower.price then
			t.tower.price = round_fn(t.tower.price * factor)
		end
	end
end

function H.scale_power_prices(towers, factor, round_fn)
	for _, n in ipairs(towers) do
		local t = H.T(n)
		if t.powers then
			for _, p in pairs(t.powers) do
				if p.price_base then
					p.price_base = round_fn(p.price_base * factor)
				end
				if p.price_inc then
					p.price_inc = round_fn(p.price_inc * factor)
				end
			end
		end
	end
end

function H.scale_tower_damage(towers, factor)
	for _, n in ipairs(towers) do
		H.T(n).tower.damage_factor = H.T(n).tower.damage_factor + (factor - 1)
	end
end

function H.scale_tower_attack_range(towers, factor, skip)
	for _, n in ipairs(towers) do
		if not (skip and skip[n]) then
			H.T(n).attacks.range = H.T(n).attacks.range * factor
		end
	end
end

function H.patch_engineer_range(towers, factor)
	H.scale_tower_attack_range(towers, factor, {
		tower_mech = true,
		tower_balloon = true
	})

	H.mul_field(H.T("tower_bfg").attacks.list[2], "range_base", factor)
	H.mul_field(H.T("druid_shooter_sylvan").attacks.list[1], "range", factor)
	H.mul_field(H.T("tower_flamespitter_lvl4").attacks.list[2], "max_range", factor)
	H.mul_field(H.T("tower_flamespitter_lvl4").attacks.list[3], "max_range", factor)
	H.mul_field(H.T("soldier_balloon").attacks.list[1], "max_range", factor)
	H.mul_field(H.T("soldier_mecha").attacks.list[1], "max_range", factor)
end

function H.patch_engineer_power_cooldown(cooldown_factor, cooldown_factor_electric)
	local cd = cooldown_factor
	local cd_e = cooldown_factor_electric

	for _, a in ipairs({
		H.T("tower_dwaarp").attacks.list[2],
		H.T("tower_dwaarp").attacks.list[3],
		H.T("soldier_mecha").attacks.list[2],
		H.T("soldier_mecha").attacks.list[3],
		H.T("druid_shooter_sylvan").attacks.list[1],
		H.T("tower_entwood").attacks.list[3],
		H.T("tower_entwood").attacks.list[2],
		H.T("tower_dwaarp").attacks.list[3],
		H.T("soldier_balloon").attacks.list[2],
		H.T("soldier_balloon").attacks.list[3],
		H.T("tower_melting_furnace").attacks.list[2],
		H.T("tower_melting_furnace").attacks.list[4],
		H.T("tower_catapult").attacks.list[2],
		H.T("tower_catapult").attacks.list[3],
		H.T("tower_catapult").attacks.list[4],
		H.T("tower_culverine").attacks.list[2],
		H.T("tower_culverine").attacks.list[3],
		H.T("tower_alchemist").attacks.list[2],
		H.T("tower_alchemist").attacks.list[3]
	}) do
		H.mul_field(a, "cooldown", cd)
	end

	H.mul_keys(H.T("tower_entwood").attacks.list[2], cd, "cooldown_factor", "cooldown")
	H.mul_keys(H.T("tower_bfg").attacks.list[2], cd, "cooldown_base", "cooldown_mixed_base", "cooldown_flying")
	H.mul_field(H.T("tower_bfg").attacks.list[3], "cooldown_base", cd)
	H.mul_keys(H.T("tower_bfg").powers.missile, cd, "cooldown_dec", "cooldown_mixed_dec")
	H.mul_field(H.T("tower_bfg").powers.cluster, "cooldown_dec", cd)
	H.mul_field(H.T("tower_bfg").attacks, "min_cooldown", cd)
	H.mul_keys(H.T("tower_dwaarp").attacks.list[3], cd, "cooldown_inc", "cooldown_base")
	H.mul_field(H.T("tower_frankenstein").attacks.list[1], "cooldown", cd_e)
	H.mul_field(H.T("tower_tesla").attacks.list[1], "cooldown", cd_e)
	H.mul_field(H.T("tower_tesla").attacks, "min_cooldown", cd_e)
	H.mul_arr(H.T("tower_tricannon_lvl4").powers.bombardment.cooldown, cd)
	H.mul_arr(H.T("tower_tricannon_lvl4").powers.overheat.cooldown, cd)
	H.mul_arr(H.T("tower_demon_pit_lvl4").powers.big_guy.cooldown, cd)
	H.mul_arr(H.T("tower_flamespitter_lvl4").powers.skill_bomb.cooldown, cd)
	H.mul_arr(H.T("tower_flamespitter_lvl4").powers.skill_columns.cooldown, cd)
	H.mul_arr(H.T("tower_sparking_geode_lvl4").powers.crystalize.cooldown, cd)
	H.mul_arr(H.T("tower_sparking_geode_lvl4").powers.spike_burst.cooldown, cd)
	H.mul_keys(H.T("tower_rotten_forest").powers.tree, cd, "cooldown", "cooldown_inc")
	H.mul_arr(H.T("tower_ogre_shipwreck").powers.goblin_launcher.cooldown, cd)
	H.mul_field(H.T("tower_rocket_riders").attacks.list[2], "cooldown", cd)
	H.mul_field(H.T("rr_mine_box").attacks.list[1], "cooldown", cd)
	H.mul_field(H.T("ignis_altar_subunit").attacks.list[1], "cooldown", cd)
	H.mul_arr(H.T("tower_sandworm").powers.worm.cooldown, cd)
	H.mul_arr(H.T("tower_sandworm").powers.slime.cooldown, cd)
	H.mul_arr(H.T("tower_sandworm").powers.eat.cooldown, cd)
	H.mul_field(H.T("aura_rotten_forest_thorn").aura, "cooldown", cd)
	H.mul_field(H.T("controller_alchemist_skill_b"), "cooldown", cd)
	H.mul_arr(H.T("tower_tree").powers.skill_a.cooldown, cd)
	H.mul_arr(H.T("tower_tree").powers.skill_c.cooldown, cd)
	H.mul_arr(H.T("soldier_tree").powers.skill_b.cooldown, cd)
	H.mul_field(H.T("tower_tree").attacks.list[4], "cooldown", cd)
end

function H.scale_sprite(s, factor)
	if s.scale then
		s.scale.x = s.scale.x * factor
		s.scale.y = s.scale.y * factor
	else
		s.scale = V.v(factor, factor)
	end
end

function H.apply_mod(bullet, mod_name)
	if bullet.mods then
		bullet.mods[#bullet.mods + 1] = mod_name
	elseif bullet.mod then
		bullet.mods = {bullet.mod, mod_name}
		bullet.mod = nil
	else
		bullet.mods = {mod_name}
	end
end

function H.add_mods(b, mods)
	if b.mod then
		table.insert(mods, b.mod)
	end

	if b.mods then
		table.append(mods, b.mods)
	end

	b.mod = nil
	b.mods = mods
end

function H.bomb_damage_mul(engineer_bombs, damage_factor)
	for _, n in ipairs(engineer_bombs) do
		H.mul_dmg(H.T(n).bullet, damage_factor)
	end

	H.mul_dmg(H.T("tower_dwaarp").attacks.list[1], damage_factor)
	H.mul_dmg(H.T("aura_tree_attack").aura, damage_factor)
	H.mul_dmg(H.T("aura_tree_ultimate_bomb").aura, damage_factor)
	H.mul_dmg(H.T("tower_melting_furnace").attacks.list[1], damage_factor)
	H.mul_dmg(H.T("ray_tesla"), damage_factor, "bounce_damage_min", "bounce_damage_max")
	H.mul_dmg(H.T("mod_ray_frankenstein").dps, damage_factor)
	H.mul_dmg(H.T("tower_flamespitter_lvl4").attacks.list[1], damage_factor)
	H.mul_dmg(H.T("mod_tower_rotten_forest_burst_damage").dps, damage_factor)
	H.mul_dmg(H.T("mod_ignis_altar_damage"), damage_factor)
	H.mul_dmg(H.T("aura_tower_sandworm").aura, damage_factor)
	H.mul_dmg(H.T("soldier_tower_demon_pit_basic_attack_lvl4"), damage_factor, "explosion_damage_min", "explosion_damage_max")
	H.mul_dmg(H.T("aura_bullet_culverine").aura, damage_factor)
	H.mul_dmg(H.T("aura_bullet_culverine_skill_b").aura, damage_factor)
	H.mul_dmg(H.T("aura_culverine_ultimate").aura, damage_factor)
	H.mul_dmg(H.T("aura_alchemist_hit_green").aura, damage_factor)

	local alchemist_aura_c = H.T("aura_alchemist_skill_c").aura
	H.mul_dmg(alchemist_aura_c, damage_factor)
	alchemist_aura_c.damage_inc = alchemist_aura_c.damage_inc * damage_factor
end

function H.mage_bolt_damage_mul(mage_tower_bolts, damage_factor)
	for _, n in ipairs(mage_tower_bolts) do
		H.mul_dmg(H.T(n).bullet, damage_factor)
	end

	H.mul_dmg(H.T("mod_ray_arcane").dps, damage_factor)
	H.mul_dmg(H.T("mod_pixie_pickpocket").modifier, damage_factor)
	H.mul_field(H.T("mod_ultimate_wizard"), "damage", damage_factor)

	local d = H.T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

	for k, v in ipairs(d) do
		d[k] = v * damage_factor
	end

	H.mul_dmg(H.T("mod_lava_infernal_mage").dps, damage_factor)
	H.mul_dmg(H.T("mod_wicked_sister_poison").dps, damage_factor)

	H.mul_dmg(H.T("aura_sunray_master_beam").aura, damage_factor)
	H.mul_dmg(H.T("aura_sunray_master_ult_beam").aura, damage_factor)
end

function H.apply_soldier_health_factor(soldiers, health_factor)
	for _, n in ipairs(soldiers) do
		H.T(n).health.hp_max = H.T(n).health.hp_max * health_factor
	end

	local tt = E:get_template("big_guy_tower_demon_pit_lvl4")

	for i = 1, #tt.health_level do
		tt.health_level[i] = tt.health_level[i] * health_factor
	end
end

function H.patch_soldier_armor_inc(soldiers, armor_inc)
	for _, n in ipairs(soldiers) do
		H.T(n).health.armor = H.T(n).health.armor + armor_inc
	end

	local tt = H.T("soldier_frankenstein")

	for i = 1, #tt.health.armor_lvls do
		tt.health.armor_lvls[i] = tt.health.armor_lvls[i] + armor_inc
	end
end

function H.patch_soldier_magic_armor_inc(damage_factor, magic_armor_inc)
	for _, t in ipairs(E:filter_templates("soldier")) do
		if t.health and not t.hero then
			t.health.damage_factor = damage_factor
			t.health.magic_armor = t.health.magic_armor + magic_armor_inc
		end
	end
end

function H.patch_soldier_dead_lifetime(soldiers, factor)
	for _, n in ipairs(soldiers) do
		H.T(n).health.dead_lifetime = H.T(n).health.dead_lifetime * factor
	end
end

return H
