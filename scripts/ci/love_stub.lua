-- love 环境打桩：让 entity_db:Load() 能在纯 LuaJIT 下跑（不需要窗口 / GPU）
--
-- 为什么需要它：文案里的 T("模板名") 直接取实体模板，只有真的 Load 过
-- 才能验证模板 / 字段是否存在、数值是否求得出；而 entity_db 的加载链会摸到
-- love（animation_db、image_db…）。这里按
-- .agents/skills/port-hero-from-fl/scripts/test_hero_room_special.lua 的做法打桩，
-- 于是离线校验（CI、迁移前后对照）都能在 luajit 里完成。
--
-- 用法（调用方需自行把仓库根目录放进 package.path，即从仓库根目录运行）：
--   local stub = require('scripts.ci.love_stub')
--   local E = stub.load_entity_db()
local stub = {}

local STUB_MODULES = {
	'love.graphics',
	'love.filesystem',
	'love.audio',
	'love.window',
	'love.mouse',
	'love.keyboard',
	'love.system',
	'love.timer',
	'love.event',
	'love.math',
	'love.data',
	'love.image',
	'lib.klove.image_db',
	'lib.klove.shader_db',
	'lib.klove.kui',
	'lib.klove.label',
	'lib.klove.text_input',
	'gg_views',
	'game_gui',
	'utf8',
	'sound_db',
	'animation_db',
	'wave_db',
	'lib.hump.signal',
	'dove_modules.perf.perf',
	'dove_modules.gui.rich_text_label',
	'dove_modules.gui.text_input'
}

local stub_fn = setmetatable({}, {
	__index = function()
		return function()
		end
	end
})

for _, name in ipairs(STUB_MODULES) do
	package.preload[name] = function()
		return stub_fn
	end
end

-- love 本体也要能取到任意子模块（如 all/constants.lua 会调 love.system.getOS()）
_G.love = setmetatable({}, {
	__index = function()
		return stub_fn
	end
})
_G.FPS = 30
_G.REF_H = 768
_G.REF_W = 1024
_G.KR_GAME = 'kr1'
_G.KR_TARGET = 'desktop'
_G.KR_PATH_GAME = 'kr1'
_G.KR_PATH_GAME_TARGET = 'kr1-desktop'
_G.KR_PATH_ALL = 'all'
_G.KR_PATH_ALL_TARGET = 'all-desktop'
_G.KR_PLATFORM = 'desktop'
_G.GGLabel = {
	static = {
		ref_h = 768
	}
}
getfulldump = function(x)
	return tostring(x)
end

for n, v in pairs({
	Z_DECALS = 100,
	Z_OBJECTS = 200,
	Z_FLYING_HEROES = 300,
	Z_BULLETS = 400,
	Z_SCREEN_FIXED = 900,
	HEALTH_BAR_SIZE_MEDIUM = 1,
	HEALTH_BAR_SIZE_LARGE = 2,
	HEALTH_BAR_SIZE_MEDIUM_LARGE = 3,
	F_FLYING = 1,
	F_CLIFF = 2,
	F_BLOCK = 4,
	F_RANGED = 8,
	F_FRIEND = 16,
	F_MOD = 32,
	F_EAT = 64,
	F_NET = 128,
	F_POISON = 256,
	F_NIGHTMARE = 512,
	F_WATER = 1024,
	F_NONE = 0,
	F_ALL = 65535,
	F_AREA = 65536,
	F_BURN = 131072,
	F_BOSS = 262144,
	F_MINIBOSS = 524288,
	DAMAGE_TRUE = 1,
	DAMAGE_PHYSICAL = 2,
	DAMAGE_MAGICAL = 4,
	DAMAGE_EXPLOSION = 8,
	DAMAGE_POISON = 16,
	DAMAGE_ARMOR = 32,
	DAMAGE_INSTAKILL = 64,
	DAMAGE_DISINTEGRATE = 128,
	DAMAGE_EAT = 256,
	DAMAGE_IGNORE_SHIELD = 512,
	DAMAGE_NO_SHIELD_HIT = 1024,
	DAMAGE_RUDE = 2048,
	TERRAIN_LAND = 1,
	TERRAIN_WATER = 2,
	TERRAIN_CLIFF = 4,
	TERRAIN_FAERIE = 8,
	TERRAIN_NOWALK = 16,
	TERRAIN_ICE = 32,
	TERRAIN_ALL_MASK = -1,
	A_NO_TARGET = 0,
	STATS_TYPE_SOLDIER = 1,
	BLOOD_NONE = 0,
	BIG_ENEMY_HP = 5000,
	MANY_ENEMY_COUNT = 3,
	NF_POWER_3 = 1,
	MAX_SCREEN_ASPECT = 1.5
}) do
	_G[n] = v
end

--- 打桩完成后加载真实的 entity_db（首次 Load 会 load + precompile 全部模板）
---@return table entity_db
function stub.load_entity_db()
	local E = require('entity_db')
	local ok, err = pcall(E.Load, E)

	if not ok then
		error('entity_db:Load() 失败: ' .. tostring(err):sub(1, 800), 2)
	end

	return E
end

return stub
