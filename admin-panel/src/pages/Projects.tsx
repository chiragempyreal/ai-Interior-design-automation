import React, { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import api from '@/services/api';
import { format } from 'date-fns';
import { Search, Filter, Eye, ChevronLeft, ChevronRight } from 'lucide-react';

interface Project {
  _id: string;
  title: string;
  type: string;
  status: string;
  createdAt: string;
  user_id: {
    full_name: string;
    email: string;
  };
}

const Projects: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const status = searchParams.get('status') || 'all';
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const limit = 10;

  // Debounce search
  React.useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(search);
    }, 500);
    return () => clearTimeout(timer);
  }, [search]);

  // Reset page when filters change
  React.useEffect(() => {
    setPage(1);
  }, [debouncedSearch, status]);

  const { data, isLoading } = useQuery({
    queryKey: ['projects', page, debouncedSearch, status],
    queryFn: async () => {
      const res = await api.get(`/admin/projects?page=${page}&limit=${limit}&search=${debouncedSearch}&status=${status}`);
      return res.data.data;
    }
  });

  const handleStatusChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newStatus = e.target.value;
    setSearchParams(prev => {
        if (newStatus === 'all') {
            prev.delete('status');
        } else {
            prev.set('status', newStatus);
        }
        return prev;
    });
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'completed': return 'bg-success/10 text-success border-success/20';
      case 'in_progress': return 'bg-primary/10 text-primary border-primary/20';
      case 'submitted': return 'bg-warning/10 text-warning border-warning/20';
      case 'quoted': return 'bg-info/10 text-info border-info/20';
      case 'approved': return 'bg-secondary/10 text-secondary border-secondary/20';
      default: return 'bg-text-secondary/10 text-text-secondary border-text-secondary/20';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold font-display text-text">Projects</h2>
          <p className="text-text-secondary mt-1">Manage and track all client projects.</p>
        </div>
        <div className="flex gap-3">
          <div className="relative">
             <Filter className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary pointer-events-none" />
             <select
               value={status}
               onChange={handleStatusChange}
               className="pl-9 pr-8 py-2 bg-white border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary appearance-none cursor-pointer hover:bg-background-light transition-colors"
             >
               <option value="all">All Status</option>
               <option value="draft">Draft</option>
               <option value="submitted">Submitted</option>
               <option value="under_review">Under Review</option>
               <option value="quoted">Quoted</option>
               <option value="approved">Approved</option>
               <option value="in_progress">In Progress</option>
               <option value="completed">Completed</option>
             </select>
          </div>
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" />
            <input 
              type="text" 
              placeholder="Search projects..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9 pr-4 py-2 bg-white border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary w-64"
            />
          </div>
        </div>
      </div>

      <div className="bg-surface rounded-xl shadow-sm border border-border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-background-light border-b border-border">
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Project Name</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Client</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Type</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Date</th>
                <th className="px-6 py-4 text-right text-xs font-semibold text-text-secondary uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-text-secondary">Loading projects...</td>
                </tr>
              ) : data?.projects.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-text-secondary">No projects found matching your criteria.</td>
                </tr>
              ) : (
                data?.projects.map((project: Project) => (
                  <tr key={project._id} className="hover:bg-background-light/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-text">{project.title || 'Untitled Project'}</div>
                      <div className="text-xs text-text-secondary font-mono mt-0.5">ID: {project._id.slice(-6)}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-8 w-8 rounded-full bg-secondary/10 flex items-center justify-center text-secondary font-bold text-xs mr-3">
                          {project.user_id?.full_name?.charAt(0) || 'U'}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-text">{project.user_id?.full_name || 'Unknown User'}</div>
                          <div className="text-xs text-text-secondary">{project.user_id?.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-text-secondary capitalize">
                      {project.type?.replace('_', ' ') || 'Interior Design'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border ${getStatusColor(project.status || 'draft')}`}>
                        {(project.status || 'draft').replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-text-secondary">
                      {format(new Date(project.createdAt), 'MMM d, yyyy')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button 
                        onClick={() => navigate(`/projects/${project._id}`)}
                        className="text-text-secondary hover:text-primary transition-colors p-1"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        
        {/* Pagination */}
        {!isLoading && data?.pagination && (
          <div className="bg-white px-6 py-4 border-t border-border flex items-center justify-between">
            <div className="text-sm text-text-secondary">
              Showing <span className="font-medium">{data.pagination.total === 0 ? 0 : (data.pagination.page - 1) * limit + 1}</span> to <span className="font-medium">{Math.min(data.pagination.page * limit, data.pagination.total)}</span> of <span className="font-medium">{data.pagination.total}</span> results
            </div>
            <div className="flex gap-2">
              <button 
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-2 rounded-lg border border-border hover:bg-background-light disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronLeft className="w-4 h-4 text-text-secondary" />
              </button>
              <button 
                onClick={() => setPage(p => Math.min(data.pagination.pages, p + 1))}
                disabled={page >= data.pagination.pages}
                className="p-2 rounded-lg border border-border hover:bg-background-light disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <ChevronRight className="w-4 h-4 text-text-secondary" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Projects;
