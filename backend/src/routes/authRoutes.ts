import { Router } from 'express';
import * as authController from '../controllers/authController';
import requestValidator from '../middleware/requestValidatorMiddleware';
import { registerSchema, loginSchema, sendOtpSchema, verifyOtpSchema, refreshTokenSchema, requestPasswordResetSchema, resetPasswordSchema } from '../validators/authValidator';

const router = Router();

router.post('/register', requestValidator(registerSchema), authController.register);
router.post('/login', requestValidator(loginSchema), authController.login);
router.post('/send-otp', requestValidator(sendOtpSchema), authController.sendOtp);
router.post('/verify-otp', requestValidator(verifyOtpSchema), authController.verifyOtp);
router.post('/refresh-token', requestValidator(refreshTokenSchema), authController.refreshToken);
router.post('/forgot-password', requestValidator(requestPasswordResetSchema), authController.forgotPassword);
router.post('/reset-password', requestValidator(resetPasswordSchema), authController.resetPassword);

export default router;
