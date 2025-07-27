from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes.grammar import router as grammar_router
from .routes.journal import router as journal_router

app = FastAPI()
app.include_router(journal_router)
app.include_router(grammar_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
