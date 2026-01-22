import mongoose, { Schema, Document } from 'mongoose';

export interface IRole extends Document {
  name: string;
  display_name: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}

const RoleSchema: Schema = new Schema(
  {
    name: {
      type: String,
      required: true,
      unique: true,
      enum: ['admin', 'designer', 'assistant', 'client', 'viewer'],
    },
    display_name: {
      type: String,
      required: true,
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

export default mongoose.model<IRole>('Role', RoleSchema);
