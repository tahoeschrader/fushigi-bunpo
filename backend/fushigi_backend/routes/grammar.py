from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from psycopg import AsyncConnection
from psycopg.errors import DatabaseError
from psycopg.rows import dict_row

from fushigi_db_tools.data.models import GrammarInDB
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/api/grammar", tags=["grammar"])


@router.get("", response_model=List[GrammarInDB])
async def list_grammar(
    conn: AsyncConnection = Depends(get_connection),
    limit: Optional[bool] = False
) -> List[GrammarInDB]:

    params = {}
    if limit:
        query = f"""
                SELECT id, usage, meaning, level, tags, notes, examples, enhanced_notes
                FROM grammar
                ORDER BY RANDOM()
                LIMIT 5
            """  # noqa: F541
    else:
        query = f"""
            SELECT id, usage, meaning, level, tags, notes, examples, enhanced_notes
            FROM grammar
            ORDER BY id
        """  # noqa: F541

    try:
        async with conn.cursor(row_factory=dict_row) as cur:
            await cur.execute(query, params)
            rows = await cur.fetchall()
    except DatabaseError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {e}",
        )

    return [GrammarInDB.model_validate(row) for row in rows]
