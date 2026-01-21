import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, Sparkles } from 'lucide-react';

const Home: React.FC = () => {
  return (
    <div className="flex flex-col min-h-screen bg-background relative overflow-hidden">
      {/* Background Decorative Elements */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
        <div className="absolute top-[-10%] right-[-5%] w-[500px] h-[500px] rounded-full bg-primary/5 blur-3xl" />
        <div className="absolute bottom-[-10%] left-[-5%] w-[600px] h-[600px] rounded-full bg-secondary/10 blur-3xl" />
      </div>

      <nav className="relative z-10 flex items-center justify-between px-8 py-6">
        <h1 className="text-2xl font-serif font-bold text-primary tracking-tight">InteriAI</h1>
        <Link to="/login" className="text-sm font-medium text-text-secondary hover:text-primary transition-colors">Sign In</Link>
      </nav>

      <main className="flex-1 flex flex-col items-center justify-center p-4 text-center relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          className="max-w-4xl mx-auto"
        >
          <div className="mb-8 inline-flex items-center justify-center p-3 rounded-2xl bg-white shadow-sm border border-border/50 animate-float">
            <div className="w-16 h-16 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
              <Sparkles size={32} />
            </div>
          </div>
          
          <h1 className="text-5xl md:text-7xl font-bold mb-8 text-text font-serif tracking-tight leading-tight">
            Design your dream space <br />
            <span className="text-primary italic">with intelligent automation</span>
          </h1>
          
          <p className="text-xl text-text-secondary mb-12 max-w-2xl mx-auto font-sans leading-relaxed">
            Transform your vision into reality. Our AI-powered assistant helps you plan, visualize, and quote your interior design projects in minutes.
          </p>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link
              to="/wizard"
              className="group inline-flex items-center px-8 py-4 text-lg font-medium rounded-full text-white bg-primary hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 hover:shadow-primary/30 hover:-translate-y-1"
            >
              Start Your Project
              <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />
            </Link>
            <button className="px-8 py-4 text-lg font-medium rounded-full text-text bg-white border border-border hover:bg-background transition-all hover:shadow-md">
              View Gallery
            </button>
          </div>
        </motion.div>

        {/* Features Preview */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.8 }}
          className="mt-24 grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl w-full px-4"
        >
          {[
            { title: 'Instant Quotes', desc: 'Get accurate pricing estimates immediately based on your specs.' },
            { title: 'AI Visualization', desc: 'See your room transformed with our advanced rendering engine.' },
            { title: 'Smart Materials', desc: 'Curated selections that match your style and budget perfectly.' }
          ].map((feature, i) => (
            <div key={i} className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl border border-border/50 shadow-sm hover:shadow-md transition-shadow text-left">
              <h3 className="text-lg font-bold text-text font-serif mb-2">{feature.title}</h3>
              <p className="text-text-secondary text-sm leading-relaxed">{feature.desc}</p>
            </div>
          ))}
        </motion.div>
      </main>

      <footer className="py-8 text-center text-text-secondary text-sm relative z-10">
        <p>© 2024 InteriAI. All rights reserved.</p>
      </footer>
    </div>
  );
};

export default Home;
