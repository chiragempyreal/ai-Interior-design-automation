import { Request, Response, NextFunction } from 'express';
import OpenAI from 'openai';
import Project from '../models/Project';
import Quote from '../models/Quote';
import CostConfig from '../models/CostConfig';
import logger from '../utils/logger';
import { sendSuccess, sendError } from '../utils/utilHelpers';
import { generateInteriorDesignPrompt, generateAnalysisPrompt } from '../utils/aiPrompts';

// Helper to delay for mock AI generation
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * @desc    Create a new project (Wizard Step 1)
 * @route   POST /api/v1/projects
 * @access  Public
 */
export const createProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, clientName, clientEmail, clientPhone, projectType } = req.body;

    // Basic validation
    if (!title || !clientName || !clientEmail) {
      return sendError(res, 'Please provide title, name and email', null, 400);
    }

    const project = await Project.create({
      title,
      clientName,
      clientEmail,
      clientPhone,
      projectType,
      status: 'draft'
    });

    return sendSuccess(res, 'Project created successfully', project, 201);
  } catch (error: any) {
    logger.error(`Create Project Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Update project details (Wizard Steps 2-7)
 * @route   PUT /api/v1/projects/:id
 * @access  Public (should be protected in prod with session/token)
 */
export const updateProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    let project = await Project.findById(id);

    if (!project) {
      return sendError(res, 'Project not found', null, 404);
    }

    // Remove fields that shouldn't be updated if empty/null
    const updateData = { ...req.body };
    if (!updateData.title) delete updateData.title; // Don't overwrite title with empty string
    if (!updateData.clientName) delete updateData.clientName;
    if (!updateData.clientEmail) delete updateData.clientEmail;

    // Update fields based on request body
    // Using simple spread for now, but in prod we might want specific field validation per step
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
 * @desc    Get single project
 * @route   GET /api/v1/projects/:id
 * @access  Public/Protected
 */
export const getProject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);

    if (!project) {
      return sendError(res, 'Project not found', null, 404);
    }

    return sendSuccess(res, 'Project retrieved successfully', project);
  } catch (error: any) {
    logger.error(`Get Project Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Get all projects (for Dashboard)
 * @route   GET /api/v1/projects
 * @access  Private (Designer/Admin)
 */
export const getProjects = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, limit } = req.query;
    
    let query: any = {};
    if (status) {
      query.status = status;
    }

    // If filtered by 'pending' for dashboard
    if (req.path.includes('pending')) {
      query.status = { $in: ['submitted', 'under_review'] };
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
 * @desc    Upload Project Images
 * @route   POST /api/v1/projects/:id/upload
 * @access  Public
 */
export const uploadProjectImages = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const files = req.files as Express.Multer.File[];

    if (!files || files.length === 0) {
      return sendError(res, 'No files uploaded', null, 400);
    }

    const project = await Project.findById(id);
    if (!project) {
      return sendError(res, 'Project not found', null, 404);
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
 * @desc    Generate AI Preview (OpenAI DALL-E 3)
 * @route   POST /api/v1/projects/:id/preview
 * @access  Public
 */
export const generateAIPreview = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const project = await Project.findById(id);

    if (!project) {
      return sendError(res, 'Project not found', null, 404);
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
    
    // START: PARALLEL GENERATION (Image + Smart Analysis)
    const imagePromise = openai.images.generate({
      model: "dall-e-2", // Optimized for cost
      prompt: optimizedPrompt.substring(0, 1000), // Ensure limit
      n: 1,
      size: "1024x1024",
    });

    const analysisPrompt = generateAnalysisPrompt({
      style,
      space,
      projectType: type,
      colors,
      materials: [flooring, walls, furniture, lighting].join(', '),
      area: project.area
    });

    const analysisPromise = openai.chat.completions.create({
      messages: [{ role: 'system', content: analysisPrompt }],
      model: 'gpt-3.5-turbo',
      temperature: 0.7,
      response_format: { type: "json_object" }
    });

    const [imageResponse, analysisResponse] = await Promise.all([imagePromise, analysisPromise]);

    // Process Image
    console.log('OpenAI Response:', imageResponse);
    if (!imageResponse || !imageResponse.data) {
      throw new Error('No response from OpenAI Image Generation');
    }
    const imageUrl = imageResponse.data[0].url;
    if (!imageUrl) {
      throw new Error('Failed to generate image URL from OpenAI');
    }

    // Process Analysis & Create Quote
    let analysisData: any = {};
    let totalEstimatedCost = 0;

    try {
      const content = analysisResponse.choices[0].message.content;
      if (content) {
        analysisData = JSON.parse(content);
        
        // Calculate Costs based on CostConfig
        const quoteItems = [];
        
        // Fetch all active cost configs
        const costConfigs = await CostConfig.find({ isActive: true });
        
        if (analysisData.items && Array.isArray(analysisData.items)) {
          for (const item of analysisData.items) {
            // Find matching config or default
            const config = costConfigs.find(c => 
              c.itemType.toLowerCase() === item.itemType.toLowerCase() || 
              c.category.toLowerCase() === item.category.toLowerCase()
            );
            
            const basePrice = config ? config.basePrice : 50; // Fallback price
            const laborCost = config ? config.laborCostPerUnit : 10;
            const unitPrice = basePrice + laborCost;
            const quantity = item.quantity || 1;
            const totalPrice = unitPrice * quantity;
            
            totalEstimatedCost += totalPrice;
            
            quoteItems.push({
              name: item.itemType,
              category: item.category,
              quantity: quantity,
              unitPrice: unitPrice,
              totalPrice: totalPrice
            });
          }

          // Create Quote
          if (quoteItems.length > 0) {
            await Quote.create({
              project: project._id as any,
              items: quoteItems,
              totalAmount: totalEstimatedCost,
              status: 'draft',
              validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
            });
          }
        }
      }
    } catch (parseError) {
      logger.error(`Failed to parse analysis JSON: ${parseError}`);
      // Continue without crashing, just missing analysis
    }

    project.aiPreviewUrl = imageUrl;
    project.status = 'under_review';
    project.aiDesignAnalysis = {
      rationale: analysisData.rationale || 'AI Analysis pending...',
      styleNotes: `Designed in ${style} style with ${colors} accents.`,
      colorPaletteExplanation: colors,
      estimatedCostRange: totalEstimatedCost > 0 
        ? `₹${Math.round(totalEstimatedCost * 0.9).toLocaleString('en-IN')} - ₹${Math.round(totalEstimatedCost * 1.1).toLocaleString('en-IN')}`
        : 'Calculated in Quote'
    };
    
    // Process ROI Analysis
    if (analysisData.roi && totalEstimatedCost > 0) {
      const multiplier = analysisData.roi.valueIncreaseMultiplier || 1.2;
      const estimatedIncrease = totalEstimatedCost * multiplier;
      
      project.roiAnalysis = {
        estimatedIncreaseInValue: Math.round(estimatedIncrease),
        roiPercentage: Math.round((multiplier - 1) * 100),
        investmentScore: analysisData.roi.investmentScore || 7,
        marketTrendAlignment: analysisData.roi.marketTrendAlignment || 'Stable'
      };
    }
    
    // Process Design DNA
    if (analysisData.designDNA) {
      project.designDNA = {
        personaName: analysisData.designDNA.personaName,
        personalityTraits: analysisData.designDNA.personalityTraits,
        colorPsychology: analysisData.designDNA.colorPsychology,
        recommendedScent: analysisData.designDNA.recommendedScent,
        playlistVibe: analysisData.designDNA.playlistVibe,
        colorPalette: analysisData.designDNA.colorPalette
      };
    }
    
    await project.save();

    return sendSuccess(res, 'AI Preview and Analysis generated successfully', { 
      previewUrl: imageUrl,
      originalUrl: project.photos?.[0] || '',
      analysis: project.aiDesignAnalysis,
      roi: project.roiAnalysis,
      designDNA: project.designDNA,
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
 * @desc    Get Dashboard Stats
 * @route   GET /api/v1/dashboard/stats
 * @access  Private
 */
export const getDashboardStats = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const activeProjects = await Project.countDocuments({ status: { $in: ['approved', 'quoted'] } });
    const pendingQuotes = await Project.countDocuments({ status: { $in: ['submitted', 'under_review'] } });
    
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
