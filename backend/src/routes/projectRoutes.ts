import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import * as projectController from '../controllers/projectController';
import { protect } from '../middleware/authMiddleware';

const router = Router();

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/projects';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Dashboard / Admin Routes (Protected)
router.get('/stats', protect, projectController.getDashboardStats);
router.get('/pending', protect, projectController.getProjects); // Controller handles "pending" path check or query
router.get('/', protect, projectController.getProjects);

// Public Wizard Routes
router.post('/', projectController.createProject);
router.put('/:id', projectController.updateProject);
router.get('/:id', projectController.getProject);
router.post('/:id/upload', upload.array('photos', 5), projectController.uploadProjectImages);
router.post('/:id/preview', projectController.generateAIPreview);

export default router;
