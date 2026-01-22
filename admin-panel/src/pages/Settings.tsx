import React, { useState } from 'react';
import { User, Lock } from 'lucide-react';
import api from '@/services/api';
import { useQuery } from '@tanstack/react-query';

import { useToast } from '@/context/ToastContext';

const Settings: React.FC = () => {
  const { success, error: toastError } = useToast();
  const [loading, setLoading] = useState(false);
  const [passwordData, setPasswordData] = useState({ currentPassword: '', newPassword: '' });
  const [profileData, setProfileData] = useState({ full_name: '', email: '' });

  // Fetch current user details
  const { data: user } = useQuery({
    queryKey: ['adminProfile'],
    queryFn: async () => {
      // In a real app, you might have a /me endpoint, or use the stored user
      // For now, let's assume we store user in localStorage or have a context
      // But better to fetch fresh
      // Using /admin/users with a filter or just relying on local state if we don't have a /me
      // Let's create a pseudo fetch from localStorage for initial state if no /me endpoint
      const stored = localStorage.getItem('user');
      return stored ? JSON.parse(stored) : null;
    }
  });

  // Initialize form with user data
  React.useEffect(() => {
    if (user) {
      setProfileData({ full_name: user.full_name || '', email: user.email || '' });
    }
  }, [user]);

  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.put('/admin/profile', profileData);
      // Update local storage if successful
      const currentUser = JSON.parse(localStorage.getItem('user') || '{}');
      localStorage.setItem('user', JSON.stringify({ ...currentUser, ...res.data.data }));
      success('Profile updated successfully');
    } catch (error: unknown) {
      const err = error as { response?: { data?: { message?: string } } };
      toastError(err.response?.data?.message || 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await api.put('/admin/change-password', passwordData);
      success('Password updated successfully');
      setPasswordData({ currentPassword: '', newPassword: '' });
    } catch (error: unknown) {
      const err = error as { response?: { data?: { message?: string } } };
      toastError(err.response?.data?.message || 'Failed to update password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold font-display text-text">Settings</h2>
        <p className="text-text-secondary mt-1">Manage your account and system preferences.</p>
      </div>

      <div className="grid gap-6">
        {/* Profile Section */}
        <div className="bg-surface rounded-xl shadow-sm border border-border p-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-2 bg-primary/10 rounded-lg text-primary">
              <User className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-semibold text-text">Profile Information</h3>
          </div>
          
          <form onSubmit={handleProfileUpdate}>
            <div className="grid md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Full Name</label>
                <input 
                  type="text" 
                  readOnly
                  value={profileData.full_name}
                  onChange={(e) => setProfileData({ ...profileData, full_name: e.target.value })}
                  className="w-full px-4 py-2 bg-background border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Email Address</label>
                <input 
                  type="email" 
                  readOnly
                  value={profileData.email}
                  onChange={(e) => setProfileData({ ...profileData, email: e.target.value })}
                  className="w-full px-4 py-2 bg-background border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                />
              </div>
            </div>
            
            {/* <div className="mt-6 flex justify-end">
              <button 
                type="submit" 
                disabled={loading}
                className="px-4 py-2 bg-primary text-white text-sm font-medium rounded-lg hover:bg-primary-dark transition-colors disabled:opacity-50"
              >
                {loading ? 'Saving...' : 'Save Changes'}
              </button>
            </div> */}
          </form>
        </div>

        {/* Security Section */}
        <div className="bg-surface rounded-xl shadow-sm border border-border p-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-2 bg-secondary/10 rounded-lg text-secondary">
              <Lock className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-semibold text-text">Security</h3>
          </div>
          
          <div className="space-y-4">
            <div className="p-4 bg-background-light rounded-lg border border-border/50">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h4 className="text-sm font-medium text-text">Change Password</h4>
                  <p className="text-xs text-text-secondary mt-1">Update your password regularly to keep your account secure.</p>
                </div>
              </div>
              <form onSubmit={handlePasswordUpdate} className="space-y-3">
                <div className="grid md:grid-cols-2 gap-4">
                   <input 
                    type="password" 
                    placeholder="Current Password"
                    value={passwordData.currentPassword}
                    onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
                    className="w-full px-4 py-2 bg-white border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                  />
                  <input 
                    type="password" 
                    placeholder="New Password"
                    value={passwordData.newPassword}
                    onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
                    className="w-full px-4 py-2 bg-white border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                  />
                </div>
                <div className="flex justify-end mt-2">
                  <button 
                    type="submit"
                    disabled={loading}
                    className="px-3 py-1.5 border border-border rounded-md text-xs font-medium text-text hover:bg-white transition-colors"
                  >
                    Update Password
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
