// bench3.scad — slat-top bench built from 2x4 dimensional lumber
// Same as bench2.scad, plus visible bolt/screw heads at the joints
// as shown in bench1.png.
// Units: inches. X = length, Y = width, Z = height.

// ---- dimensional lumber (actual sizes) ----
TWOBY_T = 1.5;   // 2x4 thickness
TWOBY_W = 3.5;   // 2x4 width

// ---- overall design dimensions (from bench1.png) ----
TOP_LEN     = 42;    // top length
TOP_WID     = 22;    // top width
FRAME_LEN   = 36;    // apron frame outer length
FRAME_WID   = 20;    // apron frame outer width
BENCH_H     = 17;    // overall height
N_SLATS     = 6;     // slats across the 22" top

LEG_H       = BENCH_H - TWOBY_T;          // legs stop under the top slats
STRETCHER_Z = 4;                          // height of side stretcher above floor
SLAT_GAP    = (TOP_WID - N_SLATS*TWOBY_W) / (N_SLATS - 1);

EXPLODE = 9;   // lift of the top for the exploded view; set 0 to assemble

// ---- hardware ----
BOLT_D   = 0.5;    // bolt head diameter
BOLT_H   = 0.05;   // how far the head stands proud of the wood
BOLT_OFF = 0.8;    // half-spacing of a bolt pair around a joint center

wood       = [0.72, 0.45, 0.20];
wood_dark  = [0.60, 0.35, 0.15];
bolt_color = [0.25, 0.15, 0.08];
//bolt_color = [0.60, 0.35, 0.15];

// ============ lumber pieces ============

// generic 2x4 stick, laid along X, cross-section t (Z) x w (Y)
module two_by_four(length, w = TWOBY_W, t = TWOBY_T) {
    cube([length, w, t]);
}

// --- top ---
// 2x4 laid flat, full 42" length
module top_slat() {
    color(wood) two_by_four(TOP_LEN);
}

// --- apron frame (2x4s on edge) ---
// long apron rail, full 36" — runs the length of the frame
module apron_long() {
    color(wood_dark) cube([FRAME_LEN, TWOBY_T, TWOBY_W]);
}

// short apron rail, fits between the long rails
module apron_short() {
    color(wood_dark) cube([TWOBY_T, FRAME_WID - 2*TWOBY_T, TWOBY_W]);
}

// center cross rail, same as a short apron rail
module cross_rail() {
    apron_short();
}

// --- legs ---
// 2x4 leg, floor to underside of top; wide face bolts to the long apron rail
module leg() {
    color(wood) cube([TWOBY_W, TWOBY_T, LEG_H]);
}

// --- side stretcher ---
// low rail butted BETWEEN the two legs of one end, flush with
// their outer faces
module stretcher() {
    color(wood_dark)
        cube([TWOBY_T, FRAME_WID - 2*TWOBY_T - 2*TWOBY_T, TWOBY_W]);
}

// --- bottom rail ---
// cross piece along the bottom, joining the two end stretchers
// at their centers
module bottom_rail() {
    color(wood_dark)
        cube([FRAME_LEN - 2*TWOBY_T - 2*TWOBY_T, TWOBY_T, TWOBY_W]);
}

// ============ hardware ============

// round bolt/screw head lying on a wood surface
module bolt_head() {
    color(bolt_color) cylinder(d = BOLT_D, h = BOLT_H, $fn = 24);
}

// bolt head at pos, pointing out of the face whose outward
// normal is "+x", "-x", "+y", "-y" or "+z"
module bolt(pos, normal) {
    translate(pos) {
        if (normal == "+x")      rotate([0,  90, 0]) bolt_head();
        else if (normal == "-x") rotate([0, -90, 0]) bolt_head();
        else if (normal == "+y") rotate([-90, 0, 0]) bolt_head();
        else if (normal == "-y") rotate([ 90, 0, 0]) bolt_head();
        else if (normal == "+z") bolt_head();
    }
}

// vertical pair of bolts around a joint center
module bolt_pair(pos, normal) {
    bolt(pos + [0, 0,  BOLT_OFF], normal);
    bolt(pos + [0, 0, -BOLT_OFF], normal);
}

// ============ assemblies ============

module top_assembly() {
    for (i = [0 : N_SLATS-1])
        translate([0, i*(TWOBY_W + SLAT_GAP), 0])
            top_slat();
    top_hardware();
}

// screws through the top slats into the rails below: one row over
// each end rail and one over the center cross rail, two per slat
// spaced across the slat width
module top_hardware() {
    overhang = (TOP_LEN - FRAME_LEN) / 2;
    stations = [overhang + TWOBY_T/2,           // over left end rail
                TOP_LEN/2,                      // over center cross rail
                TOP_LEN - overhang - TWOBY_T/2]; // over right end rail
    for (x = stations, i = [0 : N_SLATS-1]) {
        cy = i*(TWOBY_W + SLAT_GAP) + TWOBY_W/2;
        bolt([x, cy - BOLT_OFF, TWOBY_T], "+z");
        bolt([x, cy + BOLT_OFF, TWOBY_T], "+z");
    }
}

module apron_assembly() {
    // two long rails
    translate([0, 0, 0])                     apron_long();
    translate([0, FRAME_WID - TWOBY_T, 0])   apron_long();
    // two end rails
    translate([0, TWOBY_T, 0])                       apron_short();
    translate([FRAME_LEN - TWOBY_T, TWOBY_T, 0])     apron_short();
    // center cross rail
    translate([FRAME_LEN/2 - TWOBY_T/2, TWOBY_T, 0]) cross_rail();
}

module base_hardware(leg_x, leg_y) {
    rail_zc = LEG_H - TWOBY_W/2;        // apron rail centerline height
    str_zc  = STRETCHER_Z + TWOBY_W/2;  // stretcher centerline height

    // long rails -> legs: vertical pair at each corner, front and back
    for (i = [0, 1]) {
        cx = leg_x[i] + TWOBY_W/2;
        bolt_pair([cx, 0,         rail_zc], "-y");
        bolt_pair([cx, FRAME_WID, rail_zc], "+y");
    }

    // long rails -> center cross rail: vertical pair mid-span
    bolt_pair([FRAME_LEN/2, 0,         rail_zc], "-y");
    bolt_pair([FRAME_LEN/2, FRAME_WID, rail_zc], "+y");

    // end rails -> legs: vertical pair at each joint, both ends
    for (y = leg_y) {
        cy = y + TWOBY_T/2;
        bolt_pair([0,         cy, rail_zc], "-x");
        bolt_pair([FRAME_LEN, cy, rail_zc], "+x");
    }

    // legs -> stretcher end grain: vertical pair through each leg's
    // wide face, at stretcher height
    str_cx = [leg_x[0] + TWOBY_T/2, leg_x[1] + TWOBY_W - TWOBY_T/2];
    for (x = str_cx) {
        bolt_pair([x, TWOBY_T,             str_zc], "-y");
        bolt_pair([x, FRAME_WID - TWOBY_T, str_zc], "+y");
    }

    // stretchers -> bottom rail end grain: vertical pair through each
    // stretcher's outward face, centered on the width
    bolt_pair([leg_x[0],           FRAME_WID/2, str_zc], "-x");
    bolt_pair([leg_x[1] + TWOBY_W, FRAME_WID/2, str_zc], "+x");
}

module base_assembly() {
    // apron frame sits at the top of the legs
    translate([0, 0, LEG_H - TWOBY_W]) apron_assembly();

    // legs against the inside of the long rails, inset 1.5" from each end:
    // outer faces land 33" apart along the length, 17" across the width
    leg_x = [TWOBY_T, FRAME_LEN - TWOBY_T - TWOBY_W];
    leg_y = [TWOBY_T, FRAME_WID - TWOBY_T - TWOBY_T];
    for (x = leg_x, y = leg_y)
        translate([x, y, 0]) leg();

    // side stretchers between each leg pair, flush with the legs'
    // outer (end-facing) faces
    stretcher_x = [leg_x[0], leg_x[1] + TWOBY_W - TWOBY_T];
    for (x = stretcher_x)
        translate([x, TWOBY_T + TWOBY_T, STRETCHER_Z])
            stretcher();

    // bottom cross piece spanning between the two end stretchers,
    // centered across the width
    translate([leg_x[0] + TWOBY_T, FRAME_WID/2 - TWOBY_T/2, STRETCHER_Z])
        bottom_rail();

    base_hardware(leg_x, leg_y);
}

module bench(explode = EXPLODE) {
    base_assembly();
    // top centered over the frame
    translate([(FRAME_LEN - TOP_LEN)/2, (FRAME_WID - TOP_WID)/2,
               LEG_H + explode])
        top_assembly();
}

bench();
