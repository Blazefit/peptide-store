// 03_endwall_clamps_frontledge.scad  —  Variant 3: End-wall over-top clamps + front ledge clip
//
// Mechanism:
//  • END CLAMPS (2x): L-shaped levers on the two short end walls, hinge outside the end wall.
//    Folded outward when open (arm at z<50, clear). Stand up when closed, an inward ledge
//    hooks over the end-wall top (z=83). Wide EC_W for strong grip.
//  • FRONT LEDGE (single long bar): A lever on the front face at z=44 with a shorter arm.
//    Open=folded down (-Y), closed=arm at +Z with a wide cap over the front rail (z=75..78).
//    Larger profile for better capture.
//  • Back: flush, no features past y=101.6.

show = "all";  // [all,new,top]
lock = 1;      // 0=open, 1=closed

include <../top_ref.scad>

NT_X = 304.8;  NT_Y = 101.6;  NT_Z = 50;  NT_W = 3;
RAIL_TOP = 78;
END_TOP  = 83;

// ─── End clamp params (wide, robust) ────────────────────────────────────────
EC_LT     = 5.0;   // lever thickness
EC_H_PIN  = 1.5;   // pin radius
EC_H_BOR  = 2.1;

EC_HX_L   = -(EC_LT/2 + 1.2);  // -3.7 mm
EC_HX_R   = NT_X + EC_LT/2 + 1.2;
EC_HZ     = 45;
EC_ARM    = END_TOP - EC_HZ;     // 38
EC_W      = 28;     // wide clamp in Y
EC_HY0    = (NT_Y - EC_W) / 2;  // 36.8

EC_LEDGE_X = 14;   // ledge extends over end wall
EC_LEDGE_T = 5;    // ledge height Z

function ecL_a(lk) = lk ? 0 : -90;
function ecR_a(lk) = lk ? 0 : 90;

// ─── Front ledge bar params ──────────────────────────────────────────────────
FL_LT     = 5.0;
FL_H_PIN  = 1.5;
FL_H_BOR  = 2.1;

FL_HY     = -FL_LT/2 - 1.2;  // -3.7 mm (outside front face)
FL_HZ     = 44;
FL_ARM    = RAIL_TOP - FL_HZ + 1;  // 35 → tip z=79
FL_X0     = 12;
FL_X1     = NT_X - 12;
FL_LEN    = FL_X1 - FL_X0;

FL_HOOK_Y = 13;   // large cap Y reach
FL_HOOK_T = 4;    // cap Z thickness

function fl_a(lk) = lk ? 0 : 90;

// ─── New tray ─────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ─── Front ledge bar ──────────────────────────────────────────────────────────
module front_ledge(lk) {
    color("#2E7D32")
    translate([FL_X0, FL_HY, FL_HZ]) {
        rotate([0, 90, 0])
            cylinder(h=FL_LEN, r=FL_H_PIN, $fn=32);
        rotate([fl_a(lk), 0, 0]) {
            translate([-FL_LT/2, -FL_LT/2, 0])
                cube([FL_LT, FL_LT, FL_ARM]);
            // large hook cap over front rail
            translate([-FL_LT/2, -FL_LT/2, FL_ARM])
                cube([FL_LT, FL_LT + FL_HOOK_Y, FL_HOOK_T]);
            // finger tab
            translate([-FL_LT/2 - 2, -FL_LT/2 - 8, FL_ARM * 0.3])
                cube([FL_LT + 4, 8, 12]);
        }
    }
}

module front_ledge_bosses() {
    color("#1565C0")
    for (bx = [FL_X0 - 5, FL_X1]) {
        translate([bx, FL_HY, FL_HZ])
        rotate([0, 90, 0])
            difference() {
                cylinder(h=5, r=FL_H_BOR + 1.8, $fn=32);
                cylinder(h=5, r=FL_H_BOR, $fn=32);
            }
    }
}

// ─── End clamps ───────────────────────────────────────────────────────────────
module end_clamp_left(lk) {
    color("#EF6C00")
    translate([EC_HX_L, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=EC_H_PIN, $fn=32);
        rotate([0, ecL_a(lk), 0]) {
            translate([-EC_LT/2, 0, 0])
                cube([EC_LT, EC_W, EC_ARM]);
            // ledge at tip, extends in +X over end wall
            translate([-EC_LT/2, 0, EC_ARM])
                cube([EC_LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            // finger tab
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
            cylinder(h=EC_W, r=EC_H_PIN, $fn=32);
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
        rotate([90, 0, 0])
        translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=EC_H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=EC_H_BOR, $fn=32);
            }
        translate([EC_HX_R, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -4])
            difference() {
                cylinder(h=4, r=EC_H_BOR + 1.8, $fn=32);
                cylinder(h=4, r=EC_H_BOR, $fn=32);
            }
    }
}

// ─── Assembly ─────────────────────────────────────────────────────────────────
module new_assembly(lk=1) {
    new_tray();
    front_ledge_bosses();
    end_hinge_bosses();
    front_ledge(lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
