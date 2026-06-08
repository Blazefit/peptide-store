// 02_widecam.scad — Quarter-turn WIDE single cam per end
// One wide cam per short end (2 total), wide arm for large engagement area.
// Demonstrates that even 2 cams (vs 4 in 01) can meet the capture threshold.
//
// UNLOCKED (lock=0): lobe points OUTWARD, clear of all top-tray geometry.
// LOCKED   (lock=1): 90 deg twist → lobe INWARD over z=83 end-wall top edge.

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

// ─── Post / cam geometry ───────────────────────────────────────────────
POST_R    = 5.5;
POST_Z0   = 40.0;
POST_Z1   = 87.5;
GAP       = 0.45;

COLLAR_OD = POST_R + GAP + 2.2;  // = 8.15

// Wide lobe parameters — tuned for capture >= 200 and seat <= 60
// With 2 wide cams and LOBE_W=22:
//   seat: 2 * 3(end wall) * 22 * (83 - LOBE_Z0) * 0.8 <= 60 → LOBE_Z0 >= 82.47
//   capture: 2 * 3 * 22 * (85 - LOBE_Z0) * 0.8 >= 200 → LOBE_Z0 <= 82.95
// Choose LOBE_Z0 = 82.5 (midpoint)
LOBE_Z0   = 82.5;
LOBE_Z1   = 89.0;
LOBE_L    = 14.0;
LOBE_W    = 22.0;

// Retainer geometry
SHOULDER_Z = LOBE_Z0 - 2.5;
SHOULDER_R = COLLAR_OD + 0.8;
CAP_Z      = LOBE_Z1 + GAP;
CAP_R      = COLLAR_OD + 0.8;
CAP_H      = 3.5;
KNOB_R     = 8.5;
KNOB_H     = 6.0;

// Boss
BOSS_W     = 18.0;
BOSS_YHALF = 13.0;
BOSS_Z0    = 40.0;

// Single cam Y center
CAM_Y = NT_Y / 2;  // 50.8

// Post X centers — far enough outside so arm never clips end wall when unlocked
// Unlocked arm (pointing +Y/-Y from +X/−X): arm half-width in X = LOBE_W/2 = 11mm
// Need POST_XL + 11 < 0 → POST_XL < -11 → use -13
POST_XL = -13.5;
POST_XR = NT_X + 13.5;

// ─── Angle logic ──────────────────────────────────────────────────────
function lobe_angle(lk, side) =
    (side == 0) ? (lk == 1 ?   0 : 90)
                : (lk == 1 ? 180 : 90);
// Left: locked=0°(arm in +X, over end-wall), unlocked=90°(arm in +Y, clear)
// Right: locked=180°(arm in -X, over end-wall), unlocked=90°(arm in +Y, clear)

// ─── Tray walls (manifold union) ──────────────────────────────────────
module tray_walls() {
    cube([NT_X, NT_Y, NT_W]);                               // floor
    cube([NT_X, NT_W, NT_Z]);                               // front wall
    translate([0, NT_Y-NT_W, 0]) cube([NT_X, NT_W, NT_Z]); // back wall
    translate([0, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]); // left wall
    translate([NT_X-NT_W, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]); // right wall
}

// ─── Mounting boss ─────────────────────────────────────────────────────
module end_boss(px) {
    translate([px - BOSS_W/2, CAM_Y - BOSS_YHALF, BOSS_Z0])
        cube([BOSS_W, BOSS_YHALF*2, NT_Z - BOSS_Z0]);
}

// ─── Fixed post + shoulder + cap + knob ───────────────────────────────
module end_post(px) {
    translate([px, CAM_Y, POST_Z0])
        cylinder(r=POST_R, h=POST_Z1 - POST_Z0);
    translate([px, CAM_Y, SHOULDER_Z])
        cylinder(r=SHOULDER_R, h=LOBE_Z0 - SHOULDER_Z);
    translate([px, CAM_Y, CAP_Z])
        cylinder(r=CAP_R, h=CAP_H);
    translate([px, CAM_Y, CAP_Z + CAP_H])
        cylinder(r=KNOB_R, h=KNOB_H);
}

// ─── Rotating lobe (collar + arm) ─────────────────────────────────────
module end_lobe(px, side, lk) {
    ang = lobe_angle(lk, side);
    translate([px, CAM_Y, 0])
    rotate([0, 0, ang]) {
        // Collar
        translate([0, 0, LOBE_Z0])
            difference() {
                cylinder(r=COLLAR_OD, h=LOBE_Z1 - LOBE_Z0);
                translate([0, 0, -0.1])
                    cylinder(r=POST_R + GAP, h=LOBE_Z1 - LOBE_Z0 + 0.2);
            }
        // Wide arm
        translate([COLLAR_OD, -LOBE_W/2, LOBE_Z0])
            cube([LOBE_L, LOBE_W, LOBE_Z1 - LOBE_Z0]);
    }
}

// ─── New assembly ─────────────────────────────────────────────────────
module new_assembly(lk=1) {
    color("#1565C0") {
        tray_walls();
        end_boss(POST_XL);
        end_boss(POST_XR);
        end_post(POST_XL);
        end_post(POST_XR);
    }
    color("#6A1B9A") end_lobe(POST_XL, 0, lk);
    color("#00897B") end_lobe(POST_XR, 1, lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
