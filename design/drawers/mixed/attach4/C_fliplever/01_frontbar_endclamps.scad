// 01_frontbar_endclamps.scad  —  Variant 1: front flip-bar + two end cam-clamps
// Place-then-secure: top tray drops straight down (~0.6 mm loose), levers lock it.
//
// New tray origin = front-left-bottom:  304.8 x 101.6 x 50 mm, 3 mm walls
// Seated top tray (z=50 base):
//   End walls top z=83   |  Front rail z=75..78  |  Back y=98.6..101.6 flush

show = "all";  // [all,new,top]
lock = 1;      // 0=open, 1=closed

include <../top_ref.scad>

// ─── Tray dims ──────────────────────────────────────────────────────────────
NT_X = 304.8;  NT_Y = 101.6;  NT_Z = 50;  NT_W = 3;

// Seated top-tray features
FRONT_RAIL_TOP = 78;
END_TOP_Z      = 83;

// ─── Lever / hinge params ───────────────────────────────────────────────────
LT       = 4.5;   // lever arm thickness
H_PIN_R  = 1.6;   // hinge pin radius  (on moving lever)
H_BOR_R  = 2.2;   // hinge bore radius (fixed boss, 0.6 mm gap)
CORNER   = 8;     // corner pocket clearance

// ─── Front bar geometry ─────────────────────────────────────────────────────
// Hinge axis runs along global X.  Pin centre: y=LT/2 (flush outer), z=47.
// Open  (lock=0): arm rotated +90° about X → arm points −Z, tip z=47−32=15. Clear.
// Closed(lock=1): arm at 0° → arm points +Z, tip z=47+32=79.
//   Hook at tip: top cap extends +Y, then catch wall drops −Z to z≈72, gripping rail top z=78.

FB_HY  = LT / 2;  // 2.25 mm from y=0
FB_HZ  = 47;
FB_ARM = 32;
FB_X0  = CORNER;
FB_X1  = NT_X - CORNER;
FB_LEN = FB_X1 - FB_X0;   // 288.8 mm

HOOK_Y_EXT = 9;    // hook top-cap Y extension (into tray interior)
HOOK_CAP_T = 2.5;  // cap thickness (Z)
HOOK_WALL  = 8;    // catch wall height (Z drop from cap)

// ─── End clamp geometry ─────────────────────────────────────────────────────
// Hinge axis along global Y.  Left: pin centre x=LT/2, z=46.  Right: x=NT_X-LT/2, z=46.
// Open : arm rotated 90° about Y → arm points ±X (outward), tip clears lift path.
// Closed: arm at 0° → arm points +Z, tip z=46+37=83 = end wall top.
//   Hook clips over end wall top edge.

EC_HZ    = 46;
EC_ARM   = 37;    // 46+37=83 = END_TOP_Z ✓
EC_W     = 22;    // lever width in Y, centred
EC_HY0   = (NT_Y - EC_W) / 2;  // y-start of lever  (centred)
EC_HOOK_D = 9;    // X-depth of catch lip over end wall
EC_HOOK_T = 3;    // lip thickness Z
EC_CAP_Z  = 3;    // cap at arm tip

// ─── Angle helpers ──────────────────────────────────────────────────────────
// fb_angle: rotation about X of front bar  (0=up/closed, 90=down/open)
// ec_angle: rotation about Y of end clamps (0=up/closed, 90=out/open)
function fb_angle(lk) = lk ? 0 : 90;   // front bar: 0=closed(+Z), 90=open(−Y outward)
function ec_angle_L(lk) = lk ? 0 : -90; // left clamp: 0=closed(+Z), −90=open(−X outward)
function ec_angle_R(lk) = lk ? 0 : 90;  // right clamp: 0=closed(+Z), +90=open(+X outward)

// ─── New tray ────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ─── Front bar hinge bosses (fixed, part of new tray geometry) ────────────
module front_hinge_bosses() {
    color("#1565C0")
    for (bx = [FB_X0 - 5.5, FB_X1 + 0.5]) {
        translate([bx, FB_HY, FB_HZ])
        rotate([0, 90, 0])
            difference() {
                cylinder(h=5, r=H_BOR_R + 1.5, $fn=32);
                cylinder(h=5, r=H_BOR_R, $fn=32);
            }
    }
}

// ─── Front flip bar (moving lever) ───────────────────────────────────────────
module front_bar(lk) {
    color("#2E7D32")
    translate([FB_X0, FB_HY, FB_HZ]) {
        // Pin runs along X (use rotate [0,90,0] to orient cylinder along X)
        rotate([0, 90, 0])
            cylinder(h=FB_LEN, r=H_PIN_R, $fn=32);
        // Lever body pivots about X:
        rotate([fb_angle(lk), 0, 0]) {
            // Arm slab (default: arm along +Z from origin)
            translate([-LT/2, -LT/2, 0])
                cube([LT, LT, FB_ARM]);
            // Hook at tip  (at local z=FB_ARM):
            // top cap: extends in +Y (into tray when closed)
            translate([-LT/2, -LT/2, FB_ARM])
                cube([LT, LT + HOOK_Y_EXT, HOOK_CAP_T]);
            // catch wall: drops −Z from far edge of cap
            translate([-LT/2, LT/2 + HOOK_Y_EXT - LT/2, FB_ARM])
                cube([LT, LT/2, -HOOK_WALL]);  // negative Z = drops down
            // Finger tab (on outward −Y side of arm, mid-height)
            translate([-LT/2 - 1.5, -LT/2 - 7, FB_ARM * 0.35])
                cube([LT + 3, 7, 10]);
        }
    }
}

// ─── Left end clamp (hinge on x≈0 short wall) ────────────────────────────
module end_clamp_left(lk) {
    color("#EF6C00")
    translate([LT/2, EC_HY0, EC_HZ]) {
        // Pin along Y
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN_R, $fn=32);
        // Arm pivots about Y: closed=0(+Z), open=−90(−X outward)
        rotate([0, ec_angle_L(lk), 0]) {
            translate([-LT/2, 0, 0])
                cube([LT, EC_W, EC_ARM]);
            // Hook: top cap at tip
            translate([-LT/2, 0, EC_ARM])
                cube([LT, EC_W, EC_CAP_Z]);
            // Catch wall on −X side (hooks over end wall)
            translate([-LT/2 - EC_HOOK_D, 0, EC_ARM])
                cube([EC_HOOK_D, EC_W, EC_HOOK_T]);
            // Finger tab
            translate([-LT/2 - 1.5, EC_W*0.3, EC_ARM * 0.4])
                cube([LT + 3, EC_W * 0.4, 9]);
        }
    }
}

// ─── Right end clamp (hinge on x≈NT_X short wall) ────────────────────────
module end_clamp_right(lk) {
    color("#EF6C00")
    translate([NT_X - LT/2, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN_R, $fn=32);
        // closed=0(+Z), open=+90(+X outward from right end)
        rotate([0, ec_angle_R(lk), 0]) {
            translate([-LT/2, 0, 0])
                cube([LT, EC_W, EC_ARM]);
            translate([-LT/2, 0, EC_ARM])
                cube([LT, EC_W, EC_CAP_Z]);
            // Catch wall on +X side
            translate([LT/2, 0, EC_ARM])
                cube([EC_HOOK_D, EC_W, EC_HOOK_T]);
            translate([-LT/2 - 1.5, EC_W*0.3, EC_ARM * 0.4])
                cube([LT + 3, EC_W * 0.4, 9]);
        }
    }
}

// Left and right hinge boss rings (fixed on new tray)
module end_hinge_bosses() {
    color("#1565C0")
    // Left bosses
    for (ey = [EC_HY0 - 5, EC_HY0 + EC_W]) {
        translate([LT/2, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -5])
            difference() {
                cylinder(h=5, r=H_BOR_R + 1.5, $fn=32);
                cylinder(h=5, r=H_BOR_R, $fn=32);
            }
    }
    // Right bosses
    for (ey = [EC_HY0 - 5, EC_HY0 + EC_W]) {
        translate([NT_X - LT/2, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -5])
            difference() {
                cylinder(h=5, r=H_BOR_R + 1.5, $fn=32);
                cylinder(h=5, r=H_BOR_R, $fn=32);
            }
    }
}

// ─── Back passive tongue (flush at y≤101.6) ────────────────────────────────
// Thin shelf on inner back face that slides into the back open slot passively.
module back_tongue() {
    color("#1565C0", 0.7)
    translate([NT_W + 12, NT_Y - NT_W, 62])
        cube([NT_X - 2*NT_W - 24, 2, 8]);
}

// ─── Full new-tray assembly ────────────────────────────────────────────────
module new_assembly(lk=1) {
    new_tray();
    front_hinge_bosses();
    end_hinge_bosses();
    front_bar(lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
    back_tongue();
}

// ─── Render ────────────────────────────────────────────────────────────────
if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
