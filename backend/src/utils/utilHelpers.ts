import { Response } from 'express';

interface SuccessResponse {
  success: boolean;
  message: string;
  data?: any;
}

interface ErrorResponse {
  success: boolean;
  message: string;
  error?: any;
}

export const sendSuccess = (res: Response, message: string, data?: any, statusCode: number = 200) => {
  const response: SuccessResponse = {
    success: true,
    message,
    data,
  };
  return res.status(statusCode).json(response);
};

export const sendError = (res: Response, message: string, error?: any, statusCode: number = 500) => {
  const response: ErrorResponse = {
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? error : undefined,
  };
  return res.status(statusCode).json(response);
};

export const sendEmail = async (options: { email: string; subject: string; message: string }) => {
  // Mock email sending
  console.log(`Email sent to ${options.email}: ${options.subject} - ${options.message}`);
  return true;
};
