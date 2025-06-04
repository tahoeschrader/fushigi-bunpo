import os
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from contextlib import asynccontextmanager
from fushigi_db_tools.data.models import GrammarWrapper

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/fushigi")

engine = create_async_engine(DATABASE_URL, echo=True)

async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

@asynccontextmanager
async def get_session():
    async with async_session() as session:
        yield session
        
app = FastAPI()

@app.get("/grammar/{id}", response_model=GrammarWrapper)
async def get_grammar(id: int, session: AsyncSession = Depends(get_session)):
    result = await session.execute(text("SELECT data FROM grammar_point WHERE id = :id"), {"id": id})
    row = result.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    return GrammarWrapper.model_validate(row[0])  # row[0] is the JSONB 'data' field

@app.get("/grammar/", response_model=List[GrammarWrapper])
async def list_grammar(session: AsyncSession = Depends(get_session)):
    result = await session.execute(text("SELECT data FROM grammar_point ORDER BY id LIMIT 20"))
    return [GrammarWrapper.model_validate(row[0]) for row in result.fetchall()]
