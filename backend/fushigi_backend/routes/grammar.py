from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from psycopg import AsyncConnection

from fushigi_db_tools.data.models import GrammarInDB
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/api/grammar", tags=["grammar"])

@router.get("", response_model=List[GrammarInDB])
async def list_grammar(
    conn: AsyncConnection = Depends(get_connection),
) -> List[GrammarInDB]:
    params = []

    query = f"""
        SELECT id, usage, meaning, level, tags, notes, examples, enhanced_notes
        FROM grammar
        ORDER BY id
    """

    async with conn.cursor() as cur:
        await cur.execute(query, params)
        rows = await cur.fetchall()

        return [
            GrammarInDB.model_validate({
                "id": row["id"],
                "usage": row["usage"],
                "meaning": row["meaning"],
                "level": row["level"],
                "tags": row["tags"],
                "notes": row["notes"],
                "examples": row["examples"],
                "enhanced_notes": row["enhanced_notes"],
            })
            for row in rows
        ]
