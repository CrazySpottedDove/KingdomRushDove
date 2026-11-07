-- chunkname: @./kr1/heroes/registry.lua
-- 英雄模块注册表：英雄列表、殿堂数据与资源都由 kr1/heroes/<name>/init.lua 声明。
-- 插件英雄走 register()；patch 本体英雄则 HEROES:get(name) 后往资源列表里 insert。
-- 注册数据：templates / animations / sounds / groups（均为 require 路径数组）。
-- 资源声明统一为 resources[scene] = { required_textures, ... }，
--   scene 为 "game" / "map"，写法和任意 scene 的资源声明一致。
local E = require("entity_db")
local A = require("animation_db")
local S = require("sound_db")
local Registry = require("registry")

local HEROES = Registry.new({})

-- 本体英雄模块路径。插件不要改这里，用 HEROES:register。
HEROES.module_names = {
	"heroes.hero_gerald",
	"heroes.hero_alleria",
	"heroes.hero_malik",
	"heroes.hero_bolin",
	"heroes.hero_magnus",
	"heroes.hero_ignus",
	"heroes.hero_denas",
	"heroes.hero_elora",
	"heroes.hero_ingvar",
	"heroes.hero_hacksaw",
	"heroes.hero_oni",
	"heroes.hero_thor",
	"heroes.hero_10yr",
	"heroes.hero_alric",
	"heroes.hero_mirage",
	"heroes.hero_pirate",
	"heroes.hero_wizard",
	"heroes.hero_beastmaster",
	"heroes.hero_voodoo_witch",
	"heroes.hero_alien",
	"heroes.hero_monk",
	"heroes.hero_monkey_god",
	"heroes.hero_giant",
	"heroes.hero_dragon",
	"heroes.hero_priest",
	"heroes.hero_dwarf",
	"heroes.hero_minotaur",
	"heroes.hero_crab",
	"heroes.hero_van_helsing",
	"heroes.hero_dracolich",
	"heroes.hero_vampiress",
	"heroes.hero_elves_archer",
	"heroes.hero_arivan",
	"heroes.hero_bravebark",
	"heroes.hero_xin",
	"heroes.hero_elves_denas",
	"heroes.hero_rag",
	"heroes.hero_durax",
	"heroes.hero_catha",
	"heroes.hero_regson",
	"heroes.hero_lilith",
	"heroes.hero_phoenix",
	"heroes.hero_faustus",
	"heroes.hero_veznan",
	"heroes.hero_bruce",
	"heroes.hero_lynn",
	"heroes.hero_wilbur",
	"heroes.hero_bolverk",
	"heroes.hero_vesper",
	"heroes.hero_raelyn",
	"heroes.hero_muyrn",
	"heroes.hero_builder",
	"heroes.hero_hunter",
	"heroes.hero_venom",
	"heroes.hero_bird",
	"heroes.hero_space_elf",
	"heroes.hero_mecha",
	"heroes.hero_robot",
	"heroes.hero_lumenir",
	"heroes.hero_dragon_gem",
	"heroes.hero_witch",
	"heroes.hero_dragon_bone",
	"heroes.hero_wukong",
	"heroes.hero_dragon_arb",
	"heroes.hero_lava",
	"heroes.hero_spider",
	"heroes.hero_dragon_sun",
	"heroes.hero_eiskalt",
	"heroes.hero_dianyun",
	"heroes.hero_asra",
	"heroes.hero_beresad",
	"heroes.hero_orc",
	"heroes.hero_oloch",
	"heroes.hero_margosa",
	"heroes.hero_mortemis",
	"heroes.hero_jigou",
	"heroes.hero_tramin",
	"heroes.hero_tank",
	"heroes.hero_naga",
	"heroes.hero_gerald_kr6",
	"heroes.hero_zefira",
	"heroes.hero_bolin_kr6",
	"heroes.hero_connor",
	"heroes.hero_myriath",
	"heroes.hero_malik_kr6",
	"heroes.hero_rhodes",
	"heroes.hero_ashbite",
	"heroes.hero_drakkan",
	"heroes.hero_ignus_kr6",
	"heroes.hero_oni_kr6",
	"heroes.hero_illiana"
}

--- 资源字段统一为 require 路径数组；plugin_* 字段为映射
local function merge_map(paths)
	local out = {}

	for _, path in ipairs(paths or {}) do
		table.merge(out, require(path))
	end

	return out
end

HEROES.on_register = function(module)
	local sounds = module.sounds and merge_map(module.sounds) or nil

	if sounds then
		S:register_sounds(sounds)
	end

	local groups = module.groups and merge_map(module.groups) or nil

	if groups then
		S:register_groups(groups)
	end
end

--- 按需注册一个英雄的脚本与模板（模板已存在时跳过模板注册）。
--- 模板模块是副作用模块：注册前显式失效 require 缓存，保证 E:Load 重建后能重新执行。
---@param name string
function HEROES:ensure_template(name)
	local module = self:get(name)

	if not module then
		return
	end

	if not E:get_template(name) then
		for _, path in ipairs(module.templates or {}) do
			require(path)
			package.loaded[path] = nil
		end
	end
end

--- 更新一个英雄模块。如果该英雄的模板已加载，则会重新加载
---@param name string 英雄模板名称
---@param update_fn function 更新英雄模块的函数。
function HEROES:update_module_with(name, update_fn)
	update_fn()
	if E:get_template(name) then
		E.entities[name] = nil
		self:ensure_template(name)
	end
end

--- 在 A:load() 之后按需注册一个英雄的动画。
---@param name string
function HEROES:ensure_animations(name)
	if not A.loaded then
		return
	end

	local module = self:get(name)

	if not module then
		return
	end

	self._loaded_animations = self._loaded_animations or {}

	for _, path in ipairs(module.animations or {}) do
		if not self._loaded_animations[path] then
			self._loaded_animations[path] = true

			local bin_path = KR_PATH_GAME .. "/" .. path:gsub("%.", "/") .. ".bin"

			if not A:register_animations_bin(bin_path) then
				A:register_animations(require(path))
			end
		end
	end
end

return HEROES
