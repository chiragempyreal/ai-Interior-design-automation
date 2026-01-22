import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, 
  FolderKanban, 
  Users, 
  Settings, 
  LogOut
} from 'lucide-react';

const Sidebar: React.FC = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  const navItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: FolderKanban, label: 'Projects', path: '/projects' },
    { icon: Users, label: 'Users', path: '/users' },
    { icon: Settings, label: 'Settings', path: '/settings' },
  ];

  return (
    <div className="w-64 bg-surface border-r border-border h-screen sticky top-0 flex flex-col transition-all duration-300">
      <div className="h-24 flex items-center px-8 border-b border-border">
        <div className="flex items-center gap-3">
          <div className="relative w-6 h-6">
            <div className="absolute inset-0 border-[1.5px] border-primary rounded-full"></div>
            <div className="absolute inset-0 border-[1.5px] border-accent-warm rounded-full translate-x-1.5"></div>
          </div>
          <span className="font-geist text-[11px] font-bold tracking-[0.25em] uppercase ml-2 text-text">DesignQuote AI</span>
        </div>
      </div>

      <nav className="flex-1 px-4 py-8 space-y-2">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group ${
                isActive 
                  ? 'bg-primary text-white shadow-lg shadow-primary/25 font-medium' 
                  : 'text-text-secondary hover:bg-background-light hover:text-primary'
              }`
            }
          >
            <item.icon className="w-5 h-5 transition-transform group-hover:scale-110 duration-200" />
            <span className="text-sm tracking-wide">{item.label}</span>
          </NavLink>
        ))}
      </nav>

      <div className="p-4 border-t border-border">
        <button 
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 w-full rounded-xl text-text-secondary hover:bg-error/10 hover:text-error transition-all duration-200 group"
        >
          <LogOut className="w-5 h-5 transition-transform group-hover:-translate-x-1 duration-200" />
          <span className="text-sm font-medium">Log Out</span>
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
