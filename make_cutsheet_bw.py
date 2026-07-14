#!/usr/bin/env python3
"""Generate cutsheet_bw.svg: black-and-white, high-contrast cut layout
for the bench (bench3.scad) across six 8-foot 2x4s, grouped into
sections -- 'Frame' boards first, then 'Top slats'. Suited to
photocopying / laser printing: pure black ink on white, no grays,
scrap shown as diagonal hatching.

Lengths are nominal -- saw kerf is not included. The tightest board
(the 30/17/17/14/14 frame board) leaves 4" total spare.
"""

BOARD_LEN = 96      # 8-foot 2x4
BOARD_WID = 3.5     # drawn width of a 2x4 face

# sections in display order: (section title, list of boards),
# each board a list of (piece name, length in inches); scrap computed
SECTIONS = [
    ("Frame", [
        [("long apron rail", 36), ("long apron rail", 36), ("end rail", 17)],
        [("bottom rail", 30), ("end rail", 17), ("cross rail", 17),
         ("stretcher", 14), ("stretcher", 14)],
        [("leg", 15.5), ("leg", 15.5), ("leg", 15.5), ("leg", 15.5)],
    ]),
    ("Top slats", [
        [("top slat", 42), ("top slat", 42)],
        [("top slat", 42), ("top slat", 42)],
        [("top slat", 42), ("top slat", 42)],
    ]),
]

# ---- layout (px) ----
S          = 8            # px per inch
ML, MR     = 50, 30       # left/right margins
MT         = 100          # top margin (title + overall dim)
SECTION_H  = 46           # extra space for each section heading
ROW_H      = 100          # vertical pitch per board
BOARD_H    = BOARD_WID * S
TITLE_DY   = -8           # board title above the board
DIM_DY     = 16           # dim line below the board
TEXT_DY    = 14           # dim text below the dim line

INK = "#000000"           # everything is pure black on white

n_boards = sum(len(boards) for _, boards in SECTIONS)
W = ML + BOARD_LEN * S + MR
H = MT + len(SECTIONS) * SECTION_H + n_boards * ROW_H + 20


def fmt(n):
    return f"{n:g}″"          # 15.5″


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;")


out = []
out.append(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
    f'viewBox="0 0 {W} {H}" font-family="sans-serif">')
out.append(f'<rect width="{W}" height="{H}" fill="white"/>')

out.append(f'''<defs>
  <marker id="arrL" markerWidth="10" markerHeight="8" refX="1" refY="4" orient="auto">
    <path d="M10,0 L1,4 L10,8 z" fill="{INK}"/>
  </marker>
  <marker id="arrR" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto">
    <path d="M0,0 L9,4 L0,8 z" fill="{INK}"/>
  </marker>
  <pattern id="hatch" width="7" height="7" patternUnits="userSpaceOnUse"
           patternTransform="rotate(45)">
    <line x1="0" y1="0" x2="0" y2="7" stroke="{INK}" stroke-width="1"/>
  </pattern>
</defs>''')

out.append(f'<text x="{ML}" y="30" font-size="20" fill="{INK}" '
           f'font-weight="bold">Bench cut sheet — six 8′ 2x4s</text>')
out.append(f'<text x="{ML}" y="50" font-size="12" fill="{INK}">'
           f'lengths are nominal — saw kerf (≈1/8″ per cut) not included</text>')


def dim(x1, x2, y, label):
    """horizontal dimension line with arrowheads and centered label"""
    out.append(f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="{INK}" '
               f'stroke-width="1" marker-start="url(#arrL)" marker-end="url(#arrR)"/>')
    out.append(f'<text x="{(x1 + x2) / 2}" y="{y + TEXT_DY}" font-size="12" '
               f'fill="{INK}" text-anchor="middle">{esc(label)}</text>')


def witness(x, y1, y2):
    out.append(f'<line x1="{x}" y1="{y1}" x2="{x}" y2="{y2}" stroke="{INK}" '
               f'stroke-width="0.8"/>')


# overall 96" dimension above the first board
y0 = MT + SECTION_H
dim(ML, ML + BOARD_LEN * S, y0 - 18, f'{fmt(BOARD_LEN)}  (8 ft)')
witness(ML, y0 - 24, y0 - 4)
witness(ML + BOARD_LEN * S, y0 - 24, y0 - 4)

y_cursor = MT
board_no = 0
for title, boards in SECTIONS:
    # section heading with a rule out to the right edge
    yh = y_cursor + 14
    out.append(f'<text x="{ML}" y="{yh}" font-size="16" fill="{INK}" '
               f'font-weight="bold">{esc(title)}</text>')
    out.append(f'<line x1="{ML + 9 * len(title) + 14}" y1="{yh - 5}" '
               f'x2="{ML + BOARD_LEN * S}" y2="{yh - 5}" '
               f'stroke="{INK}" stroke-width="1"/>')
    y_cursor += SECTION_H

    for pieces in boards:
        board_no += 1
        y = y_cursor + 24
        used = sum(L for _, L in pieces)
        pieces = pieces + [("scrap", BOARD_LEN - used)]

        out.append(f'<text x="{ML}" y="{y + TITLE_DY}" font-size="13" '
                   f'fill="{INK}" font-weight="bold">Board {board_no}</text>')

        x = ML
        for j, (name, L) in enumerate(pieces):
            w = L * S
            scrap = name == "scrap"
            fill = "url(#hatch)" if scrap else "white"
            out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{BOARD_H}" '
                       f'fill="{fill}" stroke="{INK}" stroke-width="1.5"/>')

            # piece name inside the board; scrap label sits on a small
            # white plate so it stays readable over the hatching --
            # skipped when the block is too narrow to hold it
            style = ' font-style="italic"' if scrap else ''
            if scrap and w >= 48:
                out.append(f'<rect x="{x + w / 2 - 20}" y="{y + BOARD_H / 2 - 8}" '
                           f'width="40" height="16" fill="white"/>')
            if not scrap or w >= 48:
                out.append(f'<text x="{x + w / 2}" y="{y + BOARD_H / 2 + 4}" '
                           f'font-size="12" fill="{INK}" text-anchor="middle"{style}>'
                           f'{esc(name)}</text>')

            dim(x, x + w, y + BOARD_H + DIM_DY, fmt(L))
            witness(x, y + BOARD_H + 2, y + BOARD_H + DIM_DY + 4)
            witness(x + w, y + BOARD_H + 2, y + BOARD_H + DIM_DY + 4)

            if j < len(pieces) - 1:
                out.append(f'<line x1="{x + w}" y1="{y - 3}" x2="{x + w}" '
                           f'y2="{y + BOARD_H + 3}" stroke="{INK}" stroke-width="3"/>')
            x += w

        y_cursor += ROW_H

out.append('</svg>')

with open("cutsheet_bw.svg", "w") as f:
    f.write("\n".join(out) + "\n")
print(f"wrote cutsheet_bw.svg ({W}x{H})")
