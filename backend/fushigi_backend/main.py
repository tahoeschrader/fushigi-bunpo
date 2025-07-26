from fastapi import FastAPI

from .routes.grammar import router as grammar_router
from .routes.journal import router as journal_router

app = FastAPI()
app.include_router(journal_router)
app.include_router(grammar_router)
