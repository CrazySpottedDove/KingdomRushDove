-- chunkname: @./mods/all/mod_utils.lua
local log = require("lib.klua.log"):new("mod_utils")
local FS = love.filesystem
local mod_paths = require("mod_paths")

local mod_utils = {}

--- 获取指定路径下的所有子目录名
---
--- 返回一个包含子目录信息的表，每个元素包含name(子目录名)和path(完整路径)
---@param path string 要扫描的目录路径
---@param filter_fn function 过滤函数
---@return table 包含子目录信息的表
function mod_utils.get_subdirs(path, filter_fn)
	-- 获取目录下所有文件和子目录
	local files = FS.getDirectoryItems(path)

	-- 检查路径是否存在
	if not files then
		log.error("Path does not exist: %s", path)

		return {}
	end

	local files_count = #files

	-- 检查目录是否为空
	if files_count == 0 then
		log.debug("No files found in path: %s", path)
	end

	local file_datas = {}

	-- 遍历目录下的所有项目
	for i = 1, files_count do
		local file = files[i]
		-- 构建完整文件路径
		local filepath = path .. "/" .. file

		-- 过滤
		if (not filter_fn or filter_fn(file, filepath)) and FS.isDirectory(filepath) then
			local file_data = {
				name = file,
				path = filepath
			}

			table.insert(file_datas, file_data)
		end
	end

	return file_datas
end

--- 将表转化为字符串，返回的字符串无键值与大括号
---@param t table 表
---@return string 字符串
function mod_utils.table_tostring(t)
	if type(t) ~= "table" then
		return tostring(t)
	end

	local items = {}

	for k, v in pairs(t) do
		local value_str

		if type(v) == "string" then
			value_str = v
		elseif type(v) == "table" then
			value_str = "{" .. self.table_tostring(t) .. "}"
		else
			value_str = tostring(v)
		end

		table.insert(items, value_str)
	end

	return table.concat(items, ", ")
end

--- DEPRECATED: 建议直接注册。
--- 用于为插件提供自定义的资源加载方式。使用该方式加载的资源索引，不需要提前打包成 bytecode 格式。建议在 screen_loading 的 init 函数钩子的前面调用本函数，这样就可以让插件的资源和本体的资源一起加载。
---@param groups table 美术资源组(如：想加载 go_foo.lua，就给 {"go_foo"})
---@param path string 美术资源父路径(如：插件entry名称/assets)
---@param ref_height number 参考高度(如：game.ref_res)
---@param queue boolean 是否使用队列加载(true)或直接加载(false)
---@param item_name string scene 名称（可在 director_data里查找）
function mod_utils.load_texture_groups(groups, path, ref_height, queue, item_name)
	local director = require("director")
	local scale = director:get_texture_scale(item_name, ref_height)
	local I = require("lib.klove.image_db")
	for _, group in pairs(groups) do
		if queue then
			I:queue_load_atlas(scale, "plugins/" .. path, group, true)
		else
			I:load_atlas(scale, "plugins/" .. path, group)
		end
	end
end

return mod_utils
