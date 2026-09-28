local log=require("lib.klua.log"):new("level11")
local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local bit=require("bit")
local AC=require("achievements")
local E=require("entity_db")
local P=require("path_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local function fts(v)
return v/FPS
end
local v=V.v
local OX=-35
local level={}
level.required_sounds={"music_stage37","FrontiersJungleAmbienceSounds","SpecialAlienSounds","SpecialIndianaSounds","BossMonkey"}
level.required_textures={"go_enemies_jungle","go_stages_jungle","go_stage37","go_stage37_bg","go_stage36"}
function level:init(store)
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local r=V.r
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_indiana_boulder_update(this,store)
while not U.walk_off__accel__unsnapped(this,store.tick_length) do
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_monkey_corps_1","decal_tween",true)
tt.render.sprites[1].name="decal_monkey_corps_1"
tt.tween.remove=false
tt.tween.props[1].loop=true
tt.tween.props[1].name="flip_x"
tt.tween.props[1].keys={{0,false},{3,true},{6,false}}
tt=E:register_t_hot("decal_monkey_corps_2","decal",true)
tt.render.sprites[1].name="decal_monkey_corps_2"
tt=E:register_t_hot("decal_monkey_corps_3","decal_delayed_sequence",true)
tt.render.sprites[1].prefix="decal_monkey_corps_3"
tt.render.sprites[1].name="idle"
tt.delayed_sequence.animations={"jump","jump","jump","idle"}
tt.delayed_sequence.min_delay=0
tt.delayed_sequence.max_delay=1
tt=E:register_t_hot("indiana_puzzle_button_a","decal",true)
AC(tt,"ui")
tt.render.sprites[1].name="idle"
tt.render.sprites[1].prefix="indiana_puzzle_button_a"
tt.render.sprites[1].z=Z_DECALS+6
tt.ui.can_click=false
tt.ui.click_rect=r(-22,-22,44,44)
tt.puzzle_value=1
tt=E:register_t_hot("indiana_puzzle_button_b","indiana_puzzle_button_a",true)
tt.render.sprites[1].prefix="indiana_puzzle_button_b"
tt.puzzle_value=2
tt=E:register_t_hot("indiana_puzzle_button_c","indiana_puzzle_button_a",true)
tt.render.sprites[1].prefix="indiana_puzzle_button_c"
tt.puzzle_value=3
tt=E:register_t_hot("decal_indiana","decal_tween",true)
tt.render.sprites[1].prefix="decal_indiana"
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_DECALS+4
tt.tween.disabled=true
tt.tween.props[1].name="alpha"
tt.tween.props[1].keys={{0,255},{1,0}}
tt=E:register_t_hot("decal_indiana_question_marks","decal_timed",true)
tt.render.sprites[1].name="decal_indiana_question_marks"
tt.timed.runs=5
tt=E:register_t_hot("decal_indiana_boulder","decal_scripted",true)
AC(tt,"motion")
tt.render.sprites[1].name="decal_indiana_boulder"
tt.render.sprites[1].z=Z_DECALS+4
tt.motion.max_speed=3.9*FPS
tt.main_script.update=decal_indiana_boulder_update
store.level_terrain_style=TERRAIN_STYLE_JUNGLE
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.locked_powers={}
if store.level_mode==GAME_MODE_CAMPAIGN then
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.max_upgrade_level=5
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.max_upgrade_level=5
self.locked_towers={"tower_build_archer","tower_build_barrack"}
end
end
function level:load(store)
LU.insert_background(store,"Stage11_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage11_0002",Z_OBJECTS,575)
LU.insert_background(store,"Stage11_0003",Z_DECALS+5)
LU.insert_background(store,"Stage11_0004",Z_DECALS+5)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
self.hidden_holders={}
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if table.contains({"15","3","6","8","10"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_jungle",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
elseif store.level_mode==GAME_MODE_IRON then
for _,h in pairs(self.locations.holders) do
if table.contains({"7","8"},h.id) then
e=LU.insert_tower(store,"tower_necromancer",h.style,h.pos,h.rally_pos,nil,h.id)
e.powers.rider.level=1
e.powers.rider.changed=true
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{x,x,x,x},{x,x,x,x},{4,6,x,16},{9,6,3,7},{14,7,15,x},{4,x,3,3},{8,4,16,5},{11,9,7,13},{10,x,4,8},{x,x,9,11},{x,10,8,12},{11,13,14,x},{11,8,x,12},{12,13,5,x},{5,16,x,x},{7,3,x,15},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x}}
local e
local temple_fires={v(460+OX,566),v(459+OX,527),v(625+OX,527),v(625+OX,566)}
for _,pos in pairs(temple_fires) do
e=E:create_entity("decal")
e.render.sprites[1].name="decal_temple_fire"
e.render.sprites[1].loop=true
e.render.sprites[1].z=Z_OBJECTS
e.render.sprites[1].ts=U.frandom(0,0.3)
e.render.sprites[1].anchor=v(0.5,0)
e.pos=pos
LU.queue_insert(store,e)
end
e=E:create_entity("decal")
e.render.sprites[1].prefix="decal_indiana_top_door"
e.render.sprites[1].loop=false
e.render.sprites[1].z=Z_DECALS
e.pos=v(847+OX,703)
LU.queue_insert(store,e)
self.decal_top_door=e
e=E:create_entity("decal")
e.render.sprites[1].prefix="decal_indiana_side_door"
e.render.sprites[1].loop=false
e.render.sprites[1].z=Z_DECALS
e.pos=v(880+OX,628)
LU.queue_insert(store,e)
self.decal_side_door=e
if store.level_mode~=GAME_MODE_CAMPAIGN then
e=E:create_entity("decal")
e.render.sprites[1].name="boss_corps_monkeyCrown"
e.render.sprites[1].animated=false
e.pos=v(219+OX,622)
LU.queue_insert(store,e)
e=E:create_entity("decal_monkey_corps_1")
e.pos=v(272+OX,623)
LU.queue_insert(store,e)
e=E:create_entity("decal_monkey_corps_2")
e.pos=v(223+OX,660)
LU.queue_insert(store,e)
e=E:create_entity("decal_monkey_corps_3")
e.pos=v(300+OX,671)
LU.queue_insert(store,e)
end
e=E:create_entity("decal")
e.render.sprites[1].prefix="decal_boss_tower"
e.render.sprites[1].anchor.y=0.16
e.render.sprites[1].z=Z_OBJECTS
e.pos=v(542+OX,327)
LU.queue_insert(store,e)
self.boss_tower=e
local alien_egg_coords={{pi=2,pos=v(946+OX,592)},{pi=2,pos=v(978+OX,579)},{pi=2,pos=v(974+OX,609)},{pi=2,pos=v(1006+OX,595)}}
self.alien_eggs={}
for _,item in pairs(alien_egg_coords) do
local e=E:create_entity("alien_egg")
e.render.sprites[1].z=Z_DECALS
e.pos=item.pos
e.spawner.pi=item.pi
e.spawner.ni=106
LU.queue_insert(store,e)
table.insert(self.alien_eggs,e)
end
if store.level_mode==GAME_MODE_CAMPAIGN then
e=E:create_entity("decal_indiana")
e.pos=v(892+OX,669)
LU.queue_insert(store,e)
self.decal_indiana=e
self.puzzle_attempts=0
end
self.puzzle_buttons={}
e=E:create_entity("indiana_puzzle_button_a")
e.pos=v(702+OX,626)
LU.queue_insert(store,e)
table.insert(self.puzzle_buttons,e)
e=E:create_entity("indiana_puzzle_button_b")
e.pos=v(764+OX,626)
LU.queue_insert(store,e)
table.insert(self.puzzle_buttons,e)
e=E:create_entity("indiana_puzzle_button_c")
e.pos=v(827+OX,626)
LU.queue_insert(store,e)
table.insert(self.puzzle_buttons,e)
e=E:create_entity("background_sounds_jungle")
LU.queue_insert(store,e)
end
function level:update(store)
local puzzle_sequence={}
local puzzle_solution={2,1,3}
local flip_ts
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<6 do
coroutine.yield()
end
S:queue("SpecialIndianaRuns")
self.decal_indiana.render.sprites[1].hidden=false
U.y_animation_play(self.decal_indiana,"enter",nil,store.tick_ts)
U.animation_start_default(self.decal_indiana,"idle",nil,store.tick_ts,false)
flip_ts=store.tick_ts
for _,b in pairs(self.puzzle_buttons) do
U.animation_start_default(b,"flash",nil,store.tick_ts,false)
b.ui.can_click=true
end
while not store.waves_finished do
if store.tick_ts-flip_ts>5 then
flip_ts=store.tick_ts
local a
a=self.decal_indiana.render.sprites[1].name=="idle" and "idle2" or "idle"
U.animation_start_default(self.decal_indiana,a,nil,store.tick_ts,false)
local qm=E:create_entity("decal_indiana_question_marks")
qm.render.sprites[1].ts=store.tick_ts
qm.pos=v(734+OX,738)
LU.queue_insert(store,qm)
end
if #puzzle_sequence==3 then
local success=true
for i,r in ipairs(puzzle_sequence) do
if r~=puzzle_solution[i] then
success=false
break
end
end
if success then
log.debug("PUZZLE SUCCESS")
for _,b in pairs(self.puzzle_buttons) do
b.ui.can_click=false
end
self:y_puzzle_complete(store)
goto label_4_0
else
log.debug("PUZZLE ERROR")
puzzle_sequence={}
self:y_puzzle_failed(store)
end
else
for _,b in pairs(self.puzzle_buttons) do
if b.ui.clicked then
b.ui.clicked=false
S:queue("SpecialIndianaSelect")
U.animation_start_default(b,"active",nil,store.tick_ts,false)
table.insert(puzzle_sequence,b.puzzle_value)
end
end
end
coroutine.yield()
end
self.decal_indiana.tween.disabled=nil
self.decal_indiana.render.sprites[1].ts=store.tick_ts
::label_4_0::
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
U.y_wait_unconditional(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2.5,{x=660,y=460},1.95)
signal.emit("hide-gui")
S:queue("MusicBossPreFight")
S:queue("BossMonkeyTotemSpawn")
U.y_animation_play(self.boss_tower,"raise",nil,store.tick_ts,1)
local boss=E:create_entity("eb_gorilla")
boss.tower_pos_left=v(500+OX,370)
boss.tower_pos_right=v(584+OX,370)
boss.nav_path.pi=2
boss.nav_path.spi=1
boss.nav_path.ni=104
boss.pos=P:node_pos(boss.nav_path.pi,boss.nav_path.spi,boss.nav_path.ni)
boss.pos.y=boss.pos.y+300
LU.queue_insert(store,boss)
self.boss=boss
U.y_wait_unconditional(store,3)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
U.y_wait_unconditional(store,3)
end
log.debug("-- WON")
end
function level:y_puzzle_complete(store)
local boulder_from=v(830+OX,626)
local boulder_to=v(1071+OX+65,580)
local decal_boulder=E:create_entity("decal_indiana_boulder")
decal_boulder.pos=boulder_from
U.set_destination(decal_boulder,boulder_to)
S:queue("SpecialIndiana")
S:queue("SpecialIndianaSelect")
U.y_animation_play(self.decal_top_door,"open",nil,store.tick_ts)
U.animation_start_default(self.decal_indiana,"jump",nil,store.tick_ts,false)
U.y_wait_unconditional(store,2)
S:queue("SpecialIndianaSelect")
U.y_animation_play(self.decal_side_door,"open",nil,store.tick_ts)
U.y_wait_unconditional(store,1)
S:queue("SpecialIndianaRuns")
U.animation_start_default(self.decal_indiana,"exit",nil,store.tick_ts,false)
U.y_wait_unconditional(store,0.25)
LU.queue_insert(store,decal_boulder)
U.y_wait_unconditional(store,1)
for _,e in pairs(self.alien_eggs) do
e.do_destroy=true
end
U.y_wait_unconditional(store,1)
end
function level:y_puzzle_failed(store)
self.puzzle_attempts=self.puzzle_attempts+1
for _,b in pairs(self.puzzle_buttons) do
U.animation_start_default(b,"flash",nil,store.tick_ts,false)
end
for i=1,math.min(self.puzzle_attempts,#self.alien_eggs) do
self.alien_eggs[i].do_spawn=true
end
end
return level
