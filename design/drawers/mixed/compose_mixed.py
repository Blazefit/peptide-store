import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
CL,OP,VD,PD = u("iter14_closed.png"),u("iter15_final_open.png"),u("iter06_vialdetail.png"),u("iter08_pendetail.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";GRN="#34d399";YEL="#fbbf24";BLU="#7c9cf0"
W,H=1340,1080
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="#17171f" stroke="{c}" stroke-opacity="0.5"/>')
t(W/2,40,"Mixed peptide drawer cabinet — engineered for the fridge",INK,27,"middle","700")
t(W/2,62,"front-pull drawers on a rib-in-groove slide · real vial/pen dims · ~14.8 × 14.6 × 5.3 in",SUB,14,"middle")
# top images
panel(20,78,650,430,GRN); s.append(f'<image href="{CL}" x="26" y="84" width="638" height="418"/>'); t(36,104,"CLOSED — in the fridge",GRN,15,"start","700")
panel(686,78,634,430,ACC); s.append(f'<image href="{OP}" x="692" y="84" width="622" height="418"/>'); t(700,104,"OPEN — drawers pull out the front",ACC,15,"start","700")
# detail images
panel(20,520,430,300,BLU); s.append(f'<image href="{VD}" x="26" y="540" width="418" height="270"/>'); t(36,538,"Vial drawer · Ø23.6 chamfered pockets",BLU,13,"start","700")
panel(460,520,430,300,YEL); s.append(f'<image href="{PD}" x="466" y="540" width="418" height="270"/>'); t(476,538,"Pen drawer · cradles + end-stops + lift dip",YEL,13,"start","700")
# changelog
cx=905; panel(cx,520,W-cx-20,300,INK)
t(cx+16,542,"15 improvements applied",INK,15,"start","700")
items=["1 Open ring rack (saves plastic)","2 Real pen Ø19→Ø20.6 cradles (150 mm)",
 "3 Chamfered vial drop-in lead-ins","4 Pen end-stops (won't roll out)",
 "5 Center finger-dip to lift pens","6 Rib-in-groove slide (~0.6 mm play)",
 "7 Anti-pull-out drawer stop","8 Top-to-shelf clearance (no bind)",
 "9 2 columns → no racking","10 Finger pull + relief notch",
 "11 Recessed label patch","12 Drain holes (no fridge pooling)",
 "13 Rear vent / airflow","14 Supply cells (wipes/caps)",
 "15 Modular split (fits any bed)"]
for i,it in enumerate(items): t(cx+16,566+i*17,it,SUB,11.5)
# specs strip
t(20,860,"Capacity (2×3 = 6 drawers):  144 vials (2×72)  ·  28 pens broadside (2×14)  ·  12 supply cells",INK,15,"start","600")
t(20,886,"Slide: drawer side ribs ride in frame grooves; back-bump + front lip stop the drawer before it falls out.",SUB,13)
t(20,908,"Print: two side-by-side column modules; each column's drawers split front/back (~185 mm) to fit a normal bed. Add columns to widen.",SUB,13)
t(20,930,"Plastic-saving: vial holders are open ring racks (thin ring + base cup) instead of a solid block. Fridge drains + rear vent.",SUB,13)
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="mixed-summary.png",output_width=W*2,output_height=H*2)
print("ok")
