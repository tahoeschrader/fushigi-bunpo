from typing import List

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from fushigi_db_tools.data.models import GrammarWrapper

app = FastAPI()


@app.get("/grammar/{id}", response_model=GrammarWrapper)
async def get_grammar(
    id: int, session: AsyncSession = Depends(get_session)
) -> GrammarWrapper:
    result = await session.execute(
        text("SELECT data FROM grammar_point WHERE id = :id"), {"id": id}
    )
    row = result.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    return GrammarWrapper.model_validate(row[0])  # row[0] is the JSONB 'data' field


@app.get("/grammar/", response_model=List[GrammarWrapper])
async def list_grammar(
    session: AsyncSession = Depends(get_session),
) -> List[GrammarWrapper]:
    result = await session.execute(
        text("SELECT data FROM grammar_point ORDER BY id LIMIT 20")
    )
    return [GrammarWrapper.model_validate(row[0]) for row in result.fetchall()]
