import { Request, Response, NextFunction } from 'express';
import Project from '../models/Project';
import Quote from '../models/Quote';
import CostConfig from '../models/CostConfig';
import { sendSuccess, sendError } from '../utils/utilHelpers';
import logger from '../utils/logger';
import { generateQuotePDF } from '../utils/pdfGenerator';
import OpenAI from 'openai';
import { generateAnalysisPrompt } from '../utils/aiPrompts';
import path from 'path';
import { sendQuoteEmail } from '../services/emailService';

/**
 * @desc    Generate AI Quote (Draft)
 * @route   POST /api/v1/admin/quotes/generate
 * @access  Private (Admin)
 */
export const generateQuote = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { projectId } = req.body;

    if (!projectId) {
      return sendError(res, 'Project ID is required', null, 400);
    }

    const project = await Project.findById(projectId);
    if (!project) {
      return sendError(res, 'Project not found', null, 404);
    }

    // 1. Check if we need to run AI Analysis (if not present)
    // For now, assume we use existing analysis or re-run logic.
    
    // Re-run Analysis to get Itemized List
    const style = project.stylePreferences?.style || 'Modern';
    const space = project.spaceType || 'Living Room';
    const type = project.projectType || 'Residential';
    const colors = project.stylePreferences?.colors?.join(', ') || 'Neutral';
    const materials = project.materials || {};
    const materialsStr = [materials.flooring, materials.walls, materials.furniture, materials.lighting].filter(Boolean).join(', ');
    const area = project.area || 200;

    const analysisPrompt = generateAnalysisPrompt({
      style,
      space,
      projectType: type,
      colors,
      materials: materialsStr,
      area
    });

    const apiKey = process.env.OPENAI_API_KEY;
    const isMock = !apiKey || apiKey.startsWith('sk-proj-placeholder') || apiKey === 'dummy';
    
    let items: any[] = [];

    if (isMock) {
        // Mock Items
        items = [
            { category: 'Flooring', itemType: 'Engineered Wood', quantity: area, unit: 'sqft' },
            { category: 'Wall', itemType: 'Premium Emulsion', quantity: area * 3, unit: 'sqft' },
            { category: 'Furniture', itemType: 'Sofa Set', quantity: 1, unit: 'set' },
            { category: 'Lighting', itemType: 'Chandelier', quantity: 1, unit: 'pc' }
        ];
    } else {
        const openai = new OpenAI({ apiKey });
        const analysisResponse = await openai.chat.completions.create({
            messages: [{ role: 'system', content: analysisPrompt }],
            model: 'gpt-3.5-turbo',
            temperature: 0.7,
            response_format: { type: "json_object" }
        });
        const content = analysisResponse.choices[0].message.content;
        if (content) {
            const parsed = JSON.parse(content);
            items = parsed.items || [];
        }
    }

    // 2. Calculate Costs
    const costConfigs = await CostConfig.find({ isActive: true });
    const quoteItems = [];
    let totalEstimatedCost = 0;

    for (const item of items) {
        // Find matching config or default
        const config = costConfigs.find(c => 
          c.itemType.toLowerCase() === item.itemType.toLowerCase() || 
          c.category.toLowerCase() === item.category.toLowerCase()
        );
        
        const basePrice = config ? config.basePrice : 50; 
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

    // 3. Create Quote
    // Check if quote exists, update or create
    let quote = await Quote.findOne({ project: projectId });
    if (quote) {
        quote.items = quoteItems;
        quote.totalAmount = totalEstimatedCost;
        quote.version += 1;
        quote.status = 'draft'; // Admin generated it, waiting for review
        quote.validUntil = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    } else {
        quote = new Quote({
            project: projectId,
            items: quoteItems,
            totalAmount: totalEstimatedCost,
            status: 'draft',
            validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        });
    }

    await quote.save();

    // DO NOT Generate PDF yet. Let Admin edit first.

    // Update Project Status
    project.status = 'quoted';
    await project.save();

    return sendSuccess(res, 'Quote draft generated successfully', quote);

  } catch (error: any) {
    logger.error(`Generate Quote Error: ${error.message}`);
    next(error);
  }
};

/**
 * @desc    Update Quote Items
 * @route   PUT /api/v1/admin/quotes/:id
 * @access  Private (Admin)
 */
export const updateQuote = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const { items } = req.body;

        if (!items || !Array.isArray(items)) {
            return sendError(res, 'Items array is required', null, 400);
        }

        const quote = await Quote.findById(id);
        if (!quote) {
            return sendError(res, 'Quote not found', null, 404);
        }

        // Recalculate totals
        let totalAmount = 0;
        const newItems = items.map((item: any) => {
            const quantity = Number(item.quantity) || 0;
            const unitPrice = Number(item.unitPrice) || 0;
            const totalPrice = quantity * unitPrice;
            totalAmount += totalPrice;
            
            return {
                name: item.name,
                category: item.category,
                quantity,
                unitPrice,
                totalPrice
            };
        });

        quote.items = newItems;
        quote.totalAmount = totalAmount;
        quote.version += 1;
        await quote.save();

        return sendSuccess(res, 'Quote updated successfully', quote);
    } catch (error: any) {
        logger.error(`Update Quote Error: ${error.message}`);
        next(error);
    }
};

/**
 * @desc    Preview Quote (Generate PDF only)
 * @route   POST /api/v1/admin/quotes/:id/preview
 * @access  Private (Admin)
 */
export const previewQuote = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        
        const quote = await Quote.findById(id).populate('project');
        if (!quote) {
            return sendError(res, 'Quote not found', null, 404);
        }

        const project = quote.project as any;
        if (!project) {
             return sendError(res, 'Project associated with quote not found', null, 404);
        }

        // Generate PDF
        const pdfUrl = await generateQuotePDF(quote, project);
        quote.pdfUrl = pdfUrl;
        // Status remains draft or whatever it was
        await quote.save();

        return sendSuccess(res, 'Quote PDF generated for preview', { pdfUrl });
    } catch (error: any) {
        logger.error(`Preview Quote Error: ${error.message}`);
        next(error);
    }
};

/**
 * @desc    Finalize Quote (Generate PDF & Send)
 * @route   POST /api/v1/admin/quotes/:id/finalize
 * @access  Private (Admin)
 */
export const finalizeQuote = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        
        const quote = await Quote.findById(id).populate('project');
        if (!quote) {
            return sendError(res, 'Quote not found', null, 404);
        }

        const project = quote.project as any;
        if (!project) {
             return sendError(res, 'Project associated with quote not found', null, 404);
        }

        // Ensure PDF is up to date (regenerate)
        const pdfUrl = await generateQuotePDF(quote, project);
        quote.pdfUrl = pdfUrl;
        quote.status = 'sent';
        await quote.save();

        // Send Email
        if (project.clientEmail) {
            const subject = `Your Interior Design Quote - ${project.title}`;
            const html = `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <h2 style="color: #333;">Hello ${project.clientName},</h2>
                    <p>We have prepared a detailed quote for your project <strong>${project.title}</strong>.</p>
                    <p>Please find the attached PDF for the cost breakdown and details.</p>
                    <p>Total Estimated Cost: <strong>$${quote.totalAmount.toLocaleString()}</strong></p>
                    <br/>
                    <p>Best Regards,</p>
                    <p><strong>InteriAI Team</strong></p>
                </div>
            `;
            
            // Construct absolute path for attachment
            const relativePath = pdfUrl.startsWith('/') ? pdfUrl.substring(1) : pdfUrl;
            const attachmentPath = path.join(process.cwd(), relativePath);
            
            await sendQuoteEmail(project.clientEmail, subject, html, attachmentPath);
        }

        return sendSuccess(res, 'Quote finalized and sent successfully', quote);
    } catch (error: any) {
        logger.error(`Finalize Quote Error: ${error.message}`);
        next(error);
    }
};

/**
 * @desc    Get Quote for Project
 * @route   GET /api/v1/quotes/:projectId
 * @access  Private
 */
export const getQuoteByProject = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { projectId } = req.params;
        const quote = await Quote.findOne({ project: projectId as any });
        
        if (!quote) {
            return sendError(res, 'Quote not found', null, 404);
        }

        return sendSuccess(res, 'Quote retrieved', quote);
    } catch (error: any) {
        logger.error(`Get Quote Error: ${error.message}`);
        next(error);
    }
};
