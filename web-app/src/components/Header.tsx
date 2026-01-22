import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';

interface User {
  full_name: string;
  email: string;
  phone?: string;
}

const Header: React.FC = () => {
  const location = useLocation();
  const [scrolled, setScrolled] = useState(false);
  const [user, setUser] = useState<User | null>(() => {
    const stored = localStorage.getItem('user');
    return stored ? JSON.parse(stored) : null;
  });

  const isHome = location.pathname === '/';

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
        const storedUser = localStorage.getItem('user');
        const parsedUser = storedUser ? JSON.parse(storedUser) : null;
        if (JSON.stringify(parsedUser) !== JSON.stringify(user)) {
            setUser(parsedUser);
        }
    }, 0);
    return () => clearTimeout(timer);
  }, [location.pathname, user]); // Re-check on route change

  const headerClass = isHome 
    ? (scrolled ? 'glass-nav-scrolled bg-white backdrop-blur-md border-b border-charcoal/5 shadow-sm' : 'glass-nav bg-white md:bg-transparent backdrop-blur-md md:backdrop-blur-none') 
    : 'glass-nav bg-white backdrop-blur-md border-b border-charcoal/5 sticky top-0';

  return (
    <header 
      className={`fixed top-0 w-full z-50 px-6 md:px-12 py-5 flex items-center justify-between transition-all duration-300 ${headerClass}`} 
      id="main-header"
    >
      <Link to="/" className="flex items-center gap-3 group cursor-pointer flex-1">
        <div className="relative w-6 h-6">
          <div className="absolute inset-0 border-[1.5px] border-primary rounded-full"></div>
          <div className="absolute inset-0 border-[1.5px] border-accent-warm rounded-full translate-x-1.5"></div>
        </div>
        <h1 className="font-geist text-[11px] font-bold tracking-[0.25em] uppercase ml-2 text-charcoal">DesignQuote AI</h1>
      </Link>

      <nav className="hidden md:flex gap-8 items-center justify-center flex-1">
        <Link className="nav-link text-charcoal/80 hover:text-primary transition-colors text-sm font-medium" to="/">Home</Link>
        <Link className="nav-link text-charcoal/80 hover:text-primary transition-colors text-sm font-medium" to="/how-it-works">How It Works</Link>
        <Link className="nav-link text-charcoal/80 hover:text-primary transition-colors text-sm font-medium" to="/pricing">Pricing</Link>
        <Link className="nav-link text-charcoal/80 hover:text-primary transition-colors text-sm font-medium" to="/examples">Examples</Link>
      </nav>

      <div className="flex items-center gap-8 justify-end flex-1">
        <div className="hidden md:flex items-center">
          {user ? (
            <Link to="/profile" className="nav-link font-bold text-primary text-sm uppercase tracking-wider hover:text-primary-dark">
               {user.full_name || 'Profile'}
            </Link>
          ) : (
            <Link className="nav-link text-charcoal/80 hover:text-primary transition-colors text-sm font-medium" to="/login">Login</Link>
          )}
        </div>
        <Link to="/wizard" className="pill-button bg-primary text-white font-geist text-[10px] font-bold tracking-[0.2em] uppercase px-6 py-2.5 rounded-full shadow-sm hover:bg-charcoal transition-all">
          Start Project
        </Link>
      </div>
    </header>
  );
};

export default Header;
