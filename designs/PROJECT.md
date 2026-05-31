# HUMAN+ — Project Handoff & Operations Guide

Single source of truth for anyone (human or AI agent) picking up this project.
Read this first. It explains what the project is, how every file works, how to
regenerate the designs, and how the site is hosted on the Mac mini over Tailscale.

---

## 1. What this project is

**HUMAN+** is a streetwear/apparel brand concept: a *"Periodic Table of
Enhancement"* where peptides and hormones are styled like elements on the periodic
table. Each compound is an element "tile" (a 2-letter symbol, a number, the full
name, a tagline). Peptides and hormones form two color-coded families. Users can
also combine compounds into multi-compound **"stacks"** (e.g. WOLVERINE, KLOW).

Deliverables in this repo:
- **Print-ready vector tiles** (SVG) for every compound + curated stacks.
- **PNG previews** of every design.
- **An interactive website** (`index.html`) — a clickable periodic table that lets
  you build a custom stack and visualize it on a t-shirt / hoodie / long sleeve.
- **Hosting scripts** to serve the site privately over Tailscale from a Mac mini.

Repo: `Blazefit/peptide-store`
Working branch: `claude/periodic-table-tshirt-designs-Wd9su`
Everything for this project lives in the **`designs/`** folder.
(The repo root also has an unrelated `index.html` — a separate "Peptide Supply Co."
storefront app. Do not confuse it with `designs/index.html`.)

---

## 2. The three-family design system

The table splits into three color-coded families, each numbered differently:

| Family | Big symbol | Top-left number | Top-right | Accent color |
|---|---|---|---|---|
| **PEPTIDE** | 2-letter code (`Bp`, `Tb`, `Pt`) | the number already in the name (157, 500, 141); falls back to the amino-acid count if the name has no number | amino-acid count | mint `#2BE8B0` |
| **HORMONE** | 2-letter code (`Te`, `Tr`, `An`) | molecular weight (g/mol) | chemical formula | amber `#FFB020` |
| **MOLECULE** | 2-letter code (`Na`, `Mq`, `Mb`) | molecular weight (g/mol) | chemical formula | violet `#7C5CFC` |

The MOLECULE family covers metabolic cofactors / small-molecule nootropics that
are neither peptides nor hormones (NAD+, 5-Amino-1MQ, Methylene Blue). Family is
set by the `fam` field in `ELEMENTS`: `PEP` / `HOR` / `MOL`.

Base art = white + the family accent, on a dark garment.
Brand "+" separator color (used between stack components) = `#2BE8B0` (the green in the HUMAN+ logo).

### Stacks
24 curated stacks live in `STACKS` in `generate_tiles.py`, grouped into 5
categories (Recovery/Repair, Hormone Performance, Body Composition,
Cognitive/Nootropic, Mito/Longevity). Each is
`(name, subtitle, [component symbols], tagline, extras)`. `comps` must be element
symbols (rendered as mini element-tiles); `extras` is a free-text list of
supportive ingredients that have no element tile (supplements, blends like
"KLOW blend", "caffeine + L-theanine + tyrosine"), shown as a small green
"+ ..." line under the tiles.

Full element list, amino-acid/MW values (verified), taglines, and the
verify-before-print checklist live in **`BRAND-DESIGN-BRIEF.md`**.

---

## 3. File-by-file map (everything in `designs/`)

| File | What it is |
|---|---|
| **`generate_tiles.py`** | The generator. Holds the `ELEMENTS` table (39 compounds) and `STACKS` list (5 stacks) as the single source of truth. Renders every tile to `svg/` and `preview/`, and writes `index.html` (interactive) + `gallery.html` (static). Run it to rebuild everything. |
| **`site_template.py`** | The interactive website's HTML/CSS/JS as a Python string (`SITE_TEMPLATE`). The marker `/*__DATA__*/` is replaced with the element/stack data as JSON at build time. The tile-drawing JS here mirrors the Python SVG functions so web and print match exactly. |
| **`index.html`** | GENERATED — the interactive site (clickable table → stack builder → garment visualizer). Do not hand-edit; edit `site_template.py` and regenerate. |
| **`gallery.html`** | GENERATED — a static gallery of all PNG previews (fallback / quick review). |
| **`BRAND-DESIGN-BRIEF.md`** | The brand brief: full element table, the 5 stacks, the 5 t-shirt "collections", the master AI-art prompt, step-by-step path to a printer, and a verify-before-print checklist of amino-acid/MW values. |
| **`svg/`** | GENERATED — print-ready vector files (one per compound, per stack, plus poster + concept). Editable in Illustrator/Affinity/Inkscape. |
| **`preview/`** | GENERATED — PNG previews of every design, rendered on a near-black "garment". |
| **`serve.sh`** | Serves `designs/` locally and exposes it over Tailscale (foreground; runs while the terminal is open). Options: `--local`, `PORT=`. |
| **`install_service.sh`** | Installs an always-on macOS LaunchAgent (`com.humanplus.site`) that serves the site at login and restarts on crash. `--uninstall` to remove. |
| **`HOSTING.md`** | Human-facing hosting instructions (setup, run, always-on, troubleshooting). |
| **`PROJECT.md`** | This file. |

---

## 4. How to regenerate the designs + site

Requires Python 3 and `rsvg-convert` (from `librsvg`). On macOS: `brew install librsvg`.

```bash
cd ~/peptide-store/designs
python3 generate_tiles.py
```

This rewrites everything in `svg/`, `preview/`, plus `index.html` and `gallery.html`.
`generate_tiles.py` imports `SITE_TEMPLATE` from `site_template.py`, so both must be
present. Output ends with: `Generated N designs + index.html (interactive) + gallery.html`.

To change designs, edit the `ELEMENTS` or `STACKS` tables (or `PALETTE`) at the top
of `generate_tiles.py` and re-run. To change the website UI, edit `site_template.py`
and re-run.

After regenerating, if the site is hosted via the LaunchAgent it serves the new files
immediately (static files; just refresh the browser). No restart needed.

---

## 5. How the site is hosted (current state on the Mac mini)

- Machine: Mac mini, hostname `Daneels-Mac-mini`, user `daneel`, Apple Silicon, zsh.
- Python: `/opt/homebrew/bin/python3`.
- An always-on LaunchAgent `com.humanplus.site` runs:
  `python3 -m http.server 8088 --bind 127.0.0.1` with working dir `~/peptide-store/designs`.
  Plist at `~/Library/LaunchAgents/com.humanplus.site.plist`. Logs in `~/Library/Logs/humanplus/`.
- Tailscale Serve proxies:
  - private tailnet HTTP `http://daneels-mac-mini.rattlesnake-jazz.ts.net:8088/` → `http://127.0.0.1:8088`
  - private tailnet HTTPS `https://daneels-mac-mini.rattlesnake-jazz.ts.net/` → `http://127.0.0.1:8088`
- Tailnet name: `rattlesnake-jazz`. Intended URL:
  `http://daneels-mac-mini.rattlesnake-jazz.ts.net:8088/` (working private URL);
  `https://daneels-mac-mini.rattlesnake-jazz.ts.net/` once Tailscale cert provisioning works.
- Local check `curl http://127.0.0.1:8088/index.html` returns **HTTP 200** (server confirmed working).

Manage:
```bash
cd ~/peptide-store/designs
./install_service.sh             # (re)install always-on service
./install_service.sh --uninstall # remove service + clear Tailscale route
tail -f ~/Library/Logs/humanplus/err.log   # logs
```

---

## 6. OPEN ISSUE — iPhone can't reach the HTTPS URL (timeout)

**Symptom:** On the Mac mini, `http://127.0.0.1:8088/index.html` = HTTP 200 (server fine).
From an iPhone on the same tailnet, the HTTPS URL "won't connect / times out".

**Current workaround:** The private tailnet HTTP route is live at
`http://daneels-mac-mini.rattlesnake-jazz.ts.net:8088/`. This stays private to the
tailnet and bypasses Tailscale's HTTPS certificate provisioning layer.

**Most likely cause:** `tailscale serve --https=443` requires **HTTPS Certificates**
and **MagicDNS** to be ENABLED for the tailnet. These are admin-console settings, not
CLI-toggleable. If off, the HTTPS endpoint never provisions a cert and just times out
— which matches the symptom exactly.

**Diagnostic + fix sequence (run on the Mac mini):**
1. `curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8088/index.html` → expect 200.
2. `launchctl list | grep humanplus` → confirm the agent is loaded.
3. `tailscale serve status` → confirm proxy maps 443 → 127.0.0.1:8088.
4. `tailscale status` → confirm the iPhone appears as a peer (if not: phone isn't
   signed into / connected to the tailnet — fix that first).
5. `tailscale cert daneels-mac-mini.rattlesnake-jazz.ts.net` → if this FAILS, HTTPS
   certs / MagicDNS are disabled. Enable them in the admin console:
   - **HTTPS Certificates:** https://login.tailscale.com/admin/dns → "Enable HTTPS…"
   - **MagicDNS:** same DNS page → enable MagicDNS.
   Then re-run step 5; it should succeed.
6. Re-assert serve: `tailscale serve --bg --https=443 http://127.0.0.1:8088`.
7. **Isolation test** (HTTP, bypasses the cert layer): from the phone, with Tailscale
   on, open `http://daneels-mac-mini.rattlesnake-jazz.ts.net:8088/`. If THAT loads but
   HTTPS doesn't, it's definitely the cert/MagicDNS layer. If neither loads, it's
   phone↔tailnet connectivity (Tailscale off/signed-out on the phone, or an ACL block).
8. Check ACLs in the admin console don't block device-to-device on 443.

**Constraints:** keep the site PRIVATE to the tailnet. Do NOT enable `tailscale funnel`
(that makes it public) unless the user explicitly asks.

---

## 7. Roadmap / possible next work

- Turn "Add to cart" (currently a demo placeholder) into real checkout / print-on-demand.
- More stacks; per-stack accent theming.
- More realistic garment mockups; back-print option; size guide.
- A true system `LaunchDaemon` (runs before login) instead of a per-user LaunchAgent,
  if the Mac mini should serve unattended without auto-login.
- Public hosting (GitHub Pages or `tailscale funnel`) when the brand is ready to go public.

---

## 8. Git workflow

- Branch: `claude/periodic-table-tshirt-designs-Wd9su`. Develop here; don't push to `master`.
- Typical update loop: edit data/template → `python3 generate_tiles.py` → commit → push.
- After pushing, on the Mac mini: `git pull` (the LaunchAgent serves the new static files
  immediately; no restart needed).
