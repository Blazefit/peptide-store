// 03_magnet_corner_pockets.scad
// Ø6×3 mm disc magnets recessed into raised alignment bosses at all four
// corners of both mating faces. Trays self-locate and hold magnetically.
// Engage: lower upper tray onto lower — bosses nest, magnets snap.
// Release: pry any corner upward by hand.
//
// explode=0  → engaged
// explode=40 → open/exploded (bosses & magnets visible)

explode = 40;

lx=305; ly=102; lz=50;
ux=305; uy=102; uz=33;

mag_d    = 6.4;   // magnet pocket Ø (6 mm + 0.4 clearance)
mag_h    = 3.3;   // magnet pocket depth
boss_r   = 8;     // boss outer radius (16 mm dia — large & clear)
boss_h   = 5;     // boss protrusion height above mating face
inset    = boss_r + 3; // corner inset

corners = [
    [inset,    inset   ],
    [lx-inset, inset   ],
    [inset,    ly-inset],
    [lx-inset, ly-inset]
];

module lower_tray() { color("SteelBlue",0.85)    cube([lx,ly,lz]); }
module upper_tray() { color("LightSkyBlue",0.85) cube([ux,uy,uz]); }

// Visible magnet disc (silver)
module magnet(z) {
    color("Silver",1.0)
    translate([0,0,z])
        cylinder(d=mag_d-0.5, h=3.0, $fn=28);
}

// ==== Lower tray: bosses stand UP, magnet pocket from top ====
difference() {
    union() {
        lower_tray();
        // Raised bosses on top face
        color("DarkOrange",0.9)
        for(c=corners)
            translate([c[0], c[1], lz])
                cylinder(r=boss_r, h=boss_h, $fn=28);
    }
    // Magnet pockets recessed from top of each boss
    for(c=corners)
        translate([c[0], c[1], lz + boss_h - mag_h])
            cylinder(d=mag_d, h=mag_h+0.3, $fn=28);
}

// Magnets in lower bosses (always shown so they're visible in exploded)
for(c=corners)
    translate([c[0], c[1], 0])
        magnet(lz + boss_h - mag_h + 0.15);

// ==== Upper tray: sockets recess to receive lower bosses ====
translate([0, 0, lz + boss_h + explode])
difference() {
    upper_tray();
    // Socket holes in bottom face to receive bosses (+ 0.4 clearance)
    for(c=corners)
        translate([c[0], c[1], -boss_h - 0.1])
            cylinder(r=boss_r + 0.3, h=boss_h + 0.2, $fn=28);
    // Magnet pockets recessed from bottom of each socket
    for(c=corners)
        translate([c[0], c[1], -mag_h - 0.1])
            cylinder(d=mag_d, h=mag_h + 0.3, $fn=28);
}

// Magnets in upper sockets
for(c=corners)
    translate([c[0], c[1], lz + boss_h + explode - mag_h + 0.15 - 0.05])
        magnet(0);
