// =============================================================================
// Peptide Pen "Revolver"  —  horizontal rotating cylinder, snap-on base
// =============================================================================
// A true revolver-cylinder carousel: N chambers in a ring, all parallel to a
// horizontal axis. The drum spins on two end supports — spin it like a gun
// cylinder to index the pen you want to the top.
//
// Two printed parts, no hardware:
//   * DRUM  — the rotating cylinder of chambers (prints standing, back-face down)
//   * BASE  — plate + two end uprights with inward axle pins (prints flat)
// The drum's end sockets drop onto the base's axle pins; tilt one end in, flex
// the far upright a hair, and it snaps captive yet free to spin.
//
// Loading:  drop a pen into a chamber from the open FRONT; the closed BACK stops
//           it. Push it back out through the small EJECTOR hole behind each
//           chamber (like an ejector rod).
//
// Units: millimetres.
// -----------------------------------------------------------------------------

/* [What it holds] */
pen_diameter   = 19;    // [10:0.5:35]  pen body diameter
pen_length     = 150;   // [80:1:200]   pen length

/* [Revolver] */
num_chambers   = 6;     // [3:1:10]     6 = classic revolver
clearance      = 2.5;   // [1:0.5:6]    slip fit around the pen

/* [Structure] */
wall           = 3.0;   // [2:0.2:5]    chamber + outer wall
back_wall      = 3.0;   // [2:0.5:6]    closed back thickness
ejector_d      = 6.5;   // [0:0.5:12]   push-out hole behind each chamber (0 = none)
front_chamfer  = 3;     // [0:0.5:6]    lead-in at the loading mouth

/* [Axle / base] */
pin_d          = 9;     // [6:0.5:14]   axle pin diameter
pin_engage     = 6;     // [4:0.5:10]   how deep the pin sits in the drum
axle_gap       = 0.5;   // [0.2:0.1:1]  spin clearance (pin vs socket)
ground_clear   = 7;     // [3:1:15]     gap under the drum
plate_th       = 5;     // [3:0.5:8]    base plate thickness
upright_th     = 6;     // [4:0.5:10]   end-support thickness

/* [Click detent] */
enable_detent  = true;
detent_spring_th = 2.0; // [1.2:0.1:3]  leaf-spring thickness (lower = softer click)
detent_depth   = 1.2;   // [0.4:0.1:2]  how deep the scallops are

/* [What to show / export] */
part = "both";          // [both, drum, base]
show_pens = false;      // demo pens in the assembled view (preview only)

$fn = 96;

// --------------------------- derived geometry --------------------------------
ch_r     = (pen_diameter + clearance) / 2;            // chamber bore radius
min_chord = 2*ch_r + wall;                            // min gap between chambers
pitch_r  = max(min_chord / (2*sin(180/num_chambers)),
               ch_r + pin_d/2 + wall + 4);            // ring radius of chambers
drum_r   = pitch_r + ch_r + wall;                     // outer radius of drum
ch_depth = pen_length + 2;                            // chamber depth (pen + slack)
drum_len = ch_depth + back_wall;                      // total drum length
socket_r = pin_d/2 + axle_gap;

axis_h   = drum_r + ground_clear;                     // axle height off the table
base_len = drum_len + 2*upright_th + 2*1.5;           // along the axis (X)
base_w   = 2*drum_r * 0.95;                           // across (Y) — stable but open
det_r    = drum_r - 6;                                // radius of detent scallops

function ch_xy(i) = [pitch_r*cos(90 + i*360/num_chambers),
                     pitch_r*sin(90 + i*360/num_chambers)];

// =============================== THE DRUM ====================================
// Built with the axis along Z: back face at z=0, loading mouths at z=drum_len.
module drum() {
    difference() {
        union() {
            cylinder(h = drum_len, r = drum_r);
            if (enable_detent) detent_ring();            // scalloped collar @ back
        }
        // chambers (open at the front, closed back_wall at the bottom)
        for (i = [0:num_chambers-1]) {
            p = ch_xy(i);
            translate([p[0], p[1], back_wall])
                cylinder(h = ch_depth + 1, r = ch_r);
            // loading lead-in chamfer
            if (front_chamfer > 0)
                translate([p[0], p[1], drum_len - front_chamfer])
                    cylinder(h = front_chamfer + 0.1,
                             r1 = ch_r, r2 = ch_r + front_chamfer);
            // ejector hole through the back
            if (ejector_d > 0)
                translate([p[0], p[1], -1])
                    cylinder(h = back_wall + 2, r = ejector_d/2);
        }
        // axle sockets, both ends, on the axis
        translate([0,0,-1])            cylinder(h = pin_engage+1, r = socket_r);
        translate([0,0,drum_len-pin_engage]) cylinder(h = pin_engage+1, r = socket_r);
        // lighten the solid core a touch (optional, keeps weight/spin down)
        translate([0,0,back_wall+pin_engage])
            cylinder(h = drum_len-2*pin_engage-back_wall, r = pin_d/2 + wall);
    }
}

// Scalloped collar at the back of the drum that the base pawl clicks into
module detent_ring() {
    difference() {
        cylinder(h = detent_spring_th + 1.5, r = det_r + detent_depth + 1.5);
        for (i = [0:num_chambers-1])
            rotate([0,0,i*360/num_chambers])
                translate([det_r + detent_depth + 1.5, 0, -1])
                    cylinder(h = detent_spring_th + 4, r = 2.2, $fn=24);
    }
}

// =============================== THE BASE ====================================
// Built in the in-use orientation: axis along X, sitting on the table (z=0 up).
module base() {
    // base plate
    translate([0, -base_w/2, 0]) cube([base_len, base_w, plate_th]);
    // two end uprights with inward axle pins
    upright(upright_th/2);                 // back support (also holds the pawl)
    upright(base_len - upright_th/2);
    if (enable_detent) detent_pawl();
}

module upright(xc) {
    inner = (xc < base_len/2) ? 1 : -1;    // which way the pin points
    // the post (wide and short — plenty stiff)
    translate([xc - upright_th/2, -drum_r*0.7, 0])
        cube([upright_th, drum_r*1.4, axis_h]);
    // axle pin, pointing inward toward the drum, chamfered tip for easy snap
    translate([xc, 0, axis_h]) rotate([0, inner*90, 0])
        union() {
            cylinder(h = pin_engage + 1, r = pin_d/2);
            translate([0, 0, pin_engage + 1])
                cylinder(h = 1.4, r1 = pin_d/2, r2 = pin_d/2 - 1.4);
        }
}

// Leaf-spring pawl on the base, nub presses UP into the scallop ring under
// the drum. Flexes vertically; soften the click by lowering detent_spring_th.
module detent_pawl() {
    th       = detent_spring_th;
    contact_z = axis_h - (det_r + detent_depth);   // bottom of the scallop ring
    x_anchor = upright_th;                          // root at the back upright
    x_tip    = upright_th + 6;                      // under the collar
    // horizontal cantilever beam (thin in Z so it springs up/down)
    translate([x_anchor, -5, contact_z - th - 1])
        cube([x_tip - x_anchor + 4, 10, th]);
    // rounded nub on top that seats into each scallop
    translate([x_tip, 0, contact_z - 1])
        sphere(r = 2.2, $fn = 24);
}

// =============================== ASSEMBLY ====================================
module assembled() {
    color("#a78bfa") base();
    // drop the drum in: rotate its Z-axis to lie along X, lift to axle height
    color("#7c5cfc")
    translate([base_len/2, 0, axis_h])
        rotate([0, 90, 0])
            translate([0, 0, -drum_len/2])
                drum();
    // demo pens (preview only) — show 3 chambers loaded
    if (show_pens)
        translate([base_len/2, 0, axis_h]) rotate([0, 90, 0])
            translate([0, 0, -drum_len/2])
                for (i = [0, 2, 3]) {
                    p = ch_xy(i);
                    color("#e8e8f5")
                    translate([p[0], p[1], back_wall])
                        cylinder(h = pen_length, r = pen_diameter/2);
                }
}

if (part == "drum") drum();
else if (part == "base") base();
else assembled();

echo(str("Drum  Ø", 2*drum_r, " x ", drum_len, " mm, ", num_chambers, " chambers"));
echo(str("Base  ", base_len, " x ", base_w, " x ", axis_h, " mm"));
echo(str("Footprint overall ≈ ", base_len, " x ", base_w,
         " x ", axis_h + drum_r, " mm"));
