# Fushigi Kaiwa

Assistant for aiding conversational fluency for Japanese language.

Monorepo for backend, database build tools, frontend, and tui. 

## Current Tasks

- [ ] Edit grammar points to be more helpful (actually spoken often vs mostly written etc.)
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

Install `uv` to manage python virtual environments and requirements. Docker is also using the `uv` platform.

This simplifies the dev process to the following:

```shell Set up local dev environment
cd this/repo
uv venv
source .venv/bin/activate
uv sync --dev
```

```shell Build, test, and run
cd this/repo
docker compose up --build
```

```shell Locally test and run
cd sub/repo/project
uv run pytest
uv run python -m main
```

Whenever new dependencies are added to subfolder `pyproject.toml`, remember to `uv lock` from the root to update the lockfile. 
