import { Request, Response, NextFunction } from 'express';
import * as authService from '../services/authService';
import { registerSchema, loginSchema, refreshTokenSchema } from '../validators/authValidator';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { config } from '../config/db';
import logger from '../utils/logger';
import { sendSuccess, sendError, sendEmail } from '../utils/utilHelpers';

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication API
 */

/**
 * @swagger
 * /api/v1/auth/forgot-password:
 *   post:
 *     summary: Request password reset
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john@example.com"
 *     responses:
 *       200:
 *         description: Email sent
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Email sent"
 *                 data:
 *                   type: object
 *                   properties:
 *                     resetToken:
 *                       type: string
 *                       description: "Mocked token for development"
 *       404:
 *         description: User not found
 *       500:
 *         description: Server error
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
 * @swagger
 * /api/v1/auth/reset-password:
 *   post:
 *     summary: Reset password
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - newPassword
 *             properties:
 *               token:
 *                 type: string
 *               newPassword:
 *                 type: string
 *                 format: password
 *                 example: "newpassword123"
 *     responses:
 *       200:
 *         description: Password reset successful
 *       400:
 *         description: Invalid token
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
 * @swagger
 * /api/v1/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - full_name
 *               - phone
 *               - password
 *             properties:
 *               full_name:
 *                 type: string
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 format: email
 *                 example: john@example.com
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "password123"
 *               company_name:
 *                 type: string
 *                 example: "Design Co."
 *               subscription:
 *                 type: string
 *                 enum: [free, pro, enterprise]
 *                 default: free
 *                 example: free
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                       example: 60d0fe4f5311236168a109ca
 *                     full_name:
 *                       type: string
 *                       example: John Doe
 *                     email:
 *                       type: string
 *                       example: john@example.com
 *                     phone:
 *                       type: string
 *                       example: "+1234567890"
 *                     subscription:
 *                       type: string
 *                       example: free
 *                     role_id:
 *                       type: string
 *                       example: 60d0fe4f5311236168a109cb
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Validation error or phone already in use
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Phone number already in use
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
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: Login user using phone number and password
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - password
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Login successful"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       type: object
 *                       properties:
 *                         _id:
 *                           type: string
 *                           example: 60d0fe4f5311236168a109ca
 *                         full_name:
 *                           type: string
 *                           example: John Doe
 *                         phone:
 *                           type: string
 *                           example: "+1234567890"
 *                         role_id:
 *                           type: object
 *                           properties:
 *                             name:
 *                               type: string
 *                               example: client
 *                     tokens:
 *                       type: object
 *                       properties:
 *                         accessToken:
 *                           type: string
 *                           example: "eyJhbGciOiJIUzI1..."
 *                         refreshToken:
 *                           type: string
 *                           example: client
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       401:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Invalid credentials
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
 * @swagger
 * /api/v1/auth/send-otp:
 *   post:
 *     summary: Send OTP for login
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *       404:
 *         description: User not found
 */
export const sendOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone } = req.body;
    const otp = await authService.generateOtp(phone);
    return sendSuccess(res, 'OTP sent successfully', { otp });
  } catch (error: any) {
    if (error.message === 'User not found') {
      return sendError(res, 'User not found', null, 404);
    }
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/auth/verify-otp:
 *   post:
 *     summary: Verify OTP and login
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - otp
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *               otp:
 *                 type: string
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: Login successful
 *       400:
 *         description: Invalid OTP
 */
export const verifyOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone, otp } = req.body;
    const user = await authService.verifyOtp(phone, otp);
    const tokens = authService.generateTokens(user);
    return sendSuccess(res, 'Login successful', { user, tokens });
  } catch (error: any) {
    if (error.message === 'Invalid OTP or OTP expired') {
      return sendError(res, 'Invalid OTP or OTP expired', null, 400);
    }
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/auth/refresh-token:
 *   post:
 *     summary: Refresh access token
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *     responses:
 *       200:
 *         description: Token refreshed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *                     refreshToken:
 *                       type: string
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Missing refresh token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "refreshToken is required"
 *       401:
 *         description: Invalid refresh token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Invalid refresh token"
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
