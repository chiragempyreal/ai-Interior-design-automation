import React, { useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';

const HowItWorks: React.FC = () => {
  const observerRef = useRef<IntersectionObserver | null>(null);

  useEffect(() => {
    observerRef.current = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('.parallax-wrap, .step-number, .feature-card, .scroll-reveal');
    elements.forEach((el) => observerRef.current?.observe(el));

    return () => observerRef.current?.disconnect();
  }, []);

  return (
    <div className="bg-background font-display text-charcoal overflow-x-hidden">
      <header className="fixed top-0 w-full z-50 glass-nav border-b border-charcoal/5 px-6 md:px-12 py-5 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-3 group cursor-pointer flex-1">
          <div className="relative w-7 h-7">
            <div className="absolute inset-0 border-[1.5px] border-primary rounded-full"></div>
            <div className="absolute inset-0 border-[1.5px] border-accent-warm rounded-full translate-x-2"></div>
          </div>
          <h1 className="font-geist text-[11px] font-bold tracking-[0.25em] uppercase ml-3">DesignQuote AI</h1>
        </Link>
        <nav className="hidden md:flex gap-12 items-center justify-center flex-1">
          <Link to="/" className="nav-link">Home</Link>
          <Link to="/how-it-works" className="nav-link text-primary">How It Works</Link>
          <Link to="/pricing" className="nav-link">Pricing</Link>
          <Link to="/examples" className="nav-link">Examples</Link>
        </nav>
        <div className="flex items-center gap-8 justify-end flex-1">
          <div className="hidden md:flex items-center gap-8">
            <Link to="/login" className="nav-link">Login</Link>
          </div>
          <button className="bg-primary text-white font-geist text-[10px] font-bold tracking-[0.2em] uppercase px-7 py-3 rounded-full hover:bg-charcoal transition-all shadow-sm">
            Sign Up
          </button>
        </div>
      </header>

      <main>
        <section className="relative pt-24 pb-20 flex flex-col items-center text-center px-6 overflow-hidden">
          <div className="absolute inset-0 -z-10 opacity-[0.03] pointer-events-none architectural-pattern"></div>
          <div className="max-w-4xl mx-auto space-y-6 relative z-10">
            <span className="text-accent-warm font-geist text-[11px] font-bold tracking-[0.4em] uppercase">Our Process.</span>
            <h1 className="text-6xl md:text-8xl font-serif italic text-charcoal leading-tight">From Blueprint <br/>to Reality</h1>
            <p className="text-lg md:text-xl text-charcoal/60 max-w-2xl mx-auto font-inter font-light leading-relaxed mt-6 mb-6">
              Discover how our proprietary AI engine translates architectural constraints into photorealistic luxury environments in minutes, not days.
            </p>
          </div>
          <div className="mt-8 w-px h-24 bg-gradient-to-b from-primary/40 to-transparent"></div>
        </section>

        <section className="max-w-7xl mx-auto px-6 space-y-24 md:space-y-32 pb-20">
          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="relative order-2 lg:order-1 parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDg5rQnK30-iqx1dJDPAo2_46Dp3NCCqBajuFNHm-GfHjBVMR5HhKnn1xlp59i98qXeMFHgvN3-SuWg4F7_QFEgh4pql2gimoN-GptYG1k4RLO25DIe1oo0ETUjh7MYE9EafjB9vpYaNkoFDDRZGjDrby2Ox0lFqgvXD-ZKd-sDRNo5HTDe96Lay0lkPdTmtAqqj5W1KdjjH0DHYNubkiefQhH6oDOspEUOEnbFEwjCvMMakv4KCv4YUu8v5614dwYsIdCp36OmDjM')" }}></div>
              </div>
              <div className="absolute -bottom-10 -left-10 w-40 h-40 border border-accent-warm/20 rounded-full -z-10"></div>
            </div>
            <div className="space-y-4 order-1 lg:order-2">
              <span className="step-number text-7xl font-geist font-black">01</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">Upload Architectural Shell</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Start with your raw data. Upload floor plans, hand-drawn sketches, or photos of site shells. Our system recognizes structural boundaries, window placements, and load-bearing elements with 99.8% accuracy.
              </p>
              <ul className="space-y-4 pt-2">
                <li className="flex items-center gap-3 font-inter text-sm text-charcoal/60">
                  <span className="material-symbols-outlined text-primary">check_circle</span>
                  Supports PDF, JPEG, and CAD files
                </li>
                <li className="flex items-center gap-3 font-inter text-sm text-charcoal/60">
                  <span className="material-symbols-outlined text-primary">check_circle</span>
                  Automatic scale detection
                </li>
              </ul>
            </div>
          </div>

          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="space-y-4">
              <span className="step-number text-7xl font-geist font-black">02</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">AI Spatial Analysis</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Our proprietary engine performs a volumetric analysis of the space, calculating natural light flow and ergonomic movement paths. It identifies the "soul" of the building before a single pixel of furniture is placed.
              </p>
              <div className="p-6 bg-white rounded-2xl border border-charcoal/5 shadow-sm">
                <p className="text-xs font-geist font-bold uppercase tracking-widest text-accent-warm mb-2">Technical Insight</p>
                <p className="text-sm font-inter italic text-charcoal/60 leading-relaxed">"Light-path tracing ensures every render respects the actual solar orientation of your project site."</p>
              </div>
            </div>
            <div className="relative parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuB-WR-3ndRWx8K93h-UF7yGK98mybxoVvKx_28VBGoIiawVL32ztLKWp6EzG2qbHQbChp-hfFpPt2iCeP7NfJNl46IvST3yLvWEbVSRLYosLl4K-8QdWCvFgtsb5hBM3SndcUW_swarE1zcF2o0ZJmJl1NrD4spClSW8vglD7V999uQ2Slt4ngjB2t1Stp7l-5tbF5HRsGkyG8Z8Bst8xjyf3b83GLbZT9ra2bP1ZVRLI2oD5fhM1LTBLt05fINcFRN1CGPkS73oSw')" }}></div>
              </div>
              <div className="absolute -top-10 -right-10 w-48 h-48 bg-primary/5 rounded-full -z-10"></div>
            </div>
          </div>

          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="relative order-2 lg:order-1 parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuCz7N7uM5E8O5lZRc8e1ib67-BVzvI8rXu3syp5q7M2eagKERZP2M-8dV2St4-PD1CamAmyAp4wtwsOAO9Os1caApJwoKwmOhsoXjKo8x1MdrEb8RRmKhj68SVcMKUb-NSE7A00RSrR4fJjs3ZqExAMazml1gMawZE2LwxwZt3KpM31Sy07cGScOQmgcY8Bz5tEE7JhoxM0A_kPjrnlob56Nxf2jUJ6G-uaX1GU9Y2sptLJmKuYuE1IsxVi8bR1O25qxwUv5xy2Sg0')" }}></div>
              </div>
            </div>
            <div className="space-y-4 order-1 lg:order-2">
              <span className="step-number text-7xl font-geist font-black">03</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">Curated Style Selection</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Browse our library of 40+ high-end design languages—from Japandi and Mid-Century Modern to Industrial Luxe. Our AI doesn't just apply a filter; it selects materials and furniture that fit the chosen aesthetic.
              </p>
              <div className="flex flex-wrap gap-2 pt-2">
                <span className="px-4 py-1.5 bg-charcoal text-white text-[10px] font-geist font-bold uppercase tracking-widest rounded-full">Minimalist</span>
                <span className="px-4 py-1.5 border border-charcoal/10 text-charcoal text-[10px] font-geist font-bold uppercase tracking-widest rounded-full">Classic</span>
                <span className="px-4 py-1.5 border border-charcoal/10 text-charcoal text-[10px] font-geist font-bold uppercase tracking-widest rounded-full">Art Deco</span>
              </div>
            </div>
          </div>

          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="space-y-4">
              <span className="step-number text-7xl font-geist font-black">04</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">Interactive Refinement</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Change textures, swap furniture pieces, or adjust lighting in real-time. Use our natural language interface: "Make the floor oak wood" or "Add more ambient lighting to the ceiling."
              </p>
              <div className="flex items-center gap-4 text-primary font-geist text-[11px] font-bold uppercase tracking-widest pt-2">
                <span className="material-symbols-outlined">auto_fix_high</span>
                Instant Real-time Refresh
              </div>
            </div>
            <div className="relative parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDIvzA_DkuINJkMVsD1BPZSCSM2ftiLe4cFj0t4Sb4R5FIJq7cCwZ0FF0a5d3rFFEyzAl1_PFmDf7ufBYJ_qwYPVxZ1VIBnFQ8CXsa_FGXBxVT5fQhjpqRmDxnVjtGbfTrDDk044UzPuZhNUjT1pN4hlkOvOqQRW9WandSwtRJ5CdvYmL8qcUHa8hh2moH2KtEvxddE0MdgRBa9GE8zxMhmkIYm32RXkIMbRKTu29cc2AMIH3Ygp-Zv2_CAWknig-TvItyj4QVZwq0')" }}></div>
              </div>
            </div>
          </div>

          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="relative order-2 lg:order-1 parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDBgZaf-_rsoVTQJ7HUZBLMgJ_sgQUjhZ-MYcO9lzjQEBfpVFAKKwORh9aS-w6_yAhsiG2mvec7vPCKREILUjTOyT-CeE8H_4FVu9vmoHSEx75JVu3hIH55fedPLPtf61IIGr-ISqk05zKFlSrx9StXPJFl9rhwexdhLIWZt8Tl9MY3xpyKvy_BXDQG6C0wT-6ikceEV06rd80KAS3j6hpTKM9fk9R_x8w42m0NcYq_-ogFKfGFJLPlfyMlucVDL4E2sAX12VnoPHA')" }}></div>
              </div>
            </div>
            <div className="space-y-4 order-1 lg:order-2">
              <span className="step-number text-7xl font-geist font-black">05</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">Instant Quote Generation</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Say goodbye to weeks of manual estimation. DesignQuote AI cross-references your design with regional material databases to provide an itemized Bill of Quantities (BOQ) instantly.
              </p>
              <div className="bg-primary/5 p-8 rounded-3xl border border-primary/10">
                <div className="flex justify-between items-center mb-4">
                  <span className="text-[10px] font-geist font-bold uppercase tracking-widest text-charcoal/50">Estimated ROI</span>
                  <span className="text-xl font-bold text-primary">+32%</span>
                </div>
                <div className="w-full h-1.5 bg-charcoal/5 rounded-full overflow-hidden">
                  <div className="w-[85%] h-full bg-primary"></div>
                </div>
                <p className="mt-4 text-xs font-inter text-charcoal/50">Calculated based on average designer time-savings per project.</p>
              </div>
            </div>
          </div>

          <div className="grid lg:grid-cols-2 gap-24 items-center">
            <div className="space-y-4">
              <span className="step-number text-7xl font-geist font-black">06</span>
              <h2 className="text-4xl font-geist font-bold text-charcoal tracking-tight mb-4">One-Click Professional Export</h2>
              <p className="text-lg text-charcoal/70 font-inter leading-relaxed mt-6 mb-6">
                Download ultra-high-definition 8K renders, VR-ready panoramas, and the full procurement list. Your presentation is ready for the client meeting within minutes of the final click.
              </p>
              <button className="bg-charcoal text-white font-geist text-[11px] font-bold uppercase tracking-widest px-8 py-4 rounded-full flex items-center gap-3 mt-4">
                View Sample Report
                <span className="material-symbols-outlined text-sm">download</span>
              </button>
            </div>
            <div className="relative parallax-wrap">
              <div className="parallax-inner">
                <div className="square-rounded-heavy aspect-square bg-cover bg-center overflow-hidden shadow-2xl animate-breathing" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuB-WR-3ndRWx8K93h-UF7yGK98mybxoVvKx_28VBGoIiawVL32ztLKWp6EzG2qbHQbChp-hfFpPt2iCeP7NfJNl46IvST3yLvWEbVSRLYosLl4K-8QdWCvFgtsb5hBM3SndcUW_swarE1zcF2o0ZJmJl1NrD4spClSW8vglD7V999uQ2Slt4ngjB2t1Stp7l-5tbF5HRsGkyG8Z8Bst8xjyf3b83GLbZT9ra2bP1ZVRLI2oD5fhM1LTBLt05fINcFRN1CGPkS73oSw')" }}></div>
              </div>
            </div>
          </div>
        </section>

        <section className="bg-charcoal/5 pt-24 pb-20 px-6">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-8 space-y-2">
              <h3 className="text-primary font-geist text-[11px] font-bold uppercase tracking-[0.4em]">The Engine</h3>
              <h2 className="text-4xl font-bold text-charcoal">Advanced Interior Intelligence</h2>
            </div>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              <div className="p-10 bg-white rounded-[2.5rem] shadow-sm hover:shadow-xl transition-all border border-charcoal/5">
                <span className="material-symbols-outlined text-4xl text-accent-warm mb-6">memory</span>
                <h4 className="text-lg font-geist font-bold mb-4">Proprietary AI Engine</h4>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">Custom-trained neural network specifically for architectural and interior design logic.</p>
              </div>
              <div className="p-10 bg-white rounded-[2.5rem] shadow-sm hover:shadow-xl transition-all border border-charcoal/5">
                <span className="material-symbols-outlined text-4xl text-accent-warm mb-6">speed</span>
                <h4 className="text-lg font-geist font-bold mb-4">Real-time Rendering</h4>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">NVIDIA-powered cloud farms deliver instant visual feedback without hardware lag.</p>
              </div>
              <div className="p-10 bg-white rounded-[2.5rem] shadow-sm hover:shadow-xl transition-all border border-charcoal/5">
                <span className="material-symbols-outlined text-4xl text-accent-warm mb-6">database</span>
                <h4 className="text-lg font-geist font-bold mb-4">Material Database</h4>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">Live connection to over 500+ global furniture and finish suppliers for accurate pricing.</p>
              </div>
              <div className="p-10 bg-white rounded-[2.5rem] shadow-sm hover:shadow-xl transition-all border border-charcoal/5">
                <span className="material-symbols-outlined text-4xl text-accent-warm mb-6">security</span>
                <h4 className="text-lg font-geist font-bold mb-4">Encrypted Assets</h4>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">Enterprise-grade security for your project data and proprietary blueprints.</p>
              </div>
            </div>
          </div>
        </section>

        <section className="pt-24 pb-20 px-6 bg-white">
          <div className="max-w-3xl mx-auto">
            <h2 className="text-[11px] font-geist font-bold uppercase tracking-[0.4em] text-primary text-center mb-8">Process FAQ</h2>
            <div className="space-y-8">
              <details className="group border-b border-charcoal/5 pb-4">
                <summary className="list-none cursor-pointer flex justify-between items-center text-xl font-geist font-bold text-charcoal mb-4">
                  How accurate are the material costs?
                  <span className="material-symbols-outlined text-charcoal/30 group-open:rotate-45 transition-transform">add</span>
                </summary>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">Costs are indexed weekly against regional market averages. While we recommend a 5-10% contingency, our baseline quotes typically fall within 95% of final procurement invoices.</p>
              </details>
              <details className="group border-b border-charcoal/5 pb-4">
                <summary className="list-none cursor-pointer flex justify-between items-center text-xl font-geist font-bold text-charcoal mb-4">
                  Can I upload Revit or AutoCAD files?
                  <span className="material-symbols-outlined text-charcoal/30 group-open:rotate-45 transition-transform">add</span>
                </summary>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">Yes, we support .DWG, .RVT, and .IFC formats on our Professional and Enterprise plans. The AI will preserve your original layer structure.</p>
              </details>
              <details className="group border-b border-charcoal/5 pb-4">
                <summary className="list-none cursor-pointer flex justify-between items-center text-xl font-geist font-bold text-charcoal mb-4">
                  Who owns the copyright of AI designs?
                  <span className="material-symbols-outlined text-charcoal/30 group-open:rotate-45 transition-transform">add</span>
                </summary>
                <p className="text-sm font-inter text-charcoal/60 leading-relaxed mt-6 mb-6">You do. Any visual assets generated through your account belong entirely to your firm for commercial use.</p>
              </details>
            </div>
          </div>
        </section>

        <section className="px-6 md:px-12 pt-24 pb-20">
          <div className="max-w-7xl mx-auto bg-primary rounded-[4rem] p-12 md:p-16 relative overflow-hidden flex flex-col items-center text-center">
            <div className="absolute inset-0 opacity-10 architectural-pattern"></div>
            <div className="relative z-10 space-y-6">
              <h2 className="text-3xl md:text-6xl font-geist font-black text-white uppercase leading-tight mb-8">Ready to start your <br/> first project?</h2>
              <p className="text-white/80 max-w-xl mx-auto text-lg font-inter font-light mt-6 mb-6">Experience the future of architectural visualization today with a 7-day free trial.</p>
              <div className="flex flex-wrap justify-center gap-6 pt-4">
                <button className="bg-white text-primary font-geist text-[11px] font-bold uppercase tracking-widest py-5 px-10 rounded-full hover:shadow-2xl hover:-translate-y-1 transition-all">Start Free Trial</button>
                <button className="bg-charcoal text-white font-geist text-[11px] font-bold uppercase tracking-widest py-5 px-10 rounded-full hover:shadow-2xl hover:-translate-y-1 transition-all">Book a Demo</button>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer className="bg-cream-base text-charcoal px-6 md:px-12 py-16 border-t border-charcoal/5">
        <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-5 gap-16">
          <div className="col-span-2">
            <div className="flex items-center gap-3 mb-6">
              <div className="relative w-7 h-7">
                <div className="absolute inset-0 border-[1.5px] border-primary rounded-full"></div>
                <div className="absolute inset-0 border-[1.5px] border-accent-warm rounded-full translate-x-2"></div>
              </div>
              <h2 className="font-geist text-[11px] font-bold tracking-[0.25em] uppercase ml-3">DesignQuote AI</h2>
            </div>
            <p className="text-text-secondary text-sm leading-relaxed max-w-sm">
              The premium standard for architectural estimation and interior design quoting. Empowering studios with AI-driven precision.
            </p>
          </div>
          <div>
            <h4 className="font-geist text-charcoal mb-6 text-[11px] font-bold tracking-[0.15em] uppercase">PLATFORM</h4>
            <ul className="space-y-4">
              <li><Link to="/how-it-works" className="text-text-secondary hover:text-primary transition-colors text-sm">How it works</Link></li>
              <li><Link to="/pricing" className="text-text-secondary hover:text-primary transition-colors text-sm">Pricing</Link></li>
              <li><Link to="/examples" className="text-text-secondary hover:text-primary transition-colors text-sm">Examples</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-geist text-charcoal mb-6 text-[11px] font-bold tracking-[0.15em] uppercase">RESOURCES</h4>
            <ul className="space-y-4">
              <li><a className="text-text-secondary hover:text-primary transition-colors text-sm" href="#">Documentation</a></li>
              <li><a className="text-text-secondary hover:text-primary transition-colors text-sm" href="#">API Reference</a></li>
              <li><a className="text-text-secondary hover:text-primary transition-colors text-sm" href="#">Support Center</a></li>
            </ul>
          </div>
          <div>
            <h4 className="font-geist text-charcoal mb-6 text-[11px] font-bold tracking-[0.15em] uppercase">LEGAL</h4>
            <ul className="space-y-4">
              <li><a className="text-text-secondary hover:text-primary transition-colors text-sm" href="#">Privacy Policy</a></li>
              <li><a className="text-text-secondary hover:text-primary transition-colors text-sm" href="#">Terms of Use</a></li>
            </ul>
          </div>
        </div>
        <div className="flex flex-col md:flex-row justify-between items-center pt-10 mt-16 border-t border-charcoal/5">
          <p className="font-geist text-[10px] text-charcoal/40 font-bold tracking-[0.15em]">
            © 2024 DESIGNQUOTE AI. ALL RIGHTS RESERVED.
          </p>
          <div className="flex gap-10 mt-6 md:mt-0">
            <a className="text-charcoal/40 hover:text-primary transition-colors" href="#"><span className="material-symbols-outlined text-[20px]">public</span></a>
            <a className="text-charcoal/40 hover:text-primary transition-colors" href="#"><span className="material-symbols-outlined text-[20px]">share</span></a>
            <a className="text-charcoal/40 hover:text-primary transition-colors" href="#"><span className="material-symbols-outlined text-[20px]">mail</span></a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default HowItWorks;
