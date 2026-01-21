import { Request, Response, NextFunction } from 'express';
import Project from '../models/Project';
import logger from '../utils/logger';
import { sendSuccess, sendError } from '../utils/utilHelpers';
import { createProjectSchema } from '../validators/projectValidator';
import { IUser } from '../models/User';

interface AuthRequest extends Request {
  user?: IUser;
}

/**
 * @swagger
 * tags:
 *   name: Projects
 *   description: Project Management API
 */

/**
 * @swagger
 * /api/v1/projects:
 *   get:
 *     summary: Get all projects created by the logged-in user
 *     tags: [Projects]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of projects
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
 *                   example: "Projects retrieved successfully"
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                       title:
 *                         type: string
 *                       clientName:
 *                         type: string
 *                       clientEmail:
 *                         type: string
 *                       status:
 *                         type: string
 *       500:
 *         description: Server Error
 */
export const getProjects = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = (req as any).user?._id;
    const projects = await Project.find({ createdBy: userId }).sort({ createdAt: -1 });
    return sendSuccess(res, 'Projects retrieved successfully', projects);
  } catch (error: any) {
    logger.error(error.message);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/projects:
 *   post:
 *     summary: Create a new project
 *     tags: [Projects]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - clientName
 *               - clientEmail
 *             properties:
 *               title:
 *                 type: string
 *                 example: "Modern Living Room"
 *               clientName:
 *                 type: string
 *                 example: "Jane Doe"
 *               clientEmail:
 *                 type: string
 *                 format: email
 *                 example: "jane@example.com"
 *               requirements:
 *                 type: object
 *                 example: { "style": "modern", "budget": 5000 }
 *               status:
 *                 type: string
 *                 enum: [draft, pending_approval, approved, rejected, completed]
 *                 default: draft
 *     responses:
 *       201:
 *         description: Project created
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
 *                   example: "Project created successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     title:
 *                         type: string
 *                     clientName:
 *                         type: string
 *                     clientEmail:
 *                         type: string
 *       400:
 *         description: Validation Error
 */
export const createProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { error } = createProjectSchema.validate(req.body);
    if (error) {
      return sendError(res, error.details[0].message, null, 400);
    }

    const userId = (req as any).user?._id;
    const project = await Project.create({ ...req.body, createdBy: userId });
    return sendSuccess(res, 'Project created successfully', project, 201);
  } catch (error: any) {
    logger.error(error.message);
    return sendError(res, error.message, null, 400);
  }
};
