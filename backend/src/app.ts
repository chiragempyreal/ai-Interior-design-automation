import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';
import swaggerJsDoc from 'swagger-jsdoc';
import logger from './utils/logger';
import routes from './routes';
import { sendSuccess, sendError } from './utils/utilHelpers';

const app: Application = express();

const corsOptions = {
  origin: true, // Allow any origin
  credentials: true, // Allow cookies/headers
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept']
};

import path from 'path';

// Middleware
app.use(cors(corsOptions));
// app.options('*', cors(corsOptions)); // Removed to fix Express 5 / path-to-regexp error. global cors() handles OPTIONS.

app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));

// Serve Uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Swagger Config
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'AI Interior Design API',
      version: '1.0.0',
      description: 'API for Interior Design Automation and Auto Quote System',
    },
    servers: [
      {
        url: 'http://localhost:5001',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/*.ts', './src/controllers/*.ts'],
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Routes
app.use('/api/v1', routes);

// Health Check
app.get('/health', (req: Request, res: Response) => {
  return sendSuccess(res, 'UP', { timestamp: new Date().toISOString() });
});

// Global Error Handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  logger.error(err.stack);

  // Mongoose Validation Error
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((val: any) => val.message);
    return sendError(res, 'Validation Error', messages, 400);
  }

  // Mongoose Cast Error (Invalid ID)
  if (err.name === 'CastError') {
    return sendError(res, 'Resource not found', null, 404);
  }

  // Duplicate Key Error
  if (err.code === 11000) {
    return sendError(res, 'Duplicate field value entered', null, 400);
  }

  return sendError(res, 'Internal Server Error', err.message, 500);
});

export default app;
