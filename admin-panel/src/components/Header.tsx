import React from 'react';
import { Bell, User } from 'lucide-react';

const Header: React.FC = () => {
  return (
    <header className="bg-white shadow-sm h-16 flex items-center justify-between px-6">
      <div className="flex items-center">
        {/* Mobile menu button could go here */}
      </div>
      <div className="flex items-center space-x-4">
        <button className="p-2 text-gray-400 hover:text-gray-500 rounded-full hover:bg-gray-100">
          <Bell className="h-6 w-6" />
        </button>
        <div className="flex items-center space-x-2">
          <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-medium">
            <User className="h-5 w-5" />
          </div>
          <span className="text-sm font-medium text-gray-700">Admin User</span>
        </div>
      </div>
    </header>
  );
};

export default Header;
