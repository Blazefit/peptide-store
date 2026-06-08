// 01_vertical_dovetail_detent.scad
// Vertical dovetail rail on each short end of the stack.
// Upper tray slides DOWN onto lower; a printed spring-tab detent
// clicks into a notch and resists lifting.
// Release: squeeze detent tab, slide upper UP.
//
// explode=0  → engaged (trays together)
// explode=40 → open/exploded

explode = 40;

// Tray dims
lx=305; ly=102; lz=50;   // lower tray
ux=305; uy=102; uz=33;   // upper tray

// Dovetail rail on the short-end OUTER FACE (X=0 and X=lx)
// Rail runs vertically (Z), is centred on Y
dt_w    = 14;   // dovetail narrow width at root
dt_wide = 22;   // dovetail wide width at tip
dt_h    = 10;   // rail depth proud of face
dt_len  = uz*0.7; // rail length (shorter than upper tray height)

// Detent
det_d   = 6;    // ball/bump diameter
tab_w   = 18;
tab_h   = uz*0.6;
tab_t   = 3.2;

module lower_tray() {
    color("SteelBlue",0.85) cube([lx,ly,lz]);
}
module upper_tray() {
    color("LightSkyBlue",0.85) cube([ux,uy,uz]);
}

// Dovetail MALE rail (on lower tray end face)
module dt_rail_male() {
    color("DarkOrange",0.95)
    hull() {
        translate([0, ly/2 - dt_w/2, 0])  cube([dt_h*0.1, dt_w,    dt_len]);
        translate([0, ly/2 - dt_wide/2, dt_h]) cube([dt_h*0.1, dt_wide, dt_len]);
    }
}

// Dovetail FEMALE socket (cut into upper tray end face)
module dt_socket_cut() {
    cl = 0.35;
    hull() {
        translate([0, ly/2 - dt_w/2 - cl, -1])       cube([dt_h+0.2, dt_w+cl*2,    dt_len+2]);
        translate([0, ly/2 - dt_wide/2 - cl, dt_h-cl]) cube([dt_h+0.2, dt_wide+cl*2, dt_len+2]);
    }
}

// Spring detent tab — sits on lower tray end face, snaps into notch on upper tray
module detent_tab(side) {
    s = (side==0) ? 1 : -1;
    // Tab body
    color("Orange",0.92)
    difference() {
        translate([0, ly/2 - tab_w/2, lz - tab_h])
            cube([tab_t, tab_w, tab_h]);
        // Flex slot (vertical centre cut, leaves two finger cantilevers)
        translate([-0.1, ly/2 - 1.2, lz - tab_h + 2])
            cube([tab_t + 0.2, 2.4, tab_h]);
        // Detent bump hole in tab
        translate([tab_t, ly/2, lz - tab_h*0.45])
            rotate([0,-90,0]) cylinder(d=det_d, h=tab_t+0.2, $fn=20);
    }
    // Detent bump protruding outward
    color("DarkOrange",0.95)
    translate([tab_t - det_d*0.25, ly/2, lz - tab_h*0.45])
        rotate([0,-90,0]) cylinder(d=det_d*0.82, h=det_d*0.3, $fn=20);
}

// Detent notch recess cut in upper tray end face
module detent_notch_cut() {
    translate([0, ly/2, -tab_h*0.45 + uz])
        rotate([0,-90,0]) cylinder(d=det_d*0.82+0.4, h=3, $fn=20);
}

// ==== Lower tray assembly ====
difference() {
    lower_tray();
}

// Male dovetail rails on BOTH short ends of lower tray top portion
translate([0 - dt_h, 0, lz - dt_len])
    dt_rail_male();
translate([lx, 0, lz - dt_len])
    mirror([1,0,0]) dt_rail_male();

// Detent tabs on lower tray short ends
detent_tab(0);
translate([lx + tab_t, 0, 0]) mirror([1,0,0]) detent_tab(1);

// ==== Upper tray assembly (lifted by explode) ====
translate([0, 0, lz + explode])
difference() {
    union() {
        upper_tray();
    }
    // Female dovetail sockets in upper tray short-end faces
    translate([-dt_h - 0.05, 0, uz - dt_len - 0.5])
        dt_socket_cut();
    translate([ux + 0.05, 0, uz - dt_len - 0.5])
        mirror([1,0,0]) dt_socket_cut();
    // Detent notch in upper tray end face
    translate([-0.1, 0, 0]) detent_notch_cut();
    translate([ux + 0.1, 0, 0]) mirror([1,0,0]) detent_notch_cut();
}
