#!/usr/bin/env python3
"""Render platform-shaped app icons from the square master PNG.

iOS / Android / Web keep the square master — those systems apply their own
masks. macOS (traditional AppIcon PNGs) and Linux do not, so those assets
need a squircle with a transparent outside. Windows 11 looks native with a
rounded rectangle and alpha.
"""

from __future__ import annotations

import math
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets/icon/app_icon.png")
SRC_SVG = os.path.join(ROOT, "assets/icon/app_icon.svg")
MACOS_PNG = os.path.join(ROOT, "assets/icon/app_icon_macos.png")
MACOS_SVG = os.path.join(ROOT, "assets/icon/app_icon_macos.svg")
WINDOWS_PNG = os.path.join(ROOT, "assets/icon/app_icon_windows.png")
LINUX_PNG = os.path.join(ROOT, "linux/runner/resources/app_icon.png")
MACOS_ICNS_DIR = os.path.join(ROOT, "macos/Runner/Resources")
MACOS_ICNS = os.path.join(MACOS_ICNS_DIR, "AppIcon.icns")
SIZE = 1024
LINUX_SIZE = 256
# Native macOS icons sit inside the 1024 canvas (~86%), not edge-to-edge.
# Edge-to-edge squircles look like sharp squares in the Dock.
MACOS_BODY = 880


def _smoothstep(edge0: float, edge1: float, x: float) -> float:
    if edge0 == edge1:
        return 0.0 if x < edge0 else 1.0
    t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def superellipse_mask(size: int, n: float = 5.0, aa: float = 1.25) -> bytes:
    """Apple-style squircle (superellipse). White = opaque."""
    out = bytearray(size * size)
    center = (size - 1) / 2.0
    radius = size / 2.0
    inv_n = 1.0 / n
    for y in range(size):
        yy = abs((y - center) / radius)
        row = y * size
        for x in range(size):
            xx = abs((x - center) / radius)
            r = (xx ** n + yy ** n) ** inv_n
            dist = (r - 1.0) * radius
            if dist <= -aa:
                out[row + x] = 255
            elif dist >= aa:
                out[row + x] = 0
            else:
                out[row + x] = int(round(255.0 * (1.0 - _smoothstep(-aa, aa, dist))))
    return bytes(out)


def rounded_rect_mask(size: int, radius_ratio: float = 0.20, aa: float = 1.25) -> bytes:
    """Windows 11-style rounded square. White = opaque."""
    out = bytearray(size * size)
    center = (size - 1) / 2.0
    half = size / 2.0
    corner = size * radius_ratio
    hx = half - corner
    hy = half - corner
    for y in range(size):
        py = abs(y - center)
        ay = py - hy
        row = y * size
        for x in range(size):
            px = abs(x - center)
            ax = px - hx
            ox = ax if ax > 0.0 else 0.0
            oy = ay if ay > 0.0 else 0.0
            dist = math.hypot(ox, oy) + min(max(ax, ay), 0.0) - corner
            if dist <= -aa:
                out[row + x] = 255
            elif dist >= aa:
                out[row + x] = 0
            else:
                out[row + x] = int(round(255.0 * (1.0 - _smoothstep(-aa, aa, dist))))
    return bytes(out)


def _magick(*args: str) -> None:
    cmd = ["magick", *args]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"magick failed ({proc.returncode}): {proc.stderr.strip()}")


def apply_mask(src: str, mask: bytes, dest: str, size: int = SIZE) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        raw = os.path.join(tmp, "mask.gray")
        with open(raw, "wb") as fh:
            fh.write(mask)
        _magick(
            src,
            "(",
            "-size",
            f"{size}x{size}",
            "-depth",
            "8",
            f"gray:{raw}",
            ")",
            "-compose",
            "CopyOpacity",
            "-composite",
            "-strip",
            f"PNG32:{dest}",
        )


def resize_png(src: str, dest: str, size: int) -> None:
    _magick(src, "-resize", f"{size}x{size}", "-strip", f"PNG32:{dest}")


def superellipse_svg_path(size: int = SIZE, n: float = 5.0, steps: int = 180) -> str:
    pts: list[str] = []
    radius = size / 2.0
    exp = 2.0 / n
    for i in range(steps):
        theta = 2.0 * math.pi * i / steps
        c, s = math.cos(theta), math.sin(theta)
        x = radius + radius * math.copysign(abs(c) ** exp, c)
        y = radius + radius * math.copysign(abs(s) ** exp, s)
        pts.append(f"{x:.3f},{y:.3f}")
    return "M " + " L ".join(pts) + " Z"


def render_macos_png() -> None:
    """Inset squircle + drop shadow, matching Apple app icons in the Dock."""
    with tempfile.TemporaryDirectory() as tmp:
        body = os.path.join(tmp, "body.png")
        masked = os.path.join(tmp, "masked.png")
        _magick(SRC, "-resize", f"{MACOS_BODY}x{MACOS_BODY}!", f"PNG32:{body}")
        apply_mask(body, superellipse_mask(MACOS_BODY), masked, size=MACOS_BODY)
        _magick(
            masked,
            "(",
            "+clone",
            "-background",
            "black",
            "-shadow",
            "36x16+0+12",
            ")",
            "+swap",
            "-background",
            "none",
            "-layers",
            "merge",
            "+repage",
            "-gravity",
            "center",
            "-background",
            "none",
            "-extent",
            f"{SIZE}x{SIZE}",
            "-strip",
            f"PNG32:{MACOS_PNG}",
        )


def write_macos_icns() -> None:
    """Build a full-resolution .icns so Dock/Finder don't upscale a tiny actool subset."""
    iconset = os.path.join(tempfile.mkdtemp(prefix="appicon-"), "AppIcon.iconset")
    os.makedirs(iconset, exist_ok=True)
    sizes = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]
    for name, px in sizes:
        subprocess.run(
            ["sips", "-z", str(px), str(px), MACOS_PNG, "--out", os.path.join(iconset, name)],
            check=True,
            capture_output=True,
        )
    os.makedirs(MACOS_ICNS_DIR, exist_ok=True)
    subprocess.run(
        ["iconutil", "-c", "icns", iconset, "-o", MACOS_ICNS],
        check=True,
        capture_output=True,
    )


def write_macos_svg() -> None:
    with open(SRC_SVG, encoding="utf-8") as fh:
        src = fh.read()
    pad = (SIZE - MACOS_BODY) / 2.0
    scale = MACOS_BODY / SIZE
    clip = (
        '    <clipPath id="macosIcon">\n'
        f'      <path d="{superellipse_svg_path(SIZE)}"/>\n'
        "    </clipPath>\n"
    )
    if "</defs>" not in src:
        raise RuntimeError(f"{SRC_SVG} is missing </defs>")
    out = src.replace("  </defs>", clip.rstrip() + "\n  </defs>", 1)
    out = out.replace(
        '  <rect width="1024" height="1024" fill="url(#sky)"/>',
        f'  <g transform="translate({pad:.3f},{pad:.3f}) scale({scale:.6f})">\n'
        '  <g clip-path="url(#macosIcon)">\n'
        '  <rect width="1024" height="1024" fill="url(#sky)"/>',
        1,
    )
    if not out.rstrip().endswith("</svg>"):
        raise RuntimeError(f"{SRC_SVG} is missing closing </svg>")
    out = out.rstrip()[:-6] + "  </g>\n  </g>\n</svg>\n"
    with open(MACOS_SVG, "w", encoding="utf-8") as fh:
        fh.write(out)


def main() -> int:
    if not os.path.isfile(SRC):
        print(f"missing master icon: {SRC}", file=sys.stderr)
        return 1

    print("macOS / Linux: inset Apple squircle (~86% body + shadow)")
    render_macos_png()
    os.makedirs(os.path.dirname(LINUX_PNG), exist_ok=True)
    resize_png(MACOS_PNG, LINUX_PNG, LINUX_SIZE)

    print("Windows: rounded rectangle (20% corner radius)")
    apply_mask(SRC, rounded_rect_mask(SIZE, 0.20), WINDOWS_PNG)
    write_macos_svg()
    write_macos_icns()

    print(f"wrote {os.path.relpath(MACOS_PNG, ROOT)}")
    print(f"wrote {os.path.relpath(MACOS_SVG, ROOT)}")
    print(f"wrote {os.path.relpath(MACOS_ICNS, ROOT)}")
    print(f"wrote {os.path.relpath(WINDOWS_PNG, ROOT)}")
    print(f"wrote {os.path.relpath(LINUX_PNG, ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
