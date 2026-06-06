// =============================================================================
// Peptide Pen "Drop-Selector Revolver"  —  SIMPLE edition
// =============================================================================
// Three printed parts, no fasteners, no springs to fatigue:
//   1. DRUM    — fluted revolver cylinder; just DROPS into the body's bearings
//   2. BODY    — tray + uprights + open-top bearings + shroud + shutter track
//   3. SHUTTER — one flat slide ("drawer pull"); slide it open to drop a pen
//
// Use it: spin the drum to your pen (it clicks into place), pull the shutter,
// that one pen drops into the catch tray and rests at the front lip. Push the
// shutter shut. To refill: lift the whole drum out and drop pens in the top.
// Units: mm.
// -----------------------------------------------------------------------------

/* [What it holds] */
pen_diameter  = 19;     // [10:0.5:35]
pen_length    = 150;    // [80:1:200]

/* [Revolver] */
num_chambers  = 6;      // [4:1:8]
clearance     = 2.5;    // [1:0.5:6]
flute_depth   = 1.6;    // [0:0.2:4]

/* [Structure] */
wall          = 3.0;    // [2:0.2:5]
end_wall      = 4.0;    // [2:0.5:8]
shroud_th     = 3.0;    // [2:0.5:6]
shroud_gap    = 1.4;    // [0.8:0.1:2.5]

/* [Drop-in axle] */
stub_d        = 11;     // [7:0.5:16]  integral axle stub diameter
stub_len      = 9;      // [5:0.5:14]
bearing_gap   = 0.6;    // [0.3:0.1:1.2] stub-to-bearing running clearance

/* [Uprights] */
upright_th    = 8;      // [5:0.5:12]
upright_gap   = 1.2;    // [0.5:0.1:3] gap between drum end and upright

/* [Shutter gate] */
win_ang       = 18;     // [12:1:26]  half-angle of the bottom drop window
shutter_th    = 2.6;    // [1.8:0.1:4]
shutter_gap   = 0.6;    // [0.3:0.1:1] slide clearance
shutter_travel= 30;     // [18:1:45]  how far it slides to open

/* [Catch tray] */
tray_lip      = 24;     // [10:1:30]  taller than the pen so it can't roll out
drop_clear    = 30;     // [12:1:45]  headroom: pen drop + handle clears the catch
cushion_on    = true;   // springy fingers at the landing zone

/* [Auto-index click] */
detent_on     = true;
detent_nub    = 2.2;    // [1:0.1:4]
detent_t      = 1.8;    // [1:0.1:3]

/* [Preview] */
part = "assembled";     // [drum, body, shutter, assembled, exploded, section]
show_pen = true;
shutter_state = "closed";  // [closed, open]

/* [Refinements] (added over the iteration passes) */
finger_scoop = true;    // i1  front scoop to pinch the pen out
thumbwheel   = true;    // i2  spin grip on one drum end
chamber_nums = true;    // i3  numbers on the drum face
sel_pointer  = true;    // i4  "drop station" pointer on the body
bearing_keep = true;    // i5  lips that keep the drum seated
shutter_lock = true;    // i6  closed click + open hard-stop
hub_light    = true;    // i7  lighten the drum hub
label_panel  = true;    // i9  recessed label area on the front
feet_on      = true;    // i10 recessed non-slip feet
round_edges  = true;    // i11 chamfer the handled edges
lid_on       = false;   // i12 optional clip-on dust lid (extra part)
wallmount    = false;   // i13 optional keyhole slots on the back

$fn = 80;

// --------------------------- derived geometry --------------------------------
ch_r     = (pen_diameter + clearance) / 2;
pitch_r  = (2*ch_r + wall) / (2*sin(180/num_chambers));
drum_r   = pitch_r + ch_r + 2;
drum_len = pen_length + 2*end_wall;
throat_w = pen_diameter + 1.5;

function ch_ang(i)    = 90 + i*360/num_chambers;
function flute_ang(i) = 90 + (i+0.5)*360/num_chambers;

tray_floor_z = 6;
axle_z       = tray_floor_z + drop_clear + drum_r;
upright_x_in = drum_len/2 + upright_gap;
upright_x    = upright_x_in + upright_th/2;
body_out_x   = upright_x_in + upright_th;
shroud_ir    = drum_r + shroud_gap;
shroud_or    = shroud_ir + shroud_th;
tray_front_y = drum_r + 14;
tray_back_y  = drum_r + 6;
upright_top_z= axle_z + stub_d/2 + bearing_gap + 4;
det_dr       = drum_r - 7;
det_nz       = axle_z - det_dr;
tw_reach     = upright_gap + upright_th + 4;            // +Z stub length with wheel
tw_r         = round(drum_r*0.66);                      // thumbwheel radius
tw_th        = 8;

// =============================================================================
//  DRUM  (built on its axis = Z; integral axle stubs at both ends)
// =============================================================================
module drum() {
    union() {
        difference() {
            cylinder(h = drum_len, r = drum_r);
            for (i = [0:num_chambers-1]) rotate([0,0,ch_ang(i)]) pocket();
            if (flute_depth > 0)
                for (i = [0:num_chambers-1]) rotate([0,0,flute_ang(i)]) flute();
            // auto-index dimples on the +Z end face (one per chamber)
            if (detent_on)
                for (i = [0:num_chambers-1]) rotate([0,0,ch_ang(i)])
                    translate([det_dr, 0, drum_len]) sphere(r = detent_nub + 0.4);
            // i3: engraved chamber numbers on the -Z end face
            if (chamber_nums)
                for (i = [0:num_chambers-1])
                    rotate([0,0,ch_ang(i)]) translate([drum_r-13, 0, -0.01])
                        rotate([0,0,-ch_ang(i)+90]) mirror([1,0,0])
                            linear_extrude(height = 1.4)
                                text(str(i+1), size=8, halign="center", valign="center");
        }
        // integral axle stubs (the +Z one runs through to a thumbwheel)
        sl_pos = thumbwheel ? tw_reach : stub_len;
        translate([0,0,-stub_len+0.01]) cylinder(h = stub_len, r = stub_d/2);
        translate([0,0,drum_len-0.01])  cylinder(h = sl_pos, r = stub_d/2);
        // i2: thumbwheel spin grip, just outside the +X upright
        if (thumbwheel) translate([0,0,drum_len+sl_pos-3]) thumb_wheel();
    }
}

module thumb_wheel() {
    difference() {
        cylinder(h = tw_th, r = tw_r);
        for (i = [0:11]) rotate([0,0,i*30])
            translate([tw_r, 0, -1]) cylinder(h = tw_th+2, r = 2.4);   // grip scallops
    }
}

module pocket() {
    translate([pitch_r, 0, end_wall]) {
        cylinder(h = drum_len - 2*end_wall, r = ch_r);
        translate([0, -throat_w/2, 0])
            cube([drum_r, throat_w, drum_len - 2*end_wall]);
    }
}

module flute() {
    translate([drum_r + (3.2 - flute_depth), 0, 12])
        cylinder(h = drum_len - 24, r = 3.2);
}

// place the drum horizontally (axis = X), stubs reaching into the bearings
module drum_in_place(rot=0) {
    translate([0,0,axle_z]) rotate([0,90,0]) rotate([0,0,rot])
        translate([0,0,-drum_len/2]) drum();
}

module demo_pen() {
    color("#e8e8f5")
    translate([-pen_length/2, 0, axle_z + pitch_r])
        rotate([0,90,0]) cylinder(h = pen_length, r = pen_diameter/2);
}

include <peptide-pen-dropper-parts.scad>

// --------------------------------- output ------------------------------------
if      (part == "drum")      drum();
else if (part == "body")      body();
else if (part == "shutter")   shutter(shutter_state);
else if (part == "exploded")  exploded();
else if (part == "section")   section();
else if (part == "detentview")detentview();
else                          assembled();

echo(str("Drum Ø", 2*drum_r, " x ", drum_len, "  axle_z=", axle_z));
echo(str("body ", 2*body_out_x, " x ", tray_front_y+tray_back_y+2*wall, " x ", upright_top_z));
