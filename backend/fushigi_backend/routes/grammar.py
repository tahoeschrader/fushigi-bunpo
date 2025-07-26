from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from psycopg import AsyncConnection

from fushigi_db_tools.data.models import Grammar
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/grammar", tags=["grammar"])


@router.get("/{id}", response_model=Grammar)
async def get_grammar(
    id: int, conn: AsyncConnection = Depends(get_connection)
) -> Grammar:
    async with conn.cursor() as cur:
        await cur.execute("SELECT data FROM grammar_point WHERE id = %s", (id,))
        row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Not found")
    return Grammar.model_validate(row[0])


@router.get("/", response_model=List[Grammar])
async def list_grammar(
    level: Optional[str] = Query(None),
    tag: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    conn: AsyncConnection = Depends(get_connection),
) -> List[Grammar]:
    filters = []
    params = []

    if level:
        filters.append("data->>'level' = %s")
        params.append(level)

    if tag:
        filters.append("%s = ANY (data->'tags')")
        params.append(tag)

    if search:
        filters.append("(data->>'usage' ILIKE %s OR data->>'meaning' ILIKE %s)")
        params.extend([f"%{search}%", f"%{search}%"])

    where_clause = f"WHERE {' AND '.join(filters)}" if filters else ""
    query = f"""
        SELECT data
        FROM grammar_point
        {where_clause}
        ORDER BY id
        LIMIT %s OFFSET %s
    """
    params.extend([limit, offset])

    async with conn.cursor() as cur:
        await cur.execute(query, params)
        rows = await cur.fetchall()
        return [Grammar.model_validate(row[0]) for row in rows]
