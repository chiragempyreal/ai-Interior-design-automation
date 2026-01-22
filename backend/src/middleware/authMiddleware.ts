import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/db';
import { IUser } from '../models/User';
import * as authService from '../services/authService';
import { sendError } from '../utils/utilHelpers';

interface AuthRequest extends Request {
  user?: IUser;
}

export const protect = async (req: AuthRequest, res: Response, next: NextFunction) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return sendError(res, 'Not authorized to access this route', null, 401);
  }

  try {
    const decoded: any = jwt.verify(token, config.jwtSecret);
    const user = await authService.findUserById(decoded.sub);

    if (!user) {
      return sendError(res, 'No user found with this id', null, 401);
    }

    req.user = user;
    next();
  } catch (err) {
    return sendError(res, 'Not authorized to access this route', null, 401);
  }
};
