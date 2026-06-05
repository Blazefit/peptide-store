// Iter6 — RETENTION FIX: snap-fit C-grooves. Grooves cut 4.6mm below the ramp
// so each wraps >180deg around the pen (opening ~18.5mm < 20mm pen). The pen
// clips in past the lips and is positively captured -> will not fall out the
// front. 58deg balance, thumb scoops, back nameplate.
include <rack_lib.scad>
rack(n=4, phi=58, P=22.5, lip=4.6, endwall=3, scoop=true, plate=true);
