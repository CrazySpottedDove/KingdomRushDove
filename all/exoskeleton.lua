-- chunkname: @./all/exoskeleton.lua
local log = require("klua.log"):new("exoskeleton")
local FS = love.filesystem
local A = require("animation_db")
local EXO = {}

EXO.exos = {}
EXO.exos_count = {}
EXO.db = {}
EXO.supported_extensions = {"exo3", "exo", "lua"}
EXO.base_path = KR_PATH_GAME .. "/data/exoskeletons"
EXO.exo_lists_to_load = {}

function EXO:load_kui(name)
	local exo = self:load_lua(name)

	exo.is_kui = true
	self.exos[name] = exo
	self.exos_count[name] = (self.exos_count[name] or 0) + 1

	self:load_fake_sprites_to_db(exo)

	local anis = {}
	local max_parts = 0

	for _, animation in ipairs(exo.animations) do
		local lname = exo.name .. "_" .. animation.name

		anis[lname] = {
			from = 1,
			to = #animation.frames,
			prefix = lname
		}

		for _, frame in ipairs(animation.frames) do
			max_parts = max_parts < #frame and #frame or max_parts
		end
	end

	return anis, max_parts
end

--- director 调用，将资源列表加入 EXO.exo_lists_to_load 中，在进入对局时被加载
---@param exo_list any
function EXO:queue_load(exo_list)
	table.insert(self.exo_lists_to_load, exo_list)
end

--- 为了避免自引用，选择为 exo_frame 添加属性 exo_name，而不是直接让它引用 exo。因此，EXO 数据库需要暴露通过 exo_frame 查询 exo 的方法。
---@param exo_frame any
function EXO:get_exo_by_frame(exo_frame)
	return self.exos[exo_frame.exo_name]
end

--- 加载 exo 数据，在进入对局时，A:load()后调用
function EXO:load()
	for _, exo_list in pairs(self.exo_lists_to_load) do
		for _, exo_name in ipairs(exo_list) do
			local exo = self:load_lua(exo_name, EXO.exo_path)

			self:load_fake_sprites_to_db(exo)
			self:load_animations_to_animation_db(exo)

			self.exos[exo_name] = exo
			self.exos_count[exo_name] = (self.exos_count[exo_name] or 0) + 1
		end
	end

	self.exo_lists_to_load = {}
end

function EXO:load_groups(groups)
	if not groups then
		return
	end

	for _, g in pairs(groups) do
		local exo_names = {}
		local group_path = EXO.base_path .. "/" .. g

		if FS.isDirectory(group_path) then
			local items = FS.getDirectoryItems(group_path)

			for i = 1, #items do
				local item = items[i]

				for _, ext in pairs(EXO.supported_extensions) do
					local ext_s = "." .. ext .. "$"

					if string.match(item, ext_s) then
						local name = string.gsub(item, ext_s, "")

						table.insert(exo_names, name)

						break
					end
				end
			end
		end

		EXO:load(exo_names, g, group_path)
	end
end

function EXO:unload(exo_name)
	local exo = self.exos[exo_name]

	if not exo then
		log.error("EXO:unload - could not find %s to unload", exo_name)

		return
	end

	self.exos_count[exo_name] = self.exos_count[exo_name] - 1

	if self.exos_count[exo_name] > 0 then
		log.debug("exo %s is still in use with count %s. keep loaded...", exo_name, self.exos_count[exo_name])

		return
	end

	if exo.is_kui and A.db then
		for _, animation in ipairs(exo.animations) do
			local name = exo.name .. "_" .. animation.name

			A.db[name] = nil
		end
	end

	for _, animation in ipairs(exo.animations) do
		local ani_name = animation.name

		for idx, frame in ipairs(animation.frames) do
			local sprite_name = string.format("%s_%s_%04d", exo.name, ani_name, idx)

			self.db[sprite_name] = nil
		end
	end

	self.exos[exo_name] = nil
end

function EXO:unload_group(group)
	for n, e in pairs(self.exos) do
		if e.group == group then
			self:unload(n)
		end
	end
end

function EXO:unload_all()
	for k, exo in pairs(self.exos) do
		if not exo.is_kui then
			self:unload(k)
		end
	end
end

function EXO:destroy()
	return
end

function EXO:load_lua(exo_name, exo_path)
	local function N(v)
		if v == nil or v == "" then
			return 0
		end

		return tonumber(v)
	end

	local function lines(str)
		local ci = 0

		return function()
			local l = ""
			local c = 0

			repeat
				ci = ci + 1
				c = string.sub(str, ci, ci)

				if c ~= "" and c ~= "\n" then
					l = l .. c
				end
			until c == "" or c == "\n"

			if l ~= "" then
				return l
			end
		end
	end

	local fn = (exo_path or EXO.base_path) .. "/" .. exo_name

	if FS.getInfo(fn .. ".lua") then
		local f = FS.load(fn .. ".lua")
		local exo = f()

		exo.name = exo_name
		-- if exo.animations[1].frames[1].parts then
		-- 	-- v1 format, need to convert to v3
		-- 	local ev3 = {}
		-- 	ev3.name = exo_name
		-- 	ev3.fps = exo.fps
		-- 	ev3.partScaleCompensation = exo.partScaleCompensation
		-- 	ev3.parts = {}
		-- 	ev3.parts_idx = {}
		-- 	local pt_idx = 1
		-- 	for k, p in pairs(exo.parts) do
		-- 		local pt = {p.name, p.offsetX, p.offsetY}
		-- 		ev3.parts[k] = pt
		-- 		ev3.parts[pt_idx] = pt
		-- 		ev3.parts_idx[k] = pt_idx
		-- 		pt_idx = pt_idx + 1
		-- 	end
		-- 	ev3.attach_points = {}
		-- 	ev3.attach_idx = {}
		-- 	ev3.animations = {}
		-- 	for _, a in pairs(exo.animations) do
		-- 		local ta = {}
		-- 		table.insert(ev3.animations, ta)
		-- 		ta.name = a.name
		-- 		ta.frames = {}
		-- 		for _, af in pairs(a.frames) do
		-- 			local tf = {}
		-- 			for _, ap in pairs(af.parts) do
		-- 				local part_idx = ev3.parts_idx[ap.name]
		-- 				local xf = ap.xform
		-- 				table.insert(tf, {1, part_idx, ap.alpha, xf.x, xf.y, xf.sx, xf.sy, xf.r, xf.kx, xf.ky})
		-- 			end
		-- 			if af.attachPoints then
		-- 				for _, aa in pairs(af.attachPoints) do
		-- 					if not ev3.attach_points[aa.name] then
		-- 						local ape = {aa.name}
		-- 						table.insert(ev3.attach_points, ape)
		-- 						ev3.attach_points[aa.name] = ape
		-- 						ev3.attach_idx[aa.name] = #ev3.attach_points
		-- 					end
		-- 					local attach_idx = ev3.attach_idx[aa.name]
		-- 					local xf = aa.xform
		-- 					table.insert(tf, {8, attach_idx, aa.alpha or 1, xf.x, xf.y, xf.sx, xf.sy, xf.r, xf.kx, xf.ky})
		-- 				end
		-- 			end
		-- 			table.insert(ta.frames, tf)
		-- 		end
		-- 	end
		-- 	return ev3
		-- else
		-- already v3 format
		-- 我们已经有了 v1 -> v3 的转换代码，因此在这里取消了检查 v1 格式的代码
		exo.attach_idx = {}

		for _, v in pairs(exo.parts) do
			exo.parts[v[1]] = v
		end

		for i, v in ipairs(exo.attach_points) do
			exo.attach_points[v[1]] = v
			exo.attach_idx[v[1]] = i
		end

		return exo
	-- end
	elseif FS.getInfo(fn .. ".exo") then
		local exo = {}

		exo.parts = {}
		exo.parts_idx = {}
		exo.animations = {}
		exo.attach_idx = {}
		exo.attach_points = {}

		local has_deltas = false
		local c_ani, c_f
		local c_p_idx = 0
		local c_t_idx = 0
		local keyframes = {}
		local pinst_idx = 0
		local f = FS.newFile(fn .. ".exo")
		local ts_start = love.timer.getTime()
		local fc = f:read()

		for l in lines(fc) do
			local sp = string.split_by_char(l, " ")

			if sp[1] == "has_deltas" then
				has_deltas = sp[2] == "1"
			elseif sp[1] == "pa" then
				local _, name, offsetX, offsetY = unpack(sp)

				exo.parts[name] = {name, N(offsetX), N(offsetY)}

				table.insert(exo.parts, exo.parts[name])

				c_p_idx = c_p_idx + 1
				exo.parts_idx[c_p_idx] = exo.parts[name]
			elseif sp[1] == "ta" then
				local _, name = unpack(sp)

				exo.attach_points[name] = {name}

				table.insert(exo.attach_points, exo.attach_points[name])

				c_t_idx = c_t_idx + 1
				exo.attach_points[c_t_idx] = exo.attach_points[name]
				exo.attach_idx[name] = c_t_idx
			elseif sp[1] == "a" then
				keyframes = {}
				c_ani = {
					name = sp[2],
					frames = {}
				}

				table.insert(exo.animations, c_ani)
			elseif sp[1] == "f" then
				c_f = {}
				pinst_idx = 0

				table.insert(c_ani.frames, c_f)
			elseif sp[1] == "P" or sp[1] == "p" then
				pinst_idx = pinst_idx + 1

				local c_p
				local alpha, x, y, sx, sy, r, kx, ky = N(sp[3]), N(sp[4]), N(sp[5]), N(sp[6]), N(sp[7]), N(sp[8]), N(sp[9]), N(sp[10])

				if has_deltas and sp[1] == "p" then
					local k = keyframes[pinst_idx]
					local px, py, psx, psy, pr, pkx, pky = k.x, k.y, k.sx, k.sy, k.r, k.kx, k.ky

					c_p = {2, N(sp[2]), k.alpha + alpha, px + x, py + y, psx + sx, psy + sy, pr + r, pkx + kx, pky + ky}
				else
					c_p = {1, N(sp[2]), N(sp[3]), x, y, sx, sy, r, kx, ky}
				end

				table.insert(c_f, c_p)
			elseif sp[1] == "T" then
				local c_a = {8, N(sp[2]), N(sp[3]), N(sp[4]), N(sp[5]), N(sp[6]), N(sp[7]), N(sp[8]), N(sp[9]), N(sp[10])}

				table.insert(c_f, c_a)
			elseif sp[1] == "t" then
				log.error("deltas for attach points not implemented yet")
			elseif sp[1] and sp[2] then
				exo[sp[1]] = sp[2]
			end
		end

		log.debug("EXO -- << finished v2 - time:%f ms - file: %s - ", (love.timer.getTime() - ts_start) * 1000, fn)

		exo.name = exo_name

		return exo
	else
		log.error("exoskeleton file not found for %s", fn)

		return
	end
end

function EXO:load_animations_to_animation_db(exo)
	local db = A.db

	for _, animation in ipairs(exo.animations) do
		local name = exo.name .. "_" .. animation.name

		db[name] = {
			from = 1,
			to = #animation.frames,
			prefix = name
		}

		A:generate_frames(db[name])
	end
end

function EXO:load_fake_sprites_to_db(exo)
	for _, animation in ipairs(exo.animations) do
		local ani_name = animation.name

		for idx, frame in ipairs(animation.frames) do
			local sprite_name = string.format("%s_%s_%04d", exo.name, ani_name, idx)

			self.db[sprite_name] = frame
			frame.exo_name = exo.name
		end
	end
end

function EXO:f(frame_name)
	local exo_frame = self.db[frame_name]

	if not exo_frame then
		log.error("Could not find exo_frame called: %s", frame_name)

		return nil
	end

	return exo_frame
end

function EXO:get_last_attach_point_xform(entity, sprite_id, name)
	local f = entity.render and entity.render.sprites[sprite_id]

	if not f then
		log.error("Could not find frame for sprite_id:%s in entity:%s (%s)", sprite_id, entity.id, entity.template_name)

		return
	end

	local exo_frame = f.exo_frame

	if not exo_frame then
		log.error("frame for sprite_id:%s in entity:%s (%s) does not have exo_frame", sprite_id, entity.id, entity.template_name)
	end

	local exo = self.exos[exo_frame.exo_name]

	local idx = exo.attach_idx[name]

	if not idx then
		log.error("Could not find attach point named %s in sprite_id:%s in entity:%s (%s)", name, sprite_id, entity.id, entity.template_name)

		return
	end

	return f and f.last_attach_point_xform and f.last_attach_point_xform[idx]
end

function EXO:get_last_attach_point_xform_kui(frame_name, attach_name)
end

function EXO:draw_frame_kui(name, scale_factor, red, green, blue, alpha)
end

function EXO:hide_parts_with_string(sprite, s)
	if not sprite then
		log.error("sprite missing")

		return
	end

	if sprite.exo_hide_prefix then
		if #sprite.exo_hide_prefix >= 8 then
			log.error("only a max of 8 exo hide patterns can be set")

			return
		end

		table.insert_mt(sprite.exo_hide_prefix, s)
	else
		sprite.exo_hide_prefix = {s}
	end
end

function EXO:show_parts_with_string(sprite, s)
	if not sprite then
		log.error("sprite missing")

		return
	end

	local t = sprite.exo_hide_prefix

	if not t then
		return
	end

	local mt = getmetatable(t)

	if mt and table.contains(mt, s) then
		local nt = {}

		for i = 1, #mt do
			if mt[i] ~= s then
				table.insert(nt, mt[i])
			end
		end

		sprite.exo_hide_prefix = nt
	else
		table.removeobject(t, s)
	end
end

function EXO:show_all_parts(sprite)
	if not sprite then
		log.error("sprite missing")

		return
	end

	if sprite.exo_hide_prefix then
		sprite.exo_hide_prefix = nil
	end
end

function EXO:is_hiding_parts_with_string(sprite, s)
	if not sprite then
		log.error("sprite missing")

		return
	end

	local t = sprite.exo_hide_prefix

	if not t then
		return false
	end

	local mt = getmetatable(t)

	if mt then
		return table.keyforobject(mt, s) ~= nil
	else
		return table.keyforobject(t, s) ~= nil
	end
end

return EXO
