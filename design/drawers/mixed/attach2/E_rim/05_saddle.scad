// 05_saddle.scad
// RETROFIT: "Saddle" end-bracket — a tall U-channel at each SHORT end of the new tray.
// Each saddle straddles the top tray's short-end outer wall from outside,
// and a wide shelf at the top hooks OVER the top rim along the entire end width.
// Unlike corner clips (point-grab) this spans the full 102 mm short-end width.
// Engagement: lower top tray straight down into both saddle channels.
// Release: tilt top tray (rock one end up) to unhook it from the saddles.
// TOP TRAY FIXED — NO geometry added to it.
//
// LEFT: ENGAGED  |  RIGHT: EXPLODED (top tray tilted/lifted)

TW = 305; TD = 102; TH = 33;
NW = 305; ND = 102; NH = 50;
wall = 3;

// saddle geometry
sad_wall  = 4.0;   // saddle plate thickness
sad_h     = TH + 6; // saddle inner height (clears TH, leaves room for lip)
lip_ext   = 8;     // rim-hook shelf width (overhangs inward)
lip_t     = 4;     // rim-hook shelf thickness
gap       = 0.5;   // clearance inside saddle channel around top tray end wall

// The saddle channel width = TD + 2*gap (fits snugly around short end)
// The saddle wraps in Y: from y = -sad_wall-gap to y = TD+gap+sad_wall
ch_inner = TD + 2*gap;         // inner channel width in Y
ch_outer = ch_inner + 2*sad_wall; // outer width

C_new  = "#1565C0";
C_top  = "#90A4AE";
C_clip = "#00695C";  // teal — saddle brackets

sep = NW + 40;

module new_tray_body() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
    }
}

module top_tray_body(dz=0) {
    color(C_top)
    translate([0, 0, NH + dz])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}

// One saddle at x=0 end.  Local origin at (x=0, y=-gap-sad_wall, z=NH).
// Channel opens in +X (toward tray interior).
// U shape: two side walls + back face, open toward +X.
module saddle_end() {
    color(C_clip)
    union() {
        // back plate (outside face, x=0 side) — closes the U
        translate([-sad_wall, -sad_wall - gap, 0])
            cube([sad_wall, ch_outer, sad_h]);

        // front-Y side wall (y < 0)
        translate([-sad_wall, -sad_wall - gap, 0])
            cube([sad_wall + lip_ext, sad_wall, sad_h]);

        // back-Y side wall (y > TD)
        translate([-sad_wall, TD + gap, 0])
            cube([sad_wall + lip_ext, sad_wall, sad_h]);

        // rim-hook shelf at top — spans full channel outer width, inward reach
        translate([-sad_wall, -sad_wall - gap, sad_h - lip_t])
            cube([sad_wall + lip_ext, ch_outer, lip_t]);
    }
}

module all_saddles() {
    // x=0 end
    translate([0, 0, NH]) saddle_end();
    // x=NW end — mirror X
    translate([NW, 0, NH]) mirror([1,0,0]) saddle_end();
}

// ENGAGED
translate([0,0,0]) {
    new_tray_body();
    all_saddles();
    top_tray_body(0);
}

// EXPLODED (top tray lifted)
translate([sep,0,0]) {
    new_tray_body();
    all_saddles();
    top_tray_body(40);
}
