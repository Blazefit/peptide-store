#!/usr/bin/env python3
"""Contact sheet of all 15 iterations + a favorites highlight."""
import base64, cairosvg, os
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";ACC="#7c5cfc";ACC2="#a78bfa";GRN="#34d399";YEL="#fbbf24"
def esc(v): return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")

# ---------- contact sheet of all 15 ----------
items=[("01","finger scoop"),("02","thumbwheel"),("03","chamber numbers"),("04","dispense pointer"),
       ("05","bearing keepers"),("06","captive shutter"),("07","hub bore / metal axle"),("08","label panel"),
       ("09","base rim"),("10","chamfers"),("11","dust lid"),("12","wall-mount"),
       ("13","compact 4-ch"),("14","high-capacity 8-ch"),("15","grip polish · FINAL")]
files={f[8:10] if False else None:None}
def fpath(n):
    import glob
    g=glob.glob(f"iterations/iter{n}_*.png")
    return g[0] if g else None
W,H=1300,940; cols=5; rows=3; cw=248; ch=176; mx=18; my=70
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',
   f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def t(x,y,txt,fill=INK,sz=15,a="start",w="400"):
    s.append(f'<text x="{x}" y="{y}" fill="{fill}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{esc(txt)}</text>')
t(W/2,40,"Drop-Selector — 15 refinement iterations",INK,27,"middle","700")
t(W/2,60,"each saved under design/iterations/ · build on the previous one",SUB,14,"middle")
for i,(n,lab) in enumerate(items):
    c=i%cols; r=i//cols
    x=mx+c*(cw+ (W-2*mx-cols*cw)/(cols-1)); y=my+18+r*(ch+48)
    fp=fpath(n)
    final = (n=="15")
    col = YEL if final else ACC
    s.append(f'<rect x="{x}" y="{y}" width="{cw}" height="{ch}" rx="8" fill="#17171f" stroke="{col}" stroke-opacity="{0.9 if final else 0.4}"/>')
    if fp: s.append(f'<image href="{u(fp)}" x="{x+4}" y="{y+4}" width="{cw-8}" height="{ch-8}" preserveAspectRatio="xMidYMid meet"/>')
    s.append(f'<circle cx="{x+15}" cy="{y+15}" r="12" fill="{col}" fill-opacity="0.25" stroke="{col}"/>')
    t(x+15,y+19,n,col,12,"middle","700")
    t(x+2,y+ch+18,lab,INK if final else SUB,13,"start","600" if final else "400")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="iterations-contact.png",output_width=W*2,output_height=H*2)
print("wrote iterations-contact.png")

# ---------- favorites highlight (final + 3) ----------
fav=[("favorites/final_6chamber.png","FINAL — 6-chamber","the canonical build · all refinements on",YEL),
     ("favorites/fav_compact4.png","Favorite · compact 4-chamber","smaller footprint, same mechanism",ACC2),
     ("favorites/fav_capacity8.png","Favorite · high-capacity 8-chamber","holds more, scales parametrically",GRN),
     ("favorites/fav_dustlid.png","Favorite · with dust lid","optional clip-over cover (extra part)",ACC)]
W2,H2=1300,980
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W2}" height="{H2}" viewBox="0 0 {W2} {H2}" font-family="Segoe UI, system-ui, sans-serif">',
   f'<rect width="{W2}" height="{H2}" fill="{BG}"/>']
t(W2/2,42,"Final variation + three favorites",INK,28,"middle","700")
t(W2/2,64,"all the same 3 printed parts · drop-in drum · slide-to-dispense",SUB,14,"middle")
pw=620; phh=400
for i,(fp,lab,sub,c) in enumerate(fav):
    cx=24+(i%2)*(pw+12); cy=86+(i//2)*(phh+18)
    s.append(f'<rect x="{cx}" y="{cy}" width="{pw}" height="{phh}" rx="10" fill="#17171f" stroke="{c}" stroke-opacity="0.5"/>')
    s.append(f'<image href="{u(fp)}" x="{cx+6}" y="{cy+30}" width="{pw-12}" height="{phh-40}" preserveAspectRatio="xMidYMid meet"/>')
    t(cx+16,cy+24,lab,c,16,"start","700")
    t(cx+pw-12,cy+24,sub,SUB,12,"end")
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="favorites.png",output_width=W2*2,output_height=H2*2)
print("wrote favorites.png")
