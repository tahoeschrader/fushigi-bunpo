from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query
from psycopg import AsyncConnection

from fushigi_backend import crud
from fushigi_db_tools.data.models import (
    JournalEntryCreate,
    JournalEntryInDB,
)
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/journal", tags=["journal"])


@router.post("/", response_model=int)
async def create_journal_entry_api(
    entry: JournalEntryCreate,
    conn: AsyncConnection = Depends(get_connection),
):
    return await crud.create_journal_entry(conn, entry)


@router.get("/{entry_id}", response_model=JournalEntryInDB)
async def get_journal_entry_api(
    entry_id: int,
    conn: AsyncConnection = Depends(get_connection),
):
    entry = await crud.get_journal_entry(conn, entry_id)
    if entry is None:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    return entry


@router.get("/", response_model=List[JournalEntryInDB])
async def list_journal_entries_api(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    conn: AsyncConnection = Depends(get_connection),
):
    return await crud.list_journal_entries(conn, limit=limit, offset=offset)
