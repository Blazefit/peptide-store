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
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='7' fill='%230d0d12'/%3E%3Ctext x='16' y='24' font-family='Arial,sans-serif' font-size='24' font-weight='800' text-anchor='middle' fill='%232BE8B0'%3E%2B%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&display=swap">
<style>
  :root{
    --bg:#0d0d12;--surface:#16161f;--surface2:#1e1e2c;--border:#2a2a40;
    --text:#e6e6f2;--text2:#9393b0;--green:#2BE8B0;--amber:#FFB020;
    --violet:#7C5CFC;--blue:#38BDF8;--accent:#C9A24B;
    --display:'Space Grotesk',ui-sans-serif,system-ui,-apple-system,sans-serif;
  }
  *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
  html{scroll-behavior:smooth;}
  body{background:
      radial-gradient(110% 70% at 78% -12%, rgba(201,162,75,.14), transparent 58%),
      radial-gradient(90% 60% at 10% 10%, rgba(43,232,176,.08), transparent 60%),
      var(--bg);color:var(--text);font-family:'Segoe UI',system-ui,-apple-system,sans-serif;min-height:100vh;overflow-x:hidden;}
  body.arcane{--accent:var(--blue);
    background:radial-gradient(110% 70% at 78% -12%, rgba(56,189,248,.16), transparent 58%),
      radial-gradient(90% 60% at 10% 10%, rgba(43,232,176,.08), transparent 60%),var(--bg);}
  a{color:inherit;}
  header{position:sticky;top:0;z-index:50;background:rgba(13,13,18,.92);backdrop-filter:blur(10px);
    border-bottom:1px solid var(--border);padding:14px 18px;display:flex;align-items:center;gap:12px;justify-content:space-between;}
  .logo{font-family:var(--display);font-size:1.5rem;font-weight:700;letter-spacing:1px;text-decoration:none;white-space:nowrap;}
  .logo span{color:var(--green);}
  .series-pill{font-family:ui-monospace,monospace;font-size:.62rem;letter-spacing:3px;color:var(--text2);
    border:1px solid var(--border);border-radius:999px;padding:7px 11px;white-space:nowrap;}
  .nav{display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end;min-width:0;}
  .btn{border:1px solid var(--border);background:transparent;color:var(--text);border-radius:9px;
    padding:8px 13px;font-size:.8rem;cursor:pointer;font-weight:600;text-decoration:none;display:inline-block;transition:border-color .15s,background .15s;}
  .btn:hover{border-color:var(--accent);background:rgba(255,255,255,.03);}
  .btn.primary{background:var(--green);color:#08110d;border-color:var(--green);font-weight:800;}
  .toggle{display:flex;border:1px solid var(--border);border-radius:10px;overflow:hidden;min-width:0;}
  .toggle button{border:none;background:transparent;color:var(--text2);padding:8px 14px;font-weight:700;cursor:pointer;font-size:.8rem;letter-spacing:1px;min-width:0;overflow:hidden;}
  .toggle button.on{background:var(--accent);color:#120f08;}
  body.arcane .toggle button.on{color:#03121c;}
  main{max-width:1440px;margin:0 auto;padding:22px 18px 84px;}
  .hero{display:grid;grid-template-columns:1fr;gap:18px;align-items:center;padding:12px 0 18px;}
  .hero>*{min-width:0;}
  @media(min-width:940px){.hero{grid-template-columns:minmax(0,.82fr) minmax(560px,1.18fr);}}
  .eyebrow{font-family:ui-monospace,monospace;font-size:.68rem;letter-spacing:4px;color:var(--green);margin-bottom:10px;}
  .hero h1{font-family:var(--display);font-size:clamp(2.1rem,5vw,5.6rem);line-height:.94;font-weight:700;letter-spacing:0;}
  .hero h1 span{color:var(--accent);}
  .hero h1 .plus{color:var(--green);}
  .hero p{color:var(--text2);margin-top:14px;font-size:1rem;line-height:1.55;max-width:62ch;}
  .quicknav{display:flex;gap:10px;flex-wrap:wrap;margin-top:18px;}
  .quicknav .btn{padding:10px 15px;}
  .studio-panel{margin-top:18px;background:rgba(22,22,31,.72);border:1px solid var(--border);border-radius:14px;padding:14px;
    min-width:0;max-width:100%;}
  .choice-toggle,.garment-toggle,.compound-filter{display:grid;grid-template-columns:1fr 1fr;background:var(--surface2);border:1px solid var(--border);
    border-radius:10px;overflow:hidden;min-width:0;max-width:100%;}
  .compound-filter{grid-template-columns:repeat(4,1fr);margin-top:10px;}
  .choice-toggle button,.garment-toggle button,.compound-filter button{border:none;background:transparent;color:var(--text2);padding:10px 12px;font-weight:800;
    cursor:pointer;font-size:.78rem;letter-spacing:1px;min-width:0;white-space:normal;line-height:1.15;overflow:hidden;}
  .choice-toggle button.on,.garment-toggle button.on,.compound-filter button.on{background:var(--accent);color:#120f08;}
  body.arcane .choice-toggle button.on,body.arcane .garment-toggle button.on,body.arcane .compound-filter button.on{color:#03121c;}
  .path-carousel{display:flex;gap:10px;overflow-x:auto;padding:2px 2px 10px;scroll-snap-type:x proximity;}
  .path-card{min-width:136px;flex:1 1 0;border:1px solid var(--border);border-radius:12px;background:linear-gradient(180deg,rgba(30,30,44,.88),rgba(13,13,18,.76));
    color:var(--text);text-align:left;padding:12px;cursor:pointer;scroll-snap-align:start;transition:border-color .15s,background .15s,transform .15s;}
  .path-card:hover,.path-card.on{border-color:var(--accent);background:linear-gradient(180deg,rgba(201,162,75,.14),rgba(22,22,31,.92));transform:translateY(-2px);}
  body.arcane .path-card:hover,body.arcane .path-card.on{background:linear-gradient(180deg,rgba(56,189,248,.14),rgba(22,22,31,.92));}
  .path-card b{display:block;font-family:var(--display);font-size:1rem;line-height:1.1;}
  .path-card span{display:block;margin-top:5px;color:var(--text2);font-size:.72rem;line-height:1.35;}
  .search-box{width:100%;margin:10px 0 0;background:var(--surface2);border:1px solid var(--border);border-radius:10px;
    color:var(--text);padding:11px 12px;font-size:.9rem;}
  .selected-summary{margin:13px 0 12px;padding:12px;border:1px solid var(--border);border-radius:11px;background:rgba(13,13,18,.58);}
  .selected-summary .k{font-family:ui-monospace,monospace;font-size:.62rem;letter-spacing:3px;color:var(--accent);}
  .selected-summary .n{font-size:1.35rem;font-weight:900;margin-top:3px;}
  .selected-summary .s{font-family:ui-monospace,monospace;font-size:.68rem;letter-spacing:2px;color:var(--text2);margin-top:2px;}
  .selected-summary .c{font-size:.78rem;color:var(--text2);line-height:1.4;margin-top:8px;}
  .garment-toggle{grid-template-columns:repeat(3,1fr);margin-bottom:12px;}
  .print-controls{margin-top:12px;border-top:1px solid var(--border);padding-top:12px;display:grid;gap:10px;}
  .print-mode{display:grid;grid-template-columns:repeat(3,1fr);background:var(--surface2);border:1px solid var(--border);border-radius:10px;overflow:hidden;}
  .print-mode button{border:none;background:transparent;color:var(--text2);padding:9px 8px;font-size:.72rem;font-weight:800;letter-spacing:.7px;cursor:pointer;}
  .print-mode button.on{background:var(--accent);color:#120f08;}
  body.arcane .print-mode button.on{color:#03121c;}
  .print-fields{display:grid;grid-template-columns:1fr;gap:8px;}
  @media(min-width:620px){.print-fields{grid-template-columns:1fr 1fr;}}
  .print-fields input{width:100%;background:var(--surface2);border:1px solid var(--border);border-radius:9px;color:var(--text);padding:10px 11px;}
  .picker-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(104px,1fr));gap:10px;max-height:292px;overflow:auto;padding-right:2px;min-width:0;max-width:100%;}
  .pick-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;overflow:hidden;cursor:pointer;
    transition:border-color .14s,transform .14s,box-shadow .14s;}
  .pick-card:hover{transform:translateY(-2px);border-color:var(--accent);}
  .pick-card.on{border-color:var(--accent);box-shadow:0 0 0 2px color-mix(in srgb,var(--accent) 40%,transparent);}
  .pick-card img{width:100%;display:block;aspect-ratio:6/7;object-fit:cover;background:#000;}
  .pick-card .pname{font-size:.68rem;font-weight:800;line-height:1.15;padding:7px 7px 2px;min-height:38px;}
  .pick-card .psub{font-family:ui-monospace,monospace;font-size:.55rem;color:var(--text2);letter-spacing:1px;padding:0 7px 7px;}
  .studio-actions{margin-top:12px;display:flex;gap:10px;flex-wrap:wrap;}
  .product-stage{display:grid;grid-template-columns:1fr;gap:12px;}
  @media(min-width:640px){.product-stage{grid-template-columns:minmax(400px,1.08fr) minmax(280px,.92fr);}}
  .panel{background:rgba(22,22,31,.82);border:1px solid var(--border);border-radius:14px;overflow:hidden;min-width:0;}
  .tee-panel{min-height:420px;display:grid;align-items:center;justify-items:center;padding:18px;position:relative;}
  .mock-grid{display:grid;grid-template-columns:minmax(118px,.72fr) minmax(170px,1fr);gap:14px;width:100%;align-items:start;}
  .side-label{font-family:ui-monospace,monospace;font-size:.62rem;letter-spacing:3px;color:var(--text2);text-align:center;margin-bottom:8px;}
  .tee{position:relative;width:min(100%,360px);aspect-ratio:.74/1;}
  .mock-grid>div:first-child .tee{width:min(100%,220px);}
  .mock-grid>div:last-child .tee{width:min(100%,310px);}
  .tee-body{position:absolute;left:18%;right:18%;top:13%;bottom:2%;background:linear-gradient(180deg,#171821,#090a0f);
    border:1px solid #303044;border-radius:46% 46% 10% 10%;box-shadow:0 28px 80px rgba(0,0,0,.55);}
  .tee-sleeve{position:absolute;top:19%;width:27%;height:29%;background:#101119;border:1px solid #303044;border-radius:22px;z-index:1;}
  .tee-sleeve.left{left:3%;transform:rotate(18deg);} .tee-sleeve.right{right:3%;transform:rotate(-18deg);}
  .tee-neck{position:absolute;left:39%;right:39%;top:12%;height:11%;background:var(--bg);border:1px solid #303044;
    border-radius:0 0 999px 999px;z-index:4;}
  .tee-print{position:absolute;left:31%;top:31%;width:38%;z-index:5;border:1px solid rgba(255,255,255,.14);
    box-shadow:0 12px 34px rgba(0,0,0,.55);background:#050506;}
  .tee-print img{display:block;width:100%;aspect-ratio:6/7;object-fit:cover;}
  .tee-front-mark{position:absolute;left:27%;right:27%;top:32%;z-index:6;text-align:center;font-family:var(--display);font-weight:700;font-size:clamp(.78rem,2.1vw,1.15rem);letter-spacing:1px;}
  .tee-front-mark span{color:var(--green);}
  .tee-front-series{position:absolute;left:21%;right:21%;top:40%;z-index:6;text-align:center;font-family:ui-monospace,monospace;font-weight:800;font-size:clamp(.42rem,1.1vw,.58rem);letter-spacing:2px;color:var(--accent);}
  .back-print{position:absolute;left:12%;top:24%;width:76%;z-index:5;text-align:center;}
  .back-print.card{left:18%;top:22%;width:64%;}
  .back-print img{display:block;width:100%;max-height:230px;object-fit:contain;margin:0 auto;filter:drop-shadow(0 12px 22px rgba(0,0,0,.6));}
  .back-caption{display:none;margin-top:6px;}
  .back-print.custom .back-caption{display:block;}
  .back-caption b{display:block;font-family:var(--display);font-size:.72rem;line-height:1.05;color:#fff;}
  .back-caption span{display:block;font-family:ui-monospace,monospace;font-size:.42rem;letter-spacing:1.2px;color:var(--accent);margin-top:2px;}
  .hood{display:none;position:absolute;left:30%;right:30%;top:3%;height:22%;border:1px solid #303044;background:#101119;
    border-radius:46% 46% 18% 18%;z-index:0;}
  .tee-pocket{display:none;position:absolute;left:35%;right:35%;bottom:17%;height:12%;border:1px solid #303044;
    background:rgba(255,255,255,.025);border-radius:8px;z-index:6;}
  .garment.hoodie .hood,.garment.hoodie .tee-pocket{display:block;}
  .garment.hoodie .tee-body{top:17%;border-radius:34% 34% 10% 10%;}
  .garment.long .tee-sleeve{top:19%;height:54%;border-radius:24px 24px 16px 16px;}
  .garment.long .tee-sleeve.left{left:0;transform:rotate(12deg);}
  .garment.long .tee-sleeve.right{right:0;transform:rotate(-12deg);}
  .feature-panel{display:grid;grid-template-rows:1fr auto;background:linear-gradient(180deg,rgba(30,30,44,.94),rgba(13,13,18,.94));}
  .feature-panel img{width:100%;height:100%;max-height:520px;object-fit:contain;background:#050506;padding:14px;}
  .feature-meta{border-top:1px solid var(--border);padding:13px 14px;}
  .feature-meta .k{font-family:ui-monospace,monospace;font-size:.62rem;letter-spacing:3px;color:var(--accent);}
  .feature-meta .n{font-size:1.2rem;font-weight:850;margin-top:3px;}
  .jumpbar{position:sticky;top:66px;z-index:30;display:flex;gap:8px;flex-wrap:wrap;background:rgba(13,13,18,.88);
    backdrop-filter:blur(10px);border:1px solid var(--border);border-radius:13px;padding:8px;margin:8px 0 24px;}
  .jumpbar a{font-family:ui-monospace,monospace;font-size:.72rem;letter-spacing:2px;text-decoration:none;color:var(--text2);
    border-radius:9px;padding:8px 10px;}
  .jumpbar a:hover{color:var(--text);background:var(--surface2);}
  .section{margin-top:28px;}
  .sec-head{display:flex;justify-content:space-between;align-items:flex-end;gap:18px;border-bottom:1px solid var(--border);padding-bottom:10px;margin-bottom:12px;}
  h2.sec{font-size:1.12rem;letter-spacing:1px;font-weight:800;}
  .muted{color:var(--text2);font-size:.86rem;line-height:1.45;max-width:72ch;}
  .feature-rail{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:14px;margin-bottom:18px;}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(188px,1fr));gap:16px;margin-top:12px;}
  .result-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:14px;margin-top:12px;}
  .card{background:var(--surface);border:1px solid var(--border);border-radius:12px;overflow:hidden;cursor:pointer;
    transition:transform .14s,box-shadow .14s,border-color .14s;}
  .card.evo{border-color:color-mix(in srgb,var(--accent) 45%,var(--border));}
  .card.feature{background:linear-gradient(180deg,rgba(30,30,44,.95),rgba(18,18,25,.95));}
  .card:hover{transform:translateY(-4px);box-shadow:0 14px 40px rgba(0,0,0,.6);border-color:var(--accent);}
  .card img{width:100%;display:block;aspect-ratio:6/7;object-fit:cover;background:#000;}
  .card .cap{padding:10px 11px 11px;}
  .card .cn{font-weight:800;font-size:.94rem;letter-spacing:1px;}
  .card .cr{font-family:ui-monospace,monospace;font-size:.63rem;color:var(--text2);letter-spacing:2px;margin-top:3px;}
  .card .ce{font-family:ui-monospace,monospace;font-size:.64rem;color:var(--accent);margin-top:7px;font-weight:700;}
  .card .kind{display:inline-block;font-family:ui-monospace,monospace;font-size:.56rem;letter-spacing:2px;color:var(--text2);
    border:1px solid var(--border);border-radius:999px;padding:4px 7px;margin-top:8px;}
  /* lightbox */
  .lb{position:fixed;inset:0;z-index:90;background:rgba(4,4,8,.94);display:none;align-items:flex-start;justify-content:center;
    padding:24px;overflow:auto;}
  .lb.show{display:flex;}
  .lb-inner{max-width:1180px;width:100%;display:grid;grid-template-columns:1fr;gap:18px;margin:auto 0;}
  @media(min-width:820px){.lb-inner{grid-template-columns:minmax(300px,430px) minmax(0,1fr);align-items:start;}}
  .lb-card{width:100%;max-height:72vh;object-fit:contain;border-radius:14px;border:1px solid var(--border);background:#000;}
  .lb .meta{padding:4px 0 24px;}
  .lb .meta h3{font-size:clamp(2rem,5vw,4rem);line-height:.94;letter-spacing:0;font-weight:900;}
  .lb .meta .sub{color:var(--accent);font-family:ui-monospace,monospace;letter-spacing:3px;margin:8px 0 16px;}
  .lb .meta .lore{font-style:italic;color:var(--text);font-size:1.05rem;margin-bottom:18px;line-height:1.5;}
  .lb .meta .stat{display:flex;gap:10px;margin:7px 0;font-size:.9rem;}
  .lb .meta .stat b{color:var(--text2);font-family:ui-monospace,monospace;font-size:.72rem;letter-spacing:2px;min-width:120px;text-transform:uppercase;}
  .lb .chain{margin-top:18px;padding-top:14px;border-top:1px solid var(--border);}
  .lb .chain .lab{font-family:ui-monospace,monospace;font-size:.7rem;letter-spacing:3px;color:var(--text2);}
  .lb .chain .to{font-size:1.3rem;font-weight:800;margin-top:4px;}
  .lb .x{position:fixed;top:14px;right:18px;font-size:2rem;color:var(--text2);cursor:pointer;background:none;border:none;z-index:95;}
  .mock-mini{margin-top:20px;display:grid;grid-template-columns:105px 1fr;gap:13px;align-items:center;background:rgba(22,22,31,.75);
    border:1px solid var(--border);border-radius:12px;padding:12px;max-width:440px;}
  .mock-mini .tee{width:96px;}
  .mock-mini .copy{font-size:.86rem;color:var(--text2);line-height:1.4;}
  .mock-mini .copy b{display:block;color:var(--text);font-size:.95rem;margin-bottom:2px;}
  .dlrow{margin-top:18px;display:flex;gap:10px;flex-wrap:wrap;}
  .site-footer{border-top:1px solid var(--border);margin-top:30px;padding:40px 18px 60px;text-align:center;
    background:radial-gradient(80% 100% at 50% 0%,rgba(201,162,75,.06),transparent 70%);}
  .foot-brand{font-family:var(--display);font-weight:700;font-size:1.5rem;letter-spacing:1px;}
  .foot-brand span{color:var(--green);}
  .foot-nav{display:flex;gap:8px;justify-content:center;flex-wrap:wrap;margin:16px 0 8px;}
  .foot-nav a{color:var(--text2);text-decoration:none;font-size:.85rem;border:1px solid var(--border);
    border-radius:8px;padding:8px 14px;transition:border-color .15s,color .15s;}
  .foot-nav a:hover{color:var(--text);border-color:var(--accent);}
  .foot-nav a.primary{color:var(--green);border-color:var(--green);}
  .foot-fine{color:#55556a;font-family:ui-monospace,monospace;font-size:.68rem;letter-spacing:3px;margin-top:14px;}
  :focus-visible{outline:2px solid var(--accent);outline-offset:3px;border-radius:8px;}
  @media(prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important;scroll-behavior:auto!important;}}
  @media(max-width:760px){
    header{display:grid;grid-template-columns:1fr;align-items:flex-start;gap:8px;padding:14px 18px;}
    main{max-width:100%;padding:18px 14px 76px;}
    .series-pill{order:3;width:100%;text-align:center;}
    .nav{width:100%;display:grid;grid-template-columns:1fr 1fr;gap:8px;}
    .nav .btn{text-align:center;padding:8px 6px;}
    .toggle{grid-column:1 / -1;display:grid;grid-template-columns:1fr 1fr;}
    .toggle button{flex:1;}
    .hero{gap:16px;}
    .hero p{max-width:100%;}
    .quicknav{display:grid;grid-template-columns:1fr 1fr;width:100%;}
    .quicknav .btn{text-align:center;padding:10px 8px;}
    .quicknav .btn:last-child{grid-column:1 / -1;}
    .path-card{min-width:178px;}
    .studio-panel{padding:12px;margin-top:14px;}
    .picker-grid{display:flex;overflow-x:auto;overflow-y:hidden;max-height:none;padding-bottom:4px;}
    .pick-card{min-width:112px;}
    .choice-toggle button,.garment-toggle button,.compound-filter button{padding:10px 7px;font-size:.7rem;letter-spacing:.5px;}
    .tee-panel{min-height:360px;padding:14px;}
    .tee{width:min(100%,210px);}
    .mock-grid{gap:8px;}
    .tee-front-mark{font-size:.78rem;}
    .tee-front-series{font-size:.42rem;}
    .jumpbar{top:116px;}
    .grid{grid-template-columns:repeat(auto-fill,minmax(154px,1fr));gap:12px;}
    .feature-rail{grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;}
    .lb{padding:52px 14px 20px;}
    .lb-card{max-height:58vh;}
    .mock-mini{grid-template-columns:92px 1fr;}
  }
</style>
</head>
<body>
<header>
  <a class="logo" href="home.html">HUMAN<span>+</span></a>
  <div class="series-pill">MYTHOS SERIES</div>
  <div class="nav">
    <div class="toggle" id="styleToggle">
      <button data-s="mythic" class="on">MYTHIC</button>
      <button data-s="arcane">ANIME</button>
    </div>
    <a class="btn" href="home.html">&#8962; Hub</a>
    <a class="btn primary" href="index.html">Periodic table</a>
  </div>
</header>
<main>
  <section class="hero">
    <div>
      <div class="eyebrow">MYTHOS SERIES</div>
      <h1>HUMAN<span class="plus">+</span> <span>APPAREL</span></h1>
      <p>Start with the compound, the protocol stack, or the artwork itself. Each path keeps the peptide chemistry visible while showing the MYTHOS form on apparel.</p>
      <div class="studio-panel" id="studio">
        <div class="path-carousel" id="designMode" aria-label="Choose design path">
          <button class="path-card on" data-mode="compound"><b>Choose by compound</b><span>Pick BPC-157, GHK-Cu, testosterone, NAD+ and see every matching form.</span></button>
          <button class="path-card" data-mode="stack"><b>Choose by stack</b><span>Popular protocols first: GLOW, KLOW, WOLVERINE, HOLY TRINITY, OVERHAUL.</span></button>
          <button class="path-card" data-mode="design"><b>Choose by design</b><span>Browse every MYTHOS card by the visual you want on the shirt.</span></button>
        </div>
        <input class="search-box" id="pickerSearch" type="search" placeholder="Search compounds, stacks, or designs">
        <div class="compound-filter" id="compoundFilter">
          <button data-fam="PEP" class="on">PEPTIDES</button>
          <button data-fam="HOR">HORMONES</button>
          <button data-fam="MOL">MOLECULES</button>
          <button data-fam="ALL">ALL</button>
        </div>
        <div class="selected-summary">
          <div class="k" id="selectedKind"></div>
          <div class="n" id="selectedName"></div>
          <div class="s" id="selectedSub"></div>
          <div class="c" id="selectedChain"></div>
        </div>
        <div class="garment-toggle" id="garmentToggle">
          <button data-g="tee" class="on">TEE</button>
          <button data-g="hoodie">HOODIE</button>
          <button data-g="long">LONG</button>
        </div>
        <div class="print-controls">
          <div class="print-mode" id="printMode">
            <button data-print="card" class="on">FULL CARD</button>
            <button data-print="art">IMAGE ONLY</button>
            <button data-print="custom">CUSTOM TEXT</button>
          </div>
          <div class="print-fields">
            <input id="frontBrand" value="HUMAN+" maxlength="18" aria-label="Front brand text">
            <input id="frontSeries" value="MYTHOS SERIES" maxlength="24" aria-label="Front series text">
            <input id="backTitle" maxlength="24" aria-label="Back title text">
            <input id="backLine" maxlength="34" aria-label="Back subtitle text">
          </div>
        </div>
        <div class="picker-grid" id="pickerGrid"></div>
        <div class="studio-actions">
          <button class="btn" id="viewDetails">View details</button>
          <button class="btn" id="downloadCurrent">Download design</button>
        </div>
      </div>
    </div>
    <div class="product-stage">
      <div class="panel tee-panel">
        <div class="mock-grid">
          <div>
            <div class="side-label">FRONT</div>
            <div class="tee garment" id="frontGarment" aria-label="Front garment preview">
              <div class="hood"></div>
              <div class="tee-sleeve left"></div><div class="tee-sleeve right"></div>
              <div class="tee-body"></div><div class="tee-neck"></div>
              <div class="tee-pocket"></div>
              <div class="tee-front-mark" id="frontBrandPreview">HUMAN<span>+</span></div>
              <div class="tee-front-series" id="frontSeriesPreview">MYTHOS SERIES</div>
            </div>
          </div>
          <div>
            <div class="side-label">BACK</div>
            <div class="tee garment" id="backGarment" aria-label="Back garment preview">
              <div class="hood"></div>
              <div class="tee-sleeve left"></div><div class="tee-sleeve right"></div>
              <div class="tee-body"></div><div class="tee-neck"></div>
              <div class="tee-pocket"></div>
              <div class="back-print card" id="backPrint"><img id="shirtPrint" alt=""><div class="back-caption"><b id="backTitlePreview"></b><span id="backLinePreview"></span></div></div>
            </div>
          </div>
        </div>
      </div>
      <div class="panel feature-panel">
        <img id="featureCard" alt="">
        <div class="feature-meta">
          <div class="k" id="featureKind">STACK EVOLUTION</div>
          <div class="n" id="featureName"></div>
          <div class="muted" id="featureSub"></div>
        </div>
      </div>
    </div>
  </section>

  <nav class="jumpbar">
    <a href="#matches">MATCHING DESIGNS</a>
    <a href="#featured">FEATURED EVOLUTIONS</a>
    <a href="#evolutions">ALL STACKS</a>
    <a href="#bases">BASE COMPOUNDS</a>
  </nav>

  <section class="section" id="matches">
    <div class="sec-head">
      <div>
        <h2 class="sec" id="resultTitle">Matching Designs</h2>
        <p class="muted" id="resultCopy">Pick a compound to see the base form and every stack that contains it.</p>
      </div>
    </div>
    <div class="result-grid" id="resultGrid"></div>
  </section>

  <section class="section" id="featured">
    <div class="sec-head">
      <div>
        <h2 class="sec">Featured Stack Evolutions</h2>
        <p class="muted">The larger forged forms are surfaced first so the line reads as apparel, not just a card archive.</p>
      </div>
    </div>
    <div class="feature-rail" id="featureRail"></div>
  </section>

  <section class="section" id="evolutions">
    <div class="sec-head">
      <div>
        <h2 class="sec">All Stack Evolutions</h2>
        <p class="muted">When compounds combine, they ascend. These are the bigger forged forms that anchor the MYTHOS series.</p>
      </div>
    </div>
    <div class="grid" id="evoGrid"></div>
  </section>

  <section class="section" id="bases">
    <div class="sec-head">
      <div>
        <h2 class="sec">Base Compound Forms</h2>
        <p class="muted">Each peptide, hormone and molecule as a single HUMAN+ character card with its stack evolution called out.</p>
      </div>
    </div>
    <div class="grid" id="compGrid"></div>
  </section>
</main>

<div class="lb" id="lb">
  <button class="x" id="lbX">&times;</button>
  <div class="lb-inner">
    <img class="lb-card" id="lbImg" alt="">
    <div class="meta">
      <h3 id="lbName"></h3>
      <div class="sub" id="lbSub"></div>
      <div class="lore" id="lbLore"></div>
      <div class="stat"><b>Aura</b> <span id="lbAura"></span></div>
      <div class="stat"><b id="lbPlab">Power</b> <span id="lbPval"></span></div>
      <div class="chain" id="lbChainWrap">
        <div class="lab" id="lbChainLab"></div>
        <div class="to" id="lbChainTo"></div>
      </div>
      <div class="mock-mini">
        <div class="tee garment" id="lbGarment" aria-label="Garment preview">
          <div class="hood"></div>
          <div class="tee-sleeve left"></div><div class="tee-sleeve right"></div>
          <div class="tee-body"></div><div class="tee-neck"></div>
          <div class="tee-pocket"></div>
          <div class="tee-print"><img id="lbPrint" alt=""></div>
        </div>
        <div class="copy"><b>Product view</b><span id="lbProductCopy">Card artwork placed as a front chest print.</span></div>
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
let activeItem = null;
let mode = "compound";
let compoundFilter = "PEP";
let garment = "tee";
let query = "";
let printMode = "card";
const featuredNames = ["GLOW","KLOW","WOLVERINE","THE HOLY TRINITY","THE OVERHAUL","PRIME"];
const peptideFirst = ["Bp","Tb","Gk","Kp","Gh","Cj","Ip","Sg","Tz","Re"];
const cImg = (sym)=>`mythic_preview_clean/c_${sym}_${style}.png`;
const cSvg = (sym)=>`mythic_svg_clean/c_${sym}_${style}.svg`;
const eImg = (name)=>`mythic_preview_clean/e_${name.replace(/ /g,"_")}_${style}.png`;
const eSvg = (name)=>`mythic_svg_clean/e_${name.replace(/ /g,"_")}_${style}.svg`;
const artStyle = ()=>style==='arcane'?'anime':'mythic';
const artImg = (kind,item)=>kind==='evo'
  ? `mythic_art/art_${item.name.replace(/ /g,"_")}_${artStyle()}.png`
  : `mythic_art/art_${item.sym}_${artStyle()}.png`;
const byEvoName = new Map(DB.evolutions.map(e=>[e.name,e]));
const byCompoundSym = new Map(DB.compounds.map(c=>[c.sym,c]));

function esc(s){return (s+"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");}
function currentForm(){return style==='arcane'?'ANIME FORM':'MYTHIC FORM';}
function featuredEvolutions(){
  const picked = featuredNames.map(n=>byEvoName.get(n)).filter(Boolean);
  const seen = new Set(picked.map(e=>e.name));
  return picked.concat(DB.evolutions.filter(e=>!seen.has(e.name))).slice(0,6);
}

function orderedEvolutions(){
  const picked = featuredNames.map(n=>byEvoName.get(n)).filter(Boolean);
  const seen = new Set(picked.map(e=>e.name));
  return picked.concat(DB.evolutions.filter(e=>!seen.has(e.name)));
}

function orderedCompounds(){
  const filtered = DB.compounds.filter(c=>compoundFilter==='ALL' || c.fam===compoundFilter);
  if(compoundFilter!=='PEP') return filtered;
  const priority = peptideFirst.map(sym=>byCompoundSym.get(sym)).filter(c=>c && filtered.includes(c));
  const seen = new Set(priority.map(c=>c.sym));
  return priority.concat(filtered.filter(c=>!seen.has(c.sym)));
}
function orderedAllCompounds(){
  const priority = peptideFirst.map(sym=>byCompoundSym.get(sym)).filter(Boolean);
  const seen = new Set(priority.map(c=>c.sym));
  return priority.concat(DB.compounds.filter(c=>!seen.has(c.sym)));
}

function itemKey(kind,item){return kind==='evo'?item.name:item.sym;}
function imgFor(kind,item){return kind==='evo'?eImg(item.name):cImg(item.sym);}
function svgFor(kind,item){return kind==='evo'?eSvg(item.name):cSvg(item.sym);}
function familyLabel(fam){return fam==='PEP'?'PEPTIDE':(fam==='HOR'?'HORMONE':'MOLECULE');}
function mythicLabel(item){return item.title.replace(/^THE /,'');}
function titleFor(kind,item){return kind==='evo'?item.name:item.real;}
function subFor(kind,item){
  return kind==='evo'
    ? `${item.sub.toUpperCase()} · TIER ${item.comps.length}`
    : `${familyLabel(item.fam)} · ${item.title}`;
}
function kindFor(kind,item){return kind==='evo'?'STACK EVOLUTION':`${familyLabel(item.fam)} COMPOUND`;}
function chainFor(kind,item){return kind==='evo'?`FORGED FROM ${item.forged}`:(item.evo?`RELATED STACK ${item.evo}`:'BASE COMPOUND');}
function evoSyms(item){return item.compoundSyms || item.comps || [];}
function searchText(kind,item){
  if(kind==='evo') return [item.name,item.sub,item.forged,item.tag,item.extras,evoSyms(item).join(" ")].join(" ").toLowerCase();
  return [item.sym,item.real,item.title,item.fam,item.evo,item.lore].join(" ").toLowerCase();
}
function matchesQuery(kind,item){
  const q=query.trim().toLowerCase();
  return !q || searchText(kind,item).includes(q);
}
function compoundStackCount(sym){
  return orderedEvolutions().filter(e=>evoSyms(e).includes(sym)).length;
}
function allDesignEntries(){
  return orderedEvolutions().map(item=>({kind:'evo',item}))
    .concat(orderedAllCompounds().map(item=>({kind:'compound',item})));
}

function setGarment(next){
  garment = next;
  document.querySelectorAll('#garmentToggle button').forEach(b=>b.classList.toggle('on',b.dataset.g===garment));
  ['frontGarment','backGarment','lbGarment'].forEach(id=>{
    const el=document.getElementById(id);
    if(el) el.className=`tee garment ${garment}`;
  });
}

function renderBrandText(){
  const brand=document.getElementById('frontBrand').value || 'HUMAN+';
  const series=document.getElementById('frontSeries').value || 'MYTHOS SERIES';
  document.getElementById('frontBrandPreview').innerHTML=esc(brand).replace(/\+/g,'<span>+</span>');
  document.getElementById('frontSeriesPreview').textContent=series;
  document.getElementById('backTitlePreview').textContent=document.getElementById('backTitle').value || '';
  document.getElementById('backLinePreview').textContent=document.getElementById('backLine').value || '';
}

function updateBackInputs(kind,item){
  const title=document.getElementById('backTitle');
  const line=document.getElementById('backLine');
  if(!title.dataset.dirty) title.value=titleFor(kind,item);
  if(!line.dataset.dirty) line.value=kind==='evo'?item.forged:item.real;
}

function updateProductMockup(){
  if(!activeItem) return;
  const {kind,item}=activeItem;
  const back=document.getElementById('backPrint');
  const img=document.getElementById('shirtPrint');
  back.className=`back-print ${printMode==='card'?'card':printMode}`;
  img.src=printMode==='card'?imgFor(kind,item):artImg(kind,item);
  img.onerror=()=>{img.onerror=null;img.src=imgFor(kind,item);};
  renderBrandText();
}

function setSelected(kind,item){
  if(!item) return;
  activeItem = {kind,item};
  const png = imgFor(kind,item);
  document.getElementById('featureCard').src = png;
  document.getElementById('featureKind').textContent = kindFor(kind,item);
  document.getElementById('featureName').textContent = titleFor(kind,item);
  document.getElementById('featureSub').textContent = subFor(kind,item);
  document.getElementById('selectedKind').textContent = `${currentForm()} · ${kindFor(kind,item)}`;
  document.getElementById('selectedName').textContent = titleFor(kind,item);
  document.getElementById('selectedSub').textContent = subFor(kind,item);
  document.getElementById('selectedChain').textContent = chainFor(kind,item);
  updateBackInputs(kind,item);
  updateProductMockup();
  document.querySelectorAll('#pickerGrid .pick-card').forEach(card=>{
    card.classList.toggle('on',card.dataset.kind===kind && card.dataset.key===itemKey(kind,item));
  });
  renderResults();
}

function defaultItemForMode(){
  if(mode==='stack') return byEvoName.get('GLOW') || byEvoName.get('KLOW') || byEvoName.get('WOLVERINE') || DB.evolutions[0];
  if(mode==='design') return byEvoName.get('GLOW') || orderedEvolutions()[0] || DB.compounds[0];
  if(compoundFilter==='PEP' && byCompoundSym.get('Bp')) return byCompoundSym.get('Bp');
  return DB.compounds.find(c=>compoundFilter==='ALL' || c.fam===compoundFilter) || DB.compounds[0];
}

function pickerEntries(){
  if(mode==='stack') return orderedEvolutions().filter(e=>matchesQuery('evo',e)).map(item=>({kind:'evo',item}));
  if(mode==='design') return allDesignEntries().filter(({kind,item})=>matchesQuery(kind,item));
  return orderedCompounds().filter(c=>matchesQuery('compound',c)).map(item=>({kind:'compound',item}));
}

function renderPicker(){
  const pg=document.getElementById('pickerGrid');
  pg.innerHTML="";
  document.getElementById('compoundFilter').style.display = mode==='compound' ? 'grid' : 'none';
  const entries=pickerEntries();
  entries.forEach(({kind,item})=>{
    const d=document.createElement('div');
    d.className='pick-card';
    d.dataset.kind=kind;
    d.dataset.key=itemKey(kind,item);
    d.innerHTML=`<div class="pname">${titleFor(kind,item)}</div>
      <div class="psub">${kind==='evo'?`TIER ${item.comps.length} · ${item.forged}`:`${item.sym} · ${mythicLabel(item)}`}</div>
      <img loading="lazy" src="${imgFor(kind,item)}" alt="${titleFor(kind,item)}">`;
    d.onclick=()=>setSelected(kind,item);
    pg.appendChild(d);
  });
  const activeStillShown=activeItem && entries.some(({kind,item})=>kind===activeItem.kind && itemKey(kind,item)===itemKey(activeItem.kind,activeItem.item));
  if(entries.length && !activeStillShown){
    setSelected(entries[0].kind, entries[0].item);
  } else if(activeItem) {
    setSelected(activeItem.kind,activeItem.item);
  } else {
    renderResults();
  }
}

function makeCard(kind,item,featured=false){
  const d=document.createElement('div');
  d.className=`card ${kind==='evo'?'evo':''} ${featured?'feature':''}`;
  if(kind==='evo'){
    d.innerHTML=`<img loading="lazy" src="${eImg(item.name)}" alt="${item.name}">
      <div class="cap"><div class="cn">${item.name}</div>
      <div class="cr">${item.sub.toUpperCase()}</div>
      <div class="ce">${item.forged}</div>
      <div class="kind">STACK EVOLUTION</div></div>`;
    d.onclick=()=>openItem('evo',item);
  } else {
    d.innerHTML=`<img loading="lazy" src="${cImg(item.sym)}" alt="${item.real}">
      <div class="cap"><div class="cn">${item.real}</div>
      <div class="cr">${familyLabel(item.fam)} · ${item.title.toUpperCase()}</div>
      <div class="ce">${compoundStackCount(item.sym)} MATCHING STACKS</div>
      <div class="kind">COMPOUND FORM</div></div>`;
    d.onclick=()=>openItem('compound',item);
  }
  return d;
}

function resultEntries(){
  if(mode==='compound' && activeItem && activeItem.kind==='compound'){
    const sym=activeItem.item.sym;
    return [{kind:'compound',item:activeItem.item}]
      .concat(orderedEvolutions().filter(e=>evoSyms(e).includes(sym)).map(item=>({kind:'evo',item})));
  }
  if(mode==='stack') return orderedEvolutions().filter(e=>matchesQuery('evo',e)).map(item=>({kind:'evo',item}));
  return allDesignEntries().filter(({kind,item})=>matchesQuery(kind,item));
}

function renderResults(){
  const grid=document.getElementById('resultGrid');
  if(!grid) return;
  const entries=resultEntries();
  grid.innerHTML="";
  const title=document.getElementById('resultTitle');
  const copy=document.getElementById('resultCopy');
  if(mode==='compound' && activeItem && activeItem.kind==='compound'){
    title.textContent=`${activeItem.item.real} Designs`;
    copy.textContent=`Base ${activeItem.item.sym} card plus every stack evolution containing ${activeItem.item.real}.`;
  } else if(mode==='stack'){
    title.textContent='Stack Designs';
    copy.textContent='Popular stacks are pinned first, with GLOW, KLOW, WOLVERINE, HOLY TRINITY and OVERHAUL at the top.';
  } else {
    title.textContent='Design Browser';
    copy.textContent='All MYTHOS cards in one visual browse mode.';
  }
  entries.forEach(({kind,item})=>grid.appendChild(makeCard(kind,item)));
}

function renderGrids(){
  const fg=document.getElementById('featureRail');fg.innerHTML="";
  featuredEvolutions().forEach(e=>fg.appendChild(makeCard('evo',e,true)));
  const eg=document.getElementById('evoGrid');eg.innerHTML="";
  orderedEvolutions().forEach(e=>eg.appendChild(makeCard('evo',e)));
  const cg=document.getElementById('compGrid');cg.innerHTML="";
  DB.compounds.forEach(c=>cg.appendChild(makeCard('compound',c)));
  renderPicker();
  setGarment(garment);
  updateProductMockup();
}

function applyLightbox(){
  if(!activeItem) return;
  const {kind,item}=activeItem;
  const isEvo=kind==='evo';
  const png=imgFor(kind,item);
  const svg=svgFor(kind,item);
  document.getElementById('lbImg').src=png;
  document.getElementById('lbPrint').src=png;
  document.getElementById('lbName').textContent=titleFor(kind,item);
  document.getElementById('lbSub').textContent=isEvo?item.sub.toUpperCase():`${familyLabel(item.fam)} · ${item.title.toUpperCase()}`;
  document.getElementById('lbLore').textContent='"'+item.lore+'"';
  document.getElementById('lbAura').textContent=item.aura.toUpperCase();
  document.getElementById('lbPlab').textContent=isEvo?"TIER":item.plabel;
  document.getElementById('lbPval').textContent=isEvo?item.comps.length:item.pval;
  document.getElementById('lbChainLab').textContent=isEvo?"FORGED FROM":(item.evo?"RELATED STACK":"BASE COMPOUND");
  document.getElementById('lbChainTo').textContent=isEvo?item.forged:(item.evo||"-");
  document.getElementById('lbProductCopy').textContent=isEvo?"Back graphic preview with HUMAN+ / MYTHOS on the front.":"Compound figure preview with HUMAN+ / MYTHOS on the front.";
  const dl=document.getElementById('lbDl');
  dl.href=svg;
  dl.download=isEvo?`mythos_${item.name.replace(/ /g,'_')}_${style}.svg`:`mythos_${item.sym}_${style}.svg`;
}

function openItem(kind,item){
  mode=kind==='evo'?'stack':'compound';
  if(kind==='compound') compoundFilter=item.fam || 'PEP';
  document.querySelectorAll('#designMode button').forEach(b=>b.classList.toggle('on',b.dataset.mode===mode));
  document.querySelectorAll('#compoundFilter button').forEach(b=>b.classList.toggle('on',b.dataset.fam===compoundFilter));
  activeItem={kind,item};
  renderPicker();
  setSelected(kind,item);
  applyLightbox();
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
    applyLightbox();
  }
});
document.querySelectorAll('#designMode button').forEach(b=>b.onclick=()=>{
  mode=b.dataset.mode;
  document.querySelectorAll('#designMode button').forEach(x=>x.classList.toggle('on',x===b));
  activeItem=null;
  renderPicker();
});
document.querySelectorAll('#compoundFilter button').forEach(b=>b.onclick=()=>{
  compoundFilter=b.dataset.fam;
  document.querySelectorAll('#compoundFilter button').forEach(x=>x.classList.toggle('on',x===b));
  mode='compound';
  document.querySelectorAll('#designMode button').forEach(x=>x.classList.toggle('on',x.dataset.mode==='compound'));
  activeItem=null;
  renderPicker();
});
document.querySelectorAll('#garmentToggle button').forEach(b=>b.onclick=()=>setGarment(b.dataset.g));
document.querySelectorAll('#printMode button').forEach(b=>b.onclick=()=>{
  printMode=b.dataset.print;
  document.querySelectorAll('#printMode button').forEach(x=>x.classList.toggle('on',x===b));
  updateProductMockup();
});
document.getElementById('pickerSearch').addEventListener('input',e=>{query=e.target.value;activeItem=null;renderPicker();});
['frontBrand','frontSeries','backTitle','backLine'].forEach(id=>{
  document.getElementById(id).addEventListener('input',e=>{e.target.dataset.dirty='1';renderBrandText();});
});
document.getElementById('viewDetails').onclick=()=>{if(activeItem) openItem(activeItem.kind,activeItem.item);};
function customDesignSvg(kind,item){
  const img=artImg(kind,item);
  const title=esc(document.getElementById('backTitle').value || titleFor(kind,item));
  const line=esc(document.getElementById('backLine').value || (kind==='evo'?item.forged:item.real));
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1400">
    <rect width="1200" height="1400" fill="#0d0d12"/>
    <image href="${img}" x="120" y="90" width="960" height="1000" preserveAspectRatio="xMidYMid meet"/>
    <text x="600" y="1180" font-family="Arial,sans-serif" font-size="86" font-weight="800" text-anchor="middle" fill="#fff">${title}</text>
    <text x="600" y="1245" font-family="Courier New,monospace" font-size="34" font-weight="700" letter-spacing="5" text-anchor="middle" fill="#C9A24B">${line.toUpperCase()}</text>
    <text x="600" y="1330" font-family="Courier New,monospace" font-size="27" letter-spacing="6" text-anchor="middle" fill="#777">HUMAN+ · MYTHOS SERIES</text>
  </svg>`;
}
function downloadHref(href,name){
  const a=document.createElement('a');a.href=href;a.download=name;document.body.appendChild(a);a.click();a.remove();
}
document.getElementById('downloadCurrent').onclick=()=>{
  if(!activeItem) return;
  const {kind,item}=activeItem;
  const stem=kind==='evo'?item.name.replace(/ /g,'_'):item.sym;
  if(printMode==='card') return downloadHref(svgFor(kind,item),`mythos_${stem}_${style}.svg`);
  if(printMode==='art') return downloadHref(artImg(kind,item),`mythos_${stem}_${artStyle()}_art.png`);
  const blob=new Blob([customDesignSvg(kind,item)],{type:'image/svg+xml'});
  downloadHref(URL.createObjectURL(blob),`mythos_${stem}_${artStyle()}_custom.svg`);
};
renderGrids();
</script>
<footer class="site-footer">
  <div class="foot-brand">HUMAN<span>+</span></div>
  <nav class="foot-nav" aria-label="Footer">
    <a class="primary" href="index.html">&larr; Periodic table</a>
    <a href="home.html">Switch series</a>
  </nav>
  <p class="foot-fine">MYTHOS &middot; THE LEGEND LINE &middot; CONCEPT APPAREL</p>
</footer>
</body>
</html>"""
