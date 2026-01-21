import User, { IUser } from '../models/User';
import Role from '../models/Role';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { config } from '../config/db';

export const createUser = async (userData: Partial<IUser>) => {
  // Default to 'client' role if not specified
  if (!userData.role_id) {
    const clientRole = await Role.findOne({ name: 'client' });
    if (clientRole) {
      userData.role_id = clientRole._id as any;
    }
  }
  
  // Hash password
  if (userData.password) {
    userData.password = await bcrypt.hash(userData.password, 10);
  }

  const user = await User.create(userData);
  return user;
};

export const findUserByEmail = async (email: string) => {
  return await User.findOne({ email }).populate('role_id');
};

export const findUserByPhone = async (phone: string) => {
  return await User.findOne({ phone }).populate('role_id');
};

export const findUserById = async (id: string) => {
  return await User.findById(id).populate('role_id');
};

export const generateTokens = (user: IUser) => {
  const payload = {
    sub: user._id,
    role: (user.role_id as any).name, // Assuming populated
  };

  const accessToken = jwt.sign(payload, config.jwtSecret as jwt.Secret, { expiresIn: config.jwtAccessExpiration as any });
  const refreshToken = jwt.sign(payload, config.jwtSecret as jwt.Secret, { expiresIn: config.jwtRefreshExpiration as any });

  return { accessToken, refreshToken };
};

export const generatePasswordResetToken = async (email: string) => {
  const user = await User.findOne({ email });
  if (!user) {
    throw new Error('User not found');
  }

  // Generate random token
  const resetToken = crypto.randomBytes(20).toString('hex');

  // Hash and set to resetPasswordToken field
  user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');

  // Set expiration (10 minutes)
  user.resetPasswordExpires = new Date(Date.now() + 10 * 60 * 1000);

  await user.save();

  return resetToken;
};

export const resetPassword = async (resetToken: string, newPassword: string) => {
  // Get hashed token
  const resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');

  const user = await User.findOne({
    resetPasswordToken,
    resetPasswordExpires: { $gt: Date.now() },
  });

  if (!user) {
    throw new Error('Invalid token');
  }

  // Set new password
  user.password = await bcrypt.hash(newPassword, 10);
  user.resetPasswordToken = undefined;
  user.resetPasswordExpires = undefined;

  await user.save();

  return user;
};

export const updateUser = async (userId: string, updates: Partial<IUser>) => {
  return await User.findByIdAndUpdate(userId, updates, { new: true }).populate('role_id');
};
