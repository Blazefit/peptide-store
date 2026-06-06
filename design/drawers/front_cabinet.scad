// =============================================================================
// Front-access peptide drawer cabinet (for a fridge gap — pull OUT THE FRONT)
// Everything slides forward; nothing needs top or side access.
// mode: "mixed" | "vials" | "trays"
// =============================================================================
mode      = "mixed";   // [mixed, vials, trays]
open_ext  = 150;       // preview: how far the top drawer is pulled forward (mm)

W = 375; D = 375; H = 135;   // outer envelope (~15 x 15 x 5.3 in)
wall = 4; clr = 1.2;         // shell wall + drawer running clearance
$fn = 44;

front_face = 6;              // drawer front face thickness
// bay layout per mode: list of [interior_height, type]
bays = mode=="vials" ? [[58,"vial"],[58,"vial"]]
     : mode=="trays" ? [[34,"tray"],[34,"tray"],[34,"tray"]]
     :                 [[56,"vial"],[34,"pen"],[26,"supply"]];   // mixed

iw = W - 2*wall;            // interior width
idp= D - wall;             // interior depth (front open)

// shelf z positions (bottom of each bay interior)
function bay_z(i) = wall + i==0?0:0;  // placeholder (computed below via recursion)
function zsum(i) = i<=0 ? wall : zsum(i-1) + bays[i-1][0] + wall;

// --------------------------------------------------------------- frame
module frame() {
    color("#9aa3b2") difference() {
        cube([W, D, H]);
        // hollow each bay opening from the front
        for (i=[0:len(bays)-1]) {
            z0 = zsum(i);
            translate([wall, -1, z0])
                cube([iw, D-wall+1, bays[i][0]]);
        }
        // back vent + lightening window
        translate([W/2-70, D-wall-1, 18]) cube([140, wall+2, H-40]);
    }
    // drawer-stop nibs at the back of each bay (so drawers don't push through)
    color("#9aa3b2") for (i=[0:len(bays)-1])
        translate([W/2-30, D-wall-3, zsum(i)]) cube([60, 3, 6]);
}

// --------------------------------------------------------------- a drawer
module drawer(i, ext) {
    h    = bays[i][0];
    type = bays[i][1];
    dw   = iw - 2*clr;          // drawer outer width
    dd   = idp - 2;             // drawer depth
    dh   = h - clr;             // drawer height
    fw   = 3;                   // drawer wall
    col  = type=="vial" ? "#7c9cf0" : type=="pen" ? "#f0a23b"
         : type=="supply" ? "#34d399" : "#c0b0e8";
    translate([wall+clr, -ext, zsum(i)]) color(col) {
        difference() {
            union() {
                // open-top box
                difference() {
                    cube([dw, dd, dh]);
                    translate([fw, fw, fw]) cube([dw-2*fw, dd-2*fw, dh]);
                }
                // front face (taller for trays it's a low lip)
                fh = (type=="tray") ? min(dh, 22) : dh + front_face;
                translate([0,0,0]) cube([dw, front_face, fh]);
                // handle: bar (drawers) or scoop rail (trays)
                if (type=="tray")
                    translate([dw/2-35, -3, min(dh,22)-7]) cube([70, 4, 5]);
                else
                    translate([dw/2-40, -8, dh*0.45]) cube([80, 8, 16]);
            }
            if (type=="tray")            // finger scoop in the low front lip
                translate([dw/2, -2, 26]) rotate([-90,0,0]) cylinder(h=10, r=11);
        }
        // ---- interiors ----
        if (type=="vial") vial_grid(dw, dd, fw, dh);
        if (type=="pen")  pen_lanes(dw, dd, fw, dh);
        if (type=="supply") supply_cells(dw, dd, fw, dh);
        if (type=="tray") tray_dividers(dw, dd, fw, dh);
    }
}

module vial_grid(dw, dd, fw, dh) {
    p = 27; dia = 23;
    nx = floor((dw-2*fw-4)/p); ny = floor((dd-2*fw-4)/p);
    ox = fw + (dw-2*fw-(nx-1)*p)/2; oy = fw + (dd-2*fw-(ny-1)*p)/2;
    // a filler block with clean blind holes (distinct bottom -> no z-fighting)
    color("#6f8fe6") difference() {
        translate([fw, fw, fw]) cube([dw-2*fw, dd-2*fw, dh-fw-3]);
        for (ix=[0:nx-1]) for (iy=[0:ny-1])
            translate([ox+ix*p, oy+iy*p, fw+5]) cylinder(h=dh, d=dia);
    }
    echo(str(mode," vial drawer holds ", nx*ny, " vials (", nx, "x", ny, ")"));
}
module pen_lanes(dw, dd, fw, dh) {
    n = floor((dw-2*fw)/26);
    for (k=[1:n-1]) translate([fw + k*(dw-2*fw)/n -1, fw, fw])
        cube([2, dd-2*fw, dh-fw-2]);     // lane divider walls (pens lie front-back)
}
module supply_cells(dw, dd, fw, dh) {
    for (k=[1:2]) translate([fw + k*(dw-2*fw)/3 -1, fw, fw]) cube([2, dd-2*fw, dh-fw]);
    translate([fw, fw + (dd-2*fw)/2 -1, fw]) cube([dw-2*fw, 2, dh-fw]);
}
module tray_dividers(dw, dd, fw, dh) {
    translate([dw/2-1, fw, fw]) cube([2, dd-2*fw, dh-fw-2]);   // one length divider
}

// --------------------------------------------------------------- assembly
frame();
// cascade open toward the front (bottom drawer furthest) so interiors show
for (i=[0:len(bays)-1]) drawer(i, 35 + (len(bays)-1-i)*65);
echo(str("mode=", mode, "  outer ", W, "x", D, "x", H, "  bays=", len(bays)));
