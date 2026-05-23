local M = {}

local F = require("lib.klove.font_db")
local I = require("lib.klove.image_db")

function M.register(sys)

	sys.texts = {}
	sys.texts.name = "texts"

	function sys.texts:on_insert_unconditional(entity, store)
		if entity.texts then
			for _, t in pairs(entity.texts.list) do
				local sprite_id = t.sprite_id
				local image_name = "_tmp_text_" .. t.text

				if not I.db_images[image_name] then
					local group = "temp_game_texts"
					local scale = store.screen_scale
					local image = F:create_text_image(t.text, t.size, t.alignment, t.font_name, t.font_size, t.color, t.line_height, store.screen_scale, t.fit_height, t.debug_bg)
					I:add_image(image_name, image, group, scale)

					-- 标记 atlas 引用计数，保证卸载正常
					I.atlas_uses[string.format("%s-%.6f", group, scale)] = 1
				end

				-- local group = "temp_game_texts"
				-- local scale = store.screen_scale

				-- -- 避免重复创建文本 atlas
				-- if I.atlas_uses[name_scale] and I.atlas_uses[name_scale] > 0 then
				-- -- I.atlas_uses[name_scale] = I.atlas_uses[name_scale] + 1
				-- else
				-- 	local image = F:create_text_image(t.text, t.size, t.alignment, t.font_name, t.font_size, t.color, t.line_height, store.screen_scale, t.fit_height, t.debug_bg)
				-- 	I:add_image(image_name, image, group, scale)
				-- end

				t.image_name = image_name
				t.image_group = "texts"
				entity.render.sprites[sprite_id].name = image_name
				entity.render.sprites[sprite_id].animated = false
			end
		end

		return true
	end

	function sys.texts:on_remove_unconditional(entity, store)
		if entity.texts then
			for _, t in pairs(entity.texts.list) do
				if t.image_name then
					-- 不需要调用 remove，作为缓存就好了，等待 game 卸载时一起卸载
					-- I:remove_image(t.image_name)
					-- 跳过绘制，避免执行了 remove_image 后，由于 on_render_update 未执行即调用 draw 导致的找不到纹理错误
					entity.render.sprites[t.sprite_id].hidden = true
				end
			end
		end

		return true
	end
end

return M
