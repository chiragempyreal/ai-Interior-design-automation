import Joi from 'joi';

export const createProjectSchema = Joi.object({
  title: Joi.string().min(3).required().messages({
    'string.base': 'Title must be a string',
    'string.empty': 'Title cannot be empty',
    'string.min': 'Title should have a minimum length of 3',
    'any.required': 'Title is required',
  }),
  clientName: Joi.string().required().messages({
    'string.empty': 'Client Name cannot be empty',
    'any.required': 'Client Name is required',
  }),
  clientEmail: Joi.string().email().required().messages({
    'string.email': 'Valid Client Email is required',
    'any.required': 'Client Email is required',
  }),
  requirements: Joi.object().optional(),
  status: Joi.string().valid('draft', 'pending_approval', 'approved', 'rejected', 'completed').default('draft'),
});

export const updateProjectSchema = Joi.object({
  title: Joi.string().min(3),
  clientName: Joi.string(),
  clientEmail: Joi.string().email(),
  requirements: Joi.object(),
  status: Joi.string().valid('draft', 'pending_approval', 'approved', 'rejected', 'completed'),
});
