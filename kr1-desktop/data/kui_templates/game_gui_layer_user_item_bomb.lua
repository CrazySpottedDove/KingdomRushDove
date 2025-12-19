-- chunkname: @./kr1-desktop/data/kui_templates/game_gui_layer_user_item_bomb.lua
local SW = ctx.SW
local WH = ctx.SH

return {
	id = "layer_user_item_bomb",
	propagate_on_down = true,
	class = "KView",
	hidden = true,
	propagate_on_click = true,
	propagate_on_up = true,
	size = v(SW, WH),
	colors = {
		background = {255, 255, 255, 255}
	}
}
