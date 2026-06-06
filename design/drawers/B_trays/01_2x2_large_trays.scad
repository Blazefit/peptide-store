// 01 — 2×2 grid of large lift-out trays, each ~180×180 mm
// Outer envelope: 370×370×80 mm
// Split: base frame = two 185×370 halves (each ≤240 mm); each tray = 176×176 mm (≤240 mm)
// $fn set externally via -D

$fn = $fn > 0 ? $fn : 40;

// ── Global dims ──────────────────────────────────────────────
FRAME_W  = 370;
FRAME_D  = 370;
FRAME_H  = 14;   // base frame wall height
WALL     = 3;
GAP      = 4;    // gap between trays & frame inner wall

TRAY_W   = 176;
TRAY_D   = 176;
TRAY_H   = 62;   // enough for vials standing (52 mm) + floor

COLS = 2; ROWS = 2;

// Explode offset so trays read clearly
EXPLODE_Z = 30;

// ── Colours ──────────────────────────────────────────────────
module frame_color()  { color([0.55,0.75,0.85,1]) children(); }
module tray_color()   { color([0.95,0.80,0.55,1]) children(); }

// ── Base frame ───────────────────────────────────────────────
module base_frame() {
    frame_color() difference() {
        cube([FRAME_W, FRAME_D, FRAME_H]);
        // 2×2 pockets for tray feet
        for (r=[0:1]) for (c=[0:1]) {
            x = WALL + c*(TRAY_W + GAP);
            y = WALL + r*(TRAY_D + GAP);
            translate([x, y, WALL])
                cube([TRAY_W, TRAY_D, FRAME_H]);
        }
    }
}

// ── Single tray with compartments ────────────────────────────
// Each 176×176 tray has:
//   left col  (~80 mm wide): 5 vial holes (Ø23 mm)
//   right col (~88 mm wide): 2 pen lanes (Ø20 mm) + supply bin
module single_tray(lifted=false) {
    z = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    tray_color() translate([0, 0, z]) {
        difference() {
            cube([TRAY_W, TRAY_D, TRAY_H]);
            // hollow interior
            translate([WALL, WALL, WALL])
                cube([TRAY_W-2*WALL, TRAY_D-2*WALL, TRAY_H]);
            // ── vial holes (left column, 2 rows × 3 cols grid trimmed to 5) ──
            vial_d = 23; vial_r = vial_d/2;
            col_vial_w = 78;
            vx_starts = [vial_r+WALL+4, vial_r+WALL+4+28, vial_r+WALL+4+56];
            vy_starts = [vial_r+WALL+4, vial_r+WALL+4+30, vial_r+WALL+4+60, vial_r+WALL+4+90];
            for (ci=[0:2]) for (ri=[0:1]) {
                if (ci*2+ri < 5)
                translate([vx_starts[ci], vy_starts[ri], -1])
                    cylinder(d=vial_d, h=WALL+2);
            }
            // ── pen lane grooves (right column) ──
            pen_d = 20; pen_r = pen_d/2;
            for (lane=[0:1]) {
                translate([col_vial_w+WALL+4, WALL+2 + lane*(pen_d+8), -1])
                    cube([TRAY_W-col_vial_w-2*WALL-6, pen_d, WALL+2]);
            }
            // ── supply bin (right col, lower) ──
            translate([col_vial_w+WALL+4, WALL+2+(pen_d+8)*2, -1])
                cube([TRAY_W-col_vial_w-2*WALL-6, TRAY_D-(WALL+2+(pen_d+8)*2)-WALL, WALL+2]);
        }
        // centre divider between vial side and pen side
        translate([78, WALL, WALL])
            cube([WALL, TRAY_D-2*WALL, TRAY_H-WALL]);
        // finger notch indentation (front centre)
        // rendered as a recess in the front wall — already open on top
        // label boss (front exterior)
        translate([TRAY_W/2-15, 0, TRAY_H-10])
            cube([30, WALL, 8]);
    }
}

// ── Finger-notch cutout on top front edge ────────────────────
// (a half-cylinder scoop in the front wall)
module tray_with_notch(tx, ty, lifted=false) {
    translate([tx, ty, 0]) {
        difference() {
            single_tray(lifted=lifted);
            z = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
            translate([TRAY_W/2, ty==WALL ? -1 : TRAY_D+WALL, z+TRAY_H-18])
                rotate([-90,0,0]) cylinder(d=22, h=WALL+2);
        }
    }
}

// ── Assembly ─────────────────────────────────────────────────
base_frame();

for (r=[0:1]) for (c=[0:1]) {
    tx = WALL + c*(TRAY_W + GAP);
    ty = WALL + r*(TRAY_D + GAP);
    lifted = (r==1 && c==1); // lift one tray for exploded view
    translate([tx, ty, 0]) single_tray(lifted=lifted);
}
