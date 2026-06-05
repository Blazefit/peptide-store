// COMPACT — enclosed bores + front windows, 4 pens, vertical column on a base.
// Narrowest frontal footprint; steeper apex + wider base keep it support-free
// with comfortable margin.
include <borewin_lib.scad>
borewin(n=4, stepy=0, stepz=33, rwin=6.5, window=true, base_w=58, apexk=2.0);
