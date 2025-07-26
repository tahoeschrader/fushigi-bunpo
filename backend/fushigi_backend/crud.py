from typing import List, Optional

from psycopg import AsyncConnection

from fushigi_db_tools.data.models import JournalEntryCreate, JournalEntryInDB


async def create_journal_entry(conn: AsyncConnection, entry: JournalEntryCreate) -> int:
    async with conn.transaction():
        result = await conn.execute(
            """
            INSERT INTO journal_entry (user_id, title, content)
            VALUES (%(user_id)s, %(title)s, %(content)s)
            RETURNING id
            """,
            {"user_id": 1, "title": entry.title, "content": entry.content},
        )
        row = await result.fetchone()
        if row is None:
            raise Exception("Failed to insert journal entry and get ID")
        entry_id = row[0]

        for sentence in entry.sentences:
            result = await conn.execute(
                """
                INSERT INTO sentence (journal_entry_id, content)
                VALUES (%(entry_id)s, %(content)s)
                RETURNING id
                """,
                {"entry_id": entry_id, "content": sentence.content},
            )
            row = await result.fetchone()
            if row is None:
                raise Exception("Failed to insert sentence and get ID")
            sentence_id = row[0]

            for tag in sentence.tagged_grammar:
                await conn.execute(
                    """
                    INSERT INTO tagged_sentence (sentence_id, grammar_id)
                    VALUES (%(sid)s, %(gid)s)
                    """,
                    {"sid": sentence_id, "gid": tag.grammar_id},
                )

    return entry_id


async def get_journal_entry(
    conn: AsyncConnection, entry_id: int
) -> Optional[JournalEntryInDB]:
    result = await conn.execute(
        """
        SELECT id, user_id, title, content, created_at
        FROM journal_entry
        WHERE id = %(id)s AND user_id = %(uid)s
        """,
        {"id": entry_id, "uid": 1},
    )
    row = await result.fetchone()
    if row is None:
        return None

    entry = {
        "id": row[0],
        "user_id": row[1],
        "title": row[2],
        "content": row[3],
        "created_at": row[4].isoformat(),
        "sentences": [],
    }

    result = await conn.execute(
        "SELECT id, content FROM sentence WHERE journal_entry_id = %(id)s",
        {"id": entry_id},
    )
    sentences = await result.fetchall()

    for s_id, content in sentences:
        tag_result = await conn.execute(
            "SELECT grammar_id FROM tagged_sentence WHERE sentence_id = %(sid)s",
            {"sid": s_id},
        )
        grammar_ids = [row[0] for row in await tag_result.fetchall()]
        entry["sentences"].append(
            {
                "id": s_id,
                "content": content,
                "tagged_grammar": [{"grammar_id": gid} for gid in grammar_ids],
            }
        )

    return JournalEntryInDB(**entry)


async def list_journal_entries(
    conn: AsyncConnection, limit=20, offset=0
) -> List[JournalEntryInDB]:
    result = await conn.execute(
        """
        SELECT id, user_id, title, content, created_at
        FROM journal_entry
        WHERE user_id = %(uid)s
        ORDER BY created_at DESC
        LIMIT %(limit)s OFFSET %(offset)s
        """,
        {"uid": 1, "limit": limit, "offset": offset},
    )
    rows = await result.fetchall()
    return [
        JournalEntryInDB(
            id=row[0],
            user_id=row[1],
            title=row[2],
            content=row[3],
            created_at=row[4].isoformat(),
            sentences=[],  # Lazy-load or omit sentences here
        )
        for row in rows
    ]
