import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import api from '@/services/api';
import { format } from 'date-fns';
import { Search, Filter, MoreHorizontal, ChevronLeft, ChevronRight, Mail, Shield, Trash2, Eye } from 'lucide-react';

interface User {
  _id: string;
  full_name: string;
  email: string;
  role_id: {
    name: string;
    display_name: string;
  };
  createdAt: string;
}

const Users: React.FC = () => {
  const [page, setPage] = useState(1);
  const limit = 10;
  const [actionOpen, setActionOpen] = useState<string | null>(null);

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['users', page],
    queryFn: async () => {
      const res = await api.get(`/admin/users?page=${page}&limit=${limit}`);
      return res.data.data;
    }
  });

  const handleDelete = async (userId: string) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        // Implement delete API call here if available, or just log for now
        // await api.delete(`/admin/users/${userId}`);
        console.log('Deleting user:', userId);
        alert('Delete functionality to be implemented in backend');
      } catch (error) {
        console.error('Error deleting user:', error);
      }
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold font-display text-text">Users</h2>
          <p className="text-text-secondary mt-1">Manage system users and their roles.</p>
        </div>
        <div className="flex gap-3">
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" />
            <input 
              type="text" 
              placeholder="Search users..." 
              className="pl-9 pr-4 py-2 bg-white border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary w-64"
            />
          </div>
        </div>
      </div>

      <div className="bg-surface rounded-xl shadow-sm border border-border overflow-hidden min-h-[400px]">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-background-light border-b border-border">
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">User</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Role</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider">Joined Date</th>
                <th className="px-6 py-4 text-right text-xs font-semibold text-text-secondary uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-text-secondary">Loading users...</td>
                </tr>
              ) : data?.users.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-text-secondary">No users found.</td>
                </tr>
              ) : (
                data?.users.map((user: User) => (
                  <tr key={user._id} className="hover:bg-background-light/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-sm mr-3">
                          {user.full_name?.charAt(0) || 'U'}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-text">{user.full_name || 'Unknown User'}</div>
                          <div className="flex items-center text-xs text-text-secondary mt-0.5">
                            <Mail className="w-3 h-3 mr-1" />
                            {user.email}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <Shield className="w-3.5 h-3.5 mr-1.5 text-text-secondary" />
                        <span className="text-sm text-text capitalize">{user.role_id?.display_name || user.role_id?.name || 'User'}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-success/10 text-success border border-success/20">
                        Active
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-text-secondary">
                      {format(new Date(user.createdAt), 'MMM d, yyyy')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium relative">
                      <div className="flex items-center justify-end gap-2">
                        <button className="text-text-secondary hover:text-primary transition-colors p-1" title="View Details">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleDelete(user._id)}
                          className="text-text-secondary hover:text-error transition-colors p-1" 
                          title="Delete User"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
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
              Showing <span className="font-medium">{(data.pagination.page - 1) * limit + 1}</span> to <span className="font-medium">{Math.min(data.pagination.page * limit, data.pagination.total)}</span> of <span className="font-medium">{data.pagination.total}</span> results
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
                disabled={page === data.pagination.pages}
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

export default Users;
