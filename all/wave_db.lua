-- chunkname: @./all/wave_db.lua
local log = require("klua.log"):new("wave_db")
local km = require("klua.macros")
local FS = love.filesystem
local E = require("entity_db")
local EL = require("kr1.data.endless")
local EU = require("endless_utils")
require("constants")

local wave_db = {}

wave_db.db = nil
wave_db.game_mode = nil

local gms = {
    [GAME_MODE_CAMPAIGN] = "campaign",
    [GAME_MODE_HEROIC] = "heroic",
    [GAME_MODE_IRON] = "iron",
    -- [GAME_MODE_ENDLESS] = "endless"
    [GAME_MODE_ENDLESS] = "campaign" -- endless模式下也加载普通模式的波次
}
local function is_file(path)
    local info = love.filesystem.getInfo(path)
    return info and info.type == "file"
end

function wave_db:patch_waves(criket)
    self.db.groups = {}
    local criket_groups = criket.groups

    if not criket.fps_transformed then
        criket.fps_transformed = true

        for _, group in pairs(criket_groups) do
            for key, value in pairs(group) do
                if key == "delay" then
                    value = value * FPS
                elseif key == "spawns" then
                    for _, single_spawn in pairs(value) do
                        for k, v in pairs(single_spawn) do
                            if k == "interval" or k == "interval_next" then
                                single_spawn[k] = v * FPS
                            end
                        end
                    end
                end
            end
        end
    end

    self.db.groups[1] = {
        interval = 0,
        waves = criket_groups
    }
end

function wave_db:load(level_name, game_mode, endless)
    self.game_mode = game_mode
    self.is_endless = endless
    local suffix = gms[game_mode]
    local wn = string.format("%s/data/waves/%s_waves_%s", KR_PATH_GAME, level_name, suffix)
    local wf = string.format("%s.lua", wn)

    log.debug("Loading %s", wn)

    local ok, wchunk = pcall(FS.load, wf)

    if not ok then
        log.error("Failed to load %s: error: %s", wf, wchunk)

        return
    end

    local ok, wtable = pcall(wchunk)

    if not ok then
        log.error("Failed to eval chunk for %s: error: %s", wf, wtable)

        return
    end

    wave_db.db = wtable

    local wen = string.format("%s_extra", wn)
    local wef = string.format("%s.lua", wen)

    if is_file(wef) then
        log.info("Found extra waves: %s", wef)

        local ok, wchunk = pcall(FS.load, wef)

        if not ok then
            log.error("Failed to load %s: error: %s", wef, wchunk)

            return
        end

        local ok, extraw = pcall(wchunk)

        if not ok then
            log.error("Failed to eval extra waves chunk for %s: error: %s", wef, extraw)

            return
        end

        self:add_waves_to_groups(extraw)
    end

    if endless then
        self.endless = EU.init_endless(level_name, self:groups())
    end
end

function wave_db:add_waves_to_groups(gwaves)
    if self.db.groups then
        for g, more_waves in pairs(gwaves) do
            log.info("adding %d extra waves to group %d", #more_waves.waves, g)

            if not self.db.groups[g] then
                log.warning("Adding waves to inexistent group %d")

                self.db.groups[g] = {
                    waves = {}
                }
            end

            for _, w in pairs(more_waves.waves) do
                table.insert(self.db.groups[g].waves, w)
            end
        end
    else
        log.error("Unable to add waves. No wave groups have been loaded yet.")
    end
end

function wave_db:groups()
    return self.db.groups
end

function wave_db:group(group_number)
    return self.db.groups[group_number]
end

function wave_db:initial_gold()
    return self.db.cash or self.db.gold
end

function wave_db:initial_lives()
    return self.db.lifes
end

function wave_db:groups_count()
    if self.is_endless then
        return 0
    else
        return #self.db.groups
    end
end

function wave_db:waves_count()
    if self.is_endless then
        return 0
    else
        local result = 0

        for __, group in pairs(self.db.groups) do
            result = result + #group.waves
        end

        return result
    end
end

function wave_db:has_group(i)
    if self.is_endless then
        return i <= 100
    else
        return i <= #self.db.groups
    end
end

function wave_db:get_group(i)
    if self.is_endless then
        return self:get_endless_group(i)
    else
        return self.db.groups[i]
    end
end

function wave_db:get_endless_early_wave_reward_factor()
    if self.db and self.db.nextWaveRewardMoneyMultiplier then
        return self.db.nextWaveRewardMoneyMultiplier
    else
        return 1
    end
end

function wave_db:get_endless_score_config()
    if self.db and self.db.score then
        return table.deepclone(self.db.score)
    else
        return nil
    end
end

function wave_db:get_endless_boss_config(i)
    local out = {}
    local db = self.db
    local dif_max = #db.difficulties
    local dif_level = math.ceil(i / 10)
    local dif_idx = km.clamp(1, dif_max, dif_level)
    local dif = db.difficulties[dif_idx]
    local dbc = dif.bossConfig

    out.chance = dbc.powerChance + dbc.powerChanceIncrement * dif_level
    out.cooldown = math.random(dbc.powerCooldownMin, dbc.powerCooldownMax)
    out.multiple_attacks_chance = dbc.powerMultiChance
    out.power_chances = dbc.powerDistribution
    out.powers_config_dif = dbc.powerConfig
    out.boss_config_dif = dbc
    out.powers_config = db.bossConfig.powerConfig

    return out
end

function wave_db:get_endless_group(i)
    return EU.generate_group(self.endless)
end

return wave_db
