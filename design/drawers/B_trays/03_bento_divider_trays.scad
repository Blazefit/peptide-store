// 03 — Bento trays with removable dividers (slots moulded in)
// Outer envelope: 372×372×66 mm
// Split: 2 large bento trays (180×180) per row, 2 rows → each tray 176×176 ≤ 240 mm
//        dividers are 172×2×40 mm sticks (trivially printable)
// $fn set externally

$fn = $fn > 0 ? $fn : 40;

WALL      = 3;
TRAY_W    = 176;
TRAY_D    = 176;
TRAY_H    = 58;
FRAME_GAP = 4;
FRAME_WALL= 4;
COLS = 2; ROWS = 2;

FRAME_W = COLS*TRAY_W + (COLS-1)*FRAME_GAP + 2*FRAME_WALL;  // 372
FRAME_D = ROWS*TRAY_D + (ROWS-1)*FRAME_GAP + 2*FRAME_WALL;
FRAME_H = 12;

DIV_T = 2.4;   // divider thickness
DIV_H = 40;    // divider height (sits inside tray)
SLOT_W = DIV_T + 0.4; // slot width with clearance

EXPLODE_Z = 32;

module fc() { color([0.40,0.60,0.75,1]) children(); }
module tc() { color([0.95,0.85,0.55,1]) children(); }
module dc() { color([0.75,0.55,0.85,1]) children(); }

// ── Base frame ───────────────────────────────────────────────
module base_frame() {
    fc() difference() {
        cube([FRAME_W, FRAME_D, FRAME_H]);
        for (r=[0:ROWS-1]) for (c=[0:COLS-1]) {
            x = FRAME_WALL + c*(TRAY_W + FRAME_GAP);
            y = FRAME_WALL + r*(TRAY_D + FRAME_GAP);
            translate([x, y, WALL]) cube([TRAY_W, TRAY_D, FRAME_H]);
        }
    }
}

// ── Divider slots moulded into tray walls ────────────────────
// slots on the long (X) walls: 3 slots per wall for 4 X-divisions
// slots on the short (Y) walls: 2 slots per wall for 3 Y-divisions
module slot_cuts_x(tw, td, th, wt) {
    positions = [td*0.28, td*0.50, td*0.72];
    for (py=positions) {
        // left wall slot
        translate([wt-0.1, py-SLOT_W/2, wt+4])
            cube([SLOT_W+0.2, SLOT_W, DIV_H]);
        // right wall slot
        translate([tw-wt-SLOT_W-0.1, py-SLOT_W/2, wt+4])
            cube([SLOT_W+0.2, SLOT_W, DIV_H]);
    }
}
module slot_cuts_y(tw, td, th, wt) {
    positions = [tw*0.38, tw*0.62];
    for (px=positions) {
        translate([px-SLOT_W/2, wt-0.1, wt+4])
            cube([SLOT_W, SLOT_W+0.2, DIV_H]);
        translate([px-SLOT_W/2, td-wt-SLOT_W-0.1, wt+4])
            cube([SLOT_W, SLOT_W+0.2, DIV_H]);
    }
}

// ── Single bento tray body ────────────────────────────────────
module bento_tray(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    tc() translate([0,0,ez]) {
        difference() {
            cube([TRAY_W, TRAY_D, TRAY_H]);
            translate([WALL, WALL, WALL]) cube([TRAY_W-2*WALL, TRAY_D-2*WALL, TRAY_H]);
            slot_cuts_x(TRAY_W, TRAY_D, TRAY_H, WALL);
            slot_cuts_y(TRAY_W, TRAY_D, TRAY_H, WALL);
            // front finger scoop
            translate([TRAY_W/2, -1, TRAY_H-16])
                rotate([-90,0,0]) cylinder(d=20, h=WALL+2);
        }
        // label ledge on front
        translate([TRAY_W/2-18, 0, TRAY_H-12]) cube([36, WALL, 10]);
    }
}

// ── X-direction divider stick ─────────────────────────────────
module divider_x(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    dc() translate([WALL, 0, ez]) {
        translate([0, TRAY_D*0.28 - DIV_T/2, WALL+4])
            cube([TRAY_W-2*WALL, DIV_T, DIV_H]);
    }
}

// ── Y-direction divider stick ─────────────────────────────────
module divider_y(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    dc() translate([0, WALL, ez]) {
        translate([TRAY_W*0.38-DIV_T/2, 0, WALL+4])
            cube([DIV_T, TRAY_D-2*WALL, DIV_H]);
    }
}

// ── Assembly ─────────────────────────────────────────────────
base_frame();

for (r=[0:ROWS-1]) for (c=[0:COLS-1]) {
    tx = FRAME_WALL + c*(TRAY_W + FRAME_GAP);
    ty = FRAME_WALL + r*(TRAY_D + FRAME_GAP);
    lifted = (r==0 && c==1);
    translate([tx, ty, 0]) {
        bento_tray(lifted=lifted);
        if (!lifted) {
            divider_x(lifted=false);
            divider_y(lifted=false);
        }
    }
}
