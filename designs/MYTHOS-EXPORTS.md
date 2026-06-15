# MYTHOS Export CLI

`generate_mythic.py` can now export one MYTHOS design at a time without regenerating any AI art in `mythic_art/`.

## Export Command

```sh
cd ~/peptide-store/designs
python3 generate_mythic.py export \
  --sym Bp \
  --style mythic \
  --element card \
  --format eps \
  --title "THE MENDER" \
  --sub "BPC-157" \
  --aura "EMERALD" \
  --essence "ESSENCE 15 aa" \
  --caption "BPC-157" \
  --lore "Stitches living flesh back from ruin."
```

The command prints the written file path.

## Options

- `--sym`: compound symbol or stack key, such as `Bp`, `Gk`, `WOLVERINE`, or `THE_OVERHAUL`.
- `--style`: `mythic` or `arcane`.
- `--element`: `deity`, `card`, or `both`.
- `--format`: `svg`, `png`, or `eps`.
- `--width`: PNG output width in pixels. Default is `2000`.

Text overrides:

- `--title`: deity title.
- `--sub`: subtitle / real compound name.
- `--aura`: aura label only, such as `EMERALD`; the renderer adds `AURA`.
- `--essence`: full essence/mass/tier string, such as `ESSENCE 15 aa`.
- `--caption-label`: caption label under the image, such as `COMPOUND` or `COMPOUNDS`.
- `--caption`: compound caption under the image.
- `--lore`: lore sentence.
- `--footer`: footer text. Default is `HUMAN+ APPAREL`.

## Output Layout

Exports are written under:

```text
designs/mythic_exports/{element}/{key}_{style}.{svg|png|eps}
```

Examples:

```text
designs/mythic_exports/card/Bp_mythic.eps
designs/mythic_exports/deity/Bp_mythic.png
designs/mythic_exports/both/WOLVERINE_arcane.svg
```

`card` and `both` are the full framed card. `deity` is the existing raw deity art wrapped as needed for SVG/EPS/PNG export.

## Batch Regeneration

The existing batch mode still regenerates card SVG/PNG files:

```sh
cd ~/peptide-store/designs
python3 generate_mythic.py --no-html
```

`mythic.html` is hand-maintained separately and is not rebuilt by this script.

## EPS Backend

EPS export uses the tools already installed on the Mac:

```text
rsvg-convert -> PDF, then pdftops -eps -> EPS
```

If those are not available, the script falls back to Inkscape or Python `cairosvg` when installed.

## Web UI Integration

The stable file layout for a future download menu is:

```js
const mythosExportPath = ({ element, key, style, format }) =>
  `mythic_exports/${element}/${key}_${style}.${format}`;
```

The live page should keep using its hand-maintained `mythic.html`; wire UI controls to call or pre-generate files into the export layout above.
