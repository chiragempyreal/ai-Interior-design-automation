import { Router } from 'express';
import projectRoutes from './projectRoutes';
import authRoutes from './authRoutes';
import adminRoutes from './adminRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/projects', projectRoutes);
router.use('/admin', adminRoutes);

export default router;
