import React from 'react';
import { LayoutDashboard, Settings, Users, FileText } from 'lucide-react';
import { Link, useLocation } from 'react-router-dom';
import clsx from 'clsx';

const Sidebar: React.FC = () => {
  const location = useLocation();
  
  const navItems = [
    { name: 'Dashboard', icon: LayoutDashboard, path: '/' },
    { name: 'Projects', icon: FileText, path: '/projects' },
    { name: 'Users', icon: Users, path: '/users' },
    { name: 'Settings', icon: Settings, path: '/settings' },
  ];

  return (
    <div className="bg-surface w-72 shadow-xl hidden md:flex flex-col border-r border-border h-screen sticky top-0 z-50">
      <div className="h-24 flex items-center px-8 border-b border-border">
        <h1 className="text-3xl font-serif font-bold text-primary tracking-tight">InteriAI</h1>
      </div>
      <nav className="flex-1 overflow-y-auto p-6 space-y-2">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.name}
              to={item.path}
              className={clsx(
                'flex items-center px-4 py-3.5 rounded-xl text-sm font-medium transition-all duration-200 group relative overflow-hidden',
                isActive
                  ? 'bg-primary text-white shadow-md shadow-primary/25'
                  : 'text-text-secondary hover:bg-background hover:text-primary'
              )}
            >
              <item.icon 
                className={clsx(
                  "mr-3.5 h-5 w-5 transition-colors", 
                  isActive ? "text-white" : "text-text-secondary group-hover:text-primary"
                )} 
              />
              <span className="relative z-10">{item.name}</span>
              {!isActive && (
                <div className="absolute inset-0 bg-primary/5 opacity-0 group-hover:opacity-100 transition-opacity" />
              )}
            </Link>
          );
        })}
      </nav>
      
      <div className="p-6 border-t border-border">
        <div className="bg-background rounded-xl p-4 border border-border">
          <p className="text-xs font-medium text-text-secondary uppercase tracking-wider mb-2">System Status</p>
          <div className="flex items-center space-x-2">
            <div className="h-2 w-2 rounded-full bg-success animate-pulse" />
            <span className="text-sm font-medium text-text">Operational</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
