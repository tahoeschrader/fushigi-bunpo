# Fushigi Kaiwa

Assistant for aiding conversational fluency for Japanese language.

Monorepo for backend, app, and tui. 

## Current Tasks
- [ ] Create simple test user
- [ ] Create actix-web endpoints for getting user and grammar
- [ ] Create login page in swift code
- [ ] Add logic to swift code to connect to postgres database
- [ ] Create login that checks database
- [ ] Select all grammar and display as a list, removing current json read logic
- [ ] Repeat same three tasks above for rust TUI 
- [ ] Create actix-web endpoints for creating journal entries and sentence tags
- [ ] Add logic to swift code for creating journal entries and sentence tags
- [ ] Repeat same task above for rust TUI
- [ ] Add data backup, export logic to JSON
- [ ] Add more complicated sorted/view logic
- [ ] Add actual password hashing/security features
- [ ] Try building CI/CD logic
- [ ] Try hosting database on AWS or my TuringPi
- [ ] Start thinking about commenting logic, community views, etc.

## Dream Features

- login page and data export
- display an opinionated source of grammar points, collected during my time at ISI Shibuya.
- create daily journal prompts via AI
- semi SRS-esque grammar suggester (5) from opinionated grammar source list
- sentence level tagging using suggested grammar points
- history view of older journal entries
- community view of other users journal entries
- commenting functionality
- sort grammar points, journal entries, or view sentence display based on tags
- sort tags, journal entries, or view sentence display based on grammar points
- daily conversation mode to show same set of (5) grammar points for all users

## Development

Make sure `sqlx` cli is installed as well as `postgres`. Then, make sure the postgres service is running:

```zsh
pg_ctl -D postgres_data status
```

If it isn't:

```zsh
initdb -D postgres_data
pg_ctl -D postgres_data -l logfile start
psql -d postgres
```

And then build the test database:

```sql
CREATE ROLE tester WITH LOGIN PASSWORD 'testpassword';
ALTER ROLE tester CREATEDB;
CREATE DATABASE fushigidb OWNER tester;
```

Finally, the migrations can be run:

```zsh
cargo sqlx migrate run --database-url postgres://tester:testpassword@localhost/fushigidb
```
