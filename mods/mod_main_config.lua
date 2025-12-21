return {
	-- 总控，关闭后禁用模组管理器
	enabled = false,
	not_mod_path = {"mod_template", "all"},
	ignored_path = {"_assets"},
	ppref = love.filesystem.isFused() and "" or "src/",
	check_paths = {"/_assets/images", "/_assets/sounds/settings.lua", "/_assets/sounds/sounds.lua", "/_assets/sounds/groups.lua", "/_assets/sounds/extra.lua", "/_assets/sounds/files", "/data/levels", "/data/waves"}
}
