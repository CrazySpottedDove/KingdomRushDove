local V=require("lib.klua.vector")
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
return {{id="kr5_map_state",image=nil,layer=1,pos=v(0,0),fns={prepare=deco_fn.kr5_map_state.prepare}}}
