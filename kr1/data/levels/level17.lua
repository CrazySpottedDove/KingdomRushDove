local level={}
function level:init(store)
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_s17_barricade_update(this,store)
local boss
while not boss do
boss=LU.list_entities(store.enemies,this.boss_name)[1]
if not boss then
U.y_wait_unconditional(store,5)
end
end
while boss and boss.nav_path and boss.nav_path.ni<this.destroy_node do
coroutine.yield()
end
U.animation_start_default(this,"destroy",nil,store.tick_ts,false)
end
local tt
tt=E:register_t_hot("decal_bandits_flag","decal_loop",true)
tt.render.sprites[1].random_ts=fts(14)
tt.render.sprites[1].name="decal_bandits_flag_idle"
tt=E:register_t_hot("decal_s17_barricade","decal",true)
AC(tt,"editor","main_script")
tt.boss_name="eb_kingpin"
tt.boss_spawn_wave=15
tt.main_script.update=decal_s17_barricade_update
tt.render.sprites[1].prefix="decal_s17_barricade"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.x=0.4
tt.render.sprites[1].loop=false
tt.editor.props={{"editor.game_mode",PT_NUMBER}}
end
return level
