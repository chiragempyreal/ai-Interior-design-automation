import mongoose, { Document, Schema } from 'mongoose';

export interface IProject extends Document {
  title: string;
  clientName: string;
  clientEmail: string;
  requirements: Record<string, any>;
  status: 'draft' | 'pending_approval' | 'approved' | 'rejected' | 'completed';
  createdBy: mongoose.Schema.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const ProjectSchema: Schema = new Schema(
  {
    title: { type: String, required: true, trim: true },
    clientName: { type: String, required: true, trim: true },
    clientEmail: { type: String, required: true, trim: true, lowercase: true },
    requirements: { type: Map, of: Schema.Types.Mixed, default: {} },
    status: {
      type: String,
      enum: ['draft', 'pending_approval', 'approved', 'rejected', 'completed'],
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
