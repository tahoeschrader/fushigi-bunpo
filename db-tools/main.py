import asyncio
from db.connect import connect_to_db
from db.generate import generate_db
from data.load import load_defaults

# Tests
# TODO: add proper comments and doc generation to ci/cd
# TODO: add testing framework and step in ci/cd
# TODO: data model template has not changed
# TODO: default json deserializes to coded model
# TODO: a single grammar instance can be loaded into mocked db
# TODO: a single grammar model read out of mocked db matches coded model
# TODO: integration that checks if test database is active and returns total entries
# TODO: integration that checks if test database is active, and cofirms a single grammar instance
# TODO: if test database is not active, skip integration tests and show that in the test report

async def main():
    pool = await connect_to_db("postgres://tester:testpassword@localhost/fushigidb")
    grammar_data = load_defaults() 
    await generate_db(pool, grammar_data)

    print("Finished loading default grammar rules into Fushigi db!")

if __name__ == "__main__":
    asyncio.run(main())
