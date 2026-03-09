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
	table.insert(error_log_lines, line)
	coroutine.yield()
end

local function set_state(new_state)
	state = new_state
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
	return true
end

local function delete_file(file_path)
	return os.remove(file_path)
end

-- 网络与JSON
local server_address = nil
local json = require("lib.json")
local update_response = nil

-- HTTP 工作线程
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

-- 异步 HTTP 请求
local function async_request(url, options, timeout)
	love.thread.getChannel("um_http_req"):push({
		url = url,
		options = options
	})
	local resp_ch = love.thread.getChannel("um_http_resp")
	if timeout then
		local start_time = love.timer.getTime()
		while resp_ch:getCount() == 0 do
			if love.timer.getTime() - start_time > timeout then
				return 0, "请求超时", {}
			end
			coroutine.yield()
		end
	else
		while resp_ch:getCount() == 0 do
			coroutine.yield()
		end
	end
	local resp = resp_ch:pop()
	return resp.code, resp.body, resp.headers
end

-- 非阻塞等待
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

	f:seek("set", 0)
	local head = f:read(4096) or ""
	for i = 1, #head do
		hash = (bit.bxor(hash, head:byte(i)) * prime) % mod
	end

	if size > 8192 then
		f:seek("set", size - 4096)
		local tail = f:read(4096) or ""
		for i = 1, #tail do
			hash = (bit.bxor(hash, tail:byte(i)) * prime) % mod
		end
	end

	hash = (bit.bxor(hash, size) * prime) % mod
	f:close()
	return string.format("%08x", hash)
end

-- 解析 Content-Range 响应头中的总大小：格式为 "bytes start-end/total"
local function parse_total_size(resp_headers, http_code)
	local content_range = resp_headers["content-range"]
	if content_range then
		return tonumber(content_range:match("/(%d+)$"))
	end
	-- 服务器不支持 Range，返回 200，此时 content-length 即为总大小
	if http_code == 200 then
		return tonumber(resp_headers["content-length"])
	end
	return nil
end

-- 支持 HTTP Range 断点续传：下载到真实文件系统路径
-- 适用于需要写入真实磁盘的大型资源文件（如 _assets/ 下的文件）
-- 若存在 <real_path>.part，则自动从断点续传
-- 返回: ok (bool)
local function download_to_file_resume(url, options, real_path)
	local part_path = real_path .. ".part"

	-- 检查已有的部分下载
	local partial_size = 0
	local f_check = io.open(part_path, "rb")
	if f_check then
		partial_size = f_check:seek("end")
		f_check:close()
	end

	-- 构建请求，若有部分数据则附加 Range 头
	local req_opts = {
		method = options.method,
		data = options.data,
		headers = {}
	}
	for k, v in pairs(options.headers or {}) do
		req_opts.headers[k] = v
	end
	if partial_size > 0 then
		req_opts.headers["Range"] = "bytes=" .. partial_size .. "-"
	end

	local code, body, resp_headers = async_request(url, req_opts)

	if code == 200 then
		-- 服务器不支持 Range，或从头开始下载
		local wf = io.open(part_path, "wb")
		if not wf then
			return false
		end
		wf:write(body)
		wf:close()
	elseif code == 206 then
		-- 续传：追加到 .part 文件
		local wf = io.open(part_path, "ab")
		if not wf then
			return false
		end
		wf:write(body)
		wf:close()
	else
		return false
	end

	-- 验证总大小
	local total_size = parse_total_size(resp_headers, code)
	local f_size = io.open(part_path, "rb")
	if not f_size then
		return false
	end
	local actual = f_size:seek("end")
	f_size:close()

	if total_size and actual ~= total_size then
		return false -- 仍不完整，保留 .part 等待下次续传
	end

	-- 完成：重命名为最终路径
	ensure_parent_dir(real_path)
	os.remove(real_path)
	local renamed = os.rename(part_path, real_path)
	if not renamed then
		-- os.rename 跨设备时失败，退回到复制后删除
		local rf = io.open(part_path, "rb")
		local wf2 = io.open(real_path, "wb")
		if rf and wf2 then
			wf2:write(rf:read("*a"))
			rf:close()
			wf2:close()
			os.remove(part_path)
		else
			if rf then
				rf:close()
			end
			if wf2 then
				wf2:close()
			end
			return false
		end
	end
	return true
end

-- 支持 HTTP Range 断点续传：下载到 LÖVE 文件系统路径
-- 适用于代码/索引小文件（内容全程在内存中拼接，完成后写入 fs_path）
-- 返回: ok (bool), 文件内容 (string or nil)
local function download_to_lovefs_resume(url, options, fs_path)
	local part_path = fs_path .. ".part"

	-- 读取已有的部分下载
	local existing = FS.read(part_path) or ""
	local partial_size = #existing

	local req_opts = {
		method = options.method,
		data = options.data,
		headers = {}
	}
	for k, v in pairs(options.headers or {}) do
		req_opts.headers[k] = v
	end
	if partial_size > 0 then
		req_opts.headers["Range"] = "bytes=" .. partial_size .. "-"
	end

	local code, body, resp_headers = async_request(url, req_opts)

	local content
	if code == 200 then
		content = body
	elseif code == 206 then
		content = existing .. body
	else
		return false, nil
	end

	FS.write(part_path, content) -- 保存当前进度

	-- 验证总大小
	local total_size = parse_total_size(resp_headers, code)
	if total_size and #content ~= total_size then
		return false, content -- 仍不完整，保留 .part 等待下次续传
	end

	-- 完成：写入目标路径，清理 .part
	local parent = fs_path:match("(.+)/")
	if parent then
		FS.createDirectory(parent)
	end
	FS.write(fs_path, content)
	FS.remove(part_path)
	return true, content
end

local function diff_assets()
	set_state(STATE_CHECKING_ASSETS)
	local has_error = false
	local tmp_dir = ".assets_diff_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)

	local url = server_address .. "file"
	local max_retries = 5
	local retries = 0
	log_info("拉取资源索引文件...")

	local tmp_file_path = tmp_dir .. "/assets_index.lua"
	local index_content = nil

	while true do
		local ok, content = download_to_lovefs_resume(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = "_assets/assets_index.lua"
			})
		}, tmp_file_path)

		if ok then
			index_content = content
			log_info("资源索引文件下载完成")
			break
		else
			retries = retries + 1
			if retries > max_retries then
				log_error("下载资源索引失败（多次重试无效）")
				has_error = true
				break
			else
				log_info("文件尚未下载完整，正在续传（第 " .. retries .. " 次）: assets_index.lua")
				async_sleep(math.min(2 ^ retries, 16))
			end
		end
	end

	local added_or_modified = nil

	if not has_error then
		local remote_assets_index = loadstring(index_content)()
		local local_assets_index = dofile("_assets/assets_index.lua")

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

	FS.remove(tmp_dir)
	return added_or_modified
end

local function sync_assets(added_or_modified)
	if not server_address then
		return true
	end
	set_state(STATE_DOWNLOADING_ASSETS)

	local url = server_address .. "assets/download"
	local max_retries = 5
	local retries = 0
	local i = 1
	local file_count = #added_or_modified

	while i <= file_count do
		local file_path = added_or_modified[i]
		local local_file_path = "_assets/" .. file_path
		local part_path = local_file_path .. ".part"

		-- 日志显示续传起始位置
		local f_check = io.open(part_path, "rb")
		if f_check then
			local partial = f_check:seek("end")
			f_check:close()
			if partial > 0 then
				log_info(string.format("续传美术资源 (%d/%d) 从 %d 字节: %s", i, file_count, partial, file_path))
			end
		end

		ensure_parent_dir(local_file_path)
		local ok = download_to_file_resume(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = file_path
			})
		}, local_file_path)

		if ok then
			log_info(string.format("下载美术资源 (%d/%d): %s", i, file_count, file_path))
			retries = 0
			i = i + 1
		else
			retries = retries + 1
			if retries > max_retries then
				log_error("下载文件失败（多次重试无效）: " .. file_path)
				os.remove(part_path) -- 放弃，清理损坏的部分文件
				return false
			else
				log_info("下载未完成，正在续传（第 " .. retries .. " 次）: " .. file_path)
				async_sleep(math.min(2 ^ retries, 16))
			end
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
		local tmp_file_path = tmp_dir .. "/" .. file_path

		local ok, _ = download_to_lovefs_resume(url, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				file = file_path
			})
		}, tmp_file_path)

		if ok then
			log_info(string.format("下载代码资源 (%d/%d): %s", i, file_count, file_path))
			retries = 0
			i = i + 1
		else
			retries = retries + 1
			if retries > max_retries then
				log_error("下载代码文件失败（多次重试无效）: " .. file_path)
				has_error = true
				break
			else
				log_info("下载未完成，正在续传（第 " .. retries .. " 次）: " .. file_path)
				async_sleep(math.min(2 ^ retries, 16))
			end
		end
	end

	-- 2. 提交更改
	if not has_error then
		set_state(STATE_COMMITTING_CHANGES)
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

	FS.remove(tmp_dir)

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
		}, 10)
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
		return "NoUpdate"
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
			return "NoUpdate"
		end
		local success = sync_assets(added_or_modified)
		if success then
			success = upgrade_new_version(update_response)
		end

		if success then
			love.window.showMessageBox("升级完成", "资源已更新。点击以重启游戏。", {"确定"})
			R.tmp()
			return "Updated"
		else
			local error_report = "升级过程中发生错误，请报告以下问题（若是多次重试不成功，可能是服务器网络繁忙，可稍后重试）：\n\n" .. table.concat(error_log_lines, "\n")
			love.window.showMessageBox("升级失败", error_report, {"确定"})
			return "NoUpdate"
		end
	elseif pressed == 2 then
		return "NoUpdate"
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
	local req_ch = love.thread.getChannel("um_http_req")
	local resp_ch = love.thread.getChannel("um_http_resp")
	while req_ch:getCount() > 0 do
		req_ch:pop()
	end
	while resp_ch:getCount() > 0 do
		resp_ch:pop()
	end
	http_worker = love.thread.newThread(HTTP_WORKER)
	http_worker:start()
	local co = coroutine.create(run_code)
	self.co = co
end

function M:update(dt)
	if self.co then
		local success, result = coroutine.resume(self.co)
		if not success then
			table.insert(update_log_lines, "[错误] 更新过程中发生错误: " .. tostring(result))
			table.insert(error_log_lines, tostring(result))
			love.window.showMessageBox("升级失败", "升级过程中发生错误，错误信息已记录在日志中。请将以下信息报告给开发者：\n\n" .. tostring(result), {"确定"})
			self.co = nil
			love.thread.getChannel("um_http_req"):push("quit")
			self:done_callback()
		elseif coroutine.status(self.co) == "dead" then
			self.co = nil
			love.thread.getChannel("um_http_req"):push("quit")
			if result == "NoUpdate" then
				self:done_callback()
			end
		end
	end
end

function M:draw()
	G.setFont(font)
	G.setColor(1, 1, 1, 1)
	local w, h = G.getDimensions()
	local text = STATE_STRING_MAP[state]
	local tw = font:getWidth(text)
	local th = font:getHeight()
	G.print(text, (w - tw) / 2, (h - th) / 3)

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
