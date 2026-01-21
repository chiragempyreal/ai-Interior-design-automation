import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import * as mobileController from '../controllers/mobileController';
import { protect } from '../middleware/authMiddleware';
import requestValidator from '../middleware/requestValidatorMiddleware';
import { createProjectSchema, updateProjectSchema } from '../validators/projectValidator';

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

router.use(protect);

router.get('/stats', mobileController.getDashboardStats);
router.get('/', mobileController.getProjects);
router.post('/', requestValidator(createProjectSchema), mobileController.createProject);
router.put('/:id', requestValidator(updateProjectSchema), mobileController.updateProject);
router.get('/:id', mobileController.getProject);
router.post('/:id/upload', upload.array('photos', 5), mobileController.uploadProjectImages);
router.post('/:id/preview', mobileController.generateAIPreview);

export default router;
