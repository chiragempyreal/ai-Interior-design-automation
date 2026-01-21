import Joi from 'joi';

export const registerSchema = Joi.object({
  full_name: Joi.string().required(),
  email: Joi.string().email().optional(),
  phone: Joi.string().required(),
  password: Joi.string().min(6).required(),
  company_name: Joi.string().optional(),
  subscription: Joi.string().valid('free', 'pro', 'enterprise').default('free'),
});

export const sendOtpSchema = Joi.object({
  phone: Joi.string().required().messages({
    'string.empty': 'Phone number is required',
    'any.required': 'Phone number is required',
  }),
});

export const loginSchema = Joi.object({
  phone: Joi.string().required().messages({
    'string.empty': 'Phone number is required',
    'any.required': 'Phone number is required',
  }),
  password: Joi.string().required().messages({
    'string.empty': 'Password is required',
    'any.required': 'Password is required',
  }),
});

export const verifyOtpSchema = Joi.object({
  phone: Joi.string().required().messages({
    'string.empty': 'Phone number is required',
    'any.required': 'Phone number is required',
  }),
  otp: Joi.string().required().length(6).messages({
    'string.empty': 'OTP is required',
    'string.length': 'OTP must be 6 digits',
    'any.required': 'OTP is required',
  }),
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
