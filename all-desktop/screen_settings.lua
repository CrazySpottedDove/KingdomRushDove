-- chunkname: @./all-desktop/screen_settings.lua
local log = require("klua.log"):new("game_gui")
local km = require("klua.macros")

require("klua.table")

local class = require("middleclass")
local G = love.graphics
local V = require("klua.vector")
local v = V.v
local F = require("klove.font_db")

require("klove.kui")

local i18n = require("i18n")
local fallback_resolutions = {v(800, 600), v(1024, 768), v(1300, 768), v(1500, 800), v(1422, 800), v(1600, 1080),
                              v(1365, 768), v(1280, 720), v(1920, 1080)}
local screen_settings = {}

screen_settings.required_textures = {"screen_settings"}
screen_settings.ref_h = 1080

local colors = {
    window_bg = {220, 220, 220, 255},
    selection = {40, 130, 230, 255},
    select_list_bg = {242, 242, 242, 255},
    select_list_scroller_bg = {200, 200, 200, 255},
    select_list_scroller_fg = {40, 130, 230, 255},
    button_default_bg = {242, 242, 242, 255},
    button_hover_bg = {40, 130, 230, 255},
    button_click_bg = {20, 70, 140, 255},
    focused_outline = {40, 130, 230, 255},
    text_black = {0, 0, 0, 255},
    text_white = {255, 255, 255, 255}
}

KColorButton = class("KColorButton", KButton)

function KColorButton:initialize(default_color, hover_color, click_color, w, h)
    KColorButton.super.initialize(self, V.v(w, h))

    self.default_color = default_color
    self.hover_color = hover_color
    self.click_color = click_color
    self.colors.background = default_color
    self.shape = {
        name = "rectangle",
        args = {"fill", 0, 0, self.size.x, self.size.y, 4, 4, 8}
    }
end

function KColorButton:on_enter(drag_view)
    self.colors.background = self.hover_color
    self.colors.text = colors.text_white
end

function KColorButton:on_exit(drag_view)
    self.colors.background = self.default_color
    self.colors.text = colors.text_black
end

function KColorButton:on_down(button, x, y)
    self.colors.background = self.click_color
end

function KColorButton:on_up(button, x, y)
    self.colors.background = self.hover_color
end

function KColorButton:on_focus()
    self:on_enter()
end

function KColorButton:on_defocus()
    self:on_exit()
end

function screen_settings:init(sw, sh, params, done_callback)
    self.params = params
    self.done_callback = done_callback
    self.sw = sw
    self.sh = sh

    local resolutions = {}
    local full_screen_modes = love.window.getFullscreenModes(1)

    if full_screen_modes and #full_screen_modes > 0 then
        for _, item in pairs(love.window.getFullscreenModes(1)) do
            table.insert(resolutions, v(tonumber(item.width), tonumber(item.height)))
        end
    else
        resolutions = fallback_resolutions
    end

    table.sort(resolutions, function(r1, r2)
        return r1.x > r2.x or r1.x == r2.x and r1.y > r2.y
    end)

    self.all_resolutions = resolutions

    local window = KWindow:new(V.v(sw, sh))

    window.colors.background = colors.window_bg
    self.window = window

    local y = 0
    local h = 0
    local m = 10
    local back_image = KImageView:new("game_image")

    back_image.anchor.x = back_image.size.x * 0.5
    y = y + h + m
    back_image.pos = v(sw * 0.5, y)

    window:add_child(back_image)

    h = back_image.size.y
    y = y + h + m
    h = 12

    local l_lang = KLabel:new(V.v(sw * 0.5 - 2 * m, h))

    l_lang.pos = v(m, y)
    l_lang.font_name = "sans_bold"
    l_lang.font_size = 14
    l_lang.text = _("SETTINGS_LANGUAGE")
    l_lang.text_align = "left"
    l_lang.colors.text = colors.text_black

    window:add_child(l_lang)

    y = y + h + m
    h = 24
    -- only keep zh-Hans, so h 96 -> 24
    local sl_lang = SelectList:new(sw * 0.5 - 2 * m, h)

    sl_lang.pos = v(m, y)

    for _, v in pairs(i18n.supported_locales) do
        sl_lang:add_item(i18n.locale_names[v], v)
    end

    window:add_child(sl_lang)

    y = y + h + m
    h = 12

    local l_sound_pool = KLabel:new(V.v(sw * 0.5 - 2 * m, h))

    l_sound_pool.pos = v(m, y)
    l_sound_pool.font_name = "sans_bold"
    l_sound_pool.font_size = 14
    l_sound_pool.text = "音效池大小"
    l_sound_pool.text_align = "left"
    l_sound_pool.colors.text = colors.text_black

    window:add_child(l_sound_pool)

    y = y + h + m
    h = 72

    local sl_sound_pool = SelectList:new(sw * 0.5 - 2 * m, h)

    sl_sound_pool.pos = v(m, y)

    -- 添加音效池大小选项
    for _, pool_option in pairs({{"2倍", 2}, {"1.5倍", 1.5}, {"1倍", 1}}) do
        sl_sound_pool:add_item(pool_option[1], pool_option[2])
    end

    window:add_child(sl_sound_pool)

    y = y + h + m
    h = 12

    local l_res = KLabel:new(V.v(sw * 0.5 - 2 * m, h))

    l_res.pos = v(m, y)
    l_res.font_name = "sans_bold"
    l_res.font_size = 14
    l_res.text = _("SETTINGS_SCREEN_RESOLUTION")
    l_res.text_align = "left"
    l_res.colors.text = colors.text_black

    window:add_child(l_res)

    y = y + h + m
    h = 72

    -- leave place for sound_pool_size, so h 96 -> 72
    local sl_res = SelectList:new(sw * 0.5 - 2 * m, h)

    sl_res.pos = v(m, y)

    window:add_child(sl_res)

    y = back_image.pos.y + back_image.size.y + m
    h = 12

    local l_tex = KLabel:new(V.v(sw * 0.5 - 2 * m, h))

    l_tex.pos = v(sw * 0.5 + m, y)
    l_tex.font_name = "sans_bold"
    l_tex.font_size = 14
    l_tex.text = _("SETTINGS_IMAGE_QUALITY")
    l_tex.text_align = "left"
    l_tex.colors.text = colors.text_black

    window:add_child(l_tex)

    y = y + h + m
    h = 24
    -- delete ipad, so h 48 -> 24
    local sl_tex = SelectList:new(sw * 0.5 - 2 * m, h)

    sl_tex.pos = v(sw * 0.5 + m, y)

    for _, r in pairs({{"Full HD", "fullhd"} -- {
    -- 	"HD",
    -- 	"ipad"
    -- }
    }) do
        sl_tex:add_item(r[1], r[2])
    end

    window:add_child(sl_tex)

    y = y + h + m
    h = 10

    local l_fps = KLabel:new(V.v(sw * 0.5 - 2 * m, h))

    l_fps.pos = v(sw * 0.5 + m, y)
    l_fps.font_name = "sans_bold"
    l_fps.font_size = 14
    l_fps.text = _("SETTINGS_FRAMES_PER_SECOND")
    l_fps.text_align = "left"
    l_fps.colors.text = colors.text_black

    window:add_child(l_fps)

    y = y + h + m
    h = 72

    local sl_fps = SelectList:new(sw * 0.5 - 2 * m, h)

    sl_fps.pos = v(sw * 0.5 + m, y)

    for _, r in pairs({{"144", 144}, {"120", 120}, {"90", 90}, {"60", 60}, {"30", 30}}) do
        sl_fps:add_item(r[1], r[2])
    end

    window:add_child(sl_fps)

    y = y + h + m
    h = 16

    local c_vsync = CheckBox:new(sw - 2 * m, h, _("SETTINGS_VSYNC"))

    c_vsync.pos = v(sw * 0.5 + m, y)
    c_vsync:get_colors().text = colors.text_black

    window:add_child(c_vsync)

    y = y + h + m
    h = 16

    local c_large_pointer = CheckBox:new(sw - 2 * m, h, _("SETTINGS_LARGE_MOUSE_POINTER"))

    c_large_pointer.pos = v(sw * 0.5 + m, y)
    c_large_pointer:get_colors().text = colors.text_black

    window:add_child(c_large_pointer)

    y = y + h + m
    h = 16

    local c_highdpi
    local c_fs = CheckBox:new(sw - 2 * m, h, _("SETTINGS_FULLSCREEN"))

    c_fs.pos = v(sw * 0.5 + m, y)
    c_fs:get_colors().text = colors.text_black

    function c_fs.on_change(this, value)
        if this.checked then
            c_highdpi:set_check(false)
            c_highdpi:disable()

            c_highdpi.hidden = true
        else
            c_highdpi:enable()

            c_highdpi.hidden = love.system.getOS() ~= "OS X"
        end

        self:update_resolutions_list(this.checked, c_highdpi.checked)
    end

    window:add_child(c_fs)

    y = y + h + m
    h = 16
    c_highdpi = CheckBox:new(sw - 2 * m, h, _("Retina display (macOS)"))
    c_highdpi.pos = v(sw * 0.5 + m, y)
    c_highdpi:get_colors().text = colors.text_black
    c_highdpi.hidden = love.system.getOS() ~= "OS X"

    function c_highdpi.on_change(this, value)
        self:update_resolutions_list(c_fs.checked, this.checked)
    end

    window:add_child(c_highdpi)

    local button_offset = 70
    local b_quit = KColorButton:new(colors.button_default_bg, colors.button_hover_bg, colors.button_click_bg, 120, 45)

    b_quit.pos = v((sw * 0.5 - b_quit.size.x) * 0.5, sh - button_offset)
    b_quit.text = _("QUIT")
    b_quit.font_name = "sans_bold"
    b_quit.font_size = 14
    b_quit.text_offset = v(0, 12)
    b_quit.colors.text = colors.text_black

    function b_quit.on_click()
        self:handle_quit_button()
    end

    function b_quit.on_keypressed(this, key)
        if key == "return" or key == "space" then
            self:handle_quit_button()
        end
    end

    window:add_child(b_quit)

    local b_play = KColorButton:new(colors.button_default_bg, colors.button_hover_bg, colors.button_click_bg, 120, 45)

    b_play.pos = v((3 * sw * 0.5 - b_quit.size.x) * 0.5, sh - button_offset)
    b_play.text = _("START")
    b_play.font_name = "sans_bold"
    b_play.font_size = 14
    b_play.text_offset = v(0, 12)
    b_play.colors.text = colors.text_black

    function b_play.on_click()
        self:handle_play_button()
    end

    function b_play.on_keypressed(this, key)
        if key == "return" or key == "space" then
            self:handle_play_button()
        end
    end

    window:add_child(b_play)

    h = b_quit.size.y

    local l_ver = KLabel(V.v(sw, 12))

    l_ver.text = string.format("ver. %s", version.string or "NA")
    l_ver.font_name = "sans"
    l_ver.font_size = 11
    l_ver.colors.text = colors.text_black
    l_ver.text_align = "center"
    l_ver.pos = v(0, sh - l_ver.size.y - 6)

    window:add_child(l_ver)

    self.sl_lang = sl_lang
    self.sl_sound_pool = sl_sound_pool
    self.sl_res = sl_res
    self.sl_tex = sl_tex
    self.sl_fps = sl_fps
    self.c_fs = c_fs
    self.c_vsync = c_vsync
    self.c_large_pointer = c_large_pointer
    self.c_highdpi = c_highdpi

    self:update_resolutions_list(self.params.fullscreen)
    self:select_resolution({
        x = self.params.width,
        y = self.params.height
    })

    for _, c in pairs(sl_sound_pool.children) do
        if c.custom_value == self.params.sound_pool_size then
            sl_sound_pool:select_item(c)
            sl_sound_pool:scroll_to_show_y(c.pos.y)
            break
        end
    end

    for _, c in pairs(sl_lang.children) do
        if c.custom_value == self.params.locale then
            sl_lang:select_item(c)
            sl_lang:scroll_to_show_y(c.pos.y)

            break
        end
    end

    for _, c in pairs(sl_tex.children) do
        if c.custom_value == self.params.texture_size then
            sl_tex:select_item(c)
            sl_tex:scroll_to_show_y(c.pos.y)

            break
        end
    end

    for _, c in pairs(sl_fps.children) do
        if c.custom_value == self.params.fps then
            sl_fps:select_item(c)
            sl_fps:scroll_to_show_y(c.pos.y)

            break
        end
    end

    c_fs:set_check(self.params.fullscreen)
    c_vsync:set_check(self.params.vsync)
    c_large_pointer:set_check(self.params.large_pointer)
    c_highdpi:set_check(self.params.highdpi)
    b_play:focus()
end

function screen_settings:update(dt)
    self.window:update(dt)
end

function screen_settings:draw()
    self.window:draw()
end

function screen_settings:keypressed(key, isrepeat)
    self.window:keypressed(key)
end

function screen_settings:keyreleased(key, isrepeat)
    return
end

function screen_settings:mousepressed(x, y, button)
    self.window:mousepressed(x, y, button)
end

function screen_settings:mousereleased(x, y, button)
    self.window:mousereleased(x, y, button)
end

function screen_settings:wheelmoved(dx, dy)
    self.window:wheelmoved(dx, dy)
end

function screen_settings:handle_play_button()
    if self.sl_lang.selected_item then
        self.params.locale = self.sl_lang.selected_item.custom_value
    else
        self.params.locale = "zh-Hans"
    end

    if self.sl_res.selected_item then
        self.params.width = self.sl_res.selected_item.custom_value.x
        self.params.height = self.sl_res.selected_item.custom_value.y
    end

    if self.sl_tex.selected_item then
        self.params.texture_size = self.sl_tex.selected_item.custom_value
    else
        self.params.texture_size = "fullhd"
    end

    if self.sl_fps.selected_item then
        self.params.fps = self.sl_fps.selected_item.custom_value
    else
        self.params.fps = 60
    end

    if self.sl_sound_pool.selected_item then
        self.params.sound_pool_size = self.sl_sound_pool.selected_item.custom_value
    else
        self.params.sound_pool_size = 1
    end

    self.params.fullscreen = self.c_fs.checked
    self.params.vsync = self.c_vsync.checked
    self.params.large_pointer = self.c_large_pointer.checked
    self.params.highdpi = self.c_highdpi.checked

    self.done_callback()
end

function screen_settings:handle_quit_button()
    love.event.quit()
end

function screen_settings:update_resolutions_list(fullscreen, highdpi)
    local resolutions = {}
    local dt_w, dt_h = love.window.getDesktopDimensions()

    for _, r in pairs(self.all_resolutions) do
        local aspect = r.x / r.y

        if not fullscreen and (aspect > 1.7777777777777777 or aspect < 1.3333333333333333) then
            -- block empty
        elseif r.x < 640 or r.y < 480 then
            -- block empty
        elseif not fullscreen and highdpi and dt_w < r.x then
            -- block empty
        else
            table.insert(resolutions, r)
        end
    end

    local sl_res = self.sl_res
    local prev_selection

    if sl_res.selected_item then
        prev_selection = {
            x = sl_res.selected_item.custom_value.x,
            y = sl_res.selected_item.custom_value.y
        }
    end

    sl_res:clear_rows()

    for _, r in pairs(resolutions) do
        sl_res:add_item(string.format("%s x %s", r.x, r.y), r)
    end

    if prev_selection then
        self:select_resolution(prev_selection)
    end
end

function screen_settings:select_resolution(res)
    local sl_res = self.sl_res

    for _, c in pairs(sl_res.children) do
        if c.custom_value.x == res.x and c.custom_value.y == res.y then
            sl_res:select_item(c)
            sl_res:scroll_to_show_y(c.pos.y)

            break
        end
    end
end

CheckBox = class("CheckBox", KView)

function CheckBox:initialize(w, h, text)
    CheckBox.super.initialize(self, V.v(w, h))

    self.checked = false
    self.text = text and text or ""

    local l = KLabel:new(V.v(w, h))

    l.text = self.text
    l.font_name = "sans"
    l.font_size = 12
    l.colors.text = {255, 255, 255, 255}
    l.colors.focused_outline = colors.focused_outline
    l.text_align = "left"
    l.propagate_on_click = true

    self:add_child(l)

    self._l = l

    self:set_check(self.checked)
end

function CheckBox:get_colors()
    return self._l.colors
end

function CheckBox:set_text(text)
    self.text = text

    self:set_check(self.checked)
end

function CheckBox:set_check(value)
    if value == true then
        self.checked = true
        self._l.text = "[X] " .. self.text
    else
        self.checked = false
        self._l.text = "[ ] " .. self.text
    end

    self:on_change(value)
end

function CheckBox:on_click(button, x, y)
    self:set_check(not self.checked)
end

function CheckBox:on_keypressed(key)
    if key == "space" or key == "return" then
        self:set_check(not self.checked)
    end
end

function CheckBox:on_change(value)
    return
end

function CheckBox:draw_focus()
    local l = self._l

    G.setColor_old(l.colors.focused_outline)

    local tw = l.font:getWidth(self._l.text)

    G.rectangle("line", 0, l.size.y, tw, 1)
end

SelectList = class("SelectList", KScrollList)

function SelectList:initialize(w, h)
    SelectList.super.initialize(self, V.v(w, h))

    self._items = {}
    self.scroll_acceleration = 0
    self.scroll_amount = 24
    self.selected_item = nil
    self.colors.background = colors.select_list_bg
    self.colors.scroller_foreground = colors.select_list_scroller_fg
    self.colors.scroller_background = colors.select_list_scroller_bg
    self.colors.focused_outline = colors.focused_outline

    self:set_scroller_size(10, 2)
end

function SelectList:draw()
    KScrollList.super.draw(self)
    G.push()
    G.scale(self.scale.x, self.scale.y)
    G.rotate(-self.r)

    if not self.scroller_hidden and self._bottom_y > self.size.y then
        G.setColor_old(self.colors.scroller_background)
        G.rectangle("fill", self.scroller_rect.pos.x, self.scroller_rect.pos.y, self.scroller_rect.size.x,
            self.scroller_rect.size.y)
        G.setColor_old(self.colors.scroller_foreground)

        local scroller_height = self.size.y / self._bottom_y * (self.size.y - 2 * self.scroller_margin)
        local scroller_offset = -self.scroll_origin_y / self._bottom_y * (self.size.y - 2 * self.scroller_margin)

        G.rectangle("fill", self.size.x - self.scroller_width - self.scroller_margin,
            scroller_offset + self.scroller_margin, self.scroller_width, scroller_height)
    end

    G.pop()
end

function SelectList:add_item(text, custom_value)
    local l = KLabel:new(V.v(self.size.x, 24))

    l.colors.background = {255, 255, 255, 0}
    l.text_align = "left"
    l.text = text
    l.font_name = "NotoSansCJKkr-Regular"
    l.font_size = 12
    l.text_offset = v(5, 6)
    l.colors.text = colors.text_black
    l.propagate_on_down = true

    function l.on_click()
        self:select_item(l)
    end

    l.custom_value = custom_value

    self:add_row(l)
end

function SelectList:select_item(item)
    for _, c in pairs(self.children) do
        if c == item then
            c.colors.background = colors.selection
            c.colors.text = colors.text_white
            self.selected_item = c
        else
            c.colors.background = colors.select_list_bg
            c.colors.text = colors.text_black
        end
    end
end

function SelectList:on_focus()
    return
end

function SelectList:on_keypressed(key)
    local function get_item_index(item)
        for i, c in ipairs(self.children) do
            if c == item then
                return i
            end
        end

        return nil
    end

    if #self.children < 1 then
        return
    end

    local i = get_item_index(self.selected_item)

    if key == "up" then
        if i then
            i = km.clamp(1, #self.children, i - 1)

            self:select_item(self.children[i])
        else
            self:select_item(self.children[1])
        end

        self:scroll_to_show_y(self.selected_item.pos.y)
    elseif key == "down" then
        if i then
            i = km.clamp(1, #self.children, i + 1)

            self:select_item(self.children[i])
        else
            self:select_item(self.children[#self.children])
        end

        self:scroll_to_show_y(self.selected_item.pos.y)
    end
end

return screen_settings
