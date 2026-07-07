// bench3_edges_dimensions.scad — edge-highlighted bench (bench3_edges)
// with dimension annotations
// (overall height, top length, top width), drawn as classic
// arrowed dimension lines with witness lines and text labels.

include <bench3_edges.scad>   // edge-styled bench, parameters included

EXPLODE = 0;   // overrides bench3_edges.scad: dimensions read best assembled

// ---- annotation style ----
DIM_COLOR = [0.12, 0.12, 0.12];
DIM_D     = 0.12;   // dimension line diameter
WIT_D     = 0.08;   // witness (extension) line diameter
ARROW_L   = 1.4;    // arrowhead length
ARROW_D   = 0.55;   // arrowhead base diameter
TXT_SIZE  = 1.8;
TXT_TH    = 0.06;   // text extrusion thickness

// top position in global coords (tracks EXPLODE)
TOP_X0 = (FRAME_LEN - TOP_LEN)/2;
TOP_Y0 = (FRAME_WID - TOP_WID)/2;
TOP_Z  = LEG_H + EXPLODE + TWOBY_T;   // upper surface of the seat

// ---- primitives ----

// cylinder from p1 to p2
module dline(p1, p2, d = DIM_D) {
    v = p2 - p1;
    L = norm(v);
    translate(p1)
        rotate([0, acos(v[2]/L), atan2(v[1], v[0])])
            cylinder(d = d, h = L, $fn = 12);
}

// arrowhead cone with its tip at p, pointing along u
module dcone(p, u) {
    v = u / norm(u);
    translate(p - v*ARROW_L)
        rotate([0, acos(v[2]), atan2(v[1], v[0])])
            cylinder(d1 = ARROW_D, d2 = 0, h = ARROW_L, $fn = 16);
}

// dimension line between p1 and p2 with arrowheads, labeled at the
// midpoint; trot orients the text plane, toff nudges it off the line
module dim(p1, p2, label, trot = [90, 0, 0], toff = [0, 0, 0.6]) {
    u = p2 - p1;
    color(DIM_COLOR) {
        dline(p1, p2);
        dcone(p1, -u);
        dcone(p2,  u);
        translate((p1 + p2)/2 + toff)
            rotate(trot)
                linear_extrude(TXT_TH)
                    text(label, size = TXT_SIZE,
                         halign = "center", valign = "baseline");
    }
}

// thin witness line from the object out to the dimension line
module witness(p1, p2) {
    color(DIM_COLOR) dline(p1, p2, WIT_D);
}

// ---- the three annotations ----

// top length (42"), floating off the back edge of the seat so it
// projects into empty space above the bench silhouette
dim([TOP_X0, TOP_Y0 + TOP_WID + 4, TOP_Z],
    [TOP_X0 + TOP_LEN, TOP_Y0 + TOP_WID + 4, TOP_Z],
    str(TOP_LEN, "\""), toff = [0, 0, 0.8]);
witness([TOP_X0, TOP_Y0 + TOP_WID + 0.3, TOP_Z],
        [TOP_X0, TOP_Y0 + TOP_WID + 4.7, TOP_Z]);
witness([TOP_X0 + TOP_LEN, TOP_Y0 + TOP_WID + 0.3, TOP_Z],
        [TOP_X0 + TOP_LEN, TOP_Y0 + TOP_WID + 4.7, TOP_Z]);

// top width (22"), off the right-hand end of the seat
dim([TOP_X0 + TOP_LEN + 3, TOP_Y0, TOP_Z],
    [TOP_X0 + TOP_LEN + 3, TOP_Y0 + TOP_WID, TOP_Z],
    str(TOP_WID, "\""), trot = [90, 0, -90], toff = [0, 0, 0.8]);
witness([TOP_X0 + TOP_LEN + 0.3, TOP_Y0, TOP_Z],
        [TOP_X0 + TOP_LEN + 3.7, TOP_Y0, TOP_Z]);
witness([TOP_X0 + TOP_LEN + 0.3, TOP_Y0 + TOP_WID, TOP_Z],
        [TOP_X0 + TOP_LEN + 3.7, TOP_Y0 + TOP_WID, TOP_Z]);

// overall height (17"), off the front-left corner
dim([TOP_X0 - 8, TOP_Y0, 0],
    [TOP_X0 - 8, TOP_Y0, BENCH_H + EXPLODE],
    str(BENCH_H, "\""), trot = [90, 0, -45], toff = [-1.2, -1.2, 0]);
witness([TOP_X0 - 8.7, TOP_Y0, 0], [TWOBY_T, TOP_Y0, 0]);
witness([TOP_X0 - 8.7, TOP_Y0, BENCH_H + EXPLODE],
        [TOP_X0 + 0.5, TOP_Y0, BENCH_H + EXPLODE]);
