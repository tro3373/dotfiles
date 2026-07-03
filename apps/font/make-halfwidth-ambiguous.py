#!/usr/bin/env python3
"""Osaka-Mono の「端末が 1 セル扱いする記号」の全角グリフを半角化する。

wezterm/tmux/glibc wcwidth は曖昧幅(EAW=A)や一部の記号 (U+2212 − など)
を 1 セル(半角)として扱うため、全角デザインのままだと隣のセルに
はみ出して文字が重なる。判定は glibc の wcwidth() をそのまま使う。
対象: wcwidth==1 かつ 記号・約物(カテゴリ S*/P*) かつ advance=1000 のグリフ。
除外: 文字類(ギリシャ/キリル等)・丸数字・罫線/ブロック要素(U+2500-259F)。

usage: python3 make-halfwidth-ambiguous.py <src.otf> <dst.otf>
"""

import ctypes
import ctypes.util
import locale
import sys
import unicodedata

from fontTools.misc.transform import Transform
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

HALF = 500  # 半角の advance width (unitsPerEm=1000 前提)
PAD = 20  # 縮小時にセル左右へ残す余白

# wcwidth は UTF-8 ロケール必須 (C/POSIX だと非 ASCII が全て -1 になる)
try:
    locale.setlocale(locale.LC_CTYPE, "C.UTF-8")
except locale.Error:
    locale.setlocale(locale.LC_CTYPE, "")
_libc = ctypes.CDLL(ctypes.util.find_library("c"))
_libc.wcwidth.argtypes = [ctypes.c_wchar]
_libc.wcwidth.restype = ctypes.c_int


def is_target(cp, advance):
    ch = chr(cp)
    if 0x2500 <= cp <= 0x259F:  # 罫線・ブロック要素: 縮小すると線が途切れる
        return False
    if unicodedata.category(ch)[0] not in ("S", "P"):
        return False
    return advance == 1000 and _libc.wcwidth(ch) == 1


def main():
    src, dst = sys.argv[1], sys.argv[2]
    font = TTFont(src)
    assert font.sfntVersion == "OTTO", "CFF(OTF) 前提"
    cff = font["CFF "].cff
    top_dict = cff[cff.fontNames[0]]
    assert not hasattr(top_dict, "ROS"), "CID-keyed CFF は未対応"
    char_strings = top_dict.CharStrings
    private = top_dict.Private
    glyph_set = font.getGlyphSet()
    hmtx = font["hmtx"]

    done = set()
    for cp, gname in sorted(font.getBestCmap().items()):
        if gname in done or not is_target(cp, hmtx[gname][0]):
            continue
        done.add(gname)

        bounds = BoundsPen(glyph_set)
        glyph_set[gname].draw(bounds)
        if bounds.bounds is None:  # 空グリフは advance だけ半角化
            hmtx[gname] = (HALF, hmtx[gname][1])
            continue

        xmin, ymin, xmax, ymax = bounds.bounds
        bw = xmax - xmin
        # 半角セルに収まるなら等倍のまま、収まらなければ等比縮小。
        # 水平は半角セル中央へ、垂直は元の光学中心を維持する。
        s = 1.0 if bw <= HALF - 2 * PAD else (HALF - 2 * PAD) / bw
        cx, cy = (xmin + xmax) / 2, (ymin + ymax) / 2
        t = Transform(s, 0, 0, s, HALF / 2 - s * cx, cy - s * cy)

        pen = T2CharStringPen(HALF, glyph_set)
        glyph_set[gname].draw(TransformPen(pen, t))
        char_strings[gname] = pen.getCharString(private=private)
        hmtx[gname] = (HALF, round(s * xmin + HALF / 2 - s * cx))
        print(f"U+{cp:04X} {chr(cp)} {gname}: scale={s:.2f}")

    print(f"total: {len(done)} glyphs")
    font.save(dst)


if __name__ == "__main__":
    main()
