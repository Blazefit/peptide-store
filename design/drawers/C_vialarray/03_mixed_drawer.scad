// 03_mixed_drawer.scad
// Mixed drawer: vial array (left 60%) + pen lanes (right 20%) + supply bin (right 20%)
// Outer: 374 x 374 x 80 mm
// Vial zone: ~220 mm wide, hex-packed → ~56 vials
// Pen zone: 2 lanes × Ø20 mm × 165 mm → 2 pens (lying flat)
// Supply bin: open box ~70 × 340 mm
// Splits: Left drawer half (≤190 mm) + Right drawer half (≤190 mm) + Frame front/back halves

$fn = 36;

outer_w = 374;
outer_d = 374;
total_h = 80;
wall    = 3.2;
floor_t = 3.0;
frame_h = 15;
gap     = 1.0;

inner_w = outer_w - 2*wall;
inner_d = outer_d - 2*wall;
drawer_h = total_h - frame_h - 1;

// zone widths (inside drawer interior)
dw = inner_w - 2*gap;
dd = inner_d - gap;
arr_inner_w = dw - 2*wall;
arr_inner_d = dd - 2*wall;

vial_zone_w  = 210;
pen_zone_w   = 72;
supply_zone_w = arr_inner_w - vial_zone_w - pen_zone_w - 2*wall; // remainder

vial_d    = 23.5;
hex_col_p = vial_d + 1.5;
hex_row_p = hex_col_p * sin(60);
vial_depth = 42;
chamfer   = 3.0;

pen_d     = 21.0;
pen_len   = 165;

module vial_hole() {
    cylinder(d=vial_d, h=vial_depth);
    translate([0,0,vial_depth])
        cylinder(d1=vial_d, d2=vial_d+2*chamfer, h=chamfer);
}

module hex_vials(w, d) {
    rows = floor((d - vial_d) / hex_row_p);
    cols = floor((w - vial_d) / hex_col_p);
    mx = (w - (cols-1)*hex_col_p) / 2;
    my = (d - (rows-1)*hex_row_p) / 2;
    for (r=[0:rows-1]) {
        ox = (r%2==1) ? hex_col_p/2 : 0;
        for (c=[0:cols-1]) {
            x = mx + c*hex_col_p + ox;
            if (x > vial_d/2 && x < w-vial_d/2)
                translate([x, my + r*hex_row_p, 0]) vial_hole();
        }
    }
    echo("Vial zone cols=",cols,"rows=",rows);
}

module pen_lane(len) {
    // rounded trough lying flat
    hull() {
        translate([pen_d/2, 0, 0])   cylinder(d=pen_d, h=4);
        translate([pen_d/2, len, 0]) cylinder(d=pen_d, h=4);
    }
}

module frame_box() {
    color("Gainsboro",0.9)
    difference() {
        cube([outer_w, outer_d, frame_h]);
        translate([wall,wall,floor_t]) cube([inner_w,inner_d,frame_h]);
        translate([wall,0,0]) cube([inner_w,wall+1,frame_h]);
    }
}

module drawer_body() {
    color("MediumSeaGreen",0.85)
    difference() {
        cube([dw, dd, drawer_h]);
        z0 = drawer_h - vial_depth - floor_t;
        // vial zone
        translate([wall, wall, z0])
            hex_vials(vial_zone_w, arr_inner_d);
        // pen lanes (2, lying flat in troughs)
        pen_x = wall + vial_zone_w + wall;
        pen_z = drawer_h - pen_d/2 - floor_t - 2;
        translate([pen_x + pen_d/2, wall + 5, pen_z])
            pen_lane(pen_len);
        translate([pen_x + pen_d/2 + pen_d + 4, wall + 5, pen_z])
            pen_lane(pen_len);
        // supply bin — open cutout
        bin_x = pen_x + pen_zone_w + wall;
        bin_z = floor_t;
        translate([bin_x, wall, bin_z])
            cube([supply_zone_w, arr_inner_d, drawer_h]);
    }
    // divider walls inside
    color("SeaGreen")
    translate([wall + vial_zone_w, wall, floor_t])
        cube([wall, arr_inner_d, drawer_h - floor_t - 1]);
    translate([wall + vial_zone_w + wall + pen_zone_w, wall, floor_t])
        cube([wall, arr_inner_d, drawer_h - floor_t - 1]);
    // pull
    color("DarkGreen")
    translate([dw/2-25, -10, drawer_h/2-7]) cube([50,10,14]);
}

frame_box();
translate([wall+gap, -110, frame_h]) drawer_body();

echo("outer W x D x H =", outer_w, outer_d, total_h);
echo("pen lanes = 2");
