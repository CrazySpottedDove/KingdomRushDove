#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""检查 `_()` 翻译函数是否被同名局部变量遮蔽（KingdomRushDove i18n 专用检查）。

背景：本项目用全局函数 `_("KEY")` 取文案，而 Lua 里 `_` 又常被当作「丢弃变量」：
    for _, item in ipairs(list) do ... end
    local _, cfg = pcall(chunk)
    local f = function(_, v) ... end
这些都只是在**块内**遮蔽 `_`，本来无害；但一旦块内出现 `_("KEY")` 调用，
运行时就会报 `attempt to call local '_' (a number value)`。
本脚本用轻量词法分析找出这类调用点。

用法:
    python3 scripts/check_i18n_shadowing.py                # 扫描全项目
    python3 scripts/check_i18n_shadowing.py <file.lua> ...  # 只扫描指定文件
退出码 0 = 无问题；1 = 发现问题（可用于提交前检查）。
"""
from __future__ import print_function

import os
import re
import sys

KEYWORDS = {"function", "do", "then", "end", "repeat", "until", "else", "elseif", "local", "for", "in", "if", "while"}
SKIP_DIRS = {"lib", "_assets", "tmp", "precompile", ".git", ".agents", "scripts", "love_env", ".versions", "mime"}


def tokenize(src):
    """产出 (kind, text, line)，kind ∈ {id, kw, str, op}；注释被丢弃。"""
    i, line = 0, 1
    n = len(src)
    toks = []
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if c in " \t\r":
            i += 1
            continue
        if src.startswith("--", i):
            m = re.match(r"--\[(=*)\[", src[i:])
            if m:
                close = "]" + m.group(1) + "]"
                j = src.find(close, i)
                line += src.count("\n", i, j if j != -1 else n)
                i = (j + len(close)) if j != -1 else n
            else:
                j = src.find("\n", i)
                i = j if j != -1 else n
            continue
        if c in "\"'":
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == c:
                    break
                j += 1
            toks.append(("str", "", line))
            line += src.count("\n", i, j + 1)
            i = j + 1
            continue
        if c == "[":
            m = re.match(r"\[(=*)\[", src[i:])
            if m:
                close = "]" + m.group(1) + "]"
                j = src.find(close, i)
                toks.append(("str", "", line))
                line += src.count("\n", i, j if j != -1 else n)
                i = (j + len(close)) if j != -1 else n
                continue
        m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", src[i:])
        if m:
            w = m.group(0)
            toks.append(("kw" if w in KEYWORDS else "id", w, line))
            i += len(w)
            continue
        toks.append(("op", c, line))
        i += 1
    return toks


def block_end(toks, start):
    """返回从 start 起第一个块（do/then/function/repeat）匹配的 end/until 下标。"""
    depth = 0
    started = False
    for j in range(start, len(toks)):
        kind, text, _ = toks[j]
        if kind == "kw" and text in ("do", "then", "repeat", "function"):
            depth += 1
            started = True
        elif kind == "kw" and text in ("end", "until"):
            depth -= 1
            if started and depth <= 0:
                return j
    return len(toks)


def check(path):
    src = open(path, encoding="utf-8").read()
    toks = tokenize(src)
    stack = [None]  # 每层：None 或 {"kind","start","line"}
    pending_for = False
    findings = []

    def shadowing(idx):
        for s in stack:
            if s is None:
                continue
            if s["kind"] == "local" and s["start"] > idx:
                continue
            return s
        return None

    i = 0
    while i < len(toks):
        kind, text, line = toks[i]
        if kind == "kw" and text == "local":
            if i + 1 < len(toks) and toks[i + 1][1] == "function":
                i += 1
                continue
            j = i + 1
            first = True
            while j < len(toks) and toks[j][0] != "kw":
                if toks[j][0] == "id":
                    if first and toks[j][1] == "_":
                        stack[-1] = {"kind": "local", "start": i, "line": line}
                    first = False
                elif toks[j][0] == "op" and toks[j][1] == "=":
                    break
                elif not (toks[j][0] == "op" and toks[j][1] == ","):
                    break
                j += 1
            i += 1
            continue
        if kind == "kw" and text == "for":
            j = i + 1
            first = True
            names = []
            while j < len(toks) and toks[j][0] != "kw":
                if toks[j][0] == "id":
                    if first:
                        names.append(toks[j][1])
                        first = False
                elif toks[j][0] == "op" and toks[j][1] == ",":
                    first = True
                elif toks[j][0] == "op" and toks[j][1] == "=":
                    break
                j += 1
            pending_for = "_" in names
            i += 1
            continue
        if kind == "kw" and text == "function":
            stack.append(None)
            j = i + 1
            params = []
            if j < len(toks) and toks[j][0] == "op" and toks[j][1] == "(":
                j += 1
                first = True
                while j < len(toks) and not (toks[j][0] == "op" and toks[j][1] == ")"):
                    if toks[j][0] == "id":
                        if first:
                            params.append(toks[j][1])
                            first = False
                    elif toks[j][0] == "op" and toks[j][1] == ",":
                        first = True
                    j += 1
            if "_" in params:
                stack[-1] = {"kind": "param", "start": i, "line": line}
            i += 1
            continue
        if kind == "kw" and text in ("then", "do", "repeat"):
            stack.append({"kind": "for", "start": i, "line": line} if (text == "do" and pending_for) else None)
            pending_for = False
            i += 1
            continue
        if kind == "kw" and text == "elseif":
            if len(stack) > 1:
                stack.pop()
            i += 1
            continue
        if kind == "kw" and text == "else":
            if len(stack) > 1:
                stack.pop()
            stack.append(None)
            i += 1
            continue
        if kind == "kw" and text in ("end", "until"):
            if len(stack) > 1:
                stack.pop()
            i += 1
            continue
        if kind == "id" and text == "_" and i + 1 < len(toks) and toks[i + 1][0] == "op" and toks[i + 1][1] == "(":
            sh = shadowing(i)
            if sh:
                findings.append((line, sh["kind"], sh["line"], src.split("\n")[line - 1].strip()[:100]))
        i += 1
    return findings


def collect_default_files():
    out = []
    for root in ("all", "all-desktop", "kr1", "kr1-desktop", "dove_modules", "plugin", "main.lua"):
        if os.path.isfile(root):
            out.append(root)
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for fn in filenames:
                if fn.endswith(".lua"):
                    p = os.path.join(dirpath, fn)
                    try:
                        with open(p, encoding="utf-8") as f:
                            if re.search(r"(?<![\w.:])_\(", f.read()):
                                out.append(p)
                    except (IOError, UnicodeDecodeError):
                        pass
    return sorted(out)


def main():
    files = sys.argv[1:] or collect_default_files()
    total = 0
    for path in files:
        try:
            found = check(path)
        except Exception as e:  # noqa: BLE001
            print("%s: 扫描失败 %s" % (path, e))
            continue
        if found:
            total += len(found)
            print("### %s" % path)
            for line, kind, sline, text in found:
                print("   %s:%s 被 %s@%s 遮蔽: %s" % (path, line, kind, sline, text))
    if total:
        print("\n发现 %d 处 `_(...)` 被局部 `_` 遮蔽，请把对应 for/local/参数里的 `_` 改名（如 `_i`/`_unused`）。" % total)
        return 1
    print("OK: 未发现被遮蔽的 `_(...)` 调用（扫描 %d 个文件）" % len(files))
    return 0


if __name__ == "__main__":
    sys.exit(main())
