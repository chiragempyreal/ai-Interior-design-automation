import React from 'react';
import { CheckCircle, Circle, Minus, Plus } from 'lucide-react';

const Pricing = () => {
  return (
    <div className="bg-[#F8F6F1] font-sans text-[#131614] min-h-screen">
      {/* Header */}
      <header className="relative pt-32 pb-24 overflow-hidden">
        <div className="absolute inset-0 pointer-events-none" style={{ background: 'radial-gradient(circle at 50% 50%, rgba(74, 109, 90, 0.05) 0%, transparent 70%)' }}></div>
        <div className="relative max-w-4xl mx-auto px-6 sm:px-12 text-center">
          <span className="animate-fade-up font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary mb-6 block">PRICING STRUCTURE</span>
          <h2 className="animate-fade-up delay-100 font-serif italic text-5xl md:text-7xl text-charcoal leading-[1.05] mb-10">
            Precision tools for <br className="hidden md:block" /> visionary designers
          </h2>
          <p className="animate-fade-up delay-200 max-w-xl mx-auto text-lg text-charcoal/60 leading-relaxed font-inter">
            Select the architecture for your business growth. Simple, transparent monthly plans designed for every stage of your practice.
          </p>
        </div>
      </header>

      {/* Pricing Cards */}
      <section className="max-w-[1400px] mx-auto px-6 sm:px-12 pb-32">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-0 border border-charcoal/10 rounded-xl overflow-hidden bg-white shadow-sm">
          {/* Starter Card */}
          <div className="p-12 border-b md:border-b-0 md:border-r border-charcoal/10 flex flex-col justify-between hover:scale-[1.02] hover:z-10 transition-all duration-300 bg-white">
            <div>
              <h3 className="font-geist text-[11px] font-black uppercase tracking-[0.3em] text-charcoal/40 mb-12">Starter</h3>
              <div className="flex items-baseline mb-8">
                <span className="text-6xl font-geist font-black tracking-tighter text-charcoal">$49</span>
                <span className="text-xs font-bold text-charcoal/30 ml-2 uppercase tracking-widest">/mo</span>
              </div>
              <div className="mb-12">
                <img 
                  alt="Starter Plan" 
                  className="w-full h-32 object-cover rounded-lg mb-8 opacity-90 grayscale hover:grayscale-0 transition-all duration-700" 
                  src="https://lh3.googleusercontent.com/aida-public/AB6AXuBsMT1FrW9bEX1h46OLJNyMKJpf5fBEOhTjny5txHjwHhbaFkSaVwVMwihq8e4xpaPaYBVvQJf7wVCA63XudFpYEaIwEJkQPTN25ZqtwF5S_OtJV0X1NLLj9Vm5BcgAU6l2k4PUSzYBpV3bWUO4nXwzOyf0wCoHzZBSghlpsYf0CaqUyKVbKAll9065CrLhLHUJNEmy1N7HFOGRrTEp3wo4Ak2Up08owb1qxmqeLb1ktg6LWZ77rurhVM3glBHsAN-Z-e2AYVtJl1s"
                />
                <p className="text-sm font-inter text-charcoal/70 leading-relaxed mb-8">Perfect for independent designers focusing on small-scale residential projects.</p>
              </div>
              <ul className="space-y-4 mb-16">
                {[
                  '5 Active projects',
                  'Basic AI rendering engine',
                  'Standard documentation'
                ].map((item, i) => (
                  <li key={i} className="flex items-center gap-3 font-inter text-sm text-charcoal/80">
                    <Circle className="w-2 h-2 text-primary fill-primary" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <button className="w-full py-4 px-8 border border-charcoal/10 rounded-full font-geist text-[10px] font-black uppercase tracking-[0.2em] hover:bg-charcoal hover:text-white transition-all duration-300 hover:-translate-y-1 hover:shadow-lg">
              GET STARTED
            </button>
          </div>

          {/* Professional Card */}
          <div className="p-12 border-b md:border-b-0 md:border-r border-charcoal/10 bg-[#FBF9F4] flex flex-col justify-between relative hover:scale-[1.02] hover:z-10 hover:shadow-2xl hover:shadow-primary/10 transition-all duration-300">
            <div className="absolute top-0 right-0 p-6">
              <span className="font-geist text-[9px] font-black uppercase tracking-widest text-primary px-3 py-1 bg-primary/5 rounded-full border border-primary/10">Recommended</span>
            </div>
            <div>
              <h3 className="font-geist text-[11px] font-black uppercase tracking-[0.3em] text-primary mb-12">Professional</h3>
              <div className="flex items-baseline mb-8">
                <span className="text-6xl font-geist font-black tracking-tighter text-charcoal">$99</span>
                <span className="text-xs font-bold text-charcoal/30 ml-2 uppercase tracking-widest">/mo</span>
              </div>
              <div className="mb-12">
                <img 
                  alt="Professional Plan" 
                  className="w-full h-32 object-cover rounded-lg mb-8" 
                  src="https://lh3.googleusercontent.com/aida-public/AB6AXuCdq-m-dSZXElk_q1BzsyyHLTmeG_bOxRIEXcKmCJXcP8NpDVPQuudTtiSputtbozTXRYoxkqzhrGPWuGXiPEO8VJNudFIVaoPbBJzjntNiwG8BrZkHD88ZrUVj25CuDGuoyCirdrD6CCW9ySYP9vYRUJx1BQOoEUasFWJlHFFtQWrPnnMpSHCqM-f-wcU0Er_vQ0HQJ3pexJNEr-P1Ur4EVir2pegG-S0ZTDseOn6HNTQMSlT7cOt88H66VoirKXoRk2Eq4EvHcB4"
                />
                <p className="text-sm font-inter text-charcoal/70 leading-relaxed mb-8">Our most popular plan for established studios scaling their operations.</p>
              </div>
              <ul className="space-y-4 mb-16">
                {[
                  'Unlimited projects',
                  'Advanced AI spatial analysis',
                  'Custom client portal',
                  'Auto-quote procurement'
                ].map((item, i) => (
                  <li key={i} className="flex items-center gap-3 font-inter text-sm text-charcoal/90 font-medium">
                    <Circle className="w-2 h-2 text-primary fill-primary" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <button className="w-full py-4 px-8 bg-primary text-white rounded-full font-geist text-[10px] font-black uppercase tracking-[0.2em] shadow-lg shadow-primary/10 hover:bg-charcoal transition-all duration-300 hover:-translate-y-1">
              START FREE TRIAL
            </button>
          </div>

          {/* Studio Card */}
          <div className="p-12 flex flex-col justify-between hover:scale-[1.02] hover:z-10 transition-all duration-300 bg-white">
            <div>
              <h3 className="font-geist text-[11px] font-black uppercase tracking-[0.3em] text-charcoal/40 mb-12">Studio</h3>
              <div className="flex items-baseline mb-8">
                <span className="text-6xl font-geist font-black tracking-tighter text-charcoal">$199</span>
                <span className="text-xs font-bold text-charcoal/30 ml-2 uppercase tracking-widest">/mo</span>
              </div>
              <div className="mb-12">
                <img 
                  alt="Studio Plan" 
                  className="w-full h-32 object-cover rounded-lg mb-8 opacity-90 grayscale hover:grayscale-0 transition-all duration-700" 
                  src="https://lh3.googleusercontent.com/aida-public/AB6AXuCtgaNoBgqaRd_o300l5pv9neqTD7zcues2zzIMgFQaK9oyQeOgq3BdPM__QdGilqUF6rntN9Q2X6xIVZZfwwRwXvZDEr7PjMGeQ1hF-GTMcF87FePuyXlXlq3OTmKFBH-28jFu0Ixad2ocCLfwFgsEtKkQFzmxWNBc035PhwIAJxqL4yQKA0N28kx0sTWLjJ285NiiWEfEygDiCisHYyQfzFcWBVfbGdlYglMZ8NDmyV3zKNXebgQ3--MmmlF7wULOd2tfltQ4bP4"
                />
                <p className="text-sm font-inter text-charcoal/70 leading-relaxed mb-8">Enterprise-grade tools for high-end firms requiring full white-label capabilities.</p>
              </div>
              <ul className="space-y-4 mb-16">
                {[
                  'Multi-user collaboration',
                  'White-label reporting',
                  'API access & integrations'
                ].map((item, i) => (
                  <li key={i} className="flex items-center gap-3 font-inter text-sm text-charcoal/80">
                    <Circle className="w-2 h-2 text-primary fill-primary" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <button className="w-full py-4 px-8 border border-charcoal/10 rounded-full font-geist text-[10px] font-black uppercase tracking-[0.2em] hover:bg-charcoal hover:text-white transition-all duration-300 hover:-translate-y-1 hover:shadow-lg">
              CONTACT SALES
            </button>
          </div>
        </div>
      </section>

      {/* Breakdown Table */}
      <section className="max-w-[1200px] mx-auto px-6 sm:px-12 pb-32">
        <div className="text-center mb-16 animate-fade-up">
          <h2 className="font-geist text-[11px] font-black uppercase tracking-[0.4em] text-charcoal/30 mb-4">Detailed Breakdown</h2>
          <p className="font-serif italic text-3xl text-charcoal">Compare the features</p>
        </div>
        
        <div className="flex flex-col-reverse">
          {/* Table Rows */}
          <div className="grid grid-cols-4 py-8 border-b border-charcoal/5 hover:bg-white/40 transition-colors">
            <div className="col-span-1 font-inter text-sm font-semibold text-charcoal">Cloud Storage</div>
            <div className="font-inter text-sm text-charcoal/60">5GB</div>
            <div className="font-inter text-sm text-charcoal/60">100GB</div>
            <div className="font-inter text-sm text-charcoal/60">Unlimited</div>
          </div>
          <div className="grid grid-cols-4 py-8 border-b border-charcoal/5 hover:bg-white/40 transition-colors">
            <div className="col-span-1 font-inter text-sm font-semibold text-charcoal">Custom Branding</div>
            <div className="flex items-center"><Minus className="w-4 h-4 text-charcoal/10" /></div>
            <div className="font-inter text-sm text-charcoal/60">Partial</div>
            <div className="font-inter text-sm text-charcoal/60 font-medium">Full White-label</div>
          </div>
          <div className="grid grid-cols-4 py-8 border-b border-charcoal/5 hover:bg-white/40 transition-colors">
            <div className="col-span-1 font-inter text-sm font-semibold text-charcoal">Automated Procurement</div>
            <div className="flex items-center"><Minus className="w-4 h-4 text-charcoal/10" /></div>
            <div className="flex items-center"><CheckCircle className="w-4 h-4 text-primary" /></div>
            <div className="flex items-center"><CheckCircle className="w-4 h-4 text-primary" /></div>
          </div>
          <div className="grid grid-cols-4 py-8 border-b border-charcoal/5 hover:bg-white/40 transition-colors">
            <div className="col-span-1 font-inter text-sm font-semibold text-charcoal">AI Photo-Real Renders</div>
            <div className="font-inter text-sm text-charcoal/60">10 / month</div>
            <div className="font-inter text-sm text-charcoal/60 font-medium">Unlimited</div>
            <div className="font-inter text-sm text-charcoal/60 font-medium">Unlimited</div>
          </div>

          {/* Table Header */}
          <div className="grid grid-cols-4 py-8 border-b border-charcoal/10">
            <div className="col-span-1 font-geist text-[10px] font-black uppercase tracking-[0.2em] text-charcoal/40">Capability</div>
            <div className="font-geist text-[10px] font-black uppercase tracking-[0.2em] text-charcoal">Starter</div>
            <div className="font-geist text-[10px] font-black uppercase tracking-[0.2em] text-charcoal">Professional</div>
            <div className="font-geist text-[10px] font-black uppercase tracking-[0.2em] text-charcoal">Studio</div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="bg-white/50 py-32 border-t border-charcoal/5">
        <div className="max-w-[1200px] mx-auto px-6 sm:px-12">
          <h2 className="font-serif italic text-4xl text-charcoal mb-16 text-center animate-fade-up">Frequently Asked Questions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-x-16 gap-y-8">
            {[
              {
                q: "HOW ACCURATE IS THE AI QUOTING TOOL?",
                a: "Our AI models are trained on real-world procurement data from over 5,000 architectural suppliers. Accuracy typically stays within a 5% margin for standard materials, ensuring your initial client estimates are professionally sound."
              },
              {
                q: "CAN I SWITCH PLANS MID-PROJECT?",
                a: "Yes, you can upgrade or downgrade your plan at any time. Changes take effect immediately, and your billing will be prorated for the remainder of the cycle."
              },
              {
                q: "DOES DESIGNQUOTE OFFER A FREE TRIAL?",
                a: "Absolutely. Join our waitlist to get 7 days of full Professional access. No credit card required to start your architectural journey."
              },
              {
                q: "WHAT SUPPORT IS INCLUDED?",
                a: "All plans include 24/7 email support. Professional and Studio plans receive priority queue status and dedicated account management for custom integrations."
              }
            ].map((faq, i) => (
              <details key={i} className="group">
                <summary className="list-none cursor-pointer flex items-center justify-between py-4 border-b border-charcoal/10">
                  <h4 className="font-geist text-[11px] font-black uppercase tracking-[0.2em] text-charcoal pr-4">{faq.q}</h4>
                  <Plus className="w-4 h-4 text-primary group-open:rotate-45 transition-transform duration-300" />
                </summary>
                <div className="overflow-hidden transition-all duration-500 max-h-0 group-open:max-h-96">
                  <p className="py-6 font-inter text-sm text-charcoal/60 leading-relaxed">
                    {faq.a}
                  </p>
                </div>
              </details>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-[#F8F6F1] text-charcoal px-6 md:px-12 py-16 border-t border-charcoal/5">
        <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-12">
          <div className="col-span-1 md:col-span-1">
            <h5 className="font-geist text-[11px] font-black uppercase tracking-[0.2em] text-charcoal mb-6">DesignQuote AI</h5>
            <p className="font-inter text-sm text-charcoal/60 leading-relaxed">
              Elevating architectural visualization with precision AI tools.
            </p>
          </div>
          <div>
            <h5 className="font-geist text-[11px] font-black uppercase tracking-[0.2em] text-charcoal mb-6">Product</h5>
            <ul className="space-y-3">
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Features</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Pricing</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Enterprise</a></li>
            </ul>
          </div>
          <div>
            <h5 className="font-geist text-[11px] font-black uppercase tracking-[0.2em] text-charcoal mb-6">Company</h5>
            <ul className="space-y-3">
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">About Us</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Careers</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Blog</a></li>
            </ul>
          </div>
          <div>
            <h5 className="font-geist text-[11px] font-black uppercase tracking-[0.2em] text-charcoal mb-6">Connect</h5>
            <ul className="space-y-3">
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Twitter</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">LinkedIn</a></li>
              <li><a href="#" className="font-inter text-sm text-charcoal/60 hover:text-primary transition-colors">Instagram</a></li>
            </ul>
          </div>
        </div>
        <div className="max-w-7xl mx-auto mt-16 pt-8 border-t border-charcoal/5 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="font-inter text-xs text-charcoal/40">© 2024 DesignQuote AI. All rights reserved.</p>
          <div className="flex gap-6">
            <a href="#" className="font-inter text-xs text-charcoal/40 hover:text-primary transition-colors">Privacy Policy</a>
            <a href="#" className="font-inter text-xs text-charcoal/40 hover:text-primary transition-colors">Terms of Service</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Pricing;
