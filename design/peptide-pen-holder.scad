// =============================================================================
// Peptide Injector-Pen Holder  —  parametric, gravity-feed lane rack
// =============================================================================
// Designed from Jason's hand sketch (1. SIDE / FRONT views).
//
// Concept
//   * Holds injector pens lying FLAT, one per lane.
//   * Pens are loaded from the OPEN BACK (high) end -> "insert side".
//   * Each lane floor is tilted so a pen slides forward -> "slides down".
//   * A continuous LIP across the front catches them -> "won't fall out".
//   * Pens lift straight UP and out of the front when you grab one.
//
// Print orientation: exactly as modeled (flat bottom on the bed). The incline
// is internal, so the part itself sits flat — matching how it's used.
//
// Units: millimetres.
// -----------------------------------------------------------------------------

/* [Pen being held] */
// Body diameter of one injector pen (measure across the fattest part)
pen_diameter  = 19;    // [10:0.5:35]
// Length of one pen, end to end
pen_length    = 150;   // [80:1:200]

/* [Rack layout] */
// Number of lanes (pens side by side). Sketch shows 4; 4-6 works well.
num_lanes     = 5;     // [1:1:10]
// Self-feed incline angle. Higher = slides forward more readily. 0 = flat shelf.
incline_deg   = 8;     // [0:1:25]

/* [Fit & structure] */
// Diametral clearance around the pen (looser = easier load, looser hold)
clearance     = 2.5;   // [1:0.5:6]
// Wall / divider thickness
wall          = 2.6;   // [1.6:0.2:5]
// Floor thickness under the front (thin) end of the cradle
floor_thick   = 3.0;   // [2:0.5:6]
// How far the dividers rise above each pen's cradle (keeps pens separated)
divider_rise  = 17;    // [6:1:30]
// Front catch-lip wall thickness
lip_thick     = 4;     // [2:0.5:8]
// Extra lane length behind the pen (loading runout)
back_runout   = 14;    // [0:1:40]

/* [Quality] */
$fn = 72;              // [24:8:128]

// ------------------------- derived dimensions --------------------------------
lane_w    = pen_diameter + clearance;                 // inside width of a lane
cradle_r  = lane_w / 2;                                // rounded lane bottom
lane_len  = pen_length + lip_thick + back_runout;     // front lip -> open back
rise      = lane_len * tan(incline_deg);              // total floor rise
axis_z    = floor_thick + cradle_r;                   // pen-center height (front)

top_front = floor_thick + cradle_r + divider_rise;    // divider top @ front
top_back  = top_front + rise;                          // divider top @ back

// Lip just clears the pen centre so it blocks the pen but lets you lift it out
lip_top   = axis_z + cradle_r * 0.45;

total_w   = wall * (num_lanes + 1) + num_lanes * lane_w;

// lane i (0-based) centre X
function lane_x(i) = wall + lane_w/2 + i * (lane_w + wall);

// ------------------------------- geometry ------------------------------------
module pen_holder() {
    difference() {
        outer_wedge();
        for (i = [0 : num_lanes - 1]) lane_cut(lane_x(i));
        front_lip_cut();
    }
}

// Solid block whose top slopes up from front to back (parallel to lane floors)
module outer_wedge() {
    difference() {
        cube([total_w, lane_len, top_back + 1]);
        // shave the top to the inclined plane (z = top_front + y*tan(incline))
        translate([-1, -lane_len, top_front])
            rotate([incline_deg, 0, 0])
                cube([total_w + 2, lane_len * 3, top_back + 100]);
    }
}

// One inclined, round-bottomed lane open at the back, starting behind the lip
module lane_cut(xc) {
    overshoot = 2;                       // punch fully through the back face
    L = lane_len - lip_thick + overshoot;
    translate([xc, 0, 0])
        rotate([incline_deg, 0, 0])      // tilt: back (+Y) end rides up
            translate([0, lip_thick, axis_z]) {
                // rounded cradle (lower half holds the pen)
                rotate([-90, 0, 0])
                    cylinder(h = L, r = cradle_r);
                // open slot above the cradle so the pen drops in / lifts out
                translate([-cradle_r, 0, 0])
                    cube([lane_w, L, top_back + 100]);
            }
}

// Lower the front wall down to a catch-lip that spans all lanes
module front_lip_cut() {
    translate([-1, -1, lip_top])
        cube([total_w + 2, lip_thick + 1, top_back + 100]);
}

pen_holder();

// ---- handy console readout (View > "ECHO" / compile log) --------------------
echo(str("Footprint  W x L x H (mm) = ",
         total_w, " x ", lane_len, " x ", top_back));
echo(str("Lanes = ", num_lanes, "  lane width = ", lane_w,
         "  incline = ", incline_deg, " deg  (rise ", rise, " mm)"));
