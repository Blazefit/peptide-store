// 05_lift_rack.scad
// Best refinement: removable vial cartridges/racks that lift out of a low frame
// Frame: 374 × 374 × 70 mm outer; 4 cartridge slots side by side (each ~88 mm wide)
// Each cartridge: 88 × 360 × 60 mm, hex-packed vials, labeled row ridges
// Cartridge print size: 88 × 180 mm (split front/back halves, glue or snap)
// Total: 4 cartridges × ~21 vials each = ~84 vials
// + 1 pen tray slot at rear of frame (2 pen lanes, Ø21 mm × 165 mm)
// Outer frame splits: front half (≤190 mm) + back half (≤190 mm)

$fn = 36;

outer_w = 374;
outer_d = 374;
outer_h = 70;
wall    = 3.0;
floor_t = 3.0;

// cartridge dims
num_carts = 4;
cart_gap  = 1.5;  // clearance per side
total_cart_zone_w = outer_w - 2*wall;  // 368 mm
cart_w = (total_cart_zone_w - (num_carts+1)*cart_gap) / num_carts;  // ~89 mm
cart_d = outer_d - 2*wall - 2*cart_gap;   // 362 mm
cart_h = outer_h - floor_t - 2;            // 65 mm

vial_d    = 23.5;
chamfer   = 3.0;
vial_dep  = 50;  // pockets deep enough for vials to stand (~52 mm vial, gripped to ~50 mm)
hex_col_p = vial_d + 2.0;    // 25.5 mm — slightly more room per cartridge
hex_row_p = hex_col_p * sin(60);  // ~22.08 mm

pen_d   = 21.5;
pen_len = 168;

// label ridge spacing
label_pitch = hex_row_p;

module vial_hole() {
    cylinder(d=vial_d, h=vial_dep);
    translate([0,0,vial_dep])
        cylinder(d1=vial_d, d2=vial_d+2*chamfer, h=chamfer);
}

module hex_in_cart(w, d) {
    rows = floor((d - vial_d) / hex_row_p);
    cols = floor((w - vial_d) / hex_col_p);
    mx = (w - (cols-1)*hex_col_p) / 2;
    my = (d - (rows-1)*hex_row_p) / 2;
    for (r=[0:rows-1]) {
        ox = (r%2==1) ? hex_col_p/2 : 0;
        for (c=[0:cols-1]) {
            x = mx + c*hex_col_p + ox;
            if (x>vial_d/2 && x<w-vial_d/2)
                translate([x, my+r*hex_row_p, 0]) vial_hole();
        }
    }
    echo("cart cols=",cols,"rows=",rows,"per-cart≈",cols*rows - floor(rows/2));
}

module label_ridges(w, d) {
    rows = floor((d - vial_d) / hex_row_p);
    mx_d = (d - (rows-1)*hex_row_p) / 2;
    // tiny ridge along left edge for each row
    for (r=[0:rows-1]) {
        y = mx_d + r*hex_row_p - 1;
        translate([-0.5, y, cart_h - vial_dep - floor_t + vial_dep + 1])
            cube([2, 2, 2]);
    }
}

module cartridge(idx) {
    colors = ["CornflowerBlue","SteelBlue","DodgerBlue","SlateBlue"];
    color(colors[idx % 4], 0.88)
    difference() {
        // body
        cube([cart_w, cart_d, cart_h]);
        // vial pocket array
        arr_w = cart_w - 2*wall;
        arr_d = cart_d - 2*wall;
        z0 = cart_h - vial_dep - floor_t;
        translate([wall, wall, z0])
            hex_in_cart(arr_w, arr_d);
        // side grip scallops
        for (gy=[40, 120, 200, 280])
            translate([-1, gy, cart_h*0.4])
                rotate([0,90,0]) cylinder(d=14, h=wall+2);
    }
    // label ridges on side face
    color("White")
    label_ridges(cart_w - 2*wall, cart_d - 2*wall);
    // lift tab on top
    color("Navy")
    translate([cart_w/2 - 14, cart_d - 12, cart_h - 1])
        cube([28, 10, 4]);
}

module pen_tray() {
    tw = outer_w - 2*wall;
    td = 30;
    th = outer_h - floor_t;
    color("DarkSeaGreen", 0.9)
    difference() {
        cube([tw, td, th]);
        // 2 pen troughs
        for (pi=[0:1]) {
            py = 5 + pi*(pen_d + 5);
            translate([5, py + pen_d/2, floor_t])
                hull() {
                    translate([pen_d/2, 0, 0]) cylinder(d=pen_d, h=th);
                    translate([tw - 10, 0, 0]) cylinder(d=pen_d, h=th);
                }
        }
    }
}

// Outer frame
module frame() {
    color("WhiteSmoke", 0.92)
    difference() {
        cube([outer_w, outer_d, outer_h]);
        // 4 cartridge slots
        for (i=[0:num_carts-1]) {
            x = wall + cart_gap + i*(cart_w + cart_gap);
            translate([x, wall + cart_gap, floor_t])
                cube([cart_w, cart_d, outer_h]);
        }
        // rear pen tray slot
        translate([wall, outer_d - wall - 30 - 1, floor_t])
            cube([outer_w - 2*wall, 31, outer_h]);
        // front open face
        translate([wall, 0, floor_t])
            cube([outer_w - 2*wall, wall+1, outer_h]);
    }
}

frame();

// Place 3 cartridges seated, 1 lifted out for display
for (i=[0:num_carts-1]) {
    x = wall + cart_gap + i*(cart_w + cart_gap);
    y = wall + cart_gap;
    z_lift = (i == 2) ? outer_h + 20 : floor_t;
    translate([x, y, z_lift])
        cartridge(i);
}

// pen tray at rear
translate([wall, outer_d - wall - 30, floor_t])
    pen_tray();

rows_c = floor(((cart_d - 2*wall) - vial_d) / hex_row_p);
cols_c = floor(((cart_w - 2*wall) - vial_d) / hex_col_p);
per_cart = cols_c*rows_c - floor(rows_c/2);
echo("Per cart vials =", per_cart, "  Total (×4) =", 4*per_cart);
echo("outer W x D x H =", outer_w, outer_d, outer_h);
echo("pen lanes = 2 (in rear pen tray)");
