# Multi-stage Dockerfile for FastAPI backend and Next.js frontend

# --- Stage 1: Frontend Build ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package.json and install dependencies
COPY frontend/package.json frontend/yarn.lock* frontend/package-lock.json* ./
RUN npm install --frozen-lockfile

# Copy the rest of the frontend application code
COPY frontend/ ./

# Build the Next.js application (outputs to 'out' directory with static export)
RUN npm run build

# --- Stage 2: Backend and Serve Frontend ---
FROM python:3.9-slim-buster

WORKDIR /app

# Install backend dependencies
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application code
COPY backend/ ./

# Copy built frontend static assets from the frontend-builder stage
COPY --from=frontend-builder /app/frontend/out ./frontend_build

# Expose port 8000
EXPOSE 8000

# Run the FastAPI application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"] 