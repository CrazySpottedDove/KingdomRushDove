local storage = require("all.storage")

-- 提供一个强制阅读作者的话的界面。使用方法：在main.lua的load.run()的主循环前调用 MUST_READ.run() 即可。
local MUST_READ = {
	touch_scrolling = false,
	touch_start_y = 0,
	scroll_start = 0,
	scroll = 0,
	margin = 40,
	text = require("dove_modules.notice.author_words"),
	enabled = true,
	params = nil,
	has_read = storage:load_lua("must_read.lua", true) ~= nil,
	-- 答题模式相关
	mode = "reading", -- "reading" 或 "quiz"
	current_question = 1,
	last_submit_time = -10, -- 初始化为较早时间，避免第一次点击受冷却限制
	quiz_completed = false,
	shuffled_questions = {},
	shuffled_options = {},
	-- 鼠标位置（用于悬停特效）
	mouse_x = 0,
	mouse_y = 0,
	-- 按钮按下状态
	mouse_pressed = false,
	max_questions = 30, -- 最大题目数量，超过这个数量会随机抽取题目
	-- UI常量配置
	ui = {
		-- 主按钮（继续游戏/去答题）
		btn_w = 200,
		btn_h = 44,
		btn_y_offset = 100, -- 距离底部的距离
		-- 返回按钮
		back_btn_w = 120,
		back_btn_h = 36,
		back_btn_x = 20,
		back_btn_y = 20,
		-- 题目卡片边距
		card_margin_top = 80,
		card_margin_bottom = 80,
		card_margin_left = 40,
		card_margin_right = 40,
		card_max_w = 800, -- 卡片最大宽度
		card_max_h = 600, -- 卡片最大高度
		-- 布局模式切换阈值
		aspect_ratio_threshold = 0.8, -- 宽高比>0.8时使用左右布局，≤0.8时垂直布局（只有非常窄的竖屏才用垂直）
		-- 水平布局参数（横屏：手机横置、电脑等）
		horizontal = {
			left_ratio = 0.25, -- 左侧题目区域占55%（给题目更多空间）
			divider_margin = 25, -- 分割线区域宽度
			header_h = 45, -- 顶部进度区域高度
			footer_h = 45, -- 底部提示区域高度
			content_padding = 15 -- 内容区域内边距
		},
		-- 垂直布局参数（极窄竖屏）
		vertical = {
			header_ratio = 0.35, -- 头部占总高度35%
			min_header_h = 90, -- 最小头部高度
			footer_h = 50, -- 底部固定高度
			content_padding = 15 -- 内容区域内边距
		},
		-- 选项参数
		opt_max_h = 80, -- 选项最大高度
		opt_spacing_ratio = 0.2, -- 间距占选项区域高度比例
		opt_padding = 15, -- 选项左右内边距
		-- 文本参数
		question_padding = 20, -- 题目文本边距
		progress_margin = 10 -- 进度文本上下边距
	}
}
local utf8 = require("utf8")

-- 题库：根据作者的话生成的题目
-- 通用题库（所有平台）
local common_quiz = {
	{
		q = _("MUST_READ_QUIZ_Q1"),
		opts = {_("MUST_READ_QUIZ_Q1_A"), _("MUST_READ_QUIZ_Q1_B"), _("MUST_READ_QUIZ_Q1_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q2"),
		opts = {_("MUST_READ_QUIZ_Q2_A"), _("MUST_READ_QUIZ_Q2_B"), _("MUST_READ_QUIZ_Q2_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q3"),
		opts = {_("MUST_READ_QUIZ_Q3_A"), _("MUST_READ_QUIZ_Q3_B"), _("MUST_READ_QUIZ_Q3_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q4"),
		opts = {_("MUST_READ_QUIZ_Q4_A"), _("MUST_READ_QUIZ_OPT_NO_EFFECT"), _("MUST_READ_QUIZ_Q4_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q5"),
		opts = {_("MUST_READ_QUIZ_Q5_A"), _("MUST_READ_QUIZ_Q5_B"), _("MUST_READ_QUIZ_Q5_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q6"),
		opts = {_("MUST_READ_QUIZ_Q6_A"), _("MUST_READ_QUIZ_Q6_B"), _("MUST_READ_QUIZ_Q6_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q7"),
		opts = {_("MUST_READ_QUIZ_Q7_A"), _("MUST_READ_QUIZ_Q7_B"), _("MUST_READ_QUIZ_Q7_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q8"),
		opts = {_("MUST_READ_QUIZ_Q8_A"), _("MUST_READ_QUIZ_Q8_B"), _("MUST_READ_QUIZ_Q8_C")},
		ans = 1
	},
	-- {
	-- 	q = "如何开启无尽模式？",
	-- 	opts = {"在大地图按f1配置，打开无尽模式", "在局内按f2", "通关所有关卡后自动开启"},
	-- 	ans = 1
	-- },
	-- {
	-- 	q = "无尽模式中如何购买科技？",
	-- 	opts = {"按f2花费10000金币", "按f1花费5000金币", "自动获得"},
	-- 	ans = 1
	-- },
	{
		q = _("MUST_READ_QUIZ_Q9"),
		opts = {_("MUST_READ_QUIZ_Q9_A"), _("MUST_READ_QUIZ_Q9_B"), _("MUST_READ_QUIZ_Q9_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q10"),
		opts = {_("MUST_READ_QUIZ_Q10_A"), _("MUST_READ_QUIZ_OPT_SUMMON_HERO"), _("MUST_READ_QUIZ_OPT_NEXT_WAVE")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q11"),
		opts = {_("MUST_READ_QUIZ_OPT_SUMMON_HERO"), _("MUST_READ_QUIZ_Q11_B"), _("MUST_READ_QUIZ_OPT_NEXT_WAVE")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q12"),
		opts = {_("MUST_READ_QUIZ_OPT_NEXT_WAVE"), _("MUST_READ_QUIZ_OPT_SUMMON_HERO"), _("MUST_READ_QUIZ_Q12_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q13"),
		opts = {_("MUST_READ_QUIZ_Q13_A"), _("MUST_READ_QUIZ_Q13_B"), _("MUST_READ_QUIZ_OPT_RESTART_GAME")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q14"),
		opts = {_("MUST_READ_QUIZ_Q14_A"), _("MUST_READ_QUIZ_Q14_B"), _("MUST_READ_QUIZ_Q14_C")},
		ans = 3
	},
	{
		q = _("MUST_READ_QUIZ_Q15"),
		opts = {_("MUST_READ_QUIZ_OPT_SCOLDED_BLOCKED"), _("MUST_READ_QUIZ_OPT_NO_EFFECT"), _("MUST_READ_QUIZ_Q15_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q16"),
		opts = {_("MUST_READ_QUIZ_Q16_A"), _("MUST_READ_QUIZ_Q16_B"), _("MUST_READ_QUIZ_Q16_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q17"),
		opts = {_("MUST_READ_QUIZ_OPT_SCOLDED_BLOCKED"), _("MUST_READ_QUIZ_Q17_B"), _("MUST_READ_QUIZ_OPT_NO_EFFECT")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q18"),
		opts = {_("MUST_READ_QUIZ_Q18_A"), _("MUST_READ_QUIZ_Q18_B"), _("MUST_READ_QUIZ_Q18_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q19"),
		opts = {_("MUST_READ_QUIZ_Q19_A"), _("MUST_READ_QUIZ_Q19_B"), _("MUST_READ_QUIZ_Q19_C")},
		ans = 1
	},

	{
		q = _("MUST_READ_QUIZ_Q20"),
		opts = {_("MUST_READ_QUIZ_Q20_A"), _("MUST_READ_QUIZ_Q20_B"), _("MUST_READ_QUIZ_Q20_C")},
		ans = 1
	},

	{
		q = _("MUST_READ_QUIZ_Q21"),
		opts = {_("MUST_READ_QUIZ_OPT_CLAW"), _("MUST_READ_QUIZ_Q21_B"), _("MUST_READ_QUIZ_OPT_LIGHTNING")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q22"),
		opts = {_("MUST_READ_QUIZ_Q22_A"), _("MUST_READ_QUIZ_OPT_CLAW"), _("MUST_READ_QUIZ_Q22_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q23"),
		opts = {_("MUST_READ_QUIZ_Q23_A"), _("MUST_READ_QUIZ_Q23_B"), _("MUST_READ_QUIZ_OPT_CLAW")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q24"),
		opts = {_("MUST_READ_QUIZ_Q24_A"), _("MUST_READ_QUIZ_OPT_CLAW"), _("MUST_READ_QUIZ_OPT_LIGHTNING")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q25"),
		opts = {_("MUST_READ_QUIZ_Q25_A"), _("MUST_READ_QUIZ_Q25_B"), _("MUST_READ_QUIZ_Q25_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q26"),
		opts = {_("MUST_READ_QUIZ_Q26_A"), _("MUST_READ_QUIZ_Q26_B"), _("MUST_READ_QUIZ_Q26_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q27"),
		opts = {_("MUST_READ_QUIZ_Q27_A"), _("MUST_READ_QUIZ_Q27_B"), _("MUST_READ_QUIZ_Q27_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q28"),
		opts = {_("MUST_READ_QUIZ_Q28_A"), _("MUST_READ_QUIZ_Q28_B"), _("MUST_READ_QUIZ_Q28_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_Q29"),
		opts = {_("MUST_READ_QUIZ_Q29_A"), _("MUST_READ_QUIZ_Q29_B"), _("MUST_READ_QUIZ_Q29_C")},
		ans = 1
	}
}

-- 电脑端专用题目
local pc_only_quiz = {
	{
		q = _("MUST_READ_QUIZ_PC_Q30"),
		opts = {_("MUST_READ_QUIZ_PC_Q30_A"), _("MUST_READ_QUIZ_PC_Q30_B"), _("MUST_READ_QUIZ_PC_Q30_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q31"),
		opts = {_("MUST_READ_QUIZ_PC_Q31_A"), _("MUST_READ_QUIZ_PC_Q31_B"), _("MUST_READ_QUIZ_PC_Q31_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q32"),
		opts = {_("MUST_READ_QUIZ_PC_Q32_A"), _("MUST_READ_QUIZ_PC_Q32_B"), _("MUST_READ_QUIZ_PC_Q32_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q33"),
		opts = {_("MUST_READ_QUIZ_PC_Q33_A"), _("MUST_READ_QUIZ_PC_Q33_B"), _("MUST_READ_QUIZ_PC_Q33_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q34"),
		opts = {_("MUST_READ_QUIZ_PC_Q34_A"), _("MUST_READ_QUIZ_PC_Q34_B"), _("MUST_READ_QUIZ_PC_Q34_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q35"),
		opts = {_("MUST_READ_QUIZ_PC_Q35_A"), _("MUST_READ_QUIZ_PC_Q35_B"), _("MUST_READ_QUIZ_PC_Q35_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q36"),
		opts = {_("MUST_READ_QUIZ_PC_Q36_A"), _("MUST_READ_QUIZ_PC_Q36_B"), _("MUST_READ_QUIZ_OPT_RESTART_GAME")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q37"),
		opts = {_("MUST_READ_QUIZ_PC_Q37_A"), _("MUST_READ_QUIZ_PC_Q37_B"), _("MUST_READ_QUIZ_PC_Q37_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q38"),
		opts = {_("MUST_READ_QUIZ_PC_Q38_A"), _("MUST_READ_QUIZ_PC_Q38_B"), _("MUST_READ_QUIZ_PC_Q38_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q39"),
		opts = {_("MUST_READ_QUIZ_PC_Q39_A"), _("MUST_READ_QUIZ_PC_Q39_B"), _("MUST_READ_QUIZ_PC_Q39_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q40"),
		opts = {_("MUST_READ_QUIZ_PC_Q40_A"), _("MUST_READ_QUIZ_PC_Q40_B"), _("MUST_READ_QUIZ_PC_Q40_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q41"),
		opts = {_("MUST_READ_QUIZ_PC_Q41_A"), _("MUST_READ_QUIZ_PC_Q41_B"), _("MUST_READ_QUIZ_PC_Q41_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q42"),
		opts = {_("MUST_READ_QUIZ_PC_Q42_A"), _("MUST_READ_QUIZ_PC_Q42_B"), _("MUST_READ_QUIZ_PC_Q42_C")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q43"),
		opts = {_("MUST_READ_QUIZ_PC_Q43_A"), _("MUST_READ_QUIZ_OPT_OPEN_CONFIG"), _("MUST_READ_QUIZ_OPT_SWITCH_MAP")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q44"),
		opts = {_("MUST_READ_QUIZ_PC_Q44_A"), _("MUST_READ_QUIZ_OPT_OPEN_CONFIG"), _("MUST_READ_QUIZ_OPT_SWITCH_MAP")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q45"),
		opts = {_("MUST_READ_QUIZ_PC_Q45_A"), _("MUST_READ_QUIZ_OPT_OPEN_CONFIG"), _("MUST_READ_QUIZ_OPT_SWITCH_MAP")},
		ans = 1
	},
	{
		q = _("MUST_READ_QUIZ_PC_Q46"),
		opts = {_("MUST_READ_QUIZ_PC_Q46_A"), _("MUST_READ_QUIZ_OPT_SWITCH_MAP"), _("MUST_READ_QUIZ_OPT_OPEN_CONFIG")},
		ans = 1
	}
}

-- 安卓端专用题目
local android_only_quiz = {{
	q = _("MUST_READ_QUIZ_ANDROID_Q47"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q47_A"), _("MUST_READ_QUIZ_ANDROID_Q47_B"), _("MUST_READ_QUIZ_ANDROID_Q47_C")},
	ans = 3
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q48"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q48_A"), _("MUST_READ_QUIZ_ANDROID_Q48_B"), _("MUST_READ_QUIZ_ANDROID_Q48_C")},
	ans = 1
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q49"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q49_A"), _("MUST_READ_QUIZ_ANDROID_Q49_B"), _("MUST_READ_QUIZ_ANDROID_Q49_C")},
	ans = 1
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q50"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q50_A"), _("MUST_READ_QUIZ_ANDROID_Q50_B"), _("MUST_READ_QUIZ_ANDROID_Q50_C")},
	ans = 1
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q51"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q51_A"), _("MUST_READ_QUIZ_ANDROID_Q51_B"), _("MUST_READ_QUIZ_ANDROID_Q51_C")},
	ans = 1
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q52"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q52_A"), _("MUST_READ_QUIZ_ANDROID_Q52_B"), _("MUST_READ_QUIZ_ANDROID_Q52_C")},
	ans = 1
}, {
	q = _("MUST_READ_QUIZ_ANDROID_Q53"),
	opts = {_("MUST_READ_QUIZ_ANDROID_Q53_A"), _("MUST_READ_QUIZ_ANDROID_Q53_B"), _("MUST_READ_QUIZ_ANDROID_Q53_C")},
	ans = 1
}}

-- 根据平台组合题库
local function get_quiz_bank()
	local quiz = {}

	-- 添加通用题目
	for i = 1, #common_quiz do
		table.insert(quiz, common_quiz[i])
	end

	-- 添加平台专用题目
	if IS_ANDROID then
		for i = 1, #android_only_quiz do
			table.insert(quiz, android_only_quiz[i])
		end
	else
		for i = 1, #pc_only_quiz do
			table.insert(quiz, pc_only_quiz[i])
		end
	end

	-- 如果题库超过最大题目数量，随机抽取
	if #quiz > MUST_READ.max_questions then
		local delete_count = #quiz - MUST_READ.max_questions
		for i = 1, delete_count do
			local idx = math.random(1, #quiz)
			table.remove(quiz, idx)
		end
	end

	return quiz
end

local quiz_bank = get_quiz_bank()

local font = require("lib.klove.font_db"):f("msyh", 20)
local small_font = require("lib.klove.font_db"):f("msyh", 16)
require("lib.klove.font_db"):f("msyh", 24)

local line_h = font:getHeight() + 6
local lines = {}

-- 随机打乱题目顺序
local function shuffle_questions()
	local shuffled = {}
	for i = 1, #quiz_bank do
		shuffled[i] = i
	end
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

-- 随机打乱选项顺序，返回新顺序和正确答案的新位置
local function shuffle_options(question)
	local indices = {1, 2, 3}
	for i = 3, 2, -1 do
		local j = math.random(i)
		indices[i], indices[j] = indices[j], indices[i]
	end
	local new_ans = 1
	for i = 1, 3 do
		if indices[i] == question.ans then
			new_ans = i
			break
		end
	end
	return indices, new_ans
end

local function wrap_text(text, font, maxw)
	local lines = {}
	local current_line = {}
	local buffer = ""
	local width = 0
	local i = 1

	-- 移除RED标签
	text = text:gsub("RED", ""):gsub("/RED", "")

	local function flush_buffer()
		if buffer ~= "" then
			table.insert(current_line, {
				text = buffer,
				color = {1, 1, 1}
			})
			buffer = ""
		end
	end

	local function flush_line()
		flush_buffer()
		table.insert(lines, current_line)
		current_line = {}
		width = 0
	end

	local text_len = #text
	while i <= text_len do
		local c_start = i
		local c_end = utf8.offset(text, 2, i) and utf8.offset(text, 2, i) - 1 or text_len
		local ch = text:sub(c_start, c_end)
		i = c_end + 1

		if ch == "\n" then
			flush_line()
		else
			local w = font:getWidth(ch)
			if width + w > maxw then
				flush_buffer()
				flush_line()
				buffer = ch
				width = font:getWidth(ch)
			else
				buffer = buffer .. ch
				width = width + w
			end
		end
	end
	flush_buffer()
	if #current_line > 0 then
		table.insert(lines, current_line)
	end
	return lines
end

-- 返回 true 表示已滚到底
local function is_scrolled_to_bottom(scroll, total_lines, visible_lines)
	return scroll >= math.max(0, total_lines - visible_lines)
end

-- window 由外部设置，内部不对其进行调整
function MUST_READ:init(params, done_callback)
	self.done_callback = done_callback
	self.params = params

	-- 初始化答题系统
	if not self.has_read then
		self.shuffled_questions = shuffle_questions()
		self.current_question = 1
		self.shuffled_options = {}
		-- 为每道题预生成随机选项顺序
		for i = 1, #quiz_bank do
			local question = quiz_bank[i]
			local opt_order, new_ans = shuffle_options(question)
			self.shuffled_options[i] = {
				order = opt_order,
				ans = new_ans
			}
		end
	end

	self:layout()
end

function MUST_READ:wheelmoved(x, y)
	if y ~= 0 then
		self.scroll = math.max(0, self.scroll - math.floor(y * 3))
	end
end

function MUST_READ:touchpressed(id, x, y, dx, dy, pressure)
	self.touch_scrolling = true
	self.touch_start_y = y
	self.scroll_start = self.scroll
end

function MUST_READ:touchmoved(id, x, y, dx, dy, pressure)
	if self.touch_scrolling then
		local _, h = love.graphics.getDimensions()
		local visible_lines = math.floor((h - 180) / line_h)
		local total_lines = #lines
		local max_scroll = math.max(0, total_lines - visible_lines)
		local delta = math.ceil((self.touch_start_y - y) / 30)
		self.scroll = math.max(0, math.min(max_scroll, self.scroll_start + delta))
	end
end

function MUST_READ:layout()
	local w = love.graphics.getDimensions()
	local maxw = math.max(200, w - self.margin * 2)
	lines = wrap_text(self.text, font, maxw)
end

function MUST_READ:touchreleased(id, x, y, dx, dy, pressure)
	self.touch_scrolling = false
end

function MUST_READ:mousepressed(x, y, button)
	local w, h = love.graphics.getDimensions()

	if button ~= 1 then
		return
	end
	self.mouse_pressed = true

	-- 如果已经答题成功过，只显示阅读模式
	if self.has_read then
		if self.mode == "reading" then
			local visible_lines = math.floor((h - 180) / line_h)
			local total_lines = #lines
			local can_continue = is_scrolled_to_bottom(self.scroll, total_lines, visible_lines)

			local btn_w, btn_h = self.ui.btn_w, self.ui.btn_h
			local bx = (w - btn_w) / 2
			local by = h - self.ui.btn_y_offset

			if x >= bx and x <= bx + btn_w and y >= by and y <= by + btn_h and can_continue then
				self.done_callback()
			end
		end
		return
	end

	-- 未答题成功，显示切换按钮和答题界面
	if self.mode == "reading" then
		-- 阅读模式：检查"去答题"按钮
		local btn_w, btn_h = self.ui.btn_w, self.ui.btn_h
		local bx = (w - btn_w) / 2
		local by = h - self.ui.btn_y_offset

		if x >= bx and x <= bx + btn_w and y >= by and y <= by + btn_h then
			self.mode = "quiz"
			return
		end
	elseif self.mode == "quiz" then
		-- 答题模式
		local current_time = love.timer.getTime()
		local cooldown = 5 - (current_time - self.last_submit_time)

		-- 检查"返回阅读"按钮
		local back_btn_w, back_btn_h = self.ui.back_btn_w, self.ui.back_btn_h
		local back_x = self.ui.back_btn_x
		local back_y = self.ui.back_btn_y
		if x >= back_x and x <= back_x + back_btn_w and y >= back_y and y <= back_y + back_btn_h then
			self.mode = "reading"
			return
		end

		-- 如果在冷却中，不处理选项点击
		if cooldown > 0 then
			return
		end

		-- 检查选项点击
		-- 1. 计算卡片基本尺寸（与draw函数保持一致）
		local available_w = w - self.ui.card_margin_left - self.ui.card_margin_right
		local available_h = h - self.ui.card_margin_top - self.ui.card_margin_bottom
		local card_w = math.min(self.ui.card_max_w, available_w)
		local card_h = math.min(self.ui.card_max_h, available_h)
		local card_x = (w - card_w) / 2
		local card_y = (h - card_h) / 2

		-- 2. 判断使用水平还是垂直布局
		local aspect_ratio = card_w / card_h
		local use_horizontal = aspect_ratio > self.ui.aspect_ratio_threshold

		local opt_h, opt_spacing, opt_y, opt_x, opt_w

		if use_horizontal then
			-- 水平布局（电脑端）
			local hcfg = self.ui.horizontal
			local left_w = math.floor(card_w * hcfg.left_ratio)
			local right_w = card_w - left_w - hcfg.divider_margin
			local right_x = card_x + left_w + hcfg.divider_margin

			local content_h = card_h - hcfg.header_h - hcfg.footer_h
			local opt_area_h = content_h - hcfg.content_padding * 2

			-- 选项计算
			local total_spacing = opt_area_h * self.ui.opt_spacing_ratio
			opt_h = math.min(self.ui.opt_max_h, (opt_area_h - total_spacing) / 3)
			opt_spacing = total_spacing / 2
			opt_y = card_y + hcfg.header_h + hcfg.content_padding
			opt_x = right_x + self.ui.opt_padding
			opt_w = right_w - self.ui.opt_padding * 2
		else
			-- 垂直布局（手机端）
			local vcfg = self.ui.vertical
			local header_h = math.max(vcfg.min_header_h, card_h * vcfg.header_ratio)
			local content_h = card_h - header_h - vcfg.footer_h
			local opt_area_h = content_h - vcfg.content_padding * 2

			-- 选项计算
			local total_spacing = opt_area_h * self.ui.opt_spacing_ratio
			opt_h = math.min(self.ui.opt_max_h, (opt_area_h - total_spacing) / 3)
			opt_spacing = total_spacing / 2
			opt_y = card_y + header_h + vcfg.content_padding
			opt_x = card_x + self.ui.opt_padding
			opt_w = card_w - self.ui.opt_padding * 2
		end

		local q_idx = self.shuffled_questions[self.current_question]
		local shuffle_data = self.shuffled_options[q_idx]

		-- 选项位置
		local opt_start_y = opt_y

		for i = 1, 3 do
			local oy = opt_start_y + (i - 1) * (opt_h + opt_spacing)
			-- 使用统一的选项区域
			if x >= opt_x and x <= opt_x + opt_w and y >= oy and y <= oy + opt_h then
				-- 点击了选项
				if i == shuffle_data.ans then
					-- 答对了，不需要冷却，直接进入下一题
					if self.current_question >= #quiz_bank then
						-- 全部答完
						self.has_read = true
						self.quiz_completed = true
						storage:write_lua("must_read.lua", {
							completed = true
						})
						self.mode = "reading"
					else
						-- 下一题
						self.current_question = self.current_question + 1
					end
				else
					-- 答错了，需要冷却
					if cooldown <= 0 then
						self.last_submit_time = current_time
					end
				end
				break
			end
		end
	end
end

function MUST_READ:mousereleased(x, y, button, istouch)
	self.mouse_pressed = false
end

function MUST_READ:keypressed(key, isrepeat)
end

function MUST_READ:keyreleased(key)
end

function MUST_READ:update(dt)
	-- 更新鼠标位置
	self.mouse_x, self.mouse_y = love.mouse.getPosition()
end

function MUST_READ:draw()
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(1, 1, 1)

	if self.mode == "reading" then
		self:draw_reading_mode(w, h)
	elseif self.mode == "quiz" then
		self:draw_quiz_mode(w, h)
	end
end

function MUST_READ:draw_reading_mode(w, h)
	love.graphics.setFont(font)

	local content_w = math.max(200, w - self.margin * 2)
	local visible_lines = math.floor((h - 180) / line_h)
	local total_lines = #lines

	-- 限制 scroll 合理范围
	local max_scroll = math.max(0, total_lines - visible_lines)
	if self.scroll > max_scroll then
		self.scroll = max_scroll
	end
	if self.scroll < 0 then
		self.scroll = 0
	end

	-- 标题
	local title = _("MUST_READ_TITLE")
	love.graphics.printf(title, self.margin, 20, content_w, "center")

	-- 文本绘制
	local start_i = self.scroll + 1
	local end_i = math.min(total_lines, self.scroll + visible_lines)
	local y = 60
	for i = start_i, end_i do
		local x = self.margin
		local y_line = y
		for _, seg in ipairs(lines[i]) do
			love.graphics.setColor(seg.color)
			love.graphics.print(seg.text, x, y_line)
			x = x + font:getWidth(seg.text)
		end
		y = y + line_h
	end
	love.graphics.setColor(1, 1, 1)

	-- 滚动提示（若未到底部）
	local can_continue = is_scrolled_to_bottom(self.scroll, total_lines, visible_lines)
	if not can_continue then
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.printf(_("MUST_READ_SCROLL_HINT"), self.margin, h - 120, content_w, "left")
	end

	-- 按钮
	local btn_w, btn_h = self.ui.btn_w, self.ui.btn_h
	local bx = (w - btn_w) / 2
	local by = h - self.ui.btn_y_offset
	local is_btn_hover = self.mouse_x >= bx and self.mouse_x <= bx + btn_w and self.mouse_y >= by and self.mouse_y <= by + btn_h

	if self.has_read then
		-- 已答题完成，显示"继续游戏"
		if can_continue then
			if self.mouse_pressed and is_btn_hover then
				-- 按下状态
				love.graphics.setColor(0.08, 0.5, 0.08)
			elseif is_btn_hover then
				-- 悬停状态
				love.graphics.setColor(0.15, 0.7, 0.15)
			else
				-- 正常状态
				love.graphics.setColor(0.1, 0.6, 0.1)
			end
		else
			love.graphics.setColor(0.4, 0.4, 0.4)
		end
		love.graphics.rectangle("fill", bx, by, btn_w, btn_h, 6, 6)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(_("MUST_READ_CONTINUE"), bx, by + (btn_h - font:getHeight()) / 2, btn_w, "center")
	else
		-- 未答题，显示"去答题"
		if self.mouse_pressed and is_btn_hover then
			-- 按下状态
			love.graphics.setColor(0.15, 0.4, 0.7)
		elseif is_btn_hover then
			-- 悬停状态
			love.graphics.setColor(0.25, 0.6, 0.9)
		else
			-- 正常状态
			love.graphics.setColor(0.2, 0.5, 0.8)
		end
		love.graphics.rectangle("fill", bx, by, btn_w, btn_h, 6, 6)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(_("MUST_READ_GO_QUIZ"), bx, by + (btn_h - font:getHeight()) / 2, btn_w, "center")
	end
end

function MUST_READ:draw_quiz_mode(w, h)
	-- 背景半透明遮罩
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", 0, 0, w, h)

	-- 返回按钮
	local back_btn_w, back_btn_h = self.ui.back_btn_w, self.ui.back_btn_h
	local back_x = self.ui.back_btn_x
	local back_y = self.ui.back_btn_y
	local is_back_hover = self.mouse_x >= back_x and self.mouse_x <= back_x + back_btn_w and self.mouse_y >= back_y and self.mouse_y <= back_y + back_btn_h

	if self.mouse_pressed and is_back_hover then
		-- 按下状态
		love.graphics.setColor(0.25, 0.25, 0.25)
	elseif is_back_hover then
		-- 悬停状态
		love.graphics.setColor(0.4, 0.4, 0.4)
	else
		-- 正常状态
		love.graphics.setColor(0.3, 0.3, 0.3)
	end
	love.graphics.rectangle("fill", back_x, back_y, back_btn_w, back_btn_h, 4, 4)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(small_font)
	love.graphics.printf(_("MUST_READ_BACK_TO_READING"), back_x, back_y + (back_btn_h - small_font:getHeight()) / 2, back_btn_w, "center")

	-- 题目卡片 - 响应式布局
	-- 1. 计算卡片基本尺寸
	local available_w = w - self.ui.card_margin_left - self.ui.card_margin_right
	local available_h = h - self.ui.card_margin_top - self.ui.card_margin_bottom
	local card_w = math.min(self.ui.card_max_w, available_w)
	local card_h = math.min(self.ui.card_max_h, available_h)
	local card_x = (w - card_w) / 2
	local card_y = (h - card_h) / 2

	-- 2. 判断使用水平还是垂直布局
	local aspect_ratio = card_w / card_h
	local use_horizontal = aspect_ratio > self.ui.aspect_ratio_threshold

	local opt_h, opt_spacing, opt_y, opt_x, opt_w, question_area_h, question_x, question_w, question_y

	if use_horizontal then
		-- 水平布局（电脑端）
		local hcfg = self.ui.horizontal
		local left_w = math.floor(card_w * hcfg.left_ratio)
		local right_w = card_w - left_w - hcfg.divider_margin
		local left_x = card_x
		local right_x = card_x + left_w + hcfg.divider_margin

		local content_h = card_h - hcfg.header_h - hcfg.footer_h
		local opt_area_h = content_h - hcfg.content_padding * 2

		-- 选项计算
		local total_spacing = opt_area_h * self.ui.opt_spacing_ratio
		opt_h = math.min(self.ui.opt_max_h, (opt_area_h - total_spacing) / 3)
		opt_spacing = total_spacing / 2
		opt_y = card_y + hcfg.header_h + hcfg.content_padding
		opt_x = right_x + self.ui.opt_padding
		opt_w = right_w - self.ui.opt_padding * 2
		question_area_h = content_h

		-- 题目区域（左侧）
		question_x = left_x + self.ui.question_padding
		question_w = left_w - self.ui.question_padding * 2
		question_y = card_y + hcfg.header_h + hcfg.content_padding

		-- 绘制分割线
		love.graphics.setColor(0.4, 0.4, 0.4)
		love.graphics.setLineWidth(1)
		local divider_x = left_x + left_w + hcfg.divider_margin / 2
		love.graphics.line(divider_x, card_y + hcfg.header_h, divider_x, card_y + card_h - hcfg.footer_h)
	else
		-- 垂直布局（手机端）
		local vcfg = self.ui.vertical
		local header_h = math.max(vcfg.min_header_h, card_h * vcfg.header_ratio)
		local content_h = card_h - header_h - vcfg.footer_h
		local opt_area_h = content_h - vcfg.content_padding * 2

		-- 选项计算
		local total_spacing = opt_area_h * self.ui.opt_spacing_ratio
		opt_h = math.min(self.ui.opt_max_h, math.max(self.ui.opt_min_h, (opt_area_h - total_spacing) / 3))
		opt_spacing = total_spacing / 2
		opt_y = card_y + header_h + vcfg.content_padding
		opt_x = card_x + self.ui.opt_padding
		opt_w = card_w - self.ui.opt_padding * 2
		question_area_h = header_h - self.ui.progress_margin * 2 - 30

		-- 题目区域（顶部）
		question_x = card_x + self.ui.question_padding
		question_w = card_w - self.ui.question_padding * 2
		question_y = card_y + 30 + self.ui.progress_margin
	end

	-- 卡片背景
	love.graphics.setColor(0.15, 0.15, 0.15)
	love.graphics.rectangle("fill", card_x, card_y, card_w, card_h, 10, 10)
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", card_x, card_y, card_w, card_h, 10, 10)

	-- 获取当前题目
	local q_idx = self.shuffled_questions[self.current_question]
	local question = quiz_bank[q_idx]
	local shuffle_data = self.shuffled_options[q_idx]

	-- 进度显示（顶部居中）
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.setFont(small_font)
	local progress_text = string.format(_("MUST_READ_PROGRESS"), self.current_question, #quiz_bank)
	love.graphics.printf(progress_text, card_x, card_y + self.ui.progress_margin, card_w, "center")

	-- 题目文本
	love.graphics.setColor(1, 1, 1)
	-- 根据可用高度选择题目字体大小
	local question_font
	if question_area_h >= 120 then
		question_font = font -- 20px，正常大小
	elseif question_area_h >= 80 then
		question_font = small_font -- 16px，中等大小
	else
		-- 空间很小，使用更小的字体
		local font_size = math.floor(question_area_h * 0.2)
		question_font = require("lib.klove.font_db"):f("msyh", font_size)
	end

	love.graphics.setFont(question_font)
	local q_text = string.format("Q%d: %s", self.current_question, question.q)
	love.graphics.printf(q_text, question_x, question_y, question_w, "left")

	-- 选项
	local current_time = love.timer.getTime()
	local cooldown = 5 - (current_time - self.last_submit_time)

	for i = 1, 3 do
		local opt_idx = shuffle_data.order[i]
		local opt_text = question.opts[opt_idx]
		local oy = opt_y + (i - 1) * (opt_h + opt_spacing)
		local ox = opt_x
		local ow = opt_w

		-- 检查鼠标是否悬停在这个选项上
		local is_hover = self.mouse_x >= ox and self.mouse_x <= ox + ow and self.mouse_y >= oy and self.mouse_y <= oy + opt_h

		-- 选项背景（悬停时变亮，按下时更暗）
		if self.mouse_pressed and is_hover and cooldown <= 0 then
			-- 按下状态
			love.graphics.setColor(0.2, 0.2, 0.2)
		elseif is_hover and cooldown <= 0 then
			-- 悬停状态
			love.graphics.setColor(0.35, 0.35, 0.35)
		else
			-- 正常状态
			love.graphics.setColor(0.25, 0.25, 0.25)
		end
		love.graphics.rectangle("fill", ox, oy, ow, opt_h, 6, 6)

		-- 选项边框（悬停时高亮）
		if is_hover and cooldown <= 0 then
			love.graphics.setColor(0.6, 0.6, 0.6)
			love.graphics.setLineWidth(2)
		else
			love.graphics.setColor(0.4, 0.4, 0.4)
			love.graphics.setLineWidth(1)
		end
		love.graphics.rectangle("line", ox, oy, ow, opt_h, 6, 6)

		-- 选项文本
		love.graphics.setColor(1, 1, 1)
		-- local label = string.format("%s. %s", string.char(64 + i), opt_text)
		local label = opt_text

		-- 根据选项高度动态选择字体大小
		local text_font
		if opt_h >= 60 then
			text_font = font -- 20px，正常大小
		elseif opt_h >= 45 then
			text_font = small_font -- 16px，中等大小
		else
			-- 选项很小，使用更小的字体
			local font_size = math.floor(opt_h * 0.6) -- 字体大小约为选项高度的60%
			text_font = require("lib.klove.font_db"):f("msyh", font_size)
		end

		love.graphics.setFont(text_font)
		-- 确保文字在选项框内，垂直居中
		local text_y = oy + (opt_h - text_font:getHeight()) / 2
		love.graphics.printf(label, ox + 15, text_y, ow - 30, "left")
	end

	-- 冷却提示
	local current_time = love.timer.getTime()
	local cooldown = 5 - (current_time - self.last_submit_time)
	if cooldown > 0 then
		love.graphics.setColor(1, 0.5, 0)
		love.graphics.setFont(small_font)
		local cooldown_text = string.format(_("MUST_READ_COOLDOWN"), cooldown)
		love.graphics.printf(cooldown_text, card_x, card_y + card_h - 40, card_w, "center")
	else
		love.graphics.setColor(0.5, 1, 0.5)
		love.graphics.setFont(small_font)
		love.graphics.printf(_("MUST_READ_SUBMIT_HINT"), card_x, card_y + card_h - 40, card_w, "center")
	end
end

return MUST_READ
