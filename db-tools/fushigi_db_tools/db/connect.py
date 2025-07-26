import os
from typing import AsyncGenerator, Optional

import psycopg
from psycopg import AsyncConnection
from psycopg.rows import dict_row
from psycopg_pool import AsyncConnectionPool

DATABASE_URL = os.environ["DATABASE_URL"]
_pool: Optional[AsyncConnectionPool] = None

def get_pool() -> AsyncConnectionPool:
    global _pool
    if _pool is None:
        _pool = AsyncConnectionPool(DATABASE_URL)
    return _pool

async def connect_to_db(db_url: str) -> AsyncConnection:
    connection = await psycopg.AsyncConnection.connect(db_url)
    return connection


async def get_connection() -> AsyncGenerator[AsyncConnection, None]:
    pool = get_pool()
    async with pool.connection() as conn:
        conn.row_factory = dict_row
        yield conn
