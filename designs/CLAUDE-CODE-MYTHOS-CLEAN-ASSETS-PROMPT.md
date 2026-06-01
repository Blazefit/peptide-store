# Claude Code Prompt: Use Clean MYTHOS Assets

You are working in `~/peptide-store` on branch `claude/periodic-table-tshirt-designs-Wd9su`.

Goal: make the MYTHOS site use card images that do not show the compound-card `EVOLVES INTO` label.

Steps:

1. Pull latest:
   ```sh
   cd ~/peptide-store
   git pull origin claude/periodic-table-tshirt-designs-Wd9su
   ```

2. Confirm these folders exist:
   - `designs/mythic_preview_clean/`
   - `designs/mythic_svg_clean/`

3. Confirm the site code points to the clean folders, not the original preview folders:
   - `designs/mythic_template.py`
   - `designs/mythic.html`

   The image helpers should be:
   ```js
   const cImg = (sym)=>`mythic_preview_clean/c_${sym}_${style}.png`;
   const cSvg = (sym)=>`mythic_svg_clean/c_${sym}_${style}.svg`;
   const eImg = (name)=>`mythic_preview_clean/e_${name.replace(/ /g,"_")}_${style}.png`;
   const eSvg = (name)=>`mythic_svg_clean/e_${name.replace(/ /g,"_")}_${style}.svg`;
   ```

4. If the clean folders need to be rebuilt, run:
   ```sh
   cd ~/peptide-store/designs
   python3 generate_mythic.py
   ```

5. Verify the clean SVGs and live page do not contain the phrase:
   ```sh
   cd ~/peptide-store
   ! rg "EVOLVES INTO" designs/mythic_svg_clean designs/mythic.html
   ```

6. Verify the site still serves:
   ```sh
   curl -I --max-time 5 http://127.0.0.1:8088/mythic.html
   curl -I --max-time 8 https://daneels-mac-mini.rattlesnake-jazz.ts.net/mythic.html
   ```

Do not delete the original `designs/mythic_preview/` or `designs/mythic_svg/` folders. They are kept as legacy fallback assets. The live site should use only the clean folders.
