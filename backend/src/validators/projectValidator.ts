import Joi from 'joi';

export const createProjectSchema = Joi.object({
  title: Joi.string().required(),
  clientName: Joi.string().required(),
  clientEmail: Joi.string().email().required(),
  clientPhone: Joi.string().optional(),
  projectType: Joi.string().valid('Residential', 'Commercial').default('Residential'),
  propertyType: Joi.string().optional(),
  spaceType: Joi.string().optional(),
  area: Joi.number().optional(),
  location: Joi.object({
    city: Joi.string().optional(),
    pincode: Joi.string().optional(),
    address: Joi.string().optional()
  }).optional(),
  budget: Joi.object({
    min: Joi.number().optional(),
    max: Joi.number().optional()
  }).optional(),
  timeline: Joi.string().optional(),
  stylePreferences: Joi.object({
    style: Joi.string().optional(),
    colors: Joi.array().items(Joi.string()).optional()
  }).optional(),
  materials: Joi.object({
    flooring: Joi.string().optional(),
    walls: Joi.string().optional(),
    furniture: Joi.string().optional(),
    lighting: Joi.string().optional()
  }).optional(),
  photos: Joi.array().items(Joi.string()).optional(),
  aiPreviewUrl: Joi.string().optional(),
  status: Joi.string().valid('draft', 'submitted', 'under_review', 'quoted', 'approved', 'completed').default('draft')
});

export const updateProjectSchema = Joi.object({
  title: Joi.string().optional(),
  clientName: Joi.string().optional(),
  clientEmail: Joi.string().email().optional(),
  clientPhone: Joi.string().optional(),
  projectType: Joi.string().valid('Residential', 'Commercial').optional(),
  propertyType: Joi.string().optional(),
  spaceType: Joi.string().optional(),
  area: Joi.number().optional(),
  location: Joi.object({
    city: Joi.string().optional(),
    pincode: Joi.string().optional(),
    address: Joi.string().optional()
  }).optional(),
  budget: Joi.object({
    min: Joi.number().optional(),
    max: Joi.number().optional()
  }).optional(),
  timeline: Joi.string().optional(),
  stylePreferences: Joi.object({
    style: Joi.string().optional(),
    colors: Joi.array().items(Joi.string()).optional()
  }).optional(),
  materials: Joi.object({
    flooring: Joi.string().optional(),
    walls: Joi.string().optional(),
    furniture: Joi.string().optional(),
    lighting: Joi.string().optional()
  }).optional(),
  photos: Joi.array().items(Joi.string()).optional(),
  aiPreviewUrl: Joi.string().optional(),
  status: Joi.string().valid('draft', 'submitted', 'under_review', 'quoted', 'approved', 'completed').optional()
});
