-- chunkname: @./all/debug_view_editor.lua
local log = require("lib.klua.log"):new("debug_view_editor")
local km = require("lib.klua.macros")

dbe = {}

function dbe:inject_editor(root_view, screen)
	self.screen = screen

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == ShopItemView
	end)) do
		self:inject_on_click(l, screen)
	end

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == ShopBagItemView
	end)) do
		self:inject_on_click(l, screen)
	end

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == GGLabel
	end)) do
		self:inject_on_click(l, screen)
	end

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == KImageView
	end)) do
		self:inject_on_click(l, screen)
	end

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == GGImageButton
	end)) do
		self:inject_on_click(l, screen)
	end

	for _, l in pairs(root_view:flatten(function(v)
		return v.class == KImageButton
	end)) do
		self:inject_on_click(l, screen)
	end
end

function dbe:inject_on_click(label, screen)
	log.debug(" + injecting %s", label)

	function label.on_click(this)
		if screen.SEL_VIEW and screen.SEL_VIEW._debug_old_bg_color then
			if screen.SEL_VIEW._debug_old_bg_color == "none" then
				screen.SEL_VIEW.colors.background = nil
			else
				screen.SEL_VIEW.colors.background = screen.SEL_VIEW._debug_old_bg_color
			end

			screen.SEL_VIEW._debug_old_bg_color = nil
		end

		screen.SEL_VIEW = this
		this._debug_old_bg_color = this.colors and this.colors.background or "none"
		this.colors.background = {255, 0, 0, 100}

		log.debug("SEL_VIEW: %s", this.text)
	end
end

function dbe:keypressed(selected_view, key, isrepeat)
	if not selected_view then
		return
	end

	local av = selected_view
	local inc = 1
	local shift = love.keyboard.isDown("lshift")
	local ctrl = love.keyboard.isDown("lctrl")

	if shift then
		inc = 20
	end

	if ctrl then
		if key == "up" then
			av.size.y = av.size.y - inc
		elseif key == "down" then
			av.size.y = av.size.y + inc
		elseif key == "right" then
			av.size.x = av.size.x + inc
		elseif key == "left" then
			av.size.x = av.size.x - inc
		end
	elseif key == "up" then
		av.pos.y = av.pos.y - inc
	elseif key == "down" then
		av.pos.y = av.pos.y + inc
	elseif key == "right" then
		av.pos.x = av.pos.x + inc
	elseif key == "left" then
		av.pos.x = av.pos.x - inc
	end

	if key == "7" then
		av.r = av.r - 5 * math.pi / 180
	elseif key == "8" then
		av.r = av.r + 5 * math.pi / 180
	end

	if av.class == GGLabel or av.class == GGImageButton then
		if key == "-" then
			av.font_size = km.clamp(1, 200, av.font_size - 1)
			av.font = nil
		elseif key == "=" then
			av.font_size = km.clamp(1, 200, av.font_size + 1)
			av.font = nil
		end

		if key == "0" then
			if av.text_align == "left" then
				av.text_align = "center"
			elseif av.text_align == "center" then
				av.text_align = "right"
			elseif av.text_align == "right" then
				av.text_align = "left"
			end
		end
	end

	if key == "h" then
		av.hidden = not av.hidden
	end

	if key == "9" and av.colors then
		if not av.colors.background then
			av.colors.background = {0, 200, 200, 150}
		else
			av.colors.background = nil
		end
	end

	if key == "s" then
		local inc = shift and -0.01 or 0.01

		av.scale.x = av.scale.x + inc
		av.scale.y = av.scale.y + inc
	end

	if key == "p" then
		local v = self.screen.SEL_VIEW

		if v and v.parent then
			log.info("selecting %s:%s parent of %s", v.parent.id, v.parent, v)

			self.screen.SEL_VIEW = v.parent
		end
	end

	if key == "space" or key == "return" then
		local out = string.format("pos=v(%s,%s), size=v(%s,%s), font_size=%s, text_align='%s', text='%s'\n", av.pos.x, av.pos.y, av.size.x, av.size.y, av.font_size, av.text_align, av.text)

		log.info("\n%s\n", out)

		if av and av.parent then
			local out = "---------------------------\n"

			for _, vv in ipairs(av.parent.children) do
				local oo = ""

				if vv.id then
					oo = oo .. string.format("id='%s', ", vv.id)
				end

				local o = string.format("pos=v(%3i,%3i), ", vv.pos.x, vv.pos.y)

				if vv.class == GGLabel then
					o = o .. string.format("size=v(%3i,%3i), ", vv.size.x, vv.size.y)
				end

				if vv.r ~= 0 then
					o = o .. string.format("r=rad(%i), ", vv.r * 180 / math.pi)
				end

				if vv.scale.x ~= 1 or vv.scale.y ~= 1 then
					o = o .. string.format("scale=v(%.2f,%.2f), ", vv.scale.x, vv.scale.y)
				end

				if vv.class == GGLabel then
					o = o .. string.format("font_size=%2i, ", vv.font_size)
					oo = oo .. string.format("text_align='%s', text='%s'", vv.text_align, string.gsub(vv.text, "\n", " "))
				elseif vv.class == KImageView then
					oo = oo .. string.format("image_name=%s", vv.image_name)
				elseif vv.class == GGImageButton then
					oo = oo .. string.format("default_image_name=%s", vv.default_image_name)

					if vv.text ~= "" then
						o = o .. string.format("font_size=%2i, ", vv.font_size)
					end
				end

				if key == "space" then
					out = out .. string.format("%s\n", o)
				else
					local fill = string.rep(" ", 70 - string.len(o))

					out = out .. string.format("%s%s || %s\n", o, fill, oo)
				end
			end

			out = out .. "---------------------------\n"

			log.info("\n%s\n", out)
		end
	end
end

return dbe
