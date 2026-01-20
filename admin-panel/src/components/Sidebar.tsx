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
    <div className="bg-white w-64 shadow-lg hidden md:block">
      <div className="h-16 flex items-center justify-center border-b border-gray-200">
        <h1 className="text-xl font-bold text-blue-600">Admin Panel</h1>
      </div>
      <nav className="mt-6 px-4 space-y-2">
        {navItems.map((item) => (
          <Link
            key={item.name}
            to={item.path}
            className={clsx(
              'flex items-center px-4 py-2 text-sm font-medium rounded-md transition-colors',
              location.pathname === item.path
                ? 'bg-blue-50 text-blue-700'
                : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
            )}
          >
            <item.icon className="mr-3 h-5 w-5" />
            {item.name}
          </Link>
        ))}
      </nav>
    </div>
  );
};

export default Sidebar;
