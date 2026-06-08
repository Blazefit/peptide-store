// 05_external_spring_clip.scad
// Separate C-shaped external bracket (print in PETG or PA12 for flex)
// that snaps over each SHORT END of the stacked trays.
// Inward lips hook under a lower-tray rim ledge and over an upper-tray rim ledge.
// Two clips, one per short end.
// Engage: press clip sideways over the end of the stack — lips snap onto rims.
// Release: squeeze clip sides outward and slide off.
//
// explode=0  → clips engaged on stack
// explode=40 → clips pulled away from stack ends (exploded)

explode = 40;

lx=305; ly=102; lz=50;
ux=305; uy=102; uz=33;

stack_h  = lz + uz;    // total stack height = 83

// Rim ledge geometry (moulded into tray short-end outer face)
rim_thick = 3.5;   // rim protrudes this much in X from tray end face
rim_h     = 5;     // rim height (tall enough to be grabbed by lip)
// Lower rim at top of lower tray; upper rim at bottom of upper tray
lower_rim_z = lz - rim_h;     // rim bottom Z on lower tray
upper_rim_z = lz;             // rim bottom Z on upper tray (at the joint)

// Clip dimensions
clip_len  = 30;       // clip depth in X (how much it grips end face)
clip_t    = 3.0;      // clip wall thickness
clip_span = ly + 0.8; // internal Y span (just over tray Y)
clip_ow   = clip_span + clip_t*2; // clip outer Y width
// The clip must span from rim_h below lower_rim_z to rim_h above upper_rim_z+rim_h
clip_inner_h = rim_h + (lz - lower_rim_z) + (rim_h) + rim_h; // spans both rims + gap
clip_inner_h2 = uz + rim_h*2 + 2; // simpler: upper tray height + both lips + gap

lip_d    = 3.8;   // inward lip depth (hooks under/over rim)
lip_h    = rim_h + 0.5; // lip height matches rim

module lower_tray() { color("SteelBlue",0.85)    cube([lx,ly,lz]); }
module upper_tray() { color("LightSkyBlue",0.85) cube([ux,uy,uz]); }

// Rim ledge on a short-end face (protrudes outward in -X or +X)
module rim(z_pos, side) {
    // side 0 = X=0 face (ledge goes in -X), side 1 = X=lx face (+X)
    dir = (side==0) ? -1 : 1;
    color("DimGray",0.78)
    translate([(side==0) ? -rim_thick : lx, 0, z_pos])
        cube([rim_thick, ly, rim_h]);
}

// The C-clip: cross-section is C in YZ, extruded along X (clip_len deep)
// It has an inward lip at the bottom (grabs lower rim) and top (grabs upper rim)
module c_clip(side) {
    // Positioned at the tray end, offset by explode
    x_off = (side==0)
        ? -(clip_len + rim_thick + (explode>0 ? explode : 0))
        : lx + rim_thick + (explode>0 ? explode : 0);

    // Z so clip straddles both rims
    clip_z = lower_rim_z - lip_h - 1;
    inner_h = (upper_rim_z + rim_h + 1) - (lower_rim_z - 1) + lip_h;

    color("Orange",0.93)
    translate([x_off, -clip_t, clip_z])
    difference() {
        // Outer block
        cube([clip_len, clip_ow, inner_h + clip_t*2]);
        // Core cavity (tray end fits here)
        translate([0, clip_t, clip_t])
            cube([clip_len, clip_span, inner_h]);
        // Open the X face (the side facing the tray) — remove front wall
        translate([-0.1, clip_t, clip_t])
            cube([clip_t + 0.2, clip_span, inner_h]);
    }

    // Bottom inward lip (points inward in +Y from both sides, grabs lower rim)
    color("OrangeRed",0.92)
    translate([x_off, -clip_t, clip_z])
    union() {
        // back lip
        translate([0, clip_t, clip_t - lip_h + 1])
            cube([clip_len, lip_d, lip_h]);
        // front lip
        translate([0, clip_t + clip_span - lip_d, clip_t - lip_h + 1])
            cube([clip_len, lip_d, lip_h]);
    }

    // Top inward lip (grabs upper rim)
    color("OrangeRed",0.92)
    translate([x_off, -clip_t, clip_z])
    union() {
        translate([0, clip_t, clip_t + inner_h - 1])
            cube([clip_len, lip_d, lip_h]);
        translate([0, clip_t + clip_span - lip_d, clip_t + inner_h - 1])
            cube([clip_len, lip_d, lip_h]);
    }
}

// ==== Lower tray with rims ====
lower_tray();
for(s=[0,1]) rim(lower_rim_z, s);

// ==== Upper tray with rims ====
translate([0,0,lz])
{
    upper_tray();
    for(s=[0,1]) rim(0, s);  // rim at Z=0 of upper tray (the bottom face = lz in world)
}

// ==== Two C-clips, one per short end ====
for(s=[0,1])
    c_clip(s);
