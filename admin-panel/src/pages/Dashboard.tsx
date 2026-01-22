import React from 'react';
import { motion } from 'framer-motion';
import { useQuery } from '@tanstack/react-query';
import { TrendingUp, DollarSign, Briefcase, Clock, Users, CheckCircle } from 'lucide-react';
import api from '@/services/api';
import { format } from 'date-fns';

interface DashboardStats {
  users: {
    total: number;
    growth: string;
  };
  projects: {
    total: number;
    active: number;
    pending: number;
    completed: number;
  };
  revenue: {
    total: number;
    trend: string;
  };
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
    queryKey: ['adminStats'],
    queryFn: async () => {
      const res = await api.get('/admin/stats');
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

  const stats = statsData || { 
    users: { total: 0, growth: '0%' }, 
    projects: { total: 0, active: 0, pending: 0, completed: 0 }, 
    revenue: { total: 0, trend: '0%' } 
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <div>
        <h2 className="text-2xl font-bold text-text font-serif">Welcome back, Admin</h2>
        <p className="text-text-secondary mt-1">Here's what's happening with your projects today.</p>
      </div>
      
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard 
          title="Total Revenue" 
          value={`$${(stats.revenue.total || 0).toLocaleString()}`} 
          icon={DollarSign} 
          color="text-success" 
          bgColor="bg-success/10"
          trend={stats.revenue.trend}
        />
        <StatCard 
          title="Active Projects" 
          value={stats.projects.active?.toString() || '0'} 
          icon={Briefcase} 
          color="text-primary" 
          bgColor="bg-primary/10"
        />
        <StatCard 
          title="Total Users" 
          value={stats.users.total?.toString() || '0'} 
          icon={Users} 
          color="text-accent" 
          bgColor="bg-accent/10"
          trend={stats.users.growth}
        />
        <StatCard 
          title="Pending Quotes" 
          value={stats.projects.pending?.toString() || '0'} 
          icon={Clock} 
          color="text-warning" 
          bgColor="bg-warning/10"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-surface rounded-2xl shadow-sm border border-border/60 p-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-bold text-text font-serif">Recent Projects</h3>
            <button className="text-sm text-primary font-medium hover:text-primary-dark transition-colors">View All</button>
          </div>
          
          <div className="space-y-4">
            {pendingProjects?.slice(0, 5).map((project) => (
              <div key={project._id} className="flex items-center justify-between p-4 rounded-xl hover:bg-background-light transition-colors group border border-transparent hover:border-border/40">
                <div className="flex items-center gap-4">
                  <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary font-bold">
                    {project.title.substring(0, 2).toUpperCase()}
                  </div>
                  <div>
                    <h4 className="font-medium text-text group-hover:text-primary transition-colors">{project.title}</h4>
                    <p className="text-xs text-text-secondary">{project.clientName} • {format(new Date(project.createdAt), 'MMM d, yyyy')}</p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                    project.status === 'under_review' ? 'bg-warning/10 text-warning' : 
                    project.status === 'quoted' ? 'bg-success/10 text-success' : 'bg-primary/10 text-primary'
                  }`}>
                    {project.status.replace('_', ' ')}
                  </span>
                  <button className="text-text-secondary hover:text-primary transition-colors">
                    <TrendingUp className="h-4 w-4" />
                  </button>
                </div>
              </div>
            ))}
            
            {(!pendingProjects || pendingProjects.length === 0) && (
               <div className="text-center py-10">
                 <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-background-light mb-3">
                   <CheckCircle className="h-6 w-6 text-text-secondary/50" />
                 </div>
                 <p className="text-text-secondary">No pending projects found.</p>
               </div>
            )}
          </div>
        </div>
        
        <div className="bg-surface rounded-2xl shadow-sm border border-border/60 p-6">
          <h3 className="text-lg font-bold text-text font-serif mb-6">Quick Actions</h3>
          <div className="space-y-3">
            <button className="w-full flex items-center justify-between p-3 rounded-xl bg-background-light hover:bg-primary/5 hover:text-primary transition-colors text-text-secondary">
              <span className="font-medium text-sm">Create New Quote</span>
              <DollarSign className="h-4 w-4" />
            </button>
            <button className="w-full flex items-center justify-between p-3 rounded-xl bg-background-light hover:bg-primary/5 hover:text-primary transition-colors text-text-secondary">
              <span className="font-medium text-sm">Review Pending Requests</span>
              <Clock className="h-4 w-4" />
            </button>
            <button className="w-full flex items-center justify-between p-3 rounded-xl bg-background-light hover:bg-primary/5 hover:text-primary transition-colors text-text-secondary">
              <span className="font-medium text-sm">Manage Users</span>
              <Users className="h-4 w-4" />
            </button>
          </div>
          
          <div className="mt-8 pt-6 border-t border-border/40">
            <h4 className="text-sm font-bold text-text mb-4">System Status</h4>
            <div className="space-y-4">
              <div className="flex items-center justify-between text-sm">
                <span className="text-text-secondary">Server Status</span>
                <span className="flex items-center gap-1.5 text-success font-medium">
                  <span className="w-2 h-2 rounded-full bg-success"></span>
                  Online
                </span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="text-text-secondary">AI Engine</span>
                <span className="flex items-center gap-1.5 text-success font-medium">
                  <span className="w-2 h-2 rounded-full bg-success"></span>
                  Operational
                </span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="text-text-secondary">Database</span>
                <span className="flex items-center gap-1.5 text-success font-medium">
                  <span className="w-2 h-2 rounded-full bg-success"></span>
                  Connected
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
