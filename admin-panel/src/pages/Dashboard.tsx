import React from 'react';
import { motion } from 'framer-motion';
import { TrendingUp, Users, DollarSign, Briefcase } from 'lucide-react';

const StatCard: React.FC<{ title: string; value: string; icon: any; color: string }> = ({ title, value, icon: Icon, color }) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="bg-white rounded-lg shadow p-6"
  >
    <div className="flex items-center justify-between">
      <div>
        <p className="text-sm font-medium text-gray-500 truncate">{title}</p>
        <p className="mt-2 text-3xl font-semibold text-gray-900">{value}</p>
      </div>
      <div className={`p-3 rounded-full ${color} bg-opacity-10`}>
        <Icon className={`h-6 w-6 ${color.replace('bg-', 'text-')}`} />
      </div>
    </div>
  </motion.div>
);

const Dashboard: React.FC = () => {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Dashboard Overview</h2>
      
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard title="Total Revenue" value="$45,231" icon={DollarSign} color="text-green-600" />
        <StatCard title="Active Projects" value="12" icon={Briefcase} color="text-blue-600" />
        <StatCard title="New Clients" value="24" icon={Users} color="text-purple-600" />
        <StatCard title="Growth" value="+12.5%" icon={TrendingUp} color="text-indigo-600" />
      </div>

      <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Projects</h3>
          <div className="flow-root">
            <ul className="-my-5 divide-y divide-gray-200">
              {[1, 2, 3].map((i) => (
                <li key={i} className="py-4">
                  <div className="flex items-center space-x-4">
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        Modern Office Design #{i}
                      </p>
                      <p className="text-sm text-gray-500 truncate">
                        Started 2 days ago
                      </p>
                    </div>
                    <div>
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        Active
                      </span>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
