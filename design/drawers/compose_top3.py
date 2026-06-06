#!/usr/bin/env python3
import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
A,B,C = u("best/1_cabinet.png"),u("best/2_trays.png"),u("best/3_stairs.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";GRN="#34d399";YEL="#fbbf24";RED="#f0776a"
W,H=1320,1020
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def esc(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,txt,fill=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{esc(txt)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="11" fill="#17171f" stroke="{c}" stroke-opacity="0.55"/>')
t(W/2,44,"Peptide storage drawer set — 3 best of 20",INK,30,"middle","700")
t(W/2,68,"~15 × 15 in footprint · ≤ 5.5 in tall · all modular (every printed piece ≤ ~190 mm)",SUB,15,"middle")
cards=[
 (A,GRN,"① Classic drawer cabinet","Three pull-out drawers on a tiled frame",
   ["~372 × 372 × 138 mm","~24 standing vials + 12 pen/syringe slots + supply cells",
    "Most familiar 'drawer set'; everything hidden & dust-free",
    "Splits: frame L/R halves + drawers in halves (≤190 mm)"]),
 (B,YEL,"② Modular lift-out trays","Color-coded trays you lift straight out",
   ["~374 × 374 × 124 mm","~30 vials + 10 pens + open supply bins, reconfigurable",
    "Most flexible: pull a whole tray to your workspace; mix tray types",
    "Splits: 4 frame tiles ~187 mm + each tray ~178 mm"]),
 (C,RED,"③ Stair-tier open display","Tiered rows — every vial visible at a glance",
   ["~375 × 375 × 130 mm","64 vials (4 tiers × 16) + 6 syringes in a front tray",
    "Best visibility & speed; grab-and-go, nothing hidden",
    "Splits: left / right halves (≤188 mm)"]),
]
cw=(W-4*22)/3; ix=22; iy=92; iw=cw; ih=300
for i,(img,c,title,sub,bullets) in enumerate(cards):
    x=ix+i*(cw+22)
    panel(x,iy,cw,ih+250,c)
    s.append(f'<image href="{img}" x="{x+6}" y="{iy+6}" width="{cw-12}" height="{ih-6}" preserveAspectRatio="xMidYMid meet"/>')
    t(x+16,iy+ih+30,title,c,19,"start","700")
    t(x+16,iy+ih+52,sub,INK,13.5)
    for j,b in enumerate(bullets):
        t(x+16,iy+ih+80+j*30,"• "+b,SUB,12.5)
t(W/2,H-22,"Picked from 20 sub-agent iterations across 4 directions (cabinet · trays · vial-array · tilt/stairs). Vial-array hit ~376-vial capacity but rendered poorly — happy to revive it if you want max capacity.",SUB,12.5,"middle")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="drawers-top3.png",output_width=W*2,output_height=H*2)
print("wrote drawers-top3.png")
