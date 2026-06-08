// 02_side_snap_lip.scad
// Full-length side snap lip: a continuous flexible bead runs the full 305 mm
// length on BOTH long sides of the upper tray's outer wall.
// The lower tray has a matching groove/channel on its outer faces.
// Engage: press upper tray straight down; bead rides ramp and snaps into groove.
// Release: insert flat tool (or fingernail) in gap and pry outward on one long side.

$fn = 36;
EXPLODE = 18;   // 0=engaged, >0=exploded

/* ---- tray dimensions ---- */
LX = 305; LY = 102; LZ = 50;
UX = 305; UY = 102; UZ = 33;
W  = 3;

/* ---- snap lip params ---- */
BEAD_R   = 1.4;   // bead radius
BEAD_Z   = 6.0;   // height above lower-tray top where bead centre sits
RAMP_H   = 1.6;   // ramp above bead to guide during assembly
GROOVE_D = 0.4;   // extra groove depth clearance
GROOVE_H = BEAD_R*2 + 0.6;  // groove height in lower tray wall

module lower_tray_body() {
    color("SteelBlue", 0.85)
    difference() {
        cube([LX, LY, LZ]);
        translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
    }
}

// Groove channel milled into lower tray outer walls (front & back, full length)
module lower_groove(y_face) {
    // y_face = 0 (front) or LY (back)
    gx = 0; gz = LZ - BEAD_Z - GROOVE_H/2;
    sy = (y_face == 0) ? 0 : LY - W;
    color("SteelBlue", 0.85)
    translate([gx, sy, gz])
        cube([LX, W, GROOVE_H]);
}

// Rebuild lower tray with grooves carved in
module lower_tray() {
    color("SteelBlue", 0.85)
    difference() {
        cube([LX, LY, LZ]);
        // hollow interior
        translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
        // front groove
        translate([0, -0.1, LZ - BEAD_Z - GROOVE_H/2 - BEAD_R - GROOVE_D])
            cube([LX, W + BEAD_R + GROOVE_D + 0.1, GROOVE_H + BEAD_R*2 + GROOVE_D*2]);
        // back groove
        translate([0, LY - W - 0.0, LZ - BEAD_Z - GROOVE_H/2 - BEAD_R - GROOVE_D])
            cube([LX, W + BEAD_R + GROOVE_D + 0.1, GROOVE_H + BEAD_R*2 + GROOVE_D*2]);
    }
}

// Snap bead profile: semicircular bead on a thin wall extension
// runs full length of upper tray long side
module snap_bead_side(y_offset, flip=false) {
    // The bead is a half-round extruded along X, on the outer face of the upper tray wall
    // positioned so it aligns with the groove when trays are mated
    color("Tomato", 0.88)
    translate([0, y_offset, 0])
    rotate([0, 90, 0])
    linear_extrude(UX)
    // bead profile in YZ plane
    // bead centre at (0, -BEAD_Z) from bottom of upper tray
    // wall goes from z=0 downward; bead protrudes outward in Y
    {
        fy = flip ? 1 : -1;
        bz = -BEAD_Z;
        union() {
            // wall extension (thin skirt below upper tray bottom)
            translate([bz - BEAD_R*1.5, 0]) square([BEAD_R*3 + 2, W]);
            // ramp above bead
            polygon(points=[
                [bz + BEAD_R + RAMP_H, 0],
                [bz + BEAD_R + RAMP_H, W],
                [bz + BEAD_R, W + BEAD_R + RAMP_H*0.5],
                [bz + BEAD_R, W]
            ]);
            // bead semicircle
            translate([bz, W])
            circle(r=BEAD_R, $fn=20);
        }
    }
}

module upper_tray_body() {
    color("Tomato", 0.85)
    difference() {
        cube([UX, UY, UZ]);
        translate([W, W, W]) cube([UX-2*W, UY-2*W, UZ]);
    }
}

module upper_tray() {
    upper_tray_body();
    // Snap bead on front wall (Y=0, bead points in -Y)
    translate([0, 0, 0])
    snap_bead_front();
    // Snap bead on back wall (Y=UY, bead points in +Y)
    translate([0, UY, 0])
    snap_bead_back();
}

// Front bead (protrudes in -Y from the front wall)
module snap_bead_front() {
    color("OrangeRed", 0.92)
    translate([0, 0, 0])
    rotate([0, 90, 0])
    linear_extrude(UX)
    {
        bz = -BEAD_Z;
        union() {
            translate([bz - BEAD_R - 1, -W]) square([BEAD_R*2 + 2, W]);
            translate([bz, -W - BEAD_R]) circle(r=BEAD_R, $fn=20);
            polygon(points=[
                [bz + BEAD_R, -W - BEAD_R],
                [bz + BEAD_R + RAMP_H, 0],
                [bz + BEAD_R, 0]
            ]);
        }
    }
}

// Back bead (protrudes in +Y from the back wall)
module snap_bead_back() {
    color("OrangeRed", 0.92)
    translate([0, 0, 0])
    rotate([0, 90, 0])
    linear_extrude(UX)
    {
        bz = -BEAD_Z;
        union() {
            translate([bz - BEAD_R - 1, 0]) square([BEAD_R*2 + 2, W]);
            translate([bz, W + BEAD_R]) circle(r=BEAD_R, $fn=20);
            polygon(points=[
                [bz + BEAD_R, W + BEAD_R],
                [bz + BEAD_R + RAMP_H, 0],
                [bz + BEAD_R, 0]
            ]);
        }
    }
}

/* ---- assembly ---- */
lower_tray();

translate([0, 0, LZ + EXPLODE]) {
    upper_tray_body();
    snap_bead_front();
    snap_bead_back();
}
