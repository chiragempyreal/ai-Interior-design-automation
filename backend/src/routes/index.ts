import { Router } from 'express';
import projectRoutes from './projectRoutes';
import authRoutes from './authRoutes';
import mobileRoutes from './mobileRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/projects', projectRoutes);
router.use('/mobile', mobileRoutes);

export default router;
