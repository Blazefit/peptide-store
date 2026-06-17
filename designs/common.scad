// ============================================================
// common.scad — shared parameters + modules for all designs
// LOCKED PEN SPECIFICATION (do not change)
// ============================================================
PEN_L = 165;      // pen length (mm)
PEN_A = 17;       // pen cross-section minor
PEN_B = 20;       // pen cross-section major (used as diameter envelope)
CLEAR = 0.4;      // fit clearance
WALL  = 1.6;      // minimum wall thickness

$fn = 64;

RCH = PEN_B/2 + CLEAR;   // = 10.4  channel radius
EPS = 0.01;

// --- open-top U trough cut, axis along X, centered at local origin -----------
// Removes a lower half-cylinder of radius r plus a full-width vertical slot
// upward, so the channel is open at the top (no ceiling -> no overhang).
module trough_cut(len, r=RCH, top=80) {
    union() {
        rotate([0,90,0]) cylinder(h=len, r=r, center=true);
        translate([0,0,top/2]) cube([len, 2*r, top], center=true); // slot upward
    }
}

// --- teardrop hole, axis along X, centered at local origin --------------------
// 45-degree self-supporting apex pointing +Z so a horizontal bore can print
// without support.
module teardrop_cut(len, r=RCH) {
    rotate([0,90,0])
        linear_extrude(height=len, center=true)
            union() {
                circle(r=r);
                polygon([[ 0.7071*r, 0.7071*r],
                         [ 0,         1.4142*r],
                         [-0.7071*r,  0.7071*r]]);
            }
}

// --- dial relief: widened open-top pocket at one channel end -----------------
// place at the +X or -X end of a channel so the dose dial clears / can be turned
module dial_relief(end_x, r=RCH+2.2, len=28, top=80) {
    translate([end_x, 0, 0]) trough_cut(len, r, top);
}
