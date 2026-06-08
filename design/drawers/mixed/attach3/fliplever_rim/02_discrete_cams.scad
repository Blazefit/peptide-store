// 02_discrete_cams.scad
// FLIP-LEVER / CAM-LATCH RIM CLAMP — Variant 2
// Discrete cam levers per side, aligned to the three existing windows on each long side.
// Each lever has a cam lobe that swings UP-AND-IN to hook over the rim (z=83).
// Print-in-place PIN hinge: a captured pin with ~0.4mm radial clearance.
// Open (lock=0): lever folds flat against the outer tray wall (outward).
// Locked (lock=1): lever swings ~90° inward, cam lobe hooks over rim.
// TOP TRAY: FIXED REFERENCE — zero geometry added.

lock = 0;

TW = 305;  TD = 102;  TH = 33;
NW = 305;  ND = 102;  NH = 50;
wall = 3;
rim_top_z = NH + TH;   // 83

// Window positions (3 per long side)
win_x = [NW * 1/4, NW * 2/4, NW * 3/4];  // 76.25, 152.5, 228.75
win_w = 45;  win_h = 16;  win_cz = 64;   // center z

// Lever geometry
lev_w   = 36;    // lever width along X (wider than window)
lev_arm = 18;    // lever arm length (radial, from hinge)
lev_t   = 3.5;  // lever thickness
cam_ext = 6;     // cam lobe horizontal reach
cam_t   = 4;     // cam lobe thickness
pin_r   = 2.0;   // hinge pin radius
pin_cl  = 0.4;   // pin clearance
boss_r  = pin_r + 2.5;  // hinge boss outer radius

// Hinge at z = NH - 6 = 44 (below top rim, above window top)
hinge_z = NH - 6;

// Detent nub
det_r = 1.1;  det_h = 0.9;

// Angles
ang_open   =  95;   // folded outward (away from tray)
ang_locked = -5;    // slightly past vertical → cam hooks over rim

bar_ang = lock ? ang_locked : ang_open;

C_new   = "#1565C0";
C_top   = "#90A4AE";
C_lever = "#2E7D32";

$fn = 48;

module new_tray() {
    color(C_new)
    difference() {
        cube([NW, ND, NH]);
        translate([wall, wall, wall])
            cube([NW-2*wall, ND-2*wall, NH]);
        // Hinge boss holes in front and back walls for each lever
        for (xp = win_x) {
            // front wall (y=0..3): bore for pin
            translate([xp, -0.1, hinge_z])
                rotate([-90, 0, 0])
                cylinder(r=pin_r + pin_cl, h=wall + 0.2);
            // back wall (y=99..102): bore for pin
            translate([xp, ND - wall - 0.1, hinge_z])
                rotate([-90, 0, 0])
                cylinder(r=pin_r + pin_cl, h=wall + 0.2);
            // detent socket on front outer face at locked position
            translate([xp, -0.1, hinge_z + lev_arm - 2])
                rotate([-90, 0, 0])
                cylinder(r=det_r + 0.15, h=det_h + 0.1);
            translate([xp, ND - wall - 0.1, hinge_z + lev_arm - 2])
                rotate([-90, 0, 0])
                cylinder(r=det_r + 0.15, h=det_h + 0.1);
        }
    }
}

module top_tray() {
    color(C_top)
    translate([0, 0, NH])
    difference() {
        cube([TW, TD, TH]);
        translate([wall, wall, 0])
            cube([TW-2*wall, TD-2*wall, TH-wall]);
    }
}

// Hinge boss pair integral to new tray front face
module hinge_bosses(xp, yside) {
    color(C_new)
    for (dx = [-lev_w/2 + 3, lev_w/2 - 3 - boss_r*2])
    translate([xp + dx, yside == 0 ? -boss_r*2 + wall : ND - wall, hinge_z - boss_r])
        cube([boss_r*2, boss_r*2, boss_r*2]);
}

// Captive pin (part of lever, printed with ~0.4mm clearance in boss bores)
module hinge_pin() {
    color(C_lever)
    rotate([-90, 0, 0])
    cylinder(r=pin_r, h=lev_w);
}

// One discrete cam lever. Local origin at hinge axis center.
// Rotates about X axis. arm goes in +Z at angle=0.
// inward_sign: direction cam hooks over rim
module cam_lever(inward_sign) {
    color(C_lever)
    rotate([bar_ang * inward_sign, 0, 0])
    union() {
        // arm body
        translate([-lev_w/2, 0, 0])
            cube([lev_w, lev_t, lev_arm]);
        // cam lobe at tip — hooks over rim
        translate([-lev_w/2, lev_t - (inward_sign > 0 ? cam_ext : 0), lev_arm - cam_t])
            difference() {
                cube([lev_w, cam_ext + lev_t, cam_t]);
                // ramp chamfer
                translate([0, cam_ext + lev_t, cam_t])
                    rotate([45, 0, 0])
                    cube([lev_w, 3, 3]);
            }
        // detent bump
        translate([0, 0, lev_arm - 2])
            rotate([90, 0, 0])
            cylinder(r=det_r, h=det_h);
        // finger tab below pivot
        translate([-lev_w/2, 0, -8])
            cube([lev_w, lev_t + 4, 7]);
        // hinge pin (captive in tray bosses)
        translate([-lev_w/2, 0, 0])
            hinge_pin();
    }
}

// Place cam levers on front (y=0) and back (y=ND) faces
module all_levers() {
    for (xp = win_x) {
        // front face: inward = +Y
        translate([xp, lev_t + 0.4, hinge_z])
            cam_lever(-1);
        // back face: inward = -Y
        translate([xp, ND - lev_t - 0.4, hinge_z])
            cam_lever(1);
    }
}

new_tray();
top_tray();
all_levers();
