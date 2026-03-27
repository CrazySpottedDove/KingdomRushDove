local M = {}

function M.register(sys, deps)
	if not deps.ASSETS_CHECK_ENABLED then
		return
	end

	local E = deps.E
	local I = deps.I
	local log = deps.log

	sys.assets_checker = {}
	sys.assets_checker.name = "assets_checker"

	function sys.assets_checker:init(store)
		local info_portraits_check_result = {}

		for _, e in pairs(E.entities) do
			if e.info and e.info.portrait then
				local s = I:s(e.info.portrait)

				if s == nil then
					info_portraits_check_result[e.template_name] = e.info.portrait
				end
			end
			if e.timed_attacks and not e.timed_attacks.list[1] then
				log.error("Entity %s has timed_attacks component but empty list", e.template_name)
			end
		end

		local tower_menu_images_check_result = {}
		local tower_menus_data = require("kr1.data.tower_menus_data")

		for tower_name, tower_menus in pairs(tower_menus_data) do
			for _, tower_menus_item in pairs(tower_menus) do
				for _, tower_menus_sub_item in pairs(tower_menus_item) do
					if tower_menus_sub_item.image then
						local s = I:s(tower_menus_sub_item.image)

						if s == nil then
							if not tower_menu_images_check_result[tower_name] then
								tower_menu_images_check_result[tower_name] = {}
							end

							tower_menu_images_check_result[tower_name][#tower_menu_images_check_result[tower_name] + 1] = tower_menus_sub_item.image
						end
					end
				end
			end
		end

		if next(info_portraits_check_result) ~= nil then
			log.error("=== info.portrait 资源缺失检查 ===")

			for ename, img in pairs(info_portraits_check_result) do
				log.error("实体 %s 缺失资源 %s", ename, img)
			end
		end

		if next(tower_menu_images_check_result) ~= nil then
			log.error("=== tower_menus_data 资源缺失检查 ===")

			for tname, imgs in pairs(tower_menu_images_check_result) do
				for _, img in pairs(imgs) do
					log.error("实体 %s 缺失资源 %s", tname, img)
				end
			end
		end
	end
end

return M
