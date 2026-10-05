-- chunkname: @./all/exoskeleton.lua
local log = require("lib.klua.log"):new("exoskeleton")
local ffi = require("ffi")
local FS = love.filesystem
local A = require("animation_db")
local EXO = {}

-- EXO3 二进制格式常量（见 scripts/compile_exoskeletons.lua）
local MAGIC = 0x334F5845
local FORMAT_VERSION = 1

EXO.exos = {}
EXO.exos_count = {}
EXO.db = {}
-- EXO.supported_extensions = {"exo3", "exo", "lua"}
EXO.base_path = KR_PATH_GAME .. "/data/exoskeletons"
EXO.exo_lists_to_load = {}

-- 持久化的 exo，永远不会卸载，避免重复加载卸载的开销
local persistent_exos = table.to_map({
	"ignis_altar_lava_golem",
	"ignis_altar_lvl4",
	"ignis_altar_decal",
	"ignis_altar_decal_lava",
	"tower_catapult_level_4Def",
	"tower_catapult_level_4_rockyDef",
	"tower_catapult_level_4_ballsDef",
	"archer4Def",
	"archer4_overborderDef",
	"archer4_torreDef",
	"archer4_torre_borderDef",
	"archer4_torre_pillarDef",
	"archerarrow2Def",
	"archerarrow3_hitDef",
	"archer_buffdecalDef",
	"archer_buffdecal_2Def",
	"archer_buffbirdDef",
	"archer_markbirdDef",
	"archer_markDef",
	"archer_ultbgDef",
	"wizard4Def",
	"wizard_scroll4Def",
	"wizard_shine4Def",
	"wizard_stars4Def",
	"wizard_tower4Def",
	"wizardbuffDef",
	"wizard4ultiDef"
})

--- director 调用，将资源列表加入 EXO.exo_lists_to_load 中，在进入对局时被加载
---@param exo_list any
function EXO:queue_load(exo_list)
	table.insert(self.exo_lists_to_load, exo_list)
end

--- 插件 exo 列表：exo_name -> {path = 相对 plugins 的目录}。
--- 支持由插件指明 exo 路径，统一并入 exo_lists_to_load，在进入对局时被加载。
---@param plugin_exo_list table
function EXO:queue_load_plugin(plugin_exo_list)
	if not plugin_exo_list then
		return
	end

	local exo_list = {}

	for exo_name, exo_info in pairs(plugin_exo_list) do
		exo_list[#exo_list + 1] = {
			name = exo_name,
			path = "plugins/" .. exo_info.path
		}
	end

	table.insert(self.exo_lists_to_load, exo_list)
end

--- 为了避免自引用，选择为 exo_frame 添加属性 exo_name，而不是直接让它引用 exo。因此，EXO 数据库需要暴露通过 exo_frame 查询 exo 的方法。
---@param exo_frame any
function EXO:get_exo_by_frame(exo_frame)
	return self.exos[exo_frame.exo_name]
end

--- 加载 exo 数据，在进入对局时，A:load()后调用
function EXO:load()
	-- perf.tmp_start("EXO:load")
	for _, exo_list in ipairs(self.exo_lists_to_load) do
		for _, entry in ipairs(exo_list) do
			local exo_name, exo_path

			if type(entry) == "table" then
				exo_name = entry.name
				exo_path = entry.path
			else
				exo_name = entry
			end

			if not self.exos[exo_name] then
				-- 优先加载编译后的 EXO3；缺失/损坏时回退到文本源
				local exo = self:load_packed(exo_name, exo_path) or self:load_lua(exo_name, exo_path or EXO.exo_path)

				local db_animation = A.db
				for _, animation in ipairs(exo.animations) do
					local name = exo.name .. "_" .. animation.name

					if not db_animation[name] then
						db_animation[name] = A.extract_frame_from({
							from = 1,
							to = #animation.frames,
							prefix = name
						})
					end

					local def = db_animation[name]
					def.exo = true

					for i = 1, def[1] do
						local frame = animation.frames[i]

						if frame then
							self.db[A:def_frame_name(def, i)] = frame
							frame.exo_name = exo.name
						end
					end

					-- exo 帧不经过 image_db，直接把 exo_frame 数组作为 link 缓存
					def.link = animation.frames
				end

				self.exos[exo_name] = exo
			end
			if not self.exos_count[exo_name] then
				self.exos_count[exo_name] = 0
			end
			self.exos_count[exo_name] = self.exos_count[exo_name] + 1
		end
	end

	-- A:dump()
	self.exo_lists_to_load = {}
-- perf.tmp_stop("EXO:load")
end

--- 卸载单个 exo，未加载过时安全跳过
---@param exo_name string
local function unload_exo(self, exo_name)
	if persistent_exos[exo_name] then
		return
	end

	local count = self.exos_count[exo_name]

	if not count then
		return
	end

	count = count - 1
	self.exos_count[exo_name] = count

	if count > 0 then
		return
	end

	local exo = self.exos[exo_name]

	if not exo then
		return
	end

	local db_animation = A.db

	for _, animation in ipairs(exo.animations) do
		local name = exo.name .. "_" .. animation.name
		local def = db_animation[name]

		if def then
			for i = 1, def[1] do
				self.db[A:def_frame_name(def, i)] = nil
			end
		end

		db_animation[name] = nil
	end

	self.exos[exo_name] = nil
end

--- 卸载 exo 数据，同时支持两种形状：
--- 本体数组 {exo_name, ...}（数字键，值为名字）与插件映射 {exo_name = {path = ...}}（字符串键）。
---@param exo_list table
function EXO:unload(exo_list)
	for k, v in pairs(exo_list) do
		if type(k) == "number" then
			unload_exo(self, v)
		else
			unload_exo(self, k)
		end
	end
end

local bytes4 = ffi.new("uint8_t[4]")

local function read_u16(s, p)
	local a, b = s:byte(p, p + 1)

	return a + b * 256, p + 2
end

local function read_u32(s, p)
	local a, b, c, d = s:byte(p, p + 3)

	return a + b * 256 + c * 65536 + d * 16777216, p + 4
end

-- 小端 float32；通过临时对齐缓冲 reinterpret，避免非对齐指针读取
local function read_f32(s, p)
	bytes4[0] = s:byte(p)
	bytes4[1] = s:byte(p + 1)
	bytes4[2] = s:byte(p + 2)
	bytes4[3] = s:byte(p + 3)

	return ffi.cast("float*", bytes4)[0], p + 4
end

--- 解析已解压的 payload，构建运行时 exo 结构：
--- parts/attach_idx 为普通 Lua 表；帧数据统一存放于 exo.floats（FFI float 数组），
--- 每帧为一个共享记录 {exo_name, base, count}，base 为 floats 中的起始下标（0 基）。
local function parse_payload(payload, exo_name)
	local p = 1
	local part_count, attach_count, anim_count, unique_frame_count, total_unique_entries
	part_count, p = read_u16(payload, p)
	attach_count, p = read_u16(payload, p)
	anim_count, p = read_u16(payload, p)
	unique_frame_count, p = read_u32(payload, p)
	total_unique_entries, p = read_u32(payload, p)

	local parts = {}

	for i = 1, part_count do
		local n
		n, p = read_u16(payload, p)

		local name = payload:sub(p, p + n - 1)
		p = p + n

		local ox, oy
		ox, p = read_f32(payload, p)
		oy, p = read_f32(payload, p)
		parts[i] = {name, ox, oy}
		parts[name] = parts[i]
	end

	local attach_points = {}
	local attach_idx = {}

	for i = 1, attach_count do
		local n
		n, p = read_u16(payload, p)

		local name = payload:sub(p, p + n - 1)
		p = p + n
		attach_points[i] = {name}
		attach_points[name] = attach_points[i]
		attach_idx[name] = i
	end

	local anims = {}

	for i = 1, anim_count do
		local n
		n, p = read_u16(payload, p)

		local name = payload:sub(p, p + n - 1)
		p = p + n

		local fcount
		fcount, p = read_u32(payload, p)

		local refs = {}

		for j = 1, fcount do
			refs[j], p = read_u32(payload, p)
		end

		anims[i] = {
			name = name,
			refs = refs
		}
	end

	local counts = {}
	local bases = {}
	local acc = 0

	for i = 1, unique_frame_count do
		local c
		c, p = read_u16(payload, p)
		counts[i] = c
		bases[i] = acc
		acc = acc + c
	end

	if acc ~= total_unique_entries then
		return nil, "entry 数量不一致"
	end

	local nfloats = total_unique_entries * 10

	if p - 1 + nfloats * 4 > #payload then
		return nil, "浮点数据越界"
	end

	local arr = ffi.new("float[?]", nfloats)
	ffi.copy(arr, ffi.cast("const uint8_t*", payload) + (p - 1), nfloats * 4)

	local records = {}

	for i = 1, unique_frame_count do
		records[i] = {
			exo_name = exo_name,
			base = bases[i] * 10,
			count = counts[i]
		}
	end

	local animations = {}

	for i, ar in ipairs(anims) do
		local frames = {}

		for j, ref in ipairs(ar.refs) do
			frames[j] = records[ref]
		end

		animations[i] = {
			name = ar.name,
			frames = frames
		}
	end

	return {
		name = exo_name,
		parts = parts,
		attach_points = attach_points,
		attach_idx = attach_idx,
		floats = arr,
		animations = animations
	}
end

--- 加载编译后的 EXO3 二进制；文件缺失或校验失败时返回 nil（由调用方回退到文本加载）
---@param exo_name string
---@param exo_path string|nil 自定义 exo 目录，缺省使用本体路径
function EXO:load_packed(exo_name, exo_path)
	local fn = (exo_path or EXO.base_path) .. "/" .. exo_name .. ".exo3"

	if not FS.isFile(fn) then
		return nil
	end

	local raw = FS.read(fn)

	if not raw or #raw < 12 then
		log.error("EXO3 文件读取失败: %s", fn)

		return nil
	end

	local magic = read_u32(raw, 1)
	local version = read_u16(raw, 5)
	local flags = raw:byte(7)
	local payload_size = read_u32(raw, 9)

	if magic ~= MAGIC or version ~= FORMAT_VERSION then
		log.error("EXO3 版本/魔数不匹配: %s", fn)

		return nil
	end

	local body = raw:sub(13)
	local payload = body

	if flags % 2 == 1 then
		payload = love.data.decompress("string", "zlib", body)
	end

	if #payload ~= payload_size then
		log.error("EXO3 数据长度不匹配: %s (%d ~= %d)", fn, #payload, payload_size)

		return nil
	end

	local exo, err = parse_payload(payload, exo_name)

	if not exo then
		log.error("EXO3 解析失败: %s (%s)", fn, tostring(err))

		return nil
	end

	return exo
end

local EMPTY_FRAME_ENTRY = {}

--- 把文本 v3 格式的一帧编码为 10*N 个 float32 的字节串（与 compile_exoskeletons.lua 一致），
--- 返回 (bytes, entry_count)。文本源（尤其插件）可能省略 alpha/kx/ky，此处补齐默认值：
--- alpha=1，kx=ky=0，避免渲染热路径因缺字段拿到 nil。
local function encode_text_frame(frame)
	local n = frame and #frame or 0
	local tmp = ffi.new("float[?]", n > 0 and n * 10 or 1)

	for i = 0, n - 1 do
		local e = frame[i + 1]

		if type(e) ~= "table" then
			e = EMPTY_FRAME_ENTRY
		end

		local b = i * 10

		tmp[b] = e[1] or 0
		tmp[b + 1] = e[2] or 0
		tmp[b + 2] = e[3] or 1
		tmp[b + 3] = e[4] or 0
		tmp[b + 4] = e[5] or 0
		tmp[b + 5] = e[6] or 1
		tmp[b + 6] = e[7] or 1
		tmp[b + 7] = e[8] or 0
		tmp[b + 8] = e[9] or 0
		tmp[b + 9] = e[10] or 0
	end

	return ffi.string(tmp, n * 40), n
end

--- 把文本 v3 的 exo 适配成与 parse_payload 完全相同的运行时结构：
--- parts/attach 建好名字索引；每帧一条共享记录 {exo_name, base, count}；帧数据汇总到 exo.floats。
--- 去重策略与编译器一致（按帧的 float 字节串去重），保证内存占用与打包路径相当。
local function adapt_text_exo(exo_name, exo)
	exo.name = exo_name
	exo.parts = exo.parts or {}
	exo.attach_points = exo.attach_points or {}
	exo.animations = exo.animations or {}
	exo.attach_idx = {}

	for _, v in ipairs(exo.parts) do
		exo.parts[v[1]] = v
	end

	for i, v in ipairs(exo.attach_points) do
		exo.attach_points[v[1]] = v
		exo.attach_idx[v[1]] = i
	end

	local unique = {}
	local dedup = {}
	local total_entries = 0

	for _, anim in ipairs(exo.animations) do
		local frames = anim.frames or {}
		local refs = {}

		for i = 1, #frames do
			local bytes, count = encode_text_frame(frames[i])
			local uidx = dedup[bytes]

			if not uidx then
				uidx = #unique + 1
				unique[uidx] = {
					bytes = bytes,
					count = count
				}
				dedup[bytes] = uidx
				total_entries = total_entries + count
			end

			refs[i] = uidx
		end

		anim.refs = refs
	end

	local nfloats = total_entries * 10
	local arr = ffi.new("float[?]", nfloats > 0 and nfloats or 1)

	local bases = {}
	local acc = 0

	for i = 1, #unique do
		local uf = unique[i]

		bases[i] = acc
		ffi.copy(arr + acc * 10, uf.bytes, uf.count * 40)
		acc = acc + uf.count
	end

	local records = {}

	for i = 1, #unique do
		records[i] = {
			exo_name = exo_name,
			base = bases[i] * 10,
			count = unique[i].count
		}
	end

	for _, anim in ipairs(exo.animations) do
		local frames = {}

		for j, ref in ipairs(anim.refs) do
			frames[j] = records[ref]
		end

		anim.frames = frames
	end

	exo.floats = arr
	exo._nfloats = nfloats

	return exo
end

--- 加载存放在 lua 文件中的 v3 格式的 exo 数据（缺失/损坏返回 nil）
function EXO:load_lua(exo_name, exo_path)
	local fn = (exo_path or EXO.base_path) .. "/" .. exo_name

	local f = FS.load(fn .. ".lua")

	if not f then
		log.error("EXO 文本源读取失败: %s.lua", fn)

		return nil
	end

	local ok, exo = pcall(f)

	if not ok or type(exo) ~= "table" then
		log.error("EXO 文本源执行失败: %s.lua (%s)", fn, tostring(exo))

		return nil
	end

	return adapt_text_exo(exo_name, exo)
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

--- 把 tracker 吸附到 target 的骨骼挂点上。
--- 读取 tracker.render.sprites[sprite_id] 的 track_sprite_id / track_attach_point，
--- 从 target 对应 sprite 的挂点世界坐标写回 tracker.pos。
--- KR6 引擎在渲染阶段自动做这件事，dove 未实现；脚本里每帧调用本方法即可。
--- 约定（调用者保证）：tracker / target 存在，且 target 对应 sprite 已完成渲染
--- （exo_frame 与 last_attach_point_xform 就绪）。
function EXO:track_attach_point(tracker, target, sprite_id)
	local sp = tracker.render.sprites[sprite_id]
	local ts = target.render.sprites[sp.track_sprite_id]
	local xf = ts.last_attach_point_xform[self.exos[ts.exo_frame.exo_name].attach_idx[sp.track_attach_point]]

	tracker.pos.x, tracker.pos.y = xf.x, xf.y

	sp.flip_x = ts.flip_x
end

--- 简短查看当前 EXO 的加载情况
function EXO:dump()
	local exo_names = ""
	for k, v in pairs(self.exos) do
		exo_names = exo_names .. k .. ", "
	end
	log.error("EXO:dump - currently loaded exos: %s", exo_names)
end

-- function EXO:load_groups(groups)
-- 	if not groups then
-- 		return
-- 	end

-- 	for _, g in pairs(groups) do
-- 		local exo_names = {}
-- 		local group_path = EXO.base_path .. "/" .. g

-- 		if FS.isDirectory(group_path) then
-- 			local items = FS.getDirectoryItems(group_path)

-- 			for i = 1, #items do
-- 				local item = items[i]

-- 				for _, ext in pairs(EXO.supported_extensions) do
-- 					local ext_s = "." .. ext .. "$"

-- 					if string.match(item, ext_s) then
-- 						local name = string.gsub(item, ext_s, "")

-- 						table.insert(exo_names, name)

-- 						break
-- 					end
-- 				end
-- 			end
-- 		end

-- 		EXO:load(exo_names, g, group_path)
-- 	end
-- end

-- function EXO:load_animations_to_animation_db(exo)
-- 	local db = A.db

-- 	for _, animation in ipairs(exo.animations) do
-- 		local name = exo.name .. "_" .. animation.name

-- 		if not db[name] then
-- 			db[name] = A.extract_frame_from({
-- 				from = 1,
-- 				to = #animation.frames,
-- 				prefix = name
-- 			})
-- 		end
-- 	end
-- end

-- function EXO:load_fake_sprites_to_db(exo)
-- 	for _, animation in ipairs(exo.animations) do
-- 		local ani_name = animation.name

-- 		for idx, frame in ipairs(animation.frames) do
-- 			local sprite_name = string.format("%s_%s_%04d", exo.name, ani_name, idx)

-- 			self.db[sprite_name] = frame
-- 			frame.exo_name = exo.name
-- 		end
-- 	end
-- end

return EXO
