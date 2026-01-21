import { Request, Response, NextFunction } from 'express';
import * as authService from '../services/authService';
import { registerSchema, loginSchema, refreshTokenSchema } from '../validators/authValidator';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { config } from '../config/db';
import logger from '../utils/logger';
import { sendSuccess, sendError, sendEmail } from '../utils/utilHelpers';


// ... (register, login, refreshToken remain same but utilizing helpers already)

// ...

/**
 * @desc    Request password reset
 * @route   POST /api/v1/auth/forgot-password
 * @access  Public
 */
export const forgotPassword = async (req: Request, res: Response, next: NextFunction) => {
    try {
        if (!req.body.email) {
             return sendError(res, 'Email is required', null, 400);
        }

        const resetToken = await authService.generatePasswordResetToken(req.body.email);

        await sendEmail({
          email: req.body.email,
          subject: 'Password Reset Token',
          message: `Your reset token is: ${resetToken}`
        });

        // For dev, return token as well
        return sendSuccess(res, 'Email sent', { resetToken });
    } catch (error: any) {
        if (error.message === 'User not found') {
            return sendError(res, 'User not found', null, 404);
        }
        next(error);
    }
};

/**
 * @desc    Reset password
 * @route   POST /api/v1/auth/reset-password
 * @access  Public
 */
export const resetPassword = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { token, newPassword } = req.body;
        if (!token || !newPassword) {
            return sendError(res, 'Token and newPassword are required', null, 400);
        }

        await authService.resetPassword(token, newPassword);

        return sendSuccess(res, 'Password reset successful');
    } catch (error: any) {
        if (error.message === 'Invalid token') {
            return sendError(res, 'Invalid token', null, 400);
        }
        next(error);
    }
};

/**
 * @desc    Send OTP to phone number
 * @route   POST /api/v1/auth/send-otp
 * @access  Public
 */
export const sendOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return sendError(res, 'Phone number is required', null, 400);
    }
    // Static OTP for now
    return sendSuccess(res, 'OTP sent successfully. Use 123456.', { otp: '123456' });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Verify OTP and Login/Register
 * @route   POST /api/v1/auth/verify-otp
 * @access  Public
 */
export const verifyOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      return sendError(res, 'Phone and OTP are required', null, 400);
    }

    if (otp !== '123456') {
      return sendError(res, 'Invalid OTP', null, 400);
    }

    let user = await authService.findUserByPhone(phone);
    let isNewUser = false;

    if (!user) {
      // Register new user
      isNewUser = true;
      try {
        user = await authService.createUser({
          phone,
          full_name: `User ${phone.slice(-4)}`,
        });
        
        // Populate role for the new user as createUser returns the document but might not populate it immediately or depending on implementation
        // authService.createUser returns `await User.create(userData)`.
        // We need to populate role_id to match the expected structure for generateTokens
        user = await user.populate('role_id');
        
      } catch (err) {
        // Handle duplicate key error if race condition
        if ((err as any).code === 11000) {
           user = await authService.findUserByPhone(phone);
           if (!user) throw err; // Should not happen
        } else {
           throw err;
        }
      }
    }

    if (!user) {
        return sendError(res, 'Authentication failed', null, 500);
    }

    const tokens = authService.generateTokens(user);
    
    return sendSuccess(res, 'Login successful', {
      user: {
        _id: user._id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        role: user.role_id ? (user.role_id as any).name : 'client',
        subscription: user.subscription,
      },
      ...tokens,
      isNewUser
    });
  } catch (error) {
    console.error('Verify OTP Error:', error);
    next(error);
  }
};

/**
 * @desc    Update user profile
 * @route   PUT /api/v1/auth/profile
 * @access  Private
 */
export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (!user) {
        return sendError(res, 'User not found', null, 404);
    }
    
    const { full_name, email, phone } = req.body;
    
    const updatedUser = await authService.updateUser(user._id, { full_name, email, phone });
    
    if (!updatedUser) {
        return sendError(res, 'User not found', null, 404);
    }
    
    return sendSuccess(res, 'Profile updated successfully', {
        user: {
            _id: updatedUser._id,
            full_name: updatedUser.full_name,
            email: updatedUser.email,
            phone: updatedUser.phone,
            role: updatedUser.role_id ? (updatedUser.role_id as any).name : 'client',
            subscription: updatedUser.subscription,
        }
    });
  } catch (error) {
    next(error);
  }
};



/**
 * @desc    Register a new user
 * @route   POST /api/v1/auth/register
 * @access  Public
 */
export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { error } = registerSchema.validate(req.body);
    if (error) {
      return sendError(res, error.details[0].message, null, 400);
    }

    const existingUser = await authService.findUserByPhone(req.body.phone);
    if (existingUser) {
      return sendError(res, 'Phone number already in use', null, 400);
    }

    const user = await authService.createUser(req.body);
    const tokens = authService.generateTokens(user);

    return sendSuccess(res, 'User registered successfully', { user, tokens }, 201);
  } catch (error: any) {
    next(error);
  }
};

/**
 * @desc    Login user using phone number
 * @route   POST /api/v1/auth/login
 * @access  Public
 */
export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { error } = loginSchema.validate(req.body);
    if (error) {
      return sendError(res, error.details[0].message, null, 400);
    }

    const user = await authService.findUserByPhone(req.body.phone);
    if (!user || !user.password) {
      return sendError(res, 'Invalid credentials', null, 401);
    }

    const isMatch = await bcrypt.compare(req.body.password, user.password);
    if (!isMatch) {
      return sendError(res, 'Invalid credentials', null, 401);
    }

    const tokens = authService.generateTokens(user);
    return sendSuccess(res, 'Login successful', { user, tokens });
  } catch (error: any) {
    next(error);
  }
};

/**
 * @desc    Refresh access token
 * @route   POST /api/v1/auth/refresh-token
 * @access  Public
 */
export const refreshToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { error } = refreshTokenSchema.validate(req.body);
        if (error) return sendError(res, error.details[0].message, null, 400);

        const { refreshToken } = req.body;
        
        // Use a simple verification for now. In production, we should store refresh tokens in DB or Redis to allow revocation.
        const payload: any = jwt.verify(refreshToken, config.jwtSecret);
        
        const user = await authService.findUserById(payload.sub);
        if (!user) return sendError(res, 'User not found', null, 401);

        const tokens = authService.generateTokens(user);
        return sendSuccess(res, 'Token refreshed', { tokens });
    } catch (error) {
        return sendError(res, 'Invalid refresh token', null, 401);
    }
};
