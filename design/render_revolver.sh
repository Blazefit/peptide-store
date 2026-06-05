#!/usr/bin/env bash
# Regenerate the revolver renders + composite preview from the .scad source.
# Needs: openscad, xvfb-run, python3 + cairosvg.
set -e
cd "$(dirname "$0")"
CAM="--imgsize=1000,1000 --colorscheme=Tomorrow --viewall --autocenter --projection=p"

xvfb-run -a openscad -o view_both.png $CAM --camera=0,0,0,62,0,22,0 \
    -D 'part="both"' -D 'show_pens=true' peptide-pen-revolver.scad
xvfb-run -a openscad -o view_drum.png $CAM --camera=0,0,0,60,0,30,0 \
    -D 'part="drum"' peptide-pen-revolver.scad
xvfb-run -a openscad -o view_base.png --imgsize=1000,750 --colorscheme=Tomorrow \
    --viewall --autocenter --projection=p --camera=0,0,0,60,0,20,0 \
    -D 'part="base"' peptide-pen-revolver.scad

python3 compose_revolver.py
echo "done -> revolver-preview.png"
