local V=require("lib.klua.vector")
local v=V.v
local OFFSET=v(0,0)
local flags={{number="201",pos=v(928.8,583.75)},{number="202",pos=v(631.95,532.5)},{number="203",pos=v(524.6,662)},{number="204",pos=v(395.45,786.05)},{number="205",pos=v(717.15,819.95)},{number="206",pos=v(1096.9,746.15)},{number="207",pos=v(1177.15,967.7)},{number="208",pos=v(1353.15,917.75)},{number="209",pos=v(1594.4,619.75)},{number="210",pos=v(1494.85,572.95)},{number="211",pos=v(1363.8,453.55)},{number="212",pos=v(1329,316.75)},{number="213",pos=v(1481.55,401.4)},{number="214",pos=v(1754.3,416.9)},{number="215",pos=v(1921.65,454.55)},{number="216",pos=v(2149.15,561.8)},{number="217",pos=v(1925.25,733.95)},{number="218",pos=v(2034.2,841.65)}}
local endless_flags={}
local points={}
for _,f in ipairs(flags) do
f.pos.x=f.pos.x+OFFSET.x
f.pos.y=f.pos.y+OFFSET.y
end
for _,f in ipairs(endless_flags) do
f.pos.x=f.pos.x+OFFSET.x
f.pos.y=f.pos.y+OFFSET.y
end
for _,point in ipairs(points) do
point.pos.x=point.pos.x+OFFSET.x
point.pos.y=point.pos.y+OFFSET.y
end
return {flags=flags,endless_flags=endless_flags,points=points}
