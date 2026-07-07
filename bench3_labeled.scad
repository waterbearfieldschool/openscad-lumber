// bench3_labeled.scad — bench3 with part-name callouts: floating
// text labels with leader lines pointing at one instance of each
// distinct piece of lumber. Composed for the standard view:
//   openscad --camera=-70,-60,45,0,0,0 --viewall --autocenter

include <bench3.scad>

EXPLODE = 8;   // overrides bench3.scad: exploded view shows hidden parts

// ---- callout style ----
LBL_COLOR = [0.1, 0.1, 0.1];
LEAD_D    = 0.1;    // leader line diameter
DOT_D     = 0.5;    // anchor dot on the part
LBL_SIZE  = 1.7;
LBL_TH    = 0.06;
LBL_ROT   = [90, 0, -45];   // face the standard camera

TOP_Z = LEG_H + EXPLODE + TWOBY_T;   // upper surface of the lifted top

// cylinder from p1 to p2
module lline(p1, p2, d = LEAD_D) {
    v = p2 - p1;
    L = norm(v);
    translate(p1)
        rotate([0, acos(v[2]/L), atan2(v[1], v[0])])
            cylinder(d = d, h = L, $fn = 12);
}

// label text at target+off, leader line back to a dot on the part
module callout(txt, target, off) {
    color(LBL_COLOR) {
        translate(target) sphere(d = DOT_D, $fn = 16);
        lline(target, target + off);
        translate(target + off + [0, 0, 0.4])
            rotate(LBL_ROT)
                linear_extrude(LBL_TH)
                    text(txt, size = LBL_SIZE, halign = "center");
    }
}

// ---- one callout per distinct part ----

callout("top slat",
        [10, FRAME_WID/2 + TOP_WID/2 - TWOBY_W/2, TOP_Z],
        [0, 7, 5]);

callout("long apron rail",
        [24, 0, LEG_H - TWOBY_W/2],
        [0, -16, 0]);

callout("end rail",
        [0, FRAME_WID/2, LEG_H - TWOBY_W/2],
        [-8, -7, 1]);

callout("cross rail",
        [FRAME_LEN/2, 6, LEG_H],
        [14, -10, 2]);

callout("leg",
        [TWOBY_T + TWOBY_W/2, TWOBY_T, 9],
        [-5, -5, 0]);

callout("stretcher",
        [TWOBY_T, FRAME_WID/2, STRETCHER_Z + TWOBY_W/2],
        [-6, -6, -2]);

callout("bottom rail",
        [20, FRAME_WID/2 - TWOBY_T/2, STRETCHER_Z + TWOBY_W/2],
        [-3, -13, -2]);
