#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""给 LÖVE 的 love.exe 内嵌 manifest 加上 DPI 感知声明。

Windows 对未声明 DPI 感知的进程做 DPI 虚拟化：高缩放下报告缩小后的分辨率，
渲染完再由 DWM 位图放大，画面变糊。给 exe 的 RT_MANIFEST 写入 dpiAware /
dpiAwareness 后，系统直接按物理像素处理，全屏即为原生分辨率。

脚本原地扩展 manifest 资源（该资源位于 .rsrc 末尾），同时更新资源数据项的
Size 和 .rsrc 的 VirtualSize；已包含 dpiAware 的文件会被跳过。

用法:
    python3 scripts/patch_love_dpi.py <love.exe>
"""

import struct
import sys

RT_MANIFEST = 24
DIRENTRY = struct.Struct("<II")
DATAENTRY = struct.Struct("<IIII")

MANIFEST = b"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
      </requestedPrivileges>
    </security>
  </trustInfo>
  <application xmlns="urn:schemas-microsoft-com:asm.v3">
    <windowsSettings>
      <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true/pm</dpiAware>
      <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2, PerMonitor</dpiAwareness>
    </windowsSettings>
  </application>
</assembly>
"""


def align4(value):
    return (value + 3) & ~3


def read_sections(buf, pe_off):
    if buf[pe_off:pe_off + 4] != b"PE\0\0":
        raise ValueError("not a PE file")

    nsec = struct.unpack_from("<H", buf, pe_off + 6)[0]
    opt_off = pe_off + 24
    magic = struct.unpack_from("<H", buf, opt_off)[0]

    if magic == 0x20B:
        dd_off = opt_off + 112
    elif magic == 0x10B:
        dd_off = opt_off + 96
    else:
        raise ValueError("unknown optional header magic 0x%x" % magic)

    size_of_image = struct.unpack_from("<I", buf, opt_off + 56)[0]
    sec_tab = opt_off + struct.unpack_from("<H", buf, pe_off + 20)[0]
    sections = []

    for i in range(nsec):
        off = sec_tab + i * 40
        name = buf[off:off + 8].rstrip(b"\0").decode("ascii", "replace")
        vsize, va, rsize, raw = struct.unpack_from("<IIII", buf, off + 8)
        sections.append({
            "name": name,
            "header": off,
            "vsize": vsize,
            "va": va,
            "rsize": rsize,
            "raw": raw,
        })

    return dd_off, size_of_image, sections


def section_by_rva(sections, rva):
    for sec in sections:
        if sec["va"] <= rva < sec["va"] + max(sec["vsize"], sec["rsize"]):
            return sec

    raise ValueError("rva 0x%x not inside any section" % rva)


def iter_data_entries(buf, base, dir_off, path=()):
    named, ids = struct.unpack_from("<HH", buf, base + dir_off + 12)
    total = named + ids

    for i in range(total):
        name, off = DIRENTRY.unpack_from(buf, base + dir_off + 16 + i * 8)
        ident = None if name & 0x80000000 else name
        child = path + (ident,)

        if off & 0x80000000:
            yield from iter_data_entries(buf, base, off & 0x7FFFFFFF, child)
        else:
            yield child, base + off


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: python3 scripts/patch_love_dpi.py <love.exe>")

    path = sys.argv[1]

    with open(path, "rb") as handle:
        buf = bytearray(handle.read())

    if buf[:2] != b"MZ":
        raise SystemExit("%s: not an exe" % path)

    pe_off = struct.unpack_from("<I", buf, 0x3C)[0]
    dd_off, size_of_image, sections = read_sections(buf, pe_off)

    rsrc_rva, rsrc_size = struct.unpack_from("<II", buf, dd_off + 2 * 8)

    if rsrc_rva == 0 or rsrc_size == 0:
        raise SystemExit("%s: no resource directory" % path)

    rsrc = section_by_rva(sections, rsrc_rva)
    rsrc_base = rsrc["raw"] + (rsrc_rva - rsrc["va"])

    manifest_entry = None
    max_data_end = 0

    for ident, entry_off in iter_data_entries(buf, rsrc_base, 0):
        data_rva, data_size = DATAENTRY.unpack_from(buf, entry_off)[:2]
        data_off = rsrc["raw"] + (data_rva - rsrc["va"])
        max_data_end = max(max_data_end, data_off + data_size)

        if ident and ident[0] == RT_MANIFEST and manifest_entry is None:
            manifest_entry = (entry_off, data_off, data_rva, data_size)

    if manifest_entry is None:
        raise SystemExit("%s: RT_MANIFEST not found" % path)

    entry_off, old_off, old_rva, old_size = manifest_entry
    current = bytes(buf[old_off:old_off + old_size])

    if b"dpiAware" in current:
        print("[patch_love_dpi] already DPI aware: %s" % path)

        return

    if old_off + old_size != max_data_end:
        raise SystemExit("%s: manifest is not the last resource block, refusing to resize" % path)

    new_off = old_off
    new_end = new_off + len(MANIFEST)
    raw_end = rsrc["raw"] + rsrc["rsize"]

    if new_end > raw_end:
        raise SystemExit("%s: no room to grow manifest (%d > %d)" % (path, new_end, raw_end))

    new_end_rva = rsrc["va"] + (new_end - rsrc["raw"])
    next_va = min((sec["va"] for sec in sections if sec["va"] > rsrc["va"]), default=size_of_image)

    if new_end_rva > next_va:
        raise SystemExit("%s: manifest would overlap the next section" % path)

    buf[new_off:new_end] = MANIFEST
    DATAENTRY.pack_into(buf, entry_off, old_rva, len(MANIFEST), 0, 0)

    vsize = align4(new_end_rva - rsrc["va"])

    if vsize > rsrc["vsize"]:
        struct.pack_into("<I", buf, rsrc["header"] + 8, vsize)

    with open(path, "wb") as handle:
        handle.write(buf)

    print("[patch_love_dpi] %s: manifest %d -> %d bytes" % (path, old_size, len(MANIFEST)))


if __name__ == "__main__":
    main()
