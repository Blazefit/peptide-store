// 04_trilock.scad — Triple-point quarter-turn lock
// Two end-wall cams (one per short end) + one front-rail cam (hooks UNDER front top rail).
// 3-point locking for maximum security and front access.
//
// END CAMS: post outside x-footprint, lobe over z=83 end-wall top edge.
// FRONT CAM: post below y=0 (outside front wall), lobe under front top rail z=75..78 seated.
//   Front lobe engages the front top rail from BELOW (lobe is BELOW rail bottom z=75):
//   lobe top at z=74.8 (just below rail bottom z=75).
//   When locked (lobe under rail), lifting tray is blocked (rail pushes down on lobe underside).
//   Wait - this won't work for "blocks lift": if lobe is BELOW the rail, lifting the tray
//   takes the rail away from the lobe. The lobe needs to be ABOVE the rail.
//
// Revised front cam strategy:
//   Front lobe hooks OVER the front top rail (z=75..78 seated).
//   Lobe bottom at z=75.5 (just above rail top z=78? No.)
//   Wait: rail is z=75..78. Lobe must be ABOVE rail top (z=78) to hook over it.
//   In unlocked: lobe points -Y (away from tray), clear.
//   In locked: lobe points +Y, lobe bottom at z=78.2, extends to z=82.
//   When tray lifted: rail goes UP, hits lobe from below at z=78.2 → blocked!
//   Need lobe bottom just ABOVE rail top (z=78) with small tolerance.
//
// However: the end-wall cams already exceed 200mm^3 capture with just 2 wide cams.
// The front cam adds additional redundancy.

show = "all"; // [all,new,top]
lock = 1;

include <../top_ref.scad>

$fn = 48;

// ─── Tray dims ───────────────────────────────────────────────────────────
NT_X = 304.8;
NT_Y = 101.6;
NT_Z = 50;
NT_W = 3;

// ─── Seated z heights ────────────────────────────────────────────────────
ENDWALL_TOP  = 83.0;   // end-wall top
FRONT_RAIL_B = 75.0;   // front top rail bottom (seated z=50+25=75)
FRONT_RAIL_T = 78.0;   // front top rail top (seated z=50+28=78)

// ─── End cam geometry (same as 02_widecam but tuned) ──────────────────────
E_POST_R   = 5.5;
E_POST_Z0  = 40.0;
E_POST_Z1  = 87.5;
E_GAP      = 0.45;
E_COLL     = E_POST_R + E_GAP + 2.2;  // = 8.15

// Wide lobe for end cams — tuned for seat<=50, capture>=300
// With 2 end cams, LOBE_W=24, LOBE_Z0=82.5:
// seat: 2*3*24*(83-82.5)*0.8 = 57.6 < 60 ✓
// capture: 2*3*24*(85-82.5)*0.8 = 288 > 200 ✓
E_LOBE_Z0  = 82.5;
E_LOBE_Z1  = 89.5;
E_LOBE_L   = 14.0;
E_LOBE_W   = 24.0;

E_SHLDR_Z  = E_LOBE_Z0 - 2.5;
E_SHLDR_R  = E_COLL + 0.8;
E_CAP_Z    = E_LOBE_Z1 + E_GAP;
E_CAP_R    = E_COLL + 0.8;
E_CAP_H    = 3.5;
E_KNOB_R   = 8.5;
E_KNOB_H   = 6.0;

E_BOSS_W   = 18.0;
E_BOSS_Y   = 14.0;
E_BOSS_Z0  = 40.0;
E_CAM_Y    = NT_Y / 2;  // 50.8

// Post X centers (ensure unlocked arm x<0)
// Unlocked at 90°: arm x extent = POST_XL ± E_LOBE_W/2
// POST_XL + E_LOBE_W/2 < 0 → POST_XL < -12 → use -13.5
E_POST_XL  = -13.5;
E_POST_XR  = NT_X + 13.5;

// ─── Front cam geometry ───────────────────────────────────────────────────
// Post at y < 0, outside front wall.
// Lobe hooks OVER front top-rail (z=75..78 seated).
// Lobe bottom at z=78.3 (just above rail top z=78 with 0.3mm clearance for free seat).
// When lifted 2mm: rail top goes to z=80 → rail pushes on lobe underside.
// However: need seat_locked ≤ 60mm^3 including front cam contribution.
// Front cam lobe at z=78.3 does NOT penetrate top tray at rest (lobe bottom > rail top = 78).
// At +2 lift: rail top now at z=80, overlaps lobe (z=78.3..82) → captures!
// Front rail dimensions: x=0..304.8, y=0..3 (front wall), width 304.8mm.
// Front lobe arm covers a slice of the rail.

F_POST_R   = 4.5;
F_POST_Y   = -10.5;  // post center outside front wall (ensure all hardware stays at y<0)
F_POST_X   = NT_X / 2;  // centered (x=152.4)
F_POST_Z0  = 44.0;
F_POST_Z1  = 86.0;
F_GAP      = 0.45;
F_COLL     = F_POST_R + F_GAP + 2.0;  // = 6.95

// Front lobe — hooks over front top rail
// Lobe bottom at z=78.3 (above rail top z=78 when seated): seat = 0 ✓
// At +2 lift: rail top at z=80 < lobe top z=82 → captures
F_LOBE_Z0  = 78.3;  // just above front top rail
F_LOBE_Z1  = 82.5;
F_LOBE_L   = 9.0;   // arm length in +Y (toward tray) when locked
F_LOBE_W   = 20.0;  // arm width in X

F_SHLDR_Z  = F_LOBE_Z0 - 2.0;
F_SHLDR_R  = F_COLL + 0.8;
F_CAP_Z    = F_LOBE_Z1 + F_GAP;
F_CAP_R    = F_COLL + 0.8;
F_CAP_H    = 3.0;
F_KNOB_R   = 6.5;
F_KNOB_H   = 5.0;

F_BOSS_X   = 12.0;
F_BOSS_H   = 8.0;
F_BOSS_Z0  = NT_Z - F_BOSS_H;

// ─── Angles ───────────────────────────────────────────────────────────────
// End cams: left locked=0°, unlocked=90°; right locked=180°, unlocked=90°
function e_angle(lk, side) =
    (side == 0) ? (lk == 1 ?   0 : 90)
                : (lk == 1 ? 180 : 90);

// Front cam:
// Unlocked: arm in -Y direction (away from tray), angle = 270° (or -90°)
// Locked: arm in +Y direction (toward and under rail), angle = 90°
function f_angle(lk) = (lk == 1) ? 90 : 270;

// ─── Tray walls ──────────────────────────────────────────────────────────
module tray_walls() {
    cube([NT_X, NT_Y, NT_W]);
    cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_Y-NT_W, 0]) cube([NT_X, NT_W, NT_Z]);
    translate([0, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
    translate([NT_X-NT_W, NT_W, 0]) cube([NT_W, NT_Y-2*NT_W, NT_Z]);
}

// ─── End cam hardware ─────────────────────────────────────────────────────
module e_boss(px) {
    translate([px - E_BOSS_W/2, E_CAM_Y - E_BOSS_Y, E_BOSS_Z0])
        cube([E_BOSS_W, E_BOSS_Y*2, NT_Z - E_BOSS_Z0]);
}

module e_post(px) {
    translate([px, E_CAM_Y, E_POST_Z0])
        cylinder(r=E_POST_R, h=E_POST_Z1 - E_POST_Z0);
    translate([px, E_CAM_Y, E_SHLDR_Z])
        cylinder(r=E_SHLDR_R, h=E_LOBE_Z0 - E_SHLDR_Z);
    translate([px, E_CAM_Y, E_CAP_Z])
        cylinder(r=E_CAP_R, h=E_CAP_H);
    translate([px, E_CAM_Y, E_CAP_Z + E_CAP_H])
        cylinder(r=E_KNOB_R, h=E_KNOB_H);
}

module e_lobe(px, side, lk) {
    ang = e_angle(lk, side);
    translate([px, E_CAM_Y, 0])
    rotate([0, 0, ang])
    difference() {
        union() {
            translate([0, 0, E_LOBE_Z0])
                cylinder(r=E_COLL, h=E_LOBE_Z1 - E_LOBE_Z0);
            translate([0, -E_LOBE_W/2, E_LOBE_Z0])
                cube([E_COLL + E_LOBE_L, E_LOBE_W, E_LOBE_Z1 - E_LOBE_Z0]);
        }
        translate([0, 0, E_LOBE_Z0 - 0.1])
            cylinder(r=E_POST_R + E_GAP, h=E_LOBE_Z1 - E_LOBE_Z0 + 0.2);
    }
}

// ─── Front cam hardware ────────────────────────────────────────────────────
module f_boss() {
    translate([F_POST_X - F_BOSS_X, F_POST_Y - F_BOSS_H/2, F_BOSS_Z0])
        cube([F_BOSS_X*2, F_BOSS_H, F_BOSS_H]);
}

module f_post() {
    translate([F_POST_X, F_POST_Y, F_POST_Z0])
        cylinder(r=F_POST_R, h=F_POST_Z1 - F_POST_Z0);
    translate([F_POST_X, F_POST_Y, F_SHLDR_Z])
        cylinder(r=F_SHLDR_R, h=F_LOBE_Z0 - F_SHLDR_Z);
    translate([F_POST_X, F_POST_Y, F_CAP_Z])
        cylinder(r=F_CAP_R, h=F_CAP_H);
    translate([F_POST_X, F_POST_Y, F_CAP_Z + F_CAP_H])
        cylinder(r=F_KNOB_R, h=F_KNOB_H);
}

// Front lobe: rotates around Z axis, arm extends in +Y (toward tray) when locked
module f_lobe(lk) {
    ang = f_angle(lk);
    translate([F_POST_X, F_POST_Y, 0])
    rotate([0, 0, ang])
    difference() {
        union() {
            translate([0, 0, F_LOBE_Z0])
                cylinder(r=F_COLL, h=F_LOBE_Z1 - F_LOBE_Z0);
            // Arm extends in +Y direction (rotated: at ang=90 this is +Y global)
            translate([-F_LOBE_W/2, 0, F_LOBE_Z0])
                cube([F_LOBE_W, F_COLL + F_LOBE_L, F_LOBE_Z1 - F_LOBE_Z0]);
        }
        translate([0, 0, F_LOBE_Z0 - 0.1])
            cylinder(r=F_POST_R + F_GAP, h=F_LOBE_Z1 - F_LOBE_Z0 + 0.2);
    }
}

// ─── New assembly ──────────────────────────────────────────────────────────
module new_assembly(lk=1) {
    color("#1565C0") {
        tray_walls();
        e_boss(E_POST_XL);
        e_boss(E_POST_XR);
        e_post(E_POST_XL);
        e_post(E_POST_XR);
        f_boss();
        f_post();
    }
    color("#6A1B9A") e_lobe(E_POST_XL, 0, lk);
    color("#6A1B9A") e_lobe(E_POST_XR, 1, lk);
    color("#00897B") f_lobe(lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
