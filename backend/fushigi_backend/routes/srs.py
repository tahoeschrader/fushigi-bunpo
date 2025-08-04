from fastapi import APIRouter, Depends, HTTPException, status
from psycopg import AsyncConnection
from psycopg.errors import DatabaseError
from psycopg.rows import dict_row
from datetime import date
from typing import List

from fushigi_db_tools.data.models import GrammarInDB, SRSReview
from fushigi_db_tools.db.connect import get_connection

router = APIRouter(prefix="/api/srs", tags=["srs"])

@router.get("/daily", response_model=List[GrammarInDB])
async def get_daily_srs(user_id: int, conn: AsyncConnection = Depends(get_connection)):
    # Get up to 5 due review cards (repetition > 0 and due today or earlier)
    params = {"user_id": user_id, "today": date.today()}
    
    query = f"""
        SELECT gp.*
        FROM srs
        JOIN grammar gp ON srs.grammar_id = gp.id
        WHERE srs.user_id = :user_id
          AND srs.repetition > 0
          AND srs.due_date <= :today
        ORDER BY srs.due_date, srs.ease_factor
        LIMIT 5
    """  # noqa: F541

    try:
       async with conn.cursor(row_factory=dict_row) as cur:
            await cur.execute(query, params)
            reviews = await cur.fetchall()
    except DatabaseError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {e}",
        )
    
    count = len(reviews)
    
    if count < 5:
        # If fewer than 5, get new cards (repetition == 0) to fill
        needed = 5 - count
        params_new = {"user_id": user_id, "needed": needed}
        query_new = f"""
            SELECT gp.*
            FROM srs
            JOIN grammar gp ON srs.grammar_id = gp.id
            WHERE srs.user_id = :user_id
              AND srs.repetition = 0
            ORDER BY RANDOM()
            LIMIT :needed
        """  # noqa: F5421

        try:
           async with conn.cursor(row_factory=dict_row) as cur:
                await cur.execute(query_new, params_new)
                new = await cur.fetchall()
                reviews.extend(new)
        except DatabaseError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database error: {e}",
            )
        
    # Return combined list, mapped to Pydantic model
    return [GrammarInDB.model_validate(row) for row in reviews]

@router.post("/review")
async def submit_srs_review(review: SRSReview, conn: AsyncConnection = Depends(get_connection)):
    # Fetch existing SRS record
    params = {"user_id": review.user_id, "gp_id": review.grammar_id}
    
    query = f"SELECT * FROM srs WHERE user_id = :user_id AND grammar_id = :gp_id"  # noqa: F5421
    async with conn.cursor(row_factory=dict_row) as cur:
        await cur.execute(query, params)
        record = await cur.fetchone()
    if record is None:
        raise HTTPException(status_code=404, detail="SRS record not found")

    # Run SM-2 update logic
    updated = sm2_update(
        ease_factor=srs_record.ease_factor,
        interval_days=srs_record.interval_days,
        repetition=srs_record.repetition,
        quality=review.quality,
    )

    # Update DB record
    await session.execute(
        """
        UPDATE srs SET
            ease_factor = :ease_factor,
            interval_days = :interval_days,
            repetition = :repetition,
            due_date = :due_date,
            last_reviewed = CURRENT_DATE
        WHERE id = :id
        """,
        {
            "ease_factor": updated["ease_factor"],
            "interval_days": updated["interval_days"],
            "repetition": updated["repetition"],
            "due_date": updated["due_date"],
            "id": srs_record.id,
        }
    )
    await session.commit()
    return {"message": "SRS updated"}

from datetime import date, timedelta

def sm2_update(ease_factor: float, interval_days: int, repetition: int, quality: int):
    """
    SM-2 SRS algorithm update.

    - quality: integer 0-5 rating (5=perfect)
    - repetition: how many successful repetitions so far
    - ease_factor: current ease factor
    - interval_days: current interval in days

    Returns updated ease_factor, interval_days, repetition, due_date.
    """
    if quality < 3:
        # Repeat immediately: reset repetition and interval
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

    # Update ease factor
    ease_factor += (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
    if ease_factor < 1.3:
        ease_factor = 1.3

    due_date = date.today() + timedelta(days=interval_days)

    return {
        "ease_factor": ease_factor,
        "interval_days": interval_days,
        "repetition": repetition,
        "due_date": due_date,
    }
