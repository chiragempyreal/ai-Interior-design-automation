import { Request, Response, NextFunction } from 'express';
import { IUser } from '../models/User';
import { sendError } from '../utils/utilHelpers';

export const authorize = (...roles: string[]) => {
  return (req: Request & { user?: any }, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.role_id) {
        return sendError(res, 'User role not found', null, 403);
    }
    
    // req.user.role_id is populated object with name
    const userRole = req.user.role_id.name;

    if (!roles.includes(userRole)) {
      return sendError(res, `User role ${userRole} is not authorized to access this route`, null, 403);
    }
    next();
  };
};
