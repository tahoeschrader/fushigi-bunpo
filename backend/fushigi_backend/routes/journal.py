from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from psycopg import AsyncConnection
from psycopg.errors import DatabaseError
from psycopg.rows import dict_row

from fushigi_db_tools.data.models import (
    JournalEntry,
    JournalEntryInDB,
)
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/api/journal", tags=["journal"])


@router.post("", response_model=int)
async def create_journal_entry(
    entry: JournalEntry,
    conn: AsyncConnection = Depends(get_connection),
):
    print("ENTRY TYPE:", type(entry))
    print("ENTRY FIELDS:", entry.model_dump())
    async with conn.transaction():
        async with conn.cursor(row_factory=dict_row) as cur:
            print(entry)
            await cur.execute(
                """
                INSERT INTO journal_entry (user_id, title, content, private)
                VALUES (%(user_id)s, %(title)s, %(content)s, %(private)s)
                RETURNING id
                """,
                {
                    "user_id": 1,  # temporary
                    "title": entry.title,
                    "content": entry.content,
                    "private": entry.private,
                },
            )
            row = await cur.fetchone()
            if row is None:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Failed to insert journal entry and get ID",
                )
            entry_id = row["id"]

    return entry_id


@router.get("", response_model=List[JournalEntryInDB])
async def list_journal_entries(
    conn: AsyncConnection = Depends(get_connection),
) -> List[JournalEntryInDB]:
    params = {"uid": 1}

    query = f"""
        SELECT id, user_id, title, content, created_at, private
        FROM journal_entry
        WHERE user_id = %(uid)s
        ORDER BY created_at DESC
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

    return [JournalEntryInDB.model_validate(row) for row in rows]
