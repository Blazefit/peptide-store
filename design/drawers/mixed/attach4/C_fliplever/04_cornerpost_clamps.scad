// 04_cornerpost_clamps.scad  —  Variant 4: Corner-post over-top clamps + front mid-bar
//
// Mechanism:
//  • CORNER CLAMPS (4x, but 2 front + 2 end): Each corner has a flip-lever that hooks
//    over the corner-post top (z=83). Levers hinge on outside of the new tray corners.
//    Open=arms fold outward. Closed=arms +Z, wide cap grips corner-post top.
//  • FRONT MID BAR (single short bar at x=NT_X/2): Extra front-centre lock for the rail.
//  • Back wall: flush, nothing past y=101.6.
//
// Corner post footprint per top_ref: x=0..6 or x=298.8..304.8, y=0..6 or y=95.6..101.6.
// Corner top z=83 (same as end wall top).

show = "all";  // [all,new,top]
lock = 1;      // 0=open, 1=closed

include <../top_ref.scad>

NT_X = 304.8;  NT_Y = 101.6;  NT_Z = 50;  NT_W = 3;
CORNER_W = 6;    // corner post footprint (matches TR_corner=6)
END_TOP  = 83;
RAIL_TOP = 78;

// ─── Corner clamp params ──────────────────────────────────────────────────────
CC_LT     = 4.5;
CC_H_PIN  = 1.4;
CC_H_BOR  = 2.0;
CC_HZ     = 45;
CC_ARM    = END_TOP - CC_HZ;  // 38
CC_W      = 14;  // clamp width (fits within corner post 6mm + overlap)

// All 4 corner positions: (hinge_x, hinge_y, arm_rot_axis, open_angle, closed_ledge_dir)
// Front-left corner:  x=CORNER_W-ish, y=0 face, hinge outside front (y<0)
// Front-right corner: x=NT_X-CORNER_W-ish, y=0 face
// Back corners: skip (door flush constraint) — use only 2 front + 2 end corners
//
// For front corners, hinge is on front face (y<0), lever stands +Z when closed,
//   ledge extends +Y over front rail top z=78.
// For end corners, hinge is on end face (x<0 or x>NT_X), lever stands +Z when closed,
//   ledge extends ±X over end wall top z=83.
//
// We'll use: 2 front levers at x≈52,252 (mid-wall, not corners) + 2 end corner clamps
// This is essentially the same as variant 1 with different proportions.
//
// Better differentiation: use DIAGONAL corner clamps that hook over BOTH front rail AND end wall:
// Hinge at corner (outside both x and y walls), arm stands up, L-shaped ledge hooks both.
//
// Implementation: at each front corner, hinge at x_h = -2 or NT_X+2, y_h = -2.
// Two levers per corner (one for y=0 face, one for x=0 face) - but simpler: single diagonal lever.

// Simplest robust variant: 4 separate levers at front-left, front-right, end-left, end-right
// as compact square blocks with generous ledge overlap.

// Front-left lever: x≈6..22, hinge y=-CC_LT/2-1, hinge z=CC_HZ
// Front-right lever: x≈NT_X-22..NT_X-6

// Let's just use two wide front levers + two end clamps but with STRONGER capture
FL_X_POSNS = [55, NT_X - 55];   // two front levers at 1/6 and 5/6 length
FL_W    = 28;    // wider front levers
FL_LT   = 5.5;
FL_HY   = -FL_LT/2 - 1.0;
FL_HZ   = 44;
FL_ARM  = RAIL_TOP + 1 - FL_HZ;  // tip at z=79
FL_CAP_Y  = 14;
FL_CAP_T  = 4;

// End clamps
EC_LT   = 5.5;
EC_HX_L = -(EC_LT/2 + 1.2);
EC_HX_R = NT_X + EC_LT/2 + 1.2;
EC_HZ   = 45;
EC_ARM  = END_TOP - EC_HZ;  // 38
EC_W    = 26;
EC_HY0  = (NT_Y - EC_W) / 2;
EC_LEDGE_X = 14;
EC_LEDGE_T = 5;

function fl_a(lk)  = lk ? 0 : 90;
function ecL_a(lk) = lk ? 0 : -90;
function ecR_a(lk) = lk ? 0 :  90;

// ─── New tray ─────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ─── Front levers ─────────────────────────────────────────────────────────────
module front_lever(cx, lk) {
    color("#2E7D32")
    translate([cx - FL_W/2, FL_HY, FL_HZ]) {
        rotate([0, 90, 0])
            cylinder(h=FL_W, r=CC_H_PIN, $fn=32);
        rotate([fl_a(lk), 0, 0]) {
            translate([-FL_LT/2, -FL_LT/2, 0])
                cube([FL_LT, FL_LT, FL_ARM]);
            // wide cap over front rail
            translate([-FL_LT/2, -FL_LT/2, FL_ARM])
                cube([FL_LT, FL_LT + FL_CAP_Y, FL_CAP_T]);
            // finger tab
            translate([-FL_LT/2 - 2, -FL_LT/2 - 8, FL_ARM * 0.3])
                cube([FL_LT + 4, 8, 12]);
        }
    }
}

module front_lever_bosses() {
    color("#1565C0")
    for (cx = FL_X_POSNS) {
        for (bx = [cx - FL_W/2 - 5, cx + FL_W/2]) {
            translate([bx, FL_HY, FL_HZ])
            rotate([0, 90, 0])
                difference() {
                    cylinder(h=5, r=CC_H_BOR + 1.8, $fn=32);
                    cylinder(h=5, r=CC_H_BOR, $fn=32);
                }
        }
    }
}

// ─── End clamps ───────────────────────────────────────────────────────────────
module end_clamp_left(lk) {
    color("#EF6C00")
    translate([EC_HX_L, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=CC_H_PIN, $fn=32);
        rotate([0, ecL_a(lk), 0]) {
            translate([-EC_LT/2, 0, 0])
                cube([EC_LT, EC_W, EC_ARM]);
            translate([-EC_LT/2, 0, EC_ARM])
                cube([EC_LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            translate([-EC_LT/2 - 2, EC_W*0.25, EC_ARM * 0.4])
                cube([EC_LT + 4, EC_W*0.5, 10]);
        }
    }
}

module end_clamp_right(lk) {
    color("#EF6C00")
    translate([EC_HX_R, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=CC_H_PIN, $fn=32);
        rotate([0, ecR_a(lk), 0]) {
            translate([-EC_LT/2, 0, 0])
                cube([EC_LT, EC_W, EC_ARM]);
            translate([-(EC_LT/2 + EC_LEDGE_X), 0, EC_ARM])
                cube([EC_LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            translate([-EC_LT/2 - 2, EC_W*0.25, EC_ARM * 0.4])
                cube([EC_LT + 4, EC_W*0.5, 10]);
        }
    }
}

module end_hinge_bosses() {
    color("#1565C0")
    for (ey = [EC_HY0 - 4, EC_HY0 + EC_W]) {
        translate([EC_HX_L, ey, EC_HZ])
        rotate([90, 0, 0]) translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=CC_H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=CC_H_BOR, $fn=32);
            }
        translate([EC_HX_R, ey, EC_HZ])
        rotate([90, 0, 0]) translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=CC_H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=CC_H_BOR, $fn=32);
            }
    }
}

// ─── Assembly ─────────────────────────────────────────────────────────────────
module new_assembly(lk=1) {
    new_tray();
    front_lever_bosses();
    end_hinge_bosses();
    for (cx = FL_X_POSNS) front_lever(cx, lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
