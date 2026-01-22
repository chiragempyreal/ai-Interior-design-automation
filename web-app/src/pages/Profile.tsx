import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Mail, Phone, LogOut, Save, Loader2 } from 'lucide-react';
import Header from '../components/Header';
import Modal from '../components/Modal';
import api from '../services/api';

const Profile: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<{
    isOpen: boolean;
    title: string;
    message: string;
    type: 'success' | 'error' | 'info';
  }>({
    isOpen: false,
    title: '',
    message: '',
    type: 'info'
  });

  const showModal = (title: string, message: string, type: 'success' | 'error' | 'info' = 'info') => {
    setModal({ isOpen: true, title, message, type });
  };

  const closeModal = () => {
    setModal(prev => ({ ...prev, isOpen: false }));
  };

  const [user, setUser] = useState<{
    full_name: string;
    email: string;
    phone: string;
  }>({
    full_name: '',
    email: '',
    phone: ''
  });

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (!storedUser) {
      navigate('/login');
      return;
    }
    const parsedUser = JSON.parse(storedUser);
    setUser({
      full_name: parsedUser.full_name || '',
      email: parsedUser.email || '',
      phone: parsedUser.phone || ''
    });
  }, [navigate]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setUser({ ...user, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await api.put('/auth/profile', user);
      
      // Update local storage
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
        const parsedUser = JSON.parse(storedUser);
        const updatedUser = { ...parsedUser, ...user };
        localStorage.setItem('user', JSON.stringify(updatedUser));
      }

      showModal("Success", "Profile updated successfully.", "success");
    } catch (error: any) { // eslint-disable-line @typescript-eslint/no-explicit-any
      showModal("Error", error.response?.data?.message || 'Failed to update profile', "error");
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-background relative overflow-hidden font-sans text-text">
       {/* Background Elements */}
       <div className="fixed inset-0 z-0 pointer-events-none">
        <div className="absolute top-[-10%] right-[-5%] w-[500px] h-[500px] bg-primary/5 rounded-full blur-[100px]" />
        <div className="absolute bottom-[-10%] left-[-5%] w-[500px] h-[500px] bg-accent-warm/5 rounded-full blur-[100px]" />
      </div>

      <Header />

      <div className="relative z-10 pt-32 pb-20 px-6 max-w-4xl mx-auto">
        <div className="bg-white/80 backdrop-blur-md border border-white/20 rounded-2xl shadow-xl p-8 md:p-12">
            <div className="flex justify-between items-center mb-8 border-b border-charcoal/5 pb-6">
                <div>
                    <h1 className="text-3xl font-playfair font-bold text-charcoal mb-2">My Profile</h1>
                    <p className="text-charcoal/60">Manage your personal information and account settings</p>
                </div>
                <button 
                    onClick={handleLogout}
                    className="flex items-center gap-2 text-red-500 hover:text-red-600 transition-colors font-medium px-4 py-2 rounded-lg hover:bg-red-50"
                >
                    <LogOut size={18} />
                    Logout
                </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6 max-w-2xl">
                <div className="grid md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                        <label className="block text-sm font-bold text-charcoal/80 uppercase tracking-wider">Full Name</label>
                        <div className="relative">
                            <User className="absolute left-3 top-1/2 -translate-y-1/2 text-charcoal/40" size={18} />
                            <input
                                type="text"
                                name="full_name"
                                value={user.full_name}
                                onChange={handleChange}
                                className="w-full pl-10 pr-4 py-3 bg-white border border-charcoal/10 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                                placeholder="John Doe"
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <label className="block text-sm font-bold text-charcoal/80 uppercase tracking-wider">Phone Number</label>
                        <div className="relative">
                            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 text-charcoal/40" size={18} />
                            <input
                                type="tel"
                                name="phone"
                                value={user.phone}
                                onChange={handleChange}
                                className="w-full pl-10 pr-4 py-3 bg-white border border-charcoal/10 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                                placeholder="+1 (555) 000-0000"
                            />
                        </div>
                    </div>

                    <div className="space-y-2 md:col-span-2">
                        <label className="block text-sm font-bold text-charcoal/80 uppercase tracking-wider">Email Address</label>
                        <div className="relative">
                            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-charcoal/40" size={18} />
                            <input
                                type="email"
                                name="email"
                                value={user.email}
                                onChange={handleChange}
                                className="w-full pl-10 pr-4 py-3 bg-white border border-charcoal/10 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                                placeholder="john@example.com"
                            />
                        </div>
                    </div>
                </div>

                <div className="pt-4">
                    <button
                        type="submit"
                        disabled={loading}
                        className="flex items-center gap-2 bg-primary text-white px-8 py-3 rounded-full font-bold uppercase tracking-wider hover:bg-primary-dark transition-all disabled:opacity-70 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                    >
                        {loading ? (
                            <>
                                <Loader2 size={18} className="animate-spin" />
                                Saving...
                            </>
                        ) : (
                            <>
                                <Save size={18} />
                                Save Changes
                            </>
                        )}
                    </button>
                </div>
            </form>
        </div>
      </div>

      <Modal 
        isOpen={modal.isOpen}
        onClose={closeModal}
        title={modal.title}
        message={modal.message}
        type={modal.type}
      />
    </div>
  );
};

export default Profile;
