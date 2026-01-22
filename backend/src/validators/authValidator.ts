import Joi from 'joi';

export const registerSchema = Joi.object({
  full_name: Joi.string().required(),
  email: Joi.string().email().optional(),
  phone: Joi.string().required(),
  password: Joi.string().min(6).required(),
  company_name: Joi.string().optional(),
  subscription: Joi.string().valid('free', 'pro', 'enterprise').default('free'),
});

export const loginSchema = Joi.object({
  phone: Joi.string().required(),
  password: Joi.string().required(),
});

export const requestPasswordResetSchema = Joi.object({
  email: Joi.string().email().required(),
});

export const resetPasswordSchema = Joi.object({
  token: Joi.string().required(),
  newPassword: Joi.string().min(6).required(),
});

export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required(),
});
