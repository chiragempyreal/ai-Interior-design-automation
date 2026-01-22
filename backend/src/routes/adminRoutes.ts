import { Router } from 'express';
import * as adminController from '../controllers/adminController';
import * as quoteController from '../controllers/quoteController';
import { protect } from '../middleware/authMiddleware';
import { authorize } from '../middleware/roleMiddleware';

const router = Router();

/**
 * @swagger
 * /admin/login:
 *   post:
 *     summary: Admin Login
 *     tags: [Admin]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 */
router.post('/login', adminController.adminLogin);

// Protect all routes
router.use(protect);
router.use(authorize('admin'));

/**
 * @swagger
 * tags:
 *   name: Admin
 *   description: Admin Management
 */

/**
 * @swagger
 * /admin/stats:
 *   get:
 *     summary: Get system wide statistics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: System statistics
 */
router.get('/stats', adminController.getSystemStats);

/**
 * @swagger
 * /admin/projects:
 *   get:
 *     summary: Get all projects
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of projects
 */
router.get('/projects', adminController.getProjects);

/**
 * @swagger
 * /admin/users:
 *   get:
 *     summary: Get all users
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of users
 */
router.get('/users', adminController.getUsers);

/**
 * @swagger
 * /admin/users/{id}:
 *   delete:
 *     summary: Delete a user (soft delete)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User deleted successfully
 */
router.delete('/users/:id', adminController.deleteUser);

/**
 * @swagger
 * /admin/profile:
 *   put:
 *     summary: Update admin profile
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               full_name:
 *                 type: string
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated
 */
router.put('/profile', adminController.updateProfile);

/**
 * @swagger
 * /admin/change-password:
 *   put:
 *     summary: Change admin password
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - currentPassword
 *               - newPassword
 *             properties:
 *               currentPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password updated
 */
router.put('/change-password', adminController.changePassword);

/**
 * @swagger
 * /admin/quotes/generate:
 *   post:
 *     summary: Generate AI Quote
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - projectId
 *             properties:
 *               projectId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Quote generated
 */
router.post('/quotes/generate', quoteController.generateQuote);

/**
 * @swagger
 * /admin/quotes/{id}:
 *   put:
 *     summary: Update Quote Items
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - items
 *             properties:
 *               items:
 *                 type: array
 *     responses:
 *       200:
 *         description: Quote updated
 */
router.put('/quotes/:id', quoteController.updateQuote);

/**
 * @swagger
 * /admin/quotes/{id}/preview:
 *   post:
 *     summary: Preview Quote (Generate PDF)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Quote preview generated
 */
router.post('/quotes/:id/preview', quoteController.previewQuote);

/**
 * @swagger
 * /admin/quotes/{id}/finalize:
 *   post:
 *     summary: Finalize Quote (Generate PDF & Send)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Quote finalized
 */
router.post('/quotes/:id/finalize', quoteController.finalizeQuote);

export default router;
