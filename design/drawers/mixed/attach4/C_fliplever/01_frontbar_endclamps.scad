// 01_frontbar_endclamps.scad  —  Variant 1: full-length front flip-bar + two end cam-clamps
//
// Mechanism:
//  • Front bar: pin-hinge on new tray's front face (y<0 side). Open=arm hangs in −Y.
//    Closed=arm stands +Z, hook cap (z≈79..82) sits over front rail top (z=78), blocks lift.
//  • End clamps: pin-hinge on each short end face (x<0 and x>NT_X). Open=arm outward.
//    Closed=arm +Z, catch ledge wraps over end-wall top (z=83), blocks lift.
//  • Back: passive tongue flush in back slot (y≤101.6).
//
// Open levers fold OUTWARD (away from tray) — well clear of the lift path (≤z=50).
// Verify: door_flush maxY≤101.8, seat_unlocked≤60, lift_clear all≤60, capture≥200 mm^3.

show = "all";  // [all,new,top]
lock = 1;      // 0=open, 1=closed

include <../top_ref.scad>

// ─── Tray constants ──────────────────────────────────────────────────────────
NT_X = 304.8;  NT_Y = 101.6;  NT_Z = 50;  NT_W = 3;

// Seated top-tray features
RAIL_TOP = 78;   // front/back long-side top rail top face  z=78
RAIL_BOT = 75;
END_TOP  = 83;   // short end wall top face  z=83

// ─── Lever / hinge params ────────────────────────────────────────────────────
LT      = 4.0;   // lever arm thickness (mm)
H_PIN   = 1.4;   // hinge pin radius  (on lever; bore = pin + 0.6)
H_BOR   = 2.0;   // hinge bore radius  (fixed boss on tray)
CORNER  = 8;     // end clearance for front bar

// ─── Front bar ───────────────────────────────────────────────────────────────
// Hinge pin axis: X (runs the length of the bar).
// Pin centre: global y = -LT/2 - 1.0 = -3.0   (outside front face by ~1mm above tray wall)
//             global z = 47  (near new tray top)
// Open  (lock=0): rotate_x = +90  → arm body points in  -Y  (hangs outward from front)
// Closed(lock=1): rotate_x =   0  → arm body points in  +Z  (stands up)
//   Arm body y range: y_hinge-LT/2 .. y_hinge+LT/2 = -5 .. -1  (outside front wall, no overlap)
//   Hook cap at arm tip (z=FB_HZ+FB_ARM=79): extends from y=-5..6  over front rail (y=0..3).
//   Cap bottom z=79 > rail top z=78 → no overlap when seated.
//   At +2mm lift, rail rises to z=77..80; cap (z=79..82) overlaps rail (z=79..80) ✓

FB_HY   = -LT/2 - 1.0;   // -3.0 mm  (outside front face)
FB_HZ   = 47;
FB_ARM  = 32;             // arm length → tip at z=47+32=79

// Hook geometry (local, with arm in +Z at hinge origin):
HOOK_Y  = 9;    // cap Y-extent from arm (reaches y=FB_HY+LT/2+HOOK_Y toward back)
HOOK_CT = 3;    // cap thickness (Z)

FB_X0   = CORNER;
FB_X1   = NT_X - CORNER;
FB_LEN  = FB_X1 - FB_X0;   // 288.8 mm

function fb_a(lk) = lk ? 0 : 90;  // rotate_x: 0=closed(+Z), 90=open(-Y)

// ─── End clamps ──────────────────────────────────────────────────────────────
// Left clamp:  hinge x = -(LT/2+1) = -3.0, z=47
// Right clamp: hinge x = NT_X+LT/2+1 = 307.8, z=47
// Open  (lock=0, left):  rotate_y = -90 → arm points -X (outward)
// Closed(lock=1, left):  rotate_y =   0 → arm points +Z
//   Arm body x range (left): x_h-LT/2..x_h+LT/2 = -5..-1  (outside end wall)
//   Ledge at arm tip extends in +X over end wall (x=0..3):
//     ledge x span: -5..9 (12mm), y centered, z=83..87
//     Cap bottom z=83 = end-wall top → no overlap seated.
//     At +2mm lift: end wall top at z=85; ledge (z=83..87) overlaps end wall (z=52..85) → blocked ✓

EC_HX_L = -(LT/2 + 1.0);           // -3.0
EC_HX_R = NT_X + LT/2 + 1.0;       // 307.8
EC_HZ   = 46;
EC_ARM  = END_TOP - EC_HZ;          // 37  (tip z = 46+37 = 83 = END_TOP)
EC_W    = 22;    // clamp width in Y (centred)
EC_HY0  = (NT_Y - EC_W) / 2;       // 39.8

// Ledge over end wall
EC_LEDGE_X = 12;   // how far ledge extends in +X (left) / -X (right) from arm centre
EC_LEDGE_T = 4;    // ledge thickness Z
EC_LEDGE_Y = EC_W; // full clamp width

function ec_aL(lk) = lk ? 0 : -90;  // left:  0=closed, -90=open(-X)
function ec_aR(lk) = lk ? 0 : 90;   // right: 0=closed, +90=open(+X)

// ─── New tray ─────────────────────────────────────────────────────────────────
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ─── Front bar hinge bosses  (fixed on new tray, protrude from front face) ────
module front_hinge_bosses() {
    color("#1565C0")
    for (bx = [FB_X0 - 5.5, FB_X1 + 0.5]) {
        translate([bx, FB_HY, FB_HZ])
        rotate([0, 90, 0])
            difference() {
                cylinder(h=5, r=H_BOR + 1.8, $fn=32);
                cylinder(h=5, r=H_BOR, $fn=32);
            }
    }
}

// ─── Front flip bar ───────────────────────────────────────────────────────────
module front_bar(lk) {
    color("#2E7D32")
    translate([FB_X0, FB_HY, FB_HZ]) {
        // hinge pin along X
        rotate([0, 90, 0])
            cylinder(h=FB_LEN, r=H_PIN, $fn=32);
        // lever body (pivots about X axis)
        rotate([fb_a(lk), 0, 0]) {
            // arm slab (in +Z when closed)
            translate([-LT/2, -LT/2, 0])
                cube([LT, LT, FB_ARM]);
            // hook: top cap over the front rail
            // cap: local y from -LT/2 to -LT/2+LT+HOOK_Y = -LT/2..HOOK_Y+LT/2
            // global y (closed) = FB_HY + local_y = -3 + (-2..11) = -5..8
            translate([-LT/2, -LT/2, FB_ARM])
                cube([LT, LT + HOOK_Y, HOOK_CT]);
            // finger tab (outward −Y side)
            translate([-LT/2 - 1.5, -LT/2 - 8, FB_ARM * 0.35])
                cube([LT + 3, 8, 10]);
        }
    }
}

// ─── End clamp left ────────────────────────────────────────────────────────────
module end_clamp_left(lk) {
    color("#EF6C00")
    translate([EC_HX_L, EC_HY0, EC_HZ]) {
        // pin along Y (centred in clamp width)
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN, $fn=32);
        // arm (pivots about Y: closed=0→+Z, open=-90→-X)
        rotate([0, ec_aL(lk), 0]) {
            // arm slab
            translate([-LT/2, 0, 0])
                cube([LT, EC_W, EC_ARM]);
            // catch ledge at arm tip (z=EC_ARM):
            // extends in +X from arm centre → over end wall (x=0..3) when closed
            translate([-LT/2, 0, EC_ARM])
                cube([LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            // finger tab
            translate([-LT/2 - 2, EC_W*0.3, EC_ARM * 0.4])
                cube([LT + 4, EC_W * 0.4, 9]);
        }
    }
}

// ─── End clamp right ───────────────────────────────────────────────────────────
module end_clamp_right(lk) {
    color("#EF6C00")
    translate([EC_HX_R, EC_HY0, EC_HZ]) {
        rotate([90, 0, 0])
        translate([0, 0, -EC_W/2])
            cylinder(h=EC_W, r=H_PIN, $fn=32);
        // closed=0→+Z, open=+90→+X
        rotate([0, ec_aR(lk), 0]) {
            translate([-LT/2, 0, 0])
                cube([LT, EC_W, EC_ARM]);
            // catch ledge extends in -X direction → over right end wall
            translate([-(LT/2 + EC_LEDGE_X), 0, EC_ARM])
                cube([LT/2 + EC_LEDGE_X, EC_W, EC_LEDGE_T]);
            translate([-LT/2 - 2, EC_W*0.3, EC_ARM * 0.4])
                cube([LT + 4, EC_W * 0.4, 9]);
        }
    }
}

// ─── End clamp hinge bosses (fixed on new tray end walls) ─────────────────────
module end_hinge_bosses() {
    color("#1565C0")
    // Left bosses (pair flanking the clamp in Y)
    for (ey = [EC_HY0 - 5, EC_HY0 + EC_W]) {
        translate([EC_HX_L, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -5])
            difference() {
                cylinder(h=5, r=H_BOR + 1.8, $fn=32);
                cylinder(h=5, r=H_BOR, $fn=32);
            }
    }
    // Right bosses
    for (ey = [EC_HY0 - 5, EC_HY0 + EC_W]) {
        translate([EC_HX_R, ey, EC_HZ])
        rotate([90, 0, 0])
        translate([0, 0, -5])
            difference() {
                cylinder(h=5, r=H_BOR + 1.8, $fn=32);
                cylinder(h=5, r=H_BOR, $fn=32);
            }
    }
}

// ─── Back passive tongue (stays flush at y≤NT_Y=101.6) ────────────────────────
// Omitted — any feature in the back slot interferes with the top tray during vertical lift.
// The back wall of the new tray already sits flush against the top tray back wall.
module back_tongue() {}

// ─── Full assembly ─────────────────────────────────────────────────────────────
module new_assembly(lk=1) {
    new_tray();
    front_hinge_bosses();
    end_hinge_bosses();
    front_bar(lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
    back_tongue();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
