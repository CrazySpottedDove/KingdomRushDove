#!/usr/bin/env python3
"""截断 Lua/TSV 数据文件中的小数位数，用于缩减文本数据体积。

特性：
  - 仅匹配数字字面量，跳过字符串、单行注释、长括号字符串/注释，避免误伤文本；
  - 支持普通小数与科学计数法：科学计数法只截断尾数、保留指数
    （如 1.4366578997059e-05 -> 1.436658e-05），不会改变数量级；
  - 按四舍五入保留指定位数，并去掉多余的尾零。

注意：
  - 运行时优先加载编译后的二进制（如 .exo3、.luac）时，源码文本截断不会影响
    运行时体积/行为，只减小仓库体积；如需源码与二进制一致请重新执行对应编译
    （例：make compile_exos）。
  - 默认目标为常见数据目录；也可显式传入任意文件/目录。

用法：
  python3 scripts/trunc_decimals.py --places 6                   # 预览默认数据目录
  python3 scripts/trunc_decimals.py --places 6 --apply           # 实际写回
  python3 scripts/trunc_decimals.py --places 2 --apply kr1/data/levels
  python3 scripts/trunc_decimals.py --places 6 --ext lua,tsv --apply kr1/data
"""
import argparse
import os
import re
from decimal import Decimal, ROUND_HALF_UP

NUM = re.compile(r'(?<![\w.])-?\d+\.\d+([eE][-+]?\d+)?(?![\w.])')

DEFAULT_TARGETS = [
    "kr1/data",
    "kr1/template_groups",
    "kr1-desktop/data",
    "all-desktop/data",
]


def _fmt_mantissa(mant, qexp):
    try:
        q = Decimal(mant).quantize(qexp, rounding=ROUND_HALF_UP)
        s = format(q, 'f')
        if '.' in s:
            s = s.rstrip('0').rstrip('.')
        if s in ('-0', ''):
            s = '0'
        return s
    except Exception:
        return mant


def scan_and_replace(src, places):
    """返回 (替换后的文本, 替换次数)。"""
    qexp = Decimal(1).scaleb(-places)
    out = []
    i = 0
    n = len(src)
    count = 0

    def longbracket(i):
        if i >= n or src[i] != '[':
            return None
        j = i + 1
        eq = 0
        while j < n and src[j] == '=':
            eq += 1
            j += 1
        if j >= n or src[j] != '[':
            return None
        close = ']' + '=' * eq + ']'
        k = src.find(close, j + 1)
        return None if k < 0 else k + len(close)

    while i < n:
        c = src[i]
        if c == '-' and i + 1 < n and src[i + 1] == '-':
            j = i + 2
            lb = longbracket(j)
            if lb is not None:
                out.append(src[i:lb])
                i = lb
            else:
                nl = src.find('\n', j)
                nl = n if nl < 0 else nl + 1
                out.append(src[i:nl])
                i = nl
            continue
        if c == '"' or c == "'":
            quote = c
            j = i + 1
            while j < n:
                if src[j] == '\\':
                    j += 2
                    continue
                if src[j] == quote:
                    j += 1
                    break
                if src[j] == '\n':
                    break
                j += 1
            out.append(src[i:j])
            i = j
            continue
        if c == '[':
            lb = longbracket(i)
            if lb is not None:
                out.append(src[i:lb])
                i = lb
                continue
        if c.isdigit() or (c == '-' and i + 1 < n and src[i + 1].isdigit()):
            m = NUM.match(src, i)
            if m:
                lit = m.group(0)
                exp = m.group(1)
                mant = lit[: len(lit) - len(exp)] if exp else lit
                s = _fmt_mantissa(mant, qexp) + (exp or '')
                if s != lit:
                    count += 1
                out.append(s)
                i = m.end()
                continue
        out.append(c)
        i += 1

    return ''.join(out), count


def iter_files(targets, exts):
    for t in targets:
        if os.path.isfile(t):
            if t.rsplit('.', 1)[-1] in exts:
                yield t
        else:
            for dp, _, fns in os.walk(t):
                for fn in sorted(fns):
                    if fn.rsplit('.', 1)[-1] in exts:
                        yield os.path.join(dp, fn)


def main():
    ap = argparse.ArgumentParser(description="截断数据文件中的小数位数")
    ap.add_argument("--places", type=int, default=6, help="保留的小数位数（默认 6）")
    ap.add_argument("--apply", action="store_true", help="写回文件；缺省只预览")
    ap.add_argument("--ext", default="lua,tsv", help="处理的扩展名，逗号分隔（默认 lua,tsv）")
    ap.add_argument("targets", nargs="*", help="文件或目录；缺省使用默认数据目录")
    args = ap.parse_args()

    exts = {e.strip().lstrip('.').lower() for e in args.ext.split(",") if e.strip()}
    targets = args.targets or DEFAULT_TARGETS

    files = changed = total_repl = 0
    before = after = 0

    for f in iter_files(targets, exts):
        files += 1
        with open(f, encoding="utf-8") as fh:
            src = fh.read()
        out, cnt = scan_and_replace(src, args.places)
        before += len(src)
        after += len(out)
        if cnt:
            changed += 1
            total_repl += cnt
            if args.apply:
                with open(f, "w", encoding="utf-8") as fh:
                    fh.write(out)

    mode = "已写回" if args.apply else "预览"
    print(f"[{mode}] places={args.places} files={files} changed={changed} replacements={total_repl}")
    print(f"bytes {before} -> {after} (saved {before - after})")


if __name__ == "__main__":
    main()
