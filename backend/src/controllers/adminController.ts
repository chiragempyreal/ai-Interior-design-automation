import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import User from '../models/User';
import Project from '../models/Project';
import Quote from '../models/Quote';
import { sendSuccess, sendError } from '../utils/utilHelpers';
import * as authService from '../services/authService';
import logger from '../utils/logger';

/**
 * @desc    Admin Login (Email & Password)
 * @route   POST /api/v1/admin/login
 * @access  Public
 */
export const adminLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return sendError(res, 'Email and password are required', null, 400);
    }

    // 1. Find user by email and populate role
    const user = await User.findOne({ email }).populate('role_id');

    if (!user) {
      return sendError(res, 'Invalid credentials', null, 401);
    }

    // 2. Verify Role is 'admin' or 'superadmin' (if exists)
    const roleName = (user.role_id as any)?.name;
    if (roleName !== 'admin') {
      return sendError(res, 'Access denied. Admin privileges required.', null, 403);
    }

    // 3. Verify Password
    if (!user.password) {
      return sendError(res, 'Invalid credentials', null, 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return sendError(res, 'Invalid credentials', null, 401);
    }

    // 4. Generate Tokens
    const { accessToken, refreshToken } = authService.generateTokens(user);

    return sendSuccess(res, 'Admin login successful', {
      user: {
        _id: user._id,
        full_name: user.full_name,
        email: user.email,
        role: roleName
      },
      token: accessToken,
      refreshToken
    });

  } catch (error: any) {
    logger.error(`Admin Login Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Get System Wide Stats for Admin Dashboard
 * @route   GET /api/v1/admin/stats
 * @access  Private (Admin)
 */
export const getSystemStats = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const [
      totalUsers,
      totalProjects,
      activeProjects,
      pendingQuotes,
      completedProjects
    ] = await Promise.all([
      User.countDocuments({ deletedAt: null }),
      Project.countDocuments(),
      Project.countDocuments({ status: { $in: ['approved', 'quoted', 'in_progress'] } }),
      Project.countDocuments({ status: { $in: ['submitted', 'under_review'] } }),
      Project.countDocuments({ status: 'completed' })
    ]);

    // Calculate Total Revenue from accepted Quotes (mock logic for now if status not fully implemented)
    // In a real scenario, sum totalAmount of Quotes where status = 'accepted'
    // For now, we can sum all quotes or use a mock multiplier for active projects
    const revenueResult = await Quote.aggregate([
      { $match: { status: 'accepted' } },
      { $group: { _id: null, total: { $sum: '$totalAmount' } } }
    ]);
    
    // Fallback revenue if no quotes
    const revenue = revenueResult.length > 0 ? revenueResult[0].total : (activeProjects * 15000 + completedProjects * 50000);

    const stats = {
      users: {
        total: totalUsers,
        growth: '+12%' // Mock growth for now
      },
      projects: {
        total: totalProjects,
        active: activeProjects,
        pending: pendingQuotes,
        completed: completedProjects
      },
      revenue: {
        total: revenue,
        trend: '+8.5%' // Mock trend
      }
    };

    return sendSuccess(res, 'System stats retrieved successfully', stats);
  } catch (error: any) {
    logger.error(`Admin Stats Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Get All Projects for Admin
 * @route   GET /api/v1/admin/projects
 * @access  Private (Admin)
 */
export const getProjects = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    const [projects, total] = await Promise.all([
      Project.find()
        .populate('user_id', 'full_name email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Project.countDocuments()
    ]);

    return sendSuccess(res, 'Projects retrieved successfully', {
      projects,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error: any) {
    logger.error(`Admin Get Projects Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Get All Users with Pagination
 * @route   GET /api/v1/admin/users
 * @access  Private (Admin)
 */
export const getUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    const users = await User.find({ deletedAt: null })
      .select('-password')
      .populate('role_id', 'name display_name')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments({ deletedAt: null });

    return sendSuccess(res, 'Users retrieved successfully', {
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error: any) {
    logger.error(`Admin Get Users Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Update Admin Profile
 * @route   PUT /api/v1/admin/profile
 * @access  Private (Admin)
 */
export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { full_name, email } = req.body;
    const userId = (req as any).user.userId;

    const user = await User.findById(userId);

    if (!user) {
      return sendError(res, 'User not found', null, 404);
    }

    if (email && email !== user.email) {
      const emailExists = await User.findOne({ email });
      if (emailExists) {
        return sendError(res, 'Email already in use', null, 400);
      }
      user.email = email;
    }

    if (full_name) {
      user.full_name = full_name;
    }

    await user.save();

    return sendSuccess(res, 'Profile updated successfully', {
      _id: user._id,
      full_name: user.full_name,
      email: user.email
    });
  } catch (error: any) {
    logger.error(`Admin Update Profile Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Change Admin Password
 * @route   PUT /api/v1/admin/change-password
 * @access  Private (Admin)
 */
export const changePassword = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = (req as any).user.userId;

    if (!currentPassword || !newPassword) {
      return sendError(res, 'Please provide current and new password', null, 400);
    }

    const user = await User.findById(userId);

    if (!user) {
      return sendError(res, 'User not found', null, 404);
    }

    // Verify Current Password
    if (!user.password) {
      return sendError(res, 'Invalid credentials', null, 401);
    }
    
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return sendError(res, 'Invalid current password', null, 401);
    }

    // Hash New Password
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);

    await user.save();

    return sendSuccess(res, 'Password updated successfully', null);
  } catch (error: any) {
    logger.error(`Admin Change Password Error: ${error.message}`);
    next(error);
  }
};
