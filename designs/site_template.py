"""HTML/CSS/JS template for the HUMAN+ interactive site.
The marker /*__DATA__*/ is replaced with the embedded element/stack JSON.
Tiles are rendered as live SVG in JS, mirroring generate_tiles.py so the
web app and the print previews stay visually identical."""

SITE_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUMAN+ — Build Your Stack</title>
<style>
  :root{
    --bg:#0d0d12; --surface:#16161f; --surface2:#1e1e2c; --border:#2a2a40;
    --text:#e6e6f2; --text2:#9393b0; --green:#2BE8B0; --amber:#FFB020; --violet:#7C5CFC;
  }
  *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
  body{background:var(--bg);color:var(--text);font-family:'Segoe UI',system-ui,-apple-system,sans-serif;min-height:100vh;}
  a{color:inherit;}
  header{position:sticky;top:0;z-index:50;background:rgba(13,13,18,.92);backdrop-filter:blur(10px);
    border-bottom:1px solid var(--border);padding:14px 18px;display:flex;align-items:center;justify-content:space-between;gap:12px;}
  .logo{font-size:1.5rem;font-weight:800;letter-spacing:1px;}
  .logo span{color:var(--green);}
  .tagline{font-family:ui-monospace,monospace;font-size:.6rem;letter-spacing:3px;color:var(--text2);}
  .page{display:none;}
  .page.active{display:block;}
  main{max-width:1400px;margin:0 auto;padding:18px;}
  h2{font-size:1.1rem;font-weight:700;margin-bottom:4px;}
  .muted{color:var(--text2);font-size:.85rem;}
  .legend{display:flex;gap:18px;margin:14px 0;font-size:.78rem;font-family:ui-monospace,monospace;flex-wrap:wrap;}
  .legend i{display:inline-block;width:14px;height:14px;border-radius:3px;margin-right:6px;vertical-align:-2px;}
  /* periodic grid */
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(96px,1fr));gap:8px;margin-top:12px;}
  .cell{position:relative;aspect-ratio:1/1.12;border:2px solid var(--green);border-radius:9px;background:var(--surface);
    cursor:pointer;padding:6px;display:flex;flex-direction:column;justify-content:space-between;transition:transform .12s,box-shadow .12s;overflow:hidden;}
  .cell.hor{border-color:var(--amber);}
  .cell.mol{border-color:var(--violet);}
  .cell:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.5);}
  .cell.sel{box-shadow:0 0 0 3px var(--green) inset,0 8px 28px rgba(43,232,176,.25);}
  .cell.hor.sel{box-shadow:0 0 0 3px var(--amber) inset,0 8px 28px rgba(255,176,32,.25);}
  .cell.mol.sel{box-shadow:0 0 0 3px var(--violet) inset,0 8px 28px rgba(124,92,252,.25);}
  .cell .num{font-family:ui-monospace,monospace;font-size:.66rem;font-weight:700;}
  .cell.pep .num{color:var(--green);} .cell.hor .num{color:var(--amber);} .cell.mol .num{color:var(--violet);}
  .cell .unit{font-family:ui-monospace,monospace;font-size:.5rem;color:var(--text2);position:absolute;top:6px;right:6px;}
  .cell .sym{font-size:1.7rem;font-weight:800;text-align:center;line-height:1;margin:auto 0;}
  .cell .nm{font-size:.55rem;font-weight:700;text-align:center;}
  .cell.pep .nm{color:var(--green);} .cell.hor .nm{color:var(--amber);} .cell.mol .nm{color:var(--violet);}
  .cell.blend{border-color:#C9A24B;border-style:double;border-width:3px;}
  .cell.blend.sel{box-shadow:0 0 0 3px #C9A24B inset,0 8px 28px rgba(201,162,75,.28);}
  .cell.blend .num,.cell.blend .nm,.cell.blend .sym{color:#E7CB7E;}
  .cell .chk{position:absolute;top:4px;left:50%;transform:translateX(-50%);opacity:0;font-weight:800;color:var(--green);}
  .cell.sel .chk{opacity:1;}
  /* sticky tray */
  .tray{position:fixed;left:0;right:0;bottom:0;z-index:60;background:rgba(20,20,30,.97);backdrop-filter:blur(10px);
    border-top:1px solid var(--border);padding:12px 16px;display:flex;align-items:center;gap:12px;transform:translateY(110%);transition:transform .25s;}
  .tray.show{transform:translateY(0);}
  .tray .chips{display:flex;gap:8px;overflow-x:auto;flex:1;}
  .chip{display:flex;align-items:center;gap:6px;background:var(--surface2);border:1px solid var(--border);
    border-radius:20px;padding:5px 6px 5px 12px;font-size:.85rem;white-space:nowrap;}
  .chip b{font-weight:800;}
  .chip button{background:none;border:none;color:var(--text2);font-size:1rem;cursor:pointer;padding:0 4px;}
  .btn{border:none;border-radius:10px;padding:11px 18px;font-size:.9rem;font-weight:700;cursor:pointer;transition:filter .15s;white-space:nowrap;}
  .btn-primary{background:var(--green);color:#08110d;}
  .btn-primary:disabled{opacity:.4;cursor:not-allowed;}
  .btn-ghost{background:transparent;border:1px solid var(--border);color:var(--text);}
  .btn:hover:not(:disabled){filter:brightness(1.08);}
  /* compact stack shortcuts */
  .stack-tools{display:grid;grid-template-columns:1fr;gap:10px;margin:10px 0;}
  @media(min-width:860px){.stack-tools{grid-template-columns:minmax(0,1fr) 260px;align-items:center;}}
  .stack-filters{display:flex;gap:6px;flex-wrap:wrap;}
  .stack-filters button{border:1px solid var(--border);background:var(--surface2);color:var(--text2);
    border-radius:8px;padding:8px 10px;font-family:ui-monospace,monospace;font-size:.65rem;font-weight:800;letter-spacing:1px;cursor:pointer;}
  .stack-filters button.on{background:var(--green);color:#08110d;border-color:var(--green);}
  .stack-search{width:100%;background:var(--surface2);border:1px solid var(--border);border-radius:9px;color:var(--text);
    padding:10px 12px;font-size:.88rem;}
  .presets{display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:8px;margin:10px 0 22px;max-height:360px;overflow:auto;padding-right:3px;}
  .preset{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:10px 11px;cursor:pointer;
    transition:border-color .15s,background .15s;display:grid;grid-template-columns:minmax(0,1fr) auto;gap:8px;align-items:start;}
  .preset:hover{border-color:var(--green);background:#1a1a24;}
  .preset .pn{font-size:.9rem;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
  .preset .pt{font-size:.62rem;font-weight:700;letter-spacing:1.5px;color:var(--green);font-family:ui-monospace,monospace;
    margin-top:2px;white-space:normal;overflow-wrap:anywhere;}
  .preset .pc{font-size:.66rem;color:var(--text2);font-family:ui-monospace,monospace;margin-top:3px;line-height:1.4;
    white-space:normal;overflow-wrap:anywhere;word-break:break-word;}
  .preset .badge{font-family:ui-monospace,monospace;font-size:.58rem;color:var(--green);border:1px solid currentColor;border-radius:999px;padding:4px 7px;}
  .preset .badge.blend{color:#E7CB7E;}
  .empty{border:1px dashed var(--border);border-radius:10px;padding:14px;color:var(--text2);font-size:.85rem;}
  /* builder / garment page */
  .two{display:grid;grid-template-columns:1fr;gap:20px;}
  @media(min-width:880px){.two{grid-template-columns:1fr 1fr;}}
  .panel{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:16px;}
  .art-wrap{background:#000;border-radius:12px;overflow:hidden;display:flex;align-items:center;justify-content:center;}
  .art-wrap svg{width:100%;height:auto;display:block;}
  .garment-wrap{display:flex;align-items:center;justify-content:center;border-radius:12px;overflow:hidden;}
  .garment-wrap svg{width:100%;height:auto;max-height:70vh;}
  .row{display:flex;gap:10px;flex-wrap:wrap;align-items:center;margin:10px 0;}
  .swatch{width:34px;height:34px;border-radius:8px;border:2px solid var(--border);cursor:pointer;}
  .swatch.on{border-color:var(--green);box-shadow:0 0 0 2px var(--green);}
  .seg{display:flex;background:var(--surface2);border-radius:9px;padding:3px;}
  .seg button{flex:1;border:none;background:none;color:var(--text2);padding:8px 14px;border-radius:7px;font-weight:600;cursor:pointer;}
  .seg button.on{background:var(--green);color:#08110d;}
  label.fld{display:block;font-size:.75rem;color:var(--text2);margin:12px 0 4px;text-transform:uppercase;letter-spacing:1px;}
  input[type=text]{width:100%;background:var(--surface2);border:1px solid var(--border);border-radius:8px;color:var(--text);padding:10px 12px;font-size:.95rem;}
  .back{font-size:.85rem;color:var(--text2);cursor:pointer;display:inline-flex;gap:6px;align-items:center;margin-bottom:10px;}
  .pad-bottom{height:90px;}
  .hint{font-size:.78rem;color:var(--text2);margin-top:8px;}
</style>
</head>
<body>
<header>
  <div class="logo">HUMAN<span>+</span></div>
  <div class="tagline">MODIFIED &middot; ENHANCED &middot; OPTIMIZED</div>
  <div style="display:flex;gap:8px;align-items:center;">
    <a class="btn btn-ghost" href="home.html" style="padding:7px 12px;font-size:.8rem;text-decoration:none;">&#8962; Hub</a>
    <a class="btn btn-ghost" href="mythic.html" style="padding:7px 12px;font-size:.8rem;text-decoration:none;">Mythos</a>
    <button class="btn btn-ghost" id="navGallery" style="padding:7px 12px;font-size:.8rem;">Gallery</button>
  </div>
</header>

<!-- ============ PAGE 1 : BUILDER ============ -->
<div class="page active" id="pageBuild">
  <main>
    <h2>Build Your Stack</h2>
    <p class="muted">Tap any element to add it to your stack. Peptides are counted by amino acids, hormones by molecular weight.</p>
    <div class="legend">
      <span><i style="background:var(--green)"></i>PEPTIDE (amino acids)</span>
      <span><i style="background:var(--amber)"></i>HORMONE (g/mol)</span>
      <span><i style="background:var(--violet)"></i>MOLECULE (g/mol)</span>
    </div>

    <h2>Compound Elements</h2>
    <p class="muted">Pick individual compounds first. Your selected stack stays pinned at the bottom.</p>
    <div class="grid" id="grid"></div>

    <h2 style="margin-top:22px;">Stack Shortcuts</h2>
    <p class="muted">Compact presets for full protocols and blend tiles. Load one, then customize compounds above.</p>
    <div class="stack-tools">
      <div class="stack-filters" id="stackFilter">
        <button data-cat="ALL" class="on">ALL</button>
        <button data-cat="BLEND">BLENDS</button>
        <button data-cat="REPAIR">REPAIR</button>
        <button data-cat="HORMONE">HORMONE</button>
        <button data-cat="BODY">BODY</button>
        <button data-cat="COG">COG</button>
        <button data-cat="MITO">MITO</button>
      </div>
      <input class="stack-search" id="stackSearch" type="search" placeholder="Search stacks">
    </div>
    <div class="presets" id="presets"></div>
    <div class="pad-bottom"></div>
  </main>

  <div class="tray" id="tray">
    <div class="chips" id="chips"></div>
    <button class="btn btn-ghost" id="clearBtn">Clear</button>
    <button class="btn btn-primary" id="visualizeBtn">Visualize &rarr;</button>
  </div>
</div>

<!-- ============ PAGE 2 : GARMENT ============ -->
<div class="page" id="pageGarment">
  <main>
    <span class="back" id="backBtn">&larr; Back to builder</span>
    <div class="two">
      <div class="panel">
        <h2>Your Design</h2>
        <p class="muted" id="designSub"></p>
        <div class="art-wrap" id="artWrap" style="margin-top:12px;"></div>
        <label class="fld">Stack name</label>
        <input type="text" id="stackName" maxlength="18" placeholder="MY STACK">
        <label class="fld">Tagline</label>
        <input type="text" id="stackTag" maxlength="26" placeholder="BUILT DIFFERENT">
      </div>
      <div class="panel">
        <h2>On a Garment</h2>
        <div class="row">
          <div class="seg" id="garmentSeg">
            <button data-g="tee" class="on">T-Shirt</button>
            <button data-g="hoodie">Hoodie</button>
            <button data-g="long">Long Sleeve</button>
          </div>
        </div>
        <div class="garment-wrap" id="garmentWrap"></div>
        <label class="fld">Garment color</label>
        <div class="row" id="garmentColors"></div>
        <label class="fld">Print accent</label>
        <div class="row" id="accentColors"></div>
        <div class="row" style="margin-top:14px;">
          <button class="btn btn-primary" id="downloadBtn">Download SVG</button>
          <button class="btn btn-primary" id="downloadPngBtn">Download PNG</button>
          <button class="btn btn-ghost" id="addCartBtn">Add to cart (demo)</button>
        </div>
        <p class="hint">Demo prototype — "add to cart" is a placeholder. Download gives you the print-ready vector.</p>
      </div>
    </div>
  </main>
</div>

<!-- ============ PAGE 3 : GALLERY ============ -->
<div class="page" id="pageGallery">
  <main>
    <span class="back" id="backBtn2">&larr; Back to builder</span>
    <h2>All Designs</h2>
    <p class="muted">Every compound + curated stack, rendered live.</p>
    <div class="grid" id="galleryGrid" style="grid-template-columns:repeat(auto-fill,minmax(150px,1fr));margin-top:14px;"></div>
    <div class="pad-bottom"></div>
  </main>
</div>

<script>
const DB = /*__DATA__*/;
const SANS = "'Segoe UI',system-ui,-apple-system,sans-serif";
const MONO = "ui-monospace,'Courier New',monospace";
const EL = {}; DB.elements.forEach(e=>EL[e.sym]=e);
// blends (KL/WO/GL) act like single selectable compounds but expand into several
(DB.blends||[]).forEach(b=>{EL[b.sym]=Object.assign({fam:"BLEND",count:b.comps.length},b);});
let selected = [];     // array of symbols
let garment = "tee";
let garmentColor = "#0d0d12";
let accentColor = DB.green;
let stackCategory = "ALL";
let stackQuery = "";

/* ---------- live SVG tile (mirrors generate_tiles.py hero_tile) ---------- */
function esc(s){return (s+"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");}

function accentOf(e){return DB.palette[e.fam]||DB.palette.PEP;}
function heroTileSVG(e){
  const acc = accentOf(e);
  const tx=200,ty=360,tw=800,th=800,cx=tx+tw/2;
  let tlBig,tlLabel,tr;
  if(e.fam==="PEP"){
    if(e.name_num){tlBig=e.name_num;tlLabel="SERIES";
      tr=`<text x="${tx+tw-45}" y="${ty+58}" font-family="${MONO}" font-size="28" letter-spacing="3" text-anchor="end" fill="#fff" fill-opacity=".6">AMINO ACIDS</text>
          <text x="${tx+tw-45}" y="${ty+126}" font-family="${MONO}" font-size="62" font-weight="700" text-anchor="end" fill="${acc}">${e.count}</text>`;
    } else {tlBig=e.count;tlLabel="AMINO ACIDS";
      tr=`<text x="${tx+tw-45}" y="${ty+58}" font-family="${MONO}" font-size="28" letter-spacing="4" text-anchor="end" fill="#fff" fill-opacity=".6">PEPTIDE</text>`;}
  } else {
    tlBig=e.count;tlLabel="g/mol";
    const famWord = e.fam==="MOL"?"MOLECULE":"HORMONE";
    tr=`<text x="${tx+tw-45}" y="${ty+58}" font-family="${MONO}" font-size="28" letter-spacing="4" text-anchor="end" fill="#fff" fill-opacity=".6">${famWord}</text>
        <text x="${tx+tw-45}" y="${ty+120}" font-family="${SANS}" font-size="34" letter-spacing="1" text-anchor="end" fill="${acc}">${esc(e.formula)}</text>`;
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400">
    <text x="600" y="190" font-family="${SANS}" font-size="92" font-weight="800" text-anchor="middle" letter-spacing="6" fill="#fff">HUMAN<tspan fill="${acc}">+</tspan></text>
    <text x="600" y="240" font-family="${MONO}" font-size="26" text-anchor="middle" letter-spacing="8" fill="#fff" fill-opacity=".45">THE PERIODIC TABLE OF ENHANCEMENT</text>
    <rect x="${tx}" y="${ty}" width="${tw}" height="${th}" rx="20" fill="none" stroke="${acc}" stroke-width="10"/>
    <line x1="${tx}" y1="${ty+170}" x2="${tx+tw}" y2="${ty+170}" stroke="${acc}" stroke-width="3" stroke-opacity=".4"/>
    <text x="${tx+45}" y="${ty+102}" font-family="${MONO}" font-size="80" font-weight="700" fill="${acc}">${tlBig}</text>
    <text x="${tx+48}" y="${ty+150}" font-family="${MONO}" font-size="26" letter-spacing="3" fill="#fff" fill-opacity=".6">${tlLabel}</text>
    ${tr}
    <text x="${cx}" y="${ty+475}" font-family="${SANS}" font-size="340" font-weight="800" text-anchor="middle" fill="#fff">${esc(e.sym)}</text>
    <text x="${cx}" y="${ty+665}" font-family="${SANS}" font-size="74" font-weight="800" text-anchor="middle" fill="${acc}">${esc(e.full)}</text>
    <text x="${cx}" y="${ty+712}" font-family="${SANS}" font-size="33" letter-spacing="2" text-anchor="middle" fill="#fff" fill-opacity=".7">${esc(e.sub.toUpperCase())}</text>
    <text x="${cx}" y="${ty+772}" font-family="${MONO}" font-size="33" font-weight="700" letter-spacing="6" text-anchor="middle" fill="#fff">${esc(e.tag)}</text>
    <text x="600" y="1300" font-family="${MONO}" font-size="28" letter-spacing="4" text-anchor="middle" fill="#fff" fill-opacity=".4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
  </svg>`;
}

function fitFS(text,maxW,base,avg=0.82){
  if(text.length*avg*base<=maxW) return base;
  return Math.floor(maxW/(text.length*avg));
}

/* fit font-size to a width (mirrors python _fit) */
function fitW(t,maxW,base,avg){return (t.length*avg*base<=maxW)?base:Math.max(12,Math.floor(maxW/(t.length*avg)));}
/* component display fields, element OR blend (mirrors comp_display) */
function compDisp(cs){const e=EL[cs];const third=e.blend?"BLEND":(e.count+(e.fam==="PEP"?"aa":""));return [e.sym,e.full,third];}

/* live stack tile (mirrors stack_tile) */
function stackTileSVG(name,sub,comps,tag,extras){
  const cols=DB.stackColors;
  const n=comps.length, gap=n<=4?70:40, band=1120;
  const bw=Math.min(230,Math.floor((band-(n-1)*gap)/n));
  const total=n*bw+(n-1)*gap, start=600-total/2, boxY=640,boxH=300;
  const symFS=Math.min(116,Math.floor(bw*0.60));
  let stops="",minis="";
  comps.forEach((cs,i)=>{
    const [sy,full,third]=compDisp(cs), col=cols[i%cols.length];
    const x=start+i*(bw+gap), cxm=x+bw/2;
    const nameFs=fitW(full,bw-14,30,0.55), thirdFs=fitW(third,bw-14,22,0.62);
    stops+=`<stop offset="${Math.floor(i*100/Math.max(n-1,1))}%" stop-color="${col}"/>`;
    minis+=`<rect x="${x}" y="${boxY}" width="${bw}" height="${boxH}" rx="14" fill="none" stroke="${col}" stroke-width="7"/>
      <text x="${cxm}" y="${boxY+150}" font-family="${SANS}" font-size="${symFS}" font-weight="800" text-anchor="middle" fill="#fff">${esc(sy)}</text>
      <text x="${cxm}" y="${boxY+212}" font-family="${SANS}" font-size="${nameFs}" font-weight="700" text-anchor="middle" fill="${col}">${esc(full)}</text>
      <text x="${cxm}" y="${boxY+255}" font-family="${MONO}" font-size="${thirdFs}" text-anchor="middle" fill="#fff" fill-opacity=".6">${esc(third)}</text>`;
    if(i<n-1){const px=x+bw+gap/2, pfs=Math.min(80,gap+20);
      minis+=`<text x="${px}" y="${boxY+boxH/2+30}" font-family="${SANS}" font-size="${pfs}" font-weight="800" text-anchor="middle" fill="${DB.green}">+</text>`;}
  });
  const nameFS=fitFS(name,1080,200);
  let extrasSVG="";
  if(extras){const et="+ "+extras.toUpperCase();
    const efs=Math.min(32,Math.floor(1060/(et.length*0.6)));
    extrasSVG=`<text x="600" y="1000" font-family="${MONO}" font-size="${efs}" letter-spacing="2" text-anchor="middle" fill="${DB.green}" fill-opacity=".85">${esc(et)}</text>`;}
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400">
    <defs><linearGradient id="sg" x1="0" y1="0" x2="1" y2="0">${stops}</linearGradient></defs>
    <text x="600" y="180" font-family="${SANS}" font-size="80" font-weight="800" text-anchor="middle" letter-spacing="6" fill="#fff">HUMAN<tspan fill="${DB.green}">+</tspan></text>
    <text x="600" y="230" font-family="${MONO}" font-size="24" text-anchor="middle" letter-spacing="6" fill="#fff" fill-opacity=".45">STACK SERIES</text>
    <text x="600" y="420" font-family="${SANS}" font-size="${nameFS}" font-weight="800" text-anchor="middle" fill="url(#sg)">${esc(name||"MY STACK")}</text>
    <text x="600" y="500" font-family="${MONO}" font-size="34" letter-spacing="6" text-anchor="middle" fill="#fff" fill-opacity=".75">${esc((sub||"CUSTOM PROTOCOL").toUpperCase())}</text>
    ${minis}
    ${extrasSVG}
    <text x="600" y="1080" font-family="${MONO}" font-size="40" font-weight="700" letter-spacing="8" text-anchor="middle" fill="#fff">${esc(tag||"BUILT DIFFERENT")}</text>
    <text x="600" y="1320" font-family="${MONO}" font-size="26" letter-spacing="4" text-anchor="middle" fill="#fff" fill-opacity=".4">MODIFIED &#183; ENHANCED &#183; OPTIMIZED</text>
  </svg>`;
}

/* current design = single tile if 1 selected (custom), else a stack.
   A loaded preset always renders as a stack tile so its extras/subtitle show. */
function currentDesignSVG(){
  const name=(document.getElementById('stackName')?.value)||"";
  const tag=(document.getElementById('stackTag')?.value)||"";
  // a single blend selected -> show its expanded blend card (KLOW etc.)
  if(selected.length===1){const e=EL[selected[0]];
    if(e.blend) return stackTileSVG(name||e.full, e.sub, e.comps, tag||e.tag, "");
    if(!presetMeta) return heroTileSVG(e);
  }
  if(presetMeta)
    return stackTileSVG(name||presetMeta.name, presetMeta.sub, selected, tag||presetMeta.tag, presetMeta.extras||"");
  return stackTileSVG(name||"MY STACK","CUSTOM PROTOCOL",selected,tag||"BUILT DIFFERENT","");
}

/* ---------- garment mockups ---------- */
function luminance(hex){const n=parseInt(hex.slice(1),16);return(0.299*((n>>16)&255)+0.587*((n>>8)&255)+0.114*(n&255))/255;}
/* Apply the user's garment + accent choices to the artwork itself, so the
   on-screen preview AND the downloaded files (SVG/PNG) all match. */
function recolorArt(artSVG,gColor,aColor){
  // 1) accent swap: brand green -> chosen print accent (skip if accent is default green)
  if(aColor && aColor.toLowerCase()!==DB.green.toLowerCase()){
    artSVG=artSVG.replace(new RegExp(DB.green.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'),"gi"),aColor);
  }
  // 2) ink swap: on a LIGHT garment, white ink -> near-black so the design stays legible
  if(luminance(gColor)>0.6){
    artSVG=artSVG.replace(/#ffffff/gi,"#14141c").replace(/#fff(?![0-9a-f])/gi,"#14141c");
  }
  return artSVG;
}
/* ensure a standalone <svg> has explicit width/height so it rasterizes to PNG */
function sizedSVG(artSVG,w){const h=Math.round(w*1400/1200);
  return artSVG.replace(/^<svg /i,`<svg width="${w}" height="${h}" `);}
function garmentSVG(g,color,artSVG){
  // art is already recolored by the caller (recolorArt); just place it on the garment
  const inner=(x,y,w)=>`<svg x="${x}" y="${y}" width="${w}" height="${Math.round(w*1.1667)}" viewBox="0 0 1200 1400" preserveAspectRatio="xMidYMid meet">${artSVG.replace(/^<svg[^>]*>/,'').replace(/<\/svg>$/,'')}</svg>`;
  const stroke="#000", sw=5;
  const lighter=shade(color,20), darker=shade(color,-26), rib=shade(color,-40);
  // all three share one 1000x1150 coordinate space so they're visually comparable
  if(g==="long"){
    // separate torso + two full tapering sleeves so it clearly reads as long-sleeve
    const torso="M360 250 Q500 326 640 250 L660 250 L700 470 L700 1044 Q500 1090 300 1044 L300 470 L340 250 Z";
    const sleeveR="M636 256 L716 232 L862 300 L900 980 L788 992 L690 478 Q664 366 636 256 Z";
    const sleeveL="M364 256 L284 232 L138 300 L100 980 L212 992 L310 478 Q336 366 364 256 Z";
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1150">
      <path d="${sleeveR}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
      <path d="${sleeveL}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
      <path d="${torso}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
      <path d="M368 256 Q500 340 632 256 Q500 398 368 256 Z" fill="${darker}"/>
      <path d="M787 936 L900 928 L900 982 L788 992 Z" fill="${rib}"/>
      <path d="M100 928 L213 936 L212 992 L100 982 Z" fill="${rib}"/>
      ${inner(330,470,340)}
    </svg>`;
  }
  if(g==="hoodie"){
    const hoodOut="M300 300 Q300 108 500 108 Q700 108 700 300 Q610 206 500 206 Q390 206 300 300 Z";
    const hoodIn="M362 276 Q362 168 500 168 Q638 168 638 276 Q576 220 500 220 Q424 220 362 276 Z";
    const body="M388 250 Q500 332 612 250 L690 235 L862 300 L910 1006 L812 1012 L712 470 L716 1050 Q500 1098 284 1050 L288 470 L188 1012 L90 1006 L138 300 L310 235 Z";
    const pocket="M352 838 L648 838 L666 980 Q500 1014 334 980 Z";
    const hem="M288 1006 Q500 1054 716 1006 L716 1050 Q500 1098 284 1050 Z";
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1150">
      <path d="${hoodOut}" fill="${darker}" stroke="${stroke}" stroke-width="${sw}"/>
      <path d="${hoodIn}" fill="${rib}"/>
      <path d="${body}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
      <path d="${hem}" fill="${darker}"/>
      <path d="M806 950 L905 944 L910 1008 L812 1014 Z" fill="${rib}"/>
      <path d="M95 944 L194 950 L188 1014 L90 1008 Z" fill="${rib}"/>
      <line x1="468" y1="300" x2="470" y2="476" stroke="${rib}" stroke-width="9"/>
      <line x1="532" y1="300" x2="530" y2="476" stroke="${rib}" stroke-width="9"/>
      <circle cx="470" cy="482" r="11" fill="${rib}"/><circle cx="530" cy="482" r="11" fill="${rib}"/>
      <path d="${pocket}" fill="${darker}" opacity=".85"/>
      ${inner(345,510,310)}
    </svg>`;
  }
  // tee: torso + two short cap sleeves with rounded hems (matches long-sleeve build)
  const torso="M360 250 Q500 326 640 250 L660 250 L700 470 L700 1044 Q500 1090 300 1044 L300 470 L340 250 Z";
  const sleeveR="M634 254 L728 230 L856 332 Q812 432 720 446 Q700 360 634 254 Z";
  const sleeveL="M366 254 L272 230 L144 332 Q188 432 280 446 Q300 360 366 254 Z";
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1150">
    <path d="${sleeveR}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
    <path d="${sleeveL}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
    <path d="${torso}" fill="${color}" stroke="${stroke}" stroke-width="${sw}"/>
    <path d="M368 256 Q500 340 632 256 Q500 398 368 256 Z" fill="${darker}"/>
    ${inner(330,470,340)}
  </svg>`;
}
function shade(hex,pct){
  const n=parseInt(hex.slice(1),16);let r=(n>>16)&255,g=(n>>8)&255,b=n&255;
  r=Math.max(0,Math.min(255,r+pct));g=Math.max(0,Math.min(255,g+pct));b=Math.max(0,Math.min(255,b+pct));
  return "#"+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1);
}

/* ---------- rendering pages ---------- */
function renderGrid(){
  const g=document.getElementById('grid');
  g.innerHTML="";
  DB.elements.forEach(e=>{
    const tl=e.fam==="PEP"?(e.name_num||e.count):e.count;
    const unit=e.fam==="PEP"?e.count+"aa":"g/mol";
    const cls=e.fam==="PEP"?"pep":(e.fam==="MOL"?"mol":"hor");
    const d=document.createElement('div');
    d.className="cell "+cls+(selected.includes(e.sym)?" sel":"");
    d.innerHTML=`<span class="chk">&#10003;</span>
      <div class="num">${tl}</div><div class="unit">${unit}</div>
      <div class="sym">${esc(e.sym)}</div><div class="nm">${esc(e.full)}</div>`;
    d.onclick=()=>toggle(e.sym);
    g.appendChild(d);
  });
}
function renderBlends(){
  const g=document.getElementById('blendGrid');if(!g)return;g.innerHTML="";
  (DB.blends||[]).forEach(b=>{
    const d=document.createElement('div');
    d.className="cell blend"+(selected.includes(b.sym)?" sel":"");
    d.innerHTML=`<span class="chk">&#10003;</span>
      <div class="num">${b.comps.length}</div><div class="unit">BLEND</div>
      <div class="sym">${esc(b.sym)}</div><div class="nm">${esc(b.full)}</div>`;
    d.onclick=()=>toggle(b.sym);
    g.appendChild(d);
  });
}
function stackRecipe(item){
  let recipe=item.comps.map(c=>EL[c]?.full||c).join(" + ");
  if(item.extras) recipe+=" + "+item.extras;
  return recipe;
}
function stackCat(item){
  if(item.kind==="blend") return "BLEND";
  const s=(item.sub||"").toLowerCase();
  if(s.includes("hormone")) return "HORMONE";
  if(s.includes("body")) return "BODY";
  if(s.includes("cognitive")) return "COG";
  if(s.includes("mito")) return "MITO";
  if(s.includes("repair")||s.includes("recomp")||s.includes("recovery")) return "REPAIR";
  return "OTHER";
}
function stackItems(){
  const items=[], seen=new Set();
  (DB.blends||[]).forEach(b=>{
    seen.add(b.full.toUpperCase());
    items.push({kind:"blend",key:b.sym,name:b.full,sub:b.sub,comps:b.comps,tag:b.tag,extras:""});
  });
  DB.stacks.forEach(s=>{
    if(seen.has(s.name.toUpperCase())) return;
    items.push({kind:"stack",name:s.name,sub:s.sub,comps:s.comps,tag:s.tag,extras:s.extras});
  });
  return items;
}
function renderPresets(){
  const p=document.getElementById('presets');p.innerHTML="";
  const q=stackQuery.trim().toLowerCase();
  const items=stackItems().filter(item=>{
    const cat=stackCat(item);
    if(stackCategory!=="ALL"&&cat!==stackCategory) return false;
    if(!q) return true;
    const hay=[item.name,item.sub,item.tag,item.extras,stackRecipe(item)].join(" ").toLowerCase();
    return hay.includes(q);
  });
  if(!items.length){p.innerHTML=`<div class="empty">No stacks match that filter.</div>`;return;}
  items.forEach(item=>{
    const d=document.createElement('div');d.className="preset";
    const cat=stackCat(item), recipe=stackRecipe(item);
    d.innerHTML=`<div><div class="pn">${esc(item.name)}</div>${item.tag?`<div class="pt">${esc(item.tag)}</div>`:""}<div class="pc">${esc(item.sub)} &middot; ${esc(recipe)}</div></div>
      <div class="badge ${item.kind==="blend"?"blend":""}">${cat}</div>`;
    d.onclick=()=>{
      if(item.kind==="blend"){
        selected=[item.key];
        presetMeta={name:item.name,tag:item.tag,sub:item.sub,extras:""};
        renderBlends();
      }else{
        selected=[...item.comps];
        presetMeta={name:item.name,tag:item.tag,sub:item.sub,extras:item.extras};
      }
      renderGrid();renderTray();window.scrollTo({top:0,behavior:'smooth'});
    };
    p.appendChild(d);
  });
}
let presetMeta=null;
function toggle(sym){
  const i=selected.indexOf(sym);
  if(i>=0)selected.splice(i,1);else{if(selected.length>=6){alert("Max 6 per stack");return;}selected.push(sym);}
  presetMeta=null;renderGrid();renderBlends();renderTray();
}
function renderTray(){
  const tray=document.getElementById('tray'),chips=document.getElementById('chips');
  chips.innerHTML="";
  selected.forEach(s=>{
    const e=EL[s];const c=document.createElement('div');c.className="chip";
    c.innerHTML=`<b>${esc(e.sym)}</b> <span class="muted">${esc(e.full)}</span><button>&times;</button>`;
    c.querySelector('button').onclick=()=>toggle(s);
    chips.appendChild(c);
  });
  tray.classList.toggle('show',selected.length>0);
  document.getElementById('visualizeBtn').disabled=selected.length===0;
}
function renderGallery(){
  const g=document.getElementById('galleryGrid');g.innerHTML="";
  (DB.blends||[]).forEach(b=>{
    const w=document.createElement('div');w.style.cssText="background:#000;border-radius:10px;overflow:hidden;border:1px solid var(--border);";
    w.innerHTML=stackTileSVG(b.full,b.sub,b.comps,b.tag,"");
    g.appendChild(w);
  });
  DB.stacks.forEach(s=>{
    const w=document.createElement('div');w.style.cssText="background:#000;border-radius:10px;overflow:hidden;border:1px solid var(--border);";
    w.innerHTML=stackTileSVG(s.name,s.sub,s.comps,s.tag,s.extras);
    g.appendChild(w);
  });
  DB.elements.forEach(e=>{
    const w=document.createElement('div');w.style.cssText="background:#000;border-radius:10px;overflow:hidden;border:1px solid var(--border);";
    w.innerHTML=heroTileSVG(e);
    g.appendChild(w);
  });
}

/* ---------- garment page ---------- */
const GARMENT_COLORS=["#0d0d12","#1b1b22","#3a3a44","#6b6b78","#d9d9de","#ffffff","#102a43","#3b0d17","#0f2e1d"];
const ACCENT_COLORS=[DB.green,DB.palette.HOR,"#7C5CFC","#FF5C8A","#38BDF8","#ffffff"];
function buildGarmentPage(){
  // colors
  const gc=document.getElementById('garmentColors');gc.innerHTML="";
  GARMENT_COLORS.forEach(c=>{const s=document.createElement('div');s.className="swatch"+(c===garmentColor?" on":"");s.style.background=c;
    s.onclick=()=>{garmentColor=c;buildGarmentPage();};gc.appendChild(s);});
  const ac=document.getElementById('accentColors');ac.innerHTML="";
  ACCENT_COLORS.forEach(c=>{const s=document.createElement('div');s.className="swatch"+(c===accentColor?" on":"");s.style.background=c;
    s.onclick=()=>{accentColor=c;buildGarmentPage();};ac.appendChild(s);});
  document.querySelectorAll('#garmentSeg button').forEach(b=>b.classList.toggle('on',b.dataset.g===garment));
  // recolor the artwork to match the chosen garment + accent, then use that SAME
  // art for the flat preview, the garment mockup, AND the downloads (so files match)
  currentArt=recolorArt(currentDesignSVG(),garmentColor,accentColor);
  document.getElementById('artWrap').innerHTML=currentArt;
  document.getElementById('garmentWrap').innerHTML=garmentSVG(garment,garmentColor,currentArt);
  document.getElementById('designSub').textContent=selected.map(s=>EL[s].full).join("  +  ");
}
let currentArt="";

/* ---------- navigation ---------- */
function show(id){document.querySelectorAll('.page').forEach(p=>p.classList.remove('active'));document.getElementById(id).classList.add('active');window.scrollTo(0,0);}
document.getElementById('visualizeBtn').onclick=()=>{
  if(presetMeta){document.getElementById('stackName').value=presetMeta.name;document.getElementById('stackTag').value=presetMeta.tag;}
  else if(selected.length>1){document.getElementById('stackName').value="MY STACK";document.getElementById('stackTag').value="BUILT DIFFERENT";}
  buildGarmentPage();show('pageGarment');
};
document.getElementById('clearBtn').onclick=()=>{selected=[];presetMeta=null;renderGrid();renderBlends();renderTray();};
document.getElementById('backBtn').onclick=()=>show('pageBuild');
document.getElementById('backBtn2').onclick=()=>show('pageBuild');
document.getElementById('navGallery').onclick=()=>{renderGallery();show('pageGallery');};
document.querySelectorAll('#garmentSeg button').forEach(b=>b.onclick=()=>{garment=b.dataset.g;buildGarmentPage();});
document.querySelectorAll('#stackFilter button').forEach(b=>b.onclick=()=>{
  stackCategory=b.dataset.cat;
  document.querySelectorAll('#stackFilter button').forEach(x=>x.classList.toggle('on',x===b));
  renderPresets();
});
document.getElementById('stackSearch').addEventListener('input',e=>{stackQuery=e.target.value;renderPresets();});
['stackName','stackTag'].forEach(id=>document.getElementById(id).addEventListener('input',buildGarmentPage));
function fileBase(){
  const nm=(document.getElementById('stackName').value||selected.join("-")||"human-plus").trim().replace(/\s+/g,"_");
  const tone=luminance(garmentColor)>0.6?"light":"dark";
  return `${nm}_${tone}`;
}
// SVG download = the recolored art that matches the current garment + accent
document.getElementById('downloadBtn').onclick=()=>{
  const art=currentArt||recolorArt(currentDesignSVG(),garmentColor,accentColor);
  const blob=new Blob([art],{type:"image/svg+xml"});
  const a=document.createElement('a');a.href=URL.createObjectURL(blob);
  a.download=fileBase()+".svg";a.click();URL.revokeObjectURL(a.href);
};
// PNG download = same recolored art rasterized at print resolution (transparent bg)
function downloadPNG(){
  const art=sizedSVG(currentArt||recolorArt(currentDesignSVG(),garmentColor,accentColor),3600);
  const img=new Image();
  const url=URL.createObjectURL(new Blob([art],{type:"image/svg+xml"}));
  img.onload=()=>{
    const c=document.createElement('canvas');c.width=3600;c.height=4200;
    c.getContext('2d').drawImage(img,0,0,3600,4200);
    URL.revokeObjectURL(url);
    c.toBlob(b=>{const a=document.createElement('a');a.href=URL.createObjectURL(b);
      a.download=fileBase()+".png";a.click();URL.revokeObjectURL(a.href);},"image/png");
  };
  img.onerror=()=>{URL.revokeObjectURL(url);alert("PNG export failed in this browser — use the SVG, it's print-ready.");};
  img.src=url;
}
const pngBtn=document.getElementById('downloadPngBtn');
if(pngBtn) pngBtn.onclick=downloadPNG;
document.getElementById('addCartBtn').onclick=()=>alert("Demo only — this is where checkout would go.\n\nStack: "+selected.join(" + "));

renderGrid();renderBlends();renderPresets();renderTray();
</script>
</body>
</html>"""
