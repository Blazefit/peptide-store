// 05_c_clip_ends.scad
// Push-down C-clips on short ends: two independent C-shaped clips (one per
// short end, Y=0 and Y=LY) that slide over BOTH mating walls simultaneously.
// Each clip wraps around the junction of upper+lower tray on the short face,
// with an inner ledge that hooks under the lower tray's top rim.
// Engage: push clip straight DOWN onto the stacked short-end walls.
// Release: pull clip straight UP (or lever with fingernail under the bottom lip).
// Also resists X-slide via friction fit of the C-channel width.

$fn = 36;
EXPLODE = 18;  // 0 = engaged, >0 = exploded view

/* ---- tray dimensions ---- */
LX = 305; LY = 102; LZ = 50;   // lower tray (short dim = Y = 102mm)
UX = 305; UY = 102; UZ = 33;   // upper tray
W  = 3;                          // wall thickness

/* ---- C-clip params ---- */
// The clip straddles the combined wall thickness on the short-end (X) face.
// Short end = X=0 and X=LX faces.  Combined stack thickness = W (lower) + W (upper)
// The C channel is slightly deeper to also grip the step.

CC_W    = 60;    // width of clip along Y (centered on the short end face)
CC_T    = 2.8;   // clip arm thickness
CC_H    = 18;    // total clip height (spans across tray junction + ledge zone)
// inner channel width = combined wall thickness of stacked trays + small gap
WALL_STACK = W;  // both trays have the same wall, they are flush on the outer face
// The lower tray wall outer face is the reference; upper sits on top, same X.
CHANNEL_W = W + 1.0;  // inner slot width: snug on the wall
CHANNEL_DEPTH = CC_H; // full depth, open bottom

// snap ledge on the INSIDE of the clip's inner (lower) arm
// hooks under a small notch printed on the lower tray end wall
LEDGE_H  = 1.8;  // ledge height on clip inner arm (protrudes inward in Z)
LEDGE_OFF = 3.0; // from bottom of clip
NOTCH_H  = 2.0;  // matching notch height in lower tray
NOTCH_D  = 1.6;  // notch depth (inward from outer face)

// Clip centered on short end face at X=0; the face runs in Y from 0..LY
// Clip spans Y from (LY/2 - CC_W/2) to (LY/2 + CC_W/2)
CC_Y0 = LY/2 - CC_W/2;

// vertical position: clip sits straddling the LZ (top of lower tray)
// bottom of clip at LZ - (CC_H - overlap), where overlap into lower tray region
OVERLAP = 10;   // how far clip descends below LZ
CC_Z0   = LZ - OVERLAP;

module lower_tray() {
    color("SteelBlue", 0.85)
    union() {
        difference() {
            cube([LX, LY, LZ]);
            translate([W, W, W]) cube([LX-2*W, LY-2*W, LZ]);
            // Notch on X=0 short end face for clip ledge
            translate([-0.1, CC_Y0, CC_Z0 + LEDGE_OFF - 0.1])
                cube([W + NOTCH_D + 0.1, CC_W, NOTCH_H + 0.2]);
            // Notch on X=LX short end face
            translate([LX - W - NOTCH_D, CC_Y0, CC_Z0 + LEDGE_OFF - 0.1])
                cube([W + NOTCH_D + 0.1, CC_W, NOTCH_H + 0.2]);
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

// C-clip cross section profile in the XZ plane (local coords)
// The C opens upward (so it can push down over the wall stack)
// x=0 is the outer face of the tray wall
// z=0 is bottom of clip
// Channel: from z=0 to z=CC_H, width CHANNEL_W, open at top
module c_clip_profile() {
    // outer back wall
    square([CC_T, CC_H]);
    // inner front wall (closer to inside of tray) — shorter so clip can flex over wall
    translate([CC_T + CHANNEL_W, 0]) square([CC_T, CC_H * 0.7]);
    // bottom connecting web
    translate([0, 0]) square([CC_T*2 + CHANNEL_W, CC_T]);
    // snap ledge on inner wall interior face (protrudes in +X toward channel)
    // sits at LEDGE_OFF from bottom
    translate([CC_T, LEDGE_OFF])
        polygon(points=[
            [0, 0],
            [LEDGE_H*1.5, 0],
            [LEDGE_H, LEDGE_H*1.2],
            [0, LEDGE_H*1.2]
        ]);
}

// One C-clip, placed at short end X=0 or X=LX
// flip=true mirrors for X=LX end
module c_clip(flip=false) {
    color("OrangeRed", 0.92)
    translate([flip ? LX : 0, CC_Y0, CC_Z0])
    mirror([flip ? 1 : 0, 0, 0])
    translate([-CC_T, 0, 0])   // position outer wall flush with outer face
    rotate([90, 0, 0])
    linear_extrude(CC_W)
    c_clip_profile();
}

/* ---- assembly ---- */
lower_tray();

translate([0, 0, LZ + EXPLODE]) {
    upper_tray();
}

// Clips stay at their Z position (they span the junction)
// In exploded view move them up with the upper tray for clarity
translate([0, 0, EXPLODE]) {
    c_clip(flip=false);
    c_clip(flip=true);
}
