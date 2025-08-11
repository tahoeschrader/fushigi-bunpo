import asyncio

from .data.load import load_defaults
from .db.connect import connect_to_db
from .db.generate import generate_db


async def main() -> None:
    pool = await connect_to_db()
    grammar_data = load_defaults()
    await generate_db(pool, grammar_data)

    print("Finished loading default grammar rules into Fushigi db!")


if __name__ == "__main__":
    asyncio.run(main())
