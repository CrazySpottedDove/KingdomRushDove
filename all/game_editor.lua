-- Dove 版地图编辑器：提供给玩家自行编辑地图的功能！

local log = require("lib.klua.log"):new("game")
local storage = require("all.storage")
log:set_level("debug")

require("lib.klua.dump")

local km = require("lib.klua.macros")
local signal = require("lib.hump.signal")
local V = require("lib.klua.vector")
local F = require("lib.klove.font_db")
local simulation, A
local I = require("lib.klove.image_db")
local S = require("sound_db")
local E = require("entity_db")
local U = require("utils")
local RU = require("render_utils")
local E = require("entity_db")
local P = require("path_db")
local SU = require("screen_utils")
local GR = require("grid_db")
local LU = require("level_utils")
local GEU = require("game_editor_utils")
local sys = require("systems")
local W = require("wave_db")
local wave_gen_interface = require("dove_modules.wave_generator.interface")

simulation = require("simulation")
A = require("animation_db")

local EXO = require("all.exoskeleton")

if DEBUG then
	package.loaded.game_editor_gui = nil
end

local game_editor_gui = require("game_editor_gui")
local G = love.graphics
local bit = require("bit")
local band = bit.band

require("all.constants")

-- 网格地形底色（terrain type）
-- NONE: 黑, LAND: 绿, WATER: 蓝, CLIFF: 红
local GRID_TERRAIN_COLORS = {
	[TERRAIN_NONE] = {0, 0, 0, 255},
	[TERRAIN_LAND] = {0, 100, 0, 255},
	[TERRAIN_WATER] = {0, 0, 100, 255},
	[TERRAIN_CLIFF] = {100, 0, 0, 255}
}

-- 网格标签叠加色（terrain flags）
-- NOWALK: 红, SHALLOW: 浅蓝, FAERIE: 橙, ICE: 灰, FLYING_NOWALK: 紫
local GRID_FLAG_COLORS = {
	[TERRAIN_NOWALK] = {255, 64, 64},
	[TERRAIN_SHALLOW] = {80, 160, 255},
	[TERRAIN_FAERIE] = {255, 150, 80},
	[TERRAIN_ICE] = {200, 200, 200},
	[TERRAIN_FLYING_NOWALK] = {180, 80, 255}
}

BATCH_SIZE = 1000
DEFAULT_PATH_WIDTH = 40
editor = {}
-- 为了显示，加载这些纹理
editor.required_textures = {
	"tower_holders",
	"go_decals",
	"go_towers_group1",
	"go_editor",
	"go_towers_group2",
	"go_towers_group3",
	"go_towers_group4",
	"go_towers_group5",
	"go_towers_group6",
	"go_towers_pandas",
	"go_towers_dark_elf",
	"go_towers_tricannon",
	"go_towers_demon_pit",
	"go_towers_necromancer",
	"go_towers_ray",
	"go_towers_elven_stargazers",
	"go_towers_sand",
	"go_towers_royal_archers",
	"go_towers_arcane_wizard",
	"go_towers_rocket_gunners",
	"go_towers_flamespitter",
	"go_towers_ballista",
	"go_towers_barrel",
	"go_towers_hermit_toad",
	"go_towers_sparking_geode",
	"go_towers_dwarf",
	"go_towers_ghost",
	"go_towers_paladin_covenant",
	"go_towers_arborean_emissary",
	"go_towers_dragons",
	"kr4_dark_army_tower_archer",
	"kr4_rotten_forest_tower",
	"kr4_ember_lords_tower_mage",
	"kr4_warmongers_tower_mage",
	"kr4_fallen_ones_bone_flingers",
	"kr4_warmongers_tower_barrack",
	"kr4_dark_army_tower_barrack"
}
editor.ref_h = REF_H
editor.ref_w = REF_W
editor.ref_res = TEXTURE_SIZE_ALIAS.ipad
editor.simulation_systems = {"editor_overrides", "editor_script", "render", "last_hook"}

local function mode_suffix(mode)
	return GEU.mode_to_str(mode or GAME_MODE_CAMPAIGN)
end

local function wave_cfg_rel(level_name, mode)
	return string.format("game_editor/data/waveconfigs/%s_waves_%s_config.lua", level_name, mode_suffix(mode))
end

local function wave_rel(level_name, mode)
	return string.format("game_editor/data/waves/%s_waves_%s.lua", level_name, mode_suffix(mode))
end

local function load_lua_table_with_pref(path)
	local f = love.filesystem.loadWithPreference(path, {EDITOR_PATH, KR_PATH_GAME})
	if not f then
		return nil
	end
	local ok, data = pcall(f)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

local function sanitize_wave_config(raw)
	local ok, err = wave_gen_interface.validate_config(raw)
	if not ok then
		log.error("Invalid wave config, using default config instead: %s", err)
		return wave_gen_interface.config_default()
	end
	return raw
end

local function sanitize_wave_data(raw, fallback_cfg)
	local data = type(raw) == "table" and raw or nil
	if not data or type(data.groups) ~= "table" then
		data = {
			lives = fallback_cfg.lives,
			cash = fallback_cfg.cash,
			groups = {}
		}
		for _, group in ipairs(fallback_cfg.groups) do
			data.groups[#data.groups + 1] = wave_gen_interface.generate_group(group)
		end
		return data
	end
	data.lives = tonumber(data.lives) or fallback_cfg.lives
	data.cash = tonumber(data.cash) or fallback_cfg.cash
	return data
end

local function save_lua_table(path, data)
	local dir = path:match("(.+)/[^/]+$")
	if dir then
		love.filesystem.createDirectory(dir)
	end
	return storage:write_lua(path, data)
end

-- local CUSTOM_IMAGES_DIR = "game_editor/assets/images"
-- local CUSTOM_SOUNDS_DIR = "game_editor/assets/sounds"
-- local CUSTOM_IMPORT_BG = "background"
-- local CUSTOM_IMPORT_BATTLE = "battle_music"
-- local CUSTOM_IMPORT_BATTLE_PREP = "battle_prep_music"

-- local _texture_group_lookup = {}
-- local _animation_group_lookup = {}
-- local _sound_group_lookup = nil

-- local function ensure_custom_asset_dirs()
-- 	love.filesystem.createDirectory("game_editor/assets")
-- 	love.filesystem.createDirectory(CUSTOM_IMAGES_DIR)
-- 	love.filesystem.createDirectory(CUSTOM_SOUNDS_DIR)
-- end

-- local function sanitize_filename(name)
-- 	return (name or "asset"):gsub("[^%w%._%-]", "_")
-- end

-- local function strip_extension(filename)
-- 	return filename and (filename:match("(.+)%.[^.]+$") or filename) or "asset"
-- end

-- local function custom_resource_table(level_data)
-- 	level_data.custom_resources = level_data.custom_resources or {}
-- 	return level_data.custom_resources
-- end

-- local function custom_sound_id(level_name, kind)
-- 	return string.format("custom_%s_%s", level_name or "level", kind)
-- end

-- local function texture_group_lookup(texture_size)
-- 	local size = texture_size or TEXTURE_SIZE_ALIAS.fullhd
-- 	if _texture_group_lookup[size] then
-- 		return _texture_group_lookup[size]
-- 	end

-- 	local lookup = {}
-- 	local root = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. size
-- 	local ok, items = pcall(love.filesystem.getDirectoryItems, root)

-- 	if ok and items then
-- 		local selected = {}

-- 		for _, item in ipairs(items) do
-- 			local group

-- 			if item:match("%.luac$") then
-- 				group = item:gsub("%.luac$", "")
-- 				selected[group] = selected[group] or item
-- 			elseif item:match("%.aluac$") then
-- 				group = item:gsub("%.aluac$", "")
-- 				selected[group] = selected[group] or item
-- 			elseif item:match("%.lua$") then
-- 				group = item:gsub("%.lua$", "")
-- 				selected[group] = selected[group] or item
-- 			end
-- 		end

-- 		for group, item in pairs(selected) do
-- 			local chunk = love.filesystem.load(root .. "/" .. item)
-- 			if chunk then
-- 				local ok_info, info = pcall(chunk)
-- 				if ok_info and type(info) == "table" then
-- 					if info.count and info.keys and info.values then
-- 						for i = 1, info.count do
-- 							local key = info.keys[i]
-- 							local value = info.values[i]

-- 							lookup[key] = group
-- 							if value and value[6] then
-- 								for _, alias in ipairs(value[6]) do
-- 									lookup[alias] = group
-- 								end
-- 							end
-- 						end
-- 					else
-- 						for key, value in pairs(info) do
-- 							lookup[key] = group
-- 							if value and value.alias then
-- 								for _, alias in ipairs(value.alias) do
-- 									lookup[alias] = group
-- 								end
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	_texture_group_lookup[size] = lookup
-- 	return lookup
-- end

-- local function sound_group_lookup()
-- 	if _sound_group_lookup then
-- 		return _sound_group_lookup
-- 	end

-- 	local lookup = {}

-- 	for group_name, group in pairs(S.groups or {}) do
-- 		if group.sounds then
-- 			for _, sound_id in pairs(group.sounds) do
-- 				lookup[sound_id] = lookup[sound_id] or {}
-- 				lookup[sound_id][group_name] = true
-- 			end
-- 		end
-- 	end

-- 	_sound_group_lookup = lookup
-- 	return lookup
-- end

-- local function animation_group_lookup(texture_lookup)
-- 	if _animation_group_lookup[texture_lookup] then
-- 		return _animation_group_lookup[texture_lookup]
-- 	end

-- 	A:load()

-- 	local lookup = {}

-- 	for animation_name, animation in pairs(A.db or {}) do
-- 		local frames = animation

-- 		if not frames[1] and animation.prefix then
-- 			frames = A.extract_frame_from(animation)
-- 		end

-- 		if frames and frames[2] then
-- 			local groups = {}

-- 			for _, frame_name in ipairs(frames[2]) do
-- 				local group = texture_lookup[frame_name]
-- 				if group then
-- 					groups[group] = true
-- 				end
-- 			end

-- 			if next(groups) then
-- 				lookup[animation_name] = groups
-- 			end
-- 		end
-- 	end

-- 	_animation_group_lookup[texture_lookup] = lookup

-- 	return lookup
-- end

local function sorted_keys(derived_map)
	local out = {}
	for value in pairs(derived_map) do
		out[#out + 1] = value
	end
	table.sort(out)

	return out
end

-- local function register_custom_image(rel_path, sprite_name, group_name)
-- 	if not rel_path or not sprite_name then
-- 		return false
-- 	end

-- 	local ok_img, img_data = pcall(love.image.newImageData, rel_path)
-- 	if not ok_img or not img_data then
-- 		return false
-- 	end

-- 	local img = G.newImage(img_data)
-- 	if not img then
-- 		return false
-- 	end

-- 	I:add_image(sprite_name, img, group_name or "game_editor")

-- 	return true, img
-- end

-- local function register_custom_sound(rel_path, sound_id)
-- 	if not rel_path or not sound_id then
-- 		return false
-- 	end

-- 	local ok_src, src = pcall(love.audio.newSource, rel_path, "stream")
-- 	if not ok_src or not src then
-- 		return false
-- 	end

-- 	local file_key = sound_id .. "__file"
-- 	S.sources[file_key] = {src}
-- 	S.source_uses[file_key] = 1
-- 	S.sounds[sound_id] = {
-- 		files = {
-- 			[1] = file_key
-- 		},
-- 		gain = 0.6,
-- 		loop = true,
-- 		source_group = "MUSIC",
-- 		stream = true
-- 	}

-- 	if not S.sound_extras[sound_id] then
-- 		S:_precache_sound(sound_id, S.sounds[sound_id])
-- 	end

-- 	return true
-- end

-- local function collect_resource_refs(value, ctx, visited)
-- 	local tv = type(value)

-- 	if tv == "string" then
-- 		local sprite_group = ctx.texture_lookup[value]

-- 		if not sprite_group and value:match("^[%w_%-]+$") then
-- 			sprite_group = ctx.texture_lookup[value .. "_0001"]
-- 		end

-- 		if sprite_group and not sprite_group:match("^game_editor") then
-- 			ctx.textures[sprite_group] = true
-- 		end

-- 		local sound_groups = ctx.sound_lookup[value]
-- 		if sound_groups then
-- 			for group_name in pairs(sound_groups) do
-- 				ctx.sounds[group_name] = true
-- 			end
-- 		end

-- 		local animation_groups = ctx.animation_lookup[value]
-- 		if animation_groups then
-- 			for group_name in pairs(animation_groups) do
-- 				ctx.textures[group_name] = true
-- 			end
-- 		end

-- 		return
-- 	elseif tv ~= "table" then
-- 		return
-- 	end

-- 	if visited[value] then
-- 		return
-- 	end
-- 	visited[value] = true

-- 	if value.exo and type(value.prefix) == "string" then
-- 		ctx.exos[value.prefix] = true
-- 	end

-- 	for _, child in pairs(value) do
-- 		collect_resource_refs(child, ctx, visited)
-- 	end
-- end

local function gather_wave_enemy_templates(wave_data)
	local names = {}
	E:ensure_loaded()
	local entities = E.entities or {}
	local function add_enemy_name(name)
		if type(name) ~= "string" or name == "" then
			return
		end
		if entities[name] then
			names[name] = true
			return
		end
		local prefixed = "enemy_" .. name
		if entities[prefixed] then
			names[prefixed] = true
		end
	end

	if type(wave_data) ~= "table" or type(wave_data.groups) ~= "table" then
		return names
	end

	for _, group in ipairs(wave_data.groups) do
		if type(group) == "table" and type(group.waves) == "table" then
			for _, wave in ipairs(group.waves) do
				if type(wave) == "table" then
					if type(wave.enemies) == "table" then
						for _, enemy_name in ipairs(wave.enemies) do
							add_enemy_name(enemy_name)
						end
					end
					if type(wave.spawns) == "table" then
						for _, spawn in ipairs(wave.spawns) do
							if type(spawn) == "table" then
								add_enemy_name(spawn.creep)
								add_enemy_name(spawn.creep_aux)
							end
						end
					end
				end
			end
		end
	end

	return names
end

-- function editor:current_custom_music_ids()
-- 	local level_name = self.store and self.store.level_name or "level"

-- 	return {
-- 		[CUSTOM_IMPORT_BATTLE] = custom_sound_id(level_name, "battle"),
-- 		[CUSTOM_IMPORT_BATTLE_PREP] = custom_sound_id(level_name, "battle_prep")
-- 	}
-- end

-- function editor:set_drop_import_mode(mode)
-- 	self.drop_import_mode = mode

-- 	if self.gui and self.gui.update_drop_import_buttons then
-- 		self.gui:update_drop_import_buttons()
-- 	end
-- end

-- function editor:load_custom_resources()
-- 	local level = self.store and self.store.level
-- 	local data = level and level.data

-- 	if not data then
-- 		return
-- 	end

-- 	local resources = custom_resource_table(data)
-- 	self.last_dropped_bg = nil
-- 	self.custom_music = {}

-- 	if resources.background and resources.background.path and resources.background.sprite then
-- 		local ok, img = register_custom_image(resources.background.path, resources.background.sprite, "game_editor")

-- 		if ok then
-- 			self.last_dropped_bg = table.deepclone(resources.background)

-- 			local imported = false
-- 			for _, e in ipairs(data.entities_list or {}) do
-- 				local sprite = e.render and e.render.sprites and e.render.sprites[1]
-- 				if e.template_name == "decal_background" and sprite and sprite.name == resources.background.sprite then
-- 					imported = true
-- 					break
-- 				end
-- 			end

-- 			for _, e in pairs(self.store.entities or {}) do
-- 				local sprite = e.render and e.render.sprites and e.render.sprites[1]
-- 				if e.template_name == "decal_background" and sprite and sprite.name == resources.background.sprite then
-- 					imported = true
-- 					break
-- 				end
-- 			end

-- 			if not imported and img then
-- 				local bg_entity = E:create_entity("decal_background")
-- 				bg_entity.render.sprites[1].name = resources.background.sprite
-- 				bg_entity.render.sprites[1].z = Z_BACKGROUND

-- 				local iw, ih = img:getWidth(), img:getHeight()
-- 				if iw > 0 and ih > 0 then
-- 					bg_entity.render.sprites[1].scale = V.v(self.ref_w / iw, self.ref_h / ih)
-- 				end

-- 				self.simulation:queue_insert_entity(bg_entity)
-- 			end
-- 		end
-- 	end

-- 	local music_ids = self:current_custom_music_ids()

-- 	if resources[CUSTOM_IMPORT_BATTLE] and resources[CUSTOM_IMPORT_BATTLE].path then
-- 		if register_custom_sound(resources[CUSTOM_IMPORT_BATTLE].path, music_ids[CUSTOM_IMPORT_BATTLE]) then
-- 			self.custom_music[CUSTOM_IMPORT_BATTLE] = {
-- 				path = resources[CUSTOM_IMPORT_BATTLE].path,
-- 				filename = resources[CUSTOM_IMPORT_BATTLE].filename,
-- 				sound_id = music_ids[CUSTOM_IMPORT_BATTLE]
-- 			}
-- 		end
-- 	end

-- 	if resources[CUSTOM_IMPORT_BATTLE_PREP] and resources[CUSTOM_IMPORT_BATTLE_PREP].path then
-- 		if register_custom_sound(resources[CUSTOM_IMPORT_BATTLE_PREP].path, music_ids[CUSTOM_IMPORT_BATTLE_PREP]) then
-- 			self.custom_music[CUSTOM_IMPORT_BATTLE_PREP] = {
-- 				path = resources[CUSTOM_IMPORT_BATTLE_PREP].path,
-- 				filename = resources[CUSTOM_IMPORT_BATTLE_PREP].filename,
-- 				sound_id = music_ids[CUSTOM_IMPORT_BATTLE_PREP]
-- 			}
-- 		end
-- 	end
-- end

-- -- TODO: 该方法存在实现错误，暂不调用，不推断关卡所需资源，先交给玩家考虑这件事情。
-- function editor:refresh_required_assets()
-- 	local level = self.store.level
-- 	local data = level and level.data

-- 	if not level or not data then
-- 		return
-- 	end

-- 	local texture_map = {}
-- 	local sound_map = {}
-- 	local exo_map = {}
-- 	local ctx = {
-- 		texture_lookup = texture_group_lookup(director and director.params and director.params.texture_size),
-- 		animation_lookup = nil,
-- 		sound_lookup = sound_group_lookup(),
-- 		textures = texture_map,
-- 		sounds = sound_map,
-- 		exos = exo_map
-- 	}
-- 	ctx.animation_lookup = animation_group_lookup(ctx.texture_lookup)

-- 	for _, e in pairs(self.store.entities or {}) do
-- 		collect_resource_refs(e, ctx, {})
-- 	end

-- 	local waves = self.wave_data or load_lua_table_with_pref(wave_rel(self.store.level_name, self.store.level_mode))
-- 	for enemy_name in pairs(gather_wave_enemy_templates(waves)) do
-- 		local ok_enemy, enemy = pcall(E.create_entity, E, enemy_name)
-- 		if ok_enemy and type(enemy) == "table" then
-- 			collect_resource_refs(enemy, ctx, {})
-- 		end
-- 	end

-- 	data.required_textures = sorted_keys(texture_map)
-- 	data.required_sounds = sorted_keys(sound_map)
-- 	data.required_exoskeletons = sorted_keys(exo_map)
-- 	level.required_textures = table.deepclone(data.required_textures)
-- 	level.required_sounds = table.deepclone(data.required_sounds)
-- 	level.required_exoskeletons = table.deepclone(data.required_exoskeletons)
-- end

-- 加载某一个关卡。查找顺序：编辑器目录 → 游戏目录 → 初始化空白关卡
function editor:load_level(idx, mode, recover)
	if recover then
		-- 如果是希望恢复至游戏本体内容，优先从游戏目录加载。
		EDITOR_PATH = "kr1"
	end

	self.undo_stack = {}
	self.undo_active = false
	self.store = {}
	self.store.config = storage:load_config()

	local systems = self.simulation_systems

	simulation:init(self.store, systems, self.simulation_systems, TICK_LENGTH)

	self.simulation = simulation

	A:load()
	E:ensure_loaded()

	local s = self.store

	if not idx then
		-- 默认值：斗蛐蛐关卡
		idx = 1000
	end

	-- 如果没有 idx，我们应该找到一个合适的关卡序号，并创建一个新的关卡
	-- if not idx then
	-- -- 获取一个合适的关卡序号
	-- idx = GEU.find_min_editor_index() - 1
	-- s.level_idx = idx
	-- s.level_name = "level" .. string.format("%02i", idx)
	-- s.level_mode = mode
	-- s.level_difficulty = DIFFICULTY_EASY
	-- s.level = {
	-- 	data = {
	-- 		locked_hero = false,
	-- 		level_terrain_style = "tower_holder_grass",
	-- 		max_upgrade_level = 6,
	-- 		entities_list = {},
	-- 		invalid_path_ranges = {},
	-- 		level_mode_overrides = {{}, {}, {}},
	-- 		nav_mesh = {},
	-- 		custom_resources = {},
	-- 		required_sounds = {},
	-- 		required_textures = {},
	-- 		required_exoskeletons = {}
	-- 	},
	-- 	unlock_towers = {},
	-- 	locked_towers = {}
	-- }
	-- for _, n in ipairs({
	-- 	"required_textures",
	-- 	"required_sounds",
	-- 	"required_exoskeletons",
	-- 	"locked_hero",
	-- 	"locked_powers",
	-- 	"locked_towers",
	-- 	"max_upgrade_level",
	-- 	"custom_spawn_pos",
	-- 	"show_comic_idx",
	-- 	"nav_mesh",
	-- 	"unlock_towers",
	-- 	"custom_start_pos",
	-- 	"ignore_walk_backwards_paths"
	-- }) do
	-- 	s.level[n] = s.level.data[n]
	-- end
	-- else
	-- 不需要区分来自 game_editor 目录还是游戏目录，直接进行加载。默认情况下，会先从 game_editor 加载，然后才是从游戏目录加载。
	s.level_idx = idx
	s.level_name = "level" .. string.format("%02i", idx)
	s.level_mode = mode
	s.level_difficulty = DIFFICULTY_EASY
	s.level = LU.load_level(s, s.level_name)
	if not s.level.data then
		s.level.data = {
			locked_hero = false,
			level_terrain_style = "tower_holder_grass",
			max_upgrade_level = 6,
			entities_list = {},
			invalid_path_ranges = {},
			level_mode_overrides = {{}, {}, {}},
			nav_mesh = {},
			custom_resources = {},
			required_sounds = {},
			required_textures = {},
			required_exoskeletons = {}
		}
		for _, n in ipairs({
			"required_textures",
			"required_sounds",
			"required_exoskeletons",
			"locked_hero",
			"locked_powers",
			"locked_towers",
			"max_upgrade_level",
			"custom_spawn_pos",
			"show_comic_idx",
			"nav_mesh",
			"unlock_towers",
			"custom_start_pos",
			"ignore_walk_backwards_paths"
		}) do
			if not s.level[n] then
				s.level[n] = s.level.data[n]
			else
				s.level.data[n] = s.level[n]
			end
		end
	end
	-- custom_resource_table(s.level.data)
	director:load_texture_groups(s.level.required_textures, director.params.texture_size, self.ref_res, false, "game_editor")

	if s.level.required_exoskeletons then
		EXO:queue_load(s.level.required_exoskeletons)
		EXO:load(s.level.required_exoskeletons)
	end
	-- self:load_custom_resources()

	if s.level.init then
		s.level:init(s)
	end

	if s.level.data.entities_list then
		LU.insert_entities(self.store, s.level.data.entities_list, true)
	end

	if not s.level.nav_mesh then
		s.level.nav_mesh = {}

		s.level.data.nav_mesh = s.level.nav_mesh
	end

	if s.level.load then
		P.add_invalid_range = function()
		end

		s.level:load(s)
	end
	-- end

	-- 尝试加载网格
	if not GR:load(s.level_name) then
		local gox, goy = -192, 0
		local bgw, bgh = 1408, 768
		local gw, gh = math.ceil(bgw / GR.cell_size), math.ceil(bgh / GR.cell_size)

		GR:init_grid(gw, gh, gox, goy, GR.cell_size)
	end

	P:load_curves(s.level_name)

	self.entities_dirty = true

	self.grid_dirty = true

	self.path_curves = P.path_curves
	self.path_connections = P.path_connections
	self.active_paths = P.active_paths

	self:update_curves()

	self.paths_dirty = true

	self.simulation:update(0.03333333333333333)

	self.nav_entity_selected = nil

	self:sanitize_nav_mesh(s.level.nav_mesh)

	self.nav_dirty = true
	self.undo_stack = {}
	self.undo_active = true
	self:load_wave_assets()

	self.gui:level_loaded(idx)

	if recover then
		EDITOR_PATH = "game_editor"
	end
end

function editor:load_wave_assets()
	local level_name = self.store.level_name
	local mode = self.store.level_mode
	local cfg_path = string.format("data/waveconfigs/%s_waves_%s_config.lua", level_name, mode_suffix(mode))
	local wave_path = string.format("data/waves/%s_waves_%s.lua", level_name, mode_suffix(mode))
	local cfg_raw = load_lua_table_with_pref(cfg_path)
	local wave_raw = load_lua_table_with_pref(wave_path)
	self.wave_config = sanitize_wave_config(cfg_raw)
	self.wave_data = sanitize_wave_data(wave_raw, self.wave_config)
end

function editor:generate_wave_data_from_config(config)
	local cfg = sanitize_wave_config(config)
	local data = {
		lives = cfg.lives,
		cash = cfg.cash,
		groups = {}
	}

	for _, group in ipairs(cfg.groups) do
		data.groups[#data.groups + 1] = wave_gen_interface.generate_group(group)
	end

	return data
end

function editor:save_wave_assets()
	local level_name = self.store.level_name
	local mode = self.store.level_mode
	local cfg_path = wave_cfg_rel(level_name, mode)
	local wave_path = wave_rel(level_name, mode)
	self.wave_config = sanitize_wave_config(self.wave_config)
	self.wave_data = sanitize_wave_data(self.wave_data, self.wave_config)
	local ok_cfg = save_lua_table(cfg_path, self.wave_config)
	local ok_waves = save_lua_table(wave_path, self.wave_data)
	return ok_cfg and ok_waves
end

function editor:init(screen_w, screen_h, done_callback)
	self.screen_w = screen_w
	self.screen_h = screen_h
	self.done_callback = done_callback
	self.game_scale = self.ref_h / TEXTURE_SIZE_ALIAS["ipad"]
	self.game_ref_origin = V.v((screen_w - self.ref_w * self.game_scale) / 2, (screen_h - self.ref_h * self.game_scale) / 2)

	RU.init()

	game_editor_gui:init(screen_w, screen_h, self)
	self.gui = game_editor_gui

	local level_idx = self.args and self.args.level_idx
	local level_mode = (self.args and self.args.level_mode) or GAME_MODE_CAMPAIGN
	self:load_level(level_idx, level_mode)

	self.paths_visible = false
	self.grid_visible = false
	self.nav_visible = false
	self.drop_import_mode = nil
	self.tool_pointer = {
		size = 1,
		x = 0,
		y = 0
	}
	self.last_dropped_bg = nil

	-- 设置文件拖入处理器
	self._orig_filedropped = love.filedropped
	love.filedropped = function(file)
		self:filedropped(file)
	end
end

-- 根据用户撒的点（knots 列表）重建整条 Bezier 曲线
-- knots: {{x,y}, {x,y}, ...} 用户点的坐标列表
function editor:recalc_smooth_control_points(pi, knots)
	local path = self.path_curves[pi]
	if not path then
		return
	end
	if not knots then
		return
	end

	local n = #knots
	if n < 2 then
		return
	end

	local old_widths = path.widths
	path.nodes = {}
	path.widths = {}

	-- Catmull-Rom → Bezier：对于相邻 knot i→i+1
	--   h1 = Ki + (Ki+1 - Ki-1) / 6
	--   h2 = Ki+1 - (Ki+2 - Ki) / 6
	local function K(i)
		if i < 1 then
			i = 1
		end
		if i > n then
			i = n
		end
		return knots[i]
	end

	for i = 1, n - 1 do
		local k0, k1, k2, k3 = K(i - 1), K(i), K(i + 1), K(i + 2)
		local h1x = k1.x + (k2.x - k0.x) / 6
		local h1y = k1.y + (k2.y - k0.y) / 6
		local h2x = k2.x - (k3.x - k1.x) / 6
		local h2y = k2.y - (k3.y - k1.y) / 6

		path.nodes[#path.nodes + 1] = V.v(k1.x, k1.y)
		path.nodes[#path.nodes + 1] = V.v(h1x, h1y)
		path.nodes[#path.nodes + 1] = V.v(h2x, h2y)
		path.widths[#path.widths + 1] = old_widths[i] or DEFAULT_PATH_WIDTH
	end
	-- 末尾补一个宽度值，供 generate_paths 访问 widths[bi+1]
	path.widths[#path.widths + 1] = path.widths[#path.widths] or DEFAULT_PATH_WIDTH
	-- 最后一个 knot
	path.nodes[#path.nodes + 1] = V.v(knots[n].x, knots[n].y)

	self:update_curves()
	self.paths_dirty = true
end

local function ensure_path_user_points(path)
	if path.user_points and #path.user_points > 0 then
		return path.user_points
	end

	path.user_points = {}

	for i = 1, #path.nodes, 3 do
		local p = path.nodes[i]
		if p then
			path.user_points[#path.user_points + 1] = {
				x = p.x,
				y = p.y
			}
		end
	end

	return path.user_points
end

-- 在指定路径末尾添加平滑点（用户撒点 → Catmull-Rom 样条）
function editor:add_smooth_point(pi, x, y)
	if not self.path_curves[pi] then
		return
	end
	local path = self.path_curves[pi]

	-- 维护用户撒的点列表：首次使用时从现有 nodes 中提取 knot
	ensure_path_user_points(path)
	path.user_points[#path.user_points + 1] = {
		x = x,
		y = y
	}

	-- 用全部用户点重建曲线
	self:recalc_smooth_control_points(pi, path.user_points)
end

function editor:clear_path_points(pi)
	if not self.path_curves[pi] then
		return
	end
	local path = self.path_curves[pi]
	path.nodes = {}
	path.widths = {}
	path.user_points = {}
	self:update_curves()
end

function editor:destroy()
	-- 恢复原始的 filedropped 处理器
	if self._orig_filedropped then
		love.filedropped = self._orig_filedropped
	end

	self.gui:destroy()

	self.gui = nil

	RU.destroy()
end

function editor:update(dt)
	self.simulation:update(dt)
	self.simulation:render_update(dt)
	self.gui:update(dt)
	return true
end

function editor:keypressed(key, isrepeat)
	self.gui:keypressed(key, isrepeat)
end

function editor:keyreleased(key, isrepeat)
	self.gui:keyreleased(key, isrepeat)
end

function editor:textinput(t)
	self.gui:textinput(t)
end

function editor:mousepressed(x, y, button)
	self.gui:mousepressed(x, y, button)
end

function editor:mousereleased(x, y, button)
	self.gui:mousereleased(x, y, button)
end

function editor:wheelmoved(dx, dy)
	self.gui:wheelmoved(dx, dy)
end

-- 资源导入通过工具栏显式进入拖拽模式后才生效，避免用户误触。
function editor:filedropped(file)
-- if not file then
-- 	return
-- end

-- if not self.drop_import_mode then
-- 	if self.gui then
-- 		self.gui:show_save_notification("请先点击工具栏中的资源导入按钮，再拖入背景图或音乐文件", false)
-- 	end
-- 	return
-- end

-- local filename = file:getFilename()
-- if not filename then
-- 	return
-- end
-- local basename = filename:match("([^/\\]+)$") or filename
-- local safe_basename = sanitize_filename(basename)
-- local ext = filename:match("%.([%w_]+)$")
-- ext = ext and ext:lower() or nil

-- -- 读取文件到内存，绕过 LÖVE 文件系统沙箱
-- local ok = file:open("r")
-- if not ok then
-- 	log.error("Editor: could not open dropped file: %s", filename)
-- 	return
-- end
-- local content = file:read()
-- file:close()

-- if not content or content == "" then
-- 	log.error("Editor: empty file: %s", filename)
-- 	return
-- end

-- local level_name = self.store and self.store.level_name or "level"
-- local resources = custom_resource_table(self.store.level.data)
-- local import_mode = self.drop_import_mode
-- local music_ids = self:current_custom_music_ids()

-- ensure_custom_asset_dirs()

-- if import_mode == CUSTOM_IMPORT_BG then
-- 	if ext ~= "png" then
-- 		self.gui:show_save_notification("背景图目前只支持 PNG", false)
-- 		return
-- 	end

-- 	local sprite_name = string.format("%s__bg__%s", level_name, strip_extension(safe_basename))
-- 	local rel_asset_path = string.format("%s/%s.png", CUSTOM_IMAGES_DIR, sprite_name)
-- 	local file_data = love.filesystem.newFileData(content, "bg_temp.png")
-- 	if not file_data then
-- 		log.error("Editor: could not create FileData")
-- 		return
-- 	end
-- 	local img_data = love.image.newImageData(file_data)
-- 	local img = G.newImage(img_data)

-- 	if not img then
-- 		log.error("Editor: could not create Image from dropped file: %s", filename)
-- 		return
-- 	end

-- 	love.filesystem.write(rel_asset_path, content)
-- 	I:add_image(sprite_name, img, "game_editor")

-- 	local previous = resources.background and resources.background.sprite
-- 	local replaced = false
-- 	for _, e in pairs(self.store.entities or {}) do
-- 		local sprite = e.render and e.render.sprites and e.render.sprites[1]
-- 		if e.template_name == "decal_background" and sprite and previous and sprite.name == previous then
-- 			sprite.name = sprite_name
-- 			local iw, ih = img:getWidth(), img:getHeight()
-- 			if iw > 0 and ih > 0 then
-- 				sprite.scale = V.v(self.ref_w / iw, self.ref_h / ih)
-- 			end
-- 			replaced = true
-- 			break
-- 		end
-- 	end

-- 	if not replaced then
-- 		local bg_entity = E:create_entity("decal_background")
-- 		bg_entity.render.sprites[1].name = sprite_name
-- 		bg_entity.render.sprites[1].z = Z_BACKGROUND
-- 		local iw, ih = img:getWidth(), img:getHeight()
-- 		if iw > 0 and ih > 0 then
-- 			bg_entity.render.sprites[1].scale = V.v(self.ref_w / iw, self.ref_h / ih)
-- 		end
-- 		self.simulation:queue_insert_entity(bg_entity)
-- 	end

-- 	resources.background = {
-- 		filename = sprite_name .. ".png",
-- 		path = rel_asset_path,
-- 		sprite = sprite_name
-- 	}
-- 	self.last_dropped_bg = table.deepclone(resources.background)

-- 	if self.gui._bg_prompt then
-- 		self.gui._bg_prompt.hidden = true
-- 	end

-- 	self.gui:show_save_notification("背景图已导入: " .. safe_basename, true)
-- elseif import_mode == CUSTOM_IMPORT_BATTLE or import_mode == CUSTOM_IMPORT_BATTLE_PREP then
-- 	if ext ~= "ogg" and ext ~= "mp3" and ext ~= "wav" then
-- 		self.gui:show_save_notification("音乐目前支持 OGG / MP3 / WAV", false)
-- 		return
-- 	end

-- 	local asset_base = string.format("%s__%s__%s", level_name, import_mode, strip_extension(safe_basename))
-- 	local rel_asset_path = string.format("%s/%s.%s", CUSTOM_SOUNDS_DIR, asset_base, ext)
-- 	love.filesystem.write(rel_asset_path, content)

-- 	local sound_id = music_ids[import_mode]
-- 	if not register_custom_sound(rel_asset_path, sound_id) then
-- 		self.gui:show_save_notification("音乐导入失败: " .. safe_basename, false)
-- 		return
-- 	end

-- 	resources[import_mode] = {
-- 		filename = asset_base .. "." .. ext,
-- 		path = rel_asset_path,
-- 		sound_id = sound_id
-- 	}
-- 	self.custom_music = self.custom_music or {}
-- 	self.custom_music[import_mode] = table.deepclone(resources[import_mode])
-- 	self.gui:show_save_notification((import_mode == CUSTOM_IMPORT_BATTLE and "战斗音乐" or "备战音乐") .. "已导入: " .. safe_basename, true)
-- end

-- self:set_drop_import_mode(nil)
end

function editor:draw()
	-- 实时显示当前的内存占用
	love.graphics.print("Memory: " .. collectgarbage("count") / 1024 .. " MiB", 10, 10)

	local rox, roy = self.game_ref_origin.x, self.game_ref_origin.y
	local gs = self.game_scale
	local node_w = 10
	local curve_w = 3
	local curve_selected_w = 3
	local sel_w = 2
	local color_curve = {255, 100, 100, 255}
	local color_curve_sel = {255, 255, 100, 255}
	local color_node = {0, 0, 255, 255}
	local color_selected = {255, 150, 150, 255}

	if self.paths_visible and (not self.paths_canvas or self.paths_dirty) then
		self.paths_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.paths_canvas = G.newCanvas()

		G.setCanvas(self.paths_canvas)

		for pi, path in ipairs(self.path_curves) do
			for i, bezier in ipairs(path.beziers) do
				G.setLineWidth(pi == self.path_selected and curve_selected_w or curve_w)
				G.setColor_old(self.path_selected == pi and color_curve_sel or color_curve)
				G.line(bezier:render())

			end

			local fnt = G.getFont()
			G.setFont(F:f("DroidSansMono", 10))
			for i, bezier in ipairs(path.beziers) do
				local p1x, p1y = bezier:getControlPoint(1)
				local p4x, p4y = bezier:getControlPoint(4)

				G.setColor_old(color_node)

				if i == 1 then
					G.circle("fill", p1x, p1y, node_w, 6)
					G.setColor_old(color_curve)
					G.print(pi, p1x - 3, p1y + 6, 0, 1, -1)
					G.setColor_old(color_node)
				end

				if self.path_selected == pi then
					G.rectangle("fill", p4x - node_w / 2, p4y - node_w / 2, node_w, node_w)
				end
			end

			G.setFont(fnt)
		end

		if self.path_points then
			local fnt = G.getFont()

			G.setFont(F:f("DroidSansMono", 10))
			G.setColor(1, 1, 1, 1)

			for pi, path in ipairs(self.path_points) do
				for spi, subpath in ipairs(path) do
					for ni, o in pairs(subpath) do
						if spi == 1 and ni % 10 == 0 then
							G.circle("fill", o.x, o.y, 4, 6)
							G.setColor(0, 0, 0, 1)
							G.print(ni, o.x, o.y, 0, 1, -1)
							G.setColor(1, 1, 1, 1)
						else
							G.circle("fill", o.x, o.y, 2, 6)
						end
					end
				end
			end

			self.path_points = nil

			G.setFont(fnt)
		end

		G.setColor(1, 1, 1, 1)
		G.setCanvas()
		G.pop()
	end

	-- 更新网格 canvas
	if self.grid_visible and (not self.grid_canvas or self.grid_dirty) then
		self.grid_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)
		G.translate(GR.ox, GR.oy)

		self.grid_canvas = G.newCanvas()

		G.setCanvas(self.grid_canvas)

		local show_terrain = self.gui and self.gui.settings and self.gui.settings.grid and self.gui.settings.grid.show_terrain
		local show_tags = self.gui and self.gui.settings and self.gui.settings.grid and self.gui.settings.grid.show_tags
		show_terrain = show_terrain ~= false
		show_tags = show_tags ~= false

		for i = 1, #GR.grid do
			for j = 1, #GR.grid[i] do
				local t = GR.grid[i][j]
				local x = (i - 1) * GR.cell_size
				local y = (j - 1) * GR.cell_size

				if show_terrain then
					local terrain = band(t, TERRAIN_TYPES_MASK)
					local tc = GRID_TERRAIN_COLORS[terrain] or {100, 100, 100, 255}
					G.setColor_old(tc[1], tc[2], tc[3], tc[4] or 255)
					G.rectangle("fill", x, y, GR.cell_size, GR.cell_size)
				end

				if show_tags then
					local alpha = show_terrain and 96 or 220
					for flag, c in pairs(GRID_FLAG_COLORS) do
						if band(t, flag) ~= 0 then
							G.setColor_old(c[1], c[2], c[3], alpha)
							G.rectangle("fill", x, y, GR.cell_size, GR.cell_size)
						end
					end
				end
			end
		end

		G.setCanvas()
		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	-- 更新实体 canvas
	if self.entities_visible and (not self.entities_canvas or self.entities_dirty) then
		self.entities_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.entities_canvas = G.newCanvas()

		G.setCanvas(self.entities_canvas)

		for _, e in pairs(self.store.entities) do
			if e.pos then
				local is_selected = self.entities_selected and table.contains(self.entities_selected, e.id)

				if is_selected then
					G.setColor_old(255, 180, 0, 240)
				elseif e.render and e.render.sprites[1].hidden then
					G.setColor_old(0, 0, 200, 50)
				else
					G.setColor_old(0, 0, 200, 200)
				end

				G.rectangle("fill", e.pos.x - 2, e.pos.y - 8, 4, 16)
				G.rectangle("fill", e.pos.x - 8, e.pos.y - 2, 16, 4)

				if is_selected and e.render and e.render.sprites and e.render.sprites[1] then
					local f = e.render.sprites[1]

					if f.ss then
						local w, h = f.ss.size[1] * f.ss.ref_scale, f.ss.size[2] * f.ss.ref_scale

						G.rectangle("line", e.pos.x + f.anchor.x * -1 * w, e.pos.y + f.anchor.y * -1 * h, w, h)
					end
				end
			end
		end

		G.setCanvas()
		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	-- 更新导航网格 canvas
	if self.nav_visible and (not self.nav_canvas or self.nav_dirty) then
		self.nav_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.nav_canvas = G.newCanvas()

		G.setCanvas(self.nav_canvas)

		if self.store.level.nav_mesh then
			local sel_h_id = self.nav_entity_selected and tonumber(self.nav_entity_selected.ui.nav_mesh_id)
			local fnt = G.getFont()

			G.setFont(F:f("DroidSansMono", 24))

			local towers = {}

			for _, e in pairs(self.store.entities) do
				if e.ui and e.ui.nav_mesh_id then
					towers[tonumber(e.ui.nav_mesh_id)] = e

					local has_edges = false

					for _, v in pairs(self.store.level.nav_mesh[tonumber(e.ui.nav_mesh_id)] or {}) do
						if v ~= nil then
							has_edges = true
						end
					end

					G.setColor_old(0, 0, 0, 255)
					G.print(e.ui.nav_mesh_id, e.pos.x + 5, e.pos.y + 18, 0, 1, -1)

					if tonumber(e.ui.nav_mesh_id) == sel_h_id then
						G.setColor_old(255, 255, 0, 255)
					elseif has_edges then
						G.setColor_old(160, 160, 255, 255)
					else
						G.setColor_old(60, 60, 60, 255)
					end

					G.print(e.ui.nav_mesh_id, e.pos.x + 5 - 1, e.pos.y + 18 + 1, 0, 1, -1)
				end
			end

			G.setFont(fnt)
			G.setColor_old(0, 100, 255, 255)
			G.translate(0, 10)

			local ox, oy = 40, 15
			local ax, ay = 40, 15

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e or h_id ~= sel_h_id then
					G.setLineWidth(2)
					G.setColor_old(0, 100, 255, 50)
				else
					G.setLineWidth(4)
					G.setColor_old(0, 100, 255, 255)
				end

				local oe = towers[row[1]]

				if oe then
					G.line(e.pos.x + ox, e.pos.y, oe.pos.x - ax, oe.pos.y)
				end

				oe = towers[row[2]]

				if oe then
					G.line(e.pos.x, e.pos.y + oy, oe.pos.x, oe.pos.y - ay)
				end

				oe = towers[row[3]]

				if oe then
					G.line(e.pos.x - ox, e.pos.y, oe.pos.x + ax, oe.pos.y)
				end

				oe = towers[row[4]]

				if oe then
					G.line(e.pos.x, e.pos.y - oy, oe.pos.x, oe.pos.y + ay)
				end
			end

			local s2 = 10
			local s3 = 15

			G.setColor_old(0, 0, 200, 255)

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e or h_id ~= sel_h_id then
					G.setColor_old(0, 0, 200, 100)
				else
					G.setColor_old(0, 0, 200, 255)
				end

				for i = 1, 4 do
					local oe = towers[row[i]]

					if oe then
						local tx, ty, a

						if i == 1 then
							tx, ty = e.pos.x + ox, e.pos.y
							a = V.toPolar(oe.pos.x - ax - (e.pos.x + ox), oe.pos.y - e.pos.y)
						elseif i == 2 then
							tx, ty = e.pos.x, e.pos.y + oy
							a = V.toPolar(oe.pos.x - e.pos.x, oe.pos.y - ay - (e.pos.y - oy))
						elseif i == 3 then
							a = V.toPolar(oe.pos.x + ax - (e.pos.x - ox), oe.pos.y - e.pos.y)
							tx, ty = e.pos.x - ox, e.pos.y
						else
							a = V.toPolar(oe.pos.x - e.pos.x, oe.pos.y + ay - (e.pos.y + oy))
							tx, ty = e.pos.x, e.pos.y - oy
						end

						if a then
							G.push()
							G.translate(tx, ty)
							G.rotate(a)
							G.translate(s3, 0)
							G.polygon("fill", s2, 0, 0, s2, 0, -s2)
							G.pop()
						end
					end
				end
			end
		end

		G.setCanvas()
		G.setColor(1, 1, 1, 1)
		G.pop()
	end

	-- 绘制实体对应的帧
	G.push()
	G.translate(self.gui.window.pos.x, self.gui.window.pos.y)
	G.push()
	G.translate(rox, roy)
	G.scale(gs, gs)

	RU.draw_frames_range(self.store.render_frames, 1, Z_GUI - 1)

	G.pop()

	-- 绘制路径
	if self.paths_visible then
		G.draw(self.paths_canvas)

		if self.gui.path_nodes_selected then
			G.push()
			G.translate(rox, self.screen_h - roy)
			G.scale(gs, -gs)
			G.setColor_old(color_selected)
			G.setLineWidth(sel_w)

			for _, item in pairs(self.gui.path_nodes_selected) do
				local pi, ni = unpack(item)
				local path = self.path_curves[pi]

				if path then
					local p = path.nodes[ni]

					if p then
						G.circle("line", p.x, p.y, node_w)
					end
				end
			end

			G.setColor(1, 1, 1, 1)
			G.pop()
		end
	end

	-- 绘制网格
	if self.grid_visible then
		G.setColor(1, 1, 1, 0.392)
		G.draw(self.grid_canvas)
		G.setColor(1, 1, 1, 1)

		if self.tool_pointer.tool == "grid" then
			G.push()
			G.translate(rox, self.screen_h - roy)
			G.scale(gs, -gs)

			local bx, by = self.tool_pointer.x, self.tool_pointer.y
			local bsize = self.tool_pointer.size
			local bw = bsize / 2 * GR.cell_size

			G.setColor(1, 1, 1, 0.784)
			G.setLineWidth(1)
			G.line(bx - bw, by - bw, bx + bw, by - bw)
			G.line(bx + bw, by - bw, bx + bw, by + bw)
			G.line(bx + bw, by + bw, bx - bw, by + bw)
			G.line(bx - bw, by + bw, bx - bw, by - bw)
			G.pop()
		end
	end

	-- 绘制实体
	if self.entities_visible then
		G.setColor(1, 1, 1, 1)
		G.draw(self.entities_canvas)
		G.setColor(1, 1, 1, 1)
	end

	-- 绘制导航网格
	if self.nav_visible then
		G.setColor(1, 1, 1, 1)
		G.draw(self.nav_canvas)
		G.setColor(1, 1, 1, 1)
	end

	G.setColor_old(0, 0, 0, 200)
	G.setLineWidth(2)
	G.push()
	G.translate(rox, self.screen_h - roy)
	G.scale(gs, -gs)
	G.line(0, 0, 0, 768)
	G.line(1024, 0, 1024, 768)
	G.print("4:3", 8, 14, 0, 1, -1)
	G.pop()
	G.setLineWidth(1)
	G.setColor(1, 1, 1, 1)
	-- 绘制 GUI
	self.gui.window:draw()
	G.pop()
end

-- SAVE BEGIN

--- 清理 data table 中所有的需忽略的键值对
---@param data table
---@param keys table
local function clear_key(data, keys)
	for _, key in ipairs(keys) do
		data[key] = nil
	end
	for k, v in pairs(data) do
		if type(v) == "table" then
			for _, key in ipairs(keys) do
				v[key] = nil
			end
			clear_key(v, keys)
		end
	end
end

function editor:serialize_entity(e)
	local t = {}

	t.template = e.template_name

	if e.pos then
		t.pos = V.vclone(e.pos)
	end

	t._id = e.id

	if e.editor and e.editor.props then
		for _, prop in pairs(e.editor.props) do
			local prop_name = unpack(prop)

			t[prop_name] = LU.eval_get_prop(e, prop_name)
		end
	end

	return t
end

--- 根据当前的 store 内容，序列化到 store.level.data 中
---@param store any
function editor:serialize_level()
	local store = self.store
	local list = store.level.data.entities_list

	for _, e in pairs(store.entities) do
		if e.editor and e.editor.scaffold then
		-- block empty
		else
			local se = self:serialize_entity(e)
			local de = list._idx[e.id]

			if de then
				table.deepmerge(de, se)
			else
				table.insert(list, se)

				list._idx[e.id] = se
			end
		end
	end

	local data = store.level.data

	if data._before_ov then
		for k, v in pairs(data._before_ov) do
			if v == NULL then
				data[k] = nil
			else
				data[k] = table.deepclone(v)
			end
		end
	end
end

function editor:save_data()
	local fn = "game_editor/data/levels/" .. self.store.level_name .. "_data.lua"
	-- self:refresh_required_assets()
	self:serialize_level()
	local data = table.deepclone(self.store.level.data)
	clear_key(data, {"_idx", "_id", "_before_ov", "locations", "frames"})
	return storage:write_lua(fn, data)
end

function editor:save_curves()
	local fn = "game_editor/data/levels/" .. self.store.level_name .. "_paths.lua"
	local t = {
		connections = P.path_connections,
		curves = P.path_curves,
		paths = P:generate_paths(),
		active = P.active_paths
	}
	t = table.deepclone(t)
	clear_key(t, {"beziers"})

	return storage:write_lua(fn, t)
end

function editor:save_grid()
	local fn = "game_editor/data/levels/" .. self.store.level_name .. "_grid.lua"
	local data = table.deepclone(GR)
	clear_key(data, {"cell_size", "cell_type_names", "grid_colors", "grid_h", "grid_w", "waypoints_cache"})
	return storage:write_lua(fn, data)
end

--- 将当前 store 对应的关卡数据全部保存
function editor:level_save()
	log.info("Saving level: %s", self.store.level_name)
	local ok_curves = self:save_curves()
	local ok_grid = self:save_grid()
	local ok_data = self:save_data()
	local ok_waves = self:save_wave_assets()
	return ok_curves and ok_grid and ok_data and ok_waves
end

-- SAVE END

function editor:entities_at_pos(wx, wy, size)
	local found = {}

	for _, e in pairs(self.store.entities) do
		local select_size = size or 4

		if e.pos and wx > e.pos.x - select_size and wx < e.pos.x + select_size and wy > e.pos.y - select_size and wy < e.pos.y + select_size then
			table.insert(found, e)
		end
	end

	return found
end

function editor:undo_push_entity(from_drag, eid, ...)
	if not self.undo_active then
		return
	end

	local args = {...}
	local props = {}

	for i = 1, #args / 2 do
		props[args[2 * i - 1]] = args[2 * i]
	end

	local last = self.undo_stack[#self.undo_stack]

	if from_drag and last and last.from_drag then
		if last.from_drag and eid == last.id then
			for k, v in pairs(props) do
				if last.props[k] then
					last.props[k] = props[k]
				end
			end

			log.debug("undo: updated last entry:%s", getdump(last))
		end
	else
		local item = {
			type = "entity",
			from_drag = from_drag,
			id = eid,
			props = props
		}

		log.debug("undo: new entry: %s", getdump(item))
		table.insert(self.undo_stack, item)
	end

	if #self.undo_stack > 1000 then
		log.error("TODO: trim undo stack!")
	end
end

function editor:undo_push_paths(from_drag)
	if not self.undo_active then
		return
	end

	local last = self.undo_stack[#self.undo_stack]
	if from_drag and last and last.type == "paths" and last.from_drag then
		return
	end

	table.insert(self.undo_stack, {
		type = "paths",
		from_drag = from_drag and true or false,
		path_curves = table.deepclone(self.path_curves),
		active_paths = table.deepclone(self.active_paths),
		path_connections = table.deepclone(self.path_connections)
	})
end

function editor:undo_push_grid(from_drag)
	if not self.undo_active then
		return
	end

	local last = self.undo_stack[#self.undo_stack]
	if from_drag and last and last.type == "grid" and last.from_drag then
		return
	end

	table.insert(self.undo_stack, {
		type = "grid",
		from_drag = from_drag and true or false,
		grid = table.deepclone(GR.grid),
		grid_w = GR.grid_w,
		grid_h = GR.grid_h,
		ox = GR.ox,
		oy = GR.oy
	})
end

function editor:undo_push_entity_insert(eid)
	if not self.undo_active then
		return
	end

	table.insert(self.undo_stack, {
		type = "entity_insert",
		id = eid
	})
end

function editor:undo_push_entity_delete(e)
	if not self.undo_active or not e then
		return
	end

	table.insert(self.undo_stack, {
		type = "entity_delete",
		entity = table.deepclone(e)
	})
end

function editor:undo_pop()
	local item = table.remove(self.undo_stack)

	if not item then
		return
	end

	if item.type == "entity" then
		local e = self.store.entities[item.id]

		if not e then
			log.error("Undo could not find entity with id:%s", item.id)

			return
		end

		for k, v in pairs(item.props) do
			LU.eval_set_prop(e, k, v)
		end
	elseif item.type == "entity_insert" then
		local e = self.store.entities[item.id]
		if not e then
			return
		end

		LU.queue_remove(self.store, e)
		local list = self.store.level and self.store.level.data and self.store.level.data.entities_list
		if list and list._idx then
			local le = list._idx[e.id]
			if le then
				table.removeobject(list, le)
				list._idx[e.id] = nil
			end
		end
		self.entities_dirty = true
	elseif item.type == "entity_delete" then
		if not item.entity then
			return
		end

		LU.queue_insert(self.store, table.deepclone(item.entity))
		self.entities_dirty = true
	elseif item.type == "paths" then
		self.path_curves = table.deepclone(item.path_curves or {})
		self.active_paths = table.deepclone(item.active_paths or {})
		self.path_connections = table.deepclone(item.path_connections or {})

		P.path_curves = self.path_curves
		P.active_paths = self.active_paths
		P.path_connections = self.path_connections
		self:update_curves()
		self.paths_dirty = true
	elseif item.type == "grid" then
		GR.grid = table.deepclone(item.grid or {})
		GR.grid_w = item.grid_w or (#GR.grid > 0 and #GR.grid or 0)
		GR.grid_h = item.grid_h or (GR.grid[1] and #GR.grid[1] or 0)
		GR.ox = item.ox or 0
		GR.oy = item.oy or 0
		GR.waypoints_cache = {}
		self.grid_dirty = true
	end
end

function editor:update_curves(pi, touched)
	if pi and touched then
		local path = self.path_curves[pi]
		local nodes = path.nodes
		local beziers = path.beziers

		table.sort(touched)

		for _, ni in pairs(touched) do
			local p = nodes[ni]
			local bni = (ni - 1) % 3 + 1
			local bi = math.floor((ni - 1) / 3) + 1
			local bez_p = beziers[bi - 1]
			local bez_n = beziers[bi]

			if (ni - 1) % 3 == 0 then
				if bez_n then
					bez_n:setControlPoint(1, p.x, p.y)
				end

				if bez_p then
					bez_p:setControlPoint(4, p.x, p.y)
				end
			elseif bez_n then
				bez_n:setControlPoint(bni, p.x, p.y)
			end
		end
	else
		for _, path in pairs(self.path_curves) do
			local n = path.nodes
			local scount = (#n - 1) / 3
			local beziers = {}

			for i = 1, scount do
				local j = 3 * (i - 1) + 1
				local p1, p2, p3, p4 = n[j], n[j + 1], n[j + 2], n[j + 3]
				table.insert(beziers, love.math.newBezierCurve({p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y}))
			end

			path.beziers = beziers
		end
	end

	self.paths_dirty = true
end

function editor:set_node_width(pi, ni, w)
	local wi = (ni - 1) / 3 + 1
	local path = self.path_curves[pi]

	path.widths[wi] = w
	self.paths_dirty = true
end

function editor:set_node_pos(pi, ni, x, y)
	local path = self.path_curves[pi]
	local nodes = path.nodes
	local node = nodes[ni]

	node.x, node.y = x, y

	if (ni - 1) % 3 == 0 then
		-- 移动的是 knot → 用全部用户点重建 Catmull-Rom 样条
		ensure_path_user_points(path)
		path.user_points[(ni - 1) / 3 + 1] = {
			x = x,
			y = y
		}
		self:recalc_smooth_control_points(pi, path.user_points)
	else
		-- 移动的是控制手柄 → 对侧手柄对称移动
		local oni = ni % 3 == 0 and ni + 2 or ni - 2
		local cni = ni % 3 == 0 and ni + 1 or ni - 1
		local on = nodes[oni]
		local cn = nodes[cni]
		local nn = nodes[ni]

		if nn and on and cn then
			local ol = V.len(on.x - cn.x, on.y - cn.y)
			local donx, dony = V.mul(ol, V.rotate(km.pi, V.normalize(nn.x - cn.x, nn.y - cn.y)))
			on.x, on.y = cn.x + donx, cn.y + dony
		end

		self:update_curves(pi, {ni, oni})
	end
end

function editor:extend_path(pi, ni, x, y)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if ni ~= 1 and ni ~= #nodes then
		return
	end

	if ni == #nodes then
		local ph2 = nodes[ni - 1]
		local n1 = nodes[ni]
		local h1 = V.v(V.add(n1.x, n1.y, V.rotate(km.pi, ph2.x - n1.x, ph2.y - n1.y)))

		if not x or not y then
			x, y = n1.x + 100, n1.y
		end

		local n2 = V.v(x, y)
		local h2 = V.v(V.add(n2.x, n2.y, V.mul(0.25, n1.x - n2.x, n1.y - n2.y)))

		table.insert(nodes, h1)
		table.insert(nodes, h2)
		table.insert(nodes, n2)

		local wi = (ni - 1) / 3 + 1

		table.insert(widths, widths[wi])
	elseif ni == 1 then
		local ph1 = nodes[2]
		local n2 = nodes[1]
		local h2 = V.v(V.add(n2.x, n2.y, V.rotate(km.pi, ph1.x - n2.x, ph1.y - n2.y)))

		if not x or not y then
			x, y = n2.x - 100, n2.y
		end

		local n1 = V.v(x, y)
		local h1 = V.v(V.add(n1.x, n1.y, V.mul(0.25, n2.x - n1.x, n2.y - n1.y)))

		table.insert(nodes, 1, h2)
		table.insert(nodes, 1, h1)
		table.insert(nodes, 1, n1)
		table.insert(widths, 1, widths[1])
	end

	self:update_curves()
end

function editor:subdivide_path(pi, ni, x, y)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if (ni - 1) % 3 ~= 0 or ni == 1 or ni == #nodes then
		return
	end

	local n = nodes[ni]
	local ii = ni + 2
	local wi = (ni - 1) / 3 + 1

	if x and y then
		local ph = nodes[ni - 1]
		local nh = nodes[ni + 1]
		local xya = V.angleTo(x - n.x, y - n.y)
		local pa = math.abs(km.short_angle(xya, V.angleTo(ph.x - n.x, ph.y - n.y)))
		local na = math.abs(km.short_angle(xya, V.angleTo(nh.x - n.x, nh.y - n.y)))

		log.error("pa=%s na=%s", pa, na)

		ii = pa < na and ni - 1 or ni + 2
		wi = pa < na and wi or wi + 1
	else
		x, y = n.x + 50, n.y
	end

	local pn1 = nodes[ii - 2]
	local nn2 = nodes[ii + 1]
	local nn1 = V.v(x, y)
	local nh1 = V.v(V.add(nn1.x, nn1.y, V.mul(0.2, nn2.x - pn1.x, nn2.y - pn1.y)))
	local ph2 = V.v(V.add(nn1.x, nn1.y, V.rotate(km.pi, nh1.x - nn1.x, nh1.y - nn1.y)))

	table.insert(nodes, ii, nh1)
	table.insert(nodes, ii, nn1)
	table.insert(nodes, ii, ph2)
	table.insert(widths, wi, widths[wi - 1])
	self:update_curves()
end

function editor:remove_path(pi)
	table.remove(self.path_curves, pi)
	table.remove(self.active_paths, pi)
	table.remove(self.path_connections, pi)
	self:update_curves()
end

function editor:create_path()
	local x, y = REF_W / 2, REF_H / 2
	local d = 50
	local nodes = {V.v(x, y), V.v(x + d, y), V.v(x + 2 * d, y + d), V.v(x + 3 * d, y + d)}
	local widths = {DEFAULT_PATH_WIDTH, DEFAULT_PATH_WIDTH}

	table.insert(self.path_curves, {
		nodes = nodes,
		widths = widths
	})
	table.insert(self.active_paths, true)
	self:update_curves()

	return #self.path_curves
end

function editor:remove_path_node(pi, ni)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if (ni - 1) % 3 ~= 0 then
		return
	end

	if #nodes <= 4 then
		return
	end

	local wi = (ni - 1) / 3 + 1

	table.remove(widths, wi)

	if ni == #nodes then
		ni = ni - 2
	elseif ni ~= 1 then
		ni = ni - 1
	end

	for i = 1, 3 do
		table.remove(nodes, ni)
	end

	self:update_curves()
end

function editor:duplicate_path(pi)
	local path = self.path_curves[pi]
	local new_path = table.deepclone(path)

	table.insert(self.path_curves, new_path)
	table.insert(self.active_paths, true)
	self:update_curves()

	return #self.path_curves
end

function editor:flip_path(pi)
	local path = self.path_curves[pi]

	path.nodes = table.reverse(path.nodes)
	path.widths = table.reverse(path.widths)

	self:update_curves()
end

function editor:preview_path_points(pi)
	self.path_points = P:generate_paths(pi)
	self.paths_dirty = true
end

function editor:change_path_idx(pi, npi)
	local curves = self.path_curves

	if pi == npi or not curves[pi] or npi > #curves then
		return
	end

	local conn_idx = {}

	for i = 1, #self.path_connections do
		local ci = self.path_connections[i]

		conn_idx[i] = ci and curves[ci] or nil
	end

	local p = curves[pi]
	local p_active = self.active_paths[pi]

	if npi < pi then
		table.remove(curves, pi)
		table.insert(curves, npi, p)
		table.remove(self.active_paths, pi)
		table.insert(self.active_paths, npi, p_active)
	else
		table.insert(curves, npi + 1, p)
		table.remove(curves, pi)
		table.insert(self.active_paths, npi + 1, p_active)
		table.remove(self.active_paths, pi)
	end

	self.path_connections = {}

	for i = 1, #conn_idx do
		do
			local c = conn_idx[i]

			if c then
				for ci = 1, #curves do
					if curves[ci] == c then
						self.path_connections[i] = ci

						goto label_29_0
					end
				end

				self.path_connections[i] = nil
			end
		end

		::label_29_0::
	end

	self:update_curves()
end

function editor:set_path_connection(pi, cpi)
	if not self.path_connections then
		self.path_connections = {}
	end

	if cpi < 1 or cpi > #self.path_curves then
		self.path_connections[pi] = nil
	else
		self.path_connections[pi] = cpi
	end
end

function editor:set_path_active(pi, value)
	if not self.active_paths then
		self.active_paths = {}
	end

	self.active_paths[pi] = value
end

function editor:sanitize_nav_mesh(nav_mesh)
	for _, e in pairs(self.store.entities) do
		if e and e.tower and e.tower.holder_id and e.ui and not e.ui.nav_mesh_id then
			e.ui.nav_mesh_id = e.tower.holder_id
		end
	end

	local hids = {}

	for _, e in pairs(self.store.entities) do
		if e.ui and e.ui.nav_mesh_id then
			local hid = e.ui.nav_mesh_id

			if tonumber(hid) == 0 then
				log.error("WARNING: tower[%s] holder_id cannot be 0!!", e.id)
			end

			table.insert(hids, tonumber(e.ui.nav_mesh_id))
		end
	end

	table.sort(hids)

	for _, k in pairs(hids) do
		if not nav_mesh[k] then
			nav_mesh[k] = {}
		end
	end

	local remove = {}

	for k, v in pairs(nav_mesh) do
		if not table.contains(hids, k) then
			table.insert(remove, k)
		end
	end

	for _, k in pairs(remove) do
		nav_mesh[k] = nil
	end
end

return editor
