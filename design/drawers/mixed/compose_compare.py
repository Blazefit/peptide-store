import base64, cairosvg
def u(p): return "data:image/png;base64,"+base64.b64encode(open(p,"rb").read()).decode()
R,X,S=u("ref_frame.png"),u("myvial_xray.png"),u("myvial_section.png")
BG="#0f0f13";INK="#e2e2f0";SUB="#9393b0";GRN="#34d399";BLU="#7c9cf0";YEL="#fbbf24"
W,H=1320,900
s=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI, system-ui, sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>']
def e(v):return str(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def t(x,y,s2,f=INK,sz=15,a="start",w="400"):s.append(f'<text x="{x}" y="{y}" fill="{f}" font-size="{sz}" font-weight="{w}" text-anchor="{a}">{e(s2)}</text>')
def panel(x,y,w,h,c):s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="#17171f" stroke="{c}" stroke-opacity="0.5"/>')
t(W/2,42,"Vial holder — now matches your two-plate frame",INK,27,"middle","700")
t(W/2,64,"X-ray + cross-section vs. the rack you uploaded",SUB,14,"middle")
panel(20,86,640,430,GRN); s.append(f'<image href="{R}" x="26" y="100" width="628" height="408"/>'); t(36,108,"Your reference STL (two-plate frame)",GRN,15,"start","700")
panel(680,86,620,430,BLU); s.append(f'<image href="{X}" x="686" y="100" width="608" height="408"/>'); t(696,108,"New design — X-ray (top plate + base cups)",BLU,15,"start","700")
panel(20,528,1280,250,YEL); s.append(f'<image href="{S}" x="190" y="556" width="940" height="200"/>'); t(36,550,"Cross-section of the new vial drawer",YEL,15,"start","700")
t(36,742,"Top plate grips the upper vial · base cups seat the bottom · OPEN in between — least plastic, two-point anti-tip hold.",SUB,13)
t(20,820,"Before I'd built individual full-height rings around each vial (more plastic). This now matches your reference:",INK,14,"start","600")
t(20,846,"two thin perforated plates with an open frame between them. Same 72 vials/drawer; grips at base + ~30 mm up so they can't tip.",SUB,13)
t(20,872,"Note: the suspended top plate wants light support to print (peels out through the holes), or I can make it a drop-in insert for support-free printing.",SUB,12.5)
s.append('</svg>')
cairosvg.svg2png(bytestring="\n".join(s).encode(),write_to="vial-compare.png",output_width=W*2,output_height=H*2)
print("ok")
