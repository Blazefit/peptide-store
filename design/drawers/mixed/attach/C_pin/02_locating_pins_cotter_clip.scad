// 02_locating_pins_cotter_clip.scad
// Four locating pins on lower tray corners + a separate U-shaped cotter clip
// that slides over both trays on the long side to pin them together.
// Engage: set upper on pins, slide clip down. Release: slide clip up & off.

explode = 35; // 0=engaged, 35=exploded

lx=305; ly=102; lz=50;
ux=305; uy=102; uz=33;
wall=3;

pin_d   = 5;   // locating pin diameter
pin_h   = 10;  // pin protrusion above lower tray top
hole_cl = 0.3; // clearance for pin holes

clip_t  = 2.5; // clip wall thickness
clip_gap= lz+uz+0.6; // slot height (total stack height + clearance)
clip_len= 40;  // clip length along X
clip_w  = ly + clip_t*2; // clip spans full Y

module lower_tray() { color("SteelBlue",0.85) cube([lx,ly,lz]); }
module upper_tray() { color("LightSkyBlue",0.85) cube([ux,uy,uz]); }

// Pin boss on lower tray top face
module pin_boss(d, h) {
    boss_d = d + wall*1.2;
    color("DarkOrange",0.9) {
        cylinder(d=boss_d, h=wall*0.6, $fn=24);
        cylinder(d=d, h=h+wall*0.6, $fn=24);
    }
}

// Pin socket recess in upper tray bottom
module pin_socket(d, h) {
    cylinder(d=d+hole_cl, h=h+1, $fn=24);
}

// U-clip: spans the long side of the stack
module u_clip(engaged) {
    // clip sits flush against one long face (Y=0 side)
    // U opens in +Y direction; legs grip the outer long faces
    color("Orange", 0.92)
    difference() {
        // outer block
        cube([clip_len, clip_t + ly + clip_t, clip_gap + clip_t]);
        // inner cutout — the slot the two trays fit into
        translate([clip_t, clip_t, clip_t])
            cube([clip_len - clip_t*2, ly, clip_gap + 0.1]);
        // open the front (entry side)
        translate([clip_t, clip_t + ly - 0.1, 0])
            cube([clip_len - clip_t*2, clip_t + 1, clip_gap + clip_t + 0.1]);
        // chamfer entry on clip top
        translate([clip_t, clip_t*2, clip_gap + clip_t - clip_t*0.8])
            rotate([-45,0,0])
                cube([clip_len-clip_t*2, clip_t*2, clip_t*2]);
    }
}

// --- Assemble lower tray ---
lower_tray();

// Four pins on lower tray: near each corner, inset from edge
pin_positions = [
    [wall*2 + pin_d, wall*2 + pin_d],
    [lx - wall*2 - pin_d, wall*2 + pin_d],
    [wall*2 + pin_d, ly - wall*2 - pin_d],
    [lx - wall*2 - pin_d, ly - wall*2 - pin_d]
];

for(p = pin_positions)
    translate([p[0], p[1], lz])
        pin_boss(pin_d, pin_h);

// --- Upper tray with pin sockets ---
translate([0, 0, lz + explode])
difference() {
    upper_tray();
    for(p = pin_positions)
        translate([p[0], p[1], -pin_h])
            pin_socket(pin_d, pin_h + wall + 1);
}

// --- U-clip, placed on the long side ---
clip_x_offset = lx/2 - clip_len/2;
clip_z_offset = explode > 0 ? lz + uz + explode + 15 : 0;

translate([clip_x_offset, -clip_t, clip_z_offset])
    u_clip(explode == 0);
