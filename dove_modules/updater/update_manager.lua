local M = {}
local storage = require("all.storage")
local G = love.graphics
local FS = love.filesystem
local font = require("lib.klove.font_db"):f("msyh", 20)
local FU = require("all.file_utlis")

-- 本模块只在非安卓平台启用
local apply_upgrade = love.system.getOS() ~= "Android"
apply_upgrade = apply_upgrade and not (arg[2] == "debug" or arg[2] == "release")
local is_windows = package.config:sub(1, 1) == "\\"
local R = require("all.restart")
-- 更新状态定义
local STATE_DOWNLOADING_ASSETS = 1
local STATE_DOWNLOADING_CODE = 2
local STATE_COMMITTING_CHANGES = 3
local STATE_SELECT_URL = 4
local STATE_CHECK_UPDATE = 5
local STATE_CHECKING_ASSETS = 6
local STATE_STRING_MAP = {
	[STATE_CHECKING_ASSETS] = "校验美术资源中……",
	[STATE_DOWNLOADING_ASSETS] = "下载美术资源中（可能需要较长时间）……",
	[STATE_DOWNLOADING_CODE] = "下载代码资源中……",
	[STATE_COMMITTING_CHANGES] = "提交更新事务中……",
	[STATE_SELECT_URL] = "选择更新地址中……",
	[STATE_CHECK_UPDATE] = "检查更新中……"
}
local state = STATE_DOWNLOADING_ASSETS
local update_log_line_max_count = 20
-- 日志系统
local update_log_lines = {}
local error_log_lines = {}

-- 记录普通日志
local function log_info(line)
	table.insert(update_log_lines, line)
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	coroutine.yield()
end

-- 记录错误日志
local function log_error(line)
	table.insert(update_log_lines, "[错误] " .. line)
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	table.insert(error_log_lines, line) -- 同时存入错误报告
	coroutine.yield()
end

local function set_state(new_state)
	state = new_state
-- log_info(STATE_STRING_MAP[state])
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

-- local function write_file(file_path, content)
-- 	local f, err = io.open(file_path, "wb")
-- 	if not f then
-- 		return false, err
-- 	end
-- 	f:write(content)
-- 	f:close()
-- 	return true, nil
-- end

local function delete_file(file_path)
	return os.remove(file_path)
end

-- 网络与JSON
local server_address = nil
-- local https
local json = require("lib.json")
local update_response = nil

-- HTTP 工作线程：将阻塞的网络请求移出主线程，避免 OS 误判程序未响应
local HTTP_WORKER = [[
local https = require("https")
local req_ch  = love.thread.getChannel("um_http_req")
local resp_ch = love.thread.getChannel("um_http_resp")
while true do
	local req = req_ch:demand()
	if req == "quit" then break end
	local ok, code, body, headers = pcall(https.request, req.url, req.options)
	if ok then
		resp_ch:push({code = code, body = body, headers = headers})
	else
		resp_ch:push({code = 0, body = tostring(code), headers = {}})
	end
end
]]
local http_worker = nil

-- 异步 HTTP 请求：向工作线程发送请求并逐帧 yield 等待结果
local function async_request(url, options)
	love.thread.getChannel("um_http_req"):push({
		url = url,
		options = options
	})
	local resp_ch = love.thread.getChannel("um_http_resp")
	while resp_ch:getCount() == 0 do
		coroutine.yield()
	end
	local resp = resp_ch:pop()
	return resp.code, resp.body, resp.headers
end

-- 非阻塞等待：每帧 yield，避免主线程挂起
local function async_sleep(seconds)
	local t = love.timer.getTime()
	while love.timer.getTime() - t < seconds do
		coroutine.yield()
	end
end

local function file_hash(path)
	local bit = require("bit")
	local f = io.open(path, "rb")
	if not f then
		return "0"
	end

	local size = f:seek("end")
	local hash = 2166136261
	local prime = 16777619
	local mod = 0xFFFFFFFF

	-- 读取头部
	f:seek("set", 0)
	local head = f:read(4096) or ""
	for i = 1, #head do
		hash = (bit.bxor(hash, head:byte(i)) * prime) % mod
	end

	-- 读取尾部
	if size > 8192 then
		f:seek("set", size - 4096)
		local tail = f:read(4096) or ""
		for i = 1, #tail do
			hash = (bit.bxor(hash, tail:byte(i)) * prime) % mod
		end
	end

	-- 混入文件大小
	hash = (bit.bxor(hash, size) * prime) % mod

	f:close()
	return string.format("%08x", hash)
end

local function diff_assets()
	set_state(STATE_CHECKING_ASSETS)
	local has_error = false
	local tmp_dir = ".assets_diff_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)
	-- 先从服务器下载 assets_index.lua，准备与本地的assets_index.lua进行对比

	local url = server_address .. "file"
	local max_retries = 5
	local retries = 0
	log_info("拉取资源索引文件...")

	while true do
		local download_code, content, response_header = async_request(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = "_assets/assets_index.lua"
			})
		})

		if download_code == 200 then
			if tonumber(response_header["content-length"]) == #content then
				local tmp_file_path = tmp_dir .. "/" .. "assets_index.lua"
				FS.createDirectory(tmp_file_path:match("(.+)/"))
				if not FS.write(tmp_file_path, content) then
					log_error("写入临时文件失败: " .. tmp_file_path)
					has_error = true
					break
				end
				log_info("资源索引文件下载完成")
				break
			else
				-- 可能传输中间发生了网络中断，重试。
				retries = retries + 1
				if retries > max_retries then
					log_error("下载资源索引失败（多次重试无效）")
					has_error = true
					break
				else
					log_info("文件长度不符，正在重试（第 " .. retries .. " 次）: " .. "_assets/assets_index.lua")
					async_sleep(math.min(2 ^ retries, 16))
				end
			end
		else
			log_error("下载资源索引失败: (Code: " .. download_code .. ")")
			has_error = true
			break
		end
	end

	local added_or_modified = nil

	if not has_error then
		local remote_assets_index = loadstring(FS.read(tmp_dir .. "/assets_index.lua"))()
		local local_assets_index = dofile("_assets/assets_index.lua")

		-- diff
		added_or_modified = {}
		for file, info in pairs(remote_assets_index) do
			local local_info = local_assets_index[file]
			if not local_info then
				added_or_modified[#added_or_modified + 1] = file
			else
				if not local_info.hash then
					local_info.hash = file_hash("_assets/" .. file)
				end

				if local_info.size ~= info.size or local_info.hash ~= info.hash then
					added_or_modified[#added_or_modified + 1] = file
				end
			end
		end
	end

	FS.remove(tmp_dir) -- 清理
	return added_or_modified
end

local function sync_assets(added_or_modified)
	if not server_address then
		return true
	end
	set_state(STATE_DOWNLOADING_ASSETS)

	-- 下载文件
	local url = server_address .. "assets/download"
	local retries = 0
	local max_retries = 5
	local i = 1
	local file_count = #added_or_modified
	while i <= file_count do
		local file_path = added_or_modified[i]
		local local_file_path = "_assets/" .. file_path
		local download_code, file_content, response_header = async_request(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = file_path
			})
		})
		if download_code == 200 then
			if tonumber(response_header["content-length"]) == #file_content then
				ensure_parent_dir(local_file_path)
				if not FU.write_file(local_file_path, file_content) then
					log_error("写入文件失败: " .. local_file_path)
					return false
				end
				log_info(string.format("下载美术资源 (%d/%d): %s", i, file_count, file_path))
				retries = 0
				i = i + 1
			else
				-- 可能传输中间发生了网络中断，重试。
				retries = retries + 1
				if retries > max_retries then
					log_error("下载文件失败（多次重试无效）: " .. file_path)
					return false
				else
					log_info("文件长度不符，正在重试（第 " .. retries .. " 次）: " .. file_path)
					async_sleep(math.min(2 ^ retries, 16))
				end
			end
		else
			log_error("下载文件失败: " .. file_path .. " (Code: " .. download_code .. ")")
			return false
		end
	end

	return true
end

local function upgrade_new_version(info)
	set_state(STATE_DOWNLOADING_CODE)

	local tmp_dir = ".upgrade_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)
	local has_error = false

	-- 1. 下载到临时目录
	local added_or_modified = info.added_or_modified_files or {}
	local url = server_address .. "file"

	local i = 1
	local file_count = #added_or_modified
	local max_retries = 5
	local retries = 0

	while i <= file_count do
		local file_path = added_or_modified[i]
		local download_code, content, response_header = async_request(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = file_path
			})
		})

		if download_code == 200 then
			if tonumber(response_header["content-length"]) == #content then
				local tmp_file_path = tmp_dir .. "/" .. file_path
				FS.createDirectory(tmp_file_path:match("(.+)/"))
				if not FS.write(tmp_file_path, content) then
					log_error("写入临时文件失败: " .. tmp_file_path)
					has_error = true
					break
				end
				log_info(string.format("下载代码资源 (%d/%d): %s", i, #added_or_modified, file_path))
				retries = 0
				i = i + 1
			else
				-- 可能传输中间发生了网络中断，重试。
				retries = retries + 1
				if retries > max_retries then
					log_error("下载代码文件失败（多次重试无效）: " .. file_path)
					has_error = true
					break
				else
					log_info("文件长度不符，正在重试（第 " .. retries .. " 次）: " .. file_path)
					async_sleep(math.min(2 ^ retries, 16))
				end
			end
		else
			log_error("下载代码文件失败: " .. file_path .. " (Code: " .. download_code .. "content: )" .. tostring(content) .. "response_header: " .. json.encode(response_header))
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
				if not FU.write_file(file_path, content) then
					log_error("提交更改时写入文件失败: " .. file_path)
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
		if not FU.write_file("current_version_commit_hash.txt", info.master_commit_hash) then
			log_error("更新版本 commit hash 失败。")
			has_error = true
		end
	end

	if has_error then
		log_error("升级过程中发生错误，部分操作未完成。")
	end

	return not has_error
end

--- @return 是否有更新可用
local function check_update()
	local params = M.params
	local commit_hash = FS.read("current_version_commit_hash.txt")
	if not commit_hash then
		return false
	end

	set_state(STATE_SELECT_URL)

	-- 直接向各地址发 commits 请求，成功则同时完成探活，减少一次 RTT
	local candidate_sites = {params.update_last_site}
	for _, site in ipairs({"https://krdovedownload6.crazyspotteddove.top:52000/", "https://krdovedownload4.crazyspotteddove.top/"}) do
		if site ~= params.update_last_site then
			candidate_sites[#candidate_sites + 1] = site
		end
	end

	local resp_json = nil
	for _, site in ipairs(candidate_sites) do
		log_info("尝试使用更新地址：" .. site)
		local url = site .. "commits"
		set_state(STATE_CHECK_UPDATE)
		local code, response = async_request(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				commit_hash = commit_hash
			})
		})
		if code == 200 then
			resp_json = json.decode(response)
			server_address = site
			log_info("选中更新地址：" .. server_address)
			if site ~= params.update_last_site then
				params.update_last_site = site
				storage:save_settings(params)
			end
			break
		else
			log_info("该更新地址不可用，返回代码：" .. tostring(code))
			set_state(STATE_SELECT_URL)
		end
	end

	if not server_address then
		log_info("未找到可用的更新地址，取消更新检查。")
		return false
	end

	if resp_json and resp_json.commits and #resp_json.commits > 0 then
		update_response = resp_json
		return true
	end
	return false
end

local function run_code()
	local check_result = check_update()
	if check_result == false then
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
		local added_or_modified = diff_assets()
		if not added_or_modified then
			love.window.showMessageBox("升级失败", "校验美术资源时发生错误，无法继续升级。请将以下信息报告给开发者：\n\n" .. table.concat(error_log_lines, "\n"), {"确定"})
			return
		end
		local success = sync_assets(added_or_modified)
		if success then
			success = upgrade_new_version(update_response)
		end

		if success then
			love.window.showMessageBox("升级完成", "资源已更新。点击以重启游戏。", {"确定"})
			R.full()
		else
			local error_report = "升级过程中发生错误，请报告以下问题（若是多次重试不成功，可能是服务器网络繁忙，可稍后重试）：\n\n" .. table.concat(error_log_lines, "\n")
			love.window.showMessageBox("升级失败", error_report, {"确定"})
		end
	end
end

function M:init(params, done_callback)
	apply_upgrade = apply_upgrade and params.update_enabled
	self.done_callback = done_callback
	self.params = params
	if not apply_upgrade then
		self:done_callback()
		return
	end
	-- https = require("https")
	http_worker = love.thread.newThread(HTTP_WORKER)
	http_worker:start()
	local co = coroutine.create(run_code)
	self.co = co
end

function M:update(dt)
	if self.co then
		local success, err = coroutine.resume(self.co)
		if not success then
			-- 直接用 table.insert 写日志，不能调用 log_error（会 yield，但此处在主线程）
			table.insert(update_log_lines, "[错误] 更新过程中发生错误: " .. tostring(err))
			table.insert(error_log_lines, tostring(err))
			love.window.showMessageBox("升级失败", "升级过程中发生错误，错误信息已记录在日志中。请将以下信息报告给开发者：\n\n" .. tostring(err), {"确定"})
			self.co = nil
			love.thread.getChannel("um_http_req"):push("quit")
			self:done_callback()
		elseif coroutine.status(self.co) == "dead" then
			self.co = nil
			love.thread.getChannel("um_http_req"):push("quit")
			self:done_callback()
		end
	end
end

-- 统一的更新界面绘制函数
function M:draw()
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
end

function M:keyreleased(key, scancode)
end

function M:keypressed(key, isrepeat)
end

function M:textinput(t)
end

function M:mousepressed(x, y, button, istouch)
end

function M:mousereleased(x, y, button, istouch)
end

return M
