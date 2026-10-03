#!/usr/bin/env python3
"""将数据文件中「纯 {x=...,y=...}」的 Lua 表字面量转换为 v(x,y)。

仅转换键恰好只有 x、y 两个（顺序不限）的表；含其它键（如 {flip=1,x=,y=}）不转换。
处理时会跳过字符串与注释，并优先转换最内层表，因此嵌套表也能处理。
支持值含表达式（如 {x=this.x,y=px}）、y 在 x 前、逗号/分号分隔、尾随逗号等。
键支持两种写法：裸标识符（x = 1）与带引号方括号（["x"] = 1 / ['x'] = 1）。

重要前提：
  转换后的文件需要能解析到 v（= lib.klua.vector 的 V.v）。请确保目标文件
  满足其一：文件内已有 `local v = V.v`；或由加载环境注入 v
  （如 level_utils.eval_file、path_db、kui_db）；否则需先补别名。

用法：
  python3 scripts/migrate_xy_to_v.py                       # 预览默认目录
  python3 scripts/migrate_xy_to_v.py --apply               # 实际写回
  python3 scripts/migrate_xy_to_v.py --apply kr1/data/levels
"""
import argparse
import os
import re

DEFAULT_TARGETS = [
    "kr1/data/levels",
    "kr1-desktop/data",
    "all-desktop/data",
]

KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
BRACKET_KEY_RE = re.compile(r"^\[\s*([\"'])([A-Za-z_][A-Za-z0-9_]*)\1\s*\]$")
EQ_RE = re.compile(r"(?<![=<>~])=(?!=)")


def match_long_bracket(src, i):
    """src[i] == '['；返回长括号字符串结束后的下标（不含），否则 None。"""
    n = len(src)
    if i >= n or src[i] != "[":
        return None
    j = i + 1
    eq = 0
    while j < n and src[j] == "=":
        eq += 1
        j += 1
    if j >= n or src[j] != "[":
        return None
    close = "]" + "=" * eq + "]"
    k = src.find(close, j + 1)
    return None if k == -1 else k + len(close)


def brace_positions(src):
    """返回字符串/注释之外的 '{' / '}' 位置列表。"""
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == "-" and i + 1 < n and src[i + 1] == "-":
            j = i + 2
            lb = match_long_bracket(src, j)
            if lb is not None:
                i = lb
            else:
                nl = src.find("\n", j)
                i = n if nl == -1 else nl + 1
            continue
        if c in ('"', "'"):
            quote = c
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == quote:
                    j += 1
                    break
                if src[j] == "\n":
                    break
                j += 1
            i = j
            continue
        if c == "[":
            lb = match_long_bracket(src, i)
            if lb is not None:
                i = lb
                continue
        if c == "{" or c == "}":
            out.append((i, c))
        i += 1
    return out


def innermost_groups(src):
    """返回最内层平衡花括号对 (open, close) 列表。"""
    events = brace_positions(src)
    stack = []
    pairs = []
    for pos, ch in events:
        if ch == "{":
            stack.append(pos)
        elif stack:
            pairs.append((stack.pop(), pos))
    pairs.sort()
    return [(o, c) for o, c in pairs if not any(o < p < c for p, _ in pairs)]


def split_top_level(s):
    """按顶层 ',' 或 ';' 分割，跳过字符串/注释及括号内部。"""
    parts = []
    start = 0
    depth = 0
    i = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == "-" and i + 1 < n and s[i + 1] == "-":
            j = i + 2
            lb = match_long_bracket(s, j)
            if lb is not None:
                i = lb
                continue
            nl = s.find("\n", j)
            i = n if nl == -1 else nl
            continue
        if c in ('"', "'"):
            quote = c
            j = i + 1
            while j < n:
                if s[j] == "\\":
                    j += 2
                    continue
                if s[j] == quote:
                    j += 1
                    break
                j += 1
            i = j
            continue
        if c == "[":
            lb = match_long_bracket(s, i)
            if lb is not None:
                i = lb
                continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        elif depth == 0 and c in ",;":
            parts.append(s[start:i])
            start = i + 1
        i += 1
    parts.append(s[start:])
    return parts


def parse_kv(part):
    m = EQ_RE.search(part)
    if not m:
        return None, None
    key = part[: m.start()].strip()
    val = part[m.end():].strip()
    bm = BRACKET_KEY_RE.match(key)
    if bm:
        key = bm.group(2)
    if not KEY_RE.match(key):
        return None, None
    return key, val


def convert_content(inner):
    """若 inner 是纯 {x,y} 内容则返回 'v(x,y)'，否则 None。"""
    parts = [p for p in split_top_level(inner) if p.strip() != ""]
    if len(parts) != 2:
        return None
    kvs = [parse_kv(p) for p in parts]
    if any(k is None for k, _ in kvs):
        return None
    if {k for k, _ in kvs} != {"x", "y"}:
        return None
    d = dict(kvs)
    return "v(" + d["x"] + "," + d["y"] + ")"


def transform(src):
    count = 0
    while True:
        changed = False
        for o, c in sorted(innermost_groups(src), reverse=True):
            rep = convert_content(src[o + 1 : c])
            if rep is not None:
                src = src[:o] + rep + src[c + 1 :]
                count += 1
                changed = True
        if not changed:
            break
    return src, count


def iter_files(targets):
    for t in targets:
        if os.path.isfile(t):
            yield t
        else:
            for dp, _, fns in os.walk(t):
                for fn in sorted(fns):
                    if fn.endswith(".lua"):
                        yield os.path.join(dp, fn)


def main():
    ap = argparse.ArgumentParser(description="将纯 {x=,y=} 表转换为 v(x,y)")
    ap.add_argument("--apply", action="store_true", help="写回文件；缺省只预览")
    ap.add_argument("targets", nargs="*", help="文件或目录；缺省使用默认数据目录")
    args = ap.parse_args()

    targets = args.targets or DEFAULT_TARGETS
    touched = total = 0

    for f in iter_files(targets):
        with open(f, encoding="utf-8") as fh:
            src = fh.read()
        out, cnt = transform(src)
        if cnt:
            touched += 1
            total += cnt
            print(f"{cnt:5d}  {f}")
            if args.apply:
                with open(f, "w", encoding="utf-8") as fh:
                    fh.write(out)

    mode = "已写回" if args.apply else "预览"
    print(f"[{mode}] files touched: {touched}, conversions: {total}")


if __name__ == "__main__":
    main()
