local M = {}
-- 本模块只在非安卓平台启用
local apply_upgrade = love.system.getOS() ~= "Android"
local ok, update_cfg = pcall(dofile, "update.lua")

if ok and type(update_cfg) == "table" and update_cfg.auto_upgrade == false then
	apply_upgrade = false
end

local binary_path = "./client"

if package.config:sub(1, 1) == "\\" then -- Windows
	binary_path = "client.exe"
end

function M.update_client()
	if apply_upgrade then
		-- 如果主目录有 $binary_path.new，就用这个文件替换掉 $binary_path
		local client_updated = false
		local new_path = binary_path .. ".new"
		local f = io.open(new_path, "r")

		if f then
			f:close()
			-- 存在 .new 文件，进行替换
			os.remove(binary_path)
			os.rename(new_path, binary_path)
			client_updated = true
		end

		-- 运行 $binary_path --quiz，强等待。
		local cmd = client_updated and string.format('"%s" --quiz-force', binary_path) or string.format('"%s" --quiz', binary_path)
		local ret = os.execute(cmd)

		if ret ~= 0 then
			love.window.showMessageBox("错误", "答题错误，不允许游玩，确定以退出。", {"确定"})
            love.event.quit()
		end
	end
end

-- 检查更新的线程代码，通过 channel "update_result" 和主线程通信
local check_update_thread_code = [[
    local cmd, commit_hash = ...
    -- 写入临时文件
    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    if f then f:write(commit_hash) f:close() end
    -- 设置环境变量或切换目录（如有需要）
    -- 调用外部程序
    local full_cmd = cmd
    -- Windows下防止弹黑框
    if package.config:sub(1,1) == "\\" then
        full_cmd = 'cmd /C ' .. full_cmd
    end
    local pipe = io.popen(full_cmd, "r")
    local resp = pipe and pipe:read("*a") or nil
    if pipe then pipe:close() end
    os.remove(tmpfile)
    love.thread.getChannel("check_update_result"):push(resp or false)
]]
local update_thread_code = [[
    local cmd, update_result_json = ...
    local pipe = io.popen(cmd, "w")
    if pipe then
        pipe:write(update_result_json)
        pipe:flush()
        -- 读取输出并实时推送
        while true do
            local line = pipe:read("*l")
            if not line then break end
            love.thread.getChannel("update_std_out"):push(line)
        end
        pipe:close()
    end
    love.thread.getChannel("update_result"):push("done")
]]

function M.check_update()
	local hash_file = io.open("current_version_commit_hash.txt", "r")

	if not hash_file then
		return
	end

	local commit_hash = hash_file:read("*l")
	hash_file:close()

	if not commit_hash then
		return
	end

	local cmd = string.format('"%s" --check-new-version', binary_path)
	print("cmd:", cmd)
	-- 4. 启动线程调用
	local thread = love.thread.newThread(check_update_thread_code)
	thread:start(cmd, commit_hash)
end

local update_result_json = nil
local update_std_out = {}

--- 在 love 的更新函数中做更新覆盖。
---@param original_love_update_function function(dt: number)
---@param original_love_draw_function function()
function M.hack_love_update(original_love_update_function, original_love_draw_function)
    love.draw = original_love_draw_function
	love.update = function(dt)
		original_love_update_function(dt)

		-- 不需要更新，离线工作。
		if not apply_upgrade then
			love.update = original_love_update_function
			return
		end

		-- 查询 check_update 线程结果
		local ch = love.thread.getChannel("check_update_result")
		-- 尝试获取结果
		local result = ch:pop()

		-- 如果 check_update 线程还没结果，直接返回
		if result == nil then
			return
		end

		-- 如果 check_update 线程返回 false，表示检查不了更新，直接离线游玩。
		if result == false then
			print("Cannot check for updates.")
			love.update = original_love_update_function -- 恢复原 love.update
		end

		-- 轮询到了结果，此时触发下一步逻辑
		local ok, resp = pcall(require("json").decode, result)

		-- 需要更新
		if ok and type(resp) == "table" and resp.has_update then
			update_result_json = result
			-- 收集所有 commit message
			local messages = {}
			local max_messages_to_show = 20

			if resp.commits then
				for i, commit in ipairs(resp.commits) do
					if i > max_messages_to_show then
						table.insert(messages, string.format("...以及另外 %d 条更新内容。", #resp.commits - max_messages_to_show))
						break
					end

					table.insert(messages, commit.message)
				end
			end

			local msg_text = table.concat(messages, "\n\n")
			msg_text = msg_text .. "\n\n请耐心等待升级完成..."
			local cmd = string.format('"%s" --upgrade-new-version', binary_path)
			-- 弹窗有“升级”按钮
			local pressed = love.window.showMessageBox("发现新版本", "检测到有新内容可更新，是否立即更新？", {"更新", "取消"})

			if pressed == 1 then
				-- 新建升级线程，实时读取输出
				local update_thread = love.thread.newThread(update_thread_code)
				update_thread:start(cmd, update_result_json)
				love.window.showMessageBox("更新内容", msg_text, {"确定以继续"})
				-- 用于显示升级日志
				love.update = function(dt)
					local ch = love.thread.getChannel("update_result")
					local result = ch:pop()
					-- 轮询日志
					local log_ch = love.thread.getChannel("update_std_out")
					local line = log_ch:pop()

					if line then
						table.insert(update_std_out, line)

						-- 限制最大行数
						if #update_std_out > 30 then
							table.remove(update_std_out, 1)
						end
					end

					if result == "done" then
						love.window.showMessageBox("升级完成", "资源已更新。", {"点击以退出"})
						love.event.quit()
					elseif result == "error" then
						love.window.showMessageBox("升级失败，可检查 client.log 并报告。", "确定")
						love.update = original_love_update_function
						love.draw = original_love_draw_function
					end
				end

				love.draw = function()
					G.clear(0, 0, 0)
					G.origin()
					local font = F:f("JIMOJW", 20)
					G.setFont(font)
					G.setColor(1, 1, 1, 1)
					local w, h = G.getDimensions()
					local text = "正在升级资源，请勿关闭游戏..."
					local tw = font:getWidth(text)
					local th = font:getHeight()
					G.print(text, (w - tw) / 2, (h - th) / 2)
					-- 动画
					G.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 5))
					G.circle("fill", w / 2, (h + th) / 2 + 30, 10 + 5 * math.sin(love.timer.getTime() * 10))
					-- 显示升级日志
					G.setColor(1, 1, 1, 1)
					local log_y = (h - th) / 2 + 60

					for i, line in ipairs(update_std_out) do
						G.print(line, 40, log_y + (i - 1) * 22)
					end
				end
			end
		else
			-- 不需要更新，那么恢复原 update
			love.update = original_love_update_function
		end
	end
end

return M