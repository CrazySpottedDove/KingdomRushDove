-- 命令名 -> 实际调用的唯一映射表。
-- 新增测试只需要在这里加一行，不再去 main/director/game 里加 flag 分支。
local session = require("dove_modules.test.handlers.session")
local screen = require("dove_modules.test.handlers.screen")
local game = require("dove_modules.test.handlers.game")
local input = require("dove_modules.test.handlers.input")
local plugin = require("dove_modules.test.handlers.plugin")
local autoplay = require("dove_modules.test.handlers.autoplay")
local commands = {
	map = {
		-- 会话 / 时间
		ping = session.ping,
		status = session.status,
		snapshot = session.status,
		quit = session.quit,
		tick = session.tick,
		run_until = session.run_until,
		wait = session.wait,
		set_render = session.set_render,
		log_errors = session.log_errors,
		clear_log_errors = session.clear_log_errors,
		assert = session["assert"],
		assert_no_log_errors = session.assert_no_log_errors,
		-- 场景
		open_map = screen.open_map,
		open_level = screen.open_level,
		open_screen = screen.open_screen,
		back_to_map = screen.back_to_map,
		select_generation = screen.select_generation,
		snapshot_map = screen.snapshot_map,
		-- 地图界面语义命令
		click_upgrade_button = screen.click_upgrade_button,
		click_encyclopedia_button = screen.click_encyclopedia_button,
		click_hero_room_button = screen.click_hero_room_button,
		click_change_generation_button = screen.click_change_generation_button,
		click_spell_button = screen.click_spell_button,
		click_map_flag = screen.click_map_flag,
		click_level = screen.click_level,
		-- 局内语义命令
		configure = game.configure,
		click_next_wave = game.click_next_wave,
		force_next_wave = game.force_next_wave,
		set_lives = game.set_lives,
		set_gold = game.set_gold,
		set_speed = game.set_speed,
		build_tower = game.build_tower,
		build_all_towers = game.build_all_towers,
		upgrade_tower = game.upgrade_tower,
		sell_tower = game.sell_tower,
		get_tower_holders = game.get_tower_holders,
		get_entities = game.get_entities,
		cast_spell = game.cast_spell,
		autoplay_start = game.autoplay_start,
		autoplay_stop = game.autoplay_stop,
		set_auto_click = game.set_auto_click,
		set_force_boss = game.set_force_boss,
		report = game.report,
		-- autoplay 细粒度命令
		click_world_objects = function(harness)
			autoplay.run_clicks(harness)

			return {
				ok = true
			}
		end,
		force_boss_phases = function(harness)
			autoplay.force_boss_phases(harness)

			return {
				ok = true
			}
		end,
		-- 原始输入
		click_at = input.click_at,
		mouse_down = input.mouse_down,
		mouse_up = input.mouse_up,
		mouse_move = input.mouse_move,
		key = input.key,
		key_down = input.key_down,
		key_up = input.key_up,
		text = input.text,
		wheel = input.wheel,
		-- 插件验收
		plugins_load_all = plugin.plugins_load_all,
		plugin_load = plugin.plugin_load,
		plugin_level_test = plugin.plugin_level_test,
		open_custom_level = plugin.open_custom_level
	}
}

return commands
