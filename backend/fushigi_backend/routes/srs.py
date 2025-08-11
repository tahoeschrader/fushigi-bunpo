from fastapi import APIRouter, Depends, HTTPException, status
from psycopg import AsyncConnection
from psycopg.errors import DatabaseError
from psycopg.rows import dict_row
from datetime import date, timedelta
from typing import List, Dict

from ..data.models import GrammarInDB, SRSReview
from ..db.connect import get_connection

router = APIRouter(prefix="/api/srs", tags=["srs"])

@router.get("/daily", response_model=List[GrammarInDB])
async def get_daily_srs(user_id: int, conn: AsyncConnection = Depends(get_connection)):
    params = (user_id, date.today())
    query = """
        SELECT gp.*
        FROM srs
        JOIN grammar gp ON srs.grammar_id = gp.id
        WHERE srs.user_id = %s
          AND srs.repetition > 0
          AND srs.due_date <= %s
        ORDER BY srs.due_date, srs.ease_factor
        LIMIT 5
    """
    try:
        async with conn.cursor(row_factory=dict_row) as cur:
            await cur.execute(query, params)
            reviews = await cur.fetchall()
    except DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

    count = len(reviews)
    if count < 5:
        needed = 5 - count
        params_new = (user_id, needed)
        query_new = """
            SELECT gp.*
            FROM srs
            JOIN grammar gp ON srs.grammar_id = gp.id
            WHERE srs.user_id = %s
              AND srs.repetition = 0
            ORDER BY RANDOM()
            LIMIT %s
        """
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                await cur.execute(query_new, params_new)
                new = await cur.fetchall()
                reviews.extend(new)
        except DatabaseError as e:
            raise HTTPException(status_code=500, detail=f"Database error: {e}")

    return [GrammarInDB.model_validate(row) for row in reviews]

@router.post("/review")
async def submit_srs_review(review: SRSReview, conn: AsyncConnection = Depends(get_connection)):
    params = (review.user_id, review.grammar_id)
    select_query = "SELECT * FROM srs WHERE user_id = %s AND grammar_id = %s"

    try:
        async with conn.cursor(row_factory=dict_row) as cur:
            await cur.execute(select_query, params)
            record = await cur.fetchone()
        if record is None:
            raise HTTPException(status_code=404, detail="SRS record not found")

        updated = sm2_update(
            ease_factor=record["ease_factor"],
            interval_days=record["interval_days"],
            repetition=record["repetition"],
            quality=review.quality,
        )

        update_query = """
            UPDATE srs SET
                ease_factor = %s,
                interval_days = %s,
                repetition = %s,
                due_date = %s,
                last_reviewed = CURRENT_DATE
            WHERE id = %s
        """
        update_params = (
            updated["ease_factor"],
            updated["interval_days"],
            updated["repetition"],
            updated["due_date"],
            record["id"],
        )

        async with conn.cursor() as cur:
            await cur.execute(update_query, update_params)
            await conn.commit()

    except DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

    return {"message": "SRS updated"}

def sm2_update(
    ease_factor: float,
    interval_days: int,
    repetition: int,
    quality: int,
) -> Dict[str, object]:
    """
    SM-2 SRS algorithm update.

    Args:
        ease_factor: current ease factor
        interval_days: current interval in days
        repetition: how many successful repetitions so far
        quality: integer 0-5 rating (5=perfect)

    Returns:
        dict with updated ease_factor, interval_days, repetition, due_date
    """
    if quality < 3:
        repetition = 0
        interval_days = 1
    else:
        if repetition == 0:
            interval_days = 1
        elif repetition == 1:
            interval_days = 6
        else:
            interval_days = int(interval_days * ease_factor)
        repetition += 1

    ease_factor += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)
    ease_factor = max(ease_factor, 1.3)

    due_date = date.today() + timedelta(days=interval_days)
    return {
        "ease_factor": ease_factor,
        "interval_days": interval_days,
        "repetition": repetition,
        "due_date": due_date,
    }
