local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:init(store)
require("lib.klua.table")
local AC=require("achievements")
local scripts=require("scripts")
local tt
tt=E:register_t_hot("stage_20_arborean_oldtree_tree_2","decal_scripted",true)
E:add_comps(tt,"nav_path","motion","custom_attack")
tt.render.sprites[1].prefix="arborean_woodDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].angles={}
tt.render.sprites[1].angles.walk={"idle","idle","idle"}
tt.render.sprites[1].angles_stickiness={walk=10}
tt.render.sprites[1].sort_y_offset=-50
tt.render.sprites[1].exo=true
tt.main_script.update=scripts.stage_20_arborean_oldtree_tree.update
tt.nav_path.dir=-1
tt.nav_path.pi=3
tt.nav_path.ni=105
tt.nav_path.spi=1
tt.motion.max_speed=5*FPS
tt.custom_attack.max_range=50
tt.custom_attack.damage_min=350
tt.custom_attack.damage_max=450
tt.custom_attack.damage_type=DAMAGE_PHYSICAL
tt.custom_attack.hit_fx="fx_tower_arborean_oldtree_hit"
tt.custom_attack.cycle_time=0.3
tt.custom_attack.vis_flags=bor(F_RANGED)
tt.custom_attack.vis_bans=bor(F_FLYING)
end
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
