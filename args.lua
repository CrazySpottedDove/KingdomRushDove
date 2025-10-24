-- 启动参数
local r = {
    log_level = 5,  -- 日志等级 5：调试控制台显示完整信息
    -- screen = "slots",   -- 跳过开屏 logo，与开局设置

    -- screen = "game_editor", -- 进入关卡编辑器
    -- custom = 91,  -- 要编辑的关卡
}

local result = {}
for key, value in pairs(r) do
    table.insert(result, "-" .. key)
    if value then
        table.insert(result, value)
    end
end

return result

