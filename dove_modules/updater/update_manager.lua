-- 【修复版】解决闪烁、特殊字符、删除失败、重启卡死问题
-- 修复内容：
-- 1. ✓ 符号改为文字，避免编码问题
-- 2. 进度显示优化，避免频繁刷新导致闪烁
-- 3. 删除文件使用 FU.delete_file 而非 os.remove
-- 4. 重启卡死修复：在协程外（M:update）清理线程后再执行重启，避免在协程内调用quit导致卡死

local M = {}
local storage = require("all.storage")
local G = love.graphics
local FS = love.filesystem
local font = require("lib.klove.font_db"):f("msyh", 20)
local FU = require("all.file_utlis")

-- 本模块只在非安卓平台启用
local apply_upgrade = not IS_ANDROID
-- DEBUG 不启用
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

-- 日志记录
local update_log_lines = {}
local error_log_lines = {}

-- 【关键配置】分块下载 - 避免超时
local DOWNLOAD_CONFIG = {
	chunk_size = 1 * 1024 * 1024, -- 每块 1MB（远低于任何超时限制）
	chunk_timeout = 60, -- 单块超时 60 秒（1MB足够）
	chunk_max_retries = 10, -- 单块最多重试 10 次
	file_max_retries = 3, -- 整个文件失败后，最多从头重试 3 次
	retry_backoff_base = 2, -- 退避基数
	retry_backoff_max = 30, -- 最大退避 30 秒
	network_error_delay = 15, -- 网络错误特殊延迟
	base_timeout = 30, -- 基础超时（用于小请求）
	progress_update_interval = 0.5 -- 进度更新间隔，避免闪烁
}

-- 进度跟踪（避免频繁刷新日志）
local last_progress_update = 0
local current_download_progress = 0

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

-- 更新进度（避免频繁刷新）
local function update_progress(percent, force)
	local now = love.timer.getTime()
	if force or (now - last_progress_update) > DOWNLOAD_CONFIG.progress_update_interval then
		current_download_progress = percent
		last_progress_update = now
	end
end

local function set_state(new_state)
	state = new_state
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

        local start_time = os.time()
        local ok, code, body, headers = pcall(https.request, req.url, req.options)
        local elapsed = os.time() - start_time

        if ok then
            resp_ch:push({
                code = code,
                body = body,
                headers = headers,
                elapsed = elapsed
            })
        else
            resp_ch:push({
                code = 0,
                body = tostring(code),
                headers = {},
                elapsed = elapsed
            })
        end
   end
]]
local http_worker = nil

--- 异步 HTTP 请求，含默认超时策略
local function async_request(url, options, timeout)
	love.thread.getChannel("um_http_req"):push({
		url = url,
		options = options
	})
	local resp_ch = love.thread.getChannel("um_http_resp")
	timeout = timeout or DOWNLOAD_CONFIG.base_timeout

	local start_time = love.timer.getTime()
	while resp_ch:getCount() == 0 do
		if love.timer.getTime() - start_time > timeout then
			return 0, "请求超时", {}, 0
		end
		coroutine.yield()
	end

	local resp = resp_ch:pop()
	return resp.code, resp.body, resp.headers, resp.elapsed or 0
end

-- 非阻塞等待
local function async_sleep(seconds)
	local t = love.timer.getTime()
	while love.timer.getTime() - t < seconds do
		coroutine.yield()
	end
end

-- 与 gen_assets_index.lua 中的 hash 计算保持一致
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

-- URL 编码（简单版本，适用于文件路径）
local function url_encode(str)
	str = string.gsub(str, "([^%w%-%.%_%~%/])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	return str
end

-- 解析 Content-Range
local function parse_content_range(content_range)
	if content_range then
		local range_start, range_end, total = content_range:match("bytes (%d+)%-(%d+)/(%d+)")
		return tonumber(range_start), tonumber(range_end), tonumber(total)
	end
	return nil, nil, nil
end

-- 判断是否应该重试
local function should_retry_error(code, retry_count)
	if code == 0 then -- 网络错误
		return true, "network"
	end
	if code >= 500 then -- 服务器错误
		return true, "server"
	end
	if code == 408 or code == 429 then -- 超时或限流
		return true, "throttle"
	end
	if code == 404 then -- 文件不存在
		return false, "not_found"
	end
	if code == 416 then -- Range 无效
		return false, "invalid_range"
	end
	if code >= 400 and code < 500 then
		return retry_count < 3, "client" -- 其他客户端错误，最多3次
	end
	return true, "unknown"
end

-- 计算退避时间
local function calculate_backoff(retry_count, error_type)
	if error_type == "network" then
		return DOWNLOAD_CONFIG.network_error_delay
	end
	local backoff = math.min(DOWNLOAD_CONFIG.retry_backoff_base ^ retry_count, DOWNLOAD_CONFIG.retry_backoff_max)
	return backoff
end

-- 【核心函数】分块下载到真实文件系统（支持断点续传）
local function download_to_file_chunked(url_base, file_param, real_path)
	local part_path = real_path .. ".part"
	local chunk_size = DOWNLOAD_CONFIG.chunk_size

	-- 编码文件参数
	local encoded_file = url_encode(file_param)
	local url = url_base .. "?file=" .. encoded_file

	-- 先获取文件总大小
	local code, body, headers = async_request(url, {
		method = "GET",
		headers = {
			["Range"] = "bytes=0-0"
		}
	}, 30)

	local total_size = nil
	if code == 206 then
		local _, _, size = parse_content_range(headers["content-range"])
		total_size = size
	elseif code == 200 then
		-- 服务器不支持 Range，或文件很小直接返回了
		total_size = #body
		local wf = io.open(part_path, "wb")
		if not wf then
			log_error("无法写入文件: " .. part_path)
			return false
		end
		wf:write(body)
		wf:close()

		-- 直接完成
		FU.ensure_parent_dir(real_path)
		os.remove(real_path)
		os.rename(part_path, real_path)
		return true
	else
		log_error(string.format("无法获取文件大小: HTTP %d", code))
		return false
	end

	if not total_size or total_size == 0 then
		log_error("文件大小无效")
		return false
	end

	-- log_info(string.format("文件大小: %.2f MB", total_size / 1024 / 1024))

	-- 检查已下载的大小
	local downloaded_size = 0
	local f_check = io.open(part_path, "rb")
	if f_check then
		downloaded_size = f_check:seek("end")
		f_check:close()
		if downloaded_size > 0 then
			log_info(string.format("续传 %.2f/%.2f MB", downloaded_size / 1024 / 1024, total_size / 1024 / 1024))
		end
	end

	-- 分块下载
	local file_retries = 0
	while downloaded_size < total_size do
		-- 计算本块的范围
		local chunk_start = downloaded_size
		local chunk_end = math.min(chunk_start + chunk_size - 1, total_size - 1)

		local chunk_retries = 0
		local chunk_success = false

		while chunk_retries <= DOWNLOAD_CONFIG.chunk_max_retries do
			local code, body, headers, elapsed = async_request(url, {
				method = "GET",
				headers = {
					["Range"] = "bytes=" .. chunk_start .. "-" .. chunk_end
				}
			}, DOWNLOAD_CONFIG.chunk_timeout)

			if code == 206 or code == 200 then
				-- 成功！写入文件
				local wf = io.open(part_path, "ab")
				if not wf then
					log_error("无法打开文件写入")
					return false
				end
				wf:write(body)
				wf:close()

				downloaded_size = downloaded_size + #body

				-- 更新进度（避免闪烁）
				local percent = downloaded_size * 100.0 / total_size
				update_progress(percent, true)

				-- -- 仅在每 10% 或完成时记录日志
				-- if percent >= 100 or percent - (percent % 10) > (downloaded_size - #body) * 100.0 / total_size - ((downloaded_size - #body) * 100.0 / total_size % 10) then
				-- 	log_info(string.format("进度: %.0f%%", percent))
				-- end

				chunk_success = true
				break
			else
				-- 失败，判断是否重试
				local should_retry_flag, error_type = should_retry_error(code, chunk_retries)

				if not should_retry_flag then
					log_error(string.format("下载失败: HTTP %d", code))
					return false
				end

				chunk_retries = chunk_retries + 1
				if chunk_retries > DOWNLOAD_CONFIG.chunk_max_retries then
					log_error("块下载失败（超过重试限制）")

					-- 整个文件重试
					file_retries = file_retries + 1
					if file_retries > DOWNLOAD_CONFIG.file_max_retries then
						log_error("文件下载失败（整体重试用尽）")
						return false
					end

					log_info(string.format("从头重试 (第 %d 次)...", file_retries))
					os.remove(part_path)
					downloaded_size = 0
					break -- 跳出块重试循环
				end

				local backoff = calculate_backoff(chunk_retries, error_type)
				log_info(string.format("重试中 (%d/%d, %ds)...", chunk_retries, DOWNLOAD_CONFIG.chunk_max_retries, backoff))
				async_sleep(backoff)
			end
		end

		if not chunk_success then
		-- 触发了整体重试，继续外层循环
		end
	end

	-- 验证最终大小
	local f_final = io.open(part_path, "rb")
	if not f_final then
		log_error("下载完成但无法读取文件")
		return false
	end
	local actual_size = f_final:seek("end")
	f_final:close()

	if actual_size ~= total_size then
		log_error(string.format("文件大小不匹配: %d vs %d", actual_size, total_size))
		return false
	end

	-- 重命名为最终文件
	FU.ensure_parent_dir(real_path)
	os.remove(real_path)
	local renamed = os.rename(part_path, real_path)
	if not renamed then
		local rf = io.open(part_path, "rb")
		local wf = io.open(real_path, "wb")
		if rf and wf then
			wf:write(rf:read("*a"))
			rf:close()
			wf:close()
			os.remove(part_path)
		else
			if rf then
				rf:close()
			end
			if wf then
				wf:close()
			end
			log_error("文件移动失败")
			return false
		end
	end

	return true
end

-- 【核心函数】分块下载到 LÖVE 文件系统
local function download_to_lovefs_chunked(url_base, file_param, fs_path)
	local part_path = fs_path .. ".part"
	local chunk_size = DOWNLOAD_CONFIG.chunk_size

	local encoded_file = url_encode(file_param)
	local url = url_base .. "?file=" .. encoded_file

	-- 获取文件总大小
	local code, body, headers = async_request(url, {
		method = "GET",
		headers = {
			["Range"] = "bytes=0-0"
		}
	}, 30)

	local total_size = nil
	if code == 206 then
		local _, _, size = parse_content_range(headers["content-range"])
		total_size = size
	elseif code == 200 then
		total_size = #body
		FS.write(fs_path, body)
		FS.remove(part_path)
		return true, body
	else
		log_error(string.format("无法获取文件信息: HTTP %d", code))
		return false, nil
	end

	-- 检查已下载
	local existing = FS.read(part_path) or ""
	local downloaded_size = #existing

	if downloaded_size > 0 then
		log_info(string.format("续传 %.2f/%.2f KB", downloaded_size / 1024, total_size / 1024))
	end

	-- 分块下载
	local file_retries = 0
	while downloaded_size < total_size do
		local chunk_start = downloaded_size
		local chunk_end = math.min(chunk_start + chunk_size - 1, total_size - 1)

		local chunk_retries = 0
		local chunk_success = false

		while chunk_retries <= DOWNLOAD_CONFIG.chunk_max_retries do
			local code, body, headers, elapsed = async_request(url, {
				method = "GET",
				headers = {
					["Range"] = "bytes=" .. chunk_start .. "-" .. chunk_end
				}
			}, DOWNLOAD_CONFIG.chunk_timeout)

			if code == 206 or code == 200 then
				existing = existing .. body
				FS.write(part_path, existing)
				downloaded_size = #existing

				-- 更新进度
				local percent = downloaded_size * 100.0 / total_size
				update_progress(percent, true)

				chunk_success = true
				break
			else
				local should_retry_flag, error_type = should_retry_error(code, chunk_retries)

				if not should_retry_flag then
					log_error(string.format("下载失败: HTTP %d", code))
					return false, nil
				end

				chunk_retries = chunk_retries + 1
				if chunk_retries > DOWNLOAD_CONFIG.chunk_max_retries then
					file_retries = file_retries + 1
					if file_retries > DOWNLOAD_CONFIG.file_max_retries then
						return false, nil
					end

					log_info("从头重新下载...")
					FS.remove(part_path)
					existing = ""
					downloaded_size = 0
					break
				end

				local backoff = calculate_backoff(chunk_retries, error_type)
				log_info(string.format("重试中 (%d/%d)...", chunk_retries, DOWNLOAD_CONFIG.chunk_max_retries))
				async_sleep(backoff)
			end
		end

		if not chunk_success then
		-- 触发了整体重试
		end
	end

	if #existing ~= total_size then
		log_error(string.format("文件大小不匹配: %d vs %d", #existing, total_size))
		return false, nil
	end

	local parent = fs_path:match("(.+)/")
	if parent then
		FS.createDirectory(parent)
	end
	FS.write(fs_path, existing)
	FS.remove(part_path)
	return true, existing
end

local function diff_assets()
	set_state(STATE_CHECKING_ASSETS)
	local tmp_dir = ".assets_diff_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)

	local url_base = server_address .. "file"
	log_info("拉取资源索引文件...")

	local tmp_file_path = tmp_dir .. "/assets_index.lua"
	local ok, index_content = download_to_lovefs_chunked(url_base, "_assets/assets_index.lua", tmp_file_path)

	if not ok then
		log_error("下载资源索引失败")
		FS.remove(tmp_dir)
		return nil
	end

	log_info("资源索引下载完成")

	local remote_assets_index = loadstring(index_content)()
	local local_assets_index = dofile("_assets/assets_index.lua")

	local added_or_modified = {}
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

	FS.remove(tmp_dir)
	return added_or_modified
end

local function sync_assets(added_or_modified)
	if not server_address then
		return true
	end
	set_state(STATE_DOWNLOADING_ASSETS)

	local url_base = server_address .. "assets/download"
	local file_count = #added_or_modified

	for i, file_path in ipairs(added_or_modified) do
		local local_file_path = "_assets/" .. file_path

		log_info(string.format("[%d/%d] %s", i, file_count, file_path))

		FU.ensure_parent_dir(local_file_path)
		local ok = download_to_file_chunked(url_base, file_path, local_file_path)

		if not ok then
			log_error("下载失败: " .. file_path)
			return false
		end

	-- log_info(string.format("完成 (%d/%d)", i, file_count))
	end

	return true
end

local function upgrade_new_version(info)
	set_state(STATE_DOWNLOADING_CODE)

	local tmp_dir = ".upgrade_tmp"
	FS.remove(tmp_dir)
	FS.createDirectory(tmp_dir)

	local added_or_modified = info.added_or_modified_files or {}
	local url_base = server_address .. "file"
	local file_count = #added_or_modified

	for i, file_path in ipairs(added_or_modified) do
		local tmp_file_path = tmp_dir .. "/" .. file_path

		log_info(string.format("[%d/%d] %s", i, file_count, file_path))

		local ok, _ = download_to_lovefs_chunked(url_base, file_path, tmp_file_path)

		if not ok then
			log_error("下载失败: " .. file_path)
			FS.remove(tmp_dir)
			return false
		end

	-- log_info(string.format("完成 (%d/%d)", i, file_count))
	end

	-- 提交更改
	set_state(STATE_COMMITTING_CHANGES)
	for _, file_path in ipairs(added_or_modified) do
		local content = FS.read(tmp_dir .. "/" .. file_path)
		if content then
			FU.ensure_parent_dir(file_path)
			if not FU.write_file(file_path, content) then
				log_error("写入文件失败: " .. file_path)
				FS.remove(tmp_dir)
				return false
			end
			log_info("提交: " .. file_path)
		else
			log_error("读取临时文件失败: " .. file_path)
			FS.remove(tmp_dir)
			return false
		end
	end

	-- 【修复3】删除文件使用 FU.delete_file，并忽略不存在的文件
	for _, file_path in ipairs(info.deleted_files or {}) do
		if FS.getInfo(file_path) then
			local success = FU.delete_file and FU.delete_file(file_path) or os.remove(file_path)
			if not success then
				log_error("删除文件失败: " .. file_path)
			-- 不要因为删除失败就中断更新，继续
			else
				log_info("删除: " .. file_path)
			end
		end
	end

	FS.remove(tmp_dir)

	if info.master_commit_hash then
		if not FU.write_file("current_version_commit_hash.txt", info.master_commit_hash) then
			log_error("更新版本号失败")
			return false
		end
	end

	return true
end

local function check_update()
	local params = M.params
	local commit_hash = FS.read("current_version_commit_hash.txt")
	if not commit_hash then
		return false
	end

	-- 【修复】trim 空白字符
	commit_hash = commit_hash:match("^%s*(.-)%s*$")
	if #commit_hash ~= 40 then
		log_error("commit hash 格式无效: " .. commit_hash)
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
		log_info("尝试: " .. site)
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
		}, 15)

		if code == 200 then
			resp_json = json.decode(response)
			server_address = site
			log_info("选中: " .. server_address)
			if site ~= params.update_last_site then
				params.update_last_site = site
				storage:save_settings(params)
			end
			break
		else
			log_info("不可用: HTTP " .. tostring(code))
			set_state(STATE_SELECT_URL)
		end
	end

	if not server_address then
		log_info("无可用更新地址")
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
		return {
			status = "NoUpdate"
		}
	end

	local messages = {}
	for i, commit in ipairs(update_response.commits or {}) do
		if i > 20 then
			table.insert(messages, string.format("...以及另外 %d 条更新", #update_response.commits - 20))
			break
		end
		table.insert(messages, commit.message)
	end

	-- 【修复】返回状态，让主循环显示消息框
	return {
		status = "AskUpdate",
		message = "检测到有新内容可更新，是否立即更新？\n\n" .. table.concat(messages, "\n\n")
	}
end

local function do_update()
	local added_or_modified = diff_assets()
	if not added_or_modified then
		return {
			status = "Error",
			title = "升级失败",
			message = "校验美术资源时发生错误。\n\n" .. table.concat(error_log_lines, "\n")
		}
	end

	local success = sync_assets(added_or_modified)
	if success then
		success = upgrade_new_version(update_response)
	end

	if success then
		return {
			status = "Updated",
			-- message = "资源已更新，点击重启游戏。"
			message = "资源已更新，点击关闭游戏"
		}
	else
		return {
			status = "Error",
			title = "升级失败",
			message = "升级失败，但已保留进度，下次将自动续传。\n\n" .. table.concat(error_log_lines, "\n")
		}
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

	-- 清空通道
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
			-- 协程执行异常
			table.insert(update_log_lines, "[错误] " .. tostring(result))
			table.insert(error_log_lines, tostring(result))
			self.co = nil
			-- 确保线程退出
			love.thread.getChannel("um_http_req"):push("quit")
			if http_worker then
				http_worker:wait()
			end
			-- 【修复】在线程清理完成后显示消息框
			love.window.showMessageBox("升级失败", "更新过程异常。\n\n" .. tostring(result), {"确定"})
			self:done_callback()
		elseif coroutine.status(self.co) == "dead" then
			-- 协程正常结束，处理返回结果
			self.co = nil
			-- 无论什么情况，都要清理线程
			love.thread.getChannel("um_http_req"):push("quit")
			if http_worker then
				http_worker:wait()
			end

			-- 【修复】线程清理完成后，根据结果显示消息框并执行相应操作
			if result.status == "NoUpdate" then
				-- 无更新，继续启动游戏
				self:done_callback()
			elseif result.status == "AskUpdate" then
				-- 询问是否更新
				local pressed = love.window.showMessageBox("发现新版本", result.message, {"更新", "取消"})
				if pressed == 1 then
					-- 用户选择更新，创建新协程执行更新
					http_worker = love.thread.newThread(HTTP_WORKER)
					http_worker:start()
					self.co = coroutine.create(do_update)
				else
					-- 用户取消更新
					self:done_callback()
				end
			elseif result.status == "Updated" then
				-- 更新完成，显示成功消息并重启
				love.window.showMessageBox("升级完成", result.message, {"确定"})
				-- R.tmp()
				love.event.quit()
			elseif result.status == "Error" then
				-- 更新失败，显示错误消息
				love.window.showMessageBox(result.title or "错误", result.message, {"确定"})
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

	-- 【修复2】优化进度显示，避免闪烁
	G.setColor(1, 1, 1, 1)
	local log_y = (h - th) / 3 + 60

	-- 显示日志
	for i, line in ipairs(update_log_lines) do
		G.print(line, 40, log_y + (i - 1) * 22)
	end

	-- 显示当前进度条（如果正在下载）
	if state == STATE_DOWNLOADING_ASSETS or state == STATE_DOWNLOADING_CODE then
		if current_download_progress > 0 and current_download_progress < 100 then
			local bar_y = log_y + #update_log_lines * 22 + 10
			local bar_w = w - 80
			local bar_h = 20
			local bar_x = 40

			-- 背景
			G.setColor(0.3, 0.3, 0.3, 1)
			G.rectangle("fill", bar_x, bar_y, bar_w, bar_h)

			-- 进度
			G.setColor(0.2, 0.8, 0.3, 1)
			G.rectangle("fill", bar_x, bar_y, bar_w * current_download_progress / 100, bar_h)

			-- 边框
			G.setColor(1, 1, 1, 1)
			G.rectangle("line", bar_x, bar_y, bar_w, bar_h)

		-- 百分比文字
		-- local progress_text = string.format("%.1f%%", current_download_progress)
		-- local progress_tw = font:getWidth(progress_text)
		-- G.print(progress_text, bar_x + (bar_w - progress_tw) / 2, bar_y + 2)
		end
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
