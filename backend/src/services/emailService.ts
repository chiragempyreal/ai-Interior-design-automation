import nodemailer from 'nodemailer';
import logger from '../utils/logger';
import dotenv from 'dotenv';
import path from 'path';

const envPath = path.join(__dirname, '../../.env');
dotenv.config({ path: envPath });

// Create a transporter
// For production, configure these in .env
const transporter = nodemailer.createTransport({
  service: process.env.SMTP_SERVICE, // e.g. 'gmail'
  host: process.env.SMTP_HOST || 'smtp.ethereal.email',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER || 'ethereal_user', 
    pass: process.env.SMTP_PASS || 'ethereal_pass', 
  },
});

export const sendQuoteEmail = async (
  to: string,
  subject: string,
  html: string,
  attachmentPath?: string
) => {
  try {
    const mailOptions: any = {
      from: process.env.SMTP_FROM || '"InteriAI" <no-reply@interiai.com>',
      to,
      subject,
      html,
    };

    if (attachmentPath) {
      mailOptions.attachments = [
        {
          filename: 'Quote.pdf',
          path: attachmentPath,
        },
      ];
    }

    const info = await transporter.sendMail(mailOptions);

    logger.info(`Email sent: ${info.messageId}`);
    // Preview only available when sending through an Ethereal account
    logger.info(`Preview URL: ${nodemailer.getTestMessageUrl(info)}`);
    
    return info;
  } catch (error) {
    logger.error('Error sending email:', error);
    // In dev/hackathon, don't throw if email fails, just log it.
    // throw error; 
  }
};
