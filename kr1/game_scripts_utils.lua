log = require("klua.log"):new("game_scripts")
require("klua.table")
km = require("klua.macros")
signal = require("hump.signal")
E = require("entity_db")
GR = require("grid_db")
GS = require("game_settings")
P = require("path_db")
S = require("sound_db")
SU = require("script_utils")
U = require("utils")
LU = require("level_utils")
UP = require("upgrades")
V = require("klua.vector")
W = require("wave_db")
local bit = require("bit")
band = bit.band
bor = bit.bor
bnot = bit.bnot
IS_PHONE = KR_TARGET == "phone"
IS_CONSOLE = KR_TARGET == "console"

function tpos(e)
    return
        e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or
            e.pos
end

function enemy_ready_to_magic_attack(this, store, attack)
    return this.enemy.can_do_magic and store.tick_ts - attack.ts > attack.cooldown
end

function ready_to_attack(attack, store)
    return store.tick_ts - attack.ts > attack.cooldown
end

function get_attack_ready(attack, store)
    attack.ts = store.tick_ts - attack.cooldown
end

function enemy_is_silent_target(e)
    return (band(e.vis.flags, F_SPELLCASTER) ~= 0 or e.ranged or e.timed_attacks) and e.enemy.can_do_magic
end

function fts(v)
    return v/FPS
end

function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end
function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end
function queue_damage(store, damage)
    table.insert(store.damage_queue, damage)
end

function soldiers_around_need_heal(this, store, trigger_hp_factor, range)
    local targets = table.filter(store.entities, function(k,v)
        return (v.soldier and v.template_name ~= "soldier_mecha" and not v.refinforcement) and (v.health and v.health.hp < trigger_hp_factor * v.health.hp_max) and U.is_inside_ellipse(v.pos, this.pos, range)
    end)
    if not targets or #targets == 0 then
        return false
    else
        return true
    end
end