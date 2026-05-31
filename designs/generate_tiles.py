#!/usr/bin/env python3
"""
HUMAN+  —  Periodic Table of Enhancement
Vector tile generator for the t-shirt line.

Edit the ELEMENTS table below, then run:
    python3 generate_tiles.py
Outputs print-ready SVGs to ./svg and PNG previews to ./preview.

DESIGN NOTES
------------
- Every tile is 1200 x 1400 px = a 12in x 14in print area at 100 DPI.
- Artwork is WHITE + ONE ACCENT on a TRANSPARENT background (built for a dark
  garment). Previews are rendered on near-black so you can see them.
- Two families:
    PEPTIDE  -> numbered by AMINO-ACID COUNT  (accent = mint/electric green)
    HORMONE  -> numbered by MOLECULAR WEIGHT  (accent = amber/gold)
- Fonts here are DejaVu/Liberation (Helvetica-like + a mono) so previews render
  on this box. For final print, swap to a licensed grotesque (Neue Haas / Helvetica
  Now / Space Grotesk) and a mono (JetBrains Mono) and OUTLINE the text.
"""

import os, subprocess

# ----------------------------------------------------------------------------
# THE ELEMENT TABLE  (symbol, name, secondary, family, number, unit, tagline, formula)
# family: "PEP" = peptide (amino acids)  |  "HOR" = hormone/steroid (molecular weight)
# ----------------------------------------------------------------------------
ELEMENTS = [
    # --- PEPTIDE FAMILY : numbered by amino-acid count ---
    ("Gh", "Somatropin",     "Human Growth Hormone",   "PEP", 191, "AA", "GROW OR DIE",            "191 aa"),
    ("Bp", "BPC-157",        "Body Protection Cmpd",   "PEP", 15,  "AA", "THE BODY'S REPAIR CODE", "15 aa"),
    ("Tb", "TB-500",         "Thymosin Beta-4",        "PEP", 43,  "AA", "HEAL WITHOUT PERMISSION","43 aa"),
    ("Sg", "Semaglutide",    "GLP-1 Agonist",          "PEP", 31,  "AA", "APPETITE, OVERRULED",    "31 aa"),
    ("Tz", "Tirzepatide",    "GIP / GLP-1",            "PEP", 39,  "AA", "DUAL-ACTION OVERRIDE",   "39 aa"),
    ("Ip", "Ipamorelin",     "GH Secretagogue",        "PEP", 5,   "AA", "CLEAN PULSE",            "5 aa"),
    ("Cj", "CJC-1295",       "GHRH Analog",            "PEP", 30,  "AA", "SUSTAINED SIGNAL",       "30 aa"),
    ("Sr", "Sermorelin",     "GRF (1-29)",             "PEP", 29,  "AA", "WAKE THE PITUITARY",     "29 aa"),
    ("Tm", "Tesamorelin",    "GHRH Analog",            "PEP", 44,  "AA", "CUT THE VISCERAL",       "44 aa"),
    ("Gk", "GHK-Cu",         "Copper Tripeptide",      "PEP", 3,   "AA", "COPPER-BOUND RENEWAL",   "3 aa"),
    ("Mt", "Melanotan II",   "Melanocortin Agonist",   "PEP", 7,   "AA", "SUN IN A VIAL",          "7 aa"),
    ("Pt", "PT-141",         "Bremelanotide",          "PEP", 7,   "AA", "DESIRE, DECODED",        "7 aa"),
    ("Ox", "Oxytocin",       "Nonapeptide",            "PEP", 9,   "AA", "THE BOND MOLECULE",      "9 aa"),
    ("Sk", "Selank",         "Anxiolytic Peptide",     "PEP", 7,   "AA", "CALM, WEAPONIZED",       "7 aa"),
    ("Sx", "Semax",          "Nootropic Peptide",      "PEP", 7,   "AA", "FOCUS PROTOCOL",         "7 aa"),
    ("Ep", "Epitalon",       "Telomerase Activator",   "PEP", 4,   "AA", "RESET THE CLOCK",        "4 aa"),
    ("Ta", "Thymosin a-1",   "Immune Modulator",       "PEP", 28,  "AA", "IMMUNE FIRMWARE",        "28 aa"),
    ("Ig", "IGF-1 LR3",      "Long R3 IGF-1",          "PEP", 83,  "AA", "GROWTH, AMPLIFIED",      "83 aa"),
    ("Mc", "MOTS-c",         "Mitochondrial Peptide",  "PEP", 16,  "AA", "MITOCHONDRIAL COMMAND",  "16 aa"),
    ("Gn", "Gonadorelin",    "GnRH Decapeptide",       "PEP", 10,  "AA", "RESTART THE AXIS",       "10 aa"),
    ("Ks", "Kisspeptin-10",  "KISS1 Fragment",         "PEP", 10,  "AA", "IGNITE THE CASCADE",     "10 aa"),
    ("Hx", "Hexarelin",      "GH Secretagogue",        "PEP", 6,   "AA", "MAX PULSE",              "6 aa"),
    ("G6", "GHRP-6",         "GH-Releasing Peptide",   "PEP", 6,   "AA", "HUNGER + GROWTH",        "6 aa"),
    ("Ad", "AOD-9604",       "hGH Fragment 176-191",   "PEP", 16,  "AA", "FAT-LOSS FRAGMENT",      "16 aa"),
    ("Ds", "DSIP",           "Delta Sleep Peptide",    "PEP", 9,   "AA", "DELTA SLEEP",            "9 aa"),
    ("In", "Insulin",        "A21 / B30 Chains",       "PEP", 51,  "AA", "THE MASTER SWITCH",      "51 aa"),
    # --- HORMONE / STEROID FAMILY : numbered by molecular weight (g/mol) ---
    ("Te", "Testosterone",   "Androgen",               "HOR", 288, "g/mol", "THE ORIGINAL UPGRADE","C19H28O2"),
    ("Nd", "Nandrolone",     "19-Nortestosterone",     "HOR", 274, "g/mol", "JOINTS OF STEEL",     "C18H26O2"),
    ("Tr", "Trenbolone",     "Androgen",               "HOR", 270, "g/mol", "NO COMPROMISE",       "C18H22O2"),
    ("Es", "Estradiol",      "Estrogen",               "HOR", 272, "g/mol", "BALANCE THE EQUATION","C18H24O2"),
    ("Dh", "DHEA",           "Adrenal Precursor",      "HOR", 288, "g/mol", "THE PRECURSOR",       "C19H28O2"),
    ("T3", "Liothyronine",   "Thyroid T3",             "HOR", 651, "g/mol", "THROTTLE THE FURNACE","C15H12I3NO4"),
    ("Ml", "Melatonin",      "Pineal Hormone",         "HOR", 232, "g/mol", "LIGHTS OUT",          "C13H16N2O2"),
]

# ----------------------------------------------------------------------------
PALETTE = {
    "PEP": "#2BE8B0",   # electric mint  (peptides)
    "HOR": "#FFB020",   # amber/gold     (hormones/steroids)
}
WHITE = "#FFFFFF"
DIM   = "#FFFFFF"       # used with opacity for secondary text
BG_PREVIEW = "#0d0d12"  # near-black garment for previews

SANS = "DejaVu Sans, Liberation Sans, Arial, sans-serif"
MONO = "DejaVu Sans Mono, Liberation Mono, monospace"


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def hero_tile(sym, name, sub, fam, num, unit, tagline, formula):
    """One large element tile, centered, 1200x1400, transparent bg."""
    acc = PALETTE[fam]
    fam_label = "PEPTIDE" if fam == "PEP" else "HORMONE"
    # tile box
    tx, ty, tw, th = 200, 360, 800, 800
    cx = tx + tw / 2
    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <!-- HUMAN+ tile : {esc(name)} -->
  <!-- ===== brand wordmark ===== -->
  <text x="600" y="190" font-family="{SANS}" font-size="92" font-weight="800"
        text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="26" text-anchor="middle"
        letter-spacing="8" fill="{WHITE}" fill-opacity="0.45">THE PERIODIC TABLE OF ENHANCEMENT</text>

  <!-- ===== element tile ===== -->
  <rect x="{tx}" y="{ty}" width="{tw}" height="{th}" rx="20" fill="none" stroke="{acc}" stroke-width="10"/>
  <line x1="{tx}" y1="{ty+150}" x2="{tx+tw}" y2="{ty+150}" stroke="{acc}" stroke-width="3" stroke-opacity="0.4"/>

  <!-- number + unit (top-left) -->
  <text x="{tx+45}" y="{ty+108}" font-family="{MONO}" font-size="84" font-weight="700" fill="{acc}">{num}</text>
  <text x="{tx+48}" y="{ty+145}" font-family="{MONO}" font-size="30" letter-spacing="3" fill="{WHITE}" fill-opacity="0.6">{unit}</text>

  <!-- family + formula (top-right) -->
  <text x="{tx+tw-45}" y="{ty+68}" font-family="{MONO}" font-size="30" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">{fam_label}</text>
  <text x="{tx+tw-45}" y="{ty+118}" font-family="{MONO}" font-size="34" letter-spacing="2"
        text-anchor="end" fill="{acc}">{esc(formula)}</text>

  <!-- giant symbol -->
  <text x="{cx}" y="{ty+520}" font-family="{SANS}" font-size="360" font-weight="800"
        text-anchor="middle" fill="{WHITE}">{esc(sym_display(sym))}</text>

  <!-- full name -->
  <text x="{cx}" y="{ty+650}" font-family="{SANS}" font-size="76" font-weight="800"
        text-anchor="middle" fill="{acc}">{esc(name)}</text>
  <text x="{cx}" y="{ty+700}" font-family="{SANS}" font-size="34" letter-spacing="2"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.7">{esc(sub.upper())}</text>

  <!-- tagline (bottom of tile) -->
  <text x="{cx}" y="{ty+765}" font-family="{MONO}" font-size="34" font-weight="700" letter-spacing="6"
        text-anchor="middle" fill="{WHITE}">{esc(tagline)}</text>

  <!-- footer line -->
  <text x="600" y="1300" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''
    return svg


def sym_display(sym):
    return sym


def modified_human():
    """The 'Factory Default -> Human+' two-tile concept."""
    acc = "#2BE8B0"
    grey = "#6b6b78"
    def tile(x, sym, label, subtitle, color, glow):
        g = f'filter="url(#glow)"' if glow else ''
        fs = 150 if len(sym) <= 2 else 120  # shrink so 'Hs+' fits inside the tile
        return f'''
  <rect x="{x}" y="500" width="380" height="420" rx="18" fill="none" stroke="{color}" stroke-width="9" {g}/>
  <text x="{x+30}" y="575" font-family="{MONO}" font-size="40" fill="{color}">{'00' if not glow else '01'}</text>
  <text x="{x+190}" y="745" font-family="{SANS}" font-size="{fs}" font-weight="800" text-anchor="middle" fill="{color}">{sym}</text>
  <text x="{x+190}" y="850" font-family="{SANS}" font-size="38" font-weight="700" text-anchor="middle" fill="{color}">{label}</text>
  <text x="{x+190}" y="895" font-family="{MONO}" font-size="22" letter-spacing="2" text-anchor="middle" fill="{color}" fill-opacity="0.7">{subtitle}</text>'''
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <defs>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="9" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <text x="600" y="300" font-family="{SANS}" font-size="100" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="370" font-family="{MONO}" font-size="30" text-anchor="middle" letter-spacing="6" fill="{WHITE}" fill-opacity="0.5">FACTORY DEFAULT IS NOT FINAL</text>
  {tile(150, "Hs", "Homo sapiens", "FACTORY DEFAULT", grey, False)}
  <text x="600" y="730" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" fill="{acc}">&#8594;</text>
  {tile(670, "Hs+", "Homo sapiens +", "MODIFIED EDITION", acc, True)}
  <text x="600" y="1080" font-family="{MONO}" font-size="34" letter-spacing="8" text-anchor="middle" fill="{WHITE}">UPGRADE THE OPERATOR</text>
</svg>'''


def periodic_poster():
    """Full table laid out as a grid poster, two families color-coded."""
    cols = 6
    cell_w, cell_h = 170, 190
    pad = 14
    margin_x, margin_y = 90, 360
    cells = []
    for i, (sym, name, sub, fam, num, unit, tag, formula) in enumerate(ELEMENTS):
        r, c = divmod(i, cols)
        x = margin_x + c * (cell_w + pad)
        y = margin_y + r * (cell_h + pad)
        acc = PALETTE[fam]
        cells.append(f'''
  <g>
    <rect x="{x}" y="{y}" width="{cell_w}" height="{cell_h}" rx="10" fill="none" stroke="{acc}" stroke-width="4"/>
    <text x="{x+14}" y="{y+40}" font-family="{MONO}" font-size="26" fill="{acc}">{num}</text>
    <text x="{x+cell_w-12}" y="{y+34}" font-family="{MONO}" font-size="16" text-anchor="end" fill="{WHITE}" fill-opacity="0.5">{unit}</text>
    <text x="{x+cell_w/2}" y="{y+118}" font-family="{SANS}" font-size="78" font-weight="800" text-anchor="middle" fill="{WHITE}">{esc(sym_display(sym))}</text>
    <text x="{x+cell_w/2}" y="{y+160}" font-family="{SANS}" font-size="19" font-weight="700" text-anchor="middle" fill="{acc}">{esc(name)}</text>
  </g>''')
    rows = (len(ELEMENTS) + cols - 1) // cols
    height = margin_y + rows * (cell_h + pad) + 200
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 {height}" width="1200" height="{height}">
  <text x="600" y="170" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{PALETTE['PEP']}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="30" text-anchor="middle" letter-spacing="10" fill="{WHITE}" fill-opacity="0.6">THE PERIODIC TABLE OF ENHANCEMENT</text>
  <!-- legend -->
  <rect x="360" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['PEP']}" stroke-width="4"/>
  <text x="398" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">PEPTIDE (amino acids)</text>
  <rect x="720" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['HOR']}" stroke-width="4"/>
  <text x="758" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">HORMONE (g/mol)</text>
  {''.join(cells)}
  <text x="600" y="{height-60}" font-family="{MONO}" font-size="26" letter-spacing="6" text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''


def render_png(svg_path, png_path, bg=BG_PREVIEW):
    subprocess.run(["rsvg-convert", "-b", bg, "-w", "900", "-o", png_path, svg_path], check=True)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    svg_dir = os.path.join(here, "svg")
    prev_dir = os.path.join(here, "preview")
    os.makedirs(svg_dir, exist_ok=True)
    os.makedirs(prev_dir, exist_ok=True)

    # flagship hero tiles to render as individual files
    flagships = {"Te", "Gh", "Bp", "Sg", "Tb", "Pt"}
    made = []
    for el in ELEMENTS:
        sym = el[0]
        if sym not in flagships:
            continue
        svg = hero_tile(*el)
        base = f"tile_{sym_display(sym)}_{el[1].replace(' ', '')}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        pp = os.path.join(prev_dir, base + ".png")
        render_png(sp, pp)
        made.append(base)

    # concept tile
    for name, fn in [("concept_HumanPlus", modified_human), ("poster_PeriodicTable", periodic_poster)]:
        sp = os.path.join(svg_dir, name + ".svg")
        with open(sp, "w") as f:
            f.write(fn())
        render_png(sp, os.path.join(prev_dir, name + ".png"))
        made.append(name)

    print("Generated:", ", ".join(made))


if __name__ == "__main__":
    main()
