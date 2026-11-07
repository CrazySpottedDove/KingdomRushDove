local V=require("lib.klua.vector")
local v=V.v
local deco_fn=require("map_decos_functions")
local ani_paths=require("data.map_animations_paths")
local ani_paths2=require("data.map_animations_paths2")
local i18n=require("i18n")
local function CJK(default,zh,ja,kr)
return i18n.cjk(i18n,default,zh,ja,kr)
end
local function fc(r,g,b,a)
return {r/255,g/255,b/255,a/255}
end
return {{layer=2,id="md_gate",image="ma_gate_0001",trigger_level=7,pos=v(680,836),fns={unlock=deco_fn.gate.unlock}},{loop=true,layer=2,id="ship",image="big_ship_0001",trigger_level=6,pos=v(0,0),fns={prepare=deco_fn.ship.prepare,unlock=deco_fn.ship.unlock,update=deco_fn.ship.update},animations={down_stopped={to=225,prefix="big_ship",from=181},down={to=45,prefix="big_ship",from=1},down_side={to=90,prefix="big_ship",from=46},side={to=135,prefix="big_ship",from=91},side_stopped={to=180,prefix="big_ship",from=136}}}}
