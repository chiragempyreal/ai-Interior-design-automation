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

export const generateOtp = async (phone: string) => {
  const user = await User.findOne({ phone });
  if (!user) {
    throw new Error('User not found');
  }

  // Generate random 6-digit OTP (Mock for now)
  const otp = '123456'; 

  // Save to user
  user.otp = otp; 
  user.otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 mins
  await user.save();

  console.log(`[MOCK OTP] Phone: ${phone}, OTP: ${otp}`);
  return otp;
};

export const verifyOtp = async (phone: string, otp: string) => {
  const user = await User.findOne({ 
    phone,
    otp, 
    otpExpires: { $gt: Date.now() } 
  }).populate('role_id');

  if (!user) {
    throw new Error('Invalid OTP or OTP expired');
  }

  // Clear OTP
  user.otp = undefined;
  user.otpExpires = undefined;
  await user.save();

  return user;
};
