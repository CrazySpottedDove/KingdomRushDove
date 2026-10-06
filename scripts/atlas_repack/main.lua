-- scripts/atlas_repack/main.lua
-- 批量图集重打包（以 .images/<page>.png 为像素源）：
--   1) 去 mipmap（重打包/重编码时 -nomips；无源可改的页做无损 mip 剥离）
--   2) 允许非常规尺寸：对每页取「当前 / 包围盒裁剪 / 重新排布打包」中面积最小者
--      - 裁剪：只裁右/下（保留左上 health-bar 块），DDS 按 BC 块无损裁剪
--      - 重排：用 atlas_binpack 重新装箱，帧像素取自 PNG（无损），PNG->DDS 单次编码
--   3) 尽量以 PNG 为源，避免 dds->dds；无 PNG 的页不做重排
--
-- 用法（WSL）：
--   love scripts/atlas_repack                 # 只报告
--   love scripts/atlas_repack --apply         # 执行（先备份 .images + 图集描述）
--   love scripts/atlas_repack --apply --only=<page> [--no-backup]
--   love scripts/atlas_repack --repack-dds    # 无 PNG 的页也重排（需 GPU 解码 DDS，dds->dds）

local ROOT = os.getenv("KR_ROOT") or "."

local opts = {
	apply = false,
	backup = true,
	nv = "nvcompress.exe",
	repack_dds = false,
	gen_png = false
}
local function parse_args(...)
	local lists = {...}
	for _, a in ipairs(lists) do
		if type(a) == "table" then
			for _, x in ipairs(a) do
				if type(x) == "string" then
					if x == "--apply" then
						opts.apply = true
					elseif x == "--no-backup" then
						opts.backup = false
					elseif x == "--repack-dds" then
						opts.repack_dds = true
					elseif x == "--gen-png" then
						opts.gen_png = true
					elseif x:match("^%-%-only=") then
						opts.only = x:match("=(.+)$")
					elseif x:match("^%-%-limit=") then
						opts.limit = tonumber(x:match("=(%d+)$"))
					elseif x:match("^%-%-root=") then
						ROOT = x:match("=(.+)$")
					elseif x:match("^%-%-nv=") then
						opts.nv = x:match("=(.+)$")
					end
				end
			end
		end
	end
end

local ATLAS_DIR, IMG_DIR, BACKUP_DIR, atlas_util, binpack, G

local function resolve_root()
	if ROOT ~= "." then
		return ROOT
	end
	local f = io.open("dove_modules/atlas_manager/atlas_util.lua", "rb")
	if f then
		f:close()
		return "."
	end
	local ok, src = pcall(love.filesystem.getSource)
	if ok and type(src) == "string" then
		local r = src:match("^(.-)/scripts/atlas_repack/?$")
		if r then
			return r
		end
	end
	return "."
end

-- ---------- 基础 IO ----------
local function read_all(path)
	local f = io.open(path, "rb")
	if not f then
		return nil
	end
	local d = f:read("*all")
	f:close()
	return d
end
local function write_all(path, data)
	local f = io.open(path, "wb")
	if not f then
		return nil, "open failed"
	end
	f:write(data)
	f:close()
	return true
end
local function file_exists(path)
	local f = io.open(path, "rb")
	if f then
		f:close()
		return true
	end
	return false
end
local function list_lua(dir)
	local out = {}
	local h = io.popen('ls "' .. dir .. '"/*.lua 2>/dev/null')
	if h then
		for l in h:lines() do
			out[#out + 1] = l
		end
		h:close()
	end
	table.sort(out)
	return out
end
local function align4(v)
	return math.ceil(v / 4) * 4
end

local REPACK_CAP = 16384

local function dds_info(path)
	local d = read_all(path)
	if not d or #d < 128 or d:sub(1, 4) ~= "DDS " then
		return nil
	end
	local function u32(off)
		return string.byte(d, off + 1) + string.byte(d, off + 2) * 256 + string.byte(d, off + 3) * 65536 + string.byte(d, off + 4) * 16777216
	end
	return {
		w = u32(16),
		h = u32(12),
		flags = u32(8),
		mip = u32(28),
		fourcc = d:sub(85, 88),
		dxgi = (d:sub(85, 88) == "DX10") and u32(128) or nil,
		size = #d
	}
end
local function png_dims(path)
	local f = io.open(path, "rb")
	if not f then
		return nil
	end
	local d = f:read(24)
	f:close()
	if not d or #d < 24 or d:sub(1, 8) ~= "\137PNG\r\n\26\n" then
		return nil
	end
	local function u32be(off)
		return string.byte(d, off + 1) * 16777216 + string.byte(d, off + 2) * 65536 + string.byte(d, off + 3) * 256 + string.byte(d, off + 4)
	end
	return u32be(16), u32be(20)
end
local function bc_bytes_per_block(info)
	if info.fourcc == "DXT1" then
		return 8
	elseif info.fourcc == "DXT3" or info.fourcc == "DXT5" then
		return 16
	elseif info.fourcc == "ATI2" or info.fourcc == "BC5" or info.fourcc == "BC4" then
		return info.fourcc == "BC4" and 8 or 16
	elseif info.fourcc == "DX10" then
		local f = info.dxgi
		if f == 71 or f == 80 then
			return 8
		end
		return 16
	end
	return nil
end

-- 无损剥离 mip
local function strip_dds_mips(path)
	local info = dds_info(path)
	if not info then
		return false, "not a dds"
	end
	if info.mip <= 1 then
		return false, "no mips"
	end
	local bpb = bc_bytes_per_block(info)
	if not bpb then
		return false, "unsupported fourcc " .. tostring(info.fourcc)
	end
	local d = read_all(path)
	local hdr = (info.fourcc == "DX10") and 148 or 128
	local base = math.ceil(info.w / 4) * math.ceil(info.h / 4) * bpb
	if #d < hdr + base then
		return false, "truncated"
	end
	local out = {d:sub(1, hdr + base)}
	local function patch_u32(off, val)
		out[1] = out[1]:sub(1, off) .. string.char(val % 256, math.floor(val / 256) % 256, math.floor(val / 65536) % 256, math.floor(val / 16777216) % 256) .. out[1]:sub(off + 5)
	end
	local flags = info.flags
	if flags % 0x40000 >= 0x20000 then
		flags = flags - 0x20000
	end
	patch_u32(8, flags)
	patch_u32(28, 1)
	return write_all(path, out[1])
end

-- 无损裁剪 DDS base（按 BC 块复制 [0,nw)x[0,nh)）
local function crop_dds_blocks(path, nw, nh)
	local info = dds_info(path)
	if not info then
		return false, "not a dds"
	end
	local bpb = bc_bytes_per_block(info)
	if not bpb then
		return false, "unsupported fourcc " .. tostring(info.fourcc)
	end
	if nw >= info.w and nh >= info.h then
		return false, "no crop"
	end
	local d = read_all(path)
	local hdr = (info.fourcc == "DX10") and 148 or 128
	local old_cols = math.ceil(info.w / 4)
	local new_cols = math.ceil(nw / 4)
	local new_rows = math.ceil(nh / 4)
	local old_base = old_cols * math.ceil(info.h / 4) * bpb
	if #d < hdr + old_base then
		return false, "truncated"
	end
	local rowbytes = new_cols * bpb
	local parts = {d:sub(1, hdr)}
	for r = 0, new_rows - 1 do
		local off = hdr + (r * old_cols) * bpb
		parts[#parts + 1] = d:sub(off + 1, off + rowbytes)
	end
	local head = table.concat(parts)
	local function setu32(s, off, val)
		return s:sub(1, off) .. string.char(val % 256, math.floor(val / 256) % 256, math.floor(val / 65536) % 256, math.floor(val / 16777216) % 256) .. s:sub(off + 5)
	end
	head = setu32(head, 12, nh)
	head = setu32(head, 16, nw)
	head = setu32(head, 20, new_cols * new_rows * bpb)
	local flags = info.flags
	if flags % 0x40000 >= 0x20000 then
		flags = flags - 0x20000
	end
	head = setu32(head, 8, flags)
	head = setu32(head, 28, 1)
	return write_all(path, head)
end

local function encode_png(idata)
	local png = idata:encode("png")
	if png.getString then
		png = png:getString()
	end
	return png
end
local function crop_png_origin(src_path, w, h)
	local blob = read_all(src_path)
	if not blob then
		return nil, "read png failed"
	end
	local ok, src = pcall(love.image.newImageData, love.data.newByteData(blob))
	if not ok or not src then
		return nil, "decode png failed"
	end
	local cw = math.min(w, src:getWidth())
	local chh = math.min(h, src:getHeight())
	local out = love.image.newImageData(cw, chh)
	out:paste(src, 0, 0, 0, 0, cw, chh)
	return out
end
local function load_idata(path)
	local blob = read_all(path)
	if not blob then
		return nil
	end
	local ok, id = pcall(love.image.newImageData, love.data.newByteData(blob))
	return ok and id or nil
end
local function decode_dds_idata(path)
	if not G then
		return nil, "no graphics"
	end
	local blob = read_all(path)
	if not blob then
		return nil, "read dds failed"
	end
	local ok, cd = pcall(love.image.newCompressedData, love.filesystem.newFileData(blob, path:match("([^/]+)$")))
	if not ok or not cd then
		return nil, "compressed data failed"
	end
	local ok2, img = pcall(G.newImage, cd)
	if not ok2 or not img then
		return nil, "newImage failed"
	end
	local w, h = img:getDimensions()
	local c = G.newCanvas(w, h)
	G.setCanvas(c)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("replace", "premultiplied")
	G.draw(img, 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	local id = c:newImageData()
	c:release()
	img:release()
	id:mapPixel(function(_, _, r, g, b, a)
		if a == 0 then
			return 0, 0, 0, 0
		end
		return r, g, b, a
	end)
	return id
end
local function run_nvcompress(png, dds)
	local cmd = string.format('%s -bc3 -highest -nomips -silent "%s" "%s"', opts.nv, png, dds)
	local r = os.execute(cmd)
	return ((r == 0) or (r == true)), cmd
end

-- 用 binpack 找最小非 2 幂页，返回 w,h,placements
local function optimize_repack(frames)
	local area = 0
	local maxw, maxh = 0, 0
	for _, f in ipairs(frames) do
		area = area + f.w * f.h
		if f.w > maxw then
			maxw = f.w
		end
		if f.h > maxh then
			maxh = f.h
		end
	end
	local s = align4(math.ceil(math.sqrt(area)))
	if s < maxw then
		s = align4(maxw)
	end
	if s < maxh then
		s = align4(maxh)
	end
	for iter = 1, 60 do
		if s > REPACK_CAP then
			return nil
		end
		local pl = binpack.pack(frames, s, s)
		if pl then
			local bw, bh = 0, 0
			for _, p in ipairs(pl) do
				if p.x + p.w > bw then
					bw = p.x + p.w
				end
				if p.y + p.h > bh then
					bh = p.y + p.h
				end
			end
			bw, bh = align4(bw), align4(bh)
			local hbw = math.ceil(bw / 1024) + 1
			local hbh = math.ceil(bh / 1024) + 1
			if bw < hbw then
				bw = hbw
			end
			if bh < hbh then
				bh = hbh
			end
			local pl2 = binpack.pack(frames, bw, bh)
			if pl2 then
				return bw, bh, pl2
			end
			s = align4(math.max(bw, bh)) + (iter % 2 == 0 and 4 or 0)
		else
			s = align4(math.ceil(s * 1.12))
		end
	end
	return nil
end

local function main()
	parse_args(arg, love.arg, _cmdline)
	ROOT = resolve_root()
	ATLAS_DIR = ROOT .. "/_assets/kr1-desktop/images/fullhd"
	IMG_DIR = ROOT .. "/.images"
	BACKUP_DIR = ROOT .. "/.images_backup"
	package.loaded["lib.klove.atlas_binary"] = dofile(ROOT .. "/lib/klove/atlas_binary.lua")
	atlas_util = dofile(ROOT .. "/dove_modules/atlas_manager/atlas_util.lua")
	binpack = dofile(ROOT .. "/dove_modules/atlas_manager/atlas_binpack.lua")
	G = love.graphics

	local groups, group_order = {}, {}
	for _, path in ipairs(list_lua(ATLAS_DIR)) do
		local gname = path:match("([^/]+)%.lua$")
		local chunk = loadfile(path)
		if chunk then
			local ok, tbl = pcall(chunk)
			if ok and type(tbl) == "table" then
				groups[gname] = tbl
				group_order[#group_order + 1] = gname
			end
		end
	end

	local page_frames, page_order = {}, {}
	for _, gname in ipairs(group_order) do
		for k, v in pairs(groups[gname]) do
			local page = v.a_name
			if page then
				if not page_frames[page] then
					page_frames[page] = {}
					page_order[#page_order + 1] = page
				end
				page_frames[page][#page_frames[page] + 1] = {
					g = gname,
					k = k,
					f = v
				}
			end
		end
	end
	table.sort(page_order)

	-- ---- 可选：为缺失 PNG 源的 DDS 生成 PNG（GPU 解码；a==0 的 RGB 清零）----
	if opts.gen_png then
		local gen, skip = 0, 0
		for _, page in ipairs(page_order) do
			local key = page:gsub("%.[^%.]+$", "")
			if (not opts.only) or page:find(opts.only, 1, true) or key:find(opts.only, 1, true) then
				local png_path = IMG_DIR .. "/" .. key .. ".png"
				if not file_exists(png_path) then
					local idata, err = decode_dds_idata(ATLAS_DIR .. "/" .. page)
					if idata then
						write_all(png_path, encode_png(idata))
						gen = gen + 1
						print(string.format("[gen-png] %s (%dx%d)", key, idata:getWidth(), idata:getHeight()))
					else
						skip = skip + 1
						print(string.format("[gen-png-skip] %s: %s", key, tostring(err)))
					end
				end
			end
		end
		print(string.format("[gen-png] 生成 %d 个 PNG，跳过 %d 个", gen, skip))
	end

	-- ---- 构建计划 ----
	local plan = {}
	local only, limit = opts.only, opts.limit
	for _, page in ipairs(page_order) do
		local key = page:gsub("%.[^%.]+$", "")
		if (not only) or page:find(only, 1, true) or key:find(only, 1, true) then
			local dds_path = ATLAS_DIR .. "/" .. page
			local info = dds_info(dds_path)
			if info then
				local png_path = IMG_DIR .. "/" .. key .. ".png"
				local pw, ph = png_dims(png_path)
				local png_ok = (pw and ph and pw == info.w and ph == info.h)
				local frames = page_frames[page]
				-- physical frames
				local phys, key2rec = {}, {}
				local bw, bh = 0, 0
				local ok_phys = true
				for i, rec in ipairs(frames) do
					local v = rec.f
					local q = v.f_quad
					local aw = v.a_size and v.a_size[1]
					local ah = v.a_size and v.a_size[2]
					if q and aw and aw > 0 and ah and ah > 0 then
						local kx = info.w / aw
						local ky = info.h / ah
						local uniq = rec.g .. "\1" .. rec.k
						phys[#phys + 1] = {
							w = math.max(1, math.floor(q[3] * kx + 0.5)),
							h = math.max(1, math.floor(q[4] * ky + 0.5)),
							frame_name = uniq
						}
						key2rec[uniq] = rec
						bw = math.max(bw, (q[1] + q[3]) * kx)
						bh = math.max(bh, (q[2] + q[4]) * ky)
					else
						ok_phys = false
						break
					end
				end
				local entry = {
					page = page,
					key = key,
					dds = info,
					dds_path = dds_path,
					png_path = png_path,
					png_ok = png_ok,
					frames = frames,
					key2rec = key2rec,
					phys = phys
				}
				local cur = info.w * info.h
				-- crop
				if ok_phys and bw > 0 and bh > 0 then
					local cnw = align4(math.ceil(bw))
					local cnh = align4(math.ceil(bh))
					cnw = math.max(cnw, math.ceil(cnw / 1024) + 1)
					cnh = math.max(cnh, math.ceil(cnh / 1024) + 1)
					entry.cnw = math.min(cnw, info.w)
					entry.cnh = math.min(cnh, info.h)
					entry.crop_area = entry.cnw * entry.cnh
				end
				-- repack（有 PNG 或有 --repack-dds）
				if ok_phys and #phys > 0 and (png_ok or opts.repack_dds) then
					local rw, rh, pl = optimize_repack(phys)
					if rw and rw * rh < cur then
						entry.rw, entry.rh, entry.rpl = rw, rh, pl
						entry.repack_area = rw * rh
					end
				end
				-- 选最小
				entry.cur_area = cur
				local best = cur
				if entry.crop_area and entry.crop_area < best then
					best = entry.crop_area
				end
				if entry.repack_area and entry.repack_area < best then
					best = entry.repack_area
				end
				if entry.repack_area and entry.repack_area == best then
					entry.mode = "repack"
				elseif entry.crop_area and entry.crop_area == best and entry.crop_area < cur then
					entry.mode = "crop"
				else
					entry.mode = (info.mip > 1) and "strip" or "none"
				end
				plan[#plan + 1] = entry
				if limit and #plan >= limit then
					break
				end
			end
		end
	end

	-- ---- 统计 ----
	local old, new = 0, 0
	local n_crop, n_repack, n_strip, n_none = 0, 0, 0, 0
	local savings = {}
	for _, e in ipairs(plan) do
		old = old + e.cur_area
		local na = e.cur_area
		if e.mode == "repack" then
			na = e.repack_area
			n_repack = n_repack + 1
		elseif e.mode == "crop" then
			na = e.crop_area
			n_crop = n_crop + 1
		elseif e.mode == "strip" then
			n_strip = n_strip + 1
		else
			n_none = n_none + 1
		end
		new = new + na
		if na < e.cur_area then
			savings[#savings + 1] = {
				key = e.key,
				old = string.format("%dx%d", e.dds.w, e.dds.h),
				new = string.format("%s", e.mode == "repack" and (e.rw .. "x" .. e.rh) or (e.cnw .. "x" .. e.cnh)),
				saved = e.cur_area - na,
				mode = e.mode,
				png = e.png_ok
			}
		end
	end
	table.sort(savings, function(a, b)
		return a.saved > b.saved
	end)

	print("================ atlas_repack 报告 ================")
	print(string.format("项目根目录: %s", ROOT))
	print(string.format("图集组: %d   扫描页: %d", #group_order, #plan))
	print(string.format("重排: %d   裁剪: %d   仅剥mip: %d   无操作: %d", n_repack, n_crop, n_strip, n_none))
	print(string.format("页面积: %.1f Mpx -> %.1f Mpx  (%.1f%%)", old / 1e6, new / 1e6, 100 * new / old))
	print("-- 收益 TOP 20 --")
	for i = 1, math.min(20, #savings) do
		local s = savings[i]
		print(string.format("  %-40s %-11s -> %-11s -%.2fMpx  [%s] PNG=%s", s.key, s.old, s.new, s.saved / 1e6, s.mode, tostring(s.png)))
	end
	print("===================================================")

	if not opts.apply then
		print("[dry-run] 未写任何文件。加 --apply 执行。")
		love.event.quit()
		return
	end

	-- ---- 备份 ----
	if opts.backup then
		local ts = os.date("%Y%m%d_%H%M%S")
		local dst = BACKUP_DIR .. "/" .. ts .. "_pre_repack"
		os.execute('mkdir -p "' .. BACKUP_DIR .. '"')
		print("[backup] .images -> " .. dst)
		local r = os.execute('cp -a --reflink=auto "' .. IMG_DIR .. '" "' .. dst .. '"')
		if not ((r == 0) or (r == true)) then
			print("[backup] 失败，中止。")
			love.event.quit()
			return
		end
		local atl_dst = dst .. "_atlas_data"
		os.execute('mkdir -p "' .. atl_dst .. '"')
		os.execute('cp -a "' .. ATLAS_DIR .. '"/*.lua "' .. atl_dst .. '"/ 2>/dev/null')
		os.execute('cp -a "' .. ATLAS_DIR .. '"/*.bin "' .. atl_dst .. '"/ 2>/dev/null')
		os.execute('cp -a "' .. ATLAS_DIR .. '"/*.abin "' .. atl_dst .. '"/ 2>/dev/null')
		print("[backup] atlas data -> " .. atl_dst)
	end

	-- ---- 执行 ----
	local dirty = {}
	local fail = {}
	local done_crop, done_repack, done_strip = 0, 0, 0
	for _, e in ipairs(plan) do
		if e.mode == "repack" then
			local src = e.png_ok and load_idata(e.png_path) or decode_dds_idata(e.dds_path)
			if not src then
				fail[#fail + 1] = e.key
				print("[repack-skip] " .. e.key)
			else
				local all_frames = {}
				local okcrop = true
				for _, p in ipairs(e.rpl) do
					local rec = e.key2rec[p.frame_name]
					local v = rec.f
					local kx = e.dds.w / v.a_size[1]
					local ky = e.dds.h / v.a_size[2]
					local idx = atlas_util.crop_idata(src, math.floor(v.f_quad[1] * kx + 0.5), math.floor(v.f_quad[2] * ky + 0.5), p.w, p.h)
					if not idx then
						okcrop = false
						break
					end
					all_frames[p.frame_name] = {
						_preview_idata = idx
					}
				end
				if not okcrop then
					fail[#fail + 1] = e.key
					print("[repack-skip-crop] " .. e.key)
				else
					local merged = atlas_util.create_merged_atlas(e.rpl, all_frames, e.rw, e.rh)
					local hbw = math.ceil(e.rw / 1024) + 1
					local hbh = math.ceil(e.rh / 1024) + 1
					for y = 0, math.min(hbh - 1, e.rh - 1) do
						for x = 0, math.min(hbw - 1, e.rw - 1) do
							merged:setPixel(x, y, 255, 255, 255, 255)
						end
					end
					local orig = e.png_ok and read_all(e.png_path) or nil
					write_all(e.png_path, encode_png(merged))
					local oknv = run_nvcompress(e.png_path, e.dds_path)
					if not oknv then
						if orig then
							write_all(e.png_path, orig)
						end
						fail[#fail + 1] = e.key
						print("[repack-nvfail-rollback] " .. e.key)
					else
						for _, p in ipairs(e.rpl) do
							local rec = e.key2rec[p.frame_name]
							local v = rec.f
							local kx = e.dds.w / v.a_size[1]
							local ky = e.dds.h / v.a_size[2]
							local sz = v.size or {}
							local tr = v.trim or {}
							local function sc(a, k)
								return math.floor((a or 0) * k + 0.5)
							end
							v.f_quad = {p.x, p.y, p.w, p.h}
							v.a_size = {e.rw, e.rh}
							v.size = {sc(sz[1], kx), sc(sz[2], ky)}
							v.trim = {sc(tr[1], kx), sc(tr[2], ky), sc(tr[3], kx), sc(tr[4], ky)}
							v.ref_scale = (v.ref_scale or 1) / kx
							dirty[rec.g] = true
						end
						done_repack = done_repack + 1
						print(string.format("[repack] %-40s %dx%d -> %dx%d", e.key, e.dds.w, e.dds.h, e.rw, e.rh))
					end
				end
			end
		elseif e.mode == "crop" then
			local okc, cerr = crop_dds_blocks(e.dds_path, e.cnw, e.cnh)
			if not okc then
				print(string.format("[crop-skip] %s: %s", e.key, tostring(cerr)))
			else
				if e.png_ok then
					local idata = crop_png_origin(e.png_path, e.cnw, e.cnh)
					if idata then
						write_all(e.png_path, encode_png(idata))
					end
				end
				local rw = e.cnw / e.dds.w
				local rh = e.cnh / e.dds.h
				for _, rec in ipairs(e.frames) do
					local v = rec.f
					if v.a_size then
						v.a_size[1] = v.a_size[1] * rw
						v.a_size[2] = v.a_size[2] * rh
					end
					dirty[rec.g] = true
				end
				done_crop = done_crop + 1
			end
		elseif e.mode == "strip" then
			if strip_dds_mips(e.dds_path) then
				done_strip = done_strip + 1
			end
		end
	end

	-- ---- 写回 .lua/.bin/.abin ----
	local write_fn = function(path, data)
		local f = io.open(path, "wb")
		if not f then
			return false
		end
		f:write(data)
		f:close()
		return true
	end
	local wrote = 0
	for gname, _ in pairs(dirty) do
		local ok, err = atlas_util.write_atlas_files(ATLAS_DIR, gname, groups[gname], write_fn)
		if ok then
			wrote = wrote + 1
		else
			print(string.format("[write-fail] %s: %s", gname, tostring(err)))
		end
	end

	print("==================== 完成 ====================")
	print(string.format("重排: %d   无损裁剪: %d   剥离mip: %d   重写图集组: %d", done_repack, done_crop, done_strip, wrote))
	if #fail > 0 then
		print(string.format("失败/跳过 %d 个: %s", #fail, table.concat(fail, ", ")))
	end
	print("=============================================")
	love.event.quit()
end

function love.load(a)
	_cmdline = a
	main()
end
