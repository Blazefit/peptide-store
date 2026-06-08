// 01_corner_hooks.scad
// Snap-fit corner hook clips: four L-shaped cantilever hooks on the upper tray
// hook over a small ledge printed on the lower tray's outer rim corners.
// Engage: press upper tray down; hooks flex outward then snap under ledge.
// Release: pinch/flex two opposite hooks outward simultaneously, lift.

/* ---- global params ---- */
$fn = 36;
EXPLODE = 15;   // set 0 for engaged, >0 for exploded lift

/* ---- tray dimensions ---- */
LX = 305; LY = 102; LZ = 50;   // lower tray
UX = 305; UY = 102; UZ = 33;   // upper tray
W  = 3;                          // wall thickness

/* ---- hook params ---- */
HK_W   = 12;    // hook foot width
HK_T   = 2.8;   // cantilever arm thickness
HK_L   = 9;     // arm length (flex length)
HK_H   = 4.5;   // total hook depth past tray face
LEDGE_H = 2.0;  // ledge height on lower tray
LEDGE_P = 2.2;  // ledge protrusion
RAMP    = 1.4;  // ramp height on hook tip for self-guiding

// corner offsets from ends
CX = 18; CY = 10;

module lower_tray() {
    color("SteelBlue", 0.85)
    difference() {
        cube([LX, LY, LZ]);
        translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
    }
}

// ledge block glued to lower tray outer face at each corner
module corner_ledge(side) {
    // side: 0=front(Y=0), 1=back(Y=LY), 2=left(X=0), 3=right(X=LX)
    color("SteelBlue", 0.85)
    if (side == 0 || side == 1) {
        oy = (side == 0) ? 0 : LY;
        sy = (side == 0) ? -LEDGE_P : 0;
        for (ox = [CX, LX-CX-HK_W])
            translate([ox, oy + sy, LZ - LEDGE_H - 0.5])
                cube([HK_W, LEDGE_P, LEDGE_H]);
    } else {
        ox2 = (side == 2) ? 0 : LX;
        sx2 = (side == 2) ? -LEDGE_P : 0;
        for (oy2 = [CY, LY-CY-HK_W])
            translate([ox2 + sx2, oy2, LZ - LEDGE_H - 0.5])
                cube([LEDGE_P, HK_W, LEDGE_H]);
    }
}

module upper_tray() {
    color("Tomato", 0.85)
    difference() {
        cube([UX, UY, UZ]);
        translate([W, W, W]) cube([UX-2*W, UY-2*W, UZ]);
    }
}

// cantilever hook arm + hook tip, on upper tray outer face
// base_pt: [x,y] corner on upper tray face; dir: outward normal [dx,dy]
module hook_arm(base_pt, dir, along) {
    // arm: HK_L long in dir, HK_T thick, HK_W wide along 'along'
    ax = base_pt[0]; ay = base_pt[1];
    dx = dir[0]; dy = dir[1];
    alx = along[0]; aly = along[1];

    color("OrangeRed", 0.9)
    union() {
        // cantilever arm (thin plate extending outward)
        translate([ax, ay, -HK_H + W])
        rotate([0,0, atan2(dy,dx)])
        translate([-HK_W/2 * abs(aly), -HK_W/2 * abs(alx), 0]) // center on width
        {
            // arm body
            cube([HK_W * abs(aly) + HK_L * abs(dx),
                  HK_W * abs(alx) + HK_L * abs(dy),
                  HK_T]);
            // hook tip with ramp (snaps under ledge)
            translate([HK_L * abs(dx) + (abs(dx)>0?0:0),
                       HK_L * abs(dy) + (abs(dy)>0?0:0), 0])
            // simplified: just add a nub
            cube([HK_W * abs(aly) + (LEDGE_P+0.4)*abs(dx),
                  HK_W * abs(alx) + (LEDGE_P+0.4)*abs(dy),
                  HK_T + LEDGE_H + RAMP]);
        }
    }
}

// Simpler: parametric hook as rotate-extruded profile
module single_hook(flip=false) {
    // Hook cross-section profile (in XZ plane), width = HK_W along Y
    // arm goes in +X, hook tip curves down at the end
    f = flip ? -1 : 1;
    color("OrangeRed", 0.92)
    translate([0, -HK_W/2, 0])
    linear_extrude(HK_W)
    polygon(points=[
        [0, 0],
        [HK_L + LEDGE_P + 0.3, 0],
        [HK_L + LEDGE_P + 0.3, -(LEDGE_H + RAMP)],
        [HK_L + LEDGE_P + 0.3 - RAMP, -(LEDGE_H + RAMP)],
        [HK_L,  -LEDGE_H],
        [HK_L, -HK_T - LEDGE_H],
        [0, -HK_T - LEDGE_H]
    ]);
}

// Place hooks on upper tray perimeter corners
// Front face (Y=0): two hooks pointing in -Y
module upper_hooks() {
    Z0 = -HK_T - LEDGE_H;   // hook base flush with bottom of upper tray

    // Front face hooks (point in -Y direction, i.e. rotate to aim outward)
    for (xi = [CX, UX - CX - HK_W]) {
        translate([xi, 0, Z0])
        rotate([90, 0, 0])
        single_hook();
    }
    // Back face hooks (point in +Y direction)
    for (xi = [CX, UX - CX - HK_W]) {
        translate([xi + HK_W, UY, Z0])
        rotate([-90, 0, 180])
        single_hook();
    }
}

/* ---- assembly ---- */
// Lower tray at origin
lower_tray();
for (s=[0,1]) corner_ledge(s);

// Upper tray sitting on lower tray (or exploded above)
translate([0, 0, LZ + EXPLODE]) {
    upper_tray();
    upper_hooks();
}
