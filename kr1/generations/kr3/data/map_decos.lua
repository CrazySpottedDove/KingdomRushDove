local V=require("lib.klua.vector")
local v=V.v
local r=V.r
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
return {{layer=3,id="md_ft_mountain",image="kr3_map_background_0002",trigger_level=21,pos=v(960,540),hit_rect=r(1240,110,300,240),fns={unlock=deco_fn.md_ft_mountain.unlock}}}
