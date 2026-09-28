local log=require("lib.klua.log"):new("level11")
local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local GS=require("kr1.game_settings")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
local E=require("entity_db")
local U=require("utils")
local P=require("path_db")
require("all.constants")
require("lib.klua.table")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_drow_queen_portal_update(this,store)
local current_pack
local pi_nodes={}
local nearest_nodes=P:nearest_nodes(this.pos.x,this.pos.y,this.path_ids)
for _,item in pairs(nearest_nodes) do
pi_nodes[item[1]]=item[3]+2
end
while true do
while not this.pack do
coroutine.yield()
end
current_pack=this.pack
this.pack_finished=nil
this.tween.ts=store.tick_ts
this.tween.reverse=nil
this.tween.disabled=nil
for _,row in pairs(current_pack.waves) do
local tn,interval,qty,sub0=unpack(row,1,4)
for i=1,qty do
log.debug("(%s)decal_drow_queen_portal spawning:%s",this.id,tn)
local o=this.spawn_offsets[sub0+1]
local e=E:create_entity(tn)
e.nav_path.pi=current_pack.pi
e.nav_path.spi=sub0+1
e.nav_path.ni=pi_nodes[current_pack.pi]
e.pos.x,e.pos.y=this.pos.x+o.x,this.pos.y+o.y
e.enemy.gold=0
simulation:queue_insert_entity(e)
local fx=E:create_entity("fx_drow_queen_portal")
fx.render.sprites[1].ts=store.tick_ts
fx.pos.x,fx.pos.y=e.pos.x,e.pos.y-1
simulation:queue_insert_entity(fx)
coroutine.yield()
if interval>0 and U.y_wait_conditional(store,fts(interval),function()
return this.pack==nil
end) then
log.debug("(%s)decal_drow_queen_portal interrupted",this.id)
goto label_571_0
end
end
end
log.debug("(%s)decal_drow_queen_portal finished",this.id)
::label_571_0::
this.pack=nil
this.pack_finished=true
this.tween.ts=store.tick_ts
this.tween.reverse=true
this.tween.disabled=nil
current_pack=nil
end
end
local tt
tt=E:register_t_hot("decal_drow_queen_portal","decal_scripted",true)
AC(tt,"editor","tween")
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="stage11_portal_0001"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[2]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name="stage11_portal_0002"
tt.render.sprites[2].alpha=0
tt.render.sprites[3]=table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name="stage11_portal_0003"
tt.render.sprites[4]=table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name="stage11_portal_0004"
tt.main_script.update=decal_drow_queen_portal_update
tt.spawn_offsets={vec_2(0,0),vec_2(0,-20),vec_2(0,20)}
tt.tween.disabled=true
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{fts(7),255}}
tt.tween.props[1].sprite_id=2
tt.tween.props[2]=table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id=3
tt.tween.props[3]=table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id=4
tt.tween.props[4]=CC("tween_prop")
tt.tween.props[4].sprite_id=4
tt.tween.props[4].name="scale"
tt.tween.props[4].keys={{0,vec_1(1)},{fts(23),vec_1(1.2)}}
tt.tween.props[4].loop=true
tt.tween.props[4].ignore_reverse=true
tt=E:register_t_hot("decal_s11_door_glow","decal_tween",true)
AC(tt,"editor")
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="stage11_doorGlow"
tt.render.sprites[1].alpha=0
tt.render.sprites[1].sort_y_offset=-30
tt.tween.disabled=true
tt.tween.remove=false
tt.tween.props[1].keys={{0,100},{0.3,200},{0.6,130},{0.9,255},{1.2,100}}
tt.tween.props[1].loop=true
tt.tween.props[2]=CC("tween_prop")
tt.tween.props[2].keys={{0,0},{0.5,1},{4.8,1},{6,0}}
tt.tween.props[2].multiply=true
tt.editor.tag=1
tt.editor.props={{"editor.tag",PT_NUMBER}}
tt.editor.overrides={["render.sprites[1].alpha"]=255}
tt=E:register_t_hot("decal_s11_zealot_rune","decal_tween",true)
AC(tt,"editor")
tt.render.sprites[1].animated=false
tt.render.sprites[1].alpha=0
tt.render.sprites[1].offset=vec_2(-40,0)
tt.render.sprites[1].name="stage11_zealotRune"
tt.tween.remove=false
tt.tween.disabled=true
tt.tween.props[1].keys={{0,0},{fts(5),255}}
tt.editor.tag=1
tt.editor.props={{"editor.tag",PT_NUMBER}}
tt.editor.overrides={["render.sprites[1].alpha"]=255}
end
function level:load(store)
P:add_invalid_range(10,nil,nil,bit.bor(NF_RALLY,NF_POWER_1,NF_POWER_2,NF_POWER_3))
self.portal_packs={[0]={{"enemy_satyr_cutthroat",20,1,0},{"enemy_satyr_cutthroat",0,1,1},{"enemy_satyr_cutthroat",20,1,2},{"enemy_satyr_cutthroat",0,1,0}},{{"enemy_satyr_hoplite",20,1,0},{"enemy_satyr_cutthroat",0,1,2},{"enemy_satyr_cutthroat",20,1,1},{"enemy_satyr_cutthroat",0,1,2},{"enemy_satyr_cutthroat",20,1,1}},{{"enemy_twilight_elf_harasser",0,1,2},{"enemy_twilight_elf_harasser",20,1,1},{"enemy_twilight_scourger",0,1,0}},{{"enemy_twilight_scourger",20,1,0},{"enemy_twilight_scourger",0,1,1},{"enemy_twilight_scourger",0,1,2}},{{"enemy_twilight_avenger",30,1,0},{"enemy_twilight_elf_harasser",0,1,1},{"enemy_twilight_elf_harasser",0,1,2}},{{"enemy_twilight_scourger",20,1,0},{"enemy_twilight_elf_harasser",0,1,1},{"enemy_twilight_elf_harasser",20,1,2},{"enemy_twilight_elf_harasser",0,1,1},{"enemy_twilight_elf_harasser",20,1,2}},{{"enemy_satyr_cutthroat",0,1,1},{"enemy_satyr_cutthroat",50,1,2},{"enemy_twilight_scourger",0,1,1},{"enemy_twilight_scourger",50,1,2},{"enemy_satyr_cutthroat",0,1,0},{"enemy_satyr_cutthroat",0,1,1},{"enemy_satyr_cutthroat",50,1,2},{"enemy_satyr_cutthroat",0,1,1},{"enemy_satyr_cutthroat",50,1,2}},{{"enemy_twilight_scourger",50,1,0},{"enemy_twilight_avenger",50,2,1},{"enemy_twilight_avenger",50,0,2},{"enemy_twilight_avenger",0,1,1}},{{"enemy_twilight_avenger",0,1,1},{"enemy_twilight_avenger",70,1,2},{"enemy_twilight_elf_harasser",0,2,1},{"enemy_twilight_elf_harasser",70,0,2},{"enemy_twilight_scourger",0,1,1},{"enemy_twilight_scourger",70,1,2},{"enemy_twilight_elf_harasser",0,1,1},{"enemy_twilight_elf_harasser",70,1,2},{"enemy_twilight_elf_harasser",0,1,0}}}
self.summoner_config={[0]={portal_idx=1,summoner_pi=8,spawn_pi=5},{portal_idx=2,summoner_pi=9,spawn_pi=2}}
self.boss_waves={[2]={{"taunt",fts(20)}},[3]={{"summoner",fts(10),0,0,150},{"summoner",fts(500),0,0,150},{"summoner",fts(1000),0,0,150}},[5]={{"summoner",fts(50),1,1,180},{"summoner",fts(650),1,1,180},{"summoner",fts(1150),1,1,180}},[6]={{"powers",fts(50),1800,4,5,{0,1},13}},[8]={{"summoner",fts(80),2,0,200},{"summoner",fts(300),2,1,200},{"summoner",fts(700),2,0,200},{"summoner",fts(950),2,1,200}},[9]={{"powers",fts(150),3000,4,5,{1,0},11},{"powers",fts(1250),3000,3,4,{0.25,0.75},18}},[11]={{"summoner",fts(20),3,0,250},{"summoner",fts(420),4,1,250},{"summoner",fts(1000),3,0,250},{"summoner",fts(1000),4,1,250}},[12]={{"powers",fts(10),4200,4,5,{0.3,0.7},20},{"powers",fts(950),4200,3,4,{0.3,0.7},18}},[15]={{"summoner",fts(20),5,0,250},{"summoner",fts(20),5,1,250},{"powers",fts(250),5400,3,4,{0.3,0.7},18},{"powers",fts(850),5400,3,4,{0.3,0.7},18},{"summoner",fts(1050),5,0,250},{"summoner",fts(1050),5,1,250},{"fight",fts(2300)},{"summoner",fts(6000),5,1,300},{"summoner",fts(6000),5,0,300}}}
self.boss_fight_rounds={{6000,4,5,{0.3,0.7},20,{6,6},{4,2,4},2,3},{6000,3,4,{0,1},20,{7,7},{5,3,5},5,3},{8400,2,3,{0,1},12,{7,7,7},{5,3,2},2,3}}
end
function level:update(store)
self.portals=LU.list_entities(store.entities,"decal_drow_queen_portal")
table.sort(self.portals,function(e1,e2)
return tonumber(e1.editor.tag)<tonumber(e2.editor.tag)
end)
self.door_glows=LU.list_entities(store.entities,"decal_s11_door_glow")
table.sort(self.door_glows,function(e1,e2)
return tonumber(e1.editor.tag)<tonumber(e2.editor.tag)
end)
self.runes=LU.list_entities(store.entities,"decal_s11_zealot_rune")
table.sort(self.runes,function(e1,e2)
return tonumber(e1.editor.tag)<tonumber(e2.editor.tag)
end)
self.megaspawner=LU.list_entities(store.entities,"mega_spawner")[1]
if store.level_mode~=GAME_MODE_CAMPAIGN then
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
local boss=E:create_entity("eb_drow_queen")
boss.path_id_throne=10
boss.pos=V.vclone(boss.pos_sitting)
boss.portals=self.portals
boss.portal_packs=self.portal_packs
boss.megaspawner=self.megaspawner
boss.fight_rounds=self.boss_fight_rounds
boss.phase_signal=nil
boss.cast_pi=10
self.boss=boss
LU.queue_insert(store,boss)
coroutine.yield()
if not store.restarted then
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=1000,y=400},2)
signal.emit("hide-gui")
end
U.y_wait_unconditional(store,1)
boss.phase_signal="welcome"
boss.phase_params=0
while self.boss.phase~="prebattle" do
coroutine.yield()
end
if not store.restarted then
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
end
while store.wave_group_number<1 do
coroutine.yield()
end
self.boss.phase_signal="sitting"
while self.boss.phase~="mactans" do
self:y_boss_wave(store,store.wave_group_number)
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=680,y=400},2)
signal.emit("hide-gui",true)
while self.boss.phase~="dead" do
coroutine.yield()
end
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
U.y_wait_unconditional(store,2.5)
end
end
function level:y_boss_wave(store,wave_number)
local groups=self.boss_waves[wave_number]
if not groups then
return
end
local start_ts=store.tick_ts
for _,group in pairs(groups) do
local t_elapsed=store.tick_ts-start_ts
local t_total=group[2]
local t_actual=km.clamp(0,t_total,t_total-t_elapsed)
log.debug("wave_number:%s waiting:%s type:%s",wave_number,t_actual,group[1])
if U.y_wait_conditional(store,t_actual,function(store,time)
return store.wave_group_number~=wave_number or self.boss.health.dead
end) then
return
end
if group[1]=="summoner" then
local _,_,pack_idx,conf_idx,hp=unpack(group)
local cfg=self.summoner_config[conf_idx]
hp=10*math.ceil(hp*GS.difficulty_enemy_hp_max_factor[store.level_difficulty]/10)
local zealots=table.filter(store.entities,function(_,e)
return e.template_name=="enemy_zealot" and e.nav_path.pi==cfg.summoner_pi and not e.is_summoning
end)
for _,e in pairs(zealots) do
log.debug("killing idle zealot: %s",e.id)
e.health.hp=0
end
local door_glow=self.door_glows[cfg.portal_idx]
if door_glow then
door_glow.tween.disabled=false
door_glow.tween.ts=store.tick_ts
end
self.boss.phase_signal="summoner"
local e=E:create_entity("enemy_zealot")
e.nav_path.pi=cfg.summoner_pi
e.health.hp=hp
e.health.hp_max=hp
e.portal_pack={pi=cfg.spawn_pi,waves=self.portal_packs[pack_idx]}
e.portal=self.portals[cfg.portal_idx]
e.rune=self.runes[cfg.portal_idx]
LU.queue_insert(store,e)
else
self.boss.phase_signal=group[1]
self.boss.phase_params=group
end
if store.wave_group_number~=wave_number or self.boss.health.dead then
return
end
end
while store.wave_group_number==wave_number and not self.boss.health.dead do
coroutine.yield()
end
end
return level
