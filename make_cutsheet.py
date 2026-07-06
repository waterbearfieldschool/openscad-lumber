#!/usr/bin/env python3
"""Generate cutsheet.svg: cut layout for the bench (bench3.scad)
across six 8-foot 2x4s, with labeled pieces and dimension arrows.

Lengths are nominal -- saw kerf is not included. The tightest board
(board 5) leaves 4" total spare, about 1" per cut at 1/8" kerf.
"""

BOARD_LEN = 96      # 8-foot 2x4
BOARD_WID = 3.5     # drawn width of a 2x4 face

# (piece name, length in inches) per board; scrap is computed
CUT_PLAN = [
    [("top slat", 42), ("top slat", 42)],
    [("top slat", 42), ("top slat", 42)],
    [("top slat", 42), ("top slat", 42)],
    [("long apron rail", 36), ("long apron rail", 36), ("end rail", 17)],
    [("bottom rail", 30), ("end rail", 17), ("cross rail", 17),
     ("stretcher", 14), ("stretcher", 14)],
    [("leg", 15.5), ("leg", 15.5), ("leg", 15.5), ("leg", 15.5)],
]

# ---- layout (px) ----
S          = 8            # px per inch
ML, MR     = 50, 30       # left/right margins
MT         = 90           # top margin (title + overall dim)
ROW_H      = 100          # vertical pitch per board
BOARD_H    = BOARD_WID * S
TITLE_DY   = -8           # board title above the board
DIM_DY     = 16           # dim line below the board
TEXT_DY    = 14           # dim text below the dim line

WOOD   = ["#c68a4b", "#a86f35"]
SCRAP  = "#dddddd"
INK    = "#333333"
GRAY   = "#888888"

W = ML + BOARD_LEN * S + MR
H = MT + len(CUT_PLAN) * ROW_H + 20


def fmt(n):
    return f"{n:g}″"          # 15.5″


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;")


out = []
out.append(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
    f'viewBox="0 0 {W} {H}" font-family="sans-serif">')
out.append(f'<rect width="{W}" height="{H}" fill="white"/>')

# arrowhead markers (one pointing each way along a dim line)
out.append(f'''<defs>
  <marker id="arrL" markerWidth="10" markerHeight="8" refX="1" refY="4" orient="auto">
    <path d="M10,0 L1,4 L10,8 z" fill="{INK}"/>
  </marker>
  <marker id="arrR" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto">
    <path d="M0,0 L9,4 L0,8 z" fill="{INK}"/>
  </marker>
</defs>''')

out.append(f'<text x="{ML}" y="30" font-size="20" fill="{INK}" '
           f'font-weight="bold">Bench cut sheet — six 8′ 2x4s</text>')
out.append(f'<text x="{ML}" y="50" font-size="12" fill="{GRAY}">'
           f'lengths are nominal — saw kerf (≈1/8″ per cut) not included</text>')


def dim(x1, x2, y, label, color=INK):
    """horizontal dimension line with arrowheads and centered label"""
    out.append(f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="{color}" '
               f'stroke-width="1" marker-start="url(#arrL)" marker-end="url(#arrR)"/>')
    out.append(f'<text x="{(x1 + x2) / 2}" y="{y + TEXT_DY}" font-size="12" '
               f'fill="{color}" text-anchor="middle">{esc(label)}</text>')


def witness(x, y1, y2, color=INK):
    out.append(f'<line x1="{x}" y1="{y1}" x2="{x}" y2="{y2}" stroke="{color}" '
               f'stroke-width="0.6"/>')


# overall 96" dimension above board 1
y0 = MT
dim(ML, ML + BOARD_LEN * S, y0 - 18, f'{fmt(BOARD_LEN)}  (8 ft)')
witness(ML, y0 - 24, y0 - 4)
witness(ML + BOARD_LEN * S, y0 - 24, y0 - 4)

for b, pieces in enumerate(CUT_PLAN):
    y = MT + b * ROW_H + 24
    used = sum(L for _, L in pieces)
    pieces = pieces + [("scrap", BOARD_LEN - used)]

    out.append(f'<text x="{ML}" y="{y + TITLE_DY}" font-size="13" '
               f'fill="{INK}" font-weight="bold">Board {b + 1}</text>')

    x = ML
    for j, (name, L) in enumerate(pieces):
        w = L * S
        scrap = name == "scrap"
        fill = SCRAP if scrap else WOOD[j % 2]
        out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{BOARD_H}" '
                   f'fill="{fill}" stroke="{INK}" stroke-width="1"/>')

        # piece name centered on the piece
        tcol = GRAY if scrap else "white"
        style = ' font-style="italic"' if scrap else ''
        out.append(f'<text x="{x + w / 2}" y="{y + BOARD_H / 2 + 4}" '
                   f'font-size="12" fill="{tcol}" text-anchor="middle"{style}>'
                   f'{esc(name)}</text>')

        # dimension under the piece
        dcol = GRAY if scrap else INK
        dim(x, x + w, y + BOARD_H + DIM_DY, fmt(L), dcol)
        witness(x, y + BOARD_H + 2, y + BOARD_H + DIM_DY + 4, dcol)
        witness(x + w, y + BOARD_H + 2, y + BOARD_H + DIM_DY + 4, dcol)

        # heavy cut line at the boundary (not after the last segment)
        if j < len(pieces) - 1:
            out.append(f'<line x1="{x + w}" y1="{y - 3}" x2="{x + w}" '
                       f'y2="{y + BOARD_H + 3}" stroke="black" stroke-width="2.5"/>')
        x += w

out.append('</svg>')

with open("cutsheet.svg", "w") as f:
    f.write("\n".join(out) + "\n")
print(f"wrote cutsheet.svg ({W}x{H})")
