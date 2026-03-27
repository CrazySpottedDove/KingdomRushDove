local M = {}

function M.register(sys, deps)
	local F = deps.F
	local I = deps.I

	sys.texts = {}
	sys.texts.name = "texts"

	function sys.texts:on_insert(entity, store)
		if entity.texts then
			for _, t in pairs(entity.texts.list) do
				local sprite_id = t.sprite_id
				local image_name = string.format("text_%s_%s_%s", entity.id, sprite_id, store.tick_ts)
				local image = F:create_text_image(t.text, t.size, t.alignment, t.font_name, t.font_size, t.color, t.line_height, store.screen_scale, t.fit_height, t.debug_bg)

				I:add_image(image_name, image, "temp_game_texts", store.screen_scale)

				t.image_name = image_name
				t.image_group = "texts"
				entity.render.sprites[sprite_id].name = image_name
				entity.render.sprites[sprite_id].animated = false
			end
		end

		return true
	end

	function sys.texts:on_remove(entity, store)
		if entity.texts then
			for _, t in pairs(entity.texts.list) do
				if t.image_name then
					I:remove_image(t.image_name)
				end
			end
		end

		return true
	end
end

return M
