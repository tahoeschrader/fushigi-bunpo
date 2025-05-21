# Fushigi Kaiwa

Assistant for aiding conversational fluency for Japanese language.

Monorepo for backend, database build tools, frontend, and tui. 

## Current Tasks

- [x] Flesh out grammar points using OpenAI tools
- [x] Bootstrap project with placeholder docker-compose
- [x] Define database model (bare minimum)
- [x] Generate empty database from scratch
- [ ] Implement backend API
- [ ] Convert swift code to sveltekit (or decide not to?)
- [ ] Implement a sveltekit frontend that works as PWA (or swift?)
- [ ] Create login and user features with proper password storage/hashing
- [ ] Learn about how to deal with persisting data in the database during rebuilds
- [ ] Build CI/CD logic on github or convert to gitea/woodpecker/idk
- [ ] Start thinking about community features
- [ ] Try hosting database on AWS
- [ ] Slowly start fixing up grammar source with better tags
- [ ] Slowly start implementing better sort features in frontends
- [ ] Start thinking about implementing a tui frontend with rust
- [ ] Try hosting database on TuringPi

## Dream Features

- login page and data export
- display an opinionated source of grammar points, collected during my time at ISI.
- create daily journal prompts via AI
- semi SRS-esque grammar suggester (5) from opinionated grammar source list
- sentence level tagging using suggested grammar points
- history view of older journal entries
- community view of other users journal entries
- commenting functionality
- sort grammar points, journal entries, or example sentences based on tags
- sort tags, journal entries, or view sentence display based on grammar points
- daily conversation mode to show same set of (5) grammar points for all users synced across app

## Development

Install `uv` to manage python virtual environments. Then, source and lock dependencies via:

```shell
cd this/project/sub/repo
uv venv
source .venv/bin/activate
uv sync
```

When new dependencies are added to the project:

```shell
uv pip install ".[dev]"
uv lock
```

Build, test, and run:

```shell
uv pip freeze > requirements.txt # (optional: needed for Docker)
docker compose up --build
```
