import mongoose, { Document, Schema } from 'mongoose';

export interface IProject extends Document {
  title: string;
  clientName: string;
  clientEmail: string;
  clientPhone?: string;
  
  // Project Details
  projectType: 'Residential' | 'Commercial';
  propertyType?: string; // Apartment, Villa, Office
  spaceType?: string; // Living Room, Kitchen, Full Home
  area?: number; // sqft
  location?: {
    city: string;
    pincode?: string;
    address?: string;
  };

  // Preferences
  budget?: {
    min: number;
    max: number;
  };
  timeline?: string; // Flexible, 1-2 months, etc.
  
  // Design Specs
  stylePreferences?: {
    style?: string; // Modern, Minimal, etc.
    colors?: string[];
  };

  materials?: {
    flooring?: string;
    walls?: string;
    furniture?: string;
    lighting?: string;
  };

  // Media
  photos?: string[]; // URLs
  aiPreviewUrl?: string; // Generated AI image URL
  
  status: 'draft' | 'submitted' | 'under_review' | 'quoted' | 'approved' | 'completed';
  
  createdBy?: mongoose.Schema.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const ProjectSchema: Schema = new Schema(
  {
    title: { type: String, required: true, trim: true },
    clientName: { type: String, required: true, trim: true },
    clientEmail: { type: String, required: true, trim: true, lowercase: true },
    clientPhone: { type: String, trim: true },

    projectType: { 
      type: String, 
      enum: ['Residential', 'Commercial'], 
      default: 'Residential' 
    },
    propertyType: { type: String },
    spaceType: { type: String },
    area: { type: Number },
    location: {
      city: String,
      pincode: String,
      address: String
    },

    budget: {
      min: Number,
      max: Number
    },
    timeline: { type: String },

    stylePreferences: {
      style: String,
      colors: [String]
    },

    materials: {
      flooring: String,
      walls: String,
      furniture: String,
      lighting: String
    },

    photos: [String],
    aiPreviewUrl: String,

    status: {
      type: String,
      enum: ['draft', 'submitted', 'under_review', 'quoted', 'approved', 'completed'],
      default: 'draft',
      index: true,
    },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

// Index for search
ProjectSchema.index({ title: 'text', clientName: 'text' });

export default mongoose.model<IProject>('Project', ProjectSchema);
