// 04_corner_snap_tabs.scad
// Snap-over corner tabs: four L-shaped corner clips that wrap AROUND two
// adjacent faces at each corner. Each clip has an inward-facing bead on the
// short-side arm and a lateral locking nub on the long-side arm — resisting
// both lift AND side-slide in X. The clip is integral to the upper tray.
// Engage: press upper tray straight down; ramp on bead guides past corner edge.
// Release: pull/flex the L-tab outward at the corner tip, then lift.

$fn = 36;
EXPLODE = 18;   // 0 = engaged, >0 = exploded view

/* ---- tray dimensions ---- */
LX = 305; LY = 102; LZ = 50;   // lower tray
UX = 305; UY = 102; UZ = 33;   // upper tray
W  = 3;                          // wall thickness

/* ---- clip params ---- */
CL_W  = 18;   // clip width along each face
CL_T  = 2.6;  // clip arm thickness (flex wall)
CL_H  = 14;   // clip height (overlaps lower tray top portion)
BEAD  = 1.8;  // snap bead protrusion inward
RAMP  = 2.0;  // ramp height above bead for self-guiding
NUBW  = 3.0;  // lateral anti-slide nub width  (fits a notch in the corner)
NUBH  = 1.6;  // nub height (inward protrusion)
NOTCH_D = 1.8; // notch depth in lower tray corner for anti-slide nub

// small clearance between upper and lower tray mating faces
GAP = 0.2;

module lower_tray() {
    color("SteelBlue", 0.85)
    union() {
        difference() {
            cube([LX, LY, LZ]);
            translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
            // four corner notches for anti-slide nub (on top band of lower tray)
            // Front-Left corner
            translate([-0.1, -0.1, LZ - CL_H/2 - NUBW/2])
                cube([W + NOTCH_D + 0.1, NUBW + 0.1, NUBW]);
            // Front-Right corner
            translate([LX - W - NOTCH_D, -0.1, LZ - CL_H/2 - NUBW/2])
                cube([W + NOTCH_D + 0.1, NUBW + 0.1, NUBW]);
            // Back-Left corner
            translate([-0.1, LY - NUBW, LZ - CL_H/2 - NUBW/2])
                cube([W + NOTCH_D + 0.1, NUBW + 0.1, NUBW]);
            // Back-Right corner
            translate([LX - W - NOTCH_D, LY - NUBW, LZ - CL_H/2 - NUBW/2])
                cube([W + NOTCH_D + 0.1, NUBW + 0.1, NUBW]);
        }
    }
}

module upper_tray() {
    color("Tomato", 0.85)
    difference() {
        cube([UX, UY, UZ]);
        translate([W, W, W]) cube([UX-2*W, UY-2*W, UZ]);
    }
}

// 2D profile of clip arm cross-section (in local XZ plane)
// arm extends outward in +X, bead protrudes inward (-X side)
// height CL_H, arm thickness CL_T
module clip_arm_profile() {
    // arm body
    square([CL_T, CL_H]);
    // snap bead: small triangular bead at mid-height (outward face = left side)
    // bead protrudes in -X direction (inward toward tray)
    bz = CL_H * 0.35;  // bead z position from bottom of clip
    polygon(points=[
        [-BEAD,        bz],
        [-BEAD,        bz + BEAD*2],
        [0,            bz + BEAD + RAMP],
        [0,            bz - RAMP*0.5]
    ]);
    // anti-slide nub at mid-height on the inner face, shifted higher
    nz = CL_H * 0.52;
    polygon(points=[
        [-NUBH,  nz],
        [-NUBH,  nz + NUBW],
        [0,      nz + NUBW],
        [0,      nz]
    ]);
}

// One L-shaped corner clip
// corner_idx: 0=front-left, 1=front-right, 2=back-right, 3=back-left
module corner_clip(corner_idx) {
    // Determine rotation and translation for each corner
    // Clip has two arms: one along X face, one along Y face, joined at corner
    color("OrangeRed", 0.92)
    if (corner_idx == 0) {
        // Front-Left: X=0, Y=0 corner; arms go right (+X) and back (+Y)
        translate([0, 0, -CL_H + GAP])
        union() {
            // Y-face arm (along front face, from X=0 to X=CL_W)
            translate([0, -CL_T, 0])
            linear_extrude(CL_H) {
                // arm extends in -Y (outward from Y=0 face)
                // bead faces +Y (inward)
                mirror([1,0]) square([CL_T, CL_W]);
                // bead
                bz2 = CL_H * 0.35;
                translate([0, CL_W * 0.4]) mirror([1,0])
                    polygon(points=[
                        [0, 0],[0, BEAD*2],[BEAD, BEAD+RAMP],[BEAD, -RAMP*0.5]
                    ]);
            }
            // X-face arm (along left face, from Y=0 to Y=CL_W)
            translate([-CL_T, 0, 0])
            rotate([0,0,0])
            linear_extrude(CL_H) {
                mirror([1,0]) square([CL_T, CL_W]);
                // bead pointing +X (inward)
                translate([0, CL_W*0.4]) mirror([1,0])
                    polygon(points=[
                        [0, 0],[0, BEAD*2],[BEAD, BEAD+RAMP],[BEAD, -RAMP*0.5]
                    ]);
            }
        }
    } else if (corner_idx == 1) {
        // Front-Right: X=UX, Y=0
        translate([UX, 0, -CL_H + GAP])
        union() {
            translate([0, -CL_T, 0])
            linear_extrude(CL_H) {
                mirror([1,0]) square([CL_T, CL_W]);
                translate([0, CL_W * 0.4]) mirror([1,0])
                    polygon(points=[
                        [0,0],[0,BEAD*2],[BEAD,BEAD+RAMP],[BEAD,-RAMP*0.5]
                    ]);
            }
            translate([0, 0, 0])
            linear_extrude(CL_H)
                union() {
                    square([CL_T, CL_W]);
                    translate([0, CL_W*0.4])
                        polygon(points=[
                            [0,0],[0,BEAD*2],[-BEAD,BEAD+RAMP],[-BEAD,-RAMP*0.5]
                        ]);
                }
        }
    } else if (corner_idx == 2) {
        // Back-Right: X=UX, Y=UY
        translate([UX, UY, -CL_H + GAP])
        union() {
            translate([0, 0, 0])
            linear_extrude(CL_H)
                union() {
                    square([CL_T, CL_W]);
                    translate([0, CL_W*0.4])
                        polygon(points=[
                            [0,0],[0,BEAD*2],[-BEAD,BEAD+RAMP],[-BEAD,-RAMP*0.5]
                        ]);
                }
            translate([0, 0, 0])
            linear_extrude(CL_H)
            rotate([0,0,0]) {
                mirror([0,1,0]) square([CL_T, CL_W]);
                mirror([0,1,0]) translate([0, CL_W*0.4])
                    polygon(points=[
                        [0,0],[0,BEAD*2],[-BEAD,BEAD+RAMP],[-BEAD,-RAMP*0.5]
                    ]);
            }
        }
    } else {
        // Back-Left: X=0, Y=UY
        translate([0, UY, -CL_H + GAP])
        union() {
            translate([-CL_T, 0, 0])
            linear_extrude(CL_H)
                union() {
                    mirror([1,0]) square([CL_T, CL_W]);
                    translate([0, CL_W*0.4]) mirror([1,0])
                        polygon(points=[
                            [0,0],[0,BEAD*2],[BEAD,BEAD+RAMP],[BEAD,-RAMP*0.5]
                        ]);
                }
            linear_extrude(CL_H)
            {
                mirror([0,1,0]) square([CL_T, CL_W]);
                mirror([0,1,0]) translate([0, CL_W*0.4])
                    polygon(points=[
                        [0,0],[0,BEAD*2],[-BEAD,BEAD+RAMP],[-BEAD,-RAMP*0.5]
                    ]);
            }
        }
    }
}

/* ---- assembly ---- */
lower_tray();

translate([0, 0, LZ + EXPLODE]) {
    upper_tray();
    for (i = [0:3]) corner_clip(i);
}
