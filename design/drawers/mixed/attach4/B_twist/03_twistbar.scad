// 03_twistbar.scad — Twist-bar cam lock (T-bar profile)
// A single rotating T-bar per short end (2 total).
// The T-bar has one wide engagement arm and a narrow counterbalance.
// Twist 90° to lock; the wide arm sweeps over the end-wall top.
//
// UNLOCKED (lock=0): T-bar rotated 90°, arms point in ±Y, clear of end wall.
// LOCKED   (lock=1): T-bar in 0°/180°, wide arm over end-wall top at z=83.
//
// Design ensures unlocked arm never clips the end-wall:
// Post at x=-14, bar half-width 12mm → unlocked bar x-extent: -14±12 = -26..-2 (all x<0).

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

// ─── Post geometry ─────────────────────────────────────────────────────
POST_R    = 5.0;
POST_Z0   = 40.0;
POST_Z1   = 87.0;
GAP       = 0.45;

COLLAR_OD = POST_R + GAP + 2.0;  // = 7.45

// T-bar geometry — tuned for both cams to give >= 200mm^3 capture
// Engagement arm: extends in +X (locked) or +Y (unlocked)
// With 2 cams and BAR_W=20mm:
//   capture: 2*3*20*(85-BAR_Z0)*0.8 >= 200 → BAR_Z0 <= 82.92
//   seat: 2*3*20*(83-BAR_Z0)*0.8 <= 60 → BAR_Z0 >= 82.375
// Choose BAR_Z0 = 82.4
BAR_Z0    = 82.4;
BAR_Z1    = 88.5;
BAR_L     = 14.0;   // engagement arm length (+X direction when locked)
BAR_W     = 20.0;   // arm width in Y

// Post X positions — far enough that unlocked arms (at 90°) don't clip end wall
// Unlocked at 90°: arm in +Y, bar half-width BAR_W/2=10mm in X
// Need POST_XL + BAR_W/2 < 0 → POST_XL < -10 → use -14.0
POST_XL = -14.0;
POST_XR  = NT_X + 14.0;  // 318.8

// Retainer
SHOULDER_Z = BAR_Z0 - 2.5;
SHOULDER_R = COLLAR_OD + 0.8;
CAP_Z      = BAR_Z1 + GAP;
CAP_R      = COLLAR_OD + 0.8;
CAP_H      = 3.5;
KNOB_R     = 7.5;
KNOB_H     = 5.5;

// Boss
BOSS_W     = 18.0;
BOSS_YHALF = 12.0;
BOSS_Z0    = 40.0;

// Bar Y center
BAR_Y = NT_Y / 2;  // 50.8

// ─── Angle logic ─────────────────────────────────────────────────────
// Left: locked=0°(arm +X, inward), unlocked=90°(arm +Y, clear)
// Right: locked=180°(arm -X, inward), unlocked=90°(arm +Y, clear)
function bar_angle(lk, side) =
    (side == 0) ? (lk == 1 ?   0 : 90)
                : (lk == 1 ? 180 : 90);

// ─── Tray walls ────────────────────────────────────────────────────────
module tray_walls() {
    cube([NT_X, NT_Y, NT_W]);
    cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_Y-NT_W, 0]) cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
    translate([NT_X-NT_W, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
}

// ─── Mounting boss ──────────────────────────────────────────────────────
module end_boss(px) {
    translate([px - BOSS_W/2, BAR_Y - BOSS_YHALF, BOSS_Z0])
        cube([BOSS_W, BOSS_YHALF*2, NT_Z - BOSS_Z0]);
}

// ─── Fixed post + retainer ─────────────────────────────────────────────
module end_post(px) {
    translate([px, BAR_Y, POST_Z0])
        cylinder(r=POST_R, h=POST_Z1 - POST_Z0);
    translate([px, BAR_Y, SHOULDER_Z])
        cylinder(r=SHOULDER_R, h=BAR_Z0 - SHOULDER_Z);
    translate([px, BAR_Y, CAP_Z])
        cylinder(r=CAP_R, h=CAP_H);
    translate([px, BAR_Y, CAP_Z + CAP_H])
        cylinder(r=KNOB_R, h=KNOB_H);
}

// ─── Rotating T-bar (manifold-safe) ────────────────────────────────────
// Engagement arm extends from x=0 (overlaps collar) in +X direction.
// Post hole punched by single difference() at bar level.
module end_bar(px, side, lk) {
    ang = bar_angle(lk, side);
    translate([px, BAR_Y, 0])
    rotate([0, 0, ang])
    difference() {
        union() {
            // Collar (solid, hole punched below)
            translate([0, 0, BAR_Z0])
                cylinder(r=COLLAR_OD, h=BAR_Z1 - BAR_Z0);
            // Engagement arm (starts at x=0 to overlap collar)
            translate([0, -BAR_W/2, BAR_Z0])
                cube([COLLAR_OD + BAR_L, BAR_W, BAR_Z1 - BAR_Z0]);
            // Counterbalance arm in -X direction (narrow, for balance)
            translate([-COLLAR_OD - BAR_L*0.4, -BAR_W*0.3, BAR_Z0])
                cube([COLLAR_OD*2 + BAR_L*0.4, BAR_W*0.6, BAR_Z1 - BAR_Z0]);
        }
        // Post hole
        translate([0, 0, BAR_Z0 - 0.1])
            cylinder(r=POST_R + GAP, h=BAR_Z1 - BAR_Z0 + 0.2);
    }
}

// ─── New assembly ────────────────────────────────────────────────────
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
