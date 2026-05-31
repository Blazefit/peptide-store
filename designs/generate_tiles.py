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
    PEPTIDE  -> recognizable abbreviation (BPC, TB, PT...) as the big symbol,
                the number already in the name (157, 500, 141) TOP-LEFT,
                the real AMINO-ACID count TOP-RIGHT.  Accent = mint green.
    HORMONE  -> steroids/small molecules; numbered by MOLECULAR WEIGHT.
                Accent = amber/gold.
- Fonts here are DejaVu/Liberation (Helvetica-like + a mono) so previews render
  on this box. For final print, swap to a licensed grotesque (Neue Haas / Helvetica
  Now / Space Grotesk) and a mono (JetBrains Mono) and OUTLINE the text.
"""

import os, subprocess

# ----------------------------------------------------------------------------
# THE ELEMENT TABLE
# (sym, full_name, sub, family, name_num, count, tagline, formula)
#   sym       = big recognizable abbreviation shown in the tile center
#   full_name = spelled-out compound name shown below the symbol
#   family    = "PEP" peptide (count = amino acids) | "HOR" hormone (count = g/mol)
#   name_num  = the number that's already in the name ("157","500","141"); "" if none
#   count     = amino-acid count (PEP) or molecular weight in g/mol (HOR)
#   formula   = chemical formula (HOR) or "" (PEP)
# ----------------------------------------------------------------------------
ELEMENTS = [
    # --- PEPTIDE FAMILY ---
    ("HGH",  "Somatropin",     "Human Growth Hormone",  "PEP", "",     191, "GROW OR DIE",            ""),
    ("BPC",  "BPC-157",        "Body Protection Cmpd",  "PEP", "157",  15,  "THE BODY'S REPAIR CODE", ""),
    ("TB",   "TB-500",         "Thymosin Beta-4",       "PEP", "500",  43,  "HEAL WITHOUT PERMISSION",""),
    ("SEMA", "Semaglutide",    "GLP-1 Agonist",         "PEP", "",     31,  "APPETITE, OVERRULED",    ""),
    ("TIRZ", "Tirzepatide",    "GIP / GLP-1",           "PEP", "",     39,  "DUAL-ACTION OVERRIDE",   ""),
    ("IPA",  "Ipamorelin",     "GH Secretagogue",       "PEP", "",     5,   "CLEAN PULSE",            ""),
    ("CJC",  "CJC-1295",       "GHRH Analog",           "PEP", "1295", 30,  "SUSTAINED SIGNAL",       ""),
    ("SERM", "Sermorelin",     "GRF (1-29)",            "PEP", "",     29,  "WAKE THE PITUITARY",     ""),
    ("TESA", "Tesamorelin",    "GHRH Analog",           "PEP", "",     44,  "CUT THE VISCERAL",       ""),
    ("GHK",  "GHK-Cu",         "Copper Tripeptide",     "PEP", "",     3,   "COPPER-BOUND RENEWAL",   ""),
    ("MT",   "Melanotan II",   "Melanocortin Agonist",  "PEP", "II",   7,   "SUN IN A VIAL",          ""),
    ("PT",   "PT-141",         "Bremelanotide",         "PEP", "141",  7,   "DESIRE, DECODED",        ""),
    ("OXT",  "Oxytocin",       "Nonapeptide",           "PEP", "",     9,   "THE BOND MOLECULE",      ""),
    ("SEL",  "Selank",         "Anxiolytic Peptide",    "PEP", "",     7,   "CALM, WEAPONIZED",       ""),
    ("SMX",  "Semax",          "Nootropic Peptide",     "PEP", "",     7,   "FOCUS PROTOCOL",         ""),
    ("EPI",  "Epitalon",       "Telomerase Activator",  "PEP", "",     4,   "RESET THE CLOCK",        ""),
    ("TA",   "Thymosin a-1",   "Immune Modulator",      "PEP", "1",    28,  "IMMUNE FIRMWARE",        ""),
    ("IGF",  "IGF-1 LR3",      "Long R3 IGF-1",         "PEP", "1",    83,  "GROWTH, AMPLIFIED",      ""),
    ("MOTS", "MOTS-c",         "Mitochondrial Peptide", "PEP", "c",    16,  "MITOCHONDRIAL COMMAND",  ""),
    ("GON",  "Gonadorelin",    "GnRH Decapeptide",      "PEP", "",     10,  "RESTART THE AXIS",       ""),
    ("KISS", "Kisspeptin-10",  "KISS1 Fragment",        "PEP", "10",   10,  "IGNITE THE CASCADE",     ""),
    ("HEX",  "Hexarelin",      "GH Secretagogue",       "PEP", "",     6,   "MAX PULSE",              ""),
    ("GHRP", "GHRP-6",         "GH-Releasing Peptide",  "PEP", "6",    6,   "HUNGER + GROWTH",        ""),
    ("AOD",  "AOD-9604",       "hGH Fragment 176-191",  "PEP", "9604", 16,  "FAT-LOSS FRAGMENT",      ""),
    ("SS",   "SS-31",          "Elamipretide",          "PEP", "31",   4,   "MITOCHONDRIAL ARMOR",    ""),
    ("DSIP", "DSIP",           "Delta Sleep Peptide",   "PEP", "",     9,   "DELTA SLEEP",            ""),
    ("INS",  "Insulin",        "A21 / B30 Chains",      "PEP", "",     51,  "THE MASTER SWITCH",      ""),
    # --- HORMONE / STEROID FAMILY : numbered by molecular weight (g/mol) ---
    ("Te", "Testosterone",   "Androgen",             "HOR", "", 288, "THE ORIGINAL UPGRADE", "C19H28O2"),
    ("Nd", "Nandrolone",     "19-Nortestosterone",   "HOR", "", 274, "JOINTS OF STEEL",      "C18H26O2"),
    ("Tr", "Trenbolone",     "Androgen",             "HOR", "", 270, "NO COMPROMISE",        "C18H22O2"),
    ("Es", "Estradiol",      "Estrogen",             "HOR", "", 272, "BALANCE THE EQUATION", "C18H24O2"),
    ("Dh", "DHEA",           "Adrenal Precursor",    "HOR", "", 288, "THE PRECURSOR",        "C19H28O2"),
    ("T3", "Liothyronine",   "Thyroid T3",           "HOR", "", 651, "THROTTLE THE FURNACE", "C15H12I3NO4"),
    ("Ml", "Melatonin",      "Pineal Hormone",       "HOR", "", 232, "LIGHTS OUT",           "C13H16N2O2"),
]

# ----------------------------------------------------------------------------
PALETTE = {
    "PEP": "#2BE8B0",   # electric mint  (peptides)
    "HOR": "#FFB020",   # amber/gold     (hormones/steroids)
}
WHITE = "#FFFFFF"
BG_PREVIEW = "#0d0d12"  # near-black garment for previews

SANS = "DejaVu Sans, Liberation Sans, Arial, sans-serif"
MONO = "DejaVu Sans Mono, Liberation Mono, monospace"


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def sym_font(sym, base):
    """Scale the big symbol down as the abbreviation gets longer."""
    n = len(sym)
    if n <= 2:  return base
    if n == 3:  return int(base * 0.78)
    return int(base * 0.58)   # 4 chars (GHRP, MOTS, SEMA...)


def hero_tile(sym, full, sub, fam, name_num, count, tagline, formula):
    """One large element tile, centered, 1200x1400, transparent bg."""
    acc = PALETTE[fam]
    tx, ty, tw, th = 200, 360, 800, 800
    cx = tx + tw / 2
    fs = sym_font(sym, 360)

    # ---- top corners differ by family ----
    if fam == "PEP":
        if name_num:
            tl_big, tl_label = name_num, "SERIES"
        else:
            tl_big, tl_label = str(count), "AMINO ACIDS"
        # top-right always shows the real amino-acid count
        tr = f'''<text x="{tx+tw-45}" y="{ty+62}" font-family="{MONO}" font-size="28" letter-spacing="3"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">AMINO ACIDS</text>
  <text x="{tx+tw-45}" y="{ty+128}" font-family="{MONO}" font-size="64" font-weight="700"
        text-anchor="end" fill="{acc}">{count}</text>'''
    else:  # HOR
        tl_big, tl_label = str(count), "g/mol"
        tr = f'''<text x="{tx+tw-45}" y="{ty+62}" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="end" fill="{WHITE}" fill-opacity="0.6">HORMONE</text>
  <text x="{tx+tw-45}" y="{ty+118}" font-family="{SANS}" font-size="34" letter-spacing="1"
        text-anchor="end" fill="{acc}">{esc(formula)}</text>'''

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400" width="1200" height="1400">
  <!-- HUMAN+ tile : {esc(full)} -->
  <text x="600" y="190" font-family="{SANS}" font-size="92" font-weight="800"
        text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{acc}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="26" text-anchor="middle"
        letter-spacing="8" fill="{WHITE}" fill-opacity="0.45">THE PERIODIC TABLE OF ENHANCEMENT</text>

  <rect x="{tx}" y="{ty}" width="{tw}" height="{th}" rx="20" fill="none" stroke="{acc}" stroke-width="10"/>
  <line x1="{tx}" y1="{ty+150}" x2="{tx+tw}" y2="{ty+150}" stroke="{acc}" stroke-width="3" stroke-opacity="0.4"/>

  <!-- top-left number -->
  <text x="{tx+45}" y="{ty+108}" font-family="{MONO}" font-size="84" font-weight="700" fill="{acc}">{tl_big}</text>
  <text x="{tx+48}" y="{ty+145}" font-family="{MONO}" font-size="28" letter-spacing="3" fill="{WHITE}" fill-opacity="0.6">{tl_label}</text>

  <!-- top-right -->
  {tr}

  <!-- giant symbol -->
  <text x="{cx}" y="{ty+515}" font-family="{SANS}" font-size="{fs}" font-weight="800"
        text-anchor="middle" fill="{WHITE}">{esc(sym)}</text>

  <!-- full name -->
  <text x="{cx}" y="{ty+650}" font-family="{SANS}" font-size="76" font-weight="800"
        text-anchor="middle" fill="{acc}">{esc(full)}</text>
  <text x="{cx}" y="{ty+700}" font-family="{SANS}" font-size="34" letter-spacing="2"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.7">{esc(sub.upper())}</text>

  <!-- tagline -->
  <text x="{cx}" y="{ty+765}" font-family="{MONO}" font-size="34" font-weight="700" letter-spacing="6"
        text-anchor="middle" fill="{WHITE}">{esc(tagline)}</text>

  <text x="600" y="1300" font-family="{MONO}" font-size="28" letter-spacing="4"
        text-anchor="middle" fill="{WHITE}" fill-opacity="0.4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
</svg>'''
    return svg


def modified_human():
    """The 'Factory Default -> Human+' two-tile concept."""
    acc = "#2BE8B0"
    grey = "#6b6b78"
    def tile(x, sym, label, subtitle, color, glow):
        g = 'filter="url(#glow)"' if glow else ''
        fs = 150 if len(sym) <= 2 else 120
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
    for i, (sym, full, sub, fam, name_num, count, tag, formula) in enumerate(ELEMENTS):
        r, c = divmod(i, cols)
        x = margin_x + c * (cell_w + pad)
        y = margin_y + r * (cell_h + pad)
        acc = PALETTE[fam]
        # top-left number, top-right count/unit
        if fam == "PEP":
            tl = name_num if name_num else str(count)
            tr = f"{count}aa"
        else:
            tl = str(count)
            tr = "g/mol"
        fs = sym_font(sym, 78)
        cells.append(f'''
  <g>
    <rect x="{x}" y="{y}" width="{cell_w}" height="{cell_h}" rx="10" fill="none" stroke="{acc}" stroke-width="4"/>
    <text x="{x+14}" y="{y+40}" font-family="{MONO}" font-size="26" fill="{acc}">{tl}</text>
    <text x="{x+cell_w-12}" y="{y+34}" font-family="{MONO}" font-size="16" text-anchor="end" fill="{WHITE}" fill-opacity="0.5">{tr}</text>
    <text x="{x+cell_w/2}" y="{y+120}" font-family="{SANS}" font-size="{fs}" font-weight="800" text-anchor="middle" fill="{WHITE}">{esc(sym)}</text>
    <text x="{x+cell_w/2}" y="{y+162}" font-family="{SANS}" font-size="18" font-weight="700" text-anchor="middle" fill="{acc}">{esc(full)}</text>
  </g>''')
    rows = (len(ELEMENTS) + cols - 1) // cols
    height = margin_y + rows * (cell_h + pad) + 200
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 {height}" width="1200" height="{height}">
  <text x="600" y="170" font-family="{SANS}" font-size="120" font-weight="800" text-anchor="middle" letter-spacing="6" fill="{WHITE}">HUMAN<tspan fill="{PALETTE['PEP']}">+</tspan></text>
  <text x="600" y="240" font-family="{MONO}" font-size="30" text-anchor="middle" letter-spacing="10" fill="{WHITE}" fill-opacity="0.6">THE PERIODIC TABLE OF ENHANCEMENT</text>
  <rect x="330" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['PEP']}" stroke-width="4"/>
  <text x="368" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">PEPTIDE (amino acids)</text>
  <rect x="730" y="285" width="26" height="26" rx="5" fill="none" stroke="{PALETTE['HOR']}" stroke-width="4"/>
  <text x="768" y="306" font-family="{MONO}" font-size="24" fill="{WHITE}" fill-opacity="0.8">HORMONE (g/mol)</text>
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

    flagships = {"Te", "HGH", "BPC", "TB", "PT", "SS"}
    made = []
    for el in ELEMENTS:
        sym = el[0]
        if sym not in flagships:
            continue
        svg = hero_tile(*el)
        base = f"tile_{sym}_{el[1].replace(' ', '')}"
        sp = os.path.join(svg_dir, base + ".svg")
        with open(sp, "w") as f:
            f.write(svg)
        render_png(sp, os.path.join(prev_dir, base + ".png"))
        made.append(base)

    for name, fn in [("concept_HumanPlus", modified_human), ("poster_PeriodicTable", periodic_poster)]:
        sp = os.path.join(svg_dir, name + ".svg")
        with open(sp, "w") as f:
            f.write(fn())
        render_png(sp, os.path.join(prev_dir, name + ".png"))
        made.append(name)

    print("Generated:", ", ".join(made))


if __name__ == "__main__":
    main()
