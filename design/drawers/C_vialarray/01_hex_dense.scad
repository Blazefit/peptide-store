// 01_hex_dense.scad
// Single big drawer with dense hex-packed vial holes
// Outer: 370 x 370 x 68 mm (drawer box + frame shell)
// Vial hole: Ø23.5 mm (22 mm vial + 1.5 mm clearance), depth 40 mm
// Hex packing: row offset = Ø*sin(60) ≈ 20.35 mm, col pitch = 24.5 mm
// Two sections for printing: Left half and Right half, each ~185 mm wide
// Result: ~112 vials in hex layout

$fn = 36;

// ---- params ----
outer_w  = 370;
outer_d  = 370;
shell_h  = 68;        // total height of drawer unit
wall     = 3.0;
floor_t  = 3.0;
drawer_gap = 1.0;     // clearance each side

vial_d   = 23.5;      // hole diameter
vial_depth = 40;      // pocket depth
hex_col_pitch = vial_d + 1.5;          // 25 mm
hex_row_pitch = hex_col_pitch * sin(60); // ~21.65 mm

frame_h  = 12;        // outer frame rail height
drawer_h = shell_h - frame_h - 1;      // ~55 mm

// ---- derived ----
inner_w = outer_w - 2*wall;
inner_d = outer_d - 2*wall;

// ---- modules ----
module vial_hole() {
    // chamfered lead-in at top
    cylinder(d=vial_d, h=vial_depth);
    translate([0,0,vial_depth])
        cylinder(d1=vial_d, d2=vial_d+3, h=3);
}

module hex_array(w, d, z_offset) {
    rows = floor((d - vial_d) / hex_row_pitch);
    cols = floor((w - vial_d) / hex_col_pitch);
    margin_x = (w - (cols-1)*hex_col_pitch) / 2;
    margin_y = (d - (rows-1)*hex_row_pitch) / 2;
    for (r = [0 : rows-1]) {
        offset_x = (r % 2 == 1) ? hex_col_pitch/2 : 0;
        for (c = [0 : cols-1]) {
            x = margin_x + c*hex_col_pitch + offset_x;
            y = margin_y + r*hex_row_pitch;
            if (x > vial_d/2 && x < w - vial_d/2)
                translate([x, y, z_offset])
                    vial_hole();
        }
    }
}

// ---- Frame / housing ----
module frame() {
    difference() {
        cube([outer_w, outer_d, frame_h]);
        // inner cutout
        translate([wall, wall, floor_t])
            cube([inner_w, inner_d, frame_h]);
        // front opening for drawer
        translate([wall, 0, 0])
            cube([inner_w, wall+1, frame_h]);
    }
}

// ---- Drawer body ----
module drawer() {
    color("SteelBlue", 0.85)
    difference() {
        cube([inner_w - 2*drawer_gap, inner_d - drawer_gap, drawer_h]);
        // vial holes — use full inner area minus thin walls
        arr_w = inner_w - 2*drawer_gap - 2*wall;
        arr_d = inner_d - drawer_gap - 2*wall;
        translate([wall, wall, drawer_h - vial_depth - floor_t])
            hex_array(arr_w, arr_d, 0);
    }
    // pull tab
    color("DarkSlateBlue")
    translate([(inner_w - 2*drawer_gap)/2 - 18, -8, drawer_h/2 - 8])
        cube([36, 8, 16]);
}

// ---- Assembly ----
// Frame at base
color("WhiteSmoke", 0.9)
frame();

// Drawer shown pulled out ~80 mm
translate([wall + drawer_gap, -90, frame_h])
    drawer();

// ---- Vial count annotation (echo) ----
arr_w2 = inner_w - 2*drawer_gap - 2*wall - 2;
arr_d2 = inner_d - drawer_gap - 2*wall - 2;
rows2 = floor((arr_d2 - vial_d) / hex_row_pitch);
cols2 = floor((arr_w2 - vial_d) / hex_col_pitch);
// approximate — odd rows may lose one col
echo("Approx vial count =", rows2*cols2 - floor(rows2/2));
echo("rows=", rows2, "cols=", cols2);
echo("outer W x D x H =", outer_w, outer_d, shell_h);
