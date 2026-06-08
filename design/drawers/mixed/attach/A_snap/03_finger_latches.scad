// 03_finger_latches.scad
// Flexible finger latches: two pairs of tall, slender cantilever fingers
// on the SHORT ends (Y faces) of the upper tray. Each finger has a wedge
// hook tip that grabs a small ledge printed on the lower tray's end wall.
// The long flexible arm gives easy manual release — just squeeze the pair inward.
// Engage: press down; ramp guides hooks past ledge. Release: pinch pair, lift.

$fn = 36;
EXPLODE = 18;   // 0=engaged, >0=exploded

/* ---- tray dimensions ---- */
LX = 305; LY = 102; LZ = 50;
UX = 305; UY = 102; UZ = 33;
W  = 3;

/* ---- finger params ---- */
FW   = 10;    // finger width
FT   = 2.2;   // finger thickness (flex direction)
FL   = 20;    // free arm length (provides flex)
HOOK_H = 2.5; // hook catch height
HOOK_D = 2.0; // hook protrusion depth
RAMP_A = 40;  // ramp angle (degrees) for self-guiding on press
LEDGE_H = 2.5;
LEDGE_D = 2.2;

// X position: fingers centered on each short end, spaced apart
FSPACING = 40;  // centre-to-centre of finger pair
FX1 = UX/2 - FSPACING/2 - FW/2;
FX2 = UX/2 + FSPACING/2 - FW/2;

module lower_tray() {
    color("SteelBlue", 0.85)
    union() {
        difference() {
            cube([LX, LY, LZ]);
            translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
        }
        // Ledge on front short face (X=0 end... no, short face = Y=0 and Y=LY)
        // Actually short end = Y faces (102mm dimension): two ledges on Y=0 face
        for (xp = [FX1, FX2]) {
            // ledge on front face (Y=0), protrudes outward (-Y)
            translate([xp, -LEDGE_D, LZ - LEDGE_H - FL*0.15])
                cube([FW, LEDGE_D, LEDGE_H]);
            // ledge on back face (Y=LY)
            translate([xp, LY, LZ - LEDGE_H - FL*0.15])
                cube([FW, LEDGE_D, LEDGE_H]);
        }
    }
}

// Single flexible finger with hook tip
// Points in +Y direction (for back face) or -Y (for front face, flip=true)
module finger(flip=false) {
    fy = flip ? -1 : 1;
    color("OrangeRed", 0.92)
    union() {
        // Arm: thin plate, FL tall, FT wide in flex direction, FW wide
        cube([FW, FT, FL]);
        // Hook tip at the bottom of the arm (z=0 end)
        translate([0, FT, 0])
        linear_extrude(FW)
        polygon(points=[
            [0, 0],
            [0, -FL*0.1],
            [HOOK_D, -FL*0.1 - HOOK_H],   // ramp point
            [HOOK_D, 0]                     // tip of hook
        ]);
        // Ramp on lower tip for press-in guidance
        translate([0, FT, -HOOK_H])
        linear_extrude(FW)
        polygon(points=[
            [0, 0],
            [HOOK_D*0.6, -HOOK_H*tan(RAMP_A/57.3)*0.6],
            [0, -HOOK_H]
        ]);
    }
}

module upper_tray() {
    color("Tomato", 0.85)
    difference() {
        cube([UX, UY, UZ]);
        translate([W, W, W]) cube([UX-2*W, UY-2*W, UZ]);
    }
}

module upper_fingers() {
    // Fingers hang down from bottom of upper tray on short ends
    // Front end (Y=0): fingers point in -Y, hook catches ledge on lower tray front face
    for (xp = [FX1, FX2]) {
        // Front face: arm flush with Y=0, hook points outward (-Y = flip)
        translate([xp, W, -FL])
        rotate([0, 0, 0])
        finger(flip=false);

        // Back face: arm flush with Y=UY, hook points outward (+Y)
        translate([xp, UY - W - FT, -FL])
        finger(flip=false);
    }
}

/* ---- assembly ---- */
lower_tray();
translate([0, 0, LZ + EXPLODE]) {
    upper_tray();
    upper_fingers();
}
