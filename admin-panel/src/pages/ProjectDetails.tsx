import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '@/services/api';
import { format } from 'date-fns';
import QuoteEditor from '../components/QuoteEditor';
import { 
  ArrowLeft, 
  Calendar, 
  Download, 
  Sparkles,
  User,
  Mail,
  Phone,
  Layout,
  Palette
} from 'lucide-react';

interface Project {
  _id: string;
  title: string;
  clientName: string;
  clientEmail: string;
  clientPhone: string;
  status: string;
  createdAt: string;
  projectType: string;
  spaceType: string;
  area: number;
  location: {
    city: string;
    address: string;
  };
  budget: {
    min: number;
    max: number;
  };
  photos: string[];
  aiPreviewUrl?: string;
  aiDesignAnalysis?: {
    rationale: string;
    styleNotes: string;
    estimatedCostRange: string;
  };
}

interface QuoteItem {
  name: string;
  category: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

interface Quote {
  _id: string;
  totalAmount: number;
  items: QuoteItem[];
  pdfUrl?: string;
  status: string;
  version: number;
}

import { useToast } from '@/context/ToastContext';

const ProjectDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { success, error: toastError } = useToast();
  const [generating, setGenerating] = useState(false);

  const getImageUrl = (path: string) => {
    if (!path) return '';
    if (path.startsWith('http') || path.startsWith('data:')) return path;
    
    const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5001/api/v1';
    const rootUrl = baseUrl.replace(/\/api\/v1\/?$/, '');
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    
    return `${rootUrl}${cleanPath}`;
  };

  // Fetch Project
  const { data: project, isLoading: projectLoading } = useQuery<Project>({
    queryKey: ['project', id],
    queryFn: async () => {
      const res = await api.get(`/projects/${id}`);
      return res.data.data;
    }
  });

  // Fetch Quote (if exists)
  const { data: quote } = useQuery<Quote | null>({
    queryKey: ['quote', id],
    queryFn: async () => {
      try {
        const res = await api.get(`/projects/${id}/quote`);
        return res.data.data;
      } catch {
        return null; // No quote yet
      }
    },
    enabled: !!project // Only fetch if project loads
  });

  // Generate Quote Mutation
  const generateQuoteMutation = useMutation({
    mutationFn: async () => {
      const res = await api.post('/admin/quotes/generate', { projectId: id });
      return res.data.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quote', id] });
      queryClient.invalidateQueries({ queryKey: ['project', id] });
      success('Quote generated successfully');
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      toastError(err.response?.data?.message || 'Failed to generate quote');
    }
  });

  const handleGenerateQuote = async () => {
    setGenerating(true);
    try {
      await generateQuoteMutation.mutateAsync();
    } catch (error) {
      console.error('Failed to generate quote', error);
    } finally {
      setGenerating(false);
    }
  };

  if (projectLoading) {
    return <div className="p-8 text-center text-text-secondary">Loading project details...</div>;
  }

  if (!project) {
    return <div className="p-8 text-center text-error">Project not found</div>;
  }

  const getStatusColor = (status: string) => {
    switch (status?.toLowerCase()) {
      case 'completed': return 'bg-success/10 text-success border-success/20';
      case 'quoted': return 'bg-primary/10 text-primary border-primary/20';
      case 'submitted': return 'bg-warning/10 text-warning border-warning/20';
      default: return 'bg-text-secondary/10 text-text-secondary border-text-secondary/20';
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6 pb-12">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start gap-4">
        <button 
          onClick={() => navigate('/projects')}
          className="flex items-center text-text-secondary hover:text-primary transition-colors group mb-2 sm:mb-0"
        >
          <ArrowLeft className="w-4 h-4 mr-2 transition-transform group-hover:-translate-x-1" />
          Back to Projects
        </button>
      </div>

      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold font-display text-text">{project.title}</h1>
          <div className="flex items-center gap-3 mt-2">
            <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium border ${getStatusColor(project.status)}`}>
              {project.status?.toUpperCase()}
            </span>
            <span className="text-sm text-text-secondary flex items-center">
              <Calendar className="w-3.5 h-3.5 mr-1" />
              {format(new Date(project.createdAt), 'MMM dd, yyyy')}
            </span>
          </div>
        </div>
        
        <div className="flex gap-3">
          {quote?.pdfUrl && (
            <a 
              href={getImageUrl(quote.pdfUrl)} 
              target="_blank" 
              rel="noopener noreferrer"
              className="flex items-center px-4 py-2 bg-white border border-border rounded-xl text-sm font-medium text-text hover:bg-background-light transition-colors"
            >
              <Download className="w-4 h-4 mr-2" />
              Download PDF
            </a>
          )}
          <button 
            onClick={handleGenerateQuote}
            disabled={generating}
            className="flex items-center px-4 py-2 bg-primary text-white rounded-xl text-sm font-medium hover:bg-primary-dark transition-colors disabled:opacity-50 shadow-lg shadow-primary/25"
          >
            {generating ? (
              <span className="animate-pulse">Generating...</span>
            ) : (
              <>
                <Sparkles className="w-4 h-4 mr-2" />
                {quote ? 'Regenerate AI Quote' : 'Generate AI Quote'}
              </>
            )}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column - Details */}
        <div className="lg:col-span-2 space-y-6">
          
          {/* Client & Property Info */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-surface rounded-2xl shadow-sm border border-border p-6">
              <h3 className="text-lg font-bold text-text mb-4 flex items-center">
                <User className="w-5 h-5 mr-2 text-primary" />
                Client Details
              </h3>
              <div className="space-y-3">
                <div className="flex items-start gap-3">
                  <div className="bg-background rounded-lg p-2">
                    <User className="w-4 h-4 text-text-secondary" />
                  </div>
                  <div>
                    <p className="text-xs text-text-secondary">Name</p>
                    <p className="text-sm font-medium text-text">{project.clientName}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="bg-background rounded-lg p-2">
                    <Mail className="w-4 h-4 text-text-secondary" />
                  </div>
                  <div>
                    <p className="text-xs text-text-secondary">Email</p>
                    <p className="text-sm font-medium text-text">{project.clientEmail}</p>
                  </div>
                </div>
                {project.clientPhone && (
                  <div className="flex items-start gap-3">
                    <div className="bg-background rounded-lg p-2">
                      <Phone className="w-4 h-4 text-text-secondary" />
                    </div>
                    <div>
                      <p className="text-xs text-text-secondary">Phone</p>
                      <p className="text-sm font-medium text-text">{project.clientPhone}</p>
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div className="bg-surface rounded-2xl shadow-sm border border-border p-6">
              <h3 className="text-lg font-bold text-text mb-4 flex items-center">
                <Layout className="w-5 h-5 mr-2 text-primary" />
                Property Details
              </h3>
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-xs text-text-secondary">Type</p>
                    <p className="text-sm font-medium text-text">{project.projectType}</p>
                  </div>
                  <div>
                    <p className="text-xs text-text-secondary">Space</p>
                    <p className="text-sm font-medium text-text">{project.spaceType}</p>
                  </div>
                  <div>
                    <p className="text-xs text-text-secondary">Area</p>
                    <p className="text-sm font-medium text-text">{project.area} sqft</p>
                  </div>
                  <div>
                    <p className="text-xs text-text-secondary">City</p>
                    <p className="text-sm font-medium text-text">{project.location?.city || 'N/A'}</p>
                  </div>
                </div>
                <div className="pt-3 border-t border-border">
                   <p className="text-xs text-text-secondary">Budget Range</p>
                   <p className="text-sm font-medium text-text">
                     ₹{project.budget?.min?.toLocaleString()} - ₹{project.budget?.max?.toLocaleString()}
                   </p>
                </div>
              </div>
            </div>
          </div>

          {/* AI Analysis Section */}
          {project.aiDesignAnalysis && (
            <div className="bg-surface rounded-2xl shadow-sm border border-border p-6">
              <h3 className="text-lg font-bold text-text mb-4 flex items-center">
                <Sparkles className="w-5 h-5 mr-2 text-primary" />
                AI Analysis
              </h3>
              <div className="space-y-4">
                <div>
                  <h4 className="text-sm font-medium text-text mb-1">Design Rationale</h4>
                  <p className="text-sm text-text-secondary leading-relaxed bg-background-light p-4 rounded-xl">
                    {project.aiDesignAnalysis.rationale}
                  </p>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-text mb-1">Style Notes</h4>
                  <p className="text-sm text-text-secondary">
                    {project.aiDesignAnalysis.styleNotes}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Quote Section */}
          {quote && (
            <QuoteEditor 
              quote={quote} 
              onUpdate={() => {
                queryClient.invalidateQueries({ queryKey: ['quote', id] });
              }} 
            />
          )}
        </div>

        {/* Right Column - Images */}
        <div className="space-y-6">
          {project.aiPreviewUrl && (
            <div className="bg-surface rounded-2xl shadow-sm border border-border overflow-hidden">
              <div className="p-4 border-b border-border">
                 <h3 className="font-bold text-text flex items-center">
                   <Palette className="w-4 h-4 mr-2 text-primary" />
                   AI Generated Preview
                 </h3>
              </div>
              <div className="aspect-square relative group">
                <img 
                  src={getImageUrl(project.aiPreviewUrl || '')} 
                  alt="AI Preview" 
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                   <a 
                     href={getImageUrl(project.aiPreviewUrl || '')} 
                     target="_blank" 
                     rel="noreferrer"
                     className="px-4 py-2 bg-white rounded-lg text-sm font-medium"
                   >
                     View Full
                   </a>
                </div>
              </div>
            </div>
          )}

          <div className="bg-surface rounded-2xl shadow-sm border border-border p-6">
            <h3 className="font-bold text-text mb-4">Original Photos</h3>
            <div className="grid grid-cols-2 gap-3">
              {project.photos?.map((photo: string, idx: number) => (
                <div key={idx} className="aspect-square rounded-xl overflow-hidden relative group">
                  <img 
                    src={getImageUrl(photo)} 
                    alt={`Original ${idx}`} 
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
              {(!project.photos || project.photos.length === 0) && (
                <div className="col-span-2 text-center py-8 text-text-secondary text-sm bg-background rounded-xl border border-dashed border-border">
                  No photos uploaded
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProjectDetails;
