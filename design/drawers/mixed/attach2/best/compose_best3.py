import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
A = u("01_corner_clips.png")      # E02
B = u("02_c_clip_exploded.png")   # D05
C = u("03_hook_rail.png")         # E03
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";GRN="#34d399";YEL="#fbbf24";BLU="#7c9cf0";RED="#ef5350";PUR="#c264e0"
W,H=1340,940
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="11" fill="#17171f" stroke="{c}" stroke-opacity="0.6"/>')
t(W/2,40,"Secure stacking attachment — best 3 (retrofit: only the NEW bottom tray is modified)",INK,25,"middle","700")
t(W/2,63,"Top tray is UNCHANGED — already printed. All grab features live on the new middle/bottom tray. blue = new tray · grey = existing top tray",SUB,13.5,"middle")
cards=[
 (A,RED,"① Corner clips","RECOMMENDED — cleanest, lowest profile",
  ["4 L-clips wrap the top tray's 4 corners","each hooks a lip OVER the rim (locks DOWN)",
   "grabs two faces per corner → resists slide on every axis","press top tray straight down to snap; squeeze corners to release",
   "least plastic, fastest print, no reliance on windows"]),
 (B,PUR,"② Window C-clips","Most positive lock",
  ["6 C-clips reach OVER the wall into the 6 existing windows","a nub snaps INTO each window from the inside",
   "true mechanical detent — top tray cannot lift until un-snapped","uses features the top tray already has (no guessing the rim)",
   "strongest hold; squeeze outer legs out to release"]),
 (C,GRN,"③ Full-length hook rails","Maximum retention surface",
  ["continuous rail down BOTH long sides (305 mm)","top flange curls over the entire rim length",
   "slotted for flex + material savings","grabs the most edge → very rigid, no rattle",
   "flex both rails outward at mid-span to release"]),
]
cw=(W-4*22)/3; iy=86; ih=300
for i,(img,c,title,sub,bl) in enumerate(cards):
    x=22+i*(cw+22); panel(x,iy,cw,ih+300,c)
    s.append(f'<image href="{img}" x="{x+6}" y="{iy+6}" width="{cw-12}" height="{ih-6}" preserveAspectRatio="xMidYMid meet"/>')
    t(x+16,iy+ih+30,title,c,20,"start","700"); t(x+16,iy+ih+52,sub,INK,13.5)
    for j,b in enumerate(bl): t(x+16,iy+ih+82+j*34,"• "+b,SUB,12.5)
t(W/2,H-46,"All three add ZERO geometry to the top tray (verified in the .scad — the grey part is a fixed reference).",SUB,13,"middle")
t(W/2,H-24,"Pick one and I'll merge it onto the real layer STL, verify the snap clearance, and export a print-ready file.",ACC,13,"middle","600")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="attach-best3.png",output_width=W*2,output_height=H*2)
print("ok")
