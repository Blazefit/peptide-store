import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
A,B,C = u("best/front_mixed.png"),u("best/front_vials.png"),u("best/front_trays.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";GRN="#34d399";YEL="#fbbf24";BLU="#7c9cf0"
W,H=1320,1010
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="11" fill="#17171f" stroke="{c}" stroke-opacity="0.55"/>')
t(W/2,42,"Fridge-friendly drawer set — FRONT access only",INK,29,"middle","700")
t(W/2,66,"sits between fridge shelves · everything pulls OUT THE FRONT (no top/side reach needed) · ~15 × 15 in × ≤5.5 in",SUB,14.5,"middle")
cards=[
 (A,GRN,"① Mixed drawers","Vials + pens + supplies, all enclosed",
  ["3 pull-out drawers (vial grid · pen lanes · supply cells)","~160 vials + ~12 pens + supply compartments",
   "Dust- & light-protected; the all-rounder","Pull a drawer fully forward, grab, slide back"]),
 (B,BLU,"② Max-vial drawers","Highest capacity for vial storage",
  ["2 deep pull-out drawers, full vial grids","up to ~330 vials total (≈165 per drawer)",
   "For storing lots of vials at once","Clean chamfer-free pockets, finger pulls"]),
 (C,ACC,"③ Open front trays","Quick-glance, low fronts",
  ["3 shallow open trays with low scoop fronts","mix freely; see contents without full pull-out",
   "Fastest grab; easy to wipe out / reconfigure","Finger-scoop notch on each tray front"]),
]
cw=(W-4*22)/3; iy=92; ih=300
for i,(img,c,title,sub,bl) in enumerate(cards):
    x=22+i*(cw+22); panel(x,iy,cw,ih+240,c)
    s.append(f'<image href="{img}" x="{x+6}" y="{iy+6}" width="{cw-12}" height="{ih-6}" preserveAspectRatio="xMidYMid meet"/>')
    t(x+16,iy+ih+30,title,c,19,"start","700"); t(x+16,iy+ih+52,sub,INK,13.5)
    for j,b in enumerate(bl): t(x+16,iy+ih+80+j*30,"• "+b,SUB,12.5)
t(W/2,H-20,"Prints modular: built as a 2×2 of identical mini-cabinets (each ≤ ~190 mm) that lock into the full 15-in footprint — fits any normal bed.",SUB,12.5,"middle")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="drawers-front3.png",output_width=W*2,output_height=H*2)
print("ok")
