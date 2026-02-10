local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=27
end
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local flower_died=false
for _,e in pairs(store.entities) do
if e.template_name=="tower_stage_20_arborean_barrack" and e.health.dead then
flower_died=true
end
end
if not flower_died then
signal.emit("no-flowers-lost-stage20")
end
end
end
return level
