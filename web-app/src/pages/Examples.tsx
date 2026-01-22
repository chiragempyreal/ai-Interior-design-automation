import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import Header from '../components/Header';

const Examples: React.FC = () => {
  const observerRef = useRef<IntersectionObserver | null>(null);
  const [activeCategory, setActiveCategory] = useState('All');

  useEffect(() => {
    observerRef.current = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            entry.target.classList.remove('opacity-0', 'translate-y-8', 'translate-x-[-50px]', 'translate-x-[50px]');
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('.animate-on-scroll, .slide-left, .slide-right');
    elements.forEach((el) => observerRef.current?.observe(el));

    return () => observerRef.current?.disconnect();
  }, []);

  const categories = ['All', 'Living Rooms', 'Bedrooms', 'Kitchens', 'Offices', 'Dining'];

  return (
    <div className="bg-background-light font-display text-charcoal overflow-x-hidden min-h-screen">
      {/* Navigation */}
      <Header />

      <main className="max-w-[1920px] mx-auto px-6 lg:px-20 pt-20">
        {/* Hero Section */}
        <section className="py-20 lg:py-32">
          <div className="max-w-4xl overflow-hidden">
            <p className="font-display text-[11px] font-bold tracking-[0.3em] uppercase text-charcoal/60 mb-3 animate-on-scroll opacity-0 translate-y-8 transition-all duration-700">Portfolio Gallery</p>
            <h1 className="text-5xl lg:text-7xl font-serif italic text-heading-dark leading-[1.15] mb-8 animate-on-scroll opacity-0 translate-y-8 transition-all duration-700 delay-100">
              Real Transformations, Real Homes.
            </h1>
            <p className="font-serif italic text-xl lg:text-2xl text-charcoal/80 max-w-2xl leading-relaxed animate-on-scroll opacity-0 translate-y-8 transition-all duration-700 delay-200">
              A showcase of spaces transformed using AI-powered design previews, bridging the gap between imagination and execution.
            </p>
          </div>
        </section>

        {/* Filters */}
        <div className="flex flex-wrap gap-3 mb-16 border-y border-charcoal/10 py-8 animate-on-scroll opacity-0 translate-y-8 transition-all duration-700 delay-300">
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setActiveCategory(category)}
              className={`px-6 py-2 rounded-full text-[10px] font-bold tracking-[0.2em] uppercase transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg ${
                activeCategory === category
                  ? 'bg-primary text-white'
                  : 'bg-[#E8E6E1] text-charcoal hover:bg-primary hover:text-white'
              }`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Case Studies */}
        <section className="space-y-32 mb-32">
          {/* Case Study 01 */}
          <div className="grid lg:grid-cols-2 gap-16 items-center overflow-hidden">
            <div className="relative group slide-left opacity-0 translate-x-[-50px] transition-all duration-1000">
              <div className="aspect-[4/5] overflow-hidden rounded-[70px] border-[12px] border-white shadow-2xl animate-breath">
                <div 
                  className="w-full h-full bg-center bg-cover transition-transform duration-700 group-hover:scale-110" 
                  style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuB2HuRn2Hey37wXToqscH32qZVJsssyzeGpYszs-v0DlSKHcqgIKZneErNNjHLZ367mrqwqmdo46iZidoNABalnurquHaH77TxThStbeb717gj4IMxx0FSnU3XmlTWqNbWf5SeAyiz5Qw9dNtwtsLaQJYdNWPCNt8209VzbTIFVLWzx-J9l9YWnAhgxlqqRKU7r-abxZxJQlYHF2N20L_DHB6Hv43mtobj9oBfVmPVHIpeguMSzlzHdx6wyq5pOJqYIpHYpBLz2rk8')" }}
                ></div>
              </div>
            </div>
            <div className="lg:pl-12 slide-right opacity-0 translate-x-[50px] transition-all duration-1000 delay-200">
              <p className="font-display text-[11px] font-bold tracking-[0.3em] uppercase text-primary mb-3">Case Study 01</p>
              <h3 className="text-4xl lg:text-6xl font-serif italic text-heading-dark mb-6 leading-tight">The Minimalist Penthouse</h3>
              <p className="text-[10px] font-bold tracking-[0.2em] uppercase mb-6 text-charcoal/60">Modern Architectural • ₹15L Budget</p>
              <p className="font-serif text-lg text-charcoal/80 mb-10 leading-relaxed italic">
                "Using DesignQuote AI, we visualized the light interaction with the new floor-to-ceiling glass before the first contractor arrived. The result is a sanctuary of silence and light."
              </p>
              <button className="bg-charcoal text-white text-[10px] font-bold tracking-[0.2em] uppercase px-10 py-4 rounded-full hover:scale-105 hover:shadow-lg transition-all duration-300 flex items-center gap-3">
                View Full Project
                <span className="material-symbols-outlined text-sm">photo_camera</span>
              </button>
            </div>
          </div>

          {/* Case Study 02 */}
          <div className="grid lg:grid-cols-2 gap-16 items-center overflow-hidden">
            <div className="lg:order-2 relative group slide-right opacity-0 translate-x-[50px] transition-all duration-1000">
              <div className="aspect-[4/5] overflow-hidden rounded-[70px] border-[12px] border-white shadow-2xl animate-breath" style={{ animationDelay: '-2s' }}>
                <div 
                  className="w-full h-full bg-center bg-cover transition-transform duration-700 group-hover:scale-110" 
                  style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDIDLf3IhJs0soY3f1Ses9yVW4wAox_azBwPZlfgLmjK6AGD8KOYEugDyUf2u2_tMTMbVD2o_JuWGDiAs8X1MNB4wxAVnhOQsJkozzCoGuy4ifkxikEghlZ75RrM7nxwyLO2t36Oq_kv8r28zILVB5nCGetH4KPsRHOJ8f9yRrqUrNsdNkrAIR4nXr46KCSMA0uWl6qik-hoLMj6WEk9llCEWb7eoZZPX6MtfyHwjsMz8RoFeL5hkXSTk3X5MaZQV1BGWPnpEugB_g')" }}
                ></div>
              </div>
            </div>
            <div className="lg:pr-12 lg:text-right slide-left opacity-0 translate-x-[-50px] transition-all duration-1000 delay-200">
              <p className="font-display text-[11px] font-bold tracking-[0.3em] uppercase text-primary mb-3">Case Study 02</p>
              <h3 className="text-4xl lg:text-6xl font-serif italic text-heading-dark mb-6 leading-tight">The Heritage Villa</h3>
              <p className="text-[10px] font-bold tracking-[0.2em] uppercase mb-6 text-charcoal/60">Classic Renaissance • ₹22L Budget</p>
              <p className="font-serif text-lg text-charcoal/80 mb-10 leading-relaxed italic">
                A careful restoration project where AI helped preserve historical crown molding while integrating modern lighting solutions seamlessly into the classical architecture.
              </p>
              <button className="bg-charcoal text-white text-[10px] font-bold tracking-[0.2em] uppercase px-10 py-4 rounded-full hover:scale-105 hover:shadow-lg transition-all duration-300 flex items-center gap-3 lg:ml-auto">
                View Full Project
                <span className="material-symbols-outlined text-sm">add</span>
              </button>
            </div>
          </div>
        </section>

        {/* Curated Collection */}
        <div className="text-center mb-16 animate-on-scroll opacity-0 translate-y-8 transition-all duration-700">
          <p className="font-display text-[11px] font-bold tracking-[0.3em] uppercase text-charcoal/60 mb-3">Curated Collection</p>
          <h2 className="text-4xl lg:text-5xl font-serif italic text-heading-dark mb-4">Explore More Transformations</h2>
          <div className="w-16 h-[1px] bg-primary/30 mx-auto mt-6"></div>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-32">
          {/* Collection Item 1 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-100">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuA2-ApKPCh9n18w0a6OoUmmwdbYW1bC6bbQ2nGTfwYzVxVXBTDhONbEmjx6qdhtdR8V7OZkmbOhN6oWdNNzmPRICtNdX8yaMB-lH9t8ErFKOp7Kpb8nkwXxhpoyaWY25DuRnUl3xkXosBEHNI2OJcAu9Ex3PgA5YZpMbPJZ-U62yDqedkBHiVsCS6KAXyfvjEvg7_SYU6m0JiJUePvF-c0ZE1reer5iGpI9VYX3_9pCM30koBnjOtBOe-zuwT2JH9Zp97C9T8VqfoU')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Scandinavian • ₹8L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Living Room</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Open-plan living with AI-optimized light flow and custom modular seating.</p>
          </div>

          {/* Collection Item 2 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-200">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDZNl9Cco7_mO1pjlC8Oi9wYxddl45hzpbRwRZJ6vlHcEgq5a07YJqKyfEFC4epIp-DU005sKJy4IIYEQKfqT0InDDYOypKytAxATnFiCfYXZNS29mariDTZM-_7GwmUKiUcPAx-y4jao9xuBZOyTQRBZ1dg6x1cbBLCgF2RqjJhtmPPYhjh7iz0TB1IXAxtBQN1rna_deNJlBNINadIw37wt9kHUkngrcD63kSEPa-x-Nsg1klm9poI640iSvubES57kxK7hK7f6Y')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Minimalist • ₹5L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Master Bedroom</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Serene sanctuary with custom built-in storage and hidden ambient lighting.</p>
          </div>

          {/* Collection Item 3 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-300">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuAKPZvXNxIet_aYcIBgDELeSttlOk_2_4b-lMT5fcGszlV086GFR2BaTKc-U8PWrmBU2WKP-HQuZBbsV9SRXGp8KYOsKHHSjrF_topAJDqAifl-PujLFetZkcvb8nuMQ7An57Q6q1wcqSPH7NJc43j9P9Dkppa1JJZL7pYrU5owoThTsdvhsUHvpMSfMk2YbIeYUAQUqnzUkgDH2udN02E9RxiCMoE6LpPJqmZFW-fHL1R-JI9T6joC72Cxu44LfyYBHRO8AH15IHw')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Industrial • ₹12L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Modern Kitchen</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Chef's kitchen featuring marble accents and smart storage solutions.</p>
          </div>

          {/* Collection Item 4 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-100">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDN4jcHATMsiaZpY40y_NFg0-7ZAEssJhlIVIQH_tcRmhr433EFUhfBwKUZFfy10WM-kETOzQK-QAgrkL-_NFMfwstFBDeL9ssmspDdntdo4wyRls3DIVdZ037amelvDMO7_UShKMIiiwtnFvAZxvYXSteZuzjz-cZ4yrkfVexPqSePMWSGaJ8ReilQontDmg_vI-yfbxgblVrGArSLN8X3c4uhrHojSK2oIFROK42dTnXjqpsUALrskSJ0QyJa8r4N4x8czzL6k_8')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Contemporary • ₹3L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Home Office</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Ergonomic workspace with architectural focus on acoustic privacy.</p>
          </div>

          {/* Collection Item 5 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-200">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDIrG2qZ5d3Sl81F27bSyS0s2bNMscNQzQFwlNC7crFPfgXGOgWSWzKPn1YlK0lpY3cEGh2BD9axUHNdK245umLkPl3gdRaBQYY-Kkk9m_8PG8ois5iPTfB-5aTb9RVlCamiK5ERYinMOTV_wM8NrbSALyF68VslBG3ApemVWzdhYhol_5NW41rckm0yBuLanx47OeEau2jBUsOWwp_a48h82cuDwgO5qei9NJ8-zscqw7d7erCL6gNrUbtOtRBdJXR5nukwlVP9Sk')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Mid-Century • ₹6L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Dining Space</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Elegant hosting area with premium finishes and warm walnut textures.</p>
          </div>

          {/* Collection Item 6 */}
          <div className="bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-600 group animate-on-scroll opacity-0 translate-y-8 delay-300">
            <div className="aspect-square mb-6 overflow-hidden rounded-[70px] border-4 border-[#E8E6E1]">
              <div 
                className="w-full h-full bg-center bg-cover group-hover:scale-[1.03] transition-transform duration-600" 
                style={{ backgroundImage: "url('https://lh3.googleusercontent.com/aida-public/AB6AXuD9XTDDoAriucmRSiLsE_v1Rzqr_mXVcEiF8vKkQRw9j_S9P0NinZ2hqxI3ugGGRJcS6eHx1blapde9bxzma9D0USx-OaeTZ-ZYsm7u4Jrb4OB6HAuqJ--hSMNpHkUj6Ag5NBUQWrfEZ8vXA27Y4-KriA-WOdI71kkVq3mUIaaPQ_ywLN43fcmLTr-Ev7QGJxTETIjh0GCVISjVmOcHT107VslxjfzV-CysnAvRsTwq0Wp1TkQTvQ9GlGGytmawQ4UTfx0nh8PR6G4')" }}
              ></div>
            </div>
            <p className="font-display text-[9px] font-bold tracking-[0.3em] uppercase mb-1 text-primary">Bohemian • ₹4L Budget</p>
            <h4 className="text-2xl font-serif italic text-heading-dark mb-3">Kids Room</h4>
            <p className="font-serif text-sm text-charcoal/70 leading-relaxed italic">Playful and functional growth-centric design with sustainable materials.</p>
          </div>
        </div>

        {/* CTA Section */}
        <section className="mb-32 animate-on-scroll opacity-0 translate-y-8 transition-all duration-700">
          <div className="relative bg-primary rounded-[3rem] overflow-hidden min-h-[500px] flex items-center justify-center">
            <div className="relative z-10 max-w-3xl mx-auto px-6 text-center text-white">
              <p className="font-display text-[11px] font-bold tracking-[0.3em] uppercase text-white/70 mb-3">Getting Started</p>
              <h2 className="text-5xl lg:text-7xl font-serif italic text-white mb-6 leading-tight animate-glow">Ready to Create?</h2>
              <p className="font-serif italic text-xl lg:text-2xl mb-12 text-white/90">Experience the power of AI-driven design visualization today.</p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-6">
                <button className="w-full sm:w-auto bg-white text-primary text-[11px] font-bold tracking-[0.2em] uppercase px-12 py-5 rounded-full shadow-xl hover:scale-105 hover:shadow-2xl transition-all duration-300">
                  Start Project
                </button>
                <button className="w-full sm:w-auto border-2 border-white/50 text-white text-[11px] font-bold tracking-[0.2em] uppercase px-12 py-5 rounded-full hover:bg-white/10 hover:scale-105 transition-all duration-300">
                  Book a Demo
                </button>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-brand-cream text-charcoal pt-24 pb-12 border-t border-charcoal/10">
        <div className="max-w-[1920px] mx-auto px-6 lg:px-20">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-12 mb-20">
            <div className="col-span-2 lg:col-span-1">
              <div className="flex items-center gap-3 mb-8">
                <div className="relative size-8 flex items-center justify-center">
                  <div className="absolute size-7 border-[1.5px] border-accent-warm rounded-full -translate-x-1.5"></div>
                  <div className="absolute size-7 border-[1.5px] border-primary rounded-full translate-x-1.5"></div>
                </div>
                <h2 className="text-charcoal text-base font-bold font-display tracking-[0.15em] uppercase ml-2">DESIGNQUOTE AI</h2>
              </div>
              <p className="text-xs text-charcoal/70 leading-relaxed font-serif italic mb-6">Redefining professional interior design through the precision of artificial intelligence and the soul of architectural artistry.</p>
            </div>
            <div>
              <h4 className="text-[10px] font-bold tracking-widest uppercase mb-8 text-primary">Platform</h4>
              <ul className="space-y-4">
                <li><Link className="text-xs text-charcoal/70 hover:text-primary transition-all duration-300" to="/how-it-works">How it works</Link></li>
                <li><Link className="text-xs text-charcoal/70 hover:text-primary transition-all duration-300" to="/examples">Design Gallery</Link></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-charcoal/10 pt-12 flex flex-col md:flex-row justify-between items-center gap-6">
            <p className="text-[10px] text-charcoal/40 font-bold tracking-wider uppercase">© 2024 DesignQuote AI. All rights reserved.</p>
            <div className="flex gap-8">
              <a href="#" className="text-[10px] text-charcoal/40 font-bold tracking-wider uppercase hover:text-primary transition-colors">Privacy Policy</a>
              <a href="#" className="text-[10px] text-charcoal/40 font-bold tracking-wider uppercase hover:text-primary transition-colors">Terms of Service</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Examples;
