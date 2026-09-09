#!/usr/bin/env python3
"""Build the square master app icon (SVG + PNG) from OyunQaganTig.

Visual language matches mgl-notes-app: eternal-sky gradient, cream paper
object, vertical Mongolian, one warm accent. Mail uses an envelope + gold
seal instead of a notebook + terracotta bookmark.

Requires fontTools + uharfbuzz (optional venv). PNG is rasterized with
ImageMagick `magick`.
"""

from __future__ import annotations

import math
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FONT = ROOT / "assets/fonts/OyunQaganTig.ttf"
OUT_SVG = ROOT / "assets/icon/app_icon.svg"
OUT_PNG = ROOT / "assets/icon/app_icon.png"
TEXT = "ᠵᠠᠬᠢᠳᠠᠯ"  # zakhidal — letter / correspondence
SIZE = 1024

# Mail theme (theme.cljd) + notes-icon sky treatment.
SKY_LIGHT = "#3A8FC4"
SKY_MID = "#1A6FA8"
SKY_DEEP = "#145A8A"
PAPER = "#FFFCF7"
FLAP = "#EDE8DC"
GOLD = "#C4A035"
INK = "#1A2332"

# Same card proportions as notes (470×740, rx=78), so the two apps sit as siblings.
CARD_X, CARD_Y = 277.0, 142.0
CARD_W, CARD_H = 470.0, 740.0
CARD_RX = 78.0


def _round_path(d: str) -> str:
    import re

    return re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.2f}", d)


def _magick(*args: str) -> None:
    proc = subprocess.run(["magick", *args], capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"magick failed: {proc.stderr.strip()}")


def _shaped_glyphs(font_path: Path, text: str):
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.misc.transform import Transform
    from fontTools.ttLib import TTFont
    import uharfbuzz as hb

    tt = TTFont(font_path)
    upem = tt["head"].unitsPerEm
    glyph_set = tt.getGlyphSet()
    glyph_order = tt.getGlyphOrder()

    face = hb.Face(font_path.read_bytes())
    hbfont = hb.Font(face)
    hbfont.scale = (upem, upem)
    buf = hb.Buffer()
    buf.add_str(text)
    buf.guess_segment_properties()
    hb.shape(hbfont, buf)

    placed = []
    cursor_x = 0.0
    minx = miny = 1e9
    maxx = maxy = -1e9
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        name = glyph_order[info.codepoint]
        g = glyph_set[name]
        ox = cursor_x + pos.x_offset
        oy = pos.y_offset
        local = Transform(1, 0, 0, -1, ox, -oy)
        bp = BoundsPen(glyph_set)
        g.draw(TransformPen(bp, local))
        if bp.bounds:
            x0, y0, x1, y1 = bp.bounds
            minx = min(minx, x0)
            miny = min(miny, y0)
            maxx = max(maxx, x1)
            maxy = max(maxy, y1)
        placed.append((g, local))
        cursor_x += pos.x_advance
    return glyph_set, placed, (minx, miny, maxx, maxy)


def _paths_xml(glyph_set, finals, dx: float) -> str:
    from fontTools.pens.svgPathPen import SVGPathPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.misc.transform import Transform

    lines = []
    for g, xf in finals:
        sp = SVGPathPen(glyph_set)
        g.draw(TransformPen(sp, Transform(1, 0, 0, 1, dx, 0).transform(xf)))
        lines.append(f'    <path d="{_round_path(sp.getCommands())}"/>')
    return "\n".join(lines)


def _ink_centroid_x(glyphs: str, cx: float) -> float:
    """Rasterize glyph paths and return the ink mass-center X."""
    import tempfile

    svg = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}">
  <rect width="{SIZE}" height="{SIZE}" fill="#ffffff"/>
  <g fill="#000000">
{glyphs}
  </g>
</svg>
"""
    with tempfile.TemporaryDirectory() as tmp:
        svg_path = os.path.join(tmp, "glyphs.svg")
        raw = os.path.join(tmp, "glyphs.gray")
        Path(svg_path).write_text(svg, encoding="utf-8")
        _magick(
            "-background",
            "white",
            "-density",
            "96",
            svg_path,
            "-resize",
            f"{SIZE}x{SIZE}",
            "-colorspace",
            "gray",
            "-depth",
            "8",
            f"gray:{raw}",
        )
        data = Path(raw).read_bytes()
    sx = n = 0
    for y in range(SIZE):
        row = y * SIZE
        for x in range(SIZE):
            if data[row + x] < 80:
                sx += x
                n += 1
    if not n:
        return cx
    return sx / n


def write_svg() -> None:
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.misc.transform import Transform

    glyph_set, placed, (minx, miny, maxx, maxy) = _shaped_glyphs(FONT, TEXT)
    tw, th = maxx - minx, maxy - miny

    target_h = 390.0
    scale = target_h / tw
    cx = CARD_X + CARD_W / 2.0
    cy = CARD_Y + 503.0
    place = (
        Transform()
        .translate(cx, cy)
        .rotate(math.pi / 2)
        .scale(scale)
        .translate(-(minx + tw / 2.0), -(miny + th / 2.0))
    )

    ink_minx, ink_maxx = 1e9, -1e9
    finals = []
    for g, local in placed:
        xf = place.transform(local)
        bp = BoundsPen(glyph_set)
        g.draw(TransformPen(bp, xf))
        if bp.bounds:
            ink_minx = min(ink_minx, bp.bounds[0])
            ink_maxx = max(ink_maxx, bp.bounds[2])
        finals.append((g, xf))

    # BBox center, then shift by ink mass so the column looks centered.
    dx = cx - (ink_minx + ink_maxx) / 2.0
    preview = _paths_xml(glyph_set, finals, dx)
    mass_x = _ink_centroid_x(preview, cx)
    dx += cx - mass_x
    glyphs = _paths_xml(glyph_set, finals, dx)

    flap_tip_y = CARD_Y + 248.0
    seal_r = 38.0
    svg = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}">
  <defs>
    <radialGradient id="sky" cx="50%" cy="42%" r="75%">
      <stop offset="0%" stop-color="{SKY_LIGHT}"/>
      <stop offset="55%" stop-color="{SKY_MID}"/>
      <stop offset="100%" stop-color="{SKY_DEEP}"/>
    </radialGradient>
    <clipPath id="envelope">
      <rect x="{CARD_X}" y="{CARD_Y}" width="{CARD_W}" height="{CARD_H}" rx="{CARD_RX}"/>
    </clipPath>
  </defs>
  <rect width="1024" height="1024" fill="url(#sky)"/>
  <rect x="{CARD_X}" y="{CARD_Y}" width="{CARD_W}" height="{CARD_H}" rx="{CARD_RX}" fill="{PAPER}"/>
  <g clip-path="url(#envelope)">
    <path fill="{FLAP}" d="M{CARD_X} {CARD_Y} h{CARD_W} L{cx} {flap_tip_y} z"/>
  </g>
  <circle cx="{cx}" cy="{flap_tip_y}" r="{seal_r}" fill="{GOLD}"/>
  <circle cx="{cx}" cy="{flap_tip_y}" r="{seal_r - 12}" fill="{PAPER}"/>
  <circle cx="{cx}" cy="{flap_tip_y}" r="{seal_r - 22}" fill="{GOLD}"/>
  <g clip-path="url(#envelope)" fill="{INK}">
{glyphs}
  </g>
</svg>
"""
    OUT_SVG.parent.mkdir(parents=True, exist_ok=True)
    OUT_SVG.write_text(svg, encoding="utf-8")
    print(
        f"wrote {OUT_SVG.relative_to(ROOT)}  "
        f"(scale={scale:.4f}, glyph {tw:.0f}×{th:.0f}, dx={dx:.1f}, mass_x={mass_x:.1f})"
    )


def rasterize() -> None:
    """Magick's built-in SVG renderer drops radialGradient; paint sky in magick."""
    import tempfile

    overlay_svg = OUT_SVG.read_text(encoding="utf-8")
    overlay_svg = overlay_svg.replace(
        '  <rect width="1024" height="1024" fill="url(#sky)"/>\n',
        "",
        1,
    )
    with tempfile.TemporaryDirectory() as tmp:
        sky = os.path.join(tmp, "sky.png")
        overlay = os.path.join(tmp, "overlay.svg")
        Path(overlay).write_text(overlay_svg, encoding="utf-8")
        _magick(
            "-size",
            f"{SIZE}x{SIZE}",
            "-define",
            "gradient:center=512,430",
            "-define",
            "gradient:radii=768,768",
            f"radial-gradient:{SKY_LIGHT}-{SKY_MID}-{SKY_DEEP}",
            f"PNG32:{sky}",
        )
        _magick(
            sky,
            "(",
            "-background",
            "none",
            "-density",
            "384",
            overlay,
            "-resize",
            f"{SIZE}x{SIZE}",
            ")",
            "-composite",
            "-strip",
            f"PNG32:{OUT_PNG}",
        )
    print(f"wrote {OUT_PNG.relative_to(ROOT)}")


def main() -> int:
    if not FONT.is_file():
        print(f"missing font: {FONT}", file=sys.stderr)
        return 1
    write_svg()
    rasterize()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
