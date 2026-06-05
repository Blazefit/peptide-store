// Final snap-fit — MAX: 5 pens at 66deg (fits 63.5mm width).
// Snap-fit C-grooves + flex fingers.
include <rack_lib.scad>
rack(n=5, phi=66, P=22.5, lip=4.6, endwall=3, scoop=true, flex=5);
