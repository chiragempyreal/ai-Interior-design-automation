import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  role_id: mongoose.Types.ObjectId;
  full_name: string;
  email?: string;
  phone: string;
  password?: string;
  company_name?: string;
  profile_image?: string;
  subscription: 'free' | 'pro' | 'enterprise';
  resetPasswordToken?: string;
  resetPasswordExpires?: Date;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}

const UserSchema: Schema = new Schema(
  {
    role_id: {
      type: Schema.Types.ObjectId,
      ref: 'Role',
      required: true,
    },
    full_name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      unique: true,
      sparse: true, // Allows null/undefined unique values
    },
    phone: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
    },
    company_name: {
      type: String,
    },
    profile_image: {
      type: String,
    },
    subscription: {
      type: String,
      enum: ['free', 'pro', 'enterprise'],
      default: 'free',
    },
    resetPasswordToken: {
      type: String,
    },
    resetPasswordExpires: {
      type: Date,
    },
    deletedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model<IUser>('User', UserSchema);
