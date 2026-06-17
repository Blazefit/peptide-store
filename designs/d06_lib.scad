// d06_lib.scad — vertical STANDING pen rack (Jason's D06 concept, corrected)
// Authored + printed in the STANDING orientation (Z = up). Fixes baked in:
//  - connected rear wall (all shelves tie into one back slab)
//  - sloped/cradle shelves with 45deg+ GUSSETS underneath -> support-free
//  - front catch lip raised to the pen centerline (real retention)
//  - side-entry teardrop windows (self-supporting apex) in one end wall
//  - flared base foot for tip stability
// Inch-first intent; modeled in mm. Pen = O20mm (0.79in) x 165mm (6.5in).
include <common.scad>

LX    = PEN_L + 7;     // 172 mm  (X = pen axis, 6.77 in)
TW    = 4;             // rear wall thickness (Y)
EW    = 3;             // end wall thickness (X)
BASE_H= 5;             // base foot slab
LIPH  = 6;             // front lip rises this far above pen center
LIPW  = 3;             // front lip thickness
FLOOR = 2;             // material below the pen groove

module td2d(r) {       // teardrop, apex +Y (for self-supporting window)
    union() {
        circle(r=r);
        polygon([[0.7071*r,0.7071*r],[0,1.4142*r],[-0.7071*r,0.7071*r]]);
    }
}

module d06(n=4, pz=40, dfoot=70, z0=24) {
    zc   = [for(i=[0:n-1]) z0 + i*pz];     // pen-center heights
    yc   = TW + RCH + 4;                   // pen center Y (forward of wall)
    yf   = yc + RCH + LIPW;                // shelf front face Y
    htop = zc[n-1] + RCH + 10;
    grv0 = EW;                             // groove between the end walls
    grvL = LX - 2*EW;

    difference() {
        union() {
            // ---- connected rear wall + base foot ----
            cube([LX, TW, htop]);
            cube([LX, dfoot, BASE_H]);
            // ---- two end walls (channel ends; one gets entry windows) ----
            cube([EW, yf, htop]);
            translate([LX-EW,0,0]) cube([EW, yf, htop]);

            for (i=[0:n-1]) {
                zf = zc[i]-RCH-FLOOR;
                // shelf floor (pen sits in a groove cut from its top)
                translate([0, TW, zf]) cube([LX, yf-TW, zc[i]-zf]);
                // front catch lip (rises above the pen centerline)
                translate([0, yf-LIPW, zf]) cube([LX, LIPW, (zc[i]+LIPH)-zf]);
                // gusset under the shelf (~52deg underside -> support-free)
                translate([0, TW, zf])
                    rotate([0,-90,0]) linear_extrude(height=LX)
                        polygon([[0,0],[0,yf-TW],[1.3*(yf-TW),0]]);
            }
        }
        // ---- pen grooves (open-top cradles), capped by the end walls ----
        for (i=[0:n-1])
            translate([grv0-0.01, yc, zc[i]]) rotate([0,90,0])
                cylinder(h=grvL+0.02, r=RCH);
        // ---- side-entry teardrop windows through the near end wall ----
        for (i=[0:n-1])
            translate([-1, yc, zc[i]]) rotate([0,90,0])
                linear_extrude(height=EW+2) td2d(RCH+0.6);
    }
}
