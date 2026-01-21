import { Request, Response, NextFunction } from 'express';
import OpenAI from 'openai';
import Project from '../models/Project';
import logger from '../utils/logger';
import { sendSuccess, sendError } from '../utils/utilHelpers';
import { generateInteriorDesignPrompt } from '../utils/aiPrompts';

// Helper to delay for mock AI generation
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * @swagger
 * tags:
 *   name: Mobile
 *   description: Mobile Project Management API
 */

/**
 * @swagger
 * /api/v1/mobile/projects:
 *   post:
 *     summary: Create a new project (Mobile)
 *     tags: [Mobile]
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
 *                 example: "jane@example.com"
 *               clientPhone:
 *                 type: string
 *                 example: "+1234567890"
 *               projectType:
 *                 type: string
 *                 example: "Residential"
 *     responses:
 *       201:
 *         description: Project created successfully
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
 *                       example: "60d0fe4f5311236168a109cc"
 *                     title:
 *                       type: string
 *                       example: "Modern Living Room"
 *                     clientName:
 *                       type: string
 *                       example: "Jane Doe"
 *                     status:
 *                       type: string
 *                       example: "draft"
 *       400:
 *         description: Validation error
 *       500:
 *         description: Server error
 */
export const createProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const { title, clientName, clientEmail, clientPhone, projectType } = req.body;

    const project = await Project.create({
      title,
      clientName,
      clientEmail,
      clientPhone,
      projectType,
      status: 'draft',
      createdBy: req.user._id as any // Set the owner
    });

    return sendSuccess(res, 'Project created successfully', project, 201);
  } catch (error: any) {
    logger.error(`Create Project Error: ${error.message}`);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects/{id}:
 *   put:
 *     summary: Update project details (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Project ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               clientName:
 *                 type: string
 *               roomDimensions:
 *                 type: object
 *                 properties:
 *                   length:
 *                     type: number
 *                   width:
 *                     type: number
 *                   height:
 *                     type: number
 *               budget:
 *                 type: number
 *               stylePreferences:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Project updated successfully
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
 *                   example: "Project updated successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     title:
 *                       type: string
 *                     status:
 *                       type: string
 *       404:
 *         description: Project not found
 *       500:
 *         description: Server error
 */
export const updateProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const { id } = req.params;
    
    // Check ownership
    let project = await Project.findOne({ _id: id, createdBy: req.user._id as any });

    if (!project) {
      return sendError(res, 'Project not found or unauthorized', null, 404);
    }

    // Remove fields that shouldn't be updated if empty/null
    const updateData = { ...req.body };
    if (!updateData.title) delete updateData.title;
    if (!updateData.clientName) delete updateData.clientName;
    if (!updateData.clientEmail) delete updateData.clientEmail;

    project = await Project.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true
    });

    return sendSuccess(res, 'Project updated successfully', project);
  } catch (error: any) {
    logger.error(`Update Project Error: ${error.message}`);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects/{id}:
 *   get:
 *     summary: Get a single project (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Project ID
 *     responses:
 *       200:
 *         description: Project retrieved successfully
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
 *                 data:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     title:
 *                       type: string
 *                     status:
 *                       type: string
 *                     clientName:
 *                       type: string
 *                     clientEmail:
 *                       type: string
 *       404:
 *         description: Project not found
 *       500:
 *         description: Server error
 */
export const getProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const project = await Project.findOne({ _id: req.params.id, createdBy: req.user._id as any });

    if (!project) {
      return sendError(res, 'Project not found or unauthorized', null, 404);
    }

    return sendSuccess(res, 'Project retrieved successfully', project);
  } catch (error: any) {
    logger.error(`Get Project Error: ${error.message}`);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects:
 *   get:
 *     summary: Get all projects (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *         description: Filter by project status
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Limit number of results
 *     responses:
 *       200:
 *         description: List of projects retrieved successfully
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
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                       title:
 *                         type: string
 *                       status:
 *                         type: string
 *       500:
 *         description: Server error
 */
export const getProjects = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const { status, limit } = req.query;
    
    let query: any = { createdBy: req.user._id as any }; // Force ownership check
    if (status) {
      query.status = status;
    }

    const projects = await Project.find(query)
      .sort({ createdAt: -1 })
      .limit(Number(limit) || 20);

    return sendSuccess(res, 'Projects retrieved successfully', projects);
  } catch (error: any) {
    logger.error(`Get Projects Error: ${error.message}`);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects/{id}/upload:
 *   post:
 *     summary: Upload project images (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     consumes:
 *       - multipart/form-data
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Project ID
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               photos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       200:
 *         description: Images uploaded successfully
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
 *                 data:
 *                   type: object
 *                   properties:
 *                     photos:
 *                       type: array
 *                       items:
 *                         type: string
 *                     newPhotos:
 *                       type: array
 *                       items:
 *                         type: string
 *       400:
 *         description: No files uploaded
 *       404:
 *         description: Project not found
 *       500:
 *         description: Server error
 */
export const uploadProjectImages = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const { id } = req.params;
    const files = req.files as Express.Multer.File[];

    if (!files || files.length === 0) {
      return sendError(res, 'No files uploaded', null, 400);
    }

    const project = await Project.findOne({ _id: id, createdBy: req.user._id as any });
    if (!project) {
      return sendError(res, 'Project not found or unauthorized', null, 404);
    }

    // Create URLs for the uploaded files
    const fileUrls = files.map(file => `/uploads/projects/${file.filename}`);

    // Add new photos to existing ones
    project.photos = [...(project.photos || []), ...fileUrls];
    await project.save();

    return sendSuccess(res, 'Images uploaded successfully', { 
      photos: project.photos,
      newPhotos: fileUrls 
    });
  } catch (error: any) {
    logger.error(`Upload Images Error: ${error.message}`);
    next(error);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects/{id}/preview:
 *   post:
 *     summary: Generate an AI preview for the project (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Project ID
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               forceRegenerate:
 *                 type: boolean
 *                 description: Force regeneration of the image
 *     responses:
 *       200:
 *         description: AI Preview generated successfully
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
 *                 data:
 *                   type: object
 *                   properties:
 *                     previewUrl:
 *                       type: string
 *                     originalUrl:
 *                       type: string
 *                     isMock:
 *                       type: boolean
 *       404:
 *         description: Project not found
 *       500:
 *         description: Server error
 */
export const generateAIPreview = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const { id } = req.params;
    const project = await Project.findOne({ _id: id, createdBy: req.user._id as any });

    if (!project) {
      return sendError(res, 'Project not found or unauthorized', null, 404);
    }

    // Optimization: Return existing preview if available (saves cost)
    // Safe access to req.body in case it's undefined
    const forceRegenerate = req.body?.forceRegenerate;
    if (project.aiPreviewUrl && !forceRegenerate) {
      return sendSuccess(res, 'AI Preview retrieved from cache', { 
        previewUrl: project.aiPreviewUrl,
        originalUrl: project.photos?.[0] || '',
        isMock: false
      });
    }

    // Check if API key is valid (not placeholder)
    const apiKey = process.env.OPENAI_API_KEY;
    const isMock = !apiKey || apiKey.startsWith('sk-proj-placeholder') || apiKey === 'dummy';

    if (isMock) {
      logger.info('OpenAI API Key missing or placeholder. Using Mock Generation.');
      await delay(3000); // Simulate delay
      
      const mockPreviewUrl = 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80';
      project.aiPreviewUrl = mockPreviewUrl;
      project.status = 'under_review';
      await project.save();

      return sendSuccess(res, 'AI Preview generated successfully (Mock)', { 
        previewUrl: mockPreviewUrl,
        originalUrl: project.photos?.[0] || '',
        isMock: true
      });
    }

    // Real OpenAI Generation
    const style = project.stylePreferences?.style || 'Modern';
    const colors = project.stylePreferences?.colors?.join(', ') || 'Neutral';
    const space = project.spaceType || 'Living Room';
    const type = project.projectType || 'Residential';
    const location = project.location?.city ? ` in ${project.location.city}` : '';
    
    const materials = project.materials || {};
    const flooring = materials.flooring ? `, ${materials.flooring} flooring` : '';
    const walls = materials.walls ? `, ${materials.walls} walls` : '';
    const furniture = materials.furniture ? `, ${materials.furniture} furniture` : '';
    const lighting = materials.lighting ? materials.lighting : 'Ambient';

    // 1. Generate Optimized Prompt using GPT-3.5-Turbo
    // We use the "Master Prompt" template which instructs GPT to create a perfect DALL-E prompt
    const systemPrompt = generateInteriorDesignPrompt({
      style,
      space,
      projectType: type,
      location: location.replace(' in ', ''),
      colors,
      flooring,
      walls,
      furniture,
      lighting
    });

    // Initialize OpenAI client dynamically
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    // 1.5 Generate Optimized Prompt using GPT-3.5-Turbo
    // The "systemPrompt" is a set of instructions for GPT, NOT for DALL-E.
    const completion = await openai.chat.completions.create({
      messages: [{ role: 'system', content: systemPrompt }],
      model: 'gpt-3.5-turbo',
      temperature: 0.7,
      max_tokens: 300,
    });

    const optimizedPrompt = completion.choices[0].message.content || '';
    logger.info(`Generated Optimized Prompt: ${optimizedPrompt}`);

    if (!optimizedPrompt) {
      throw new Error('Failed to generate prompt from GPT');
    }
    console.log('optimizedPrompt', optimizedPrompt);
    // 2. Generate Image using DALL-E 2 with the optimized prompt
    // Use the already initialized client
    const response = await openai.images.generate({
      model: "dall-e-2", // Optimized for cost
      prompt: optimizedPrompt.substring(0, 1000), // Ensure limit
      n: 1,
      size: "1024x1024",
    });

    console.log('OpenAI Response:', response);

    if (!response || !response.data) {
      throw new Error('No response from OpenAI');
    }
    const imageUrl = response.data[0].url;
    
    if (!imageUrl) {
      throw new Error('Failed to generate image URL from OpenAI');
    }
    
    project.aiPreviewUrl = imageUrl;
    project.status = 'under_review';
    await project.save();

    return sendSuccess(res, 'AI Preview generated successfully', { 
      previewUrl: imageUrl,
      originalUrl: project.photos?.[0] || '',
      isMock: false
    });

  } catch (error: any) {
    logger.error(`AI Preview Error: ${error.message}`);
    
    // Log full error details for debugging
    if (error.response) {
      logger.error(`OpenAI API Error: ${JSON.stringify(error.response.data)}`);
    }

    // Return detailed error message to client
    const errorMessage = error.response?.data?.error?.message || error.message;
    return sendError(res, `Failed to generate AI preview: ${errorMessage}`, error, 500);
  }
};

/**
 * @swagger
 * /api/v1/mobile/projects/stats:
 *   get:
 *     summary: Get dashboard statistics (Mobile)
 *     tags: [Mobile]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics retrieved successfully
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
 *                 data:
 *                   type: object
 *                   properties:
 *                     activeProjects:
 *                       type: number
 *                     pendingQuotes:
 *                       type: number
 *                     revenue:
 *                       type: number
 *       500:
 *         description: Server error
 */
export const getDashboardStats = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) return sendError(res, 'User not authenticated', 401);
    const activeProjects = await Project.countDocuments({ status: { $in: ['approved', 'quoted'] }, createdBy: req.user._id as any });
    const pendingQuotes = await Project.countDocuments({ status: { $in: ['submitted', 'under_review'] }, createdBy: req.user._id as any });
    
    // Mock revenue for now
    const revenue = 1850000; // 18.5L

    return sendSuccess(res, 'Dashboard stats retrieved', {
      activeProjects,
      pendingQuotes,
      revenue
    });
  } catch (error: any) {
    logger.error(`Stats Error: ${error.message}`);
    next(error);
  }
};
