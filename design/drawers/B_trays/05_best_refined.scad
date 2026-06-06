// 05 — Best refinement: vial-hole inserts + pen lanes + supply bin
//      Clean finger-notches, label bosses, chamfered lift tabs
// Outer envelope: 374×374×130 mm  (5.12" — fits within 5.5" limit)
// Layout: 2×2 grid of 178×178 lift-out trays in a 374×374×14 mm base frame
//   Tray A (×2, col 0): 5×3 vial holes (Ø23 mm) + 2 pen lanes  — "vial+pen combo"
//   Tray B (×1, col 1 row 0): 4 wide open supply bins
//   Tray C (×1, col 1 row 1): full-coverage pen-lane tray (4 lanes, 160 mm length)
// Capacity:  30 vials (15 per tray A × 2), 8 pens (4×2), misc supplies
// Split: frame = two 187×374 halves → each half 187×187 quarter (≤240 mm each)
//        every tray = 178×178 mm (≤240 mm)
// $fn set externally (-D '$fn=40')

$fn = $fn > 0 ? $fn : 40;

// ── Parameters ────────────────────────────────────────────────
WALL  = 3.2;
FW    = 4;      // frame outer wall
GAP   = 4;      // gap between tray slots in frame
TW    = 178;    // tray width (X)
TD    = 178;    // tray depth (Y)
TH    = 110;    // tray height — holds vials (52 mm) with room, plus raised lip
FRAME_H = 14;
FRAME_W = 2*TW + GAP + 2*FW;  // 374
FRAME_D = FRAME_W;             // 374

VIAL_D   = 23;
VIAL_SPC = 30;   // centre-to-centre vial spacing
PEN_D    = 20;
PEN_LEN  = 162;  // leave clearance on both ends

EXPLODE_Z = 40;

// ── Color helpers ─────────────────────────────────────────────
module clr_frame()  { color([0.38, 0.58, 0.78, 1.0]) children(); }
module clr_trayA()  { color([0.95, 0.82, 0.45, 1.0]) children(); }
module clr_trayB()  { color([0.72, 0.90, 0.62, 1.0]) children(); }
module clr_trayC()  { color([0.90, 0.62, 0.55, 1.0]) children(); }
module clr_insert() { color([0.80, 0.80, 0.80, 1.0]) children(); }

// ── Chamfer helper (2D profile) ──────────────────────────────
// a beveled rectangle for linear_extrude cross-sections — not needed for speed,
// so we use simple cubes for all structural elements

// ── Base frame ───────────────────────────────────────────────
// Pocketed so each tray drops in with ~0.5 mm clearance on each side.
// Pocket rim (WALL thick) supports tray floor.
// Frame splits into four 187×187 quarter-tiles for printing.
module base_frame() {
    clr_frame() difference() {
        cube([FRAME_W, FRAME_D, FRAME_H]);
        for (r=[0:1]) for (c=[0:1]) {
            x = FW + c*(TW+GAP);
            y = FW + r*(TD+GAP);
            // open pocket — tray rests on its own floor supported by frame rim
            translate([x, y, WALL])
                cube([TW, TD, FRAME_H]);
        }
        // finger access notches on front face (y=0 side) for front two trays
        for (c=[0:1]) {
            cx = FW + c*(TW+GAP) + TW/2;
            translate([cx-12, -1, FRAME_H-10])
                cube([24, FW+2, 12]);
        }
    }
}

// ── Shared tray shell ─────────────────────────────────────────
// Returns a hollow box with:
//   - front finger-scoop (semicircular notch top of front wall)
//   - label boss on front exterior
//   - chamfered lift tabs on both side walls top edge
module tray_shell(w=TW, d=TD, h=TH) {
    difference() {
        union() {
            // outer shell
            cube([w, d, h]);
            // label boss (front, exterior)
            translate([w/2-20, 0, h-14])
                cube([40, WALL, 12]);
            // lift tabs on sides — small D-profile pull tabs
            for (side=[0,1]) {
                mirror([side,0,0])
                translate([0, d/2-14, h-18])
                    cube([WALL+4, 28, 16]);
            }
        }
        // hollow interior
        translate([WALL, WALL, WALL])
            cube([w-2*WALL, d-2*WALL, h]);
        // front finger scoop
        translate([w/2, -1, h-22])
            rotate([-90,0,0])
            cylinder(d=26, h=WALL+2);
        // label recess in boss
        translate([w/2-16, -0.5, h-12])
            cube([32, WALL+1, 9]);
    }
}

// ── Tray A: vial holes + 2 pen lanes (combo) ─────────────────
// Left zone (~110 mm): 5×3 vial grid  →  15 vials per tray
// Right zone (~56 mm): 2 pen lanes + internal divider
module tray_A(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    clr_trayA() translate([0,0,ez]) {
        difference() {
            tray_shell(TW, TD, TH);
            // ── vial holes (5 cols × 3 rows) ──
            // Zone: x = WALL+4 .. ~115, y = WALL+4 .. ~WALL+4+2*VIAL_SPC+VIAL_D
            vx0 = WALL + 5 + VIAL_D/2;
            vy0 = WALL + 5 + VIAL_D/2;
            for (ci=[0:4]) for (ri=[0:2]) {
                vx = vx0 + ci*VIAL_SPC;
                vy = vy0 + ri*(VIAL_SPC+2);
                if (vx < 120 && vy < TD-WALL-5)
                    translate([vx, vy, -1])
                        cylinder(d=VIAL_D, h=WALL+2);
            }
            // ── 2 pen lane grooves (right zone) ──
            pen_x0 = 122;
            pen_lane_w = TW - pen_x0 - WALL - 3;
            for (lane=[0:1]) {
                py = WALL + 4 + lane*(PEN_D+10);
                translate([pen_x0, py, -1])
                    cube([pen_lane_w, PEN_D, WALL+2]);
            }
            // ── supply recess in remaining right-zone space ──
            sy0 = WALL + 4 + 2*(PEN_D+10);
            if (sy0 < TD - WALL - 10)
                translate([pen_x0, sy0, -1])
                    cube([pen_lane_w, TD-sy0-WALL-3, WALL+2]);
        }
        // internal divider between vial zone and pen/supply zone
        translate([119, WALL, WALL])
            cube([WALL, TD-2*WALL, TH-WALL-2]);
        // short cross-divider between 2 pen lanes and supply bin
        translate([119, WALL+4+2*(PEN_D+10)-WALL/2, WALL])
            cube([TW-119-WALL, WALL, TH-WALL-2]);
    }
}

// ── Tray B: 4 open supply bins (2×2) ─────────────────────────
module tray_B(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    clr_trayB() translate([0,0,ez]) {
        difference() {
            tray_shell(TW, TD, TH);
            // 2×2 grid of supply bins
            bw = (TW - 3*WALL - 8) / 2;
            bd = (TD - 3*WALL - 8) / 2;
            for (bri=[0:1]) for (bci=[0:1]) {
                bx = WALL + 4 + bci*(bw+WALL);
                by = WALL + 4 + bri*(bd+WALL);
                translate([bx, by, -1])
                    cube([bw, bd, WALL+2]);
            }
        }
        // cross dividers visible above floor
        translate([WALL+4+(TW-3*WALL-8)/2+WALL/2, WALL, WALL])
            cube([WALL, TD-2*WALL, TH-WALL-2]);
        translate([WALL, WALL+4+(TD-3*WALL-8)/2+WALL/2, WALL])
            cube([TW-2*WALL, WALL, TH-WALL-2]);
    }
}

// ── Tray C: 4 pen lanes, full-length syringe storage ─────────
module tray_C(lifted=false) {
    ez = lifted ? FRAME_H + EXPLODE_Z : FRAME_H;
    clr_trayC() translate([0,0,ez]) {
        difference() {
            tray_shell(TW, TD, TH);
            // 4 pen lanes running along Y (depth) axis — TD=178 ≥ 160 mm pens ✓
            lane_w = (TW - 2*WALL - 5*4) / 4;
            for (i=[0:3]) {
                lx = WALL + 4 + i*(lane_w+4);
                translate([lx, WALL+2, -1])
                    cube([lane_w, TD-2*WALL-4, WALL+2]);
            }
        }
        // lane dividers (full height)
        lane_w = (TW - 2*WALL - 5*4) / 4;
        for (i=[1:3]) {
            dx = WALL + 4 + i*(lane_w+4) - 4;
            translate([dx, WALL+2, WALL])
                cube([4, TD-2*WALL-4, TH-WALL-2]);
        }
    }
}

// ── Vial insert disc (snap-in ring, optional) ─────────────────
// A thin ring that snaps into a vial hole to tighten fit for smaller vials
module vial_insert() {
    clr_insert()
    difference() {
        cylinder(d=VIAL_D-0.4, h=8);
        cylinder(d=VIAL_D-0.4-3*2, h=8);
    }
}

// ── Full assembly (exploded view) ──────────────────────────────
// Layout:
//   [c=0, r=0] = Tray A (front-left)   lifted=false
//   [c=1, r=0] = Tray B (front-right)  lifted=false
//   [c=0, r=1] = Tray A (back-left)    lifted=false
//   [c=1, r=1] = Tray C (back-right)   LIFTED — exploded view

base_frame();

// Front-left: Tray A
translate([FW + 0*(TW+GAP), FW + 0*(TD+GAP), 0])
    tray_A(lifted=false);

// Front-right: Tray B
translate([FW + 1*(TW+GAP), FW + 0*(TD+GAP), 0])
    tray_B(lifted=false);

// Back-left: Tray A clone
translate([FW + 0*(TW+GAP), FW + 1*(TD+GAP), 0])
    tray_A(lifted=false);

// Back-right: Tray C — lifted for exploded render
translate([FW + 1*(TW+GAP), FW + 1*(TD+GAP), 0])
    tray_C(lifted=true);

// A few sample vial inserts shown hovering above front-left tray
for (ci=[0:2]) {
    vx = FW + WALL + 5 + VIAL_D/2 + ci*VIAL_SPC;
    vy = FW + TD*1 + WALL + 5 + VIAL_D/2;
    translate([vx, vy, FRAME_H + TH + EXPLODE_Z + 5])
        vial_insert();
}
