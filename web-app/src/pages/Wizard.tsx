import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  ChevronRight, ChevronLeft, Upload, Layout, 
  Palette, DollarSign, CheckCircle, Image as ImageIcon,
  Loader2, Sparkles, MapPin, User, Mail, Phone, Ruler, X, TrendingUp, Music, Wind, Fingerprint
} from 'lucide-react';
import api from '../services/api';
import Header from '../components/Header';
import Modal from '../components/Modal';

interface WizardData {
  title: string;
  clientName: string;
  clientEmail: string;
  clientPhone: string;
  projectType: 'Residential' | 'Commercial';
  propertyType: string;
  spaceType: string;
  area: number;
  location: { city: string; pincode: string };
  photos: string[];
  stylePreferences: { style: string; colors: string[] };
  materials: { flooring: string; walls: string; furniture: string; lighting: string };
  budget: { min: number; max: number };
  timeline: string;
}

const initialData: WizardData = {
  title: '',
  clientName: '',
  clientEmail: '',
  clientPhone: '',
  projectType: 'Residential',
  propertyType: 'Apartment',
  spaceType: 'Living Room',
  area: 400,
  location: { city: '', pincode: '' },
  photos: [],
  stylePreferences: { style: 'Modern', colors: [] },
  materials: { flooring: '', walls: '', furniture: '', lighting: '' },
  budget: { min: 500000, max: 1000000 },
  timeline: 'Flexible'
};

const Wizard: React.FC = () => {
  const [step, setStep] = useState(1);
  const [data, setData] = useState<WizardData>(initialData);
  const [projectId, setProjectId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [aiPreview, setAiPreview] = useState<string | null>(null);
  const [aiAnalysis, setAiAnalysis] = useState<{ rationale: string; estimatedCostRange: string } | null>(null);
  const [roiData, setRoiData] = useState<{
    estimatedIncreaseInValue: number;
    roiPercentage: number;
    investmentScore: number;
    marketTrendAlignment: string;
  } | null>(null);
  const [designDNA, setDesignDNA] = useState<{
    personaName: string;
    personalityTraits: string[];
    colorPsychology: string;
    recommendedScent: string;
    playlistVibe: string;
    colorPalette: Array<{ name: string; hex: string; mood: string }>;
  } | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

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

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      const user = JSON.parse(storedUser);
      setData(prev => ({
        ...prev,
        clientName: user.full_name || prev.clientName,
        clientEmail: user.email || prev.clientEmail,
        clientPhone: user.phone || prev.clientPhone,
      }));
    }
  }, []);

  const totalSteps = 7; 

  const updateData = (field: keyof WizardData, value: unknown) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

  const updateNestedData = (parent: keyof WizardData, field: string, value: unknown) => {
    setData(prev => ({
      ...prev,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      [parent]: { ...prev[parent] as any, [field]: value }
    }));
  };

  const getImageUrl = (path: string) => {
    if (!path) return '';
    if (path.startsWith('http') || path.startsWith('data:')) return path;
    const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5001/api/v1';
    const rootUrl = baseUrl.replace(/\/api\/v1\/?$/, '');
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `${rootUrl}${cleanPath}`;
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      handleUpload(Array.from(e.dataTransfer.files));
    }
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      handleUpload(Array.from(e.target.files));
    }
  };

  const handleUpload = async (files: File[]) => {
    if (!projectId) {
      alert("Please ensure basic details are saved first.");
      return;
    }
    
    setUploading(true);
    const formData = new FormData();
    files.forEach(file => {
      formData.append('photos', file);
    });

    try {
      const res = await api.post(`/projects/${projectId}/upload`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      if (res.data.success) {
        updateData('photos', res.data.data.photos);
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('Failed to upload photos');
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handleRemovePhoto = async (photoUrl: string) => {
    const newPhotos = data.photos.filter(p => p !== photoUrl);
    updateData('photos', newPhotos);
    if (projectId) {
      try {
        await api.put(`/projects/${projectId}`, { photos: newPhotos });
      } catch (err) {
        console.error('Failed to sync photo removal', err);
      }
    }
  };

  const handleNext = async () => {
    setLoading(true);
    try {
      if (step === 1) {
        // Auto-update profile if logged in
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
           const user = JSON.parse(storedUser);
           // Only update if changed
           if (data.clientName !== user.full_name || data.clientEmail !== user.email || data.clientPhone !== user.phone) {
              try {
                  await api.put('/auth/profile', {
                      full_name: data.clientName,
                      email: data.clientEmail,
                      phone: data.clientPhone
                  });
                  // Update local storage
                  const updatedUser = { ...user, full_name: data.clientName, email: data.clientEmail, phone: data.clientPhone };
                  localStorage.setItem('user', JSON.stringify(updatedUser));
              } catch (err) {
                  console.error("Failed to update profile", err);
              }
           }
        }

        const res = await api.post('/projects', {
          title: data.title || `${data.clientName}'s ${data.spaceType}`,
          clientName: data.clientName,
          clientEmail: data.clientEmail,
          clientPhone: data.clientPhone,
          projectType: data.projectType
        });
        setProjectId(res.data.data._id);
      } else if (projectId && step < totalSteps) {
        await api.put(`/projects/${projectId}`, data);
      }

      if (step < totalSteps) {
        setStep(s => s + 1);
      } else if (step === totalSteps) {
        setStep(8); // Move to Loading Step
        generatePreview();
      }
    } catch (error) {
      console.error('Error saving step:', error);
      alert('Failed to save progress. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const generatePreview = async () => {
    if (!projectId) return;
    try {
      const res = await api.post(`/projects/${projectId}/preview`);
      setAiPreview(res.data.data.previewUrl);
      if (res.data.data.analysis) {
        setAiAnalysis(res.data.data.analysis);
      }
      if (res.data.data.roi) {
        setRoiData(res.data.data.roi);
      }
      if (res.data.data.designDNA) {
        setDesignDNA(res.data.data.designDNA);
      }
      setStep(9); 
    } catch (error) {
      console.error('AI Gen Error:', error);
      alert('Failed to generate preview');
      setStep(totalSteps); // Go back to review
    }
  };

  const handleGetQuote = async () => {
    if (!projectId) return;
    setLoading(true);
    try {
      await api.put(`/projects/${projectId}`, { status: 'submitted' });
      showModal("Success!", "Quote request submitted successfully! We will contact you shortly.", "success");
    } catch (error) {
      console.error('Quote Request Error:', error);
      showModal("Submission Failed", "Failed to submit quote request", "error");
    } finally {
      setLoading(false);
    }
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <div className="space-y-12 animate-fade-up">
            <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 01</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Let's start with the basics</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Tell us a bit about yourself so we can personalize your experience.</p>
            </div>
            <div className="grid grid-cols-1 gap-8 max-w-2xl">
              <div className="relative group">
                <User className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 group-focus-within:text-primary transition-colors" />
                <input
                  type="text"
                  placeholder="Your Name"
                  className="block w-full pl-14 pr-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal placeholder:text-charcoal/30 focus:ring-0 focus:border-primary transition-all shadow-sm hover:border-charcoal/20"
                  value={data.clientName}
                  onChange={e => updateData('clientName', e.target.value)}
                />
              </div>
              <div className="relative group">
                <Mail className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 group-focus-within:text-primary transition-colors" />
                <input
                  type="email"
                  placeholder="Email Address"
                  className="block w-full pl-14 pr-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal placeholder:text-charcoal/30 focus:ring-0 focus:border-primary transition-all shadow-sm hover:border-charcoal/20"
                  value={data.clientEmail}
                  onChange={e => updateData('clientEmail', e.target.value)}
                />
              </div>
              <div className="relative group">
                <Phone className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 group-focus-within:text-primary transition-colors" />
                <input
                  type="tel"
                  placeholder="Phone Number"
                  className="block w-full pl-14 pr-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal placeholder:text-charcoal/30 focus:ring-0 focus:border-primary transition-all shadow-sm hover:border-charcoal/20"
                  value={data.clientPhone}
                  onChange={e => updateData('clientPhone', e.target.value)}
                />
              </div>
              <div className="relative">
                <select
                  className="block w-full px-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal focus:ring-0 focus:border-primary transition-all shadow-sm appearance-none hover:border-charcoal/20 cursor-pointer"
                  value={data.projectType}
                  onChange={e => updateData('projectType', e.target.value)}
                >
                  <option value="Residential">Residential Project</option>
                  <option value="Commercial">Commercial Project</option>
                </select>
                <ChevronRight className="absolute right-6 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 rotate-90 pointer-events-none" />
              </div>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-12 animate-fade-up">
            <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 02</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Tell us about your space</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">What kind of property are we designing today?</p>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl">
              <div className="md:col-span-2 space-y-4">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">Property Type</label>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                  {['Apartment', 'Villa', 'Office', 'Retail'].map((type) => (
                    <button
                      key={type}
                      onClick={() => updateData('propertyType', type)}
                      className={`py-5 px-6 rounded-xl border transition-all duration-300 font-medium ${
                        data.propertyType === type
                          ? 'border-primary bg-primary text-white shadow-lg shadow-primary/20 scale-[1.02]'
                          : 'border-charcoal/10 bg-white text-charcoal hover:border-primary/50 hover:bg-primary/5'
                      }`}
                    >
                      {type}
                    </button>
                  ))}
                </div>
              </div>

              <div className="md:col-span-2 space-y-4">
                 <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">Space to Design</label>
                 <div className="relative">
                   <select
                    className="block w-full px-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal focus:ring-0 focus:border-primary transition-all shadow-sm appearance-none cursor-pointer hover:border-charcoal/20"
                    value={data.spaceType}
                    onChange={e => updateData('spaceType', e.target.value)}
                  >
                    <option value="Living Room">Living Room</option>
                    <option value="Bedroom">Bedroom</option>
                    <option value="Kitchen">Kitchen</option>
                    <option value="Full Home">Full Home</option>
                    <option value="Office Cabin">Office Cabin</option>
                  </select>
                  <ChevronRight className="absolute right-6 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 rotate-90 pointer-events-none" />
                 </div>
              </div>

              <div className="space-y-4">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">Area (sqft)</label>
                <div className="relative group">
                  <Ruler className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 group-focus-within:text-primary transition-colors" />
                  <input
                    type="number"
                    className="block w-full pl-14 pr-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal focus:ring-0 focus:border-primary transition-all shadow-sm hover:border-charcoal/20"
                    value={data.area}
                    onChange={e => updateData('area', Number(e.target.value))}
                  />
                </div>
              </div>

              <div className="space-y-4">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">City</label>
                <div className="relative group">
                  <MapPin className="absolute left-5 top-1/2 -translate-y-1/2 text-charcoal/40 h-5 w-5 group-focus-within:text-primary transition-colors" />
                  <input
                    type="text"
                    placeholder="e.g. Mumbai"
                    className="block w-full pl-14 pr-6 py-5 rounded-xl border border-charcoal/10 bg-white text-charcoal focus:ring-0 focus:border-primary transition-all shadow-sm hover:border-charcoal/20"
                    value={data.location.city}
                    onChange={e => updateNestedData('location', 'city', e.target.value)}
                  />
                </div>
              </div>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-12 animate-fade-up">
             <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 03</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Upload Photos</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Show us your current space (optional but recommended).</p>
            </div>
            
            <input
              type="file"
              ref={fileInputRef}
              className="hidden"
              multiple
              accept="image/*"
              onChange={handleFileSelect}
            />
            
            <div 
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onDrop={handleDrop}
              onClick={() => fileInputRef.current?.click()}
              className={`border border-dashed rounded-[2rem] p-20 text-center transition-all duration-500 cursor-pointer group relative overflow-hidden ${
                isDragging 
                  ? 'border-primary bg-primary/5 scale-[1.02]' 
                  : 'border-charcoal/20 bg-white/50 hover:border-primary hover:bg-white hover:shadow-xl hover:shadow-primary/5'
              }`}
            >
              {uploading && (
                <div className="absolute inset-0 bg-white/90 flex items-center justify-center z-10 backdrop-blur-sm">
                  <div className="flex flex-col items-center">
                    <Loader2 className="h-10 w-10 text-primary animate-spin mb-3" />
                    <p className="font-medium text-charcoal font-geist tracking-widest uppercase text-xs">Uploading...</p>
                  </div>
                </div>
              )}
              
              <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-primary/5 mb-8 group-hover:scale-110 group-hover:bg-primary/10 transition-all duration-500">
                <Upload className="h-10 w-10 text-primary" />
              </div>
              <p className="text-xl font-serif italic text-charcoal mb-2">Click to upload or drag and drop</p>
              <p className="text-sm font-geist text-charcoal/40 uppercase tracking-widest">SVG, PNG, JPG or GIF (max. 5MB)</p>
            </div>

            {data.photos.length > 0 && (
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-6 mt-8">
                {data.photos.map((photo, index) => (
                  <div key={index} className="group relative aspect-square bg-white rounded-2xl border border-charcoal/10 overflow-hidden shadow-sm hover:shadow-md transition-all">
                    <img 
                      src={getImageUrl(photo)} 
                      alt={`Space ${index + 1}`} 
                      className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
                    />
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleRemovePhoto(photo);
                      }}
                      className="absolute top-3 right-3 p-2 bg-white/90 backdrop-blur rounded-full text-charcoal/60 hover:text-red-500 hover:bg-white transition-all shadow-sm opacity-0 group-hover:opacity-100 transform translate-y-2 group-hover:translate-y-0"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {data.photos.length === 0 && (
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 opacity-30 mt-8 pointer-events-none">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="aspect-square bg-charcoal/5 rounded-2xl border border-charcoal/5 flex items-center justify-center text-charcoal/20">
                    <ImageIcon className="w-8 h-8" />
                  </div>
                ))}
              </div>
            )}
          </div>
        );

      case 4:
        return (
          <div className="space-y-12 animate-fade-up">
            <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 04</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Choose your style</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Which aesthetic resonates with you the most?</p>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
              {['Modern', 'Minimalist', 'Industrial', 'Scandinavian', 'Bohemian', 'Classic'].map((style) => (
                <motion.div
                  key={style}
                  whileHover={{ y: -5 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => updateNestedData('stylePreferences', 'style', style)}
                  className={`cursor-pointer p-8 rounded-[2rem] text-center transition-all duration-300 ${
                    data.stylePreferences.style === style 
                      ? 'bg-charcoal text-white shadow-xl shadow-charcoal/20' 
                      : 'bg-white text-charcoal border border-charcoal/10 hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5'
                  }`}
                >
                  <span className="text-lg font-serif italic">{style}</span>
                </motion.div>
              ))}
            </div>
          </div>
        );

      case 5:
        return (
          <div className="space-y-12 animate-fade-up">
            <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 05</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Material Preferences</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Select your preferred finishes.</p>
            </div>
            <div className="space-y-8 max-w-4xl">
              <div className="space-y-4">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">Flooring Preference</label>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                   {['Italian Marble', 'Wooden', 'Vitrified Tiles'].map((opt) => (
                     <button
                        key={opt}
                        onClick={() => updateNestedData('materials', 'flooring', opt)}
                        className={`py-4 px-6 rounded-xl text-sm font-medium border transition-all duration-300 ${
                          data.materials.flooring === opt
                            ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                            : 'bg-white text-charcoal border-charcoal/10 hover:border-primary/50 hover:bg-primary/5'
                        }`}
                     >
                       {opt}
                     </button>
                   ))}
                </div>
              </div>
              <div className="space-y-4">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 ml-1">Wall Finish</label>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                   {['Premium Paint', 'Wallpaper', 'Texture'].map((opt) => (
                     <button
                        key={opt}
                        onClick={() => updateNestedData('materials', 'walls', opt)}
                        className={`py-4 px-6 rounded-xl text-sm font-medium border transition-all duration-300 ${
                          data.materials.walls === opt
                            ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                            : 'bg-white text-charcoal border-charcoal/10 hover:border-primary/50 hover:bg-primary/5'
                        }`}
                     >
                       {opt}
                     </button>
                   ))}
                </div>
              </div>
            </div>
          </div>
        );

      case 6:
        return (
          <div className="space-y-12 animate-fade-up">
             <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 06</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Budget & Timeline</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Help us design within your means.</p>
            </div>
            <div className="bg-white p-8 rounded-[2rem] border border-charcoal/10 shadow-sm space-y-8">
              <div>
                <div className="flex justify-between items-center mb-6">
                  <label className="font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60">Estimated Budget</label>
                  <span className="text-2xl font-serif italic text-primary">₹{(data.budget.max / 100000).toFixed(1)} Lakhs</span>
                </div>
                <input
                  type="range"
                  min="100000"
                  max="5000000"
                  step="50000"
                  className="w-full h-3 bg-charcoal/10 rounded-lg appearance-none cursor-pointer accent-primary"
                  value={data.budget.max}
                  onChange={e => updateNestedData('budget', 'max', Number(e.target.value))}
                />
                <div className="flex justify-between text-xs text-charcoal/40 mt-3 font-geist tracking-wider uppercase">
                  <span>₹1L</span>
                  <span>₹50L+</span>
                </div>
              </div>
              
              <div className="pt-8 border-t border-charcoal/10">
                <label className="block font-geist text-[11px] font-bold uppercase tracking-[0.2em] text-charcoal/60 mb-6">Project Timeline</label>
                <div className="flex flex-col sm:flex-row gap-4">
                  {['Urgent (<1 mo)', 'Standard (1-2 mo)', 'Flexible'].map((t) => (
                    <button
                      key={t}
                      onClick={() => updateData('timeline', t)}
                      className={`flex-1 py-5 px-6 rounded-xl text-sm font-medium border transition-all duration-300 ${
                        data.timeline === t
                          ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                          : 'bg-white text-charcoal border-charcoal/10 hover:border-primary/50 hover:bg-primary/5'
                      }`}
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        );

      case 7:
        return (
          <div className="space-y-12 animate-fade-up">
            <div className="text-center md:text-left space-y-4">
              <span className="font-geist text-[11px] font-bold uppercase tracking-[0.4em] text-primary">Step 07</span>
              <h3 className="text-4xl md:text-5xl font-serif italic text-charcoal">Review your details</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-xl">Almost there! Review your preferences before we generate the design.</p>
            </div>
            <div className="bg-white rounded-[2rem] p-8 space-y-8 shadow-sm border border-charcoal/10">
              <div className="flex justify-between items-start border-b border-charcoal/10 pb-8">
                <div>
                  <h4 className="font-serif italic text-xl text-charcoal flex items-center mb-2"><User className="w-5 h-5 mr-3 text-primary"/> Client Details</h4>
                  <div className="pl-8 space-y-1">
                    <p className="text-charcoal/80">{data.clientName}</p>
                    <p className="text-charcoal/60 text-sm">{data.clientEmail}</p>
                  </div>
                </div>
                <button onClick={() => setStep(1)} className="text-primary hover:text-primary-dark text-xs font-bold uppercase tracking-widest hover:underline">Edit</button>
              </div>
              <div className="flex justify-between items-start border-b border-charcoal/10 pb-8">
                <div>
                  <h4 className="font-serif italic text-xl text-charcoal flex items-center mb-2"><Layout className="w-5 h-5 mr-3 text-primary"/> Space Details</h4>
                  <div className="pl-8 space-y-1">
                    <p className="text-charcoal/80">{data.spaceType} ({data.propertyType})</p>
                    <p className="text-charcoal/60 text-sm">{data.area} sqft • {data.location.city}</p>
                  </div>
                </div>
                <button onClick={() => setStep(2)} className="text-primary hover:text-primary-dark text-xs font-bold uppercase tracking-widest hover:underline">Edit</button>
              </div>
              <div className="flex justify-between items-start">
                <div>
                  <h4 className="font-serif italic text-xl text-charcoal flex items-center mb-2"><Palette className="w-5 h-5 mr-3 text-primary"/> Preferences</h4>
                  <div className="pl-8 space-y-1">
                    <p className="text-charcoal/80">{data.stylePreferences.style} Style</p>
                    <p className="text-charcoal/60 text-sm">Budget: ~₹{(data.budget.max / 100000).toFixed(1)}L</p>
                  </div>
                </div>
                <button onClick={() => setStep(4)} className="text-primary hover:text-primary-dark text-xs font-bold uppercase tracking-widest hover:underline">Edit</button>
              </div>
            </div>
          </div>
        );

      case 8:
        return (
          <div className="flex flex-col items-center justify-center min-h-[50vh] text-center space-y-8 animate-fade-up">
            <div className="relative">
              <div className="absolute inset-0 bg-primary/10 rounded-full animate-ping"></div>
              <div className="relative bg-white p-8 rounded-full shadow-2xl shadow-primary/10 border border-primary/20">
                <Loader2 className="w-16 h-16 text-primary animate-spin" />
              </div>
            </div>
            <div className="space-y-4">
              <h3 className="text-4xl font-serif italic text-charcoal animate-pulse">Designing your Dream Space...</h3>
              <p className="text-charcoal/60 font-inter text-lg max-w-md mx-auto leading-relaxed">
                Our AI is analyzing your preferences and generating a photorealistic preview. This usually takes about 10-15 seconds.
              </p>
            </div>
            <div className="flex space-x-3">
              <span className="w-2.5 h-2.5 bg-primary rounded-full animate-bounce [animation-delay:-0.3s]"></span>
              <span className="w-2.5 h-2.5 bg-primary rounded-full animate-bounce [animation-delay:-0.15s]"></span>
              <span className="w-2.5 h-2.5 bg-primary rounded-full animate-bounce"></span>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  if (step === 9 && aiPreview) {
    return (
          <div className="fixed inset-0 z-50 bg-background flex flex-col overflow-hidden">
            {/* Header */}
            <div className="h-16 border-b border-charcoal/10 flex items-center justify-between px-6 bg-white shrink-0 z-20 relative">
              <div className="flex items-center space-x-4">
                <button 
                  onClick={() => setStep(totalSteps)}
                  className="p-2 hover:bg-charcoal/5 rounded-full transition-colors"
                >
                  <X className="w-5 h-5 text-charcoal" />
                </button>
                <div>
                   <span className="font-geist text-[10px] font-bold uppercase tracking-widest text-primary block">Final Concept</span>
                   <h3 className="font-serif italic text-xl text-charcoal leading-none">Your Dream Space</h3>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                 <button className="hidden sm:flex items-center space-x-2 px-4 py-2 bg-charcoal/5 rounded-full text-[10px] font-bold uppercase tracking-widest text-charcoal/60 hover:bg-charcoal/10 transition-colors font-geist">
                    <Upload className="w-3.5 h-3.5" />
                    <span>Share</span>
                 </button>
                 <span className="bg-primary/10 text-primary px-3 py-1.5 rounded-full text-[10px] font-bold uppercase tracking-widest border border-primary/20 font-geist flex items-center">
                   <Sparkles className="w-3 h-3 mr-2" />
                   AI Generated
                 </span>
              </div>
            </div>
            
            <div className="flex-1 grid grid-cols-1 lg:grid-cols-12 gap-0 overflow-hidden">
              {/* Left Column - Image (7 cols) */}
              <div className="relative h-[40vh] lg:h-full lg:col-span-7 bg-charcoal/5 overflow-hidden flex items-center justify-center group">
                 {/* Blurred Background for Ambiance */}
                 <div 
                    className="absolute inset-0 bg-cover bg-center blur-2xl opacity-30 scale-110 transition-transform duration-700 group-hover:scale-125"
                    style={{ backgroundImage: `url(${aiPreview})` }}
                 />
                 <div className="absolute inset-0 bg-gradient-to-t from-charcoal/20 to-transparent pointer-events-none" />
                 
                 {/* Main Image - Contained to prevent stretching */}
                 <img 
                    src={aiPreview} 
                    alt="AI Design" 
                    className="relative w-full h-full object-contain z-10 transition-transform duration-700 hover:scale-[1.02]" 
                 />
              </div>

              {/* Right Column - Details (5 cols) */}
              <div className="lg:col-span-5 flex flex-col bg-white h-full border-l border-charcoal/10">
                 <div className="flex-1 overflow-y-auto p-6 lg:p-8 space-y-6">
                    
                    {/* Design Elements - Compact Grid */}
                    <div className="grid grid-cols-2 gap-3">
                      {[
                        { label: 'Style', value: data.stylePreferences.style, icon: Palette },
                        { label: 'Flooring', value: data.materials.flooring, icon: Layout },
                        { label: 'Walls', value: data.materials.walls, icon: Ruler },
                        { label: 'Budget', value: `₹${(data.budget.max / 100000).toFixed(1)}L`, icon: DollarSign }
                      ].map((item, i) => (
                        <div key={i} className="bg-charcoal/[0.02] p-3 rounded-xl border border-charcoal/5 flex items-center space-x-3 hover:border-charcoal/10 transition-colors">
                          <div className="bg-white p-2 rounded-lg shadow-sm border border-charcoal/5 text-charcoal/40">
                            <item.icon className="w-3.5 h-3.5" />
                          </div>
                          <div className="overflow-hidden">
                            <p className="text-charcoal/40 font-geist uppercase text-[8px] tracking-[0.2em] font-bold mb-0.5">{item.label}</p>
                            <p className="font-bold text-charcoal font-display text-xs truncate">{item.value || 'N/A'}</p>
                          </div>
                        </div>
                      ))}
                    </div>

                    {/* AI Analysis */}
                    {aiAnalysis && (
                      <div className="bg-primary/5 p-4 rounded-2xl border border-primary/10 relative overflow-hidden">
                        <div className="absolute top-0 right-0 p-3 opacity-10">
                           <Sparkles className="w-12 h-12 text-primary" />
                        </div>
                        <div className="flex justify-between items-start mb-2 relative z-10">
                           <h4 className="font-bold text-primary text-[10px] uppercase tracking-wider font-geist">AI Analysis</h4>
                           <span className="bg-white/80 px-2 py-0.5 rounded text-[9px] font-bold text-primary border border-primary/10 font-geist shadow-sm">
                             {aiAnalysis.estimatedCostRange}
                           </span>
                        </div>
                        <p className="text-charcoal/80 italic font-serif text-sm leading-relaxed relative z-10">"{aiAnalysis.rationale}"</p>
                      </div>
                    )}

                    {/* Design DNA */}
                    {designDNA && (
                      <div className="bg-gradient-to-r from-[#F8F6F1] to-[#E6C6A6]/10 p-5 rounded-2xl border border-[#D4A574]/20 shadow-sm">
                        <div className="flex justify-between items-center mb-4">
                          <h4 className="font-bold text-[#D4A574] text-[10px] uppercase tracking-wider flex items-center font-geist">
                            <Fingerprint className="w-3.5 h-3.5 mr-2" />
                            Design DNA
                          </h4>
                          <span className="bg-[#D4A574]/10 text-[#D4A574] text-[9px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider font-geist">
                            {designDNA.personaName}
                          </span>
                        </div>
                        
                        {/* Compact Color Palette */}
                        <div className="flex items-center space-x-2 mb-4">
                          {designDNA.colorPalette.map((color, idx) => (
                            <div key={idx} className="group relative flex-1">
                              <div 
                                className="h-6 w-full rounded shadow-sm border border-black/5 transition-transform group-hover:scale-105"
                                style={{ backgroundColor: color.hex }}
                              ></div>
                              <div className="opacity-0 group-hover:opacity-100 absolute -bottom-4 left-1/2 -translate-x-1/2 bg-charcoal text-white text-[8px] px-1.5 py-0.5 rounded whitespace-nowrap transition-opacity z-20">
                                {color.name}
                              </div>
                            </div>
                          ))}
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                          <div className="bg-white/60 p-2 rounded-lg flex items-center space-x-2 border border-charcoal/5">
                            <Wind className="w-3 h-3 text-[#D4A574] shrink-0" />
                            <div className="overflow-hidden">
                              <p className="text-[8px] text-charcoal/40 uppercase font-bold tracking-wider font-geist">Scent</p>
                              <p className="text-[10px] font-bold text-charcoal font-display truncate">{designDNA.recommendedScent}</p>
                            </div>
                          </div>
                          <div className="bg-white/60 p-2 rounded-lg flex items-center space-x-2 border border-charcoal/5">
                            <Music className="w-3 h-3 text-primary shrink-0" />
                            <div className="overflow-hidden">
                              <p className="text-[8px] text-charcoal/40 uppercase font-bold tracking-wider font-geist">Vibe</p>
                              <p className="text-[10px] font-bold text-charcoal font-display truncate">{designDNA.playlistVibe}</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    )}

                    {/* Investment Intelligence - Horizontal */}
                    {roiData && (
                      <div className="bg-gradient-to-br from-white to-primary/5 p-4 rounded-2xl border border-primary/10 shadow-sm">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="font-bold text-primary text-[10px] uppercase tracking-wider flex items-center font-geist">
                            <TrendingUp className="w-3.5 h-3.5 mr-2" />
                            Investment Intelligence
                          </h4>
                          <div className="text-[10px] font-bold font-geist text-primary">
                             Score: {roiData.investmentScore}/10
                          </div>
                        </div>
                        
                        <div className="grid grid-cols-2 gap-3">
                          <div className="bg-white p-2.5 rounded-xl border border-charcoal/5 shadow-sm text-center">
                            <p className="text-[8px] text-charcoal/40 uppercase font-bold tracking-wider mb-0.5 font-geist">Value Increase</p>
                            <p className="text-sm font-bold text-[#7A9A8C] font-display">
                              +₹{roiData.estimatedIncreaseInValue.toLocaleString('en-IN')}
                            </p>
                          </div>
                          <div className="bg-white p-2.5 rounded-xl border border-charcoal/5 shadow-sm text-center">
                            <p className="text-[8px] text-charcoal/40 uppercase font-bold tracking-wider mb-0.5 font-geist">ROI</p>
                            <p className="text-sm font-bold text-[#D4A574] font-display">
                              {roiData.roiPercentage}%
                            </p>
                          </div>
                        </div>
                      </div>
                    )}
                 </div>

                 {/* Sticky CTA Footer */}
                 <div className="p-6 border-t border-charcoal/10 bg-white z-20">
                   <div className="flex items-center justify-between gap-4">
                     <div>
                        <p className="font-serif italic text-charcoal">Love this concept?</p>
                        <p className="text-charcoal/40 text-[10px] font-geist uppercase tracking-widest">Get your detailed quote now.</p>
                     </div>
                     <button 
                       onClick={handleGetQuote}
                       disabled={loading}
                       className="px-6 py-3 bg-charcoal text-white rounded-xl font-bold uppercase tracking-widest hover:bg-primary transition-all shadow-lg hover:shadow-primary/20 disabled:opacity-50 text-[10px] flex items-center font-geist whitespace-nowrap"
                     >
                       {loading ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : 'Get Full Quote'}
                       {!loading && <ChevronRight className="ml-2 h-3.5 w-3.5" />}
                     </button>
                   </div>
                 </div>
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
  }

  return (
    <div className="min-h-screen bg-background font-sans text-charcoal">
      {/* Header */}
      <Header />

      <div className="flex min-h-screen pt-20">
        {/* Sidebar - Desktop */}
        <div className="hidden lg:flex w-80 flex-col fixed left-0 top-20 bottom-0 border-r border-charcoal/10 bg-white z-40">
          <nav className="flex-1 overflow-y-auto p-6 space-y-2 mt-4">
          {[
            { id: 1, name: 'Basics', icon: User },
            { id: 2, name: 'Space', icon: Layout },
            { id: 3, name: 'Photos', icon: ImageIcon },
            { id: 4, name: 'Style', icon: Palette },
            { id: 5, name: 'Materials', icon: Sparkles },
            { id: 6, name: 'Budget', icon: DollarSign },
            { id: 7, name: 'Review', icon: CheckCircle },
          ].map((item) => (
            <div
              key={item.id}
              className={`flex items-center px-4 py-3 rounded-xl text-xs font-bold uppercase tracking-widest transition-all font-geist ${
                step === item.id
                  ? 'bg-primary text-white shadow-lg shadow-primary/20'
                  : step > item.id
                  ? 'text-primary bg-primary/5'
                  : 'text-charcoal/40 hover:text-charcoal/60 hover:bg-charcoal/5'
              }`}
            >
              <item.icon className={`mr-3 h-4 w-4 ${step === item.id ? 'text-white' : step > item.id ? 'text-primary' : 'text-charcoal/40'}`} />
              {item.name}
              {step > item.id && <CheckCircle className="ml-auto h-3 w-3" />}
            </div>
          ))}
        </nav>
        <div className="p-6 border-t border-charcoal/10">
          <div className="bg-cream-base rounded-xl p-4 border border-charcoal/5">
            <p className="text-[10px] font-bold uppercase tracking-widest text-charcoal/40 mb-2 font-geist">Progress</p>
            <div className="w-full bg-charcoal/10 rounded-full h-1.5">
              <div 
                className="bg-primary h-1.5 rounded-full transition-all duration-500 ease-out" 
                style={{ width: `${Math.min(100, ((step - 1) / (totalSteps - 1)) * 100)}%` }}
              ></div>
            </div>
            <p className="text-[10px] text-right text-charcoal/40 mt-2 font-geist font-bold">{Math.min(100, Math.round(((step - 1) / (totalSteps - 1)) * 100))}%</p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 lg:ml-80 flex flex-col min-h-screen">
        <div className="flex-1 max-w-3xl mx-auto w-full p-6 sm:p-12 md:p-16 flex flex-col justify-center">
          {/* Mobile Header */}
          <div className="lg:hidden mb-8">
            <div className="flex justify-end items-center mb-4">
               <span className="text-[10px] font-bold uppercase tracking-widest bg-white px-3 py-1 rounded-full border border-charcoal/10 text-charcoal/60 font-geist">
                 {step === 8 ? 'Processing...' : `Step ${step}/${totalSteps}`}
               </span>
            </div>
            <div className="w-full bg-charcoal/10 rounded-full h-1.5">
              <div 
                className="bg-primary h-1.5 rounded-full transition-all duration-500 ease-out" 
                style={{ width: `${Math.min(100, ((step - 1) / (totalSteps - 1)) * 100)}%` }}
              ></div>
            </div>
          </div>

          <AnimatePresence mode="wait">
            <motion.div
              key={step}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="w-full"
            >
              {renderStep()}
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Footer Navigation */}
        {step !== 8 && (
        <div className="sticky bottom-0 bg-white/80 backdrop-blur-md border-t border-charcoal/10 p-6 sm:px-12">
          <div className="max-w-3xl mx-auto w-full flex justify-between items-center">
            <button
              onClick={() => setStep(s => Math.max(1, s - 1))}
              disabled={step === 1 || loading}
              className={`flex items-center px-6 py-3 rounded-xl text-xs font-bold uppercase tracking-widest transition-colors font-geist ${
                step === 1 ? 'invisible' : 'text-charcoal/40 hover:bg-charcoal/5 hover:text-charcoal'
              }`}
            >
              <ChevronLeft className="mr-2 h-4 w-4" />
              Back
            </button>
            <button
              onClick={handleNext}
              disabled={loading}
              className="flex items-center px-8 py-3 rounded-xl text-xs font-bold uppercase tracking-widest text-white bg-primary hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 hover:shadow-primary/40 disabled:opacity-50 disabled:shadow-none font-geist"
            >
              {loading ? (
                <Loader2 className="animate-spin h-5 w-5" />
              ) : step === totalSteps ? (
                <>Generate Design <Sparkles className="ml-2 h-4 w-4" /></>
              ) : (
                <>Next Step <ChevronRight className="ml-2 h-4 w-4" /></>
              )}
            </button>
          </div>
        </div>
        )}</div>
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

export default Wizard;
