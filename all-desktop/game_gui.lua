-- chunkname: @./all-desktop/game_gui.lua
if DEBUG then
    package.loaded["data.game_gui_data"] = nil
    package.loaded.gg_views_custom = nil
end

local log = require("klua.log"):new("game_gui")
local km = require("klua.macros")

require("klua.table")
require("klove.kui")

local kui_db = require("klove.kui_db")
local timer = require("hump.timer"):new()
local signal = require("hump.signal")
local class = require("middleclass")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local AC = require("achievements")
local F = require("klove.font_db")
local I = require("klove.image_db")
local S = require("sound_db")
local SU = require("screen_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local v = V.v
local r = V.r
local P = require("path_db")
local PS = require("platform_services")
local GR = require("grid_db")
local GS = require("game_settings")
local GU = require("gui_utils")
local LU = require("level_utils")
local storage = require("storage")
local G = love.graphics
local i18n = require("i18n")
local EU = require("endless_utils")
local EL = require("kr1.data.endless")
local function ISW(...)
    return i18n.sw(i18n, ...)
end

local function CJK(default, zh, ja, kr)
    return i18n.cjk(i18n, default, zh, ja, kr)
end
local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

local IS_KR3 = KR_GAME == "kr3"
local IS_KR2 = KR_GAME == "kr2"
local IS_KR1 = KR_GAME == "kr1"

require("constants")

local features = require("features")

require("gg_views_custom")

local data = require("data.game_gui_data")
local tower_menus = require("data.tower_menus_data")
local game_gui = {}

game_gui.required_textures = { "gui_common", "gui_ico", "gui_portraits", "achievements", "encyclopedia",
"gui_notifications_common",
                              "gui_notifications_bg", "view_options"}
game_gui.ref_h = GUI_REF_H
game_gui.ref_w = GUI_REF_W
game_gui.ref_res = TEXTURE_SIZE_ALIAS.ipad
game_gui.selected_controables = {}

local function wid(name)
    return game_gui.window:ci(name)
end

local function unlock_user_power_handler(power_idx)
    if power_idx == 1 then
        game_gui.power_1:set_mode("unlocked")
    elseif power_idx == 2 then
        game_gui.power_2:set_mode("unlocked")
    elseif power_idx == 3 and game_gui.power_3 then
        game_gui.power_3:set_mode("unlocked")
    end
end

local function enemy_reached_goal_handler(enemy)
    if enemy and enemy.enemy and enemy.enemy.lives_cost > 0 then
        S:queue("GUILooseLife")
    end

    if enemy == game_gui.selected_entity then
        game_gui:deselect_entity()
    end
end

local function next_wave_ready_handler(group)
    log.debug("next_wave_ready_handler. group_idx:%s", group.group_idx)
    S:queue("GUINextWaveReady")
    game_gui:show_wave_flags(group)
    game_gui.next_wave_button:enable()

    if game_gui.game.store.level.show_next_wave_balloon then
        game_gui.game.store.level.show_next_wave_balloon = nil

        game_gui:show_balloon("TB_WAVE")
    end
    if game_gui.game.store.level_mode_override == GAME_MODE_ENDLESS then
        if game_gui.game.store.endless.load_from_history then
            game_gui.game.store.endless.load_from_history = false
        else
            if #game_gui.game.store.endless.upgrade_options > 0 and game_gui.game.store.wave_group_number <= 75 then
                if game_gui.endless_select_reward_view.hidden then
                    game_gui.endless_select_reward_view:show()
                end
            end

            local endless = game_gui.game.store.endless
            EU.patch_enemy_growth(endless)
        end
    end
end

local function next_wave_sent_handler(group)
    log.debug("next_wave_sent_handler")
    game_gui:hide_wave_flags()
    game_gui.next_wave_button:disable()
    game_gui:show_early_wave_reward()

    if group.group_idx == 1 then
        local locks = game_gui.game.store.level.locked_powers

        if not locks or #locks == 0 or locks[1] == false then
            unlock_user_power_handler(1)
        end

        if not locks or #locks == 0 or locks[2] == false then
            unlock_user_power_handler(2)
        end

        if game_gui.heroes and #game_gui.heroes > 0 and (not locks or #locks == 0 or locks[3] == false) then
            unlock_user_power_handler(3)
        end

        if game_gui.bag_button then
            local slot = storage:load_slot()

            if slot.bag then
                for k, v in pairs(slot.bag) do
                    if v > 0 then
                        game_gui.bag_button:set_mode("unlocked")

                        break
                    end
                end
            end
        end

        S:stop_group("MUSIC")
        S:queue(string.format("MusicBattle_%02d", game_gui.game.store.level_idx))
    end

    S:queue("GUINextWaveIncoming")
end

local function early_wave_called_handler(group, reward, remaining_time, score_reward)
    game_gui.power_1:early_wave_bonus(remaining_time)
    game_gui.power_2:early_wave_bonus(remaining_time)

    if game_gui.power_3 then
        game_gui.power_3:early_wave_bonus(remaining_time)
    end

    if score_reward then
        game_gui.hud_counters:show_bonus(score_reward)
    end
end

local function hide_gui_handler()
    log.debug("hide_gui_handler")
    game_gui:hide()
end

local function show_gui_handler()
    log.debug("show_gui_handler")
    game_gui:show()
end

local function hero_added_handler(hero)
    log.debug("hero added: %s", hero.template_name)
    game_gui:add_hero(hero)
end

local function hero_added_no_panel_handler(hero)
    game_gui:add_hero_no_panel(hero)
end

local function game_defeat_handler(store)
    game_gui:defeat()
end

local function game_victory_handler(store)
    game_gui:deselect_all()
    game_gui:disable_keys()
    local wait_time
    if store.criket and store.criket.on then
        wait_time = 0.5
    else
        wait_time = 2
    end
    timer:after(wait_time, function()
        game_gui:victory()
    end)
end

local function wave_notification_handler(type, id, force)
    log.debug("wave_notification - type:%s, id:%s", type, id)

    if type == "view" then
        game_gui:show_notification(id, force)
    elseif type == "icon" then
        game_gui:queue_notification_icon(id, force)
    end
end

local function show_balloon_handler(id, at_level_idx)
    log.debug("balloon:%s at_level_idx:%s", id, at_level_idx)

    if not at_level_idx or at_level_idx == game.store.level_idx then
        game_gui:show_balloon(id)
    end
end

local function show_gems_reward_handler(entity, amount)
    if not game_gui.is_premium then
        return
    end

    local v = GemsRewardFx:new(amount)

    v.world_pos = V.vclone(entity.pos)

    if entity.unit then
        v.world_offset = V.vclone(entity.unit.hit_offset)
    end

    game_gui.layer_gui_game:add_child(v, 1)
    S:queue("InAppEarnGems")
end

local function show_achievement_handler(id)
    log.debug("achievement %s", id)
    game_gui:show_achievement(id)
end

local function block_random_power_handler(duration, style)
    game_gui:block_random_power(duration, style)
end

local function debug_ready_user_powers_handler()
    game_gui.power_1:set_mode("ready")
    game_gui.power_2:set_mode("ready")

    if game_gui.power_3 then
        game_gui.power_3:set_mode("ready")
    end

    if game_gui.bag_button then
        game_gui.bag_button:set_mode("unlocked")
    end
end

local function debug_ready_plants_crystals_handler()
    for _, e in pairs(game_gui.game.simulation.store.entities) do
        if table.contains({"plant_magic_blossom", "plant_poison_pumpkin", "crystal_arcane", "crystal_unstable",
                           "paralyzing_tree"}, e.template_name) then
            e.force_ready = true
        end
    end
end

local function atomic_freeze_starts_handler()
    local this = wid("layer_user_item_freeze")

    if this.timer_h then
        timer:cancel(this.timer_h)
    end

    S:queue("InAppAtomicFreezeStart")

    if this.hidden == true then
        this.hidden = false
        this.timer_h = timer:tween(0.25, this, {
            alpha = 1
        }, "linear")
    end
end

local function atomic_freeze_ends_handler()
    local this = wid("layer_user_item_freeze")

    if this.timer_h then
        timer:cancel(this.timer_h)
    end

    S:queue("InAppAtomicFreezeEnd")

    this.timer_h = timer:tween(0.25, this, {
        alpha = 0
    }, "linear", function()
        this.hidden = true
    end)
end

local function atomic_bombs_starts_handler()
    local this = wid("layer_user_item_bomb")

    this.colors.background = {255, 255, 255, 255}
    this.hidden = false
    this.alpha = 1

    timer:tween(1.7, this.colors.background, {
        [2] = 0,
        [3] = 0
    })
    timer:tween(4, this, {
        alpha = 0
    }, "out-quad", function()
        this.hidden = true
    end)
end

local function gem_timewarp_starts_handler()
    local this = wid("layer_user_item_gem_timewarp")

    if this.timer_h then
        timer:cancel(this.timer_h)
    end

    if this.hidden == true then
        this.timer_h = timer:script(function(wait)
            this.hidden = false

            timer:tween(0.3333333333333333, this, {
                alpha = 1
            }, "out-sine")
            wait(0.3333333333333333)
            timer:tween(0.3333333333333333, this, {
                alpha = 0.6
            }, "in-sine")
            wait(0.3333333333333333)
            timer:tween(0.3333333333333333, this, {
                alpha = 1
            }, "out-sine")
            wait(0.3333333333333333)
            timer:tween(0.3333333333333333, this, {
                alpha = 0
            }, "in-sine")
            wait(0.3333333333333333)

            this.hidden = true
        end)
    end
end

local function wrath_of_elynia_starts_handler()
    local this = wid("layer_user_item_wrath_of_elynia")

    if this.timer_h then
        timer:cancel(this.timer_h)
    end

    if this.hidden == true then
        this.hidden = false
        this.timer_h = timer:tween(0.5, this, {
            alpha = 0.35294117647058826
        }, "linear")
    end
end

local function wrath_of_elynia_ends_handler()
    local this = wid("layer_user_item_wrath_of_elynia")

    if this.timer_h then
        timer:cancel(this.timer_h)
    end

    this.timer_h = timer:tween(0.25, this, {
        alpha = 0
    }, "linear", function()
        this.hidden = true
    end)
end

local function hand_midas_starts_handler()
    log.error("TODO TODO TODO")
end

local function hand_midas_ends_handler()
    log.error("TODO TODO TODO")
end

function game_gui:init(w, h, game)
    self.game = game
    self.w = w
    self.h = h

    local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)

    self.sw = sw
    self.sh = sh
    self.gui_scale = scale
    self.mode = GUI_MODE_IDLE
    self.manual_gui_hide = nil
    self.keys_disabled = nil
    self.is_premium = PS.services.iap and PS.services.iap:is_premium()

    local settings = storage:load_settings()
    self.key_shortcuts = storage:load_keyset()

    self.pause_on_switch = settings.pause_on_switch
    local window = KWindow:new(V.v(sw, sh))

    self.window = window
    window.timer = timer
    window.scale.x, window.scale.y = scale, scale
    window.colors.background = {0, 0, 0, 0}
    window.font_scale = scale
    window.origin = origin
    GGLabel.static.font_scale = scale
    GGLabel.static.ref_h = self.ref_h

    local pickview = PickView:new(sw, sh)

    pickview.pos = v(0, 0)

    local towermenu = TowerMenu:new()

    towermenu.hidden = true

    local criketmenu = CriketMenu:new()
    criketmenu.hidden = true

    local towertooltip = TowerMenuTooltip:new()

    towertooltip.hidden = true

    local rallyrange = RangeCircle:new("rally_circle")

    rallyrange.hidden = true

    local tower_range = RangeCircle:new("range_circle")

    tower_range.hidden = true

    local meleerange = RangeCircle:new("rally_circle")

    meleerange.hidden = true

    local rangedrange = RangeCircle:new("range_circle")

    rangedrange.hidden = true

    local tower_range_upgrade = RangeCircle:new("range_circle")

    tower_range_upgrade.hidden = true

    local point_confirm = KImageView:new("confirm_feedback_0001")

    point_confirm.animation = {
        to = 11,
        prefix = "confirm_feedback",
        from = 1
    }
    point_confirm.hidden = true
    point_confirm.anchor = v(point_confirm.size.x * 0.5, point_confirm.size.y * 0.5)

    local rallyflag = KImageView:new("rally_feedback_0005")

    rallyflag.animation = {
        to = 30,
        prefix = "rally_feedback",
        from = 1
    }
    rallyflag.hidden = true
    rallyflag.anchor = v(rallyflag.size.x * 0.5, rallyflag.size.y * 0.5)

    local hud_bottom = HudBottomView:new(sw, sh)
    local hud_counters = HudCountersView:new(self.game.simulation.store.level_mode)

    hud_counters.anchor = v(0, 0)
    hud_counters.pos = v(0, -22)
    hud_counters.scale = v(0.9, 0.9)

    local incoming_tooltip = IncomingTooltip:new()

    incoming_tooltip.hidden = true

    local mouse_pointer = MousePointer:new()

    mouse_pointer.hidden = true

    local hud_pause = HudPauseButton:new()

    hud_pause.anchor = v(hud_pause.size.x, 0)
    hud_pause.pos = v(sw + (IS_KR3 and 0 or -37), -21)
    hud_pause.scale = v(0.9, 0.9)

    local pauseview = PauseView:new()

    pauseview.anchor = v(pauseview.size.x * 0.5, pauseview.size.y * 0.5)
    pauseview.pos.x = self.sw * 0.5
    pauseview.hidden = true

    local hud_noti_queue = NotificationQueue:new()

    hud_noti_queue.anchor = v(0, 0)
    hud_noti_queue.pos = v(80, 100)
    hud_noti_queue.propagate_on_click = true

    local notiview = NotificationView:new()

    notiview.pos = v(self.sw * 0.5, self.sh * 0.5)
    notiview.hidden = true

    local victoryview = VictoryView:new(self.game.simulation.store.level_mode)

    victoryview.pos.x, victoryview.pos.y = self.sw * 0.5, self.sh / 3
    victoryview.anchor.x, victoryview.anchor.y = victoryview.size.x * 0.5, victoryview.size.y * 0.5
    victoryview.hidden = true

    local defeatview

    -- if self.game.simulation.store.level_mode == GAME_MODE_ENDLESS then
    if false then -- TODO: endless模式的胜利界面还没做完，先用普通模式的
        defeatview = KView:new_from_table(kui_db:get_table("game_gui_defeat_view", {
            SW = self.sw,
            SH = self.sh
        }))
        defeatview:ci("defeat_endless_view_try_again_button").on_click = function(this)
            S:queue("GUIButtonCommon")
            game_gui:restart_game()
        end
        defeatview:ci("defeat_endless_view_quit_button").on_click = function(this)
            S:queue("GUIButtonCommon")
            game_gui:go_to_map()
        end

        function defeatview.show(this)
            S:stop_all()
            S:queue("GUIQuestCompleted")
            game_gui.overlay:show()

            local level_mode = game_gui.game.store.level_mode
            local level_idx = game_gui.game.store.level_idx
            local gems = game_gui.game.store.gems_collected or 0

            timer:script(function(wait)
                this.hidden = false

                local gv = this:ci("gems_view")

                gv.hidden = true
                wid("waves_label").text = game_gui.game.store.wave_group_number
                wid("score_label").text = game_gui.game.store.player_score

                local max_taunt_idx = 120
                local taunt_idx = km.clamp(1, max_taunt_idx, game_gui.game.store.wave_group_number)
                local taunt_text, taunt_key

                repeat
                    taunt_key = string.format("ENDLESS_GUI_VICTORY_TAUNT_%04d", taunt_idx)
                    taunt_text = _(taunt_key)
                    taunt_idx = taunt_idx + 1
                until taunt_key ~= taunt_text or max_taunt_idx < taunt_idx

                this:ci("taunt_label").text = taunt_text

                local b = this:ci("badge_view")

                b.scale = V.v(0.5, 0.5)

                timer:tween(0.6, b.scale, {
                    x = 1,
                    y = 1
                }, "out-back", nil, 1.5)
                wait(0.15)

                this:ci("gems_label").text = gems
                gv.hidden = false

                timer:tween(0.4, gv.pos, {
                    x = gv.shown_x
                }, "out-elastic")
                S:queue("InAppExtraGold")

                if PS.services.fullads then
                    flows = PS.services.fullads:get_workflows("defeat_endless")

                    if flows then
                        for _, flow in pairs(flows) do
                            game_gui:show_fullads_icon(flow.id, flow)
                        end
                    end
                end

                local cb = wid("defeat_endless_view_try_again_button")
                local cv = wid("defeat_endless_view_try_again")
                local rb = wid("defeat_endless_view_quit_button")
                local rv = wid("defeat_endless_view_quit")

                cb:disable(false)
                rb:disable(false)

                cb.hidden = false
                cv.hidden = false

                timer:tween(0.5, cv.pos, {
                    y = cv.shown_y
                }, "out-back")
                wait(0.5)

                rv.hidden = false

                timer:tween(0.5, rv.pos, {
                    y = rv.shown_y
                }, "out-back")
                wait(0.5)
                cb:enable()
                rb:enable()
                game_gui:set_mode(GUI_MODE_FINISHED)
            end)
        end
    else
        defeatview = DefeatView:new()
        defeatview.pos.x, defeatview.pos.y = self.sw * 0.5, 3 * self.sh / 7
        defeatview.anchor.x, defeatview.anchor.y = defeatview.size.x * 0.5, defeatview.size.y * 0.5
    end

    defeatview.hidden = true

    local endless_select_reward_view = EndlessSelectRewardView:new(sw, sh)
    endless_select_reward_view.hidden = true
    endless_select_reward_view.pos = v(0, 0)

    local overlay = OverlayView:new(sw, sh)

    overlay.hidden = true

    local comic_transition = KView:new(V.v(sw, sh))

    comic_transition.colors.background = {0, 0, 0, 255}

    if self.game.store.level.show_comic_idx then
        comic_transition.hidden = false
        comic_transition.alpha = 1

        timer:tween(0.5, comic_transition, {
            alpha = 0
        }, "out-linear", function()
            comic_transition.hidden = true
        end)
    else
        comic_transition.hidden = true
    end

    local layer_freeze, layer_bomb, layer_wrath, layer_timewarp

    if IS_KR1 or IS_KR2 then
        layer_freeze = KView:new_from_table(kui_db:get_table("game_gui_layer_user_item_freeze", {
            SW = self.sw,
            SH = self.sh
        }))
        layer_bomb = KView:new_from_table(kui_db:get_table("game_gui_layer_user_item_bomb", {
            SW = self.sw,
            SH = self.sh
        }))
    elseif IS_KR3 then
        -- block empty
    end

    local layer_gui = KView:new()

    layer_gui.id = "layer_gui"
    layer_gui.pos = v(0, 0)
    layer_gui.size = v(sw, sh)
    layer_gui.propagate_on_click = true
    layer_gui.propagate_on_down = true

    local layer_gui_game = KView:new()

    layer_gui_game.id = "layer_gui_game"
    layer_gui_game.pos = v(0, 0)
    layer_gui_game.size = v(sw, sh)
    layer_gui_game.propagate_on_click = true
    layer_gui_game.propagate_on_down = true

    local layer_gui_hud = KView:new()

    layer_gui_hud.id = "layer_gui_hud"
    layer_gui_hud.pos = v(0, 0)
    layer_gui_hud.size = v(sw, sh)
    layer_gui_hud.propagate_on_click = true
    layer_gui_hud.propagate_on_down = true

    local layer_gui_top = KView:new()

    layer_gui_top.id = "layer_gui_top"
    layer_gui_top.pos = v(0, 0)
    layer_gui_top.size = v(sw, sh)
    layer_gui_top.propagate_on_click = true
    layer_gui_top.propagate_on_down = true

    layer_gui_game:add_child(rallyrange)
    layer_gui_game:add_child(tower_range)
    layer_gui_game:add_child(tower_range_upgrade)
    layer_gui_game:add_child(meleerange)
    layer_gui_game:add_child(rangedrange)
    layer_gui_game:add_child(towertooltip)
    layer_gui_game:add_child(towermenu)
    layer_gui_game:add_child(criketmenu)
    layer_gui_game:add_child(incoming_tooltip)

    if IS_KR1 or IS_KR2 then
        layer_gui_hud:add_child(layer_freeze)
        layer_gui_hud:add_child(layer_bomb)
    elseif IS_KR3 then
        -- block empty
    end

    layer_gui_hud:add_child(hud_counters)
    layer_gui_hud:add_child(hud_pause)
    layer_gui_hud:add_child(hud_noti_queue)
    layer_gui_hud:add_child(hud_bottom)
    layer_gui_hud:add_child(mouse_pointer)
    layer_gui_top:add_child(overlay)
    layer_gui_top:add_child(notiview)
    layer_gui_top:add_child(pauseview)
    layer_gui_top:add_child(endless_select_reward_view)
    layer_gui_top:add_child(victoryview)
    layer_gui_top:add_child(defeatview)
    layer_gui_top:add_child(comic_transition)
    layer_gui:add_child(rallyflag)
    layer_gui:add_child(point_confirm)
    layer_gui:add_child(layer_gui_game)
    layer_gui:add_child(layer_gui_hud)
    layer_gui:add_child(layer_gui_top)
    window:add_child(pickview)
    window:add_child(layer_gui)

    self.endless_select_reward_view = endless_select_reward_view
    self.pickview = pickview
    self.towermenu = towermenu
    self.criketmenu = criketmenu
    self.towertooltip = towertooltip
    self.rallyrange = rallyrange
    self.tower_range = tower_range
    self.tower_range_upgrade = tower_range_upgrade
    self.melee_range = meleerange
    self.ranged_range = rangedrange
    self.point_confirm = point_confirm
    self.rallyflag = rallyflag
    self.hud_bottom = hud_bottom
    self.hud_counters = hud_counters
    self.hud_pause = hud_pause
    self.hud_noti_queue = hud_noti_queue
    self.mouse_pointer = mouse_pointer
    self.overlay = overlay
    self.pauseview = pauseview
    self.notiview = notiview
    self.victoryview = victoryview
    self.defeatview = defeatview
    self.incoming_tooltip = incoming_tooltip
    self.comic_transition = comic_transition
    self.layer_gui = layer_gui
    self.layer_gui_game = layer_gui_game
    self.layer_gui_hud = layer_gui_hud
    self.layer_gui_top = layer_gui_top
    self.heroes = {}
    self.heroes_no_panel = {}
    signal.register("enemy-reached-goal", enemy_reached_goal_handler)
    signal.register("next-wave-ready", next_wave_ready_handler)
    signal.register("next-wave-sent", next_wave_sent_handler)
    signal.register("early-wave-called", early_wave_called_handler)
    signal.register("hide-gui", hide_gui_handler)
    signal.register("show-gui", show_gui_handler)
    signal.register("hero-added", hero_added_handler)
    signal.register("hero-added-no-panel", hero_added_no_panel_handler)
    signal.register("hero-removed-no-panel", function(hero)
        game_gui:remove_hero_no_panel(hero)
    end)
    signal.register("game-defeat", game_defeat_handler)
    signal.register("game-victory", game_victory_handler)
    signal.register("unlock-user-power", unlock_user_power_handler)
    signal.register("wave-notification", wave_notification_handler)
    signal.register("show-balloon", show_balloon_handler)
    signal.register("show-gems-reward", show_gems_reward_handler)
    signal.register("got-achievement", show_achievement_handler)
    signal.register("block-random-power", block_random_power_handler)
    signal.register("atomic-freeze-starts", atomic_freeze_starts_handler)
    signal.register("atomic-freeze-ends", atomic_freeze_ends_handler)
    signal.register("atomic-bomb-starts", atomic_bombs_starts_handler)
    signal.register("gem-timewarp-starts", gem_timewarp_starts_handler)
    signal.register("wrath-of-elynia-starts", wrath_of_elynia_starts_handler)
    signal.register("wrath-of-elynia-ends", wrath_of_elynia_ends_handler)
    signal.register("hand-midas-starts", hand_midas_starts_handler)
    signal.register("hand-midas-ends", hand_midas_ends_handler)
    signal.register("debug-ready-user-powers", debug_ready_user_powers_handler)
    signal.register("debug-ready-plants-crystals", debug_ready_plants_crystals_handler)
end

function game_gui:destroy()
    timer:clear()

    self.heroes = nil

    self.window:destroy()

    self.window = nil
    self.game = nil

    SU.remove_references(self, KView)
    signal.remove("enemy-reached-goal", enemy_reached_goal_handler)
    signal.remove("next-wave-ready", next_wave_ready_handler)
    signal.remove("next-wave-sent", next_wave_sent_handler)
    signal.remove("early-wave-called", early_wave_called_handler)
    signal.remove("hide-gui", hide_gui_handler)
    signal.remove("show-gui", show_gui_handler)
    signal.remove("hero-added", hero_added_handler)
    signal.remove("game-defeat", game_defeat_handler)
    signal.remove("game-victory", game_victory_handler)
    signal.remove("unlock-user-power", unlock_user_power_handler)
    signal.remove("wave-notification", wave_notification_handler)
    signal.remove("show-balloon", show_balloon_handler)
    signal.remove("show-gems-reward", show_gems_reward_handler)
    signal.remove("got-achievement", show_achievement_handler)
    signal.remove("block-random-power", block_random_power_handler)
    signal.remove("atomic-freeze-starts", atomic_freeze_starts_handler)
    signal.remove("atomic-freeze-ends", atomic_freeze_ends_handler)
    signal.remove("atomic-bomb-starts", atomic_bombs_starts_handler)
    signal.remove("gem-timewarp-starts", gem_timewarp_starts_handler)
    signal.remove("wrath-of-elynia-starts", wrath_of_elynia_starts_handler)
    signal.remove("wrath-of-elynia-ends", wrath_of_elynia_ends_handler)
    signal.remove("hand-midas-starts", hand_midas_starts_handler)
    signal.remove("hand-midas-ends", hand_midas_ends_handler)
    signal.remove("debug-ready-user-powers", debug_ready_user_powers_handler)
    signal.remove("debug-ready-plants-crystals", debug_ready_plants_crystals_handler)
end

function game_gui:update(dt)
    timer:update(dt)
    local e = game_gui.selected_entity
    if e then
        if e.melee and e.melee.range then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_melee_range(ux, uy, e.melee.range)
        end
        if e.ranged and e.ranged.attacks[1].max_range and not e.ranged.attacks[1].disabled then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_ranged_range(ux, uy, e.ranged.attacks[1].max_range)
        elseif e.timed_attacks and e.timed_attacks.list[1].max_range and not e.timed_attacks.list[1].disabled then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_ranged_range(ux, uy, e.timed_attacks.list[1].max_range)
        end
    end

    self.window:update(dt)
end

function game_gui:mousepressed(x, y, button)
    if button == 2 and not DEBUG_RIGHT_CLICK then
        self:deselect_all()
    else
        self.window:mousepressed(x, y, button)
    end
end

function game_gui:mousereleased(x, y, button)
    self.window:mousereleased(x, y, button)
end

function game_gui:keypressed(key, isrepeat)
    if isrepeat then
        return
    end

    if DBG_SLIDE_EDITOR and game_gui.SEL_VIEW then
        local inc = 1
        local shift = love.keyboard.isDown("lshift")
        local ctrl = love.keyboard.isDown("lctrl")

        if shift then
            inc = 20
        end

        local av = game_gui.SEL_VIEW

        if ctrl then
            if key == "up" then
                av.size.y = av.size.y - inc
            elseif key == "down" then
                av.size.y = av.size.y + inc
            elseif key == "right" then
                av.size.x = av.size.x + inc
            elseif key == "left" then
                av.size.x = av.size.x - inc
            end
        elseif key == "up" then
            av.pos.y = av.pos.y - inc
        elseif key == "down" then
            av.pos.y = av.pos.y + inc
        elseif key == "right" then
            av.pos.x = av.pos.x + inc
        elseif key == "left" then
            av.pos.x = av.pos.x - inc
        end

        if key == "7" then
            av.r = av.r - 5 * math.pi / 180
        elseif key == "8" then
            av.r = av.r + 5 * math.pi / 180
        end

        if key == "-" then
            av.font_size = km.clamp(1, 200, av.font_size - 1)
            av.font = nil
        elseif key == "=" then
            av.font_size = km.clamp(1, 200, av.font_size + 1)
            av.font = nil
        end

        if key == "0" then
            if av.text_align == "left" then
                av.text_align = "center"
            elseif av.text_align == "center" then
                av.text_align = "right"
            elseif av.text_align == "right" then
                av.text_align = "left"
            end
        end

        if key == "h" then
            av.hidden = not av.hidden
        end

        if key == "9" then
            if not av.colors.background then
                av.colors.background = {0, 200, 200, 150}
            else
                av.colors.background = nil
            end
        end

        if key == "space" or key == "return" then
            local out = string.format("pos=v(%s,%s), size=v(%s,%s), font_size=%s, text_align='%s'\n", av.pos.x,
                av.pos.y, av.size.x, av.size.y, av.font_size, av.text_align)

            log.debug("\n%s\n", out)

            if av and av.parent then
                local out = "---------------------------\n"

                for _, vv in ipairs(av.parent.children) do
                    out = out ..
                              string.format("pos=v(%s,%s), size=v(%s,%s), r=%s, font_size=%s, text_align='%s'\n",
                            vv.pos.x, vv.pos.y, vv.size.x, vv.size.y, vv.r, vv.font_size, vv.text_align)
                end

                out = out .. "---------------------------\n"

                log.debug("\n%s\n", out)
            end
        end
    end

    if key == KEYPRESS_ESCAPE then
        if not self.notiview.hidden then
            self.notiview:hide()
        elseif not self.victoryview.hidden then
            game_gui:go_to_map()
        elseif not self.defeatview.hidden then
            game_gui:go_to_map()
        elseif not self.pauseview.hidden then
            self.pauseview:hide()
        elseif self.selected_entity or self.mode ~= GUI_MODE_IDLE then
            self:deselect_all()
        elseif not self.keys_disabled then
            self.pauseview:show()
        end
    end

    if self.keys_disabled then
        return
    end

    local ks = self.key_shortcuts

    if table.contains(ks.pow_1, key) and not self.power_1:is_disabled() then
        self.power_1:toggle_selection()
    elseif table.contains(ks.pow_2, key) and not self.power_2:is_disabled() then
        self.power_2:toggle_selection()
        -- elseif IS_KR3 and key == ks.pow_3 and not self.power_3:is_disabled() then
        --     self.power_3:toggle_selection()
    elseif table.contains(ks.hero_1, key) then
        if self.heroes and self.heroes[1] then
            self.heroes[1]:on_click(1, 0, 0)
        end
    elseif table.contains(ks.hero_2, key) then
        if self.heroes and self.heroes[2] then
            self.heroes[2]:on_click(1, 0, 0)
        end
    elseif table.contains(ks.hero_3, key) then
        if self.heroes_no_panel and self.heroes_no_panel[1] then
            local e = game_gui:entity_by_id(self.heroes_no_panel[1].id)
            if e == game_gui.selected_entity then
                game_gui:deselect_entity()
            elseif e then
                game_gui:deselect_all()
                game_gui:select_entity(e)
            end
        end
    elseif table.contains(ks.hero_4, key) then
        if self.heroes_no_panel and self.heroes_no_panel[2] then
            local e = game_gui:entity_by_id(self.heroes_no_panel[2].id)
            if e == game_gui.selected_entity then
                game_gui:deselect_entity()
            elseif e then
                game_gui:deselect_all()
                game_gui:select_entity(e)
            end
        end
    elseif table.contains(ks.hero_5, key) then
        if self.heroes_no_panel and self.heroes_no_panel[3] then
            local e = game_gui:entity_by_id(self.heroes_no_panel[3].id)
            if e == game_gui.selected_entity then
                game_gui:deselect_entity()
            elseif e then
                game_gui:deselect_all()
                game_gui:select_entity(e)
            end
        end
    elseif table.contains(ks.reinforce, key) then
        if #self.selected_controables > 0 then
            self:deselect_controables()
        else
            for _, e in pairs(self.game.simulation.store.soldiers) do
                if e.controable and not e.health.dead and not e.controable_other then
                    self:select_controable(e)
                end
            end
            self:set_mode(GUI_MODE_RALLY_CONTROABLES)
        end
    elseif table.contains(ks.reinforce_other, key) then
        if #self.selected_controables > 0 then
            self:deselect_controables()
        else
            for _, e in pairs(self.game.simulation.store.soldiers) do
                if e.controable and not e.health.dead and e.controable_other then
                    self:select_controable(e)
                end
            end
            self:set_mode(GUI_MODE_RALLY_CONTROABLES)
        end
    elseif table.contains(ks.slow, key) then
        self.game.simulation.store.speed_factor = self.game.simulation.store.speed_factor * 0.5
    elseif table.contains(ks.quick, key) then
        self.game.simulation.store.speed_factor = self.game.simulation.store.speed_factor * 2
    elseif table.contains(ks.normal, key) then
        self.game.simulation.store.speed_factor = 1
        -- elseif not game.DBG_ENEMY_PAGES and self.is_premium and key == ks.bag then
        --     if self.bag_button and not self.bag_button:is_disabled() then
        --         self.bag_button:on_click()
        --     end
    elseif table.contains(ks.next_wave, key) then
        if not self.next_wave_button:is_disabled() then
            game_gui.game.store.send_next_wave = true
        end
    elseif table.contains(ks.criket_toggle, key) then
        if self.criketmenu.hidden then
            self.criketmenu:show()
        else
            self.criketmenu:hide()
        end
    elseif table.contains(ks.barrack_seek, key) then
        local store = self.game.simulation.store
        for _, t in pairs(store.towers) do
            if t.barrack and t.barrack.soldiers then
                local busy = true
                for _, s in pairs(t.barrack.soldiers) do
                    if s.health and not s.health.dead and s.soldier.target_id == nil then
                        busy = false
                        break
                    end
                end
                if not busy then
                    local enemy = U.find_foremost_enemy(store, t.pos, 0, t.barrack.rally_range, nil, F_BLOCK, F_FLYING)
                    if enemy then
                        t.barrack.rally_pos.x = enemy.pos.x
                        t.barrack.rally_pos.y = enemy.pos.y
                        t.barrack.rally_new = true
                    end
                end
            end
        end
    elseif table.contains(ks.endless_shop, key) and self.game.store.level_mode_override == GAME_MODE_ENDLESS and
        self.game.store.player_gold >= EL.gold_extra_cost and game_gui.endless_select_reward_view.hidden then
        self.game.store.player_gold = self.game.store.player_gold - EL.gold_extra_cost
        game_gui.endless_select_reward_view:show(true)
        -- elseif self.is_premium and self.bag_button and not self.bag_button:is_disabled() and
        --     table.contains(table.keys(ks.all_items), key) then
        --     local bb = self.bag_button
        --     local item = ks.all_items[key]
        --     local last_selected_item = bb.selected_item

        --     self:deselect_all()

        --     if last_selected_item ~= item then
        --         local ib = wid("bag_item_" .. item)

        --         if ib and not ib:is_disabled() then
        --             bb:select_item(item)
        --         end
        --     end
    end
end

function game_gui:keyreleased(key, isrepeat)
    return
end

function game_gui:focus(focus)
    if focus or self.game.store.paused or self.gui_hud_hidden or DEBUG_IGNORE_FOCUS then
        return
    end

    if self.pause_on_switch and self.pauseview then
        self.pauseview:show()
    end
end

function game_gui:g2u(p, snap)
    local sx = (p.x * self.game.game_scale + self.game.game_ref_origin.x - self.window.origin.x) / self.gui_scale
    local sy = (-1 * (p.y * self.game.game_scale + self.game.game_ref_origin.y - self.sh * self.gui_scale) -
                   self.window.origin.y) / self.gui_scale

    if snap then
        sx, sy = math.floor(sx + 0.5), math.floor(sy + 0.5)
    end

    return sx, sy
end

function game_gui:u2g(s)
    local px = (s.x * self.gui_scale + self.window.origin.x - self.game.game_ref_origin.x) / self.game.game_scale
    local py =
        (self.sh * self.gui_scale - (s.y * self.gui_scale + self.window.origin.y) - self.game.game_ref_origin.y) /
            self.game.game_scale

    return px, py
end

function game_gui:entity_at_pos(x, y)
    return U.find_entity_at_pos(self.game.simulation.store.entities, x, y)
end

function game_gui:entity_by_id(id)
    return self.game.simulation.store.entities[id]
end

function game_gui:list_heroes()
    local result = table.filter(self.game.simulation.store.pending_inserts, function(_, e)
        return e.hero
    end)

    table.sort(result, function(e1, e2)
        return e1.id < e2.id
    end)

    return result
end

function game_gui:set_mode(mode)
    local new_mode = mode or GUI_MODE_IDLE

    log.debug("  CHANGING MODE: %s -> %s", self.mode, new_mode)

    self.mode = new_mode

    self.mouse_pointer:update_pointer(mode)
end

function game_gui:show_point_confirm(x, y)
    if self.timer then
        timer:cancel(self.timer)
    end

    self.point_confirm.pos.x, self.point_confirm.pos.y = x, y
    self.point_confirm.hidden = false
    self.point_confirm.alpha = 1
    self.point_confirm.ts = 0
    self.timer = timer:after(0.36666666666666664, function()
        self.point_confirm.hidden = true
        self.timer = nil
    end)
end

function game_gui:show_rally_flag(x, y)
    if self.timer then
        timer:cancel(self.timer)
    end

    self.rallyflag.pos.x, self.rallyflag.pos.y = x, y
    self.rallyflag.hidden = false
    self.rallyflag.alpha = 1
    self.rallyflag.ts = 0
    self.timer = timer:tween(1.5, self.rallyflag, {
        alpha = 0
    }, "out-quad", function()
        self.rallyflag.hidden = true
        self.timer = nil
    end)
end

function game_gui:show_rally_range(x, y, range)
    local rr = self.rallyrange

    rr.range_shown = range
    rr.pos.x, rr.pos.y = x, y
    rr.scale = v(range * self.game.game_scale / (rr.actual_radius.x * self.gui_scale),
        range * self.game.game_scale * ASPECT / (rr.actual_radius.y * self.gui_scale))
    rr.hidden = false
end

function game_gui:hide_rally_range()
    local rr = self.rallyrange

    rr.range_shown = nil
    rr.hidden = true
end

function game_gui:show_tower_range(x, y, range)
    local r = self.tower_range

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale = v(range * self.game.game_scale / (r.actual_radius.x * self.gui_scale),
        range * self.game.game_scale * ASPECT / (r.actual_radius.y * self.gui_scale))
    r.hidden = false
end

function game_gui:show_tower_range_upgrade(x, y, range)
    local r = self.tower_range_upgrade

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale = v(range * self.game.game_scale / (r.actual_radius.x * self.gui_scale),
        range * self.game.game_scale * ASPECT / (r.actual_radius.y * self.gui_scale))
    r.hidden = false
end

function game_gui:show_melee_range(x, y, range)
    local r = self.melee_range

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale.x = range * self.game.game_scale / (r.actual_radius.x * self.gui_scale)
    r.scale.y = range * self.game.game_scale * ASPECT / (r.actual_radius.y * self.gui_scale)
    r.hidden = false
end

function game_gui:show_ranged_range(x, y, range)
    local r = self.ranged_range

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale.x = range * self.game.game_scale / (r.actual_radius.x * self.gui_scale)
    r.scale.y = range * self.game.game_scale * ASPECT / (r.actual_radius.y * self.gui_scale)
    r.hidden = false
end

function game_gui:hide_tower_range_upgrade()
    self.tower_range_upgrade.hidden = true
    self.tower_range_upgrade.range_shown = nil
end

function game_gui:hide_tower_ranges()
    self.tower_range.hidden = true
    self.tower_range.range_shown = nil
    self.tower_range_upgrade.hidden = true
    self.tower_range_upgrade.range_shown = nil
end

function game_gui:hide_melee_range()
    self.melee_range.hidden = true
    self.melee_range.range_shown = nil
end

function game_gui:hide_ranged_range()
    self.ranged_range.hidden = true
    self.ranged_range.range_shown = nil
end

function game_gui:show_invalid_point_cross(x, y)
    self.mouse_pointer:show_cross()
end

function game_gui:show_wave_flags(group)
    self.wave_flags = {}

    local store = self.game.store
    local flags_positions = store.level.locations.entrances
    if not flags_positions then
        return
    end

    for _, w in pairs(group.waves) do
        local item = flags_positions[w.path_index]

        if item and P:is_path_active(w.path_index) then
            local duration = group.group_idx > 1 and group.interval / FPS or nil
            local incoming_report = GU.incoming_wave_report(group, w.path_index, self.game.store.level_mode)

            if incoming_report and #incoming_report > 0 then
                local wf = WaveFlag:new(w.some_flying, duration, incoming_report, w.path_index)
                local wfx, wfy = self:g2u(item.pos)

                wf.pointer.r = item.r - math.pi * 0.5
                wf.hidden = false

                local vf = V.v(V.rotate(-item.r, 1, 0))
                local pf = V.v(wfx, wfy)

                wf.pos = self:find_flag_position(pf, vf, 50, item.len)

                self.layer_gui_game:add_child(wf)
                wf:order_below(self.towertooltip)
                table.insert(self.wave_flags, wf)
            end
        end
    end
end

function game_gui:hide_wave_flags()
    if self.wave_flags then
        for _, wf in pairs(self.wave_flags) do
            wf:hide()
        end

        self.wave_flags = nil
    end
end

function game_gui:find_flag_position(pf, vf, margin, len)
    local function intersection(p1, v1, p2, v2)
        local v1xv2 = V.cross(v1.x, v1.y, v2.x, v2.y)

        if math.abs(v1xv2) < 1e-05 then
            return nil
        else
            local sx, sy = V.sub(p2.x, p2.y, p1.x, p1.y)
            local m = V.cross(sx, sy, v2.x, v2.y) / v1xv2
            local pi = V.v(V.add(p1.x, p1.y, V.mul(m, v1.x, v1.y)))
            local a = V.angleTo(v1.x, v1.y, pi.x - p1.x, pi.y - p1.y)

            return pi, math.abs(a) < math.pi / 4
        end
    end

    local pt, vt = v(0, 15), v(1, 0)
    local pb, vb = v(0, self.sh - 15), v(1, 0)
    local pr, vr = v(self.sw, 0), v(0, 1)
    local pl, vl = v(0, 0), v(0, 1)
    local borders = {{pb, vb}, {pt, vt}, {pr, vr}, {pl, vl}}
    local isects = {}

    for _, b in pairs(borders) do
        local pi, towards = intersection(pf, vf, b[1], b[2])

        if pi then
            table.insert(isects, pi)
        end
    end

    table.sort(isects, function(p1, p2)
        return V.dist2(pf.x, pf.y, p1.x, p1.y) < V.dist2(pf.x, pf.y, p2.x, p2.y)
    end)

    local pi = isects[1]

    if pi.y == pt.y or pi.y == pb.y then
        return pf
    else
        if len and len < V.dist(pf.x, pf.y, pi.x, pi.y) then
            local ox, oy = V.mul(len, vf.x, vf.y)

            return V.v(V.add(pf.x, pf.y, ox, oy))
        else
            local ox, oy = V.mul(-margin, vf.x, vf.y)

            pi.x, pi.y = V.add(pi.x, pi.y, ox, oy)
        end

        return pi
    end
end

-- 内部调用，不直接暴露给用户
function game_gui:select_controable(e)
    table.insert(self.selected_controables, e)
end

function game_gui:deselect_controables()
    self.selected_controables = {}
    self:set_mode()
end

function game_gui:select_entity(e)
    if e and e.ui and not e.ui.can_select then
        log.debug("cannot select: entity %s has ui.can_select = false", e.id)

        return
    end

    if self.selected_entity and e ~= self.selected_entity then
        self:deselect_entity()
    end

    self.selected_entity = e

    if e.tower then
        game_gui.towermenu:show()
    elseif e.hero then
        self:set_mode(GUI_MODE_RALLY_HERO)
        self:select_hero(e.id)
    elseif e.controable then
        self:set_mode(GUI_MODE_RALLY_CONTROABLE)
    end

    if game_gui.bag_button then
        game_gui.bag_button:deselect()
    end

    game_gui.hud_bottom.infobar:show()

    if e.enemy or e.soldier or e.barrack then
        if e.soldier and e.soldier.tower_id and self.game.simulation.store.entities[e.soldier.tower_id] then
            local tower = self.game.simulation.store.entities[e.soldier.tower_id]

            game_gui:set_mode(GUI_MODE_RALLY_TOWER)
            local ux, uy = game_gui:g2u(V.v(V.add(tower.pos.x, tower.pos.y, tower.tower.range_offset.x,
                tower.tower.range_offset.y)))

            game_gui:show_rally_range(ux, uy, tower.barrack.rally_range)
        else
            local m = E:create_entity("entity_marker_controller")
            m.target = e
            self.game.simulation:insert_entity(m)
            self.selected_entity_marker = m
        end
    end
end

function game_gui:deselect_entity()
    if self.selected_entity and self.selected_entity.hero then
        self:deselect_heroes()
    end

    self.towermenu:hide()
    self.hud_bottom.infobar:hide()
    self:hide_melee_range()
    self:hide_ranged_range()
    if self.selected_entity_marker then
        self.selected_entity_marker.done = true
    end

    self.selected_entity = nil
    self.selected_controables = {}
    self:set_mode()
end

function game_gui:deselect_powers()
    for _, p in pairs({self.power_1, self.power_2, self.power_3}) do
        if p and p.mode == "selected" then
            self:set_mode()
            p:set_mode("default")
        end
    end
end

function game_gui:deselect_all()
    local e = self.selected_entity

    if e and e.user_selection then
        e.user_selection.in_progress = false
        e.user_selection.new_pos = nil
    end

    self:deselect_powers()
    self:deselect_entity()
    self:hide_rally_range()

    if self.bag_button then
        self.bag_button:deselect()
    end
end

function game_gui:deselect_heroes()
    for _, h in pairs(self.heroes) do
        h:deselect()
    end
end

function game_gui:select_hero(id)
    for _, h in pairs(self.heroes) do
        if h.hero_id == id then
            h:select()
        end
    end
end

function game_gui:add_hero(hero_entity)
    local hero = self.hud_bottom:add_hero(hero_entity)

    table.insert(self.heroes, hero)
end

function game_gui:add_hero_no_panel(hero_entity)
    table.insert(self.heroes_no_panel, hero_entity)
end

function game_gui:remove_hero_no_panel(hero_entity)
    for i, h in ipairs(self.heroes_no_panel) do
        if h.id == hero_entity.id then
            table.remove(self.heroes_no_panel, i)
            break
        end
    end
end

function game_gui:disable_keys()
    self.keys_disabled = true
end

function game_gui:enable_keys()
    if not self.manual_gui_hide then
        self.keys_disabled = nil
    end
end

function game_gui:hide()
    if self.manual_gui_hide then
        return
    end

    self.manual_gui_hide = true

    self:disable_keys()
    self:deselect_all()
    self.pickview:disable()
    self.hud_bottom:hide()
    self.hud_pause:hide()
    self.hud_counters:hide()

    if self.wave_flags then
        for _, f in pairs(self.wave_flags) do
            f.hidden = true
        end
    end

    if self.hud_noti_queue then
        self.hud_noti_queue:hide()
    end
end

function game_gui:show()
    if not self.manual_gui_hide then
        return
    end

    self.manual_gui_hide = nil

    self:enable_keys()
    self.pickview:enable()
    self.hud_bottom:show()
    self.hud_pause:show()
    self.hud_counters:show()

    if self.wave_flags then
        for _, f in pairs(self.wave_flags) do
            f.hidden = false
        end
    end

    if self.hud_noti_queue then
        self.hud_noti_queue:show()
    end
end

function game_gui:defeat()
    self.game.store.paused = true

    self:hide_wave_flags()
    self:deselect_all()
    self:disable_keys()
    self.defeatview:show()
end

function game_gui:victory()
    if self.pauseview and not self.pauseview.hidden then
        self.pauseview:hide()
    end

    self.game.store.paused = true

    self:deselect_all()

    if self.game.store.custom_game_outcome then
        self.game.done_callback(self.game.store.custom_game_outcome)
    else
        self.victoryview:show()
    end
end

function game_gui:go_to_map()
    if self.game.store.main_hero and not GS.hero_xp_ephemeral then
        local hero = self.game.store.main_hero
        local slot = storage:load_slot()

        slot.heroes.status[hero.template_name].xp = hero.hero.xp

        storage:save_slot(slot)
    end
    if self.game.store.level_mode_override == GAME_MODE_ENDLESS then
        local endless_data = self.game.store.endless
        -- 保存玩家基础信息
        endless_data.player_gold = self.game.store.player_gold
        endless_data.lives = self.game.store.lives
        endless_data.wave_group_number = self.game.store.wave_group_number

        -- 保存塔的信息
        endless_data.towers = {}
        for _, tower in pairs(self.game.store.towers) do
            local tower_data = {
                template_name = tower.template_name,
                pos = {
                    x = tower.pos.x,
                    y = tower.pos.y
                },
                tower_level = tower.tower.level,
                spent = tower.tower.spent or 0,
                holder_id = tower.tower.holder_id,
                flip_x = tower.tower.flip_x,
                terrain_style = tower.tower.terrain_style
            }

            -- 保存塔的技能等级
            if tower.powers then
                tower_data.powers = {}
                for power_name, power in pairs(tower.powers) do
                    tower_data.powers[power_name] = {
                        level = power.level,
                        price_base = power.price_base,
                        price_inc = power.price_inc
                    }
                end
            end

            -- 保存兵营的集结点
            if tower.barrack and tower.barrack.rally_pos then
                tower_data.rally_pos = {
                    x = tower.barrack.rally_pos.x,
                    y = tower.barrack.rally_pos.y
                }
                tower_data.soldier_count = #tower.barrack.soldiers
            end

            -- 保存塔的攻击信息
            if tower.attacks then
                tower_data.attacks = {}
                for i, attack in ipairs(tower.attacks.list) do
                    if attack.bought then
                        tower_data.attacks[i] = {
                            bought = true
                        }
                    end
                end
            end

            table.insert(endless_data.towers, tower_data)
        end

        storage:save_endless(self.game.store.level_name, self.game.store.endless)
    end
    S:stop_all()
    S:resume()
    signal.emit("game-quit", self.game.store)
    game_gui.game.done_callback({
        next_item_name = "map"
    })
end

function game_gui:restart_game()
    if self.game.store.main_hero and not GS.hero_xp_ephemeral then
        local hero = self.game.store.main_hero
        local slot = storage:load_slot()

        slot.heroes.status[hero.template_name].xp = hero.hero.xp

        storage:save_slot(slot)
    end

    S:stop_all()
    S:resume()
    signal.emit("game-restart", self.game.store)
    if self.game.store.level_mode_override == GAME_MODE_ENDLESS then
        -- 删除无尽模式存档
        storage:delete_endless(self.game.store.level_name)
    end
    game_gui.game:restart()
end

function game_gui:show_early_wave_reward()
    if game_gui.game.store.early_wave_reward > 0 then
        S:queue("GUICoins")

        local reward_fx = WaveRewardFx:new(game_gui.game.store.early_wave_reward)
        local x, y = self.window:get_mouse_position()
        local wx, wy = self.window:screen_to_view(x, y)

        wy = wy - reward_fx.size.y
        reward_fx.pos = V.v(wx, wy)

        self.layer_gui_hud:add_child(reward_fx)
        log.debug("show early wave reward at %s,%s", wx, wy)
    end
end

function game_gui:show_notification(id, force_show)
    self.notiview:show(id, nil, force_show)
end

function game_gui:queue_notification_icon(id, force)
    self.hud_noti_queue:add(id, force)
end

function game_gui:show_balloon(id)
    local b = TutorialBalloon:new(id)

    self.layer_gui_game:add_child(b)
end

function game_gui:show_achievement(id)
    if self.manual_gui_hide then
        return
    end

    if features.hide_achievements_popup then
        log.debug("features.hide_achievements_popup enabled: not showing achievement popup")

        return
    end

    if not self.achievement_banner then
        self.achievement_banner = AchievementBanner:new()

        self.layer_gui_game:add_child(self.achievement_banner)
    end

    self.achievement_banner:queue(id)
end

function game_gui:block_random_power(duration, style)
    local powers = {}

    for i = 1, 3 do
        local p = game_gui["power_" .. i]

        if p and not p:is_disabled() and table.contains({"default", "unlocked", "ready"}, p.mode) then
            table.insert(powers, p)
        end
    end

    local p = table.random(powers)

    if p then
        log.debug("blocking power: %s", p)

        local pbb = PowerButtonBlock:new(p, duration, style)

        p:add_child(pbb)
        pbb:block()
    end
end

GemsRewardFx = class("GemsRewardFx", KView)

function GemsRewardFx:initialize(amount)
    KView.initialize(self)

    self.ani_offset = 0
    self.world_offset = v(0, 0)

    local icon = KImageView:new("gemsReward_0001")

    icon.anchor.y = icon.size.y * 0.5

    self:add_child(icon)

    local digits = SpriteDigits:new("waveRewardTimer", "%i", amount)

    digits.anchor.y = digits.size.y * 0.5
    digits.pos.x = icon.size.x

    self:add_child(digits)

    self.anchor.x, self.anchor.y = (digits.size.x + icon.size.x) * 0.5, icon.size.y + 2
    self.scale = V.v(0.3, 0.3)

    timer:script(function(wait)
        timer:tween(0.21, self.scale, {
            x = 1,
            y = 1
        }, "out-back")
        wait(0.21)

        local dy = icon.size.y * 0.5

        timer:tween(0.4, self, {
            alpha = 0,
            ani_offset = -dy
        })
        wait(0.4)
        self:remove_from_parent()
    end)
end

function GemsRewardFx:update(dt)
    self.class.super.update(self, dt)

    if self.world_pos then
        local wp, wo = self.world_pos, self.world_offset

        self.pos.x, self.pos.y = game_gui:g2u(V.v(wp.x + wo.x, wp.y + wo.y))
        self.pos.y = self.pos.y + self.ani_offset
    end
end

TimeRewardFx = class("TimeRewardFx", KView)

function TimeRewardFx:initialize(amount)
    TimeRewardFx.super.initialize(self)

    self.ts = 0

    local vd = KView:new()

    self:add_child(vd)

    local text_width = 0
    local letter_spacing = 0.7
    local offset = v(0, 0)
    local reward_string = string.format("-%is", amount)
    local img_fmt = "waveRewardTimer_00%02i"

    for i = 1, #reward_string do
        local c = string.sub(reward_string, i, i)
        local index

        index = c == "-" and 11 or c == "s" and 12 or tonumber(c)

        local v = KImageView:new(string.format(img_fmt, index))

        v.pos.x, v.pos.y = offset.x, offset.y

        local char_size = km.round(letter_spacing * v.size.x)

        offset.x = offset.x + char_size
        text_width = text_width + char_size

        vd:add_child(v)

        self.size.y = v.size.y
    end

    self.size.x = text_width + text_width * (1 - letter_spacing) / #reward_string
    self.anchor.x = self.size.x * 0.5
    self.alpha = 1

    timer:tween(1, self, {
        alpha = 0
    }, "out-quad", function()
        self:remove_from_parent()
    end)

    local dy = self.size.y / 3

    timer:tween(1, vd.pos, {
        y = -dy
    }, "out-quad")
end

SpriteDigits = class("SpriteDigits", KView)

function SpriteDigits:initialize(prefix, format, ...)
    KView.initialize(self)

    local text_width = 0
    local offset = v(0, 0)
    local reward_string = string.format(format, ...)
    local img_fmt = prefix .. "_%04i"

    for i = 1, #reward_string do
        local c = string.sub(reward_string, i, i)
        local index

        index = c == "+" and 11 or c == "-" and 11 or c == "s" and 12 or tonumber(c)

        local v = KImageView:new(string.format(img_fmt, index))

        v.pos.x, v.pos.y = offset.x, offset.y

        local char_size = km.round(0.7 * v.size.x)

        offset.x = offset.x + char_size
        text_width = text_width + char_size

        self:add_child(v)

        self.size.y = math.max(v.size.y, self.size.y)
    end

    self.size.x = text_width
end

WaveRewardFx = class("WaveRewardFx", KImageView)

function WaveRewardFx:initialize(reward)
    WaveRewardFx.super.initialize(self, "nextwave_coin_0001")

    self.animation = {
        to = 14,
        prefix = "nextwave_coin",
        from = 1
    }
    self.ts = 0

    local vd = KView:new()

    self:add_child(vd)

    local text_width = 0
    local offset = v(0, 0)
    local reward_string = string.format("+%i", reward)
    local img_fmt = "waveReward_00%02i"

    for i = 1, #reward_string do
        local c = string.sub(reward_string, i, i)
        local index

        index = c == "+" and 11 or tonumber(c)

        local v = KImageView:new(string.format(img_fmt, index))

        v.pos.x, v.pos.y = offset.x, offset.y

        local char_size = km.round(0.7 * v.size.x)

        offset.x = offset.x + char_size
        text_width = text_width + char_size

        vd:add_child(v)
    end

    vd.pos.x = self.size.x
    self.anchor.x = (self.size.x + text_width) * 0.5
    self.alpha = 1

    timer:tween(1.5, self, {
        alpha = 0
    }, "out-quad", function()
        self:remove_from_parent()
    end)
end

HeroPortrait = class("HeroPortrait", KButton)

function HeroPortrait:initialize(hero_entity)
    HeroPortrait.super.initialize(self, V.v(102, 101))

    self.colors.background = {0, 0, 0, 0}
    self.disabled_tint_color = {200, 200, 200, 255}
    self.hero_id = hero_entity.id
    self.portrait_image_name = hero_entity.info.hero_portrait
    if hero_entity.template_name == "hero_dragon_gem" then
        -- self.portrait = KImageView:new(self.portrait_image_name, nil, 0.45)
        -- self.portrait.pos.x = self.portrait.pos.x + 5
        self.portrait = KImageView:new(self.portrait_image_name)
    else
        self.portrait = KImageView:new(self.portrait_image_name)
    end

    self.portrait.propagate_on_click = true

    self:add_child(self.portrait)

    self.ov_cooldown = KView:new(V.v(63, 63))
    self.ov_cooldown.pos = v(19, 78)
    self.ov_cooldown.anchor = v(0, 0)
    self.ov_cooldown.colors.background = {0, 0, 0, 150}
    self.ov_cooldown.propagate_on_click = true
    self.ov_cooldown.hidden = true

    self:add_child(self.ov_cooldown)

    self.frame = KImageView:new("heroPortrait_0001")
    self.frame.disabled_tint_color = {200, 200, 200, 255}
    self.frame.propagate_on_click = true

    self:add_child(self.frame)

    self.level = GGLabel:new(V.v(16, 16))
    self.level.pos = v(66, IS_KR3 and 60 or 65)
    self.level.font_name = "TOONISH"
    self.level.font_size = 14
    self.level.colors.text = {255, 255, 255}
    self.level.text_align = "center"
    self.level.text = "1"
    self.level.propagate_on_click = true

    self:add_child(self.level)

    self.bar_health = KImageView:new("hero_portrait_bars_0001")
    self.bar_health.pos = IS_KR3 and v(22, 78) or v(23, 83)
    self.bar_health.anchor = v(0, 0)
    self.bar_health.propagate_on_click = true

    self:add_child(self.bar_health)

    self.bar_level = KImageView:new("hero_portrait_bars_0002")
    self.bar_level.pos = IS_KR3 and v(22, 84) or v(23, 89)
    self.bar_level.anchor = v(0, 0)
    self.bar_level.propagate_on_click = true

    self:add_child(self.bar_level)

    self.ov_selected = KImageView:new("heroPortrait_selected")
    self.ov_selected.hidden = true
    self.ov_selected.propagate_on_click = true

    self:add_child(self.ov_selected)

    self.ov_hover = KImageView:new("heroPortrait_0003")
    self.ov_hover.hidden = true
    self.ov_hover.propagate_on_click = true

    self:add_child(self.ov_hover)

    self.ov_levelup = KImageView:new("heroPortrait_0001")
    self.ov_levelup.propagate_on_click = true
    self.ov_levelup.animation = {
        to = 29,
        prefix = "heroPortrait",
        from = 2
    }
    self.ov_levelup.ts = 100

    self:add_child(self.ov_levelup)
    self:update_xp(hero_entity)
end

function HeroPortrait:set_style(style)
    local prefix

    prefix = style == "left" and "heroPortrait_L" or style == "right" and "heroPortrait_R" or "heroPortrait"

    self.frame:set_image(prefix .. "_0001")
    self.ov_hover:set_image(prefix .. "_0003")

    self.ov_levelup.animation.prefix = prefix
end

function HeroPortrait:select()
    self.ov_selected.hidden = false
end

function HeroPortrait:deselect()
    self.ov_selected.hidden = true
end

function HeroPortrait:hide()
    self._original_pos_y = self.pos.y

    timer:tween(1, self.pos, {
        y = self._original_pos_y + self.size.y
    }, "out-quad")
end

function HeroPortrait:show()
    timer:tween(1, self.pos, {
        y = self._original_pos_y
    }, "out-quad")
end

function HeroPortrait:on_enter()
    self.ov_hover.hidden = false
end

function HeroPortrait:on_exit()
    self.ov_hover.hidden = true
end

function HeroPortrait:on_click(button, x, y)
    if button == 2 and DEBUG_RIGHT_CLICK then
        local wx, wy = game_gui:u2g(V.v(x, y))

        DEBUG_RIGHT_CLICK(wx, wy)
    end

    local e = game_gui:entity_by_id(self.hero_id)

    if e == game_gui.selected_entity then
        game_gui:deselect_entity()
    elseif e then
        game_gui:deselect_all()
        game_gui:select_entity(e)
    end
end

function HeroPortrait:update_xp(hero)
    local e = hero
    local levelup = self.hero_level ~= e.hero.level

    if e.hero.level == 10 then
        if self.hero_level ~= e.hero.level then
            self.bar_level.scale.x = 1
            self.hero_level = e.hero.level
            self.level.text = e.hero.level
        end
    else
        if self.hero_level ~= e.hero.level then
            log.debug("level up! %s - %s", e.id, e.template_name)

            self.hero_level = e.hero.level
            self.hero_xp_base = 0

            if e.hero.level > 1 then
                self.hero_xp_base = GS.hero_xp_thresholds[e.hero.level - 1]
            end

            self.hero_xp_next = GS.hero_xp_thresholds[e.hero.level]
            self.level.text = e.hero.level
            levelup = true
        end

        self.bar_level.scale.x = (e.hero.xp - self.hero_xp_base) / (self.hero_xp_next - self.hero_xp_base)
    end

    return levelup
end

function HeroPortrait:update(dt)
    local e = force_hero or game_gui:entity_by_id(self.hero_id)

    if not e or not e.hero then
        return
    end

    local new_level = self:update_xp(e)

    if new_level then
        self.ov_levelup.ts = 0
    end

    self.bar_health.scale.x = e.health.hp / e.health.hp_max

    if e.health.dead then
        if self.ov_cooldown.hidden then
            if game_gui.selected_entity == e then
                game_gui:deselect_entity()
            end

            if not e.info.hero_portrait_always_on then
                self:disable()
            end

            self.ov_cooldown.hidden = false
            self.ov_cooldown.scale.y = -1
            self.death_start_ts = game_gui.game.store.tick_ts
        else
            local phase = km.clamp(0, 1, (game_gui.game.store.tick_ts - self.death_start_ts) / e.health.dead_lifetime)

            self.ov_cooldown.scale.y = phase - 1
        end
    elseif not e.health.dead and (self:is_disabled() or not self.ov_cooldown.hidden) then
        self:enable()

        self.ov_cooldown.hidden = true
        self.ov_levelup.ts = 0
    end

    if self.portrait_image_name ~= e.info.hero_portrait then
        self.portrait:set_image(e.info.hero_portrait)

        self.portrait_image_name = e.info.hero_portrait
    end

    HeroPortrait.super.update(self, dt)
end

PowerButton = class("PowerButton", KButton)

function PowerButton:initialize(default_image, mask_image)
    PowerButton.super.initialize(self, nil, default_image)

    self.anchor = v(0, self.size.y)
    self.animations = {}
    self.mode = "default"
    self.cooldown_time = 2
    self.selected_gui_mode = nil

    local cv = KView:new(V.v(self.size.x, self.size.y))

    cv.size = v(self.size.x - 18, self.size.y - 19)
    cv.pos = v(9, 10 + cv.size.y)
    cv.colors.background = {0, 0, 0, 150}
    cv.hidden = true

    self:add_child(cv)

    self.cooldown_view = cv

    if mask_image then
        self.mask = KImageView:new(mask_image)

        self:add_child(self.mask)
    end
end

function PowerButton:set_mode(mode)
    self.mode = mode

    if self.animations[mode] then
        local tv = self.mask or self

        tv.animation = self.animations[mode]
        tv.ts = 0
    end

    self.cooldown_view.hidden = true

    self:enable()

    if mode == "locked" then
        self:disable()
    elseif mode == "cooldown" then
        self:disable()

        self.cooldown_view.hidden = false
        self.cooldown_view.start_ts = game_gui.game.store.tick_ts
        self.cooldown_view.scale.x, self.cooldown_view.scale.y = 1, -1
    elseif mode == "ready" then
        S:queue("GUISpellRefresh")
    end
end

function PowerButton:update(dt)
    if self.mode == "cooldown" then
        local phase = km.clamp(0, 1, (game_gui.game.store.tick_ts - self.cooldown_view.start_ts) / self.cooldown_time)

        self.cooldown_view.scale.y = phase - 1

        if phase == 1 then
            self:set_mode("ready")
        end
    end

    PowerButton.super.update(self, dt)
end

function PowerButton:on_click(button, x, y)
    self:toggle_selection(true)
end

function PowerButton:toggle_selection(keep_hover)
    if game_gui.mode == self.selected_gui_mode then
        game_gui:set_mode()

        if keep_hover then
            self:set_mode("highlighted")
        else
            self:set_mode("default")
        end

        signal.emit("power-deselected")
    else
        game_gui:deselect_all()
        game_gui:set_mode(self.selected_gui_mode)
        self:set_mode("selected")
        S:queue("GUISpellSelect")
        signal.emit("power-selected", self.selected_gui_mode)
    end
end

function PowerButton:fire(wx, wy)
    game_gui:set_mode()
    self:set_mode("cooldown")
end

function PowerButton:is_disabled()
    log.debug(" ---- mode: %s", self.mode)

    return self._disabled or self.mode == "locked" or self.mode == "cooldown"
end

function PowerButton:on_enter()
    if table.contains({"default", "unlocked", "ready"}, self.mode) then
        self:set_mode("highlighted")
    end
end

function PowerButton:on_exit()
    if self.mode == "highlighted" then
        self:set_mode("default")
    end
end

function PowerButton:early_wave_bonus(remaining_time)
    if self.mode == "cooldown" and remaining_time > 1 then
        self.cooldown_view.start_ts = self.cooldown_view.start_ts - remaining_time

        local reward_fx = TimeRewardFx:new(remaining_time)

        reward_fx.pos = V.v(self.size.x * 0.5, -2 * reward_fx.size.y / 3)

        self:add_child(reward_fx)
        log.debug("show early wave time reward at %s,%s", wx, wy)
    end
end

Power1Button = class("Power1Button", PowerButton)

function Power1Button:initialize()
    if IS_KR3 then
        Power1Button.super.initialize(self, "power_button_icons_0017", "power_button_mask_0001")

        local mask_prefix = "power_button_mask"

        self.animations = {
            default = {
                to = 1,
                from = 1,
                prefix = mask_prefix
            },
            highlighted = {
                to = 45,
                from = 45,
                prefix = mask_prefix
            },
            cooldown = {
                to = 1,
                from = 1,
                prefix = mask_prefix
            },
            locked = {
                to = 30,
                from = 30,
                prefix = mask_prefix
            },
            unlocked = {
                to = 44,
                from = 30,
                prefix = mask_prefix
            },
            selected = {
                to = 29,
                from = 29,
                prefix = mask_prefix
            },
            ready = {
                to = 28,
                from = 1,
                prefix = mask_prefix,
                post = {1}
            }
        }
    else
        Power1Button.super.initialize(self, "fire_0001")

        self.animations = {
            default = {
                to = 1,
                prefix = "fire",
                from = 1
            },
            highlighted = {
                to = 2,
                prefix = "fire",
                from = 2
            },
            cooldown = {
                to = 1,
                prefix = "fire",
                from = 1
            },
            locked = {
                to = 30,
                prefix = "fire_ready",
                from = 30
            },
            unlocked = {
                to = 44,
                prefix = "fire_ready",
                from = 30
            },
            selected = {
                to = 29,
                prefix = "fire_ready",
                from = 29
            },
            ready = {
                to = 28,
                prefix = "fire_ready",
                from = 1,
                post = {1}
            }
        }
    end

    self.selected_gui_mode = GUI_MODE_POWER_1

    self:set_mode("locked")
end

function Power1Button:fire(wx, wy)
    Power1Button.super.fire(self, wx, wy)

    local e = E:create_entity("user_power_1")

    e.pos.x, e.pos.y = wx, wy

    game_gui.game.simulation:insert_entity(e)
    signal.emit("power-used", 1)
end

function Power1Button:set_cooldown_time(t)
    self.cooldown_time = t
end

function Power1Button:wait_time_dec(dt)
    if self.cooldown_view.start_ts then
        self.cooldown_view.start_ts = self.cooldown_view.start_ts - dt
    end
end

Power2Button = class("Power2Button", PowerButton)

function Power2Button:initialize()
    Power2Button.super.initialize(self, "reinforcements_0001")

    self.animations = {
        default = {
            to = 1,
            prefix = "reinforcements",
            from = 1
        },
        highlighted = {
            to = 2,
            prefix = "reinforcements",
            from = 2
        },
        cooldown = {
            to = 1,
            prefix = "reinforcements",
            from = 1
        },
        locked = {
            to = 30,
            prefix = "reinforcement_ready",
            from = 30
        },
        unlocked = {
            to = 44,
            prefix = "reinforcement_ready",
            from = 30
        },
        selected = {
            to = 29,
            prefix = "reinforcement_ready",
            from = 29
        },
        ready = {
            to = 28,
            prefix = "reinforcement_ready",
            from = 1,
            post = {1}
        }
    }

    self.selected_gui_mode = GUI_MODE_POWER_2

    self:set_mode("locked")
end

function Power2Button:fire(wx, wy)
    Power2Button.super.fire(self, wx, wy)

    local i = math.random(1, 3)
    local e = E:create_entity("re_current_" .. i)

    e.pos.x = wx + 10
    e.pos.y = wy - 10
    e.nav_rally.center = V.v(wx, wy)
    e.nav_rally.pos = V.vclone(e.pos)

    game_gui.game.simulation:insert_entity(e)

    i = math.random(1, 3)
    e = E:create_entity("re_current_" .. i)
    e.pos.x = wx - 10
    e.pos.y = wy + 10
    e.nav_rally.center = V.v(wx, wy)
    e.nav_rally.pos = V.vclone(e.pos)

    game_gui.game.simulation:insert_entity(e)

    signal.emit("power-used", 2)
end

Power3Button = class("Power3Button", PowerButton)

function Power3Button:initialize()
    local ht = E:get_template(game_gui.game.store.selected_hero)
    local icon_name = "power_button_icons_" .. ht.info.ultimate_icon

    Power3Button.super.initialize(self, icon_name, "power_button_mask_0001")

    self.animations = {
        default = {
            to = 1,
            prefix = "power_button_mask",
            from = 1
        },
        highlighted = {
            to = 45,
            prefix = "power_button_mask",
            from = 45
        },
        cooldown = {
            to = 1,
            prefix = "power_button_mask",
            from = 1
        },
        locked = {
            to = 30,
            prefix = "power_button_mask",
            from = 30
        },
        unlocked = {
            to = 44,
            prefix = "power_button_mask",
            from = 30
        },
        selected = {
            to = 29,
            prefix = "power_button_mask",
            from = 29
        },
        ready = {
            to = 28,
            prefix = "power_button_mask",
            from = 1,
            post = {1}
        }
    }
    self.selected_gui_mode = GUI_MODE_POWER_3

    self:set_mode("locked")
end

function Power3Button:fire(wx, wy)
    Power3Button.super.fire(self, wx, wy)

    if game_gui.heroes and game_gui.heroes[1] then
        local he = game_gui:entity_by_id(game_gui.heroes[1].hero_id)
        local u = he.hero.skills.ultimate
        local e = E:create_entity(u.controller_name)

        e.pos.x, e.pos.y = wx, wy
        e.owner = he
        e.level = u.level

        game_gui.game.simulation:insert_entity(e)
        signal.emit("power-used", 3)

        self.cooldown_time = e.cooldown
    end
end

PowerButtonBlock = class("PowerButtonBlock", KImageView)

function PowerButtonBlock:initialize(power_button, duration, style_name)
    self.power_button = power_button
    self.duration = duration

    local styles = data.power_button_block_styles
    local style = styles[style_name] or styles.drow_queen

    KImageView.initialize(self, style.image)

    self.anchor = v(self.size.x * 0.5, self.size.y * 0.5)
    self.pos.x, self.pos.y = power_button.size.x * 0.5, power_button.size.y * 0.5
    self.animations = style.animations
end

function PowerButtonBlock:block()
    self.power_button:disable(false)

    self.start_ts = game_gui.game.store.tick_ts
    self.animation = self.animations.block
    self.ts = 0
end

function PowerButtonBlock:unblock()
    self.power_button:enable(false)

    self.start_ts = nil
    self.animation = self.animations.unblock
    self.ts = 0

    timer:after((self.animation.to - self.animation.from + 1) / 30, function()
        self:remove_from_parent()
    end)
end

function PowerButtonBlock:update(dt)
    if self.start_ts and game_gui.game.store.tick_ts - self.start_ts > self.duration then
        self:unblock()
    end

    PowerButtonBlock.super.update(self, dt)
end

BagButton = class("BagButton", KImageView)
BagButton.static.init_arg_names = {"default_image_name", "focused_image_name", "selected_image_name"}

function BagButton:initialize(default_image_name, focused_image_name, selected_image_name)
    KImageView.initialize(self, default_image_name)

    self.default_image_name = default_image_name
    self.focused_image_name = focused_image_name
    self.selected_image_name = selected_image_name
    self.icon_bg_image_name = icon_bg_image_name
    self.selected_item = nil
    self.selected_gui_mode = GUI_MODE_BAG

    self:set_mode("locked")

    self.propagate_on_down = false
    self.propagate_on_up = false
    self.propagate_on_touch_down = false
    self.propagate_on_touch_up = false
    self.propagate_on_touch_move = false
end

function BagButton:set_mode(new_mode, item_name)
    self.mode = new_mode
    self.selected_item = nil

    local function sid(id)
        return self:ci(id)
    end

    local doors = sid("doors")
    local bb = sid("bag_button_icons")

    local function show_icon(id)
        for _, v in pairs(bb.children) do
            v.hidden = v.id ~= id
        end
    end

    if new_mode == "locked" then
        self:disable()

        doors.hidden = false
        doors.ts = 0
        doors.animation.paused = true
    elseif new_mode == "unlocked" then
        self:enable()
        self:set_image(self.default_image_name)
        show_icon("default")

        doors.hidden = false
        doors.ts = 0
        doors.animation.paused = nil
    elseif new_mode == "selected" then
        self:set_image(self.selected_image_name)
        show_icon("default")
    elseif new_mode == "item" then
        self:set_image(self.selected_image_name)
        show_icon(item_name)

        self.selected_item = item_name
    else
        self:enable()
        show_icon("default")

        self.mode = "default"

        self:set_image(self.default_image_name)
    end
end

function BagButton:deselect()
    if self.mode == "selected" or self.mode == "item" then
        self:set_mode("default")
    end

    wid("bag_view"):hide()
end

function BagButton:select_item(item_name)
    self:set_mode("item", item_name)
    wid("bag_view"):hide()
    game_gui:set_mode(GUI_MODE_BAG_ITEM)
end

function BagButton:toggle_selection()
    log.debug("gui_mode:%s", game_gui.mode)

    if game_gui.mode == GUI_MODE_BAG_ITEM then
        self:deselect()
        game_gui:set_mode()
    elseif game_gui.mode == GUI_MODE_BAG then
        game_gui:set_mode()
        self:set_mode("default")
        wid("bag_view"):hide()
    else
        game_gui:deselect_all()
        game_gui:set_mode(GUI_MODE_BAG)
        self:set_mode("selected")
        wid("bag_view"):show()
        S:queue("GUISpellSelect")
    end
end

function BagButton:on_click()
    self:toggle_selection()
end

function BagButton:on_enter()
    if table.contains({"default", "unlocked"}, self.mode) then
        self:set_image(self.focused_image_name)
    end
end

function BagButton:on_exit()
    if table.contains({"default", "unlocked"}, self.mode) then
        self:set_image(self.default_image_name)
    end
end

function BagButton:fire_item(item_name, x, y, entity)
    self:deselect()

    local slot = storage:load_slot()
    local qty = slot.bag[item_name] or 0

    qty = km.clamp(0, 9000000000, qty - 1)
    slot.bag[item_name] = qty

    storage:save_slot(slot)

    local item_button = wid("bag_item_" .. item_name)

    item_button:ci("bag_item_qty").text = qty

    if qty < 1 then
        item_button:disable()
    end

    if item_name == "coins" then
        local gnome = game_gui.hud_counters.gold_gnome

        timer:script(function(wait)
            S:queue("InAppExtraGold")

            gnome.hidden = false
            gnome.alpha = 0
            gnome.pos.x = gnome.hidden_x

            timer:tween(1.2, gnome.pos, {
                x = gnome.shown_x
            }, "out-elastic")
            timer:tween(0.2, gnome, {
                alpha = 1
            })

            local p1, p2 = ItemRewardParticles:new(), ItemRewardParticles:new()

            p1.pos.x, p1.pos.y = x, y
            p2.pos.x, p2.pos.y = gnome.shown_x, gnome.pos.y

            game_gui.layer_gui_hud:add_child(p1)
            game_gui.layer_gui_hud:add_child(p2)
            wait(1)
            timer:tween(0.2, gnome, {
                alpha = 0
            })

            game.store.player_gold = game.store.player_gold + entity.reward
        end)
    elseif item_name == "hearts" then
        S:queue("InAppExtraHearts")

        local lh = game_gui.layer_gui_hud
        local hud = game_gui.hud_counters
        local p1 = ItemRewardParticles:new()

        p1.pos.x, p1.pos.y = x, y

        lh:add_child(p1)

        for i = 1, entity.reward do
            local h = KImageView:new("heart_0001")

            h.pos = V.v(lh:view_to_view(x, y, hud))
            h.anchor.x, h.anchor.y = h.size.x * 0.5, h.size.y * 0.5
            h.hidden = true

            hud:add_child(h)
            timer:after((i - 1) * 0.15, function()
                h.hidden = false

                timer:tween(1, h.pos, {
                    x = hud.heart_x
                }, "in-back")
                timer:tween(1, h.pos, {
                    y = hud.heart_y
                }, "linear")
            end)
            timer:after((i - 1) * 0.15 + 1, function()
                h:remove_from_parent()

                local p1 = ItemRewardParticles:new(0.4)

                p1.pos = V.v(hud:view_to_view(hud.heart_x, hud.heart_y, lh))

                lh:add_child(p1)

                game.store.lives = game.store.lives + 1

                for _, e in pairs(E:filter_templates("enemy")) do
                    if U.flag_has(e.vis.flags, F_BOSS) then
                        e.enemy.lives_cost = game.store.lives
                    end
                end

                for _, e in E:filter_iter(game.store.entities, "enemy") do
                    if U.flag_has(e.vis.flags, F_BOSS) then
                        e.enemy.lives_cost = game.store.lives
                    end
                end
            end)
        end
    elseif item_name == "atomic_bomb" then
        entity.pos.x, entity.pos.y = game_gui:u2g(V.v(-50, 200))
        entity.plane_dest = V.v(game_gui:u2g(V.v(game_gui.sw + 50, 200)))
        entity.bomb_dest = V.v(game_gui:u2g(V.v(game_gui.sw * 0.5, 450)))

        local wx, wy = game_gui:u2g(V.v(x, y))
    end
end

BagItemButton = class("BagItemButton", KView)
BagItemButton.static.init_arg_names = {"item", "image_suffix"}

function BagItemButton:initialize(item, image_suffix)
    KView.initialize(self)

    self.item = item

    local b = self:ci("bag_item_button")

    b.propagate_on_touch_down = false
    b.propagate_on_touch_up = false
    b.propagate_on_touch_move = false
    b.default_image_name = "backPack_icons_" .. image_suffix
    b.disabled_image_name = "backPack_icons_off_" .. image_suffix
    b.hover_image_name = b.default_image_name
    b.click_image_name = b.default_image_name

    function b.on_click(this)
        game_gui.bag_button:select_item(self.item)
    end

    local p = self:ci("bag_item_plus")

    p.hidden = true
    self.but = b
    self.plus = p

    self:refresh()
end

function BagItemButton:refresh()
    local slot = storage:load_slot()
    local qty = slot.bag and slot.bag[self.item] or 0

    self:ci("bag_item_qty").text = qty

    if qty < 1 then
        self:disable()
    else
        self:enable()
    end
end

function BagItemButton:disable()
    self.but:set_image(self.but.disabled_image_name)
    GGImageButton.disable(self.but, false)
end

function BagItemButton:enable()
    self.but:set_image(self.but.default_image_name)
    GGImageButton.enable(self.but)
end

function BagItemButton:is_disabled()
    return self.but:is_disabled()
end

NextWaveButton = class("NextWaveButton", KImageButton)

function NextWaveButton:initialize()
    NextWaveButton.super.initialize(self, "nextwave_0001", "nextwave_0002", "nextwave_0002")

    self.anchor = v(math.floor(self.size.x * 0.5), self.size.y)
end

function NextWaveButton:on_click(button, x, y)
    log.debug("")

    game_gui.game.store.send_next_wave = true
end

InfoBar = class("InfoBar", KImageView)

function InfoBar:initialize()
    InfoBar.super.initialize(self, "base")

    local v_portrait = KView:new(V.v(68, 68))

    v_portrait.anchor = v(34, 34)
    v_portrait.pos = v(61, 32)
    v_portrait.propagate_on_down = true
    v_portrait.propagate_on_click = true
    self.v_portrait = v_portrait

    self:add_child(v_portrait)

    local portrait_bo = KView:new(V.v(68, 68), "info_portraits_hero_0000")
    portrait_bo.anchor = v(34, 34)
    portrait_bo.pos = v(61, 32)
    portrait_bo.propagate_on_down = true
    portrait_bo.propagate_on_click = true
    self.portrait_bo = portrait_bo

    self:add_child(portrait_bo)

    local l_name = GGLabel:new(V.v(130, 15))

    l_name.pos = v(97, 11)
    l_name.font_name = "infobar_name"
    l_name.font_size = 12
    l_name.colors.text = {255, 255, 255, 255}
    l_name.colors.background = DEBUG_BACKGROUND_COLOR
    l_name.text_align = "left"
    l_name.vertical_align = "bottom"
    l_name.propagate_on_down = true
    l_name.propagate_on_click = true
    l_name.fit_lines = 1
    self.l_name = l_name

    self:add_child(l_name)

    local s_1 = 396
    local s_3 = 133.33333333333334
    local s_2 = 200
    local s_4 = 100
    local s_9 = 44.44444444444444
    local s_12 = 33.333333333333336
    local margin = v(10, 14)
    local padding = v(20, CJK(1, 0, 3, -1.5))
    local label_height = 14
    local stat_labels = {}

    stat_labels[STATS_TYPE_TOWER_BARRACK] = {{"label", "l_hp", "base_info_icons_0009", 0.8 * s_4},
                                             {"label", "l_damage", "base_info_icons_0001", 0.8 * s_4},
                                             {"label", "l_armor", "base_info_icons_0003", 0.8 * s_4},
                                             {"label", "l_magic_armor", "base_info_icons_0004", 0.8 * s_4},
                                             {"label", "l_respawn", "base_info_icons_0007", 0.8 * s_4}}
    stat_labels[STATS_TYPE_SOLDIER] = {{"bar", "b_hp", "base_info_bar_bg", "base_info_bar", 3.3 * s_12},
                                       {"label", "l_hp", nil, 3.3 * s_12, "center", true, v(0, CJK(1, 0, 3, -1))},
                                       {"label", "l_damage", "base_info_icons_0001", 2.2 * s_12},
                                       {"label", "l_ranged_damage", "base_info_icons_0001", 2.2 * s_12},
                                       {"label", "l_armor", "base_info_icons_0003", 1.5 * s_12},
                                       {"label", "l_magic_armor", "base_info_icons_0004", 1.5 * s_12},
                                       {"label", "l_respawn", "base_info_icons_0007", 1.5 * s_12}}
    stat_labels[STATS_TYPE_ENEMY] = table.deepclone(stat_labels[STATS_TYPE_SOLDIER])
    stat_labels[STATS_TYPE_ENEMY][7] = {"label", "l_lives", "base_info_icons_0008", 1.5 * s_9}
    stat_labels[STATS_TYPE_TOWER] = {{"label", "l_damage", "base_info_icons_0001", s_3},
                                     {"label", "l_range", "base_info_icons_0005", s_3},
                                     {"label", "l_cooldown", "base_info_icons_0006", s_3}}
    stat_labels[STATS_TYPE_TOWER_NO_RANGE] = {{"label", "l_damage", "base_info_icons_0001", s_2},
                                              {"label", "l_cooldown", "base_info_icons_0006", s_2}}
    stat_labels[STATS_TYPE_TOWER_MAGE] = table.deepclone(stat_labels[STATS_TYPE_TOWER])
    stat_labels[STATS_TYPE_TOWER_MAGE][1][3] = "base_info_icons_0002"
    stat_labels[STATS_TYPE_TEXT] = {{"label", "l_desc", nil, s_1, "left", false, v(4, CJK(1, -1, 3, -2))}}

    local function make_label(icon, w, align, shadow)
        local l

        if icon then
            l = GGLabel:new(V.v(w, label_height), icon)
            l.text_offset = padding
        else
            l = GGLabel:new(V.v(w, label_height))
        end

        l.font_name = "infobar_stats"
        l.font_size = 12
        l.fit_lines = 1
        l.colors.text = {255, 255, 255, 255}
        l.colors.background = DEBUG_BACKGROUND_COLOR
        l.text_align = align or "left"
        l.text_shadow = shadow
        l.propagate_on_down = true
        l.propagate_on_click = true

        return l
    end

    self.stats_view = nil
    self.stats_views = {}

    for vn, vp in pairs(stat_labels) do
        local sv = KView:new()

        sv.pos = v(100, 33)
        sv.propagate_on_down = true
        sv.propagate_on_click = true
        self.stats_views[vn] = sv

        local off_x = 0

        for i, p in ipairs(vp) do
            if p[1] == "space" then
                off_x = off_x + p[2]
            elseif p[1] == "bar" then
                local _, name, bg_image, fg_image, w = unpack(p)
                local b = KImageView:new(bg_image)
                local bfg = KImageView:new(fg_image)

                b:add_child(bfg)

                bfg.pos.x = (b.size.x - bfg.size.x) * 0.5
                bfg.pos.y = (b.size.y - bfg.size.y) * 0.5
                b.pos.x = off_x
                b.bar = bfg
                b.pos.x = (w - b.size.x) * 0.5
                sv[name] = b

                sv:add_child(b)
            elseif p[1] == "label" then
                local _, l_name, l_icon, l_w, l_align, shadow, custom_padding = unpack(p)
                local l = make_label(l_icon, l_w, l_align, shadow)

                l.pos.x = off_x

                if custom_padding then
                    l.pos.x, l.pos.y = l.pos.x + custom_padding.x, l.pos.y + custom_padding.y
                end

                off_x = off_x + l_w
                sv[l_name] = l

                sv:add_child(l)
            end
        end
    end
end

function InfoBar:show()
    log.debug("pos:%s,%s  size:%s,%s", self.pos.x, self.pos.y, self.size.x, self.size.y)

    local e = game_gui.selected_entity

    if not e or not e.info then
        self:hide()

        return
    end

    if e.info and e.info.i18n_key then
        self.l_name.text = string.upper(_(e.info.i18n_key .. "_NAME"))
    else
        self.l_name.text = string.upper(_(string.upper(e.template_name) .. "_NAME"))
    end

    self:update_portrait()
    self:update_stats()

    if self.tweening then
        timer:cancel(self.tweening)
    end

    self.hidden = false

    local pos_vis_y = self.pos_hidden.y - self.size.y

    if self.pos.y == pos_vis_y then
        return
    end

    local to_y = pos_vis_y

    self.tweening = timer:tween(0.25, self.pos, {
        y = to_y
    }, "out-quad", function()
        self.tweening = nil
    end)
end

function InfoBar:hide()
    if self.hidden then
        return
    end

    if self.tweening then
        timer:cancel(self.tweening)
    end

    local to_y = self.pos_hidden.y

    self.tweening = timer:tween(0.25, self.pos, {
        y = to_y
    }, "in-quad", function()
        self.hidden = true
        self.tweening = nil
    end)
end

function InfoBar:update(dt)
    InfoBar.super.update(self, dt)

    local e = game_gui.selected_entity

    if e and e.ui and not e.ui.can_select then
        game_gui:deselect_all()

        return
    end

    self:update_portrait()
    self:update_stats(dt)
end

function InfoBar:update_portrait()
    local e = game_gui.selected_entity

    if not e or not e.info then
        return
    end

    if self.v_portrait_image_name ~= e.info.portrait then
        if e.info.portrait then
            self.v_portrait:set_image(e.info.portrait)
            self.v_portrait.hidden = false
            self.v_portrait_image_name = e.info.portrait

            self.portrait_bo.hidden = false
        else
            self.v_portrait.hidden = true
            self.v_portrait_image_name = nil

            self.portrait_bo.hidden = true
        end
    end
end

function InfoBar:update_stats()
    local e = game_gui.selected_entity

    if not e or not e.info or not e.info.fn then
        return
    end

    local stats = e.info.fn(e)
    local sv = self.stats_views[stats.type]

    if not sv then
        log.error("Entity %s has no infobar", entity)
        self:hide()

        return
    elseif sv ~= self.stats_view then
        if self.stats_view then
            self:remove_child(self.stats_view)

            self.stats_view = nil
        end

        self.stats_view = sv

        self:add_child(self.stats_view)
    end

    local ddi = data.damage_icons
    local damage_icon = ddi[stats.damage_icon] or ddi[band(DAMAGE_BASE_TYPES, stats.damage_type or 0)] or ddi.default
    if stats.ranged_damage_type and not stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_PHYSICAL) ~= 0 then
        stats.ranged_damage_icon = "arrow"
    end
    local ranged_damage_icon = ddi[stats.ranged_damage_icon] or
                                   ddi[band(DAMAGE_BASE_TYPES, stats.ranged_damage_type or 0)] or ddi.default

    if stats.type == STATS_TYPE_TOWER_BARRACK then
        sv.l_hp.text = string.format("%i", stats.hp_max)
        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

        sv.l_armor.text = GU.armor_value_desc(stats.armor)
        sv.l_magic_armor.text = GU.armor_value_desc(stats.magic_armor)
        sv.l_respawn.text = stats.respawn and string.format(_("%i sec."), stats.respawn) or "-"
    elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE then
        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

        sv.l_range.text = GU.range_value_desc(stats.range)
        sv.l_cooldown.text = GU.cooldown_value_desc(stats.cooldown)
    elseif stats.type == STATS_TYPE_TOWER_NO_RANGE then
        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

        sv.l_cooldown.text = GU.cooldown_value_desc(stats.cooldown)
    elseif stats.type == STATS_TYPE_ENEMY then
        sv.b_hp.bar.scale.x = stats.hp / stats.hp_max

        if stats.immune then
            sv.l_hp.text = _("CArmor9")
        else
            sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
        end

        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

        sv.l_ranged_damage.text = GU.damage_value_desc(stats.ranged_damage_min, stats.ranged_damage_max)
        sv.l_ranged_damage:set_image(ranged_damage_icon, V.v(sv.l_ranged_damage.size.x, sv.l_ranged_damage.size.y))

        sv.l_armor.text = GU.armor_value_desc(stats.armor)
        sv.l_magic_armor.text = GU.armor_value_desc(stats.magic_armor)

        sv.l_lives.text = type(stats.lives) == "number" and stats.lives > 0 and stats.lives or "-"
    elseif stats.type == STATS_TYPE_SOLDIER then
        sv.b_hp.bar.scale.x = stats.hp / stats.hp_max
        sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))
        sv.l_ranged_damage.text = GU.damage_value_desc(stats.ranged_damage_min, stats.ranged_damage_max)
        sv.l_ranged_damage:set_image(ranged_damage_icon, V.v(sv.l_ranged_damage.size.x, sv.l_ranged_damage.size.y))

        sv.l_armor.text = GU.armor_value_desc(stats.armor)
        sv.l_magic_armor.text = GU.armor_value_desc(stats.magic_armor)
        sv.l_respawn.text = stats.respawn or "-"
    elseif stats.type == STATS_TYPE_TEXT then
        sv.l_desc.text = _(stats.desc)
    end
end

HudBottomView = class("HudBottomView", KView)

function HudBottomView:initialize(sw, sh)
    sh = sh + 1

    HudBottomView.super.initialize(self)

    self.propagate_on_click = true

    if IS_KR3 then
        local x = 0
        local vh
        local bg_bar = KView:new()

        while x < sw do
            local v = KImageView:new("base_gui_kr3_tile")

            v.pos.x, v.pos.y = x, 0

            bg_bar:add_child(v)

            x = x + v.size.x
            vh = v.size.y
        end

        bg_bar.propagate_on_click = true
        bg_bar.propagate_on_down = true
        bg_bar.propagate_on_up = true
        bg_bar.anchor = v(0, vh)
        bg_bar.size = v(sw, vh)
        bg_bar.pos = v(0, sh)

        self:add_child(bg_bar)
    else
        local bg_bar = KImageView:new("bg_bottom_bar")

        bg_bar.anchor = v(0, bg_bar.size.y)
        bg_bar.pos = v(0, sh)

        self:add_child(bg_bar)
    end

    local next_wave = IS_KR3 and KView:new(v(120, 36)) or KImageView:new("bg_bottom_right")

    next_wave.anchor = v(next_wave.size.x, next_wave.size.y)
    next_wave.pos = v(sw + 6, sh)
    self.next_wave = next_wave

    self:add_child(next_wave)

    local bg_nextwave = KImageView:new("bg_bottom_nextwave")

    bg_nextwave.anchor = v(math.floor(bg_nextwave.size.x * 0.5), bg_nextwave.size.y)
    bg_nextwave.pos = v(next_wave.size.x * 0.5, next_wave.size.y)

    next_wave:add_child(bg_nextwave)

    local next_wave_button = NextWaveButton:new()

    next_wave_button.pos = v(next_wave.size.x * 0.5, 31)

    next_wave:add_child(next_wave_button)

    self.bg_right = next_wave

    local powers

    if IS_KR3 then
        powers = KView:new(v(247, 36))
    else
        powers =
            GG9View:new("bg_bottom_left", game_gui.is_premium and V.v(310, 36) or V.v(247, 36), V.r(140, 36, 10, 1))
    end

    powers.anchor = v(0, powers.size.y)
    powers.pos = v(105, sh)
    self.powers = powers

    self:add_child(powers)

    local base_powers = KImageView:new(game_gui.is_premium and "base_powers_3_bg" or "base_powers_bg")

    base_powers.anchor = v(103, base_powers.size.y)
    base_powers.pos = v(123.5, powers.size.y)

    powers:add_child(base_powers)

    local power_1 = Power1Button:new()

    power_1.cooldown_time = E:get_template("user_power_1").cooldown
    power_1.pos = IS_KR3 and v(29, 30) or v(59, 30)

    powers:add_child(power_1)

    local power_2 = Power2Button:new()

    power_2.cooldown_time = E:get_template("re_current_1").cooldown
    power_2.pos = IS_KR3 and v(92, 30) or v(125, 30)

    powers:add_child(power_2)

    local power_3

    if IS_KR3 then
        power_3 = Power3Button:new()
        power_3.pos = v(155, 30)

        powers:add_child(power_3)
    end

    local bag_button

    if game_gui.is_premium then
        local tt = kui_db:get_table("game_gui_bag_button", {})

        bag_button = BagButton:new_from_table(tt)
        bag_button.pos = v((power_3 and power_3.pos.x or power_2.pos.x) + 66, 29.5)

        powers:add_child(bag_button)
    end

    for i = 1, IS_KR3 and 3 or 2 do
        local pb = powers.children[1 + i]
        local pn = KImageView:new("power_nbrs_000" .. i)

        pn.anchor = v(pn.size.x * 0.5, pn.size.y)
        pn.pos = v(pb.pos.x + pb.size.x * 0.5, powers.size.y)

        powers:add_child(pn)
    end

    local x_center = math.floor((sw - next_wave.size.x - powers.size.x - powers.pos.x) * 0.5) + powers.pos.x +
                         powers.size.x

    if not IS_KR3 then
        local bg_center = KImageView:new("bg_bottom_center")

        bg_center.anchor = v(bg_center.size.x * 0.5, bg_center.size.y)
        bg_center.pos = v(x_center, sh)
        self.bg_center = bg_center

        self:add_child(bg_center)
    end

    local bagbar

    if game_gui.is_premium then
        local tt = kui_db:get_table("game_gui_bag_view", {})

        bagbar = GG9View:new_from_table(tt)
        bagbar.anchor = v(math.floor(bagbar.size.x * 0.5), bagbar.size.y)
        bagbar.y_shown = sh + 25
        bagbar.y_hidden = sh + bagbar.size.y
        bagbar.pos = V.v(x_center, bagbar.y_hidden)
        self.bagbar = bagbar

        self:add_child(bagbar)

        function bagbar.show(this)
            this.hidden = false

            if this._timer then
                timer:cancel(this._timer)
            end

            this._timer = timer:tween(0.25, this.pos, {
                y = this.y_shown
            }, "out-quad", function()
                this._timer = nil
            end)
        end

        function bagbar.hide(this)
            if this._timer then
                timer:cancel(this._timer)
            end

            this._timer = timer:tween(0.25, this.pos, {
                y = this.y_hidden
            }, "out-quad", function()
                this.hidden = true
                this._timer = nil
            end)
        end
    end

    local infobar = InfoBar:new()

    infobar.anchor = v(math.floor(infobar.size.x * 0.5), infobar.size.y)
    infobar.pos = v(x_center, sh + infobar.size.y)
    infobar.pos_hidden = V.vclone(infobar.pos)
    infobar.hidden = true
    self.infobar = infobar

    self:add_child(infobar)
    self:update_bars_pos()

    local herobar = KView:new()

    herobar.propagate_on_click = true
    herobar.propagate_on_down = true
    herobar.propagate_on_up = true
    herobar.pos = v(0, sh)
    self.herobar = herobar

    self:add_child(herobar)

    game_gui.power_1 = power_1
    game_gui.power_2 = power_2
    game_gui.power_3 = power_3
    game_gui.bag_button = bag_button
    game_gui.next_wave_button = next_wave_button
end

function HudBottomView:hide()
    self._original_pos_y = self.pos.y

    timer:tween(1, self.pos, {
        y = self._original_pos_y + 110
    }, "out-quad")
end

function HudBottomView:show()
    timer:tween(1, self.pos, {
        y = self._original_pos_y
    }, "out-quad")
end

function HudBottomView:update_bars_pos()
    local x_center = math.floor((game_gui.sw - self.next_wave.size.x - self.powers.size.x - self.powers.pos.x) * 0.5) +
                         self.powers.pos.x + self.powers.size.x

    self.infobar.pos.x = x_center - 12

    if self.bagbar then
        self.bagbar.pos.x = x_center
    end

    if self.bg_center then
        self.bg_center.pos.x = x_center
    end
end

function HudBottomView:add_hero(hero_entity)
    local hero = HeroPortrait:new(hero_entity)

    hero.anchor = v(0, hero.size.y)

    self.herobar:add_child(hero)

    if #self.herobar.children > 1 then
        self.powers.pos.x = 175

        local last = self.herobar.children[1]

        last:set_style("left")

        last.pos.x = 8

        local overlap = 18

        hero.pos = v(last.pos.x + hero.size.x - overlap, 0)

        hero:set_style("right")

        local separator = KImageView:new("heroPortrait_separator")

        separator.anchor = v(separator.size.x * 0.5, hero.size.y)
        separator.pos = v(last.pos.x + hero.size.x - overlap * 0.5, 3)
        separator.propagate_on_click = true
        separator.propagate_on_down = true
        separator.propagate_on_up = true

        self.herobar:add_child(separator)
    else
        hero.pos = v(15, 0)
        self.powers.pos.x = 105
    end

    game_gui.hud_bottom:update_bars_pos()

    return hero
end

HudCountersView = class("HudCountersView", KImageView)

function HudCountersView:initialize(level_mode)
    -- HudCountersView.super.initialize(self, level_mode == GAME_MODE_ENDLESS and "top_left_endless" or "top_left")
    HudCountersView.super.initialize(self, "top_left")

    self.level_mode = level_mode
    self.heart_x = 70
    self.heart_y = 50

    local lbl_lives = GGLabel:new(V.v(71, 35))

    lbl_lives.pos = v(80, CJK(44, 39, 46, 39))
    lbl_lives.text = "0"
    lbl_lives.text_align = "left"
    lbl_lives.font_name = "hud"
    lbl_lives.font_size = 12
    lbl_lives.colors.text = {255, 255, 255}

    local lbl_gold = GGLabel:new(V.v(71, 35))

    lbl_gold.pos = v(136, CJK(44, 39, 46, 39))
    lbl_gold.text = "1000"
    lbl_gold.text_align = "left"
    lbl_gold.font_name = "hud"
    lbl_gold.font_size = 12
    lbl_gold.colors.text = {255, 255, 255}

    local lbl_wave = GGLabel:new(V.v(game_gui.game.store.level_mode_override == GAME_MODE_ENDLESS and 25 or 74, 28))

    lbl_wave.pos = v(240, 38)
    lbl_wave.text_align = "left"
    lbl_wave.vertical_align = "middle"
    lbl_wave.font_name = "hud"
    lbl_wave.font_size = 12
    lbl_wave.fit_step = 0.25
    lbl_wave.fit_size = true
    lbl_wave.fit_lines = 1
    lbl_wave.colors.text = {255, 255, 255}
    lbl_wave.colors.background = DEBUG_BACKGROUND_COLOR

    local gold_gnome = KImageView:new("gold_gnome")

    gold_gnome.id = "user_item_gold_gnome_view"
    gold_gnome.pos = v(100, 25)
    gold_gnome.hidden_x = 80
    gold_gnome.shown_x = 112
    gold_gnome.hidden = true

    self:add_child(lbl_lives)
    self:add_child(lbl_gold)
    self:add_child(lbl_wave)
    self:add_child(gold_gnome)

    self.lbl_lives = lbl_lives
    self.lbl_gold = lbl_gold
    self.lbl_wave = lbl_wave
    self.gold_gnome = gold_gnome

    -- if level_mode == GAME_MODE_ENDLESS then
    --     local lbl_score = GGLabel:new(V.v(56, 28))

    --     lbl_score.pos = v(289, 38)
    --     lbl_score.text_align = "left"
    --     lbl_score.vertical_align = "middle"
    --     lbl_score.font_name = "hud"
    --     lbl_score.font_size = 12
    --     lbl_score.fit_step = 0.25
    --     lbl_score.fit_size = true
    --     lbl_score.fit_lines = 1
    --     lbl_score.colors.text = {255, 255, 255}
    --     lbl_score.colors.background = DEBUG_BACKGROUND_COLOR

    --     self:add_child(lbl_score)

    --     self.lbl_score = lbl_score

    --     local bonus_fx = KImageView:new("hud_bonusFx_0001")

    --     bonus_fx.animation = {
    --         to = 16,
    --         prefix = "hud_bonusFx"
    --     }
    --     bonus_fx.pos = V.v(270, 7)
    --     bonus_fx.hidden = true

    --     self:add_child(bonus_fx)

    --     self.bonus_fx = bonus_fx

    --     local lbl_bonus = GGShaderLabel:new(V.v(42, 18))

    --     lbl_bonus.r = km.deg2rad(7)
    --     lbl_bonus.text = "+9999"
    --     lbl_bonus.pos = V.v(28, 40)
    --     lbl_bonus.fit_lines = 1
    --     lbl_bonus.vertical_align = "middle"
    --     lbl_bonus.font_name = "numbers_bold"
    --     lbl_bonus.font_size = 17
    --     lbl_bonus.colors = {
    --         text = {255, 255, 255, 255},
    --         background = {0, 0, 0, 0}
    --     }
    --     lbl_bonus.shaders = {"p_outline", "p_glow"}
    --     lbl_bonus.shader_margin = 8
    --     lbl_bonus.shader_args = {{
    --         thickness = 0.75,
    --         outline_color = {0, 0.4980392156862745, 0.7058823529411765, 1}
    --     }, {
    --         thickness = 0.5,
    --         glow_color = {0, 0.4980392156862745, 0.7058823529411765, 1}
    --     }}

    --     bonus_fx:add_child(lbl_bonus)

    --     self.lbl_bonus = lbl_bonus
    -- end
end

function HudCountersView:update(dt)
    HudCountersView.super.update(self, dt)

    local store = game_gui.game.store

    self.lbl_lives.text = string.format("%d", store.lives)
    self.lbl_gold.text = string.format("%d", store.player_gold)

    if game_gui.game.store.level_mode_override == GAME_MODE_ENDLESS then
        self.lbl_wave.text = string.format("%d", store.wave_group_number)
        -- self.lbl_score.text = string.format("%d", store.player_score)
    elseif store.criket.on then
        self.lbl_wave.text = string.format("%3d*%.2f", store.enemy_count, store.config.enemy_health_multiplier)
    else
        self.lbl_wave.text = string.format(_("MENU_HUD_WAVES"), store.wave_group_number, store.wave_group_total)
    end
end

function HudCountersView:hide()
    self._original_pos_y = self.pos.y

    timer:tween(1, self.pos, {
        y = self._original_pos_y - self.size.y
    }, "out-quad")
end

function HudCountersView:show()
    timer:tween(1, self.pos, {
        y = self._original_pos_y
    }, "out-quad")
end

function HudCountersView:show_bonus(reward)
    if not reward or reward < 1 or not self.lbl_bonus then
        return
    end

    self.lbl_bonus.text = string.format("+%d", reward)

    local b = self.bonus_fx

    b.hidden = false
    b.ts = 0
    b.alpha = 1

    timer:tween(1, b, {
        alpha = 0
    }, "in-quint")
end

OverlayView = class("OverlayView", KView)

function OverlayView:initialize(sw, sh)
    OverlayView.super.initialize(self, V.v(sw, sh))

    self.colors.background = {0, 0, 0, 120}
    self.sw = sw
    self.sh = sh
    self.propagate_on_click = false
    self.propagate_on_down = false
    self.propagate_on_up = false
    self.propagate_on_enter = false
end

function OverlayView:show()
    if self.tweener then
        timer:cancel(self.tweener)
    end

    self.tweener = timer:tween(0.25, self.colors.background, {0, 0, 0, 120}, "in-quad", function()
        self.tweener = nil
    end)
    self.propagating = false
    self.hidden = false
end

function OverlayView:hide()
    if self.tweener then
        timer:cancel(self.tweener)
    end

    self.tweener = timer:tween(0.25, self.colors.background, {0, 0, 0, 1}, "in-quad", function()
        self.hidden = true
        self.tweener = nil
    end)
end

HudPauseButton = class("HudPauseButton", KImageView)

function HudPauseButton:initialize()
    HudPauseButton.super.initialize(self, "pause_base")

    local button = KImageButton:new("pause_btn_0001", "pause_btn_0002", "pause_btn_0002")

    button.anchor = v(button.size.x * 0.5, 0)
    button.pos = v(self.size.x * 0.5, 25)

    function button.on_click()
        S:queue("GUIButtonCommon")
        game_gui.pauseview:show()
    end

    self:add_child(button)
end

function HudPauseButton:hide()
    self._original_pos_y = self.pos.y

    timer:tween(1, self.pos, {
        y = self._original_pos_y - self.size.y
    }, "out-quad")
end

function HudPauseButton:show()
    timer:tween(1, self.pos, {
        y = self._original_pos_y
    }, "out-quad")
end

PauseView = class("PauseView", KImageView)

function PauseView:initialize()
    PauseView.super.initialize(self, "options_bg_notxt")

    local header = GGPanelHeader:new(_("OPTIONS"), 170)

    header.pos = V.v(172, CJK(30, 28, nil, 28) + (IS_KR3 and -16 or 0))

    self:add_child(header)

    local mx = 100
    local y = 100
    local title = GGOptionsLabel:new(V.v(self.size.x, 28))

    title.text = _("SFX")
    title.pos = V.v(self.size.x * 0.5, y)
    title.anchor.x = title.size.x * 0.5
    title.vertical_align = "middle"

    self:add_child(title)

    y = y + title.size.y + 6

    local s_sfx = VolumeSlider:new("options_sounds_0004", "options_sounds_0005", "options_sounds_0006")

    s_sfx.pos = V.v(mx, y)

    function s_sfx:on_change(value)
        S:set_main_gain_fx(value, game_gui.game.store.active_sound_sources)
    end

    s_sfx.id = "s_sfx"

    self:add_child(s_sfx)

    y = y + 50
    title = GGOptionsLabel:new(V.v(self.size.x, 28))
    title.text = _("Music")
    title.pos = V.v(self.size.x * 0.5, y)
    title.anchor.x = title.size.x * 0.5
    title.vertical_align = "middle"

    self:add_child(title)

    y = y + title.size.y + 6

    local s_music = VolumeSlider:new("options_sounds_0001", "options_sounds_0002", "options_sounds_0003")

    function s_music:on_change(value)
        S:set_main_gain_music(value, game_gui.game.store.active_sound_sources)
    end

    s_music.pos = V.v(mx, y)
    s_music.id = "s_music"

    self:add_child(s_music)

    mx = 45
    y = y + 90 + 30

    local b

    b = GGOptionsButton:new(_("BUTTON_QUIT"))
    b.pos = V.v(mx + b.size.x * 0.5, y)

    self:add_child(b)

    function b.on_click(this, button, x, y)
        S:queue("GUIButtonCommon")
        game_gui:go_to_map()
    end

    b = GGOptionsButton:new(_("BUTTON_RESTART"))
    b.pos = V.v(math.ceil(self.size.x * 0.5), y)

    self:add_child(b)

    function b.on_click(this, button, x, y)
        S:queue("GUIButtonCommon")
        game_gui:restart_game()
    end

    b = GGOptionsButton:new(_("BUTTON_RESUME"))
    b.pos = V.v(self.size.x - mx - b.size.x * 0.5, y)

    self:add_child(b)

    function b.on_click(this, button, x, y)
        S:queue("GUIButtonCommon")
        self:hide()
    end

    local settings = storage:load_settings()

    if settings then
        if settings.volume_fx and type(settings.volume_fx) == "number" then
            s_sfx:set_value(km.clamp(0, 1, settings.volume_fx))
        end

        if settings.volume_music and type(settings.volume_music) == "number" then
            s_music:set_value(km.clamp(0, 1, settings.volume_music))
        end
    end
end

function PauseView:show()
    if self.tweener then
        timer:cancel(self.tweener)
    end

    game_gui:disable_keys()
    game_gui:deselect_all()
    S:pause()
    self:disable(false)

    game_gui.game.store.paused = true

    game_gui.overlay:show()

    self.pos.y = game_gui.sh * 0.5 - 50
    self.hidden = false
    self.alpha = 0
    self.tweener = timer:tween(0.25, self, {
        alpha = 1,
        pos = {
            y = self.pos.y + 50
        }
    }, "out-quad", function()
        self:enable()

        self.tweener = nil
    end)
    self._last_volume_fx = km.clamp(0, 1, self:get_child_by_id("s_sfx").value)
    self._last_volume_music = km.clamp(0, 1, self:get_child_by_id("s_music").value)
end

function PauseView:hide()
    if self.tweener then
        timer:cancel(self.tweener)
    end

    game_gui:enable_keys()
    self:disable(false)
    S:resume()

    game_gui.game.store.paused = false

    game_gui.overlay:hide()

    self.tweener = timer:tween(0.25, self, {
        alpha = 0,
        pos = {
            y = self.pos.y - 50
        }
    }, "out-quad", function()
        self.hidden = true
        self.tweener = nil
    end)

    local s_sfx = self:get_child_by_id("s_sfx")
    local s_music = self:get_child_by_id("s_music")

    if self._last_volume_fx ~= s_sfx.value or self._last_volume_music ~= s_music.value then
        local settings = storage:load_settings()

        settings.volume_fx = km.clamp(0, 1, s_sfx.value)
        settings.volume_music = km.clamp(0, 1, s_music.value)

        storage:save_settings(settings)
    end
end

DefeatView = class("DefeatView", KView)

function DefeatView:initialize()
    DefeatView.super.initialize(self, v(455, 384))

    if game_gui.is_premium then
        local gnome = KImageView:new("win_Gnome")

        gnome.pos = V.v(300, 120)
        gnome.id = "defeat_gems_view"
        gnome.hidden = true

        self:add_child(gnome)

        local gems_label = GGShaderLabel:new(V.v(90, 48))

        gems_label.colors = {
            text = {255, 255, 255, 255},
            background = {0, 0, 0, 0}
        }
        gems_label.fit_size = true
        gems_label.font_name = "numbers_bold"
        gems_label.font_size = 44
        gems_label.id = "defeat_gems_label"
        gems_label.pos = V.v(94, 140)
        gems_label.r = math.rad(-14)
        gems_label.text_align = "center"
        gems_label.text = "9999"
        gems_label.vertical_align = "middle-caps"
        gems_label.shaders = {"p_outline", "p_glow"}
        gems_label.shader_margin = 8
        gems_label.shader_args = {{
            thickness = 1.5,
            outline_color = {0, 0.6196078431372549, 0.7058823529411765, 1}
        }, {
            thickness = 1,
            glow_color = {0, 0.6196078431372549, 0.7058823529411765, 1}
        }}

        gnome:add_child(gems_label)
    end

    local bg = KImageView:new("defeat_bg_notxt")

    self:add_child(bg)

    local header = GGPanelHeader:new(_("DEFEAT"), 140)

    header.pos = V.v(160, CJK(81, 81, 83) + (IS_KR3 and -16 or 0))

    self:add_child(header)

    local l_tip = GGLabel:new(V.v(246, 90))

    l_tip.anchor.x = l_tip.size.x * 0.5
    l_tip.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
    l_tip.text_align = "center"
    l_tip.font_name = "body"
    l_tip.vertical_align = "middle"
    l_tip.font_size = 15
    l_tip.fit_size = true
    l_tip.colors.text = {255, 255, 255, 255}
    l_tip.pos.x, l_tip.pos.y = self.size.x * 0.5, 155

    self:add_child(l_tip)

    self.l_tip = l_tip

    local mx = 84
    local y = 278
    local b

    b = GGOptionsButton(_("BUTTON_RESTART"))
    b.pos.x, b.pos.y = V.csnap(mx + b.size.x * 0.5, y + b.size.y * 0.5)

    function b.on_click()
        log.debug("RETRY")
        game_gui:restart_game()
    end

    self:add_child(b)

    b = GGOptionsButton(_("Quit"))
    b.pos.x, b.pos.y = V.csnap(self.size.x - mx - b.size.x * 0.5, y + b.size.y * 0.5)

    function b.on_click()
        log.debug("QUIT")
        game_gui:go_to_map()
    end

    self:add_child(b)
end

function DefeatView:show()
    game_gui.overlay:show()

    self.hidden = false
    self.l_tip.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))

    S:stop_all()
    S:queue("GUIQuestFailed")

    self.pos.y = -game_gui.sw * 0.5

    timer:tween(0.5, self.pos, {
        y = game_gui.sh * 0.5
    }, "out-back", nil, 1)

    if game_gui.is_premium then
        local gems = game_gui.game.store.gems_collected or 0

        self:ci("defeat_gems_label").text = gems

        local gv = self:ci("defeat_gems_view")

        timer:script(function(wait)
            wait(0.5)
            S:queue("InAppExtraGold")

            gv.hidden = false

            timer:tween(0.4, gv.pos, {
                x = 400
            }, "out-elastic")
        end)
    end
end

VictoryParticles = class("VictoryParticles", KView)

function VictoryParticles:initialize(w, h)
    VictoryParticles.super.initialize(self)

    local ss = I:s("victory_star")
    local p_scale = ss.ref_scale or 1
    local c = G.newCanvas(ss.size[1], ss.size[2])

    G.setCanvas(c)
    G.draw(I:i(ss.atlas), ss.quad)
    G.setCanvas()

    local ps = G.newParticleSystem(c, 500)

    ps:setDirection(-math.pi * 0.5)
    ps:setSpread(2 * math.pi / 3)
    ps:setSizes(1 * p_scale, 1.4 * p_scale)
    ps:setLinearAcceleration(0, 2000)
    ps:setParticleLifetime(0, 1.5)
    ps:setSpeed(400, 1000)
    ps:setRadialAcceleration(-200)
    ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    ps:emit(150)

    self.ps = ps
    self.ss = ss
end

function VictoryParticles:update(dt)
    VictoryParticles.super.update(self, dt)
    self.ps:update(dt)
end

function VictoryParticles:draw()
    G.setBlendMode("add")
    G.draw(self.ps, 0, 0)
    G.setBlendMode("alpha")
    VictoryParticles.super.draw(self)
end

VictoryView = class("VictoryView", KView)

function VictoryView:initialize(level_mode)
    VictoryView.super.initialize(self)

    self.level_mode = level_mode

    local img_names = {
        [GAME_MODE_CAMPAIGN] = "victoryBadges_notxt_0002",
        [GAME_MODE_HEROIC] = "victoryBadges_notxt_0003",
        [GAME_MODE_IRON] = "victoryBadges_notxt_0001"
    }
    local v_badge = KImageView:new(img_names[level_mode])
    local vw, vh = v_badge.size.x, v_badge.size.y

    v_badge.anchor.x = vw * 0.5
    v_badge.anchor.y = 0
    v_badge.pos.x, v_badge.pos.y = vw * 0.5, 0
    v_badge.propagate_on_click = true

    local ct = GGEllipseText:new(V.v(320, -30))

    ct.pos.x, ct.pos.y = v_badge.size.x * 0.5, 235
    ct.anchor.x = ct.size.x * 0.5
    ct.text = _("VICTORY")
    ct.font_name = "h_noti"
    ct.font_size = 78
    ct.colors.text = {76, 56, 23}
    ct.max_angle = math.pi / 6
    self.ct = ct
    v_badge:add_child(ct)

    local v_stars = KImageView:new("victoryStars_0001")

    v_stars.anchor.x = v_stars.size.x * 0.5
    v_stars.pos.x, v_stars.pos.y = vw * 0.5, 230
    v_stars.hidden = true
    v_stars.animations = {{
        to = 19,
        prefix = "victoryStars",
        from = 1
    }, {
        to = 38,
        prefix = "victoryStars",
        from = 1
    }, {
        to = 54,
        prefix = "victoryStars",
        from = 1
    }}

    if level_mode == GAME_MODE_IRON then
        v_stars.pos.y = v_stars.pos.y + 40
    end

    local v_c = KView:new()
    local c = KImageView:new("button_continue_chains")
    local b = GGBorderButton(_("BUTTON_CONTINUE"), true)

    c.anchor.x = c.size.x * 0.5
    c.anchor.y = c.size.y + 0.9 * b.size.y
    c.pos.x = vw * 0.5
    c.pos.y = 0
    b.pos.x = c.size.x * 0.5
    b.pos.y = c.size.y + 0.125 * b.size.y

    function b.on_click()
        log.debug("CONTINUE")
        game_gui:go_to_map()
    end

    c:disable(false)
    c:add_child(b)
    v_c:add_child(c)

    v_c.propagate_on_click = true
    v_c.propagate_on_down = true
    v_c.clip = true
    v_c.size.x = vw
    v_c.size.y = vh
    v_c.anchor.x = vw * 0.5
    v_c.anchor.y = 0
    v_c.pos.x = vw * 0.5
    v_c.pos.y = 300

    local v_r = KView:new()
    local c = KImageView:new("button_restart_chains")
    local b = GGBorderButton(_("BUTTON_RESTART"))

    c.anchor.x = c.size.x * 0.5
    c.anchor.y = c.size.y + 0.9 * b.size.y
    c.pos.x = vw * 0.5
    c.pos.y = 0
    b.pos.x = c.size.x * 0.5
    b.pos.y = c.size.y + 0.125 * b.size.y

    function b.on_click()
        log.debug("RESTART")
        game_gui:restart_game()
    end

    c:disable(false)
    c:add_child(b)
    v_r:add_child(c)

    v_r.clip = true
    v_r.size.x = vw
    v_r.size.y = vh
    v_r.anchor.x = vw * 0.5
    v_r.anchor.y = 0
    v_r.pos.x = vw * 0.5
    v_r.pos.y = v_c.pos.y + 115

    local v_gnome

    if game_gui.is_premium then
        v_gnome = KImageView:new_from_table(kui_db:get_table("game_gui_gems_view", {
            level_mode = level_mode
        }))
    end

    self.size.x = vw
    self.size.y = vh

    if v_gnome then
        self:add_child(v_gnome)
    end

    self:add_child(v_r)
    self:add_child(v_c)
    self:add_child(v_badge)
    self:add_child(v_stars)

    self.v_badge = v_badge
    self.v_stars = v_stars
    self.v_restart = v_r
    self.v_continue = v_c
end

function VictoryView:show()
    local criket = game_gui.game.store.criket
    if criket and criket.on then
        local lives
        if game_gui.game.store.lives < 0 then
            lives = -game_gui.game.store.lives
        else
            lives = game_gui.game.store.lives
        end
        self.ct.text = string.format("%s损 %.1f秒 %d牺牲", tostring(lives), criket.time_cost, game_gui.game.store.dead_soldier_count)
        self.ct.font_size = 28
        if criket.tower_name then
            local tower_icon = KImageView:new(E:get_template(criket.tower_name).info.portrait)
            tower_icon.anchor = V.v(tower_icon.size.x * 0.5, tower_icon.size.y * 0.5)
            tower_icon.pos = V.v(400, 120)
            tower_icon.scale = V.v(1.2, 1.2)
            tower_icon.hidden = false
            self:add_child(tower_icon)
        end
    end

    game_gui.overlay:show()

    self.hidden = false

    S:stop_all()
    S:queue("GUIQuestCompleted")

    local v_badge, v_stars, v_restart, v_continue = self.v_badge, self.v_stars, self.v_restart, self.v_continue
    local c_chain = v_continue.children[1]
    local r_chain = v_restart.children[1]
    local stars_rating = game_gui.game.store.game_outcome.stars
    local level_idx = game_gui.game.store.level_idx
    local gems = game_gui.game.store.gems_collected or 0
    local gv = self:ci("gems_view")

    if gv then
        gv.hidden = true
    end

    timer:script(function(wait)
        self.scale.x, self.scale.y = 0.6, 0.6

        timer:tween(0.6, self.scale, {
            x = 1,
            y = 1
        }, "out-back", nil, 1.5)
        wait(0.15)

        local p = VictoryParticles:new()

        p.pos.x, p.pos.y = self.size.x * 0.5, self.size.y / 3
        self.particles = p

        self:add_child(p)
        wait(0.5)

        local animation = v_stars.animations[stars_rating]

        v_stars.animation = animation
        v_stars.ts = 0
        v_stars.hidden = false

        for i = 1, stars_rating do
            S:queue("GUIWinStars", {
                delay = (i - 1) * 0.7
            })
        end

        wait(animation.to / FPS)

        c_chain.pos.y = 0

        timer:tween(0.5, c_chain.pos, {
            y = c_chain.anchor.y
        }, "out-back")
        wait(0.5)

        r_chain.pos.y = 0

        timer:tween(0.5, r_chain.pos, {
            y = r_chain.anchor.y
        }, "out-back")
        wait(0.5)
        c_chain:enable()
        r_chain:enable()
        S:queue(string.format("MusicBattlePrep_%02d", level_idx))
    end)
end

function VictoryView:hide()
    return
end

MousePointer = class("MousePointer", KView)

function MousePointer:initialize()
    MousePointer.super.initialize(self)

    self.propagate_on_click = true
    self.propagate_on_down = true
    self.propagate_on_up = true

    local rally_tower = KImageView:new("pointer_set_rally_0001")

    rally_tower.anchor = V.v(rally_tower.size.x * 0.5, rally_tower.size.y * 0.5)
    rally_tower.animation = {
        to = 10,
        prefix = "pointer_set_rally",
        from = 1
    }
    rally_tower.loop = true

    local ipc = KImageView:new("error_feedback_0001")

    ipc.anchor = v(ipc.size.x * 0.5, ipc.size.y * 0.5)
    ipc.animation = {
        to = 14,
        prefix = "error_feedback",
        from = 1
    }

    local pirate_camp = KImageView:new("pointer_pirate_cannons")

    pirate_camp.anchor = v(pirate_camp.size.x * 0.5, pirate_camp.size.y * 0.5)
    pirate_camp.alpha = 0.75

    local p1b, p2b, p3b, pb_point, pb_area, sunray_tower

    p1b = KImageView:new("pointer_area_orange_0001")
    p1b.anchor = V.v(p1b.size.x * 0.5, p1b.size.y * 0.5)
    p1b.animation = {
        to = 10,
        prefix = "pointer_area_orange",
        from = 1
    }
    p1b.loop = true

    local p1i = KImageView:new(IS_KR3 and "pointer_hero_power_0017" or "pointer_user_power_0001")

    p1i.anchor = V.v(p1i.size.x * 0.5, p1i.size.y * 100 / 100)
    p1i.pos.x, p1i.pos.y = p1b.size.x * 0.5, p1b.size.y * 0.5

    p1b:add_child(p1i)

    p2b = KImageView:new("pointer_point_orange_0001")
    p2b.anchor = V.v(p2b.size.x * 0.5, p2b.size.y * 0.5)
    p2b.animation = {
        to = 10,
        prefix = "pointer_point_orange",
        from = 1
    }
    p2b.loop = true

    local p2i = KImageView:new(IS_KR3 and "pointer_hero_power_0018" or "pointer_user_power_0002")

    p2i.anchor = V.v(p2i.size.x * 0.5, p2i.size.y * 100 / 100)
    p2i.pos.x, p2i.pos.y = p2b.size.x * 0.5, p2b.size.y * 0.5

    p2b:add_child(p2i)

    if IS_KR3 then
        local ht = E:get_template(game_gui.game.store.selected_hero)
        local p3_icon = "pointer_hero_power_" .. ht.info.ultimate_icon
        local p3_style = ht.info.ultimate_pointer_style or "point"
        local p3b_prefix = p3_style == "area" and "pointer_area_orange" or "pointer_point_orange"

        p3b = KImageView:new(p3b_prefix .. "_0001")
        p3b.anchor = V.v(p3b.size.x * 0.5, p3b.size.y * 0.5)
        p3b.animation = {
            to = 10,
            from = 1,
            prefix = p3b_prefix
        }
        p3b.loop = true

        local p3i = KImageView:new(p3_icon)

        p3i.anchor = V.v(p3i.size.x * 0.5, p3i.size.y * 100 / 100)
        p3i.pos.x, p3i.pos.y = p3b.size.x * 0.5, p3b.size.y * 0.5

        p3b:add_child(p3i)
    end

    if IS_KR1 then
        sunray_tower = KImageView:new("pointer_point_orange_0001")
        sunray_tower.anchor = V.v(sunray_tower.size.x * 0.5, sunray_tower.size.y * 0.5)
        sunray_tower.animation = {
            to = 10,
            prefix = "pointer_point_orange",
            from = 1
        }
        sunray_tower.loop = true

        local drop = KImageView:new("pointer_sunray_tower")

        drop.anchor = V.v(drop.size.x * 0.5, drop.size.y * 100 / 100)
        drop.pos.x, drop.pos.y = sunray_tower.size.x * 0.5, sunray_tower.size.y * 0.5

        sunray_tower:add_child(drop)
    end

    if game_gui.is_premium then
        pb_point = KImageView:new("pointer_point_orange_0001")
        pb_point.anchor = V.v(pb_point.size.x * 0.5, pb_point.size.y * 0.5)
        pb_point.animation = {
            to = 10,
            prefix = "pointer_point_orange",
            from = 1
        }
        pb_point.loop = true

        local pbi = KImageView:new("pointer_bag_item_0001")

        pbi.anchor = V.v(pbi.size.x * 0.5, pbi.size.y * 100 / 100)
        pbi.pos.x, pbi.pos.y = pb_point.size.x * 0.5, pb_point.size.y * 0.5

        pb_point:add_child(pbi)

        pb_area = KImageView:new("pointer_area_orange_0001")
        pb_area.anchor = V.v(pb_area.size.x * 0.5, pb_area.size.y * 0.5)
        pb_area.animation = {
            to = 10,
            prefix = "pointer_area_orange",
            from = 1
        }
        pb_area.loop = true
        pbi = KImageView:new("pointer_bag_item_0001")
        pbi.anchor = V.v(pbi.size.x * 0.5, pbi.size.y * 100 / 100)
        pbi.pos.x, pbi.pos.y = pb_area.size.x * 0.5, pb_area.size.y * 0.5

        pb_area:add_child(pbi)
    end

    self.cross = ipc
    self.pointers = {
        [GUI_MODE_RALLY_TOWER] = {
            default = rally_tower
        },
        [GUI_MODE_RALLY_HERO] = {
            default = rally_tower
        },
        [GUI_MODE_RALLY_CONTROABLE] = {
            default = rally_tower
        },
        [GUI_MODE_RALLY_CONTROABLES] = {
            default = rally_tower
        },
        [GUI_MODE_SELECT_POINT] = {
            default = pirate_camp,
            sunray_tower = sunray_tower
        },
        [GUI_MODE_POWER_1] = {
            default = p1b
        },
        [GUI_MODE_POWER_2] = {
            default = p2b
        },
        [GUI_MODE_POWER_3] = {
            default = p3b
        }
    }

    if game_gui.is_premium then
        if IS_KR1 or IS_KR2 then
            self.pointers[GUI_MODE_BAG_ITEM] = {
                coins = {
                    image = "pointer_bag_item_0006",
                    pointer = pb_point
                },
                hearts = {
                    image = "pointer_bag_item_0005",
                    pointer = pb_point
                },
                freeze = {
                    image = "pointer_bag_item_0004",
                    pointer = pb_area
                },
                dynamite = {
                    image = "pointer_bag_item_0003",
                    pointer = pb_area
                },
                atomic_freeze = {
                    image = "pointer_bag_item_0002",
                    pointer = pb_area
                },
                atomic_bomb = {
                    image = "pointer_bag_item_0001",
                    pointer = pb_area
                }
            }
        elseif IS_KR3 then
            self.pointers[GUI_MODE_BAG_ITEM] = {}
        end
    end
end

function MousePointer:update_pointer(mode)
    if self.timer then
        timer:cancel(self.timer)

        self.timer = nil
    end

    local pointer, pointer_image
    local pointers = self.pointers[mode]

    if pointers then
        if mode == GUI_MODE_BAG_ITEM and game_gui.bag_button and game_gui.bag_button.selected_item then
            local item = pointers[game_gui.bag_button.selected_item]

            if item then
                pointer = item.pointer
                pointer_image = item.image

                pointer.children[1]:set_image(pointer_image)
            end
        else
            local e = game_gui.selected_entity

            if e and e.user_selection and e.user_selection.custom_pointer_name and
                pointers[e.user_selection.custom_pointer_name] then
                pointer = pointers[e.user_selection.custom_pointer_name]
            else
                pointer = pointers.default
            end
        end
    end

    log.paranoid("pointer: %s", pointer and pointer.image_name)

    if not pointer then
        self.hidden = true

        love.mouse.setVisible(true)
    else
        love.mouse.setVisible(false)
        self:remove_children()
        self:add_child(pointer)

        self.hidden = false
    end
end

function MousePointer:show_cross()
    if self.timer then
        timer:cancel(self.timer)

        self.timer = nil
    else
        if self.hidden then
            -- block empty
        end

        self.last_cursor = self.children[1]
    end

    self:remove_children()
    self:add_child(self.cross)

    self.cross.ts = 0
    self.hidden = false
    self.timer = timer:after(0.4666666666666667, function()
        self:remove_children()

        if self.last_cursor then
            self:add_child(self.last_cursor)

            self.last_cursor = nil
            self.timer = nil
        else
            self.hidden = true
        end
    end)
end

function MousePointer:update(dt)
    if not self.hidden then
        if not self.window then
            self.window = self:get_window()
        end

        local x, y = self.window:get_mouse_position()

        self.pos.x, self.pos.y = self.window:screen_to_view(x, y)
    end

    MousePointer.super.update(self, dt)
end

NotificationView = class("NotificationView", KView)

function NotificationView:initialize(w, h)
    NotificationView.super.initialize(self)
end

function NotificationView:show(id, no_transition, force_show)
    local img_prefix = {
        [N_ENEMY] = "encyclopedia_creeps_",
        [N_TOWER] = "encyclopedia_towers_",
        [N_POWER] = "tutorial_powers_polaroids_"
    }
    local titles = {
        218,
        215,
        157,
        [N_ENEMY] = {"notifications_tit_newenemy_bg", _("NEW ENEMY!"), {247, 244, 185}},
        [N_TOWER] = {"notifications_tit_towers_bg", _("NEW TOWER UNLOCKED"), {247, 244, 185}},
        [N_TOWER_4] = {"notifications_tit_towers_bg", _("NEW TOWER UPGRADES"), {247, 244, 185}},
        [N_TOWER_2] = {"notifications_tit_towers_bg", _("NEW TOWERS UNLOCKED"), {247, 244, 185}},
        [N_POWER] = {"notifications_tit_newpower_bg", _("NEW SPECIAL POWER!"), {247, 244, 185}},
        [N_TIP] = {"notifications_tit_generics_bg_0001", _("HINT"), {247, 244, 185}},
        [N_TUTORIAL] = {"tutorial_tit_instructions_bg", _("INSTRUCTIONS")}
    }

    local function create_noti_title(style)
        local title_bg, title_text, title_color = unpack(titles[style])
        local is_long = #title_text > 20
        local v_title = KImageView:new(title_bg)

        v_title.anchor = V.v(0, v_title.size.y)
        v_title.pos = V.v(80, 40)
        v_title.scale.x = is_long and 1.3 or 1

        local v_title_label = GGShaderLabel:new(V.v(math.floor(208 * v_title.scale.x), 38))

        v_title_label.font_name = "h_noti"
        v_title_label.font_size = 24
        v_title_label.scale.x = 1 / v_title.scale.x
        v_title_label.pos.y = 16
        v_title_label.pos.x = v_title.size.x * 0.5
        v_title_label.anchor.x = v_title_label.size.x * 0.5
        v_title_label.text = title_text
        v_title_label.text_align = "center"
        v_title_label.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "zh-Hant", "middle", "ko", "middle",
            "ja", "middle")
        v_title_label.colors.text = title_color
        v_title_label.colors.background = DEBUG_BACKGROUND_COLOR
        v_title_label.shaders = {"p_glow"}
        v_title_label.shader_args = {{
            thickness = 0.6,
            glow_color = {0, 0, 0, 1}
        }}
        v_title_label.fit_lines = 1

        v_title:add_child(v_title_label)

        return v_title
    end

    local function create_noti_button(style)
        local b

        if style == "light" then
            b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002",
                "notifications_but_lightblue_bg_0002")
            b.label.text = _("OK!")
        elseif style == "dark" then
            b = GGButton("notifications_but_dark_bg_0001", "notifications_but_dark_bg_0002",
                "notifications_but_dark_bg_0002")
            b.label.text = _("OK!")
        elseif style == "skip" then
            b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002",
                "notifications_but_lightblue_bg_0002")
            b.label.text = _("Skip this!")
        elseif style == "next" then
            b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002",
                "notifications_but_lightblue_bg_0002")
            b.label.text = _("Next!")
        elseif style == "gotcha" then
            local prefix = "tutorial_but_gotcha_bg_long"

            b = GGButton(prefix .. "_0001", prefix .. "_0002", prefix .. "_0002")
            b.label.text = _("Got it!")
        end

        b.anchor.y = 0
        b.label.size.x = b.label.size.x - 40
        b.label.size.y = 34
        b.label.pos.x = 20
        b.label.pos.y = 14
        b.label.vertical_align = CJK("middle-caps", "middle")
        b.label.text_align = "center"
        b.label.font_name = "body"
        b.label.font_size = 20
        b.label_colors = {
            default = {255, 254, 200},
            hover = {255, 255, 255}
        }
        b.label.colors.text = b.label_colors.default
        b.label.colors.background = DEBUG_BACKGROUND_COLOR
        b.label.shader_args = {{
            thickness = 0.5,
            glow_color = {0, 0, 0, 1}
        }}

        b.label:do_fit_lines(1)

        if style == "gotcha" then
            b.label.vertical_align = nil
            b.label.size.y = 26
            b.label.anchor.y = 26
            b.label.pos.y = CJK(30, 24, nil, 26)
            b.label.font_size = 20
            b.label.fit_lines = 1

            local margin = 15
            local l2 = GGShaderLabel:new(V.v(b.size.x - 2 * margin, 20))

            l2.font_name = "body"
            l2.font_size = 12
            l2.text = _("I'm ready. Now bring it on!")
            l2.anchor.y = 0
            l2.pos = v(margin, CJK(28, 26, nil, 28))
            l2.propagate_on_down = true
            l2.propagate_on_up = true
            l2.propagate_on_click = true
            l2.shaders = {"p_glow"}
            l2.shader_args = {{
                thickness = 0.1,
                glow_color = {0, 0, 0, 1}
            }}
            l2.colors.text = {255, 254, 200}
            l2.fit_lines = 1

            b:add_child(l2)
        end

        return b
    end

    local function create_photo(image, rotation, small_shadow)
        local v_image = KImageView:new(image)

        v_image.anchor = V.v(v_image.size.x * 0.5, v_image.size.y * 0.5)
        v_image.r = rotation
        v_image.propagate_on_click = true

        local border_name = small_shadow and "notifications_polaroid_overlay_small_shadow" or
                                "notifications_polaroid_overlay"
        local v_border = KImageView:new(border_name)
        local dx, dy = (v_border.size.x - v_image.size.x) * 0.5, (v_border.size.y - v_image.size.y) * 0.5

        v_border.pos = V.v(-dx, -dy)
        v_border.propagate_on_click = true

        v_image:add_child(v_border)

        return v_image
    end

    local function create_slide(layout_name, paper, layout_data)
        local colors = {
            black = {0, 0, 0},
            white = {255, 255, 255},
            gray = {48, 41, 35},
            red = {216, 55, 18},
            dark_red = {183, 63, 13},
            blue = {0, 124, 178}
        }
        local views = {}
        local v_paper = KImageView:new(paper)

        v_paper.propagate_on_click = true
        v_paper.propagate_on_down = true

        table.insert(views, v_paper)

        for i, d in pairs(layout_data) do
            local lv = GGLabel:new(V.v(d.size.x, d.size.y))

            lv.font_name = "body_slides"
            lv.font_size = 18
            lv.text_align = "left"
            lv.fit_size = true
            lv.colors.text = {17, 20, 12, 255}

            table.deepmerge(lv, d)

            lv.text = _(lv.text)

            if lv.color and colors[lv.color] then
                lv.colors.text = colors[lv.color]
            end

            table.insert(views, lv)

            if DBG_SLIDE_EDITOR then
                function lv.on_click(this)
                    if game_gui.SEL_VIEW and game_gui.SEL_VIEW._debug_old_bg_color then
                        if game_gui.SEL_VIEW._debug_old_bg_color == "none" then
                            game_gui.SEL_VIEW.colors.background = nil
                        else
                            game_gui.SEL_VIEW.colors.background = game_gui.SEL_VIEW._debug_old_bg_color
                        end

                        game_gui.SEL_VIEW._debug_old_bg_color = nil
                    end

                    game_gui.SEL_VIEW = this
                    this._debug_old_bg_color = this.colors and this.colors.background or "none"
                    this.colors.background = {255, 0, 0, 100}

                    log.debug("NotificationView - SEL_VIEW: %s", this.text)
                end
            else
                lv.propagate_on_click = true
                lv.propagate_on_down = true
                lv.propagate_on_up = true
            end
        end

        return views, v_paper.size.x, v_paper.size.y
    end

    local function create_layout(layout, image, prefix, subtitle, offset_y)
        offset_y = offset_y or 0

        local views = {}
        local ox, oy = 255, 50 + offset_y
        local my = 0
        local label_w = 320

        prefix = string.upper(prefix)

        local v_paper = KImageView:new("notifications_newenemy")

        v_paper.pos.y = offset_y
        v_paper.propagate_on_click = true
        v_paper.propagate_on_down = true

        table.insert(views, v_paper)

        if layout == N_ENEMY then
            local l_name = GGLabel:new(V.v(label_w, 36))

            l_name.pos = V.v(ox, CJK(oy, nil, nil, oy - 5))
            l_name.text = _(prefix .. "_NAME")
            l_name.font_name = "body_slides"
            l_name.font_size = 28
            l_name.colors.text = {24, 26, 15, 255}
            l_name.text_align = "left"
            l_name.fit_lines = 1

            table.insert(views, l_name)

            oy = oy + my + l_name.size.y

            local l_desc = GGLabel:new(V.v(label_w, 100))

            l_desc.pos = V.v(ox, oy)
            l_desc.text = _(prefix .. "_DESCRIPTION")
            l_desc.font_name = "body_slides"
            l_desc.font_size = 19
            l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)
            l_desc.colors.text = {24, 26, 15, 255}
            l_desc.text_align = "left"
            l_desc.fit_size = true

            table.insert(views, l_desc)

            oy = oy + my + l_desc.size.y

            local l_extra = GGLabel:new(V.v(label_w, 90))

            l_extra.pos = V.v(ox, oy + 1)
            l_extra.text = string.gsub(_(prefix .. "_EXTRA"), "- ", "* ")
            l_extra.font_name = "body_slides"
            l_extra.font_size = 13
            l_extra.line_height = CJK(0.85, nil, 1.1, 0.9)
            l_extra.text_align = "left"
            l_extra.colors.text = {146, 25, 0, 255}

            table.insert(views, l_extra)

            oy = oy + my + l_extra.size.y
        elseif layout == N_POWER then
            local l_name = GGLabel:new(V.v(label_w, 35))

            l_name.pos = V.v(ox, oy)
            l_name.text = _(prefix .. "_NAME")
            l_name.font_name = "body_slides"
            l_name.font_size = 28
            l_name.colors.text = {24, 26, 15, 255}
            l_name.text_align = "left"
            l_name.vertical_align = "middle"
            l_name.fit_lines = 1

            table.insert(views, l_name)

            oy = oy + my + l_name.size.y

            local l_desc = GGLabel:new(V.v(label_w, 85))

            l_desc.pos = V.v(ox, CJK(oy, nil, nil, oy + 8))
            l_desc.text = _(prefix .. "_LARGE_DESCRIPTION")
            l_desc.font_name = "body_slides"
            l_desc.font_size = 17
            l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)
            l_desc.colors.text = {24, 26, 15, 255}
            l_desc.text_align = "left"

            table.insert(views, l_desc)

            oy = oy + my + l_desc.size.y
        elseif layout == N_TOWER then
            oy = oy + 20

            local l_sub = GGLabel:new(V.v(label_w, 20))

            l_sub.pos = V.v(ox + 2, oy + CJK(4, nil, nil, -4))
            l_sub.text = _(subtitle)
            l_sub.font_name = "body_slides"
            l_sub.font_size = 15
            l_sub.colors.text = {24, 26, 15, 255}
            l_sub.text_align = "left"

            table.insert(views, l_sub)

            oy = oy + my + l_sub.size.y

            local l_name = GGLabel:new(V.v(label_w, 40))

            l_name.pos = V.v(ox, CJK(oy, nil, nil, oy - 2))
            l_name.text = _(prefix .. "_NAME")
            l_name.font_name = "body_slides"
            l_name.font_size = 28
            l_name.colors.text = {24, 26, 15, 255}
            l_name.text_align = "left"
            l_name.fit_lines = 1

            table.insert(views, l_name)

            oy = oy + my + l_name.size.y

            local l_extra = GGLabel:new(V.v(label_w, 100))

            l_extra.pos = V.v(ox, oy)
            l_extra.text = _(prefix .. "_EXTRA")
            l_extra.font_name = "body_slides"
            l_extra.font_size = 17
            l_extra.line_height = CJK(0.8, nil, 1.1, 0.9)
            l_extra.colors.text = {24, 26, 15, 255}
            l_extra.text_align = "left"

            table.insert(views, l_extra)

            oy = oy + my + l_extra.size.y
        end

        local v_photo = create_photo(image, math.pi / 24)

        v_photo.pos = V.v(134, 160 + offset_y)

        table.insert(views, v_photo)

        if DBG_SLIDE_EDITOR then
            for _, v in pairs(views) do
                if v:isInstanceOf(GGLabel) then
                    function v.on_click(this)
                        if game_gui.SEL_VIEW and game_gui.SEL_VIEW._debug_old_bg_color then
                            if game_gui.SEL_VIEW._debug_old_bg_color == "none" then
                                game_gui.SEL_VIEW.colors.background = nil
                            else
                                game_gui.SEL_VIEW.colors.background = game_gui.SEL_VIEW._debug_old_bg_color
                            end

                            game_gui.SEL_VIEW._debug_old_bg_color = nil
                        end

                        game_gui.SEL_VIEW = this
                        this._debug_old_bg_color = this.colors and this.colors.background or "none"
                        this.colors.background = {255, 0, 0, 100}

                        log.debug("create_layout - SEL_VIEW: %s", this.text)
                    end
                end
            end
        end

        return views, v_paper.size.x, v_paper.size.y
    end

    local n = data.notifications[id]

    if not n then
        log.debug("Notification with id:%s not found", id)

        return
    end

    if not force_show and U.is_seen(game_gui.game.store, id) and not n.always then
        return
    end

    U.mark_seen(game_gui.game.store, id)

    if n and n.seen then
        for _, name in pairs(n.seen) do
            U.mark_seen(game_gui.game.store, name)
        end
    end

    if self.timers then
        for _, t in pairs(self.timers) do
            timer:cancel(t)
        end

        self:remove_children()

        self.timers = nil
    end

    if table.contains({N_ENEMY, N_POWER, N_TOWER}, n.layout) then
        local n_prefix = n.prefix or id

        if n.layout == N_ENEMY then
            local t = E:get_template(id)

            n_prefix = t and t.info and t.info.i18n_key or n_prefix
        end

        local views, pw, ph = create_layout(n.layout, n.image, n_prefix, n.sub)
        local v_title = create_noti_title(n.layout)

        v_title.anchor = V.v(0, v_title.size.y)

        local b_ok = create_noti_button("dark")

        b_ok.pos = V.v(475, 254)

        function b_ok.on_click(this)
            this:disable()
            self:hide()
        end

        self:add_child(v_title)
        self:add_child(b_ok)

        for _, v in pairs(views) do
            self:add_child(v)
        end

        self.size = V.v(pw, ph)
        self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    elseif n.layout == N_TIP then
        local views, pw, ph = create_slide(n.layout, n.paper, data.notification_slides[id])
        local v_title = create_noti_title(n.layout)

        v_title.anchor = V.v(v_title.size.x * 0.5, v_title.size.y)
        v_title.pos = V.v(pw * 0.5, 32)

        local b_ok = create_noti_button("light")

        b_ok.pos = V.v(300, 360)
        b_ok.anchor.x = 0

        function b_ok.on_click(this)
            this:disable()
            self:hide()
        end

        self:add_child(v_title)
        self:add_child(b_ok)

        for _, v in pairs(views) do
            self:add_child(v)
        end

        self.size = V.v(pw, ph)
        self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    elseif n.layout == N_TOWER_2 then
        local views_1, pw1, ph1 = create_layout(N_TOWER, n.images[1], n.prefixes[1], n.subs[1])
        local views_2, pw2, ph2 = create_layout(N_TOWER, n.images[2], n.prefixes[2], n.subs[2], ph1 - 30)
        local v_title = create_noti_title(n.layout)

        v_title.anchor = V.v(0, v_title.size.y)

        local b_ok = create_noti_button("dark")

        b_ok.pos = V.v(450, ph1 + ph2 - 30 - 40)

        function b_ok.on_click(this)
            this:disable()
            self:hide()
        end

        self:add_child(v_title)
        self:add_child(b_ok)

        for _, v in pairs(views_1) do
            self:add_child(v)
        end

        for _, v in pairs(views_2) do
            self:add_child(v)
        end

        self.size = V.v(pw1, ph1 + ph2 - 30)
        self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    elseif n.layout == N_TOWER_4 then
        local ox, oy = 76, 55
        local my = 5
        local v_paper = KImageView:new("notifications_newenemy")

        v_paper.propagate_on_click = true
        v_paper.propagate_on_down = true

        local l_1 = GGLabel:new(V.v(490, 32))

        l_1.pos = V.v(ox, oy)
        l_1.text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_TITLE"), n.level)
        l_1.font_name = "body_slides"
        l_1.font_size = 24
        l_1.colors.text = {24, 26, 15, 255}
        l_1.text_align = "center"
        oy = oy + my + l_1.size.y

        local l_2 = GGLabel:new(V.v(490, 85))

        l_2.pos = V.v(ox, oy)
        l_2.text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_DESCRIPTION"), n.level)
        l_2.font_name = "body_slides"
        l_2.font_size = 16
        l_2.colors.text = {24, 26, 15, 255}
        l_2.text_align = "center"
        oy = oy + my + l_2.size.y

        local offx = 140
        local pox, poy = (v_paper.size.x - 3 * offx) * 0.5, 220
        local rotations = {math.pi / 22, -math.pi / 20, math.pi / 30, -math.pi / 25}
        local photos = {}

        for i, image in ipairs(n.images) do
            local photo = create_photo(image, rotations[i], true)

            photo.pos.x, photo.pos.y = pox + (i - 1) * offx, poy
            photo.scale = V.v(0.85, 0.85)

            table.insert(photos, photo)
        end

        local v_title = create_noti_title(n.layout)

        v_title.anchor = V.v(0, v_title.size.y)

        local b_ok = create_noti_button("dark")

        b_ok.pos = V.v(450, v_paper.size.y - 15)

        function b_ok.on_click(this)
            this:disable()
            self:hide()
        end

        self:add_child(v_title)
        self:add_child(b_ok)
        self:add_child(v_paper)
        self:add_child(l_1)
        self:add_child(l_2)

        for _, p in ipairs(photos) do
            self:add_child(p)
        end

        self.size = V.vclone(v_paper.size)
        self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    elseif n.layout == N_TUTORIAL then
        local views, pw, ph = create_slide(n.layout, n.paper, data.notification_slides[id])
        local v_paper = views[1]

        v_paper.propagate_on_click = true
        v_paper.propagate_on_down = true

        local v_title = create_noti_title(n.layout)

        v_title.anchor = V.v(v_title.size.x * 0.5, v_title.size.y)
        v_title.pos = V.v(pw * 0.5, 32)

        self:add_child(v_title)

        if n.next then
            local b_skip = create_noti_button("skip")

            b_skip.anchor = V.v(b_skip.size.x, 0)
            b_skip.pos = V.v(v_paper.size.x * 0.5 - 20, v_paper.size.y - 30)

            function b_skip.on_click(this)
                this:disable()
                self:hide()
            end

            self:add_child(b_skip)

            local b_next = create_noti_button("next")

            b_next.anchor = V.v(0, 0)
            b_next.pos = V.v(v_paper.size.x * 0.5 + 20, v_paper.size.y - 30)

            function b_next.on_click(this)
                self.show_next = n.next

                this:disable()
                self:hide(true)
            end

            self:add_child(b_next)
        else
            local b_ok = create_noti_button("gotcha")

            b_ok.anchor = V.v(b_ok.size.x * 0.5, 0)
            b_ok.pos = V.v(v_paper.size.x * 0.5, v_paper.size.y - 24)

            function b_ok.on_click(this)
                this:disable()
                self:hide()
            end

            self:add_child(b_ok)
        end

        for _, v in pairs(views) do
            self:add_child(v)
        end

        self.size.x, self.size.y = pw, ph
        self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    else
        log.error("Notification type %s unknown", n.layout)

        return
    end

    game_gui:deselect_all()
    game_gui:disable_keys()

    game_gui.game.store.paused = true

    game_gui.overlay:show()

    self.hidden = false

    if no_transition then
        self.alpha = 1
        self.scale = V.v(1, 1)
    else
        self.alpha = 0
        self.scale = V.v(0.5, 0.5)
        self.timers = {timer:tween(0.4, self, {
            alpha = 1
        }), timer:tween(0.4, self.scale, {
            x = 1,
            y = 1
        }, "out-back")}
    end

    S:queue("GUINotificationOpen")
    signal.emit("notification-shown", n)

    if n.signals then
        for _, s in pairs(n.signals) do
            signal.emit(unpack(s))
        end
    end
end

function NotificationView:hide(no_transition)
    if not self.show_next then
        game_gui:enable_keys()

        game_gui.game.store.paused = false

        game_gui.overlay:hide()
    end

    if no_transition then
        self:remove_children()
        self:show(self.show_next, true)

        self.show_next = nil

        return
    end

    self.alpha = 1

    if self.timers then
        for _, t in pairs(self.timers) do
            timer:cancel(t)
        end

        self.timers = nil
    end

    self.timers = {timer:tween(0.4, self, {
        alpha = 0
    }), timer:tween(0.4, self.scale, {
        x = 0.5,
        y = 0.5
    }, "in-back", function()
        self.timers = nil
        self.hidden = true

        self:remove_children()

        if self.show_next then
            self:show(self.show_next)

            self.show_next = nil
        end
    end)}

    S:queue("GUINotificationClose")
end

NotificationQueue = class("NotificationQueue", KView)

function NotificationQueue:initialize(w, h)
    NotificationQueue.super.initialize(self, V.v(w, h))

    self.clip = false
    self.colors.background = {0, 0, 0, 0}
    self.space_y = 10
end

function NotificationQueue:add(id, force)
    local n = data.notifications[id]

    if not n then
        log.warning("Notification with id:%s not found", id)

        return
    end

    if U.is_seen(game_gui.game.store, id) and not n.always and not force then
        return
    end

    U.mark_seen(game_gui.game.store, id)

    local v_icon = NotificationIcon:new(n.icon, id, n.layout)

    v_icon.pos.y = #self.children * (v_icon.size.y + self.space_y)

    self:add_child(v_icon)
    S:queue("GUINotificationSecondLevel")

    if n.icon_signals then
        for _, s in pairs(n.icon_signals) do
            signal.emit(unpack(s))
        end
    end
end

function NotificationQueue:remove_icon(child)
    local move = false

    for i, c in ipairs(self.children) do
        if c == child then
            move = true
        elseif move then
            timer:tween(0.3, c.pos, {
                y = c.pos.y - (c.size.y + self.space_y)
            }, "out-quad")
        end
    end

    self:remove_child(child)
end

function NotificationQueue:hide()
    timer:tween(0.3, self, {
        alpha = 0
    }, "in-quad")
end

function NotificationQueue:show()
    timer:tween(0.3, self, {
        alpha = 1
    }, "in-quad")
end

NotificationIcon = class("NotificationIcon", KImageView)

function NotificationIcon:initialize(image, notification_id, layout)
    NotificationIcon.super.initialize(self, image)

    self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)
    self.notification_id = notification_id

    local title = GGShaderLabel:new(V.v(math.floor(self.size.x * 1.5), 30))

    title.anchor = V.v(title.size.x * 0.5, 0)
    title.pos.x = self.size.x * 0.5 - 4
    title.font_name = "h_noti"
    title.text_align = "center"
    title.vertical_align = "bottom"
    title.colors.text = {253, 248, 73}
    title.shaders = {"p_bands", "p_outline", "p_edge_blur"}

    if layout == N_TIP or layout == N_POWER then
        title.pos.y = CJK(-6, -10, -12, -14)
        title.font_size = 22
        title.text = _("TIP_ALERT_ICON")
        title.shader_args = {{
            margin = 0,
            p1 = 0.3,
            p2 = 0.55,
            c1 = {0.5019607843137255, 0.9490196078431372, 1, 1},
            c2 = {0.5019607843137255, 0.9490196078431372, 1, 1},
            c3 = {0.14901960784313725, 0.7137254901960784, 0.8509803921568627, 1}
        }, {
            thickness = 1,
            outline_color = {0.09019607843137255, 0.1411764705882353, 0.14901960784313725, 1}
        }, {
            thickness = 1
        }}
    else
        title.pos.y = CJK(-14, -13, -16, -20)
        title.font_size = 17
        title.text = _("NEW_ENEMY_ALERT_ICON")
        title.shader_args = {{
            margin = 1,
            p1 = 0.3,
            p2 = 0.45,
            c1 = {0.9921568627450981, 0.9725490196078431, 0.28627450980392155, 1},
            c2 = {0.9921568627450981, 0.9725490196078431, 0.28627450980392155, 1},
            c3 = {0.9921568627450981, 0.7725490196078432, 0.21568627450980393, 1}
        }, {
            thickness = 2,
            outline_color = {0.18823529411764706, 0.1803921568627451, 0.043137254901960784, 1}
        }, {
            thickness = 1
        }}
    end

    title.fit_lines = 1
    title.propagate_on_click = true

    self:add_child(title)
    self:show()
end

function NotificationIcon:loop_tween()
    local s = self.scale.x > 1 and 0.985 or 1.015

    timer:tween(0.3, self.scale, {
        x = s,
        y = s
    }, "in-out-sine", function()
        self:loop_tween()
    end)
end

function NotificationIcon:on_click()
    game_gui:show_notification(self.notification_id, true)
    self:hide()
end

function NotificationIcon:show()
    S:queue("GUINotificationSecondLevel")
    timer:tween(0.3, self, {
        alpha = 1
    }, "in-quad")

    self.scale.x, self.scale.y = 0.8, 0.8

    self:loop_tween()
end

function NotificationIcon:hide()
    self:disable(false)

    local s = 0.4

    timer:tween(0.4, self.scale, {
        x = s,
        y = s
    }, "in-back", function()
        self.parent:remove_icon(self)
    end)
    timer:tween(0.4, self, {
        alpha = 0
    })
end

TutorialBalloon = class("TutorialBalloon", KImageView)

function TutorialBalloon:initialize(id)
    local bd = data.tutorial_balloons[id]

    if not bd then
        log.error("Balloon with id:%s not found", id)

        return
    end

    TutorialBalloon.super.initialize(self, bd.image)

    if data.notification_slides[id] then
        local views = {}

        for i, d in pairs(data.notification_slides[id]) do
            local lv = GGLabel:new(V.v(d.size.x, d.size.y))

            lv.font_name = "body"
            lv.font_size = 18
            lv.text_align = "left"
            lv.colors.text = {17, 20, 12, 255}

            table.deepmerge(lv, d)

            lv.text = _(lv.text)

            if lv.color and colors[lv.color] then
                lv.colors.text = colors[lv.color]
            end

            table.insert(views, lv)

            if DBG_SLIDE_EDITOR then
                function lv.on_click(this)
                    game_gui.SEL_VIEW = this

                    log.debug("SEL_VIEW: %s", this.text)
                end
            else
                lv.propagate_on_click = true
                lv.propagate_on_down = true
                lv.propagate_on_up = true
            end
        end

        for _, v in pairs(views) do
            self:add_child(v)
        end
    end

    self.id = id
    self.propagate_on_click = true
    self.propagate_on_down = true
    self.propagate_on_up = true
    self.balloon_on_hide = bd.balloon
    self.anchor = V.v(self.size.x * 0.5, self.size.y * 0.5)

    if bd.origin == "world" then
        self.pos.x, self.pos.y = game_gui:g2u(bd.offset)
    else
        local ox, oy

        if string.match(bd.origin, "top") then
            oy = 0
        end

        if string.match(bd.origin, "bottom") then
            oy = game_gui.sh
        end

        if string.match(bd.origin, "left") then
            ox = 0
        end

        if string.match(bd.origin, "right") then
            ox = game_gui.sw
        end

        if string.match(bd.origin, "center") then
            ox = game_gui.sw * 0.5
            oy = game_gui.sh * 0.5
        end

        self.pos.x, self.pos.y = ox + bd.offset.x, oy + bd.offset.y
    end

    self.sig_handles = {}

    local function sig_reg(name, fn)
        local h = signal.register(name, fn)

        table.insert(self.sig_handles, {name, h})
    end

    self.hide_cond = bd.hide_cond

    if self.hide_cond == "tower_built" then
        sig_reg("tower-built", function()
            self:remove(false)
        end)
        sig_reg("tower-menu-showing", function()
            self:hide()
        end)
        sig_reg("tower-menu-hiding", function()
            self:show()
        end)
    elseif self.hide_cond == "power_selected_1" then
        sig_reg("power-selected", function(mode)
            if mode == GUI_MODE_POWER_1 then
                self:remove(true)
            end
        end)
    elseif self.hide_cond == "power_selected_2" then
        sig_reg("power-selected", function(mode)
            if mode == GUI_MODE_POWER_2 then
                self:remove(true)
            end
        end)
    elseif self.hide_cond == "power_selected_3" then
        sig_reg("power-selected", function(mode)
            if mode == GUI_MODE_POWER_3 then
                self:remove(true)
            end
        end)
    elseif self.hide_cond == "power_used" then
        sig_reg("power-used", function()
            self:remove(true)
        end)
        sig_reg("power-deselected", function()
            self:remove(true)
        end)
    elseif self.hide_cond == "noti_shown" then
        sig_reg("notification-shown", function()
            self:remove(true)
        end)
    elseif self.hide_cond == "wave_sent" then
        sig_reg("next-wave-sent", function()
            self:remove(true)
        end)
    end

    sig_reg("game-defeat", function()
        self:remove(false)
    end)
    sig_reg("game-victory", function()
        self:remove(false)
    end)
    sig_reg("hide-gui", function()
        self:remove(false)
    end)

    self.hidden = true

    self:show()
end

function TutorialBalloon:loop_tween()
    if self.tween_handle then
        timer:cancel(self.tween_handle)
    end

    if self.hidden then
        return
    end

    local s = self.scale.x > 1 and 0.985 or 1.015

    self.tween_handle = timer:tween(0.3, self.scale, {
        x = s,
        y = s
    }, "in-out-sine", function()
        self:loop_tween()
    end)
end

function TutorialBalloon:hide()
    log.debug("TutorialBalloon:hide %s", self.id)

    if self.hidden or not self.parent then
        return
    end

    if self.tween_handle then
        timer:cancel(self.tween_handle)
    end

    local s = 0.4

    self.tween_handle = timer:tween(0.4, self, {
        alpha = 0,
        scale = {
            x = s,
            y = s
        }
    }, "in-back", function()
        self.hidden = true
    end)
end

function TutorialBalloon:remove(animated)
    log.debug("TutorialBalloon:remove animated:%s, id:%s, parent:%s", animated, self.id, self.parent)

    for _, h in pairs(self.sig_handles) do
        local name, fn = unpack(h)

        signal.remove(name, fn)
    end

    if self.tween_handle then
        timer:cancel(self.tween_handle)
    end

    if animated then
        if self.balloon_on_hide then
            game_gui:show_balloon(self.balloon_on_hide)
        end

        local s = 0.4

        self.tween_handle = timer:tween(0.4, self, {
            alpha = 0,
            scale = {
                x = s,
                y = s
            }
        }, "in-back", function()
            self:remove_from_parent()
        end)
    else
        self:remove_from_parent()
    end
end

function TutorialBalloon:show()
    log.debug("TutorialBalloon:show id:%s", self.id)

    if not self.hidden then
        return
    end

    if self.tween_handle then
        timer:cancel(self.tween_handle)
    end

    self.hidden = false

    timer:tween(0.3, self, {
        alpha = 1
    }, "in-quad")

    self.scale.x, self.scale.y = 0.8, 0.8

    self:loop_tween()
end

AchievementBanner = class("AchievementBanner", KImageView)

function AchievementBanner:initialize(id)
    AchievementBanner.super.initialize(self, "achievements_box_large")

    local header = GGLabel:new(V.v(78, 13))

    header.pos.x, header.pos.y = 95, 8.5 + CJK(0, -1, 0, 0)
    header.text = _("ACHIEVEMENT")
    header.vertical_align = "middle"
    header.text_align = "center"
    header.colors.text = {72, 51, 25, 255}
    header.font_name = "h_noti"
    header.font_size = 16
    header.fit_lines = 1

    self:add_child(header)

    local icon = KImageView:new("achievement_icons_0001")

    icon.anchor = V.v(icon.size.x * 0.5, icon.size.y * 0.5)
    icon.pos = V.v(40, 54)
    icon.scale = V.v(0.8, 0.8)
    icon.propagate_on_click = true

    self:add_child(icon)

    local l_title = GGLabel:new(V.v(180, 14))

    l_title.pos = V.v(68, CJK(35, 33, nil, 33))
    l_title.font_name = "h"
    l_title.font_size = 12
    l_title.colors.text = {234, 205, 132}
    l_title.text = "TITLE"
    l_title.text_align = "left"
    l_title.propagate_on_click = true
    l_title.fit_lines = 1

    self:add_child(l_title)

    local l_desc = GGLabel:new(V.v(180, 32))

    l_desc.font_name = "body"
    l_desc.font_size = 10
    l_desc.colors.text = {246, 227, 176}
    l_desc.text = "DESC"
    l_desc.text_align = "left"
    l_desc.propagate_on_click = true
    l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)

    l_desc:do_fit_lines(3)

    l_desc.clip = true
    l_desc.pos.x, l_desc.pos.y = 68, 45 + CJK(0, 3, 3, 1)

    self:add_child(l_desc)

    self.icon = icon
    self.l_title = l_title
    self.l_desc = l_desc

    function self.on_click(this)
        if self.active then
            this:hide()
        end
    end

    self.anchor = V.v(self.size.x * 0.5, self.size.y)
    self.pos = V.v(game_gui.sw * 0.5, -1)
    self.hidden = true
    self.queued_ids = {}
end

function AchievementBanner:queue(id)
    table.insert(self.queued_ids, id)
    self:show()
end

function AchievementBanner:show()
    if #self.queued_ids < 1 or not self.hidden then
        return
    end

    local id = table.remove(self.queued_ids, 1)
    local ach = AC:get_data(id)
    local prefix = KR_GAME == "kr3" and "ELVES_" or ""

    self.icon:set_image("achievement_icons_" .. string.format("%04i", ach.icon))

    self.l_title.text = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_NAME")
    self.l_desc.text = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_DESCRIPTION")
    self.hidden = false
    self.active = true

    S:queue("GUIAchievementWin", {
        ignore = 1
    })

    if self.timers then
        for _, t in pairs(self.timers) do
            timer:cancel(t)
        end
    end

    self.timers = {timer:tween(0.5, self.pos, {
        y = self.size.y * self.scale.y + 10
    }, "out-back"), timer:after(4, function()
        self:hide()
    end)}
end

function AchievementBanner:hide()
    if self.timers then
        for _, t in pairs(self.timers) do
            timer:cancel(t)
        end
    end

    self.timers = {}
    self.active = false
    self.timers = {timer:tween(0.5, self.pos, {
        y = -1
    }, "in-back", function()
        self.timers = nil
        self.hidden = true

        if #self.queued_ids > 0 then
            self:show()
        end
    end)}
end

PickView = class("PickView", KView)

function PickView:initialize(w, h)
    PickView.super.initialize(self)

    self.size = v(w, h)
    self.clip = false
    self.colors.background = {0, 0, 0, 0}
end

function PickView:update(dt)
    local function show_tower_hover(entity)
        if game_gui.game.store.paused then
            return
        end

        local s = entity.render.sprites[1]
        if s then
            s._orig_name = s.name
            s.name = s.name .. "_over"

            if s.hover_off_hidden then
                s.hidden = nil
            end
        end

        self.last_tower_hover = entity

        S:queue("GUIQuickMenuOver")
    end

    local function hide_tower_hover()
        local oe = self.last_tower_hover

        if oe then
            local s = oe.render.sprites[1]
            if s then
                s.name = s._orig_name

                if s.hover_off_hidden then
                    s.hidden = true
                end
            end

            self.last_tower_hover = nil
        end
    end

    PickView.super.update(self, dt)

    local e = game_gui.selected_entity

    if e and (e.tower and e.tower.blocked or e.health and e.health.dead and not e.health.ignore_damage) then
        game_gui:deselect_all()
    end

    if self:is_disabled() or game_gui.mode ~= GUI_MODE_IDLE then
        hide_tower_hover()

        return
    elseif not game_gui.towermenu.hidden then
        local e = game_gui.selected_entity

        if e and game_gui.selected_entity and self.last_tower_hover ~= e then
            hide_tower_hover()

            if e.tower and e.tower.can_hover and e.ui and e.ui.can_click and not self.last_tower_hover then
                show_tower_hover(e)
            end
        end

        return
    end

    local x, y = game_gui.window:get_mouse_position()

    x, y = game_gui.window:screen_to_view(x, y)

    local wx, wy = game_gui:u2g(V.v(x, y))
    local e = game_gui:entity_at_pos(wx, wy)

    if e and e.tower and e.tower.can_hover and e.ui and e.ui.can_click and not self.last_tower_hover then
        show_tower_hover(e)
    elseif self.last_tower_hover and (not e or e ~= self.last_tower_hover) then
        hide_tower_hover()
    end
end

function PickView:on_down(button, x, y)
    local wx, wy = game_gui:u2g(V.v(x, y))

    log.debug("button:%d, screen:%s,%s  world:%s,%s", button, x, y, wx, wy)

    if button == 2 then
        if DEBUG_RIGHT_CLICK then
            DEBUG_RIGHT_CLICK(wx, wy)
        end
    elseif button == 1 then
        if game_gui.mode == GUI_MODE_RALLY_TOWER then
            log.debug("set rally point. view:%s,%s -> game:%s,%s", x, y, wx, wy)

            local e = game_gui.selected_entity
            if not e.barrack then
                e = game_gui.game.simulation.store.entities[e.soldier.tower_id]
            end
            local b = e.barrack

            local rc = V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y))

            if U.is_inside_ellipse(v(wx, wy), rc, b.rally_range) and
                (b.rally_anywhere or P:valid_node_nearby(wx, wy, nil, NF_RALLY) and
                    GR:cell_is_only(wx, wy, b.rally_terrains)) then
                S:queue("GUIPlaceRallyPoint")

                e.barrack.rally_pos = v(wx, wy)
                e.barrack.rally_new = true

                game_gui:show_rally_flag(x, y)
                game_gui:hide_rally_range()
                game_gui:deselect_entity()
                log.debug("entity barrack.rally_pos to %s", e.barrack.rally_pos)
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_RALLY_HERO or game_gui.mode == GUI_MODE_RALLY_CONTROABLE then
            local e = game_gui.selected_entity

            log.debug("set rally point for hero %s to %s,%s", e, wx, sy)

            if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(wx, wy, nil, NF_RALLY)) and
                GR:cell_is_only(wx, wy, e.nav_grid.valid_terrains_dest) and
                (e.teleport and not e.teleport.disabled and V.dist(wx, wy, e.pos.x, e.pos.y) > e.teleport.min_distance or
                    e.nav_grid.ignore_waypoints or
                    GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(wx, wy), e.nav_grid.valid_terrains)) then
                if not e.nav_grid.ignore_waypoints then
                    e.nav_grid.waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(wx, wy),
                        e.nav_grid.valid_terrains)
                end

                e.nav_rally.new = true
                e.nav_rally.pos = v(wx, wy)
                e.nav_rally.center = v(wx, wy)

                game_gui:show_point_confirm(x, y)
                game_gui:deselect_entity()
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_RALLY_CONTROABLES then
            local function calc_rally_pos(idx)
                local r = 15
                return V.v(wx + r * math.cos(idx * 2 * math.pi / #game_gui.selected_controables),
                    wy + r * math.sin(idx * 2 * math.pi / #game_gui.selected_controables))
            end
            if P:valid_node_nearby(wx, wy, nil, NF_RALLY) then
                local num = #game_gui.selected_controables
                for idx, e in ipairs(game_gui.selected_controables) do
                    local rally_pos = calc_rally_pos(idx)
                    if GR:cell_is_only(rally_pos.x, rally_pos.y, e.nav_grid.valid_terrains_dest) then
                        local waypoints =
                            GR:find_waypoints(e.pos, e.nav_rally.pos, rally_pos, e.nav_grid.valid_terrains)
                        if waypoints then
                            e.nav_grid.waypoints = waypoints
                            e.nav_rally.new = true
                            e.nav_rally.pos = rally_pos
                            e.nav_rally.center = rally_pos
                        end
                    end
                end
                game_gui:show_point_confirm(x, y)
                game_gui:deselect_controables()
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_SELECT_POINT then
            local e = game_gui.selected_entity

            if e.user_selection.can_select_point_fn and
                not e.user_selection.can_select_point_fn(e, wx, wy, game_gui.game.store) then
                game_gui:show_invalid_point_cross(x, y)

                return
            end

            e.user_selection.in_progress = false
            e.user_selection.new_pos = v(wx, wy)

            game_gui:deselect_entity()
            log.debug("fire to %s", v(wx, wy))
        elseif game_gui.mode == GUI_MODE_POWER_1 then
            local store = game_gui.game.store
            local level = store.level

            if not GR:cell_is(wx, wy, TERRAIN_CLIFF) and not GR:cell_is(wx, wy, TERRAIN_FAERIE) and
                (P:valid_node_nearby(wx, wy, 1.4285714285714286, NF_POWER_1) or level.fn_can_power and
                    level:fn_can_power(store, GUI_MODE_POWER_1, V.v(wx, wy)) or GR:cell_is(wx, wy, TERRAIN_WATER)) then
                game_gui.power_1:fire(wx, wy)
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_POWER_2 then
            if P:valid_node_nearby(wx, wy, nil, NF_RALLY) and GR:cell_is_only(wx, wy, bor(TERRAIN_LAND, TERRAIN_ICE)) then
                game_gui.power_2:fire(wx, wy)
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_POWER_3 then
            local he = game_gui:entity_by_id(game_gui.heroes[1].hero_id)
            local un = he.hero.skills.ultimate
            local ut = E:get_template(un.controller_name)

            if not ut.can_fire_fn or ut.can_fire_fn(ut, wx, wy, game_gui.game.store) then
                game_gui.power_3:fire(wx, wy)
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        elseif game_gui.mode == GUI_MODE_BAG_ITEM then
            local item_name = wid("bag_button").selected_item
            local e = E:create_entity("user_item_" .. item_name)
            local fn = e.user_selection.can_select_point_fn

            if not fn or fn(e, wx, wy, store) then
                e.pos.x, e.pos.y = wx, wy

                game_gui.game.simulation:insert_entity(e)
                wid("bag_button"):fire_item(item_name, x, y, e)
                signal.emit("item-used", item_name)
                game_gui:set_mode()
            else
                game_gui:show_invalid_point_cross(x, y)
            end
        else
            local e = game_gui:entity_at_pos(wx, wy)

            if e then
                log.info("SELECTED ENTITY (%s) %s pos:(%s,%s)", e.id, e.template_name, e.pos.x, e.pos.y)
            end

            game_gui:deselect_all()

            if e and e.ui and e.ui.can_click then
                e.ui.clicked = true

                if e ~= game_gui.selected_entity then
                    game_gui:select_entity(e)
                elseif not e.enemy then
                    game_gui:deselect_entity()
                end
            else
                game_gui:deselect_entity()
            end
        end
    end
end

RangeCircle = class("RangeCircle", KView)

function RangeCircle:initialize(sprite_name)
    RangeCircle.super.initialize(self)

    self.range_shown = nil

    local tl = KImageView:new(sprite_name)
    local tr = KImageView:new(sprite_name)
    local bl = KImageView:new(sprite_name)
    local br = KImageView:new(sprite_name)

    tl.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
    tl.scale = v(1, 1)
    tr.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
    tr.scale = v(-1, 1)
    bl.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
    bl.scale = v(1, -1)
    br.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
    br.scale = v(-1, -1)
    tl.propagate_on_down = true
    tr.propagate_on_down = true
    bl.propagate_on_down = true
    br.propagate_on_down = true

    self:add_child(tl)
    self:add_child(tr)
    self:add_child(bl)
    self:add_child(br)

    self.can_drag = false
    self.propagate_on_click = true
    self.scale = v(1, 0.7)
    self.actual_radius = v(tl.size.x, tl.size.y)
end

CriketMenuButton = class("CriketMenuButton", KView)
function CriketMenuButton:initialize(item)
    CriketMenuButton.super.initialize(self)

    self.item_image = item.image
    self.item = item
    self.entity = entity

    local b = KImageView:new(item.image)
    b.pos = v(0, 0)

    b.propagate_on_click = true
    b.disabled_tint_color = nil
    self.button = b

    self:add_child(b)

    local function get_pos(this, offset)
        offset = offset or v(0, 0)
        local x = math.floor(-0.5 * (this.size.x - b.size.x) + offset.x)
        local y = math.floor(-0.5 * (this.size.y - b.size.y) + offset.y)

        return v(x, y)
    end

    local function create_bo_view(img_name)
        local bo = KImageView:new(img_name)

        bo.pos = get_pos(bo)
        bo.propagate_on_click = true

        self:add_child(bo, 2)

        return bo
    end

    local halo = KImageView:new(item.halo)

    if item.halo == "glow_ico_sell" then
        halo.pos = v(-2.5, -3.5)
    else
        halo.pos = get_pos(halo)
    end

    halo.propagate_on_click = true
    halo.hidden = true
    self.halo = halo

    self:add_child(halo)

    local bo

    if table.contains({ "tw_upgrade", "tw_buy_soldier", "tw_buy_attack" }, item.action) then
        bo = create_bo_view("main_icons_0000")
    end

    local price_tag

    if item.action == "tw_upgrade" then
        local nt = E:get_template(item.action_arg)

        if nt.build_name then
            nt = E:get_template(nt.build_name)
        end

        price_tag = tostring(nt.tower.price)
    elseif item.action == "tw_unblock" then
        price_tag = tostring(entity.tower_holder.unblock_price)
    elseif item.action == "upgrade_power" then
        local power = entity.powers[item.action_arg]
        local price = power.level == 0 and power.price_base or power.price_inc

        if power.level == power.max_level then
            -- block empty
        end

        price_tag = tostring(price)
    elseif item.action == "tw_buy_soldier" then
        local nt = E:get_template(item.action_arg)

        price_tag = tostring(nt.unit.price)
    elseif item.action == "tw_buy_attack" then
        price_tag = ""
    end

    -- if price_tag then
    --     local pt = GGLabel:new(nil, "price_tag")

    --     pt.id = "price_tag"
    --     pt.pos = V.v(b.size.x * 0.5 - pt.size.x * 0.5, b.size.y - 11)
    --     pt.text_algin = "center"
    --     pt.text_offset.y = CJK(5, 2, 7, 3)
    --     pt.font_name = "body"
    --     pt.font_size = 11
    --     pt.colors.text = { 255, 224, 0 }
    --     pt.disabled_tint_color = nil
    --     pt.propagate_on_click = true
    --     pt.text = price_tag
    --     self.price_tag = pt

    --     self:add_child(pt)
    -- end

    if item.action == "upgrade_power" then
        local power = entity.powers[item.action_arg]

        if not item.no_upgrade_lights then
            self.power_buttons = {}

            for i = 1, power.max_level do
                local pv

                if i > power.level then
                    pv = KImageView:new("power_rank_0002")
                else
                    pv = KImageView:new("power_rank_0001")
                end

                pv.pos = get_pos(pv, V.vclone(data.tower_menu_power_offset[i]))
                pv.pos.x, pv.pos.y = pv.pos.x - pv.size.x * 0.5, pv.pos.y - pv.size.y * 0.5
                pv.disabled_tint_color = nil
                pv.propagate_on_click = true

                bo:add_child(pv)
                table.insert(self.power_buttons, pv)
            end
        end

        if power.level >= power.max_level then
            self:remove_child(self.halo)

            self.halo = nil
        end
    end

    local ufx = KImageView:new("effect_powerbuy_0001")

    ufx.animation = {
        to = 23,
        prefix = "effect_powerbuy",
        from = 1
    }
    ufx.pos = get_pos(ufx)
    ufx.hidden = true
    ufx.propagate_on_click = true
    self.ufx = ufx

    self:add_child(ufx)

    self.size = V.vclone(b.size)
end

CriketMenu = class("CriketMenu", KImageView)

function CriketMenu:initialize()
    CriketMenu.super.initialize(self, "gui_ring")
    self.can_drag = false
    self.propagate_on_click = true
    self.propagate_on_down = true
    self.propagate_on_up = true
    self.propagate_on_enter = true
    self.anchor = v(self.size.x * 0.5, self.size.y * 0.5)
    self.clip = false
end

local criket_menu = require("kr1.data.criket_menu_data")
function CriketMenu:calculate_button_position(item_index)
    local circle_volume = 6
    local radius_mod = 65
    local radius = radius_mod -- 默认半径
    while item_index > circle_volume do
        item_index = item_index - circle_volume
        radius = radius + radius_mod -- 每圈增加80像素的半径
        circle_volume = circle_volume + 6 -- 每圈增加6个按钮
    end

    -- 计算每个按钮之间的角度间隔
    local angle_step = (2 * math.pi) / circle_volume

    -- 计算当前按钮的角度（从顶部开始，顺时针）
    local angle = (item_index - 1) * angle_step - math.pi * 0.5

    -- 计算相对于圆心的位置
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    -- 返回相对于菜单中心的位置
    return V.v(self.size.x * 0.5 + x, self.size.y * 0.5 + y)
end
function CriketMenu:show()
    self:remove_children()
    for index, item in pairs(criket_menu) do
        local b = CriketMenuButton:new(item)
        b.pos = self:calculate_button_position(index)
        b.pos.x, b.pos.y = b.pos.x - b.size.x * 0.5, b.pos.y - b.size.y * 0.5
        b.item_props = item

        local stm = self

        if item.action == "tw_none" then
            b:disable()
        else
            function b.on_click(this, button, x, y)
                log.debug("CLICK")

                if not self.tweening and not this.click_disabled then
                    stm:button_callback(this, item)
                end
            end

            function b.on_enter(this, drag_view)
                if not self.tweening then
                    stm:button_enter(this)
                end
            end

            function b.on_exit(this, drag_view)
                stm:button_exit(this)
            end
        end

        self:add_child(b)
    end

    self.pos = v(game_gui.sw * 0.5, game_gui.sh * 0.5)
    self.scale = v(0.6, 0.6)
    self.alpha = 0
    self.hidden = false
    self.tweening = true
    self.tweeners = {timer:tween(0.12, self.scale, {
        x = 1,
        y = 1
    }, "out-quad"), timer:tween(0.12, self, {
        alpha = 1
    }, "out-quad", function()
        self.tweening = nil
        self.tweeners = {}
    end)}

    S:queue("GUIQuickMenuOpen")
end

function CriketMenu:hide()
    if self.tweeners then
        for _, t in pairs(self.tweeners) do
            timer:cancel(t)
        end
    end

    self.tweening = true
    self.tweeners = {timer:tween(0.12, self, {
        alpha = 0
    }, "out-quad"), timer:tween(0.12, self.scale, {
        x = 0.6,
        y = 0.6
    }, "out-quad", function()
        self.hidden = true
        self.tweening = false
        self.tweeners = {}
    end)}
end

function CriketMenu:update(dt)
    CriketMenu.super.update(self, dt)

    if self.hidden then
        return
    end

    local store = game_gui.game.store

    for _, c in pairs(self.children) do
        if c:isInstanceOf(CriketMenuButton) and c.item_props then
            if c.item_props.action == "tw_upgrade" then
                local nt = E:get_template(c.item_props.action_arg)

                if nt.build_name then
                    nt = E:get_template(nt.build_name)
                end
            end
        end
    end
end

function CriketMenu:button_enter(button)
    if button.halo then
        button.halo.hidden = false
    end
end

function CriketMenu:button_exit(button)
    if button.halo then
        button.halo.hidden = true
    end
end

function CriketMenu:button_callback(button, item, entity, mouse_button, x, y)
    if item.action == "tw_upgrade" then
        local total_cost = 0
        for k, v in pairs(game_gui.game.store.towers) do
            local new_tower = E:create_entity(item.action_arg)
            game_gui.game.store.criket.tower_name = new_tower.template_name
            new_tower.pos = V.vclone(v.pos)
            new_tower.tower.holder_id = v.tower.holder_id
            new_tower.tower.flip_x = v.tower.flip_x
            if v.tower.default_rally_pos then
                new_tower.tower.default_rally_pos = V.vclone(v.tower.default_rally_pos)
            end
            if v.tower.terrain_style then
                new_tower.tower.terrain_style = v.tower.terrain_style
                new_tower.render.sprites[1].name =
                    string.format(new_tower.render.sprites[1].name, v.tower.terrain_style)
            end

            if new_tower.ui and v.ui then
                new_tower.ui.nav_mesh_id = v.ui.nav_mesh_id
            end
            queue_remove(game_gui.game.store, v)
            queue_insert(game_gui.game.store, new_tower)
            game_gui.game.store.towers[k] = new_tower
            if new_tower.powers then
                for _, p in pairs(new_tower.powers) do
                    p.level = p.max_level
                    p.changed = true
                end
            end
            if new_tower.template_name == "tower_sunray" then
                new_tower.powers.manual.level = 0
                new_tower.powers.manual.changed = nil
                new_tower.powers.auto.level = 1
                new_tower.powers.auto.changed = true
            end
            if new_tower.barrack then
                if game_gui.game.store.criket and game_gui.game.store.criket.on then
                    local path_index = game_gui.game.store.criket.groups[1].path_index
                    -- local nodes = P:nearest_nodes(new_tower.pos.x, new_tower.pos.y, {path_index}, {1}, true)
                    local nodes = P.paths[path_index][1]

                    local i = 1

                    while i <= #nodes and
                        not U.is_inside_ellipse(nodes[i], new_tower.pos, new_tower.barrack.rally_range) do
                        i = i + 1
                    end
                    if i > #nodes then
                        new_tower.barrack.rally_pos = V.vclone(new_tower.tower.default_rally_pos)
                    else
                        if i == 1 then
                            i = 2
                        end
                        new_tower.barrack.rally_pos = V.vclone(nodes[i - 1])
                    end
                else
                    new_tower.barrack.rally_pos = V.vclone(new_tower.tower.default_rally_pos)
                end
            end
            if new_tower.mercenary then
                for i = 1, new_tower.barrack.max_soldiers do
                    new_tower.barrack.soldiers[i] = E:create_entity(new_tower.barrack.soldier_type)
                    new_tower.barrack.soldiers[i].health.dead = true
                    new_tower.barrack.soldiers[i].id = -1
                end
            end
            if table.contains(GS.archer_towers, new_tower.template_name) then
                total_cost = total_cost + E:get_template("tower_archer_1").tower.price + E:get_template("tower_archer_2").tower.price +
                                 E:get_template("tower_archer_3").tower.price
            elseif table.contains(GS.mage_towers, new_tower.template_name) then
                total_cost = total_cost + E:get_template("tower_mage_1").tower.price + E:get_template("tower_mage_2").tower.price +
                                 E:get_template("tower_mage_3").tower.price
            elseif table.contains(GS.engineer_towers, new_tower.template_name) then
                total_cost = total_cost + E:get_template("tower_engineer_1").tower.price + E:get_template("tower_engineer_2").tower.price +
                                 E:get_template("tower_engineer_3").tower.price
            elseif table.contains(GS.barrack_towers, new_tower.template_name) then
                total_cost = total_cost + E:get_template("tower_barrack_1").tower.price + E:get_template("tower_barrack_2").tower.price +
                                 E:get_template("tower_barrack_3").tower.price
            end
            total_cost = total_cost + new_tower.tower.price
            for _, p in pairs(new_tower.powers) do
                total_cost = total_cost + p.price_base + p.price_inc * (p.max_level - 1)
            end
            if new_tower.mercenary then
                total_cost = total_cost + E:get_template(new_tower.barrack.soldier_type).unit.price
            end
        end
        local store = game_gui.game.store
        if store.criket.on and store.criket.gold_judge then
            store.config.enemy_health_multiplier = total_cost / store.criket.gold_base
        end
    end
    self:hide()
end

TowerMenu = class("TowerMenu", KImageView)

function TowerMenu:initialize()
    TowerMenu.super.initialize(self, "gui_ring")

    self.can_drag = false
    self.propagate_on_click = true
    self.propagate_on_down = true
    self.propagate_on_up = true
    self.propagate_on_enter = true
    self.anchor = v(self.size.x * 0.5, self.size.y * 0.5)
    self.clip = false
end

function TowerMenu:show()
    local entity = game_gui.selected_entity

    if not entity or not entity.tower then
        return
    end

    if entity.user_selection then
        entity.user_selection.menu_shown = true
    end

    game_gui:hide_tower_ranges()

    if entity.attacks and entity.attacks.range and not entity.attacks.hide_range then
        local range = entity.attacks.range
        local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x,
            entity.tower.range_offset.y)))

        game_gui:show_tower_range(ux, uy, range)
    end

    if not tower_menus[entity.tower.type] or not tower_menus[entity.tower.type][entity.tower.level] then
        log.debug("tower_menus[%s][%s] not found", entity.tower.type, entity.tower.level)

        self.hidden = true

        return
    end

    local tm = tower_menus[entity.tower.type][entity.tower.level]

    self:remove_children()

    for _, item in pairs(tm) do
        if item.action == "tw_upgrade" and game_gui.game.store.level.locked_towers and
            table.contains(game_gui.game.store.level.locked_towers, item.action_arg) and not DEBUG_UNLOCK_ALL_TOWERS then
            local b = KImageView:new("main_icons_0014")

            b.pos = V.vclone(data.tower_menu_button_places[item.place])
            b.pos.x, b.pos.y = b.pos.x - b.size.x * 0.5, b.pos.y - b.size.y * 0.5

            self:add_child(b)

            -- if table.contains(GS.kr3_towers, entity.tower.type) then
            --     local bo = KImageView:new("kr3_main_icons_over")

            --     bo.pos = v(math.floor(-0.5 * (bo.size.x - b.size.x)), math.floor(-0.5 * (bo.size.y - b.size.y)))
            --     bo.propagate_on_click = true
            --     bo.disabled_tint_color = nil

            --     b:add_child(bo)
            -- end
        elseif item.action == "tw_sell" and entity.tower and not entity.tower.can_be_sold then
            -- block empty
        else
            local b = TowerMenuButton:new(item, entity)

            b.pos = V.vclone(data.tower_menu_button_places[item.place])
            b.pos.x, b.pos.y = b.pos.x - b.size.x * 0.5, b.pos.y - b.size.y * 0.5
            b.item_props = item

            local stm = self

            if item.action == "tw_none" then
                b:disable()
            else
                function b.on_click(this, button, x, y)
                    log.debug("CLICK")

                    if not self.tweening and not this.click_disabled then
                        stm:button_callback(this, item, entity, button, x, y)
                    end
                end

                function b.on_enter(this, drag_view)
                    if not self.tweening then
                        stm:button_enter(this, item, entity, button)
                    end
                end

                function b.on_exit(this, drag_view)
                    stm:button_exit(this, item, entity, button)
                end
            end

            self:add_child(b)
        end
    end

    if self.tweeners then
        for _, t in pairs(self.tweeners) do
            timer:cancel(t)
        end
    end

    local ro = entity.tower.range_offset
    local mo = entity.tower.menu_offset
    local ewx, ewy = game_gui:g2u(V.v(entity.pos.x + ro.x + mo.x, entity.pos.y + ro.y + mo.y), true)

    self.pos = v(ewx, ewy)
    self.scale = v(0.6, 0.6)
    self.alpha = 0
    self.hidden = false
    self.tweening = true
    self.tweeners = {timer:tween(0.12, self.scale, {
        x = 1,
        y = 1
    }, "out-quad"), timer:tween(0.12, self, {
        alpha = 1
    }, "out-quad", function()
        self.tweening = nil
        self.tweeners = {}
    end)}

    signal.emit("tower-menu-showing")
    S:queue("GUIQuickMenuOpen")
end

function TowerMenu:hide()
    local entity = game_gui.selected_entity

    if entity and entity.user_selection then
        entity.user_selection.menu_shown = nil
    end

    if self.tweeners then
        for _, t in pairs(self.tweeners) do
            timer:cancel(t)
        end
    end

    self.tweening = true
    self.tweeners = {timer:tween(0.12, self, {
        alpha = 0
    }, "out-quad"), timer:tween(0.12, self.scale, {
        x = 0.6,
        y = 0.6
    }, "out-quad", function()
        self.hidden = true
        self.tweening = false
        self.tweeners = {}
    end)}

    game_gui:hide_tower_ranges()
    game_gui.towertooltip:hide()
    signal.emit("tower-menu-hiding")
end

function TowerMenu:update(dt)
    TowerMenu.super.update(self, dt)

    if self.hidden then
        return
    end

    local e = game_gui.selected_entity

    if not e or not e.tower then
        return
    end

    local store = game_gui.game.store

    for _, c in pairs(self.children) do
        if c:isInstanceOf(TowerMenuButton) and c.item_props then
            if c.item_props.action == "tw_point" and e and e.user_selection then
                if not e.user_selection.allowed then
                    c:disable()
                else
                    c:enable()
                end
            elseif e and c.item_props.action == "tw_upgrade" then
                local nt = E:get_template(c.item_props.action_arg)

                if nt.build_name then
                    nt = E:get_template(nt.build_name)
                end

                if nt.tower.price > store.player_gold then
                    c:disable()
                else
                    c:enable()
                end
            elseif e and c.item_props.action == "tw_unblock" then
                if e.tower_holder.unblock_price > store.player_gold then
                    c:disable()
                else
                    c:enable()
                end
            elseif e and c.item_props.action == "upgrade_power" then
                local power = e.powers[c.item_props.action_arg]
                local price = power.level == 0 and power.price_base or power.price_inc

                if price > store.player_gold and power.level < power.max_level then
                    c:disable()
                else
                    c:enable()
                end

                local pt = c:get_child_by_id("price_tag")

                if pt then
                    pt.text = tostring(price)
                    pt.hidden = power.level == power.max_level
                end
            elseif e and c.item_props.action == "tw_buy_soldier" then
                local nt = E:get_template(c.item_props.action_arg)
                local price = nt.unit.price

                if price > store.player_gold or #e.barrack.soldiers >= e.barrack.max_soldiers then
                    c:disable()
                else
                    c:enable()
                end

                local pt = c:get_child_by_id("price_tag")

                if pt then
                    pt.text = tostring(price)
                    pt.hidden = false
                end
            elseif e and c.item_props.action == "tw_buy_attack" then
                local price = e.attacks.list[c.item_props.action_arg].price

                if price > store.player_gold then
                    c:disable()
                else
                    c:enable()
                end

                local pt = c:get_child_by_id("price_tag")

                if pt then
                    pt.text = tostring(price)
                    pt.hidden = false
                end
            elseif e and c.item_props.action == "tw_change_mode" then
                local current_mode = e.tower_upgrade_persistent_data.current_mode

                if current_mode ~= 0 then
                    c.button:set_image(U.str_reset_leading_zero(c.item_image, current_mode))
                else
                    c.button:set_image(c.item_image)
                end
            elseif e and c.item_props.action == "tw_free_action" then
                local usa = e.user_selection and e.user_selection.actions

                if usa and usa.tw_free_action then
                    if not usa.tw_free_action.allowed then
                        c:disable()
                    else
                        c:enable()
                    end
                elseif not e.user_selection.allowed then
                    c:disable()
                else
                    c:enable()
                end
            end
        end
    end

    if e and e.attacks and e.attacks.range and not game_gui.tower_range.hidden and game_gui.tower_range.range_shown ~=
        e.attacks.range then
        local ux, uy = game_gui:g2u(V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y)), true)

        game_gui:show_tower_range(ux, uy, e.attacks.range)

        if not game_gui.tower_range_upgrade.hidden and e.template_name == "tower_crossbow" then
            if e.powers.eagle.level < 3 then
                local m = E:get_template("mod_crossbow_eagle")
                local factor = e.powers.eagle.level < 1 and m.range_factor + m.range_factor_inc or 1 +
                                   m.range_factor_inc
                local range = e.attacks.range * factor

                game_gui:show_tower_range_upgrade(ux, uy, range)
            else
                game_gui:hide_tower_range_upgrade()
            end
        end
    end
end

function TowerMenu:button_enter(button, item, entity, mouse_button)
    log.debug("")

    if button.halo then
        button.halo.hidden = false
    end

    if item.action == "tw_upgrade" then
        local nt

        if item.preview then
            local tb = E:get_template(item.action_arg)

            nt = E:get_template(tb.build_name)
        else
            nt = E:get_template(item.action_arg)
        end

        local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x,
            entity.tower.range_offset.y)), snap)

        if nt and nt.attacks and nt.attacks.range then
            local new_range = nt.attacks.range

            if entity.template_name ~= "tower_crossbow" then
                local mods = table.filter(game_gui.game.store.entities, function(k, m)
                    return m.template_name == "mod_crossbow_eagle" and m.modifier.target_id == entity.id
                end)

                if #mods == 1 and mods[1].modifier then
                    local m = mods[1]

                    new_range = new_range * (m.range_factor + m.modifier.level * m.range_factor_inc)
                end

                log.debug("range:%s new_range:%s eagle mods: %s", nt.attacks.range, new_range, #mods)
            end

            game_gui:show_tower_range_upgrade(ux, uy, new_range)
        elseif nt.barrack and nt.barrack.rally_range then
            game_gui:show_rally_range(ux, uy, nt.barrack.rally_range)
        end
    elseif item.action == "upgrade_power" and entity.template_name == "tower_crossbow" and item.action_arg == "eagle" and
        entity.powers.eagle.level < 3 then
        local new_range = entity.attacks.range
        local mods = table.filter(game_gui.game.store.entities, function(k, m)
            return m.template_name == "mod_crossbow_eagle" and m.modifier.target_id == entity.id
        end)

        if #mods == 1 and mods[1].modifier and mods[1].modifier.level > entity.powers.eagle.level then
            -- block empty
        else
            local m = E:get_template("mod_crossbow_eagle")
            local factor = entity.powers.eagle.level < 1 and m.range_factor + m.range_factor_inc or 1 +
                               m.range_factor_inc

            new_range = new_range * factor
        end

        local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x,
            entity.tower.range_offset.y)))

        log.debug("range:%s factor:%s", new_range, factor)
        game_gui:show_tower_range_upgrade(ux, uy, new_range)
    end

    if item.preview then
        local preview_ids = entity.tower_holder.preview_ids
        local preview_id = preview_ids[item.preview]
        local s = entity.render.sprites[preview_id]
        if s then
            s.hidden = false
        end
    end

    game_gui.towertooltip:show(entity, item)

    if entity.ui then
        entity.ui.hover_active = true
        entity.ui.args = item.action_arg
    end
end

function TowerMenu:button_exit(button, item, entity, mouse_button)
    log.debug("")

    if button.halo then
        button.halo.hidden = true
    end

    game_gui:hide_tower_range_upgrade()
    game_gui.towertooltip:hide()

    if game_gui.mode ~= GUI_MODE_RALLY_TOWER then
        game_gui:hide_rally_range()
    end

    if item.preview then
        local preview_ids = entity.tower_holder.preview_ids
        local preview_id = preview_ids[item.preview]
        local s = entity.render.sprites[preview_id]
        if s then
            s.hidden = true
        end
    end

    if entity.ui then
        entity.ui.hover_active = nil
        entity.ui.args = nil
    end
end

function TowerMenu:button_callback(button, item, entity, mouse_button, x, y)
    log.debug("BUTTON CALLBACK action:%s entity:%s", item.action, entity.id)
    button:disable()

    local inhibit_sounds = false

    local e = game_gui.selected_entity

    if item.action == "tw_rally" then
        game_gui:set_mode(GUI_MODE_RALLY_TOWER)

        local ux, uy = game_gui:g2u(V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y)))

        game_gui:show_rally_range(ux, uy, e.barrack.rally_range)
        self:hide()
    elseif item.action == "tw_point" then
        if e.user_selection then
            e.user_selection.in_progress = true
            e.user_selection.new_pos = nil
        end

        game_gui:set_mode(GUI_MODE_SELECT_POINT)

        local ux, uy = game_gui:g2u(e.pos)

        self:hide()
    elseif item.action == "tw_upgrade" or item.action == "tw_unblock" then
        entity.tower.upgrade_to = item.action_arg
        signal.emit("tower-built")
        game_gui:deselect_entity()
    elseif item.action == "upgrade_power" then
        local power = entity.powers[item.action_arg]

        if power.level < power.max_level then
            power.level = power.level + 1
            power.changed = true

            if not item.no_upgrade_lights then
                for i, pv in ipairs(button.power_buttons) do
                    if i == power.level then
                        pv:set_image("power_rank_0001")
                    end
                end

                button.ufx.hidden = false
                button.ufx.ts = 0
            end

            local store = game_gui.game.store
            local spent

            if power.level == 1 then
                spent = power.price_base
            else
                spent = power.price_inc
            end

            store.player_gold = store.player_gold - spent
            entity.tower.spent = entity.tower.spent + spent

            game_gui.towertooltip:show(entity, item)

            if power.level >= power.max_level and button.halo then
                button:remove_child(button.halo)

                button.halo = nil
            end

            signal.emit("tower-power-upgraded", entity, power)
        else
            inhibit_sounds = true
        end
    elseif item.action == "tw_sell" then
        entity.tower.sell = true

        game_gui:deselect_entity()
    elseif item.action == "tw_buy_soldier" then
        entity.barrack.unit_bought = item.action_arg

        game_gui:deselect_entity()
    elseif item.action == "tw_buy_attack" then
        if e.user_selection then
            if e.user_selection.ignore_point then
                e.user_selection.arg = item.action_arg

                game_gui:deselect_entity()
            else
                e.user_selection.in_progress = true
                e.user_selection.arg = item.action_arg
                e.user_selection.new_pos = nil

                game_gui:set_mode(GUI_MODE_SELECT_POINT)
                self:hide()
            end
        else
            game_gui:deselect_entity()
        end
    elseif item.action == "tw_change_mode" then
        if e.tower then
            local current_mode = e.tower_upgrade_persistent_data.current_mode
            local max_current_mode = e.tower_upgrade_persistent_data.max_current_mode
            e.change_mode = true

            game_gui:deselect_entity()

            if current_mode >= max_current_mode then
                e.tower_upgrade_persistent_data.current_mode = 0
            else
                e.tower_upgrade_persistent_data.current_mode = current_mode + 1
            end
        end
    elseif item.action == "tw_free_action" then
        if e.user_selection then
            e.user_selection.in_progress = true
            e.user_selection.arg = item.action_arg
            e.user_selection.new_pos = nil
        end

        self:hide()
    end

    if item.sounds and not inhibit_sounds then
        for _, sid in pairs(item.sounds) do
            S:queue(sid)
        end
    end
end

TowerMenuTooltip = class("TowerMenuTooltip", KImageView)

function TowerMenuTooltip:initialize()
    TowerMenuTooltip.super.initialize(self, "tooltip_bg_standard")

    local margin = v(10, 14)
    local title = GGLabel:new(V.v(self.size.x - 2 * margin.x, 16))

    title.pos = v(margin.x, margin.y + CJK(0, -2, nil, nil))
    title.font_name = "h"
    title.font_size = 12.8
    title.colors.text = {205, 245, 55}
    title.text_align = "left"
    title.text = "ARCHER TOWER"
    title.fit_lines = 1
    self.title = title

    self:add_child(title)

    local desc = GGLabel:new(V.v(self.size.x - 2 * margin.x, 74))

    desc.pos = v(margin.x, margin.y + 14)
    desc.font_name = "body"
    desc.font_size = 12.5
    desc.line_height = CJK(0.9, nil, 1.1, 0.9)
    desc.colors.text = {240, 230, 185}
    desc.text_align = "left"
    desc.text = "Archers ready to strike at your enemies from a distance."
    desc.fit_size = true
    self.desc = desc

    self:add_child(desc)

    local bottom_margin = 26
    local font_size = 10
    local text_offset = v(18, CJK(3, 1, 1, 1))
    local w2 = (self.size.x - margin.x) * 0.5
    local w3 = (self.size.x - margin.x) / 3
    local p12, p22 = margin.x * 0.5, margin.x * 0.5 + w2
    local p13, p23, p33 = margin.x * 0.5, margin.x * 0.5 + w3, margin.x * 0.5 + 2 * w3
    local damage_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0007")

    damage_label.pos = v(p13, self.size.y - bottom_margin)
    damage_label.font_name = "sans"
    damage_label.font_size = font_size
    damage_label.colors.text = {205, 245, 55}
    damage_label.text_offset = text_offset
    damage_label.text_align = "left"
    damage_label.text = "6-8"
    self.damage_label = damage_label

    self:add_child(damage_label)

    local cooldown_label = GGLabel:new(V.v(self.size.x * 0.5, 16), "tooltip_icons_0009")

    cooldown_label.pos = v(p23, self.size.y - bottom_margin)
    cooldown_label.font_name = "sans"
    cooldown_label.font_size = font_size
    cooldown_label.colors.text = {205, 245, 55}
    cooldown_label.text_offset = text_offset
    cooldown_label.text_align = "left"
    cooldown_label.text = "Average"
    self.cooldown_label = cooldown_label

    self:add_child(cooldown_label)

    local health_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0006")

    health_label.pos = v(p23, self.size.y - bottom_margin)
    health_label.font_name = "sans"
    health_label.font_size = font_size
    health_label.colors.text = {205, 245, 55}
    health_label.text_offset = text_offset
    health_label.text_align = "left"
    health_label.text = "100"
    self.health_label = health_label

    self:add_child(health_label)

    local armor_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0004")

    armor_label.pos = v(p33, self.size.y - bottom_margin)
    armor_label.font_name = "sans"
    armor_label.font_size = font_size
    armor_label.colors.text = {205, 245, 55}
    armor_label.text_offset = text_offset
    armor_label.text_align = "left"
    armor_label.text = "Medium"
    self.armor_label = armor_label

    self:add_child(armor_label)

    local phrase_label = GGLabel:new(V.v(self.size.x - 2 * margin.x, 16))

    phrase_label.pos = v(margin.x, self.size.y - 22)
    phrase_label.font_name = "sans"
    phrase_label.font_size = font_size
    phrase_label.colors.text = {170, 160, 125}
    phrase_label.text_align = "left"
    self.phrase_label = phrase_label

    self:add_child(phrase_label)
end

function TowerMenuTooltip:set_template(template)
    return
end

function TowerMenuTooltip:show(entity, item)
    self.hidden = false
    self.damage_label.hidden = true
    self.health_label.hidden = true
    self.armor_label.hidden = true
    self.cooldown_label.hidden = true
    self.phrase_label.hidden = true

    if item.action == "tw_upgrade" then
        self.title.text = item.tt_title or U.balance_format(_(item.action_arg))
        self.desc.text = U.balance_format(item.tt_desc) or ""

        local te

        if entity.tower_holder then
            te = E:get_template(item.action_arg)

            if te and te.build_name then
                te = E:get_template(te.build_name)
            end
        else
            te = E:get_template(item.action_arg)
        end

        local stats = te.info.fn(te)

        if stats.type == STATS_TYPE_TOWER_BARRACK then
            self.damage_label.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

            self.damage_label:set_image("tooltip_icons_0007", V.v(self.damage_label.size.x, self.damage_label.size.y))

            self.health_label.text = stats.hp_max
            self.armor_label.text = GU.armor_value_desc(stats.armor)
            self.damage_label.hidden = false
            self.health_label.hidden = false
            self.armor_label.hidden = false
        elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE then
            self.damage_label.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

            self.damage_label:set_image(stats.type == STATS_TYPE_TOWER_MAGE and "tooltip_icons_0010" or
                                            "tooltip_icons_0007",
                V.v(self.damage_label.size.x, self.damage_label.size.y))

            self.cooldown_label.text = GU.cooldown_value_desc(stats.cooldown)
            self.damage_label.hidden = false
            self.cooldown_label.hidden = false
        end
    elseif item.action == "upgrade_power" then
        if item.tt_phrase then
            self.phrase_label.text = item.tt_phrase
            self.phrase_label.hidden = false

            self.phrase_label:do_fit_lines(1, 10, 0.15)
        end

        local power = entity.powers[item.action_arg]
        local show_level = km.clamp(1, power.max_level, power.level + 1)
        if show_level > #item.tt_list then
            show_level = #item.tt_list
        end
        local texts = item.tt_list[show_level]

        self.title.text = texts.tt_title
        self.desc.text = U.balance_format(texts.tt_desc)

        if power.level == power.max_level then
            -- self.hidden = true
        end
    elseif item.action == "tw_buy_soldier" or item.action == "tw_buy_attack" or item.action == "tw_unblock" or item.action == "tw_free_action" then
        if item.tt_title then
            self.title.text = item.tt_title
        end

        if item.tt_desc then
            self.desc.text = U.balance_format(item.tt_desc)
        end
    elseif item.action == "tw_sell" then
        self.title.text = _("Sell Tower")

        local refund = game_gui.game.store.wave_group_number == 0 and entity.tower.spent or
                           km.round(entity.tower.refund_factor * entity.tower.spent)

        self.desc.text = string.format(_("Sell this tower and get a %s GP refund."), refund)
    elseif item.action == "tw_change_mode" then
        local current_mode = entity.tower_upgrade_persistent_data.current_mode

        self.title.text = item["tt_title_mode" .. current_mode]
        self.desc.text = item["tt_desc_mode" .. current_mode]
    else
        self.hidden = true
    end

    if not self.hidden then
        local no_bottom_label = self.damage_label.hidden and self.health_label.hidden and self.armor_label.hidden and
                                    self.cooldown_label.hidden and self.phrase_label.hidden

        self.title:do_fit_lines()
        self.desc:do_fit_lines()
        self.damage_label:do_fit_lines()

        local width, lines = self.desc:get_wrap_lines()

        if self.title:get_font_height() + self.desc:get_font_height() * lines +
            (no_bottom_label and 0 or self.damage_label:get_font_height()) < 73 then
            self:set_image("tooltip_bg_small")
        else
            self:set_image("tooltip_bg_standard")
        end

        for _, v in pairs({self.damage_label, self.cooldown_label, self.health_label, self.armor_label}) do
            v.pos.y = self.size.y - 26
        end

        self.phrase_label.pos.y = self.size.y - 22
    end

    local oy = 126
    local ex, ey = game_gui:g2u(V.v(entity.pos.x, entity.pos.y), true)

    self.pos.x = ex - math.floor(self.size.x * 0.5)
    self.pos.y = ey - self.size.y - oy - 20

    if self.pos.y < self.size.y / 3 then
        self.pos.y = ey + 76
    end
end

function TowerMenuTooltip:hide()
    self.hidden = true
end

TowerMenuButton = class("TowerMenuButton", KView)

function TowerMenuButton:enable()
    self.click_disabled = false

    self.button:set_image(self.item_image)
    self.button:enable()
    if self.price_tag then
        self.price_tag:set_image("price_tag")
        self.price_tag:enable()
        self.price_tag.colors.text = {255, 224, 0}
    end
end

function TowerMenuButton:disable()
    self.click_disabled = true

    if self.item.action ~= "tw_change_mode" and self.item.action ~= "tw_swap_mode" then
        --self.button:set_image(self.item_image .. "_disabled")
        self.button:disable()
        if self.price_tag then
            -- self.price_tag:set_image("price_tag_disabled")
            self.price_tag:disable()
            self.price_tag.colors.text = {156, 146, 132}
        end
    end
end

function TowerMenuButton:initialize(item, entity)
    TowerMenuButton.super.initialize(self)

    self.item_image = item.image
    self.item = item
    self.entity = entity

    local b = KImageView:new(item.image)
    b.pos = v(0, 0)

    b.propagate_on_click = true
    -- b.disabled_tint_color = nil
    self.button = b

    self:add_child(b)

    local function get_pos(this, offset)
        offset = offset or v(0, 0)
        local x = math.floor(-0.5 * (this.size.x - b.size.x) + offset.x)
        local y = math.floor(-0.5 * (this.size.y - b.size.y) + offset.y)

        return v(x, y)
    end

    local function create_bo_view(img_name)
        local bo = KImageView:new(img_name)

        bo.pos = get_pos(bo)
        bo.propagate_on_click = true

        self:add_child(bo, 2)

        return bo
    end

    local halo = KImageView:new(item.halo)

    if item.halo == "glow_ico_sell" then
        halo.pos = v(-2.5, -3.5)
    else
        halo.pos = get_pos(halo)
    end

    halo.propagate_on_click = true
    halo.hidden = true
    self.halo = halo

    self:add_child(halo)

    local bo

    if item.action == "upgrade_power" then
        bo = create_bo_view("special_icons_0000")
    elseif table.contains({ "tw_upgrade", "tw_buy_soldier", "tw_buy_attack" }, item.action) then
        bo = create_bo_view("main_icons_0000")
    end

    local price_tag

    if item.action == "tw_upgrade" then
        local nt = E:get_template(item.action_arg)

        if nt.build_name then
            nt = E:get_template(nt.build_name)
        end

        price_tag = tostring(nt.tower.price)
    elseif item.action == "tw_unblock" then
        price_tag = tostring(entity.tower_holder.unblock_price)
    elseif item.action == "upgrade_power" then
        local power = entity.powers[item.action_arg]
        local price = power.level == 0 and power.price_base or power.price_inc

        if power.level == power.max_level then
            -- block empty
        end

        price_tag = tostring(price)
    elseif item.action == "tw_buy_soldier" then
        local nt = E:get_template(item.action_arg)

        price_tag = tostring(nt.unit.price)
    elseif item.action == "tw_buy_attack" then
        price_tag = ""
    end

    if price_tag then
        local pt = GGLabel:new(nil, "price_tag")

        pt.id = "price_tag"
        pt.pos = V.v(b.size.x * 0.5 - pt.size.x * 0.5, b.size.y - 11)
        pt.text_algin = "center"
        pt.text_offset.y = CJK(5, 2, 7, 3)
        pt.font_name = "body"
        pt.font_size = 11
        pt.colors.text = {255, 224, 0}
        pt.disabled_tint_color = nil
        pt.propagate_on_click = true
        pt.text = price_tag
        self.price_tag = pt

        self:add_child(pt)
    end

    if item.action == "upgrade_power" then
        local power = entity.powers[item.action_arg]

        if not item.no_upgrade_lights then
            self.power_buttons = {}

            for i = 1, power.max_level do
                local pv

                if i > power.level then
                    pv = KImageView:new("power_rank_0002")
                else
                    pv = KImageView:new("power_rank_0001")
                end

                pv.pos = get_pos(pv, V.vclone(data.tower_menu_power_offset[i]))
                pv.pos.x, pv.pos.y = pv.pos.x - pv.size.x * 0.5, pv.pos.y - pv.size.y * 0.5
                pv.disabled_tint_color = nil
                pv.propagate_on_click = true

                bo:add_child(pv)
                table.insert(self.power_buttons, pv)
            end
        end

        if power.level >= power.max_level then
            self:remove_child(self.halo)

            self.halo = nil
        end
    end

    local ufx = KImageView:new("effect_powerbuy_0001")

    ufx.animation = {
        to = 23,
        prefix = "effect_powerbuy",
        from = 1
    }
    ufx.pos = get_pos(ufx)
    ufx.hidden = true
    ufx.propagate_on_click = true
    self.ufx = ufx

    self:add_child(ufx)

    self.size = V.vclone(b.size)
end

IncomingTooltip = class("IncomingTooltip", KView)

function IncomingTooltip:initialize()
    IncomingTooltip.super.initialize(self, V.v(200, 90))

    self.colors.background = {21, 17, 13, 220}

    local aw, ah = 18, 24
    local arrow = KView:new(V.v(aw, ah))

    arrow.shape = {
        name = "polygon",
        args = {"fill", {0, ah, aw, ah * 0.5, aw * 0.5, ah * 0.5, aw * 0.5, 0}}
    }
    arrow.colors.background = self.colors.background
    arrow.anchor = V.v(aw * 0.5, ah * 0.5)

    self:add_child(arrow)

    local title = GGLabel:new(V.v(180, 30))

    title.text = _("INCOMING WAVE")
    title.font_name = "h"
    title.font_size = 14
    title.text_align = "center"
    title.colors.text = {255, 115, 55, 255}

    local report = GGLabel:new(V.v(180, 90))

    report.font_name = "body"
    report.font_size = 12
    report.text_align = "center"
    report.colors.text = {255, 245, 210, 255}
    title.pos.x, title.pos.y = 0, 10
    report.pos.x, report.pos.y = 0, 30

    self:add_child(title)
    self:add_child(report)

    self.arrow = arrow
    self.title = title
    self.report = report
end

function IncomingTooltip:set_report(text)
    self.report.text = text

    local title_w = self.title:get_text_width(self.title.text)
    local report_w = self.report:get_text_width(text)
    local w = math.max(title_w, report_w) + 40

    self.report.size.x = w
    self.title.size.x = w
    self.size.x = w

    local width, lines = self.report:get_wrap_lines()
    local height = lines * self.report:get_font_height()

    self.size.y = 40 + height + 10
end

function IncomingTooltip:show(x, y, r, report)
    self:set_report(report)

    local arrow = self.arrow
    local a_w, a_h = arrow.anchor.x, arrow.size.y - arrow.anchor.y
    local a = km.unroll(r)
    local offset = 15

    if x > 1.5 * self.size.x then
        arrow.pos.x = self.size.x
        arrow.scale.x = -1
        self.pos.x = x - self.size.x - a_w - offset
    else
        arrow.pos.x = 0
        arrow.scale.x = 1
        self.pos.x = x + a_w + offset
    end

    if y < 3 * self.size.y then
        arrow.pos.y = 0
        arrow.scale.y = -1
        self.pos.y = y + a_h + offset
    else
        arrow.pos.y = self.size.y
        arrow.scale.y = 1
        self.pos.y = y - self.size.y - a_h - offset
    end

    self.pos.x, self.pos.y = V.csnap(self.pos.x, self.pos.y)

    if self.timer then
        timer:cancel(self.timer)
    end

    self.hidden = false
    self.alpha = 0
    self.timer = timer:tween(0.25, self, {
        alpha = 1
    }, "out-quad")
end

function IncomingTooltip:hide()
    if self.timer then
        timer:cancel(self.timer)
    end

    self.timer = timer:tween(0.25, self, {
        alpha = 0
    }, "out-quad", function()
        self.hidden = true
    end)
end

function IncomingTooltip:update(dt)
    if not self.hidden and game_gui.mode ~= GUI_MODE_IDLE and game_gui.mode ~= GUI_MODE_WAVE_FLAG then
        self.hidden = true
    end
end

WaveFlag = class("WaveFlag", KView)

function WaveFlag:initialize(flying, duration, report, path_index)
    WaveFlag.super.initialize(self)
    self.path_index = path_index
    self.duration = duration
    self.report = report
    self.start_game_ts = game_gui.game.store.tick_ts
    self.ts = 0
    self.pulse_animation = true

    local halo = KImageView:new("nextwaveTimer_glow_0001")
    local bg_circle = KImageView:new("nextwaveTimer_Full")
    local circle = KImageView:new("nextwaveTimer_0001")
    local icon = KImageView:new(flying and "nextwaveTimer_0003" or "nextwaveTimer_0002")
    local pointer = KImageView:new("nextwaveTimer_0020")

    self.size.x, self.size.y = halo.size.x, halo.size.y
    self.anchor.x, self.anchor.y = self.size.x * 0.5, self.size.y * 0.5

    local hrs = 0.25

    self.hit_rect = V.r(hrs * self.size.x, hrs * self.size.y, (1 - 2 * hrs) * self.size.x, (1 - 2 * hrs) * self.size.y)

    for _, v in pairs({halo, bg_circle, circle, icon}) do
        v.anchor.x, v.anchor.y = v.size.x * 0.5, v.size.y * 0.5
    end

    pointer.anchor.x, pointer.anchor.y = pointer.size.x * 0.5, pointer.size.y

    for _, v in pairs({halo, bg_circle, circle, icon, pointer}) do
        v.pos.x, v.pos.y = self.size.x * 0.5, self.size.y * 0.5
        v.propagate_on_click = true

        self:add_child(v)
    end

    halo.hidden = true
    pointer.r = -math.pi * 0.5
    bg_circle.phase = 0
    bg_circle.clip = true

    function bg_circle.clip_fn()
        local start_angle = 3 * math.pi * 0.5
        local stop_angle = 7 * math.pi * 0.5 - bg_circle.phase * 2 * math.pi

        G.arc("fill", bg_circle.size.x * 0.5, bg_circle.size.y * 0.5, bg_circle.size.x * 0.5, start_angle, stop_angle,
            12)
    end

    self.halo = halo
    self.bg_circle = bg_circle
    self.pointer = pointer
end

function WaveFlag:on_click()
    log.debug(">>> sending next wave...")
    self:disable()

    self.clicked = true
    game_gui.game.store.send_next_wave = true
end

function WaveFlag:on_enter()
    self.halo.hidden = false

    game_gui.incoming_tooltip:show(self.pos.x, self.pos.y, self.pointer.r + math.pi * 0.5, self.report)

    game.shown_path = self.path_index
end

function WaveFlag:on_exit()
    self.halo.hidden = true
    game.shown_path = nil
    game_gui.incoming_tooltip:hide()
end

function WaveFlag:hide()
    self.pulse_animation = false

    self:disable()

    if not self.hide_timer then
        self.hide_timer = timer:tween(0.5, self, {
            alpha = 0,
            scale = {
                x = 1.5,
                y = 1.5
            }
        }, "out-quad", function()
            self.hidden = true

            self:remove_from_parent()
        end)
    end
end

function WaveFlag:update(dt)
    WaveFlag.super.update(self, dt)

    if self.pulse_animation then
        local scale = 0.85 + 0.15 * (0.5 * math.sin(2 * math.pi * self.ts * 1.25) + 1)

        self.scale.x, self.scale.y = scale, scale
    end

    if self.duration and self.duration > 0 then
        self.bg_circle.phase = km.clamp(0, 1, (self.duration - (game_gui.game.store.tick_ts - self.start_game_ts)) /
            self.duration)
    end

    if not self.clicked and not self.hide_timer then
        if game_gui.mode == GUI_MODE_IDLE or game_gui.mode == GUI_MODE_WAVE_FLAG then
            self:enable()

            self.alpha = 1
        else
            self:disable(false)

            self.alpha = 0.2
        end
    end
end

ItemRewardParticles = class("ItemRewardParticles", KView)

function ItemRewardParticles:initialize(scale)
    ItemRewardParticles.super.initialize(self)

    scale = scale or 1

    local ss = I:s("lives_particle")
    local p_scale = (ss.ref_scale or 1) * scale
    local c = G.newCanvas(ss.size[1], ss.size[2])

    G.setCanvas(c)
    G.draw(I:i(ss.atlas), ss.quad, ss.trim[1], ss.trim[2])
    G.setCanvas()

    local ps = G.newParticleSystem(c, 500)

    ps:setDirection(-math.pi * 0.5)
    ps:setSpread(2 * math.pi)
    ps:setSizes(1 * p_scale, 0.5 * p_scale)
    ps:setParticleLifetime(0, 0.8)
    ps:setSpeed(50 * scale, 300 * scale)
    ps:setRadialAcceleration(-50 * scale)
    ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    ps:emit(150)

    self.ps = ps

    timer:after(1, function()
        self.parent:remove_child(self)
        log.debug("remving particles :%s", self)
    end)
end

function ItemRewardParticles:update(dt)
    ItemRewardParticles.super.update(self, dt)
    self.ps:update(dt)
end

function ItemRewardParticles:draw()
    G.setBlendMode("add")
    G.draw(self.ps, 0, 0)
    G.setBlendMode("alpha")
    ItemRewardParticles.super.draw(self)
end

SelectItem = class("SelectItem", KButton)

function SelectItem:initialize(key_text, size)
    size = size or V.v(400, 80) -- 增加高度以容纳两行文本
    KButton.initialize(self, size)

    self.key = key_text
    self.on_change_callback = nil

    -- 标题标签（原来的key_label改为title_label）
    self.title_label = GGLabel:new(V.v(self.size.x - 20, 20))
    self.title_label.pos = V.v(15, 8)
    self.title_label.font_name = "body"
    self.title_label.font_size = 16
    self.title_label.text = key_text -- 直接使用key_text作为标题
    self.title_label.text_align = "left"
    self.title_label.vertical_align = "top"
    self.title_label.colors.text = {255, 255, 255, 255}
    self.title_label.colors.text_default = {255, 255, 255, 255}
    self.title_label.colors.text_hover = {255, 255, 100, 255}
    self.title_label.propagate_on_click = true

    -- 描述标签（新增）
    self.desc_label = GGLabel:new(V.v(self.size.x - 20, 40))
    self.desc_label.pos = V.v(15, 32)
    self.desc_label.font_name = "body"
    self.desc_label.font_size = 12
    self.desc_label.text = "" -- 描述文本稍后通过映射设置
    self.desc_label.text_align = "left"
    self.desc_label.vertical_align = "top"
    self.desc_label.colors.text = {180, 180, 180, 255}
    self.desc_label.colors.text_default = {180, 180, 180, 255}
    self.desc_label.colors.text_hover = {220, 220, 220, 255}
    self.desc_label.propagate_on_click = true

    self:add_child(self.title_label)
    self:add_child(self.desc_label)

    -- 设置初始状态
    self.value = false
    self:update_display()
end

function SelectItem:set_description(desc_text)
    self.desc_label.text = desc_text or ""
end

function SelectItem:update_display()
    if self.value then
        self.colors.background = {40, 40, 40, 200}
        self.title_label.colors.text = self.title_label.colors.text_hover
        self.desc_label.colors.text = self.desc_label.colors.text_hover
    else
        self.colors.background = {0, 0, 0, 0}
        self.title_label.colors.text = self.title_label.colors.text_default
        self.desc_label.colors.text = self.desc_label.colors.text_default
    end
end

function SelectItem:on_enter()
    self.colors.background = {60, 60, 60, 150}
    self.title_label.colors.text = self.title_label.colors.text_hover
    self.desc_label.colors.text = self.desc_label.colors.text_hover
end

function SelectItem:on_exit()
    self.colors.background = {0, 0, 0, 0}
    self.title_label.colors.text = self.title_label.colors.text_default
    self.desc_label.colors.text = self.desc_label.colors.text_default
    self:update_display()
end

function SelectItem:on_click()
    S:queue("GUIButtonCommon")
    self:toggle()
end

function SelectItem:toggle()
    self.value = not self.value
    self:update_display()

    if self.on_change_callback then
        self.on_change_callback(self.key, self.value)
    end
end

function SelectItem:set_false()
    self.value = false
    self:update_display()
end

-- 布尔值切换组类 - 管理多个布尔值项
SelectGroup = class("SelectGroup", KView)

function SelectGroup:initialize(size)
    size = size or V.v(400, 300)
    KView.initialize(self, size)
    self.key_label_map = {}
    self.items = {}
    self.item_height = 75
    self.padding = V.v(10, -5) -- 修正：使用向量表示水平和垂直内边距
    self.data = {}
end

function SelectGroup:set_key_label_map(map)
    self.key_label_map = map
end

function SelectGroup:add_item(key, initial_value)
    local item_count = 0
    for _ in pairs(self.items) do
        item_count = item_count + 1
    end

    local item_y = self.padding.y + item_count * self.item_height

    local display_text = self.key_label_map[key] or key
    local item = SelectItem:new(display_text, V.v(self.size.x - 2 * self.padding.x, 80))

    -- 设置描述文本
    if self.key_desc_map and self.key_desc_map[key] then
        item:set_description(self.key_desc_map[key])
    end

    item.pos = V.v(self.padding.x, item_y)
    item.on_change_callback = function(label, value)
        self.data[key] = value
        for k, v in pairs(self.data) do
            if k ~= key then
                self.data[k] = false
                if self.items[k] then
                    self.items[k]:set_false()
                end
            end
        end
    end

    self:add_child(item)
    self.items[key] = item
    self.data[key] = initial_value

    return item
end

function SelectGroup:set_key_desc_map(map)
    self.key_desc_map = map
end

function SelectGroup:get_value(key)
    return self.data[key]
end

function SelectGroup:get_all_data()
    return self.data
end

function SelectGroup:set_all_data(data)
    self.data = data
    for key, item in pairs(self.items) do
        self:remove_child(item)
    end
    self.items = {}
    for key, value in pairs(data) do
        if type(value) == "boolean" then
            self:add_item(key, value)
        end
    end
end

function SelectGroup:set_on_data_change_callback(callback)
    self.on_data_change_callback = callback
end

SelectPanelView = class("SelectPanelView", PopUpView)
function SelectPanelView:initialize(sw, sh, title)
    PopUpView.initialize(self, V.v(sw, sh))

    self.back = KImageView:new("options_bg_notxt")
    self.pos = v(0, 0)
    self.back.anchor = v(self.back.size.x * 0.5, self.back.size.y * 0.5)
    self.back.pos = v(sw * 0.5, sh * 0.5 - 50)
    self.header = title
    self:add_child(self.back)
    self.extra = false
    self.back.alpha = 1
    -- 添加标题
    local header = GGPanelHeader:new(self.header, 242)
    header.pos = V.v(135, 28)
    self.back:add_child(header)

    -- 创建配置组
    local data_group_width = 400
    self.data_group = SelectGroup:new(V.v(data_group_width, 300))
    self.data_group.pos = V.v((self.back.size.x - data_group_width) * 0.5, 120)

    -- 设置数据改变回调
    self.data_group:set_on_data_change_callback(function(key, value, all_data)
    end)

    self.back:add_child(self.data_group)

    -- 添加底部按钮
    local mx = 150
    local y = 420

    local b = GGOptionsButton:new(_("BUTTON_DONE"))
    b.anchor.x = b.size.x * 0.5
    b.pos = V.v(self.back.size.x * 0.5, y)

    function b.on_click()
        S:queue("GUIButtonCommon")
        self:save()
        self:hide()
    end

    self.done_button = b
    self.back:add_child(b)
end

function SelectPanelView:set_key_label_map(map)
    self.data_group:set_key_label_map(map)
end

function SelectPanelView:set_key_desc_map(map)
    self.data_group:set_key_desc_map(map)
end

function SelectPanelView:load()
    log.error("SelectPanelView:load not implemented")
end

function SelectPanelView:save()
    log.error("SelectPanelView:save not implemented")
end

function SelectPanelView:show(extra)
    if extra then
        self.extra = true
    else
        self.extra = false
    end
    self:load()
    SelectPanelView.super.show(self)
end

function SelectPanelView:hide()
    SelectPanelView.super.hide(self)
end

EndlessSelectRewardView = class("EndlessSelectRewardView", SelectPanelView)

function EndlessSelectRewardView:initialize(sw, sh)
    SelectPanelView.initialize(self, sw, sh, "选择奖励")
    self:set_key_label_map(EL.key_label_map)
    self:set_key_desc_map(EL.key_desc_map)
end

function EndlessSelectRewardView:load()
    -- 随机选择
    local selected = {}

    if self.extra then
        local count = 0
        while count < 3 do
            local choice = table.random(game_gui.game.store.endless.gold_extra_upgrade_options)
            if selected[choice] == nil then
                selected[choice] = false
                count = count + 1
            end
        end
    else
        local count = 0 -- 手动计数
        local upgrade_options = game_gui.game.store.endless.upgrade_options
        local max_count = math.min(3, #upgrade_options) -- 最大选择数量
        while count < max_count do
            local choice = upgrade_options[math.random(1, #upgrade_options)]
            if selected[choice] == nil then
                selected[choice] = false
                count = count + 1 -- 增加计数
            end
        end
    end

    self.data_group:set_all_data(selected)

    game_gui:disable_keys()
    game_gui:deselect_all()
    S:pause()
    game_gui.game.store.paused = true

    game_gui.overlay:show()
end

function EndlessSelectRewardView:save()
    local key
    for k, v in pairs(self.data_group:get_all_data()) do
        if v then
            key = k
            break
        end
    end

    local store = game_gui.game.store

    EU.patch_upgrade_in_game(key, store, store.endless)
    game_gui:enable_keys()
    S:resume()
    game_gui.game.store.paused = false
    game_gui.overlay:hide()
end

return game_gui
