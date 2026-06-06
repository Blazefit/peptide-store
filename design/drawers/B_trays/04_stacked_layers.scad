// 04 — Two stacked tray layers using the full 5.5" (139.7 mm) height
// Lower layer: deep trays (60 mm) for syringes/pens lying flat — 2×2 grid
// Upper layer: shallower trays (52 mm) for vials standing + supplies — 2×2 grid
// Frame stack: lower frame 12 mm + lower trays 60 mm + upper frame 12 mm + upper trays 52 mm = 136 mm ≤ 139.7 mm
// Outer: 374×374×136 mm
// Split: each frame tile ~187×374 → split again: 187×187 quarters (≤240 mm); each tray 178×178 ≤ 240 mm
// $fn set externally

$fn = $fn > 0 ? $fn : 40;

WALL = 3;
GAP  = 4;
FW   = 3;   // frame wall thickness

TW   = 178;  // tray width
TD   = 178;  // tray depth
COLS = 2; ROWS = 2;

FRAME_W = 2*TW + GAP + 2*FW;   // 374
FRAME_D = FRAME_W;
FRAME_H = 12;

LOWER_TH = 60;   // lower tray height (pens lying along 160 mm... trays orient along Y)
UPPER_TH = 52;   // upper tray height (vials standing 52 mm)

LOWER_Z  = FRAME_H;
UPPER_Z  = LOWER_Z + LOWER_TH + FRAME_H;

EXPLODE_UPPER_Z = 35;

// ── Colour helpers ───────────────────────────────────────────
module fclr(lo=true) { color(lo ? [0.40,0.60,0.80,1] : [0.35,0.55,0.72,1]) children(); }
module tclr(lo=true) { color(lo ? [0.90,0.70,0.40,1] : [0.65,0.88,0.68,1]) children(); }

// ── Generic frame ────────────────────────────────────────────
module grid_frame(fh, lo=true) {
    fclr(lo) difference() {
        cube([FRAME_W, FRAME_D, fh]);
        for (r=[0:1]) for (c=[0:1]) {
            x = FW + c*(TW+GAP);
            y = FW + r*(TD+GAP);
            translate([x, y, WALL]) cube([TW, TD, fh]);
        }
    }
}

// ── Lower pen tray (deep, 3 pen lanes per tray) ───────────────
// syringes lying along Y (up to 160 mm): TD=178 ✓
module pen_tray(lifted=false, lz=0) {
    pd = 20;
    ez = lifted ? lz + EXPLODE_UPPER_Z : lz;
    tclr(true) translate([0,0,ez]) {
        difference() {
            cube([TW, TD, LOWER_TH]);
            translate([WALL,WALL,WALL]) cube([TW-2*WALL,TD-2*WALL,LOWER_TH]);
            // 3 pen lane cut-outs along Y axis
            lanes = 3;
            lw = (TW - 2*WALL - (lanes+1)*4) / lanes;
            for (i=[0:lanes-1]) {
                lx = WALL + 4 + i*(lw+4);
                translate([lx, WALL+2, -1]) cube([lw, TD-2*WALL-4, WALL+2]);
            }
            // front notch
            translate([TW/2, -1, LOWER_TH-18])
                rotate([-90,0,0]) cylinder(d=22, h=WALL+2);
        }
        translate([TW/2-14, 0, LOWER_TH-10]) cube([28, WALL, 8]);
    }
}

// ── Upper vial tray (shallower, vials standing) ───────────────
module vial_tray(lifted=false, lz=0) {
    vd = 23;
    ez = lifted ? lz + EXPLODE_UPPER_Z : lz;
    tclr(false) translate([0,0,ez]) {
        difference() {
            cube([TW, TD, UPPER_TH]);
            translate([WALL,WALL,WALL]) cube([TW-2*WALL,TD-2*WALL,UPPER_TH]);
            // 4×4 vial grid (16 vials per tray, spacing ~38 mm)
            spacing = 38;
            for (ci=[0:3]) for (ri=[0:3]) {
                vx = WALL+6+vd/2+ci*spacing;
                vy = WALL+6+vd/2+ri*spacing;
                if (vx < TW-WALL-vd/2 && vy < TD-WALL-vd/2)
                    translate([vx, vy, -1]) cylinder(d=vd, h=WALL+2);
            }
            // front notch
            translate([TW/2, -1, UPPER_TH-16])
                rotate([-90,0,0]) cylinder(d=20, h=WALL+2);
        }
        translate([TW/2-14, 0, UPPER_TH-10]) cube([28, WALL, 8]);
    }
}

// ── Assembly ─────────────────────────────────────────────────
// Lower frame
translate([0,0,0]) grid_frame(FRAME_H, lo=true);

// Lower trays (pens)
for (r=[0:1]) for (c=[0:1]) {
    tx = FW + c*(TW+GAP);
    ty = FW + r*(TD+GAP);
    translate([tx, ty, LOWER_Z]) pen_tray(lifted=false, lz=0);
}

// Upper frame (sits on top of lower trays)
translate([0,0,LOWER_Z+LOWER_TH]) grid_frame(FRAME_H, lo=false);

// Upper trays (vials) — lift back-right to show stacking
for (r=[0:1]) for (c=[0:1]) {
    tx = FW + c*(TW+GAP);
    ty = FW + r*(TD+GAP);
    lifted = (r==1 && c==1);
    translate([tx, ty, UPPER_Z]) vial_tray(lifted=lifted, lz=0);
}
