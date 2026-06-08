// clip_ends.scad — ADD-ON end clip that ties layer2 to the top piece (L3).
// Nothing is modified on either part; this is a separate printed clip (x2, one per end).
// Grabs: a barb into layer2's end WINDOW (z26-44) + a notch that grips OVER the top
// piece's end-wall TOP edge (z83). Hook the bottom barb into the window, then press
// the top notch over the top edge until the detent clicks.
//
// show = all | clips | layer2 | top | clip_one | exploded
show = "all";
$fn = 32;

L2 = "layer2.stl";      // imported originals (unmodified)
L3 = "top_piece.stl";
NTX = 304.8;            // end faces at x=0 and x=NTX
SEAT = 50;             // top piece seated on layer2 top (z=50)

// ---- clip parameters (left end, x=0; mirrored for right) ----
PT     = 3.0;          // spine plate thickness (sits outside the end face, x<0)
CY0    = 30; CY1 = 74; // clip width band in Y (inside both windows: L2 y22-80, L3 y17-85)
SP_Z0  = 33; SP_Z1 = 86;   // spine vertical span
// bottom barb into layer2 window (open z26-44, inner wall face x=3)
BB_Z0  = 33; BB_Z1 = 43;   // barb height (within window, top near z44)
BB_X   = 4.6;              // reaches 1.6mm past the 3mm wall (sits inside the window)
// top notch that grips L3 end-wall top (wall x0-3, top z83)
CLR    = 0.4;              // assembly clearance for print-bureau tolerances (MJF/SLS/FDM)
TN_OVER = 6;               // how far the over-top lip reaches inward
IN_LIP_X0 = 3.0+CLR; IN_LIP_X1 = 3.0+CLR+2.4;  // inner catching lip (clears the 3mm wall)
IN_LIP_Z0 = 78.5; IN_LIP_Z1 = 84.5;
DET_Z  = 79;               // detent bump height (clicks under the inner top edge)

C_L2="#1565C0"; C_L3="#9aa6b2"; C_CLIP="#C62828";

module originals(dz3=0){
    color(C_L2) import(L2);
    color(C_L3) translate([0,0,SEAT+dz3]) import(L3);
}

// clip for the LEFT end (x=0). Inward direction = +X.
module clip_left(){
  color(C_CLIP) union(){
    // spine plate (outside the end face)
    translate([-PT, CY0, SP_Z0]) cube([PT, CY1-CY0, SP_Z1-SP_Z0]);
    // bottom barb into layer2 window
    translate([-0.6, CY0+4, BB_Z0]) cube([BB_X+0.6, CY1-CY0-8, BB_Z1-BB_Z0]);
    // over-the-top lip (caps L3 end-wall top z83)
    translate([-PT, CY0, 83]) cube([PT+TN_OVER, CY1-CY0, 3]);
    // inner catching lip (drops behind the inner top edge -> grips the wall in X)
    translate([IN_LIP_X0-0.4, CY0+4, IN_LIP_Z0]) cube([IN_LIP_X1-IN_LIP_X0+0.4, CY1-CY0-8, IN_LIP_Z1-IN_LIP_Z0]);
    // small detent bump on the inner lip (snaps under the top edge)
    translate([IN_LIP_X1-0.2, CY0+8, DET_Z]) cube([1.0, CY1-CY0-16, 1.2]);
    // finger pull tab (outside)
    translate([-PT-6, CY0+(CY1-CY0)/2-9, SP_Z0]) cube([6.5, 18, 7]);
  }
}
module clip_right(){ translate([NTX,0,0]) mirror([1,0,0]) clip_left(); }
module clips(){ clip_left(); clip_right(); }

if      (show=="clips")    clips();
else if (show=="clip_one") clip_left();
else if (show=="layer2")   color(C_L2) import(L2);
else if (show=="top")      color(C_L3) translate([0,0,SEAT]) import(L3);
else if (show=="exploded"){ originals(35); translate([0,0,18]) clips(); }
else { originals(0); clips(); }
