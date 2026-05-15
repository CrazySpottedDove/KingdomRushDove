-- 【修复版】解决闪烁、特殊字符、删除失败、重启卡死问题
-- 修复内容：
-- 1. ✓ 符号改为文字，避免编码问题
-- 2. 进度显示优化，避免频繁刷新导致闪烁
-- 3. 删除文件使用 FU.delete_file 而非 os.remove
-- 4. 重启卡死修复：在协程外（M:update）清理线程后再执行重启，避免在协程内调用quit导致卡死
-- 5. 【新增】现代化 UI：卡片式界面、动画、详细信息

local M = {}
local storage = require("all.storage")
local G = love.graphics
local FS = love.filesystem
local font_title = require("lib.klove.font_db"):f("msyh", 28)
local font_normal = require("lib.klove.font_db"):f("msyh", 18)
local font_small = require("lib.klove.font_db"):f("msyh", 14)
local font = font_normal -- 兼容旧代码
local FU = require("all.file_utlis")

-- UI 动画状态
local ui_state = {
	progress_display = 0, -- 显示用的进度（平滑动画）
	progress_target = 0, -- 目标进度
	pulse_time = 0, -- 脉冲动画计时
	fade_alpha = 0, -- 淡入动画
	bytes_downloaded = 0, -- 已下载字节
	bytes_total = 0, -- 总字节
	download_start_time = 0, -- 下载开始时间
	current_file = "", -- 当前文件名
	files_done = 0, -- 已完成文件数
	files_total = 0, -- 总文件数
	speed_samples = {}, -- 速度采样（用于计算平均速度）
	last_bytes = 0, -- 上次记录的字节数
	last_sample_time = 0 -- 上次采样时间
}

-- 本模块只在非安卓平台启用
local apply_upgrade = not IS_ANDROID
-- DEBUG 不启用
apply_upgrade = apply_upgrade and not (arg[2] == "debug" or arg[2] == "release")

local R = require("all.restart")

-- 更新状态定义
local STATE_DOWNLOADING_ASSETS = 1
local STATE_DOWNLOADING_CODE = 2
local STATE_COMMITTING_CHANGES = 3
local STATE_SELECT_URL = 4
local STATE_CHECK_UPDATE = 5
local STATE_CHECKING_ASSETS = 6
local STATE_DOWNLOADING_ASSETS_HEAVY = 7 -- 【新增】大规模资源更新状态（超过1000个文件）
local STATE_DOWNLOADING_ASSETS_MIDDLE_HEAVY = 8 -- 【新增】中等规模资源更新状态（超过100个文件）
local STATE_STRING_MAP = {
	[STATE_CHECKING_ASSETS] = "校验美术资源中……",
	[STATE_DOWNLOADING_ASSETS] = "下载美术资源中（可能需要较长时间）……",
	[STATE_DOWNLOADING_CODE] = "下载代码资源中……",
	[STATE_COMMITTING_CHANGES] = "提交更新事务中……",
	[STATE_SELECT_URL] = "选择更新地址中……",
	[STATE_CHECK_UPDATE] = "检查更新中……",
	[STATE_DOWNLOADING_ASSETS_HEAVY] = "下载巨量美术资源中，强烈建议直接下载本体⊙﹏⊙∥",
	[STATE_DOWNLOADING_ASSETS_MIDDLE_HEAVY] = "下载大量美术资源中，如不成功可下载本体……"
}
local state = STATE_DOWNLOADING_ASSETS
local update_log_line_max_count = 20

-- 日志记录
local update_log_lines = {}
local error_log_lines = {}

-- 【关键配置】分块下载 - 避免超时
local DOWNLOAD_CONFIG = {
	chunk_size_initial = 1 * 1024 * 1024, -- 初始块大小 1MB
	chunk_size_min = 64 * 1024, -- 最小块大小 64KB
	chunk_timeout = 45, -- 单块超时 45 秒
	chunk_max_retries = 5, -- 单块最多重试 5 次（移除文件级重试）
	retry_backoff_base = 1.5, -- 退避基数（缩短）
	retry_backoff_max = 8, -- 最大退避 8 秒（大幅缩短）
	network_error_delay = 5, -- 网络错误延迟 5 秒（缩短）
	base_timeout = 20, -- 基础超时（用于小请求）
	progress_update_interval = 0.3 -- 进度更新间隔
}

-- 当前自适应的块大小（会根据网络情况动态调整，单次更新中保持）
local current_chunk_size = DOWNLOAD_CONFIG.chunk_size_initial
-- 连续成功计数（用于判断是否可以增大块大小）
local consecutive_success_count = 0

-- 更新目录（基于 local_hash + server_hash）
local update_cache_dir = nil

-- 进度跟踪（避免频繁刷新日志）
local last_progress_update = 0
local current_download_progress = 0

-- UTF-8 清理函数：移除无效的 UTF-8 字节序列
local function sanitize_utf8(s)
	if type(s) ~= "string" then
		return tostring(s)
	end

	local utf8 = require("utf8")
	local result = {}
	local i = 1
	local len = #s

	while i <= len do
		local byte = string.byte(s, i)

		-- 处理 UTF-8 多字节序列
		if byte < 0x80 then
			-- ASCII 单字节
			result[#result + 1] = string.char(byte)
			i = i + 1
		elseif byte < 0xC0 then
			-- 无效的 UTF-8 起始字节，跳过
			i = i + 1
		elseif byte < 0xE0 then
			-- 2 字节序列
			if i + 1 <= len then
				local byte2 = string.byte(s, i + 1)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 1)
					i = i + 2
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		elseif byte < 0xF0 then
			-- 3 字节序列
			if i + 2 <= len then
				local byte2 = string.byte(s, i + 1)
				local byte3 = string.byte(s, i + 2)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 and byte3 >= 0x80 and byte3 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 2)
					i = i + 3
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		elseif byte < 0xF8 then
			-- 4 字节序列
			if i + 3 <= len then
				local byte2 = string.byte(s, i + 1)
				local byte3 = string.byte(s, i + 2)
				local byte4 = string.byte(s, i + 3)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 and byte3 >= 0x80 and byte3 < 0xC0 and byte4 and byte4 >= 0x80 and byte4 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 3)
					i = i + 4
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		else
			-- 无效字节，跳过
			i = i + 1
		end
	end

	return table.concat(result)
end

-- UTF-8 安全的字符串截断函数：按字符（不是字节）数截断
-- 当截断到不完整的 UTF-8 字符时，会舍弃该字符
local function utf8_sub(s, max_chars)
	if type(s) ~= "string" or max_chars <= 0 then
		return ""
	end

	local utf8 = require("utf8")
	local result = {}
	local char_count = 0
	local i = 1
	local len = #s

	while i <= len and char_count < max_chars do
		local byte = string.byte(s, i)

		if byte < 0x80 then
			-- ASCII 单字节字符
			result[#result + 1] = string.char(byte)
			char_count = char_count + 1
			i = i + 1
		elseif byte < 0xC0 then
			-- 无效的 UTF-8 起始字节，跳过
			i = i + 1
		elseif byte < 0xE0 then
			-- 2 字节序列
			if i + 1 <= len then
				local byte2 = string.byte(s, i + 1)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 1)
					char_count = char_count + 1
					i = i + 2
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		elseif byte < 0xF0 then
			-- 3 字节序列（中文字符）
			if i + 2 <= len then
				local byte2 = string.byte(s, i + 1)
				local byte3 = string.byte(s, i + 2)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 and byte3 >= 0x80 and byte3 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 2)
					char_count = char_count + 1
					i = i + 3
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		elseif byte < 0xF8 then
			-- 4 字节序列
			if i + 3 <= len then
				local byte2 = string.byte(s, i + 1)
				local byte3 = string.byte(s, i + 2)
				local byte4 = string.byte(s, i + 3)
				if byte2 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 and byte3 >= 0x80 and byte3 < 0xC0 and byte4 and byte4 >= 0x80 and byte4 < 0xC0 then
					result[#result + 1] = string.sub(s, i, i + 3)
					char_count = char_count + 1
					i = i + 4
				else
					i = i + 1
				end
			else
				i = i + 1
			end
		else
			-- 无效字节，跳过
			i = i + 1
		end
	end

	return table.concat(result)
end

local function point_in_rect(x, y, rect)
	return rect and x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h
end

local function clamp(v, min_v, max_v)
	if v < min_v then
		return min_v
	elseif v > max_v then
		return max_v
	end
	return v
end

local function log_info(line)
	table.insert(update_log_lines, sanitize_utf8(line))
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	coroutine.yield()
end

-- 记录错误日志
local function log_error(line)
	table.insert(update_log_lines, "[错误] " .. sanitize_utf8(line))
	if #update_log_lines > update_log_line_max_count then
		table.remove(update_log_lines, 1)
	end
	table.insert(error_log_lines, sanitize_utf8(line))
	coroutine.yield()
end

-- 更新进度（避免频繁刷新）+ 收集详细信息用于现代 UI
local function update_progress(percent, force, bytes_downloaded, bytes_total)
	local now = love.timer.getTime()
	if force or (now - last_progress_update) > DOWNLOAD_CONFIG.progress_update_interval then
		current_download_progress = percent
		last_progress_update = now

		-- 更新 UI 状态
		ui_state.progress_target = percent
		if bytes_downloaded then
			ui_state.bytes_downloaded = bytes_downloaded
		end
		if bytes_total then
			ui_state.bytes_total = bytes_total
		end

		-- 采样下载速度（每 0.5 秒一次）
		if bytes_downloaded and (now - ui_state.last_sample_time) >= 0.5 then
			local delta_bytes = bytes_downloaded - ui_state.last_bytes
			local delta_time = now - ui_state.last_sample_time
			if delta_time > 0 then
				local speed = delta_bytes / delta_time
				table.insert(ui_state.speed_samples, speed)
				-- 只保留最近 10 个样本
				if #ui_state.speed_samples > 10 then
					table.remove(ui_state.speed_samples, 1)
				end
			end
			ui_state.last_bytes = bytes_downloaded
			ui_state.last_sample_time = now
		end
	end
end

-- 设置当前下载文件信息（用于 UI 显示）
local function set_current_file(filename, file_index, file_total)
	ui_state.current_file = filename or ""
	ui_state.files_done = file_index or 0
	ui_state.files_total = file_total or 0
end

local function set_state(new_state)
	state = new_state
	-- 重置下载开始时间
	if new_state == STATE_DOWNLOADING_ASSETS or new_state == STATE_DOWNLOADING_CODE then
		ui_state.download_start_time = love.timer.getTime()
		ui_state.speed_samples = {}
		ui_state.last_bytes = 0
		ui_state.last_sample_time = love.timer.getTime()
	end
end

-- 【新增】生成更新缓存目录名（基于 local_hash 和 server_hash）
local function get_update_cache_dir(local_hash, server_hash)
	-- 取 hash 前 8 位作为目录名
	local short_local = local_hash:sub(1, 8)
	local short_server = server_hash:sub(1, 8)
	return string.format("tmp/update_%s_%s", short_local, short_server)
end

-- 【新增】清理过时的更新缓存目录
local function cleanup_old_update_dirs(current_dir)
	local tmp_items = FS.getDirectoryItems("tmp")
	if not tmp_items then
		return
	end

	for _, item in ipairs(tmp_items) do
		if item:match("^update_") then
			local full_path = "tmp/" .. item
			if full_path ~= current_dir then
				-- 这是一个过时的更新目录，删除它
				local info = FS.getInfo(full_path)
				if info and info.type == "directory" then
					-- 递归删除目录内容
					local function remove_dir_recursive(dir_path)
						local items = FS.getDirectoryItems(dir_path)
						for _, sub_item in ipairs(items or {}) do
							local sub_path = dir_path .. "/" .. sub_item
							local sub_info = FS.getInfo(sub_path)
							if sub_info then
								if sub_info.type == "directory" then
									remove_dir_recursive(sub_path)
								else
									FS.remove(sub_path)
								end
							end
						end
						FS.remove(dir_path)
					end
					remove_dir_recursive(full_path)
					log_info("清理旧缓存: " .. item)
				end
			end
		end
	end
end

-- 【新增】确保更新缓存目录存在
local function ensure_update_cache_dir(local_hash, server_hash)
	local dir = get_update_cache_dir(local_hash, server_hash)

	-- 确保 tmp 目录存在
	FS.createDirectory("tmp")

	-- 清理旧的更新目录
	cleanup_old_update_dirs(dir)

	-- 创建当前更新目录
	FS.createDirectory(dir)
	FS.createDirectory(dir .. "/code")
	FS.createDirectory(dir .. "/assets")

	update_cache_dir = dir
	return dir
end

-- 【新增】获取文件在缓存目录中的路径
local function get_cached_file_path(file_path, file_type)
	if not update_cache_dir then
		return nil
	end
	-- file_type: "code" 或 "assets"
	return update_cache_dir .. "/" .. file_type .. "/" .. file_path
end

-- 【新增】检查文件是否已经完整下载到缓存
local function is_file_cached(file_path, file_type, expected_size)
	local cached_path = get_cached_file_path(file_path, file_type)
	if not cached_path then
		return false
	end

	local info = FS.getInfo(cached_path)
	if info and info.size == expected_size then
		return true
	end
	return false
end

-- 【新增】根据网络状况动态调整块大小
local function adjust_chunk_size(success)
	if success then
		consecutive_success_count = consecutive_success_count + 1
		-- 连续 5 次成功后才尝试增大块大小
		if consecutive_success_count >= 5 and current_chunk_size < DOWNLOAD_CONFIG.chunk_size_initial then
			current_chunk_size = math.min(current_chunk_size * 1.5, DOWNLOAD_CONFIG.chunk_size_initial)
			consecutive_success_count = 0
			log_info(string.format("网络稳定，增大块: %dKB", current_chunk_size / 1024))
		end
	else
		-- 失败时立即减半块大小（但不低于最小值）
		consecutive_success_count = 0
		local old_size = current_chunk_size
		current_chunk_size = math.max(current_chunk_size / 2, DOWNLOAD_CONFIG.chunk_size_min)
		if current_chunk_size ~= old_size then
			log_info(string.format("网络不稳定，减小块: %dKB", current_chunk_size / 1024))
		end
	end
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
		log_error("网络错误: " .. tostring(code))
		return true, "network"
	end
	if code >= 500 then -- 服务器错误
		log_error("服务器错误: HTTP " .. tostring(code))
		return true, "server"
	end
	if code == 408 or code == 429 then -- 超时或限流
		log_error("请求超时或被限流: HTTP " .. tostring(code))
		return true, "throttle"
	end
	if code == 404 then -- 文件不存在
		log_error("文件未找到: HTTP 404")
		return false, "not_found"
	end
	if code == 416 then -- Range 无效
		log_error("请求的范围无效: HTTP 416")
		return false, "invalid_range"
	end
	if code >= 400 and code < 500 then
		log_error("客户端错误: HTTP " .. tostring(code))
		return retry_count < 3, "client" -- 其他客户端错误，最多3次
	end
	return true, "unknown"
end

-- 计算退避时间
local function calculate_backoff(retry_count, error_type)
	-- 【优化】缩短退避时间，让用户不会感觉卡住
	if error_type == "network" then
		return DOWNLOAD_CONFIG.network_error_delay
	end
	-- 使用更短的退避时间：1.5^n，上限 8 秒
	local backoff = math.min(DOWNLOAD_CONFIG.retry_backoff_base ^ retry_count, DOWNLOAD_CONFIG.retry_backoff_max)
	return math.floor(backoff)
end

-- 校验分块响应；返回是否有效，以及下载后总长度（nil 表示不更新）
local function validate_chunk_response(code, body, headers, chunk_start, chunk_end, total_size, current_size)
	if code == 206 then
		local range_start, range_end, range_total = parse_content_range(headers and headers["content-range"])
		local expected_len = chunk_end - chunk_start + 1
		if range_start ~= chunk_start or range_end ~= chunk_end or range_total ~= total_size or #body ~= expected_len then
			log_error(string.format("分块响应异常：请求 %d-%d，收到 %s，长度 %d", chunk_start, chunk_end, tostring(headers and headers["content-range"]), #body))
			return false, nil
		end
		return true, current_size + #body
	end

	if code == 200 then
		-- 某些代理会忽略 Range 返回整文件；仅接受完整文件长度，且按覆盖处理。
		if #body == total_size then
			return true, total_size
		end
		log_error(string.format("分块响应异常：Range 请求返回 200 但长度不符（%d vs %d）", #body, total_size))
		return false, nil
	end

	return false, nil
end

-- 【核心函数】分块下载到真实文件系统（支持断点续传）
-- 使用自适应块大小
local function download_to_file_chunked(url_base, file_param, real_path)
	local part_path = real_path .. ".part"

	-- 使用当前自适应的块大小
	local chunk_size = current_chunk_size

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
		if downloaded_size > total_size then
			log_info(string.format("检测到异常续传文件（%d > %d），自动重置重下", downloaded_size, total_size))
			os.remove(part_path)
			downloaded_size = 0
		end
		if downloaded_size > 0 then
			log_info(string.format("续传 %.2f/%.2f MB", downloaded_size / 1024 / 1024, total_size / 1024 / 1024))
		end
	end

	-- 分块下载
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
				local ok_resp, new_size = validate_chunk_response(code, body, headers, chunk_start, chunk_end, total_size, downloaded_size)
				if ok_resp then
					local write_mode = code == 200 and "wb" or "ab"
					local wf = io.open(part_path, write_mode)
					if not wf then
						log_error("无法打开文件写入")
						return false
					end
					wf:write(body)
					wf:close()

					downloaded_size = new_size

					-- 更新进度（传递字节信息用于 UI）
					local percent = downloaded_size * 100.0 / total_size
					update_progress(percent, true, downloaded_size, total_size)

					chunk_success = true
					break
				end
				code = 0 -- 响应内容非法，按可重试网络错误处理
			end

			if not chunk_success then
				-- 失败，判断是否重试
				local should_retry_flag, error_type = should_retry_error(code, chunk_retries)

				if not should_retry_flag then
					log_error(string.format("下载失败: HTTP %d", code))
					return false
				end

				chunk_retries = chunk_retries + 1
				if chunk_retries > DOWNLOAD_CONFIG.chunk_max_retries then
					log_error("块下载失败（超过重试限制）")
					return false
				end

				-- 【优化】使用自适应块大小
				adjust_chunk_size(false)
				-- 更新本次循环使用的块大小
				chunk_size = current_chunk_size

				local backoff = calculate_backoff(chunk_retries, error_type)
				log_info(string.format("重试中 (%d/%d, %ds, 块%dKB)...", chunk_retries, DOWNLOAD_CONFIG.chunk_max_retries, backoff, chunk_size / 1024))
				async_sleep(backoff)
			end
		end

		-- 【优化】成功下载块后，尝试逐步恢复块大小
		if chunk_success then
			adjust_chunk_size(true)
			chunk_size = current_chunk_size
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

-- 【核心函数】分块下载到 LÖVE 文件系统（使用自适应块大小）
local function download_to_lovefs_chunked(url_base, file_param, fs_path)
	local part_path = fs_path .. ".part"
	-- 使用自适应块大小
	local chunk_size = current_chunk_size

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
	if downloaded_size > total_size then
		log_info(string.format("检测到异常续传文件（%d > %d），自动重置重下", downloaded_size, total_size))
		FS.remove(part_path)
		existing = ""
		downloaded_size = 0
	end

	if downloaded_size > 0 then
		log_info(string.format("续传 %.2f/%.2f KB", downloaded_size / 1024, total_size / 1024))
	end

	-- 分块下载（移除文件级别重试，只保留块级别重试）
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
				local ok_resp, new_size = validate_chunk_response(code, body, headers, chunk_start, chunk_end, total_size, downloaded_size)
				if ok_resp then
					if code == 200 then
						existing = body
					else
						existing = existing .. body
					end
					FS.write(part_path, existing)
					downloaded_size = new_size

					-- 更新进度（传递字节信息用于 UI）
					local percent = downloaded_size * 100.0 / total_size
					update_progress(percent, true, downloaded_size, total_size)

					chunk_success = true
					break
				end
				code = 0 -- 响应内容非法，按可重试网络错误处理
			end

			if not chunk_success then
				local should_retry_flag, error_type = should_retry_error(code, chunk_retries)

				if not should_retry_flag then
					log_error(string.format("下载失败: HTTP %d", code))
					return false, nil
				end

				chunk_retries = chunk_retries + 1
				if chunk_retries > DOWNLOAD_CONFIG.chunk_max_retries then
					log_error("块下载失败（超过重试限制）")
					return false, nil
				end

				-- 使用自适应块大小
				adjust_chunk_size(false)
				chunk_size = current_chunk_size

				local backoff = calculate_backoff(chunk_retries, error_type)
				log_info(string.format("重试中 (%d/%d, %ds, 块%dKB)...", chunk_retries, DOWNLOAD_CONFIG.chunk_max_retries, backoff, chunk_size / 1024))
				async_sleep(backoff)
			end
		end

		-- 成功下载块后，尝试恢复块大小
		if chunk_success then
			adjust_chunk_size(true)
			chunk_size = current_chunk_size
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
	local local_assets_index = love.filesystem.load("_assets/assets_index.lua")()

	local added_or_modified = {}
	for file, info in pairs(remote_assets_index) do
		local local_info = local_assets_index[file]
		if not local_info then
			added_or_modified[#added_or_modified + 1] = file
		else
			if not local_info[2] then
				local_info[2] = file_hash("_assets/" .. file)
			end

			if local_info[1] ~= info[1] or local_info[2] ~= info[2] then
				added_or_modified[#added_or_modified + 1] = file
			end
		end
	end

	FS.remove(tmp_dir)
	return added_or_modified
end

-- 【重构】下载资源到缓存目录（不直接覆盖本地文件）
local function sync_assets(added_or_modified)
	if not server_address or not update_cache_dir then
		return true
	end

	local url_base = server_address .. "assets/download"
	local file_count = #added_or_modified

	if file_count > 1000 then
		set_state(STATE_DOWNLOADING_ASSETS_HEAVY)
	elseif file_count > 100 then
		set_state(STATE_DOWNLOADING_ASSETS_MIDDLE_HEAVY)
	else
		set_state(STATE_DOWNLOADING_ASSETS)
	end

	for i, file_path in ipairs(added_or_modified) do
		-- 下载到缓存目录，而不是直接覆盖本地文件
		local cached_path = update_cache_dir .. "/assets/" .. file_path

		-- 设置当前文件信息（用于 UI）
		set_current_file(file_path, i, file_count)
		log_info(string.format("[资源 %d/%d] %s", i, file_count, file_path))

		-- 检查是否已经在缓存中（断点续传）
		local cached_info = FS.getInfo(cached_path)
		if cached_info and cached_info.size and cached_info.size > 0 then
			log_info("已缓存，跳过")
		else
			FU.ensure_parent_dir(cached_path)
			local ok = download_to_file_chunked(url_base, file_path, cached_path)

			if not ok then
				log_error("下载失败: " .. file_path)
				return false
			end
		end
	end

	return true
end

-- 【重构】下载代码到缓存目录
local function upgrade_new_version(info)
	set_state(STATE_DOWNLOADING_CODE)

	local added_or_modified = info.added_or_modified_files or {}
	local url_base = server_address .. "file"
	local file_count = #added_or_modified

	for i, file_path in ipairs(added_or_modified) do
		-- 下载到缓存目录
		local cached_path = update_cache_dir .. "/code/" .. file_path

		-- 设置当前文件信息（用于 UI）
		set_current_file(file_path, i, file_count)
		log_info(string.format("[代码 %d/%d] %s", i, file_count, file_path))

		-- 检查是否已经在缓存中（断点续传）
		local cached_info = FS.getInfo(cached_path)
		if cached_info and cached_info.size and cached_info.size > 0 then
			log_info("已缓存，跳过")
		else
			FU.ensure_parent_dir(cached_path)
			local ok, _ = download_to_lovefs_chunked(url_base, file_path, cached_path)

			if not ok then
				log_error("下载失败: " .. file_path)
				return false
			end
		end
	end

	return true
end

-- 【新增】统一提交所有更改（代码 + 资源）
local function commit_all_changes(info)
	set_state(STATE_COMMITTING_CHANGES)

	local added_or_modified_code = info.added_or_modified_files or {}
	local added_or_modified_assets = info.added_or_modified_assets or {}
	local deleted_files = info.deleted_files or {}

	-- 1. 提交代码文件
	for _, file_path in ipairs(added_or_modified_code) do
		local cached_path = update_cache_dir .. "/code/" .. file_path
		local content = FS.read(cached_path)
		if content then
			FU.ensure_parent_dir(file_path)
			if not FU.write_file(file_path, content) then
				log_error("写入代码失败: " .. file_path)
				return false
			end
			log_info("提交代码: " .. file_path)
		else
			log_error("读取缓存失败: " .. cached_path)
			return false
		end
	end

	-- 2. 提交资源文件（从缓存复制到 _assets/）
	for _, file_path in ipairs(added_or_modified_assets) do
		local cached_path = update_cache_dir .. "/assets/" .. file_path
		local local_path = "_assets/" .. file_path

		-- 读取缓存文件
		local rf = io.open(cached_path, "rb")
		if not rf then
			log_error("读取资源缓存失败: " .. cached_path)
			return false
		end
		local content = rf:read("*a")
		rf:close()

		-- 写入本地文件
		FU.ensure_parent_dir(local_path)
		local wf = io.open(local_path, "wb")
		if not wf then
			log_error("写入资源失败: " .. local_path)
			return false
		end
		wf:write(content)
		wf:close()
		log_info("提交资源: " .. file_path)
	end

	-- 3. 删除文件
	for _, file_path in ipairs(deleted_files) do
		if FS.getInfo(file_path) then
			local success = FU.delete_file(file_path)
			if not success then
				log_error("删除文件失败: " .. file_path)
			-- 不中断更新
			else
				log_info("删除: " .. file_path)
			end
		end
	end

	-- 4. 更新版本号
	if info.master_commit_hash then
		if not FU.write_file("current_version_commit_hash.txt", info.master_commit_hash) then
			log_error("更新版本号失败")
			return false
		end
	end

	-- 5. 清理缓存目录
	cleanup_old_update_dirs(nil) -- 传 nil 表示清理所有更新目录

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
	for _, commit in ipairs(update_response.commits or {}) do
		table.insert(messages, commit.message)
	end

	-- 【修复】返回状态，让主循环显示消息框
	return {
		status = "AskUpdate",
		message = "检测到有新内容可更新，是否立即更新？\n\n" .. table.concat(messages, "\n\n")
	}
end

local function do_update()
	-- 【新增】初始化缓存目录
	local local_hash = FS.read("current_version_commit_hash.txt")
	if local_hash then
		local_hash = local_hash:match("^%s*(.-)%s*$")
	else
		local_hash = "unknown"
	end
	local server_hash = update_response.master_commit_hash or "unknown"
	ensure_update_cache_dir(local_hash, server_hash)
	log_info("缓存目录: " .. update_cache_dir)

	-- 1. 检查资源差异
	local added_or_modified_assets = diff_assets()
	if not added_or_modified_assets then
		return {
			status = "Error",
			title = "升级失败",
			message = "校验美术资源时发生错误。\n\n" .. table.concat(error_log_lines, "\n")
		}
	end

	-- 2. 下载资源到缓存
	local success = sync_assets(added_or_modified_assets)
	if not success then
		return {
			status = "Error",
			title = "升级失败",
			message = "下载资源失败，但已保留进度，下次将自动续传。\n\n" .. table.concat(error_log_lines, "\n")
		}
	end

	-- 3. 下载代码到缓存
	success = upgrade_new_version(update_response)
	if not success then
		return {
			status = "Error",
			title = "升级失败",
			message = "下载代码失败，但已保留进度，下次将自动续传。\n\n" .. table.concat(error_log_lines, "\n")
		}
	end

	-- 4. 【关键】所有下载完成后，统一提交更改
	-- 构建完整的更新信息
	local commit_info = {
		added_or_modified_files = update_response.added_or_modified_files or {},
		added_or_modified_assets = added_or_modified_assets,
		deleted_files = update_response.deleted_files or {},
		master_commit_hash = update_response.master_commit_hash
	}

	success = commit_all_changes(commit_info)
	if not success then
		return {
			status = "Error",
			title = "升级失败",
			message = "提交更改失败。\n\n" .. table.concat(error_log_lines, "\n")
		}
	end

	return {
		status = "Updated",
		message = "资源已更新，点击关闭游戏"
	}
end

function M:_open_dialog(title, message, buttons, on_select)
	self._dialog = {
		title = sanitize_utf8(title or ""),
		message = sanitize_utf8(message or ""),
		buttons = buttons or {{
			text = "确定",
			value = "ok",
			is_default = true,
			is_cancel = true
		}},
		on_select = on_select
	}
	self._dialog_scroll_y = 0
	self._dialog_dragging = false
	self._dialog_drag_button = nil
	self._dialog_drag_start_y = 0
	self._dialog_scroll_start = 0
	self._dialog_hover_button_index = nil
	self._dialog_focus_index = 1
	for i, btn in ipairs(self._dialog.buttons) do
		if btn.is_default then
			self._dialog_focus_index = i
			break
		end
	end
	self._dialog_layout = nil
end

function M:_close_dialog(button_index)
	local dialog = self._dialog
	if not dialog then
		return
	end
	self._dialog = nil
	self._dialog_layout = nil
	self._dialog_dragging = false
	self._dialog_drag_button = nil
	self._dialog_hover_button_index = nil
	local callback = dialog.on_select
	if callback then
		callback(dialog.buttons[button_index], button_index)
	end
end

function M:_activate_dialog_button(button_index)
	local dialog = self._dialog
	if not dialog or not dialog.buttons[button_index] then
		return
	end
	self:_close_dialog(button_index)
end

function M:_get_dialog_layout()
	if not self._dialog then
		return nil
	end
	local w, h = G.getDimensions()
	local panel_w = math.max(420, math.min(math.floor(w * 0.72), w - 80))
	local panel_h = math.max(220, math.min(math.floor(h * 0.6), h - 80))
	local panel_x = math.floor((w - panel_w) / 2)
	local panel_y = math.floor((h - panel_h) / 2)
	local btn_count = math.max(1, #self._dialog.buttons)
	local btn_gap = 12
	local available_btn_w = panel_w - 40 - (btn_count - 1) * btn_gap
	local btn_w = math.max(110, math.min(180, math.floor(available_btn_w / btn_count)))
	local total_btn_w = btn_w * btn_count + (btn_count - 1) * btn_gap
	local btn_x = panel_x + math.floor((panel_w - total_btn_w) / 2)
	local btn_y = panel_y + panel_h - 56
	local btn_h = 36
	local buttons = {}
	for i = 1, btn_count do
		buttons[i] = {
			x = btn_x + (i - 1) * (btn_w + btn_gap),
			y = btn_y,
			w = btn_w,
			h = btn_h
		}
	end
	self._dialog_layout = {
		x = panel_x,
		y = panel_y,
		w = panel_w,
		h = panel_h,
		title_x = panel_x + 24,
		title_y = panel_y + 18,
		text_x = panel_x + 24,
		text_y = panel_y + 58,
		text_w = panel_w - 48,
		text_h = panel_h - 124,
		text_padding = 12,
		buttons = buttons
	}
	return self._dialog_layout
end

function M:_get_dialog_text_metrics(layout)
	local dialog = self._dialog
	if not dialog or not layout then
		return nil
	end
	local text_w = math.max(60, layout.text_w - layout.text_padding * 2)
	local text_h = math.max(40, layout.text_h - layout.text_padding * 2)
	if dialog._cache_text_w ~= text_w then
		local _, wrapped = font_normal:getWrap(dialog.message or "", text_w)
		dialog._wrapped_lines = wrapped or {""}
		dialog._cache_text_w = text_w
	end
	local line_h = font_normal:getHeight() + 4
	local content_h = #dialog._wrapped_lines * line_h
	local max_scroll = math.max(0, content_h - text_h)
	return {
		text_w = text_w,
		text_h = text_h,
		line_h = line_h,
		content_h = content_h,
		max_scroll = max_scroll,
		lines = dialog._wrapped_lines
	}
end

function M:_set_dialog_scroll(scroll_y)
	local layout = self:_get_dialog_layout()
	local metrics = self:_get_dialog_text_metrics(layout)
	if not metrics then
		self._dialog_scroll_y = 0
		return
	end
	self._dialog_scroll_y = clamp(scroll_y or 0, 0, metrics.max_scroll)
end

function M:_scroll_dialog_by(delta)
	self:_set_dialog_scroll((self._dialog_scroll_y or 0) + delta)
end

function M:init(params, done_callback)
	apply_upgrade = apply_upgrade and params.update_enabled

	self.done_callback = done_callback
	self.params = params
	self._dialog = nil
	self._dialog_layout = nil
	self._dialog_focus_index = 1
	self._dialog_scroll_y = 0
	self._dialog_dragging = false
	self._dialog_drag_button = nil
	self._dialog_drag_start_y = 0
	self._dialog_scroll_start = 0
	self._dialog_hover_button_index = nil
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
	if self._dialog then
		if self._dialog_dragging then
			local drag_button = self._dialog_drag_button or 1
			if not love.mouse.isDown(drag_button) then
				self._dialog_dragging = false
				self._dialog_drag_button = nil
			else
				local _, my = love.mouse.getPosition()
				local delta = my - (self._dialog_drag_start_y or my)
				self:_set_dialog_scroll((self._dialog_scroll_start or 0) - delta)
			end
		end
		return
	end
	if self.co then
		local success, result = coroutine.resume(self.co)
		if not success then
			-- 协程执行异常
			table.insert(update_log_lines, "[错误] " .. sanitize_utf8(tostring(result)))
			table.insert(error_log_lines, sanitize_utf8(tostring(result)))
			self.co = nil
			-- 确保线程退出
			love.thread.getChannel("um_http_req"):push("quit")
			if http_worker then
				http_worker:wait()
			end
			self:_open_dialog("升级失败", "更新过程异常。\n\n" .. sanitize_utf8(tostring(result)), {{
				text = "确定",
				value = "ok",
				is_default = true,
				is_cancel = true
			}}, function()
				self:done_callback()
			end)
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
				self:_open_dialog("发现新版本", result.message, {{
					text = "更新",
					value = "update",
					is_default = true
				}, {
					text = "取消",
					value = "cancel",
					is_cancel = true
				}}, function(btn)
					if btn and btn.value == "update" then
						http_worker = love.thread.newThread(HTTP_WORKER)
						http_worker:start()
						self.co = coroutine.create(do_update)
					else
						self:done_callback()
					end
				end)
			elseif result.status == "Updated" then
				-- 更新完成，显示成功消息并重启
				self:_open_dialog("升级完成", result.message, {{
					text = "确定",
					value = "ok",
					is_default = true,
					is_cancel = true
				}}, function()
					love.event.quit()
				end)
			elseif result.status == "Error" then
				-- 更新失败，显示错误消息
				self:_open_dialog(result.title or "错误", result.message, {{
					text = "确定",
					value = "ok",
					is_default = true,
					is_cancel = true
				}}, function()
					self:done_callback()
				end)
			end
		end
	end
end

-- ============================================================
-- 【现代化 UI 绘制】
-- ============================================================

-- 绘制圆角矩形（填充模式）
local function draw_rounded_rect_fill(x, y, w, h, r)
	r = math.min(r, w / 2, h / 2)
	-- 中间主体
	G.rectangle("fill", x + r, y, w - 2 * r, h)
	-- 左右两侧
	G.rectangle("fill", x, y + r, r, h - 2 * r)
	G.rectangle("fill", x + w - r, y + r, r, h - 2 * r)
	-- 四个圆角
	G.arc("fill", x + r, y + r, r, math.pi, math.pi * 1.5)
	G.arc("fill", x + w - r, y + r, r, -math.pi / 2, 0)
	G.arc("fill", x + w - r, y + h - r, r, 0, math.pi / 2)
	G.arc("fill", x + r, y + h - r, r, math.pi / 2, math.pi)
end

-- 绘制圆角矩形边框（只画外圈弧线，无直角）
local function draw_rounded_rect_line(x, y, w, h, r)
	r = math.min(r, w / 2, h / 2)
	-- 四条直线
	G.line(x + r, y, x + w - r, y) -- 上
	G.line(x + w, y + r, x + w, y + h - r) -- 右
	G.line(x + w - r, y + h, x + r, y + h) -- 下
	G.line(x, y + h - r, x, y + r) -- 左
	-- 四个圆角（使用 "open" 模式避免画到圆心的连线）
	G.arc("line", "open", x + r, y + r, r, math.pi, math.pi * 1.5)
	G.arc("line", "open", x + w - r, y + r, r, -math.pi / 2, 0)
	G.arc("line", "open", x + w - r, y + h - r, r, 0, math.pi / 2)
	G.arc("line", "open", x + r, y + h - r, r, math.pi / 2, math.pi)
end

-- 格式化字节数
local function format_bytes(bytes)
	if bytes < 1024 then
		return string.format("%d B", bytes)
	elseif bytes < 1024 * 1024 then
		return string.format("%.1f KB", bytes / 1024)
	else
		return string.format("%.2f MB", bytes / 1024 / 1024)
	end
end

-- 格式化时间
local function format_time(seconds)
	if seconds < 60 then
		return string.format("%d秒", math.ceil(seconds))
	elseif seconds < 3600 then
		return string.format("%d分%d秒", math.floor(seconds / 60), math.floor(seconds % 60))
	else
		return string.format("%d时%d分", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
	end
end

-- ============================================================
-- 【像素画角色】Arch-chan (48x64)
-- ============================================================
local PIXEL_PALETTE = {
	[0] = nil, -- 透明
	[1] = {0.10, 0.14, 0.20}, -- 暗蓝
	[2] = {0.18, 0.24, 0.31}, -- 深蓝灰
	[3] = {0.27, 0.39, 0.51}, -- 中蓝
	[4] = {0.39, 0.59, 0.75}, -- 浅蓝
	[5] = {0.55, 0.75, 0.86}, -- 亮蓝
	[6] = {0.94, 0.78, 0.71}, -- 肤色亮
	[7] = {0.86, 0.69, 0.61}, -- 肤色
	[8] = {0.78, 0.59, 0.51}, -- 肤色暗
	[9] = {1.00, 1.00, 1.00} -- 白色
}

-- 48x64 像素画数据（Arch-chan）
local PIXEL_ART = {
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000",
	"000000000000000122222211000000000000000000000000",
	"000000000000012211111111111100000000000000000000",
	"000000000000111123211112202231000000000000000000",
	"000000000001111299931139921123100000000000000000",
	"000000000111110495341144950111320000000000000000",
	"000000001111110493431243590111131000000000000000",
	"000000012111111394578855691011124000000000000000",
	"000000121111111296777888991001103200000000000000",
	"000000321111212136677887730001122400000000000000",
	"000001311104311286666887630000363310000000000000",
	"000002211235213336666887731000772210000000000000",
	"000001210338343106666887824200762210000000000000",
	"000002112434530002666877102430867720000000000000",
	"000002124355200000367872010242088830000000000000",
	"000012124451000000087720100013202230000000000000",
	"000012014400000000002202200001320241000000000000",
	"000022023000000112100008800000133142000000000000",
	"000031230000002233200008620000014323000000000000",
	"000231300000028273800016963000001533100000000000",
	"000333100000173893630139967300010154100000000000",
	"000331000222668997760269699631200015300000000000",
	"001420000228838699793699968882210001400000000000",
	"003300001212531189969997211441221000220000000000",
	"013000012126943349999997343993122000110000000000",
	"011100011229995599999999555993121000010000000000",
	"010110011216996699999999969962221001100000000000",
	"021110111218999999999999999981221121101000000000",
	"023111111222869999999999999721221111102100000000",
	"002311111121279999999999996821211111113000000000",
	"000232111112289999999999999312211211232000000000",
	"001012321212236999999999962222112233320000000000",
	"001110121211437666999966688732113331000000000000",
	"001111121220356677766777767881123200110000000000",
	"001111121121249996666666996681132111100000000000",
	"001102111120855996999999999721232210100000000000",
	"011112111101299999999996667410321111100000000000",
	"001012111231184355576664355301211220100000000000",
	"001022121344444245555764555113112320100000000000",
	"001028222433543035555542353234213381000000000000",
	"001037221344552134555542243333122263010000000000",
	"001036121134541023455542044431122343100000000000",
	"001028210112331223495542223211122332000000000000",
	"000102111011112214555443211100122331000000000000",
	"000120111001111113445433111100121331100000000000",
	"000131111101134112445433110111111022100000000000",
	"000053111111034321345333011111110112100000000000",
	"000036111111001221244232110011110112100000000000",
	"000057111111000000133232100011100112100000000000",
	"000353110111000000022122000011101112100000000000",
	"001452110011000000023331000011101112200000000000",
	"003541110011000000023330000011011112320000000000",
	"014530110001000000023220000011011112230000000000",
	"004510111000000000120000000011111111122000000000",
	"003300111000000000122100000011111111011000000000",
	"003200011000000000112321100001111110011000000000",
	"001000001100000000220233322110111100011000000000",
	"001100001122233333332233333222110000110000000000",
	"332111100111222222222222222211100001123200000000",
	"332100001112222222222222222222110001233333100000",
	"222211111222222222222222222222211111222233331000",
	"222222222222222222222222222222222222222222233210",
	"111112222222222222322222222222222211112222222221"
}

-- 绘制像素画角色
local function draw_pixel_character(x, y, scale, alpha)
	scale = scale or 3
	alpha = alpha or 0.8

	for row_idx, row in ipairs(PIXEL_ART) do
		for col_idx = 1, #row do
			local char = row:sub(col_idx, col_idx)
			local pixel = tonumber(char)
			local color = PIXEL_PALETTE[pixel]
			if color then
				G.setColor(color[1], color[2], color[3], alpha)
				G.rectangle("fill", x + (col_idx - 1) * scale, y + (row_idx - 1) * scale, scale, scale)
			end
		end
	end
end

-- 计算平均下载速度
local function get_average_speed()
	if #ui_state.speed_samples == 0 then
		return 0
	end
	local sum = 0
	for _, s in ipairs(ui_state.speed_samples) do
		sum = sum + s
	end
	return sum / #ui_state.speed_samples
end

-- 计算剩余时间
local function get_eta()
	local speed = get_average_speed()
	if speed <= 0 or ui_state.bytes_total <= 0 then
		return nil
	end
	local remaining = ui_state.bytes_total - ui_state.bytes_downloaded
	return remaining / speed
end

-- 主绘制函数
function M:draw()
	local w, h = G.getDimensions()
	local dt = love.timer.getDelta()

	-- 更新动画
	ui_state.pulse_time = ui_state.pulse_time + dt
	ui_state.fade_alpha = math.min(ui_state.fade_alpha + dt * 2, 1)

	-- 平滑进度动画
	local progress_diff = ui_state.progress_target - ui_state.progress_display
	ui_state.progress_display = ui_state.progress_display + progress_diff * math.min(dt * 8, 1)

	-- 背景渐变（深蓝色调）
	local bg_top = {0.08, 0.10, 0.15}
	local bg_bottom = {0.05, 0.07, 0.12}
	for i = 0, h do
		local t = i / h
		G.setColor(bg_top[1] + (bg_bottom[1] - bg_top[1]) * t, bg_top[2] + (bg_bottom[2] - bg_top[2]) * t, bg_top[3] + (bg_bottom[3] - bg_top[3]) * t, ui_state.fade_alpha)
		G.rectangle("fill", 0, i, w, 1)
	end

	-- 主卡片尺寸（尽量填满窗口，留 20px 边距）
	local card_x = 0.05 * w + 20
	local card_y = 0.05 * h + 20
	local card_w = w - 2 * card_x
	local card_h = h - 2 * card_y

	-- 卡片阴影
	G.setColor(0, 0, 0, 0.3 * ui_state.fade_alpha)
	draw_rounded_rect_fill(card_x + 4, card_y + 4, card_w, card_h, 16)

	-- 卡片背景
	G.setColor(0.12, 0.14, 0.18, 0.95 * ui_state.fade_alpha)
	draw_rounded_rect_fill(card_x, card_y, card_w, card_h, 16)

	-- 卡片边框（微光效果）
	local pulse = math.sin(ui_state.pulse_time * 2) * 0.1 + 0.2
	G.setColor(0.3, 0.5, 0.8, pulse * ui_state.fade_alpha)
	G.setLineWidth(2)
	draw_rounded_rect_line(card_x, card_y, card_w, card_h, 16)
	G.setLineWidth(1)

	-- 标题区域
	local title_y = card_y + 20
	G.setFont(font_title)
	local title_text = "正在更新游戏"
	local title_w = font_title:getWidth(title_text)
	G.setColor(1, 1, 1, ui_state.fade_alpha)
	G.print(title_text, card_x + (card_w - title_w) / 2, title_y)

	-- 状态文字
	local status_y = title_y + 40
	G.setFont(font_normal)
	local status_text = STATE_STRING_MAP[state] or "处理中……"
	local status_w = font_normal:getWidth(status_text)
	G.setColor(0.7, 0.8, 0.9, ui_state.fade_alpha)
	G.print(status_text, card_x + (card_w - status_w) / 2, status_y)

	-- 进度条区域
	local bar_y = status_y + 45
	local bar_x = card_x + 30
	local bar_w = card_w - 60
	local bar_h = 24

	if state == STATE_DOWNLOADING_ASSETS or state == STATE_DOWNLOADING_CODE then
		-- 进度条背景
		G.setColor(0.2, 0.22, 0.28, ui_state.fade_alpha)
		draw_rounded_rect_fill(bar_x, bar_y, bar_w, bar_h, bar_h / 2)

		-- 进度条填充（渐变色）
		local progress_w = bar_w * ui_state.progress_display / 100
		if progress_w > 0 then
			-- 渐变：蓝色到青色
			local gradient_start = {0.2, 0.6, 1.0}
			local gradient_end = {0.3, 0.9, 0.7}
			local t = ui_state.progress_display / 100
			G.setColor(gradient_start[1] + (gradient_end[1] - gradient_start[1]) * t, gradient_start[2] + (gradient_end[2] - gradient_start[2]) * t, gradient_start[3] + (gradient_end[3] - gradient_start[3]) * t, ui_state.fade_alpha)
			draw_rounded_rect_fill(bar_x, bar_y, math.max(progress_w, bar_h), bar_h, bar_h / 2)

			-- 发光效果
			G.setColor(1, 1, 1, 0.15 * ui_state.fade_alpha)
			draw_rounded_rect_fill(bar_x, bar_y, math.max(progress_w, bar_h), bar_h / 2, bar_h / 4)
		end

		-- 进度百分比（居中显示）
		local percent_text = string.format("%.1f%%", ui_state.progress_display)
		local percent_w = font_normal:getWidth(percent_text)
		G.setColor(1, 1, 1, ui_state.fade_alpha)
		G.print(percent_text, bar_x + (bar_w - percent_w) / 2, bar_y + 2)

		-- 详细信息区域
		local info_y = bar_y + bar_h + 15
		G.setFont(font_small)

		-- 当前文件
		if ui_state.current_file ~= "" then
			local filename = ui_state.current_file:match("[^/]+$") or ui_state.current_file
			if #filename > 50 then
				filename = "..." .. filename:sub(-47)
			end
			G.setColor(0.6, 0.7, 0.8, ui_state.fade_alpha)
			G.print("当前文件: " .. filename, bar_x, info_y)
		end

		-- 文件进度
		if ui_state.files_total > 0 then
			local files_text = string.format("文件进度: %d / %d", ui_state.files_done, ui_state.files_total)
			G.setColor(0.6, 0.7, 0.8, ui_state.fade_alpha)
			G.print(files_text, bar_x + bar_w - font_small:getWidth(files_text), info_y)
		end

		-- 下载速度和剩余时间
		local speed_y = info_y + 20
		local speed = get_average_speed()
		if speed > 0 then
			local speed_text = format_bytes(speed) .. "/s"
			G.setColor(0.5, 0.8, 0.5, ui_state.fade_alpha)
			G.print("速度: " .. speed_text, bar_x, speed_y)
		end

		-- 已下载/总大小
		if ui_state.bytes_total > 0 then
			local size_text = string.format("%s / %s", format_bytes(ui_state.bytes_downloaded), format_bytes(ui_state.bytes_total))
			G.setColor(0.6, 0.7, 0.8, ui_state.fade_alpha)
			local size_w = font_small:getWidth(size_text)
			G.print(size_text, bar_x + (bar_w - size_w) / 2, speed_y)
		end

		-- 剩余时间
		local eta = get_eta()
		if eta and eta > 0 and eta < 86400 then
			local eta_text = "剩余: " .. format_time(eta)
			G.setColor(0.6, 0.7, 0.8, ui_state.fade_alpha)
			G.print(eta_text, bar_x + bar_w - font_small:getWidth(eta_text), speed_y)
		end
	else
		-- 非下载状态：显示加载动画
		local spinner_x = card_x + card_w / 2
		local spinner_y = bar_y + 20
		local spinner_r = 20
		G.setLineWidth(3)
		for i = 0, 7 do
			local angle = (i / 8) * math.pi * 2 + ui_state.pulse_time * 4
			local alpha = ((i + 1) / 8) * ui_state.fade_alpha
			G.setColor(0.3, 0.6, 1.0, alpha)
			local x1 = spinner_x + math.cos(angle) * (spinner_r - 8)
			local y1 = spinner_y + math.sin(angle) * (spinner_r - 8)
			local x2 = spinner_x + math.cos(angle) * spinner_r
			local y2 = spinner_y + math.sin(angle) * spinner_r
			G.line(x1, y1, x2, y2)
		end
		G.setLineWidth(1)
	end

	-- 日志区域（卡片底部，动态计算高度）
	-- bar_y 是相对屏幕的绝对坐标，所以 log_y 也是
	local log_y = bar_y + bar_h + 60 -- 进度条下方留出信息区域空间
	local log_bottom_margin = 15
	local log_x = card_x + 20
	local log_w = card_w - 40
	local log_h = (card_y + card_h - log_bottom_margin) - log_y

	-- 日志背景
	G.setColor(0.08, 0.09, 0.12, 0.8 * ui_state.fade_alpha)
	draw_rounded_rect_fill(log_x, log_y, log_w, log_h, 8)

	-- 计算可显示的日志行数（填满整个日志区域）
	local line_height = 18
	local log_padding = 8
	local max_visible_logs = math.floor((log_h - log_padding * 2) / line_height)

	-- 增加日志保留数量以填满区域
	if max_visible_logs > update_log_line_max_count then
		update_log_line_max_count = max_visible_logs
	end

	local visible_logs = math.min(max_visible_logs, #update_log_lines)
	local start_idx = math.max(1, #update_log_lines - visible_logs + 1)

	-- 计算最大字符数（根据日志区域宽度）
	local max_chars = math.floor((log_w - 20) / font_small:getWidth("M"))

	G.setFont(font_small)
	for i = start_idx, #update_log_lines do
		local line = update_log_lines[i]
		-- 使用 UTF-8 安全的截断函数，按字符数而不是字节数截断
		if #line > max_chars then
			line = utf8_sub(line, max_chars - 3) .. "..."
		end
		local line_y = log_y + log_padding + (i - start_idx) * line_height
		-- 错误日志用红色
		if line:find("错误") then
			G.setColor(1, 0.4, 0.4, ui_state.fade_alpha)
		else
			G.setColor(0.5, 0.6, 0.7, ui_state.fade_alpha)
		end
		G.print(line, log_x + 10, line_y)
	end

	-- 绘制像素斑鸠（卡片右下角，带轻微浮动动画）
	local char_scale = math.max(3, math.floor(math.min(w, h) / 150))
	local char_w = 48 * char_scale
	local char_h = 64 * char_scale
	local float_offset = math.sin(ui_state.pulse_time * 1.5) * 4
	local char_x = card_x + card_w - char_w - 20
	local char_y = card_y + card_h - char_h - 15 + float_offset
	draw_pixel_character(char_x, char_y, char_scale, 0.9 * ui_state.fade_alpha)

	if self._dialog then
		local layout = self:_get_dialog_layout()
		local metrics = self:_get_dialog_text_metrics(layout)
		local mx, my = love.mouse.getPosition()
		self._dialog_hover_button_index = nil
		for i, btn_rect in ipairs(layout.buttons) do
			if point_in_rect(mx, my, btn_rect) then
				self._dialog_hover_button_index = i
				break
			end
		end
		-- 遮罩层
		G.setColor(0, 0, 0, 0.58)
		G.rectangle("fill", 0, 0, w, h)

		-- 对话框主体
		G.setColor(0.14, 0.16, 0.22, 0.98)
		draw_rounded_rect_fill(layout.x, layout.y, layout.w, layout.h, 12)
		G.setColor(0.35, 0.55, 0.9, 0.9)
		G.setLineWidth(2)
		draw_rounded_rect_line(layout.x, layout.y, layout.w, layout.h, 12)
		G.setLineWidth(1)

		G.setFont(font_title)
		G.setColor(1, 1, 1, 1)
		G.printf(self._dialog.title or "", layout.title_x, layout.title_y, layout.w - 48, "left")

		-- 文本区域（支持滚轮/拖动）
		G.setColor(0.09, 0.11, 0.16, 0.95)
		draw_rounded_rect_fill(layout.text_x, layout.text_y, layout.text_w, layout.text_h, 8)
		G.setColor(0.28, 0.40, 0.58, 0.95)
		draw_rounded_rect_line(layout.text_x, layout.text_y, layout.text_w, layout.text_h, 8)

		local text_draw_x = layout.text_x + layout.text_padding
		local text_draw_y = layout.text_y + layout.text_padding
		G.setScissor(text_draw_x, text_draw_y, metrics.text_w, metrics.text_h)
		G.setFont(font_normal)
		G.setColor(0.85, 0.90, 0.98, 1)
		local start_line = math.max(1, math.floor((self._dialog_scroll_y or 0) / metrics.line_h) + 1)
		local y_offset = ((self._dialog_scroll_y or 0) % metrics.line_h)
		local y = text_draw_y - y_offset
		for i = start_line, #metrics.lines do
			if y > text_draw_y + metrics.text_h then
				break
			end
			G.print(metrics.lines[i], text_draw_x, y)
			y = y + metrics.line_h
		end
		G.setScissor()

		if metrics.max_scroll > 0 then
			local track_w = 6
			local track_x = layout.text_x + layout.text_w - track_w - 6
			local track_y = layout.text_y + 6
			local track_h = layout.text_h - 12
			G.setColor(0.18, 0.22, 0.30, 0.9)
			draw_rounded_rect_fill(track_x, track_y, track_w, track_h, 3)
			local thumb_h = math.max(28, track_h * metrics.text_h / metrics.content_h)
			local thumb_y = track_y + (track_h - thumb_h) * ((self._dialog_scroll_y or 0) / metrics.max_scroll)
			G.setColor(0.46, 0.66, 0.98, 0.95)
			draw_rounded_rect_fill(track_x, thumb_y, track_w, thumb_h, 3)
		end

		for i, btn_rect in ipairs(layout.buttons) do
			local focused = i == self._dialog_focus_index
			local hovered = i == self._dialog_hover_button_index
			if focused and hovered then
				G.setColor(0.21, 0.62, 0.88, 1)
			elseif hovered then
				G.setColor(0.24, 0.40, 0.55, 1)
			elseif focused then
				G.setColor(0.23, 0.53, 0.93, 1)
			else
				G.setColor(0.22, 0.25, 0.33, 1)
			end
			draw_rounded_rect_fill(btn_rect.x, btn_rect.y, btn_rect.w, btn_rect.h, 8)
			if focused and hovered then
				G.setColor(0.70, 0.94, 0.98, 1)
			elseif hovered then
				G.setColor(0.58, 0.78, 0.90, 1)
			elseif focused then
				G.setColor(0.60, 0.85, 1.00, 1)
			else
				G.setColor(0.42, 0.52, 0.68, 1)
			end
			draw_rounded_rect_line(btn_rect.x, btn_rect.y, btn_rect.w, btn_rect.h, 8)

			G.setFont(font_normal)
			G.setColor(1, 1, 1, 1)
			local btn_text = (self._dialog.buttons[i] and self._dialog.buttons[i].text) or "确定"
			G.printf(btn_text, btn_rect.x, btn_rect.y + 8, btn_rect.w, "center")
		end
	end
end

function M:keyreleased(key, scancode)
end
function M:keypressed(key, isrepeat)
	if not self._dialog then
		return
	end
	local buttons = self._dialog.buttons or {}
	local count = #buttons
	if count == 0 then
		return
	end
	if key == "left" or key == "a" then
		self._dialog_focus_index = self._dialog_focus_index - 1
		if self._dialog_focus_index < 1 then
			self._dialog_focus_index = count
		end
	elseif key == "right" or key == "d" then
		self._dialog_focus_index = self._dialog_focus_index + 1
		if self._dialog_focus_index > count then
			self._dialog_focus_index = 1
		end
	elseif key == "return" or key == "kpenter" or key == "space" then
		self:_activate_dialog_button(self._dialog_focus_index)
	elseif key == "up" then
		self:_scroll_dialog_by(-36)
	elseif key == "down" then
		self:_scroll_dialog_by(36)
	elseif key == "pageup" then
		local layout = self:_get_dialog_layout()
		local metrics = self:_get_dialog_text_metrics(layout)
		self:_scroll_dialog_by(-(metrics and metrics.text_h or 180) * 0.85)
	elseif key == "pagedown" then
		local layout = self:_get_dialog_layout()
		local metrics = self:_get_dialog_text_metrics(layout)
		self:_scroll_dialog_by((metrics and metrics.text_h or 180) * 0.85)
	elseif key == "escape" then
		local cancel_index = count
		for i, btn in ipairs(buttons) do
			if btn.is_cancel then
				cancel_index = i
				break
			end
		end
		self:_activate_dialog_button(cancel_index)
	end
end
function M:textinput(t)
end
function M:mousepressed(x, y, button, istouch)
	if not self._dialog then
		return
	end
	local layout = self:_get_dialog_layout()
	if (button == 1 or button == 3) and point_in_rect(x, y, {
		x = layout.text_x,
		y = layout.text_y,
		w = layout.text_w,
		h = layout.text_h
	}) then
		self._dialog_dragging = true
		self._dialog_drag_button = button
		self._dialog_drag_start_y = y
		self._dialog_scroll_start = self._dialog_scroll_y or 0
		return
	end
	if button ~= 1 then
		return
	end
	for i, rect in ipairs(layout.buttons or {}) do
		if point_in_rect(x, y, rect) then
			self._dialog_focus_index = i
			self:_activate_dialog_button(i)
			return
		end
	end
end
function M:mousereleased(x, y, button, istouch)
	if not self._dialog then
		return
	end
	if self._dialog_dragging and button == self._dialog_drag_button then
		self._dialog_dragging = false
		self._dialog_drag_button = nil
	end
end
function M:wheelmoved(dx, dy)
	if not self._dialog then
		return
	end
	local mx, my = love.mouse.getPosition()
	local layout = self:_get_dialog_layout()
	if point_in_rect(mx, my, {
		x = layout.text_x,
		y = layout.text_y,
		w = layout.text_w,
		h = layout.text_h
	}) then
		self:_scroll_dialog_by(-dy * 42)
	end
end

return M
