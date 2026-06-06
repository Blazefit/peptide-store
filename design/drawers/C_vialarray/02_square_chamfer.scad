// 02_square_chamfer.scad
// Square-grid vial holes with chamfered lead-ins, easy grabbing
// Outer: 370 x 370 x 72 mm
// Grid pitch: 26 mm → 14 cols × 14 rows = 196 holes (interior pruned ~182)
// Chamfer funnel top makes blind insertions easy
// Splits: Left section (≤185 mm) + Right section (≤185 mm)

$fn = 36;

outer_w = 370;
outer_d = 370;
total_h = 72;

wall      = 3.2;
floor_t   = 3.0;
frame_h   = 14;
drawer_gap = 1.0;

vial_d    = 23.5;
chamfer   = 3.0;        // lead-in chamfer
pitch     = 26.5;       // center-to-center
vial_depth = 42;
pocket_d  = vial_depth;

inner_w = outer_w - 2*wall;
inner_d = outer_d - 2*wall;
drawer_h = total_h - frame_h - 1;

module chamfered_hole(depth) {
    cylinder(d=vial_d, h=depth);
    translate([0,0,depth])
        cylinder(d1=vial_d, d2=vial_d + 2*chamfer, h=chamfer);
}

module square_array(w, d) {
    cols = floor((w + pitch - vial_d) / pitch);
    rows = floor((d + pitch - vial_d) / pitch);
    mx = (w - (cols-1)*pitch) / 2;
    my = (d - (rows-1)*pitch) / 2;
    for (c=[0:cols-1])
        for (r=[0:rows-1])
            translate([mx + c*pitch, my + r*pitch, 0])
                chamfered_hole(pocket_d);
    // echo count
    echo("Square grid cols=",cols,"rows=",rows,"total=",cols*rows);
}

// Frame
module frame_box() {
    color("Gainsboro", 0.95)
    difference() {
        cube([outer_w, outer_d, frame_h]);
        translate([wall, wall, floor_t])
            cube([inner_w, inner_d, frame_h]);
        translate([wall, 0, 0])
            cube([inner_w, wall+1, frame_h]);
    }
}

// Drawer
module drawer_body() {
    dw = inner_w - 2*drawer_gap;
    dd = inner_d - drawer_gap;
    color("CornflowerBlue", 0.85)
    difference() {
        cube([dw, dd, drawer_h]);
        arr_w = dw - 2*wall;
        arr_d = dd - 2*wall;
        z0 = drawer_h - pocket_d - floor_t;
        translate([wall, wall, z0])
            square_array(arr_w, arr_d);
    }
    // pull handle — wide bar
    color("MidnightBlue")
    translate([dw/2 - 30, -10, drawer_h/2 - 7])
        cube([60, 10, 14]);
}

frame_box();

// show drawer pulled out
translate([wall+drawer_gap, -100, frame_h])
    drawer_body();

echo("outer W x D x H =", outer_w, outer_d, total_h);
