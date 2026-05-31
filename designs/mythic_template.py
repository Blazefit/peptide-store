"""Templates for the MYTHOS series page and the HUMAN+ hub.
The mythic gallery renders the pre-generated card PNGs (one per style) so the
web view is pixel-identical to the print/preview output. /*__DATA__*/ is
replaced with the embedded compound/evolution JSON."""

HOME_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUMAN+ — Choose Your Series</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box;}
  body{background:#08080c;color:#eef2f8;font-family:'Segoe UI',system-ui,sans-serif;min-height:100vh;
    display:flex;flex-direction:column;}
  header{padding:26px 18px 10px;text-align:center;}
  .logo{font-size:2.4rem;font-weight:800;letter-spacing:2px;}
  .logo span{color:#2BE8B0;}
  .tag{font-family:ui-monospace,monospace;font-size:.66rem;letter-spacing:5px;color:#8a8aa2;margin-top:6px;}
  main{flex:1;display:grid;grid-template-columns:1fr;gap:18px;max-width:1100px;margin:0 auto;padding:24px 18px 50px;width:100%;}
  @media(min-width:820px){main{grid-template-columns:1fr 1fr;}}
  .door{position:relative;border-radius:18px;overflow:hidden;cursor:pointer;text-decoration:none;color:inherit;
    min-height:440px;display:flex;flex-direction:column;justify-content:flex-end;border:1px solid #23232f;
    transition:transform .18s,box-shadow .18s,border-color .18s;}
  .door:hover{transform:translateY(-4px);box-shadow:0 18px 50px rgba(0,0,0,.55);}
  .door .bg{position:absolute;inset:0;z-index:0;}
  .door .inner{position:relative;z-index:2;padding:26px;}
  .door h2{font-size:1.9rem;font-weight:800;letter-spacing:1px;margin-bottom:6px;}
  .door p{color:#c8c8d6;font-size:.95rem;max-width:42ch;}
  .door .pill{display:inline-block;margin-top:14px;font-family:ui-monospace,monospace;font-size:.72rem;
    letter-spacing:3px;padding:8px 14px;border-radius:20px;border:1px solid currentColor;}
  .door .scrim{position:absolute;inset:0;z-index:1;background:linear-gradient(180deg,rgba(8,8,12,.15),rgba(8,8,12,.92));}
  /* periodic door */
  .d1{}
  .d1 .bg{background:
    radial-gradient(120% 80% at 20% 10%, rgba(43,232,176,.18), transparent 60%),
    radial-gradient(120% 90% at 90% 30%, rgba(124,92,252,.16), transparent 60%),
    #0d0d12;}
  .d1 .accent{color:#2BE8B0;}
  .d1 .grid-deco{position:absolute;inset:0;z-index:0;opacity:.5;
    background-image:linear-gradient(#1c2b27 1px,transparent 1px),linear-gradient(90deg,#1c2b27 1px,transparent 1px);
    background-size:54px 60px;-webkit-mask-image:radial-gradient(circle at 30% 20%,#000,transparent 75%);
    mask-image:radial-gradient(circle at 30% 20%,#000,transparent 75%);}
  /* mythos door */
  .d2 .bg{background:
    radial-gradient(120% 80% at 80% 12%, rgba(201,162,75,.22), transparent 60%),
    radial-gradient(120% 90% at 10% 40%, rgba(122,90,168,.16), transparent 60%),
    #100c08;}
  .d2 .accent{color:#C9A24B;}
  .d2 h2{font-family:'Cinzel',Georgia,serif;}
  .d2 .runes{position:absolute;inset:0;z-index:0;opacity:.22;
    background:repeating-linear-gradient(45deg,#3a2e18 0 2px,transparent 2px 26px);
    -webkit-mask-image:radial-gradient(circle at 75% 25%,#000,transparent 70%);
    mask-image:radial-gradient(circle at 75% 25%,#000,transparent 70%);}
  .foot{text-align:center;color:#55556a;font-family:ui-monospace,monospace;font-size:.7rem;letter-spacing:3px;padding:0 0 24px;}
  .mini{position:absolute;z-index:1;top:18px;right:18px;display:flex;gap:8px;opacity:.85;}
  .mini i{width:44px;height:52px;border-radius:7px;border:2px solid;display:block;}
</style>
</head>
<body>
<header>
  <div class="logo">HUMAN<span>+</span></div>
  <div class="tag">MODIFIED &middot; ENHANCED &middot; OPTIMIZED</div>
</header>
<main>
  <a class="door d1" href="index.html">
    <div class="bg"></div><div class="grid-deco"></div>
    <div class="mini">
      <i style="border-color:#2BE8B0"></i><i style="border-color:#FFB020"></i><i style="border-color:#7C5CFC"></i>
    </div>
    <div class="scrim"></div>
    <div class="inner">
      <h2>THE PERIODIC TABLE</h2>
      <p>The original science line. Every compound as a clean periodic-element tile —
         peptides, hormones, molecules. Build a custom stack and put it on a shirt.</p>
      <span class="pill accent">ENTER THE LAB &rarr;</span>
    </div>
  </a>
  <a class="door d2" href="mythic.html">
    <div class="bg"></div><div class="runes"></div>
    <div class="scrim"></div>
    <div class="inner">
      <h2>MYTHOS</h2>
      <p>The legend line. Every compound reborn as a mythic figure — Titans, Seraphs,
         Wardens — and every stack as their evolution. Forged in stone and gold.</p>
      <span class="pill accent">ENTER THE FORGE &rarr;</span>
    </div>
  </a>
</main>
<div class="foot">TWO SERIES &middot; ONE PROTOCOL</div>
</body>
</html>"""


MYTHIC_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUMAN+ — MYTHOS</title>
<style>
  :root{--bg:#0b0805;--panel:#15100a;--border:#2c2418;--gold:#C9A24B;--text:#ece4d2;--dim:#998f78;}
  *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
  body{background:
      radial-gradient(120% 60% at 80% -5%, rgba(201,162,75,.10), transparent 60%),
      var(--bg);color:var(--text);font-family:'Segoe UI',system-ui,sans-serif;min-height:100vh;}
  body.arcane{--bg:#0a0c12;--panel:#10131b;--border:#222838;--gold:#52c0ff;--text:#eef2f8;--dim:#9aa3b5;
    background:radial-gradient(120% 60% at 80% -5%, rgba(82,192,255,.12), transparent 60%),#0a0c12;}
  header{position:sticky;top:0;z-index:40;background:rgba(11,8,5,.92);backdrop-filter:blur(10px);
    border-bottom:1px solid var(--border);padding:14px 18px;display:flex;align-items:center;gap:14px;justify-content:space-between;}
  body.arcane header{background:rgba(10,12,18,.92);}
  .brand{font-family:'Cinzel',Georgia,serif;font-size:1.5rem;font-weight:800;letter-spacing:3px;}
  .brand span{color:var(--gold);}
  body.arcane .brand{font-family:'Segoe UI',system-ui,sans-serif;letter-spacing:1px;}
  .nav{display:flex;gap:8px;align-items:center;}
  .btn{border:1px solid var(--border);background:transparent;color:var(--text);border-radius:9px;
    padding:8px 13px;font-size:.8rem;cursor:pointer;font-weight:600;text-decoration:none;display:inline-block;transition:border-color .15s,background .15s;}
  .btn:hover{border-color:var(--gold);}
  .toggle{display:flex;border:1px solid var(--border);border-radius:10px;overflow:hidden;}
  .toggle button{border:none;background:transparent;color:var(--dim);padding:8px 14px;font-weight:700;cursor:pointer;font-size:.8rem;letter-spacing:1px;}
  .toggle button.on{background:var(--gold);color:#1a1306;}
  body.arcane .toggle button.on{color:#03121c;}
  main{max-width:1400px;margin:0 auto;padding:20px 18px 80px;}
  .hero{text-align:center;padding:18px 0 6px;}
  .hero h1{font-family:'Cinzel',Georgia,serif;font-size:2.2rem;letter-spacing:4px;font-weight:800;}
  body.arcane .hero h1{font-family:'Segoe UI',system-ui,sans-serif;letter-spacing:1px;}
  .hero p{color:var(--dim);margin-top:8px;font-size:.92rem;}
  h2.sec{font-family:'Cinzel',Georgia,serif;font-size:1.25rem;letter-spacing:2px;margin:28px 0 4px;border-bottom:1px solid var(--border);padding-bottom:8px;}
  body.arcane h2.sec{font-family:'Segoe UI',system-ui,sans-serif;}
  .muted{color:var(--dim);font-size:.85rem;margin-bottom:10px;}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:16px;margin-top:12px;}
  .card{background:var(--panel);border:1px solid var(--border);border-radius:14px;overflow:hidden;cursor:pointer;
    transition:transform .14s,box-shadow .14s,border-color .14s;}
  .card:hover{transform:translateY(-4px);box-shadow:0 14px 40px rgba(0,0,0,.6);border-color:var(--gold);}
  .card img{width:100%;display:block;aspect-ratio:6/7;object-fit:cover;background:#000;}
  .card .cap{padding:9px 11px;}
  .card .cn{font-family:'Cinzel',Georgia,serif;font-weight:700;font-size:.92rem;letter-spacing:1px;}
  body.arcane .card .cn{font-family:'Segoe UI',system-ui,sans-serif;}
  .card .cr{font-family:ui-monospace,monospace;font-size:.64rem;color:var(--dim);letter-spacing:2px;margin-top:2px;}
  .card .ce{font-family:ui-monospace,monospace;font-size:.62rem;color:var(--gold);margin-top:5px;}
  /* lightbox */
  .lb{position:fixed;inset:0;z-index:90;background:rgba(4,3,2,.92);display:none;align-items:center;justify-content:center;padding:20px;}
  .lb.show{display:flex;}
  .lb-inner{max-width:1100px;width:100%;display:grid;grid-template-columns:1fr;gap:18px;}
  @media(min-width:760px){.lb-inner{grid-template-columns:minmax(0,420px) 1fr;align-items:center;}}
  .lb img{width:100%;border-radius:14px;border:1px solid var(--border);background:#000;}
  .lb .meta{}
  .lb .meta h3{font-family:'Cinzel',Georgia,serif;font-size:2rem;letter-spacing:2px;}
  body.arcane .lb .meta h3{font-family:'Segoe UI',system-ui,sans-serif;}
  .lb .meta .sub{color:var(--gold);font-family:ui-monospace,monospace;letter-spacing:3px;margin:6px 0 16px;}
  .lb .meta .lore{font-style:italic;color:var(--text);font-size:1.05rem;margin-bottom:18px;line-height:1.5;}
  .lb .meta .stat{display:flex;gap:10px;margin:7px 0;font-size:.9rem;}
  .lb .meta .stat b{color:var(--dim);font-family:ui-monospace,monospace;font-size:.72rem;letter-spacing:2px;min-width:120px;text-transform:uppercase;}
  .lb .chain{margin-top:18px;padding-top:14px;border-top:1px solid var(--border);}
  .lb .chain .lab{font-family:ui-monospace,monospace;font-size:.7rem;letter-spacing:3px;color:var(--dim);}
  .lb .chain .to{font-family:'Cinzel',Georgia,serif;font-size:1.3rem;font-weight:700;margin-top:4px;}
  body.arcane .lb .chain .to{font-family:'Segoe UI',system-ui,sans-serif;}
  .lb .x{position:absolute;top:16px;right:20px;font-size:2rem;color:var(--dim);cursor:pointer;background:none;border:none;}
  .dlrow{margin-top:18px;display:flex;gap:10px;flex-wrap:wrap;}
</style>
</head>
<body>
<header>
  <div class="brand">MYTHOS<span>+</span></div>
  <div class="nav">
    <div class="toggle" id="styleToggle">
      <button data-s="mythic" class="on">MYTHIC</button>
      <button data-s="arcane">ARCANE</button>
    </div>
    <a class="btn" href="home.html">&#8962; Hub</a>
    <a class="btn" href="index.html">Periodic &rarr;</a>
  </div>
</header>
<main>
  <div class="hero">
    <h1>THE MYTHOS SERIES</h1>
    <p>Every compound, reborn as a legend. Every stack, its evolution. Toggle
       <b>MYTHIC</b> (forged in stone &amp; gold) or <b>ARCANE</b> (the bright energy-typed cut).</p>
  </div>

  <h2 class="sec">BASE FORMS &mdash; THE COMPOUNDS</h2>
  <p class="muted">Each peptide, hormone &amp; molecule as a single mythic figure. Tap a card for its lore and evolution.</p>
  <div class="grid" id="compGrid"></div>

  <h2 class="sec">EVOLUTIONS &mdash; THE STACKS</h2>
  <p class="muted">When compounds combine, they ascend. Forged from their base forms.</p>
  <div class="grid" id="evoGrid"></div>
</main>

<div class="lb" id="lb">
  <button class="x" id="lbX">&times;</button>
  <div class="lb-inner">
    <img id="lbImg" alt="">
    <div class="meta">
      <h3 id="lbName"></h3>
      <div class="sub" id="lbSub"></div>
      <div class="lore" id="lbLore"></div>
      <div class="stat"><b>Archetype</b> <span id="lbArch"></span></div>
      <div class="stat"><b>Aura</b> <span id="lbAura"></span></div>
      <div class="stat"><b id="lbPlab">Power</b> <span id="lbPval"></span></div>
      <div class="chain" id="lbChainWrap">
        <div class="lab" id="lbChainLab"></div>
        <div class="to" id="lbChainTo"></div>
      </div>
      <div class="dlrow">
        <a class="btn" id="lbDl" download>Download artwork (SVG)</a>
      </div>
    </div>
  </div>
</div>

<script>
const DB = /*__DATA__*/;
let style = "mythic";
const cImg = (sym)=>`mythic_preview/c_${sym}_${style}.png`;
const cSvg = (sym)=>`mythic_svg/c_${sym}_${style}.svg`;
const eImg = (name)=>`mythic_preview/e_${name.replace(/ /g,"_")}_${style}.png`;
const eSvg = (name)=>`mythic_svg/e_${name.replace(/ /g,"_")}_${style}.svg`;

function renderGrids(){
  const cg=document.getElementById('compGrid');cg.innerHTML="";
  DB.compounds.forEach(c=>{
    const d=document.createElement('div');d.className="card";
    d.innerHTML=`<img loading="lazy" src="${cImg(c.sym)}" alt="${c.title}">
      <div class="cap"><div class="cn">${c.title}</div>
      <div class="cr">${c.real.toUpperCase()}</div>
      ${c.evo?`<div class="ce">&#9650; ${c.evo}</div>`:`<div class="ce">BASE FORM</div>`}</div>`;
    d.onclick=()=>openComp(c);cg.appendChild(d);
  });
  const eg=document.getElementById('evoGrid');eg.innerHTML="";
  DB.evolutions.forEach(e=>{
    const d=document.createElement('div');d.className="card";
    d.innerHTML=`<img loading="lazy" src="${eImg(e.name)}" alt="${e.name}">
      <div class="cap"><div class="cn">${e.name}</div>
      <div class="cr">${e.sub.toUpperCase()}</div>
      <div class="ce">TIER ${e.comps.length}</div></div>`;
    d.onclick=()=>openEvo(e);eg.appendChild(d);
  });
}

function openComp(c){
  document.getElementById('lbImg').src=cImg(c.sym);
  document.getElementById('lbName').textContent=c.title;
  document.getElementById('lbSub').textContent=c.real.toUpperCase();
  document.getElementById('lbLore').textContent='"'+c.lore+'"';
  document.getElementById('lbArch').textContent=c.arch.toUpperCase();
  document.getElementById('lbAura').textContent=c.aura.toUpperCase();
  document.getElementById('lbPlab').textContent=c.plabel;
  document.getElementById('lbPval').textContent=c.pval;
  const cw=document.getElementById('lbChainWrap');
  document.getElementById('lbChainLab').textContent=c.evo?"EVOLVES INTO":"BASE FORM";
  document.getElementById('lbChainTo').textContent=c.evo||"—";
  cw.style.display="";
  const dl=document.getElementById('lbDl');dl.href=cSvg(c.sym);dl.download=`mythos_${c.sym}_${style}.svg`;
  document.getElementById('lb').classList.add('show');
}
function openEvo(e){
  document.getElementById('lbImg').src=eImg(e.name);
  document.getElementById('lbName').textContent=e.name;
  document.getElementById('lbSub').textContent=e.sub.toUpperCase();
  document.getElementById('lbLore').textContent='"'+e.lore+'"';
  document.getElementById('lbArch').textContent=e.arch.toUpperCase();
  document.getElementById('lbAura').textContent=e.aura.toUpperCase();
  document.getElementById('lbPlab').textContent="TIER";
  document.getElementById('lbPval').textContent=e.comps.length;
  document.getElementById('lbChainLab').textContent="FORGED FROM";
  document.getElementById('lbChainTo').textContent=e.forged;
  document.getElementById('lbChainWrap').style.display="";
  const dl=document.getElementById('lbDl');dl.href=eSvg(e.name);dl.download=`mythos_${e.name.replace(/ /g,'_')}_${style}.svg`;
  document.getElementById('lb').classList.add('show');
}

document.getElementById('lbX').onclick=()=>document.getElementById('lb').classList.remove('show');
document.getElementById('lb').onclick=(ev)=>{if(ev.target.id==='lb')document.getElementById('lb').classList.remove('show');};
document.querySelectorAll('#styleToggle button').forEach(b=>b.onclick=()=>{
  style=b.dataset.s;
  document.querySelectorAll('#styleToggle button').forEach(x=>x.classList.toggle('on',x===b));
  document.body.classList.toggle('arcane',style==='arcane');
  renderGrids();
  if(document.getElementById('lb').classList.contains('show')){
    // refresh open lightbox image to new style
    const img=document.getElementById('lbImg');
    img.src=img.src.replace(/_(mythic|arcane)\.png/,`_${style}.png`);
    const dl=document.getElementById('lbDl');dl.href=dl.href.replace(/_(mythic|arcane)\.svg/,`_${style}.svg`);
  }
});
renderGrids();
</script>
</body>
</html>"""
