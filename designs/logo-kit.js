/* HUMAN+ Logo Kit — self-contained brand-logo download panel.
   Drop into any page with:  <script src="logo-kit.js"></script>
   and a trigger:            <button class="logokit-trigger" onclick="openLogoKit()">Logo</button>
   No page dependencies — its own brand constants, SVG generators, styling, and download logic. */
(function () {
  "use strict";

  var BRAND = {
    green: "#2BE8B0",
    sans: "'Segoe UI', system-ui, -apple-system, Arial, sans-serif",
    mono: "ui-monospace, 'Courier New', monospace"
  };

  // variant -> {label, viewBox:[w,h], build(txt, green)}
  var VARIANTS = {
    wordmark: {
      label: "Wordmark",
      vb: [1000, 300],
      build: function (t, g) {
        return tspanLine(500, 212, 210, 6, "middle", t, g);
      }
    },
    left_chest: {
      label: "Left chest",
      vb: [1200, 1400],
      build: function (t, g) {
        return tspanLine(250, 430, 74, 3, "start", t, g) +
          tagline(252, 470, 19, 6, "start", t);
      }
    },
    centered: {
      label: "Centered",
      vb: [1200, 1400],
      build: function (t, g) {
        return tspanLine(600, 690, 150, 8, "middle", t, g) +
          tagline(600, 770, 34, 10, "middle", t);
      }
    },
    concept: {
      label: "Concept",
      vb: [1200, 1400],
      build: function (t, g) {
        var grey = "#6b6b78";
        return tspanLine(600, 300, 100, 6, "middle", t, g) +
          txt(600, 370, BRAND.mono, 30, 700, 6, "middle", t, .5, "FACTORY DEFAULT IS NOT FINAL") +
          box(150, 500, grey) +
          txt(180, 575, BRAND.mono, 40, 700, 0, "start", grey, 1, "00") +
          txt(340, 745, BRAND.sans, 120, 800, 0, "middle", grey, 1, "Hs") +
          txt(340, 850, BRAND.sans, 38, 700, 0, "middle", grey, 1, "Homo sapiens") +
          txt(340, 895, BRAND.mono, 22, 700, 2, "middle", grey, .7, "FACTORY DEFAULT") +
          txt(600, 730, BRAND.sans, 90, 800, 0, "middle", g, 1, "→") +
          box(670, 500, g) +
          txt(700, 575, BRAND.mono, 40, 700, 0, "start", g, 1, "01") +
          txt(860, 745, BRAND.sans, 110, 800, 0, "middle", g, 1, "H+") +
          txt(860, 850, BRAND.sans, 38, 700, 0, "middle", g, 1, "Human plus") +
          txt(860, 895, BRAND.mono, 22, 700, 2, "middle", g, .8, "ENHANCED");
      }
    }
  };

  function esc(s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }

  // "HUMAN" + green "+"
  function tspanLine(x, y, size, ls, anchor, fill, green) {
    return '<text x="' + x + '" y="' + y + '" font-family="' + BRAND.sans +
      '" font-size="' + size + '" font-weight="800" letter-spacing="' + ls +
      '" text-anchor="' + anchor + '" fill="' + fill + '">HUMAN<tspan fill="' + green + '">+</tspan></text>';
  }
  function tagline(x, y, size, ls, anchor, fill) {
    return '<text x="' + x + '" y="' + y + '" font-family="' + BRAND.mono +
      '" font-size="' + size + '" font-weight="700" letter-spacing="' + ls +
      '" text-anchor="' + anchor + '" fill="' + fill + '" fill-opacity="0.55">MODIFIED · ENHANCED · OPTIMIZED</text>';
  }
  function txt(x, y, font, size, weight, ls, anchor, fill, op, s) {
    return '<text x="' + x + '" y="' + y + '" font-family="' + font + '" font-size="' + size +
      '" font-weight="' + weight + '" letter-spacing="' + ls + '" text-anchor="' + anchor +
      '" fill="' + fill + '" fill-opacity="' + op + '">' + esc(s) + '</text>';
  }
  function box(x, y, stroke) {
    return '<rect x="' + x + '" y="' + y + '" width="380" height="420" rx="18" fill="none" stroke="' +
      stroke + '" stroke-width="9"/>';
  }

  function buildSVG(variant, mode) {
    var v = VARIANTS[variant];
    var t = mode === "ink" ? "#14141A" : "#FFFFFF";
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + v.vb[0] + ' ' + v.vb[1] +
      '" role="img" aria-label="HUMAN+ logo">' + v.build(t, BRAND.green) + '</svg>';
  }

  var state = { variant: "wordmark", mode: "light" };
  var root = null;

  function downloadBlob(blob, name) {
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url; a.download = name; a.click();
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
  }
  function fname(ext) { return "human-plus-" + state.variant + "-" + state.mode + "." + ext; }

  function downloadSVG() {
    downloadBlob(new Blob([buildSVG(state.variant, state.mode)], { type: "image/svg+xml" }), fname("svg"));
  }
  function downloadPNG() {
    var svg = buildSVG(state.variant, state.mode);
    var v = VARIANTS[state.variant].vb;
    var longEdge = 4000, scale = longEdge / Math.max(v[0], v[1]);
    var W = Math.round(v[0] * scale), H = Math.round(v[1] * scale);
    var img = new Image();
    img.onload = function () {
      var c = document.createElement("canvas"); c.width = W; c.height = H;
      c.getContext("2d").drawImage(img, 0, 0, W, H);
      c.toBlob(function (b) { downloadBlob(b, fname("png")); }, "image/png");
    };
    img.src = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg);
  }

  function renderPreview() {
    var box = root.querySelector(".lk-preview");
    box.style.background = state.mode === "ink" ? "#e9e9ef" : "#0d0d12";
    box.innerHTML = buildSVG(state.variant, state.mode);
    var svgEl = box.querySelector("svg");
    svgEl.removeAttribute("width"); svgEl.removeAttribute("height");
    svgEl.style.maxWidth = "100%"; svgEl.style.maxHeight = "300px";
    root.querySelectorAll("[data-variant]").forEach(function (b) {
      b.classList.toggle("on", b.dataset.variant === state.variant);
    });
    root.querySelectorAll("[data-mode]").forEach(function (b) {
      b.classList.toggle("on", b.dataset.mode === state.mode);
    });
  }

  function ensureModal() {
    if (root) return;
    var style = document.createElement("style");
    style.textContent =
      ".logokit-trigger{display:inline-flex;align-items:center;gap:6px;padding:7px 12px;font:700 .8rem/1 " + BRAND.sans + ";letter-spacing:.5px;color:#bdf5e4;background:rgba(43,232,176,.10);border:1px solid rgba(43,232,176,.40);border-radius:8px;cursor:pointer;transition:.15s;text-decoration:none;}" +
      ".logokit-trigger:hover{background:" + BRAND.green + ";color:#08110d;border-color:" + BRAND.green + ";}" +
      ".lk-overlay{position:fixed;inset:0;z-index:9999;display:none;align-items:center;justify-content:center;background:rgba(4,6,12,.72);backdrop-filter:blur(4px);padding:20px;}" +
      ".lk-overlay.open{display:flex;}" +
      ".lk-panel{width:min(560px,100%);max-height:92vh;overflow:auto;background:#0f1118;border:1px solid #23263a;border-radius:18px;box-shadow:0 30px 80px rgba(0,0,0,.6);color:#e6e6f2;font-family:" + BRAND.sans + ";}" +
      ".lk-head{display:flex;align-items:center;justify-content:space-between;padding:18px 20px 8px;}" +
      ".lk-head h3{margin:0;font-size:1.05rem;font-weight:800;letter-spacing:.5px;}" +
      ".lk-head h3 span{color:" + BRAND.green + ";}" +
      ".lk-x{background:none;border:none;color:#9393b0;font-size:1.5rem;line-height:1;cursor:pointer;padding:0 4px;}" +
      ".lk-x:hover{color:#fff;}" +
      ".lk-sub{padding:0 20px 12px;color:#9393b0;font-size:.78rem;font-family:" + BRAND.mono + ";letter-spacing:.5px;}" +
      ".lk-preview{margin:0 20px;border-radius:12px;min-height:170px;display:flex;align-items:center;justify-content:center;padding:22px;border:1px solid #23263a;}" +
      ".lk-row{display:flex;flex-wrap:wrap;gap:8px;padding:14px 20px 0;}" +
      ".lk-row .lk-label{flex:0 0 100%;font-size:.66rem;letter-spacing:2px;color:#9393b0;font-family:" + BRAND.mono + ";text-transform:uppercase;margin-bottom:2px;}" +
      ".lk-chip{padding:8px 12px;border-radius:8px;border:1px solid #2a2e44;background:#161a26;color:#cfd0e6;font:700 .75rem/1 " + BRAND.sans + ";letter-spacing:.5px;cursor:pointer;transition:.12s;}" +
      ".lk-chip:hover{border-color:" + BRAND.green + ";}" +
      ".lk-chip.on{background:" + BRAND.green + ";color:#08110d;border-color:" + BRAND.green + ";}" +
      ".lk-actions{display:flex;gap:10px;padding:18px 20px 22px;}" +
      ".lk-actions button{flex:1;padding:12px;border-radius:10px;border:none;font:800 .85rem/1 " + BRAND.sans + ";letter-spacing:.5px;cursor:pointer;}" +
      ".lk-svg{background:#1d2233;color:#e6e6f2;border:1px solid #2a2e44!important;}" +
      ".lk-svg:hover{border-color:" + BRAND.green + "!important;}" +
      ".lk-png{background:" + BRAND.green + ";color:#08110d;}" +
      ".lk-png:hover{filter:brightness(1.08);}";
    document.head.appendChild(style);

    root = document.createElement("div");
    root.className = "lk-overlay";
    root.innerHTML =
      '<div class="lk-panel" role="dialog" aria-label="HUMAN+ logo download">' +
      '<div class="lk-head"><h3>HUMAN<span>+</span> Logo Kit</h3><button class="lk-x" aria-label="Close">×</button></div>' +
      '<div class="lk-sub">Transparent background · vector SVG + 4000px PNG · front-chest ready</div>' +
      '<div class="lk-preview"></div>' +
      '<div class="lk-row"><span class="lk-label">Placement</span>' +
      Object.keys(VARIANTS).map(function (k) {
        return '<button class="lk-chip" data-variant="' + k + '">' + VARIANTS[k].label + '</button>';
      }).join("") + '</div>' +
      '<div class="lk-row"><span class="lk-label">Color</span>' +
      '<button class="lk-chip" data-mode="light">Light (dark garments)</button>' +
      '<button class="lk-chip" data-mode="ink">Ink (light garments)</button></div>' +
      '<div class="lk-actions"><button class="lk-svg">Download SVG</button><button class="lk-png">Download PNG</button></div>' +
      '</div>';
    document.body.appendChild(root);

    root.addEventListener("click", function (e) {
      if (e.target === root) closeLogoKit();
      var b = e.target.closest("[data-variant]"); if (b) { state.variant = b.dataset.variant; renderPreview(); }
      var m = e.target.closest("[data-mode]"); if (m) { state.mode = m.dataset.mode; renderPreview(); }
      if (e.target.closest(".lk-x")) closeLogoKit();
      if (e.target.closest(".lk-svg")) downloadSVG();
      if (e.target.closest(".lk-png")) downloadPNG();
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && root.classList.contains("open")) closeLogoKit();
    });
  }

  window.openLogoKit = function () { ensureModal(); renderPreview(); root.classList.add("open"); };
  window.closeLogoKit = function () { if (root) root.classList.remove("open"); };
})();
