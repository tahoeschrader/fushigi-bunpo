from typing import List

from psycopg import AsyncConnection
from psycopg.types.json import Json

from ..data.models import Grammar


async def generate_db(conn: AsyncConnection, grammar_data: List[Grammar]) -> None:
    async with conn.cursor() as cur:
        for g in grammar_data:
            await cur.execute(
                """
                INSERT INTO grammar
                    (usage, meaning, level, tags, notes, examples, enhanced_notes)
                VALUES
                    (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    g.usage,
                    g.meaning,
                    g.level,
                    g.tags,
                    g.notes,
                    Json(
                        [e.model_dump() for e in g.examples]
                    ),  # like json dumps for jsonb type in db
                    Json(g.enhanced_notes.model_dump()),  # same
                ),
            )
        await conn.commit()
