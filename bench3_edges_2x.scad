// bench3_edges_2x.scad — bench3_edges with a configurable seat:
// the top can be built from 2x4, 2x6, 2x8, or 2x12 stock. The board
// count is chosen automatically so the seat width lands as close as
// possible to TARGET_WID (~20", within about +/-4").
// The frame underneath is unchanged (2x4s).
//
// NOTE: the seat helpers are defined BEFORE the include: overriding
// variables of an included file keeps the last-assigned value but
// evaluates it at the original definition's position, so everything
// the overrides reference must already exist by then.

// ---- seat options ----
SEAT_STOCK = "2x4";   // "2x4", "2x6", "2x8" or "2x12"
SEAT_GAP   = 0.1;     // gap between seat boards
TARGET_WID = 20;      // aim the seat width here

// actual widths of 2x dimensional lumber (all 1.5" thick)
SLAT_W = SEAT_STOCK == "2x4"  ?  3.5  :
         SEAT_STOCK == "2x6"  ?  5.5  :
         SEAT_STOCK == "2x8"  ?  7.25 :
         SEAT_STOCK == "2x12" ? 11.25 : undef;

function seat_width(n) = n*SLAT_W + (n - 1)*SEAT_GAP;

// board count whose total width lands closest to the target
n_lo   = max(1, floor((TARGET_WID + SEAT_GAP) / (SLAT_W + SEAT_GAP)));
n_best = abs(seat_width(n_lo) - TARGET_WID)
         <= abs(seat_width(n_lo + 1) - TARGET_WID) ? n_lo : n_lo + 1;

include <bench3_edges.scad>

// ---- overrides of the included seat parameters ----
N_SLATS = n_best;
TOP_WID = seat_width(n_best);

// 0 = assembled; ~9 lifts the seat for an exploded view
// (also settable from the CLI: -D EXPLODE=9)
EXPLODE = 0;

echo(str("seat: ", N_SLATS, " x ", SEAT_STOCK, " (", SLAT_W,
         "\" wide) + ", SEAT_GAP, "\" gaps -> ", TOP_WID, "\" total"));

// ---- top modules redefined for the wider stock ----

module top_slat() {
    edged_cube([TOP_LEN, SLAT_W, TWOBY_T]);
}

module top_assembly() {
    for (i = [0 : N_SLATS-1])
        translate([0, i*(SLAT_W + SEAT_GAP), 0])
            top_slat();
    top_hardware();
}

// same three screw rows as bench3, but the pair spreads toward the
// edges of the wider boards
module top_hardware() {
    overhang = (TOP_LEN - FRAME_LEN) / 2;
    stations = [overhang + TWOBY_T/2,            // over left end rail
                TOP_LEN/2,                       // over center cross rail
                TOP_LEN - overhang - TWOBY_T/2]; // over right end rail
    dy = max(BOLT_OFF, SLAT_W/2 - 1.5);
    for (x = stations, i = [0 : N_SLATS-1]) {
        cy = i*(SLAT_W + SEAT_GAP) + SLAT_W/2;
        bolt([x, cy - dy, TWOBY_T], "+z");
        bolt([x, cy + dy, TWOBY_T], "+z");
    }
}
