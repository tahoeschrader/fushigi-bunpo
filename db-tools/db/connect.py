import psycopg
from psycopg import AsyncConnection

async def connect_to_db(db_url: str) -> AsyncConnection:
    connection = await psycopg.AsyncConnection.connect(db_url)
    return connection
