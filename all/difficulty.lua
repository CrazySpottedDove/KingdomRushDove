-- chunkname: @./all/difficulty.lua
local E = require("entity_db")
local GS = require("game_settings")
local km = require("klua.macros")

require("constants")

local difficulty = {}

function difficulty:set_level(level)
    self.level = level
end

function difficulty:patch_templates()
    local function PT(t, key)
        if t and t[key] and type(t[key]) == "table" then
            if t[key][4] and self.level == 3 then
                t[key] = t[key][4]
            else
                t[key] = t[key][self.level] or t[key][3]
            end
            return true
        end

        return false
    end

    local hp_factor_soldier = GS.difficulty_soldier_hp_max_factor[self.level]
    local hp_factor_enemy = GS.difficulty_enemy_hp_max_factor[self.level]
    local speed_factor_enemy = GS.difficulty_enemy_speed_factor[self.level]
    local gold_factor_enemy = GS.difficulty_enemy_gold_factor[self.level]
    local gold_factor_tower = GS.difficulty_tower_gold_factor[self.level]
    local armor_factor_enemy = GS.difficulty_enemy_armor_factor[self.level]
    local ranged_attack_cooldown_factor_enemy = GS.difficulty_enemy_ranged_attack_cooldown_factor[self.level]
    local timed_attack_cooldown_factor_enemy = GS.difficulty_enemy_timed_attack_cooldown_factor[self.level]
    for _, t in pairs(E.entities) do
        if t.soldier then
            if t.hero and t.hero.level_stats and t.hero.level_stats.hp_max then
                local m = t.hero.level_stats.hp_max

                for i = 1, #m do
                    m[i] = math.floor(m[i] * hp_factor_soldier)
                end
            elseif not PT(t.health, "hp_max") and hp_factor_soldier and hp_factor_soldier ~= 1 then
                if not t.health.hp_max then
                    log.debug("no hp_max in %s", t.template_name)
                else
                    t.health.hp_max = math.floor(t.health.hp_max * hp_factor_soldier)
                end
            end
        end
        if t.enemy then
            if not PT(t.health, "hp_max") and hp_factor_enemy ~= 1 then
                if self.level == DIFFICULTY_IMPOSSIBLE and t.health.hp_max > 2000 then
                    t.health.instakill_resistance = km.clamp(0, 1, (t.health.hp_max - 2000) * 0.0002)
                end
                if band(t.vis.flags, F_FLYING) ~= 0 then
                    -- 削弱飞行兵的生命加成
                    t.health.hp_max = math.floor(t.health.hp_max * (0.25 + 0.75 * hp_factor_enemy))
                else
                    t.health.hp_max = math.floor(t.health.hp_max * hp_factor_enemy)
                end
            end

            if not PT(t.motion, "max_speed") and speed_factor_enemy ~= 1 then
                t.motion.max_speed = t.motion.max_speed * speed_factor_enemy
            end

            if not PT(t.enemy, "gold") and gold_factor_enemy ~= 1 then
                print(t.template_name)
                print(t.enemy.gold)
                t.enemy.gold = math.floor(t.enemy.gold * gold_factor_enemy)
            end

            PT(t.death_spawns, "quantity")
            PT(t.enemy, "lives_cost")
            if not PT(t.health, "armor") and armor_factor_enemy ~= 1 then
                t.health.armor = (t.health.armor + armor_factor_enemy) / (1 + armor_factor_enemy)
            end
            PT(t.health, "magic_armor")
            PT(t.motion, "speed_limit")

            if t.melee then
                for i, a in ipairs(t.melee.attacks) do
                    PT(a, "damage_max")
                    PT(a, "damage_min")
                    PT(a, "cooldown")
                end
            end

            if t.ranged then
                if t.ranged.cooldown and not PT(t.ranged, "cooldown") and ranged_attack_cooldown_factor_enemy ~= 1 then
                    t.ranged.cooldown = math.ceil(t.ranged.cooldown * ranged_attack_cooldown_factor_enemy)
                end
                for i, a in ipairs(t.ranged.attacks) do
                    if a.cooldown and not PT(a, "cooldown") and ranged_attack_cooldown_factor_enemy ~= 1 then
                        a.cooldown = math.ceil(a.cooldown * ranged_attack_cooldown_factor_enemy)
                    end
                end
            end

            if t.timed_attacks and t.timed_attacks.list then
                for i, a in ipairs(t.timed_attacks.list) do
                    if a.cooldown and not PT(a, "cooldown") and timed_attack_cooldown_factor_enemy ~= 1 then
                        a.cooldown = math.ceil(a.cooldown * timed_attack_cooldown_factor_enemy)
                    end
                    if a.max_cooldown and not PT(a, "max_cooldown") and timed_attack_cooldown_factor_enemy ~= 1 then
                        a.max_cooldown = math.ceil(a.max_cooldown * timed_attack_cooldown_factor_enemy)
                    end
                    if a.min_cooldown and not PT(a, "min_cooldown") and timed_attack_cooldown_factor_enemy ~= 1 then
                        a.min_cooldown = math.ceil(a.min_cooldown * timed_attack_cooldown_factor_enemy)
                    end
                    PT(a, "max_count")
                    PT(a, "damage_max")
                    PT(a, "damage_min")
                    PT(a, "max_clones")
                    PT(a, "max_per_cast")
                end
            end

            PT(t, "power_block_duration")

        end
        if t.tower then
            if not PT(t.tower, "price") and gold_factor_tower ~= 1 then
                t.tower.price = math.floor(t.tower.price * gold_factor_tower)
            end

        end
        if t.aura then
            PT(t.aura, "damage_max")
            PT(t.aura, "damage_min")
        end
        if t.modifier then
            PT(t.modifier, "duration")
        end
        if t.bullet then
            PT(t.bullet, "damage_max")
            PT(t.bullet, "damage_min")
        end
    end

    local necromancer_aura = E:get_template("necromancer_aura")
    necromancer_aura.min_health_for_knight = necromancer_aura.min_health_for_knight *
                                                 GS.difficulty_enemy_hp_max_factor[self.level]

    local tower_arcane_wizard = E:get_template("tower_arcane_wizard")
    tower_arcane_wizard.powers.disintegrate.upper_damage[1] =
        tower_arcane_wizard.powers.disintegrate.upper_damage[1] * GS.difficulty_enemy_hp_max_factor[self.level]
    tower_arcane_wizard.powers.disintegrate.upper_damage[2] =
        tower_arcane_wizard.powers.disintegrate.upper_damage[2] * GS.difficulty_enemy_hp_max_factor[self.level]
    tower_arcane_wizard.powers.disintegrate.upper_damage[3] =
        tower_arcane_wizard.powers.disintegrate.upper_damage[3] * GS.difficulty_enemy_hp_max_factor[self.level]

end

return difficulty
