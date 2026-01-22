/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import Header from '../components/Header';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [showOtp, setShowOtp] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, '');
    if (value.length <= 10) {
      setPhone(value);
    }
  };

  const handleSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!phone) {
      setError('Please enter your mobile number');
      return;
    }
    if (phone.length !== 10) {
      setError('Please enter a valid 10-digit mobile number');
      return;
    }
    setError('');
    setIsLoading(true);
    try {
      await api.post('/auth/send-otp', { phone });
      setShowOtp(true);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to send OTP');
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!otp) {
      setError('Please enter the OTP');
      return;
    }
    setError('');
    setIsLoading(true);
    try {
      const response = await api.post('/auth/verify-otp', { phone, otp });
      const { accessToken, user } = response.data.data;
      
      if (accessToken) {
        localStorage.setItem('token', accessToken);
        localStorage.setItem('user', JSON.stringify(user));
        
        // Update api headers immediately for subsequent requests in the same session
        api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`;
        
        const from = (location as any).state?.from?.pathname || '/wizard';
        navigate(from, { replace: true });
      } else {
        throw new Error('No access token received');
      }
    } catch (err: any) { // eslint-disable-line @typescript-eslint/no-explicit-any
      setError(err.response?.data?.message || 'Invalid OTP');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col relative overflow-x-hidden bg-background-light font-display">
      <div className="fixed inset-0 architectural-pattern opacity-[0.05] pointer-events-none"></div>

      {/* Header */}
      <Header />

      {/* Main Content */}
      <main className="flex-1 flex flex-col items-center justify-center px-4 py-20 relative z-10 max-w-[1920px] mx-auto w-full">
        <div className="text-center mb-16">
          <h1 className="text-charcoal text-[36px] font-bold tracking-[0.25em] uppercase leading-tight pb-3">
            Welcome to DesignQuote AI
          </h1>
          <p className="font-serif italic text-xl text-primary/80">
            Log in or create an account with your mobile number.
          </p>
        </div>

        <div className="w-full max-w-[550px] bg-white rounded-arch shadow-[0_40px_80px_-20px_rgba(42,66,53,0.12)] overflow-hidden flex flex-col min-h-[500px] border border-white p-14 md:p-20">
          <div className="mb-10">
            <h3 className="font-geist text-primary mb-3 text-[11px] font-bold tracking-[0.15em] uppercase">
              {showOtp ? 'Verification' : 'Get Started'}
            </h3>
            <h2 className="text-3xl font-bold text-charcoal tracking-tight">
              {showOtp ? 'Enter OTP' : 'Login / Register'}
            </h2>
          </div>

          {error && (
            <div className="mb-6 p-4 bg-red-50 text-red-500 text-sm rounded-xl border border-red-100 font-geist">
              {error}
            </div>
          )}

          {!showOtp ? (
            <form className="space-y-6" onSubmit={handleSendOtp}>
              <div className="space-y-2">
                <label className="font-geist text-text-secondary text-[10px] font-bold tracking-[0.15em] uppercase">Mobile Number</label>
                <div className="relative">
                  <span className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 font-geist text-sm">+91</span>
                  <input 
                  className="w-full pl-14 pr-5 py-4 rounded-xl border border-border bg-background-light/20 focus:border-primary focus:ring-0 focus:outline-none transition-all placeholder:text-zinc-300 font-geist" 
                  placeholder="9876543210" 
                  type="tel" 
                  value={phone}
                  onChange={handlePhoneChange}
                  required
                />
                </div>
              </div>
              <button 
                className="w-full h-14 bg-primary text-white rounded-full font-geist text-sm font-bold tracking-[0.15em] hover:bg-primary-dark transition-all transform hover:-translate-y-1 mt-4 shadow-lg shadow-primary/10 cursor-pointer disabled:opacity-70 disabled:cursor-not-allowed" 
                type="submit"
                disabled={isLoading}
              >
                {isLoading ? 'SENDING...' : 'GET OTP'}
              </button>
            </form>
          ) : (
            <form className="space-y-6" onSubmit={handleVerifyOtp}>
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <label className="font-geist text-text-secondary text-[10px] font-bold tracking-[0.15em] uppercase">Enter 6-digit OTP</label>
                  <button 
                    type="button"
                    onClick={() => setShowOtp(false)}
                    className="font-geist text-[9px] text-primary/60 hover:text-primary transition-colors font-bold tracking-[0.15em] uppercase"
                  >
                    Change Number
                  </button>
                </div>
                <input 
                  className="w-full px-5 py-4 rounded-xl border border-border bg-background-light/20 focus:border-primary focus:ring-0 focus:outline-none transition-all placeholder:text-zinc-300 text-center tracking-[0.5em] text-xl font-bold font-geist" 
                  placeholder="••••••" 
                  type="text" 
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  required
                />
                <p className="text-[10px] text-zinc-400 text-center mt-2">
                  OTP sent to +91 {phone}. Use <span className="text-primary font-bold">123456</span>
                </p>
              </div>
              <button 
                className="w-full h-14 bg-primary text-white rounded-full font-geist text-sm font-bold tracking-[0.15em] hover:bg-primary-dark transition-all transform hover:-translate-y-1 mt-4 shadow-lg shadow-primary/10 cursor-pointer disabled:opacity-70 disabled:cursor-not-allowed" 
                type="submit"
                disabled={isLoading}
              >
                {isLoading ? 'VERIFYING...' : 'VERIFY & CONTINUE'}
              </button>
            </form>
          )}

          <div className="mt-10 pt-10 border-t border-border/30">
            <p className="text-[11px] text-zinc-400 leading-relaxed text-center">
              By continuing, you agree to DesignQuote AI's{' '}
              <a className="underline text-primary/80 hover:text-primary transition-colors" href="#">Terms</a> and{' '}
              <a className="underline text-primary/80 hover:text-primary transition-colors" href="#">Privacy</a>.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 px-10 pt-24 pb-12 bg-background-light w-full border-t border-border/20">
        <div className="max-w-[1920px] mx-auto">
          <div className="flex flex-col md:flex-row justify-between items-center gap-8">
            <div className="flex items-center gap-4">
              <div className="interlocking-circles scale-75">
                <div className="circle-gold"></div>
                <div className="circle-green"></div>
              </div>
              <span className="text-charcoal text-[11px] font-bold tracking-[0.2em] uppercase">DesignQuote AI</span>
            </div>
            <div className="text-[10px] text-zinc-400 font-bold tracking-[0.1em] uppercase">
              © 2026 DESIGNQUOTE AI. ALL RIGHTS RESERVED.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Login;