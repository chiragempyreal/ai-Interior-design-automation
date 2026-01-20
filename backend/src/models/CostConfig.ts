import mongoose, { Document, Schema } from 'mongoose';

export interface ICostConfig extends Document {
  category: string;
  itemType: string;
  basePrice: number;
  unit: string;
  laborCostPerUnit: number;
  isActive: boolean;
}

const CostConfigSchema: Schema = new Schema(
  {
    category: { type: String, required: true, index: true },
    itemType: { type: String, required: true, unique: true },
    basePrice: { type: Number, required: true, min: 0 },
    unit: { type: String, required: true },
    laborCostPerUnit: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export default mongoose.model<ICostConfig>('CostConfig', CostConfigSchema);
