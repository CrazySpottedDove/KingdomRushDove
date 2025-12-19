-- chunkname: @./all/shop_views.lua
local log = require("lib.klua.log"):new("shop_views")
local class = require("middleclass")
local signal = require("hump.signal")
local I = require("klove.image_db")
local S = require("sound_db")
local PS = require("platform_services")
local V = require("lib.klua.vector")
local v = V.v
local storage = require("storage")
local iap_data = require("data.iap_data")
local G = love.graphics
local IS_PHONE = KR_TARGET == "phone"
local IS_TABLET = KR_TARGET == "tablet"

GemsStoreView = class("GemsStoreView", KView)

function GemsStoreView:initialize(size)
	KView.initialize(self, size)

	self:ci("gems_store_close_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		self:hide()
	end
end

function GemsStoreView:show(no_title)
	if PS.services.iap then
		local status = PS.services.iap:get_sync_status()

		if not status.products then
			PS.services.iap:sync_products()
		end
	end

	GemsStoreItemView:reload(self:get_window())

	self:get_window():ci("modal_bg_transparent_view").hidden = false
	self:ci("gems_store_items_slider").pos.x = self:ci("gems_store_items_slider").drag_limits.pos.x
	self.hidden = false
	self.pos.y = -self.size.y

	local timer = self:get_window().timer

	if IS_PHONE then
		if self.timer_h then
			timer:cancel(self.timer_h)
		end

		self.timer_h = timer:tween(0.4, self.pos, {
			y = 0
		}, "out-back", nil, 0.8)
	else
		local v = self

		if v.timers then
			for _, t in pairs(v.timers) do
				timer:cancel(t)
			end
		end

		v.hidden = false
		v.alpha = 0
		v.pos.y = v.pos_hidden.y
		v.timers = {timer:tween(0.5, v, {
			alpha = 1
		}, "out-quad"), timer:tween(0.5, v.pos, {
			y = v.pos_shown.y
		}, "out-quad", function()
			v.timer = nil
		end)}
	end

	if IS_TABLET then
		self:ci("gems_store_title").hidden = no_title
	end
end

function GemsStoreView:hide()
	self:get_window():ci("modal_bg_transparent_view").hidden = true

	local timer = self:get_window().timer

	if IS_PHONE then
		if self.timer_h then
			timer:cancel(self.timer_h)
		end

		self.timer_h = timer:tween(0.3, self.pos, {
			y = -self.size.y
		}, "in-back", function()
			self.hidden = true
		end, 0.8)
	else
		local v = self

		if v.timers then
			for _, t in pairs(v.timers) do
				timer:cancel(t)
			end
		end

		v.timers = {timer:tween(0.3, v, {
			alpha = 0
		}, "in-quad"), timer:tween(0.3, v.pos, {
			y = v.pos_hidden.y
		}, "in-quad", function()
			v.hidden = true
			v.timer = nil
		end)}
	end
end

ShopView = class("ShopView", KView)

function ShopView:initialize(size)
	KView.initialize(self, size)

	self:ci("shop_buy_button").on_click = function(this)
		local v = self:ci("shop_items").selected_view
		local user_data = storage:load_slot()
		local timer = self:get_window().timer

		if v then
			if user_data.gems < v.price then
				if PS.services.iap and not PS.services.iap:is_premium() and not PS.services.fullads then
					signal.emit(SGN_SHOW_GEMS_STORE)
				else
					local arm = self:ci("shop_failure_arm")

					if arm.timer_h then
						timer:cancel(arm.timer_h)
					end

					arm.hidden = false
					arm.alpha = 1
					arm.timer_h = timer:tween(1.5, self:ci("shop_failure_arm"), {
						alpha = 0
					}, "in-expo", function()
						self:ci("shop_failure_arm").hidden = true
					end)

					local b = self:ci("shop_failure_balloon")

					if b.timer_h then
						timer:cancel(b.timer_h)
					end

					b.hidden = false
					b.alpha = 1
					b.timer_h = timer:tween(1.5, self:ci("shop_failure_balloon"), {
						alpha = 0
					}, "in-expo", function()
						self:ci("shop_failure_balloon").hidden = true
					end)
				end
			else
				S:queue("InAppBuyGems")
				v:buy()
			end
		end
	end
	self:ci("shop_help_view").on_click = function(this)
		local user_data = storage:load_slot()

		user_data.seen.shop_help = true

		storage:save_slot(user_data)

		this.hidden = true
	end
	self:ci("shop_done_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		self:hide()
	end

	if self:ci("shop_more_gems_button") then
		self:ci("shop_more_gems_button").hidden = not PS.services.iap or PS.services.iap:is_premium()
		self:ci("shop_more_gems_button").on_click = function(this)
			S:queue("GUIButtonCommon")
			signal.emit(SGN_SHOW_GEMS_STORE, true)
		end
	end
end

function ShopView:show(initial_item_name)
	local user_data = storage:load_slot()

	if not user_data.seen.shop_help or DBG_SHOW_BALLOONS then
		self:ci("shop_help_view").hidden = false
	end

	ShopBagItemView:load_all(self:ci("shop_bag_items").children)

	local item_idx = self:ci("shop_items").initial_item or 1
	local item

	if initial_item_name then
		for _, c in pairs(self:ci("shop_items").children) do
			if c.item_name == initial_item_name then
				item = c

				break
			end
		end
	end

	if item then
		item:select()
	else
		self:ci("shop_items").children[item_idx]:select()
	end

	signal.emit(SGN_SHOP_GEMS_CHANGED)
	signal.emit(SGN_SHOP_SHOWN)

	self.hidden = false

	local FADE_IN_TIME = IS_TABLET and 0.5 or 0.5
	local HIDDEN_Y = IS_TABLET and -self.size.y or -50

	if KR_TARGET == "tablet" or KR_TARGET == "desktop" then
		local timer = self:get_window().timer
		local ov = self:get_window():ci("modal_bg_shaded_view")

		if ov then
			if ov.timers then
				for _, h in pairs(ov.timers) do
					timer:cancel(h)
				end
			end

			ov.alpha = 0
			ov.hidden = false
			ov.timers = {timer:tween(FADE_IN_TIME, ov, {
				alpha = 1
			})}
		end

		if self.timers then
			for _, h in pairs(self.timers) do
				timer:cancel(h)
			end
		end

		self.pos.y = HIDDEN_Y
		self.alpha = 0
		self.timers = {timer:tween(FADE_IN_TIME, self, {
			alpha = 1
		}, "out-quad"), timer:tween(FADE_IN_TIME, self.pos, {
			y = 0
		}, "out-quad", function()
			self.timers = nil
		end)}
	end
end

function ShopView:hide()
	if KR_TARGET == "tablet" or KR_TARGET == "desktop" then
		local timer = self:get_window().timer
		local FADE_OUT_TIME = IS_TABLET and 0.3 or 0.3
		local HIDDEN_Y = IS_TABLET and -self.size.y or -50
		local ov = self:get_window():ci("modal_bg_shaded_view")

		if ov then
			if ov.timers then
				for _, h in pairs(ov.timers) do
					timer:cancel(h)
				end
			end

			ov.timers = {timer:tween(FADE_OUT_TIME, ov, {
				alpha = 0
			}, "linear", function()
				ov.hidden = true
			end)}
		end

		if self.timers then
			for _, h in pairs(self.timers) do
				timer:cancel(h)
			end
		end

		self.timers = {timer:tween(FADE_OUT_TIME, self, {
			alpha = 0
		}, "in-quad"), timer:tween(FADE_OUT_TIME, self.pos, {
			y = HIDDEN_Y
		}, "in-quad", function()
			self.hidden = true
			self.timers = nil

			signal.emit(SGN_SHOP_HIDDEN)
			signal.emit(SGN_SHOP_GEMS_CHANGED)
		end)}
	else
		self.hidden = true

		signal.emit(SGN_SHOP_HIDDEN)
		signal.emit(SGN_SHOP_GEMS_CHANGED)
	end
end

ShopItemView = class("ShopItemView", KView)
ShopItemView.static.instance_keys = {"id", "pos", "item_name"}
ShopItemView.static.init_arg_names = {"item_name"}

function ShopItemView:initialize(item_name)
	local sd = iap_data.shop_data[item_name]

	self.item_name = item_name
	self.item_idx = sd.item_idx
	self.price = sd.price

	local image = KImageView:new(string.format("inaps_Icons_%04i", self.item_idx))
	local glow = KImageView:new(string.format("inaps_IconsGlow_%04i", self.item_idx))

	KView.initialize(self, image.size)

	self.anchor.x, self.anchor.y = self.size.x * 0.5, self.size.y * 0.5

	if KR_TARGET == "phone" then
		self.pos.x, self.pos.y = self.pos.x + self.size.x * 0.5 + self.padding.x * -1, self.pos.y + self.size.y * 0.5 + self.padding.y * -1
	end

	glow.hidden = true
	glow.scale = V.v(1.8, 1.8)
	glow.pos.x, glow.pos.y = image.size.x * 0.5 * (1 - glow.scale.x), image.size.y * 0.5 * (1 - glow.scale.y)
	self.glow = glow

	if KR_TARGET == "tablet" or KR_TARGET == "desktop" then
		self.board_image = string.format("inaps_boardDrawings_%04i", self.item_idx)
	end

	self:add_child(glow)
	self:add_child(image)
	image:order_to_back()
	glow:order_to_back()
end

function ShopItemView:on_down(button, x, y)
	self.scale = V.v(0.95, 0.95)
end

function ShopItemView:on_up(button, x, y)
	self.scale = V.v(1, 1)
end

function ShopItemView:on_exit()
	self.scale = V.v(1, 1)
end

function ShopItemView:on_click(button, x, y)
	S:queue("GUIButtonCommon")
	self:select()
end

function ShopItemView:select()
	for _, v in pairs(self.parent.children) do
		v.glow.hidden = true
	end

	self.glow.hidden = false
	self:get_window():get_child_by_id("shop_items").selected_view = self
	self:get_window():get_child_by_id("shop_board_title").text = _(string.format("INAPP_NAME_%04i", self.item_idx))
	self:get_window():get_child_by_id("shop_board_desc").text = _(string.format("INAPP_DESCRIPTION_%04i", self.item_idx))
	self:get_window():get_child_by_id("shop_board_price").text = self.price

	if self.board_image then
		self:get_window():get_child_by_id("shop_board_image"):set_image(self.board_image)
	end
end

function ShopItemView:buy()
	local ud = storage:load_slot()

	if ud.gems < self.price then
		log.debug("Price exceeds available gems")

		return 
	end

	if not ud.bag[self.item_name] then
		ud.bag[self.item_name] = 0
	end

	ud.bag[self.item_name] = ud.bag[self.item_name] + 1
	ud.gems = ud.gems - self.price

	storage:save_slot(ud, nil, true)
	signal.emit(SGN_SHOP_GEMS_CHANGED)
	ShopBagItemView:load_all(self:get_window():get_child_by_id("shop_bag_items").children)

	for _, v in pairs(self:get_window():get_child_by_id("shop_bag_items").children) do
		if v.item_name == self.item_name then
			v:buy_fx()
		end
	end

	local timer = self:get_window().timer
	local b = self:get_window():get_child_by_id("shop_success_balloon")

	b.hidden = false
	b.alpha = 1

	if b.timer_h then
		timer:cancel(b.timer_h)
	end

	b.timer_h = timer:tween(1.5, b, {
		alpha = 0
	}, "in-expo", function()
		b.hidden = true
	end)
end

ShopBagItemView = class("ShopBagItemView", KImageView)

function ShopBagItemView.static:load_all(items)
	local user_data = storage:load_slot()
	local bag = user_data.bag

	for _, v in pairs(items) do
		if v:isInstanceOf(ShopBagItemView) then
			if bag[v.item_name] and bag[v.item_name] > 0 then
				v.hidden = false
				v:get_child_by_id("bag_item_qty").text = bag[v.item_name]
			else
				v.hidden = true
			end
		end
	end
end

function ShopBagItemView:buy_fx()
	if not self.scale then
		self.scale = V.v(1, 1)
	end

	self:get_window().timer:tween(0.2, self.scale, {
		x = 1
	}, "out-back")

	local p = BuyFxParticlesView:new("inaps_gemParticle_0001", 1)

	if KR_TARGET == "phone" then
		p.pos.x, p.pos.y = self.pos.x + self.size.x * 0.5, self.pos.y + self.size.y * 0.5
	else
		p.pos.x, p.pos.y = self.pos.x, self.pos.y
	end

	self.parent:add_child(p)
end

GemsStoreItemView = class("GemsStoreItemView", KImageView)
GemsStoreItemView.static.instance_keys = {"id", "pos", "item_name", "item_image"}
GemsStoreItemView.static.init_arg_names = {"size", "item_name", "item_image"}

function GemsStoreItemView.static:reload(window)
	for _, v in pairs(window:get_child_by_id("gems_store_items_slider").children) do
		if v:isInstanceOf(GemsStoreItemView) then
			v:load()
		end
	end
end

function GemsStoreItemView:initialize(size, item_name, item_image)
	KImageView.initialize(self, size)

	self.item_name = item_name
	self.item_image = item_image
	self:ci("play_button").on_click = function()
		S:queue("GUIButtonCommon")
		self:play_ad()
	end
	self:ci("buy_button").on_click = function()
		S:queue("GUIButtonCommon")
		self:buy_iap()
	end

	self:ci("image"):set_image(item_image)

	self:ci("title").text = _("MAP_INAPP_" .. string.upper(item_name))

	local mp = self:ci("most_popular")
	local bv = self:ci("best_value")

	if mp then
		mp.hidden = item_name ~= "gem_pack_chest"
	end

	if bv then
		bv.hidden = item_name ~= "gem_pack_vault"
	end

	self:load()
end

function GemsStoreItemView:load()
	local product = PS.services.iap and PS.services.iap:get_product(self.item_name) or {}

	self:ci("reward").text = product.reward or ""

	if product.play_ad then
		self:ci("play_button").hidden = false
		self:ci("buy_button").hidden = true
	else
		self:ci("play_button").hidden = true
		self:ci("buy_button").hidden = false
		self:ci("buy_button").text = product.price or "?"
	end
end

function GemsStoreItemView:play_ad()
	local product = PS.services.iap and PS.services.iap:get_product(self.item_name)

	if not product or not product.play_ad or not product.gems then
		log.error("Item product for %s not found or not gems.", self.item_name)

		return 
	end

	if not PS.services.ads then
	-- block empty
	else
		local provider = PS.services.ads:get_provider_with_video_ad()

		if not provider then
			PS.services.ads:cache_video_ad()
		elseif not PS.services.ads:show_video_ad(provider, {
			rewards = {
				gems = product.reward
			}
		}, AD_TYPE_REWARDED) then
		-- block empty
		else
			signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)

			return 
		end
	end

	signal.emit(SGN_SHOP_SHOW_MESSAGE, "reward_error")
	log.error("Error tying to play video ad for product %s", self.item_name)
end

function GemsStoreItemView:buy_iap()
	if not PS.services.iap or not PS.services.iap:purchase_product(self.item_name) then
		signal.emit(SGN_SHOP_SHOW_MESSAGE, "iap_error")
		log.error("Error trying to purchase product %s", self.item_name)

		return 
	end

	signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)
end

MessageView = class("MessageView", KView)
MessageView.static.instance_keys = {"id", "pos"}

function MessageView:initialize(size)
	KView.initialize(self, size)

	self:ci("message_view_close_button").on_click = function(this)
		S:queue("GUIButtonCommon")
		self:hide()

		if self.callback then
			self.callback()
		end
	end
end

function MessageView:show(kind, arg)
	local function wid(name)
		return self:ci(name)
	end

	local PS = require("platform_services")

	self.callback = nil

	if kind == "reward" then
		wid("message_view_label").text = string.format(_("ADS_REWARD_EARNED"), arg)
	elseif kind == "reward_error" then
		wid("message_view_label").text = _("ADS_NO_REWARD_VIDEO_AVAILABLE")

		if arg and arg.callback then
			self.callback = arg.callback
		end
	elseif kind == "iap_error" then
		local service_name = PS.services.iap and PS.services.iap.SRV_DISPLAY_NAME or "Store"

		wid("message_view_label").text = string.format(string.gsub(_("IAP_CONNECTION_ERROR"), "@", "s"), service_name)
	elseif kind == "channel_quit_game" then
		if arg and arg ~= "" then
			__, title, content = unpack(string.split(arg, "|"))
			wid("message_view_label").text = title .. "\n" .. content
		end

		if PS.services.channel then
			wid("message_view_close_button").on_click = function(this)
				S:queue("GUIButtonCommon")
				PS.services.channel:quit_game()
			end
		end
	else
		log.error("show_message called with unknown kind. skipping")

		return 
	end

	self.hidden = false
end

function MessageView:hide()
	self.hidden = true
end

IapProgressView = class("IapProgressView", KView)
IapProgressView.static.instance_keys = {"id", "pos"}

function IapProgressView:update(dt)
	local v = self:ci("iap_progress_spinner")

	v.r = v.r - dt * math.pi
end

BuyFxParticlesView = class("BuyFxParticlesView", KView)

function BuyFxParticlesView:initialize(particle_image, max_scale)
	KView.initialize(self)

	local ss = I:s(particle_image)
	local p_scale = ss.ref_scale or 1
	local c = G.newCanvas(ss.size[1], ss.size[2])

	G.setCanvas(c)
	G.draw(I:i(ss.atlas), ss.quad)
	G.setCanvas()

	local ps = G.newParticleSystem(c, 500)

	ps:setDirection(0)
	ps:setSpread(2 * math.pi)
	ps:setSizes(0.2 * p_scale, (max_scale or 2) * p_scale)
	ps:setParticleLifetime(0, 0.75)
	ps:setRotation(-math.pi, math.pi)
	ps:setSpeed(100, 200)
	ps:setRadialAcceleration(-200)
	ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	ps:emit(20)

	self.particle_system = ps
	self.ts = love.timer.getTime()
end

function BuyFxParticlesView:update(dt)
	if love.timer.getTime() - self.ts > 1 then
		self.parent:remove_child(self)

		return 
	end

	self.particle_system:update(dt)
end

function BuyFxParticlesView:draw()
	G.draw(self.particle_system, self.size.x * 0.5, self.size.y * 0.5)
end
