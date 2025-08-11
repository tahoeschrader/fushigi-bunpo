import os
from typing import AsyncGenerator, Optional

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


async def connect_to_db() -> AsyncConnection:
    return await AsyncConnection.connect(DATABASE_URL)


async def get_connection() -> AsyncGenerator[AsyncConnection, None]:
    pool = get_pool()
    async with pool.connection() as conn:
        conn.row_factory = dict_row  # type: ignore[assignment]
        yield conn
