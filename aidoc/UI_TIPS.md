# KUI 界面开发经验总结

> 本文档记录在 KingdomRushDove 项目中进行 KUI 界面开发时积累的经验、坑点与最佳实践。
> 主要来源：`all-desktop/screen_settings.lua` 美化工作（2026-03）

---

## 一、KUI 绘制系统基础

### 坐标系与绘制顺序
- `KView._draw_children` 在绘制每个子元素前会平移到该子元素的 `pos` 位置，因此子元素的 `_draw_self` 中 `(0, 0)` 就是该元素自身的左上角。
- `SelectList:draw()` 内部已被平移到 list 的位置，`G.push()/G.pop()` 保存/恢复的是**变换矩阵**，不保存颜色和线宽——必须手动恢复。
- 绘制顺序：背景 → 子元素 → 前景装饰（border overlay 等）。

### shape 属性
- 任何 `KView` 子类均可设置 `self.shape = { name="rectangle", args={...} }` 来绘制背景形状。
- `args` 格式与 `love.graphics.rectangle` 完全一致：`{"fill", x, y, w, h[, rx, ry, segments]}`。
- 如需圆角：`args = {"fill", 0, 0, w, h, rx, ry, segments}`，`segments` 建议 ≥ 8，否则曲线锯齿明显。
- **圆角与子元素的矩形背景会产生视觉冲突**：子元素铺满宽度的矩形背景会遮住 list 圆角区域。解决方案：将子元素 `colors.background = nil`（透明），在 `_draw_self` 中手动绘制内缩的高亮矩形。

### colors.background = nil
- 将 `self.colors.background` 设为 `nil` 可使 KView 跳过背景绘制，完全透明。
- 常用于 list item：让 list 自身的背景直接透出，高亮由 `_draw_self` 手动绘制。

### G.setColor vs G.setColor_old
- `G.setColor(r, g, b, a)`：参数范围 0–1。
- `G.setColor_old(table)`：参数范围 0–255 的表，如 `{52, 120, 210, 255}`。
- colors 表统一用 0–255 存储，绘制时除以 255 换算。

---

## 二、实例方法覆盖技巧

### 覆盖单个实例的 _draw_self
```lua
function l:_draw_self()
    local _G = love.graphics
    local pr, pg, pb, pa = _G.getColor()
    -- 自定义绘制...
    _G.setColor(pr, pg, pb, pa)   -- 必须恢复颜色
    KLabel._draw_self(self)        -- 调用父类方法
end
```
- 用 `self` 参数（冒号语法）覆盖实例方法。
- 调用父类时用 `KLabel._draw_self(self)` 显式传 self。
- **始终在最后恢复颜色和线宽**，否则影响后续所有元素绘制。

### on_enter / on_exit / on_click 用点语法（闭包）
```lua
function l.on_enter()   -- 注意：点语法，无 self 参数
    l._hovered = true   -- 通过闭包引用 l
end
```
- 用 `_hovered`、`_selected` 等自定义 flag 驱动绘制，比直接改 `colors.background` 更干净（尤其存在 background=nil 时）。

---

## 三、SelectList 开发规范

### children 遍历必须检查 custom_value
SelectList 的 children 中可能混有 spacer（`KView`，无 `custom_value`），遍历时务必判空：
```lua
for _, c in pairs(sl.children) do
    if c.custom_value ~= nil and c.custom_value == target then
        -- ...
    end
end
-- 对于 custom_value 是 table 的情况（如分辨率）：
if c.custom_value and c.custom_value.x == res.x then ...
```

### clear_rows 后需重置 _spacer_added
如果在 `add_item` 中用 `_spacer_added` flag 插入顶部空白行，`clear_rows` 后要重置该 flag，否则下次 add_item 不会重新添加 spacer：
```lua
sl_res:clear_rows()
sl_res._spacer_added = nil
```

### remove_row 不存在
`KScrollList` 只有 `clear_rows()`，没有 `remove_row()`。不要尝试动态删除某一行。

### scroller 绘制
- `SelectList:draw()` 内部手动绘制 scroller，在 `G.push()/G.pop()` 块内，坐标为 list 本地坐标系。
- scroller 只在 `self._bottom_y > self.size.y` 时显示（内容超出可视区域时）。

### scroll_amount
- 控制鼠标滚轮每次滚动的像素数，应与 item 高度一致，例如 item 高 28px → `scroll_amount = 28`。

---

## 四、CheckBox 开发规范

### 布局
- indicator（勾选框图形）绘制在左侧，宽度 = `h + 2`（高度 + 2px）。
- label 起始 x = `indicator_w + 4`，宽度 = `w - indicator_w - 4`。
- `text_offset.y` 建议设为 3–5（根据字号调整），让文字垂直居中。

### _draw_self 中绘制 indicator
```lua
function CheckBox:_draw_self()
    KView._draw_self(self)   -- 先绘制背景（若有）
    local G = love.graphics
    local pr, pg, pb, pa = G.getColor()
    local s = self.size.y
    local bpad = 3
    local ix, iy = bpad, bpad
    local iw, ih = s - bpad * 2, s - bpad * 2
    if self.checked then
        -- 填充色 + 勾形
        G.setColor(52/255, 118/255, 210/255, 1)
        G.rectangle("fill", ix, iy, iw, ih)
        G.setColor(1, 1, 1, 0.95)
        G.setLineWidth(2)
        -- 勾：左下角到中间，再到右上角
        local mx = ix + math.floor(iw * 0.38)
        local my = iy + ih - 4
        G.line(ix+3, iy+ih*0.52, mx, my)
        G.line(mx, my, ix+iw-2, iy+3)
        G.setLineWidth(1)
    else
        -- 空框
        G.setColor(80/255, 130/255, 210/255, 0.55)
        G.setLineWidth(1.5)
        G.rectangle("line", ix, iy, iw, ih)
        G.setLineWidth(1)
    end
    G.setColor(pr, pg, pb, pa)
end
```

### get_colors() 返回 label 的 colors
外部通过 `checkbox:get_colors().text = ...` 设置文字颜色。

---

## 五、KColorButton 开发规范

### 每个按钮可有独立的默认文字颜色
`on_exit` 默认恢复 `text_black`，但金色/彩色按钮默认状态文字可能是白色。
解决方案：在 `KColorButton` 中加 `default_text_color` 字段：
```lua
function KColorButton:initialize(...)
    ...
    self.default_text_color = colors.text_black  -- 默认值
end

function KColorButton:on_exit()
    self.colors.background = self.default_color
    self.colors.text = self.default_text_color    -- 用实例字段
end
```
构造后对特定按钮覆盖：
```lua
b_play.default_text_color = colors.text_white
```

### 避免按钮初始聚焦
不要在 init 末尾调用 `b_play:focus()`，否则按钮一开始就处于 hover/focus 样式。

---

## 六、draw() 装饰层

### screen_settings:draw() 执行顺序
```lua
function screen_settings:draw()
    self.window:draw()   -- 先画窗口内容
    -- 再在上面叠加全局装饰（分隔线、边框等）
    local G = love.graphics
    local w, h = love.graphics.getDimensions()
    local scale = self.scale
    -- 注意：draw() 中坐标是屏幕像素坐标，需乘 scale
    G.line(0, 57 * scale, w, 57 * scale)
end
```
- 窗口内部坐标用 `ref_h = 1080` 的虚拟像素，`draw()` 中的屏幕坐标需乘 `scale`。

---

## 七、颜色设计参考（深色策略游戏风格）

```lua
local colors = {
    window_bg              = {16, 20, 32, 255},   -- 深海军蓝背景
    panel_bg               = {26, 33, 50, 255},   -- 标题栏/卡片面板
    selection              = {58, 130, 220, 255},  -- 选中蓝
    select_list_bg         = {22, 28, 42, 255},   -- 列表背景
    select_list_scroller_bg = {34, 42, 62, 255},
    select_list_scroller_fg = {75, 140, 225, 255},
    button_default_bg      = {36, 46, 68, 255},   -- 次要按钮（深色）
    button_play_default_bg = {182, 124, 28, 255}, -- 主要按钮金色
    button_play_hover_bg   = {215, 155, 45, 255},
    button_play_click_bg   = {148, 98, 18, 255},
    button_quit_hover_bg   = {162, 50, 46, 255},
    button_quit_click_bg   = {108, 30, 28, 255},
    text_black             = {205, 218, 248, 255}, -- 主文字（亮色，暗背景下）
    text_white             = {255, 255, 255, 255},
    title_text             = {238, 244, 255, 255},
    accent_gold            = {195, 148, 38, 255},  -- 金色装饰线
}
```

### item 高亮颜色
- 选中：`{52, 118, 210, 255}` 实色蓝
- 悬浮：`{75, 110, 175, 255}` 带透明度（alpha ≈ 0.35），视觉上浅蓝，不喧宾夺主

---

## 八、布局常量参考

| 名称 | 值 | 说明 |
|------|-----|------|
| `ref_h` | 1080 | 虚拟高度，所有布局坐标基于此 |
| `m` | 24 | 通用外边距 |
| `title_h` | 56 | 标题栏高度 |
| item 高度 | 28 | SelectList 每行高度 |
| `scroll_amount` | 28 | 与 item 高度对齐 |
| 按钮（次要） | 130×46 | 退出按钮 |
| 按钮（主要） | 152×50 | 开始按钮，略大 |

### 文字垂直居中经验值
- item 高 28，字号 13：`text_offset.y = 5`
- 按钮高 46，字号 14：`text_offset.y = 13`
- 按钮高 50，字号 15：`text_offset.y = 15`
- 规律：`text_offset.y ≈ (height - font_size) / 2 - 1`（KLabel 渲染有约 1–2px 的 ascender 偏移）
