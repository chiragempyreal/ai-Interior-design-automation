import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  ChevronRight, ChevronLeft, Upload, Layout, 
  Palette, DollarSign, CheckCircle, Image as ImageIcon,
  Loader2, Sparkles, MapPin, User, Mail, Phone, Ruler, X
} from 'lucide-react';
import api from '../services/api';

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
  const fileInputRef = useRef<HTMLInputElement>(null);

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
    if (path.startsWith('http') || path.startsWith('data:')) return path;
    const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5001/api/v1';
    const rootUrl = baseUrl.replace('/api/v1', '');
    return `${rootUrl}${path}`;
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
      alert('Quote request submitted successfully! We will contact you shortly.');
    } catch (error) {
      console.error('Quote Request Error:', error);
      alert('Failed to submit quote request');
    } finally {
      setLoading(false);
    }
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <div className="space-y-8">
            <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Let's start with the basics</h3>
              <p className="text-text-secondary">Tell us a bit about yourself so we can personalize your experience.</p>
            </div>
            <div className="grid grid-cols-1 gap-6">
              <div className="relative">
                <User className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary h-5 w-5" />
                <input
                  type="text"
                  placeholder="Your Name"
                  className="block w-full pl-12 pr-4 py-4 rounded-xl border-border bg-surface text-text placeholder:text-text-secondary/50 focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
                  value={data.clientName}
                  onChange={e => updateData('clientName', e.target.value)}
                />
              </div>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary h-5 w-5" />
                <input
                  type="email"
                  placeholder="Email Address"
                  className="block w-full pl-12 pr-4 py-4 rounded-xl border-border bg-surface text-text placeholder:text-text-secondary/50 focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
                  value={data.clientEmail}
                  onChange={e => updateData('clientEmail', e.target.value)}
                />
              </div>
              <div className="relative">
                <Phone className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary h-5 w-5" />
                <input
                  type="tel"
                  placeholder="Phone Number"
                  className="block w-full pl-12 pr-4 py-4 rounded-xl border-border bg-surface text-text placeholder:text-text-secondary/50 focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
                  value={data.clientPhone}
                  onChange={e => updateData('clientPhone', e.target.value)}
                />
              </div>
              <select
                className="block w-full px-4 py-4 rounded-xl border-border bg-surface text-text focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm appearance-none"
                value={data.projectType}
                onChange={e => updateData('projectType', e.target.value)}
              >
                <option value="Residential">Residential Project</option>
                <option value="Commercial">Commercial Project</option>
              </select>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-8">
            <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Tell us about your space</h3>
              <p className="text-text-secondary">What kind of property are we designing today?</p>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">Property Type</label>
                <div className="grid grid-cols-2 gap-4">
                  {['Apartment', 'Villa', 'Office', 'Retail'].map((type) => (
                    <button
                      key={type}
                      onClick={() => updateData('propertyType', type)}
                      className={`py-4 px-6 rounded-xl border transition-all font-medium ${
                        data.propertyType === type
                          ? 'border-primary bg-primary/10 text-primary ring-1 ring-primary'
                          : 'border-border bg-surface text-text hover:border-secondary'
                      }`}
                    >
                      {type}
                    </button>
                  ))}
                </div>
              </div>

              <div className="md:col-span-2">
                 <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">Space to Design</label>
                 <select
                  className="block w-full px-4 py-4 rounded-xl border-border bg-surface text-text focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
                  value={data.spaceType}
                  onChange={e => updateData('spaceType', e.target.value)}
                >
                  <option value="Living Room">Living Room</option>
                  <option value="Bedroom">Bedroom</option>
                  <option value="Kitchen">Kitchen</option>
                  <option value="Full Home">Full Home</option>
                  <option value="Office Cabin">Office Cabin</option>
                </select>
              </div>

              <div className="relative">
                <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">Area (sqft)</label>
                <div className="relative">
                  <Ruler className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary h-5 w-5" />
                  <input
                    type="number"
                    className="block w-full pl-12 pr-4 py-4 rounded-xl border-border bg-surface text-text focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
                    value={data.area}
                    onChange={e => updateData('area', Number(e.target.value))}
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">City</label>
                <div className="relative">
                  <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary h-5 w-5" />
                  <input
                    type="text"
                    placeholder="e.g. Mumbai"
                    className="block w-full pl-12 pr-4 py-4 rounded-xl border-border bg-surface text-text focus:ring-2 focus:ring-secondary focus:border-transparent transition-all shadow-sm"
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
          <div className="space-y-8">
             <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Upload Photos</h3>
              <p className="text-text-secondary">Show us your current space (optional but recommended).</p>
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
              className={`border-2 border-dashed rounded-2xl p-16 text-center transition-all cursor-pointer group relative overflow-hidden ${
                isDragging 
                  ? 'border-secondary bg-secondary/10 scale-[1.02]' 
                  : 'border-border bg-surface hover:border-secondary hover:bg-secondary/5'
              }`}
            >
              {uploading && (
                <div className="absolute inset-0 bg-surface/80 flex items-center justify-center z-10 backdrop-blur-sm">
                  <div className="flex flex-col items-center">
                    <Loader2 className="h-10 w-10 text-secondary animate-spin mb-3" />
                    <p className="font-medium text-text">Uploading...</p>
                  </div>
                </div>
              )}
              
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-background mb-6 group-hover:scale-110 transition-transform shadow-sm">
                <Upload className="h-10 w-10 text-secondary" />
              </div>
              <p className="text-lg font-medium text-text">Click to upload or drag and drop</p>
              <p className="text-sm text-text-secondary mt-2">SVG, PNG, JPG or GIF (max. 5MB)</p>
            </div>

            {data.photos.length > 0 && (
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 mt-6">
                {data.photos.map((photo, index) => (
                  <div key={index} className="group relative aspect-square bg-surface rounded-xl border border-border overflow-hidden shadow-sm">
                    <img 
                      src={getImageUrl(photo)} 
                      alt={`Space ${index + 1}`} 
                      className="w-full h-full object-cover transition-transform group-hover:scale-105"
                    />
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleRemovePhoto(photo);
                      }}
                      className="absolute top-2 right-2 p-1.5 bg-background/90 rounded-full text-text-secondary hover:text-red-500 hover:bg-red-50 transition-colors shadow-sm opacity-0 group-hover:opacity-100"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {data.photos.length === 0 && (
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 opacity-50">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="aspect-square bg-surface rounded-xl border border-border flex items-center justify-center text-text-secondary/30 shadow-sm">
                    <ImageIcon className="w-8 h-8" />
                  </div>
                ))}
              </div>
            )}
          </div>
        );

      case 4:
        return (
          <div className="space-y-8">
            <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Choose your style</h3>
              <p className="text-text-secondary">Which aesthetic resonates with you the most?</p>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
              {['Modern', 'Minimalist', 'Industrial', 'Scandinavian', 'Bohemian', 'Classic'].map((style) => (
                <motion.div
                  key={style}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => updateNestedData('stylePreferences', 'style', style)}
                  className={`cursor-pointer p-8 rounded-2xl text-center transition-all shadow-sm ${
                    data.stylePreferences.style === style 
                      ? 'bg-primary text-white shadow-lg shadow-primary/30 ring-2 ring-primary ring-offset-2' 
                      : 'bg-surface text-text border border-border hover:border-secondary hover:shadow-md'
                  }`}
                >
                  <span className="text-lg font-medium">{style}</span>
                </motion.div>
              ))}
            </div>
          </div>
        );

      case 5:
        return (
          <div className="space-y-8">
            <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Material Preferences</h3>
              <p className="text-text-secondary">Select your preferred finishes.</p>
            </div>
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">Flooring Preference</label>
                <div className="grid grid-cols-3 gap-4">
                   {['Italian Marble', 'Wooden', 'Vitrified Tiles'].map((opt) => (
                     <button
                        key={opt}
                        onClick={() => updateNestedData('materials', 'flooring', opt)}
                        className={`py-3 px-4 rounded-xl text-sm font-medium border transition-all ${
                          data.materials.flooring === opt
                            ? 'bg-secondary text-white border-secondary'
                            : 'bg-surface text-text border-border hover:bg-background'
                        }`}
                     >
                       {opt}
                     </button>
                   ))}
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-2 ml-1">Wall Finish</label>
                <div className="grid grid-cols-3 gap-4">
                   {['Premium Paint', 'Wallpaper', 'Texture'].map((opt) => (
                     <button
                        key={opt}
                        onClick={() => updateNestedData('materials', 'walls', opt)}
                        className={`py-3 px-4 rounded-xl text-sm font-medium border transition-all ${
                          data.materials.walls === opt
                            ? 'bg-secondary text-white border-secondary'
                            : 'bg-surface text-text border-border hover:bg-background'
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
          <div className="space-y-8">
             <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Budget & Timeline</h3>
              <p className="text-text-secondary">Help us design within your means.</p>
            </div>
            <div className="bg-surface p-8 rounded-2xl border border-border shadow-sm space-y-8">
              <div>
                <div className="flex justify-between items-center mb-4">
                  <label className="text-lg font-medium text-text">Estimated Budget</label>
                  <span className="text-2xl font-bold text-primary">₹{(data.budget.max / 100000).toFixed(1)} Lakhs</span>
                </div>
                <input
                  type="range"
                  min="100000"
                  max="5000000"
                  step="50000"
                  className="w-full h-3 bg-border rounded-lg appearance-none cursor-pointer accent-primary"
                  value={data.budget.max}
                  onChange={e => updateNestedData('budget', 'max', Number(e.target.value))}
                />
                <div className="flex justify-between text-xs text-text-secondary mt-3 font-mono">
                  <span>₹1L</span>
                  <span>₹50L+</span>
                </div>
              </div>
              
              <div className="pt-4 border-t border-border">
                <label className="block text-lg font-medium text-text mb-4">Project Timeline</label>
                <div className="flex flex-col sm:flex-row gap-4">
                  {['Urgent (<1 mo)', 'Standard (1-2 mo)', 'Flexible'].map((t) => (
                    <button
                      key={t}
                      onClick={() => updateData('timeline', t)}
                      className={`flex-1 py-4 px-4 rounded-xl text-sm font-medium border transition-all ${
                        data.timeline === t
                          ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                          : 'bg-background text-text border-border hover:bg-surface'
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
          <div className="space-y-8">
            <div className="text-center md:text-left">
              <h3 className="text-3xl font-serif font-bold text-primary mb-2">Review your details</h3>
              <p className="text-text-secondary">Almost there! Review your preferences before we generate the design.</p>
            </div>
            <div className="bg-surface rounded-2xl p-8 space-y-6 shadow-sm border border-border">
              <div className="flex justify-between items-start border-b border-border pb-6">
                <div>
                  <h4 className="font-medium text-text text-lg flex items-center"><User className="w-4 h-4 mr-2 text-secondary"/> Client Details</h4>
                  <p className="text-sm text-text-secondary mt-2 pl-6">{data.clientName}</p>
                  <p className="text-sm text-text-secondary pl-6">{data.clientEmail}</p>
                </div>
                <button onClick={() => setStep(1)} className="text-secondary hover:text-secondary-light text-sm font-medium hover:underline">Edit</button>
              </div>
              <div className="flex justify-between items-start border-b border-border pb-6">
                <div>
                  <h4 className="font-medium text-text text-lg flex items-center"><Layout className="w-4 h-4 mr-2 text-secondary"/> Space Details</h4>
                  <p className="text-sm text-text-secondary mt-2 pl-6">{data.spaceType} ({data.propertyType})</p>
                  <p className="text-sm text-text-secondary pl-6">{data.area} sqft • {data.location.city}</p>
                </div>
                <button onClick={() => setStep(2)} className="text-secondary hover:text-secondary-light text-sm font-medium hover:underline">Edit</button>
              </div>
              <div className="flex justify-between items-start">
                <div>
                  <h4 className="font-medium text-text text-lg flex items-center"><Palette className="w-4 h-4 mr-2 text-secondary"/> Preferences</h4>
                  <p className="text-sm text-text-secondary mt-2 pl-6">{data.stylePreferences.style} Style</p>
                  <p className="text-sm text-text-secondary pl-6">Budget: ~₹{(data.budget.max / 100000).toFixed(1)}L</p>
                </div>
                <button onClick={() => setStep(4)} className="text-secondary hover:text-secondary-light text-sm font-medium hover:underline">Edit</button>
              </div>
            </div>
          </div>
        );

      case 8:
        return (
          <div className="flex flex-col items-center justify-center min-h-[50vh] text-center space-y-8">
            <div className="relative">
              <div className="absolute inset-0 bg-secondary/20 rounded-full animate-ping"></div>
              <div className="relative bg-surface p-6 rounded-full shadow-xl border border-border">
                <Loader2 className="w-16 h-16 text-secondary animate-spin" />
              </div>
            </div>
            <div className="space-y-3">
              <h3 className="text-3xl font-serif font-bold text-primary animate-pulse">Designing your Dream Space...</h3>
              <p className="text-text-secondary text-lg max-w-md mx-auto">
                Our AI is analyzing your preferences and generating a photorealistic preview. This usually takes about 10-15 seconds.
              </p>
            </div>
            <div className="flex space-x-2">
              <span className="w-2 h-2 bg-primary rounded-full animate-bounce [animation-delay:-0.3s]"></span>
              <span className="w-2 h-2 bg-primary rounded-full animate-bounce [animation-delay:-0.15s]"></span>
              <span className="w-2 h-2 bg-primary rounded-full animate-bounce"></span>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  if (step === 9 && aiPreview) {
    return (
      <div className="min-h-screen bg-background py-12 px-4 sm:px-6 lg:px-8 font-sans">
        <div className="max-w-6xl mx-auto">
           <div className="bg-surface rounded-3xl shadow-2xl overflow-hidden border border-border">
            <div className="p-8 border-b border-border bg-background flex justify-between items-center">
              <div>
                <h2 className="text-3xl font-serif font-bold text-primary">Your Dream Design</h2>
                <p className="text-text-secondary mt-1">AI-generated concept based on your preferences</p>
              </div>
              <div className="hidden sm:block">
                 <span className="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium bg-success/10 text-success border border-success/20">
                   <Sparkles className="w-4 h-4 mr-2" />
                   AI Generated
                 </span>
              </div>
            </div>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-0">
              <div className="relative h-[500px] lg:h-auto bg-gray-100">
                 <img src={aiPreview} alt="AI Design" className="w-full h-full object-cover" />
                 <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent lg:hidden"></div>
              </div>
              <div className="p-10 flex flex-col justify-center space-y-8 bg-surface">
                 <div>
                   <h3 className="text-2xl font-semibold mb-6 text-primary font-serif">Design Elements</h3>
                   <ul className="space-y-4">
                     {[
                       { label: 'Style', value: data.stylePreferences.style },
                       { label: 'Flooring', value: data.materials.flooring },
                       { label: 'Walls', value: data.materials.walls },
                       { label: 'Budget', value: `₹${(data.budget.max / 100000).toFixed(1)} Lakhs` }
                     ].map((item, i) => (
                       <li key={i} className="flex items-center justify-between border-b border-border pb-3 last:border-0">
                         <span className="text-text-secondary">{item.label}</span>
                         <span className="font-medium text-text">{item.value || 'Not specified'}</span>
                       </li>
                     ))}
                   </ul>
                 </div>

                 <div className="bg-background p-8 rounded-2xl border border-border">
                   <h4 className="font-semibold text-primary text-xl mb-3">Ready to proceed?</h4>
                   <p className="text-text-secondary text-sm mb-6">Get a detailed quote with itemized costs and timeline.</p>
                   <button 
                     onClick={handleGetQuote}
                     disabled={loading}
                     className="w-full py-4 bg-primary text-white rounded-xl font-semibold hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 disabled:opacity-50 text-lg flex justify-center items-center"
                   >
                     {loading ? <Loader2 className="animate-spin mr-2" /> : 'Get Full Quote'}
                   </button>
                   <p className="text-xs text-center text-text-secondary mt-4">No obligation. Free consultation.</p>
                 </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex font-sans text-text">
      {/* Sidebar - Desktop */}
      <div className="hidden lg:flex w-80 flex-col fixed inset-y-0 border-r border-border bg-surface z-10">
        <div className="h-24 flex items-center px-8 border-b border-border">
          <h1 className="text-2xl font-serif font-bold text-primary tracking-tight">InteriAI</h1>
        </div>
        <nav className="flex-1 overflow-y-auto p-6 space-y-2">
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
              className={`flex items-center px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                step === item.id
                  ? 'bg-primary text-white shadow-md shadow-primary/20'
                  : step > item.id
                  ? 'text-success bg-success/5'
                  : 'text-text-secondary'
              }`}
            >
              <item.icon className={`mr-3 h-5 w-5 ${step === item.id ? 'text-white' : step > item.id ? 'text-success' : 'text-text-secondary'}`} />
              {item.name}
              {step > item.id && <CheckCircle className="ml-auto h-4 w-4" />}
            </div>
          ))}
        </nav>
        <div className="p-6 border-t border-border">
          <div className="bg-background rounded-xl p-4 border border-border">
            <p className="text-xs text-text-secondary mb-2">Progress</p>
            <div className="w-full bg-border rounded-full h-1.5">
              <div 
                className="bg-primary h-1.5 rounded-full transition-all duration-500 ease-out" 
                style={{ width: `${((step - 1) / (totalSteps - 1)) * 100}%` }}
              ></div>
            </div>
            <p className="text-xs text-right text-text-secondary mt-2">{Math.round(((step - 1) / (totalSteps - 1)) * 100)}%</p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 lg:ml-80 flex flex-col min-h-screen">
        <div className="flex-1 max-w-3xl mx-auto w-full p-6 sm:p-12 md:p-16 flex flex-col justify-center">
          {/* Mobile Header */}
          <div className="lg:hidden mb-8">
            <div className="flex justify-between items-center mb-4">
               <h1 className="text-xl font-serif font-bold text-primary">InteriAI</h1>
               <span className="text-xs font-medium bg-surface px-3 py-1 rounded-full border border-border">
                 {step === 8 ? 'Processing...' : `Step ${step}/${totalSteps}`}
               </span>
            </div>
            <div className="w-full bg-border rounded-full h-1.5">
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
        <div className="sticky bottom-0 bg-surface/80 backdrop-blur-md border-t border-border p-6 sm:px-12">
          <div className="max-w-3xl mx-auto w-full flex justify-between items-center">
            <button
              onClick={() => setStep(s => Math.max(1, s - 1))}
              disabled={step === 1 || loading}
              className={`flex items-center px-6 py-3 rounded-xl text-sm font-medium transition-colors ${
                step === 1 ? 'invisible' : 'text-text-secondary hover:bg-background hover:text-text'
              }`}
            >
              <ChevronLeft className="mr-2 h-4 w-4" />
              Back
            </button>
            <button
              onClick={handleNext}
              disabled={loading}
              className="flex items-center px-8 py-3 rounded-xl text-sm font-medium text-white bg-primary hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 hover:shadow-primary/40 disabled:opacity-50 disabled:shadow-none"
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
        )}
      </div>
    </div>
  );
};

export default Wizard;
