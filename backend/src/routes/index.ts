import { Router } from 'express';
import projectRoutes from './projectRoutes';
import authRoutes from './authRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/projects', projectRoutes);

export default router;
