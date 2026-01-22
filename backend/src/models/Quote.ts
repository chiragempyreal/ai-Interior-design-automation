import mongoose, { Document, Schema } from 'mongoose';

export interface IQuote extends Document {
  project: mongoose.Schema.Types.ObjectId;
  items: Array<{
    name: string;
    category: string;
    quantity: number;
    unitPrice: number;
    totalPrice: number;
  }>;
  totalAmount: number;
  version: number;
  status: 'draft' | 'sent' | 'approved' | 'rejected';
  validUntil: Date;
  pdfUrl?: string;
}

const QuoteSchema: Schema = new Schema(
  {
    project: { type: Schema.Types.ObjectId, ref: 'Project', required: true, index: true },
    items: [
      {
        name: { type: String, required: true },
        category: { type: String, required: true },
        quantity: { type: Number, required: true, min: 0 },
        unitPrice: { type: Number, required: true, min: 0 },
        totalPrice: { type: Number, required: true, min: 0 },
      },
    ],
    totalAmount: { type: Number, required: true, min: 0 },
    version: { type: Number, default: 1 },
    status: {
      type: String,
      enum: ['draft', 'sent', 'approved', 'rejected'],
      default: 'draft',
    },
    validUntil: { type: Date },
    pdfUrl: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model<IQuote>('Quote', QuoteSchema);
