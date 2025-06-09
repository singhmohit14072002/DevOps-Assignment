from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "message": "Backend is running successfully"}

@app.get("/api/message")
async def get_message():
    return {"message": "You've successfully integrated the backend!"}

# Mount static files from the frontend build directory only if not in testing environment
if os.getenv("TESTING") != "true":
    app.mount("/", StaticFiles(directory="./frontend_build", html=True), name="frontend")
