// 04_two_drawers.scad
// Two stacked drawers, each with hex-packed vial array → max total capacity
// Outer: 374 x 374 x 130 mm (fits in 139.7 mm envelope)
// Each drawer: hex array ~56 vials → total ~112 vials
// Frame splits front/back for ≤240 mm print; each drawer splits left/right halves
// Drawer height ~52 mm each, fits vials standing (52 mm > vial 52 mm, snug)

$fn = 36;

outer_w  = 374;
outer_d  = 374;
total_h  = 130;
wall     = 3.2;
floor_t  = 3.0;
gap      = 1.0;

num_drawers = 2;
frame_rail_h = 8;   // each rail between drawers
// available height split: total - top cap - bottom cap
cap_h    = 6;
drawer_slot_h = (total_h - 2*cap_h - (num_drawers-1)*frame_rail_h) / num_drawers;
// = (130 - 12 - 8) / 2 = 55 mm
drawer_h = drawer_slot_h - gap;  // ~54 mm

vial_d   = 23.5;
chamfer  = 3.0;
vial_dep = 45;   // pocket depth — vials stand in it
hex_col_p = vial_d + 1.5;
hex_row_p = hex_col_p * sin(60);

inner_w  = outer_w - 2*wall;
inner_d  = outer_d - 2*wall;
dw       = inner_w - 2*gap;
dd       = inner_d - gap;
arr_w    = dw - 2*wall;
arr_d    = dd - 2*wall;

module vial_hole() {
    cylinder(d=vial_d, h=vial_dep);
    translate([0,0,vial_dep]) cylinder(d1=vial_d,d2=vial_d+2*chamfer,h=chamfer);
}

module hex_array() {
    rows = floor((arr_d - vial_d) / hex_row_p);
    cols = floor((arr_w - vial_d) / hex_col_p);
    mx = (arr_w - (cols-1)*hex_col_p) / 2;
    my = (arr_d - (rows-1)*hex_row_p) / 2;
    for (r=[0:rows-1]) {
        ox = (r%2==1) ? hex_col_p/2 : 0;
        for (c=[0:cols-1]) {
            x = mx + c*hex_col_p + ox;
            if (x>vial_d/2 && x<arr_w-vial_d/2)
                translate([x, my+r*hex_row_p, 0]) vial_hole();
        }
    }
    echo("hex rows=",rows,"cols=",cols);
}

module drawer(clr) {
    color(clr, 0.85)
    difference() {
        cube([dw, dd, drawer_h]);
        z0 = drawer_h - vial_dep - floor_t;
        translate([wall, wall, z0]) hex_array();
    }
    // pull tab
    color("Navy")
    translate([dw/2-22, -10, drawer_h/2-6]) cube([44,10,12]);
}

// Outer housing
module housing() {
    color("LightGray", 0.92)
    difference() {
        cube([outer_w, outer_d, total_h]);
        // two drawer slots
        for (i=[0:num_drawers-1]) {
            z_slot = cap_h + i*(drawer_slot_h + frame_rail_h);
            translate([wall, wall, z_slot])
                cube([inner_w, inner_d, drawer_slot_h]);
            // front opening
            translate([wall, 0, z_slot])
                cube([inner_w, wall+1, drawer_slot_h]);
        }
    }
}

housing();

// Draw drawer 0 in place and drawer 1 pulled out
for (i=[0:1]) {
    z_slot = cap_h + i*(drawer_slot_h + frame_rail_h);
    y_pull = (i == 1) ? -120 : 0;
    clr = (i == 0) ? "SteelBlue" : "DodgerBlue";
    translate([wall+gap, wall+gap + y_pull, z_slot])
        drawer(clr);
}

rows_c = floor((arr_d - vial_d) / hex_row_p);
cols_c = floor((arr_w - vial_d) / hex_col_p);
echo("Per-drawer approx vials =", rows_c*cols_c - floor(rows_c/2));
echo("Total vials (×2) =", 2*(rows_c*cols_c - floor(rows_c/2)));
echo("outer W x D x H =", outer_w, outer_d, total_h);
echo("drawer_h =", drawer_h);
