local M = {}
local G = love.graphics
local FS = love.filesystem

-- 本模块只在非安卓平台启用
local apply_upgrade = love.system.getOS() ~= "Android"
local ok, update_cfg = pcall(dofile, "update.lua")

if (ok and type(update_cfg) == "table" and update_cfg.auto_upgrade == false) or (arg[2] == "debug" or arg[2] == "release") then
	apply_upgrade = false
end

local is_windows = package.config:sub(1, 1) == "\\"

-- 更新状态定义
local STATE_DOWNLOADING_ASSETS = 1
local STATE_DOWNLOADING_CODE = 2
local STATE_COMMITTING_CHANGES = 3
local STATE_STRING_MAP = {
	[STATE_DOWNLOADING_ASSETS] = "下载美术资源中（可能需要较长时间）……",
	[STATE_DOWNLOADING_CODE] = "下载代码资源中……",
	[STATE_COMMITTING_CHANGES] = "提交更新事务中……"
}
local state = STATE_DOWNLOADING_ASSETS
local update_log_line_max_count = 20
-- 日志系统
local update_log_lines = {}
local error_log_lines = {}

-- 统一的更新界面绘制函数
local function update_draw_func()
	local font = require("lib.klove.font_db"):f("msyh", 20)
	G.clear(0, 0, 0)
	G.origin()
	G.setFont(font)
	G.setColor(1, 1, 1, 1)

	local w, h = G.getDimensions()
	local text = STATE_STRING_MAP[state]
	local tw = font:getWidth(text)
	local th = font:getHeight()
	G.print(text, (w - tw) / 2, (h - th) / 3)

	-- 显示升级日志
	G.setColor(1, 1, 1, 1)
	local log_y = (h - th) / 3 + 60
	for i, line in ipairs(update_log_lines) do
		G.print(line, 40, log_y + (i - 1) * 22)
	end
	G.present()
end

-- 记录普通日志
local function log_info(line)
	table.insert(update_log_lines, line)
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	update_draw_func()
end

-- 记录错误日志
local function log_error(line)
	table.insert(update_log_lines, "[错误] " .. line)
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	table.insert(error_log_lines, line) -- 同时存入错误报告
	update_draw_func()
end

local function set_state(new_state)
	state = new_state
	log_info(STATE_STRING_MAP[state])
end

-- 文件系统操作封装
local function ensure_parent_dir(file_path)
	local parent_dir = file_path:match("(.+)[/\\]")
	if parent_dir then
		if is_windows then
			return os.execute('mkdir "' .. parent_dir .. '" >nul 2>nul')
		else
			return os.execute('mkdir -p "' .. parent_dir .. '" >/dev/null 2>&1')
		end
	end
	return true -- 在根目录，无需创建
end

local function write_file(file_path, content)
	local f, err = io.open(file_path, "wb")
	if not f then
		return false, err
	end
	f:write(content)
	f:close()
	return true, nil
end

local function delete_file(file_path)
	return os.remove(file_path)
end

-- 网络与JSON
local https = require("https")
local json = require("lib.json")
local candidate_sites = {"https://krdovedownload6.crazyspotteddove.top:52000/", "https://krdovedonwload4.crazyspotteddove.top/"}
local server_address = nil

for _, site in ipairs(candidate_sites) do
	if https.request(site) == 200 then
		server_address = site
		print("Selected update server:", server_address)
		break
	end
end

if not server_address then
	print("No available update server found. Disabling updates.")
	apply_upgrade = false
end

local update_response = nil

-- 对应 Rust 的 sync_assets("master")
function M.sync_assets()
	if not server_address then
		return true
	end
	set_state(STATE_DOWNLOADING_ASSETS)
	local url = server_address .. "assets"
	local code, response_body = https.request(url, {
		method = "POST",
		headers = {
			["Content-Type"] = "application/json"
		},
		data = json.encode({
			branch = "master",
			mode = "download",
			assets_index = "return {}"
		})
	})

	if code ~= 200 then
		log_error("无法同步美术资源。服务器返回代码：" .. code)
		log_error("服务器回复: " .. (response_body or "nil"))
		return false
	end

	local ok, resp_json = pcall(json.decode, response_body)
	if not ok or not resp_json then
		log_error("无法解码资源同步的服务器回复。")
		return false
	end

	-- 删除文件
	for _, file_path in ipairs(resp_json.delete_files or {}) do
		local local_file_path = "_assets/" .. file_path
		if FS.getInfo(local_file_path) and not delete_file(local_file_path) then
			log_error("删除文件失败：" .. file_path)
			return false
		else
			log_info("删除文件：" .. file_path)
		end
	end

	-- 下载文件
	local url = server_address .. "assets/download"
	for i, file_info in ipairs(resp_json.need_files or {}) do
		local file_path = file_info.file
		local local_file_path = "_assets/" .. file_path
		local local_file_info = FS.getInfo(local_file_path)
		if not (local_file_info and local_file_info.size == file_info.size) then
			local download_code, file_content = https.request(url, {
				method = "POST",
				headers = {
					["Content-Type"] = "application/json"
				},
				data = json.encode({
					file = file_path
				})
			})
			if download_code == 200 then
				ensure_parent_dir(local_file_path)
				local success, err = write_file(local_file_path, file_content)
				if not success then
					log_error("写入文件失败: " .. local_file_path .. " (" .. tostring(err) .. ")")
					return false
				end
				log_info(string.format("下载美术资源 (%d/%d): %s", i, #resp_json.need_files, file_path))
			else
				log_error("下载文件失败: " .. file_path .. " (Code: " .. download_code .. ")")
				return false
			end
		end
	end
	return true
end

function M.upgrade_new_version(info)
	set_state(STATE_DOWNLOADING_CODE)

	local tmp_dir = ".upgrade_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)
	local has_error = false

	-- 1. 下载到临时目录
	local added_or_modified = info.added_or_modified_files or {}
	local url = server_address .. "file"
	for i, file_path in ipairs(added_or_modified) do
		local download_code, content = https.request(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = file_path
			})
		})
		if download_code == 200 then
			local tmp_file_path = tmp_dir .. "/" .. file_path
			FS.createDirectory(tmp_file_path:match("(.+)/"))
			if not FS.write(tmp_file_path, content) then
				log_error("写入临时文件失败: " .. tmp_file_path)
				has_error = true
				break
			end
			log_info(string.format("下载代码资源 (%d/%d): %s", i, #added_or_modified, file_path))
		else
			log_error("下载代码文件失败: " .. file_path .. " (Code: " .. download_code .. ")")
			has_error = true
			break
		end
	end

	-- 2. 提交更改
	if not has_error then
		set_state(STATE_COMMITTING_CHANGES)
		-- 覆盖文件
		for _, file_path in ipairs(added_or_modified) do
			local content = FS.read(tmp_dir .. "/" .. file_path)
			if content then
				ensure_parent_dir(file_path)
				local success, err = write_file(file_path, content)
				if not success then
					log_error("提交更改时写入文件失败: " .. file_path .. " (" .. tostring(err) .. ")")
					has_error = true
					break
				end
				log_info("提交更改: " .. file_path)
			else
				log_error("读取临时文件失败: " .. tmp_dir .. "/" .. file_path)
				has_error = true
				break
			end
		end
		-- 删除文件
		if not has_error then
			for _, file_path in ipairs(info.deleted_files or {}) do
				if FS.getInfo(file_path) and not delete_file(file_path) then
					log_error("删除文件失败: " .. file_path)
					has_error = true
					break
				else
					log_info("删除文件: " .. file_path)
				end
			end
		end
	end

	FS.remove(tmp_dir) -- 清理

	-- 3. 更新版本号
	if not has_error and info.master_commit_hash then
		if not write_file("current_version_commit_hash.txt", info.master_commit_hash) then
			log_error("更新版本 commit hash 失败。")
			has_error = true
		end
	end

	if has_error then
		log_error("升级过程中发生错误，部分操作未完成。")
	end

	return not has_error
end

function M.check_update()
	if not apply_upgrade then
		return
	end
	local commit_hash = FS.read("current_version_commit_hash.txt")
	if not commit_hash then
		return
	end
	local url = server_address .. "commits"
	local code, response = https.request(url, {
		method = "POST",
		headers = {
			["Content-Type"] = "application/json"
		},
		data = json.encode({
			commit_hash = commit_hash
		})
	})

	if code == 200 then
		local resp_json = json.decode(response)
		if resp_json.commits and #resp_json.commits > 0 then
			apply_upgrade = true
			update_response = resp_json
		else
			apply_upgrade = false
		end
	else
		print("无法检查更新。服务器返回代码：" .. code)
		apply_upgrade = false
	end
end

function M.run()
	if not apply_upgrade then
		return
	end

	local messages = {}
	for i, commit in ipairs(update_response.commits or {}) do
		if i > 20 then
			table.insert(messages, string.format("...以及另外 %d 条更新内容。", #update_response.commits - 20))
			break
		end
		table.insert(messages, commit.message)
	end

	local pressed = love.window.showMessageBox("发现新版本", "检测到有新内容可更新，是否立即更新？\n\n" .. table.concat(messages, "\n\n"), {"更新", "取消"})

	if pressed == 1 then
		local old_w, old_h, old_flags = love.window.getMode()
		local dw, dh = love.window.getDesktopDimensions()
		love.window.setMode(math.max(800, math.floor(dw * 0.8)), math.max(600, math.floor(dh * 0.8)), {
			resizable = false
		})

		local success = M.sync_assets()
		if success then
			success = M.upgrade_new_version(update_response)
		end

		if success then
			love.window.showMessageBox("升级完成", "资源已更新。点击以关闭游戏。", {"确定"})
			love.event.quit("restart")
		else
			local error_report = "升级过程中发生错误，请报告以下问题：\n\n" .. table.concat(error_log_lines, "\n")
			love.window.showMessageBox("升级失败", error_report, {"确定"})
			love.window.setMode(old_w, old_h, old_flags) -- 恢复窗口
		end
	end
end

return M
