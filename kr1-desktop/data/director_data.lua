local d={}
d.item_props={splash={src="screen_splash",next="slots",type="screen"},slots={src="screen_slots",show_loading=false,type="screen"},credits={src="screen_credits",next="slots",type="screen"},map={src="screen_map",show_loading=true,type="screen"},game={show_loading=true,next="map",type="game"},kr1_end={src="screen_kr1_end",next="map",type="screen"},kr2_end={src="screen_kr2_end",next="map",type="screen"},game_editor={src="game_editor",show_loading=false,scissor=false,type="screen"}}
return d
