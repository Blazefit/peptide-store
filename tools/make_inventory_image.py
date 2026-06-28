#!/usr/bin/env python3
"""Render a quick peptide inventory list as a PNG image."""
from PIL import Image, ImageDraw, ImageFont

# (name, strength) — B12 removed (out of stock). BAC Water kept at bottom as a supply.
ITEMS = [
    ("Adamax", "5mg"),
    ("AHK-Cu", "100mg"),
    ("BPC-157 + TB-500", "20mg"),
    ("Cerebrolysin", "60mg"),
    ("CJC-1295 (no DAC)", "5mg"),
    ("Dermorphin", "5mg"),
    ("DSIP", "5mg"),
    ("Epithalon", "10mg"),
    ("GHK-Cu", "50mg"),
    ("Glutathione", "1500mg"),
    ("Ipamorelin", "10mg"),
    ("KLOW", "80mg"),
    ("KPV", "10mg"),
    ("LL-37", "5mg"),
    ("MOTS-c", "10mg"),
    ("MOTS-c", "40mg"),
    ("MT-2", "10mg"),
    ("NAD+", "500mg"),
    ("NAD+", "1000mg"),
    ("Pinealon", "10mg"),
    ("Pinealon", "20mg"),
    ("PT-141", "10mg"),
    ("Retatrutide", "5mg"),
    ("Retatrutide", "10mg"),
    ("Retatrutide", "20mg"),
    ("Retatrutide", "30mg"),
    ("Retatrutide", "60mg"),
    ("Selank", "11mg"),
    ("Semax", "5mg"),
    ("SLU-PP-322", "5mg"),
    ("Somatropin (HGH)", "24IU"),
    ("Somatropin (HGH)", "36IU"),
    ("SS-31", "10mg"),
    ("SS-31", "50mg"),
    ("TB-500", "5mg"),
    ("Tesamorelin", "10mg"),
    ("Tesamorelin", "20mg"),
    ("Thymosin Alpha-1", "10mg"),
    ("Vilon", "20mg"),
]

# Layout — two columns to keep it compact and screenshot-friendly
BG = (255, 255, 255)
HEADER_BG = (17, 24, 39)
ROW_ALT = (243, 244, 246)
TEXT = (17, 24, 39)
ACCENT = (37, 99, 235)
LINE = (209, 213, 219)

PAD = 40
TITLE_H = 70
SUB_H = 34
HEADER_H = 44
ROW_H = 40
COL_W = 470
COL_GAP = 30


def load_font(size, bold=False):
    paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold
        else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for p in paths:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()


f_title = load_font(38, bold=True)
f_sub = load_font(18)
f_head = load_font(20, bold=True)
f_row = load_font(21)

n = len(ITEMS)
per_col = (n + 1) // 2
left = ITEMS[:per_col]
right = ITEMS[per_col:]

width = PAD * 2 + COL_W * 2 + COL_GAP
height = PAD + TITLE_H + SUB_H + HEADER_H + per_col * ROW_H + PAD

img = Image.new("RGB", (width, height), BG)
d = ImageDraw.Draw(img)

# Title
d.text((PAD, PAD), "Peptide Inventory", font=f_title, fill=TEXT)
d.text((PAD, PAD + 48), "In stock as of June 28, 2026", font=f_sub, fill=(107, 114, 128))

y0 = PAD + TITLE_H + SUB_H


def draw_column(x, rows):
    # header bar
    d.rectangle([x, y0, x + COL_W, y0 + HEADER_H], fill=HEADER_BG)
    d.text((x + 16, y0 + 11), "Peptide", font=f_head, fill=(255, 255, 255))
    d.text((x + COL_W - 120, y0 + 11), "Strength", font=f_head, fill=(255, 255, 255))
    ry = y0 + HEADER_H
    for i, (name, strength) in enumerate(rows):
        if i % 2 == 1:
            d.rectangle([x, ry, x + COL_W, ry + ROW_H], fill=ROW_ALT)
        d.text((x + 16, ry + 9), name, font=f_row, fill=TEXT)
        d.text((x + COL_W - 120, ry + 9), strength, font=f_row, fill=ACCENT)
        ry += ROW_H
    d.rectangle([x, y0, x + COL_W, ry], outline=LINE, width=1)


draw_column(PAD, left)
draw_column(PAD + COL_W + COL_GAP, right)

out = "/home/user/peptide-store/peptide-inventory.png"
img.save(out, "PNG")
print("saved", out, img.size)
