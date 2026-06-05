// =============================================================================
// Peptide Pen "Drop-Selector Revolver"   (evolution of peptide-pen-revolver)
// =============================================================================
// Spin the fluted drum to bring the chamber you want to the BOTTOM "drop
// station", press the button, and that one pen is released — it drops through
// a trapdoor into the angled catch tray of a secondary base below and rolls
// forward to a lip where you grab it.
//
// PARTS (print separately, select with `part`):
//   drum       — fluted revolver cylinder, chamber pockets open along the side
//   cradle     — legs + axle pins + shroud (holds pens in) + button-latch
//   flap       — the trapdoor that drops the pen (snaps onto the cradle hinge)
//   secondary  — lower base: slides onto the cradle legs, angled catch tray + lip
//   both       — everything assembled (preview)
//   exploded   — parts pulled apart (preview)
//
// NOTE: the button/latch/hinge are modelled in the CLOSED position; this file
// captures the geometry and motion of the mechanism (see README) rather than a
// tuned spring. Units: millimetres.
// -----------------------------------------------------------------------------

/* [What it holds] */
pen_diameter  = 19;     // [10:0.5:35]
pen_length    = 150;    // [80:1:200]

/* [Revolver] */
num_chambers  = 6;      // [4:1:8]
clearance     = 2.5;    // [1:0.5:6]
flute_depth   = 1.6;    // [0:0.2:4]   exterior scallops between chambers (0 = plain)

/* [Structure] */
wall          = 3.0;    // [2:0.2:5]
end_wall      = 4.0;    // [2:0.5:8]   solid drum ends (axial pen stop)
shroud_th     = 3.0;    // [2:0.5:6]
shroud_gap    = 1.2;    // [0.6:0.1:2] drum-to-shroud running clearance

/* [Axle] */
pin_d         = 9;      // [6:0.5:14]
pin_engage    = 6;      // [4:0.5:10]
axle_gap      = 0.5;    // [0.2:0.1:1]

/* [Secondary base / catch tray] */
tray_incline  = 8;      // [4:1:18]   forward slope so the pen rolls to the lip
tray_lip      = 12;     // [6:1:20]   front catch-lip height
drop_clear    = 26;     // [12:1:50]  air gap from drum bottom down into the tray

/* [Preview] */
part = "exploded";      // [drum, cradle, flap, secondary, both, exploded]
show_pen = true;        // demo pen in the bottom chamber (preview only)

$fn = 80;

// --------------------------- derived geometry --------------------------------
ch_r     = (pen_diameter + clearance) / 2;
pitch_r  = max(2*ch_r + wall, ch_r + pin_d/2 + wall + 5)
           / (2*sin(180/num_chambers));               // ring radius
drum_r   = pitch_r + ch_r + 2;                          // pen recessed ~2 mm
drum_len = pen_length + 2*end_wall;
throat_w = pen_diameter + 1.5;                          // side opening of a pocket
socket_r = pin_d/2 + axle_gap;

// chambers placed so #0 is at TOP (load) and one is at BOTTOM (drop)
function ch_ang(i) = 90 + i*360/num_chambers;
function flute_ang(i) = 90 + (i+0.5)*360/num_chambers;

// in-use placement (axis = X, table at z=0)
leg_th    = 9;
leg_gap   = 2;
axle_x    = drum_len/2 + leg_gap + leg_th/2;            // legs centred at ±axle_x
shroud_ir = drum_r + shroud_gap;
shroud_or = shroud_ir + shroud_th;
tray_floor_z = 6;                                       // tray low point (front)
axle_z    = tray_floor_z + drop_clear + drum_r;         // drum centre height

// =============================================================================
//  DRUM  (built on its axis = Z; back face z=0, front face z=drum_len)
// =============================================================================
module drum() {
    difference() {
        cylinder(h = drum_len, r = drum_r);
        // chamber pockets: rounded cradle + throat opening to the outer surface
        for (i = [0:num_chambers-1]) rotate([0,0,ch_ang(i)]) pocket();
        // exterior flutes between chambers
        if (flute_depth > 0)
            for (i = [0:num_chambers-1]) rotate([0,0,flute_ang(i)]) flute();
        // axle sockets both ends
        translate([0,0,-1])                  cylinder(h = pin_engage+1, r = socket_r);
        translate([0,0,drum_len-pin_engage]) cylinder(h = pin_engage+1, r = socket_r);
    }
}

module pocket() {
    translate([pitch_r, 0, end_wall]) {
        cylinder(h = drum_len - 2*end_wall, r = ch_r);     // cradle
        translate([0, -throat_w/2, 0])                      // throat to surface
            cube([drum_r, throat_w, drum_len - 2*end_wall]);
    }
}

module flute() {
    fl = drum_len - 24;
    translate([drum_r + (3.2 - flute_depth), 0, 12])
        cylinder(h = fl, r = 3.2);
}

// =============================================================================
//  ASSEMBLY HELPERS — place the drum horizontally
// =============================================================================
module drum_in_place(rot=0) {
    translate([0,0,axle_z]) rotate([0,90,0]) rotate([0,0,rot])
        translate([0,0,-drum_len/2]) drum();
}

// crude pen for preview, sitting in the visible TOP chamber
module demo_pen() {
    color("#e8e8f5")
    translate([-pen_length/2, 0, axle_z + pitch_r])
        rotate([0,90,0]) cylinder(h = pen_length, r = pen_diameter/2);
}

// (cradle, flap, secondary defined below)
include <peptide-pen-dropper-parts.scad>

// --------------------------------- output ------------------------------------
if      (part == "drum")      drum();
else if (part == "cradle")    cradle();
else if (part == "flap")      flap();
else if (part == "secondary") secondary();
else if (part == "exploded")  exploded();
else if (part == "section")   section();
else                          assembled();

echo(str("Drum Ø", 2*drum_r, " x ", drum_len, "  pitch_r=", pitch_r));
echo(str("axle_z=", axle_z, " shroud_or=", shroud_or));
