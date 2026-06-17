// sk1_sketch — from Jason's sketch: wedge with 4 stacked horizontal channels,
// each with a front lip to catch the pen; insert from the SIDE (one open end),
// pen settles into its channel and the lip keeps it from falling out the front.
include <lipcradle_lib.scad>
lipcradle(n=4, phi=36, P=22.5, lip=6, scoop=false, side_open=true);
