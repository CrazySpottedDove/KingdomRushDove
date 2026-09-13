if not ASSETS_CHECK_ENABLED then
	return false
end

local assets_checker = {}

local log = require("lib.klua.log"):new("systems")
local E = require("entity_db")
local I = require("lib.klove.image_db")

assets_checker.name = "assets_checker"

function assets_checker:init(store)
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
		log.error(_("ASSETS_CHECK_PORTRAIT_HEADER"))

		for ename, img in pairs(info_portraits_check_result) do
			log.error(_("ASSETS_CHECK_ENTITY_MISSING"), ename, img)
		end
	end

	if next(tower_menu_images_check_result) ~= nil then
		log.error(_("ASSETS_CHECK_TOWER_MENU_HEADER"))

		for tname, imgs in pairs(tower_menu_images_check_result) do
			for _i, img in pairs(imgs) do
				log.error(_("ASSETS_CHECK_ENTITY_MISSING"), tname, img)
			end
		end
	end
end

return assets_checker
