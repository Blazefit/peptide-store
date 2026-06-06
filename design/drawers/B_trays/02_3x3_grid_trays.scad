// 02 — 3×3 grid of smaller trays with mixed compartment sizes
// Outer envelope: 369×369×60 mm
// Split: frame = three 123×369 strips (≤240 mm each printed flat); each tray = 117×117 mm (≤240 mm)
// $fn set externally

$fn = $fn > 0 ? $fn : 40;

WALL  = 2.8;
GAP   = 3;
COLS  = 3; ROWS  = 3;
TW    = 117;  // tray width
TD    = 117;  // tray depth
TH    = 48;   // tray height (holds syringes lying: need ~160 mm in-tray length — handled by orientation along Y)

FRAME_W = COLS*TW + (COLS+1)*WALL + (COLS-1)*GAP;  // ≈ 369
FRAME_D = ROWS*TD + (ROWS+1)*WALL + (ROWS-1)*GAP;
FRAME_H = 10;

EXPLODE_Z = 25;

module fc() { color([0.45,0.65,0.78,1]) children(); }
module tc() { color([0.90,0.72,0.45,1]) children(); }

// ── Base frame ───────────────────────────────────────────────
module base_frame() {
    fc() difference() {
        cube([FRAME_W, FRAME_D, FRAME_H]);
        for (r=[0:ROWS-1]) for (c=[0:COLS-1]) {
            x = WALL + c*(TW+GAP);
            y = WALL + r*(TD+GAP);
            translate([x, y, WALL]) cube([TW, TD, FRAME_H]);
        }
    }
}

// ── Tray types ───────────────────────────────────────────────
// type 0: vial tray — 3×3 grid of Ø23 holes
module tray_vial() {
    tc() difference() {
        cube([TW, TD, TH]);
        translate([WALL,WALL,WALL]) cube([TW-2*WALL,TD-2*WALL,TH]);
        vd=23; spacing=34;
        for (ci=[0:2]) for (ri=[0:2])
            translate([WALL+4+vd/2+ci*spacing, WALL+4+vd/2+ri*spacing, -1])
                cylinder(d=vd, h=WALL+2);
    }
}

// type 1: pen tray — 3 lanes for syringes lying along Y axis
module tray_pen() {
    pd=20;
    tc() difference() {
        cube([TW, TD, TH]);
        translate([WALL,WALL,WALL]) cube([TW-2*WALL,TD-2*WALL,TH]);
        lane_w = TW-2*WALL-4;
        for (i=[0:2]) {
            lx = WALL+2;
            ly = WALL+2 + i*(pd+5);
            translate([lx, ly, -1]) cube([lane_w, pd, WALL+2]);
        }
    }
}

// type 2: supply tray — open divided bins
module tray_supply() {
    tc() difference() {
        cube([TW, TD, TH]);
        translate([WALL,WALL,WALL]) cube([TW-2*WALL,TD-2*WALL,TH]);
        // 2 columns × 2 rows of bins
        bw=(TW-3*WALL-4)/2; bd=(TD-3*WALL-4)/2;
        for (bri=[0:1]) for (bci=[0:1])
            translate([WALL+2+bci*(bw+WALL), WALL+2+bri*(bd+WALL), -1])
                cube([bw, bd, WALL+2]);
    }
}

// ── Place a tray with optional lift ──────────────────────────
module place_tray(c, r, ttype, lift=false) {
    x = WALL + c*(TW+GAP);
    y = WALL + r*(TD+GAP);
    ez = lift ? FRAME_H + EXPLODE_Z : FRAME_H;
    translate([x, y, ez]) {
        if (ttype==0) tray_vial();
        else if (ttype==1) tray_pen();
        else tray_supply();
        // front finger notch label boss
        translate([TW/2-10, 0, TH-8]) cube([20, WALL, 6]);
    }
}

// layout: row 0 = vials, row 1 = pens, row 2 = supply
base_frame();

// row 0: all vial trays
for (c=[0:2]) place_tray(c, 0, 0);
// row 1: pen trays
for (c=[0:2]) place_tray(c, 1, 1);
// row 2: supply trays — lift middle one for exploded view
for (c=[0:2]) place_tray(c, 2, 2, lift=(c==1));
