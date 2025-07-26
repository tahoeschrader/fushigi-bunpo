from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .routes.grammar import router as grammar_router
from .routes.journal import router as journal_router

app = FastAPI()
app.include_router(journal_router)
app.include_router(grammar_router)

# Junk for now just to get some quick UI testing
from pathlib import Path
import os
import uvicorn

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

frontend_path = Path(os.getenv("FRONTEND_PATH", "/app/frontend"))
if frontend_path.exists():
    app.mount("/", StaticFiles(directory=frontend_path, html=True), name="frontend")
else:
    print(f"Static frontend path not found: {frontend_path}. Skipping mount.")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
