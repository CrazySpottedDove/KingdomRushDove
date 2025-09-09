-- chunkname: @./all-desktop/screen_slots.lua

local log = require("klua.log"):new("screen_slots")
local class = require("middleclass")
local F = require("klove.font_db")
local I = require("klove.image_db")
local V = require("klua.vector")
local v = V.v
local signal = require("hump.signal")
local storage = require("storage")
local slot_template = require("data.slot_template")
local timer = require("hump.timer").new()
local PS = require("platform_services")
local S = require("sound_db")
local SU = require("screen_utils")
local U = require("utils")
local km = require("klua.macros")
local GS = require("game_settings")
local i18n = require("i18n")
local features = require("features")

require("gg_views_custom")
require("klove.kui")

local kui_db = require("klove.kui_db")
local screen = {}

screen.required_sounds = {
	"common",
	"music_screen_slots"
}
screen.required_textures = {
	"screen_slots",
	"view_options"
}
screen.ref_w = 1920
screen.ref_h = 1080
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd

local function wid(name)
	return screen.window:get_child_by_id(name)
end

CSinkButton = class("CSinkButton", KImageButton)

function CSinkButton:initialize(default_image_name, hover_image_name, click_image_name, disable_image_name)
	CSinkButton.super.initialize(self, default_image_name, hover_image_name, click_image_name, disable_image_name)

	if not self.down_offset then
		self.down_offset = V.v(-3, 5)
	end
end

function CSinkButton:on_enter(drag_view)
	CSinkButton.super.on_enter(self, drag_view)

	local c = self.children[1]

	if c then
		c.pos = V.v(0, 0)

		for _, cc in pairs(table.append({
			c
		}, c.children, true)) do
			if cc:isInstanceOf(CHoverImage) then
				cc:show_hover()
			end
		end
	end
end

function CSinkButton:on_exit(drag_view)
	CSinkButton.super.on_exit(self, drag_view)

	local c = self.children[1]

	if c then
		c.pos = V.v(0, 0)

		for _, cc in pairs(table.append({
			c
		}, c.children, true)) do
			if cc:isInstanceOf(CHoverImage) then
				cc:hide_hover()
			end
		end
	end
end

function CSinkButton:on_down(button, x, y)
	CSinkButton.super.on_down(self, button, x, y)

	if self.children[1] then
		self.children[1].pos = self.down_offset
	end
end

function CSinkButton:on_up(button, x, y)
	CSinkButton.super.on_up(self, button, x, y)

	if self.children[1] then
		self.children[1].pos = V.v(0, 0)
	end
end

CHoverImage = class("CHoverImage", KImageView)

CHoverImage:append_serialize_keys("default_image_name", "hover_image_name")

CHoverImage.static.init_arg_names = {
	"default_image_name",
	"hover_image_name"
}

function CHoverImage:initialize(default_image_name, hover_image_name)
	self.hover_image_name = hover_image_name or default_image_name

	CHoverImage.super.initialize(self, default_image_name)
end

function CHoverImage:show_hover(drag_view)
	if not self:is_disabled() then
		self:set_image(self.hover_image_name)
	end
end

function CHoverImage:hide_hover(drag_view)
	if not self:is_disabled() then
		self:set_image(self.default_image_name)
	end
end

SlotView = class("SlotView", KView)
SlotView.static.init_arg_names = {
	"slot_idx"
}
SlotView.static.instance_keys = {
	"id",
	"template_name",
	"pos",
	"slot_idx"
}

function SlotView:initialize(slot_idx)
	self.slot_idx = slot_idx

	SlotView.super.initialize(self)

	local b_slot = self:get_child_by_id("button_slot")

	function b_slot.on_click()
		S:queue("GUIButtonCommon")
		screen:handle_slot_button(self.slot_idx)
	end

	local b_new = self:get_child_by_id("button_slot_new")

	function b_new.on_click()
		S:queue("GUIButtonCommon")
		screen:handle_slot_button(self.slot_idx)
	end

	local b_delete = self:get_child_by_id("button_slot_delete")

	function b_delete.on_click()
		S:queue("GUIButtonCommon")

		local delete_view = screen.window:get_child_by_id("delete_view")

		delete_view.slot_view = self

		delete_view:show()
	end

	if KR_GAME == "kr1" then
		local button_slot = self:get_child_by_id("button_slot")
		local sm = {
			{
				1,
				2,
				3
			},
			{
				7,
				8,
				9
			},
			{
				10,
				11,
				12
			}
		}

		for i, k in ipairs({
			"default_image_name",
			"hover_image_name",
			"click_image_name"
		}) do
			button_slot[k] = string.gsub(button_slot[k], "_00%d%d$", string.format("_%04d", sm[slot_idx][i]))
			button_slot[k] = string.gsub(button_slot[k], "_en_", "_" .. i18n.current_locale .. "_")
		end

		button_slot:on_exit()

		local button_slot_new = self:get_child_by_id("button_slot_new")

		for _, k in pairs({
			"default_image_name",
			"hover_image_name",
			"click_image_name"
		}) do
			button_slot_new[k] = string.gsub(button_slot_new[k], "_en_", "_" .. i18n.current_locale .. "_")
		end

		button_slot_new:on_exit()
	elseif KR_GAME == "kr3" then
		for _, id in pairs({
			"l_slot",
			"l_slot_new"
		}) do
			local v = self:get_child_by_id(id)

			for _, k in pairs({
				"default_image_name",
				"hover_image_name"
			}) do
				if id == "l_slot" then
					v[k] = string.gsub(v[k], "_%d_", string.format("_%s_", slot_idx))
				end

				v[k] = string.gsub(v[k], "_en$", "_" .. i18n.current_locale)
			end

			v:hide_hover()
		end
	else
		local button_slot = self:get_child_by_id("button_slot")

		for _, k in pairs({
			"default_image_name",
			"hover_image_name",
			"click_image_name"
		}) do
			button_slot[k] = string.gsub(button_slot[k], "_%d_", string.format("_%s_", slot_idx))
			button_slot[k] = string.gsub(button_slot[k], "_en$", "_" .. i18n.current_locale)
		end

		button_slot:on_exit()

		local button_slot_new = self:get_child_by_id("button_slot_new")

		for _, k in pairs({
			"default_image_name",
			"hover_image_name",
			"click_image_name"
		}) do
			button_slot_new[k] = string.gsub(button_slot_new[k], "_en$", "_" .. i18n.current_locale)
		end

		button_slot_new:on_exit()
	end

	self:show()
end

function SlotView:show()
	local slot = storage:load_slot(self.slot_idx, true)

	if not slot then
		self:get_child_by_id("slot_used").hidden = true
		self:get_child_by_id("slot_empty").hidden = false
	else
		self:get_child_by_id("slot_used").hidden = false
		self:get_child_by_id("slot_empty").hidden = true

		local l_stars = self:get_child_by_id("l_stars")
		local l_heroic = self:get_child_by_id("l_heroic")
		local l_iron = self:get_child_by_id("l_iron")
		local num_stars, num_heroic, num_iron = U.count_stars(slot)

		l_stars.text = tostring(num_stars) .. "/" .. tostring(GS.max_stars)
		l_heroic.text = tostring(num_heroic)
		l_iron.text = tostring(num_iron)
	end
end

function SlotView:delete_slot()
	storage:delete_slot(self.slot_idx)

	self:get_child_by_id("slot_used").hidden = true
	self:get_child_by_id("slot_empty").hidden = false
end

screen.signal_handlers = {
	[SGN_PS_SYNC_SLOTS_FINISHED] = function(service_name, success, request_id, status_code)
		log.debug(SGN_PS_SYNC_SLOTS_FINISHED .. " : %s %s", service_name, success)

		if service_name == "cloudsave" then
			screen.cloudsave_req_id = nil

			if not wid("cloudsave_progress_view").hidden then
				screen:hide_cloudsave_progress()

				if success then
					screen.slot_panel:show()
				else
					screen:show_cloudsave_error(status_code)
				end
			end
		end
	end
}

function screen:init(w, h, done_callback)
	self.done_callback = done_callback

	local sw = self.ref_h * (w / h)
	local sh = self.ref_h
	local scale = h / self.ref_h

	self.sw = sw
	self.sh = sh
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	local ctx = {
		left_margin = (self.ref_w - sw) * 0.5
	}
	local tt = kui_db:get_table("screen_slots", ctx)
	local window = KWindow:new_from_table(tt)

	window.scale = {
		x = scale,
		y = scale
	}
	window.size = {
		x = sw,
		y = sh
	}
	window.timer = timer
	self.window = window

	local backImage = window:get_child_by_id("bg_view")

	backImage.pos.x = sw * 0.5

	if i18n.current_locale == "zh-Hans" and KR_GAME == "kr2" then
		window:get_child_by_id("main_menu_subtitle_cn").hidden = false
	end

	if features.gov_approval_id then
		local v = window:get_child_by_id("gov_approval_view")

		v.hidden = false
		v.text = string.format(v.text, features.gov_approval_id)
	end

	if features.health_warning then
		window:get_child_by_id("health_advice_view").hidden = false
	end

	local banner = window:get_child_by_id("banner")

	banner.propagate_on_click = true
	self.banner = banner

	local slot_panel = window:get_child_by_id("slot_panel")

	self.slot_panel = slot_panel
	self.slot_panel.hidden = true

	function slot_panel.hide(this)
		local banner_pos_left = 0

		timer:tween(0.1, this, {
			pos = {
				x = banner_pos_left
			}
		}, "out-quad", function()
			this.hidden = true
		end)
	end

	function slot_panel.show(this)
		for _, v in pairs(wid("slot_panel").children) do
			if v:isInstanceOf(SlotView) then
				v:show()
			end
		end

		local banner_pos_right = 160

		this.hidden = false

		timer:tween(0.1, this, {
			pos = {
				x = banner_pos_right
			}
		}, "out-quad")
	end

	function slot_panel.toggle(this)
		if this.hidden then
			this:show()
		else
			this:hide()
		end
	end

	local show_slots = window:get_child_by_id("banner_button_start")

	self.show_slots = show_slots

	function show_slots.on_click()
		S:queue("GUIButtonCommon")

		if self.slot_panel.hidden then
			local pscloud = PS and PS.services.cloudsave

			if pscloud then
				if self.cloudsave_req_id then
					self:show_cloudsave_progress()

					return
				elseif pscloud and pscloud:get_status() then
					local status = pscloud:get_sync_status()

					if not status.slots or os.time() - status.slots > 600 then
						local rid = pscloud:sync_slots()

						if rid then
							self:show_cloudsave_progress()

							self.cloudsave_req_id = rid

							return
						end
					end
				end
			end

			self.slot_panel:show()
		else
			self.slot_panel:hide()
		end
	end

	local show_options = window:get_child_by_id("banner_button_options")

	function show_options.on_click()
		S:queue("GUIButtonCommon")
		self.window:get_child_by_id("options_view"):show()
	end

	local show_credits = window:get_child_by_id("banner_button_credits")

	function show_credits.on_click()
		self:handle_credits_button(b_credits)
		S:queue("GUIButtonCommon")
	end

	local quit = window:get_child_by_id("banner_button_quit")

	function quit.on_click()
		S:queue("GUIButtonCommon")
		self.window:get_child_by_id("quit_view"):show()
	end

	for _, v in pairs({
		show_slots,
		show_options,
		show_credits,
		quit
	}) do
		if KR_GAME == "kr1" then
			for _, k in pairs({
				"default_image_name",
				"hover_image_name",
				"click_image_name"
			}) do
				v[k] = string.gsub(v[k], "_en_", "_" .. i18n.current_locale .. "_")
			end

			v:on_exit()
		elseif KR_GAME == "kr3" then
			for _, k in pairs({
				"default_image_name",
				"hover_image_name"
			}) do
				v.children[1][k] = string.gsub(v.children[1][k], "_en$", "_" .. i18n.current_locale)
			end

			v.children[1]:hide_hover()
		else
			for _, k in pairs({
				"default_image_name",
				"hover_image_name",
				"click_image_name"
			}) do
				v[k] = string.gsub(v[k], "_en$", "_" .. i18n.current_locale)
			end

			v:on_exit()
		end
	end

	local delete_view = window:get_child_by_id("delete_view")
	local delete_yes = window:get_child_by_id("delete_button_yes")

	function delete_yes.on_click(this)
		S:queue("GUIButtonCommon")
		delete_view.slot_view:delete_slot()
		delete_view:hide()
	end

	local delete_no = window:get_child_by_id("delete_button_no")

	function delete_no.on_click(this)
		S:queue("GUIButtonCommon")
		delete_view:hide()
	end

	local quit_view = window:get_child_by_id("quit_view")
	local quit_yes = window:get_child_by_id("quit_button_yes")

	function quit_yes.on_click(this)
		S:queue("GUIButtonCommon")
		screen:handle_quit_button(b_yes)
	end

	local quit_no = window:get_child_by_id("quit_button_no")

	function quit_no.on_click(this)
		S:queue("GUIButtonCommon")
		quit_view:hide()
	end

	local options_view = window:get_child_by_id("options_view")
	local options_done = window:get_child_by_id("options_button_done")

	function options_done.on_click(this)
		S:queue("GUIButtonCommon")

		local s_sfx = window:get_child_by_id("s_sfx")
		local s_music = window:get_child_by_id("s_music")
		local settings = storage:load_settings()

		settings.volume_fx = km.clamp(0, 1, s_sfx.value)
		settings.volume_music = km.clamp(0, 1, s_music.value)

		storage:save_settings(settings, true)
		options_view:hide()
	end

	local s_sfx = window:get_child_by_id("s_sfx")
	local s_music = window:get_child_by_id("s_music")

	function s_sfx:on_change(value)
		S:set_main_gain_fx(value)
	end

	function s_music:on_change(value)
		S:set_main_gain_music(value)
	end

	local vol_settings = storage:load_settings()

	if vol_settings then
		if vol_settings.volume_fx and type(vol_settings.volume_fx) == "number" then
			s_sfx:set_value(km.clamp(0, 1, vol_settings.volume_fx))
		else
			s_sfx:set_value(1)
		end

		if vol_settings.volume_music and type(vol_settings.volume_music) == "number" then
			s_music:set_value(km.clamp(0, 1, vol_settings.volume_music))
		else
			s_music:set_value(1)
		end
	end

	if not S:sound_is_playing("MusicMainMenu") then
		S:queue("MusicMainMenu")
	end

	wid("cloudsave_cancel_button").on_click = function(this)
		S:queue("GUIButtonCommon")

		local rid = screen.cloudsave_req_id

		if rid and PS and PS.services.cloudsave then
			PS.services.cloudsave:cancel_request(rid)
		end

		screen.cloudsave_req_id = nil

		screen:hide_cloudsave_progress()
		screen.slot_panel:show()
	end
	wid("cloudsave_close_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen:hide_cloudsave_error()
		screen.slot_panel:show()
	end

	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end

	if PS.services.cloudsave and PS.services.cloudsave:get_status() then
		self.cloudsave_req_id = PS.services.cloudsave:sync_slots()
	end

	local global = storage:load_global()

	if not global.first_launch_time then
		global.first_launch_time = os.time()

		storage:save_global(global)
	end
end

function screen:destroy()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end

	timer:clear()
	self.window:destroy()

	self.window = nil

	SU.remove_references(self, KView)
end

function screen:update(dt)
	self.window:update(dt)
	timer:update(dt)
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	if key == "escape" then
		for _, id in pairs({
			"quit_view",
			"options_view",
			"delete_view",
			"slot_panel"
		}) do
			if not wid(id).hidden then
				wid(id):hide()

				return
			end
		end

		wid("quit_view"):show()
	end
end

function screen:mousepressed(x, y, button)
	self.window:mousepressed(x, y, button)
end

function screen:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function screen:handle_slot_button(slot_idx)
	if not storage:load_slot(slot_idx) then
		storage:create_slot(slot_idx)
	end

	storage:set_active_slot(slot_idx)
	self.done_callback({
		next_item_name = "map",
		slot_idx = slot_idx
	})
end

function screen:handle_credits_button(button)
	self.done_callback({
		next_item_name = "credits"
	})
end

function screen:handle_quit_button(button)
	self.done_callback({
		quit = true
	})
end

function screen:show_cloudsave_progress()
	wid("cloudsave_progress_view").hidden = false
end

function screen:hide_cloudsave_progress()
	wid("cloudsave_progress_view").hidden = true
end

function screen:show_cloudsave_error(error_code)
	wid("cloudsave_error_view").hidden = false
	wid("cloudsave_error_code_label").text = string.format("Error code: %s", error_code)
end

function screen:hide_cloudsave_error()
	wid("cloudsave_error_view").hidden = true
end

return screen
