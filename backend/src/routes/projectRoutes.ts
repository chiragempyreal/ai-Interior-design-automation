import { Router } from 'express';
import * as projectController from '../controllers/projectController';
import { protect } from '../middleware/authMiddleware';

const router = Router();

router.use(protect);

router.get('/', protect, projectController.getProjects);
router.post('/', protect, projectController.createProject);

export default router;
