// 01_endcam.scad — Quarter-turn end-wall cam lock
// Two captive print-in-place rotating cams per short end (4 total).
//
// UNLOCKED (lock=0): lobes point OUTWARD (away from tray), clear of lift path.
// LOCKED   (lock=1): 90 deg twist, lobes INWARD over z=83 end-wall top edge.
//
// Posts are OUTSIDE top-tray x-footprint so they never touch the top tray.

show = "all"; // [all,new,top]
lock = 1;

include <../top_ref.scad>

$fn = 48;

// ─── Tray dims ────────────────────────────────────────────────────────
NT_X = 304.8;
NT_Y = 101.6;
NT_Z = 50;
NT_W = 3;

// ─── Key z heights ─────────────────────────────────────────────────────
ENDWALL_TOP = 83.0;  // top-tray end-wall top when seated

// ─── Post / cam geometry ─────────────────────────────────────────────
POST_R     = 4.0;
POST_Z0    = 44.0;  // post base z
POST_Z1    = 86.5;  // post top z
GAP        = 0.45;  // print-in-place clearance

COLLAR_OD  = POST_R + GAP + 1.8;  // rotating collar outer r

LOBE_Z0    = 82.35; // lobe bottom: 0.65mm below end-wall top → cam engages on lock
LOBE_Z1    = 88.0;  // lobe top
LOBE_L     = 11.0;  // arm length beyond collar
LOBE_W     = 8.0;   // arm width

SHOULDER_Z = LOBE_Z0 - 2.0;
SHOULDER_R = COLLAR_OD + 0.5;
CAP_Z      = LOBE_Z1 + GAP;
CAP_R      = COLLAR_OD + 0.5;
CAP_H      = 3.0;
KNOB_R     = 6.5;
KNOB_H     = 5.0;

BOSS_W     = 14.0;
BOSS_YHALF = 10.0;
BOSS_Z0    = 43.0;

// Post X centers (outside top-tray x-extents 0..304.8)
POST_XL = -7.0;
POST_XR = NT_X + 7.0;

// Cam Y positions
CAM_Y1 = 25.4;
CAM_Y2 = 76.2;

// ─── Angle logic ──────────────────────────────────────────────────────
// Left (post at x<0):  locked=1 → lobe in +X (inward), locked=0 → lobe in -X (outward)
// Right(post at x>NT_X): locked=1 → lobe in -X (inward), locked=0 → lobe in +X (outward)
function lobe_angle(lk, side) =
    (side==0) ? (lk==1 ? 0 : 180)
              : (lk==1 ? 180 : 0);

// ─── Tray body (manifold: union of walls) ──────────────────────────────
module tray_walls() {
    // Floor
    cube([NT_X, NT_Y, NT_W]);
    // Front wall (y=0)
    cube([NT_X, NT_W, NT_Z]);
    // Back wall (y=NT_Y-NT_W)
    translate([0, NT_Y-NT_W, 0]) cube([NT_X, NT_W, NT_Z]);
    // Left wall (x=0)
    translate([0, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
    // Right wall (x=NT_X-NT_W)
    translate([NT_X-NT_W, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
}

// ─── Mounting boss outside tray end ───────────────────────────────────
// Bridges from tray wall to post base
module boss(px, py) {
    translate([px - BOSS_W/2, py - BOSS_YHALF, BOSS_Z0])
        cube([BOSS_W, BOSS_YHALF*2, NT_Z - BOSS_Z0]);
}

// ─── Fixed post + retainer ────────────────────────────────────────────
module post_fixed(px, py) {
    // Post rod
    translate([px, py, POST_Z0])
        cylinder(r=POST_R, h=POST_Z1 - POST_Z0);
    // Lower shoulder (lobe collar rests on)
    translate([px, py, SHOULDER_Z])
        cylinder(r=SHOULDER_R, h=LOBE_Z0 - SHOULDER_Z);
    // Upper retainer cap
    translate([px, py, CAP_Z])
        cylinder(r=CAP_R, h=CAP_H);
    // Grip knob
    translate([px, py, CAP_Z + CAP_H])
        cylinder(r=KNOB_R, h=KNOB_H);
}

// ─── Rotating lobe (print-in-place, manifold-safe) ─────────────────────
// Arm starts from x=0 (overlaps collar) so union is clean; post hole punched
// by a single difference() at the lobe level (not inside color block).
module lobe(px, py, side, lk) {
    ang = lobe_angle(lk, side);
    translate([px, py, 0])
    rotate([0, 0, ang])
    difference() {
        union() {
            // Collar (solid cylinder, hole punched below)
            translate([0, 0, LOBE_Z0])
                cylinder(r=COLLAR_OD, h=LOBE_Z1 - LOBE_Z0);
            // Arm: starts at x=0 to overlap collar (no touching edge seam)
            translate([0, -LOBE_W/2, LOBE_Z0])
                cube([COLLAR_OD + LOBE_L, LOBE_W, LOBE_Z1 - LOBE_Z0]);
        }
        // Post-hole clearance
        translate([0, 0, LOBE_Z0 - 0.1])
            cylinder(r=POST_R + GAP, h=LOBE_Z1 - LOBE_Z0 + 0.2);
    }
}

// ─── Passive back rail (tongue in back-slot for passive capture) ───────
// NOTE: disabled — 4 end-cams provide full security, no back rail needed.
// If re-enabled, tongue must be sized to fit in open slot z=59..74 and
// not penetrate the top-tray back wall solid sections.
module back_rail() {
    // intentionally empty
}

// ─── New assembly ────────────────────────────────────────────────────
module new_assembly(lk=1) {
    // Tray body
    color("#1565C0") {
        tray_walls();
        back_rail();
        for (cy=[CAM_Y1, CAM_Y2]) {
            boss(POST_XL, cy);
            boss(POST_XR, cy);
            post_fixed(POST_XL, cy);
            post_fixed(POST_XR, cy);
        }
    }
    // Rotating lobes
    for (cy=[CAM_Y1, CAM_Y2]) {
        color("#6A1B9A") lobe(POST_XL, cy, 0, lk);
        color("#00897B") lobe(POST_XR, cy, 1, lk);
    }
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
