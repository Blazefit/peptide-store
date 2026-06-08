// 03_twistbar.scad — Twist-bar cam lock
// A single rotating bar per end, pivoting on a central post.
// Bar has two lobes (one per Y end of end-wall) for a balanced 2-point engagement.
// Inspired by quarter-turn barrel fasteners.
//
// UNLOCKED (lock=0): bar aligned WITH end-wall (lobes clear of vertical lift path).
// LOCKED   (lock=1): bar rotated 90deg, lobes over end-wall top edges at z=83.
//
// Single post per end (centered in Y), bar rotates around it.

show = "all"; // [all,new,top]
lock = 1;

include <../top_ref.scad>

$fn = 48;

// ─── Tray dims ─────────────────────────────────────────────────────────
NT_X = 304.8;
NT_Y = 101.6;
NT_Z = 50;
NT_W = 3;

// ─── Key heights ───────────────────────────────────────────────────────
ENDWALL_TOP = 83.0;

// ─── Post / bar geometry ───────────────────────────────────────────────
POST_R    = 5.0;
POST_Z0   = 42.0;
POST_Z1   = 87.0;
GAP       = 0.45;

// Bar (horizontal, rotates around post Z axis)
BAR_Z0    = 82.4;    // bar bottom (slightly below end-wall top for engagement)
BAR_Z1    = 88.5;    // bar top
BAR_H     = BAR_Z1 - BAR_Z0;
BAR_THK   = 20.0;    // bar width in Y (wide for capture)

// Bar collar
COLLAR_OD = POST_R + GAP + 2.0;
COLLAR_H  = BAR_H;

// Bar arms extend from collar outward in +Y and -Y
// When locked (rotated 0°): arms point +Y and -Y → over end-wall
// When unlocked (rotated 90°): arms point +X and -X → clear of end-wall
// (end-wall is in Y direction, posts are outside in X)
//
// Wait: the end-wall is at x=0..3 (left) or x=301.8..304.8 (right), extends full Y
// Posts at x=-9 (left) and x=NT_X+9 (right).
// For the bar to reach OVER the end-wall top, it must extend in +X direction
// from the post (for left) or -X (for right), then have arm tops above z=83.
//
// Revised: bar arm extends in ±X when LOCKED (arm over end-wall), in ±Y when UNLOCKED.
// But with a SINGLE central post, a bar with TWO arms 90° apart would either
// engage or disengage simultaneously — that's a good lock bar.
//
// Actually for left end (post at x=-9):
//   Bar arm in +X direction covers end-wall (x=0..3) when rotated at angle 0°
//   Bar arm in -X direction is away from tray when rotated at angle 180° (unused, same arm other end)
//   At 90°: bar points in ±Y direction → clear of end-wall
//
// This is a symmetric bar (one arm, extends in both directions from center),
// but we only need the +X arm to engage. The -X arm is free (pointing away from tray).
// That makes it a single-lobe design with 1 arm engaged.

// Single arm per side for simplicity:
BAR_L = 13.0;  // arm length (from collar surface to tip)

// Retainer
SHOULDER_Z = BAR_Z0 - 2.0;
SHOULDER_R = COLLAR_OD + 0.6;
CAP_Z      = BAR_Z1 + GAP;
CAP_R      = COLLAR_OD + 0.6;
CAP_H      = 3.5;
KNOB_R     = 8.0;
KNOB_H     = 6.0;

// Boss
BOSS_W     = 18.0;
BOSS_YHALF = 12.0;
BOSS_Z0    = 40.0;

// Bar Y-arm half-length (for visual bar shape - aesthetic twin arms)
BAR_Y_ARM  = 20.0;  // arm extends +/-Y in unlocked state

// Post X centers
POST_XL = -9.0;
POST_XR = NT_X + 9.0;

// Bar center Y
BAR_Y = NT_Y / 2;

// ─── Angle logic ────────────────────────────────────────────────────
// Left: locked=0°(arm +X, over end-wall), unlocked=90°(arm +Y, clear)
// Right: locked=180°(arm -X, over end-wall), unlocked=90°(arm +Y, clear)
function bar_angle(lk, side) =
    (side == 0) ? (lk == 1 ? 0 : 90)
                : (lk == 1 ? 180 : 90);

// ─── Tray walls ───────────────────────────────────────────────────────
module tray_walls() {
    cube([NT_X, NT_Y, NT_W]);
    cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_Y-NT_W, 0]) cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
    translate([NT_X-NT_W, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
}

// ─── Mounting boss ─────────────────────────────────────────────────────
module end_boss(px) {
    translate([px - BOSS_W/2, BAR_Y - BOSS_YHALF, BOSS_Z0])
        cube([BOSS_W, BOSS_YHALF*2, NT_Z - BOSS_Z0]);
}

// ─── Fixed post + retainer ─────────────────────────────────────────────
module end_post(px) {
    translate([px, BAR_Y, POST_Z0]) cylinder(r=POST_R, h=POST_Z1-POST_Z0);
    translate([px, BAR_Y, SHOULDER_Z]) cylinder(r=SHOULDER_R, h=BAR_Z0-SHOULDER_Z);
    translate([px, BAR_Y, CAP_Z]) cylinder(r=CAP_R, h=CAP_H);
    translate([px, BAR_Y, CAP_Z+CAP_H]) cylinder(r=KNOB_R, h=KNOB_H);
}

// ─── Rotating twist bar ─────────────────────────────────────────────────
// Bar: collar + arm in one direction + counterbalance arm in opposite
module end_bar(px, side, lk) {
    ang = bar_angle(lk, side);
    translate([px, BAR_Y, 0])
    rotate([0, 0, ang]) {
        // Collar
        translate([0, 0, BAR_Z0])
            difference() {
                cylinder(r=COLLAR_OD, h=COLLAR_H);
                translate([0,0,-0.1]) cylinder(r=POST_R+GAP, h=COLLAR_H+0.2);
            }
        // Main engagement arm (+X direction → over end-wall when locked)
        translate([COLLAR_OD, -BAR_THK/2, BAR_Z0])
            cube([BAR_L, BAR_THK, BAR_H]);
        // Counterbalance arm (-X direction)
        translate([-COLLAR_OD-BAR_L*0.6, -BAR_THK/2, BAR_Z0])
            cube([BAR_L*0.6, BAR_THK, BAR_H]);
    }
}

// ─── New assembly ──────────────────────────────────────────────────────
module new_assembly(lk=1) {
    color("#1565C0") {
        tray_walls();
        end_boss(POST_XL);
        end_boss(POST_XR);
        end_post(POST_XL);
        end_post(POST_XR);
    }
    color("#6A1B9A") end_bar(POST_XL, 0, lk);
    color("#00897B") end_bar(POST_XR, 1, lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
