import React from 'react';
import { User } from 'lucide-react';

const Header: React.FC = () => {
  return (
    <header className="bg-surface/80 backdrop-blur-md sticky top-0 z-40 h-24 flex items-center justify-between px-8 border-b border-border transition-all duration-200">
      <div className="flex items-center">
        <h2 className="text-xl font-medium text-text font-serif">Overview</h2>
      </div>
      <div className="flex items-center space-x-6">
        {/* <button className="relative p-2.5 text-text-secondary hover:text-primary rounded-full hover:bg-background transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-primary/20">
          <Bell className="h-6 w-6" />
          <span className="absolute top-2.5 right-2.5 h-2.5 w-2.5 rounded-full bg-error border-2 border-surface"></span>
        </button> */}
        {/* <div className="h-8 w-px bg-border mx-2"></div> */}
        <div className="flex items-center gap-4 pl-2 cursor-pointer group">
          <div className="flex flex-col items-end hidden sm:flex">
            <span className="text-sm font-semibold text-text group-hover:text-primary transition-colors">Admin User</span>
            <span className="text-xs text-text-secondary">Administrator</span>
          </div>
          <div className="h-11 w-11 rounded-full bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center text-white font-medium shadow-md shadow-primary/20 ring-2 ring-surface group-hover:ring-primary/20 transition-all">
            <User className="h-5 w-5" />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
