import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import Header from '../components/Header';

const Home: React.FC = () => {
  const [sliderPosition, setSliderPosition] = useState(50);
  const [isDragging, setIsDragging] = useState(false);
  const comparisonRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('.reveal-on-scroll');
    elements.forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !comparisonRef.current) return;

      const rect = comparisonRef.current.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const percentage = Math.max(0, Math.min(100, (x / rect.width) * 100));
      setSliderPosition(percentage);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging]);


  return (
    <div className="bg-background-light font-display text-charcoal overflow-x-hidden min-h-screen">
      <Header />

      <main className="pt-6">
        {/* Hero Section */}
        <section className="relative min-h-[85vh] flex items-center px-6 md:px-12 py-12 md:py-16 overflow-hidden">
          <div className="absolute top-1/4 -right-20 w-96 h-96 border border-accent-warm/10 rounded-full animate-float -z-10"></div>
          <div className="absolute bottom-1/4 -left-20 w-64 h-64 bg-primary/5 rounded-full animate-float-reverse -z-10"></div>
          <div className="absolute inset-0 opacity-[0.05] pointer-events-none animate-parallax-dots" style={{ backgroundImage: 'radial-gradient(#2b3e3a 1px, transparent 1px)', backgroundSize: '40px 40px' }}></div>

          <div className="max-w-7xl mx-auto w-full grid lg:grid-cols-12 gap-12 items-center relative z-10">
            <div className="lg:col-span-5 space-y-6">
              <div className="space-y-3">
                <span className="inline-block animate-reveal-up text-accent-warm font-geist text-[11px] font-bold tracking-[0.4em] uppercase">Architecture Visualizer</span>
                <h1 className="text-5xl md:text-6xl font-black leading-[1.05] uppercase tracking-tight text-charcoal">
                  <span className="block animate-reveal-up opacity-0" style={{ animationDelay: '100ms', animationFillMode: 'forwards' }}>See your dream</span>
                  <span className="block animate-reveal-up opacity-0" style={{ animationDelay: '200ms', animationFillMode: 'forwards' }}>interior.</span>
                  <span className="block animate-reveal-up opacity-0 font-serif italic capitalize font-light text-accent-warm mt-1" style={{ animationDelay: '350ms', animationFillMode: 'forwards' }}>before it's built.</span>
                </h1>
              </div>
              <p className="animate-reveal-up opacity-0 text-base md:text-lg text-charcoal/70 max-w-md leading-relaxed font-light" style={{ animationDelay: '500ms', animationFillMode: 'forwards' }}>
                Transform raw blueprints and structural shells into curated luxury living spaces using our proprietary architectural AI engine.
              </p>
              <div className="flex flex-wrap gap-4 pt-2 animate-reveal-up opacity-0" style={{ animationDelay: '650ms', animationFillMode: 'forwards' }}>
                <Link to="/wizard" className="pill-button bg-primary text-white font-geist text-[11px] font-bold tracking-widest uppercase py-4 px-8 rounded-full shadow-xl hover:bg-charcoal">
                  Get Free Preview
                  <span className="material-symbols-outlined text-sm">arrow_forward</span>
                </Link>
                {/* <button className="pill-button bg-white/50 backdrop-blur-sm border border-charcoal/10 text-charcoal font-geist text-[11px] font-bold tracking-widest uppercase py-4 px-8 rounded-full hover:bg-white">
                  Watch Demo
                  <span className="material-symbols-outlined text-sm">play_circle</span>
                </button> */}
              </div>
            </div>

            <div className="lg:col-span-7 relative">
              <div
                ref={comparisonRef}
                className="animate-breathe aspect-[16/10] md:aspect-[4/3] rounded-[1.5rem] overflow-hidden shadow-2xl relative border-[8px] border-white/30 transition-transform duration-700"
              >
                <div className="absolute inset-0 bg-cover bg-center" style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDg5rQnK30-iqx1dJDPAo2_46Dp3NCCqBajuFNHm-GfHjBVMR5HhKnn1xlp59i98qXeMFHgvN3-SuWg4F7_QFEgh4pql2gimoN-GptYG1k4RLO25DIe1oo0ETUjh7MYE9EafjB9vpYaNkoFDDRZGjDrby2Ox0lFqgvXD-ZKd-sDRNo5HTDe96Lay0lkPdTmtAqqj5W1KdjjH0DHYNubkiefQhH6oDOspEUOEnbFEwjCvMMakv4KCv4YUu8v5614dwYsIdCp36OmDjM')" }}></div>
                <div
                  className="absolute inset-0 overflow-hidden border-r-2 border-white/80 z-10 transition-all duration-300 ease-out"
                  style={{ width: `${sliderPosition}%` }}
                >
                  <div
                    className="absolute top-0 left-0 h-full bg-cover bg-center grayscale contrast-125 brightness-75"
                    style={{
                      backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuB-WR-3ndRWx8K93h-UF7yGK98mybxoVvKx_28VBGoIiawVL32ztLKWp6EzG2qbHQbChp-hfFpPt2iCeP7NfJNl46IvST3yLvWEbVSRLYosLl4K-8QdWCvFgtsb5hBM3SndcUW_swarE1zcF2o0ZJmJl1NrD4spClSW8vglD7V999uQ2Slt4ngjB2t1Stp7l-5tbF5HRsGkyG8Z8Bst8xjyf3b83GLbZT9ra2bP1ZVRLI2oD5fhM1LTBLt05fINcFRN1CGPkS73oSw')",
                      width: comparisonRef.current ? `${comparisonRef.current.offsetWidth}px` : '100%'
                    }}
                  ></div>
                </div>
                <div className="absolute top-6 left-6 z-30 bg-black/40 backdrop-blur-md px-3 py-1.5 rounded-full flex items-center">
                  <span className="text-white font-geist text-[9px] font-bold uppercase tracking-widest">Original Structure</span>
                </div>
                <div
                  className="absolute top-0 bottom-0 w-[2px] bg-white/50 z-20 transition-all duration-300 ease-out"
                  style={{ left: `${sliderPosition}%` }}
                >
                  <div
                    className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-30 w-12 h-12 bg-white rounded-full shadow-2xl flex items-center justify-center cursor-ew-resize hover:scale-110 transition-transform duration-300"
                    onMouseDown={(e) => {
                      e.preventDefault();
                      setIsDragging(true);
                    }}
                  >
                    <div className="flex items-center gap-1">
                      <span className="material-symbols-outlined text-charcoal text-lg">chevron_left</span>
                      <span className="material-symbols-outlined text-charcoal text-lg">chevron_right</span>
                    </div>
                  </div>
                </div>
                <div className="absolute top-6 right-6 z-20 bg-primary/90 backdrop-blur px-3 py-1.5 rounded-full flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-accent-warm animate-pulse"></span>
                  <span className="text-white font-geist text-[9px] font-bold uppercase tracking-widest">AI Visualization</span>
                </div>
                <div
                  className="absolute bottom-6 z-20 bg-white/90 backdrop-blur-md px-4 py-2 rounded-xl shadow-lg border border-charcoal/5 transition-all duration-300"
                  style={{ left: `${sliderPosition}%`, transform: 'translateX(1rem)' }}
                >
                  <p className="text-[9px] font-bold text-charcoal/40 uppercase tracking-tighter mb-0.5">Estimated Budget</p>
                  <p className="text-base font-black text-charcoal">₹12,40,000</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* How It Works Section */}
        <section className="px-6 md:px-12 py-16 md:py-24 bg-charcoal text-cream-base rounded-[3rem] mx-4 relative overflow-hidden" id="how-it-works">
          <div className="absolute top-0 right-0 w-1/2 h-full bg-white/5 skew-x-12 origin-top-right -z-10"></div>
          <div className="max-w-7xl mx-auto">
            <div className="mb-12 space-y-2 reveal-on-scroll">
              <h3 className="text-accent-warm font-geist text-[11px] font-bold tracking-[0.4em] uppercase">The Workflow</h3>
              <h2 className="text-3xl md:text-4xl font-bold">From Blueprint to Reality.</h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                { icon: 'cloud_upload', step: '01', title: 'Upload', desc: 'Snap photos of your current raw space. Our AI analyzes architectural boundaries instantly.' },
                { icon: 'palette', step: '02', title: 'Choose', desc: 'Select from curated luxury styles—from Japandi Minimalism to Industrial Loft aesthetics.' },
                { icon: 'auto_awesome', step: '03', title: 'Preview', desc: 'Witness photorealistic AI renders that look like high-end professional photography.' },
                { icon: 'request_quote', step: '04', title: 'Quote', desc: 'Get an instant, itemized budget estimation based on regional material and labor costs.' },
                { icon: 'verified', step: '05', title: 'Approve', desc: 'Fine-tune details with a professional interior designer directly within our platform.' },
                { icon: 'rocket_launch', step: '06', title: 'Start', desc: 'Export blueprint assets and material lists to begin your physical transformation.' }
              ].map((item, index) => (
                <div key={index} className="feature-card reveal-on-scroll group p-8 rounded-2xl border border-white/5 bg-white/5">
                  <div className="mb-6 flex items-center justify-between">
                    <span className="material-symbols-outlined text-3xl group-hover:text-accent-warm group-hover:scale-110 transition-all duration-300">{item.icon}</span>
                    <span className="text-4xl font-thin text-white/5 italic group-hover:text-accent-warm/10 transition-colors">{item.step}</span>
                  </div>
                  <h4 className="text-lg font-bold mb-2">{item.title}</h4>
                  <p className="text-white/50 text-sm leading-relaxed font-light">{item.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Examples Section */}
        <section className="px-6 md:px-12 py-16 md:py-24" id="examples">
          <div className="max-w-7xl mx-auto">
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-10 reveal-on-scroll">
              <div>
                <h3 className="text-primary font-geist text-[11px] font-bold tracking-[0.4em] uppercase mb-2">Curated Portfolio</h3>
                <h2 className="text-3xl md:text-4xl font-bold">Luxury Transformations</h2>
              </div>
              <Link to="/examples" className="pill-button font-geist text-[11px] font-bold uppercase tracking-widest border-b border-charcoal/20 pb-1 hover:border-primary flex items-center gap-2">
                View Full Gallery
                <span className="material-symbols-outlined text-sm">trending_flat</span>
              </Link>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {[
                {
                  img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCz7N7uM5E8O5lZRc8e1ib67-BVzvI8rXu3syp5q7M2eagKERZP2M-8dV2St4-PD1CamAmyAp4wtwsOAO9Os1caApJwoKwmOhsoXjKo8x1MdrEb8RRmKhj68SVcMKUb-NSE7A00RSrR4fJjs3ZqExAMazml1gMawZE2LwxwZt3KpM31Sy07cGScOQmgcY8Bz5tEE7JhoxM0A_kPjrnlob56Nxf2jUJ6G-uaX1GU9Y2sptLJmKuYuE1IsxVi8bR1O25qxwUv5xy2Sg0',
                  title: 'Modern Living Room',
                  meta: 'Minimalist • ₹8,00,000',
                  alt: 'Modern minimalist living room'
                },
                {
                  img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDIvzA_DkuINJkMVsD1BPZSCSM2ftiLe4cFj0t4Sb4R5FIJq7cCwZ0FF0a5d3rFFEyzAl1_PFmDf7ufBYJ_qwYPVxZ1VIBnFQ8CXsa_FGXBxVT5fQhjpqRmDxnVjtGbfTrDDk044UzPuZhNUjT1pN4hlkOvOqQRW9WandSwtRJ5CdvYmL8qcUHa8hh2moH2KtEvxddE0MdgRBa9GE8zxMhmkIYm32RXkIMbRKTu29cc2AMIH3Ygp-Zv2_CAWknig-TvItyj4QVZwq0',
                  title: 'Scandi Kitchen',
                  meta: 'Contemporary • ₹12,00,000',
                  alt: 'Contemporary kitchen'
                },
                {
                  img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDBgZaf-_rsoVTQJ7HUZBLMgJ_sgQUjhZ-MYcO9lzjQEBfpVFAKKwORh9aS-w6_yAhsiG2mvec7vPCKREILUjTOyT-CeE8H_4FVu9vmoHSEx75JVu3hIH55fedPLPtf61IIGr-ISqk05zKFlSrx9StXPJFl9rhwexdhLIWZt8Tl9MY3xpyKvy_BXDQG6C0wT-6ikceEV06rd80KAS3j6hpTKM9fk9R_x8w42m0NcYq_-ogFKfGFJLPlfyMlucVDL4E2sAX12VnoPHA',
                  title: 'Luxury Master Suite',
                  meta: 'Art Deco • ₹15,00,000',
                  alt: 'Luxury master suite'
                }
              ].map((item, index) => (
                <div key={index} className="group cursor-pointer reveal-on-scroll">
                  <div className="relative aspect-[3/4] rounded-2xl overflow-hidden mb-4">
                    <img alt={item.alt} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110" src={item.img} />
                    <div className="absolute inset-0 bg-gradient-to-t from-charcoal/90 via-charcoal/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 flex items-end p-6">
                      <span className="pill-button bg-white text-charcoal font-geist text-[9px] font-bold px-5 py-2.5 rounded-full uppercase tracking-widest translate-y-3 group-hover:translate-y-0 transition-transform duration-500">
                        Explore Design
                        <span className="material-symbols-outlined text-xs">arrow_forward</span>
                      </span>
                    </div>
                  </div>
                  <div className="flex justify-between items-start px-1">
                    <div>
                      <h5 className="text-lg font-bold group-hover:text-primary transition-colors">{item.title}</h5>
                      <p className="text-[10px] text-charcoal/50 uppercase tracking-[0.2em] font-bold mt-0.5">{item.meta}</p>
                    </div>
                    <span className="material-symbols-outlined text-accent-warm group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform">north_east</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="px-6 md:px-12 py-16">
          <div className="bg-primary rounded-[3rem] p-12 md:p-24 text-center relative overflow-hidden reveal-on-scroll">
            <div className="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none" style={{ backgroundImage: 'radial-gradient(#fff 1px, transparent 1px)', backgroundSize: '30px 30px' }}></div>
            <h2 className="text-3xl md:text-5xl font-bold text-white mb-6">Ready to redesign your space?</h2>
            <p className="text-white/70 max-w-2xl mx-auto mb-10 text-lg font-light">Join thousands of homeowners who have transformed their interiors with InteriAI's intelligent automation.</p>
            <Link to="/wizard" className="pill-button bg-white text-primary font-geist text-[11px] font-bold tracking-widest uppercase py-4 px-10 rounded-full shadow-xl hover:bg-cream-base inline-flex">
              Start Your Project
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
          </div>
        </section>

        <footer className="py-12 border-t border-charcoal/5">
          <div className="max-w-7xl mx-auto px-6 md:px-12 flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center gap-2">
              <div className="relative w-4 h-4">
                <div className="absolute inset-0 border-[1px] border-primary rounded-full"></div>
                <div className="absolute inset-0 border-[1px] border-accent-warm rounded-full translate-x-1"></div>
              </div>
              <span className="font-geist text-[10px] font-bold tracking-[0.2em] uppercase text-charcoal">InteriAI © 2024</span>
            </div>
            <div className="flex gap-8">
              <a href="#" className="text-[10px] font-bold uppercase tracking-widest text-charcoal/50 hover:text-primary transition-colors">Privacy</a>
              <a href="#" className="text-[10px] font-bold uppercase tracking-widest text-charcoal/50 hover:text-primary transition-colors">Terms</a>
              <a href="#" className="text-[10px] font-bold uppercase tracking-widest text-charcoal/50 hover:text-primary transition-colors">Contact</a>
            </div>
          </div>
        </footer>
      </main>
    </div>
  );
};

export default Home;