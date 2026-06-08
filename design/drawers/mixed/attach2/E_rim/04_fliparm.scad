// 04_fliparm.scad
// RETROFIT: Flip-up lever arm — a paddle hinged on the NEW tray's outer wall.
// The hinge pivot is at the TOP of the new tray outer face (z≈NH).
// Engaged: arm hangs straight UP alongside top tray, lip curls inward over rim.
// Released: arm pivots outward & down (~90°) so tip clears the rim entirely.
// Four arms: 2 per long side (symmetric about mid-X).
// TOP TRAY FIXED — NO geometry added to it.
//
// LEFT: ENGAGED  |  RIGHT: RELEASED + EXPLODED

TW = 305; TD = 102; TH = 33;
NW = 305; ND = 102; NH = 50;
wall = 3;

// arm dims
arm_w   = 22;    // width along X
arm_t   = 4;     // thickness
arm_len = TH + 10; // length from pivot to tip (≫ TH=33 so tip clears rim)
lip_ext = 8;     // horizontal lip depth over rim
lip_t   = 4;     // lip thickness
gap     = 0.5;   // clearance between arm face and top tray outer face
pivot_r = 3;     // hinge pin radius

// Pivot sits at z = NH (new-tray top face), on the outer face.
// Local arm z=0 at pivot; arm extends in +Z (up) when angle=0.
ang_engaged  = 0;    // arm straight up, lip over rim
ang_released = 95;   // arm rotated outward past horizontal (~floor level)

C_new  = "#1565C0";
C_top  = "#90A4AE";
C_clip = "#6A1B9A";  // purple

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

// Hinge knuckle boss integral to new tray outer face.
// Centered at (0,0,0) in local space.
module hinge_knuckle() {
    color(C_new)
    rotate([0, 90, 0])
    cylinder(r=pivot_r+2.5, h=arm_w, center=true, $fn=24);
}

// Flip arm: pivot at local origin.
// Arm shaft goes in +Z from 0 to arm_len; lip at tip curls in -Y.
module flip_arm_shape(ang) {
    color(C_clip)
    rotate([ang, 0, 0])
    union() {
        // arm shaft — from pivot upward
        translate([-arm_w/2, gap, 0])
            cube([arm_w, arm_t, arm_len]);
        // lip at tip end — extends inward (-Y side, toward tray centerline)
        translate([-arm_w/2, gap - lip_ext + arm_t, arm_len - lip_t])
            cube([arm_w, lip_ext, lip_t]);
    }
}

// X positions
x_pos = [NW * 0.25, NW * 0.73];

module all_arms(ang) {
    for (xp = x_pos) {
        // FRONT side: pivot on outer face y=0, arm extends in -Y direction externally
        translate([xp, 0, NH]) {
            hinge_knuckle();
            mirror([0,1,0]) flip_arm_shape(ang);
        }
        // BACK side: pivot at y=ND
        translate([xp, ND, NH]) {
            hinge_knuckle();
            flip_arm_shape(ang);
        }
    }
}

// ENGAGED
translate([0,0,0]) {
    new_tray_body();
    all_arms(ang_engaged);
    top_tray_body(0);
}

// RELEASED + EXPLODED
translate([sep,0,0]) {
    new_tray_body();
    all_arms(ang_released);
    top_tray_body(40);
}
