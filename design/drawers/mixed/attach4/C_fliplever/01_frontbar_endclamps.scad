// 01_frontbar_endclamps.scad
// Variant 1: Full-length front flip-bar + two end flip-clamps
// Place-then-secure: top tray drops straight down ~0.6mm loose,
// then flip levers up-and-in to lock.
//
// New tray: 304.8(X) x 101.6(Y) x 50(Z), walls 3mm, open top
// Top tray seated at z=50 (origin = new tray front-left-bottom):
//   End walls top z=83, front top-rail z=75..78, slot z=59..74

show  = "all"; // [all,new,top]
lock  = 1;     // 0=open, 1=closed

include <../top_ref.scad>

// ---- Tray constants -------------------------------------------------------
NT_X = 304.8;
NT_Y = 101.6;
NT_Z = 50;
NT_W = 3;

// Seated top-tray geometry
END_TOP_Z      = 83;   // short end walls top z
FRONT_RAIL_TOP = 78;   // front long-side top rail top
FRONT_RAIL_BOT = 75;
BACK_RAIL_TOP  = 78;
SLOT_TOP       = 74;
SLOT_BOT       = 59;

// ---- Hinge / lever params ------------------------------------------------
H_R   = 2.2;   // hinge bore radius (on tray)
H_PIN = 1.6;   // hinge pin radius (on lever, H_PIN < H_R - 0.4)
H_CLR = 0.4;   // radial clearance

LEVER_T = 4.5; // lever arm thickness (Y direction for front, X for end)
LIP_H   = 7.0; // lip height
LIP_D   = 5.0; // lip overhang depth

// Front bar: hinge along X, runs full length minus corner pockets
FB_X0 = 10;
FB_X1 = NT_X - 10;
FB_LEN = FB_X1 - FB_X0; // 284.8 mm

// Hinge position: on front wall (y~0 face), pin axis at y=H_R+0.5, z chosen
// so lever tip clears lift path when open (folds DOWN against y<0 space)
// and captures front rail at z=75..78 when closed
// Hinge z: we want open lever to stay z<=50 (folded down)
// closed: lever arm swings up-and-in; tip reaches z=front_rail_top
// Let hinge be at z=47 (3mm below new tray top), arm length ~28mm
// closed angle ~55° inward -> tip_z ~ 47 + 28*sin(55) ~ 47+23 = 70 -> ok for hooking rail

FB_HINGE_Z = 47;  // z of hinge axis
FB_HINGE_Y = NT_W + H_R + H_CLR + 0.3;  // ~6mm from front face
FB_ARM_L   = 28;  // arm length from hinge to lip root
OPEN_A  = -90; // open: folded straight down (below hinge)
CLOSE_A =  58; // closed: flipped up-and-in

// End clamps
EC_HINGE_Z   = 47;
EC_HINGE_Y0  = (NT_Y - 20) / 2;  // centered in Y
EC_W         = 20;    // clamp width in Y
EC_ARM_L     = 26;    // arm length from hinge
EC_HINGE_X_L = NT_W + H_R + H_CLR + 0.3;
EC_HINGE_X_R = NT_X - NT_W - H_R - H_CLR - 0.3;

function la(lk) = lk ? CLOSE_A : OPEN_A;

// ============================================================================
// NEW TRAY
// ============================================================================
module new_tray() {
    color("#1565C0")
    difference() {
        cube([NT_X, NT_Y, NT_Z]);
        // hollow (open top)
        translate([NT_W, NT_W, NT_W])
            cube([NT_X - 2*NT_W, NT_Y - 2*NT_W, NT_Z]);
    }
}

// ============================================================================
// FRONT BAR HINGE BOSSES (fixed on tray, part of new_tray geometry)
// Axis along X. Two short boss cylinders flanking the bar.
// ============================================================================
module front_hinge_bosses() {
    color("#1565C0")
    translate([0, FB_HINGE_Y, FB_HINGE_Z])
    rotate([0, 90, 0]) {
        // Left boss (at x=FB_X0-4..FB_X0)
        translate([0, 0, FB_X0 - 5])
            difference() {
                cylinder(h=5, r=H_R + 1.5, $fn=32);
                cylinder(h=5, r=H_R, $fn=32);
            }
        // Right boss (at x=FB_X1..FB_X1+5)
        translate([0, 0, FB_X1])
            difference() {
                cylinder(h=5, r=H_R + 1.5, $fn=32);
                cylinder(h=5, r=H_R, $fn=32);
            }
    }
}

// ============================================================================
// FRONT FLIP BAR
// Hinge pin along X axis. When open: arm folds straight DOWN (angle=-90).
// When closed: arm sweeps up-and-in (~58°) so lip captures front top rail.
// ============================================================================
module front_bar(lk) {
    ang = la(lk);
    color("#2E7D32")
    translate([FB_X0, FB_HINGE_Y, FB_HINGE_Z])
    rotate([0, 90, 0])  // now X is the hinge axis
    {
        // Pin runs along hinge axis (now local Z) for full bar length
        cylinder(h=FB_LEN, r=H_PIN, $fn=32);
        // Bar body: rotate about hinge axis
        rotate([ang, 0, 0])
        {
            // Main arm slab: extends from hinge outward
            // Local coords: Z=along bar, Y=arm direction, X=thickness
            translate([-LEVER_T/2, 0, 0])
                cube([LEVER_T, FB_ARM_L, FB_LEN]);
            // Lip at tip: hooks OVER front top rail (from above at z=78)
            // Extends inward (+Y local = inward toward tray when closed)
            translate([-LEVER_T/2, FB_ARM_L - 2, 0])
                cube([LEVER_T + LIP_D, LIP_H, FB_LEN]);
            // Finger tab (outward, -Y local = toward front when closed)
            translate([-LEVER_T/2 - 2, -8, 0])
                cube([LEVER_T + 4, 8, FB_LEN]);
        }
    }
}

// ============================================================================
// END CLAMP - LEFT (at x=0 short wall)
// Hinge axis along Y. When open: folds down/out (-x direction, angle=-90).
// When closed: sweeps in (+x, over end wall top at z=83).
// ============================================================================
module end_clamp_left(lk) {
    ang = la(lk);
    color("#EF6C00")
    translate([EC_HINGE_X_L, EC_HINGE_Y0, EC_HINGE_Z])
    rotate([90, 0, 0])  // hinge axis along Y
    {
        // pin
        cylinder(h=EC_W, r=H_PIN, $fn=32);
        // arm body
        rotate([0, ang, 0])
        {
            translate([0, -LEVER_T/2, 0])
                cube([EC_ARM_L, LEVER_T, EC_W]);
            // lip hooking over end wall top z=83
            translate([EC_ARM_L - 2, -LEVER_T/2, 0])
                cube([LIP_H, LEVER_T + LIP_D, EC_W]);
            // finger tab
            translate([-8, -LEVER_T/2 - 2, 0])
                cube([8, LEVER_T + 4, EC_W]);
        }
    }
}

// ============================================================================
// END CLAMP - RIGHT (at x=NT_X short wall)
// Mirror of left.
// ============================================================================
module end_clamp_right(lk) {
    ang = la(lk);
    color("#EF6C00")
    translate([EC_HINGE_X_R, EC_HINGE_Y0, EC_HINGE_Z])
    rotate([90, 0, 0])
    {
        cylinder(h=EC_W, r=H_PIN, $fn=32);
        rotate([0, -ang, 0])
        {
            translate([-EC_ARM_L, -LEVER_T/2, 0])
                cube([EC_ARM_L, LEVER_T, EC_W]);
            translate([-EC_ARM_L - LIP_H + 2, -LEVER_T/2, 0])
                cube([LIP_H, LEVER_T + LIP_D, EC_W]);
            translate([0, -LEVER_T/2 - 2, 0])
                cube([8, LEVER_T + 4, EC_W]);
        }
    }
}

// ============================================================================
// BACK PASSIVE TONGUE (flush in back slot y=98.6..101.6, slot z=59..74)
// Just a slim tongue on the back wall that slides into the open slot.
// Stays within y<=101.6, acts as a passive guide/backstop.
// ============================================================================
module back_tongue() {
    color("#1565C0", 0.8)
    translate([NT_W + 6, NT_Y - NT_W, SLOT_BOT + 2])
        cube([NT_X - 2*NT_W - 12, 2, (SLOT_TOP - SLOT_BOT) - 4]);
}

// ============================================================================
// ASSEMBLY
// ============================================================================
module new_assembly(lk=1) {
    new_tray();
    front_hinge_bosses();
    front_bar(lk);
    end_clamp_left(lk);
    end_clamp_right(lk);
    back_tongue();
}

if (show != "top") new_assembly(lock);
if (show != "new") top_ref(50);
