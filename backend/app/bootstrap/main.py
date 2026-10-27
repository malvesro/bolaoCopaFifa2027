import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.modules.identity.local_admin import router as local_admin_router

app = FastAPI(
    title="Bolão Copa 2027",
    version="0.1.0",
    description="API do Bolão da Copa do Mundo Feminina",
)

app.include_router(local_admin_router)

cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to Bolão Copa 2027 API"}

@app.get("/live")
async def liveness():
    return {"status": "ok", "service": "bolao-backend"}

@app.get("/ready")
async def readiness():
    # In a real app, this would check database connections
    return {"status": "ready"}
