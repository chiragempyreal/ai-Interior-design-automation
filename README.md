# AI Interior Design Automation System

This project consists of three main components:

1.  **Admin Panel**: React (Next.js) + Material UI
2.  **Backend**: Node.js + Express + MongoDB + Redis
3.  **Web App**: React (Vite) + Tailwind CSS

## Prerequisites

- Node.js (v18+)
- Docker & Docker Compose
- MongoDB (if running locally without Docker)
- Redis (if running locally without Docker)

## Quick Start (Docker)

To start the entire system using Docker Compose:

```bash
docker-compose up --build
```

This will start:
- Backend API at `http://localhost:5001`
- Admin Panel at `http://localhost:3000`
- Web App at `http://localhost:80` (mapped to port 80)
- MongoDB at `mongodb://localhost:27017`
- Redis at `redis://localhost:6379`

## Manual Setup

### Backend

```bash
cd backend
npm install
npm run seed # Seed database with sample data
npm run dev
```

### Admin Panel

```bash
cd admin-panel
npm install
npm run dev
```

### Web App

```bash
cd web-app
npm install
npm run dev
```

## Documentation

- **API Documentation**: Available at `http://localhost:5000/api-docs` when backend is running.
