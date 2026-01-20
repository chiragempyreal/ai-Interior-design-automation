import { Router, Request, Response } from 'express';
import Project from '../models/Project';
import logger from '../utils/logger';

const router = Router();

/**
 * @swagger
 * /api/v1/projects:
 *   get:
 *     summary: Get all projects
 *     tags: [Projects]
 *     responses:
 *       200:
 *         description: List of projects
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const projects = await Project.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: projects });
  } catch (error: any) {
    logger.error(error.message);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
});

/**
 * @swagger
 * /api/v1/projects:
 *   post:
 *     summary: Create a new project
 *     tags: [Projects]
 *     responses:
 *       201:
 *         description: Project created
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const project = await Project.create(req.body);
    res.status(201).json({ success: true, data: project });
  } catch (error: any) {
    logger.error(error.message);
    res.status(400).json({ success: false, message: error.message });
  }
});

export default router;
