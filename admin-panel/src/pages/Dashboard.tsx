import React from 'react';
import { motion } from 'framer-motion';
import { useQuery } from '@tanstack/react-query';
import { TrendingUp, DollarSign, Briefcase, Clock, AlertCircle } from 'lucide-react';
import api from '@/services/api';
import { format } from 'date-fns';

interface DashboardStats {
  activeProjects: number;
  pendingQuotes: number;
  revenue: number;
}

interface Project {
  _id: string;
  title: string;
  clientName: string;
  createdAt: string;
  status: string;
  aiPreviewUrl?: string;
  stylePreferences?: {
    style: string;
  };
}

const StatCard: React.FC<{ title: string; value: string; icon: React.ElementType; color: string; bgColor: string; trend?: string }> = ({ title, value, icon: Icon, color, bgColor, trend }) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="bg-surface rounded-2xl shadow-sm border border-border/60 p-6 hover:shadow-md transition-shadow duration-300 group"
  >
    <div className="flex items-start justify-between">
      <div>
        <p className="text-sm font-medium text-text-secondary">{title}</p>
        <div className="mt-4 flex items-baseline gap-2">
          <p className="text-3xl font-bold text-text font-serif tracking-tight">{value}</p>
          {trend && (
            <span className="text-xs font-medium text-success bg-success/10 px-2 py-0.5 rounded-full">
              {trend}
            </span>
          )}
        </div>
      </div>
      <div className={`p-3.5 rounded-xl ${bgColor} group-hover:scale-110 transition-transform duration-300`}>
        <Icon className={`h-6 w-6 ${color}`} />
      </div>
    </div>
  </motion.div>
);

const Dashboard: React.FC = () => {
  const { data: statsData, isLoading: statsLoading } = useQuery<DashboardStats>({
    queryKey: ['dashboardStats'],
    queryFn: async () => {
      const res = await api.get('/projects/stats');
      return res.data.data;
    }
  });

  const { data: pendingProjects, isLoading: pendingLoading } = useQuery<Project[]>({
    queryKey: ['pendingProjects'],
    queryFn: async () => {
      const res = await api.get('/projects/pending');
      return res.data.data;
    }
  });

  if (statsLoading || pendingLoading) {
    return (
      <div className="flex flex-col justify-center items-center h-full space-y-4">
        <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full animate-spin"></div>
        <p className="text-text-secondary font-medium animate-pulse">Loading dashboard...</p>
      </div>
    );
  }

  const stats = statsData || { activeProjects: 0, pendingQuotes: 0, revenue: 0 };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <div>
        <h2 className="text-2xl font-bold text-text font-serif">Welcome back, Admin</h2>
        <p className="text-text-secondary mt-1">Here's what's happening with your projects today.</p>
      </div>
      
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard 
          title="Total Revenue" 
          value={`$${(stats.revenue || 0).toLocaleString()}`} 
          icon={DollarSign} 
          color="text-success" 
          bgColor="bg-success/10"
          trend="+12.5%"
        />
        <StatCard 
          title="Active Projects" 
          value={stats.activeProjects?.toString() || '0'} 
          icon={Briefcase} 
          color="text-primary" 
          bgColor="bg-primary/10"
        />
        <StatCard 
          title="Pending Quotes" 
          value={stats.pendingQuotes?.toString() || '0'} 
          icon={Clock} 
          color="text-warning" 
          bgColor="bg-warning/10"
        />
        <StatCard 
          title="Growth Rate" 
          value="24.8%" 
          icon={TrendingUp} 
          color="text-secondary" 
          bgColor="bg-secondary/10"
          trend="+4.2%"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="bg-surface shadow-sm border border-border/60 rounded-2xl p-6 lg:col-span-2">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-bold text-text font-serif">Recent Requests</h3>
            <button className="text-sm font-medium text-primary hover:text-primary-dark transition-colors">View All</button>
          </div>
          
          <div className="flow-root">
            {!pendingProjects || pendingProjects.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <div className="h-16 w-16 bg-background rounded-full flex items-center justify-center mb-4">
                  <Briefcase className="h-8 w-8 text-text-secondary/50" />
                </div>
                <p className="text-text font-medium">No pending requests</p>
                <p className="text-sm text-text-secondary mt-1">New project requests will appear here.</p>
              </div>
            ) : (
              <ul className="-my-2 divide-y divide-border/50">
                {pendingProjects.map((project) => (
                  <li key={project._id} className="py-4 hover:bg-background/50 transition-colors rounded-xl px-4 -mx-4 group cursor-pointer">
                    <div className="flex items-center gap-4">
                      <div className="flex-shrink-0">
                        {project.aiPreviewUrl ? (
                          <img className="h-12 w-12 rounded-lg object-cover border border-border shadow-sm group-hover:shadow transition-shadow" src={project.aiPreviewUrl} alt="" />
                        ) : (
                          <div className="h-12 w-12 rounded-lg bg-background border border-border flex items-center justify-center group-hover:border-primary/30 transition-colors">
                            <AlertCircle className="h-5 w-5 text-text-secondary" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <p className="text-sm font-semibold text-text truncate group-hover:text-primary transition-colors">
                            {project.title}
                          </p>
                          <span className="text-xs text-text-secondary">
                            {format(new Date(project.createdAt), 'MMM d')}
                          </span>
                        </div>
                        <div className="flex items-center gap-2 mt-1">
                          <p className="text-xs text-text-secondary truncate max-w-[200px]">
                            {project.clientName}
                          </p>
                          <span className="h-1 w-1 rounded-full bg-border"></span>
                          <p className="text-xs text-text-secondary font-medium">
                            {project.stylePreferences?.style || 'No Style'}
                          </p>
                        </div>
                      </div>
                      <div>
                        <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border
                          ${project.status === 'submitted' 
                            ? 'bg-warning/5 text-warning border-warning/20' 
                            : 'bg-primary/5 text-primary border-primary/20'}`}>
                          {project.status.replace('_', ' ').toUpperCase()}
                        </span>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>

        <div className="bg-gradient-to-br from-primary to-primary-dark rounded-2xl p-6 text-white shadow-lg shadow-primary/20 relative overflow-hidden">
          <div className="absolute top-0 right-0 -mt-4 -mr-4 w-24 h-24 bg-white/10 rounded-full blur-xl"></div>
          <div className="absolute bottom-0 left-0 -mb-4 -ml-4 w-24 h-24 bg-black/10 rounded-full blur-xl"></div>
          
          <h3 className="text-lg font-bold font-serif mb-2 relative z-10">Pro Tips</h3>
          <p className="text-primary-light/90 text-sm mb-6 relative z-10 leading-relaxed">
            Reviewing pending quotes within 24 hours increases conversion rates by 40%.
          </p>
          
          <div className="space-y-4 relative z-10">
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/10 hover:bg-white/20 transition-colors cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-white/10 rounded-lg">
                  <TrendingUp className="h-4 w-4 text-white" />
                </div>
                <div>
                  <p className="text-xs font-medium text-white/70">Trending Style</p>
                  <p className="text-sm font-semibold">Minimalist Zen</p>
                </div>
              </div>
            </div>
            
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/10 hover:bg-white/20 transition-colors cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-white/10 rounded-lg">
                  <Briefcase className="h-4 w-4 text-white" />
                </div>
                <div>
                  <p className="text-xs font-medium text-white/70">Most Active Region</p>
                  <p className="text-sm font-semibold">North America</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
