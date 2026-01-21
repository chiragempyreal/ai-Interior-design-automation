import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { sendError } from '../utils/utilHelpers';

const requestValidator = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    // Validate request body
    const { error, value } = schema.validate(req.body);
    
    if (error) {
      return sendError(res, error.details[0].message, null, 400);
    }
    
    // Replace body with validated/sanitized value
    req.body = value;

    next();
  };
};

export default requestValidator;